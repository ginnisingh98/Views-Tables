--------------------------------------------------------
--  DDL for Package Body FTE_REGION_ZONE_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_REGION_ZONE_LOADER" AS
/* $Header: FTERZLRB.pls 120.5.12000000.2 2007/07/24 10:29:21 sankarun ship $ */
    -------------------------------------------------------------------------- --
    --                                                                         --
    -- NAME:        FTE_REGION_ZONE_LOADER                                     --
    -- TYPE:        BODY                                                       --
    -- DESCRIPTION: Contains Zone and Region functions for R12 Bulk Loader     --
    --                                                                         --
    -- PROCEDURES and FUNCTIONS:                                               --
    --                                                                         --
    --      FUNCTION   GET_NEXT_REGION_ID                                      --
    --                 GET_ZONE_ID                                             --
    --                 ADD_ZONE                                                --
    --      PROCEDURE                                                          --
    --             PROCESS_DATA                                                --
    --             PROCESS_ZONE                                                --
    --             PROCESS_REGION                                              --
    -------------------------------------------------------------------------- --

    G_PKG_NAME  CONSTANT  VARCHAR2(50) := 'FTE_REGION_ZONE_LOADER';
    G_USER_ID   CONSTANT  NUMBER       := FND_GLOBAL.USER_ID;

    TYPE LANE_ID_TBL IS TABLE OF FTE_LANES.LANE_ID%TYPE INDEX BY BINARY_INTEGER;

    TYPE REGION_ID_TAB IS TABLE OF WSH_REGIONS_INTERFACE.REGION_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE COUNTRY_CODE_TAB IS TABLE OF WSH_REGIONS_INTERFACE.COUNTRY_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE STATE_CODE_TAB IS TABLE OF WSH_REGIONS_INTERFACE.STATE_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE CITY_CODE_TAB IS TABLE OF WSH_REGIONS_INTERFACE.CITY_CODE%TYPE INDEX BY BINARY_INTEGER;

    TYPE LANGUAGE_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.LANGUAGE%TYPE INDEX BY BINARY_INTEGER;
    TYPE COUNTRY_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.COUNTRY%TYPE INDEX BY BINARY_INTEGER;
    TYPE STATE_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.STATE%TYPE INDEX BY BINARY_INTEGER;
    TYPE CITY_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.CITY%TYPE INDEX BY BINARY_INTEGER;
    TYPE POSTAL_CODE_FROM_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.POSTAL_CODE_FROM%TYPE INDEX BY BINARY_INTEGER;
    TYPE POSTAL_CODE_TO_TAB IS TABLE OF WSH_REGIONS_TL_INTERFACE.POSTAL_CODE_TO%TYPE INDEX BY BINARY_INTEGER;


    --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_NEXT_REGION_ID
    --
    -- PURPOSE: Get the next avaiable region id for insertion
    --
    -- Returns region id, -1 if error occured
    --_______________________________________________________________________________________--

    FUNCTION GET_NEXT_REGION_ID RETURN NUMBER IS

        CURSOR GET_REGION_ID IS
        SELECT  WSH_REGIONS_S.NEXTVAL FROM DUAL;
        l_region_id NUMBER := -1;

    BEGIN

      OPEN GET_REGION_ID;
      FETCH GET_REGION_ID INTO l_region_id;
      CLOSE GET_REGION_ID;

      RETURN l_region_id;

    EXCEPTION
      WHEN OTHERS THEN
          IF ( GET_REGION_ID%ISOPEN) THEN
              CLOSE GET_REGION_ID;
          END IF;
          FTE_UTIL_PKG.Write_LogFile('GET_NEXT_REGION_ID', 'UNEXPECTED ERROR',sqlerrm);
          RAISE;
    END GET_NEXT_REGION_ID;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION  GET_ZONE_ID
    --
    -- Purpose
    --    Get the region_id of a zone from the wsh_regions_tl table.
    --
    -- IN Parameters
    --    1. p_zone_name:     The name of the zone.
    --    2. p_exact_match:   A boolean which specifies whether the match on zone_name
    --                        should be exact.
    --
    -- RETURNS: A p_zone_table.  If a match was found, this p_zone_table contains a
    --          single p_zone_record with the name and id of the FIRST match.
    --          If there was no match found, this p_zone_record is NULL.
    --_______________________________________________________________________________________--

    FUNCTION GET_ZONE_ID(p_zone_name     IN VARCHAR2 ) RETURN NUMBER IS

    CURSOR GET_ZONE_ID(p_zone_name VARCHAR2) IS
    SELECT region_id
    FROM wsh_regions_tl
    WHERE zone = p_zone_name
    --BUG 6067174 : Zone ID returned should be specific to the instance language.
    and language = userenv('lang');

    l_zone_id  NUMBER := -1;
    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_ZONE_ID';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_zone_name',p_zone_name);

        OPEN GET_ZONE_ID(p_zone_name);
        FETCH GET_ZONE_ID INTO l_zone_id;
        CLOSE GET_ZONE_ID;

	IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zone_id', l_zone_id);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN l_zone_id;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR in GET_ZONE_ID',sqlerrm);
            RAISE;
    END GET_ZONE_ID;


    --_______________________________________________________________________________________--
    --
    -- FUNCTION ADD_ZONE
    --
    -- Purpose: Add a zone to wsh_regions table
    --
    -- IN parameters:
    --    1. p_zone_name:     name of the zone to be added
    --    2. p_validate_flag: validate flag
    --    3. p_supplier_id:   supplier id
    --
    -- OUT parameters:
    --    1. x_status:    status of the processing, -1 means no error
    --    2. x_error_msg: error message if any.
    --
    -- Returns zone id, -1 if any errors occured
    --_______________________________________________________________________________________--

    FUNCTION ADD_ZONE(p_zone_name      IN  VARCHAR2,
                      p_validate_flag  IN  BOOLEAN,
                      p_supplier_id    IN  NUMBER,
                      p_region_type    IN  VARCHAR2) RETURN NUMBER IS

    l_zone_id         NUMBER := -1;
    l_rows_affected   NUMBER;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.ADD_ZONE';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        IF ( p_validate_flag ) THEN
	    l_zone_id := FTE_REGION_ZONE_LOADER.GET_ZONE_ID(p_zone_name);
        END IF;

        IF (l_zone_id = -1) THEN

            l_zone_id := GET_NEXT_REGION_ID;

            IF ( FTE_BULKLOAD_PKG.g_debug_on ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zone_id', l_zone_id);
            END IF;

            IF (l_zone_id = -1) THEN
                RETURN l_zone_id;
            END IF;

            INSERT INTO WSH_REGIONS(
                                    REGION_ID,
                                    PARENT_REGION_ID,
                                    REGION_TYPE,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    CREATION_DATE,
                                    CREATED_BY)
                             VALUES(
                                    l_zone_id,
                                    -1,
                                    p_region_type,
                                    SYSDATE,
                                    G_USER_ID,
                                    SYSDATE,
                                    G_USER_ID);

            INSERT INTO WSH_REGIONS_TL(
                                       REGION_ID,
                                       LANGUAGE,
                                       ZONE,
                                       LAST_UPDATE_DATE,
                                       LAST_UPDATED_BY,
                                       CREATION_DATE,
                                       CREATED_BY)
                                VALUES(
                                       l_zone_id,
                                       USERENV('LANG'),
                                       p_zone_name,
                                       SYSDATE,
                                       G_USER_ID,
                                       SYSDATE,
                                       G_USER_ID);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN l_zone_id;

    EXCEPTION
        WHEN OTHERS THEN
            l_zone_id := -1;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN l_zone_id;
    END ADD_ZONE;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_REGION_ID
    --
    -- Purpose: call wsh_regions_search_pkg and get region information
    --
    -- IN parameters:
    --    1. p_region_info:   region information record
    --
    -- OUT parameters:
    --    1. x_status:        status, -1 if no error
    --    2. x_error_msg:     error message if error
    --_______________________________________________________________________________________--

    FUNCTION GET_REGION_ID(p_region_info IN WSH_REGIONS_SEARCH_PKG.REGION_REC)

    RETURN NUMBER IS

    x_region_info     WSH_REGIONS_SEARCH_PKG.REGION_REC;

    l_country_code    VARCHAR2(3) := '';
    l_country         VARCHAR2(50);
    l_state           P_REGION_INFO.STATE%TYPE;
    l_city            P_REGION_INFO.CITY%TYPE;
    l_city_code       VARCHAR2(2) := '';
    l_state_code      VARCHAR2(3) := '';

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_REGION_ID';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        l_country := p_region_info.COUNTRY;
        l_city    := p_region_info.CITY;
        l_state   := p_region_info.STATE;

        --+
        -- WSH_REGIONS_SEARCH_PKG.Get_Region_Info expects a country
        -- name as its first argument, and not a country code
        -- i.e. 'United States' instead of 'US'. If we THINK that the
        -- 'country' argument supplied is a country code, we pass it as
        -- the 'country code' argument.
        --+

        IF (LENGTH(l_country) <= 3) THEN
           -- we are assuming that no country name has 3 or less characters.
           l_country_code := l_country;
           l_country := NULL;
        END IF;

        IF (LENGTH(l_state) <= 3) THEN
            l_state_code := l_state;
            l_state := NULL;
        END IF;

        IF (LENGTH(l_city) <= 2) THEN
            l_city_code := l_city;
            l_city := NULL;
        END IF;

        WSH_REGIONS_SEARCH_PKG.Get_Region_Info(
                 p_country             => l_country,
                 p_country_region      => '',
                 p_state               => l_state,
                 p_city                => l_city,
                 p_postal_code_from    => p_region_info.postal_code_from,
                 p_postal_code_to      => p_region_info.postal_code_to,
                 p_zone                => p_region_info.zone,
                 p_lang_code           => 'US',
                 p_country_code        => l_country_code,
                 p_country_region_code => '',
                 p_state_code          => l_state_code,
                 p_city_code           => l_city_code,
                 p_region_type         => '',
                 p_interface_flag      => 'N',
                 p_search_flag         => 'Y',
                 x_region_info         => x_region_info);

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN x_region_info.region_id;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END GET_REGION_ID;


    --_______________________________________________________________________________________--
    --
    -- FUNCTION GET_REGION_ID
    --
    -- Purpose: call wsh_regions_search_pkg and get region information
    --
    -- IN parameters:
    --    1. p_region_info:   region information record
    --    2. p_recursively_flag: recursive search flag
    --
    -- RETURN
    --    1. region id
    --_______________________________________________________________________________________--

    FUNCTION GET_REGION_ID(p_region_info IN WSH_REGIONS_SEARCH_PKG.REGION_REC,
                           p_recursively_flag   IN VARCHAR2)

    RETURN NUMBER IS

    x_region_id       NUMBER;

    l_country_code    VARCHAR2(3) := '';
    l_country         VARCHAR2(50);
    l_state           P_REGION_INFO.STATE%TYPE;
    l_city            P_REGION_INFO.CITY%TYPE;
    l_city_code       VARCHAR2(2) := '';
    l_state_code      VARCHAR2(3) := '';

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_REGION_ID';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        l_country := p_region_info.COUNTRY;
        l_city    := p_region_info.CITY;
        l_state   := p_region_info.STATE;

        --+
        -- WSH_REGIONS_SEARCH_PKG.Get_Region_Info expects a country
        -- name as its first argument, and not a country code
        -- i.e. 'United States' instead of 'US'. If we THINK that the
        -- 'country' argument supplied is a country code, we pass it as
        -- the 'country code' argument.
        --+
        IF (LENGTH(l_country) <= 3) THEN
           -- we are assuming that no country name has 3 or less characters.
           l_country_code := l_country;
           l_country := NULL;
        END IF;
        IF (LENGTH(l_state) <= 3) THEN
            l_state_code := l_state;
            l_state := NULL;
        END IF;
        IF (LENGTH(l_city) <= 2) THEN
            l_city_code := l_city;
            l_city := NULL;
        END IF;

        WSH_REGIONS_SEARCH_PKG.Get_Region_Info(
                 p_country             => l_country,
                 p_country_region      => '',
                 p_state               => l_state,
                 p_city                => l_city,
                 p_postal_code_from    => p_region_info.postal_code_from,
                 p_postal_code_to      => p_region_info.postal_code_to,
                 p_zone                => p_region_info.zone,
                 p_lang_code           => 'US',
                 p_country_code        => l_country_code,
                 p_country_region_code => '',
                 p_state_code          => l_state_code,
                 p_city_code           => l_city_code,
                 p_region_type         => '',
                 p_interface_flag      => 'N',
                 p_search_flag         => 'Y',
                 p_recursively_flag    => 'Y',
                 x_region_id           => x_region_id);

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

        RETURN x_region_id;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END GET_REGION_ID;

    --_______________________________________________________________________________________--
    --
    -- FUNCTION INSERT_PARTY_REGION
    --
    -- Purpose: To insert into wsh_zone_regions for party
    --
    -- IN parameters:
    --    1. p_region_id
    --    2. p_parent_region_id
    --    3. p_supllier_id
    --    4. p_validate_flag
    --    5. p_postal_code_from
    --    6. p_postal_code_to
    --
    -- RETURN
    --    1. p_part_region_id
    --_______________________________________________________________________________________--

    FUNCTION  INSERT_PARTY_REGION(p_region_id        IN NUMBER,
                                  p_parent_region_id IN NUMBER,
                                  p_supplier_id      IN NUMBER,
                                  p_validate_flag    IN BOOLEAN,
                                  p_postal_code_from IN NUMBER,
                                  p_postal_code_to   IN NUMBER)
    RETURN NUMBER IS

    l_result           NUMBER := -1;
    l_party_region_id  NUMBER := -1;

    l_postal_code_from VARCHAR2(25) := '';
    l_postal_code_to   VARCHAR2(25) := '';

    l_zone_flag        VARCHAR2(3);

    CURSOR GET_PARTY_REGION_ID IS
    SELECT
       zone_region_id
    FROM
       wsh_zone_regions
    WHERE
       region_id = p_region_id AND
       parent_region_id = p_parent_region_id AND
       party_id = p_supplier_id AND
       (p_postal_code_from IS NULL OR postal_code_from = p_postal_code_from) AND
       (p_postal_code_to IS NULL OR postal_code_to = p_postal_code_to) ;

    CURSOR GET_NEXT_PARTY_REGION_ID IS
    SELECT WSH_ZONE_REGIONS_S.NEXTVAL FROM DUAL;

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.INSERT_PARTY_REGION';

    BEGIN

       FTE_UTIL_PKG.Enter_Debug(l_module_name);
       IF (p_validate_flag) THEN
           OPEN GET_PARTY_REGION_ID;
           FETCH GET_PARTY_REGION_ID INTO l_party_region_id;
           CLOSE GET_PARTY_REGION_ID;

           IF (l_party_region_id <> -1 ) THEN
               FTE_UTIL_PKG.Exit_Debug(l_module_name);
               RETURN l_party_region_id;
           END IF;
       END IF;

       OPEN GET_NEXT_PARTY_REGION_ID;
       FETCH GET_NEXT_PARTY_REGION_ID INTO l_party_region_id;
       CLOSE GET_NEXT_PARTY_REGION_ID;

       IF (p_region_id = p_parent_region_id) THEN
           l_zone_flag := 'N';
       ELSE
           l_zone_flag := 'Y';
       END IF;

       IF (p_postal_code_from IS NOT NULL) THEN
           l_postal_code_from := p_postal_code_from;
           IF (p_postal_code_to IS NULL) THEN
               l_postal_code_to := p_postal_code_to;
           END IF;
       END IF;

       INSERT INTO WSH_ZONE_REGIONS(
                    ZONE_REGION_ID,
                    REGION_ID,
                    PARENT_REGION_ID,
                    PARTY_ID,
                    ZONE_FLAG,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    POSTAL_CODE_FROM,
                    POSTAL_CODE_TO)
             VALUES(
                    l_party_region_id,
                    p_region_id,
                    p_parent_region_id,
                    p_supplier_id,
                    l_zone_flag,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    l_postal_code_from,
                    l_postal_code_to);

       IF (SQL%ROWCOUNT < 0) THEN
           l_party_region_id := -1;
       END IF;

       FTE_UTIL_PKG.Exit_Debug(l_module_name);
       RETURN l_party_region_id;

    EXCEPTION
        WHEN OTHERS THEN

            IF (GET_NEXT_PARTY_REGION_ID%ISOPEN) THEN
                CLOSE GET_NEXT_PARTY_REGION_ID;
            END IF;

            IF (GET_PARTY_REGION_ID%ISOPEN) THEN
                CLOSE GET_PARTY_REGION_ID;
            END IF;

            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END INSERT_PARTY_REGION;

    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_ZONE
    --
    -- Purpose: process the lines in p_table for zones
    --
    -- IN parameters:
    --  1. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  2. p_line_number:   line number for the beginning of the block
    --  3. p_region_type:   type of region
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_ZONE (p_block_header IN  FTE_BULKLOAD_PKG.block_header_tbl,
                            p_block_data   IN  FTE_BULKLOAD_PKG.block_data_tbl,
                            p_line_number  IN  NUMBER,
                            p_region_type  IN  VARCHAR2,
                            x_status       OUT NOCOPY  NUMBER,
                            x_error_msg    OUT NOCOPY  VARCHAR2) IS

    l_action        VARCHAR2(100);
    l_zone_name     VARCHAR2(200);
    l_country       VARCHAR2(100);
    l_zone_id       NUMBER;
    l_region_id     NUMBER;
    l_region_rec    WSH_REGIONS_SEARCH_PKG.region_rec;
    l_temp_id       NUMBER;

    l_values   FTE_BULKLOAD_PKG.data_values_tbl;

    l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_ZONE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --+
        -- Validate the column names
        --+
        FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                            p_type      => 'ZONE',
                                            p_line_number => p_line_number-1,
                                            x_status    => x_status,
                                            x_error_msg => x_error_msg);
        FOR i IN 1..p_block_data.COUNT LOOP

            l_values := p_block_data(i);

            FTE_VALIDATION_PKG.VALIDATE_ZONE(p_values      => l_values,
                                             p_line_number => p_line_number+i-1,
                                             p_region_type => p_region_type,
                                             p_action      => l_action,
                                             p_zone_name   => l_zone_name,
                                             p_country     => l_country,
                                             p_zone_id     => l_zone_id,
                                             p_region_rec  => l_region_rec,
                                             p_region_id   => l_region_id,
                                             x_status      => x_status,
                                             x_error_msg   => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_VALIDATION_PKG.VALIDATE_ZONE returned with error ', x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF ( FTE_BULKLOAD_PKG.g_debug_on ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, ' l_zone_id',  l_zone_id);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, ' l_region_id',  l_region_id);
            END IF;

            IF (l_zone_id = -1) THEN

                l_zone_id := ADD_ZONE(l_zone_name, FALSE, -1, p_region_type);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, ' l_zone_id',  l_zone_id);
                END IF;

            END IF;

            IF (l_zone_id = -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Unable to create new Zone');
                RETURN;
            END IF;

            WSH_REGIONS_PKG.UPDATE_ZONE_REGION(p_insert_type      => 'INSERT',
                                               p_zone_region_id   => l_region_id,
                                               p_zone_id          => l_zone_id,
                                               p_region_id        => l_region_id,
                                               p_country          => l_region_rec.country,
                                               p_state            => l_region_rec.state,
                                               p_city             => l_region_rec.city,
                                               p_postal_code_from => l_region_rec.postal_code_from,
                                               p_postal_code_to   => l_region_rec.postal_code_to,
                                               p_lang_code        => USERENV('LANG'),
                                               p_country_code     => '',
                                               p_state_code       => '',
                                               p_city_code        => '',
                                               p_user_id          => -1,
                                               p_zone_type        => p_region_type,
                                               x_zone_region_id   => l_temp_id,
                                               x_region_id        => l_region_id,
                                               x_status           => x_status,
                                               x_error_msg        => x_error_msg);

            IF (x_status = 2) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'WSH_REGIONS_PKG.UPDATE_ZONE_REGION returned with error',x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF (x_error_msg IS NOT NULL) THEN
                IF (x_error_msg = 'WSH_REGION_NOT_FOUND') THEN
                    FTE_UTIL_PKG.Write_OutFile('FTE__REGION_NOT_FOUND', 'C', p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (x_error_msg = 'WSH_REGION_EXISTS_IN_ZONE') THEN
                    FTE_UTIL_PKG.Write_OutFile('FTE_REGION_EXISTS_IN_ZONE', 'D', p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (x_error_msg <> 'WSH_SAME_REGION_IN_ZONE') THEN
                    FTE_UTIL_PKG.Write_OutFile('FTE_SAME_REGION_IN_ZONE', 'D', p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSE -- ignore error FTE_SAME_REGION_IN_ZONE
                    x_status := -1;
                END IF;
            ELSE
                x_status := -1;
            END IF;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
       WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_ZONE;


    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_REGION
    --
    -- PURPOSE: process the lines in p_table for zones
    --
    -- IN parameters:
    --  1. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  2. p_line_number:   line number for the beginning of the block
    --  3. p_region_type:   type of region
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_REGION(p_block_header IN  FTE_BULKLOAD_PKG.block_header_tbl,
                             p_block_data   IN  FTE_BULKLOAD_PKG.block_data_tbl,
                             p_line_number  IN  NUMBER,
                             x_status       OUT NOCOPY  NUMBER,
                             x_error_msg    OUT NOCOPY VARCHAR2) IS

    l_action      VARCHAR2(25);
    l_interface_region_id   NUMBER;
    l_type  CONSTANT VARCHAR2(15) := 'REGION';

    l_request_id   NUMBER;

    l_values FTE_BULKLOAD_PKG.data_values_tbl;

    L_REGION_ID REGION_ID_TAB;
    L_COUNTRY_CODE COUNTRY_CODE_TAB;
    L_STATE_CODE STATE_CODE_TAB;
    L_CITY_CODE CITY_CODE_TAB;
    L_LANGUAGE LANGUAGE_TAB;
    L_COUNTRY COUNTRY_TAB;
    L_STATE STATE_TAB;
    L_CITY CITY_TAB;
    L_POSTAL_CODE_FROM POSTAL_CODE_FROM_TAB;
    L_POSTAL_CODE_TO POSTAL_CODE_TO_TAB;

    CURSOR GET_INTERFACE_REGION_ID IS
    SELECT WSH_REGIONS_INTERFACE_S.NEXTVAL
    FROM DUAL;

    l_module_name    CONSTANT  VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_REGION';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                            p_type      => l_type,
                                            p_line_number => p_line_number-1,
                                            x_status    => x_status,
                                            x_error_msg => x_error_msg);

        FOR i IN 1..p_block_data.COUNT LOOP

            l_values := p_block_data(i);
            l_action := l_values('ACTION');

            l_action := UPPER(l_action);

            FTE_VALIDATION_PKG.VALIDATE_ACTION(p_action      => l_action,
                                               p_type        => l_type,
                                               p_line_number => p_line_number + i + 1,
                                               x_status      => x_status,
                                               x_error_msg   => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_VALIDATION_PKG.VALIDATE_ACTION failed');
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF (l_action = 'ADD') THEN

                OPEN GET_INTERFACE_REGION_ID;
                FETCH GET_INTERFACE_REGION_ID INTO l_interface_region_id;
                CLOSE GET_INTERFACE_REGION_ID;

                L_REGION_ID(i)   := l_interface_region_id;
                L_COUNTRY_CODE(i):= FTE_UTIL_PKG.GET_DATA('COUNTRY_CODE', l_values);
                L_STATE_CODE(i)  := FTE_UTIL_PKG.GET_DATA('STATE_CODE', l_values);
                L_CITY_CODE(i)   := FTE_UTIL_PKG.GET_DATA('CITY_CODE', l_values);

                L_LANGUAGE(i)  := NVL(USERENV('LANG'),'US');
                L_COUNTRY(i)   := FTE_UTIL_PKG.GET_DATA('COUNTRY', l_values);
                L_STATE(i)     := FTE_UTIL_PKG.GET_DATA('STATE', l_values);
                L_CITY(i)      := FTE_UTIL_PKG.GET_DATA('CITY', l_values);
                L_POSTAL_CODE_FROM(i) := FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_FROM', l_values);
                L_POSTAL_CODE_TO(i)   := FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_TO', l_values);

            END IF;

        END LOOP;

        FORALL i in L_REGION_ID.FIRST..L_REGION_ID.LAST

            INSERT INTO WSH_REGIONS_INTERFACE(
                                              REGION_ID,
                                              PARENT_REGION_ID,
                                              COUNTRY_CODE,
                                              STATE_CODE,
                                              CITY_CODE,
                                              CREATED_BY,
                                              CREATION_DATE,
                                              LAST_UPDATED_BY,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATE_LOGIN,
                                              PROCESSED_FLAG)
                                       VALUES(
                                              L_REGION_ID(i),
                                              -1,
                                              L_COUNTRY_CODE(i),
                                              L_STATE_CODE(i),
                                              L_CITY_CODE(i),
                                              FND_GLOBAL.USER_ID,
                                              SYSDATE,
                                              FND_GLOBAL.USER_ID,
                                              SYSDATE,
                                              FND_GLOBAL.USER_ID,
                                              NULL);

        FORALL i in L_REGION_ID.FIRST..L_REGION_ID.LAST

            INSERT INTO WSH_REGIONS_TL_INTERFACE(
                                                LANGUAGE,
                                                REGION_ID,
                                                COUNTRY,
                                                STATE,
                                                CITY,
                                                POSTAL_CODE_FROM,
                                                POSTAL_CODE_TO,
                                                CREATED_BY,
                                                CREATION_DATE,
                                                LAST_UPDATED_BY,
                                                LAST_UPDATE_DATE,
                                                LAST_UPDATE_LOGIN)
                                         VALUES(
                                                L_LANGUAGE(i),
                                                L_REGION_ID(i),
                                                L_COUNTRY(i),
                                                L_STATE(i),
                                                L_CITY(i),
                                                L_POSTAL_CODE_FROM(i),
                                                L_POSTAL_CODE_TO(i),
                                                FND_GLOBAL.USER_ID,
                                                SYSDATE,
                                                FND_GLOBAL.USER_ID,
                                                SYSDATE,
                                                FND_GLOBAL.USER_ID);

        l_request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'WSH',
                                                   program     => 'WSHRGINT',
                                                   description => null,
                                                   start_time  => null,
                                                   sub_request => false);
    IF (FTE_BULKLOAD_PKG.g_debug_on)  THEN
        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_request_id',l_request_id);
    END IF;

    EXCEPTION
            WHEN OTHERS THEN
            x_status := 2;
            IF (GET_INTERFACE_REGION_ID%ISOPEN) THEN
                CLOSE GET_INTERFACE_REGION_ID;
            END IF;

            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

     END PROCESS_REGION;

    --_______________________________________________________________________________________--
    --
    -- PROCEDURE PROCESS_DATA
    --
    -- Purpose: Call appropriate process function according to the type.
    --
    -- IN parameters:
    --  1. p_type:      type of the block (Zone or Region)
    --  2. p_table:     pl/sql table of STRINGARRAY containing the block information
    --  3. p_line_number:   line number for the beginning of the block
    --
    -- OUT parameters:
    --  1. x_status:    status of the processing, -1 means no error
    --  2. x_error_msg: error message if any.
    --_______________________________________________________________________________________--

    PROCEDURE PROCESS_DATA(p_type            IN  VARCHAR2,
                           p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                           p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                           p_line_number     IN  NUMBER,
                           x_status          OUT NOCOPY  NUMBER,
                           x_error_msg       OUT NOCOPY  VARCHAR2) IS

    l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_DATA';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status    := -1;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_type', p_type);
        END IF;

        IF (p_type = 'ZONE') THEN

            PROCESS_ZONE(p_block_header    => p_block_header,
                         p_block_data      => p_block_data,
                         p_line_number     => p_line_number,
                         p_region_type     => '10',
                         x_status          => x_status,
                         x_error_msg       => x_error_msg);

        ELSIF (p_type = 'REGION') THEN

            PROCESS_REGION(p_block_header    => p_block_header,
                           p_block_data      => p_block_data,
                           p_line_number     => p_line_number,
                           x_status          => x_status,
                           x_error_msg       => x_error_msg);
        ELSE

          x_status := 2;
          FTE_UTIL_PKG.Write_LogFile(l_module_name,'Invalid Type',p_type);
          FTE_UTIL_PKG.Exit_Debug(l_module_name);
          RETURN;

        END IF;

        IF( x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Error occured in process zone');
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

        EXCEPTION
            WHEN OTHERS THEN
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR OCCURED', sqlerrm);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END PROCESS_DATA;

END FTE_REGION_ZONE_LOADER;

/
