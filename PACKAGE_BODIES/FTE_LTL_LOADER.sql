--------------------------------------------------------
--  DDL for Package Body FTE_LTL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LTL_LOADER" AS
/* $Header: FTELTLRB.pls 120.7.12000000.3 2007/01/20 11:04:07 htnguyen ship $ */

    /*----------------------------------------------------------------------------------------
    --                                                                                      --
    -- NAME:        FTE_LTL_LOADER                                                          --
    -- TYPE:        BODY                                                                    --
    -- DESCRIPTION: Gets a block of data from FTE_BULKLOAD_PKG                              --
    --              and creates RATE-CHARTS, ZONES, LANES and more !!                       --
    --                                                                                      --
    -- PROCEDURES:                                                                          --
    --                                                                                      --
    -- CHANGE CONTROL LOG                                                                   --
    --                                                                                      --
    --                                                                                      --
    -- DATE        VERSION  BY                 DESCRIPTION                                  --
    --                                                                                      --
    -- 08/07/2002  I        GLAMI              Created.                                     --
    --                                                                                      --
    -- 05/02/2005  R12      PRABHAKHAR         Refactored.                                  --
    ------------------------------------------------------------------------------------------*/

    G_PKG_NAME   CONSTANT  VARCHAR2(50) := 'FTE_LTL_LOADER';

    G_USER_ID              NUMBER  := FND_GLOBAL.USER_ID;
    G_ACTION               VARCHAR2(10);
    G_LTL_UOM              VARCHAR2(5)  := 'Lbs';
    G_ORIG_COUNTRY         VARCHAR2(10) := 'US';
    G_DEST_COUNTRY         VARCHAR2(10) := 'US';
    G_REF_COUNTRY          VARCHAR2(10) := 'US';
    G_LTL_CURRENCY         VARCHAR2(20) := 'USD';
    G_SERVICE_CODE         VARCHAR2(30);
    G_BULK_INSERT_LIMIT    NUMBER := 250;
    G_TOTAL_NUMCHARTS      NUMBER := 0;
    G_CHART_COUNT_TEMP     NUMBER := 0;
    G_VALID_DATE           DATE;
    G_VALID_DATE_STRING    VARCHAR2(20);
    G_DIRECTION_FLAG       VARCHAR2(5);
    G_ORIGIN_DEST          VARCHAR2(30);
    G_IN_OUT               VARCHAR2(30);
    G_PROCESSED_LINES      NUMBER := 0;
    G_NUM_COLUMNS          CONSTANT NUMBER := 18;
    G_NUM_CONC_PROCESSES   NUMBER := 10;
    G_LANE_FUNCTION_ID     NUMBER;
    G_MIN_CHARGE_ID        NUMBER;
    G_DEF_WT_ENABLED_ID    NUMBER;
    G_DEF_WT_BREAK_ID      NUMBER;
    G_DATE_FORMAT          CONSTANT VARCHAR2(50) := 'MM-DD-YYYY hh24:mi:ss';
    G_DATE                 CONSTANT VARCHAR2(50) := 'MM-DD-YYYY';

    G_REPORT_HEADER        LTL_Report_Header;
    G_DUMMY_BLOCK_HDR_TBL  FTE_BULKLOAD_PKG.block_header_tbl;

    --+
    -- Cursors used by more than one procedures
    --+
    CURSOR GET_LOAD_NUMBER(p_tariff_name  IN  VARCHAR2) IS
    SELECT
      SUBSTR(lane_type,INSTR(lane_type,'_', -1)+1)
    FROM
      fte_lanes
    WHERE
      tariff_name  = p_tariff_name
    ORDER BY creation_date DESC;

    CURSOR GET_TARIFF_CARRIERS (p_tariff_name  IN  VARCHAR2, p_action_code  IN  VARCHAR2) IS
    SELECT
      carrier_id,
      TO_CHAR(new_effective_date, G_DATE_FORMAT),
      TO_CHAR(new_expiry_date,G_DATE_FORMAT)
    FROM
      fte_tariff_carriers
    WHERE
      tariff_name = p_tariff_name AND
      action_code = p_action_code;


    --+
    -- ORDER BY is significant, because we need to fetch
    -- the information for the lastest lane created, not the first.
    --+
    CURSOR GET_PREVIOUS_LOAD_INFO (p_tariff_name IN VARCHAR2)  IS
    SELECT
      SUBSTR(l.lane_type,INSTR(lane_type,'_', -1) + 1),
      l.service_type_code,
      owr.country_code,
      dwr.country_code,
      l.carrier_id
    FROM
      fte_lanes l,
      fte_tariff_carriers tc,
      wsh_zone_regions ozr,
      wsh_zone_regions dzr,
      wsh_regions owr,
      wsh_regions dwr
    WHERE
      l.tariff_name = p_tariff_name AND
      l.tariff_name = tc.tariff_name AND
      tc.action_code IN ('M', 'D') AND
      l.carrier_id = tc.carrier_id AND
      ozr.parent_region_id = l.origin_id AND
      dzr.parent_region_id = l.destination_id AND
      ozr.region_id = owr.region_id AND
      dzr.region_id = dwr.region_id
    ORDER BY l.creation_date DESC;

    --_________________________________________________________________________________--
    --
    -- FUNCTION: GET_PHASE
    --
    -- Purpose
    --   Return the phase of the LTL loading process.
    --   In phase 1, rate charts and zones are prepared in the interface tables.
    --   In phase 2, lanes are created and linked to the rate charts.
    --               This happens after the sub-processes (for QP Rate Chart Loading) complete
    --               successfully.
    --_________________________________________________________________________________--

    FUNCTION GET_PHASE RETURN NUMBER IS

        l_request_data          VARCHAR2(100) := NULL;
        l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_PHASE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        l_request_data := FND_CONC_GLOBAL.REQUEST_DATA;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_request_data', l_request_data);
        END IF;

        IF (l_request_data IS NULL) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN 1;
        ELSE
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN 2;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR FTE_LTL_LOADER.GET_PHASE', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END GET_PHASE;


    --_________________________________________________________________________________--
    --
    -- FUNCTION: ROW_NUM_MAX
    --
    -- PURPOSE:  To get the next number to be used for ROW_NUMBER in
    --           insertion into fte_interface_zones.
    --
    -- RETURNS:  The number to use for ROW_NUMBER, by adding one to the max of the
    --           ROW_NUMBER at present in FTE_INTERFACE_ZONES for a given zone.
    --_________________________________________________________________________________--

    FUNCTION ROW_NUM_MAX(l_zone_name IN VARCHAR2) RETURN NUMBER IS

        l_max NUMBER;
        l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_PHASE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        SELECT
          MAX(row_number) INTO l_max
        FROM
          fte_interface_zones
        WHERE
          zone_name = l_zone_name;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

        RETURN l_max + 1;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN FTE_LTL_LOADER.ROW_NUM_MAX', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END ROW_NUM_MAX;

    --______________________________________________________________________________________--
    --
    -- FUNCTION:  VERIFY_TARIFF_CARRIER
    --
    -- Purpose
    --    check if carrier_id is associated with the tariff
    --
    -- IN Parameters
    --    1. p_tariff:      The name of the tariff.
    --    2. p_carrier_id:  The carrier_id to check
    --
    -- RETURNS:
    --    true, if the carrier is associated with the tariff.
    --    false, otherwise.
    --______________________________________________________________________________________--

    FUNCTION VERIFY_TARIFF_CARRIER(p_tariff_name IN VARCHAR2,
                                   p_carrier_id  IN NUMBER,
                                   x_error_msg   OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    l_carrier_ids     NUMBER_TAB;
    l_effective_dates STRINGARRAY;
    l_expiry_dates    STRINGARRAY;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.VERIFY_TARIFF_CARRIER';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                                 p_action_code => 'D');
        FETCH GET_TARIFF_CARRIERS

        BULK COLLECT INTO l_carrier_ids, l_effective_dates, l_expiry_dates;

        CLOSE GET_TARIFF_CARRIERS;

	IF l_carrier_ids.COUNT > 0 THEN
        FOR i in l_carrier_ids.FIRST..l_carrier_ids.LAST LOOP
            IF (p_carrier_id = l_carrier_ids(i)) THEN
	        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN TRUE;
            END IF;
        END LOOP;

	END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN FALSE;

    EXCEPTION
        WHEN OTHERS THEN

            IF (GET_TARIFF_CARRIERS%ISOPEN) THEN
                CLOSE GET_TARIFF_CARRIERS;
            END IF;

            x_error_msg := 'UNEXPECTED ERROR in' || l_module_name || ': ' || sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END VERIFY_TARIFF_CARRIER;

    --______________________________________________________________________________________--
    --
    -- FUNCTION: GET_TARIFF_RATECHARTS
    --
    -- PURPOSE
    --    Get the ratechart ids belonging to the tariff <p_tariff>
    --
    -- IN Parameters
    --    1. p_tariff_name,  The name of the tariff.
    --
    -- RETURNS:
    --    The pricelist Ids
    --______________________________________________________________________________________--

    FUNCTION GET_TARIFF_RATECHARTS (p_tariff_name IN  VARCHAR2,
                                    x_error_msg   OUT NOCOPY VARCHAR2)

    RETURN WSH_UTIL_CORE.ID_TAB_TYPE IS

    x_list_header_ids   WSH_UTIL_CORE.ID_TAB_TYPE;
    l_load_number       NUMBER;
    l_carrier_id        NUMBER;
    l_effective_date    VARCHAR2(40);
    l_expiry_date       VARCHAR2(40);

    --+
    -- select distinct because a rate chart could be shared
    -- by multiple lanes.
    --+
    CURSOR GET_TARIFF_CHARTS (p_load_number IN NUMBER,
                              p_carrier_id  IN NUMBER) IS
     SELECT distinct
       lrc.list_header_id
     FROM
       fte_lanes l,
       fte_lane_rate_charts lrc
     WHERE
       l.lane_id = lrc.lane_id AND
       l.tariff_name = p_tariff_name AND
       l.lane_type = 'LTL_' || p_tariff_name || '_' || p_load_number AND
       l.carrier_id = p_carrier_id;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_TARIFF_RATECHARTS';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        OPEN GET_LOAD_NUMBER(p_tariff_name => p_tariff_name);
        FETCH GET_LOAD_NUMBER INTO l_load_number;

        IF GET_LOAD_NUMBER%NOTFOUND THEN
            x_error_msg := 'Tariff ' || p_tariff_name || ' does not have any existing data';
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            CLOSE GET_LOAD_NUMBER;
            RETURN x_list_header_ids;
        END IF;

        CLOSE GET_LOAD_NUMBER;

        OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                                 p_action_code => 'D');

        FETCH GET_TARIFF_CARRIERS
        INTO l_carrier_id, l_effective_date, l_expiry_date;

        CLOSE GET_TARIFF_CARRIERS;

        OPEN GET_TARIFF_CHARTS (l_load_number, l_carrier_id);

        FETCH GET_TARIFF_CHARTS
        BULK COLLECT INTO x_list_header_ids;
        CLOSE GET_TARIFF_CHARTS;

        IF (x_list_header_ids.COUNT <= 0) THEN
            x_error_msg := 'Tariff ' || p_tariff_name || ' does not have any rate charts';
        END IF;

	FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN x_list_header_ids;

    EXCEPTION
        WHEN OTHERS THEN
            IF (GET_LOAD_NUMBER % ISOPEN) THEN
                CLOSE GET_LOAD_NUMBER;
            END IF;
            IF (GET_TARIFF_CARRIERS % ISOPEN) THEN
                CLOSE GET_TARIFF_CARRIERS;
            END IF;
            IF (GET_TARIFF_CHARTS % ISOPEN) THEN
                CLOSE GET_TARIFF_CHARTS;
            END IF;

            x_error_msg := 'UNEXPECTED ERROR in getting rate charts for tariff ' || p_tariff_name || ': ' || sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END GET_TARIFF_RATECHARTS;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: BULK_INSERT_LANES
    --
    -- PURPOSE:  To bulk insert the data stored in PL/SQL tables with the name LN_*
    --           to the database.
    --
    --___________________________________________________________________________________--

    PROCEDURE BULK_INSERT_LANES IS

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.BULK_INSERT_LANES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        FORALL i IN 1..LN_LANE_ID.COUNT
             INSERT INTO fte_lanes( lane_id,
                                    lane_number,
                                    owner_id,
                                    carrier_id,
                                    origin_id,
                                    destination_id,
                                    mode_of_transportation_code,
                                    commodity_detail_flag,
                                    service_detail_flag,
                                    equipment_detail_flag,
                                    commodity_catg_id,
                                    service_type_code,
                                    basis,
                                    pricelist_view_flag,
                                    effective_date,
                                    expiry_date,
                                    comm_fc_class_code,
                                    schedules_flag,
                                    editable_flag,
                                    lane_type,
                                    tariff_name,
                                    created_by,
                                    creation_date,
                                    last_updated_by,
                                    last_update_date,
                                    last_update_login)
                           VALUES ( LN_LANE_ID(i),
                                    LN_LANE_ID(i),
                                    -1,
                                    LN_CARRIER_ID(i),
                                    LN_ORIGIN_ID(i),
                                    LN_DEST_ID(i),
                                    'LTL',
                                    'Y',
                                    'Y',
                                    'N',
                                    LN_COMMODITY_CATG_ID(i),
                                    G_SERVICE_CODE,
                                    'WEIGHT',
                                    'Y',
                                    TO_DATE(LN_START_DATE(i), G_DATE_FORMAT),
                                    TO_DATE(LN_END_DATE(i), G_DATE_FORMAT),
                                    LN_COMM_FC_CLASS_CODE(i),
                                    'N',
                                    'N',
                                    LN_LANE_TYPE(i),
                                    LN_TARIFF_NAME(i),
                                    G_USER_ID,
                                    SYSDATE,
                                    G_USER_ID,
                                    SYSDATE,
                                    G_USER_ID);

        FORALL i IN 1..LN_LANE_ID.COUNT
            INSERT INTO fte_lane_services(lane_service_id,
                                          lane_id,
                                          service_code,
                                          created_by,
                                          creation_date,
                                          last_updated_by,
                                          last_update_date,
                                          last_update_login )
                                   VALUES(fte_lane_services_s.nextval,
                                          LN_LANE_ID(i),
                                          G_SERVICE_CODE,
                                          G_USER_ID,
                                          SYSDATE,
                                          G_USER_ID,
                                          SYSDATE,
                                          G_USER_ID);

        LN_LANE_ID.DELETE;
        LN_CARRIER_ID.DELETE;
        LN_ORIGIN_ID.DELETE;
        LN_DEST_ID.DELETE;
        LN_COMMODITY_CATg_ID.DELETE;
        LN_COMM_FC_CLASS_CODE.DELETE;
        LN_LANE_TYPE.DELETE;
        LN_TARIFF_NAME.DELETE;
        LN_START_DATE.DELETE;
        LN_END_DATE.DELETE;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
       WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN FTE_LTL_LOADER.BULK_INSERT_LANES', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END BULK_INSERT_LANES;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE:   BULK_INSERT_LANE_RATE_CHARTS
    --
    -- Purpose:  To bulk insert the data stored in PL/SQL tables with the name LRC_*
    --           to the database
    --
    --___________________________________________________________________________________--

    PROCEDURE BULK_INSERT_LANE_RATE_CHARTS IS

    l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.BULK_INSERT_LANE_RATE_CHARTS';

    BEGIN

      FTE_UTIL_PKG.Enter_Debug(l_module_name);

      FORALL i IN 1..LRC_LANE_ID.COUNT
            INSERT INTO  fte_lane_rate_charts(lane_id,
                                              list_header_id,
                                              start_date_active,
                                              end_date_active,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login )
                                       VALUES(LRC_LANE_ID(i),
                                              LRC_LIST_HEADER_ID(i),
                                              LRC_START_DATE(i),
                                              LRC_END_DATE(i),
                                              G_USER_ID,
                                              SYSDATE,
                                              G_USER_ID,
                                              SYSDATE,
                                              G_USER_ID);

      LRC_LANE_ID.DELETE;
      LRC_LIST_HEADER_ID.DELETE;
      LRC_START_DATE.DELETE;
      LRC_END_DATE.DELETE;

      FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
       WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN FTE_LTL_LOADER.BULK_INSERT_LANE_RATE_CHARTS', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END BULK_INSERT_LANE_RATE_CHARTS;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: BULK_INSERT_LANE_PARAMETERS
    --
    -- Purpose: To bulk insert the data stored in PL/SQL tables with the name PRC_*
    --           to the database
    --
    --___________________________________________________________________________________--

    PROCEDURE BULK_INSERT_LANE_PARAMETERS IS

    l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.BULK_INSERT_LANE_PARAMETERS';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        FORALL i IN 1..PRC_LANE_ID.COUNT
            INSERT INTO fte_prc_parameters(value_from,
                                           uom_code,
                                           currency_code,
                                           parameter_instance_id,
                                           lane_id,
                                           parameter_id,
                                           created_by,
                                           creation_date,
                                           last_updated_by,
                                           last_update_date,
                                           last_update_login)
                                    VALUES(PRC_VALUE_FROM(i),
                                           G_LTL_UOM,
                                           G_LTL_CURRENCY,
                                           FTE_PRC_PARAMETERS_S.NEXTVAL,
                                           PRC_LANE_ID(i),
                                           PRC_PARAMETER_ID(i),
                                           G_USER_ID,
                                           SYSDATE,
                                           G_USER_ID,
                                           SYSDATE,
                                           G_USER_ID);

        -- Reset the tables
        PRC_LANE_ID.DELETE;
        PRC_VALUE_FROM.DELETE;
        PRC_PARAMETER_ID.DELETE;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
       WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN FTE_LTL_LOADER_PKG.BULK_INSERT_LANE_PARAMETERS', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END BULK_INSERT_LANE_PARAMETERS;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE:   BULK_INSERT_LANE_COMMODITIES
    --
    -- Purpose: To bulk insert the data stored in PL/SQL tables with the name CM_*
    --           to the database
    --
    --___________________________________________________________________________________--

    PROCEDURE BULK_INSERT_LANE_COMMODITIES IS

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.BULK_INSERT_LANE_COMMODITIES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        FORALL i IN 1..CM_LANE_ID.COUNT

            INSERT INTO FTE_LANE_COMMODITIES(lane_commodity_id,
                                             lane_id,
                                             commodity_catg_id,
                                             created_by,
                                             creation_date,
                                             last_updated_by,
                                             last_update_date,
                                             last_update_login)
                                      VALUES(FTE_BULKLOAD_DATA_S.NEXTVAL,
                                             CM_LANE_ID(i),
                                             CM_CATg_ID(i),
                                             G_USER_ID,
                                             SYSDATE,
                                             G_USER_ID,
                                             SYSDATE,
                                             G_USER_ID);
        CM_LANE_ID.DELETE;
        CM_CATG_ID.DELETE;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
       WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN FTE_LTL_LOADER.BULK_INSERT_LANE_PARAMETERS', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;
    END BULK_INSERT_LANE_COMMODITIES;

    --_________________________________________________________________________________________--
    --
    -- PROCEDURE: GENERATE_LTL_REPORT
    --
    -- PURPOSE
    --         Writes the following data to the OUTPUT file
    --         1) The Zones Created.
    --         2) The Rate Charts Created.
    --         3) The Services Created.
    --
    -- PARAMETER
    -- IN
    --  p_load_id,
    --  p_load_type,
    --
    --_________________________________________________________________________________________--

    PROCEDURE GENERATE_LTL_REPORT(p_load_id     IN  NUMBER,
                                  p_load_number IN  NUMBER,
                                  p_tariff_name IN  VARCHAR2,
                                  x_error_msg   OUT NOCOPY VARCHAR2,
                                  x_status      OUT  NOCOPY NUMBER) IS

    zoneNames       ZONENAMESTAB;
    l_lane_numbers  LANE_NUMBER_TAB;
    l_origins       ZONE_TAB;
    l_dests         ZONE_TAB;
    l_chart_names   RATECHARTNAMESTAB;
    l_min_charges   MIN_CHARGE_TAB;
    l_carriers      CARRIER_NAME_TAB;
    rateCharts      RATECHARTNAMESTAB;

    l_num_reused_zones   NUMBER;


     CURSOR NEW_ZONES (p_load_id IN NUMBER) IS
     SELECT
       zone_name
     FROM
       fte_interface_zones
     WHERE
       load_id = p_load_id  AND
       hash_value <> 0;

     CURSOR NEW_SERVICES_INFO (p_load_number IN NUMBER, p_tariff_name IN VARCHAR2) IS
     SELECT
       l.lane_number,
       oz.zone Origin,
       dz.zone Destination,
       hzp.party_name carrier_name,
       qlht.name rate_chart_name,
       prc.value_from minimum_charge
     FROM
       fte_lanes l,
       hz_parties hzp,
       qp_list_headers_tl qlht,
       wsh_regions_tl oz,
       wsh_regions_tl dz,
       fte_lane_rate_charts flrc,
       fte_prc_parameters prc
     WHERE
       l.tariff_name = p_tariff_name AND
       l.lane_type = 'LTL_' || p_tariff_name || '_' || p_load_number AND
       l.lane_id = prc.lane_id AND
       prc.parameter_id = g_min_charge_id AND
       oz.language = dz.language AND
       oz.language = userenv('LANG') AND
       l.origin_id = oz.region_id  AND
       l.destination_id = dz.region_id  AND
       l.lane_id = flrc.lane_id AND
       flrc.list_header_id = qlht.list_header_id  AND
       qlht.language = userenv('LANG') AND
       hzp.party_id = l.carrier_id;

     CURSOR NEW_RATE_CHARTS (p_load_number IN NUMBER, p_tariff_name IN VARCHAR2) IS
     SELECT DISTINCT
       qlht.name rate_chart_name
     FROM
       fte_lanes l,
       fte_lane_rate_charts flrc,
       qp_list_headers_tl qlht
     WHERE
       l.tariff_name = p_tariff_name AND
       l.lane_type = 'LTL_' || p_tariff_name || '_' || p_load_number AND
       l.lane_id = flrc.lane_id AND
       flrc.list_header_id = qlht.list_header_id AND
       qlht.language = userenv('LANG');

    l_load_number     NUMBER;
    l_module_name     CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GENERATE_LTL_REPORT';
    l_msg VARCHAR2(2000);

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_load_number := p_load_number;

        IF l_load_number IS NULL THEN
          OPEN GET_LOAD_NUMBER(p_tariff_name);
          FETCH GET_LOAD_NUMBER INTO l_load_number;
          CLOSE GET_LOAD_NUMBER;
        END IF;

        OPEN NEW_ZONES(p_load_id);
        FETCH NEW_ZONES BULK COLLECT INTO zoneNames;

        OPEN NEW_SERVICES_INFO(l_load_number,p_tariff_name);
        FETCH NEW_SERVICES_INFO BULK COLLECT INTO l_lane_numbers, l_origins, l_dests, l_carriers, l_chart_names, l_min_charges;

        OPEN NEW_RATE_CHARTS(l_load_number,p_tariff_name);
        FETCH NEW_RATE_CHARTS BULK COLLECT INTO rateCharts;

         FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_START_REPORT');        --              *** Start of BulkLoader Report ***

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => l_msg,
                               p_category       => NULL);

     FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                p_msg            => ' ',
                                p_category       => NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);

        --+
        -- Print the Header Info already remembered in the global variable
        -- "g_report_header"
        --+

        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Type of Process     : LTL Carrier',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Start Date          : ' || g_report_header.StartDate,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'End Date            : ' || to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS'),
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'File Name           : ' || g_report_header.FileName,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Tariff Name         : ' || g_report_header.TariffName,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Service Level       : ' || g_report_header.ServiceLevel,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Origin Country      : ' || g_report_header.Orig_Country,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Destination Country : ' || g_report_header.Dest_Country,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Currency            : ' || g_report_header.Currency,
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'UOM                 : ' || g_report_header.UOM,
                                   p_category    => NULL);

        l_num_reused_zones := rateCharts.COUNT - zoneNames.COUNT + 1;

        --+
        -- Print the Details part
        --+
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => ' ',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         =>'Created :',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => zoneNames.COUNT ||' New zones. Reused ' || l_num_reused_zones || ' zones.',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => l_lane_numbers.COUNT || ' Services',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => rateCharts.COUNT || ' Rate Charts',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => ' ',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Zones Information (Zone Name)',
                                   p_category    => NULL);

        FOR i in 1..zoneNames.COUNT LOOP
            FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                       p_msg         => zoneNames(i),
                                       p_category    => NULL);
        END LOOP;

        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => ' ',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Services Information',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Lane Number,   Origin,   Destination,   Carrier,   Rate Chart Name,   Minimum Charge',
                                   p_category    => NULL);

        FOR i in 1..l_lane_numbers.COUNT LOOP
            FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                       p_msg         => l_lane_numbers(i) || ',  ' || l_origins(i) || ',  '
                                                        || l_dests(i) || ',  ' || l_carriers(i) || ',  ' || l_chart_names(i) || ',  ' || l_min_charges(i),
                                       p_category    => NULL);
        END LOOP;

        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => ' ',
                                   p_category    => NULL);
        FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                   p_msg         => 'Rate Chart Information (Name)',
                                   p_category    => NULL);

        FOR i in rateCharts.FIRST..rateCharts.LAST LOOP
            FTE_UTIL_PKG.Write_OutFile(p_module_name => l_module_name,
                                       p_msg         => rateCharts(i),
                                       p_category    => NULL);
        END LOOP;

         FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);
    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => ' ',
                               p_category       => NULL);

    l_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BULKLOAD_END_REPORT');        --              *** End of BulkLoader Report ***

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => l_msg,
                               p_category       => NULL);

     FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                                p_msg            => ' ',
                                p_category       => NULL);

    FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name    => l_module_name,
                               p_msg            => '+---------------------------------------------------------------------------+',
                               p_category       => NULL);


        IF NEW_ZONES%ISOPEN  THEN
            CLOSE NEW_ZONES;
        END IF;

        IF NEW_SERVICES_INFO%ISOPEN THEN
            CLOSE NEW_SERVICES_INFO;
        END IF;

        IF NEW_RATE_CHARTS%ISOPEN THEN
            CLOSE NEW_RATE_CHARTS;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN

          IF NEW_ZONES%ISOPEN  THEN
             CLOSE NEW_ZONES;
          END IF;

          IF NEW_SERVICES_INFO%ISOPEN THEN
             CLOSE NEW_SERVICES_INFO;
          END IF;

          IF NEW_RATE_CHARTS%ISOPEN THEN
             CLOSE NEW_RATE_CHARTS;
          END IF;

          x_error_msg := sqlerrm;
          x_status := 2;
          FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
          FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END GENERATE_LTL_REPORT;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: OBSOLETE_PREVIOUS_LOAD
    --
    -- PURPOSE  Obsolete the lanes from a previous LTL load. This procedure
    --          uses the lane_type column in FTE_LANES to identify the lanes
    --          to be obsoleted.
    --
    -- PARAMETERS
    -- IN
    --    p_lane_type, The lane_type of the lanes to be obsoleted.
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --_________________________________________________________________________________--

    PROCEDURE OBSOLETE_PREVIOUS_LOAD (p_lane_type      IN     VARCHAR2,
                                      p_delete_lanes   IN     BOOLEAN,
                                      x_status         OUT  NOCOPY    NUMBER,
                                      x_error_msg      OUT  NOCOPY   VARCHAR2) IS

        l_lane_ids          NUMBER_TAB;
        l_effective_dates   STRINGARRAY;
        l_expiry_dates      STRINGARRAY;

        l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.OBSOLETE_PREVIOUS_LOAD';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN

            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Obsoleting Lanes...');

            IF (p_delete_lanes) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_delete_lanes', 'true');
            ELSE
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_delete_lanes', 'false');
            END IF;

            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_lane_type   ', p_lane_type);
        END IF;

        --+
        -- To 'delete' the lanes, set the effective date range
        -- to one that doesn't make sense, and change the editable flag.
        --+
        IF p_delete_lanes THEN

            UPDATE
              FTE_LANES
            SET
              expiry_date    = sysdate-1,
              effective_date = sysdate,
              editable_flag  = 'D',
              last_updated_by = G_USER_ID,
              last_update_date = SYSDATE,
              last_update_login = G_USER_ID
            WHERE
              lane_type LIKE p_lane_type
            RETURNING
              lane_id, effective_date, expiry_date
            BULK COLLECT INTO
              l_lane_ids, l_effective_dates, l_expiry_dates;

        ELSE

            UPDATE
              FTE_LANES
            SET
              expiry_date      = (G_VALID_DATE-Fnd_Number.Canonical_To_Number('0.0001')),
              last_updated_by  = G_USER_ID,
              last_update_date = SYSDATE,
              last_update_login = G_USER_ID
            WHERE
              lane_type LIKE p_lane_type AND
              nvl(expiry_date, G_VALID_DATE) >= G_VALID_DATE
            RETURNING
              lane_id, effective_date, expiry_date
            BULK COLLECT INTO
              l_lane_ids, l_effective_dates, l_expiry_dates;

        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Obsoleted ' || sql%rowcount || ' lanes.');
        END IF;

        FORALL i in 1..l_lane_ids.COUNT
            UPDATE
              FTE_LANE_RATE_CHARTS
            SET
              START_DATE_ACTIVE = l_effective_dates(i),
              END_DATE_ACTIVE = l_expiry_dates(i),
              last_updated_by  = G_USER_ID,
              last_update_date = SYSDATE,
              last_update_login = G_USER_ID
            WHERE
              list_header_id = (select list_header_id
                                from fte_lane_rate_charts
                                where lane_id = l_lane_ids(i));

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Obsolete Lane Rate Charts');
        END IF;

        FORALL i in 1..l_lane_ids.COUNT
            UPDATE
              QP_LIST_HEADERS_B
            SET
              START_DATE_ACTIVE = l_effective_dates(i),
              END_DATE_ACTIVE = l_expiry_dates(i),
              last_updated_by  = G_USER_ID,
              last_update_date = SYSDATE,
              last_update_login = G_USER_ID
            WHERE
              LIST_HEADER_ID = (SELECT list_header_id
                                FROM fte_lane_rate_charts
                                WHERE lane_id = l_lane_ids(i));

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := 'Unexpected error while obsoleting previous lanes => ' || sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END OBSOLETE_PREVIOUS_LOAD;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE:  ADD_CARRIERS_TO_RATECHARTS
    --
    -- PURPOSE
    --        Add new carriers as qualifiers to existing rate charts of a tariff.
    --
    -- PARAMETERS
    -- IN
    --     p_tariff_name
    --     p_load_number
    --     p_carrier_ids
    --     p_load_id
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --___________________________________________________________________________________--

    PROCEDURE ADD_CARRIERS_TO_RATECHARTS (p_tariff_name IN   VARCHAR2,
                                          p_load_number IN   NUMBER,
                                          p_carrier_ids IN   NUMBER_TAB,
                                          p_load_id     IN   NUMBER,
                                          x_status      OUT  NOCOPY  NUMBER,
                                          x_error_msg   OUT  NOCOPY  VARCHAR2) IS

        l_effective_dates    STRINGARRAY;
        l_start_dates        STRINGARRAY;

        l_list_header_ids    NUMBER_TAB;
        l_rate_names         STRINGARRAY;
        l_descriptions       VAR_ARR4000;

        l_currency_codes     STRINGARRAY;
        l_existing_carriers  NUMBER_TAB;
        l_max_groups         NUMBER_TAB;

        l_process_id         NUMBER;
        l_process_ids        NUMBER_TAB;

        l_rate_hdr_data       FTE_BULKLOAD_PKG.data_values_tbl;
        l_rate_hdr_block_tbl  FTE_BULKLOAD_PKG.block_data_tbl;

        l_qualifier_data      FTE_BULKLOAD_PKG.data_values_tbl;
        l_qualifier_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

        l_currency_tbl        FTE_RATE_CHART_PKG.LH_CURRENCY_CODE_TAB;
        l_name                FTE_RATE_CHART_PKG.LH_NAME_TAB;

        l_module_name        CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.ADD_CARRIERS_TO_RATECHARTS';

        CURSOR GET_RATE_CHART_DETAILS IS
        SELECT
          MAX(lh.list_header_id),
          MAX(lh.name),
          MAX(lh.description),
          MAX(b.currency_code),
          MAX(ql.qualifier_attr_value),
          MAX(ql.qualifier_grouping_no),
          MAX(b.start_date_active)
        FROM
          qp_list_headers_tl lh,
          qp_list_headers_b b,
          qp_qualifiers ql,
          fte_lane_rate_charts lrc,
          fte_lanes l
        WHERE
          l.tariff_name = p_tariff_name AND
          l.lane_type = 'LTL_' || p_tariff_name || '_' || p_load_number AND
          l.lane_id = lrc.lane_id AND
          lh.list_header_id = lrc.list_header_id AND
          lh.list_header_id = ql.list_header_id AND
          lh.list_header_id = b.list_header_id AND
          ql.qualifier_attribute = 'QUALIFIER_ATTRIBUTE1' AND
          ql.qualifier_context = 'PARTY' AND
          lh.language = USERENV('LANG')
        GROUP BY
          lh.list_header_id;
    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        OPEN GET_RATE_CHART_DETAILS;

        FETCH GET_RATE_CHART_DETAILS
        BULK COLLECT INTO l_list_header_ids,
                          l_rate_names,
                          l_descriptions,
                          l_currency_codes,
                          l_existing_carriers,
                          l_max_groups,
                          l_start_dates;

        CLOSE GET_RATE_CHART_DETAILS;

        IF (l_list_header_ids.COUNT <= 0) THEN
            x_status := 2;
            x_error_msg := 'Error in updating LTL rates. Previous load does not exist.';
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Number of ratecharts to modify',l_list_header_ids.COUNT);
        END IF;

        FOR i IN 1..l_list_header_ids.COUNT
        LOOP
            -- Get a process id
            SELECT qp_process_id_s.NEXTVAL
            INTO l_process_id
            FROM DUAL;

            l_process_ids(l_process_ids.COUNT + 1) := l_process_id;

            FTE_BULKLOAD_PKG.g_load_id := l_process_id;

            l_rate_hdr_data('ACTION')      := 'APPEND';
            l_rate_hdr_data('LTL_RATE_CHART_NAME') :=  l_rate_names(i);
            l_rate_hdr_data('CARRIER_ID')  := l_existing_carriers(1);
            l_rate_hdr_data('DESCRIPTION') := l_descriptions(i);
            l_rate_hdr_data('CURRENCY')    := l_currency_codes(i);
            l_rate_hdr_data('ATTRIBUTE1')  := 'LTL_RC';
            l_rate_hdr_data('START_DATE')  := to_char(l_start_dates(i),FTE_BULKLOAD_PKG.G_DATE_FORMAT);

            l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                     p_block_data   => l_rate_hdr_block_tbl,
                                                     p_line_number  => 0,
                                                     p_validate_column => FALSE,
                                                     p_process_id   => l_process_id,
                                                     x_status       => x_status,
                                                     x_error_msg    => x_error_msg);

            IF x_status <> -1 THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            -- for each rate chart, add all the carriers
            FOR m IN 1..p_carrier_ids.COUNT LOOP

                l_qualifier_data('ACTION')     := 'ADD';
                l_qualifier_data('PROCESS_ID') := l_process_id;
                l_qualifier_data('ATTRIBUTE')  := 'SUPPLIER';
                l_qualifier_data('VALUE')      := p_carrier_ids(m);
                l_qualifier_data('CONTEXT')    := 'PARTY';
                l_qualifier_data('GROUP')      := l_max_groups(i)+m;

                l_qualifier_block_tbl(1) := l_qualifier_data;

                FTE_RATE_CHART_LOADER.PROCESS_QUALIFIER(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_qualifier_block_tbl,
                                                        p_line_number   => 0,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END LOOP;
        END LOOP;

        -- Inserting Data into interface tables
        FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(p_qp_call   => FALSE,
                                                x_status    => x_status,
                                                x_error_msg => x_error_msg);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Calling QP for update ...');
        END IF;

        FOR i IN 1..l_process_ids.COUNT
        LOOP
            l_name(1) := l_rate_names(i);
            l_currency_tbl(1) := l_currency_codes(i);

            FTE_RATE_CHART_PKG.QP_API_CALL(p_chart_type   => 'LTL_RATE_CHART',
                                           p_process_id   => l_process_ids(i),
                                           p_name         => l_name,
                                           p_currency     => l_currency_tbl,
                                           x_status       => x_status,
                                           x_error_msg    => x_error_msg);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN

            IF (GET_RATE_CHART_DETAILS%ISOPEN) THEN
                CLOSE GET_RATE_CHART_DETAILS;
            END IF;

            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR OCCURED', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END ADD_CARRIERS_TO_RATECHARTS;

    --_____________________________________________________________________________________--
    --                                                                                     --
    -- PROCEDURE:  GET_PARAMETER_DEFAULTS                                                  --
    --                                                                                     --
    -- Purpose                                                                             --
    --     Populates all the default parameters in the global variables from               --
    --     the table FTE_PRC_PARAMETER_DEFAULTS.                                           --
    --                                                                                     --
    --     The Parameters are:                                                             --
    --           G_LANE_FUNCTION_ID G_MIN_CHARGE_ID G_DEF_WT_ENABLED_ID G_DEF_WT_BREAK_ID  --
    --
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --_____________________________________________________________________________________--

    PROCEDURE GET_PARAMETER_DEFAULTS (x_status    OUT NOCOPY VARCHAR2,
                                      x_error_msg OUT NOCOPY VARCHAR2) IS

        l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_PARAMETER_DEFAULTS';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (G_LANE_FUNCTION_ID is null) THEN
            SELECT
              parameter_id
            INTO
              G_LANE_FUNCTION_ID
            FROM
              FTE_PRC_PARAMETER_DEFAULTS
            WHERE
              parameter_type     = 'PARAMETER' AND
              parameter_sub_type = 'LANE' AND
              parameter_name     = 'LANE_FUNCTION' AND
              lane_function      = 'NONE';
        END IF;

        IF (G_MIN_CHARGE_ID is null) THEN
            SELECT
              parameter_id
            INTO
              G_MIN_CHARGE_ID
            FROM
              FTE_PRC_PARAMETER_DEFAULTS
            WHERE
              parameter_type     = 'PARAMETER' AND
              parameter_sub_type = 'MIN_CHARGE' AND
              parameter_name     = 'MIN_CHARGE_AMT' AND
              lane_function      = 'NONE';
        END IF;

        IF (G_DEF_WT_ENABLED_ID is null) THEN

            SELECT
              parameter_id
            INTO
              G_DEF_WT_ENABLED_ID
            FROM
              FTE_PRC_PARAMETER_DEFAULTS
            WHERE
              parameter_type     = 'PARAMETER' AND
              parameter_sub_type = 'DEFICIT_WT' AND
              parameter_name     = 'ENABLED' AND
              lane_function      = 'LTL';

        END IF;

        IF (G_DEF_WT_BREAK_ID is null) THEN

            SELECT
              parameter_id
            INTO
              G_DEF_WT_BREAK_ID
            FROM
              FTE_PRC_PARAMETER_DEFAULTS
            WHERE
              parameter_type     = 'PARAMETER' AND
              parameter_sub_type = 'DEFICIT_WT' AND
              parameter_name     = 'WT_BREAK_POINT' AND
              lane_function      = 'LTL';

        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_LANE_FUNCTION_ID ', G_LANE_FUNCTION_ID );
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_MIN_CHARGE_ID    ', G_MIN_CHARGE_ID);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_DEF_WT_ENABLED_ID', G_DEF_WT_ENABLED_ID);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_DEF_WT_BREAK_ID  ', G_DEF_WT_BREAK_ID);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_status := 2;
            x_error_msg := 'The setup for pricing parameters defaults is invalid';
            FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                       p_message     => x_error_msg);

            FTE_UTIL_PKG.Exit_Debug(l_module_name);
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                        p_message     => sqlerrm);

            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END GET_PARAMETER_DEFAULTS;

    --_________________________________________________________________________________--
    --
    --  PROCEDURE: CLEANUP_TABLES
    --
    -- Purpose
    --   Clean up the temporary tables after the rate chart loading process.
    --   Also roll back the effects of a "commit" when an error is encountered.
    --   The "rollback" is necessary because we have to commit before we launch the
    --   sub-processes for rate chart loading. If an error is encountered after
    --   rate chart loading, we have to undo the commit.
    --
    -- PARAMETERS
    -- IN
    --     p_load_id, The load id of the bulkload job.
    --     p_abort,    This should be set to true if we are aborting
    --                 and want to get rid of all data. If abort is false,
    --                 we only delete data in the interface tables.
    --     p_tariff_name, the tariff name
    --     p_action_code,
    --
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --_________________________________________________________________________________--

    PROCEDURE CLEANUP_TABLES (p_load_id       IN   NUMBER,
                              p_abort         IN   BOOLEAN,
                              p_tariff_name   IN   VARCHAR2,
                              p_action_code   IN   VARCHAR2,
                              p_save_data     IN   NUMBER,
                              x_status        OUT NOCOPY   VARCHAR2,
                              x_error_msg     OUT NOCOPY  VARCHAR2) IS

        CURSOR GET_PROCESS_IDS IS
        SELECT
          process_id,
          rate_chart_name
        FROM
          fte_interface_lanes
        WHERE
          load_id = p_load_id;

        l_process_id  NUMBER;
        l_chart_name  VARCHAR2(100);
        l_num_lh      NUMBER := 0;
        l_num_ql      NUMBER := 0;
        l_num_at      NUMBER := 0;
        l_num_ll      NUMBER := 0;
        l_num_ln      NUMBER := 0;
        l_num_zn      NUMBER := 0;
        l_num_lane    NUMBER := 0;
        l_abort       VARCHAR2(30);

        l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CLEANUP_TABLES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (p_abort) THEN
            l_abort := 'Yes';
        ELSE
            l_abort := 'No';
        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Cleanup Tables: Abort', ' ' || l_abort || ' ' );
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_load_id', p_load_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Save Interface data',  p_save_data);
        END IF;

        FND_CONC_GLOBAL.set_req_globals(conc_status => 'COMPLETED', request_data => NULL);

        OPEN GET_PROCESS_IDS;
        LOOP
            FETCH GET_PROCESS_IDS INTO l_process_id, l_chart_name;
            EXIT WHEN GET_PROCESS_IDS%NOTFOUND;

            IF (p_abort) THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleting Data From QP Tables');
                END IF;

                DELETE FROM
                  QP_LIST_HEADERS_B
                WHERE
                  list_header_id IN (SELECT list_header_id
                                     FROM qp_list_headers_tl
                                     WHERE name = l_chart_name);
                l_num_lh := l_num_lh + SQL%ROWCOUNT;

                DELETE FROM
                  QP_QUALIFIERS
                WHERE
                  list_header_id IN (SELECT list_header_id
                                     FROM qp_list_headers_tl
                                     WHERE name = l_chart_name);

                l_num_ql := l_num_ql + SQL%ROWCOUNT;

                DELETE FROM
                  QP_LIST_LINES
                WHERE
                  list_header_id IN (SELECT list_header_id
                                     FROM qp_list_headers_tl
                                     WHERE name = l_chart_name);
                l_num_ll := l_num_ll + SQL%ROWCOUNT;

                DELETE FROM
                  QP_PRICING_ATTRIBUTES
                WHERE list_header_id IN (SELECT list_header_id
                                         FROM qp_list_headers_tl
                                         WHERE name = l_chart_name);

                l_num_at := l_num_at + SQL%ROWCOUNT;

                DELETE FROM
                  FTE_LANE_RATE_CHARTS
                WHERE
                  list_header_id IN (SELECT list_header_id
                                     FROM qp_list_headers_tl
                                     WHERE name = l_chart_name);

                l_num_lane := l_num_lane + SQL%ROWCOUNT;

                DELETE FROM
                  QP_LIST_HEADERS_TL
                WHERE name = l_chart_name;

                DELETE FROM
                  FTE_INTERFACE_ZONES
                WHERE load_id = p_load_id;

                l_num_zn := l_num_zn + SQL%ROWCOUNT;
            END IF;

            IF p_save_data <> 1 THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleting Data From QP Interface Tables For Process Id ' || l_process_id);
                END IF;

                DELETE FROM QP_INTERFACE_LIST_LINES WHERE process_id = l_process_id;
                DELETE FROM QP_INTERFACE_QUALIFIERS WHERE process_id = l_process_id;
                DELETE FROM QP_INTERFACE_PRICINg_ATTRIBS WHERE process_id = l_process_id;
                DELETE FROM QP_INTERFACE_LIST_HEADERS WHERE process_id = l_process_id;
            END IF;
        END LOOP;

        CLOSE get_process_ids;
        --      delete from fte_bulkload_data where load_id = p_load_id;  --could be too expensive..

        DELETE FROM fte_interface_lanes WHERE load_id = p_load_id;

        l_num_ln := SQL%ROWCOUNT;

        DELETE FROM fte_interface_zones WHERE zone_id IS NULL;

        l_num_zn := l_num_zn + SQL%ROWCOUNT;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_lh || ' from QP_LIST_HEADERS');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_ll || ' from QP_LIST_LINES');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_at || ' from QP_PRICINg_ATTRIBUTES');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_ql || ' from QP_QUALIFIERS');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_ln || ' from FTE_INTERFACE_LANES');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_zn || ' from FTE_INTERFACE_ZONES');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || l_num_lane || ' from FTE_LANES');
        END IF;

        --+
        -- Cleanup FTE_TARIFF_CARRIERS
        --+
        DELETE FROM
          fte_tariff_carriers
        WHERE
          tariff_name = p_tariff_name AND
          action_code = 'N';

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleted ' || SQL%ROWCOUNT || ' rows from fte_tariff_carriers for tariff ' || p_tariff_name);
        END IF;

        UPDATE
          fte_tariff_carriers
        SET
          action_code = 'D',
          last_updated_by  = G_USER_ID,
          last_update_date = SYSDATE,
          last_update_login = G_USER_ID
        WHERE
          tariff_name = p_tariff_name AND
          action_code = 'M';

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Updated ' || sql%rowcount || ' rows in fte_tariff_carriers.');
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN

            IF (GET_PROCESS_IDS%ISOPEN) THEN
                CLOSE GET_PROCESS_IDS;
            END IF;

            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                       p_message     => sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CLEANUP_TABLES;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: CREATE_RATE_CHART
    --
    -- PURPOSE  Create a rate chart from a string of rate breaks and freight classes
    --
    -- PARAMETERS
    --
    -- IN
    --    p_carrier_ids: The name of the carriers.
    --    p_chart_name: The name of the rate chart.
    --    p_break_string: String containing concatenation of rate breaks.
    --    p_class_string: String containing concatenation of freight classes.
    --
    -- OUT
    --    x_status: Completion status. Success ==> -1, Failure otherwise.
    --    x_error_msg: Error message, if there is an error.
    --    x_process_id: The process id associated with the rate chart.
    --___________________________________________________________________________________--

    PROCEDURE CREATE_RATE_CHART(p_chart_name    IN   VARCHAR2,
                                p_carrier_ids   IN   NUMBER_TAB,
                                p_break_string  IN   VARCHAR2,
                                p_class_string  IN   VARCHAR2,
                                x_status        OUT  NOCOPY  VARCHAR2,
                                x_error_msg     OUT  NOCOPY  VARCHAR2,
                                x_process_id    OUT  NOCOPY  NUMBER) IS

    TYPE t_breakList      IS TABLE OF VARCHAR2(6);
    TYPE t_break_max_vals IS TABLE OF NUMBER;

    v_description         VARCHAR2(200) := 'LTL RATE CHART ' || p_chart_name;
    v_status              NUMBER;

    v_class_value         VARCHAR2(20);
    v_classes             STRINGARRAY;

    v_break_numchars      CONSTANT NUMBER := 6;
    v_break_charge        VARCHAR2(10);

    v_break_charges       t_breakList := t_breakList(); -- collection holding the list of prices
    v_price_charge_count  NUMBER := 0;

    v_validate_keys       STRINGARRAY;
    v_validate_data       STRINGARRAY;

    v_break_max_vals   t_break_max_vals := t_break_max_vals(Fnd_Number.Canonical_To_Number('499.999999999999999'), --15dp
                                                            Fnd_Number.Canonical_To_Number('999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('1999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('4999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('9999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('19999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('29999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('39999.999999999999999'),
                                                            Fnd_Number.Canonical_To_Number('9999999'));

    -- variables for creating commodity classes from class_string
    v_class_string               VARCHAR2(200) := p_class_string;

    -- variables for creating break charges from class_string
    v_break_str_len              NUMBER := length(p_break_string);
    v_break_start_index          NUMBER := 1;

    -- variables for creating lines from classes and break charges.
    v_parent_linenum             NUMBER := 1;
    v_current_linenum            NUMBER := 0;
    v_current_break              NUMBER := 1;   -- current break index in table of break charges
    v_break_min                  NUMBER;        -- min charge for the current break
    v_break_max                  NUMBER := -1;  -- max charge for the current break

    v_numBreaks_perClass  CONSTANT NUMBER := 9;   -- this is standard for LTL.

    l_rate_hdr_data       FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_block_tbl  FTE_BULKLOAD_PKG.block_data_tbl;

    l_rate_line_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_qualifier_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_qualifier_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_attribute_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_attribute_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_rate_break_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_break_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CREATE_RATE_CHART';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;
        x_error_msg := 'COMPLETED';

        BEGIN
            SELECT QP_PROCESS_ID_S.NEXTVAL
            INTO   x_process_ID
            FROM   DUAL;
        EXCEPTION
            WHEN OTHERS THEN
                x_status := 2;
                x_error_msg := 'Unexpected error while performing select qp_process_id_s.nextval ' || sqlerrm;
                FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
        END;

        FTE_BULKLOAD_PKG.g_load_id := x_process_id;

        G_TOTAL_NUMCHARTS := G_TOTAL_NUMCHARTS + 1;

        --+
        -- Get the classes from the class_string and store in collection v_classes
        --+

        v_class_string := REPLACE(v_class_string,' '); -- remove white spaces
        v_classes := FTE_UTIL_PKG.TOKENIZE_STRING(v_class_string, ',');

        --+
        -- Get the breaks from the break_string and store in collection v_break_charges
        -- The break_string is a concatenation of break charges. Each charge consists of
        -- 'v_break_numchars'(6) characters.
        --+

        BEGIN

            WHILE v_break_start_index < v_break_str_len LOOP

                v_price_charge_count := v_price_charge_count + 1;
                v_break_charge := SUBSTR(p_break_string, v_break_start_index, v_break_numchars);

                IF LENGTH(v_break_charge) < v_break_numchars THEN
                    x_error_msg := 'NOT ENOUGH PRICE BREAKS IN STRING ' || p_break_string;
                    FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                               p_message     => x_error_msg);  -- C

                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                v_break_start_index := v_break_start_index + v_break_numchars;
                v_break_charges.EXTEND;
                v_break_charges(v_price_charge_count) := v_break_charge;

            END LOOP;
        END;

        v_price_charge_count := v_break_charges.COUNT;

       /* -------------------------------------------------------------------------------------------
        This rate chart creation process simulates a simple rate chart with freight classes,
        attributes and breaks. An example is shown below:

        RATE_CHART
        ACTION  CARRIER_NAME      RATE_CHART_NAME  CURRENCY  START_DATE   END_DATE   DESCRIPTION
        ADD          UPS          RATE_CHART_1     USD       30-Jun-01    30-Jun-03  Rate Chart 1

        RATE_LINE
        ACTION   LINE_NUMBER  DESCRIPTION   RATE    UOM     RATE_BREAK_TYPE      VOLUME_TYPE
        ADD      1                 Line             Lbs     POINT                TOTAL_QUANTITY

        RATE_BREAK
        ACTION   LINE_NUMBER   LOWER_LIMIT  UPPER_LIMIT  RATE*
        ADD      2             0            499          58.28
        ADD      3             500          999          49.29
         .       .             .            .            .
         .       .             .            .            .
        ADD      9             50000        99999        28.41

        RATING_ATTRIBUTE
        ACTION  LINE_NUMBER   ATTRIBUTE   ATTRIBUTE_VALUE
        ADD     1         COMMODITY       FC.200.US

        RATE_LINE
        ACTION    LINE_NUMBER  DESCRIPTION   RATE    UOM     RATE_BREAK_TYPE      VOLUME_TYPE
        ADD       10           Line                  Lbs     POINT                TOTAL_QUANTITY
         .        .            .             .       .        .                   .
        --------------------------------------------------------------------------------------------*/

        -- Validate the header

        l_rate_hdr_data('ACTION')      := 'ADD';
        l_rate_hdr_data('LTL_RATE_CHART_NAME') :=  p_chart_name;
        l_rate_hdr_data('CARRIER_ID')  := p_carrier_ids(1);
        l_rate_hdr_data('DESCRIPTION') := v_description;
        l_rate_hdr_data('CURRENCY')    := G_LTL_CURRENCY;
        l_rate_hdr_data('ATTRIBUTE1')  := 'LTL_RC';
        l_rate_hdr_data('START_DATE')  := to_char(G_VALID_DATE,FTE_BULKLOAD_PKG.G_DATE_FORMAT);
        l_rate_hdr_data('END_DATE')    := '';

        l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                 p_block_data   => l_rate_hdr_block_tbl,
                                                 p_line_number  => 0,
                                                 p_validate_column => FALSE,
                                                 p_process_id   => x_process_id,
                                                 x_status       => x_status,
                                                 x_error_msg    => x_error_msg);

        IF (x_status <> -1) THEN
           -- if the rate chart already exists, delete it, then try creating the rate chart again.
            IF (x_status = 999) THEN
                -- v_validate_data(1) := 'DELETE';
                l_rate_hdr_data('ACTION') := 'DELETE';
                l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                         p_block_data   => l_rate_hdr_block_tbl,
                                                         p_line_number  => 0,
                                                         p_validate_column => FALSE,
                                                         p_process_id   => x_process_id,
                                                         x_status       => x_status,
                                                         x_error_msg    => x_error_msg);
                -- v_validate_data(1) := 'ADD';
                l_rate_hdr_data('ACTION') := 'ADD';
                l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                         p_block_data   => l_rate_hdr_block_tbl,
                                                         p_line_number  => 0,
                                                         p_validate_column => FALSE,
                                                         p_process_id   => x_process_id,
                                                         x_status       => x_status,
                                                         x_error_msg    => x_error_msg);
            ELSE
                x_status := 2;
                x_error_msg := 'Error in ' || p_chart_name || ': ' || x_error_msg;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        IF (x_status <> -1) THEN
            x_status := 2;
            return;
        END IF;

        -- Validate Lines
        BEGIN
            --
            -- For each class, validate the parent line, and then validate
            -- the breaks for that class. We take out the first and last elements
            -- of this array since they are blank.
            -- e.g. v_class_string is like ,500,400,...,10,
            --
            FOR v_class_counter IN v_classes.first + 1..v_classes.last - 1 LOOP

                l_rate_line_data('ACTION')       := 'ADD';
                l_rate_line_data('LINE_NUMBER')  := v_parent_linenum;
                l_rate_line_data('DESCRIPTION')  := v_description;
                l_rate_line_data('RATE')         := '';
                l_rate_line_data('UOM')          := G_LTL_UOM;
                l_rate_line_data('RATE_BREAK_TYPE')  := 'POINT';
                l_rate_line_data('VOLUME_TYPE')  := 'TOTAL_QUANTITY';
                l_rate_line_data('RATE_TYPE')    := 'PER_UOM';

                l_rate_line_block_tbl(1) := l_rate_line_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_rate_line_block_tbl,
                                                        p_line_number   => 0,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);

                IF (x_status <> -1) THEN
                    x_error_msg := 'Line ' || v_parent_linenum || ' of ' || p_chart_name || ': ' || x_error_msg;
                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                v_break_max := Fnd_Number.Canonical_To_Number('0');
                -- example (break_min,break_max) pairs are (0, 500..), (500, 1000..), ...
                v_current_linenum := 0;

                FOR i IN 1..v_numBreaks_perClass LOOP
                    v_break_min := v_break_max + Fnd_Number.Canonical_To_Number('0');
                    v_break_max := v_break_max_vals(i);
                    v_break_charge := v_break_charges(v_current_break);

                    v_break_charge := ltrim(v_break_charge, '0');

                    IF (LENGTH(v_break_charge) > 0) THEN  -- skip if it was all 0's.
                        v_current_linenum := v_current_linenum + 1;
                        v_break_charge := Fnd_Number.Number_To_Canonical(Fnd_Number.Canonical_To_Number(v_break_charge)/10000);

                        l_rate_break_data('ACTION')     := 'ADD';
                        l_rate_break_data('LINE_NUMBER'):= (v_parent_linenum + v_current_linenum);
                        l_rate_break_data('LOWER_LIMIT'):= Fnd_Number.Number_To_Canonical(v_break_min);
                        l_rate_break_data('UPPER_LIMIT'):= Fnd_Number.Number_To_Canonical(v_break_max);
                        l_rate_break_data('RATE')       := v_break_charge;

                        l_rate_break_block_tbl(1) := l_rate_break_data;

                        FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header  => g_dummy_block_hdr_tbl,
                                                                 p_block_data    => l_rate_break_block_tbl,
                                                                 p_line_number   => 0,
                                                                 p_validate_column => FALSE,
                                                                 x_status        => x_status,
                                                                 x_error_msg     => x_error_msg);

                        IF (x_status <> -1) THEN
                            v_status := v_parent_linenum + v_current_linenum;
                            x_status := 2;
                            x_error_msg := 'Line Break ' || v_status || ' of ' || p_chart_name || ': ' || x_error_msg;
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                        END IF;
                    END IF;
                    v_current_break := v_current_break + 1;
                END LOOP;

                IF (v_current_linenum = 0) THEN
                    x_error_msg := 'Line ' || v_parent_linenum || ' of ' || p_chart_name || ' has no breaks.';
                    FTE_UTIL_PKG.Write_LogFile( p_module_name => l_module_name,
                                                p_message   => x_error_msg);

                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    return;
                END IF;

                v_class_value := v_classes(v_class_counter);

                l_attribute_data('ACTION')              := 'ADD';
                l_attribute_data('LINE_NUMBER')         := v_parent_linenum;
                l_attribute_data('ATTRIBUTE')           := 'COMMODITY';
                l_attribute_data('ATTRIBUTE_VALUE')     := 'FC.'||v_class_value;

                l_attribute_block_tbl(1) := l_attribute_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATING_ATTRIBUTE( p_block_header  => g_dummy_block_hdr_tbl,
                                                                p_block_data    => l_attribute_block_tbl,
                                                                p_line_number   => 0,
                                                                p_validate_column => FALSE,
                                                                x_status        => x_status,
                                                                x_error_msg     => x_error_msg);

                IF (x_status <> -1) THEN
                    x_error_msg := 'Error Validating Attribute FC.' || v_class_value|| ': ' || x_error_msg;
                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    return;
                END IF;

                v_parent_linenum := v_parent_linenum + v_current_linenum + 1;
            END LOOP; -- end looping over classes

            -- Add the rest of the carriers as qualifiers.
            FOR q IN 2..p_carrier_ids.COUNT LOOP

                l_qualifier_data('ACTION')     := 'ADD';
                l_qualifier_data('PROCESS_ID') := x_process_id;
                l_qualifier_data('ATTRIBUTE')  := 'SUPPLIER';
                l_qualifier_data('VALUE')      :=  p_carrier_ids(q);
                l_qualifier_data('CONTEXT')    := 'PARTY';
                l_qualifier_data('GROUP')      := q;

                l_qualifier_block_tbl(1) := l_qualifier_data;

                FTE_RATE_CHART_LOADER.PROCESS_QUALIFIER(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_qualifier_block_tbl,
                                                        p_line_number   => 0,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END LOOP;

            G_CHART_COUNT_TEMP := G_CHART_COUNT_TEMP + 1;

            IF (G_CHART_COUNT_TEMP = G_BULK_INSERT_LIMIT) THEN

                 FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(x_status    => x_status,
                                                         x_error_msg => x_error_msg);

                IF (x_status <> -1) THEN
                    x_error_msg := 'ERROR INSERTING DATA into QP_INTERFACE TABLES: ' || x_error_msg;
                    x_status := 2;
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
                G_CHART_COUNT_TEMP := 0;
            END IF;
         END;

         FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR',sqlerrm);
    END CREATE_RATE_CHART;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: CREATE_LANE_DATA
    --
    -- PURPOSE to create the lane data,
    --
    -- PARAMETERS
    --      p_origin_id
    --      p_destination_id
    --      p_carriers_id
    --      p_effective_Dates
    --      p_expiry_dates
    --      p_tariff_names
    --      p_lane_type
    --      p_category_ids
    --      p_list_header_id
    --      p_min_charge
    --
    -- OUT
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.
    --___________________________________________________________________________________--

    PROCEDURE CREATE_LANE_DATA (p_origin_id        IN  NUMBER,
                                p_destination_id   IN  NUMBER,
                                p_carrier_ids      IN  NUMBER_TAB,
                                p_effective_dates  IN  STRINGARRAY,
                                p_expiry_dates     IN  STRINGARRAY,
                                p_tariff_name      IN  VARCHAR2,
                                p_lane_type        IN  VARCHAR2,
                                p_category_ids     IN  NUMBER_TAB,
                                p_list_header_id   IN  NUMBER,
                                p_min_charge       IN  NUMBER,
                                x_status           OUT NOCOPY NUMBER,
                                x_error_msg        OUT NOCOPY VARCHAR2) IS

        l_fc_value           VARCHAR2(10);
        l_category_ids       NUMBER_TAB;
        l_catg_id            NUMBER;
        l_lane_id            NUMBER;
        l_deficit_wt_breaks  STRINGARRAY;
        l_num_lanes          NUMBER;

        l_module_name        CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CREATE_LANE_DATA';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_catg_id := p_category_ids(1);

        IF ( FTE_BULKLOAD_PKG.g_debug_on ) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_origin_id      ',p_origin_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_destination_id ',p_destination_id );
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_tariff_name    ',p_tariff_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_list_header_id ',p_list_header_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_lane_type      ',p_tariff_name);
        END IF;

        --+
        -- For each carrier, create a lane and its associated entities
        --+
        FOR k IN 1..p_carrier_ids.COUNT LOOP

            SELECT fte_lanes_s.NEXTVAL INTO l_lane_id FROM DUAL;

            -- FTE_LANE_COMMODITIES
            FOR m IN 1..p_category_ids.COUNT LOOP
                CM_LANE_ID(cm_lane_id.COUNT+1) := l_lane_id;
                CM_CATG_ID(cm_catg_id.COUNT+1) := p_category_ids(m);
            END LOOP;

            --+
        -- If we have more than one commodity on the lane, we need to set the commodity
            -- in FTE_LANES to null and store everything in FTE_LANE_COMMODITIES.
            --+
            IF p_category_ids.COUNT > 1 THEN
                l_catg_id := NULL;
            END IF;

            -- FTE_LANES
            LN_LANE_ID(ln_lane_id.COUNT+1)      := l_lane_id;
            LN_CARRIER_ID(ln_carrier_id.COUNT+1):= p_carrier_ids(k);
            LN_START_DATE(ln_start_date.COUNT+1):= p_effective_dates(k);
            LN_END_DATE(ln_end_date.COUNT+1)    := p_expiry_dates(k);

            --+
            -- Switch back the origin and destination if we are dealing with inbound.
            --+
            IF (G_DIRECTION_FLAG = 'I') THEN
                LN_DEST_ID(ln_dest_id.COUNT+1)          := p_origin_id;
                LN_ORIGIN_ID(ln_origin_id.COUNT+1)      := p_destination_id;
            ELSIF (G_DIRECTION_FLAG = 'O' OR G_DIRECTION_FLAG IS NULL) THEN
                LN_ORIGIN_ID(ln_origin_id.COUNT+1)      := p_origin_id;
                LN_DEST_ID(ln_dest_id.COUNT+1)          := p_destination_id;
            END IF;

            LN_COMMODITY_CATG_ID(ln_commodity_catg_id.COUNT+1)   := l_catg_id;
            LN_COMM_FC_CLASS_CODE(ln_comm_fc_class_code.COUNT+1) := 'FC';
            LN_LANE_TYPE(ln_lane_type.COUNT+1)                   := p_lane_type;
            LN_TARIFF_NAME(ln_tariff_name.COUNT+1)               := p_tariff_name;

            -- FTE_LANE_RATE_CHARTS
            LRC_LANE_ID(lrc_lane_id.COUNT+1)                     := l_lane_id;
            LRC_LIST_HEADER_ID(lrc_list_header_id.COUNT+1)       := p_list_header_id;
            LRC_START_DATE(lrc_start_date.COUNT+1)               := G_VALID_DATE;
            LRC_END_DATE(lrc_end_date.COUNT+1)                   := NULL;

            -- FTE_PRC_PARAMETERS

            -- Deficit Weight Breaks
            l_deficit_wt_breaks := STRINGARRAY('0', '500', '1000', '2000', '5000', '10000', '20000', '30000', '40000');

            FOR n IN 1..l_deficit_wt_breaks.COUNT LOOP
                PRC_VALUE_FROM(prc_value_from.COUNT+1)     := l_deficit_wt_breaks(n);
                PRC_PARAMETER_ID(prc_parameter_id.COUNT+1) := G_DEF_WT_BREAK_ID;
                PRC_LANE_ID(prc_lane_id.COUNT+1)           := l_lane_id;
            END LOOP;

            -- Enable Deficit Weights
            PRC_VALUE_FROM(prc_value_from.COUNT+1)        := 'Y';
            PRC_PARAMETER_ID(prc_parameter_id.COUNT+1)    := G_DEF_WT_ENABLED_ID ;
            PRC_LANE_ID(prc_lane_id.COUNT+1)              := l_lane_id;

            -- Lane FunctionID
            PRC_VALUE_FROM(prc_value_from.COUNT+1)        := 'LTL';
            PRC_PARAMETER_ID(prc_parameter_id.COUNT+1)    := G_LANE_FUNCTION_ID;
            PRC_LANE_ID(prc_lane_id.COUNT+1)              := l_lane_id;

            -- Minimum charge
            PRC_VALUE_FROM(prc_value_from.COUNT+1)        := p_min_charge;
            PRC_PARAMETER_ID(prc_parameter_id.COUNT+1)    := G_MIN_CHARGE_ID;
            PRC_LANE_ID(prc_lane_id.COUNT+1)              := l_lane_id;

            IF (LN_LANE_ID.COUNT >= G_BULK_INSERT_LIMIT) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Bulk inserting Lanes');
                Bulk_Insert_Lanes;
                Bulk_Insert_Lane_Rate_Charts;
            END IF;

            IF (PRC_LANE_ID.COUNT >= G_BULK_INSERT_LIMIT) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Bulk inserting Lane Parameters');
                Bulk_Insert_Lane_Parameters;
            END IF;

            IF (CM_LANE_ID.COUNT >= G_BULK_INSERT_LIMIT) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Bulk inserting Lane Commodities');
                Bulk_Insert_Lane_Commodities;
            END IF;

        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR', SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CREATE_LANE_DATA;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:CREATE_LANES
    --
    -- PURPOSE To create lanes. Actually, delegates the  lane data creation to CREATE_LANE_DATA-
    --         Use the WSH API to create the regions and
    --         zones in the WSH tables.
    -- PARAMETERS
    -- IN
    --   p_load_id
    --   p_tariff_name
    --   p_carrier_ids
    --   p_effective_dates
    --   p_expiry_dates
    --
    -- OUT
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.-
    --_________________________________________________________________________________--

    PROCEDURE CREATE_LANES (p_load_id          IN  NUMBER,
                            p_tariff_name      IN  VARCHAR2,
                            p_carrier_ids      IN  NUMBER_TAB,
                            p_effective_dates  IN  STRINGARRAY,
                            p_expiry_dates     IN  STRINGARRAY,
                            x_status           OUT NOCOPY VARCHAR2,
                            x_error_msg        OUT NOCOPY VARCHAR2) IS


        l_fc_class_code        VARCHAR2(2);
        l_lane_commodities     STRINGARRAY;
        l_lanes_temp           lanes_temp_record;
        l_zones_temp           zones_temp_record;
        l_list_header_id       NUMBER;
        c_current_fetch        NUMBER;
        c_previous_fetch       NUMBER;
        k_counter              NUMBER;
        l_catg_id              NUMBER;
        l_category_ids         Number_Tab;
        l_number_of_loads      NUMBER;
        l_previous_name        VARCHAR2(40);

        --+
        -- This cursor queries the RateChart Name and the String form the FTE_INTERFACE_LANES
        --+
        CURSOR GET_LANES(p_load_id NUMBER) IS
        SELECT
          origin_id,
          dest_id,
          rate_chart_name,
          class_string,
          min_charge1
        FROM
          fte_interface_lanes
        WHERE
          load_id = p_load_id;

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CREATE_LANES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_previous_name  := 'NULL';
        c_previous_fetch := 0;

        OPEN GET_LANES(p_load_id);
        LOOP
            FETCH  GET_LANES BULK COLLECT INTO l_lanes_temp.origin_id,
                                               l_lanes_temp.dest_id,
                                               l_lanes_temp.rate_chart_name,
                                               l_lanes_temp.class,
                                               l_lanes_temp.min_charge1 LIMIT 1000;

            FOR i IN 1..l_lanes_temp.origin_id.COUNT LOOP

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_lanes_temp.rate_chart_name('||i||')',l_lanes_temp.rate_chart_name(i));
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_lanes_temp.origin_id('||i||')',l_lanes_temp.origin_id(i));
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_lanes_temp.dest_id('||i||')',l_lanes_temp.dest_id(i));
                END IF;

                BEGIN
                    SELECT
                      l.list_header_id
                    INTO
                      l_list_header_id
                    FROM
                      qp_list_headers_tl l,
                      qp_list_headers_b b
                    WHERE
                      l.list_header_id = b.list_header_id AND
                      l.name = l_lanes_temp.rate_chart_name(i) AND
                      l.language = userenv('LANG');

                EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                        x_status := 2;
                        x_error_msg := 'Rate Chart ' || l_lanes_temp.rate_chart_name(i) || ' NOT FOUND!';
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;

                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := sqlerrm;
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;

                l_lane_commodities := FTE_UTIL_PKG.TOKENIZE_STRING(l_lanes_temp.class(i),',');
                l_category_ids.DELETE;

                IF (l_lane_commodities.COUNT <= 2) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_COMMODITY_MISSING');
                    FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'C',
                                                p_line_number => 0);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                FOR j IN 2..l_lane_commodities.COUNT-1 LOOP

                    FTE_UTIL_PKG.GET_CATEGORY_ID(p_commodity_value => 'FC.'||l_lane_commodities(j),
                                                 x_catg_id         => l_catg_id,
                                                 x_class_code      => l_fc_class_code,
                                                 x_status          => x_status,
                                                 x_error_msg       => x_error_msg);

                    IF (l_catg_id IS NULL OR x_status <> -1) THEN
                        x_status := 2;
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    ELSE
                        l_category_ids(j-1) := l_catg_id;
                    END IF;

                END LOOP;

                CREATE_LANE_DATA(p_origin_id        => l_lanes_temp.origin_id(i),
                                 p_destination_id   => l_lanes_temp.dest_id(i),
                                 p_carrier_ids      => p_carrier_ids,
                                 p_effective_dates  => p_effective_dates,
                                 p_expiry_dates     => p_expiry_dates,
                                 p_tariff_name      => p_tariff_name,
                                 p_lane_type        => 'LTL_' || p_tariff_name || '_' || l_number_of_loads,
                                 p_category_ids     => l_category_ids,
                                 p_list_header_id   => l_list_header_id,
                                 p_min_charge       => l_lanes_temp.min_charge1(i),
                                 x_status           => x_status,
                                 x_error_msg        => x_error_msg);
            END LOOP;

            EXIT WHEN (GET_LANES%NOTFOUND);

        END LOOP;

        CLOSE GET_LANES;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Bulk Inserting Last Set of Data');
        END IF;

        Bulk_Insert_Lanes;
        Bulk_Insert_Lane_Rate_Charts;
        Bulk_Insert_Lane_Parameters;
        Bulk_Insert_Lane_Commodities;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

     EXCEPTION
        WHEN OTHERS THEN

            IF (GET_LANES%ISOPEN) THEN
                CLOSE GET_LANES;
            END IF;

            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXCEPTED ERROR ',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

     END CREATE_LANES;

    --____________________________________________________________________________________--
    --
    -- PROCEDURE:  FIND_IDENTICAL_ZONE
    --
    -- PURPOSE: Given a reference zone name and a set of zone names, find out if
    --          any of the zones in the set is identical to the reference zone.
    --          If an identical zone is found, the out parameters x_identical_zone
    --          and x_zone_id are the zone_name and zone_id of the matching zone.
    --
    -- PARAMETERS
    -- IN
    --      p_zone_name        The reference zone name
    --      p_matching_zones  The set of zones to be checked.
    -- OUT
    --      x_identical_zone OUT  NOCOPY VARCHAR2:
    --      x_zone_id        OUT  NOCOPY NUMBER:
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.
    --____________________________________________________________________________________--

    PROCEDURE FIND_IDENTICAL_ZONE(p_zone_name      IN  VARCHAR2,
                                  p_matching_zones IN  STRINGARRAY,
                                  p_origin_flag    IN  BOOLEAN,
                                  x_identical_zone OUT NOCOPY VARCHAR2,
                                  x_zone_id        OUT NOCOPY NUMBER,
                                  x_status         OUT NOCOPY  VARCHAR2,
                                  x_error_msg      OUT NOCOPY  VARCHAR2) IS

        j                    NUMBER;
        l_row_numbers        NUMBER_TAB;
        l_zone_ids           NUMBER_TAB;
        l_zone_names         STRINGARRAY;
        l_postal_strings     var_arr4000;
        l_mismatch           BOOLEAN;
        l_country_codes      STRINGARRAY;
        l_new_country_code   VARCHAR2(10);

        CURSOR GET_ZONE_DETAILS( p_zone1  IN  VARCHAR2, p_zone2  IN  VARCHAR2) IS
            SELECT
              zone_name,
              postal_code_string,
              row_number,
              zone_id
            FROM
              fte_interface_zones
            WHERE
              zone_name IN (p_zone1, p_zone2) AND
              hash_value <> 0
            ORDER BY
              row_number;

        CURSOR GET_ZONE_COUNTRY(p_zone_name IN VARCHAR2) IS
            SELECT
              w2.country_code
            FROM
              wsh_zone_regions w,
              fte_interface_zones f,
              wsh_regions w2
            WHERE
              w.parent_region_id = f.zone_id AND
              f.zone_name = p_zone_name AND
              w.region_id = w2.region_id;

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.FIND_IDENTICAL_ZONE';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        x_identical_zone := NULL;
        x_zone_id  := NULL;

        IF FTE_BULKLOAD_PKG.g_debug_on THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_zone_name ', p_zone_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_matching_zones.COUNT', p_matching_zones.COUNT);
        END IF;

        FOR i IN 1..p_matching_zones.COUNT LOOP

            OPEN GET_ZONE_DETAILS(p_zone_name, p_matching_zones(i));

            FETCH GET_ZONE_DETAILS
            BULK COLLECT INTO
               l_zone_names,
               l_postal_strings,
               l_row_numbers,
               l_zone_ids;

            CLOSE GET_ZONE_DETAILS;

            j := 1;
            l_mismatch := FALSE;

            WHILE (j <= l_postal_strings.COUNT-1) LOOP
                IF (l_postal_strings(j) <> l_postal_strings(j+1)) THEN
                    -- we've found a mismatch
                    l_mismatch := true;
                    EXIT;
                END IF;
                    j := j + 2;
            END LOOP;
            --+
            -- If we looped through everything, then all the postal
            -- code strings must match for the two zones.
            -- now check country
            --+
            IF (NOT l_mismatch AND j > l_postal_strings.COUNT AND j >= 2) THEN

                IF (p_origin_flag) THEN
                    l_new_country_code := G_ORIG_COUNTRY;
                ELSE
                    l_new_country_code := G_DEST_COUNTRY;
                END IF;

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_new_country_code', l_new_country_code);
                END IF;

                OPEN GET_ZONE_COUNTRY(p_matching_zones(i));

                FETCH GET_ZONE_COUNTRY
                BULK COLLECT INTO l_country_codes;

                CLOSE GET_ZONE_COUNTRY;

                --+
                -- verify new zone's country is in the matching zone's country list
                --+
                l_mismatch := TRUE;

                FOR k IN 1..l_country_codes.COUNT LOOP

                    IF ( FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_country_codes(' || k || ')', l_country_codes(k));
                    END IF;

                    IF (l_new_country_code = l_country_codes(k)) THEN -- if found a country match, then can use this zone
                        l_mismatch := FALSE;
                    END IF;

                END LOOP;
            END IF;

            IF (NOT l_mismatch AND j > l_postal_strings.COUNT AND j >= 2) THEN

            IF (l_zone_ids(1) IS NOT NULL) THEN
                    x_zone_id := l_zone_ids(1);
                    x_identical_zone := l_zone_names(1);
                ELSE
                    x_zone_id := l_zone_ids(2);
                    x_identical_zone := l_zone_names(2);
                END IF;

                --+
                -- this shouldn't happen, but life is sometimes unfair...
                --+
                IF (x_zone_id IS NULL) THEN
                    x_identical_zone := NULL;
                END IF;

                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            END IF;

        END LOOP; --END looping through matching zones

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN

            IF(GET_ZONE_COUNTRY%ISOPEN) THEN
                CLOSE GET_ZONE_COUNTRY;
            END IF;
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END FIND_IDENTICAL_ZONE;


    --__________________________________________________________________________________--
    --
    -- PROCEDURE: LOAD_RATE_CHARTS
    --
    -- PURPOSE
    --          Analyze the data in FTE_BULKLOAD_FILE:
    --          a. Identify the destinations sharing the same rate chart and group
    --             them in the same zone. Put this information in FTE_INTERFACE_ZONES.
    --          b. Create a rate chart for each zone. Put this chart information
    --             into the QP_INTERFACE tables and later into the QP tables.
    -- PARAMETERS
    -- IN
    --   p_load_id
    --   p_number_of_loads
    -- OUT
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.
    --__________________________________________________________________________________--

    PROCEDURE LOAD_RATE_CHARTS (p_load_id         IN   NUMBER,
                                p_number_of_loads IN   NUMBER,
                                p_origin          IN   VARCHAR2,
                                p_origin_name     IN   VARCHAR2,
                                x_status          OUT NOCOPY  NUMBER,
                                x_error_msg       OUT NOCOPY  VARCHAR2) IS

        l_counter            NUMBER;
        l_debug_on           NUMBER;
        l_conc_request_data  VARCHAR2(1000);
        p_retcode            VARCHAR2(100);
        x_request_ids        NUMBER_TAB;

        l_module_name        CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.LOAD_RATE_CHARTS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        p_retcode := '0';
        x_status := -1;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            l_debug_on := 1;
        END IF;

        --
        -- load the rate charts
        --
        FOR l_counter in 1..G_NUM_CONC_PROCESSES LOOP

            x_request_ids(l_counter) := FND_REQUEST.SUBMIT_REQUEST(application  => 'FTE',
                                                                   program      => 'FTE_RC_LOADER',
                                                                   description  => null,
                                                                   start_time   => null,
                                                                   sub_request  => true,
                                                                   argument1    => p_load_id,
                                                                   argument2    => l_counter,
                                                                   argument3    => l_debug_on);

            IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Submitted Sub-request with ID => ' || x_request_ids(l_counter));
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_load_id ',p_load_id);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_counter ',l_counter);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_debug_on',l_debug_on);
            END IF;

            IF (x_request_ids(l_counter) = 0 ) THEN
                x_error_msg := FND_MESSAGE.get;
                x_error_msg := 'Error submitting concurrent request: ' || x_error_msg;
                x_error_msg := substr(x_error_msg, 0, 300);
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name,x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END LOOP;

        IF (x_status <> 2) THEN
            l_conc_request_data := G_VALID_DATE_STRING ||','|| Fnd_Number.Number_To_Canonical(p_number_of_loads) ||','||
                                   p_origin   ||','|| p_origin_name ||','||
                                   l_debug_on ||','|| G_DIRECTION_FLAG ||',' ||
                                   G_REPORT_HEADER.STARTDATE;

            FND_CONC_GLOBAL.SET_REQ_GLOBALS(conc_status  => 'PAUSED',
                                            request_data => l_conc_request_data);

            x_error_msg  := 'SUB-REQUEST SUBMITTED';
            p_retcode := 0;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXCEPTED ERROR',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END LOAD_RATE_CHARTS;

    --__________________________________________________________________________________________--
    --
    -- PROCEDURE: BUILD_ZONES_AND_CHARTS
    --
    -- PURPOSE
    --
    --          Analyze the data in FTE_BULKLOAD_FILE:
    --          a. Identify the destinations sharing the same rate chart and group
    --             them in the same zone. Put this information in FTE_INTERFACE_ZONES.
    --          b. Create a rate chart for each zone. Put this chart information
    --             into the QP_INTERFACE tables and later into the QP tables.
    -- PARAMETERS
    -- IN  p_load_id,
    --     p_tariff_name
    --     p_carrier_ids
    --
    -- OUT
    --      x_origin , x_origin_name
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.
    --__________________________________________________________________________________________--

    PROCEDURE BUILD_ZONES_AND_CHARTS(p_load_id     IN  NUMBER,
                                     p_tariff_name IN  VARCHAR2,
                                     p_carrier_ids IN  NUMBER_TAB,
                                     x_origin      OUT  NOCOPY VARCHAR2,
                                     x_origin_name OUT NOCOPY VARCHAR2,
                                     x_number_of_loads OUT NOCOPY NUMBER,
                                     x_status      OUT NOCOPY NUMBER,
                                     x_error_msg   OUT NOCOPY VARCHAR2) IS

        l_origin               VARCHAR2(15);
        l_origin_high          VARCHAR2(15);
        l_origin_name          VARCHAR2(125);
        l_previous_dest_low    VARCHAR2(10);
        l_previous_dest_high   VARCHAR2(10);
        l_number_of_loads      NUMBER := 1;
        l_number_of_charts     NUMBER;
        l_number_of_zones      NUMBER;
        l_total_string         VARCHAR2(4000);
        l_class_string         VARCHAR2(200);
        l_lanes_temp           LANES_TEMP_RECORD;
        l_process_id           NUMBER;
        l_group_id             NUMBER := 0;
        g_hash_base            NUMBER := 1;
        g_hash_size            NUMBER := power(2, 25);
        l_need_to_fetch        BOOLEAN;
        l_class                VARCHAR2(10);
        l_min_charge1          VARCHAR2(10);
        l_previous_name        VARCHAR2(40);
        l_zone_name            VARCHAR2(125);
        l_rate_name            VARCHAR2(125);
        l_dest_low             VARCHAR2(15);
        l_dest_high            VARCHAR2(15);
        l_dest_names           STRINGARRAY;
        l_rate_names           STRINGARRAY;
        l_min_charges          STRINGARRAY;
        l_hash_value           NUMBER;
        l_min_charge_match     BOOLEAN := FALSE;
        l_rate_chart_match     VARCHAR2(1) := 'N';
        l_counter              NUMBER;
        c_current_fetch        NUMBER;
        c_previous_fetch       NUMBER;
        l_last_block           BOOLEAN;
        l_row_number           NUMBER;
        j                      NUMBER;

        CURSOR GET_LOAD_NUMBER(p_tariff_name  IN  VARCHAR2) IS
        SELECT
          substr(lane_type,instr(lane_type, '_', -1 ) + 1)
        FROM
          fte_lanes
        WHERE
          tariff_name  = p_tariff_name
        ORDER BY creation_date desc;

        --+
        -- Takes care of the number of available origins
        --+
        CURSOR NEW_ORIGIN(p_load_id NUMBER) IS
        SELECT DISTINCT
          origin_low,
          origin_high
        FROM
          fte_bulkload_file
        WHERE
          load_id = p_load_id;

        --+
        -- Queries up an entire block that has to be used for creating the string
        -- Inputs: p_load_id, p_origin_low
        --+
        CURSOR CREATE_STRING(p_load_id NUMBER, p_origin_low VARCHAR2) IS
        SELECT
          lpad(nvl(l5c,0),6,'0')  ||lpad(nvl(m5c,0),6,'0') ||
          lpad(nvl(m1m,0),6,'0')  ||lpad(nvl(m2m,0),6,'0') ||
          lpad(nvl(m5m,0),6,'0')  ||lpad(nvl(m10m,0),6,'0')||
          lpad(nvl(m20m,0),6,'0') ||lpad(nvl(m30m,0),6,'0')||
          lpad(nvl(m40m,0),6,'0'),
          dest_low,
          dest_high,
          class,
          lpad(min_charge1,6,'0')
        FROM
          fte_bulkload_file
        WHERE
          load_id = p_load_id AND
          origin_low = p_origin_low
        ORDER BY dest_low, dest_high, TO_NUMBER(class) desc;

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.BUILD_ZONES_AND_CHARTS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_total_string   := null;
        l_class_string   := null;

        l_last_block     := false;
        l_need_to_fetch  := false;

        --+
        -- Get the load number for the previous load
        -- The LANE_TYPE of FTE_LANES has the format LTL_<p_tariff_name>_numberOfLoad.
        --+
        OPEN GET_LOAD_NUMBER(p_tariff_name);

        FETCH GET_LOAD_NUMBER INTO l_number_of_loads;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_number_of_loads',l_number_of_loads);
        END IF;

        IF (GET_LOAD_NUMBER%FOUND) THEN
            l_number_of_loads := l_number_of_loads + 1;
        END IF;

        CLOSE GET_LOAD_NUMBER;

        --+
        -- This Loop is to make sure that one only one origin or destination is supported
        -- Think about the NEW_ORIGIN % ROWCOUNT
        --+
        OPEN NEW_ORIGIN(p_load_id);
        LOOP
            FETCH NEW_ORIGIN into l_origin, l_origin_high;

            l_number_of_charts := 1;
            l_number_of_zones  := 1;
            l_origin_name      := l_origin || '-' || l_origin_high || '-' || g_orig_country;

            --+
            -- Multiple Origins not supported
            --+
            IF ( NEW_ORIGIN % ROWCOUNT > 1) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_MULTI_ORG_DEST_NO_SUPPORT');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                           p_module_name => l_module_name,
                                           p_category    => 'D',
                                           p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            EXIT WHEN (NEW_ORIGIN%NOTFOUND);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_IN_OUT     ', G_IN_OUT);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_ORIGIN_DEST', G_ORIGIN_DEST);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_origin     ', l_origin);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_origin_high', l_origin_high);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_load_id    ', p_load_id);
            END IF;

            --+
            -- Insert a new origin into FTE_INTERFACE_ZONES
            --+
            BEGIN
                INSERT INTO fte_interface_zones(ZONE_NAME,
                                                POSTAL_CODE_FROM,
                                                POSTAL_CODE_TO,
                                                POSTAL_CODE_STRING,
                                                LOAD_ID,
                                                HASH_VALUE,
                                                ZONE_ID,
                                                ROW_NUMBER)
                                        VALUES (l_origin_name,
                                                l_origin,
                                                l_origin_high,
                                                '',
                                                p_load_id,
                                                0,
                                                null,
                                                1);
            EXCEPTION
                WHEN OTHERS THEN
                    x_status  := 2;
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXCEPTED ERROR while inserting into FTE_INTERFACE_ZONES',sqlerrm);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
            END ;

            l_previous_dest_low  := null;
            l_previous_dest_high := null;
            c_current_fetch  := 0;
            c_previous_fetch := 0;
            l_counter        := 1;

            OPEN  CREATE_STRING(p_load_id, l_origin);
            LOOP
                l_counter := 1;
                FETCH CREATE_STRING BULK COLLECT INTO l_lanes_temp.rate_chart_string,
                                                      l_lanes_temp.dest_low,
                                                      l_lanes_temp.dest_high,
                                                      l_lanes_temp.class,
                                                      l_lanes_temp.min_charge1 LIMIT 1000;

                c_current_fetch := CREATE_STRING % ROWCOUNT - c_previous_fetch;

                EXIT WHEN (c_current_fetch <= 0);

                WHILE(l_counter <= c_current_fetch)
                LOOP
                    --+
                    -- Re-initialize those variables only if we have to build a new string;
                    -- only if dest changes
                    --+
                    IF (not l_need_to_fetch) THEN
                        l_total_string       := '';
                        l_class_string       := '';
                        l_previous_dest_low  := l_lanes_temp.dest_low(l_counter);
                        l_previous_dest_high := l_lanes_temp.dest_high(l_counter);
                        l_dest_low           := l_lanes_temp.dest_low(l_counter);
                        l_dest_high          := l_lanes_temp.dest_high(l_counter);
                        l_min_charge1        := l_lanes_temp.min_charge1(l_counter);  -- it is the same for all of the classes

                        IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_previous_dest_low ', l_previous_dest_low);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_previous_dest_high', l_previous_dest_high);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_dest_low          ', l_dest_low);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_dest_high         ', l_dest_high);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_min_charge1       ', l_min_charge1);
                        END IF;

                    END IF;

                    IF (l_dest_low > l_dest_high) THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_INVALID_ZIP_CODE_RANGE');
                        FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                                     p_module_name => l_module_name,
                                                     p_category    => 'D',
                                                     p_line_number => 0 );
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;

                    --+
                    -- Loop through till the destination remains same and till the last record.
                    --+
                    WHILE (l_counter <= c_current_fetch AND
                           l_lanes_temp.dest_low(l_counter) = l_previous_dest_low AND
                           l_lanes_temp.dest_high(l_counter) = l_previous_dest_high)
                    LOOP
                        l_class := l_lanes_temp.class(l_counter);
                        --
                        -- Check if the Class is already present in the string for same block.
                        --
                        IF (l_class_string IS NOT NULL) THEN
                            IF (instr(l_class_string, ',' || l_class || ',') <> 0) THEN
                                x_status := 2;
                                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_DUPLICATE_FRIEGHT_CLASS');
                                FTE_UTIL_PKG.Write_logFile(l_module_name, l_class_string || '  ' || l_class);
                                FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                                            p_module_name => l_module_name,
                                                            p_category    => 'D',
                                                            p_line_number => 0);
                                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                                RETURN;
                            END IF;
                        END IF;

                        IF (l_class_string IS NULL) THEN
                            l_class_string := ',' || l_class || ',';
                        ELSE
                            l_class_string := l_class_string || l_class || ',';
                        END IF;

                        l_total_string := l_total_string || l_lanes_temp.rate_chart_string(l_counter);
                        l_counter      := l_counter + 1;

                    END LOOP;

                    l_need_to_fetch := l_counter > c_current_fetch;

                    --+
                    -- Only if the last fetched row has a different destination we can insert into some table
                    -- otherwise we have to fetch more rows and append them to
                    --+
                    l_last_block := c_current_fetch < 1000;

                    IF (l_counter <= c_current_fetch OR l_last_block  ) THEN

                        l_hash_value := DBMS_UTILITY.GET_HASH_VALUE(name      => l_total_string,
                                                                    base      => g_hash_base,
                                                                    hash_size => g_hash_size);
                        l_min_charge1 := ltrim(l_min_charge1, '0');

                        IF (l_min_charge1 IS NOT NULL AND length(l_min_charge1) > 0) THEN
                            l_min_charge1 := Fnd_Number.Number_To_Canonical(Fnd_Number.Canonical_To_Number(l_min_charge1)/100);
                        END IF;

                        l_min_charge_match := FALSE;
                        l_rate_chart_match := 'N';

                        --+
                        -- Find a zone in the existing load with the same rate chart
                        -- i.e. Same rate chart string and class string.
                        --+
                        SELECT
                          dest_name,
                          min_charge1,
                          rate_chart_name
                        BULK COLLECT INTO
                          l_dest_names,
                          l_min_charges,
                          l_rate_names
                        FROM
                          fte_interface_lanes
                        WHERE
                          hash_value        = l_hash_value AND
                          rate_chart_string = l_total_string AND
                          class_string      = l_class_string AND
                          origin_name       = l_origin_name AND
                          load_id           = p_load_id;

                        --+
                        -- If we find an existing zone/lane with the same rate chart, we reuse the
                        -- rate chart. However we only reuse the lane if the minimum charge is identical.
                        -- If the minimum charge is not identical, we create a new zone/lane with this
                        -- new minimum charge, but sharing the rate chart.
                        --+
                        IF (l_rate_names.COUNT > 0) THEN

                            l_rate_chart_match := 'Y';

                            -- reuse the rate chart
                            l_rate_name := l_rate_names(1);

                            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                                FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_rate_name' || l_rate_name);
                            END IF;

                            --+
                            -- Search the found lanes/zones with the same minimum charge.
                            --+
                            FOR i IN 1..l_rate_names.COUNT LOOP
                                --+
                                -- If you find an zone/lane with the same min. charge,
                                -- add this information to the existing zone.
                                --+
                                IF (l_min_charges(i) = l_min_charge1) THEN

                                    l_min_charge_match := TRUE;
                                    l_row_number := row_num_max(l_dest_names(i));

                                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_row_number' || l_row_number);
                                    END IF;

                                    INSERT INTO fte_interface_zones(ZONE_NAME,
                                                                    POSTAL_CODE_FROM,
                                                                    POSTAL_CODE_TO,
                                                                    POSTAL_CODE_STRING,
                                                                    LOAD_ID,
                                                                    HASH_VALUE,
                                                                    ZONE_ID,
                                                                    ROW_NUMBER )
                                                             VALUES(l_dest_names(i),
                                                                    l_dest_low,
                                                                    l_dest_high,
                                                                    '',
                                                                    p_load_id,
                                                                    0,
                                                                    null,
                                                                    l_row_number);
                                    EXIT;
                                END IF;  -- if the min_charges also match
                             END LOOP;
                        END IF;  -- if rate chart matched

                        --+
                        -- If there was a rate chart match, but no minimum charge match
                        -- then we reuse the rate chart. In all cases where there was no
                        -- minimum charge match, we create a new zone and lane.
                        --+
                        IF (NOT l_min_charge_match) THEN
                            --+
                            -- If there was no rate chart match, create a new rate chart
                            --+
                            IF (l_rate_chart_match = 'N') THEN

                                l_rate_name  := p_tariff_name || '_' || l_number_of_charts || '_' || l_number_of_loads;

                                CREATE_RATE_CHART(p_chart_name     => l_rate_name,
                                                  p_carrier_ids    => p_carrier_ids,
                                                  p_break_string   => l_total_string,
                                                  p_class_string   => l_class_string,
                                                  x_status         => x_status,
                                                  x_error_msg      => x_error_msg,
                                                  x_process_id     => l_process_id);

                                IF (x_status <> -1) THEN
                                    x_status := 2;
                                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                                    RETURN;
                                END IF;

                                l_group_id := 1 + mod(l_group_id, G_NUM_CONC_PROCESSES);
                                l_number_of_charts := l_number_of_charts + 1;

                            END IF;

                            l_zone_name  := p_load_id || '-' || l_number_of_zones;

                            INSERT INTO fte_interface_lanes(ORIGIN_NAME,
                                                            DEST_NAME,
                                                            RATE_CHART_STRING,
                                                            RATE_CHART_NAME,
                                                            HASH_VALUE,
                                                            CLASS_STRING,
                                                            MIN_CHARGE1,
                                                            LOAD_ID,
                                                            ORIGIN_ID,
                                                            DEST_ID,
                                                            PROCESS_ID,
                                                            GROUP_PROCESS_ID)
                                                     VALUES(l_origin_name,
                                                            l_zone_name,
                                                            l_total_string,
                                                            l_rate_name,
                                                            l_hash_value,
                                                            l_class_string,
                                                            l_min_charge1,
                                                            p_load_id,
                                                            null,
                                                            null,
                                                            l_process_id,
                                                            decode(l_rate_chart_match, 'N', l_group_id, 'Y', NULL));

                            INSERT INTO fte_interface_zones(ZONE_NAME,
                                                            POSTAL_CODE_FROM,
                                                            POSTAL_CODE_TO,
                                                            POSTAL_CODE_STRING,
                                                            LOAD_ID,
                                                            HASH_VALUE,
                                                            ZONE_ID,
                                                            ROW_NUMBER )
                                                    VALUES( l_zone_name,
                                                            l_dest_low,
                                                            l_dest_high,
                                                            '',
                                                            p_load_id,
                                                            0,
                                                            null,
                                                            1);

                            l_number_of_zones := l_number_of_zones + 1;
                        END IF;    --IF (NOT l_min_charge_match)
                     END IF ;   -- IF (l_counter <= c_current_fetch OR l_last_block)
                END LOOP;    -- WHILE (l_counter <= c_current_fetch) LOOP

                c_previous_fetch := CREATE_STRING%ROWCOUNT ;

            END LOOP;

            CLOSE CREATE_STRING;

        END LOOP;

        CLOSE  NEW_ORIGIN;

        IF (G_TOTAL_NUMCHARTS < G_NUM_CONC_PROCESSES) THEN
            G_NUM_CONC_PROCESSES := G_TOTAL_NUMCHARTS;
        END IF;

        --
        -- Call SUBMIT_QP_PROCESS to insert the last set of rate charts into qp_interface tables.
        --
        FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(p_qp_call   => FALSE,
                                                x_status    => x_status,
                                                x_error_msg => x_error_msg);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        ELSE

            x_origin := l_origin;
            x_origin_name := l_origin_name;
            x_number_of_loads := l_number_of_loads;

            --
            -- Need to commit here because we are going to exit this
            -- program, call QP_PROCESS, and come back later.
            --
            COMMIT;

        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN

            IF (GET_LOAD_NUMBER%ISOPEN) THEN
                CLOSE GET_LOAD_NUMBER;
            END IF;

            IF(CREATE_STRING%ISOPEN)THEN
                CLOSE CREATE_STRING;
            END IF;

            IF(NEW_ORIGIN%ISOPEN)THEN
                CLOSE NEW_ORIGIN;
            END IF;

            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END BUILD_ZONES_AND_CHARTS;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: MANAGE_ZONES
    --
    -- PURPOSE
    --       Remove redundant rows from FTE_INTERFACE_ZONES by grouping
    --       all zones sharing the same rate chart into a single row.
    --       Reuse old zones if the new zones are exactly the same.
    --
    -- PARAMETERS
    --  IN
    --    p_load_id, the process_id which identifies self load.
    --    p_tariff_name, the tariff name in question
    -- OUT
    --      x_status, the return status of the procedure,
    --                -1, success
    --                any other non negative value indicates failure.
    --      x_error_msg, the error message indicating the cause and detailing the error occured.
    --___________________________________________________________________________________--

    PROCEDURE MANAGE_ZONES(p_load_id     IN  NUMBER,
                           p_tariff_name IN  VARCHAR2,
                           p_origin_name IN  VARCHAR2,
                           x_status      OUT NOCOPY VARCHAR2,
                           x_error_msg   OUT NOCOPY VARCHAR2) IS

      l_identical_zone    VARCHAR2(40);
      l_zone_id           NUMBER;
      l_matching_zones    STRINGARRAY;
      l_sum_row_number    NUMBER;
      l_max_row_number    NUMBER;
      l_sum_hash_value    NUMBER;
      l_num_zone_matches  NUMBER;
      l_new_zones_info    zone_info_record;
      l_more_rows         BOOLEAN;
      l_counter           NUMBER;
      l_zone_name         VARCHAR2(125);
      l_zones_temp        zones_temp_record;
      l_row_number        NUMBER;
      l_last_block        BOOLEAN;
      l_dest_string       VARCHAR2(4000);
      c_previous_fetch    NUMBER;
      c_current_fetch     NUMBER;
      l_previous_name     VARCHAR2(40);
      l_need_to_fetch     BOOLEAN;
      l_hash_value        NUMBER;
      g_hash_base         NUMBER := 1;
      g_hash_size         NUMBER := power(2, 25);

      l_return_status     VARCHAR2(100);
      l_error_msg         VARCHAR2(100);

    --+
    --  This cursor is used to collect queried rows from FTE_INTERFACE_ZONES. With those rows we want to
    --  check if zones are already present into the system.
    --+
    CURSOR DEFINE_ZONES(p_load_id NUMBER) IS
    SELECT
      zone_name,
      postal_code_from,
      postal_code_to
    FROM
      fte_interface_zones
    WHERE
      load_id = p_load_id
    ORDER BY
      zone_name ASC, row_number ASC ;

    --
    -- Get summary zone information about existing zones in
    -- fte_interface_zones.  This is used to check if a new
    -- zone already exists in the table.
    --
    CURSOR GET_EXISTING_ZONE_INFO(p_load_id      IN    NUMBER,
                                  p_sum_rownum   IN    NUMBER,
                                  p_max_rownum   IN    NUMBER,
                                  p_sum_hash     IN    NUMBER)IS
    SELECT
      zone_name
    FROM
      fte_interface_zones
    WHERE
    load_id <> p_load_id
    HAVING
      SUM(hash_value) = p_sum_hash AND
      SUM(row_number) = p_sum_rownum AND
      MAX(row_number) = p_max_rownum
    GROUP BY zone_name;
    --
    --
    CURSOR GET_NEW_ZONES_INFO(p_load_id   IN   NUMBER)IS
    SELECT
      zone_name,
      SUM(row_number),
      MAX(row_number),
      SUM(hash_value)
    FROM
      fte_interface_zones
    WHERE
      load_id = p_load_id AND
      hash_value <> 0
    GROUP BY
      zone_name;

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.MANAGE_ZONES';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        c_previous_fetch := 0;
        l_previous_name  := null;
        l_zone_name      := null;
        l_need_to_fetch  := FALSE;
        l_row_number     := 1;
        l_more_rows   := false;
        l_dest_string := '';

        OPEN DEFINE_ZONES(p_load_id);
        LOOP
            l_counter := 1;

            FETCH DEFINE_ZONES BULK COLLECT INTO l_zones_temp.zone_name,
                                                 l_zones_temp.dest_low,
                                                 l_zones_temp.dest_high  LIMIT 1000;

            c_current_fetch := DEFINE_ZONES%ROWCOUNT - c_previous_fetch;

            IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'c_current_fetch      ', c_current_fetch);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'DEFINE_ZONES%ROWCOUNT',define_zones%ROWCOUNT);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'c_previous_fetch     ',c_previous_fetch);
            END IF;

            EXIT WHEN (c_current_fetch <= 0);

            WHILE (l_counter <= c_current_fetch) LOOP

                IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_counter      ', l_counter);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'c_current_fetch', c_current_fetch);
                    IF (l_need_to_fetch) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_need_to_fetch','TRUE');
                    ELSE
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_need_to_fetch','FALSE');
                    END IF;
                END IF;

                IF (not l_need_to_fetch) THEN
                    l_dest_string   := '';
                    l_previous_name := l_zones_temp.zone_name(l_counter); -- save zone name
                END IF;

                IF (l_need_to_fetch AND l_previous_name <> l_zones_temp.zone_name(l_counter)) THEN
                    --
                    -- zone name has changed at fetch boundary. We need to update
                    -- the previous zone in fte_interface_zones before building the
                    -- next zone.
                    --
                    l_zone_name := l_previous_name;
                ELSE
                    l_zone_name := l_zones_temp.zone_name(l_counter);
                END IF;

                -- build the postal code string
                WHILE (l_counter <= c_current_fetch and l_zones_temp.zone_name(l_counter) = l_previous_name and
                      (l_dest_string is null or LENGTH(l_dest_string) <= 3600) ) LOOP

                    l_dest_string := l_dest_string ||
                                     l_zones_temp.dest_low(l_counter) ||','||
                                     l_zones_temp.dest_high(l_counter)||';';

                    l_counter := l_counter + 1;

                END LOOP;

                --
                -- If the dest_string is too long we have to start storing in following rows of the same zone.
                --
                l_more_rows := LENGTH(l_dest_string) >= 3600;

                --
                -- I only have to update the ROW and increment the number of rows to compare with
                --
                l_need_to_fetch :=  l_counter > c_current_fetch;

                l_last_block := c_current_fetch < 1000;

                IF (l_counter <= c_current_fetch OR l_last_block) THEN
                    --
                    -- Before insert the string in the zones row we have to check if that string
                    -- is already in the zones_temp, in that case we only have to update lanes_temp with the zone_name
                    --
                    l_hash_value := DBMS_UTILITY.GET_HASH_VALUE(name      => l_dest_string,
                                                                base      => g_hash_base,
                                                                hash_size => g_hash_size );

                    UPDATE
                      FTE_INTERFACE_ZONES
                    SET
                      POSTAL_CODE_STRING = l_dest_string,
                      HASH_VALUE = l_hash_value
                    WHERE
                      ZONE_NAME = l_zone_name AND
                      LOAD_ID   = p_load_id AND
                      ROW_NUMBER = l_row_number;

                    IF (l_more_rows ) THEN
                        l_row_number := l_row_number + 1;
                    ELSE
                        l_row_number := 1;
                    END IF;
                END IF;   -- IF (l_counter <= c_current_fetch OR l_last_block)
            END LOOP;   -- WHILE (l_counter <= c_current_fetch)

            c_previous_fetch := define_zones%ROWCOUNT ;

        END LOOP;

        CLOSE DEFINE_ZONES;

        c_current_fetch := 0;
        c_previous_fetch := 0;

        -- Part 2
        OPEN GET_NEW_ZONES_INFO(p_load_id);
            --
            -- Get summary information about all the new zones, and compare with
            -- summary information about all the existing zones.
            --
        LOOP
        FETCH GET_NEW_ZONES_INFO
            BULK COLLECT INTO l_new_zones_info.zone_name,
                              l_new_zones_info.sum_row_number,
                              l_new_zones_info.max_row_number,
                              l_new_zones_info.sum_hash_value LIMIT 1000;

            IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'GET_NEW_ZONES_INFO%ROWCOUNT',GET_NEW_ZONES_INFO%ROWCOUNT);
            END IF;


            FOR i IN 1..l_new_zones_info.zone_name.COUNT
            LOOP
                l_zone_name      := l_new_zones_info.zone_name(i);
                l_sum_row_number := l_new_zones_info.sum_row_number(i);
                l_max_row_number := l_new_zones_info.max_row_number(i);
                l_sum_hash_value := l_new_zones_info.sum_hash_value(i);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'i',i);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_zone_name      ',l_zone_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_sum_row_number ',l_sum_row_number);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_max_row_number ',l_max_row_number);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_sum_hash_value ',l_sum_hash_value);
                END IF;

                OPEN GET_EXISTING_ZONE_INFO(p_load_id    => p_load_id,
                                            p_sum_rownum => l_sum_row_number,
                                            p_max_rownum => l_max_row_number,
                                            p_sum_hash   => l_sum_hash_value);

                FETCH GET_EXISTING_ZONE_INFO
                BULK COLLECT INTO l_matching_zones;

                l_num_zone_matches := GET_EXISTING_ZONE_INFO%ROWCOUNT;

                CLOSE GET_EXISTING_ZONE_INFO;

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_num_zone_matches', l_num_zone_matches);
                END IF;

                IF (l_num_zone_matches >= 1) THEN
                    --
                    -- We've found a zone whose summary information matches the new zone.
                    -- compare their postal code strings
                    --
                    IF (l_zone_name = p_origin_name) THEN
                        FIND_IDENTICAL_ZONE(p_zone_name      => l_zone_name,
                                            p_matching_zones => l_matching_zones,
                                            p_origin_flag    => TRUE,
                                            x_identical_zone => l_identical_zone,
                                            x_zone_id        => l_zone_id,
                                            x_status         => l_return_status,
                                            x_error_msg      => l_error_msg );
                    ELSE
                        FIND_IDENTICAL_ZONE(p_zone_name      => l_zone_name,
                                            p_matching_zones => l_matching_zones,
                                            p_origin_flag    => FALSE,
                                            x_identical_zone => l_identical_zone,
                                            x_zone_id        => l_zone_id,
                                            x_status         => l_return_status,
                                            x_error_msg      => l_error_msg);
                    END IF;

                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_identical_zone', l_identical_zone);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_zone_name     ', l_zone_name);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_zone_id       ', l_zone_id);
                    END IF;

                    IF (l_identical_zone IS NOT NULL) THEN

                        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Found Matching Zone');
                        END IF;

                        IF (l_zone_id IS NULL) THEN
                            -- Serious Error --
                            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Cannot Find Zone ID!!!');
                            RETURN;
                        END IF;

                        --
                        -- we've found an identical zone!
                        --
                        IF (l_zone_name = p_origin_name) THEN
                            --+
                            -- We need to update origin
                            --+
                            UPDATE
                              fte_interface_lanes
                            SET
                              origin_name = l_identical_zone,
                              origin_id = l_zone_id
                            WHERE
                              load_id  = p_load_id AND
                              origin_name = l_zone_name;
                        ELSE
                            --  We need to update dest
                            UPDATE
                              fte_interface_lanes
                            SET
                              dest_name = l_identical_zone,
                              dest_id = l_zone_id
                            WHERE
                              load_id   = p_load_id AND
                              dest_name  = l_zone_name;

                        END IF;

                        --
                        -- we don't need this current zone
                        --
                        DELETE FROM
                          fte_interface_zones
                        WHERE
                          zone_name = l_zone_name AND
                          load_id = p_load_id;
                    END IF;
                END IF;

            END LOOP;

            EXIT WHEN (GET_NEW_ZONES_INFO%NOTFOUND);

        END LOOP;

        CLOSE GET_NEW_ZONES_INFO;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN

            IF (DEFINE_ZONES%ISOPEN) THEN
                CLOSE DEFINE_ZONES;
            END IF;
            IF (GET_NEW_ZONES_INFO%ISOPEN) THEN
                CLOSE GET_NEW_ZONES_INFO;
            END IF;

            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR',SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END MANAGE_ZONES;


    --_________________________________________________________________________________________--
    --
    -- PROCEDURE: CREATE_ZONES_AND_REGIONS
    --
    -- PURPOSE
    --       Use the WSH API to create the regions and
    --       zones in the WSH tables.
    -- PARAMETERS
    -- IN
    --    p_load_id, the process_id which identifies self load.
    --__________________________________________________________________________________________--

    PROCEDURE CREATE_ZONES_AND_REGIONS (p_load_id     IN  NUMBER,
                                        p_origin_name IN  VARCHAR2,
                                        x_status      OUT NOCOPY VARCHAR2,
                                        x_error_msg   OUT NOCOPY VARCHAR2) IS

        l_zone_id              NUMBER;
        l_region_id            NUMBER;
        l_parent_region_id     NUMBER;
        l_status               NUMBER;
        c_previous_fetch       NUMBER;
        c_current_fetch        NUMBER;
        l_country_code         VARCHAR2(10);
        l_previous_name        VARCHAR2(40);
        l_counter              NUMBER;
        l_zones_temp           zones_temp_record;
        l_zone_name            VARCHAR2(125);

        --+
        --  This cursor is used to collect queried rows from fte_interface_zones. Those are used to
        --  create Zones into WSH_REGIONS, WSH_REGIONS_TL and WSH_ZONE_REGIONS
        --+
        CURSOR BULK_ZONES(p_load_id NUMBER) IS
        SELECT
          zone_name,
          postal_code_from,
          postal_code_to
        FROM
          fte_interface_zones
        WHERE
          load_id = p_load_id AND
          zone_id is null
        ORDER BY
          zone_name,
          row_number asc;

      l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CREATE_ZONES_AND_REGIONS';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_previous_name    := 'NULL';
        l_zone_id          := -1;
        c_previous_fetch   := 0;

        OPEN BULK_ZONES(p_load_id);
        LOOP
            l_counter := 1;

            FETCH BULK_ZONES BULK COLLECT INTO l_zones_temp.zone_name,
                                               l_zones_temp.dest_low,
                                               l_zones_temp.dest_high  LIMIT 1000;

            c_current_fetch := BULK_ZONES%ROWCOUNT - c_previous_fetch;

            IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'c_current_fetch      ', c_current_fetch);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'BULK_ZONES%ROWCOUNT  ', BULK_ZONES%ROWCOUNT);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'c_previous_fetch     ', c_previous_fetch);
            END IF;

            EXIT WHEN (c_current_fetch <= 0);

            WHILE (l_counter <= c_current_fetch) LOOP

                l_zone_name := l_zones_temp.zone_name(l_counter);

                IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_zone_name ', l_zone_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_counter   ', l_counter);
                END IF;

                IF (l_zones_temp.zone_name(l_counter) <> l_previous_name) THEN
                    --+
                    -- Anytime that the ZONE NAME changes we have to create a new ZONE
                    --+
                    WSH_REGIONS_PKG.UPDATE_ZONE(p_insert_type => 'INSERT',
                                                p_zone_id     => '',
                                                p_zone_name   => l_zone_name,
                                                p_zone_level  => 11,
                                                p_zone_type   => 11,
                                                p_lang_code   => userenv('LANG'),
                                                p_user_id     => G_USER_ID,
                                                x_zone_id     => l_zone_id,
                                                x_status      => l_status,
                                                x_error_msg   => x_error_msg);

                    IF (l_status = 2) THEN
                        --+
                        -- It means that the Zone already exists.
                        --+
                        SELECT
                          region_id
                        INTO
                          l_zone_id
                        FROM
                          wsh_regions_tl
                        WHERE
                          zone = l_zone_name;
                    END IF;

                    IF (l_zone_id IS NULL) THEN
                        x_status := 2;
                        x_error_msg := 'Zone ID is NULL';
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Zone ID is NULL after WSH_REGIONS_PKG.Update_Zone ');
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zone_name',l_zone_name);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;

                    BEGIN
                        UPDATE
                          FTE_INTERFACE_ZONES
                        SET
                          ZONE_ID = l_zone_id
                        WHERE
                          zone_name = l_zone_name AND
                          HASH_VALUE <> 0 AND
                          LOAD_ID = p_load_id;

                        IF (l_zone_name = p_origin_name) THEN
                            --
                            -- We need to update origin ID
                            --
                            UPDATE
                              FTE_INTERFACE_LANES
                            SET
                              ORIGIN_ID = l_zone_id
                            WHERE
                              load_id     = p_load_id AND
                              origin_name = l_zone_name;

                            l_country_code := g_orig_country;

                        ELSE
                         -- We need to update dest
                            UPDATE
                              FTE_INTERFACE_LANES
                            SET
                              DEST_ID   = l_zone_id
                            WHERE
                              load_id   = p_load_id AND
                              dest_name = l_zone_name;

                            l_country_code := G_DEST_COUNTRY;
                        END IF;

                    EXCEPTION

               WHEN OTHERS THEN
                           x_status := 2;
                           x_error_msg := sqlerrm;
                           FTE_UTIL_PKG.Write_LogFile(l_module_name,'Premature UNEXPECTED Error', sqlerrm);
                           FTE_UTIL_PKG.Exit_Debug(l_module_name);
                           RETURN;
                    END;

                END IF;

                WSH_REGIONS_PKG.UPDATE_ZONE_REGION(p_insert_type       => 'INSERT',
                                                   p_zone_region_id    => null,
                                                   p_zone_id           => l_zone_id,
                                                   p_region_id         => null,
                                                   p_country           => '',
                                                   p_state             => '',
                                                   p_city              => '',
                                                   p_postal_code_from  => l_zones_temp.dest_low(l_counter),
                                                   p_postal_code_to    => l_zones_temp.dest_high(l_counter),
                                                   p_lang_code         => userenv('LANG'),
                                                   p_country_code      => l_country_code,
                                                   p_state_code        => '',
                                                   p_city_code         => '',
                                                   p_user_id           => G_USER_ID,
                                                   p_zone_type         => '11',
                                                   x_zone_region_id    => l_region_id,
                                                   x_region_id         => l_parent_region_id,
                                                   x_status            => l_status,
                                                   x_error_msg         => x_error_msg);
                l_previous_name := l_zone_name;
                l_counter       := l_counter +1;

                IF (l_status = 1 AND x_error_msg = 'WSH_SAME_REGION_IN_ZONE') THEN
                    --+
                    -- if the region already exists in that zone, then we'll
                    -- get an error, but that's ok.
                    --+
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'WSH_SAME_REGION_IN_ZONE');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => 0);

                -- If it failed for any other reason, we need to exit.
                ELSIF (l_status = 1) THEN
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => x_error_msg);
                    FTE_UTIL_PKG.Write_OutFile(p_msg          => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'D',
                                                p_line_number => 0);

                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zones_temp.dest_low(' || l_counter || ')', l_zones_temp.dest_low(l_counter-1));
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zones_temp.dest_high(' || l_counter || ')', l_zones_temp.dest_high(l_counter-1));
                    END IF;

                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);

                    RETURN;

                END IF;

            END LOOP;

            c_previous_fetch := bulk_zones%ROWCOUNT ;

        END LOOP;

        CLOSE BULK_ZONES;
   EXCEPTION
       WHEN OTHERS THEN

         IF (BULK_ZONES%ISOPEN) THEN
             CLOSE BULK_ZONES;
         END IF;
         x_status := 2;
         x_error_msg := SQLERRM;
         FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                     p_message   => sqlerrm);
         FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CREATE_ZONES_AND_REGIONS;


    --___________________________________________________________________________________--
    --
    -- PROCEDURE: LOAD_TEMP_TABLES
    --
    -- Purpose
    --      Create the lanes, zones and rate charts from the data in FTE_BULKLOAD_FILE.
    --
    --      It calls 4 sub procedures.
    --          i.   BUILD_ZONES_AND_CHARTS
    --          ii.  MANAGE_ZONES
    --          iii. CREATE_ZONES_AND_REGIONS
    --          iv.  CREATE_LANES
    --
    -- IN Parameters
    --    1. p_load_id: The load id for the bulkload job.
    --    2. p_service_code: The service level for this load
    --    3. p_tariff_name: The tariff name
    --    4. p_carrier_ids: a nuber table of carrier ids.
    --
    -- OUT Parameters
    --    1. x_status: return status.
    --                 -1, Success, Failure otherwise.
    --    2. x_error_msg: Error message, if there is an error.
    --
    --___________________________________________________________________________________--

    PROCEDURE LOAD_TEMP_TABLES (p_load_id          IN         NUMBER,
                                p_tariff_name      IN         VARCHAR2,
                                p_carrier_ids      IN         NUMBER_TAB,
                                p_effective_dates  IN         STRINGARRAY,
                                p_expiry_dates     IN         STRINGARRAY,
                                x_status           OUT NOCOPY VARCHAR2,
                                x_error_msg        OUT NOCOPY VARCHAR2) IS

        l_phase             NUMBER := 1;
        l_requests_tab      FND_CONCURRENT.REQUESTS_TAB_TYPE;
        l_var_string        VARCHAR2(200);
        l_scac              VARCHAR2(50);
        l_origin            VARCHAR2(15);
        l_status            VARCHAR2(10);
        l_error_msg         VARCHAR2(1000);
        l_number_of_loads   NUMBER;
        l_origin_name       VARCHAR2(125);
        l_counter           NUMBER;
        l_debug_on          NUMBER;
        t_varchar2_tab      STRINGARRAY;

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.LOAD_TEMP_TABLES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --+
        -- Remember these G_ORIG/DEST_COUNTRY are mantadory fields
        -- in the UI. Now, you should know where these variables had been intialized.
        -- Try PROCESS_LTL_DATA -> LOAD_LTL_DATA.
        --+

        IF (G_DIRECTION_FLAG = 'I') THEN
            G_REF_COUNTRY := G_ORIG_COUNTRY;
        ELSE
            G_REF_COUNTRY := G_DEST_COUNTRY;
        END IF;

        l_phase := GET_PHASE;

        IF(l_phase = 1) THEN

            BUILD_ZONES_AND_CHARTS(p_load_id      =>  p_load_id,
                                   p_tariff_name  =>  p_tariff_name,
                                   p_carrier_ids  =>  p_carrier_ids,
                                   x_origin       =>  l_origin,
                                   x_origin_name  =>  l_origin_name,
                                   x_number_of_loads => l_number_of_loads,
                                   x_status       =>  x_status,
                                   x_error_msg    =>  x_error_msg );

            IF ( x_status <> -1 ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from BUILD_ZONES_AND_CHARTS', x_status);
                RETURN;
            END IF;

            LOAD_RATE_CHARTS(p_load_id      => p_load_id,
                             p_number_of_loads => l_number_of_loads,
                             p_origin       =>  l_origin,
                             p_origin_name  =>  l_origin_name,
                             x_status       =>  l_status,
                             x_error_msg    =>  l_error_msg );

            IF ( x_status <> -1 ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from LOAD_RATE_CHARTS', x_status);
                RETURN;
            END IF;

        ELSE

            --+
            -- Sub-requests have been submitted already.
            -- get the stored variables and parse the string. Dont you belive me.
            -- Please, verify at the end of LOAD_RATE_CHARTS procedure.
            --+

            l_var_string   := FND_CONC_GLOBAL.request_data;
            t_varchar2_tab := FTE_UTIL_PKG.TOKENIZE_STRING(l_var_string, ',');

            G_VALID_DATE          := to_date(t_varchar2_tab(1), 'rrrrmmdd');
            l_number_of_loads     := Fnd_Number.Canonical_To_Number(t_varchar2_tab(2));
            l_origin              := t_varchar2_tab(3);
            l_origin_name         := t_varchar2_tab(4);
            l_debug_on            := t_varchar2_tab(5);
            G_DIRECTION_FLAG      := t_varchar2_tab(6);
            G_REPORT_HEADER.StartDate := t_varchar2_tab(7);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_VALID_DATE     ', G_VALID_DATE);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_number_of_loads', l_number_of_loads);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_origin         ', l_origin);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_origin_name    ', l_origin_name);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_debug_on       ', l_debug_on);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_DIRECTION_FLAG ', G_DIRECTION_FLAG);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_REPORT_HEADER.StartDate', G_REPORT_HEADER.StartDate);
            END IF;

            --+
            -- Get back the status from each child.
            --+
            l_requests_tab := FND_CONCURRENT.GET_SUB_REQUESTS(FND_GLOBAL.CONC_REQUEST_ID);

            l_counter := l_requests_tab.first;

            WHILE (l_counter is not null) LOOP

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'Status of sub-request ' || l_counter, l_requests_tab(l_counter).dev_status);
                END IF;

                IF (l_requests_tab(l_counter).dev_status IN('ERROR','TERMINATED')) THEN
                    x_error_msg := 'QP ERROR ' || substr(l_requests_tab(l_counter).message, 0, 300);
                    x_status := 2;
                    FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                               p_message   => x_error_msg);

                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                l_counter := l_requests_tab.next(l_counter);

            END LOOP;

            GET_PARAMETER_DEFAULTS(x_status    => x_status,
                                   x_error_msg => x_error_msg);

            IF (x_status <> -1) THEN
                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from GET_PARAMETER_DEFAULTS ',x_status);
                END IF;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            MANAGE_ZONES(p_load_id     => p_load_id,
                         p_tariff_name => p_tariff_name,
                         p_origin_name => l_origin_name,
                         x_status      => x_status,
                         x_error_msg   => x_error_msg);

            IF ( x_status <> -1 ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from MANAGE_ZONES', x_status);
                RETURN;
            END IF;

            CREATE_ZONES_AND_REGIONS(p_load_id    => p_load_id,
                                     p_origin_name => l_origin_name,
                                     x_status     => x_status,
                                     x_error_msg  => x_error_msg);

            IF ( x_status <> -1 ) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from CREATE_ZONES_AND_REGIONS', x_status);
                RETURN;
            END IF;

            --+
            -- The rows in FTE_INTERFACE_ZONES with hash value of 0 are no longer needed
            -- because the information has been put into another row.
            --+
            DELETE FROM FTE_INTERFACE_ZONES WHERE hash_value = 0;

            IF (l_number_of_loads = 1 and G_SERVICE_CODE = 'LTL') THEN

                --+
                -- Obsolete pre-10+ loads.
                -- Previous lane type is : <direction_flag>_LTL_<scac>_<origin>_<number_of_loads>
                -- This should only be done only the first time we move from 10 to 10+
                --+
                FOR q IN 1..p_carrier_ids.COUNT LOOP

                    SELECT
                      scac_code
                    INTO
                      l_scac
                    FROM
                      wsh_carriers
                    WHERE
                      carrier_id = p_carrier_ids(q);

                    OBSOLETE_PREVIOUS_LOAD (p_lane_type    => G_DIRECTION_FLAG || '_LTL_' || l_scac || '_' || l_origin || '_%',
                                            p_delete_lanes => FALSE,
                                            x_status       => x_status,
                                            x_error_msg    => x_error_msg);
                END LOOP;

            ELSE

                --+
                -- Since the lane is being replaced by other lanes with the same dates,
                -- we need to delete the current lanes from the system.
                --+
                OBSOLETE_PREVIOUS_LOAD (p_lane_type    => 'LTL_' || p_tariff_name || '_' || (l_number_of_loads-1),
                                        p_delete_lanes => TRUE,
                                        x_status       => x_status,
                                        x_error_msg    => x_error_msg);
            END IF;

            CREATE_LANES(p_load_id         => p_load_id,
                         p_tariff_name     => p_tariff_name,
                         p_carrier_ids     => p_carrier_ids,
                         p_effective_dates => p_effective_dates,
                         p_expiry_dates    => p_expiry_dates,
                         x_status          => l_status,
                         x_error_msg       => l_error_msg);

            --+
            -- Update the dates in fte_tariff_carriers
            --+

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Update FTE_TARIFF_CARRIERS to complete process');
            END IF;

            FORALL n IN 1..p_carrier_ids.COUNT
                UPDATE
                  fte_tariff_carriers
                SET
                  effective_date   = to_date(p_effective_dates(n), G_DATE_FORMAT),
                  expiry_date      = to_date(p_expiry_dates(n), G_DATE_FORMAT),
                  action_code      = 'D',
                  last_updated_by  = G_USER_ID,
                  last_update_date = SYSDATE,
                  last_update_login = G_USER_ID
                WHERE
                  tariff_name = p_tariff_name AND
                  carrier_id  = p_carrier_ids(n);
        END IF;

        IF (x_status = -1) THEN
          COMMIT;
        ELSE
          ROLLBACK;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED EEROR in' ,sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END LOAD_TEMP_TABLES;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: INSERT_LTL_DATA
    --
    -- PURPOSE:
    --   Insert the read data into FTE_BULKLOAD_FILE.
    --
    -- PARAMETERS:
    -- IN
    --   p_load_id, the load id for the current job.
    --
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --___________________________________________________________________________________--

    PROCEDURE INSERT_LTL_DATA (p_load_id   IN  NUMBER,
                               x_status    OUT NOCOPY VARCHAR2,
                               x_error_msg OUT NOCOPY VARCHAR2) IS

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.INSERT_LTL_DATA';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Inserting ' || FL_ORIGIN_LOW.COUNT || ' rows into fte_bulkload_file.');
        END IF;

        FORALL i in 1..FL_ORIGIN_LOW.COUNT
            INSERT INTO FTE_BULKLOAD_FILE ( LOAD_ID,
                                            ORIGIN_LOW,
                                            ORIGIN_HIGH,
                                            DEST_LOW,
                                            DEST_HIGH,
                                            CLASS,
                                            MIN_CHARGE1,
                                            L5C,
                                            M5C,
                                            M1M,
                                            M2M,
                                            M5M,
                                            M10M,
                                            M20M,
                                            M30M,
                                            M40M,
                                            EFFECTIVE_DATE,
                                            OUTBOUND_FLAG,
                                            MILEAGE)
                                    VALUES (P_LOAD_ID,
                                            FL_ORIGIN_LOW(i),
                                            FL_ORIGIN_HIGH(i),
                                            FL_DEST_LOW(i),
                                            FL_DEST_HIGH(i),
                                            FL_CLASS(i),
                                            FL_MIN_CHARGE1(i),
                                            FL_L5C(i),
                                            FL_M5C(i),
                                            FL_M1M(i),
                                            FL_M2M(i),
                                            FL_M5M(i),
                                            FL_M10M(i),
                                            FL_M20M(i),
                                            FL_M30M(i),
                                            FL_M40M(i),
                                            G_VALID_DATE,
                                            FL_OUTBOUND_FLAG(i),
                                            FL_MILEAGE(i));

        FL_ORIGIN_LOW.DELETE;
        FL_ORIGIN_HIGH.DELETE;
        FL_DEST_LOW.DELETE;
        FL_DEST_HIGH.DELETE;
        FL_CLASS.DELETE;
        FL_MIN_CHARGE1.DELETE;
        FL_L5C.DELETE;
        FL_M5C.DELETE;
        FL_M1M.DELETE;
        FL_M2M.DELETE;
        FL_M5M.DELETE;
        FL_M10M.DELETE;
        FL_M20M.DELETE;
        FL_M30M.DELETE;
        FL_M40M.DELETE;
        FL_OUTBOUND_FLAG.DELETE;
        FL_MILEAGE.DELETE;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END INSERT_LTL_DATA;


    --______________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_LTL_LINE
    --
    -- PURPOSE
    --   Populate the global arrays of form 'FL_%' with the appropriate
    --   values passed in 'p_ltl_line'
    --
    -- PARAMETERS
    -- IN
    --    p_ltl_line, A line of data from the LOB object.
    --    p_load_id, The load id of the bulkload job.
    --
    -- OUT
    --    x_status, the return status of the procedure,
    --              -1, success
    --              any other non negative value indicates failure.
    --    x_error_msg, the error message indicating the cause and detailing the error occured.
    --______________________________________________________________________________________--

    PROCEDURE PROCESS_LTL_LINE (p_load_id   IN  VARCHAR2,
                                p_ltl_line  IN  VARCHAR2,
                                x_status    OUT NOCOPY VARCHAR2,
                                x_error_msg OUT NOCOPY VARCHAR2) IS

        l_num            NUMBER;
        l_table          STRINGARRAY;

        l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_LTL_LINE';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF ( p_ltl_line IS NULL OR p_ltl_line = '' ) THEN
            x_status := 2;
            x_error_msg := 'Returning from PROCESS_LTL_LINE as p_ltl_line';
            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
               FTE_UTIL_PKG.Write_LogFile(l_module_name,x_error_msg, p_ltl_line);
            END IF;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        l_table := FTE_UTIL_PKG.TOKENIZE_STRING(p_ltl_line, ',');

        IF (l_table.COUNT <> G_NUM_COLUMNS) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_INVALID_FILE_FORMAT');
            FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => G_PROCESSED_LINES);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        --+
        -- LTL FileFormat for reference:
        -- ORIGIN_LOW(1), ORIGIN_HIGH(2), DEST_LOW(3), DEST_HIGH(4),
        -- FREIGHT_CLASS(5), MINIMUM_CHARGE(6), L5C(7), M5C(8), M1M(9), M2M(10), M5M(11), M10M(12), M20M(13), M30M(14), M40M(15),
        -- VALID_DATE(16), DIRECTION(17), MILEAGE(18)
        --+

        --+
        -- Initialize variables if this is the first line
        --+
        IF (G_PROCESSED_LINES = 0) THEN
            G_VALID_DATE        := to_date(l_table(16), 'rrrrmmdd');
            G_VALID_DATE_STRING := l_table(16);
            G_DIRECTION_FLAG    := upper(l_table(17));
        END IF;

        l_num := FL_ORIGIN_LOW.count + 1;

        IF (UPPER(G_DIRECTION_FLAG) = 'O') THEN
            --+
            -- OUTBOUND
            -- Origin is the same for all rows. Destination is processed into zones.
            --+
            G_ORIGIN_DEST := 'destinations';
            G_IN_OUT      := 'OUTBOUND';

            FL_ORIGIN_LOW(l_num)  := l_table(1);
            FL_ORIGIN_HIGH(l_num) := l_table(2);
            FL_DEST_LOW(l_num)    := l_table(3);
            FL_DEST_HIGH(l_num)   := l_table(4);

        ELSIF (UPPER(G_DIRECTION_FLAG) = 'I') THEN
            --+
            -- INBOUND
            -- Destination is the same for all rows.
            -- For the purpose of processing,
            -- we will switch the origin and destination and treat is an inbound problem.
            --+
            G_ORIGIN_DEST := 'origins';
            G_IN_OUT      := 'INBOUND';

            FL_DEST_LOW(l_num)    := l_table(1);
            FL_DEST_HIGH(l_num)   := l_table(2);
            FL_ORIGIN_LOW(l_num)  := l_table(3);
            FL_ORIGIN_HIGH(l_num) := l_table(4);

        ELSE
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_INVALID_DIRECTION_FLAG');
            FTE_UTIL_PKG.Write_OutFile(p_msg          => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'D',
                                       p_line_number => G_PROCESSED_LINES);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FL_CLASS(l_num)         := l_table(5);
        FL_MIN_CHARGE1(l_num)   := l_table(6);
        FL_L5C(l_num)           := l_table(7);
        FL_M5C(l_num)           := l_table(8);
        FL_M1M(l_num)           := l_table(9);
        FL_M2M(l_num)           := l_table(10);
        FL_M5M(l_num)           := l_table(11);
        FL_M10M(l_num)          := l_table(12);
        FL_M20M(l_num)          := l_table(13);
        FL_M30M(l_num)          := l_table(14);
        FL_M40M(l_num)          := l_table(15);
        FL_OUTBOUND_FLAG(l_num) := l_table(17);
        FL_MILEAGE(l_num)       := l_table(18);

        IF (FL_ORIGIN_LOW.COUNT = G_BULK_INSERT_LIMIT) THEN

            INSERT_LTL_DATA(p_load_id   => p_load_id,
                            x_status    => x_status,
                            x_error_msg => x_error_msg);

            IF (x_status <> -1) THEN

               IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                   FTE_UTIL_PKG.Write_LogFile(l_module_name, 'INSERT_LTL_DATA returned with ERROR');
                   FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return status ', x_status);
               END IF;
               FTE_UTIL_PKG.Exit_Debug(l_module_name);
               RETURN;

            END IF;

        END IF;

        G_PROCESSED_LINES := G_PROCESSED_LINES + 1;

         FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN SUBSCRIPT_BEYOND_COUNT THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_WRONG_FILE_FORMAT');
            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'D',
                                       p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN VALUE_ERROR THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR');
            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'D',
                                       p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;

    END PROCESS_LTL_LINE;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: READ_LTL_FILE_FROM_TABLE
    --
    -- PURPOSE
    --   Read the LTL data file from the table FTE_BULKLOAD_DATA and insert the
    --   contents in FTE_BULKLOAD_FILE.
    --
    -- PARAMETERS
    -- IN
    --    1. p_file_name: The filename of the data file.
    --    2. p_load_id:   The load id of the bulkload job.
    --
    -- OUT
    --    1. x_status:     2 ==> Error during file reading process.
    --                    -1 ==> Completed successfully.
    --___________________________________________________________________________________--

    PROCEDURE READ_LTL_FILE_FROM_TABLE (p_file_name    IN  VARCHAR2,
                                        p_load_id      IN  VARCHAR2,
                                        x_status       OUT NOCOPY NUMBER,
                                        x_error_msg    OUT NOCOPY VARCHAR2) IS

    l_carriage_return     VARCHAR2(1) := Fnd_Global.Local_Chr(13);
    l_linefeed            VARCHAR2(1) := Fnd_Global.Local_Chr(10);
    l_size                NUMBER;
    l_content             BLOB;
    l_amount              BINARY_INTEGER := 12000;
    l_position            INTEGER := 1;
    data_buffer           VARCHAR2(32000);
    temp_buffer           VARCHAR2(32000);
    l_lines               STRINGARRAY;

    l_module_name        CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.READ_LTL_FILE_FROM_TABLE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'File name', p_file_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Load Id', p_load_id);
        END IF;

        SELECT
          content
        INTO
          l_content
        FROM
          fte_bulkload_data
        WHERE
          file_name = p_file_name and
          load_id = p_load_id;

        l_size := dbms_lob.getlength(l_content);
        data_buffer := NULL;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'File size', l_size);
        END IF;

        WHILE l_size > 0 LOOP

            -- read a big chunk at a time:
            dbms_lob.read (l_content, l_amount, l_position, temp_buffer);
            data_buffer := data_buffer || utl_raw.cast_to_varchar2(temp_buffer);
            data_buffer := replace(data_buffer, l_carriage_return, ''); -- dos2unix conversion

            -- Now tokenize by linefeed
            l_lines := FTE_UTIL_PKG.TOKENIZE_STRING(data_buffer, l_linefeed);

            FOR k IN 1..l_lines.COUNT-1 LOOP

                PROCESS_LTL_LINE (p_load_id    => p_load_id,
                                  p_ltl_line   => l_lines(k),
                                  x_error_msg  => x_error_msg,
                                  x_status     => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            END LOOP;

            l_position := l_position + l_amount;
            l_size := l_size - l_amount;
            --+
            -- Append the last remaining to the next chunk because it might not be complete
            --+
            data_buffer := l_lines(l_lines.COUNT);
        END LOOP;

        IF (data_buffer IS NOT NULL) THEN

            PROCESS_LTL_LINE(p_load_id    => p_load_id,
                             p_ltl_line   => data_buffer,
                             x_error_msg  => x_error_msg,
                             x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                return;
            END IF;

        END IF;

        --+
        -- Insert the last set of lines
        --+
        INSERT_LTL_DATA(p_load_id   => p_load_id,
                        x_status    => x_status,
                        x_error_msg => x_error_msg);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Finished Reading File.');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Number of lines processed ', g_processed_lines);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Unexpected error while reading file: [Row ' || g_processed_lines || '].'
                                       || fnd_global.newline || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END READ_LTL_FILE_FROM_TABLE;


    --___________________________________________________________________________________--
    --
    -- PROCEDURE: READ_LTL_FILE_FROM_DIR
    --
    -- Purpose:
    --   Read the LTL data file and insert the contents in FTE_BULKLOAD_FILE.
    --
    -- IN Parameters
    --    1. p_file_name: The filename of the data file.
    --    2. p_load_id:   The load id of the bulkload job.
    --
    -- OUT Parameters:
    --    1. x_status:     0 ==> File not found
    --                     2 ==> Error during file reading process.
    --                    -1 ==> Completed successfully.
    --____________________________________________________________________________________--

    PROCEDURE READ_LTL_FILE_FROM_DIR (p_file_name    IN  VARCHAR2,
                                      p_load_id      IN  VARCHAR2,
                                      x_error_msg    OUT NOCOPY VARCHAR2,
                                      x_status       OUT NOCOPY NUMBER) IS

    l_chart_file          UTL_FILE.file_type;
    l_src_file_dir        VARCHAR2(500);
    l_carriage_return     VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(13);
    l_line                VARCHAR2(1000);
    isFileEmpty           VARCHAR2(1) := 'Y';

    l_module_name         CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.READ_LTL_FILE_FROM_DIR';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_src_file_dir := FTE_BULKLOAD_PKG.GET_UPLOAD_DIR;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_src_file_dir     ',l_src_file_dir);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_file_name        ',p_file_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_BULK_INSERT_LIMIT', G_BULK_INSERT_LIMIT);
        END IF;

        l_chart_file := UTL_FILE.FOPEN(l_src_file_dir, p_file_name, 'R');

        LOOP
            UTL_FILE.GET_LINE(l_chart_file, l_line);

            l_line := replace(l_line, l_carriage_return, ''); -- dos2unix conversion

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_line', l_line);
            END IF;

            PROCESS_LTL_LINE(p_load_id    => p_load_id,
                             p_ltl_line   => l_line,
                             x_error_msg  => x_error_msg,
                             x_status     => x_status);

            isFileEmpty := 'N';

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'PROCESS_LTL_LINE returned with ERROR ' || l_line , sqlerrm);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            UTL_FILE.FCLOSE(l_chart_file);
            IF(isFileEmpty = 'N') THEN
                --
                -- Insert the last set of lines
                --
                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Inserting last set of lines :-)');
                END IF;

                INSERT_LTL_DATA(p_load_id   => p_load_id,
                                x_status    => x_status,
                                x_error_msg => x_error_msg);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Finished Reading File.');
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Number of lines processed: ' || g_processed_lines);
                END IF;
                x_status := -1;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);

            ELSIF(isFileEmpty = 'Y') THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_WRONG_FILE_FORMAT');
                FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'E',
                                            p_line_number =>  0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
            END IF;

        WHEN UTL_FILE.INVALID_PATH THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_INVALID_PATH');
            FTE_UTIL_PKG.Write_OutFile(  p_msg         => x_error_msg,
                                         p_module_name => l_module_name,
                                         p_category    => 'E',
                                         p_line_number =>  0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN UTL_FILE.INVALID_OPERATION THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_INVALID_FILE_OPERATION');
            FTE_UTIL_PKG.Write_OutFile(  p_msg         => x_error_msg,
                                         p_module_name => l_module_name,
                                         p_category    => 'E',
                                         p_line_number =>  0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR while reading file: [Row ' || g_processed_lines || '].'
                                        || fnd_global.newline || l_line || fnd_global.newline || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END READ_LTL_FILE_FROM_DIR;

    --___________________________________________________________________________________--
    --
    -- PROCEDURE: UPDATE_TARIFF_LANES
    --
    -- PURPOSE
    --    Associates a carrier to a tariff by creating new lanes for that carrier
    --    OR updates the dates on lanes for an existing carrier.
    --
    -- PARAMETERS
    -- IN
    --    1. p_tariff_name:
    --    2. p_load_id: The load id of the bulkload job.
    --
    -- OUT
    --    1. x_error_msg: A buffer of error messages.
    --    2. p_retcode: The return code. A return code of '2' specifies ERROR.
    --___________________________________________________________________________________--

    PROCEDURE UPDATE_TARIFF_LANES(p_tariff_name IN  VARCHAR2,
                                  p_load_id     IN  NUMBER,
                                  x_abort       OUT NOCOPY BOOLEAN,
                                  x_status      OUT NOCOPY NUMBER,
                                  x_error_msg   OUT NOCOPY VARCHAR2) IS

        CURSOR GET_TARIFF_LANES(p_load_number  IN  NUMBER, p_carrier_id   IN  NUMBER) IS
        SELECT
          l.lane_id,
          l.origin_id,
          l.destination_id,
          lrc.list_header_id,
          lrc.start_date_active,
          prc.value_from
        FROM
          fte_lanes l,
          fte_lane_rate_charts lrc,
          fte_prc_parameters prc
        WHERE
          l.tariff_name = p_tariff_name AND
          l.LANE_ID = lrc.LANE_ID AND
          prc.LANE_ID = l.LANE_ID AND
          prc.LANE_ID = lrc.LANE_ID AND
          prc.PARAMETER_ID = g_min_charge_id AND
          mode_of_transportation_code = 'LTL' AND
          l.lane_type = 'LTL_' || p_tariff_name || '_' || p_load_number AND
          l.carrier_id = p_carrier_id;

        CURSOR GET_LANE_COMMODITIES (p_lane_id  IN  NUMBER) IS
        SELECT
          commodity_catg_id
        FROM
          fte_lane_commodities
        WHERE
          lane_id = p_lane_id;

        CURSOR GET_PREVIOUS_REGIONS_INFO (p_tariff_name  IN  VARCHAR2,
                                          p_lane_type    IN  VARCHAR2) IS
        SELECT
          DECODE (COUNT(DISTINCT origin_id), 1, 'O', 'I') direction,
          MAX(ozr.postal_code_from) origin_low,
          MAX(dzr.postal_code_from) destination_low
        FROM
          fte_lanes l,
          wsh_zone_regions ozr,
          wsh_zone_regions dzr
        WHERE
          l.lane_type = p_lane_type AND
          l.tariff_name = p_tariff_name AND
          ozr.parent_region_id = l.origin_id AND
          dzr.parent_region_id = l.destination_id;

        l_load_number       NUMBER;
        l_lane_ids          NUMBER_TAB;
        l_origin_ids        NUMBER_Tab;
        l_destination_ids   NUMBER_TAB;
        l_catg_ids          NUMBER_TAB;
        l_min_charges       NUMBER_TAB;
        l_list_header_ids   NUMBER_TAB;
        l_existing_carrier  NUMBER;
        l_scac              VARCHAR2(30);
        l_origin            VARCHAR2(10);
        l_origin_low        VARCHAR2(10);
        l_dest_low          VARCHAR2(10);
        l_rc_start_dates    STRINGARRAY;

        -- New carriers being added
        l_add_carriers      NUMBER_TAB;
        l_add_start_dates   STRINGARRAY;
        l_add_end_dates     STRINGARRAY;

        -- Carriers being modified
        l_modified_carriers NUMBER_TAB;
        l_mod_start_dates   STRINGARRAY;
        l_mod_end_dates     STRINGARRAY;
        l_current_fetch     NUMBER;
        l_fetch_total       NUMBER;

        l_module_name        CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.UPDATE_TARIFF_LANES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;
        x_abort := FALSE;

        -- SECTION: Create New Lanes
        -- Get the carriers that need new lanes created.
        OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                              p_action_code => 'N');

        FETCH GET_TARIFF_CARRIERS
        BULK COLLECT INTO  l_add_carriers,
                           l_add_start_dates,
                           l_add_end_dates;
        CLOSE GET_TARIFF_CARRIERS;

        IF (l_add_carriers.COUNT <= 0) THEN

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'No new carriers to add');
            END IF;

            OPEN GET_LOAD_NUMBER(p_tariff_name => p_tariff_name);

            FETCH GET_LOAD_NUMBER INTO l_load_number;

            IF (GET_LOAD_NUMBER%NOTFOUND) THEN
                x_error_msg := 'Error updating LTL rates. Load Number does not exist.';
                FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                            p_message   => x_error_msg);

                x_status := 2;
                CLOSE GET_LOAD_NUMBER;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            CLOSE GET_LOAD_NUMBER;
        ELSE
            -- Validate the service level for each carrier.
            FOR i IN 1..l_add_carriers.COUNT LOOP
                G_SERVICE_CODE := FTE_VALIDATION_PKG.Validate_Service_Level(p_carrier_id    => l_add_carriers(i),
                                                                            p_carrier_name  => NULL,
                                                                            p_service_level => G_SERVICE_CODE,
                                                                            p_line_number   => 0,
                                                                            x_error_msg     => x_error_msg,
                                                                            x_status        => x_status);
                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END LOOP;

            --+
            -- Get information from a previous LTL load for this tariff
            --+
            OPEN GET_PREVIOUS_LOAD_INFO(p_tariff_name => p_tariff_name);
            FETCH GET_PREVIOUS_LOAD_INFO INTO l_load_number,
                                              G_SERVICE_CODE,
                                              g_orig_country,
                                              g_dest_country,
                                              l_existing_carrier;

            IF (GET_PREVIOUS_LOAD_INFO%NOTFOUND) THEN
                x_error_msg := 'Error updating LTL rates. Previous load does not exist.';
                FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                            p_message   => x_error_msg);

                x_status := 2;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                CLOSE GET_PREVIOUS_LOAD_INFO;
                RETURN;
            END IF;

            CLOSE GET_PREVIOUS_LOAD_INFO;

            IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Service Code            ', G_SERVICE_CODE);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Origin Country Code     ', g_orig_country);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Destination Country Code', g_dest_country);
            END IF;

            Get_Parameter_Defaults(x_status => x_status,
                                   x_error_msg => x_error_msg);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Get a representative set of lane data from the existing
            -- carrier.  The new lanes created will be duplicates of this
            -- set of lanes.
            --+
            OPEN Get_Tariff_Lanes (p_load_number => l_load_number,
                                   p_carrier_id  => l_existing_carrier);
            LOOP
                l_fetch_total := Get_Tariff_lanes%ROWCOUNT ;

                FETCH GET_TARIFF_LANES
                BULK COLLECT INTO l_lane_ids,
                                  l_origin_ids,
                                  l_destination_ids,
                                  l_list_header_ids,
                                  l_rc_start_dates,
                                  l_min_charges LIMIT 1000;

                l_current_fetch := Get_Tariff_Lanes%ROWCOUNT - l_fetch_total;

                EXIT WHEN (l_current_fetch <= 0);

                IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating ' || l_lane_ids.COUNT || ' new lanes for carriers');
                END IF;

                IF (l_rc_start_dates.COUNT > 0) THEN
                    g_valid_date := l_rc_start_dates(1);
                END IF;

                FOR k IN 1..l_lane_ids.COUNT LOOP
                    OPEN Get_Lane_Commodities (p_lane_id => l_lane_ids(k));
                    FETCH Get_Lane_Commodities
                    BULK COLLECT INTO l_catg_ids;
                    CLOSE Get_Lane_Commodities;

                    -- the dates passed into here should be from fte_lane_rate_charts --nii
                    Create_Lane_Data (p_origin_id        => l_origin_ids(k),
                                      p_destination_id   => l_destination_ids(k),
                                      p_carrier_ids      => l_add_carriers,
                                      p_effective_dates  => l_add_start_dates,
                                      p_expiry_dates     => l_add_end_dates,
                                      p_tariff_name      => p_tariff_name,
                                      p_lane_type        => 'LTL_' || p_tariff_name || '_' || l_load_number,
                                      p_category_ids     => l_catg_ids,
                                      p_list_header_id   => l_list_header_ids(k),
                                      p_min_charge       => l_min_charges(k),
                                      x_status           => x_status,
                                      x_error_msg        => x_error_msg);

                    IF x_status <> -1 THEN
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END LOOP;
            END LOOP;
            CLOSE GET_TARIFF_LANES;


            -- Update the dates in fte_tariff_carriers
            FORALL p IN 1..l_add_carriers.COUNT
                UPDATE
                  fte_tariff_carriers
                SET
                  effective_date   = l_add_start_dates(p),
                  expiry_date      = l_add_end_dates(p),
                  action_code      = 'D',
                  last_updated_by  = G_USER_ID,
                  last_update_date = SYSDATE,
                  last_update_login = G_USER_ID
                WHERE
                  tariff_name      = p_tariff_name AND
                  action_code      = 'N' AND
                  carrier_id       = l_add_carriers(p);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Calling Add_Carriers_To_RateCharts');
            END IF;

            ADD_CARRIERS_TO_RATECHARTS(p_tariff_name => p_tariff_name,
                                       p_load_number => l_load_number,
                                       p_carrier_ids => l_add_carriers,
                                       p_load_id     => p_load_id,
                                       x_error_msg   => x_error_msg,
                                       x_status      => x_status);

            IF x_status <> -1 THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                return;
            END IF;

        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Bulk Insert Lane Data');
        END IF;

        Bulk_Insert_Lanes;
        Bulk_Insert_Lane_Rate_Charts;
        Bulk_Insert_Lane_Parameters;
        Bulk_Insert_Lane_Commodities;

        -- Obsolete pre-10+ lanes for these carriers
        IF (G_SERVICE_CODE = 'LTL') THEN
            FOR q IN 1..l_add_carriers.COUNT LOOP
                SELECT scac_code INTO l_scac
                FROM wsh_carriers
                WHERE carrier_id = l_add_carriers(q);

                OPEN Get_Previous_Regions_Info (p_tariff_name => p_tariff_name,
                                                p_lane_type => 'LTL_' || p_tariff_name || '_' || l_load_number);

                FETCH Get_Previous_Regions_Info
                INTO g_direction_flag,
                     l_origin_low,
                     l_dest_low;

                CLOSE Get_Previous_Regions_Info;

                IF (g_direction_flag = 'I') THEN
                    l_origin := l_dest_low;
                ELSE
                    l_origin := l_origin_low;
                END IF;

                OBSOLETE_PREVIOUS_LOAD (p_lane_type => g_direction_flag||'_LTL_'||l_scac||'_'||l_origin||'_%',
                                        p_delete_lanes => FALSE,
                                        x_status  => x_status,
                                        x_error_msg => x_error_msg);
            END LOOP;
        END IF;

        --+
        -- Update
        -- Get the carriers that have been modified
        --+
        OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                                 p_action_code => 'M');

        FETCH GET_TARIFF_CARRIERS
        BULK COLLECT INTO l_modified_carriers,
                          l_mod_start_dates,
                          l_mod_end_dates;

        CLOSE GET_TARIFF_CARRIERS;

        IF (l_modified_carriers.COUNT <= 0) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'No carriers to modify');
        ELSE
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Updating Tariff Lanes for ' || l_modified_carriers.COUNT || ' existing carrier(s)');
        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on)THEN
            FOR lt IN 1..l_modified_carriers.COUNT loop
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'carrier    ' || lt , l_modified_carriers(lt));
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'start date ' || lt , l_mod_start_dates(lt));
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'end date   ' || lt , l_mod_end_dates(lt));
            END LOOP;
        END IF;

        IF l_modified_carriers.COUNT > 0 THEN
            FORALL n IN 1..l_modified_carriers.COUNT
                UPDATE
                  fte_lanes
                SET
                  effective_date = l_mod_start_dates(n),
                  expiry_date    = l_mod_end_dates(n),
                  last_updated_by  = G_USER_ID,
                  last_update_date = SYSDATE,
                  last_update_login = G_USER_ID
                WHERE
                  tariff_name = p_tariff_name AND
                  lane_type = 'LTL_' || p_tariff_name || '_' || l_load_number AND
                  carrier_id = l_modified_carriers(n);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Update Tariff Carriers Table');
            END IF;

            --+
            -- Update the dates in fte_tariff_carriers
            --+
            FORALL n IN 1..l_modified_carriers.COUNT
                UPDATE
                  fte_tariff_carriers
                SET
                  effective_date   = l_mod_start_dates(n),
                  expiry_date      = l_mod_end_dates(n),
                  action_code      = 'D',
                  last_updated_by  = G_USER_ID,
                  last_update_date = SYSDATE,
                  last_update_login = G_USER_ID
                WHERE
                  tariff_name      = p_tariff_name AND
                  action_code      = 'M' AND
                  carrier_id       = l_modified_carriers(n);

            -- FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Update Lane Rate Charts');
            -- update fte_lane_rate_charts:
            -- FORALL n IN 1..l_modified_carriers.COUNT
            --  UPDATE fte_lane_rate_charts
            --  SET    start_date_active = l_mod_start_dates(n),
            --         end_date_active  = l_mod_end_dates(n),
            --         last_update_date = sysdate
            --  WHERE  lane_id IN
            --         (select lane_id from fte_lanes
            --         where lane_type = 'LTL_' || p_tariff_name || '_' || l_load_number
            --         and   carrier_id = l_modified_carriers(n)
            --         and   tariff_name = p_tariff_name);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN

            IF (GET_PREVIOUS_LOAD_INFO%ISOPEN) THEN
                CLOSE GET_PREVIOUS_LOAD_INFO;
            END IF;

            x_status := 2;
            x_error_msg := SQLERRM;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR' || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END UPDATE_TARIFF_LANES;

    --______________________________________________________________________________________--
    --
    -- PROCEDURE: UPLOAD_LTL_RATES
    --
    -- PURPOSE  Starts the rate chart and lane loading process.
    --
    -- PARAMETERS
    -- IN
    --    1. p_file_name   The file name
    --    2. p_load_id     The load ID for this load.
    --    3. p_tariff_name tariff_name
    --    4. x_phase       the current phase, to see what is a phase please refer to get_phase function.
    --    5. x_abort
    --
    -- OUT
    --    1. x_status  Completion status. Success ==> -1, Failure otherwise.
    --    2. x_error_msg  Error message, if there is an error.
    --______________________________________________________________________________________--

    PROCEDURE UPLOAD_LTL_RATES(p_file_name   IN  VARCHAR2,
                               p_load_id     IN  VARCHAR2,
                               p_tariff_name IN  VARCHAR2,
                               p_action_code IN  VARCHAR2,
                               x_phase       OUT NOCOPY NUMBER,
                               x_abort       OUT NOCOPY BOOLEAN,
                               x_status      OUT NOCOPY NUMBER,
                               x_error_msg   OUT NOCOPY VARCHAR2) IS

    l_source             VARCHAR2(30);
    l_load_number        NUMBER;
    l_carrier_ids        Number_Tab;
    l_effective_dates    STRINGARRAY;
    l_expiry_dates       STRINGARRAY;

    l_module_name        CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.UPLOAD_LTL_RATES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        --+
        --  Identify the phase we are in.
        --  Phase 1: rate charts and zones are prepared in the interface tables.
        --  Phase 2: lanes are created and linked to the rate charts.
        --+
        x_phase  := GET_PHASE;
        x_abort  := FALSE;
        x_status := -1;

        FND_PROFILE.GET('FTE_BULKLOAD_SOURCE_TYPE', l_source);

        IF( FTE_BULKLOAD_PKG.g_debug_on ) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Phase        ' || x_phase);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Reading from ' || l_source);
        END IF;

        IF (x_phase = 1) THEN
            IF (upper(l_source) = 'SERVER') THEN
                READ_LTL_FILE_FROM_DIR(p_file_name  => p_file_name,
                                       p_load_id    => p_load_id,
                                       x_error_msg  => x_error_msg,
                                       x_status     => x_status);
            ELSE
                READ_LTL_FILE_FROM_TABLE(p_file_name => p_file_name,
                                         p_load_id   => p_load_id,
                                         x_error_msg => x_error_msg,
                                         x_status    => x_status);
            END IF;
        END IF;

        IF (x_status = -1) THEN

            IF (p_action_code = 'ADD') THEN

                OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                                         p_action_code => 'N');
            ELSIF (p_action_code = 'UPDATE') THEN

                OPEN GET_TARIFF_CARRIERS(p_tariff_name => p_tariff_name,
                                         p_action_code => 'M');
            END IF;

            FETCH GET_TARIFF_CARRIERS
            BULK COLLECT INTO l_carrier_ids, l_effective_dates, l_expiry_dates;
            CLOSE GET_TARIFF_CARRIERS;

            IF (l_carrier_ids.COUNT <= 0) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CARRIERS_NOT_FOUND');
                FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'C',
                                            p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            ELSE
                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Fetched ' || l_carrier_ids.COUNT || ' carrier(s) to ' || p_action_code);
                END IF;
            END IF;

            LOAD_TEMP_TABLES(p_load_id         => p_load_id,
                             p_tariff_name     => p_tariff_name,
                             p_carrier_ids     => l_carrier_ids,
                             p_effective_dates => l_effective_dates,
                             p_expiry_dates    => l_expiry_dates,
                             x_status          => x_status,
                             x_error_msg       => x_error_msg);

            IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Returned from LOAD_TEMP_TABLES with status ', x_status);
            END IF;
        ELSE
            -- Error while reading file.
            x_status    := 2;
            x_error_msg := 'LTL Loading Failed While Reading File. ' || x_error_msg || '. Please check logs for details.';
            x_abort     := TRUE;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR ', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RAISE;

    END UPLOAD_LTL_RATES;

    --____________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_LTL_DATA
    --
    -- PURPOSE
    --        This has been registered as the executable for the CP 'FTE_LTL_BULK_LOADER'.
    --        Runs the entire LTL Bulkloading process. When PROCESS_LTL_DATA submits the requests
    --        here the execution begins!
    --
    -- PARAMETERS
    -- IN
    --    p_load_id       The load id of the bulkload job.
    --    p_src_filename  The filename of the file containing the LTL data.
    --    p_currency      The operating currency. (DEFAULT: USD);
    --    p_uom_code      The unit of measurement of LTL packages.
    --    p_orig_country  The Origin Country code
    --    p_dest_country  The Destination Country code
    --    p_service_code  service level
    --    p_action_code   The action to be taken, ADD/UPDATE/UPDATE_ASSOC
    --
    -- OUT
    --    p_errbuf: A buffer of error messages.
    --    p_retcode: The return code. A return code of '2' specifies ERROR.
    --____________________________________________________________________________________--

    PROCEDURE PROCESS_LTL_DATA(errbuf          OUT NOCOPY  VARCHAR2,
                               retcode         OUT NOCOPY  VARCHAR2,
                               p_load_id       IN  NUMBER,
                               p_src_filename  IN  VARCHAR2,
                               p_currency      IN  VARCHAR2,
                               p_uom_code      IN  VARCHAR2,
                               p_orig_country  IN  VARCHAR2,
                               p_dest_country  IN  VARCHAR2,
                               p_service_code  IN  VARCHAR2,
                               p_action_code   IN  VARCHAR2,
                               p_tariff_name   IN  VARCHAR2,
                               p_user_debug    IN  NUMBER) IS

    l_phase             NUMBER := 2;
    x_status            NUMBER;
    l_load_number       NUMBER;
    l_existing_carrier  NUMBER;
    l_abort             BOOLEAN := false;
    l_return_status     NUMBER;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.LOAD_LTL_DATA';

    BEGIN
        --+
        -- Start the WSH debugger
        --+
        FTE_UTIL_PKG.Init_Debug(p_user_debug);

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        G_ACTION        := p_action_code;
        G_LTL_UOM       := p_uom_code;
        G_LTL_CURRENCY  := p_currency;
        G_ORIG_COUNTRY  := p_orig_country;
        G_DEST_COUNTRY  := p_dest_country;
        G_SERVICE_CODE  := p_service_code;

        g_report_header.StartDate := to_char(sysdate, 'Dy MM/DD/YYYY HH24:MI:SS');

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_action_code ', p_action_code);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_service_code', p_service_code);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_tariff_name ', p_tariff_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_uom_code    ', p_uom_code);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_orig_country', p_orig_country);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_dest_country', p_dest_country);
        END IF;

        IF (p_action_code IS NULL OR length(p_action_code) = 0) THEN
            x_status := 2;
            errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_ACTION');
            FTE_UTIL_PKG.Write_OutFile(  p_msg         => errbuf,
                                         p_module_name => l_module_name,
                                         p_category    => 'B',
                                         p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;

        ELSIF (p_tariff_name IS NULL OR length(p_tariff_name) = 0) THEN
            x_status := 2;
            errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LTL_TARIFF_NAME_MISSING');
            FTE_UTIL_PKG.Write_OutFile(  p_msg         => errbuf,
                                         p_module_name => l_module_name,
                                         p_category    => 'B',
                                         p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;

        ELSIF ((p_src_filename IS NULL OR length(p_src_filename) = 0) AND
                p_action_code IN ('ADD', 'UPDATE')) THEN
            x_status := 2;
            errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_FILE_NAME_MISSING');
            FTE_UTIL_PKG.Write_OutFile(  p_msg         => errbuf,
                                         p_module_name => l_module_name,
                                         p_category    => 'B',
                                         p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;

        ELSIF(p_action_code = 'ADD') THEN

            IF (p_service_code IS NULL OR length(p_service_code) = 0) THEN
                x_status := 2;
                errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_SERVICE_LEVEL_MISSING');
                FTE_UTIL_PKG.Write_OutFile(  p_msg         => errbuf,
                                             p_module_name => l_module_name,
                                             p_category    => 'B',
                                             p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            ELSIF (p_orig_country IS NULL OR length(p_orig_country) = 0) THEN
                x_status := 2;
                errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_ORIGIN');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => errbuf,
                                           p_module_name => l_module_name,
                                           p_category    => 'B',
                                           p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            ELSIF (p_dest_country IS NULL OR length(p_dest_country) = 0) THEN
                x_status := 2;
                errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_DESTINATION');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => errbuf,
                                           p_module_name => l_module_name,
                                           p_category    => 'B',
                                           p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        --+
        -- Gather information from the previous LTL load
        -- Get the load number of the target set of lanes.
        --+
        IF (p_action_code = 'UPDATE') THEN

            OPEN GET_PREVIOUS_LOAD_INFO (p_tariff_name => p_tariff_name);

            FETCH GET_PREVIOUS_LOAD_INFO
            INTO l_load_number,
                 G_SERVICE_CODE,
                 g_orig_country,
                 g_dest_country,
                 l_existing_carrier;

            IF (GET_PREVIOUS_LOAD_INFO%NOTFOUND) THEN
                x_status := 2;
                errbuf := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_DESTINATION');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => errbuf,
                                           p_module_name => l_module_name,
                                           p_category    => 'C',
                                           p_line_number => 0);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);

                IF(GET_PREVIOUS_LOAD_INFO%ISOPEN) THEN
                    CLOSE GET_PREVIOUS_LOAD_INFO;
                END IF;
                RETURN;
            END IF;

            IF(GET_PREVIOUS_LOAD_INFO%ISOPEN) THEN
                CLOSE GET_PREVIOUS_LOAD_INFO;
            END IF;
        END IF;

        UPDATE
          fte_tariff_carriers
        SET
          new_expiry_date = to_date(to_char(to_date(to_char(new_expiry_date, G_DATE), G_DATE_FORMAT)+1-1/24/60/60, G_DATE_FORMAT), G_DATE_FORMAT),
          last_updated_by  = G_USER_ID,
          last_update_date = SYSDATE,
          last_update_login = G_USER_ID
        WHERE
          tariff_name = p_tariff_name;

        IF (p_action_code IN ('ADD', 'UPDATE')) THEN

            UPLOAD_LTL_RATES(p_file_name   => p_src_filename,
                             p_load_id     => p_load_id,
                             p_tariff_name => p_tariff_name,
                             p_action_code => p_action_code,
                             x_phase       => l_phase,
                             x_abort       => l_abort,
                             x_status      => x_status,
                             x_error_msg   => errbuf);

        ELSIF (p_action_code = 'UPDATE_ASSOC') THEN

            UPDATE_TARIFF_LANES(p_tariff_name => p_tariff_name,
                                p_load_id     => p_load_id,
                                x_abort       => l_abort,
                                x_status      => x_status,
                                x_error_msg   => errbuf);
            l_phase := 2;

        END IF;

        --+
        -- Clean up the tables if we failed, or after the whole process is complete.
        --+
        IF (l_phase = 2 OR x_status <> -1) THEN

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Finished ' || p_action_code || ' with status ' || x_status);
            END IF;

            CLEANUP_TABLES(p_load_id     => p_load_id,
                           p_abort       => l_abort,
                           p_tariff_name => p_tariff_name,
                           p_action_code => p_action_code,
                           p_save_data   => p_user_debug,
                           x_status      => l_return_status,
                           x_error_msg   => errbuf);

        END IF;

        IF(x_status = -1) THEN
            --+
            -- Concurrent Manager expects 0 for success.
            --+

            retcode := 0;
            errbuf  := 'Completed phase ' || l_phase || ' successfully!' || errbuf;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, errbuf);
            END IF;

            COMMIT;

            --+
            -- Generate a report of all created lanes and rate charts if completed successfully
            --+
            IF (l_phase = 2) THEN
                g_report_header.FileName     := p_src_filename;
                g_report_header.TariffName   := p_tariff_name;
                g_report_header.ServiceLevel := G_SERVICE_CODE;
                g_report_header.Orig_Country := g_orig_country;
                g_report_header.Dest_Country := g_dest_country;
                g_report_header.Currency     := p_currency;
                g_report_header.UOM          := p_uom_code;

                IF (p_action_code = 'UPDATE') THEN
                    l_load_number := l_load_number + 1;
                END IF;

                GENERATE_LTL_REPORT(p_load_id     => p_load_id,
                                    p_load_number => l_load_number,
                                    p_tariff_name => p_tariff_name,
                                    x_error_msg   => errbuf,
                                    x_status      => x_status);

                --+
                -- If there is an error or exception during the printing
                -- of the report, it should only be reported as a warning.
                -- It should not cause the program to error out.
                --+
                IF (errbuf IS NOT NULL) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, errbuf);
                END IF;

            END IF;

        ELSE
            retcode := 2;
            errbuf  := 'Completed with errors. ' || errbuf || '. Please check logs for more details.';
            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, errbuf);
            END IF;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            CLEANUP_TABLES( p_load_id     => p_load_id,
                            p_abort       => TRUE,
                            p_tariff_name => p_tariff_name,
                            p_action_code => p_action_code,
                            p_save_data   => p_user_debug,
                            x_error_msg   => errbuf,
                            x_status      => x_status);
            COMMIT;

            FTE_UTIL_PKG.Write_LogFile(p_module_name => l_module_name,
                                       p_message     => sqlerrm);

            retcode := 2;
            errbuf  := errbuf || sqlerrm;
    END PROCESS_LTL_DATA;

    --______________________________________________________________________________________--
    --
    -- PROCEDURE: QP_PROCESS
    --
    -- Purpose
    --   Use the QP api to load a given group of rate charts.
    --
    -- IN Parameters
    --    1. p_load_id: the load id of the bulkload job.
    --    2. p_group_process_id: This specifies the group of rate charts to load.
    --                           The process ids of this group of rate charts are
    --                           obtained from the table FTE_INTERFACE_LANES.
    --
    -- Out Parameters
    --    1. errbuf: A buffer of error messages.
    --    2. retcode: The return code. A return code of '1' specifies ERROR.
    --______________________________________________________________________________________--

    PROCEDURE QP_PROCESS (ERRBUF            OUT NOCOPY VARCHAR2,
                          RETCODE           OUT NOCOPY VARCHAR2,
                          p_load_id           IN  NUMBER,
                          p_group_process_id  IN  NUMBER,
                          p_user_debug        IN  NUMBER) IS

    l_process_id    NUMBER;
    x_status        NUMBER := -1;
    x_error_msg     VARCHAR2(8000);
    l_temp          BOOLEAN;
    l_name          VARCHAR2(200);
    l_currency_tbl  FTE_RATE_CHART_PKG.LH_CURRENCY_CODE_TAB;
    l_name_tbl      FTE_RATE_CHART_PKG.LH_NAME_TAB;

    CURSOR GET_PROCESS_ID IS
    SELECT
      l.process_id, qh.name
    FROM
      fte_interface_lanes l, qp_interface_list_headers qh
    WHERE
      l.load_id = p_load_id AND
      l.group_process_id = p_group_process_id AND
      l.process_id = qh.process_id;

    l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.QP_PROCESS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);

        IF (p_user_debug = 1) THEN
            FTE_BULKLOAD_PKG.g_debug_on := TRUE;
        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'QP SUB PROCESS FOR Load ID, p_load_id', p_load_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_group_process_id        ', p_group_process_id);
        END IF;

        OPEN GET_PROCESS_ID;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Number of Rate Charts is ' || get_process_id%ROWCOUNT);
        END IF;

        LOOP
            FETCH get_process_id INTO l_process_id, l_name_tbl(1);
            EXIT WHEN get_process_id%NOTFOUND;

            IF (x_status <> -1) THEN

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'QP ERROR ' || x_error_msg);
                END IF;

                l_temp:= FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
                errbuf := x_error_msg;
                retcode := '1';

                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            END IF;

            FTE_RATE_CHART_PKG.QP_API_CALL(p_chart_type => 'LTL_RATE_CHART',
                                           p_process_id => l_process_id,
                                           p_name       => l_name_tbl,
                                           p_currency   => l_currency_tbl,
                                           x_status     => x_status,
                                           x_error_msg  => x_error_msg);

        END LOOP;

        CLOSE GET_PROCESS_ID;

        IF (x_status = -1) THEN
            l_temp:= Fnd_Concurrent.Set_Completion_Status('NORMAL','');
            retcode := 0;
        ELSE
            errbuf := x_error_msg;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,Fte_Util_Pkg.Get_Msg(p_name => 'FTE_LOADER_CATEGORY_O'),x_error_msg);
            l_temp:= Fnd_Concurrent.Set_Completion_Status('ERROR','');
            retcode := 2;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        COMMIT;

    EXCEPTION

        WHEN OTHERS THEN
            errbuf := sqlcode || ', ' || sqlerrm;
            retcode := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Unexpected Error While Calling QP API', errbuf);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END QP_PROCESS;

END FTE_LTL_LOADER;

/
