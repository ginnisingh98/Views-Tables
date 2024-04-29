--------------------------------------------------------
--  DDL for Package Body HR_LEG_INSTALLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_LEG_INSTALLATION_PKG" as
/* $Header: hrlegins.pkb 115.5 2004/03/17 04:47:01 divicker ship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : hrlegins.pkb
 Description   : procedures required for installation of legislations
 Author        : T.Battoo
 Date Created  : 19-May-1999

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 17-MAR-2004 D.Vickers       115.5              Bug 3513091. User user_
                                                as called with virtual apps
 28-JUN-2001 D.Vickers       115.3              correct ghr status
 19-May-1999 T.Battoo	     115.0		created
*/

 procedure insert_row(p_application_short_name varchar2,
                      p_legislation_code varchar2,
                      p_status varchar2,
                      p_action varchar2,
                      p_pi_steps_exist varchar2,
                      p_view_name varchar2,
                      p_created_by varchar2,
                      p_creation_date date,
                      p_last_update_login varchar2,
                      p_last_update_date date,
                      p_last_updated_by varchar2) is
 begin
 INSERT INTO  hr_legislation_installations
   (application_short_name,
   legislation_code,
   status,
   action,
   pi_steps_exist,
   view_name,
   created_by,
   creation_date,
   last_update_login,
   last_update_date,
   last_updated_by)
  SELECT
   p_application_short_name,
   p_legislation_code,
   p_status,
   p_action,
   p_pi_steps_exist,
   p_view_name,
   p_created_by,
   p_creation_date,
   p_last_update_login,
   p_last_update_date,
   p_last_updated_by
 from dual
 WHERE not exists (select 1 from hr_legislation_installations
	           where application_short_name=p_application_short_name
		   and nvl(p_legislation_code,'x')=nvl(legislation_code,'x'));
 end;

 procedure update_row(p_application_short_name varchar2,
		      p_legislation_code varchar2,
		      p_status varchar2,
		      p_action varchar2,
                      p_created_by varchar2,
                      p_creation_date date,
                      p_last_update_login varchar2,
                      p_last_update_date date,
                      p_last_updated_by varchar2) is
 begin

 UPDATE hr_legislation_installations
 SET status=p_status,
     action=p_action,
     created_by=p_created_by,
     creation_date=p_creation_date,
     last_update_login=p_last_update_login,
     last_update_date=p_last_update_date,
     last_updated_by=p_last_updated_by
 WHERE application_short_name=p_application_short_name
 and nvl(p_legislation_code,'x')=nvl(legislation_code,'x');

 end;


 procedure drop_view(p_product varchar2,p_legislation varchar2) is
  l_view_name varchar2(256);
  view_exists varchar2(256);
  statem          varchar2(256);
  sql_curs        number;
  rows_processed  integer;
 begin
  select view_name
  into l_view_name
  from hr_legislation_installations
  where application_short_name=p_product
  and nvl(p_legislation,'x')=nvl(legislation_code,'x');


  -- check to see if view exists --
  select view_name
  into view_exists
  from user_views
  where view_name = l_view_name
  and rownum=1;

  statem := 'DROP VIEW ' || l_view_name ;
  sql_curs := dbms_sql.open_cursor;
  dbms_sql.parse(sql_curs,
                statem,
                dbms_sql.v7);
  rows_processed := dbms_sql.execute(sql_curs);
  dbms_sql.close_cursor(sql_curs);


  exception
   when no_data_found then return;

 end;


 procedure create_view(p_product varchar2,p_legislation varchar2) is
  l_view_name varchar2(256);
  statem          varchar2(256);
  sql_curs        number;
  rows_processed  integer;
 begin

  select view_name
  into l_view_name
  from hr_legislation_installations
  where application_short_name=p_product
  and nvl(p_legislation,'x')=nvl(legislation_code,'x');

  statem := 'CREATE OR REPLACE FORCE VIEW ' || l_view_name ||'(product_implemented) AS SELECT ''product_implemented'' from dual';
  sql_curs := dbms_sql.open_cursor;
  dbms_sql.parse(sql_curs,
                statem,
                dbms_sql.v7);
  rows_processed := dbms_sql.execute(sql_curs);
  dbms_sql.close_cursor(sql_curs);

  exception
   when no_data_found then return;
 end;

 procedure check_existing_data is
  pay_installed   number := 0;
  hr_installed    number := 0;
  ghr_installed   number := 0;
  school_data_installed number:=0;
  no_tax_rules    integer;
  l_leg_code      varchar2(256);

  cursor legislations is
  select distinct legislation_code
  from pay_element_classifications
  where legislation_code in ('GB','US','JP');
 begin
--set hr_installed variable
   select count(*)
   into hr_installed
   from fnd_product_installations
   where  application_id=800 and status='I';
--set pay_installed variable
   select  count(*)
   into pay_installed
   from fnd_product_installations
   where  application_id=801 and status='I';
--set ghr_installed variable
   select  count(*)
   into ghr_installed
   from fnd_product_installations
   where  application_id=8301 and status='I';
--
   -- set ghr row
   if ghr_installed <> 0 then
     update_row('GHR', 'US', 'I', NULL,NULL,NULL,NULL,NULL,NULL);
   end if;
   if hr_installed <> 0 then
   update_row('PER',NULL,'I',NULL,NULL,NULL,NULL,NULL,NULL);
   for leg_codes in legislations loop
     update_row('PER',leg_codes.legislation_code,'I',NULL,NULL,NULL,NULL,NULL,NULL);
     -- school data views
    if pay_installed=1 then
     update_row('PAY',leg_codes.legislation_code,'I',NULL,NULL,NULL,NULL,NULL,NULL);
    end if;
    if leg_codes.legislation_code in ('US','GB') then
      school_data_installed:=0;
      select  count(*)
      into school_data_installed
      from per_establishments
      where rownum=1;
      if school_data_installed <> 0 then
        update_row('CM',leg_codes.legislation_code,'I',NULL,NULL,NULL,NULL,NULL,NULL);
      end if;
    end if;
   end loop;
  end if;
 end;

 procedure set_existing_data is
  cursor installed_data is
  select application_short_name,legislation_code
  from hr_legislation_installations
  where status='I' ;
 begin
   for installed_leg in installed_data loop
     create_view(installed_leg.application_short_name,installed_leg.legislation_code);
   end loop;
 end;

end;

/
