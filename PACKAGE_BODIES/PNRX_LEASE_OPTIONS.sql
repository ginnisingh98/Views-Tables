--------------------------------------------------------
--  DDL for Package Body PNRX_LEASE_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_LEASE_OPTIONS" AS
/* $Header: PNRXLOPB.pls 120.2 2005/12/01 14:37:22 appldev ship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : PN_LEASE_OPTIONS
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_payment_terms with _ALL table.
-- 27-OCT-05  sdmahesh o ATG Mandated changes for SQL literals
-------------------------------------------------------------------------------
PROCEDURE pn_lease_options(
          lease_number_low                  IN                 VARCHAR2,
          lease_number_high                 IN                 VARCHAR2,
          location_code_low                 IN                 VARCHAR2,
          location_code_high                IN                 VARCHAR2,
          lease_responsible_user            IN                 VARCHAR2,
          option_type                       IN                 VARCHAR2,
          exer_window_termination_from      IN                 DATE,
          exer_window_termination_to        IN                 DATE,
          lease_termination_from            IN                 DATE,
          lease_termination_to              IN                 DATE,
          l_request_id                      IN                 NUMBER,
          l_user_id                         IN                 NUMBER,
          retcode                           OUT NOCOPY         VARCHAR2,
          errbuf                            OUT NOCOPY         VARCHAR2
                   )
 IS
   l_login_id                                                  NUMBER;
   type cur_typ is ref cursor;
   c_lease_pn                                                  CUR_TYP;
   c_loc_pn                                                    CUR_TYP;
   c_options_pn                                                CUR_TYP;
   c_currency_pn                                               CUR_TYP;
   query_str                                                   VARCHAR2(20000);
 --declare the 'where clauses here........'
   lease_number_where_clause                                   VARCHAR2(4000);
   location_code_where_clause                                  VARCHAR2(4000);
   l_location_date_clause                                      VARCHAR2(4000);
   les_resp_user_where_clause                                  VARCHAR2(4000);
   option_type_where_clause                                    VARCHAR2(4000);
   lease_date_where_clause                                     VARCHAR2(4000);
   exer_date_where_clause                                      VARCHAR2(4000);
   l_one                                                       NUMBER default 1;
   l_two                                                       NUMBER default 2;
   l_three                                                     NUMBER default 3;
   l_four                                                      NUMBER default 4;
   l_five                                                      NUMBER default 5;
   l_six                                                       NUMBER default 6;
 --declare all columns as variables here
   V_LEASE_ID                                                  NUMBER;
   V_LEASE_NAME                                                VARCHAR2(50);
   V_LEASE_NUMBER                                              VARCHAR2(30);
   V_LEASE_COM_DATE                                            DATE;
   V_LEASE_TERM_DATE                                           DATE;
   V_LEASE_EXE_DATE                                            DATE;
   V_LEASE_TERM                                                NUMBER;
   V_LEASE_CLASS                                               VARCHAR2(80);
   V_LEASE_RESP_USER                                           VARCHAR2(100);
   V_LEASE_STATUS                                              VARCHAR2(80);
   V_LEASE_TYPE                                                VARCHAR2(80);
   V_ESTIMATED_OCCUPANCY_DATE                                  DATE;
   V_ACTUAL_OCCUPANCY_DATE                                     DATE;
   V_LOCATION_ID                                               NUMBER;
   V_LOCATION_ID_1                                             NUMBER;
   V_LOCATION_TYPE                                             VARCHAR2(80);
   V_LOCATION_NAME                                             VARCHAR2(30);
   V_LOCATION_CODE                                             VARCHAR2(90);
   V_SPACE_TYPE                                                VARCHAR2(30);
   V_PROPERTY_CODE                                             VARCHAR2(90);
   V_REGION_NAME                                               VARCHAR2(50);
   V_ADDRESS                                                   VARCHAR2(1500);
   V_COUNTY                                                    VARCHAR2(60);
   V_CITY                                                      VARCHAR2(60);
   V_STATE                                                     VARCHAR2(60);
   V_PROVINCE                                                  VARCHAR2(60);
   V_ZIP_CODE                                                  VARCHAR2(60);
   V_COUNTRY                                                   VARCHAR2(60);
   V_RENTABLE_AREA                                             NUMBER;
   V_USABLE_AREA                                               NUMBER;
   V_GROSS_AREA                                                NUMBER;
   V_TENURE                                                    VARCHAR2(80);
   V_OPTION_ID                                                 NUMBER;
   V_OPTION_TYPE                                               VARCHAR2(80);
   V_OPTION_STATUS                                             VARCHAR2(80);
   V_OPTION_TERM                                               NUMBER;
   V_REFERENCE                                                 VARCHAR2(15);
   V_OPTION_NOTICE_REQD                                        VARCHAR2(1);
   V_OPTION_ACTION_DATE                                        DATE;
   V_OPTION_SIZE                                               NUMBER;
   V_OPTION_COST                                               VARCHAR2(15);
   V_UOM_CODE                                                  VARCHAR2(3);
   V_OPTION_AREA_CHANGE                                        NUMBER;
   V_OPTION_CURRENCY                                           VARCHAR2(15);
   V_OPTION_EXER_START_DATE                                    DATE;
   V_OPTION_EXER_END_DATE                                      DATE;
   V_OPTION_COMM_DATE                                          DATE;
   V_OPTION_EXP_DATE                                           DATE;
   V_OPTION_COMMENTS                                           VARCHAR2(2000);
   V_ATTRIBUTE_CATEGORY                                        VARCHAR2(30);
   V_ATTRIBUTE1                                                VARCHAR2(150);
   V_ATTRIBUTE2                                                VARCHAR2(150);
   V_ATTRIBUTE3                                                VARCHAR2(150);
   V_ATTRIBUTE4                                                VARCHAR2(150);
   V_ATTRIBUTE5                                                VARCHAR2(150);
   V_ATTRIBUTE6                                                VARCHAR2(150);
   V_ATTRIBUTE7                                                VARCHAR2(150);
   V_ATTRIBUTE8                                                VARCHAR2(150);
   V_ATTRIBUTE9                                                VARCHAR2(150);
   V_ATTRIBUTE10                                               VARCHAR2(150);
   V_ATTRIBUTE11                                               VARCHAR2(150);
   V_ATTRIBUTE12                                               VARCHAR2(150);
   V_ATTRIBUTE13                                               VARCHAR2(150);
   V_ATTRIBUTE14                                               VARCHAR2(150);
   V_ATTRIBUTE15                                               VARCHAR2(150);
   V_LAST_UPDATE_DATE                                          DATE;
   V_LAST_UPDATED_BY                                           NUMBER;
   V_LAST_UPDATE_LOGIN                                         NUMBER;
   V_CREATION_DATE                                             DATE;
   V_CREATED_BY                                                NUMBER;

   l_lease_number_low                                         VARCHAR2(30);
   l_lease_number_high                                        VARCHAR2(30);
   l_location_code_low                                        VARCHAR2(90);
   l_location_code_high                                       VARCHAR2(90);

   l_statement                                                VARCHAR2(10000);
   l_cursor                                                   INTEGER;
   l_rows                                                     INTEGER;
   l_count                                                    INTEGER;
   l_lease_responsible_user                                   VARCHAR2(100);
   l_option_type                                              VARCHAR2(30);
   l_exer_window_termination_from                             DATE;
   l_exer_window_termination_to                               DATE;
   l_lease_termination_from                                   DATE;
   l_lease_termination_to                                     DATE;



 --declare the record type for the function here.........
   v_code_data                  PNP_UTIL_FUNC.location_name_rec := NULL;
-- declare cursors.....
  CURSOR pterm (V_LEASE_ID IN NUMBER) IS
   SELECT payment_term_id,start_date,end_date,payment_term_type_code,vendor_id,
          vendor_site_id, customer_id, customer_site_use_id
   FROM   pn_payment_terms_all
   WHERE  lease_id = V_LEASE_ID
     AND  payment_term_type_code in ('BASE','DEP','OEXP');


  CURSOR psched (V_LEASE_ID IN  NUMBER) IS
   SELECT schedule_date, payment_schedule_id
   FROM   pn_payment_schedules_all
   WHERE  lease_id                       = V_LEASE_ID;
--     AND  to_char(schedule_date, 'YYYY') = to_char(sysdate, 'YYYY');


  CURSOR pitem (V_PAYMENT_TERM_ID IN NUMBER, V_PAYMENT_SCHEDULE_ID IN NUMBER) IS
   SELECT actual_amount
   FROM   pn_payment_items_all
   WHERE  payment_term_id               = V_PAYMENT_TERM_ID
     AND  payment_schedule_id           = V_PAYMENT_SCHEDULE_ID
     AND  payment_item_type_lookup_code = 'CASH';


BEGIN

  PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_leaseConditions(+)');
--Initialise status parameters...
  retcode:=0;
  errbuf:='';
  fnd_profile.get('LOGIN_ID', l_login_id);

  l_cursor := dbms_sql.open_cursor;

--lease number conditions.....
  l_lease_number_low := lease_number_low;
  l_lease_number_high := lease_number_high;

IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   lease_number_where_clause := ' AND les.lease_number  BETWEEN
   :l_lease_number_low AND :l_lease_number_high';
 ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
        lease_number_where_clause := ' AND les.lease_number = :l_lease_number_high';
 ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
       lease_number_where_clause := ' AND les.lease_number = :l_lease_number_low';
 ELSE  lease_number_where_clause := ' AND 1=1 ';
END IF;

--location code conditions.....
l_location_code_low  := location_code_low;
l_location_code_high := location_code_high;

 IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
   location_code_where_clause := ' WHERE loc.location_code  BETWEEN
   :l_location_code_low AND :l_location_code_high';
 ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
       location_code_where_clause := ' WHERE loc.location_code =
       :l_location_code_high';
 ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
        location_code_where_clause := ' WHERE loc.location_code =
        :l_location_code_low';
 ELSE  location_code_where_clause := ' WHERE 2=2 ';
END IF;


 l_lease_responsible_user :=  lease_responsible_user;
--lease responsible user conditions....
IF lease_responsible_user IS NOT NULL THEN les_resp_user_where_clause := '
  AND les.user_responsible = :l_lease_responsible_user';
ELSE les_resp_user_where_clause:=' AND 3=3 ';
END IF;


--option type conditions....
l_option_type := option_type;
IF option_type IS NOT NULL THEN option_type_where_clause:= ' AND opt.option_type_code =
   :l_option_type';
 ELSE option_type_where_clause:=' AND 4=4 ';
END IF;


 --exer window termination date conditions.....
l_exer_window_termination_from := exer_window_termination_from;
l_exer_window_termination_to   := exer_window_termination_to;
IF exer_window_termination_from IS NOT NULL AND exer_window_termination_to IS NOT NULL THEN
    exer_date_where_clause := ' AND opt.option_exer_end_date  BETWEEN
   :l_exer_window_termination_from AND :l_exer_window_termination_to';
 ELSIF exer_window_termination_from IS NULL AND exer_window_termination_to IS NOT NULL THEN
      exer_date_where_clause := ' AND opt.option_exer_end_date =
      :l_exer_window_termination_to';
 ELSIF exer_window_termination_from IS NOT NULL AND exer_window_termination_to IS NULL THEN
       exer_date_where_clause := ' AND opt.option_exer_end_date =
       :l_exer_window_termination_from';
 ELSE  exer_date_where_clause := ' AND 5=5 ';
END IF;


 --lease date conditions.....
l_lease_termination_from :=  lease_termination_from;
l_lease_termination_to   :=  lease_termination_to;
IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
   lease_date_where_clause := ' AND les.lease_termination_date  BETWEEN :l_lease_termination_from
                                                                   AND :l_lease_termination_to';
 ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
        lease_date_where_clause := ' AND les.lease_termination_date =
        :l_lease_termination_to';
 ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
        lease_date_where_clause := ' AND les.lease_termination_date =
        :l_lease_termination_from';
 ELSE  lease_date_where_clause := ' AND 6=6 ';
END IF;

l_location_date_clause := 'AND ((( loc.active_start_date between  les.lease_commencement_date'
                          || ' AND  les.lease_Termination_date) OR (loc.active_end_date between'
                          ||' les.lease_commencement_date AND  les.lease_Termination_date))'
                          ||' OR ( loc.active_start_date < les.lease_commencement_date '
                          || ' AND loc.active_end_date > les.lease_Termination_date)) ' ;

--lease cursor.....

l_statement :=
'SELECT
  distinct
  ten.location_id                                  LOCATION_ID,
  ten.tenancy_usage_lookup_code                    USAGE_TYPE,
  les.lease_id                                     LEASE_ID,
  les.lease_name                                   LEASE_NAME,
  les.lease_number                                 LEASE_NUMBER,
  les.lease_commencement_date                      LEASE_COMMENCEMENT_DATE,
  les.lease_termination_date                       LEASE_TERMINATION_DATE,
  les.lease_execution_date                         LEASE_EXECUTION_DATE,
  les.lease_term                                   LEASE_TERM,
  fl1.meaning                                      LEASE_CLASS,
  les.user_responsible                             LEASE_RESPONSIBLE_USER,
  fnd.meaning                                      LEASE_STATUS,
  fl2.meaning                                      LEASE_TYPE,
  ten.estimated_occupancy_date                     ESTIMATED_OCCUPANCY_DATE,
  ten.occupancy_date                               OCCUPANCY_DATE,
  ten.attribute_category                           ATTRIBUTE_CATEGORY,
  ten.attribute1                                   ATTRIBUTE1,
  ten.attribute2                                   ATTRIBUTE2,
  ten.attribute3                                   ATTRIBUTE3,
  ten.attribute4                                   ATTRIBUTE4,
  ten.attribute5                                   ATTRIBUTE5,
  ten.attribute6                                   ATTRIBUTE6,
  ten.attribute7                                   ATTRIBUTE7,
  ten.attribute8                                   ATTRIBUTE8,
  ten.attribute9                                   ATTRIBUTE9,
  ten.attribute10                                  ATTRIBUTE10,
  ten.attribute11                                  ATTRIBUTE11,
  ten.attribute12                                  ATTRIBUTE12,
  ten.attribute13                                  ATTRIBUTE13,
  ten.attribute14                                  ATTRIBUTE14,
  ten.attribute15                                  ATTRIBUTE15,
  les.last_update_date                             LAST_UPDATE_DATE,
  les.last_updated_by                              LAST_UPDATED_BY,
  les.last_update_login                            LAST_UPDATE_LOGIN,
  les.creation_date                                CREATION_DATE,
  les.created_by                                   CREATED_BY
 FROM    pn_leases_v             les,
         pn_tenancies            ten,
         fnd_lookups             fnd,
         fnd_lookups             fl1,
         fnd_lookups             fl2,
         pn_options              opt
 WHERE ten.lease_id     = les.lease_id
   AND ten.primary_flag ='||''''||'Y'||''''||'
   AND les.status = fnd.lookup_code
   AND fnd.lookup_type = '||''''||'PN_LEASE_STATUS_TYPE'||''''||'
   AND fl1.lookup_code = les.lease_class_code
   AND fl1.lookup_type = '||''''||'PN_LEASE_CLASS'||''''||'
   AND fl2.lookup_code = les.lease_type_code
   AND fl2.lookup_type = '||''''||'PN_LEASE_TYPE'||''''||'
   AND ten.location_id IN(SELECT loc.location_id FROM pn_locations loc'
   ||location_code_where_clause|| ' '|| l_location_date_clause|| ')'
   ||lease_number_where_clause||les_resp_user_where_clause||option_type_where_clause
   ||exer_date_where_clause||lease_date_where_clause;



dbms_sql.parse(l_cursor,l_statement,dbms_sql.native);


--lease number conditions.....
IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_high',l_lease_number_high);
ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_number_low',l_lease_number_low);
END IF;

--location code conditions.....
IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
   dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
 ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_high',l_location_code_high);
 ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_location_code_low',l_location_code_low);
END IF;

--lease responsible user conditions....
IF lease_responsible_user IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_responsible_user',l_lease_responsible_user);
END IF;

--option type conditions....
IF option_type IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_option_type',l_option_type);
END IF;


 --exer window termination date conditions.....
IF exer_window_termination_from IS NOT NULL AND exer_window_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_exer_window_termination_from',l_exer_window_termination_from);
   dbms_sql.bind_variable(l_cursor,'l_exer_window_termination_to',l_exer_window_termination_to);
ELSIF exer_window_termination_from IS NULL AND exer_window_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_exer_window_termination_to',l_exer_window_termination_to);
ELSIF exer_window_termination_from IS NOT NULL AND exer_window_termination_to IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_exer_window_termination_from',l_exer_window_termination_from);
END IF;


 --lease date conditions.....
IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_from',l_lease_termination_from);
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_to',l_lease_termination_to);
ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_to',l_lease_termination_to);
ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
   dbms_sql.bind_variable(l_cursor,'l_lease_termination_from',l_lease_termination_from);
END IF;


   dbms_sql.define_column (l_cursor,1,V_LOCATION_ID_1);
   dbms_sql.define_column (l_cursor,2,V_SPACE_TYPE,30);
   dbms_sql.define_column (l_cursor,3,V_LEASE_ID);
   dbms_sql.define_column (l_cursor,4,V_LEASE_NAME,50);
   dbms_sql.define_column (l_cursor,5,V_LEASE_NUMBER,30);
   dbms_sql.define_column (l_cursor,6,V_LEASE_COM_DATE);
   dbms_sql.define_column (l_cursor,7,V_LEASE_TERM_DATE);
   dbms_sql.define_column (l_cursor,8,V_LEASE_EXE_DATE);
   dbms_sql.define_column (l_cursor,9,V_LEASE_TERM);
   dbms_sql.define_column (l_cursor,10,V_LEASE_CLASS,80);
   dbms_sql.define_column (l_cursor,11,V_LEASE_RESP_USER,100);
   dbms_sql.define_column (l_cursor,12,V_LEASE_STATUS,80);
   dbms_sql.define_column (l_cursor,13,V_LEASE_TYPE,80);
   dbms_sql.define_column (l_cursor,14,V_ESTIMATED_OCCUPANCY_DATE);
   dbms_sql.define_column (l_cursor,15,V_ACTUAL_OCCUPANCY_DATE);
   dbms_sql.define_column (l_cursor,16,V_ATTRIBUTE_CATEGORY,30);
   dbms_sql.define_column (l_cursor,17,V_ATTRIBUTE1,150);
   dbms_sql.define_column (l_cursor,18,V_ATTRIBUTE2,150);
   dbms_sql.define_column (l_cursor,19,V_ATTRIBUTE3,150);
   dbms_sql.define_column (l_cursor,20,V_ATTRIBUTE4,150);
   dbms_sql.define_column (l_cursor,21,V_ATTRIBUTE5,150);
   dbms_sql.define_column (l_cursor,22,V_ATTRIBUTE6,150);
   dbms_sql.define_column (l_cursor,23,V_ATTRIBUTE7,150);
   dbms_sql.define_column (l_cursor,24,V_ATTRIBUTE8,150);
   dbms_sql.define_column (l_cursor,25,V_ATTRIBUTE9,150);
   dbms_sql.define_column (l_cursor,26,V_ATTRIBUTE10,150);
   dbms_sql.define_column (l_cursor,27,V_ATTRIBUTE11,150);
   dbms_sql.define_column (l_cursor,28,V_ATTRIBUTE12,150);
   dbms_sql.define_column (l_cursor,29,V_ATTRIBUTE13,150);
   dbms_sql.define_column (l_cursor,30,V_ATTRIBUTE14,150);
   dbms_sql.define_column (l_cursor,31,V_ATTRIBUTE15,150);
   dbms_sql.define_column (l_cursor,32,V_LAST_UPDATE_DATE);
   dbms_sql.define_column (l_cursor,33,V_LAST_UPDATED_BY);
   dbms_sql.define_column (l_cursor,34,V_LAST_UPDATE_LOGIN);
   dbms_sql.define_column (l_cursor,35,V_CREATION_DATE);
   dbms_sql.define_column (l_cursor,36,V_CREATED_BY);



   l_rows   := dbms_sql.execute(l_cursor);

  PNP_DEBUG_PKG.put_log_msg('pn_roll_rent_lesLoop(+)');
LOOP  --start lease loop....

 l_count := dbms_sql.fetch_rows( l_cursor );

 EXIT WHEN l_count <> 1;

 dbms_sql.column_value (l_cursor,1,V_LOCATION_ID_1);
 dbms_sql.column_value (l_cursor,2,V_SPACE_TYPE);
 dbms_sql.column_value (l_cursor,3,V_LEASE_ID);
 dbms_sql.column_value (l_cursor,4,V_LEASE_NAME);
 dbms_sql.column_value (l_cursor,5,V_LEASE_NUMBER);
 dbms_sql.column_value (l_cursor,6,V_LEASE_COM_DATE);
 dbms_sql.column_value (l_cursor,7,V_LEASE_TERM_DATE);
 dbms_sql.column_value (l_cursor,8,V_LEASE_EXE_DATE);
 dbms_sql.column_value (l_cursor,9,V_LEASE_TERM);
 dbms_sql.column_value (l_cursor,10,V_LEASE_CLASS);
 dbms_sql.column_value (l_cursor,11,V_LEASE_RESP_USER);
 dbms_sql.column_value (l_cursor,12,V_LEASE_STATUS);
 dbms_sql.column_value (l_cursor,13,V_LEASE_TYPE);
 dbms_sql.column_value (l_cursor,14,V_ESTIMATED_OCCUPANCY_DATE);
 dbms_sql.column_value (l_cursor,15,V_ACTUAL_OCCUPANCY_DATE);
 dbms_sql.column_value (l_cursor,16,V_ATTRIBUTE_CATEGORY);
 dbms_sql.column_value (l_cursor,17,V_ATTRIBUTE1);
 dbms_sql.column_value (l_cursor,18,V_ATTRIBUTE2);
 dbms_sql.column_value (l_cursor,19,V_ATTRIBUTE3);
 dbms_sql.column_value (l_cursor,20,V_ATTRIBUTE4);
 dbms_sql.column_value (l_cursor,21,V_ATTRIBUTE5);
 dbms_sql.column_value (l_cursor,22,V_ATTRIBUTE6);
 dbms_sql.column_value (l_cursor,23,V_ATTRIBUTE7);
 dbms_sql.column_value (l_cursor,24,V_ATTRIBUTE8);
 dbms_sql.column_value (l_cursor,25,V_ATTRIBUTE9);
 dbms_sql.column_value (l_cursor,26,V_ATTRIBUTE10);
 dbms_sql.column_value (l_cursor,27,V_ATTRIBUTE11);
 dbms_sql.column_value (l_cursor,28,V_ATTRIBUTE12);
 dbms_sql.column_value (l_cursor,29,V_ATTRIBUTE13);
 dbms_sql.column_value (l_cursor,30,V_ATTRIBUTE14);
 dbms_sql.column_value (l_cursor,31,V_ATTRIBUTE15);
 dbms_sql.column_value (l_cursor,32,V_LAST_UPDATE_DATE);
 dbms_sql.column_value (l_cursor,33,V_LAST_UPDATED_BY);
 dbms_sql.column_value (l_cursor,34,V_LAST_UPDATE_LOGIN);
 dbms_sql.column_value (l_cursor,35,V_CREATION_DATE);
 dbms_sql.column_value (l_cursor,36,V_CREATED_BY);


OPEN c_loc_pn FOR
 SELECT
  distinct
  loc.location_id                                                           LOCATION_ID,
  fl1.meaning                                                               LOCATION_TYPE,
  NVL(NVL(loc.building, loc.FLOOR), loc.office)                             LOCATION_NAME,
  loc.location_code                                                         LOCATION_CODE,
  pa.address_line1||pa.address_line2||pa.address_line3||pa.address_line4
  ||pa.county||pa.city||pa.state||pa.province||pa.zip_code||pa.country      ADDRESS,
  pa.county                                                                 COUNTY,
  pa.city                                                                   CITY,
  pa.state                                                                  STATE,
  pa.province                                                               PROVINCE,
  pa.zip_code                                                               ZIP_CODE,
  pa.country                                                                COUNTRY,
  DECODE (location_type_lookup_code,'OFFICE',loc.rentable_area,
          'FLOOR',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id, loc.active_start_date),
          'PARCEL',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id, loc.active_start_date),
          'BUILDING',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id, loc.active_start_date),
          'LAND',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id, loc.active_start_date),
                rentable_area) RENTABLE_AREA,
  DECODE (location_type_lookup_code,'OFFICE',loc.usable_area,
          'FLOOR',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id, loc.active_start_date),
          'PARCEL',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id, loc.active_start_date),
          'BUILDING',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id, loc.active_start_date),
          'LAND',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id, loc.active_start_date),
                usable_area)   USABLE_AREA,
  loc.gross_area               GROSS_AREA,
  fnd.meaning                  TENURE
 FROM pn_locations_all   loc,
      pn_addresses_all   pa,
      fnd_lookups        fnd,
      fnd_lookups        fl1
 WHERE pa.address_id(+)   = loc.address_id
   AND loc.lease_or_owned = fnd.lookup_code(+)
   AND fnd.lookup_type(+)    = 'PN_LEASED_OR_OWNED'
   AND fl1.lookup_code(+) = loc.location_type_lookup_code
   AND fl1.lookup_type(+) = 'PN_LOCATION_TYPE'
   AND loc.location_id    = V_LOCATION_ID_1;


LOOP --start location loop
 FETCH c_loc_pn into V_LOCATION_ID                              ,
                     V_LOCATION_TYPE                            ,
                     V_LOCATION_NAME                            ,
                     V_LOCATION_CODE                            ,
                     V_ADDRESS                                  ,
                     V_COUNTY                                   ,
                     V_CITY                                     ,
                     V_STATE                                    ,
                     V_PROVINCE                                 ,
                     V_ZIP_CODE                                 ,
                     V_COUNTRY                                  ,
                     V_RENTABLE_AREA                            ,
                     V_USABLE_AREA                              ,
                     V_GROSS_AREA                               ,
                     V_TENURE                                   ;
 EXIT WHEN c_loc_pn%notfound;
OPEN c_options_pn FOR
 SELECT
   distinct
   opt.option_id                                                   OPTION_ID,
   fl.meaning                                                      OPTION_TYPE,
   fl1.meaning                                                     OPTION_STATUS,
   (trunc(opt.expiration_date) - trunc(opt.start_date)+1)          OPTION_TERM,
   opt.option_reference                                            REFERENCE,
   opt.option_notice_reqd                                          OPTION_NOTICE_REQD,
   opt.option_action_date                                          OPTION_ACTION_DATE,
   opt.option_size                                                 OPTION_SIZE,
   opt.option_cost                                                 OPTION_COST,
   opt.uom_code                                                    UOM_CODE,
   opt.option_area_change                                          OPTION_AREA_CHANGE,
   opt.option_exer_start_date                                      OPTION_EXER_START_DATE,
   opt.option_exer_end_date                                        OPTION_EXER_END_DATE,
   opt.start_date                                                  OPTION_COMM_DATE,
   opt.expiration_date                                             OPTION_EXP_DATE,
   opt.option_comments                                             OPTION_COMMENTS
 FROM pn_options_all opt,
      fnd_lookups fl,
      fnd_lookups fl1
 WHERE opt.lease_id     = V_LEASE_ID
 AND    fl.lookup_code(+)= opt.option_type_code
 AND    fl.lookup_type(+)= 'PN_LEASE_OPTION_TYPE'
 AND    fl1.lookup_code(+)= opt.option_status_lookup_code
 AND    fl1.lookup_type(+)= 'PN_OPTION_STATUS_TYPE';
LOOP
  FETCH c_options_pn into V_OPTION_ID,
           V_OPTION_TYPE,
           V_OPTION_STATUS,
           V_OPTION_TERM,
           V_REFERENCE,
           V_OPTION_NOTICE_REQD,
           V_OPTION_ACTION_DATE,
           V_OPTION_SIZE,
           V_OPTION_COST,
           V_UOM_CODE,
           V_OPTION_AREA_CHANGE,
           V_OPTION_EXER_START_DATE,
           V_OPTION_EXER_END_DATE,
           V_OPTION_COMM_DATE,
           V_OPTION_EXP_DATE,
           V_OPTION_COMMENTS;

  EXIT WHEN c_options_pn%notfound;

OPEN c_currency_pn FOR
 SELECT currency_code
 FROM gl_sets_of_books
 WHERE set_of_books_id = to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                   pn_mo_cache_utils.get_current_org_id));
LOOP
 FETCH c_currency_pn into V_OPTION_CURRENCY;
 EXIT WHEN c_currency_pn%notfound;
END LOOP;

v_code_data:=pnp_util_func.get_location_name(V_LOCATION_ID, V_OPTION_COMM_DATE);

  PNP_DEBUG_PKG.put_log_msg('pn_roll_rent_inserting(+)');
INSERT INTO pn_lease_options_itf
 (LEASE_ID                                   ,
 LEASE_NAME                                  ,
 LEASE_NUMBER                                ,
 LEASE_COMMENCEMENT_DATE                     ,
 LEASE_TERMINATION_DATE                      ,
 LEASE_EXECUTION_DATE                        ,
 LEASE_TERM                                  ,
 LEASE_CLASS                                 ,
 LEASE_RESPONSIBLE_USER                      ,
 LEASE_STATUS                                ,
 LEASE_TYPE                                  ,
 ESTIMATED_OCCUPANCY_DATE                    ,
 ACTUAL_OCCUPANCY_DATE                       ,
 LOCATION_ID                                 ,
 LOCATION_TYPE                               ,
 LOCATION_NAME                               ,
 LOCATION_CODE                               ,
 SPACE_TYPE                                  ,
 REGION                                      ,
 PROPERTY_NAME                               ,
 BUILDING_OR_LAND_NAME                       ,
 FLOOR_OR_PARCEL_NAME                        ,
 OFFICE_OR_SECTION_NAME                      ,
 ADDRESS                                     ,
 COUNTY                                      ,
 CITY                                        ,
 STATE                                       ,
 PROVINCE                                    ,
 ZIP_CODE                                    ,
 COUNTRY                                     ,
 GROSS_AREA                                  ,
 RENTABLE_AREA                               ,
 USABLE_AREA                                 ,
 TENURE                                      ,
 OPTION_ID                                   ,
 OPTION_TYPE                                 ,
 OPTION_STATUS                               ,
 OPTION_TERM                                 ,
 REFERENCE                                   ,
 OPTION_NOTICE_REQD                          ,
 OPTION_ACTION_DATE                          ,
 OPTION_SIZE                                 ,
 OPTION_COST                                 ,
 UOM_CODE                                    ,
 OPTION_AREA_CHANGE                          ,
 OPTION_CURRENCY                             ,
 OPTION_EXER_START_DATE                      ,
 OPTION_EXER_END_DATE                        ,
 OPTION_COMM_DATE                            ,
 OPTION_EXP_DATE                             ,
 OPTION_COMMENTS                             ,
 TEN_ATTRIBUTE_CATEGORY                      ,
 TEN_ATTRIBUTE1                              ,
 TEN_ATTRIBUTE2                              ,
 TEN_ATTRIBUTE3                              ,
 TEN_ATTRIBUTE4                              ,
 TEN_ATTRIBUTE5                              ,
 TEN_ATTRIBUTE6                              ,
 TEN_ATTRIBUTE7                              ,
 TEN_ATTRIBUTE8                              ,
 TEN_ATTRIBUTE9                              ,
 TEN_ATTRIBUTE10                             ,
 TEN_ATTRIBUTE11                             ,
 TEN_ATTRIBUTE12                             ,
 TEN_ATTRIBUTE13                             ,
 TEN_ATTRIBUTE14                             ,
 TEN_ATTRIBUTE15                             ,
 LAST_UPDATE_DATE                            ,
 LAST_UPDATED_BY                             ,
 LAST_UPDATE_LOGIN                           ,
 CREATION_DATE                               ,
 CREATED_BY                                  ,
 REQUEST_ID                                  )
VALUES
 (V_LEASE_ID                                 ,
 V_LEASE_NAME                                ,
 V_LEASE_NUMBER                              ,
 V_LEASE_COM_DATE                            ,
 V_LEASE_TERM_DATE                           ,
 V_LEASE_EXE_DATE                            ,
 V_LEASE_TERM                                ,
 V_LEASE_CLASS                               ,
 V_LEASE_RESP_USER                           ,
 V_LEASE_STATUS                              ,
 V_LEASE_TYPE                                ,
 V_ESTIMATED_OCCUPANCY_DATE                  ,
 V_ACTUAL_OCCUPANCY_DATE                     ,
 V_LOCATION_ID                               ,
 V_LOCATION_TYPE                             ,
 V_LOCATION_NAME                             ,
 V_LOCATION_CODE                             ,
 V_SPACE_TYPE                                ,
 v_code_data.REGION_NAME                     ,
 v_code_data.PROPERTY_NAME                   ,
 v_code_data.BUILDING                        ,
 v_code_data.FLOOR                           ,
 v_code_data.OFFICE                          ,
 V_ADDRESS                                   ,
 V_COUNTY                                    ,
 V_CITY                                      ,
 V_STATE                                     ,
 V_PROVINCE                                  ,
 V_ZIP_CODE                                  ,
 V_COUNTRY                                   ,
 V_GROSS_AREA                                ,
 V_RENTABLE_AREA                             ,
 V_USABLE_AREA                               ,
 V_TENURE                                    ,
 V_OPTION_ID                                 ,
 V_OPTION_TYPE                               ,
 V_OPTION_STATUS                             ,
 V_OPTION_TERM                               ,
 V_REFERENCE                                 ,
 V_OPTION_NOTICE_REQD                        ,
 V_OPTION_ACTION_DATE                        ,
 V_OPTION_SIZE                               ,
 V_OPTION_COST                               ,
 V_UOM_CODE                                  ,
 V_OPTION_AREA_CHANGE                        ,
 V_OPTION_CURRENCY                           ,
 V_OPTION_EXER_START_DATE                    ,
 V_OPTION_EXER_END_DATE                      ,
 V_OPTION_COMM_DATE                          ,
 V_OPTION_EXP_DATE                           ,
 V_OPTION_COMMENTS                           ,
 V_ATTRIBUTE_CATEGORY                        ,
 V_ATTRIBUTE1                                ,
 V_ATTRIBUTE2                                ,
 V_ATTRIBUTE3                                ,
 V_ATTRIBUTE4                                ,
 V_ATTRIBUTE5                                ,
 V_ATTRIBUTE6                                ,
 V_ATTRIBUTE7                                ,
 V_ATTRIBUTE8                                ,
 V_ATTRIBUTE9                                ,
 V_ATTRIBUTE10                               ,
 V_ATTRIBUTE11                               ,
 V_ATTRIBUTE12                               ,
 V_ATTRIBUTE13                               ,
 V_ATTRIBUTE14                               ,
 V_ATTRIBUTE15                               ,
 V_LAST_UPDATE_DATE                          ,
 V_LAST_UPDATED_BY                           ,
 V_LAST_UPDATE_LOGIN                         ,
 V_CREATION_DATE                             ,
 V_CREATED_BY                                ,
 l_request_id                              );
 PNP_DEBUG_PKG.put_log_msg('pn_roll_rent_inserting(-)');
     END LOOP; --end option loop
  END LOOP; --end location loop...
END LOOP; --end lease loop...
IF dbms_sql.is_open (l_cursor) THEN
 dbms_sql.close_cursor (l_cursor);
END IF;

PNP_DEBUG_PKG.put_log_msg('pn_lease_optionsLoop(-)');
--If there is something amiss...
EXCEPTION
WHEN OTHERS THEN
  retcode:=2;
  errbuf:=substr(SQLERRM,1,235);
  RAISE;
END pn_lease_options;
END pnrx_lease_options;

/
