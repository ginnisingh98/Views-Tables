--------------------------------------------------------
--  DDL for Package Body PNRX_MILESTONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_MILESTONES" AS
/* $Header: PNRXMSTB.pls 120.3 2006/06/16 01:44:01 kkhegde ship $ */


-------------------------------------------------------------------------------
-- PROCDURE     : PN_MILESTONES
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_distributions with _ALL.
-- 21-OCT-05  Hareesha o ATG mandated changes for SQL literals using dbms_sql.
-- 16-Jun-06  Kiran    o Bug # 5334793 - removed stray ) from l_statement that
--                       was causing the query to fail.
-------------------------------------------------------------------------------
PROCEDURE pn_milestones(
          lease_number_low                  IN                    VARCHAR2,
          lease_number_high                 IN                    VARCHAR2,
          location_code_low                 IN                    VARCHAR2,
          location_code_high                IN                    VARCHAR2,
          lease_termination_from            IN                    DATE,
          lease_termination_to              IN                    DATE,
          responsible_user                  IN                    VARCHAR2,
          action_due_date_from              IN                    DATE,
          action_due_date_to                IN                    DATE,
          milestone_type                    IN                    VARCHAR2,
          l_request_id                      IN                    NUMBER,
          l_user_id                         IN                    NUMBER,
          retcode                           OUT NOCOPY            VARCHAR2,
          errbuf                            OUT NOCOPY            VARCHAR2
                   )
IS
  l_login_id                                                  NUMBER;
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
  V_LOCATION_ID                                               NUMBER;
  V_OCCUPANCY_DATE                                            DATE;
  V_LOCATION_ID_1                                             NUMBER;
  V_LOCATION_TYPE                                             VARCHAR2(80);
  V_LOCATION_NAME                                             VARCHAR2(30);
  V_LOCATION_CODE                                             VARCHAR2(90);
  V_SPACE_TYPE                                                VARCHAR2(80);
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
  V_LEASE_MILESTONE_ID                                        NUMBER;
  V_MILESTONE_TYPE                                            VARCHAR2(80);
  V_RESPONSIBLE_USER                                          VARCHAR2(100);
  V_ACTION_DATE                                               DATE;
  V_MILESTONE_DATE                                            DATE;
  V_ACTION_TAKEN                                              VARCHAR2(50);
  V_LAST_UPDATE_DATE                                          DATE;
  V_LAST_UPDATED_BY                                           NUMBER;
  V_LAST_UPDATE_LOGIN                                         NUMBER;
  V_CREATION_DATE                                             DATE;
  V_CREATED_BY                                                NUMBER;
  l_cursor                                                    INTEGER;
  l_statement                                                 VARCHAR2(10000);
  l_rows                                                      INTEGER;
  l_count                                                     INTEGER;
  l_lease_number_low                                          VARCHAR2(30);
  l_lease_number_high                                         VARCHAR2(30);
  l_location_code_low                                         VARCHAR2(90);
  l_location_code_high                                        VARCHAR2(90);
  l_responsible_user                                          VARCHAR2(100);
  l_action_due_date_from                                      DATE;
  l_action_due_date_to                                        DATE;
  l_lease_termination_from                                    DATE;
  l_lease_termination_to                                      DATE;
  l_milestone_type                                            VARCHAR2(30);
  --declare the record type for the function here.........
  v_code_data                  PNP_UTIL_FUNC.location_name_rec := NULL;
 -- declare cursors.....
BEGIN
  PNP_DEBUG_PKG.put_log_msg('pn_sp_assign_leaseConditiond(+)');
  --Initialise status parameters...
  retcode:=0;
  errbuf:='';
  fnd_profile.get('LOGIN_ID', l_login_id);

  l_cursor := dbms_sql.open_cursor;
  l_statement :=
  'SELECT
  distinct
  ten.location_id                                  LOCATION_ID,
  NVL(ten.occupancy_date, ten.estimated_occupancy_date)    OCCUPANCY_DATE,
  les.lease_id                                     LEASE_ID,
  les.lease_name                                   LEASE_NAME,
  les.lease_number                                 LEASE_NUMBER,
  les.lease_commencement_date                      LEASE_COMMENCEMENT_DATE,
  les.lease_termination_date                       LEASE_TERMINATION_DATE,
  les.lease_execution_date                         LEASE_EXECUTION_DATE,
  (TRUNC(les.lease_termination_date)- TRUNC(les.lease_commencement_date)+1) LEASE_TERM,
  fnd4.meaning                                     LEASE_CLASS,
  les.user_responsible                             LEASE_RESPONSIBLE_USER,
  fnd1.meaning                                     LEASE_STATUS,
  fnd6.meaning                                     LEASE_TYPE,
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
  les.created_by                                   CREATED_BY,
  fnd5.meaning                                     LOCATION_TYPE,
  NVL(NVL(loc.building, loc.FLOOR), loc.office)    LOCATION_NAME,
  loc.location_code                                LOCATION_CODE,
  fnd7.meaning                                     USAGE_TYPE,
  pa.address_line1||pa.address_line2||pa.address_line3||pa.address_line4||pa.county||pa.city||pa.state||pa.province||pa.zip_code||pa.country               ADDRESS,
  pa.county                                        COUNTY,
  pa.city                                          CITY,
  pa.state                                         STATE,
  pa.province                                      PROVINCE,
  pa.zip_code                                      ZIP_CODE,
  pa.country                                       COUNTRY,
  DECODE (location_type_lookup_code,'||''''||'OFFICE'||''''||',loc.rentable_area,
          '||''''||'FLOOR'||''''||',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id),
          '||''''||'PARCEL'||''''||',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id),
          '||''''||'BUILDING'||''''||',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id),
          '||''''||'LAND'||''''||',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id),
                rentable_area)                     RENTABLE_AREA,
  DECODE (location_type_lookup_code,'||''''||'OFFICE'||''''||',loc.usable_area,
          '||''''||'FLOOR'||''''||',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id),
          '||''''||'PARCEL'||''''||',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id),
          '||''''||'BUILDING'||''''||',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id),
          '||''''||'LAND'||''''||',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id),
                usable_area)                       USABLE_AREA,
  loc.gross_area                                   GROSS_AREA,
  fnd2.meaning                                     TENURE,
  mil.lease_milestone_id                           LEASE_MILESTONE_ID,
  fnd3.meaning                                     MILESTONE_TYPE,
  fnd.user_name                                    RESPONSIBLE_USER,
  mil.milestone_date                               ACTION_DATE,
  mil.milestone_date-mil.lead_days                 MILESTONE_DATE,
  mil.action_taken                                 ACTION_TAKEN
  FROM pn_leases_v                les,
       pn_tenancies               ten,
       pn_locations               loc,
       pn_lease_milestones        mil,
       fnd_user                   fnd,
       pn_addresses               pa,
       fnd_lookups                fnd1,
       fnd_lookups                fnd2,
       fnd_lookups                fnd3,
       fnd_lookups                fnd4,
       fnd_lookups                fnd5,
       fnd_lookups                fnd6,
       fnd_lookups                fnd7
  WHERE ten.lease_id      = les.lease_id
    AND ten.location_id   = loc.location_id
    AND ( (( loc.active_start_date BETWEEN  les.lease_commencement_date AND  les.lease_Termination_date) OR
    (loc.active_end_date BETWEEN  les.lease_commencement_date AND  les.lease_Termination_date)) OR ( loc.active_start_date < les.lease_commencement_date AND loc.active_end_date
     > les.lease_Termination_date))
    AND mil.lease_id      = les.lease_id
    AND mil.user_id       = fnd.user_id
    AND ten.primary_flag  ='||''''||'Y'||''''||'
    AND les.status = fnd1.lookup_code (+)
    AND loc.lease_or_owned = fnd2.lookup_code (+)
    AND fnd3.lookup_code   = mil.milestone_type_code
    AND fnd4.lookup_code (+)  = les.lease_class_code
    AND fnd5.lookup_code   = loc.location_type_lookup_code
    AND fnd6.lookup_code   = les.lease_type_code
    AND fnd7.lookup_code   = ten.tenancy_usage_lookup_code
    AND fnd1.lookup_type (+) = '||''''||'PN_LEASE_STATUS_TYPE'||''''||'
    AND fnd2.lookup_type (+) = '||''''||'PN_LEASED_OR_OWNED'||''''||'
    AND fnd3.lookup_type = '||''''||'PN_MILESTONES_TYPE'||''''||'
    AND fnd4.lookup_type (+) = '||''''||'PN_LEASE_CLASS'||''''||'
    AND fnd5.lookup_type = '||''''||'PN_LOCATION_TYPE'||''''||'
    AND fnd6.lookup_type = '||''''||'PN_LEASE_TYPE'||''''||'
    AND fnd7.lookup_type = '||''''||'PN_TENANCY_USAGE_TYPE'||''''||'
    AND pa.address_id(+)  = loc.address_id';

  --lease number conditions.....
  IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
     l_lease_number_low  := lease_number_low;
     l_lease_number_high := lease_number_high;
     l_statement :=
     l_statement || ' AND les.lease_number  BETWEEN :l_lease_number_low AND :l_lease_number_high ';

  ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
     l_lease_number_high := lease_number_high;
     l_statement :=
     l_statement || ' AND les.lease_number = :l_lease_number_high ';

  ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
     l_lease_number_low  := lease_number_low;
     l_statement :=
     l_statement || ' AND les.lease_number = :l_lease_number_low ';

  ELSE
     l_statement :=
     l_statement || ' AND 1=1 ';

  END IF;


  --location code conditions.....
  IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     l_location_code_low  := location_code_low;
     l_location_code_high := location_code_high;
     l_statement :=
     l_statement || ' AND loc.location_code  BETWEEN :l_location_code_low AND :l_location_code_high ';

  ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     l_location_code_high := location_code_high;
     l_statement :=
     l_statement || ' AND loc.location_code = :l_location_code_high ';

  ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     l_location_code_low  := location_code_low;
     l_statement :=
     l_statement || ' AND loc.location_code = :l_location_code_low ';

  ELSE
     l_statement :=
     l_statement || ' AND 2=2 ';

  END IF;

  --responsible user conditions....
  IF responsible_user IS NOT NULL THEN
     l_responsible_user := responsible_user;
     l_statement :=
     l_statement || ' AND fnd.user_name = :l_responsible_user ';

  ELSE
     l_statement :=
     l_statement || ' AND 3=3 ';

  END IF;


  --action due date conditions.....
  IF action_due_date_from IS NOT NULL AND action_due_date_to IS NOT NULL THEN
     l_action_due_date_from := action_due_date_from;
     l_action_due_date_to   := action_due_date_to;
     l_statement :=
     l_statement || ' AND mil.milestone_date BETWEEN :l_action_due_date_from AND :l_action_due_date_to ';

  ELSIF action_due_date_from IS NULL AND action_due_date_to IS NOT NULL THEN
     l_action_due_date_to   := action_due_date_to;
     l_statement :=
     l_statement || ' AND mil.milestone_date = :l_action_due_date_to ';

  ELSIF action_due_date_from IS NOT NULL AND action_due_date_to IS NULL THEN
     l_action_due_date_from := action_due_date_from;
     l_statement :=
     l_statement || ' AND mil.milestone_date = :l_action_due_date_from ';

  ELSE
     l_statement :=
     l_statement || ' AND 4=4 ';

  END IF;


  --lease date conditions.....
  IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
     l_lease_termination_from := lease_termination_from;
     l_lease_termination_to   := lease_termination_to;
     l_statement :=
     l_statement || ' AND les.lease_termination_date
                      BETWEEN :l_lease_termination_from AND :l_lease_termination_to ';

  ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
     l_lease_termination_to   := lease_termination_to;
     l_statement :=
     l_statement || ' AND les.lease_termination_date = :l_lease_termination_to ';

  ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
     l_lease_termination_from := lease_termination_from;
     l_statement :=
     l_statement || ' AND les.lease_termination_date = :l_lease_termination_from ';

  ELSE
     l_statement :=
     l_statement || ' AND 5=5 ';

  END IF;


  --milestone type conditions....
  IF milestone_type IS NOT NULL THEN
     l_milestone_type := milestone_type;
     l_statement :=
     l_statement || ' AND mil.milestone_type_code =  :l_milestone_type ';

  ELSE
     l_statement :=
     l_statement || ' AND 6=6 ';

  END IF;

  dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

  IF lease_number_low IS NOT NULL AND lease_number_high IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_number_low', l_lease_number_low );
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_number_high', l_lease_number_high );

  ELSIF lease_number_low IS NULL AND lease_number_high IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_number_high', l_lease_number_high );

  ELSIF lease_number_low IS NOT NULL AND lease_number_high IS NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_number_low', l_lease_number_low );
  END IF;

  IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_location_code_low', l_location_code_low );
     dbms_sql.bind_variable
              (l_cursor, 'l_location_code_high', l_location_code_high );

  ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_location_code_high', l_location_code_high );

  ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_location_code_low', l_location_code_low );
  END IF;

  IF responsible_user IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_responsible_user', l_responsible_user );
  END IF;

  IF action_due_date_from IS NOT NULL AND action_due_date_to IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_action_due_date_from', l_action_due_date_from );
     dbms_sql.bind_variable
              (l_cursor, 'l_action_due_date_to', l_action_due_date_to );

  ELSIF action_due_date_from IS NULL AND action_due_date_to IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_action_due_date_to', l_action_due_date_to );
  ELSIF action_due_date_from IS NOT NULL AND action_due_date_to IS NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_action_due_date_from', l_action_due_date_from );
  END IF;

  IF lease_termination_from IS NOT NULL AND lease_termination_to IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_termination_from', l_lease_termination_from );
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_termination_to', l_lease_termination_to );

  ELSIF lease_termination_from IS NULL AND lease_termination_to IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_termination_to', l_lease_termination_to );
  ELSIF lease_termination_from IS NOT NULL AND lease_termination_to IS NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_lease_termination_from', l_lease_termination_from );
  END IF;

  IF milestone_type IS NOT NULL THEN
     dbms_sql.bind_variable
              (l_cursor, 'l_milestone_type', l_milestone_type );
  END IF;

  dbms_sql.define_column (l_cursor, 1,V_LOCATION_ID);
  dbms_sql.define_column (l_cursor, 2,V_OCCUPANCY_DATE);
  dbms_sql.define_column (l_cursor, 3,V_LEASE_ID);
  dbms_sql.define_column (l_cursor, 4,V_LEASE_NAME,50);
  dbms_sql.define_column (l_cursor, 5,V_LEASE_NUMBER,30);
  dbms_sql.define_column (l_cursor, 6,V_LEASE_COM_DATE);
  dbms_sql.define_column (l_cursor, 7,V_LEASE_TERM_DATE);
  dbms_sql.define_column (l_cursor, 8,V_LEASE_EXE_DATE);
  dbms_sql.define_column (l_cursor, 9,V_LEASE_TERM);
  dbms_sql.define_column (l_cursor, 10,V_LEASE_CLASS,80);
  dbms_sql.define_column (l_cursor, 11,V_LEASE_RESP_USER,100);
  dbms_sql.define_column (l_cursor, 12,V_LEASE_STATUS,80);
  dbms_sql.define_column (l_cursor, 13,V_LEASE_TYPE,80);
  dbms_sql.define_column (l_cursor, 14,V_ESTIMATED_OCCUPANCY_DATE);
  dbms_sql.define_column (l_cursor, 15,V_ACTUAL_OCCUPANCY_DATE);
  dbms_sql.define_column (l_cursor, 16,V_ATTRIBUTE_CATEGORY,30);
  dbms_sql.define_column (l_cursor, 17,V_ATTRIBUTE1,150);
  dbms_sql.define_column (l_cursor, 18,V_ATTRIBUTE2,150);
  dbms_sql.define_column (l_cursor, 19,V_ATTRIBUTE3,150);
  dbms_sql.define_column (l_cursor, 20,V_ATTRIBUTE4,150);
  dbms_sql.define_column (l_cursor, 21,V_ATTRIBUTE5,150);
  dbms_sql.define_column (l_cursor, 22,V_ATTRIBUTE6,150);
  dbms_sql.define_column (l_cursor, 23,V_ATTRIBUTE7,150);
  dbms_sql.define_column (l_cursor, 24,V_ATTRIBUTE8,150);
  dbms_sql.define_column (l_cursor, 25,V_ATTRIBUTE9,150);
  dbms_sql.define_column (l_cursor, 26,V_ATTRIBUTE10,150);
  dbms_sql.define_column (l_cursor, 27,V_ATTRIBUTE11,150);
  dbms_sql.define_column (l_cursor, 28,V_ATTRIBUTE12,150);
  dbms_sql.define_column (l_cursor, 29,V_ATTRIBUTE13,150);
  dbms_sql.define_column (l_cursor, 30,V_ATTRIBUTE14,150);
  dbms_sql.define_column (l_cursor, 31,V_ATTRIBUTE15,150);
  dbms_sql.define_column (l_cursor, 32,V_LAST_UPDATE_DATE);
  dbms_sql.define_column (l_cursor, 33,V_LAST_UPDATED_BY);
  dbms_sql.define_column (l_cursor, 34,V_LAST_UPDATE_LOGIN);
  dbms_sql.define_column (l_cursor, 35,V_CREATION_DATE);
  dbms_sql.define_column (l_cursor, 36,V_CREATED_BY);
  dbms_sql.define_column (l_cursor, 37,V_LOCATION_TYPE,80);
  dbms_sql.define_column (l_cursor, 38,V_LOCATION_NAME,30);
  dbms_sql.define_column (l_cursor, 39,V_LOCATION_CODE,90);
  dbms_sql.define_column (l_cursor, 40,V_SPACE_TYPE,80);
  dbms_sql.define_column (l_cursor, 41,V_ADDRESS,1500);
  dbms_sql.define_column (l_cursor, 42,V_COUNTY,60);
  dbms_sql.define_column (l_cursor, 43,V_CITY,60);
  dbms_sql.define_column (l_cursor, 44,V_STATE,60);
  dbms_sql.define_column (l_cursor, 45,V_PROVINCE,60);
  dbms_sql.define_column (l_cursor, 46,V_ZIP_CODE,60);
  dbms_sql.define_column (l_cursor, 47,V_COUNTRY,60);
  dbms_sql.define_column (l_cursor, 48,V_RENTABLE_AREA);
  dbms_sql.define_column (l_cursor, 49,V_USABLE_AREA);
  dbms_sql.define_column (l_cursor, 50,V_GROSS_AREA);
  dbms_sql.define_column (l_cursor, 51,V_TENURE,80);
  dbms_sql.define_column (l_cursor, 52,V_LEASE_MILESTONE_ID);
  dbms_sql.define_column (l_cursor, 53,V_MILESTONE_TYPE,80);
  dbms_sql.define_column (l_cursor, 54,V_RESPONSIBLE_USER,100);
  dbms_sql.define_column (l_cursor, 55,V_ACTION_DATE);
  dbms_sql.define_column (l_cursor, 56,V_MILESTONE_DATE);
  dbms_sql.define_column (l_cursor, 57,V_ACTION_TAKEN,50);

  l_rows   := dbms_sql.execute(l_cursor);

  LOOP

     l_count := dbms_sql.fetch_rows( l_cursor );
     EXIT WHEN l_count <> 1;

        dbms_sql.column_value (l_cursor, 1,V_LOCATION_ID);
        dbms_sql.column_value (l_cursor, 2,V_OCCUPANCY_DATE);
        dbms_sql.column_value (l_cursor, 3,V_LEASE_ID);
        dbms_sql.column_value (l_cursor, 4,V_LEASE_NAME);
        dbms_sql.column_value (l_cursor, 5,V_LEASE_NUMBER);
        dbms_sql.column_value (l_cursor, 6,V_LEASE_COM_DATE);
        dbms_sql.column_value (l_cursor, 7,V_LEASE_TERM_DATE);
        dbms_sql.column_value (l_cursor, 8,V_LEASE_EXE_DATE);
        dbms_sql.column_value (l_cursor, 9,V_LEASE_TERM);
        dbms_sql.column_value (l_cursor, 10,V_LEASE_CLASS);
        dbms_sql.column_value (l_cursor, 11,V_LEASE_RESP_USER);
        dbms_sql.column_value (l_cursor, 12,V_LEASE_STATUS);
        dbms_sql.column_value (l_cursor, 13,V_LEASE_TYPE);
        dbms_sql.column_value (l_cursor, 14,V_ESTIMATED_OCCUPANCY_DATE);
        dbms_sql.column_value (l_cursor, 15,V_ACTUAL_OCCUPANCY_DATE);
        dbms_sql.column_value (l_cursor, 16,V_ATTRIBUTE_CATEGORY);
        dbms_sql.column_value (l_cursor, 17,V_ATTRIBUTE1);
        dbms_sql.column_value (l_cursor, 18,V_ATTRIBUTE2);
        dbms_sql.column_value (l_cursor, 19,V_ATTRIBUTE3);
        dbms_sql.column_value (l_cursor, 20,V_ATTRIBUTE4);
        dbms_sql.column_value (l_cursor, 21,V_ATTRIBUTE5);
        dbms_sql.column_value (l_cursor, 22,V_ATTRIBUTE6);
        dbms_sql.column_value (l_cursor, 23,V_ATTRIBUTE7);
        dbms_sql.column_value (l_cursor, 24,V_ATTRIBUTE8);
        dbms_sql.column_value (l_cursor, 25,V_ATTRIBUTE9);
        dbms_sql.column_value (l_cursor, 26,V_ATTRIBUTE10);
        dbms_sql.column_value (l_cursor, 27,V_ATTRIBUTE11);
        dbms_sql.column_value (l_cursor, 28,V_ATTRIBUTE12);
        dbms_sql.column_value (l_cursor, 29,V_ATTRIBUTE13);
        dbms_sql.column_value (l_cursor, 30,V_ATTRIBUTE14);
        dbms_sql.column_value (l_cursor, 31,V_ATTRIBUTE15);
        dbms_sql.column_value (l_cursor, 32,V_LAST_UPDATE_DATE);
        dbms_sql.column_value (l_cursor, 33,V_LAST_UPDATED_BY);
        dbms_sql.column_value (l_cursor, 34,V_LAST_UPDATE_LOGIN);
        dbms_sql.column_value (l_cursor, 35,V_CREATION_DATE);
        dbms_sql.column_value (l_cursor, 36,V_CREATED_BY);
        dbms_sql.column_value (l_cursor, 37,V_LOCATION_TYPE);
        dbms_sql.column_value (l_cursor, 38,V_LOCATION_NAME);
        dbms_sql.column_value (l_cursor, 39,V_LOCATION_CODE);
        dbms_sql.column_value (l_cursor, 40,V_SPACE_TYPE);
        dbms_sql.column_value (l_cursor, 41,V_ADDRESS);
        dbms_sql.column_value (l_cursor, 42,V_COUNTY);
        dbms_sql.column_value (l_cursor, 43,V_CITY);
        dbms_sql.column_value (l_cursor, 44,V_STATE);
        dbms_sql.column_value (l_cursor, 45,V_PROVINCE);
        dbms_sql.column_value (l_cursor, 46,V_ZIP_CODE);
        dbms_sql.column_value (l_cursor, 47,V_COUNTRY);
        dbms_sql.column_value (l_cursor, 48,V_RENTABLE_AREA);
        dbms_sql.column_value (l_cursor, 49,V_USABLE_AREA);
        dbms_sql.column_value (l_cursor, 50,V_GROSS_AREA);
        dbms_sql.column_value (l_cursor, 51,V_TENURE);
        dbms_sql.column_value (l_cursor, 52,V_LEASE_MILESTONE_ID);
        dbms_sql.column_value (l_cursor, 53,V_MILESTONE_TYPE);
        dbms_sql.column_value (l_cursor, 54,V_RESPONSIBLE_USER);
        dbms_sql.column_value (l_cursor, 55,V_ACTION_DATE);
        dbms_sql.column_value (l_cursor, 56,V_MILESTONE_DATE);
        dbms_sql.column_value (l_cursor, 57,V_ACTION_TAKEN);

        v_code_data:=pnp_util_func.get_location_name(V_LOCATION_ID, V_OCCUPANCY_DATE);

        PNP_DEBUG_PKG.put_log_msg('pn_roll_rent_les: insert(+)');

        INSERT INTO pn_milestones_itf
        (LEASE_MILESTONE_ID                         ,
        MILESTONE_TYPE_CODE                         ,
        RESPONSIBLE_USER                            ,
        ACTION_DATE                                 ,
        NOTIFICATION_DATE                           ,
        ACTION_TAKEN                                ,
        LEASE_ID                                    ,
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
        (V_LEASE_MILESTONE_ID                       ,
        V_MILESTONE_TYPE                            ,
        V_RESPONSIBLE_USER                          ,
        V_ACTION_DATE                               ,
        V_MILESTONE_DATE                            ,
        V_ACTION_TAKEN                              ,
        V_LEASE_ID                                  ,
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
        l_request_id                                );

        PNP_DEBUG_PKG.put_log_msg('pn_roll_rent_les: insert(-)');

  END LOOP;

  IF dbms_sql.is_open (l_cursor) THEN
     dbms_sql.close_cursor (l_cursor);
  END IF;

  PNP_DEBUG_PKG.put_log_msg('pn_lease_optionsLoop(-)');

  --If there is something amiss...
  EXCEPTION
  WHEN OTHERS THEN
     retcode:=2;
     errbuf:=SUBSTR(SQLERRM,1,235);
     RAISE;
     COMMIT;
END pn_milestones;
END pnrx_milestones;

/
