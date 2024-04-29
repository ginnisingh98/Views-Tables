--------------------------------------------------------
--  DDL for Package Body PN_EXP_TO_CAD_ITF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_EXP_TO_CAD_ITF" AS
  -- $Header: PNTXPCDB.pls 120.5 2006/08/31 10:41:23 sraaj ship $

  -------------------------------------------------------------------
  -- for loading Locations Info into the Interface Table ( FOR CAFM )
  -- ( Run AS a Conc Process )
  -- ( PN_LOCATIONS --> PN_LOCATIONS_ITF )
  -- 30-AUG-06 Shabda o As part of bug # 5449595, we now pas canonical dates
  -- This method expects non canonical too, so we change it back to non canonical.
  -------------------------------------------------------------------
  PROCEDURE exp_to_cad_itf (
    errbuf                  OUT NOCOPY      VARCHAR2   ,
    retcode                 OUT NOCOPY      VARCHAR2   ,
    locn_or_spc_flag                        VARCHAR2   ,
    p_batch_name                            VARCHAR2   ,
    p_locn_type                             VARCHAR2   ,
    p_locn_code_from                        VARCHAR2   ,
    p_locn_code_to                          VARCHAR2   ,
    p_last_update_from                      VARCHAR2   ,
    p_last_update_to                        VARCHAR2   ,
    p_as_of_date                            VARCHAR2 DEFAULT NULL
      )

  IS
     l_as_of_date DATE := pnp_util_func.get_as_of_date(fnd_date.canonical_to_date(p_as_of_date));
  BEGIN

    IF (locn_or_spc_flag = 'LOCATION') THEN

      BEGIN
        exp_loc_to_cad_itf (
          p_batch_name       => p_batch_name         ,
          p_locn_type        => p_locn_type          ,
          p_locn_code_from   => p_locn_code_from     ,
          p_locn_code_to     => p_locn_code_to       ,
          p_last_update_from => p_last_update_from   ,
          p_last_update_to   => p_last_update_to     ,
          p_as_of_date       => l_as_of_date
        );

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name ('PN', 'PN_EXP_LOC_TO_CAD_ITF');
          RAISE;

      END;

    ELSIF (locn_or_spc_flag = 'SPACE') THEN

      BEGIN
        exp_spc_to_cad_itf (
          p_batch_name         ,
          p_locn_type          ,
          p_locn_code_from     ,
          p_locn_code_to       ,
          p_last_update_from   ,
          p_last_update_to     ,
          p_as_of_date
        );

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name ('PN', 'PN_EXP_SPC_TO_CAD_ITF');
          RAISE;

      END;

    -- This should logically not be reached.
    ELSE
      APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;

  END exp_to_cad_itf;


  -----------------------------------------------------------------------------
  -- FOR loading Locations Info into the Interface Table ( FOR CAFM )
  -- ( Run AS a Conc Process )
  -- ( PN_LOCATIONS --> PN_LOCATIONS_ITF )
  -- 15-JUL-05  hareesha o Bug 4284035 - Replaced pn_addresses with _ALL table.
  -- 29-SEP-05  Hareesha o ATG mandated changes for SQL literals using dbms_sql.
   -----------------------------------------------------------------------------
  PROCEDURE exp_loc_to_cad_itf (
    p_batch_name            IN VARCHAR2   ,
    p_locn_type             IN VARCHAR2   ,
    p_locn_code_from        IN VARCHAR2   ,
    p_locn_code_to          IN VARCHAR2   ,
    p_last_update_from      IN VARCHAR2   ,
    p_last_update_to        IN VARCHAR2   ,
    p_as_of_date            IN VARCHAR2
  )


  IS

    l_last_update_from        DATE := fnd_date.canonical_to_date(NVL(p_last_update_from,'0001/01/01:00:00:00'));
    l_last_update_to          DATE := fnd_date.canonical_to_date(NVL(p_last_update_to,'4712/12/31:00:00:00'));

/* this is for a probable future use...
    l_as_of_date              DATE := NVL(p_as_of_date,
                                          fnd_date.canonical_to_date('4712/12/31:00:00:00'));
*/
    exists_in_itf             NUMBER;
    insert_update             VARCHAR2(6);
    FAIL_ON_UPDATE            EXCEPTION;
    INVALID_PARAMETER         EXCEPTION;

    v_where_clause                          VARCHAR2(5000) := ' ';
    v_dummy                                 INTEGER;

    v_counter                               NUMBER    := 0;
    v_fail                                  NUMBER    := 0;
    v_success                               NUMBER    := 0;

    v_location_id                           PN_LOCATIONS.LOCATION_ID%TYPE;
    v_location_code                         PN_LOCATIONS.LOCATION_CODE%TYPE;
    v_location_type_lookup_code             PN_LOCATIONS.LOCATION_TYPE_LOOKUP_CODE%TYPE;
    v_space_type_lookup_code                PN_LOCATIONS.SPACE_TYPE_LOOKUP_CODE%TYPE;
    v_last_update_date                      PN_LOCATIONS.LAST_UPDATE_DATE%TYPE;
    v_creation_date                         PN_LOCATIONS.CREATION_DATE%TYPE;
    v_parent_location_id                    PN_LOCATIONS.PARENT_LOCATION_ID%TYPE;
    v_lease_or_owned                        PN_LOCATIONS.LEASE_OR_OWNED%TYPE;
    v_building                              PN_LOCATIONS.BUILDING%TYPE;
    v_floor                                 PN_LOCATIONS.FLOOR%TYPE;
    v_office                                PN_LOCATIONS.OFFICE%TYPE;
    v_address_line1                         PN_ADDRESSES.ADDRESS_LINE1%TYPE;
    v_address_line2                         PN_ADDRESSES.ADDRESS_LINE2%TYPE;
    v_address_line3                         PN_ADDRESSES.ADDRESS_LINE3%TYPE;
    v_address_line4                         PN_ADDRESSES.ADDRESS_LINE4%TYPE;
    v_county                                PN_ADDRESSES.COUNTY%TYPE;
    v_city                                  PN_ADDRESSES.CITY%TYPE;
    v_state                                 PN_ADDRESSES.STATE%TYPE;
    v_province                              PN_ADDRESSES.PROVINCE%TYPE;
    v_zip_code                              PN_ADDRESSES.ZIP_CODE%TYPE;
    v_country                               PN_ADDRESSES.COUNTRY%TYPE;
    v_address_style                         PN_ADDRESSES.ADDRESS_STYLE%TYPE;
    v_max_capacity                          PN_LOCATIONS.MAX_CAPACITY%TYPE;
    v_rentable_area                         PN_LOCATIONS.RENTABLE_AREA%TYPE;
    v_optimum_capacity                      PN_LOCATIONS.OPTIMUM_CAPACITY%TYPE;
    v_usable_area                           PN_LOCATIONS.USABLE_AREA%TYPE;
    v_allocate_cost_center_code             PN_LOCATIONS.ALLOCATE_COST_CENTER_CODE%TYPE;
    v_uom_code                              PN_LOCATIONS.UOM_CODE%TYPE;
    v_last_update_login                     PN_LOCATIONS.LAST_UPDATE_LOGIN%TYPE;
    v_last_updated_by                       PN_LOCATIONS.LAST_UPDATED_BY%TYPE;
    v_created_by                            PN_LOCATIONS.CREATED_BY%TYPE;
    v_attribute_category                    VARCHAR2(30);
    v_attribute1                            VARCHAR2 ( 150 );
    v_attribute2                            VARCHAR2 ( 150 );
    v_attribute3                            VARCHAR2 ( 150 );
    v_attribute4                            VARCHAR2 ( 150 );
    v_attribute5                            VARCHAR2 ( 150 );
    v_attribute6                            VARCHAR2 ( 150 );
    v_attribute7                            VARCHAR2 ( 150 );
    v_attribute8                            VARCHAR2 ( 150 );
    v_attribute9                            VARCHAR2 ( 150 );
    v_attribute10                           VARCHAR2 ( 150 );
    v_attribute11                           VARCHAR2 ( 150 );
    v_attribute12                           VARCHAR2 ( 150 );
    v_attribute13                           VARCHAR2 ( 150 );
    v_attribute14                           VARCHAR2 ( 150 );
    v_attribute15                           VARCHAR2 ( 150 );
    v_addr_attribute_category               VARCHAR2 ( 30 );
    v_addr_attribute1                       VARCHAR2 ( 150 );
    v_addr_attribute2                       VARCHAR2 ( 150 );
    v_addr_attribute3                       VARCHAR2 ( 150 );
    v_addr_attribute4                       VARCHAR2 ( 150 );
    v_addr_attribute5                       VARCHAR2 ( 150 );
    v_addr_attribute6                       VARCHAR2 ( 150 );
    v_addr_attribute7                       VARCHAR2 ( 150 );
    v_addr_attribute8                       VARCHAR2 ( 150 );
    v_addr_attribute9                       VARCHAR2 ( 150 );
    v_addr_attribute10                      VARCHAR2 ( 150 );
    v_addr_attribute11                      VARCHAR2 ( 150 );
    v_addr_attribute12                      VARCHAR2 ( 150 );
    v_addr_attribute13                      VARCHAR2 ( 150 );
    v_addr_attribute14                      VARCHAR2 ( 150 );
    v_addr_attribute15                      VARCHAR2 ( 150 );
    v_source                                PN_LOCATIONS.SOURCE%TYPE;
    v_gross_area                            PN_LOCATIONS.GROSS_AREA%TYPE;
    v_assignable_area                       PN_LOCATIONS.ASSIGNABLE_AREA%TYPE;
    v_class                                 PN_LOCATIONS.CLASS%TYPE;
    v_status_type                           PN_LOCATIONS.STATUS_TYPE%TYPE;
    v_suite                                 PN_LOCATIONS.SUITE%TYPE;
    v_common_area                           PN_LOCATIONS.COMMON_AREA%TYPE;
    v_common_area_flag                      PN_LOCATIONS.COMMON_AREA_FLAG%TYPE;
    v_function_type_lookup_code             PN_LOCATIONS.FUNCTION_TYPE_LOOKUP_CODE%TYPE;   --BUG#2198182
    v_active_start_date                     PN_LOCATIONS.ACTIVE_START_DATE%TYPE;
    v_active_end_date                       PN_LOCATIONS.ACTIVE_END_DATE%TYPE;
    l_cursor                                INTEGER;
    l_statement                             VARCHAR2(10000);
    l_locn_type                             VARCHAR2(30);
    l_locn_code_from                        VARCHAR2(90);
    l_locn_code_to                          VARCHAR2(90);
    l_rows                                  INTEGER;
    l_count                                 INTEGER;
    v_standard_type_lookup_code             PN_LOCATIONS.STANDARD_TYPE_LOOKUP_CODE%TYPE;   --BUG#5359173

  BEGIN

      fnd_message.set_name ('PN','PN_HRSYNC_LOC_TYPE');
      fnd_message.set_token ('TYPE',p_locn_type);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      l_cursor := dbms_sql.open_cursor;
      l_statement :=
      'SELECT
                       LOCATION_ID,
                       LOCATION_CODE,
                       LOCATION_TYPE_LOOKUP_CODE,
                       SPACE_TYPE_LOOKUP_CODE,
                       PARENT_LOCATION_ID,
                       LEASE_OR_OWNED,
                       BUILDING,
                       FLOOR,
                       OFFICE,
                       ADDRESS_LINE1,
                       ADDRESS_LINE2,
                       ADDRESS_LINE3,
                       ADDRESS_LINE4,
                       COUNTY,
                       CITY,
                       STATE,
                       PROVINCE,
                       ZIP_CODE,
                       COUNTRY,
                       ADDRESS_STYLE,
                       MAX_CAPACITY,
                       OPTIMUM_CAPACITY,
                       RENTABLE_AREA,
                       USABLE_AREA,
                       ALLOCATE_COST_CENTER_CODE,
                       UOM_CODE,
                       L.ATTRIBUTE_CATEGORY,
                       L.ATTRIBUTE1,
                       L.ATTRIBUTE2,
                       L.ATTRIBUTE3,
                       L.ATTRIBUTE4,
                       L.ATTRIBUTE5,
                       L.ATTRIBUTE6,
                       L.ATTRIBUTE7,
                       L.ATTRIBUTE8,
                       L.ATTRIBUTE9,
                       L.ATTRIBUTE10,
                       L.ATTRIBUTE11,
                       L.ATTRIBUTE12,
                       L.ATTRIBUTE13,
                       L.ATTRIBUTE14,
                       L.ATTRIBUTE15,
                       A.ATTRIBUTE_CATEGORY,
                       A.ATTRIBUTE1,
                       A.ATTRIBUTE2,
                       A.ATTRIBUTE3,
                       A.ATTRIBUTE4,
                       A.ATTRIBUTE5,
                       A.ATTRIBUTE6,
                       A.ATTRIBUTE7,
                       A.ATTRIBUTE8,
                       A.ATTRIBUTE9,
                       A.ATTRIBUTE10,
                       A.ATTRIBUTE11,
                       A.ATTRIBUTE12,
                       A.ATTRIBUTE13,
                       A.ATTRIBUTE14,
                       A.ATTRIBUTE15,
                       L.SOURCE,
                       L.GROSS_AREA,
                       L.ASSIGNABLE_AREA,
                       L.CLASS,
                       L.STATUS_TYPE,
                       L.SUITE,
                       L.COMMON_AREA,
                       L.COMMON_AREA_FLAG,
                       L.FUNCTION_TYPE_LOOKUP_CODE, ---BUG#2198182
                       L.ACTIVE_START_DATE,
                       L.ACTIVE_END_DATE,
                       L.STANDARD_TYPE_LOOKUP_CODE ---BUG#5359173
                     FROM
                       PN_LOCATIONS L,
                       PN_ADDRESSES_ALL A
                     WHERE
                       L.ADDRESS_ID = A.ADDRESS_ID (+)
                       AND L.LAST_UPDATE_DATE >= TRUNC(:date_from )
                       AND  L.LAST_UPDATE_DATE  <= TRUNC(:date_to) ';

    -- Append the AND clause

    IF (p_locn_type <> 'ALL') THEN

      l_locn_type := p_locn_type;
      l_statement :=
      l_statement || ' AND location_type_lookup_code = :l_locn_type';

    END IF;

    -- Append the other AND clauses, as needed.

    IF p_locn_code_from IS NOT NULL THEN

      l_locn_code_from := p_locn_code_from;
      l_statement :=
      l_statement || ' AND location_code >= :l_locn_code_from';

    END IF;

    IF p_locn_code_to IS NOT NULL THEN

      l_locn_code_to := p_locn_code_to;
      l_statement :=
      l_statement || ' AND location_code <= :l_locn_code_to';

    END IF;

    l_statement := l_statement || '  order by L.LOCATION_CODE' ;

    dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

    dbms_sql.bind_variable
            (l_cursor,'date_from',l_last_update_from );

    dbms_sql.bind_variable
            (l_cursor,'date_to',l_last_update_to );

    IF (p_locn_type <> 'ALL') THEN
       dbms_sql.bind_variable
              (l_cursor, 'l_locn_type', l_locn_type );
    END IF;

    IF p_locn_code_from IS NOT NULL THEN
       dbms_sql.bind_variable
              (l_cursor, 'l_locn_code_from', l_locn_code_from );
    END IF;

    IF p_locn_code_to IS NOT NULL THEN
       dbms_sql.bind_variable
              (l_cursor, 'l_locn_code_to', l_locn_code_to );
    END IF;

    dbms_sql.define_column (l_cursor, 1,v_location_id);
    dbms_sql.define_column (l_cursor, 2,v_location_code,90);
    dbms_sql.define_column (l_cursor, 3,v_location_type_lookup_code,30);
    dbms_sql.define_column (l_cursor, 4,v_space_type_lookup_code,30);
    dbms_sql.define_column (l_cursor, 5,v_parent_location_id);
    dbms_sql.define_column (l_cursor, 6,v_lease_or_owned,30);
    dbms_sql.define_column (l_cursor, 7,v_building,30);
    dbms_sql.define_column (l_cursor, 8,v_floor,20);
    dbms_sql.define_column (l_cursor, 9,v_office,20);
    dbms_sql.define_column (l_cursor, 10,v_address_line1,240);
    dbms_sql.define_column (l_cursor, 11,v_address_line2,240);
    dbms_sql.define_column (l_cursor, 12,v_address_line3,240);
    dbms_sql.define_column (l_cursor, 13,v_address_line4,240);
    dbms_sql.define_column (l_cursor, 14,v_county,60);
    dbms_sql.define_column (l_cursor, 15,v_city,60);
    dbms_sql.define_column (l_cursor, 16,v_state,60);
    dbms_sql.define_column (l_cursor, 17,v_province,60);
    dbms_sql.define_column (l_cursor, 18,v_zip_code,60);
    dbms_sql.define_column (l_cursor, 19,v_country,60);
    dbms_sql.define_column (l_cursor, 20,v_address_style,30);
    dbms_sql.define_column (l_cursor, 21,v_max_capacity);
    dbms_sql.define_column (l_cursor, 22,v_optimum_capacity);
    dbms_sql.define_column (l_cursor, 23,v_rentable_area);
    dbms_sql.define_column (l_cursor, 24,v_usable_area);
    dbms_sql.define_column (l_cursor, 25,v_allocate_cost_center_code,30);
    dbms_sql.define_column (l_cursor, 26,v_uom_code,3);
    dbms_sql.define_column (l_cursor, 27,v_attribute_category,30);
    dbms_sql.define_column (l_cursor, 28,v_attribute1,150);
    dbms_sql.define_column (l_cursor, 29,v_attribute2,150);
    dbms_sql.define_column (l_cursor, 30,v_attribute3,150);
    dbms_sql.define_column (l_cursor, 31,v_attribute4,150);
    dbms_sql.define_column (l_cursor, 32,v_attribute5,150);
    dbms_sql.define_column (l_cursor, 33,v_attribute6,150);
    dbms_sql.define_column (l_cursor, 34,v_attribute7,150);
    dbms_sql.define_column (l_cursor, 35,v_attribute8,150);
    dbms_sql.define_column (l_cursor, 36,v_attribute9,150);
    dbms_sql.define_column (l_cursor, 37,v_attribute10,150);
    dbms_sql.define_column (l_cursor, 38,v_attribute11,150);
    dbms_sql.define_column (l_cursor, 39,v_attribute12,150);
    dbms_sql.define_column (l_cursor, 40,v_attribute13,150);
    dbms_sql.define_column (l_cursor, 41,v_attribute14,150);
    dbms_sql.define_column (l_cursor, 42,v_attribute15,150);
    dbms_sql.define_column (l_cursor, 43,v_addr_attribute_category,30);
    dbms_sql.define_column (l_cursor, 44,v_addr_attribute1,150);
    dbms_sql.define_column (l_cursor, 45,v_addr_attribute2,150);
    dbms_sql.define_column (l_cursor, 46,v_addr_attribute3,150);
    dbms_sql.define_column (l_cursor, 47,v_addr_attribute4,150);
    dbms_sql.define_column (l_cursor, 48,v_addr_attribute5,150);
    dbms_sql.define_column (l_cursor, 49,v_addr_attribute6,150);
    dbms_sql.define_column (l_cursor, 50,v_addr_attribute7,150);
    dbms_sql.define_column (l_cursor, 51,v_addr_attribute8,150);
    dbms_sql.define_column (l_cursor, 52,v_addr_attribute9,150);
    dbms_sql.define_column (l_cursor, 53,v_addr_attribute10,150);
    dbms_sql.define_column (l_cursor, 54,v_addr_attribute11,150);
    dbms_sql.define_column (l_cursor, 55,v_addr_attribute12,150);
    dbms_sql.define_column (l_cursor, 56,v_addr_attribute13,150);
    dbms_sql.define_column (l_cursor, 57,v_addr_attribute14,150);
    dbms_sql.define_column (l_cursor, 58,v_addr_attribute15,150);
    dbms_sql.define_column (l_cursor, 59,v_source,80);
    dbms_sql.define_column (l_cursor, 60,v_gross_area);
    dbms_sql.define_column (l_cursor, 61,v_assignable_area);
    dbms_sql.define_column (l_cursor, 62,v_class,30);
    dbms_sql.define_column (l_cursor, 63,v_status_type,30);
    dbms_sql.define_column (l_cursor, 64,v_suite,30);
    dbms_sql.define_column (l_cursor, 65,v_common_area);
    dbms_sql.define_column (l_cursor, 66,v_common_area_flag,1);
    dbms_sql.define_column (l_cursor, 67,v_function_type_lookup_code,30);
    dbms_sql.define_column (l_cursor, 68,v_active_start_date);
    dbms_sql.define_column (l_cursor, 69,v_active_end_date);
    dbms_sql.define_column (l_cursor, 70,v_standard_type_lookup_code,30); ---BUG#5359173

    l_rows   := dbms_sql.execute(l_cursor);

    LOOP

        l_count := dbms_sql.fetch_rows( l_cursor );

        EXIT WHEN l_count <> 1;

        dbms_sql.column_value (l_cursor, 1,v_location_id);
        dbms_sql.column_value (l_cursor, 2,v_location_code);
        dbms_sql.column_value (l_cursor, 3,v_location_type_lookup_code);
        dbms_sql.column_value (l_cursor, 4,v_space_type_lookup_code);
        dbms_sql.column_value (l_cursor, 5,v_parent_location_id);
        dbms_sql.column_value (l_cursor, 6,v_lease_or_owned);
        dbms_sql.column_value (l_cursor, 7,v_building);
        dbms_sql.column_value (l_cursor, 8,v_floor);
        dbms_sql.column_value (l_cursor, 9,v_office);
        dbms_sql.column_value (l_cursor, 10,v_address_line1);
        dbms_sql.column_value (l_cursor, 11,v_address_line2);
        dbms_sql.column_value (l_cursor, 12,v_address_line3);
        dbms_sql.column_value (l_cursor, 13,v_address_line4);
        dbms_sql.column_value (l_cursor, 14,v_county);
        dbms_sql.column_value (l_cursor, 15,v_city);
        dbms_sql.column_value (l_cursor, 16,v_state);
        dbms_sql.column_value (l_cursor, 17,v_province);
        dbms_sql.column_value (l_cursor, 18,v_zip_code);
        dbms_sql.column_value (l_cursor, 19,v_country);
        dbms_sql.column_value (l_cursor, 20,v_address_style);
        dbms_sql.column_value (l_cursor, 21,v_max_capacity);
        dbms_sql.column_value (l_cursor, 22,v_optimum_capacity);
        dbms_sql.column_value (l_cursor, 23,v_rentable_area);
        dbms_sql.column_value (l_cursor, 24,v_usable_area);
        dbms_sql.column_value (l_cursor, 25,v_allocate_cost_center_code);
        dbms_sql.column_value (l_cursor, 26,v_uom_code);
        dbms_sql.column_value (l_cursor, 27,v_attribute_category);
        dbms_sql.column_value (l_cursor, 28,v_attribute1);
        dbms_sql.column_value (l_cursor, 29,v_attribute2);
        dbms_sql.column_value (l_cursor, 30,v_attribute3);
        dbms_sql.column_value (l_cursor, 31,v_attribute4);
        dbms_sql.column_value (l_cursor, 32,v_attribute5);
        dbms_sql.column_value (l_cursor, 33,v_attribute6);
        dbms_sql.column_value (l_cursor, 34,v_attribute7);
        dbms_sql.column_value (l_cursor, 35,v_attribute8);
        dbms_sql.column_value (l_cursor, 36,v_attribute9);
        dbms_sql.column_value (l_cursor, 37,v_attribute10);
        dbms_sql.column_value (l_cursor, 38,v_attribute11);
        dbms_sql.column_value (l_cursor, 39,v_attribute12);
        dbms_sql.column_value (l_cursor, 40,v_attribute13);
        dbms_sql.column_value (l_cursor, 41,v_attribute14);
        dbms_sql.column_value (l_cursor, 42,v_attribute15);
        dbms_sql.column_value (l_cursor, 43,v_addr_attribute_category);
        dbms_sql.column_value (l_cursor, 44,v_addr_attribute1);
        dbms_sql.column_value (l_cursor, 45,v_addr_attribute2);
        dbms_sql.column_value (l_cursor, 46,v_addr_attribute3);
        dbms_sql.column_value (l_cursor, 47,v_addr_attribute4);
        dbms_sql.column_value (l_cursor, 48,v_addr_attribute5);
        dbms_sql.column_value (l_cursor, 49,v_addr_attribute6);
        dbms_sql.column_value (l_cursor, 50,v_addr_attribute7);
        dbms_sql.column_value (l_cursor, 51,v_addr_attribute8);
        dbms_sql.column_value (l_cursor, 52,v_addr_attribute9);
        dbms_sql.column_value (l_cursor, 53,v_addr_attribute10);
        dbms_sql.column_value (l_cursor, 54,v_addr_attribute11);
        dbms_sql.column_value (l_cursor, 55,v_addr_attribute12);
        dbms_sql.column_value (l_cursor, 56,v_addr_attribute13);
        dbms_sql.column_value (l_cursor, 57,v_addr_attribute14);
        dbms_sql.column_value (l_cursor, 58,v_addr_attribute15);
        dbms_sql.column_value (l_cursor, 59,v_source);
        dbms_sql.column_value (l_cursor, 60,v_gross_area);
        dbms_sql.column_value (l_cursor, 61,v_assignable_area);
        dbms_sql.column_value (l_cursor, 62,v_class);
        dbms_sql.column_value (l_cursor, 63,v_status_type);
        dbms_sql.column_value (l_cursor, 64,v_suite);
        dbms_sql.column_value (l_cursor, 65,v_common_area);
        dbms_sql.column_value (l_cursor, 66,v_common_area_flag);
        dbms_sql.column_value (l_cursor, 67,v_function_type_lookup_code);
        dbms_sql.column_value (l_cursor, 68,v_active_start_date);
        dbms_sql.column_value (l_cursor, 69,v_active_end_date);
        dbms_sql.column_value (l_cursor, 70,v_standard_type_lookup_code); ---BUG#5359173
      -- Check if data exists in ITF table already.

      exists_in_itf := 0;

      BEGIN
        SELECT  1
        INTO    exists_in_itf
        FROM    PN_LOCATIONS_ITF
        WHERE   location_id         =  v_location_id
        AND     active_start_date   =  v_active_start_date
        AND     active_END_date     =  v_active_end_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          EXIT;
      END;

      /*
      IF (v_Source IS NOT NULL) THEN
        exists_in_itf := 0;
      END IF;
      */

      -- Insert if data does not exist in ITF table, else Update

      IF (exists_in_itf = 0) THEN


      -- Insert the fetched data into PN_LOCATIONS_ITF table.

      INSERT INTO PN_LOCATIONS_ITF (
        BATCH_NAME,
        ENTRY_TYPE,
        LOCATION_ID,
        LOCATION_CODE,
        LOCATION_TYPE_LOOKUP_CODE,
        SPACE_TYPE_LOOKUP_CODE,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        PARENT_LOCATION_ID,
        LEASE_OR_OWNED,
        BUILDING,
        FLOOR,
        OFFICE,
        ADDRESS_LINE1,
        ADDRESS_LINE2,
        ADDRESS_LINE3,
        ADDRESS_LINE4,
        COUNTY,
        CITY,
        STATE,
        PROVINCE,
        ZIP_CODE,
        COUNTRY,
        ADDRESS_STYLE,
        MAX_CAPACITY,
        OPTIMUM_CAPACITY,
        RENTABLE_AREA,
        USABLE_AREA,
        ALLOCATE_COST_CENTER_CODE,
        UOM_CODE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        CREATED_BY,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        ADDR_ATTRIBUTE_CATEGORY,
        ADDR_ATTRIBUTE1,
        ADDR_ATTRIBUTE2,
        ADDR_ATTRIBUTE3,
        ADDR_ATTRIBUTE4,
        ADDR_ATTRIBUTE5,
        ADDR_ATTRIBUTE6,
        ADDR_ATTRIBUTE7,
        ADDR_ATTRIBUTE8,
        ADDR_ATTRIBUTE9,
        ADDR_ATTRIBUTE10,
        ADDR_ATTRIBUTE11,
        ADDR_ATTRIBUTE12,
        ADDR_ATTRIBUTE13,
        ADDR_ATTRIBUTE14,
        ADDR_ATTRIBUTE15,
        SOURCE,
        GROSS_AREA,
        ASSIGNABLE_AREA,
        CLASS,
        STATUS_TYPE,
        SUITE,
        COMMON_AREA,
        COMMON_AREA_FLAG,
        FUNCTION_TYPE_LOOKUP_CODE,
        STANDARD_TYPE_LOOKUP_CODE, ---BUG#5359173
        ACTIVE_START_DATE,
        ACTIVE_END_DATE
      )
      VALUES (
        p_BATCH_NAME,
        decode(v_SOURCE, NULL, 'A', 'U'),
        v_LOCATION_ID,
        v_LOCATION_CODE,
        v_LOCATION_TYPE_LOOKUP_CODE,
        v_SPACE_TYPE_LOOKUP_CODE,
        SYSDATE,
        SYSDATE,
        v_PARENT_LOCATION_ID,
        v_LEASE_OR_OWNED,
        v_BUILDING,
        v_FLOOR,
        v_OFFICE,
        v_ADDRESS_LINE1,
        v_ADDRESS_LINE2,
        v_ADDRESS_LINE3,
        v_ADDRESS_LINE4,
        v_COUNTY,
        v_CITY,
        v_STATE,
        v_PROVINCE,
        v_ZIP_CODE,
        v_COUNTRY,
        v_ADDRESS_STYLE,
        to_NUMBER(v_MAX_CAPACITY),
        to_NUMBER(v_OPTIMUM_CAPACITY),
        to_NUMBER(v_RENTABLE_AREA),
        to_NUMBER(v_USABLE_AREA),
        v_ALLOCATE_COST_CENTER_CODE,
        v_UOM_CODE,
        fnd_profile.value('CONC_LOGIN_ID'),
        fnd_profile.value('USER_ID'),
        fnd_profile.value('USER_ID'),
        v_ATTRIBUTE_CATEGORY,
        v_ATTRIBUTE1,
        v_ATTRIBUTE2,
        v_ATTRIBUTE3,
        v_ATTRIBUTE4,
        v_ATTRIBUTE5,
        v_ATTRIBUTE6,
        v_ATTRIBUTE7,
        v_ATTRIBUTE8,
        v_ATTRIBUTE9,
        v_ATTRIBUTE10,
        v_ATTRIBUTE11,
        v_ATTRIBUTE12,
        v_ATTRIBUTE13,
        v_ATTRIBUTE14,
        v_ATTRIBUTE15,
        v_ADDR_ATTRIBUTE_CATEGORY,
        v_ADDR_ATTRIBUTE1,
        v_ADDR_ATTRIBUTE2,
        v_ADDR_ATTRIBUTE3,
        v_ADDR_ATTRIBUTE4,
        v_ADDR_ATTRIBUTE5,
        v_ADDR_ATTRIBUTE6,
        v_ADDR_ATTRIBUTE7,
        v_ADDR_ATTRIBUTE8,
        v_ADDR_ATTRIBUTE9,
        v_ADDR_ATTRIBUTE10,
        v_ADDR_ATTRIBUTE11,
        v_ADDR_ATTRIBUTE12,
        v_ADDR_ATTRIBUTE13,
        v_ADDR_ATTRIBUTE14,
        v_ADDR_ATTRIBUTE15,
        NVL(v_source,'PN'),
        v_GROSS_AREA,
        v_ASSIGNABLE_AREA,
        v_CLASS,
        v_STATUS_TYPE,
        v_SUITE,
        v_COMMON_AREA,
        v_COMMON_AREA_FLAG,
        v_function_type_lookup_code,
        v_standard_type_lookup_code,    ---BUG#5359173
        v_active_start_date,
        v_active_end_date
      );

        Insert_Update := 'Insert';

      END IF;


      -- Update data IN ITF table

      IF (exists_in_itf = 1) THEN

        UPDATE  PN_LOCATIONS_ITF SET
        BATCH_NAME = p_batch_name,
        ENTRY_TYPE = 'U',
        LOCATION_ID = v_location_id,
        LOCATION_CODE = v_LOCATION_CODE,
        LOCATION_TYPE_LOOKUP_CODE = v_location_type_lookup_code,
        SPACE_TYPE_LOOKUP_CODE = v_location_type_lookup_code,
        LAST_UPDATE_DATE = SYSDATE,
        CREATION_DATE = SYSDATE,
        PARENT_LOCATION_ID = v_parent_location_id,
        LEASE_OR_OWNED = v_lease_or_owned,
        BUILDING = v_building,
        FLOOR = v_floor,
        OFFICE = v_office,
        ADDRESS_LINE1 = v_address_line1,
        ADDRESS_LINE2 = v_address_line2,
        ADDRESS_LINE3 = v_address_line3,
        ADDRESS_LINE4 = v_address_line4,
        COUNTY = v_county,
        CITY = v_city,
        STATE = v_state,
        PROVINCE = v_province,
        ZIP_CODE = v_zip_code,
        COUNTRY = v_country,
        ADDRESS_STYLE = v_address_style,
        MAX_CAPACITY = v_max_capacity,
        OPTIMUM_CAPACITY = v_optimum_capacity,
        RENTABLE_AREA = v_rentable_area,
        USABLE_AREA = v_usable_area,
        ALLOCATE_COST_CENTER_CODE = v_allocate_cost_center_code,
        UOM_CODE = v_uom_code,
        LAST_UPDATE_LOGIN = fnd_profile.value('CONC_LOGIN_ID'),
        LAST_UPDATED_BY = fnd_profile.value('USER_ID'),
        CREATED_BY = fnd_profile.value('USER_ID'),
        ATTRIBUTE_CATEGORY = v_attribute_category,
        ATTRIBUTE1 = v_attribute1,
        ATTRIBUTE2 = v_attribute2,
        ATTRIBUTE3 = v_attribute3,
        ATTRIBUTE4 = v_attribute4,
        ATTRIBUTE5 = v_attribute5,
        ATTRIBUTE6 = v_attribute6,
        ATTRIBUTE7 = v_attribute7,
        ATTRIBUTE8 = v_attribute8,
        ATTRIBUTE9 = v_attribute9,
        ATTRIBUTE10 = v_attribute10,
        ATTRIBUTE11 = v_attribute11,
        ATTRIBUTE12 = v_attribute12,
        ATTRIBUTE13 = v_attribute13,
        ATTRIBUTE14 = v_attribute14,
        ATTRIBUTE15 = v_attribute15,
        ADDR_ATTRIBUTE_CATEGORY = v_addr_attribute_category,
        ADDR_ATTRIBUTE1 = v_addr_attribute1,
        ADDR_ATTRIBUTE2 = v_addr_attribute2,
        ADDR_ATTRIBUTE3 = v_addr_attribute3,
        ADDR_ATTRIBUTE4 = v_addr_attribute4,
        ADDR_ATTRIBUTE5 = v_addr_attribute5,
        ADDR_ATTRIBUTE6 = v_addr_attribute6,
        ADDR_ATTRIBUTE7 = v_addr_attribute7,
        ADDR_ATTRIBUTE8 = v_addr_attribute8,
        ADDR_ATTRIBUTE9 = v_addr_attribute9,
        ADDR_ATTRIBUTE10 = v_addr_attribute10,
        ADDR_ATTRIBUTE11 = v_addr_attribute11,
        ADDR_ATTRIBUTE12 = v_addr_attribute12,
        ADDR_ATTRIBUTE13 = v_addr_attribute13,
        ADDR_ATTRIBUTE14 = v_addr_attribute14,
        ADDR_ATTRIBUTE15 = v_addr_attribute15,
        -- SOURCE = NVL(v_Source, 'PN'),
        GROSS_AREA = v_gross_area,
        ASSIGNABLE_AREA = v_assignable_area,
        CLASS = v_class,
        STATUS_TYPE = v_status_type,
        SUITE = v_suite,
        COMMON_AREA = v_common_area,
        COMMON_AREA_FLAG = v_common_area_flag,
        FUNCTION_TYPE_LOOKUP_CODE = v_function_type_lookup_code,   --BUG#2198182
        STANDARD_TYPE_LOOKUP_CODE = v_standard_type_lookup_code  ---BUG#5359173
        WHERE LOCATION_ID = v_location_id
        AND   active_start_date = v_active_start_date
        AND   active_end_date   = v_active_end_date ;

        IF (SQL%NOTFOUND) THEN
           RAISE FAIL_ON_UPDATE;
        END IF;

        Insert_Update := 'Update';

      END IF;


      v_Counter  :=  v_Counter + 1;


      -------------------------------------------
      -- For Conc Log/output Files
      -------------------------------------------

      IF v_counter = 1 THEN

      fnd_message.set_name ('PN','PN_BATCH_NAME');
      fnd_message.set_token ('NAME',p_batch_name);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name ('PN','PN_HRSYNC_LOC_TYPE');
      fnd_message.set_token ('TYPE',p_locn_type);
      pnp_debug_pkg.put_log_msg(fnd_message.get);


      END IF;


      PNP_DEBUG_PKG.log (
        'Record NUMBER: '        || v_Counter                   ||
        ', '                     || Insert_Update               ||
        ', Location Code: '      || v_Location_Code             ||
        ', Location Id: '        || v_Location_Id
       );

      fnd_message.set_name ('PN','PN_XPEAM_LOC');
      fnd_message.set_token ('LOC_CODE',v_Location_Code);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

     END LOOP;

     IF dbms_sql.is_open (l_cursor) THEN
        dbms_sql.close_cursor (l_cursor);
     END IF;
    -- Commit our work.

    COMMIT;

    -- log the summary
    v_success := v_counter - v_fail;
    PNP_DEBUG_PKG.put_log_msg('
===============================================================================');
    fnd_message.set_name('PN', 'PN_CAFM_LOCATION_TOTAL');
    fnd_message.set_token('NUM', v_Counter);
    PNP_DEBUG_PKG.put_log_msg(fnd_message.get);

    fnd_message.set_name('PN', 'PN_CAFM_LOCATION_SUCCESS');
    fnd_message.set_token('NUM', v_success);
    PNP_DEBUG_PKG.put_log_msg(fnd_message.get);

    fnd_message.set_name('PN', 'PN_CAFM_LOCATION_FAILURE');
    fnd_message.set_token('NUM', v_fail);
    PNP_DEBUG_PKG.put_log_msg(fnd_message.get);
    PNP_DEBUG_PKG.put_log_msg('
===============================================================================');
   EXCEPTION
      WHEN OTHERS THEN
          RAISE;



  END exp_loc_to_cad_itf;


  -----------------------------------------------------------------------------
  -- For loading Space Allocations Info into the Interface Table ( FOR CAFM )
  -- ( Run AS a Conc Process )
  -- ( PN_SPACE_ALLOCATIONS --> PN_EMP_SPACE_ASSIGN_ITF )
  -- 15-JUL-05  hareesha o Bug 4284035 - Replaced PN_LOCATIONS with _ALL table.
  -- 04-OCT-05  Hareesha o ATG mandated changes for SQL literals using dbms_sql
  -- 28-AUG-06  Shabda o Bug 5449595 - Added changes to accomodate
  -- project_id and task_id
  -- 29-AUG-06  SHABDA o Bug 5449595 - Removed long log messages. Removed unused
  -- commented code
  -----------------------------------------------------------------------------

  PROCEDURE exp_spc_to_cad_itf (
    p_batch_name            IN              VARCHAR2   ,
    p_locn_type             IN              VARCHAR2   ,
    p_locn_code_from        IN              VARCHAR2   ,
    p_locn_code_to          IN              VARCHAR2   ,
    p_last_update_from      IN              VARCHAR2   ,
    p_last_update_to        IN              VARCHAR2   ,
    p_as_of_date            IN              VARCHAR2
  )

  IS

    l_last_update_from        DATE := NVL(fnd_date.canonical_to_date(p_last_update_from),
                                          fnd_date.canonical_to_date('0001/01/01:00:00:00'));
    l_last_update_to          DATE := NVL(fnd_date.canonical_to_date(p_last_update_to),
                                          fnd_date.canonical_to_date('4712/12/31:00:00:00'));
    l_as_of_date              DATE := fnd_date.canonical_to_date(p_as_of_date);

    exists_in_itf                           NUMBER;
    Insert_Update                           VARCHAR2(6);
    FAIL_ON_UPDATE                          EXCEPTION;

    v_cursorid                              INTEGER;
    v_where_clause                          VARCHAR2(5000);
    v_Dummy                                 INTEGER;

    v_Counter                               NUMBER    :=   0;

    v_person_id                             NUMBER;
    v_LOCATION_ID                           NUMBER;
    v_EMP_SPACE_ASSIGN_ID                   NUMBER;
    v_COST_CENTER_CODE                      VARCHAR2(30);
    v_ALLOCATED_AREA                        NUMBER;
    v_LAST_UPDATE_DATE                      DATE;
    v_LAST_UPDATE_LOGIN                     NUMBER;
    v_CREATED_BY                            NUMBER;
    v_CREATION_DATE                         DATE;
    v_LAST_UPDATED_BY                       NUMBER;
    v_ATTRIBUTE_CATEGORY                    VARCHAR2(30);
    v_ATTRIBUTE1                            VARCHAR2(150);
    v_ATTRIBUTE2                            VARCHAR2(150);
    v_ATTRIBUTE3                            VARCHAR2(150);
    v_ATTRIBUTE4                            VARCHAR2(150);
    v_ATTRIBUTE5                            VARCHAR2(150);
    v_ATTRIBUTE6                            VARCHAR2(150);
    v_ATTRIBUTE7                            VARCHAR2(150);
    v_ATTRIBUTE8                            VARCHAR2(150);
    v_ATTRIBUTE9                            VARCHAR2(150);
    v_ATTRIBUTE10                           VARCHAR2(150);
    v_ATTRIBUTE11                           VARCHAR2(150);
    v_ATTRIBUTE12                           VARCHAR2(150);
    v_ATTRIBUTE13                           VARCHAR2(150);
    v_ATTRIBUTE14                           VARCHAR2(150);
    v_ATTRIBUTE15                           VARCHAR2(150);
    v_LOCATION_TYPE_LOOKUP_CODE             VARCHAR2(30);
    v_LOCATION_CODE                         VARCHAR2(90);
    v_SOURCE                                VARCHAR2(80);
    v_EMP_ASSIGN_START_DATE                 DATE;
    v_EMP_ASSIGN_END_DATE                   DATE;
    v_UTILIZED_AREA                         NUMBER;
    vl_date                                 DATE := NULL;
    l_cursor                                INTEGER;
    l_statement                             VARCHAR2(10000);
    l_rows                                  INTEGER;
    l_locn_type                             VARCHAR2(30);
    l_locn_code_from                        VARCHAR2(90);
    l_locn_code_to                          VARCHAR2(90);
    l_count                                 INTEGER;
    v_PROJECT_ID                            NUMBER;
    v_TASK_ID                               NUMBER;

  BEGIN
    pnp_debug_pkg.put_log_msg('inside exp_spc_to_cad_itf');
    vl_date := NVL(vl_date, fnd_date.canonical_to_date('4712/12/31:00:00:00'));

    fnd_message.set_name ('PN','PN_HRSYNC_LOC_TYPE');
    fnd_message.set_token ('TYPE',p_locn_type);
    pnp_debug_pkg.put_log_msg(fnd_message.get);


    l_cursor := dbms_sql.open_cursor;

    l_statement :=
    'SELECT
                       SP.EMP_SPACE_ASSIGN_ID,
                       SP.LOCATION_ID,
                       SP.PERSON_ID,
                       SP.COST_CENTER_CODE,
                       SP.ALLOCATED_AREA,
                       SP.ATTRIBUTE_CATEGORY,
                       SP.ATTRIBUTE1,
                       SP.ATTRIBUTE2,
                       SP.ATTRIBUTE3,
                       SP.ATTRIBUTE4,
                       SP.ATTRIBUTE5,
                       SP.ATTRIBUTE6,
                       SP.ATTRIBUTE7,
                       SP.ATTRIBUTE8,
                       SP.ATTRIBUTE9,
                       SP.ATTRIBUTE10,
                       SP.ATTRIBUTE11,
                       SP.ATTRIBUTE12,
                       SP.ATTRIBUTE13,
                       SP.ATTRIBUTE14,
                       SP.ATTRIBUTE15,
                       LO.LOCATION_TYPE_LOOKUP_CODE,
                       LO.LOCATION_CODE,
                       SP.SOURCE,
                       SP.EMP_ASSIGN_START_DATE,
                       SP.EMP_ASSIGN_END_DATE,
                       SP.UTILIZED_AREA,
                       SP.PROJECT_ID,
                       SP.TASK_ID
                     FROM
                       PN_LOCATIONS     LO,
                       PN_SPACE_ASSIGN_EMP_ALL  SP
                     WHERE
                      LO.location_id  =  SP.location_id
                     AND TRUNC(:as_of_date) between
                          SP.EMP_ASSIGN_START_DATE
                     AND NVL(SP.EMP_ASSIGN_END_DATE,TRUNC(:v_date))
                     AND SP.LAST_UPDATE_DATE >= TRUNC(:date_from )
                     AND  SP.LAST_UPDATE_DATE  <= TRUNC(:date_to)';


  -- append the and clauses, as needed.

    IF p_locn_type <> 'ALL' THEN

      l_locn_type := p_locn_type;
      l_statement :=
      l_statement || ' AND LO.location_type_lookup_code = :l_locn_type ';

    END IF;

    IF p_locn_code_from IS NOT NULL THEN

      l_locn_code_from := p_locn_code_from ;
      l_statement :=
      l_statement ||' AND LO.location_code >= :l_locn_code_from ';

    END IF;

    IF p_locn_code_to IS NOT NULL THEN

      l_locn_code_to := p_locn_code_to ;
      l_statement :=
      l_statement ||' AND LO.location_code <= :l_locn_code_to ';

    END IF;


    dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

    pnp_debug_pkg.log(' after parse ');

    dbms_sql.bind_variable
            (l_cursor,'as_of_date',l_as_of_date );

    dbms_sql.bind_variable
            (l_cursor,'v_date',vl_date );

    dbms_sql.bind_variable
            (l_cursor,'date_from',l_last_update_from );

    dbms_sql.bind_variable
            (l_cursor,'date_to',l_last_update_to );

    IF(p_locn_type <> 'ALL') THEN
      dbms_sql.bind_variable
            (l_cursor, 'l_locn_type', l_locn_type );
    END IF;

    IF p_locn_code_FROM IS NOT NULL THEN
      dbms_sql.bind_variable
             (l_cursor, 'l_locn_code_from', l_locn_code_from );
    END IF;

    IF p_locn_code_to IS NOT NULL THEN
      dbms_sql.bind_variable
             (l_cursor, 'l_locn_code_to', l_locn_code_to );
    END IF;

    dbms_sql.define_column (l_cursor, 1,v_EMP_SPACE_ASSIGN_ID);
    dbms_sql.define_column (l_cursor, 2,v_LOCATION_ID);
    dbms_sql.define_column (l_cursor, 3,v_person_id);
    dbms_sql.define_column (l_cursor, 4,v_COST_CENTER_CODE,30);
    dbms_sql.define_column (l_cursor, 5,v_ALLOCATED_AREA);
    dbms_sql.define_column (l_cursor, 6,v_ATTRIBUTE_CATEGORY,30);
    dbms_sql.define_column (l_cursor, 7,v_ATTRIBUTE1,150);
    dbms_sql.define_column (l_cursor, 8,v_ATTRIBUTE2,150);
    dbms_sql.define_column (l_cursor, 9,v_ATTRIBUTE3,150);
    dbms_sql.define_column (l_cursor, 10,v_ATTRIBUTE4,150);
    dbms_sql.define_column (l_cursor, 11,v_ATTRIBUTE5,150);
    dbms_sql.define_column (l_cursor, 12,v_ATTRIBUTE6,150);
    dbms_sql.define_column (l_cursor, 13,v_ATTRIBUTE7,150);
    dbms_sql.define_column (l_cursor, 14,v_ATTRIBUTE8,150);
    dbms_sql.define_column (l_cursor, 15,v_ATTRIBUTE9,150);
    dbms_sql.define_column (l_cursor, 16,v_ATTRIBUTE10,150);
    dbms_sql.define_column (l_cursor, 17,v_ATTRIBUTE11,150);
    dbms_sql.define_column (l_cursor, 18,v_ATTRIBUTE12,150);
    dbms_sql.define_column (l_cursor, 19,v_ATTRIBUTE13,150);
    dbms_sql.define_column (l_cursor, 20,v_ATTRIBUTE14,150);
    dbms_sql.define_column (l_cursor, 21,v_ATTRIBUTE15,150);
    dbms_sql.define_column (l_cursor, 22,v_LOCATION_TYPE_LOOKUP_CODE,30);
    dbms_sql.define_column (l_cursor, 23,v_LOCATION_CODE,90);
    dbms_sql.define_column (l_cursor, 24,v_SOURCE,80);
    dbms_sql.define_column (l_cursor, 25,v_EMP_ASSIGN_START_DATE);
    dbms_sql.define_column (l_cursor, 26,v_EMP_ASSIGN_END_DATE);
    dbms_sql.define_column (l_cursor, 27,v_UTILIZED_AREA);
    dbms_sql.define_column (l_cursor, 28,v_PROJECT_ID);
    dbms_sql.define_column (l_cursor, 29,v_TASK_ID);

    l_rows   := dbms_sql.execute(l_cursor);

    LOOP

       l_count := dbms_sql.fetch_rows( l_cursor );

       pnp_debug_pkg.log(' after fetch_rows');
       EXIT WHEN l_count <>1;

       dbms_sql.column_value (l_cursor, 1,v_EMP_SPACE_ASSIGN_ID);
       dbms_sql.column_value (l_cursor, 2,v_LOCATION_ID);
       dbms_sql.column_value (l_cursor, 3,v_person_id);
       dbms_sql.column_value (l_cursor, 4,v_COST_CENTER_CODE);
       dbms_sql.column_value (l_cursor, 5,v_ALLOCATED_AREA);
       dbms_sql.column_value (l_cursor, 6,v_ATTRIBUTE_CATEGORY);
       dbms_sql.column_value (l_cursor, 7,v_ATTRIBUTE1);
       dbms_sql.column_value (l_cursor, 8,v_ATTRIBUTE2);
       dbms_sql.column_value (l_cursor, 9,v_ATTRIBUTE3);
       dbms_sql.column_value (l_cursor, 10,v_ATTRIBUTE4);
       dbms_sql.column_value (l_cursor, 11,v_ATTRIBUTE5);
       dbms_sql.column_value (l_cursor, 12,v_ATTRIBUTE6);
       dbms_sql.column_value (l_cursor, 13,v_ATTRIBUTE7);
       dbms_sql.column_value (l_cursor, 14,v_ATTRIBUTE8);
       dbms_sql.column_value (l_cursor, 15,v_ATTRIBUTE9);
       dbms_sql.column_value (l_cursor, 16,v_ATTRIBUTE10);
       dbms_sql.column_value (l_cursor, 17,v_ATTRIBUTE11);
       dbms_sql.column_value (l_cursor, 18,v_ATTRIBUTE12);
       dbms_sql.column_value (l_cursor, 19,v_ATTRIBUTE13);
       dbms_sql.column_value (l_cursor, 20,v_ATTRIBUTE14);
       dbms_sql.column_value (l_cursor, 21,v_ATTRIBUTE15);
       dbms_sql.column_value (l_cursor, 22,v_LOCATION_TYPE_LOOKUP_CODE);
       dbms_sql.column_value (l_cursor, 23,v_LOCATION_CODE);
       dbms_sql.column_value (l_cursor, 24,v_SOURCE);
       dbms_sql.column_value (l_cursor, 25,v_EMP_ASSIGN_START_DATE);
       dbms_sql.column_value (l_cursor, 26,v_EMP_ASSIGN_END_DATE);
       dbms_sql.column_value (l_cursor, 27,v_UTILIZED_AREA);
       dbms_sql.column_value (l_cursor, 28,v_PROJECT_ID);
       dbms_sql.column_value (l_cursor, 29,v_TASK_ID);

      -- Check if data exists in ITF table already.

      exists_in_itf := 0;

      BEGIN
        SELECT  1
        INTO    exists_in_itf
        FROM    PN_EMP_SPACE_ASSIGN_ITF
        WHERE   emp_space_assign_id         =  V_EMP_SPACE_ASSIGN_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          EXIT;
      END;


      -- Insert if data does not exist in ITF table, else Update

      IF (exists_in_itf = 0) THEN

      -- Insert the fetched data INTO PN_EMP_SPACE_ASSIGN_ITF table.

      pnp_debug_pkg.log(' bfore insert ');

      INSERT INTO PN_EMP_SPACE_ASSIGN_ITF (
        BATCH_NAME,
        ENTRY_TYPE,
        EMP_SPACE_ASSIGN_ID,
        LOCATION_ID,
        employee_id,
        COST_CENTER_CODE,
        ALLOCATED_AREA,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        SOURCE,
        EMP_ASSIGN_START_DATE,
        EMP_ASSIGN_END_DATE,
        UTILIZED_AREA,
        PROJECT_ID,
        TASK_ID
      )
      VALUES (
        p_BATCH_NAME,
        decode(v_SOURCE, NULL, 'A', 'U'),
        v_EMP_SPACE_ASSIGN_ID,
        v_LOCATION_ID,
        v_person_id,
        v_COST_CENTER_CODE,
        v_ALLOCATED_AREA,
        SYSDATE,
        fnd_profile.value('CONC_LOGIN_ID'),
        fnd_profile.value('USER_ID'),
        SYSDATE,
        fnd_profile.value('USER_ID'),
        v_ATTRIBUTE_CATEGORY,
        v_ATTRIBUTE1,
        v_ATTRIBUTE2,
        v_ATTRIBUTE3,
        v_ATTRIBUTE4,
        v_ATTRIBUTE5,
        v_ATTRIBUTE6,
        v_ATTRIBUTE7,
        v_ATTRIBUTE8,
        v_ATTRIBUTE9,
        v_ATTRIBUTE10,
        v_ATTRIBUTE11,
        v_ATTRIBUTE12,
        v_ATTRIBUTE13,
        v_ATTRIBUTE14,
        v_ATTRIBUTE15,
        NVL(v_source,'PN'),
        v_EMP_ASSIGN_START_DATE,
        v_EMP_ASSIGN_END_DATE,
        v_UTILIZED_AREA,
        v_PROJECT_ID,
        v_TASK_ID
      );

        Insert_Update := 'Insert';

        PNP_DEBUG_PKG.log('Inserted Row ' || v_Counter);

      END IF;


      -- Update data in ITF table

      IF (exists_in_itf = 1) THEN

      UPDATE PN_EMP_SPACE_ASSIGN_ITF SET
        BATCH_NAME = p_batch_name,
        ENTRY_TYPE = 'U',
        EMP_SPACE_ASSIGN_ID = v_emp_space_assign_id,
        LOCATION_ID = v_location_id,
        employee_id = v_person_id,
        COST_CENTER_CODE = v_cost_center_code,
        ALLOCATED_AREA = v_allocated_area,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = fnd_profile.value('CONC_LOGIN_ID'),
        CREATED_BY = fnd_profile.value('USER_ID'),
        CREATION_DATE = SYSDATE,
        LAST_UPDATED_BY = fnd_profile.value('USER_ID'),
        ATTRIBUTE_CATEGORY = v_attribute_category,
        ATTRIBUTE1 = v_attribute1,
        ATTRIBUTE2 = v_attribute2,
        ATTRIBUTE3 = v_attribute3,
        ATTRIBUTE4 = v_attribute4,
        ATTRIBUTE5 = v_attribute5,
        ATTRIBUTE6 = v_attribute6,
        ATTRIBUTE7 = v_attribute7,
        ATTRIBUTE8 = v_attribute8,
        ATTRIBUTE9 = v_attribute9,
        ATTRIBUTE10 = v_attribute10,
        ATTRIBUTE11 = v_attribute11,
        ATTRIBUTE12 = v_attribute12,
        ATTRIBUTE13 = v_attribute13,
        ATTRIBUTE14 = v_attribute14,
        ATTRIBUTE15 = v_attribute15,
        EMP_ASSIGN_START_DATE = v_EMP_ASSIGN_START_DATE,
        EMP_ASSIGN_END_DATE = v_EMP_ASSIGN_END_DATE,
        UTILIZED_AREA = v_UTILIZED_AREA,
        PROJECT_ID = v_PROJECT_ID,
        TASK_ID=v_TASK_ID
        WHERE EMP_SPACE_ASSIGN_ID = v_emp_space_assign_id;

        IF (SQL%NOTFOUND) THEN
          RAISE FAIL_ON_UPDATE;
        END IF;

        Insert_Update := 'Update';

        PNP_DEBUG_PKG.log('Updated Row ' || v_Counter);

      END IF;



      -------------------------------------------
      -- For Conc Log/OutPut Files
      -------------------------------------------

      IF v_Counter = 1 THEN

      fnd_message.set_name ('PN','PN_BATCH_NAME');
      fnd_message.set_token ('NAME',p_batch_name);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name ('PN','PN_HRSYNC_LOC_TYPE');
      fnd_message.set_token ('TYPE',p_locn_type);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      END IF;


      PNP_DEBUG_PKG.log (
        'Record Number: '        || v_Counter                   ||
        ', '                     || Insert_Update               ||
        ', Emp Space Assign Id: '|| v_emp_space_assign_id       ||
        ', Location Id: '        || v_Location_Id               ||
        ', Location Code: '      || v_Location_Code
       );

      fnd_message.set_name ('PN','PN_XPEAM_LOC');
      fnd_message.set_token ('LOC_CODE',v_Location_Code);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

    END LOOP;

    IF dbms_sql.is_open (l_cursor) THEN
       dbms_sql.close_cursor (l_cursor);
    END IF;
    -- Commit our work.
    commit;

    EXCEPTION

      WHEN OTHERS THEN

        RAISE;


  END exp_spc_to_cad_itf;


-------------------------------
-- End of Package
-------------------------------
END PN_EXP_TO_CAD_ITF;

/
