﻿-----------------------------------------------------------------
-- SCRIPT TO TRANSFERT THE CURRENT DATABASE TO THE NEW DATABASE
-----------------------------------------------------------------

-- This will take the data from the current sea table which was built on the wise EU layer


insert into ref.tr_sea_sea 
(select distinct on (emu_sea)
emu_hyd_syst_o as sea_o, 
emu_hyd_syst_s as sea_s,
 emu_sea as sea_code  from carto.t_emu_emu
 where emu_sea is not null);


-----------------------------------
-- TODO insert definitions
------------------------------------

insert into ref.tr_lifestage_lfs select 'G' , lfs_name,  lfs_definition from ts.tr_lifestage_lfs where lfs_name='glass eel';
insert into ref.tr_lifestage_lfs select 'Y' , lfs_name,  lfs_definition from ts.tr_lifestage_lfs where lfs_name='yellow eel';
insert into ref.tr_lifestage_lfs select 'S' , lfs_name,  lfs_definition from ts.tr_lifestage_lfs where lfs_name='silver eel';
insert into ref.tr_lifestage_lfs select 'YS' , lfs_name,  lfs_definition from ts.tr_lifestage_lfs where lfs_name='yellow + silver eel';
insert into ref.tr_lifestage_lfs select 'GY' , lfs_name,  lfs_definition from ts.tr_lifestage_lfs where lfs_name='glass eel + yellow eel';

update ref.tr_lifestage_lfs set lfs_name='yellow eel+ silver eel' where lfs_name='yellow + silver eel';

/*
Insert definition for stages
*/

update ref.tr_lifestage_lfs set  lfs_definition ='' from ts.tr_lifestage_lfs where lfs_code='G';
update ref.tr_lifestage_lfs set  lfs_definition ='' from ts.tr_lifestage_lfs where lfs_code='Y';
update ref.tr_lifestage_lfs set  lfs_definition ='' from ts.tr_lifestage_lfs where lfs_code='S';
update ref.tr_lifestage_lfs set  lfs_definition ='' from ts.tr_lifestage_lfs where lfs_code='YS';
update ref.tr_lifestage_lfs set  lfs_definition ='A mixture of glass and yellow eel, some traps have historical set of data where glass eel and yellow eel were not separated,
they were dominated by glass eel' from ts.tr_lifestage_lfs where lfs_code='GY';


--------------------------
-- tr_emu_emu
-------------------------
insert into ref.tr_emu_emu select distinct on (emu_name_short) * from carto.emu;


--------------------------
-- tr_emu_emu
-------------------------
delete from ref.tr_emu_emu;
insert into ref.tr_emu_emu select distinct on (emu_name_short) * from carto.emu;
--select emu_name_short,emu_name,emu_coun_abrev from ref.tr_emu_emu order by emu_coun_abrev,emu_name_short


insert into  ref.tr_emu_emu (emu_name_short,emu_coun_abrev) 
select cou_code||'_total',cou_code from ref.tr_country_cou ;--44 lines inserted

insert into ref.tr_emu_emu (emu_name_short,emu_coun_abrev) 
select cou_code||'_outside_emu',cou_code from ref.tr_country_cou ;-- 44 lines inserted


--------------------------
-- tr_country_coun
-------------------------
--select * from ref.tr_country_cou;
insert into ref.tr_country_cou select distinct on ("order") * from carto.country_order order by "order"; -- 44





--------------------------
-- ref.tr_emusplit_ems
-------------------------
insert into ref.tr_emusplit_ems (
  gid, 
  emu_name_short, 
  emu_name, 
  emu_coun_abrev, 
  emu_hyd_syst_s, 
  emu_sea, 
  sum, 
  geom, 
  centre, 
  x, 
  y, 
  emu_cty_id, 
  meu_dist_sargasso_km)

select   
  t_emuagreg_ema.gid, 
  t_emuagreg_ema.emu_name_short, 
  t_emuagreg_ema.emu_name, 
  t_emuagreg_ema.emu_coun_abrev, 
  t_emuagreg_ema.emu_hyd_syst_s, 
  t_emuagreg_ema.emu_sea, 
  t_emuagreg_ema.sum, 
  t_emuagreg_ema.geom, 
  t_emuagreg_ema.centre, 
  t_emuagreg_ema.y, 
  t_emuagreg_ema.x, 
  t_emuagreg_ema.emu_cty_id, 
  t_emuagreg_ema.dist_sargasso_km 
  from carto.t_emuagreg_ema;-- 126 lines inserted
--------------------------
-- tr_habitattype_hty
-------------------------
delete from ref.tr_habitattype_hty;
insert into ref.tr_habitattype_hty (hty_code,hty_description) values ('F','Freshwater');
insert into ref.tr_habitattype_hty (hty_code,hty_description) values ('T','WFD Transitional water - implies reduced salinity');
insert into ref.tr_habitattype_hty (hty_code,hty_description) values ('C','WFD Coastal water');
insert into ref.tr_habitattype_hty (hty_code,hty_description) values ('MO','Marine water (open sea)');

----------------------
-- tr_units_uni
---------------------
delete from ref.tr_units_uni;
insert into ref.tr_units_uni values('kg','weight in kilogrammes');
insert into ref.tr_units_uni values('nr','number');
insert into ref.tr_units_uni values('index','calculated value following a specified protocol');
insert into ref.tr_units_uni values('t','weight in tonnes');
insert into ref.tr_units_uni values('nr/h','number per hour');
insert into ref.tr_units_uni values('nr/m2','number per square meter');
insert into ref.tr_units_uni values('kg/d','kilogramme per day');
insert into ref.tr_units_uni values('kg/boat/d','kilogramme per boat per day');
insert into ref.tr_units_uni values('nr haul','number of haul'); -- effort unit used for recruitment
insert into ref.tr_units_uni values('nr electrofishing','number of electrofishing campain in the year to collect the recruitment index');

---------------------
-- data.t_series_ser 
---------------------

/*
select * from ts.t_location_loc
select * from data.t_series_ser
*/

/*
--- before launching to check join and create case when script
 select * from ref.tr_units_uni right  join 
  (select lower(rec_unit::text) unit from ts.t_recruitment_rec) lowercaserec 
  on lowercaserec.unit=uni_code

select distinct rec_lfs_name from ts.t_recruitment_rec
select * from ref.tr_lifestage_lfs 
 */

INSERT INTO  data.t_series_ser
 (ser_id, 
  ser_order, 
  ser_nameshort, 
  ser_namelong, 
  -- ser_typ_id, update using join with data
  ser_comment, 
  ser_uni_code, 
  ser_lfs_code, 
  ser_habitat_name, 
  ser_emu_name_short, 
  ser_cou_code, 
  ser_x, 
  ser_y, 
  geom)
  SELECT
  rec_loc_id AS ser_id, 
  rec_order AS ser_order, 
  rec_nameshort AS ser_nameshort, 
  rec_namelong AS ser_namelong, 
  coalesce(t_location_loc.loc_comment,'')||t_recruitment_rec.rec_remark AS ser_comment, -- to avoid problems with null
  CASE WHEN rec_unit='eel/m2' THEN 'nr/m2'
       WHEN rec_unit='cpue' THEN 'kg/boat/d'
       WHEN rec_unit='Number' THEN 'nr'
       WHEN rec_unit='nb/h' THEN 'nr/h'
  ELSE lower(rec_unit) END AS ser_uni_code, 
  CASE WHEN rec_lfs_name='glASs eel' THEN 'G'
	WHEN rec_lfs_name='yellow eel' THEN 'Y' 
	WHEN rec_lfs_name='glASs eel + yellow eel' THEN 'GY'
	ELSE NULL END AS ser_lfs_code,
  rec_location AS ser_habitat_name, 
  CASE WHEN loc_emu_name_short='NO_Norw' THEN 'NO_total'
  ELSE loc_emu_name_short
  END AS  ser_emu_name_short, 
  cou_code AS ser_cou_code, 
  loc_x AS ser_x, 
  loc_y AS ser_y, 
  the_geom AS geom
FROM 
  ts.t_location_loc, 
  ts.t_recruitment_rec,
  ref.tr_country_cou
WHERE 
 t_location_loc.loc_id=t_recruitment_rec.rec_loc_id
 AND t_location_loc.loc_country= tr_country_cou.cou_country
 ORDER BY ser_id;--49






  select * 
 