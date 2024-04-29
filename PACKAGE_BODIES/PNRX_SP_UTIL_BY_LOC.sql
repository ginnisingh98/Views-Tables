--------------------------------------------------------
--  DDL for Package Body PNRX_SP_UTIL_BY_LOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_SP_UTIL_BY_LOC" AS
/* $Header: PNRXULOB.pls 120.3 2005/12/01 15:04:45 appldev ship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : PN_SPACE_UTIL_LOC
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - Replaced pn_locations with _ALL table
-- 25-OCT-05  Hareesha o ATG mandated changes for SQL literals using dbms_sql.
-------------------------------------------------------------------------------
PROCEDURE pn_space_util_loc(
           property_code_low           IN                    VARCHAR2,
           property_code_high          IN                    VARCHAR2,
           location_code_low           IN                    VARCHAR2,
           location_code_high          IN                    VARCHAR2,
           location_type               IN                    VARCHAR2,
           as_of_date                  IN                    DATE,
           l_request_id                IN                    NUMBER,
           l_user_id                   IN                    NUMBER,
           retcode                     OUT NOCOPY            VARCHAR2,
           errbuf                      OUT NOCOPY            VARCHAR2
                      )
IS
  l_login_id                                 NUMBER;
  l_one                                      NUMBER DEFAULT 1;
  l_two                                      NUMBER DEFAULT 2;
  l_three                                    NUMBER DEFAULT 3;
  l_three                                    NUMBER DEFAULT 3;
  --declare all columns as variables here
  V_LOCATION_ID                              NUMBER;
  V_LOCATION_TYPE                            VARCHAR2(80);
  V_LOCATION_ID_1                            NUMBER;
  V_LOCATION_TYPE_1                          VARCHAR2(80);
  V_PROPERTY_CODE_1                          VARCHAR2(90);
  V_LOCATION_NAME                            VARCHAR2(30);
  V_LOCATION_CODE                            VARCHAR2(90);
  V_RENTABLE_AREA                            NUMBER;
  V_USABLE_AREA                              NUMBER;
  V_ASSIGNABLE_AREA                          NUMBER;
  V_COMMON_AREA                              NUMBER;
  V_MAXIMUM_OCCUPANCY                        NUMBER;
  V_OPTIMUM_OCCUPANCY                        NUMBER;
  V_MAXIMUM_VACANCY                          NUMBER;
  V_OPTIMUM_VACANCY                          NUMBER;
  V_USAGE_TYPE                               VARCHAR2(80);
  V_PROPERTY_CODE                            VARCHAR2(90);
  V_VACANT_AREA                              NUMBER;
  V_ASSIGNED_AREA                            NUMBER;
  V_UTILIZED                                 NUMBER;
  V_EMP_START_DATE                           DATE;
  V_EMP_END_DATE                             DATE;
  V_CUST_START_DATE                          DATE;
  V_CUST_END_DATE                            DATE;
  V_ATTRIBUTE_CATEGORY                       VARCHAR2(30);
  V_ATTRIBUTE1                               VARCHAR2(150);
  V_ATTRIBUTE2                               VARCHAR2(150);
  V_ATTRIBUTE3                               VARCHAR2(150);
  V_ATTRIBUTE4                               VARCHAR2(150);
  V_ATTRIBUTE5                               VARCHAR2(150);
  V_ATTRIBUTE6                               VARCHAR2(150);
  V_ATTRIBUTE7                               VARCHAR2(150);
  V_ATTRIBUTE8                               VARCHAR2(150);
  V_ATTRIBUTE9                               VARCHAR2(150);
  V_ATTRIBUTE10                              VARCHAR2(150);
  V_ATTRIBUTE11                              VARCHAR2(150);
  V_ATTRIBUTE12                              VARCHAR2(150);
  V_ATTRIBUTE13                              VARCHAR2(150);
  V_ATTRIBUTE14                              VARCHAR2(150);
  V_ATTRIBUTE15                              VARCHAR2(150);
  V_LAST_UPDATE_DATE                         DATE;
  V_LAST_UPDATED_BY                          NUMBER(15);
  V_LAST_UPDATE_LOGIN                        NUMBER(15);
  V_CREATION_DATE                            DATE;
  V_CREATED_BY                               NUMBER(15);
  V_REQUEST_ID                               NUMBER;
  l_found                                    VARCHAR2(1);
  v_code_data                                PNP_UTIL_FUNC.location_name_rec := NULL;
  v_compare                                  BOOLEAN;
  l_cursor                                   INTEGER;
  l_statement                                VARCHAR2(10000);
  l_rows                                     INTEGER;
  l_count                                    INTEGER;
  l_property_code_low                        VARCHAR2(90);
  l_property_code_high                       VARCHAR2(90);
  l_location_code_low                        VARCHAR2(90);
  l_location_code_high                       VARCHAR2(90);
  l_location_type                            VARCHAR2(30);
  l_as_of_date                               DATE;
  l_cursor_2                                 INTEGER;
  l_statement_2                              VARCHAR2(10000);
  l_rows_2                                   INTEGER;
  l_count_2                                  INTEGER;
  l_LOCATION_ID_1                            NUMBER;


  CURSOR c_check IS
     SELECT 'Y'
     FROM dual
     WHERE EXISTS (SELECT null
                   FROM pn_space_util_loc_itf
                   WHERE location_id = V_LOCATION_ID
                   AND   request_id = l_request_id);

BEGIN
  pnp_debug_pkg.put_log_msg('PNRXULOB: pn_sp_util_locConditions(+)');
  --Initialise status parameters...
  retcode:=0;
  errbuf:='';
  fnd_profile.get('LOGIN_ID', l_login_id);

  l_cursor := dbms_sql.open_cursor;
  l_statement :=
  'SELECT
   loc.location_id     LOCATION_ID
    FROM   pn_locations_all loc,
           pn_properties p
    WHERE  p.property_id(+) = loc.property_id ';

  l_as_of_date := as_of_date;
  l_statement :=
  l_statement || ' AND loc.active_start_date <= :l_as_of_date
                   AND loc.active_end_date >= :l_as_of_date ';

  --property code conditions
  IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
     l_property_code_low := property_code_low;
     l_property_code_high := property_code_high;
     l_statement :=
     l_statement || ' AND p.property_code  BETWEEN :l_property_code_low AND :l_property_code_high ';

  ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
     l_property_code_high := property_code_high;
     l_statement :=
     l_statement || ' AND p.property_code = :l_property_code_high ';

  ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
     l_property_code_low := property_code_low;
     l_statement :=
     l_statement || ' AND p.property_code = :l_property_code_low ';

  ELSE
     l_statement :=
     l_statement || ' AND 1 = 1 ';

  END IF;

  --location code conditions.....
  IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     l_location_code_low := location_code_low;
     l_location_code_high := location_code_high;
     l_statement :=
     l_statement || ' AND loc.location_code  BETWEEN :l_location_code_low AND :l_location_code_high ';

  ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     l_location_code_high := location_code_high;
     l_statement :=
     l_statement || ' AND loc.location_code = :l_location_code_high ';

  ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     l_location_code_low := location_code_low;
     l_statement :=
     l_statement || ' AND loc.location_code = :l_location_code_low ';

  ELSE
     l_statement :=
     l_statement || ' AND 2 = 2 ';

  END IF;
  --location type conditions....
  IF location_type IS NOT NULL THEN
     l_location_type := location_type;
     l_statement :=
     l_statement || ' AND loc.location_type_lookup_code = :l_location_type ';

  ELSE
     l_statement :=
     l_statement || ' AND 3 = 3 ';

  END IF;

  pnp_debug_pkg.log('l_statement:'||l_statement);

  dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

  dbms_sql.bind_variable
            (l_cursor,'l_as_of_date',l_as_of_date );

  IF property_code_low IS NOT NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_property_code_low',l_property_code_low );
     dbms_sql.bind_variable
            (l_cursor,'l_property_code_high',l_property_code_high );

  ELSIF property_code_low IS NULL AND property_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_property_code_high',l_property_code_high );

  ELSIF property_code_low IS NOT NULL AND property_code_high IS NULL THEN
        dbms_sql.bind_variable
            (l_cursor,'l_property_code_low',l_property_code_low );
  END IF;

  IF location_code_low IS NOT NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_location_code_high',l_location_code_high );
     dbms_sql.bind_variable
            (l_cursor,'l_location_code_low',l_location_code_low );

  ELSIF location_code_low IS NULL AND location_code_high IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_location_code_high',l_location_code_high );

  ELSIF location_code_low IS NOT NULL AND location_code_high IS NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_location_code_low',l_location_code_low );
  END IF;

  IF location_type IS NOT NULL THEN
     dbms_sql.bind_variable
            (l_cursor,'l_location_type',l_location_type );
  END IF;

  dbms_sql.define_column (l_cursor, 1,V_LOCATION_ID_1);

  l_rows   := dbms_sql.execute(l_cursor);

  LOOP

     l_count := dbms_sql.fetch_rows( l_cursor );

     EXIT WHEN l_count <> 1;

     dbms_sql.column_value (l_cursor, 1,V_LOCATION_ID_1);

     l_cursor_2 := dbms_sql.open_cursor;
     l_statement_2 :=
     'SELECT
        loc.location_id                                                    LOCATION_ID,
        fl1.meaning                                                        LOCATION_TYPE,
        NVL(NVL(loc.building, loc.floor), loc.office)                      LOCATION_NAME,
        loc.location_code                                                  LOCATION_CODE,
        DECODE (location_type_lookup_code,''OFFICE'',loc.rentable_area,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_rentable_area(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_rentable_area(loc.location_id,:l_as_of_date),
                      rentable_area)                                       RENTABLE_AREA,
        DECODE (location_type_lookup_code,''OFFICE'',loc.usable_area,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_usable_area(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_usable_area(loc.location_id,:l_as_of_date),
                      usable_area)                                         USABLE_AREA,
        DECODE (location_type_lookup_code,''OFFICE'',loc.assignable_area,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_assignable_area(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_assignable_area(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_assignable_area(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_assignable_area(loc.location_id,:l_as_of_date),
                      assignable_area)                                     ASSIGNABLE_AREA,
        DECODE (location_type_lookup_code,''OFFICE'',loc.common_area,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_common_area(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_common_area(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_common_area(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_common_area(loc.location_id,:l_as_of_date),
                 common_area)                                         COMMON_AREA,
        DECODE (location_type_lookup_code,''OFFICE'',loc.max_capacity,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_max_capacity(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_max_capacity(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_max_capacity(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_max_capacity(loc.location_id,:l_as_of_date),
                      max_capacity)                                        MAXIMUM_OCCUPANCY,
        DECODE (location_type_lookup_code,''OFFICE'',loc.optimum_capacity,
                ''FLOOR'',PNP_UTIL_FUNC.get_floor_optimum_capacity(loc.location_id,:l_as_of_date),
                ''PARCEL'',PNP_UTIL_FUNC.get_floor_optimum_capacity(loc.location_id,:l_as_of_date),
                ''BUILDING'',PNP_UTIL_FUNC.get_building_optimum_capacity(loc.location_id,:l_as_of_date),
                ''LAND'',PNP_UTIL_FUNC.get_building_optimum_capacity(loc.location_id,:l_as_of_date),
                      optimum_capacity)                                    OPTIMUM_OCCUPANCY,
        fl.meaning                                                         USAGE_TYPE,
        loc.attribute_category                                             ATTRIBUTE_CATEGORY,
        loc.attribute1                                                     ATTRIBUTE1,
        loc.attribute2                                                     ATTRIBUTE2,
        loc.attribute3                                                     ATTRIBUTE3,
        loc.attribute4                                                     ATTRIBUTE4,
        loc.attribute5                                                     ATTRIBUTE5,
        loc.attribute6                                                     ATTRIBUTE6,
        loc.attribute7                                                     ATTRIBUTE7,
        loc.attribute8                                                     ATTRIBUTE8,
        loc.attribute9                                                     ATTRIBUTE9,
        loc.attribute10                                                    ATTRIBUTE10,
        loc.attribute11                                                    ATTRIBUTE11,
        loc.attribute12                                                    ATTRIBUTE12,
        loc.attribute13                                                    ATTRIBUTE13,
        loc.attribute14                                                    ATTRIBUTE14,
        loc.attribute15                                                    ATTRIBUTE15,
        loc.last_update_date                                               LAST_UPDATE_DATE,
        loc.last_updated_by                                                LAST_UPDATED_BY,
        loc.last_update_login                                              LAST_UPDATE_LOGIN,
        loc.creation_date                                                  CREATION_DATE,
        loc.created_by                                                     CREATED_BY
       FROM pn_locations_all loc,
           fnd_lookups  fl,
           fnd_lookups  fl1
       WHERE fl.lookup_code(+) = loc.space_type_lookup_code
       AND   fl.lookup_type(+) = ''PN_SPACE_TYPE''
       AND   fl1.lookup_code(+)= loc.location_type_lookup_code
       AND   fl1.lookup_type(+)= ''PN_LOCATION_TYPE''
       AND   loc.location_id IN (SELECT distinct loc.location_id FROM pn_locations_all loc
                                 WHERE loc.active_start_date <= :l_as_of_date
                                 AND   loc.active_end_date >= :l_as_of_date
                                 START WITH loc.location_id = :l_LOCATION_ID_1
                                 CONNECT BY PRIOR loc.location_id = loc.parent_location_id
           AND :l_as_of_date BETWEEN prior active_start_date AND  prior active_end_date)';

     l_LOCATION_ID_1 := V_LOCATION_ID_1;

     dbms_sql.parse(l_cursor_2, l_statement_2, dbms_sql.native);

     dbms_sql.bind_variable
            (l_cursor_2,'l_as_of_date',l_as_of_date );

     dbms_sql.bind_variable
            (l_cursor_2,'l_LOCATION_ID_1',l_LOCATION_ID_1 );

     dbms_sql.define_column (l_cursor_2, 1,V_LOCATION_ID);
     dbms_sql.define_column (l_cursor_2, 2,V_LOCATION_TYPE,80);
     dbms_sql.define_column (l_cursor_2, 3,V_LOCATION_NAME,30);
     dbms_sql.define_column (l_cursor_2, 4,V_LOCATION_CODE,90);
     dbms_sql.define_column (l_cursor_2, 5,V_RENTABLE_AREA);
     dbms_sql.define_column (l_cursor_2, 6,V_USABLE_AREA);
     dbms_sql.define_column (l_cursor_2, 7,V_ASSIGNABLE_AREA);
     dbms_sql.define_column (l_cursor_2, 8,V_COMMON_AREA);
     dbms_sql.define_column (l_cursor_2, 9,V_MAXIMUM_OCCUPANCY);
     dbms_sql.define_column (l_cursor_2, 10,V_OPTIMUM_OCCUPANCY);
     dbms_sql.define_column (l_cursor_2, 11,V_USAGE_TYPE,80);
     dbms_sql.define_column (l_cursor_2, 12,V_ATTRIBUTE_CATEGORY,30);
     dbms_sql.define_column (l_cursor_2, 13,V_ATTRIBUTE1,150);
     dbms_sql.define_column (l_cursor_2, 14,V_ATTRIBUTE2,150);
     dbms_sql.define_column (l_cursor_2, 15,V_ATTRIBUTE3,150);
     dbms_sql.define_column (l_cursor_2, 16,V_ATTRIBUTE4,150);
     dbms_sql.define_column (l_cursor_2, 17,V_ATTRIBUTE5,150);
     dbms_sql.define_column (l_cursor_2, 18,V_ATTRIBUTE6,150);
     dbms_sql.define_column (l_cursor_2, 19,V_ATTRIBUTE7,150);
     dbms_sql.define_column (l_cursor_2, 20,V_ATTRIBUTE8,150);
     dbms_sql.define_column (l_cursor_2, 21,V_ATTRIBUTE9,150);
     dbms_sql.define_column (l_cursor_2, 22,V_ATTRIBUTE10,150);
     dbms_sql.define_column (l_cursor_2, 23,V_ATTRIBUTE11,150);
     dbms_sql.define_column (l_cursor_2, 24,V_ATTRIBUTE12,150);
     dbms_sql.define_column (l_cursor_2, 25,V_ATTRIBUTE13,150);
     dbms_sql.define_column (l_cursor_2, 26,V_ATTRIBUTE14,150);
     dbms_sql.define_column (l_cursor_2, 27,V_ATTRIBUTE15,150);
     dbms_sql.define_column (l_cursor_2, 28,V_LAST_UPDATE_DATE);
     dbms_sql.define_column (l_cursor_2, 29,V_LAST_UPDATED_BY);
     dbms_sql.define_column (l_cursor_2, 30,V_LAST_UPDATE_LOGIN);
     dbms_sql.define_column (l_cursor_2, 31,V_CREATION_DATE);
     dbms_sql.define_column (l_cursor_2, 32,V_CREATED_BY);

     l_rows_2   := dbms_sql.execute(l_cursor_2);

     LOOP
        l_count_2 := dbms_sql.fetch_rows( l_cursor_2 );

        EXIT WHEN l_count_2 <> 1;

        dbms_sql.column_value (l_cursor_2, 1,V_LOCATION_ID);
        dbms_sql.column_value (l_cursor_2, 2,V_LOCATION_TYPE);
        dbms_sql.column_value (l_cursor_2, 3,V_LOCATION_NAME);
        dbms_sql.column_value (l_cursor_2, 4,V_LOCATION_CODE);
        dbms_sql.column_value (l_cursor_2, 5,V_RENTABLE_AREA);
        dbms_sql.column_value (l_cursor_2, 6,V_USABLE_AREA);
        dbms_sql.column_value (l_cursor_2, 7,V_ASSIGNABLE_AREA);
        dbms_sql.column_value (l_cursor_2, 8,V_COMMON_AREA);
        dbms_sql.column_value (l_cursor_2, 9,V_MAXIMUM_OCCUPANCY);
        dbms_sql.column_value (l_cursor_2, 10,V_OPTIMUM_OCCUPANCY);
        dbms_sql.column_value (l_cursor_2, 11,V_USAGE_TYPE);
        dbms_sql.column_value (l_cursor_2, 12,V_ATTRIBUTE_CATEGORY);
        dbms_sql.column_value (l_cursor_2, 13,V_ATTRIBUTE1);
        dbms_sql.column_value (l_cursor_2, 14,V_ATTRIBUTE2);
        dbms_sql.column_value (l_cursor_2, 15,V_ATTRIBUTE3);
        dbms_sql.column_value (l_cursor_2, 16,V_ATTRIBUTE4);
        dbms_sql.column_value (l_cursor_2, 17,V_ATTRIBUTE5);
        dbms_sql.column_value (l_cursor_2, 18,V_ATTRIBUTE6);
        dbms_sql.column_value (l_cursor_2, 19,V_ATTRIBUTE7);
        dbms_sql.column_value (l_cursor_2, 20,V_ATTRIBUTE8);
        dbms_sql.column_value (l_cursor_2, 21,V_ATTRIBUTE9);
        dbms_sql.column_value (l_cursor_2, 22,V_ATTRIBUTE10);
        dbms_sql.column_value (l_cursor_2, 23,V_ATTRIBUTE11);
        dbms_sql.column_value (l_cursor_2, 24,V_ATTRIBUTE12);
        dbms_sql.column_value (l_cursor_2, 25,V_ATTRIBUTE13);
        dbms_sql.column_value (l_cursor_2, 26,V_ATTRIBUTE14);
        dbms_sql.column_value (l_cursor_2, 27,V_ATTRIBUTE15);
        dbms_sql.column_value (l_cursor_2, 28,V_LAST_UPDATE_DATE);
        dbms_sql.column_value (l_cursor_2, 29,V_LAST_UPDATED_BY);
        dbms_sql.column_value (l_cursor_2, 30,V_LAST_UPDATE_LOGIN);
        dbms_sql.column_value (l_cursor_2, 31,V_CREATION_DATE);
        dbms_sql.column_value (l_cursor_2, 32,V_CREATED_BY);

        pnp_debug_pkg.log(' bfore insert into pn_space_util_loc_itf ');
        v_code_data := pnp_util_func.get_location_name(V_LOCATION_ID, as_of_date);

        /* Before inserting, check to see whether the record already exists in the table */

        l_found := 'N';
        OPEN c_check;
        FETCH c_check INTO l_found;
        CLOSE c_check;

        IF l_found = 'N' then

        INSERT INTO pn_space_util_loc_itf
        (LOCATION_ID                              ,
         LOCATION_TYPE                            ,
         LOCATION_NAME                            ,
         LOCATION_CODE                            ,
         RENTABLE_AREA                            ,
         USABLE_AREA                              ,
         ASSIGNABLE_AREA                          ,
         COMMON_AREA                              ,
         MAXIMUM_OCCUPANCY                        ,
         OPTIMUM_OCCUPANCY                        ,
         USAGE_TYPE                               ,
         VACANT_AREA                              ,
         ASSIGNED_AREA                            ,
         UTILIZED                                 ,
         MAXIMUM_VACANCY                          ,
         OPTIMUM_VACANCY                          ,
         PROPERTY_CODE                            ,
         PROPERTY_NAME                            ,
         BUILDING_LOCATION_CODE                   ,
         BUILDING_OR_LAND_NAME                    ,
         FLOOR_LOCATION_CODE                      ,
         FLOOR_OR_PARCEL_NAME                     ,
         OFFICE_LOCATION_CODE                     ,
         OFFICE_OR_SECTION_NAME                   ,
         LOC_ATTRIBUTE_CATEGORY                   ,
         LOC_ATTRIBUTE1                           ,
         LOC_ATTRIBUTE2                           ,
         LOC_ATTRIBUTE3                           ,
         LOC_ATTRIBUTE4                           ,
         LOC_ATTRIBUTE5                           ,
         LOC_ATTRIBUTE6                           ,
         LOC_ATTRIBUTE7                           ,
         LOC_ATTRIBUTE8                           ,
         LOC_ATTRIBUTE9                           ,
         LOC_ATTRIBUTE10                          ,
         LOC_ATTRIBUTE11                          ,
         LOC_ATTRIBUTE12                          ,
         LOC_ATTRIBUTE13                          ,
         LOC_ATTRIBUTE14                          ,
         LOC_ATTRIBUTE15                          ,
         LAST_UPDATE_DATE                         ,
         LAST_UPDATED_BY                          ,
         LAST_UPDATE_LOGIN                        ,
         CREATION_DATE                            ,
         CREATED_BY                               ,
         REQUEST_ID                               )
        VALUES
        ( V_LOCATION_ID                           ,
          V_LOCATION_TYPE                         ,
          V_LOCATION_NAME                         ,
          V_LOCATION_CODE                         ,
          V_RENTABLE_AREA                         ,
          V_USABLE_AREA                           ,
          V_ASSIGNABLE_AREA                       ,
          V_COMMON_AREA                           ,
          V_MAXIMUM_OCCUPANCY                     ,
          V_OPTIMUM_OCCUPANCY                     ,
          V_USAGE_TYPE                            ,
          pnp_util_func.get_vacant_area(V_LOCATION_ID, as_of_date),
          V_ASSIGNABLE_AREA-pnp_util_func.get_vacant_area(V_LOCATION_ID, as_of_date),
          pnp_util_func.get_utilized_capacity(V_LOCATION_ID, as_of_date),
          decode(SIGN(V_MAXIMUM_OCCUPANCY-pnp_util_func.get_utilized_capacity(V_LOCATION_ID, as_of_date)),-1,0,V_MAXIMUM_OCCUPANCY-pnp_util_func.get_utilized_capacity(V_LOCATION_ID, as_of_date)),
          decode(SIGN(V_OPTIMUM_OCCUPANCY-pnp_util_func.get_utilized_capacity(V_LOCATION_ID, as_of_date)),-1,0,V_OPTIMUM_OCCUPANCY-pnp_util_func.get_utilized_capacity(V_LOCATION_ID, as_of_date)),
          v_code_data.PROPERTY_CODE               ,
          v_code_data.PROPERTY_NAME               ,
          v_code_data.BUILDING_LOCATION_CODE      ,
          v_code_data.BUILDING                    ,
          v_code_data.FLOOR_LOCATION_CODE         ,
          v_code_data.FLOOR                       ,
          v_code_data.OFFICE_LOCATION_CODE        ,
          v_code_data.OFFICE                      ,
          V_ATTRIBUTE_CATEGORY                    ,
          V_ATTRIBUTE1                            ,
          V_ATTRIBUTE2                            ,
          V_ATTRIBUTE3                            ,
          V_ATTRIBUTE4                            ,
          V_ATTRIBUTE5                            ,
          V_ATTRIBUTE6                            ,
          V_ATTRIBUTE7                            ,
          V_ATTRIBUTE8                            ,
          V_ATTRIBUTE9                            ,
          V_ATTRIBUTE10                           ,
          V_ATTRIBUTE11                           ,
          V_ATTRIBUTE12                           ,
          V_ATTRIBUTE13                           ,
          V_ATTRIBUTE14                           ,
          V_ATTRIBUTE15                           ,
          V_LAST_UPDATE_DATE                      ,
          V_LAST_UPDATED_BY                       ,
          V_LAST_UPDATE_LOGIN                     ,
          V_CREATION_DATE                         ,
          V_CREATED_BY                            ,
          l_request_id                            );

        END IF;

     END LOOP;
     pnp_debug_pkg.put_log_msg('PNRXULOB: c_pn: c_util_loc Loop (-)');

     IF dbms_sql.is_open (l_cursor_2) THEN
        dbms_sql.close_cursor (l_cursor_2);
     END IF;

 END LOOP;
  pnp_debug_pkg.put_log_msg('PNRXULOB: c_pn Loop (-)');

  IF dbms_sql.is_open (l_cursor) THEN
     dbms_sql.close_cursor (l_cursor);
  END IF;

  COMMIT;
  --If there is something amiss...
  pnp_debug_pkg.put_log_msg('PNRXULOB: pn_sp_util_locConditions(-)');

EXCEPTION
WHEN OTHERS THEN
  retcode:=2;
  errbuf:=SUBSTR(SQLERRM,1,235);
  RAISE;
  COMMIT;
END pn_space_util_loc;
END pnrx_sp_util_by_loc;

/
