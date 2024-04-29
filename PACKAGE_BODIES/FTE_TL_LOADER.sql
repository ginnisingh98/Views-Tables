--------------------------------------------------------
--  DDL for Package Body FTE_TL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TL_LOADER" AS
/* $Header: FTETLLRB.pls 120.13 2006/04/28 04:51:12 pkaliyam noship $ */
    --================================================================================--
    --
    --  NAME: FTE_TL_LOADER ("TL" stands for TruckLoad)
    --
    --
    --  PURPOSE : BulkLoading of TL Services, TL Base Rates, TL Surchages and
    --            Facility charges.
    --
    --  PROCEDURES:  PROCESS_DATA                Entry point in the package
    --               PROCESS_TL_SERVICES         To process TL Services
    --               PROCESS_FACILITY_CHARGES    To process Facility Charges
    --               PROCESS_TL_BASE_RATES       To process TL Rate Charts
    --               PROCESS_TL_SURCHARGES       To process TL Accessorial Charges
    --
    -- CHANGE CONTROL LOG
    --
    -- DATE        VERSION  BY        BUG      DESCRIPTION
    -- ----------  -------  --------  -------  ------------
    -- Prabhakhar                              CREATED.
    --=================================================================================--


    -------------------------  GLOBAL Variables  Start -----------------------------------

    G_CURDATE               DATE := sysdate;
    G_MAX_NUMBER            NUMBER := 9999999;
    G_ACTION                VARCHAR2(30);

    G_LANE_TBL              FTE_LANE_PKG.lane_tbl;
    G_LANE_RATE_CHART_TBL   FTE_LANE_PKG.lane_rate_chart_tbl;
    G_LANE_SERVICE_TBL      FTE_LANE_PKG.lane_service_tbl;
    G_LANE_COMMODITY_TBL    FTE_LANE_PKG.LANE_COMMODITY_TBL;

    G_DUMMY_BLOCK_HDR_TBL   FTE_BULKLOAD_PKG.block_header_tbl;

    G_PKG_NAME         CONSTANT  VARCHAR2(50) := 'FTE_TL_LOADER';

    -------------------------  GLOBAL Variables  END -----------------------------------

    --_________________________________________________________________________________--
    --
    -- FUNCTION:  GET_GLOBAL_UNIT_UOM
    --
    -- PURPOSE  Get the global unit uom from wsh_global_parameters table.
    --
    -- PARAMETERS
    -- IN
    --   NO PARAMETERS.
    --
    -- RETURNS,  GLOBAL_UNIT_UOM defined in Shipping parameters form, if setup.
    --           NULL  otherwise.
    --_________________________________________________________________________________--

    FUNCTION GET_GLOBAL_UNIT_UOM (x_status     OUT NOCOPY NUMBER,
                                  x_error_msg  OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

        l_unit_uom        VARCHAR2(10);
        l_params          WSH_SHIPPING_PARAMS_PVT.GLOBAL_PARAMETERS_REC_TYP;
        l_return_status   VARCHAR2(30);

        l_module_name     CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_GLOBAL_UNIT_UOM';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        WSH_SHIPPING_PARAMS_PVT.GET_GLOBAL_PARAMETERS(l_params, l_return_status);

        IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING )) THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'CALL TO WSH_SHIPPING_PARAMS_PVT.GET_GLOBAL_PARAMETERS RETURNED WITH STATUS', l_return_status);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN NULL;
        END IF;

        l_unit_uom := l_params.UOM_FOR_NUM_OF_UNITS;

        IF (l_unit_uom IS NULL) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.Get_Msg(p_name => 'FTE_GLOBAL_UNIT_UOM_NOT_DEFINE');

            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'B',
                                       p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN NULL;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

        RETURN l_unit_uom;

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR in GET_GLOBAL_UNIT_UOM', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END GET_GLOBAL_UNIT_UOM;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:  GET_CARRIER_PREFERENCES
    --
    -- PURPOSE:   In Frieght Carriers form, we might have set the Carrier Preferences.
    --            It queries up the preferences that have set in that
    --            form for the carrier, p_carrier_name.
    --
    -- PARAMETERS:
    --
    --  IN
    --    p_carrier_name,  the carrier name for which the preferences to be retrieved.
    --    p_service_level, the service level of the carrier we are looking for.
    --    p_line_number,   line number in the upload file, used for logging.
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --________________________________________________________________________________

    PROCEDURE GET_CARRIER_PREFERENCES ( p_carrier_name   IN      VARCHAR2,
                                        p_service_level  IN      VARCHAR2,
                                        p_line_number    IN      NUMBER,
                                        x_status         OUT NOCOPY  NUMBER,
                                        x_error_msg      OUT NOCOPY  VARCHAR2) IS

        l_volume_uom             VARCHAR2(3);
        l_weight_uom             VARCHAR2(3);

        l_mode_of_trans CONSTANT VARCHAR2(25)  := 'TRUCK';

        l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_CARRIER_PREFERENCES';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Getting Carrier Preferences for ' || p_carrier_name);
        END IF;

        -- Unit rate basis for WEIGHT/VOLUME/CONTAINER/PALLET
        IF (g_carrier_name <> p_carrier_name OR
            g_service_level <> p_service_level OR
            g_carrier_id IS NULL OR
            g_carrier_unit_basis IS NULL OR
            g_carrier_unit_basis_uom IS NULL) THEN

            BEGIN
                SELECT
                  ca.carrier_id,
                  ca.currency_code,
                  nvl(cs.unit_rate_basis, ca.unit_rate_basis) unit_rate_basis,
                  ca.time_uom,
                  ca.distance_uom,
                  ca.weight_uom,
                  ca.volume_uom
                INTO
                  g_carrier_id,
                  g_carrier_currency,
                  g_carrier_unit_basis,
                  g_carrier_time_uom,
                  g_carrier_distance_uom,
                  l_weight_uom,
                  l_volume_uom
                FROM
                  WSH_CARRIER_SERVICES cs,
                  WSH_CARRIERS ca,
                  HZ_PARTIES hz
                WHERE
                  cs.carrier_id(+) = ca.carrier_id AND
                  cs.service_level(+) = p_service_level AND
                  cs.mode_of_transport = l_mode_of_trans AND
                  hz.party_name = p_carrier_name AND
                  hz.party_id = ca.carrier_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_SEL_INVALID_CARRIER',
                                                        p_tokens => STRINGARRAY('NAME'),
                                                        p_values => STRINGARRAY(p_carrier_name));

                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                 WHEN OTHERS THEN
                    x_status := 2;
                    x_error_msg := sqlerrm;
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR occured ' || sqlerrm );
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
            END;

            --+
            -- Get the carrier's prefered rate basis uom.
            --+
            IF (g_carrier_unit_basis IS NULL) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CARRIER_RATE_BASIS_NOT_SET',
                                                    p_tokens => STRINGARRAY('CARRIER'),
                                                    p_values => STRINGARRAY(p_carrier_name));
                FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'B',
                                            p_line_number => p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            ELSIF (g_carrier_unit_basis = 'WEIGHT') THEN

                g_carrier_unit_basis_uom := l_weight_uom;

            ELSIF (g_carrier_unit_basis = 'VOLUME') THEN

                g_carrier_unit_basis_uom := l_volume_uom;

            ELSIF (g_carrier_unit_basis IN ('CONTAINER', 'PALLET')) THEN

                g_carrier_unit_basis_uom := g_unit_uom;

            END IF;

            g_carrier_name  := p_carrier_name;
            g_service_level := p_service_level;

        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_carrier_name  ', g_carrier_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_service_level ', g_service_level);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_carrier_id    ', g_carrier_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_rate_basis    ', g_carrier_unit_basis);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_rate_basis_uom',g_carrier_unit_basis_uom);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_currency_code ',g_carrier_currency);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION WHEN OTHERS THEN

        x_status := 2;
        x_error_msg := sqlerrm;
        FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END GET_CARRIER_PREFERENCES;

    --_________________________________________________________________________________--
    --
    -- FUNCTION: CHECK_RATE_BASIS
    --
    -- PURPOSE  Checks a rate basis and uom against a carrier's prefered rate bases.
    --
    -- PARAMETERS
    -- IN
    --    1. p_carrier_name
    --    2. p_rate_basis
    --    3. p_rate_basis_uom
    --    4. p_service_level
    --    5. p_line_number
    -- OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error meassge,
    --                 if any exception occurs during the process.
    --
    --_________________________________________________________________________________--

    PROCEDURE CHECK_RATE_BASIS( p_carrier_name     IN  VARCHAR2,
                                p_rate_basis       IN  VARCHAR2,
                                p_rate_basis_uom   IN  VARCHAR2,
                                p_service_level    IN  VARCHAR2,
                                p_line_number      IN  NUMBER,
                                x_status           OUT NOCOPY  VARCHAR2,
                                x_error_msg        OUT NOCOPY  VARCHAR2) IS

    l_basis_type      VARCHAR2(10);
    l_prefered_basis  VARCHAR2(50);
    l_prefered_uom    VARCHAR2(50);

    l_module_name     CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CHECK_RATE_BASIS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;
        l_basis_type := p_rate_basis;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_carrier_name ',p_carrier_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_rate_basis   ',p_rate_basis);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_rate_basis_uom',p_rate_basis_uom);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_service_level',p_service_level);
        END IF;

        GET_CARRIER_PREFERENCES (p_carrier_name   => p_carrier_name,
                                 p_service_level  => p_service_level,
                                 p_line_number    => p_line_number,
                                 x_status         => x_status,
                                 x_error_msg      => x_error_msg);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'GET_CARRIER_PREFERENCES returned with error');
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF (p_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,       -- Container
                             FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET,     -- Pallet
                             FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT,         -- Weight
                             FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL)) THEN  -- Volume

            l_basis_type := 'UNIT';

            IF (p_rate_basis <> g_carrier_unit_basis) THEN

                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_RATE_BASIS_NO_MATCH',
                                                    p_tokens => STRINGARRAY('RATE_BASIS','CARRIER'),
                                                    p_values => STRINGARRAY(p_rate_basis,p_carrier_name));
                FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'D',
                                            p_line_number => p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;

            ELSIF (p_rate_basis_uom <> g_carrier_unit_basis_uom) THEN
                x_status := 3;
            END IF;

        ELSIF (p_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME AND
               p_rate_basis_uom <> g_carrier_time_uom) THEN

            x_status := 3;

        ELSIF (p_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST AND
               p_rate_basis_uom <> g_carrier_distance_uom) THEN

            x_status := 3;

        END IF;

        --+
        -- The rate basis uom did not match that of the carrier
        --+
        IF (x_status = 3) THEN
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_RATE_BASIS_UOM_NO_MATCH',
                                                p_tokens => STRINGARRAY('RATE_BASIS_UOM','CARRIER'),
                                                p_values => STRINGARRAY(p_rate_basis_uom,p_carrier_name));
            FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            x_status := 2;

        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_error_msg := sqlerrm;
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN CHECK_RATE_BASIS ' || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CHECK_RATE_BASIS;

    --____________________________________________________________________________--
    --
    -- PROCEDURE:  CHECK_DUPLICATE_RATE_CHART
    --
    -- PURPOSE    To ensure that the rate chart is qualified to be
    --            loaded.  Validate the qualifiers, rate basis and uoms.
    --
    -- PARAMETERS
    -- IN
    --  p_chart_name,    The Rate Chart Name
    --  p_chart_type,    The Rate Chart Type
    --  p_carrier_name,  Carrier name
    --  p_service_level, Service level of the carrier
    --  p_line_number,   Line Number in the upload file, used for error reporting.
    --
    -- OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error meassge,
    --                 if any exception occurs during the process.
    --______________________________________________________________________________--

    PROCEDURE CHECK_DUPLICATE_RATE_CHART( p_chart_name     IN      VARCHAR2,
                                          p_chart_type     IN      VARCHAR2,
                                          p_carrier_name   IN      VARCHAR2,
                                          p_service_level  IN      VARCHAR2,
                                          p_line_number    IN      NUMBER,
                                          x_error_msg  OUT NOCOPY  VARCHAR2,
                                          x_status     OUT NOCOPY  NUMBER ) IS

    l_rc_names  VARCHAR100_TAB;
    l_rc_types  VARCHAR100_TAB;

    CURSOR GET_TL_CHARTS IS
    SELECT
      lh.name, b.attribute1
    FROM
      qp_list_headers_tl lh,
      qp_list_headers_b b,
      qp_qualifiers qc,
      qp_qualifiers qs,
      qp_qualifiers qm
    WHERE
      lh.list_header_id       = b.list_header_id AND
      qc.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE1' AND
      qc.qualifier_context    = 'PARTY' AND
      qc.qualifier_attr_value = Fnd_Number.Number_To_Canonical(g_carrier_id) AND
      qc.list_header_id       = lh.list_header_id AND
      qs.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE10' AND
      qs.qualifier_context    = 'LOGISTICS' AND
      qs.qualifier_attr_value = p_service_level AND
      qs.list_header_id       = qc.list_header_id AND
      qm.qualifier_attribute  = 'QUALIFIER_ATTRIBUTE7' AND
      qm.qualifier_context    = 'LOGISTICS' AND
      qm.qualifier_attr_value = 'TRUCK' AND
      qm.list_header_id       = qc.list_header_id AND
      lh.language             = userenv('LANG');

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CHECK_DUPLICATE_RATE_CHART';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --
        -- Ensure that there is no rate chart with the same qualifier set
        -- already loaded (CARRIER, SERVICE_LEVEL, MODE_OF_TRANSPORT)
        --

        IF (p_chart_type IN ('TL_MODIFIER')) THEN

            GET_CARRIER_PREFERENCES(p_carrier_name   => p_carrier_name,
                                    p_service_level  => p_service_level,
                                    p_line_number    => p_line_number,
                                    x_error_msg      => x_error_msg,
                                    x_status         => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'GET_CARRIER_PREFERENCES returned with error' || x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            OPEN  GET_TL_CHARTS;
            FETCH GET_TL_CHARTS BULK COLLECT INTO l_rc_names, l_rc_types;
            CLOSE GET_TL_CHARTS;

            FOR i IN 1..l_rc_types.COUNT LOOP
                IF (l_rc_types(i) = p_chart_type) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DUPLICATE_CHART');
                    FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'C',
                                                p_line_number => p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END LOOP;

        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR in CHECK_DUPLICATE_RATE_CHART ', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CHECK_DUPLICATE_RATE_CHART;

    --______________________________________________________________________________________--
    --                                                                                      --
    -- FUNCTION: GET_CHART_DATA                                                             --
    --                                                                                      --
    -- PURPOSE  Store summary information about each rate chart in the current load.        --
    --                                                                                      --
    -- PARAMETERS                                                                           --
    -- IN                                                                                   --
    --     p_chart_name:    The rate chart name                                             --
    --     p_carrier_name:  The carrier name                                                --
    --     p_currency:      The Currency of the rate chart                                  --
    --     p_chart_type:    The Chart type                                                  --
    --     p_line_number:   The line number in the upload file.                             --
    --                                                                                      --
    -- IN OUT                                                                    --
    --    x_service_level: The service level                                                --
    --                                                                                      --
    -- OUT                                                                      --
    --    x_cur_line,  The current line number of rate chart.                               --
    --    x_job_id,    The process ID of this job.                                          --
    --    x_status,    The return status, -1 for success                                    --
    --                                   2 for failure.                                     --
    --    x_error_msg, The corresponding error meassge,                                     --
    --                 if any exception occurs during the process.                          --
    --______________________________________________________________________________________--

    PROCEDURE GET_CHART_DATA( p_chart_name    IN  VARCHAR2,
                              p_currency      IN  VARCHAR2,
                              p_chart_type    IN  VARCHAR2,
                              x_carrier_name  IN  OUT NOCOPY VARCHAR2,
                              x_service_level IN  OUT NOCOPY VARCHAR2,
                              x_cur_line      OUT NOCOPY NUMBER,
                              x_job_id        OUT NOCOPY NUMBER,
                              p_line_number   IN NUMBER,
                              x_error_msg     OUT NOCOPY VARCHAR2,
                              x_status        OUT NOCOPY NUMBER) IS

    chart_exists    BOOLEAN := FALSE;

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_CHART_DATA';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_chart_name',p_chart_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_currency  ',p_currency);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_chart_type', p_chart_type);
        END IF;

        FOR i IN 1.. Chart_Names.COUNT LOOP

            IF (p_chart_name = Chart_Names(i)) THEN
                x_cur_line := Chart_LineNums(i);
                x_job_id := Chart_Process_Ids(i);
                x_carrier_name := Chart_Carriers(i);
                IF (x_service_level IS NULL) THEN
                    x_service_level := chart_service_levels(i);
                ELSIF (x_service_level <> chart_service_levels(i)) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_SERVICE_LEVELS_NOT_SAME');
                    FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'D',
                                                p_line_number => p_line_number);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
                chart_exists := true;
                EXIT;
            END IF;

        END LOOP;

        IF (NOT chart_exists) THEN

            x_cur_line := 0;
            Chart_Names(Chart_Names.COUNT + 1)        := p_chart_name;
            Chart_LineNums(Chart_LineNums.COUNT + 1)  := x_cur_line;
            Chart_Carriers(Chart_Carriers.COUNT + 1)  := x_carrier_name;
            Chart_Service_Levels(Chart_Service_Levels.COUNT + 1) := x_service_level;
            Chart_Currencies(Chart_Currencies.COUNT + 1) := p_currency;

            IF (p_chart_type IS NOT NULL) THEN
                Chart_Types(Chart_Types.COUNT + 1) := p_chart_type;
            ELSE
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Programmer Error: Chart_Type NOT SPECIFIED');
                x_status := 2;
            END IF;

            x_job_id := FTE_BULKLOAD_PKG.GET_PROCESS_ID;
            Chart_Process_Ids(Chart_Process_Ids.COUNT + 1) := x_job_id;

            --+
            -- validate the rate chart to ensure that it can be loaded.
            --+
            IF (G_ACTION = 'ADD') THEN

                CHECK_DUPLICATE_RATE_CHART(p_chart_name    => p_chart_name,
                                           p_chart_type    => p_chart_type,
                                           p_carrier_name  => x_carrier_name,
                                           p_service_level => x_service_level,
                                           p_line_number   => p_line_number,
                                           x_error_msg     => x_error_msg,
                                           x_status        => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END GET_CHART_DATA;

    --_________________________________________________________________________________--
    --
    -- FUNCTION: IS_LANE_LOADED
    --
    -- Purpose   Returns true if the rate chart <p_chart_name> has an associated
    --           lane that has already been loaded.  If that is true, the lane
    --           needs to be updated with the rate chart id.
    --
    -- PARAMETERS
    -- IN
    --   p_chart_name   VARCHAR2 : The rate chart name
    --   p_carrier_name VARCHAR2 : The carrier name of the rate chart.
    --
    -- OUT
    --   x_carrier_id   NUMBER     : The carrier ID of the rate chart.
    --   x_lane_ids     NUMBER_TAB : A list of all the lanes associated with
    --                               this rate chart.
    -- RETURN:
    --  true , If the lane_type is of the form hold_<p_chart_name>
    --  false, otherwise.
    --_________________________________________________________________________________--

    FUNCTION IS_LANE_LOADED( p_chart_name      IN      VARCHAR2,
                             p_carrier_name    IN      VARCHAR2,
                             p_service_level   IN      VARCHAR2,
                             p_line_number     IN      NUMBER,
                             x_lane_ids    OUT NOCOPY  NUMBER_TAB,
                             x_error_msg   OUT NOCOPY  VARCHAR2,
                             x_status      OUT NOCOPY  VARCHAR2)
    RETURN BOOLEAN IS

    l_lane_loaded      BOOLEAN := true;
    l_name             VARCHAR2(50);
    l_lane_numbers     STRINGARRAY;
    l_lane_services    STRINGARRAY;
    l_carrier_ids      NUMBER_TAB;

    l_num_of_lanes     NUMBER;

    CURSOR GET_LANES(p_chart_name VARCHAR2) IS
    SELECT
      lane_id,
      carrier_id,
      lane_number,
      service_type_code
    FROM
      fte_lanes
    WHERE
      UPPER(lane_type) = UPPER('HOLD_'|| p_chart_name) AND
      editable_flag <> 'D';

    l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.IS_LANE_LOADED';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status    := -1;

        l_name := UPPER(p_chart_name);

    IF ( FTE_BULKLOAD_PKG.g_debug_on )  THEN
       FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_name ',l_name );
    END IF;

        OPEN GET_LANES(p_chart_name);

        FETCH GET_LANES BULK COLLECT INTO x_lane_ids, l_carrier_ids, l_lane_numbers, l_lane_services;

        l_num_of_lanes := GET_LANES % ROWCOUNT;

        CLOSE GET_LANES;

        l_lane_loaded := l_num_of_lanes > 0;

        --+
        -- check to make sure the carrier ids of the lanes and rate chart match
        --+
        IF (l_lane_loaded) THEN

            GET_CARRIER_PREFERENCES(p_carrier_name  => p_carrier_name,
                                    p_service_level => p_service_level,
                                    p_line_number   => p_line_number,
                                    x_error_msg     => x_error_msg,
                                    x_status        => x_status);

            IF (x_status <> -1) THEN
                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error message from GET_CARRIER_PREFERENCES => ' || x_error_msg );
                END IF;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN FALSE;
            END IF;

            FOR i IN 1..l_carrier_ids.COUNT LOOP
                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_lane_numbers(' || i || ')', l_lane_numbers(i));
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_lane_services('|| i || ')', l_lane_services(i));
                END IF;

                IF (g_carrier_id <> l_carrier_ids(i)) THEN
                    x_status := 2;
                    l_lane_loaded := false;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_CAT_CARRIER_LANE_MISMATCH',
                                                        p_tokens => STRINGARRAY('CARRIER','RATE_CHART','SERVICE'),
                                                        p_values => STRINGARRAY(p_carrier_name,p_chart_name,l_lane_numbers(i)));
                    FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'D',
                                                p_line_number => p_line_number);
                    EXIT;
                ELSIF (p_service_level <> l_lane_services(i)) THEN
                    x_status := 2;
                    l_lane_loaded := false;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_SERV_LEVEL_LANE_MISMATCH',
                                                        p_tokens => STRINGARRAY('RATE_CHART','SERVICE'),
                                                        p_values => STRINGARRAY(p_chart_name,l_lane_numbers(i)));
                    FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    => 'D',
                                                p_line_number => p_line_number);

                    EXIT;
                END IF;
            END LOOP;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

        RETURN l_lane_loaded;

    EXCEPTION
        WHEN OTHERS THEN
            IF ( GET_LANES%ISOPEN ) THEN
                CLOSE GET_LANES;
            END IF;
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END IS_LANE_LOADED;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:  SET_CHART_LINE
    --
    -- PURPOSE   Update the cached rate chart information with the current line
    --           Number of the rate chart.
    --
    -- PARAMETERS
    -- IN
    --    1. p_chart_name : The rate chart name
    --    2. p_linenum    : The rate chart's current line number.
    --
    -- OUT
    --    1. x_status     : The exit status
    --_________________________________________________________________________________--

    PROCEDURE SET_CHART_LINE (p_chart_name  IN  VARCHAR2,
                              p_linenum     IN  NUMBER,
                              x_status      OUT NOCOPY NUMBER) IS

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.SET_CHART_LINE';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        FOR i IN 1.. Chart_Names.COUNT LOOP
            IF (p_chart_name = Chart_Names(i)) THEN
                Chart_LineNums(i) := p_linenum;
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END LOOP;

        x_status := 2;

        IF( FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: Rate Chart ' || p_chart_name || ' not found');
        END  IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR IN SET_CHART_LINE: ' || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END SET_CHART_LINE;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: LINK_RC_MODIFIERS
    --
    -- PURPOSE: Link all processed Modifiers to their corresponding Rate Charts.
    --          Creates a Qualifier for the Modifier and stores the Rate Chart
    --          ID in the qualifier attribute value.
    --
    --          The Modifier Names and and their associated Rate Chart Names
    --          are stored in the tables Link_ChartNames and Link_ModifierNames
    --
    -- PARAMETERS
    --  IN  p_chart_name, the chart name to be linked
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE LINK_RC_MODIFIERS(p_chart_name     IN     VARCHAR2,
                                x_error_msg      OUT NOCOPY VARCHAR2,
                                x_status         OUT NOCOPY VARCHAR2) IS

    l_rc_id               NUMBER;
    l_mod_pid             NUMBER;
    l_rc_name             VARCHAR2(50);
    l_mod_name            VARCHAR2(50);
    l_temp                VARCHAR2(30);
    l_carrier_name        VARCHAR2(100);

    l_qualifier_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_qualifier_data_tbl  FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.LINK_RC_MODIFIERS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --
        -- Get the associated modifier name, if it exists.
        --
        FOR i IN 1..Link_ChartNames.COUNT LOOP

            IF (Link_ChartNames(i) = p_chart_name) THEN

                l_mod_name := Link_ModifierNames(i);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Modifier for ' || p_chart_name || ' is ' || l_mod_name);
                END IF;

                BEGIN
                    SELECT
                      l.list_header_id
                    INTO
                      l_rc_id
                    FROM
                      qp_list_headers_tl l,
                      qp_list_headers_b b
                    WHERE
                      l.list_header_id = b.list_header_id AND
                      l.name = p_chart_name AND
                      l.language = userenv('LANG');

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        x_status := 2;
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'Rate Chart ' || p_chart_name || ' has not been loaded!'); --message.
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;

                -- Get the process_id of the modifier, for update.
                GET_CHART_DATA(p_chart_name    => l_mod_name,
                               p_currency      => l_temp,
                               p_chart_type    => l_temp,
                               x_carrier_name  => l_carrier_name,
                               x_service_level => l_temp,
                               x_cur_line      => l_temp,
                               x_job_id        => l_mod_pid,
                               p_line_number   => 0,
                               x_error_msg     => x_error_msg,
                               x_status        => x_status);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_chart_name', p_chart_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_mod_name  ', l_mod_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rc_id     ', l_rc_id);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_mod_pid   ', l_mod_pid);
                END IF;

                l_qualifier_data('ACTION')          := 'ADD';
                l_qualifier_data('RATE_CHART_NAME') := p_chart_name;
                l_qualifier_data('PROCESS_ID')      := l_mod_pid;
                l_qualifier_data('ATTRIBUTE')       := 'PRICE_LIST';
                l_qualifier_data('VALUE')           := l_rc_id;
                l_qualifier_data('CONTEXT')         := 'MODLIST';
                l_qualifier_data('GROUP')           := 1;

                l_qualifier_data_tbl(1) := l_qualifier_data;

                FTE_RATE_CHART_LOADER.PROCESS_QUALIFIER(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_qualifier_data_tbl,
                                                        p_line_number   => 0,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);
                l_qualifier_data.DELETE;
                l_qualifier_data_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(p_qp_call   => FALSE,
                                                        x_status    => x_status,
                                                        x_error_msg => x_error_msg);
                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
                EXIT;
            END IF;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXP. ERROR in LINK_RC_MODIFIERS: ' || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
    END LINK_RC_MODIFIERS;


    --_________________________________________________________________________________--
    --
    -- FUNCTION:  GET_FACILITY_RATE_BASIS
    --
    -- PURPOSE  Get the rate basis and UOM associated with the facility modifier.
    --
    -- PARAMETERS
    --
    -- IN
    --    p_chart_name:    The rate chart name
    --
    -- OUT
    --    x_rate_basis: The rate basis of the facility modifier.
    --    x_uom:        The rate basis uom.
    --_________________________________________________________________________________--

    PROCEDURE GET_FACILITY_RATE_BASIS(p_chart_name  IN         VARCHAR2,
                                      x_rate_basis  OUT NOCOPY VARCHAR2,
                                      x_uom         OUT NOCOPY VARCHAR2,
                                      x_status      OUT NOCOPY NUMBER,
                                      x_error_msg   OUT NOCOPY VARCHAR2) IS

    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.GET_FACILITY_RATE_BASIS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        FOR i IN 1..Fac_Modifier_Names.COUNT LOOP
            IF (p_chart_name = Fac_Modifier_Names(i)) THEN
                x_rate_basis := Fac_Modifier_Bases(i);
                x_uom :=  Fac_Modifier_Uoms(i);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END LOOP;

        x_status := 2;
        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            x_error_msg:='Facility Rate Chart Name Not Found';
            FTE_UTIL_PKG.Write_LogFile(l_module_name , x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name , 'UNEXP. ERROR IN GET_FACILITY_RATE_BASIS: ' || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END GET_FACILITY_RATE_BASIS;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:  ADD_ATTRIBUTE
    --
    -- PURPOSE   Add an attribute to a rate chart line.
    --           Calls FTE_RATE_CHART_VAL_PKG.Validate_Attribute_Row.
    --
    -- PARAMETERS
    --
    -- IN
    --  p_attribute_type      Attribute Type (eg. COMMODITY)
    --  p_attribute_value     Attribute Value_From
    --  p_attribute_value_to  Attribute Value_To
    --  p_context             Context of the Attribute
    --  p_linenum             Rate Chart Line Number.
    --  p_comp_operator       Comparison Operator (eg. BETWEEN)
    --  p_process_id          process ID of the rate chart.
    --  p_line_number         line number in the spreadsheet, used for error logging
    --
    -- OUT
    --    x_status  :  the return status, -1 for success
    --                                     2 for failure.
    --    x_error_msg: the corresponding error meassge,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE ADD_ATTRIBUTE(p_attribute_type      IN     VARCHAR2,
                            p_attribute_value     IN     VARCHAR2,
                            p_attribute_value_to  IN     VARCHAR2,
                            p_context             IN     VARCHAR2,
                            p_linenum             IN     NUMBER,
                            p_comp_operator       IN     VARCHAR2,
                            p_process_id          IN     NUMBER,
                            p_line_number         IN     NUMBER,
                            x_error_msg      OUT  NOCOPY VARCHAR2,
                            x_status         OUT  NOCOPY NUMBER ) IS


    l_attribute_data         FTE_BULKLOAD_PKG.data_values_tbl;
    l_attribute_block_tbl    FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name  CONSTANT  VARCHAR2(100) := 'fte.plsql.'||G_PKG_NAME||'.ADD_ATTRIBUTE';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_attribute_data('ACTION')              := 'ADD';
        l_attribute_data('LINE_NUMBER')         := Fnd_Number.Number_To_Canonical(p_linenum);
        l_attribute_data('ATTRIBUTE')           := p_attribute_type;
        l_attribute_data('ATTRIBUTE_VALUE')     := p_attribute_value;
        l_attribute_data('ATTRIBUTE_VALUE_TO')  := p_attribute_value_to;
        l_attribute_data('CONTEXT')             := p_context;
        l_attribute_data('COMPARISON_OPERATOR') := p_comp_operator;

        l_attribute_block_tbl(1) := l_attribute_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATING_ATTRIBUTE( p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_attribute_block_tbl,
                                                        p_line_number   => p_line_number,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);

        l_attribute_data.DELETE;
        l_attribute_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error ',x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR ', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END ADD_ATTRIBUTE;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:  RESET_ALL
    --
    -- PURPOSE  To delete all rows from all pl/sql tables, used for caching by the
    --          procedure GET_CHART_DATA.
    --
    --_________________________________________________________________________________--

    PROCEDURE RESET_ALL IS

    BEGIN

        IF (Chart_Names.EXISTS(1)) THEN
            Chart_Names.DELETE;
            Chart_Carriers.DELETE;
            Chart_Service_Levels.DELETE;
            Chart_LineNums.DELETE;
            Chart_Currencies.DELETE;
            Chart_Process_Ids.DELETE;
            Chart_Types.DELETE;
            Chart_Min_Charges.DELETE;
            Chart_Ids.DELETE;
            Chart_Start_Dates.DELETE;
            Chart_End_Dates.DELETE;
            g_layovr_charges.DELETE;
            g_layovr_breaks.DELETE;
            Link_ChartNames.DELETE;
            Link_Modifiernames.DELETE;
        END IF;

        g_chart_name      := NULL;
        g_wknd_layovr_uom := NULL;

    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile('RESET_ALL','UNEXPECTED ERROR occured',sqlerrm);
            RAISE;
    END RESET_ALL;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE:  RESET_CHART_INFO
    --
    -- Purpose  To reset the chart info already stored in global variables.
    --
    --_________________________________________________________________________________--

    PROCEDURE RESET_CHART_INFO IS
    BEGIN
        g_layovr_charges  := STRINGARRAY();
        g_layovr_breaks   := STRINGARRAY();
        g_chart_name      := NULL;
        g_wknd_layovr_uom := NULL;
    EXCEPTION
        WHEN OTHERS THEN
            FTE_UTIL_PKG.Write_LogFile('RESET_CHART_INFO','Unexpected error');
            RAISE;
    END RESET_CHART_INFO;


    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: CREATE_BREAKS                                                        --
    --                                                                                 --
    -- PURPOSE:   Create rate chart break lines in qp_list_lines given the             --
    --            charges and break ranges.                                            --
    --                                                                                 --
    -- PARAMETERS                                                                      --
    -- IN                                                                              --
    --    p_break_charges,   The charges of the break ranges.                          --
    --    p_break_limits,    The limits of the break ranges.                           --
    --    p_break_gap,       The gap between the end of one break and the              --
    --                       beginning of the next break                               --
    --    p_rate_type,       Rate Type (eg. STOP, FACILITY, ...)                       --
    --    p_attribute_type,  The attribute type associated with the break line.        --
    --    p_process_id,      Process Id of the rate chart.                             --
    --                                                                                 --
    -- IN OUT Parameters                                                               --
    --    x_linenum,         The line number of the rate break header.                 --
    --                                                                                 --
    -- OUT Parameters                                                                  --
    --    x_status,       the return status, -1 for success                            --
    --                                        2 for failure.                           --
    --    x_error_msg, the corresponding error meassge,                                --
    --                   if any exception occurs during the process.                   --
    --_________________________________________________________________________________--

    PROCEDURE CREATE_BREAKS(p_break_charges   IN  STRINGARRAY,
                            p_break_limits    IN  STRINGARRAY,
                            p_break_start     IN  NUMBER,
                            p_break_gap       IN  NUMBER,
                            p_rate_type       IN  VARCHAR2,
                            p_attribute_type  IN  VARCHAR2,
                            p_process_id      IN  NUMBER,
                            x_linenum         IN  OUT NOCOPY NUMBER,
                            x_error_msg       OUT NOCOPY VARCHAR2,
                            x_status          OUT NOCOPY NUMBER) IS

    l_break_min      NUMBER;
    l_break_max      NUMBER;
    l_rate           NUMBER;
    l_index1         NUMBER;
    l_index2         NUMBER;
    p_line_number    NUMBER := 0;

    l_rate_break_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_break_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.CREATE_BREAKS';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_break_max := p_break_start - p_break_gap;

        l_index1 := p_break_charges.FIRST;
        l_index2 := p_break_limits.FIRST;

        FOR i IN 1..p_break_charges.COUNT LOOP

            l_rate      := Fnd_Number.Canonical_To_Number(p_break_charges(l_index1));
            l_break_min := l_break_max + p_break_gap;
            l_break_max := Fnd_Number.Canonical_To_Number(p_break_limits(l_index2));
            x_linenum   := x_linenum + 1;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'x_linenum  ' || x_linenum);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_break_min' || l_break_min);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_break_max' || l_break_max);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate     ' || l_rate);
            END IF;

            l_rate_break_data('ACTION')     := 'ADD'; --G_ACTION;
            l_rate_break_data('LINE_NUMBER'):= x_linenum;
            l_rate_break_data('LOWER_LIMIT'):= Fnd_Number.Number_To_Canonical(l_break_min);
            l_rate_break_data('UPPER_LIMIT'):= Fnd_Number.Number_To_Canonical(l_break_max);
            l_rate_break_data('RATE')       := Fnd_Number.Number_To_Canonical(l_rate);
            l_rate_break_data('RATE_TYPE')  := p_rate_type;
            l_rate_break_data('ATTRIBUTE')  := p_attribute_type;
            l_rate_break_data('TYPE')       := 'ACCESSORIAL_SURCHARGE';

            l_rate_break_block_tbl(1) := l_rate_break_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header  => g_dummy_block_hdr_tbl,
                                                     p_block_data    => l_rate_break_block_tbl,
                                                     p_line_number   => p_line_number,
                                                     p_validate_column => FALSE,
                                                     x_status        => x_status,
                                                     x_error_msg     => x_error_msg);

            l_rate_break_data.DELETE;
            l_rate_break_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error On Line ' || x_linenum);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
            l_index1 := p_break_charges.NEXT(l_index1);
            l_index2 := p_break_limits.NEXT(l_index2);

        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN

            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CREATE_BREAKS;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: CREATE_MINCHARGE_MODIFIER
    --
    -- PURPOSE:  Create a Modifier for a rate chart that has minimum charges
    --           For its lines. This modifier is then later linked to the rate
    --           chart.
    --
    -- PARAMETERS
    -- IN
    --   p_chart_name,    the rate chart name
    --   p_service_level, service level of the carrier
    --   p_carrier_name,  carrier name for which the mincharge has to be attached
    --   p_currency,      carrier currency?
    --   p_charge_data,   minimum rate figures
    --   p_line_number,   line number in the upload file, used for logging
    --
    -- OUT Parameters
    --    x_status,       the return status, -1 for success
    --                                        2 for failure.
    --    x_error_msg, the corresponding error meassge,
    --                   if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE CREATE_MINCHARGE_MODIFIER( p_chart_name    IN     VARCHAR2,
                                         p_service_level IN     VARCHAR2,
                                         p_carrier_name  IN     VARCHAR2,
                                         p_currency      IN     VARCHAR2,
                                         p_charge_data   IN     VARCHAR2,
                                         x_mod_name  OUT NOCOPY VARCHAR2,
                                         p_line_number   IN     NUMBER,
                                         x_status    OUT NOCOPY NUMBER,
                                         x_error_msg OUT NOCOPY VARCHAR2) IS
    l_description      VARCHAR2(100);
    l_vehicle_type     VARCHAR2(50);
    l_basis            VARCHAR2(30);
    l_attribute_type   VARCHAR2(50);
    l_context          VARCHAR2(50);
    l_linenum          NUMBER;
    l_process_id       NUMBER;
    l_mincharge        NUMBER;
    l_service_level    VARCHAR2(30);
    l_start_date       VARCHAR2(30);
    l_end_date         VARCHAR2(30);
    l_type             VARCHAR2(30);
    l_subtype          VARCHAR2(30);
    l_uom              VARCHAR2(30);
    l_count            NUMBER;
    l_chart_type       VARCHAR2(30);
    l_charge_info      STRINGARRAY;
    l_formula_id       NUMBER;
    l_carrier_name     VARCHAR2(100);

    l_rate_hdr_data       FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_block_tbl  FTE_BULKLOAD_PKG.block_data_tbl;

    l_rate_line_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.'||G_PKG_NAME||'.CREATE_MINCHARGE_MODIFIER';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        x_mod_name      := p_chart_name || '_MIN';
        l_service_level := p_service_level;
        l_chart_type    := 'MIN_MODIFIER';
        l_carrier_name  := p_carrier_name;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, p_service_level||'::'||p_chart_name||'::'||p_currency);
        END IF;

        -- Store modifier data.
        GET_CHART_DATA(p_chart_name    => x_mod_name,
                       p_currency      => p_currency,
                       p_chart_type    => l_chart_type,
                       x_carrier_name  => l_carrier_name,
                       x_service_level => l_service_level,
                       x_cur_line      => l_linenum,
                       x_job_id        => l_process_id,
                       p_line_number   => p_line_number,
                       x_error_msg     => x_error_msg,
                       x_status        => x_status);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_linenum      ', l_linenum);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_process_id   ', l_process_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_service_level', l_service_level);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating Modifier Header For ' || x_mod_name);
        END IF;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        -- Create Modifier Header --
        l_description := 'Rate Chart ' || x_mod_name;

        l_rate_hdr_data('ACTION')        := 'ADD';
        l_rate_hdr_data('TL_MIN_CHARGE') := x_mod_name;
        l_rate_hdr_data('DESCRIPTION')   := l_description;
        l_rate_hdr_data('START_DATE')    := l_start_date;
        l_rate_hdr_data('END_DATE')      := l_end_date;
        l_rate_hdr_data('CURRENCY')      := p_currency;
        l_rate_hdr_data('CARRIER_NAME')  := p_carrier_name;
        l_rate_hdr_data('SERVICE_LEVEL') := l_service_level;
        l_rate_hdr_data('ATTRIBUTE1')    := l_chart_type;

        l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                 p_block_data   => l_rate_hdr_block_tbl,
                                                 p_line_number  => p_line_number,
                                                 p_validate_column => FALSE,
                                                 p_process_id   => l_process_id,
                                                 x_status       => x_status,
                                                 x_error_msg    => x_error_msg);

        l_rate_hdr_data.DELETE;
        l_rate_hdr_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;


        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_charge_data', p_charge_data);
        END IF;

        l_charge_info := FTE_UTIL_PKG.TOKENIZE_STRING(p_string => p_charge_data,
                                                      p_delim  => ':' );
        l_type := 'ACCESSORIAL_SURCHARGE';

        BEGIN

            SELECT price_formula_id
            INTO   l_formula_id
            FROM   qp_price_formulas_b
            WHERE  price_formula_no = 'QP_MIN_CHARGE';

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_MIN_CHARGE_FORMULA_NOT_SET');
                FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'B',
                                            p_line_number => p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            WHEN OTHERS THEN
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);

        END;

        --+
        -- Create a Line for each (basis,vehicle,mincharge) combination.
        -- l_charge_info contains strings of the format
        -- (B:<basis>:V:<veh>:U:<uom>:C:<charge>:B:<basis>:...)
        --+

        l_count := l_charge_info.FIRST;

        WHILE l_count < l_charge_info.COUNT-1 LOOP

            l_linenum := l_linenum + 1;

            l_description := 'Line ' || l_linenum || ' Of ' ||x_mod_name;

            l_basis        := l_charge_info(l_count + 1);
            l_vehicle_type := l_charge_info(l_count + 3);
            l_uom          := l_charge_info(l_count + 5);
            l_mincharge    := Fnd_Number.Canonical_To_Number(l_charge_info(l_count+7));

            IF (l_basis = 'DISTANCE') THEN
                l_subtype := FTE_RTG_GLOBALS.G_C_MIN_DISTANCE_CH;
            ELSIF (l_basis = 'TIME') THEN
                l_subtype := FTE_RTG_GLOBALS.G_C_MIN_TIME_CH;
            ELSE
                -- WEIGHT/VOLUME/PALLET/CONTAINER
                l_subtype := FTE_RTG_GLOBALS.G_C_MIN_UNIT_CH;
            END IF;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating   ' || l_description);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_subtype  ', l_subtype);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_basis    ', l_basis);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_vehicle_type',l_vehicle_type);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_mincharge ', l_mincharge);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_uom       ', l_uom);
            END IF;

            --
            -- MinCharge Modifier lines must have the item_amount attribute for each line
            -- AND no item_all attribute.
            --
            l_rate_line_data('ACTION')       := G_ACTION;
            l_rate_line_data('LINE_NUMBER')  := l_linenum;
            l_rate_line_data('DESCRIPTION')  := l_description;
            l_rate_line_data('FIXED_RATE')   := Fnd_Number.Number_To_Canonical(l_mincharge);
            l_rate_line_data('UOM')          := l_uom;
            l_rate_line_data('RATE_BREAK_TYPE')  := 'POINT';
            l_rate_line_data('RATE_TYPE')    := 'LUMPSUM';
            l_rate_line_data('TYPE')         := l_type;
            l_rate_line_data('SUBTYPE')      := l_subtype;
            l_rate_line_data('MOD_LEVEL_CODE')  := 'LINEGROUP';
            l_rate_line_data('FORMULA_ID')   := l_formula_id;
            l_rate_line_data('ATTRIBUTE')    := 'ITEM_AMOUNT';
            l_rate_line_data('CONTEXT')      := 'VOLUME';
            l_rate_line_data('COMPARISON_OPERATOR') := 'BETWEEN';
            l_rate_line_data('ATTRIBUTE_VALUE')     :=  1;
            l_rate_line_data('ATTRIBUTE_VALUE_TO')  := g_max_number;

            l_rate_line_block_tbl(1) := l_rate_line_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                    p_block_data    => l_rate_line_block_tbl,
                                                    p_line_number   => p_line_number,
                                                    p_validate_column => FALSE,
                                                    x_status        => x_status,
                                                    x_error_msg     => x_error_msg);
            l_rate_line_data.DELETE;
            l_rate_line_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            ADD_ATTRIBUTE(p_attribute_type      => 'TL_RATE_BASIS',
                          p_attribute_value     => l_basis,
                          p_attribute_value_to  => NULL,
                          p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_BASIS,
                          p_comp_operator       => NULL,
                          p_linenum             => l_linenum,
                          p_process_id          => l_process_id,
                          p_line_number         => p_line_number,
                          x_error_msg           => x_error_msg,
                          x_status              => x_status);

            ADD_ATTRIBUTE(p_attribute_type      => 'TL_RATE_TYPE',
                          p_attribute_value     => 'BASE_RATE',
                          p_attribute_value_to  => NULL,
                          p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE,
                          p_comp_operator       => NULL,
                          p_linenum             => l_linenum,
                          p_process_id          => l_process_id,
                          p_line_number         => p_line_number,
                          x_error_msg           => x_error_msg,
                          x_status              => x_status);


            -- Attribute : VEHICLE TYPE (optional)
            IF (l_vehicle_type IS NOT NULL AND LENGTH(l_vehicle_type) > 0) THEN
                --Vehicle type is already in ID form
                ADD_ATTRIBUTE (p_attribute_type      => 'TL_VEHICLE_TYPE',
                               p_attribute_value     => l_vehicle_type,
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_VEHICLE,
                               p_comp_operator       => NULL,
                               p_linenum             => l_linenum,
                               p_process_id          => l_process_id,
                               p_line_number         => p_line_number,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

            END IF;
            --
            -- Insert a qualifier for the associated pricelist
            --
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            l_count := l_count + 8;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR in CREATE_MINCHARGE_MODIFIER',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END CREATE_MINCHARGE_MODIFIER;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: STORE_MIN_CHARGE
    --
    -- Purpose:  Store Minimum Charges for the the rate chart.
    --           Each Rate Chart has a minimum charges for each of its
    --           rate bases.
    --
    --           Rate Chart       Basis:<val>:Veh:<val>:Uom:<val>:Charge:<val>:Basis:....
    --           ----------       -------------------------------------------------------
    --           Rate       ->    B:WEIGHT:V:53FT:C:30:U:Lbs:B:DIST:...
    --
    -- PARAMETERS
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE STORE_MIN_CHARGE(p_chart_name     IN     VARCHAR2,
                               p_charge         IN     NUMBER,
                               p_basis          IN     VARCHAR2,
                               p_uom            IN     VARCHAR2,
                               p_vehicle        IN     VARCHAR2,
                               p_line_number    IN     NUMBER,
                               x_error_msg  OUT NOCOPY VARCHAR2,
                               x_status     OUT NOCOPY NUMBER ) IS


    l_module_name   CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.STORE_MIN_CHARGE';

    l_charge_str    VARCHAR2(2000);
    l_str           VARCHAR2(100);

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --+
        -- Create the minimum charge string.
        --+
        l_str := 'B:' || p_basis || ':V:' || p_vehicle||':U:'|| p_uom ||':C:' || Fnd_Number.Number_To_Canonical(p_charge) || ':';

        FOR i IN 1.. Chart_Names.COUNT LOOP
            IF (p_chart_name = Chart_Names(i)) THEN
                IF (NOT Chart_Min_Charges.EXISTS(i)) THEN
                    --+
                    -- store a new min charge string for the rate chart
                    --+
                    Chart_Min_Charges(i) := l_str;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSE
                    --+
                    -- Get the stored string from the min charges table
                    --+
                    l_charge_str := Chart_Min_Charges(i);
                END IF;

                --+
                -- Validate the Rate Basis, Vehicle Type, Uom, Minimum Charge combination.
                --+
                IF (l_charge_str IS NOT NULL) THEN

                    --+
                    -- Check the stored string for the same combination of basis, vehicle, uom, charge.
                    -- If that combination exists, then
                    --    a. If basis is NOT distance, we have a duplicate line (ERROR).
                    --    b. If basis is distance, this is not an error because distance
                    --       allows different distance types to have the same combination.
                    --+
                    IF (INSTR(l_charge_str, l_str) > 0) THEN
                        IF (p_basis <> 'DISTANCE') THEN
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DUPLICATE_BASIS_LINE',
                                                                p_tokens => STRINGARRAY('BASIS','VEHICLE'),
                                                                p_values => STRINGARRAY(p_basis,p_vehicle));
                            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number);

                            x_status := 2;
                        END IF;
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    --
                    -- Check the stored string for the same combination of basis, vehicle, uom
                    -- If that combination exists, then
                    --    a. If basis is NOT distance, we have a duplicate line (ERROR).
                    --    b. If basis is distance, we have an error because the different
                    --       distance types must have the same minimum charge.
                    --
                    ELSIF (INSTR(l_charge_str, 'B:'||p_basis||':V:'||p_vehicle||':U:'||p_uom) > 0) THEN
                        IF (p_basis <> 'DISTANCE') THEN
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DUPLICATE_BASIS_LINE',
                                                                p_tokens => STRINGARRAY('BASIS','VEHICLE'),
                                                                p_values => STRINGARRAY(p_basis,p_vehicle));
                            FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                                        p_module_name => l_module_name,
                                                        p_category    => 'D',
                                                        p_line_number => p_line_number);
                            x_status := 2;
                        ELSE
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_MULTIPLE_MIN_CHARGES',
                                                                p_tokens => STRINGARRAY('BASIS','VEHICLE'),
                                                                p_values => STRINGARRAY(p_basis,p_vehicle));
                            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number);
                            x_status := 2;
                        END IF;

                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;

                    --
                    -- Check for the same combination of basis and vehicle.
                    -- If it exists, then we have an error because we have a
                    --    similar preceding line (basis, vehicle) with different uom.
                    --
                    ELSIF (INSTR(l_charge_str, 'B:' || p_basis || ':V:'||p_vehicle) > 0) THEN
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name   => 'FTE_CAT_MULTIPLE_UOMS',
                                                            p_tokens => STRINGARRAY('BASIS','VEHICLE'),
                                                            p_values => STRINGARRAY(p_basis,p_vehicle));
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    => 'D',
                                                   p_line_number => p_line_number);
                         x_status := 2;
                         FTE_UTIL_PKG.Exit_Debug(l_module_name);
                         RETURN;
                    END IF;
                END IF;

                l_charge_str := l_charge_str || l_str;
                Chart_Min_Charges(i) := l_charge_str;

            END IF;
        END LOOP;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR in STORE_MIN_CHARGE', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END STORE_MIN_CHARGE;

    --______________________________________________________________________________________--
    --                                                                                      --
    -- PROCEDURE: PROCESS_WKND_LAYOVR_CHARGES                                                --
    --                                                                                      --
    -- Purpose : week end lay over charge is a type os TL surcharge.                        --
    --           This is called from PROCESS_TL_SURCHARGES to process             --
    --           PROCESS_WKND_LAYOVR_CHARGES, if the type of charge is 'B'.                 --
    --                                                                                      --
    -- Parameters :                                                                         --
    --                                                                                      --
    -- IN     p_process_id,                                                                 --
    --        p_line_number                                                                 --
    -- OUT                                                                                  --
    --    x_linenum                                                                         --
    --    x_status,   the return status, -1 for success                                     --
    --                                        2 for failure.                                --
    --    x_error_msg, the corresponding error meassge,                                     --
    --                    if any exception occurs during the process.                       --
    --______________________________________________________________________________________--

    PROCEDURE PROCESS_WKND_LAYOVR_CHARGES(p_process_id  IN  NUMBER,
                                          x_linenum     IN  OUT NOCOPY NUMBER,
                                          p_line_number IN  NUMBER,
                                          x_error_msg   OUT NOCOPY VARCHAR2,
                                          x_status      OUT NOCOPY NUMBER) IS
    l_subtype               VARCHAR2(30);
    l_type                  VARCHAR2(30);
    l_break_type            VARCHAR2(30);
    l_description           VARCHAR2(300);
    l_context               VARCHAR2(50);
    l_attribute_value       VARCHAR2(50);
    l_attribute_type        VARCHAR2(50);

    l_rate_line_data        FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl   FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name         CONSTANT VARCHAR2(100) := 'FTE.PLSQL.'||G_PKG_NAME||'.PROCESS_WKND_LAYOVR_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        x_linenum := x_linenum + 1;
        l_description := 'Weekend Layover Charge: Line ' || x_linenum;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, l_description);
        END IF;

        l_type        := 'ACCESSORIAL_SURCHARGE';
        l_break_type  := 'POINT';
        l_subtype     := FTE_RTG_GLOBALS.G_C_WEEKEND_LAYOVER_CH;

        l_rate_line_data('ACTION')         := 'ADD'; --G_ACTION;
        l_rate_line_data('LINE_NUMBER')    := x_linenum;
        l_rate_line_data('DESCRIPTION')    := l_description;
        l_rate_line_data('VOLUME_TYPE')    := 'TOTAL_QUANTITY';
        l_rate_line_data('RATE_BREAK_TYPE'):= l_break_type;
        l_rate_line_data('SUBTYPE')        := l_subtype;
        l_rate_line_data('TYPE')           := l_type;
        l_rate_line_data('RATE_TYPE')      := 'FIXED';
        l_rate_line_data('UOM')            := g_unit_uom;

        l_rate_line_block_tbl(1) := l_rate_line_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header    => g_dummy_block_hdr_tbl,
                                                p_block_data      => l_rate_line_block_tbl,
                                                p_line_number     => p_line_number,
                                                p_validate_column => FALSE,
                                                x_status          => x_status,
                                                x_error_msg       => x_error_msg);
        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        --+
        -- add Rate Type Attribute
        --+
        l_attribute_type  := 'TL_RATE_TYPE';
        l_context         := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;
        l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;

        ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                       p_attribute_value     => l_attribute_value,
                       p_attribute_value_to  => NULL,
                       p_context             => l_context,
                       p_linenum             => x_linenum,
                       p_comp_operator       => '=',
                       p_process_id          => p_process_id,
                       p_line_number         => p_line_number,
                       x_error_msg           => x_error_msg,
                       x_status              => x_status);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Begin Create Breaks');
        END IF;

        CREATE_BREAKS (p_break_charges    => g_layovr_charges,
                       p_break_limits     => g_layovr_breaks,
                       p_break_start      => Fnd_Number.Canonical_To_Number('0'),
                       p_break_gap        => Fnd_Number.Canonical_To_Number('0'),
                       p_rate_type        => 'LUMPSUM',
                       p_attribute_type   => 'TL_WEEKEND_LAYOVER_MILEAGE',
                       p_process_id       => p_process_id,
                       x_linenum          => x_linenum,
                       x_error_msg        => x_error_msg,
                       x_status           => x_status);

        g_layovr_breaks.DELETE;
        g_layovr_charges.DELETE;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR in PROCESS_WKND_LAYOVR_CHARGES Error',sqlerrm);

    END PROCESS_WKND_LAYOVR_CHARGES;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: SUBMIT_TL_CHART
    --
    -- PURPOSE: Calls FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS, to popupulate the interface
    --          tables and call corresponginf QP API. The values for headers,lines, attribs,
    --          qualifiers have already been stored through the validation procedures.
    --          For instance, FTE.VALIDATION_PKG.VALIDATE_RATE_CHART stores the header info
    --          after all validations for header in temporary pl/sql tables.
    --          Inspite of name, validation procedures stores the data in temp pl/sql tables.
    --
    -- PARAMETERS
    --
    -- OUT
    --  x_status , -1 return status,
    --             > 0, otherwise
    --_________________________________________________________________________________--

    PROCEDURE SUBMIT_TL_CHART (x_status     OUT NOCOPY NUMBER,
                   x_error_msg  OUT NOCOPY VARCHAR2) IS

    l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.SUBMIT_TL_CHART';

    l_lane_loaded          BOOLEAN;
    l_chart_name           VARCHAR2(60);
    l_carrier_name         VARCHAR2(60);
    l_process_id           NUMBER;
    l_lane_ids             NUMBER_TAB;
    l_lane_id              NUMBER;
    l_list_header_id       NUMBER;
    l_start_date           VARCHAR2(20);
    l_end_date             VARCHAR2(20);
    l_service_level        VARCHAR2(30);
    l_chart_type           VARCHAR2(30);
    l_count                NUMBER;
    l_linenum              NUMBER;
    l_lane_service         VARCHAR2(30);

    -- For Facility Modifiers
    l_currency             VARCHAR2(30);
    l_prc_param_ids        STRINGARRAY;
    l_prc_param_values     STRINGARRAY;
    l_parameter_id         NUMBER;
    l_rate_basis           VARCHAR2(30);
    l_rate_basis_uom       VARCHAR2(30);
    l_modifier_id          NUMBER;
    l_currency_tbl     FTE_RATE_CHART_PKG.LH_CURRENCY_CODE_TAB;
    l_name         FTE_RATE_CHART_PKG.LH_NAME_TAB;

    l_carrier_name_temp	VARCHAR2(60);
    l_service_level_temp	VARCHAR2(30);
    l_linenum_temp	NUMBER;
    l_process_id_temp	NUMBER;

    p_line_number         NUMBER := 0;

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (g_unit_uom IS NULL) THEN

            g_unit_uom := GET_GLOBAL_UNIT_UOM (x_status, x_error_msg);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'ERROR Getting Global UOM' || x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

   IF (g_layovr_breaks.exists(1)) THEN
     Get_Chart_Data(p_chart_name    => g_chart_name,
                    p_currency      => l_currency,
                    p_chart_type    => l_chart_type,
                    x_carrier_name  => l_carrier_name_temp,
                    x_service_level => l_service_level_temp,
                    x_cur_line      => l_linenum_temp,
                    x_job_id        => l_process_id_temp,
		    p_line_number   => null,
                    x_error_msg     => x_error_msg,
                    x_status        => x_status);

     IF (l_carrier_name_temp IS NULL) THEN
       x_status := 2;
       x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_NO_RC');
       FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                 		  p_msg   => x_error_msg,
                 		  p_category    => 'D');
       FTE_UTIL_PKG.Exit_Debug(l_module_name);
       RETURN;
     END IF;

     IF (g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_name', g_chart_name);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_process_id', l_process_id_temp);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'l_service_level', l_service_level_temp);
	FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '--------Begin Process_Weekend_Layover_Charges');
     END IF;

     Process_Wknd_Layovr_Charges (p_process_id  => l_process_id_temp,
                                  x_linenum     => l_linenum_temp,
				  p_line_number	=> null,
                                  x_error_msg   => x_error_msg,
                                  x_status      => x_status );
     IF (g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, '--------End Process_Weekend_Layover_Charges with status :' || x_status);
     END IF;

     Set_Chart_Line(g_chart_name, l_linenum_temp, x_status);

     IF (x_status <> -1) THEN
       FTE_UTIL_PKG.Exit_Debug(l_module_name);
       RETURN;
     END IF;

   END IF;


    IF (instr(g_chart_name, 'MOD_') > 0 AND g_action <> 'DELETE') THEN
      Get_Chart_Data(p_chart_name    => g_chart_name,
                     p_currency      => l_currency,
                     p_chart_type    => l_chart_type,
                     x_carrier_name  => l_carrier_name_temp,
                     x_service_level => l_service_level_temp,
                     x_cur_line      => l_linenum_temp,
                     x_job_id        => l_process_id_temp,
		     p_line_number   => null,
                     x_error_msg     => x_error_msg,
                     x_status        => x_status);

      IF (g_debug_on) THEN
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'action: ', g_action);
        FTE_UTIL_PKG.WRITE_LOGFILE(l_module_name, 'linenum: ', l_linenum_temp);
      END IF;

      IF (l_linenum_temp = 0 OR x_status <> -1) THEN
        x_status := 2;
        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_UI_NO_LINES',
					    p_tokens => STRINGARRAY('TYPE'),
					    p_values => STRINGARRAY(FTE_UTIL_PKG.GET_MSG('FTE_TL_ACCESSORIALS')));
        FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                 		   p_msg   => x_error_msg,
                 		   p_category    => 'D');
        FTE_UTIL_PKG.Exit_Debug(l_module_name);
        RETURN;
      END IF;
    END IF;

        --+
        -- Process any remaining weekday layover charges.
        --+
        IF (g_layovr_breaks.COUNT > 0) THEN

            GET_CHART_DATA( p_chart_name    => g_chart_name,
                            p_currency      => l_currency,
                            p_chart_type    => l_chart_type,
                            x_carrier_name  => l_carrier_name,
                            x_service_level => l_service_level,
                            x_cur_line      => l_linenum,
                            x_job_id        => l_process_id,
                            p_line_number   => p_line_number,
                            x_error_msg     => x_error_msg,
                            x_status        => x_status);

            IF (l_linenum = 0 OR x_status <> -1) THEN
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'ERROR BREAK: No Rate Chart Name Previously Defined');
            END IF;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_name         ', g_chart_name);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_process_id   ', l_process_id);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_service_level', l_service_level);
            END IF;

            PROCESS_WKND_LAYOVR_CHARGES ( p_process_id  => l_process_id,
                                          x_linenum     => l_linenum,
                                          p_line_number => p_line_number,
                                          x_error_msg   => x_error_msg,
                                          x_status      => x_status );
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Returned with Error from PROCESS_WKND_LAYOVR_CHARGES',x_error_msg );
            END IF;

        END IF;

        --+
        -- For all previously created rate charts, we need to create a minimum charge
        -- modifier for the rate chart, if minimum charges exist.
        --+

        l_count := Chart_Names.COUNT;
        FOR i IN 1..l_count LOOP
            IF (Chart_Min_Charges.EXISTS(i)) THEN
                CREATE_MINCHARGE_MODIFIER(p_chart_name    => Chart_Names(i),
                                          p_service_level => Chart_Service_Levels(i),
                                          p_carrier_name  => Chart_Carriers(i),
                                          p_currency      => Chart_Currencies(i),
                                          p_charge_data   => Chart_Min_Charges(i),
                                          x_mod_name      => l_chart_name,
                                          p_line_number   => p_line_number,
                                          x_status        => x_status,
                                          x_error_msg     => x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Returned Error from CREATE_MINCHARGE_MODIFIER', x_error_msg );
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSE
                    Link_ChartNames(Link_ChartNames.COUNT+1) := Chart_Names(i);
                    Link_ModifierNames(Link_ModifierNames.COUNT+1) := l_chart_name;
                END IF;
            END IF;
        END LOOP;

        --+
        -- Now Insert All rate chart data into the QP_INTERFACE tables.
        -- Insert_qp_interface tables of rate chart package  should not call QP_MOD_LOADER_PUB.LOAD_MOD_LIST(p
        -- depending on some parameters.
        --+
        FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS(p_qp_call   => FALSE,
                                                x_error_msg => x_error_msg,
                                                x_status    => x_status);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return Status from FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS', x_status);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return Message from FTE_RATE_CHART_LOADER.SUBMIT_QP_PROCESS', x_error_msg);
        END IF;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return status from  SUBMIT_QP_PROCESS', x_status );
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FND_PROFILE.PUT('QP_PRICING_TRANSACTION_ENTITY', 'LOGSTX');
        FND_PROFILE.PUT('QP_SOURCE_SYSTEM_CODE', 'FTE');

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Chart_Process_Ids.COUNT ', Chart_Process_Ids.COUNT);
        END IF;

        FOR i IN 1..Chart_Process_Ids.COUNT LOOP
            l_chart_name    := Chart_Names(i);
            l_carrier_name  := Chart_Carriers(i);
            l_process_id    := Chart_Process_Ids(i);
            l_service_level := Chart_Service_Levels(i);
            l_chart_type    := Chart_Types(i);
            l_currency      := Chart_Currencies(i);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_chart_name   ', l_chart_name);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_carrier_name ', l_carrier_name);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_process_id   ', l_process_id);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_service_level', l_service_level);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_chart_type   ', l_chart_type);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_currency     ', l_currency);
            END IF;

            IF (l_chart_type in('TL_RATE_CHART', 'FAC_RATE_CHART')) THEN
                l_name(1) := l_chart_name;
                l_currency_tbl(1) := l_currency;
                FTE_RATE_CHART_PKG.QP_API_CALL(p_chart_type     => l_chart_type,
                                               p_process_id => l_process_id,
                                               p_name       => l_name,
                                               p_currency   => l_currency_tbl,
                                               x_status     => x_status,
                                               x_error_msg  => x_error_msg);

                IF (x_status <> -1) THEN
                          FTE_UTIL_PKG.Exit_Debug(l_module_name);
                          RETURN;
                ELSE

                    --+
                    -- We need to link the rate chart to any modifiers that
                    -- may be attached to it, before we upload the modifiers.
                    -- (TL_RATE_CHART => MIN_MODIFIER), (FAC_RATE_CHART => FAC_MODIFIER)
                    --+

                    LINK_RC_MODIFIERS(p_chart_name => l_chart_name,
                                      x_error_msg  => x_error_msg,
                                      x_status     => x_status);

                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;

            ELSIF (l_chart_type IN ('TL_MODIFIER', 'FAC_MODIFIER', 'FTE_MODIFIER', 'MIN_MODIFIER')) THEN
                l_name(1) := l_chart_name;
                l_currency_tbl(1) := l_currency;
                FTE_RATE_CHART_PKG.QP_API_CALL(p_chart_type     => l_chart_type,
                                               p_process_id => l_process_id,
                                               p_name       => l_name,
                                               p_currency   => l_currency_tbl,
                                               x_status     => x_status,
                                               x_error_msg  => x_error_msg);

                IF (x_status <> -1) THEN
                     FTE_UTIL_PKG.Exit_Debug(l_module_name);
                     RETURN;
                END IF;

            ELSE
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Unknown Chart Type ' || l_chart_type);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Could Not Load The Rate Chart ' || l_chart_name);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            IF (i = 1) THEN
                FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                           p_msg     => 'FTE_RATECHARTS_LOADED',
                                           p_category    => NULL);
            END IF;

            FTE_UTIL_PKG.WRITE_OUTFILE(p_module_name => l_module_name,
                                       p_msg         => l_chart_name,
                                       p_category    => NULL);

            IF (l_chart_type = 'TL_RATE_CHART') THEN

                --+
                -- Update any lanes associated with this loaded rate chart.
                --+
                l_lane_loaded := IS_LANE_LOADED( p_chart_name    => l_chart_name,
                                                 p_carrier_name  => l_carrier_name,
                                                 p_service_level => l_service_level,
                                                 p_line_number   => p_line_number,
                                                 x_lane_ids      => l_lane_ids,
                                                 x_error_msg     => x_error_msg,
                                                 x_status        => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error In Lane Status');
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Found ' || l_lane_ids.COUNT || ' lanes matching rate chart');
                END IF;

                IF (l_lane_loaded) THEN

                    IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Updating Existing Lanes with Rate Chart Info');
                    END IF;

                    BEGIN

                        SELECT
                          lh.list_header_id,
                          b.start_date_active,
                          b.end_date_active
                        INTO
                          l_list_header_id,
                          l_start_date,
                          l_end_date
                        FROM
                          qp_list_headers_tl lh,
                          qp_list_headers_b b,
                          qp_qualifiers q
                        WHERE
                          lh.list_header_id = b.list_header_id AND
                          lh.list_header_id = q.list_header_id AND
                          q.qualifier_context = 'PARTY' AND
                          q.qualifier_attr_value = Fnd_Number.Number_To_Canonical(g_carrier_id) AND
                          lh.name = l_chart_name AND
                          lh.language = userenv('LANG');

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_list_header_id := NULL;
                            x_status := 2;
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICE_NAME_MISSING');
                            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number);
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                    END;

                    IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_list_header_id', l_list_header_id);
                    END IF;

                    --+
                    -- Update the lane with the rate chart ID:
                    --+
                    FOR j IN 1..l_lane_ids.COUNT LOOP
                        BEGIN
                            IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'lane id('|| j|| ')',l_lane_ids(j));
                            END IF;

                            INSERT INTO FTE_LANE_RATE_CHARTS (LANE_ID,
                                                              LIST_HEADER_ID,
                                                              START_DATE_ACTIVE,
                                                              END_DATE_ACTIVE,
                                                              CREATED_BY,
                                                              CREATION_DATE,
                                                              LAST_UPDATED_BY,
                                                              LAST_UPDATE_DATE,
                                                              LAST_UPDATE_LOGIN)
                                                      VALUES (l_lane_ids(j),
                                                              l_list_header_id,
                                                              l_start_date,
                                                              l_end_date,
                                                              FND_GLOBAL.USER_ID,
                                                              G_CURDATE,
                                                              FND_GLOBAL.USER_ID,
                                                              G_CURDATE,
                                                              FND_GLOBAL.USER_ID);
                        EXCEPTION
                            WHEN OTHERS THEN
                                 x_status := 2;
                                 FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
                                 FTE_UTIL_PKG.Exit_Debug(l_module_name);
                          END;

                        BEGIN
                            IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Updating Fte_Lanes with service level ', l_service_level);
                            END IF;

                            UPDATE fte_lanes
                            SET service_detail_flag ='Y',
                                service_type_code = l_service_level,
                                lane_type = NULL,
                                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                                LAST_UPDATE_DATE = SYSDATE,
                                LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
                            WHERE lane_id = l_lane_ids(j);

                        EXCEPTION
                            WHEN OTHERS THEN
                                x_status := 2;
                                FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
                                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        END;
                    END LOOP;

                END IF;

            ELSIF (l_chart_type = 'FAC_MODIFIER') THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Postprocessing Facility Modifier');
                END IF;

                BEGIN

                    SELECT
                      modc.list_header_id,
                      Fnd_Number.Canonical_To_Number(qual.qualifier_attr_value)
                    INTO
                      l_modifier_id,
                      l_list_header_id
                    FROM
                      qp_list_headers_tl modc,
                      qp_list_headers_b b,
                      qp_qualifiers  qual
                    WHERE
                      modc.list_header_id = b.list_header_id AND
                      qual.list_header_id = modc.list_header_id AND
                      qual.qualifier_context = 'MODLIST' AND
                      qual.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4' AND
                      modc.name = l_chart_name AND
                      modc.language = userenv('LANG');

                EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                        l_list_header_id := NULL;
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICELIST_INVALID');
                        FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                    p_module_name => l_module_name,
                                                    p_category    => 'D',
                                                    p_line_number => p_line_number);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;

                GET_FACILITY_RATE_BASIS(p_chart_name  =>  l_chart_name,
                                        x_rate_basis  =>  l_rate_basis,
                                        x_uom         =>  l_rate_basis_uom,
                                        x_status      =>  x_status,
                                        x_error_msg   =>  x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error In Get_Facility_Rate_Basis', x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                l_prc_param_ids    := STRINGARRAY(57, 58, 59, 60);
                l_prc_param_values := STRINGARRAY(l_rate_basis, l_rate_basis_uom, l_list_header_id, l_currency);

                --+
                -- Insert Facility Data into FTE_PRC_PARAMETERS
                --+
                BEGIN
                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Inserting into FTE_PRC_PARAMETERS');
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_chart_name    ', l_chart_name);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis    ', l_rate_basis);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis_uom', l_rate_basis_uom);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_currency      ', l_currency);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_modifier_id   ', l_modifier_id);
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_list_header_id', l_list_header_id);
                    END IF;

                    FORALL m IN 1..l_prc_param_ids.COUNT
                        INSERT INTO FTE_PRC_PARAMETERS( PARAMETER_INSTANCE_ID,
                                                        PARAMETER_ID,
                                                        VALUE_FROM,
                                                        UOM_CODE,
                                                        CURRENCY_CODE,
                                                        CREATION_DATE,
                                                        CREATED_BY,
                                                        LAST_UPDATE_DATE,
                                                        LAST_UPDATED_BY,
                                                        LIST_HEADER_ID)
                                                VALUES( fte_prc_parameters_s.NEXTVAL,
                                                        l_prc_param_ids(m),
                                                        l_prc_param_values(m),
                                                        l_rate_basis_uom,
                                                        l_currency,
                                                        sysdate,
                                                        FND_GLOBAL.User_Id,
                                                        sysdate,
                                                        FND_GLOBAL.User_Id,
                                                        l_modifier_id);
                EXCEPTION
                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := sqlerrm;
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXP. ERROR Inserting Prc_Parameters', sqlerrm);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                END;
            END IF; -- End Processing Different Chart Types

        END LOOP;


        RESET_ALL;
        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXP ERROR in SUBMIT_TL_CHART', sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END SUBMIT_TL_CHART;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_FUEL_CHARGES
    --
    -- PURPOSE  To processs the Fuel charges in the file. called by PROCESS_TL_SURCHAGRES.
    --
    -- PARAMETERS
    -- IN
    --    p_charge
    --    p_process_id
    --    p_line_number
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_FUEL_CHARGES(p_charge       IN  NUMBER,
                                   p_process_id   IN  NUMBER,
                                   p_line_number  IN  NUMBER,
                                   x_linenum      IN  OUT NOCOPY  NUMBER,
                                   x_error_msg    OUT NOCOPY      VARCHAR2,
                                   x_status       OUT NOCOPY      NUMBER) IS

    l_description      VARCHAR2(300);
    l_type             VARCHAR2(30);
    l_subtype          VARCHAR2(50);
    l_attribute_value  VARCHAR2(50);
    l_attribute_type   VARCHAR2(50);
    l_context          VARCHAR2(30);

    l_rate_line_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.'||G_PKG_NAME||'.PROCESS_FUEL_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        x_linenum := x_linenum + 1;
        l_description := 'Fuel Surcharge Line ' || x_linenum;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, l_description);
        END IF;

        l_type := 'ACCESSORIAL_SURCHARGE';
        l_subtype  := FTE_RTG_GLOBALS.G_C_FUEL_CH;

        l_rate_line_data('ACTION')      := G_ACTION;
        l_rate_line_data('LINE_NUMBER') := x_linenum;
        l_rate_line_data('DESCRIPTION') := l_description;
        l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
        l_rate_line_data('SUBTYPE')     := l_subtype;
        l_rate_line_data('TYPE')        := l_type;
        l_rate_line_data('PERCENTAGE')  := Fnd_Number.Number_To_Canonical(p_charge);
        l_rate_line_data('UOM')         := g_unit_uom;

        l_rate_line_block_tbl(1) := l_rate_line_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                p_block_data    => l_rate_line_block_tbl,
                                                p_line_number   => p_line_number,
                                                p_validate_column => FALSE,
                                                x_status        => x_status,
                                                x_error_msg     => x_error_msg);

        l_rate_line_data.DELETE;
        l_rate_line_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        l_context         := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;
        l_attribute_type  := 'TL_RATE_TYPE';
        l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_LOAD;

        ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                      p_attribute_value     => l_attribute_value,
                      p_attribute_value_to  => NULL,
                      p_context             => l_context,
                      p_comp_operator       => NULL,
                      p_linenum             => x_linenum,
                      p_process_id          => p_process_id,
                      p_line_number         => p_line_number,
                      x_error_msg           => x_error_msg,
                      x_status              => x_status);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR in PROCESS_FUEL_CHARGES', sqlerrm);

    END PROCESS_FUEL_CHARGES;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_REGION_CHARGES
    --
    -- Purpose
    --
    -- IN Parameters
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_REGION_CHARGES(p_region_type IN  VARCHAR2,
                                     p_region_info IN  WSH_REGIONS_SEARCH_PKG.REGION_REC,
                                     p_charge      IN  NUMBER,
                                     p_process_id  IN  NUMBER,
                                     p_line_number IN  NUMBER,
                                     p_region_id   IN  NUMBER,
                                     x_linenum     IN  OUT NOCOPY NUMBER,
                                     x_error_msg   OUT NOCOPY VARCHAR2,
                                     x_status      OUT NOCOPY NUMBER) IS
    l_description      VARCHAR2(300);
    l_zone_id          NUMBER;
    l_type             VARCHAR2(30);
    l_subtype          VARCHAR2(50);
    l_attribute_value  VARCHAR2(50);
    l_attribute_type   VARCHAR2(50);
    l_context          VARCHAR2(30);

    l_rate_line_data         FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl    FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name    CONSTANT VARCHAR2(100) := 'FTE.PLSQL.'||G_PKG_NAME||'.PROCESS_REGION_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (p_region_id IS NOT NULL) THEN
            l_zone_id := p_region_id;
        ELSE
            l_zone_id := FTE_REGION_ZONE_LOADER.GET_REGION_ID(p_region_info => p_region_info);
        END IF;

        IF (l_zone_id IS NULL OR l_zone_id = -1) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_REGION_NOT_FOUND');
            FTE_UTIL_PKG.Write_OutFile(p_msg          => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'D',
                                       p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        x_linenum := x_linenum + 1;
        l_description := p_region_type || ' Surcharge Line ' || x_linenum;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Zone Id', l_zone_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, l_description);
        END IF;


        l_type := 'ACCESSORIAL_SURCHARGE';

        IF (p_region_type = 'ORIGIN') THEN
            l_subtype  := FTE_RTG_GLOBALS.G_C_ORIGIN_SURCHRG;
        ELSIF (p_region_type = 'DESTINATION') THEN
            l_subtype  := FTE_RTG_GLOBALS.G_C_DESTINATION_SURCHRG;
        END IF;

        l_rate_line_data('ACTION')     := G_ACTION;
        l_rate_line_data('LINE_NUMBER'):= x_linenum;
        l_rate_line_data('DESCRIPTION'):= l_description;
        l_rate_line_data('VOLUME_TYPE'):= 'TOTAL_QUANTITY';
        l_rate_line_data('SUBTYPE')    := l_subtype;
        l_rate_line_data('TYPE')       := l_type;
        l_rate_line_data('FIXED_RATE') := Fnd_Number.Number_To_Canonical(p_charge);
        l_rate_line_data('UOM')        := g_unit_uom;

        l_rate_line_block_tbl(1) := l_rate_line_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                p_block_data    => l_rate_line_block_tbl,
                                                p_line_number   => p_line_number,
                                                p_validate_column => FALSE,
                                                x_status        => x_status,
                                                x_error_msg     => x_error_msg);
        l_rate_line_data.DELETE;
        l_rate_line_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        l_context       := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;
        l_attribute_type  := 'TL_RATE_TYPE';
        l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;

        ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                      p_attribute_value     => l_attribute_value,
                      p_attribute_value_to  => NULL,
                      p_context             => l_context,
                      p_comp_operator       => NULL,
                      p_linenum             => x_linenum,
                      p_process_id          => p_process_id,
                      p_line_number         => p_line_number,
                      x_error_msg           => x_error_msg,
                      x_status              => x_status);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        -- Add Region Attribute
        l_attribute_type := p_region_type || '_ZONE_ID';

        IF (p_region_type = 'ORIGIN') THEN
            l_context  := FTE_RTG_GLOBALS.G_AX_ORIGIN_ZONE;
        ELSIF (p_region_type = 'DESTINATION') THEN
            l_context  := FTE_RTG_GLOBALS.G_AX_DESTINATION_ZONE;
        END IF;

        ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                       p_attribute_value     => Fnd_Number.Number_To_Canonical(l_zone_id),
                       p_attribute_value_to  => NULL,
                       p_context             => l_context,
                       p_comp_operator       => NULL,
                       p_linenum             => x_linenum,
                       p_process_id          => p_process_id,
                       p_line_number         => p_line_number,
                       x_error_msg           => x_error_msg,
                       x_status              => x_status);

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            x_error_msg := sqlerrm;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXP. ERROR in Process_Region_Charges',sqlerrm);

    END PROCESS_REGION_CHARGES;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_STOPOFF_CHARGES
    --
    -- PURPOSE . Processing for stop off charges is being done here.
    --           Called by PROCESS_CHART_CHARGES.
    --
    -- Parameters
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_STOPOFF_CHARGES(p_break_charges  IN  STRINGARRAY,
                                      p_num_free_stops IN  NUMBER,
                                      p_process_id     IN  NUMBER,
                                      x_linenum        IN  OUT NOCOPY NUMBER,
                                      p_line_number    IN  NUMBER,
                                      x_error_msg      OUT NOCOPY VARCHAR2,
                                      x_status         OUT NOCOPY NUMBER) IS

    l_break_charges       STRINGARRAY;
    l_break_limits        STRINGARRAY := STRINGARRAY();
    l_subtype             VARCHAR2(30);
    l_type                VARCHAR2(30);
    l_rate_type           VARCHAR2(30);
    l_break_type          VARCHAR2(30);
    l_break_start         NUMBER;
    l_description         VARCHAR2(300);
    l_context             VARCHAR2(50);
    l_attribute_value     VARCHAR2(50);
    l_attribute_type      VARCHAR2(50);

    l_rate_line_data        FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl   FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_STOPOFF_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_break_charges := p_break_charges;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_num_free_stops', p_num_free_stops);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_process_id    ', p_process_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'x_linenum       ', x_linenum);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_line_number   ', p_line_number);

            FOR i IN 1..l_break_charges.COUNT LOOP
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_break_charges(' || i || ')', l_break_charges(i));
            END LOOP;

        END IF;

        --+
        --  Remove any NULL breaks
        --  If any of the stop off charges are NULL, we delete the remaining breaks are also.
        --  But, check additional stop off charges, which is the last element in the STRINGARRAY.
        --+
        FOR i IN 1..l_break_charges.COUNT LOOP

        IF (l_break_charges(i) IS NULL) THEN
                IF (l_break_charges(l_break_charges.COUNT) IS NULL) THEN
                    l_break_charges.DELETE(i, l_break_charges.COUNT);
                ELSE
                    l_break_charges(i) := l_break_charges(l_break_charges.COUNT);
                    l_break_charges.DELETE(i+1, l_break_charges.COUNT);
                END IF;
                EXIT;
            END IF;

        END LOOP;

        IF (p_num_free_stops IS NULL OR p_num_free_stops <= 0) THEN
            l_break_charges.DELETE(1);
            l_break_start := 1;
        ELSE
            l_break_start := p_num_free_stops;
        END IF;

        IF (l_break_charges.COUNT > 0) THEN
            x_linenum := x_linenum + 1;
            l_description := 'Stop Off Charge: Line ' || x_linenum;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, l_description, l_description);
            END IF;

            l_type       := 'ACCESSORIAL_SURCHARGE';
            l_rate_type  := 'LUMPSUM';
            l_break_type := 'RANGE';
            l_subtype    := FTE_RTG_GLOBALS.G_C_STOP_OFF_CH;

            l_rate_line_data('ACTION')         := G_ACTION;
            l_rate_line_data('LINE_NUMBER')    := x_linenum;
            l_rate_line_data('DESCRIPTION')    := l_description;
            l_rate_line_data('VOLUME_TYPE')    := 'TOTAL_QUANTITY';
            l_rate_line_data('RATE_BREAK_TYPE'):= l_break_type;
            l_rate_line_data('SUBTYPE')        := l_subtype;
            l_rate_line_data('TYPE')           := l_type;
            l_rate_line_data('RATE_TYPE')      := l_rate_type;
            l_rate_line_data('UOM')            := g_unit_uom;

            l_rate_line_block_tbl(1) := l_rate_line_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                    p_block_data    => l_rate_line_block_tbl,
                                                    p_line_number   => p_line_number,
                                                    p_validate_column => FALSE,
                                                    x_status        => x_status,
                                                    x_error_msg     => x_error_msg);
            l_rate_line_data.DELETE;
            l_rate_line_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Add Rate Type Attribute
            --+
            l_attribute_type  := 'TL_RATE_TYPE';
            l_context         := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;
            l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_LOAD;

            ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                          p_attribute_value     => l_attribute_value,
                          p_attribute_value_to  => NULL,
                          p_context             => l_context,
                          p_linenum             => x_linenum,
                          p_comp_operator       => '=',
                          p_process_id          => p_process_id,
                          p_line_number         => p_line_number,
                          x_error_msg           => x_error_msg,
                          x_status              => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error', x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- create the break limits
            --+
            l_break_limits.EXTEND;
            l_break_limits(1) := Fnd_Number.Number_To_Canonical(l_break_start);

            FOR i IN 2..l_break_charges.COUNT LOOP
                l_break_limits.EXTEND;
                l_break_limits(i) := Fnd_Number.Number_To_Canonical(Fnd_Number.Canonical_To_Number(l_break_limits(i-1)) + 1);
            END LOOP;

            l_break_limits(l_break_limits.COUNT) := g_max_number;

            --+
            -- Create Breaks
            --+
            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Begin Create Breaks');
            END IF;

            CREATE_BREAKS(p_break_charges    => l_break_charges,
                          p_break_limits     => l_break_limits,
                          p_break_start      => Fnd_Number.Canonical_To_Number('0'),
                          p_break_gap        => Fnd_Number.Canonical_To_Number('0'),
                          p_rate_type        => l_rate_type,
                          p_attribute_type   => 'TL_NUM_STOPS',
                          p_process_id       => p_process_id,
                          x_linenum          => x_linenum,
                          x_error_msg        => x_error_msg,
                          x_status           => x_status);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Unexpected Error in PROCESS_STOP_OFF_CHARGES',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_STOPOFF_CHARGES;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_LOADING_CHARGES
    --
    -- Purpose
    --
    -- PARAMETERS
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_LOADING_CHARGES(p_min_charge     IN  NUMBER,
                                      p_charge         IN  NUMBER,
                                      p_load_type      IN  VARCHAR2,
                                      p_basis          IN  VARCHAR2,
                                      p_basis_uom      IN  VARCHAR2,
                                      p_process_id     IN  NUMBER,
                                      x_linenum        IN  OUT NOCOPY NUMBER,
                                      p_line_number    IN  NUMBER,
                                      x_error_msg      OUT NOCOPY VARCHAR2,
                                      x_status         OUT NOCOPY NUMBER) IS
    l_subtype          VARCHAR2(30);
    l_subtype_min      VARCHAR2(30);
    l_subtype2         VARCHAR2(30);
    l_type             VARCHAR2(30);
    l_rate             NUMBER;
    l_rate_type        VARCHAR2(30);
    l_break_type       VARCHAR2(30);
    l_description      VARCHAR2(300);
    l_context          VARCHAR2(50);
    l_flat_rate        BOOLEAN := FALSE;
    l_min_break        BOOLEAN := FALSE;

    -- attributes
    l_attr1_type       VARCHAR2(50);
    l_attr2_type       VARCHAR2(50);
    l_attr3_type       VARCHAR2(50);
    l_attr1_value      VARCHAR2(50);
    l_attr2_value      VARCHAR2(50);
    l_attr3_value      VARCHAR2(50);
    l_attr1_context    VARCHAR2(50);
    l_attr2_context    VARCHAR2(50);
    l_attr3_context    VARCHAR2(50);
    l_attr_value_from  VARCHAR2(50);
    l_attr_value_to    VARCHAR2(50);

    l_rate_line_data       FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl  FTE_BULKLOAD_PKG.block_data_tbl;

    l_rate_break_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_break_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_LOADING_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_type            := 'ACCESSORIAL_SURCHARGE';
        l_attr1_type      := 'TL_RATE_TYPE';
        l_attr1_context   := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;

        l_attr3_type      := 'LOADING_PROTOCOL';
        l_attr3_context   := FTE_RTG_GLOBALS.G_AX_LOADING_PROTOCOL;

        -- TL handling only deals with weight and volume
        IF (p_load_type = 'HANDLING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_LOAD;
            l_attr3_value := 'CARRIER';
            l_subtype_min     := FTE_RTG_GLOBALS.G_C_MIN_HANDLING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_HANDLING_WEIGHT_CH;
                l_attr2_type    := 'TL_HANDLING_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_HANDLING_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_HANDLING_VOLUME_CH;
                l_attr2_type    := 'TL_HANDLING_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_HANDLING_VOL;
            ELSIF (p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_HANDLING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;
        ELSIF (p_load_type = 'FACILITY_HANDLING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'FACILITY';
            l_subtype_min     := FTE_RTG_GLOBALS.G_F_MIN_HANDLING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_HANDLING_WEIGHT_CH;
                l_attr2_type    := 'FAC_HANDLING_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_HANDLING_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_HANDLING_VOLUME_CH;
                l_attr2_type    := 'FAC_HANDLING_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_HANDLING_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_HANDLING_PALLET_CH;
                l_attr2_type    := 'FAC_HANDLING_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_HANDLING_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_HANDLING_CONTAINER_CH;
                l_attr2_type    := 'FAC_HANDLING_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_HANDLING_CONTAINER;
            ELSIF (p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_HANDLING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'UNLOADING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
            l_attr3_value := 'CARRIER';
            l_subtype_min     := FTE_RTG_GLOBALS.G_C_MIN_UNLOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_UNLOADING_WEIGHT_CH;
                l_attr2_type    := 'TL_DROPOFF_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_UNLOADING_VOLUME_CH;
                l_attr2_type    := 'TL_DROPOFF_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_UNLOADING_PALLET_CH;
                l_attr2_type    := 'TL_DROPOFF_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_UNLOADING_CONTAINER_CH;
                l_attr2_type    := 'TL_DROPOFF_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_UNLOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'FACILITY_UNLOADING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'FACILITY';
            l_subtype_min     := FTE_RTG_GLOBALS.G_F_MIN_UNLOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_UNLOADING_WEIGHT_CH;
                l_attr2_type    := 'FAC_DROPOFF_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_UNLOADING_VOLUME_CH;
                l_attr2_type    := 'FAC_DROPOFF_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_UNLOADING_PALLET_CH;
                l_attr2_type    := 'FAC_DROPOFF_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_UNLOADING_CONTAINER_CH;
                l_attr2_type    := 'FAC_DROPOFF_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_UNLOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'ASSISTED_UNLOADING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_C_MIN_AST_UNLOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_UNLOADING_WEIGHT_CH;
                l_attr2_type    := 'TL_DROPOFF_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_UNLOADING_VOLUME_CH;
                l_attr2_type    := 'TL_DROPOFF_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_UNLOADING_PALLET_CH;
                l_attr2_type    := 'TL_DROPOFF_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_UNLOADING_CONTAINER_CH;
                l_attr2_type    := 'TL_DROPOFF_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_DROPOFF_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_AST_UNLOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'FACILITY_ASSISTED_UNLOADING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_F_MIN_AST_UNLOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_UNLOADING_WEIGHT_CH;
                l_attr2_type    := 'FAC_DROPOFF_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_UNLOADING_VOLUME_CH;
                l_attr2_type    := 'FAC_DROPOFF_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_UNLOADING_PALLET_CH;
                l_attr2_type    := 'FAC_DROPOFF_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_UNLOADING_CONTAINER_CH;
                l_attr2_type    := 'FAC_DROPOFF_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_DROPOFF_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_AST_UNLOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'LOADING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
            l_attr3_value := 'CARRIER';
            l_subtype_min     := FTE_RTG_GLOBALS.G_C_MIN_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_LOADING_WEIGHT_CH;
                l_attr2_type    := 'TL_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_LOADING_VOLUME_CH;
                l_attr2_type    := 'TL_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_LOADING_PALLET_CH;
                l_attr2_type    := 'TL_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_LOADING_CONTAINER_CH;
                l_attr2_type    := 'TL_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'FACILITY_LOADING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'FACILITY';
            l_subtype_min := FTE_RTG_GLOBALS.G_F_MIN_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_LOADING_WEIGHT_CH;
                l_attr2_type    := 'FAC_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_LOADING_VOLUME_CH;
                l_attr2_type    := 'FAC_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_LOADING_PALLET_CH;
                l_attr2_type    := 'FAC_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_LOADING_CONTAINER_CH;
                l_attr2_type    := 'FAC_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'ASSISTED_LOADING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_C_MIN_AST_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_WEIGHT_CH;
                l_attr2_type    := 'TL_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_VOLUME_CH;
                l_attr2_type    := 'TL_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_PALLET_CH;
                l_attr2_type    := 'TL_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_CONTAINER_CH;
                l_attr2_type    := 'TL_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_AST_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'FACILITY_ASSISTED_LOADING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_F_MIN_AST_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_WEIGHT_CH;
                l_attr2_type    := 'FAC_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_VOLUME_CH;
                l_attr2_type    := 'FAC_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_PALLET_CH;
                l_attr2_type    := 'FAC_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_CONTAINER_CH;
                l_attr2_type    := 'FAC_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_AST_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'ASSISTED_LOADING') THEN
            l_attr1_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_C_MIN_AST_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_WEIGHT_CH;
                l_attr2_type    := 'TL_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_VOLUME_CH;
                l_attr2_type    := 'TL_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_PALLET_CH;
                l_attr2_type    := 'TL_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_C_AST_LOADING_CONTAINER_CH;
                l_attr2_type    := 'TL_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_TL_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_C_AST_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;

        ELSIF (p_load_type = 'FACILITY_ASSISTED_LOADING') THEN
            l_attr1_value := 'FACILITY_CHARGE';
            l_attr3_value := 'JOINT';
            l_subtype_min := FTE_RTG_GLOBALS.G_F_MIN_AST_LOADING_CH;

            IF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_WEIGHT_CH;
                l_attr2_type    := 'FAC_PICKUP_WT';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_WT;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_VOLUME_CH;
                l_attr2_type    := 'FAC_PICKUP_VOL';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_VOL;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_PALLET_CH;
                l_attr2_type    := 'FAC_PICKUP_PALLET';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_PALLET;
            ELSIF (p_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_subtype       := FTE_RTG_GLOBALS.G_F_AST_LOADING_CONTAINER_CH;
                l_attr2_type    := 'FAC_PICKUP_CONTAINER';
                l_attr2_context := FTE_RTG_GLOBALS.G_AX_FAC_PICKUP_CONTAINER;
            ELSIF(p_basis = 'FLAT') THEN
                l_flat_rate  := TRUE;
                l_subtype    := FTE_RTG_GLOBALS.G_F_AST_LOADING_FLAT_CH;
            ELSE
                x_status := 3;
            END IF;
        END IF;

        IF (x_status = 3) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_INVALID_BASIS',
                                                p_tokens => STRINGARRAY('BASIS','LOAD'),
                                                p_values => STRINGARRAY(p_basis,p_load_type));
            FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => p_line_number );
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
        END IF;

        --+
        -- Cannot Have Flat Rate With Minimum Charges
        --+
        IF (l_flat_rate AND (p_min_charge IS NOT NULL)) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_FLAT_CANT_HAVE_MIN');
            FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                         p_module_name => l_module_name,
                                         p_category    => 'D',
                                         p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;
        --+
        -- Find out if you need to create breaks.
        --+
        IF (p_charge IS NOT NULL AND p_min_charge IS NOT NULL) THEN
            l_min_break := TRUE;
        END IF;

        IF (l_flat_rate) THEN
            l_rate        := p_charge;
            l_rate_type   := 'LUMPSUM';
        ELSE
            l_rate        := NULL;
            l_break_type  := 'POINT';
            l_rate_type   := 'FIXED';
        END IF;

        x_linenum := x_linenum + 1;
        l_description := p_load_type || ' : Line ' || x_linenum;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, l_description);
        END IF;

        l_rate_line_data('ACTION')      := G_ACTION;
        l_rate_line_data('LINE_NUMBER') := x_linenum;
        l_rate_line_data('DESCRIPTION') := l_description;
        l_rate_line_data('RATE')        := Fnd_Number.Number_To_Canonical(l_rate);
        l_rate_line_data('UOM')         := g_unit_uom;
        l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
        l_rate_line_data('TYPE')        := l_type;
        l_rate_line_data('RATE_TYPE')   := l_rate_type;
        l_rate_line_data('SUBTYPE')     := l_subtype;
        l_rate_line_data('RATE_BREAK_TYPE')  := l_break_type;

        l_rate_line_block_tbl(1) := l_rate_line_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                p_block_data    => l_rate_line_block_tbl,
                                                p_line_number   => p_line_number,
                                                p_validate_column => FALSE,
                                                x_status        => x_status,
                                                x_error_msg     => x_error_msg);

        l_rate_line_data.DELETE;
        l_rate_line_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        -- Add the Charge Type attribute.
        IF (l_attr1_type IS NOT NULL AND l_context IS NULL) THEN
            ADD_ATTRIBUTE (p_attribute_type      => l_attr1_type,
                           p_attribute_value     => l_attr1_value,
                           p_attribute_value_to  => NULL,
                           p_context             => l_attr1_context,
                           p_linenum             => x_linenum,
                           p_comp_operator       => '=',
                           p_process_id          => p_process_id,
                           p_line_number         => p_line_number,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);

        END IF;

        -- Add the Loading_Protocol Attribute
        IF (p_load_type NOT IN ('HANDLING', 'FACILITY_HANDLING')) THEN
            ADD_ATTRIBUTE (p_attribute_type      => l_attr3_type,
                           p_attribute_value     => l_attr3_value,
                           p_attribute_value_to  => NULL,
                           p_context             => l_attr3_context,
                           p_linenum             => x_linenum,
                           p_comp_operator       => NULL,
                           p_process_id          => p_process_id,
                           p_line_number         => p_line_number,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);
        END IF;

        -- Add additional attributes for loading, unloading, handling if flat rate basis
        IF (p_basis IN ('FLAT')) THEN
            IF (p_load_type IN ('LOADING', 'FACILITY_LOADING','ASSISTED_LOADING', 'FACILITY_ASSISTED_LOADING')) THEN

                ADD_ATTRIBUTE (p_attribute_type      => 'TL_STOP_LOADING_ACT',
                               p_attribute_value     => 'Y',
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_TL_STOP_LOADING_ACT,
                               p_linenum             => x_linenum,
                               p_comp_operator       => '=',
                               p_process_id          => p_process_id,
                               p_line_number         => p_line_number,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

            ELSIF (p_load_type IN ('UNLOADING', 'FACILITY_UNLOADING','ASSISTED_UNLOADING', 'FACILITY_ASSISTED_UNLOADING')) THEN

                ADD_ATTRIBUTE ( p_attribute_type      => 'TL_STOP_UNLOADING_ACT',
                                p_attribute_value     => 'Y',
                                p_attribute_value_to  => NULL,
                                p_context             => FTE_RTG_GLOBALS.G_AX_TL_STOP_UNLOADING_ACT,
                                p_linenum             => x_linenum,
                                p_comp_operator       => '=',
                                p_process_id          => p_process_id,
                                p_line_number         => p_line_number,
                                x_error_msg           => x_error_msg,
                                x_status              => x_status);

            ELSIF (p_load_type IN ('HANDLING', 'FACILITY_HANDLING')) THEN

                ADD_ATTRIBUTE (p_attribute_type      => 'TL_HANDLING_ACT',
                               p_attribute_value     => 'Y',
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_TL_HANDLING_ACT,
                               p_linenum             => x_linenum,
                               p_comp_operator       => '=',
                               p_process_id          => p_process_id,
                               p_line_number         => p_line_number,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

            END IF;
        END IF;

        --+
        -- For Non-Flat Charge basis, we have to add breaks for block unit pricing.
        --+
        IF (NOT l_flat_rate) THEN

            -- Add Break 1
            l_attr_value_from := 0;
            IF (NOT l_min_break) THEN
                l_attr_value_to  := g_max_number;
                l_rate           := p_charge;
                l_subtype2       := l_subtype;
                l_rate_type      := 'BLOCK_UNIT';
            ELSE
                l_attr_value_to  := Fnd_Number.Number_To_Canonical(ROUND(p_min_charge/p_charge, 1));
                l_rate           := p_min_charge;
                l_subtype2       := l_subtype_min;
                l_rate_type      := 'LUMPSUM';
            END IF;

            x_linenum := x_linenum + 1;

            l_rate_break_data('ACTION')     := G_ACTION;
            l_rate_break_data('LINE_NUMBER'):= x_linenum;
            l_rate_break_data('LOWER_LIMIT'):= 0;
            l_rate_break_data('UPPER_LIMIT'):= l_attr_value_to;
            l_rate_break_data('RATE')       := Fnd_Number.Number_To_Canonical(l_rate);
            l_rate_break_data('RATE_TYPE')  := l_rate_type;
            l_rate_break_data('ATTRIBUTE')  := l_attr2_type;
            l_rate_break_data('TYPE')       := l_type;
            l_rate_break_data('SUBTYPE')    := l_subtype2;

            l_rate_break_block_tbl(1) := l_rate_break_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header  => g_dummy_block_hdr_tbl,
                                                     p_block_data    => l_rate_break_block_tbl ,
                                                     p_line_number   => p_line_number,
                                                     p_validate_column => FALSE,
                                                     x_status        => x_status,
                                                     x_error_msg     => x_error_msg);

            l_rate_break_data.DELETE;
            l_rate_break_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            -- Break 2
            IF (l_min_break) THEN
                x_linenum         := x_linenum + 1;
                l_attr_value_from := Fnd_Number.Canonical_To_Number(l_attr_value_to);
                l_attr_value_to   := g_max_number;
                l_rate            := p_charge;
                l_rate_type       := 'BLOCK_UNIT';

                l_rate_break_data('ACTION')     := G_ACTION;
                l_rate_break_data('LINE_NUMBER'):= x_linenum;
                l_rate_break_data('LOWER_LIMIT'):= Fnd_Number.Number_To_Canonical(l_attr_value_from);
                l_rate_break_data('UPPER_LIMIT'):= Fnd_Number.Number_To_Canonical(l_attr_value_to);
                l_rate_break_data('RATE')       := Fnd_Number.Number_To_Canonical(l_rate);
                l_rate_break_data('RATE_TYPE')  := l_rate_type;
                l_rate_break_data('ATTRIBUTE')  := l_attr2_type;
                l_rate_break_data('TYPE')       := l_type;
                l_rate_break_data('SUBTYPE')    := l_subtype;

                l_rate_break_block_tbl(1) := l_rate_break_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header  => g_dummy_block_hdr_tbl,
                                                         p_block_data    => l_rate_break_block_tbl,
                                                         p_line_number   => p_line_number,
                                                         p_validate_column => FALSE,
                                                         x_status        => x_status,
                                                         x_error_msg     => x_error_msg);

                l_rate_break_data.DELETE;
                l_rate_break_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Error: ' || x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);
    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Process_Loading_Charges Error: ' || sqlerrm);

    End PROCESS_LOADING_CHARGES;

    --_________________________________________________________________________________--
    --
    -- PROCEDURE: PROCESS_BLOCK_UNIT_CHARGES
    --
    -- Purpose Process block unit charges that do not have a minimum charge.
    --
    -- Parameters
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_BLOCK_UNIT_CHARGES(p_charge      IN  NUMBER,
                                         p_subtype     IN  VARCHAR2,
                                         p_uom         IN  VARCHAR2,
                                         p_process_id  IN  NUMBER,
                                         x_linenum     IN  OUT NOCOPY NUMBER,
                                         p_line_number IN  NUMBER,
                                         x_error_msg   OUT NOCOPY VARCHAR2,
                                         x_status      OUT NOCOPY NUMBER) IS

    l_type             VARCHAR2(30);
    l_break_type       VARCHAR2(30);
    l_description      VARCHAR2(300);
    l_context          VARCHAR2(50);
    l_attribute_value  VARCHAR2(50);
    l_attribute_type   VARCHAR2(50);
    l_attr_value_to    VARCHAR2(50);
    l_rate_type        VARCHAR2(25);
    l_volume_type      VARCHAR2(25);
    l_subtype          VARCHAR2(30);

    l_rate_line_data       FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_break_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl  FTE_BULKLOAD_PKG.block_data_tbl;
    l_rate_break_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name      CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_BLOCK_UNIT_CHARGES';

    BEGIN
        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        x_linenum    := x_linenum + 1;
        l_type       := 'ACCESSORIAL_SURCHARGE';
        l_break_type := 'POINT';
        l_rate_type  := 'FIXED';
        l_volume_type:= 'TOTAL_QUANTITY';

        IF (p_subtype = FTE_RTG_GLOBALS.G_C_OUT_OF_ROUTE_CH) THEN
            l_description := 'Out Of Route Charge: Line ' || x_linenum;
        ELSIF (p_subtype = FTE_RTG_GLOBALS.G_C_WEEKDAY_LAYOVER_CH) THEN
            l_description := 'Weekday Layover Charge: Line ' || x_linenum;
        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_description', l_description);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_type       ', l_type);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_break_type ', l_break_type);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'p_subtype    ', p_subtype);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_type  ', l_rate_type);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_volume_type', l_volume_type);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_unit_uom   ', g_unit_uom);
        END IF;

        l_rate_line_data('ACTION')      := G_ACTION;
        l_rate_line_data('LINE_NUMBER') := x_linenum;
        l_rate_line_data('DESCRIPTION') := l_description;
        l_rate_line_data('UOM')         := g_unit_uom;
        l_rate_line_data('VOLUME_TYPE') := l_volume_type;
        l_rate_line_data('TYPE')        := l_type;
        l_rate_line_data('RATE_TYPE')   := l_rate_type;
        l_rate_line_data('SUBTYPE')     := p_subtype;
        l_rate_line_data('RATE_BREAK_TYPE') := l_break_type;

        l_rate_line_block_tbl(1) := l_rate_line_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                p_block_data    => l_rate_line_block_tbl,
                                                p_line_number   => p_line_number,
                                                p_validate_column => FALSE,
                                                x_status        => x_status,
                                                x_error_msg     => x_error_msg);

        l_rate_line_data.DELETE;
        l_rate_line_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        -- add Rate Type Attribute
        l_attribute_type  := 'TL_RATE_TYPE';
        l_context         := FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE;

        IF (p_subtype = FTE_RTG_GLOBALS.G_C_OUT_OF_ROUTE_CH) THEN
            l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_LOAD;
        ELSIF (p_subtype = FTE_RTG_GLOBALS.G_C_WEEKDAY_LAYOVER_CH) THEN
            l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
        END IF;

        IF (l_attribute_type IS NOT NULL AND l_context IS NOT NULL) THEN
            ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                           p_attribute_value     => l_attribute_value,
                           p_attribute_value_to  => NULL,
                           p_context             => l_context,
                           p_comp_operator       => '=',
                           p_linenum             => x_linenum,
                           p_process_id          => p_process_id,
                           p_line_number         => p_line_number,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);
        END IF;

        -- Add Charge Type Attribute
        IF (p_subtype = FTE_RTG_GLOBALS.G_C_OUT_OF_ROUTE_CH) THEN
            l_attribute_type := 'TL_CHARGED_OUT_RT_DISTANCE';
            l_context        := FTE_RTG_GLOBALS.G_AX_TL_CHARGED_OUT_RT_DIST;

        ELSIF (p_subtype = FTE_RTG_GLOBALS.G_C_WEEKDAY_LAYOVER_CH) THEN
            l_attribute_type := 'TL_NUM_WEEKDAY_LAYOVERS';
            l_context        := FTE_RTG_GLOBALS.G_AX_TL_NUM_WEEKDAY_LAYOVERS;
        END IF;


        -- NOTE: attributes with context VOLUME should not be put on the PBH.

        -- break
        x_linenum := x_linenum + 1;

        l_rate_break_data('ACTION')     := G_ACTION;
        l_rate_break_data('LINE_NUMBER'):= x_linenum;
        l_rate_break_data('LOWER_LIMIT'):= 0;
        l_rate_break_data('UPPER_LIMIT'):= FTE_UTIL_PKG.Canonicalize_Number(g_max_number);
        l_rate_break_data('RATE')       := p_charge;
        l_rate_break_data('RATE_TYPE')  := 'BLOCK_UNIT';
        l_rate_break_data('ATTRIBUTE')  := l_attribute_type;
        l_rate_break_data('TYPE')       := l_type;
        l_rate_break_data('SUBTYPE')    := l_subtype;
        l_rate_break_data('CONTEXT')    := l_context;

        l_rate_break_block_tbl(1) := l_rate_break_data;

        FTE_RATE_CHART_LOADER.PROCESS_RATE_BREAK(p_block_header  => g_dummy_block_hdr_tbl,
                                                 p_block_data    => l_rate_break_block_tbl,
                                                 p_line_number   => p_line_number,
                                                 p_validate_column => FALSE,
                                                 x_status        => x_status,
                                                 x_error_msg     => x_error_msg);

        l_rate_break_data.DELETE;
        l_rate_break_block_tbl.DELETE;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Process_Block_Unit_Charges Error',sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_BLOCK_UNIT_CHARGES;

    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_CHART_SURCHARGES
    --
    -- PURPOSE:
    --
    -- PARAMETERS
    --  IN
    --   p_values:      An Associative array of data with header as key.
    --   p_chart_type   rate chart type, may be TL_MODIFIER...
    --   p_process_id   the load id of the current process
    --   p_line_number  line number in the file, used for error logging
    --   p_doValidate   to indicate whether the validations to be done or not.
    --                  From UI, this takes the value of FALSE. Defaulted to TRUE.
    --
    --  IN OUT
    --   x_linenum
    --
    --  OUT
    --    x_status,  the return status, -1 for success
    --                                   2 for failure.
    --    x_error_msg, the corresponding error message,
    --                 if any exception occurs during the process.
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_CHART_SURCHARGES (p_values      IN   FTE_BULKLOAD_PKG.data_values_tbl,
                                        p_chart_type  IN   VARCHAR2,
                                        p_process_id  IN   NUMBER,
                                        p_line_number IN   NUMBER,
                                        p_doValidate  IN   BOOLEAN DEFAULT TRUE,
                                        x_linenum     IN   OUT  NOCOPY NUMBER,
                                        x_error_msg   OUT  NOCOPY VARCHAR2,
                                        x_status      OUT  NOCOPY NUMBER  ) IS

    l_module_name CONSTANT VARCHAR2(100) := 'FTE.PLSQL.'||G_PKG_NAME||'.PROCESS_CHART_SURCHARGES';

    l_num_free_stops               NUMBER;
    l_stop_chg_1                   NUMBER;
    l_stop_chg_2                   NUMBER;
    l_stop_chg_3                   NUMBER;
    l_stop_chg_4                   NUMBER;
    l_stop_chg_5                   NUMBER;
    l_stop_chg_x                   NUMBER;
    l_out_rt_chg                   NUMBER;
    l_handling_chg                 NUMBER;
    l_min_handling_chg             NUMBER;
    l_ld_chg                       NUMBER;
    l_min_ld_chg                   NUMBER;
    l_asst_ld_chg                  NUMBER;
    l_unld_chg                     NUMBER;
    l_min_unld_chg                 NUMBER;
    l_asst_unld_chg                NUMBER;
    l_min_asst_unld_chg            NUMBER;
    l_min_asst_ld_chg              NUMBER;
    l_cont_mv_dsct_prcnt           NUMBER;
    l_wkday_layovr_chg             NUMBER;
    l_out_rt_chg_uom               VARCHAR2(20);
    l_rate_basis                   VARCHAR2(20);
    l_rate_basis_uom               VARCHAR2(20);
    l_break_type                   VARCHAR2(30);
    l_break_charges                STRINGARRAY;
    l_attribute_type               VARCHAR2(50);
    l_attribute_value              VARCHAR2(50);
    l_context                      VARCHAR2(50);
    l_load_type_prefix             VARCHAR2(30);
    l_description                  VARCHAR2(100);
    l_type                         VARCHAR2(50);
    l_subtype                      VARCHAR2(50);
    l_carrier_name                 VARCHAR2(100);
    l_service_level                VARCHAR2(30);

    l_rate_line_data      FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_block_tbl FTE_BULKLOAD_PKG.block_data_tbl;

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        l_carrier_name      := FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', p_values);
        l_num_free_stops    := FTE_UTIL_PKG.GET_DATA('NUMBER_OF_FREE_STOPS', p_values);
        l_rate_basis        := FTE_UTIL_PKG.GET_DATA('BASIS_FOR_HANDLING_LOADING_UNLOADING_CHARGES', p_values);
        l_rate_basis_uom    := FTE_UTIL_PKG.GET_DATA('UOM_FOR_HANDLING_LOADING_UNLOADING_CHARGE_BASIS', p_values);
        l_out_rt_chg_uom    := FTE_UTIL_PKG.GET_DATA('OUT_OF_ROUTE_CHARGE_BASIS_UOM', p_values);
        l_stop_chg_1        := FTE_UTIL_PKG.GET_DATA('FIRST_ADD_STOP_OFF_CHARGES', p_values );
        l_stop_chg_2        := FTE_UTIL_PKG.GET_DATA('SECOND_ADD_STOP_OFF_CHARGES', p_values);
        l_stop_chg_3        := FTE_UTIL_PKG.GET_DATA('THIRD_ADD_STOP_OFF_CHARGES', p_values);
        l_stop_chg_4        := FTE_UTIL_PKG.GET_DATA('FOURTH_ADD_STOP_OFF_CHARGES', p_values);
        l_stop_chg_5        := FTE_UTIL_PKG.GET_DATA('FIFTH_ADD_STOP_OFF_CHARGES', p_values);
        l_stop_chg_x        := FTE_UTIL_PKG.GET_DATA('ADDITIONAL_STOP_CHARGES',p_values);
        l_out_rt_chg        := FTE_UTIL_PKG.GET_DATA('OUT_OF_ROUTE_CHARGES',p_values);
        l_handling_chg      := FTE_UTIL_PKG.GET_DATA('HANDLING_CHARGES', p_values);
        l_min_handling_chg  := FTE_UTIL_PKG.GET_DATA('MINIMUM_HANDLING_CHARGES', p_values);
        l_ld_chg            := FTE_UTIL_PKG.GET_DATA('LOADING_CHARGES', p_values);
        l_min_ld_chg        := FTE_UTIL_PKG.GET_DATA('MINIMUM_LOADING_CHARGES', p_values);
        l_unld_chg          := FTE_UTIL_PKG.GET_DATA('UNLOADING_CHARGES', p_values);
        l_min_unld_chg      := FTE_UTIL_PKG.GET_DATA('MINIMUM_UNLOADING_CHARGES', p_values);
        l_asst_unld_chg     := FTE_UTIL_PKG.GET_DATA('ASSISTED_UNLOADING_CHARGES', p_values);
        l_min_asst_unld_chg := FTE_UTIL_PKG.GET_DATA('MINIMUM_ASSISTED_UNLOADING_CHARGES', p_values);
        l_asst_ld_chg       := FTE_UTIL_PKG.GET_DATA('ASSISTED_LOADING_CHARGES', p_values);
        l_min_asst_ld_chg   := FTE_UTIL_PKG.GET_DATA('MINIMUM_ASSISTED_LOADING_CHARGES', p_values);
        l_cont_mv_dsct_prcnt:= FTE_UTIL_PKG.GET_DATA('CONTINUOUS_MOVE_DISCOUNT_PERCENTAGE', p_values);
        l_wkday_layovr_chg  := FTE_UTIL_PKG.GET_DATA('WEEKDAY_LAYOVER_CHARGES', p_values);
        l_service_level     := FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL', p_values);

    IF (NOT p_doValidate) THEN
      l_service_level     := FTE_UTIL_PKG.GET_DATA('SERVICE_CODE', p_values);
    END IF;

        l_rate_basis := UPPER(l_rate_basis);

        BEGIN
            l_stop_chg_1        := Fnd_Number.Canonical_To_Number(l_stop_chg_1);
            l_stop_chg_2        := Fnd_Number.Canonical_To_Number(l_stop_chg_2);
            l_stop_chg_3        := Fnd_Number.Canonical_To_Number(l_stop_chg_3);
            l_stop_chg_4        := Fnd_Number.Canonical_To_Number(l_stop_chg_4);
            l_stop_chg_5        := Fnd_Number.Canonical_To_Number(l_stop_chg_5);
            l_stop_chg_x        := Fnd_Number.Canonical_To_Number(l_stop_chg_x);
            l_out_rt_chg        := Fnd_Number.Canonical_To_Number(l_out_rt_chg);
            l_handling_chg      := Fnd_Number.Canonical_To_Number(l_handling_chg);
            l_min_handling_chg  := Fnd_Number.Canonical_To_Number(l_min_handling_chg);
            l_ld_chg            := Fnd_Number.Canonical_To_Number(l_ld_chg);
            l_min_ld_chg        := Fnd_Number.Canonical_To_Number(l_min_ld_chg);
            l_unld_chg          := Fnd_Number.Canonical_To_Number(l_unld_chg);
            l_min_unld_chg      := Fnd_Number.Canonical_To_Number(l_min_unld_chg);
            l_asst_unld_chg     := Fnd_Number.Canonical_To_Number(l_asst_unld_chg);
            l_min_asst_unld_chg := Fnd_Number.Canonical_To_Number(l_min_asst_unld_chg);
            l_asst_ld_chg       := Fnd_Number.Canonical_To_Number(l_asst_ld_chg);
            l_min_asst_ld_chg   := Fnd_Number.Canonical_To_Number(l_min_asst_ld_chg);
            l_cont_mv_dsct_prcnt:= Fnd_Number.Canonical_To_Number(l_cont_mv_dsct_prcnt);
            l_wkday_layovr_chg  := Fnd_Number.Canonical_To_Number(l_wkday_layovr_chg);
        EXCEPTION
            WHEN OTHERS THEN
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Unexcepted Error ', sqlerrm);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
        END;

        IF ( p_doValidate ) THEN
            IF (p_chart_type <> 'FAC_MODIFIER') THEN
                l_service_level := FTE_VALIDATION_PKG.VALIDATE_SERVICE_LEVEL(p_carrier_id    => NULL,
                                                                             p_carrier_name  => l_carrier_name,
                                                                             p_service_level => l_service_level,
                                                                             p_line_number   => p_line_number,
                                                                             x_error_msg     => x_error_msg,
                                                                             x_status        => x_status);
                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;
        END IF;

        IF (l_out_rt_chg < 0         OR l_stop_chg_1 < 0 OR l_handling_chg < 0 OR
            l_asst_unld_chg < 0      OR l_stop_chg_2 < 0 OR l_min_handling_chg < 0 OR
            l_min_asst_unld_chg < 0  OR l_stop_chg_3 < 0 OR l_min_ld_chg < 0 OR
            l_min_asst_ld_chg < 0    OR l_stop_chg_4 < 0 OR l_ld_chg < 0 OR
            l_asst_ld_chg < 0        OR l_stop_chg_5 < 0 OR l_unld_chg < 0 OR
            l_cont_mv_dsct_prcnt < 0 OR l_stop_chg_x < 0 OR l_min_unld_chg < 0 OR
            l_wkday_layovr_chg < 0 ) THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                p_tokens => STRINGARRAY('ENTITY'),
                                                p_values => STRINGARRAY('Charge'));
            FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN

            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Validating Modifier for Process ID ' || p_process_id);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, '-------------------------------------------');
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_num_free_stops ',l_num_free_stops);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_1     ',l_stop_chg_1);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_2     ',l_stop_chg_2);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_3     ',l_stop_chg_3);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_4     ',l_stop_chg_4);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_5     ',l_stop_chg_5);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_stop_chg_x     ',l_stop_chg_x);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_out_rt_chg     ',l_out_rt_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_out_rt_chg_uom ',l_out_rt_chg_uom);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis     ',l_rate_basis);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis_uom ',l_rate_basis_uom);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_handling_chg   ',l_handling_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_min_handling_chg',l_min_handling_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_ld_chg         ',l_ld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_min_ld_chg     ',l_min_ld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_asst_ld_chg    ',l_asst_ld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_unld_chg       ',l_unld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_min_unld_chg   ',l_min_unld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_asst_unld_chg  ',l_asst_unld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_min_asst_unld_chg ',l_min_asst_unld_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_wkday_layovr_chg  ',l_wkday_layovr_chg);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_cont_mv_dsct_prcnt',l_cont_mv_dsct_prcnt);
        END IF;

        -- Attribute : Rate Basis, Rate Basis UOM are required

        IF (l_rate_basis IS NULL OR LENGTH(l_rate_basis) = 0 OR l_rate_basis = 'FLAT') THEN

            l_rate_basis := 'FLAT';
            l_rate_basis_uom := g_unit_uom;

        ELSIF (l_rate_basis NOT IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_FLAT)) THEN

            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_BASIS_INVALID');
            FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        --+
        -- UOM Required for 'DISTANCE', 'TIME', 'VOLUME', 'WEIGHT'
        --+
        ELSIF (l_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST,
                                FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT,
                                FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL,
                                FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME)) THEN
            IF (l_rate_basis_uom IS NULL OR LENGTH(l_rate_basis_uom) = 0) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_RATE_BASIS_UOM_MISSING');
                FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'A',
                                            p_line_number => p_line_number);

                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            ELSE
                l_rate_basis_uom := FTE_UTIL_PKG.GET_UOM_CODE(p_uom => l_rate_basis_uom);

                IF (x_status <> -1 OR l_rate_basis_uom IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name  => 'FTE_CAT_UOM_INVALID',
                                                        p_tokens   => STRINGARRAY('UOM'),
                                                        p_values   => STRINGARRAY(l_rate_basis_uom));
                    FTE_UTIL_PKG.WRITE_OUTFILE(p_msg          => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number);

                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            END IF;

        ELSIF (l_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,
                                FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET)) THEN
            l_rate_basis_uom := g_unit_uom;
        END IF;

        IF (p_chart_type = 'TL_MODIFIER') THEN
            --+
            -- Validate rate basis against carrier preferences
            --+
            CHECK_RATE_BASIS(p_carrier_name   => l_carrier_name,
                             p_rate_basis     => l_rate_basis,
                             p_rate_basis_uom => l_rate_basis_uom,
                             p_service_level  => l_service_level,
                             p_line_number    => p_line_number,
                             x_status         => x_status,
                             x_error_msg      => x_error_msg);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        --+
        -- OUT OF ROUTE Charges
        --+

        IF (l_out_rt_chg IS NOT NULL) THEN

            IF (l_out_rt_chg_uom IS NULL) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_OUT_RTE_CHG_UOM_MISSING');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                           p_module_name => l_module_name,
                                           p_category    => 'A',
                                           p_line_number => p_line_number);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            ELSE

                l_out_rt_chg_uom := FTE_UTIL_PKG.GET_UOM_CODE(l_out_rt_chg_uom);

                IF (l_out_rt_chg_uom IS NULL) THEN
                    x_status := 2;
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'Returned with Error from FTE_UTIL_PKG.GET_UOM_CODE');
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            END IF;

            PROCESS_BLOCK_UNIT_CHARGES(p_charge      => l_out_rt_chg,
                                       p_subtype     => FTE_RTG_GLOBALS.G_C_OUT_OF_ROUTE_CH,
                                       p_uom         => g_unit_uom,
                                       p_process_id  => p_process_id,
                                       x_linenum     => x_linenum,
                                       p_line_number => p_line_number,
                                       x_error_msg   => x_error_msg,
                                       x_status      => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        --+
        -- Process WEEKDAY LAYOVER Charges if specified.
        --+

        IF (l_wkday_layovr_chg IS NOT NULL) THEN

            PROCESS_BLOCK_UNIT_CHARGES(p_charge      => l_wkday_layovr_chg,
                                       p_subtype     => FTE_RTG_GLOBALS.G_C_WEEKDAY_LAYOVER_CH,
                                       p_uom         => g_unit_uom,
                                       p_process_id  => p_process_id,
                                       x_linenum     => x_linenum,
                                       p_line_number => p_line_number,
                                       x_error_msg   => x_error_msg,
                                       x_status      => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        --+
        -- Process CONTINUOUS MOVE Charges if specified.
        --+

        IF (l_cont_mv_dsct_prcnt IS NOT NULL) THEN

            l_type    := 'DISCOUNT';
            l_subtype := FTE_RTG_GLOBALS.G_C_CONTINUOUS_MOVE_DISCOUNT;

            x_linenum := x_linenum + 1;
            l_description := ' Continuous Move Discount Line ' || x_linenum;

            l_rate_line_data('ACTION')      := G_ACTION;
            l_rate_line_data('LINE_NUMBER') := x_linenum;
            l_rate_line_data('DESCRIPTION') := l_description;
            l_rate_line_data('UOM')         := g_unit_uom;
            l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
            l_rate_line_data('TYPE')        := l_type;
            l_rate_line_data('SUBTYPE')     := l_subtype;
            l_rate_line_data('PERCENTAGE')  := Fnd_Number.Number_To_Canonical(l_cont_mv_dsct_prcnt);

            l_rate_line_block_tbl(1) := l_rate_line_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                    p_block_data    => l_rate_line_block_tbl,
                                                    p_line_number   => p_line_number,
                                                    p_validate_column => FALSE,
                                                    x_status        => x_status,
                                                    x_error_msg     => x_error_msg);

            l_rate_line_data.DELETE;
            l_rate_line_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            -- Add CHARGE Attribute
            l_attribute_type := 'TL_CM_DISCOUNT_FLG';
            l_context        := FTE_RTG_GLOBALS.G_AX_TL_CM_DISCOUNT_FLG;
            ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                           p_attribute_value     => 'Y',
                           p_attribute_value_to  => NULL,
                           p_context             => l_context,
                           p_comp_operator       => NULL,
                           p_linenum             => x_linenum,
                           p_process_id          => p_process_id,
                           p_line_number         => p_line_number,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);
        END IF;

        --+
        --  Processing for STOP OFF Charges, if specified.
        --  l_num_free_stops is required to specify additional stop-off charges.
        --  It has the number of stops that are included in the base rate.
        --+

        IF (l_num_free_stops IS NOT NULL AND
            (l_stop_chg_1 IS NULL AND l_stop_chg_2 IS NULL AND l_stop_chg_3 IS NULL AND
             l_stop_chg_4 IS NULL AND l_stop_chg_5 IS NULL AND l_stop_chg_x IS NULL)) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_STOPOFF_CHRG_MISSING');
            FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'A',
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        l_break_charges := STRINGARRAY(0,
                                       l_stop_chg_1, l_stop_chg_2,
                                       l_stop_chg_3, l_stop_chg_4,
                                       l_stop_chg_5, l_stop_chg_x);

        PROCESS_STOPOFF_CHARGES(p_break_charges  => l_break_charges,
                                p_num_free_stops => l_num_free_stops,
                                p_process_id     => p_process_id,
                                x_linenum        => x_linenum,
                                p_line_number    => p_line_number,
                                x_error_msg      => x_error_msg,
                                x_status         => x_status);

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF (p_chart_type = 'FAC_MODIFIER') THEN
            l_load_type_prefix := 'FACILITY_';
        END IF;

        --+
        --  Process HANDLING Charges if specified.
        --+
        IF (l_handling_chg IS NOT NULL) THEN
            PROCESS_LOADING_CHARGES(p_min_charge => l_min_handling_chg,
                                    p_charge     => l_handling_chg,
                                    p_load_type  => l_load_type_prefix || 'HANDLING',
                                    p_basis      => l_rate_basis,
                                    p_basis_uom  => g_unit_uom,
                                    p_process_id => p_process_id,
                                    x_linenum    => x_linenum,
                                    p_line_number => p_line_number,
                                    x_error_msg  => x_error_msg,
                                    x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        --+
        -- Process LOADING Charges if specified.
        --+

        IF (l_ld_chg IS NOT NULL) THEN

            PROCESS_LOADING_CHARGES(p_min_charge => l_min_ld_chg,
                                    p_charge     => l_ld_chg,
                                    p_load_type  => l_load_type_prefix || 'LOADING',
                                    p_basis      => l_rate_basis,
                                    p_basis_uom  => g_unit_uom,
                                    p_process_id => p_process_id,
                                    x_linenum    => x_linenum,
                                    p_line_number => p_line_number,
                                    x_error_msg  => x_error_msg,
                                    x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        --+
        -- Process ASSISTED LOADING Charges if specified.
        --+

        IF (l_asst_ld_chg IS NOT NULL) THEN
            PROCESS_LOADING_CHARGES(p_min_charge => l_min_asst_ld_chg,
                                    p_charge     => l_asst_ld_chg,
                                    p_load_type  => l_load_type_prefix || 'ASSISTED_LOADING',
                                    p_basis      => l_rate_basis,
                                    p_basis_uom  => g_unit_uom,
                                    p_process_id => p_process_id,
                                    x_linenum    => x_linenum,
                                    p_line_number => p_line_number,
                                    x_error_msg  => x_error_msg,
                                    x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        --+
        -- Process UNLOADING Charges if specified
        --+

        IF (l_unld_chg IS NOT NULL) THEN

            PROCESS_LOADING_CHARGES(p_min_charge => l_min_unld_chg,
                                    p_charge     => l_unld_chg,
                                    p_load_type  => l_load_type_prefix || 'UNLOADING',
                                    p_basis      => l_rate_basis,
                                    p_basis_uom  => g_unit_uom,
                                    p_process_id => p_process_id,
                                    x_linenum    => x_linenum,
                                    p_line_number => p_line_number,
                                    x_error_msg  => x_error_msg,
                                    x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END IF;

        --+
        -- Process ASSISTED UNLOADING Charges if specified.
        --+

        IF (l_asst_unld_chg IS NOT NULL) THEN

            PROCESS_LOADING_CHARGES(p_min_charge => l_min_asst_unld_chg,
                                    p_charge     => l_asst_unld_chg,
                                    p_load_type  => l_load_type_prefix || 'ASSISTED_UNLOADING',
                                    p_basis      => l_rate_basis,
                                    p_basis_uom  => g_unit_uom,
                                    p_process_id => p_process_id,
                                    x_linenum    => x_linenum,
                                    p_line_number => p_line_number,
                                    x_error_msg  => x_error_msg,
                                    x_status     => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        --+
        -- For Facility Modifiers, store the rate basis and its uom. Each facility rate chart
        -- has a unique rate basis and basis uom.  These will be used to populate
        -- fte_prc_parameters.
        --+

        IF (p_chart_type = 'FAC_MODIFIER') THEN

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Facility Modifier : Storing UOM ',l_rate_basis_uom);
            END IF;

            Fac_Modifier_Names(Fac_Modifier_Names.COUNT+1) := FTE_UTIL_PKG.GET_DATA('FACILITY_RATE_CHART_NAME', p_values);
            Fac_Modifier_Bases(Fac_Modifier_Bases.COUNT+1) := l_rate_basis;
            Fac_Modifier_Uoms(Fac_Modifier_Uoms.COUNT+1) := l_rate_basis_uom;

        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_CHART_SURCHARGES;

    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_FACILITY_CHARGES                                             --
    --                                                                                 --
    -- Purpose: This is called by PROCESS_DATA if the type to be processed             --
    --          is 'FACILITY_CHARGES'.                                                 --
    --                                                                                 --
    -- IN Parameters                                                                   --
    --    1. p_block_header: An associative array with column names in the upload file,--
    --                       as indices and integers as values.                        --
    --    2. p_block_data  : A table of associative array. Each element in the table   --
    --                       represents a single line of data in the upload file.      --
    --    3. p_line_number : Specifies the line number in the file where this block    --
    --                       begins.This is used for error logging, which aims         --
    --                       at ease of loader usage.                                  --
    --    4. p_doValidate  : determines whether to validate the incoming data or not.  --
    --                       Normally it will have the vlue TRUE, enabling validation  --
    --                       When called from RATE CHART EDITOR UI, no need to validate--
    --                       so they will pass FALSE for this.                         --
    --                                                                                 --
    -- Out Parameters                                                                  --
    --    1. x_status  :  the return status, -1 for success                            --
    --                                        2 for failure.                           --
    --    2.x_error_msg: the corresponding error meassge,                              --
    --                   if any exception occurs during the process.                   --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_FACILITY_CHARGES(p_block_header IN   FTE_BULKLOAD_PKG.block_header_tbl,
                                       p_block_data   IN   FTE_BULKLOAD_PKG.block_data_tbl,
                                       p_line_number  IN   NUMBER,
                                       x_error_msg    OUT  NOCOPY  VARCHAR2,
                                       x_status       OUT  NOCOPY  NUMBER) IS

    l_carrier_name          VARCHAR2(50);
    l_currency              VARCHAR2(20);
    l_start_date            VARCHAR2(20);
    l_end_date              VARCHAR2(20);
    l_name                  VARCHAR2(60);
    l_rc_name               VARCHAR2(60);
    l_list_header_id        NUMBER;
    l_description           VARCHAR2(240);
    l_process_id            NUMBER;
    l_linenum               NUMBER;
    l_chart_type            VARCHAR2(50);
    l_status                VARCHAR2(4000);
    l_service_level         VARCHAR2(30);
    l_assoc_rc_ids          STRINGARRAY;

    l_values                FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_data         FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_data        FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_block_tbl    FTE_BULKLOAD_PKG.block_data_tbl;
    l_rate_line_block_tbl   FTE_BULKLOAD_PKG.block_data_tbl;

    l_type         CONSTANT  VARCHAR2(30)  := 'FACILITY_CHARGES';
    l_module_name  CONSTANT  VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_FACILITY_CHARGES';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF (g_unit_uom IS NULL) THEN
            g_unit_uom := GET_GLOBAL_UNIT_UOM(x_status, x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'FTE_UTIL_PKG.GET_GLOBAL_UNIT_UOM returned with error' || x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                            p_type      => l_type,
                                            p_line_number => p_line_number-1,
                                            x_status    => x_status,
                                            x_error_msg => x_error_msg);
        IF (x_status <> -1) THEN
           RETURN;
        END IF;

        FOR i IN 1..p_block_data.COUNT LOOP

            l_values      := p_block_data(i);
            G_ACTION      := FTE_UTIL_PKG.GET_DATA('ACTION', l_values);
            l_currency    := FTE_UTIL_PKG.GET_DATA('CURRENCY', l_values);
            l_start_date  := FTE_UTIL_PKG.GET_DATA('START_DATE', l_values);
            l_end_date    := FTE_UTIL_PKG.GET_DATA('END_DATE', l_values);
            l_name        := FTE_UTIL_PKG.GET_DATA('FACILITY_RATE_CHART_NAME', l_values);

            G_ACTION      := UPPER(G_ACTION);

            IF (l_start_date IS NOT NULL) THEN
                BEGIN
                    l_start_date := to_char(to_date(l_start_date, 'MM/DD/YYYY'),'MM/DD/YYYY');
                EXCEPTION
                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DATE_FORMAT_ERROR');
                        FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                                     p_module_name => l_module_name,
                                                     p_category    => 'D',
                                                     p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;
            END IF;

            IF (l_end_date IS NOT NULL) THEN
                BEGIN
                    l_end_date := to_char(to_date(l_end_date, 'MM/DD/YYYY'),'MM/DD/YYYY');
                EXCEPTION
                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DATE_FORMAT_ERROR');
                        FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                                     p_module_name => l_module_name,
                                                     p_category    => 'D',
                                                     p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;
            END IF;

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_ACTION    ',G_ACTION);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_name      ',l_name);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_currency  ',l_currency);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_start_date',l_start_date);
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_end_date  ',l_end_date);
            END IF;

            --Action
            IF (G_ACTION IS NULL OR LENGTH(G_ACTION) = 0) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_ACTION_MISSING');
                FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'A',
                                            p_line_number => p_line_number + i + 1);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --
            -- Rate Chart Name
            --
            IF (l_name IS NULL OR LENGTH(l_name) = 0) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICE_NAME_MISSING');
                FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                            p_module_name => l_module_name,
                                            p_category    => 'A',
                                            p_line_number => p_line_number + i + 1);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            -- Delete
            IF (G_ACTION IN('DELETE')) THEN

                --+
                -- For DELETE, we delete the dummy rate chart associated with the modifier.
                --+
                l_assoc_rc_ids := FTE_RATE_CHART_PKG.GET_ASSOC_PRICELISTS(NULL, l_name);

                FOR i IN 1..l_assoc_rc_ids.COUNT LOOP

                    FTE_RATE_CHART_PKG.G_CHART_TYPE := 'FAC_RATE_CHART';
                    FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id  => l_assoc_rc_ids(i),
                                                      p_name            => NULL,
                                                      p_action          => 'DELETE',
                                                      p_line_number     => p_line_number + i + 1,
                                                      x_status          => x_status,
                                                      x_error_msg       => x_error_msg);
                    IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'Deleting Rate Chart with ID '||l_assoc_rc_ids(i)|| ' of Modifier ' || l_name);
                    END IF;
                END LOOP;

                --+
                -- For Delete, we delete the lines and attributes and exit
                --+

                FTE_RATE_CHART_PKG.G_CHART_TYPE := 'FAC_MODIFIER';
                FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id  => NULL,
                                                  p_name            => l_name,
                                                  p_action          => G_ACTION,
                                                  p_line_number     => p_line_number + i + 1,
                                                  x_status          => x_status,
                                                  x_error_msg       => x_error_msg);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
            --+
            -- Currency
            --+

            IF (l_currency IS NULL OR LENGTH(l_currency) = 0) THEN
                x_status := 2;
                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CURRENCY_MISSING');
                FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                           p_module_name => l_module_name,
                                           p_category    => 'A',
                                           p_line_number => p_line_number + i + 1);
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Create Dummy Rate Chart
            -- For update, the dummy pricelist already exists. We don't need to recreate it.
            --+
            IF (G_ACTION = 'ADD') THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Create Dummy Rate Chart');
                END IF;

                l_rc_name := l_name || '_RC';

                l_chart_type := 'FAC_RATE_CHART';
                l_description := 'Rate Chart ' || l_rc_name;

                GET_CHART_DATA(p_chart_name    => l_rc_name,
                               p_currency      => l_currency,
                               p_chart_type    => l_chart_type,
                               x_carrier_name  => l_carrier_name,
                               x_service_level => l_service_level,
                               x_cur_line      => l_linenum,
                               x_job_id        => l_process_id,
                               p_line_number   => p_line_number,
                               x_error_msg     => x_error_msg,
                               x_status        => x_status);


                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating Fac Chart Header');
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Name', l_rc_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'PID ', l_process_id);
                END IF;

                l_rate_hdr_data('ACTION')        := G_ACTION;
                l_rate_hdr_data('FACILITY_RATE_CHART_NAME') := l_rc_name;
                l_rate_hdr_data('DESCRIPTION')   := l_description;
                l_rate_hdr_data('START_DATE')    := l_start_date;
                l_rate_hdr_data('END_DATE')      := l_end_date;
                l_rate_hdr_data('CURRENCY')      := l_currency;
                l_rate_hdr_data('ATTRIBUTE1')    := 'FAC_RATE_CHART';

                l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                         p_block_data   => l_rate_hdr_block_tbl,
                                                         p_line_number  => p_line_number + i + 1,
                                                         p_validate_column => FALSE,
                                                         p_process_id   => l_process_id,
                                                         x_status       => x_status,
                                                         x_error_msg    => x_error_msg);

                l_rate_hdr_data.DELETE;
                l_rate_hdr_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                l_rate_line_data('ACTION')      := G_ACTION;
                l_rate_line_data('LINE_NUMBER') := 1;
                l_rate_line_data('DESCRIPTION') := l_description;
                l_rate_line_data('RATE')        := 0;
                l_rate_line_data('UOM')         := g_unit_uom;
                l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
                l_rate_line_data('TYPE')        := l_type;
                l_rate_line_data('RATE_TYPE')   := 'PER_UOM';

                l_rate_line_block_tbl(1) := l_rate_line_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_rate_line_block_tbl,
                                                        p_line_number   => p_line_number + i + 1,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);
            END IF;

            -- Now process the modifier.
            l_chart_type := 'FAC_MODIFIER';

            --+
            -- Obtain Cached Information about the Chart, if it exists.
            --+
            GET_CHART_DATA(p_chart_name    => l_name,
                           p_currency      => l_currency,
                           p_chart_type    => l_chart_type,
                           x_carrier_name  => l_carrier_name,
                           x_service_level => l_service_level,
                           x_cur_line      => l_linenum,
                           x_job_id        => l_process_id,
                           p_line_number   => p_line_number,
                           x_error_msg     => x_error_msg,
                           x_status        => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Create Modifier Header
            --+
            IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating Modifier Header For ' || l_name);
            END IF;

            l_description := 'Rate Chart ' || l_name;

            l_rate_hdr_data('ACTION')        := G_ACTION;
            l_rate_hdr_data('TL_FACILITY_MODIFIER_NAME') := l_name;
            l_rate_hdr_data('DESCRIPTION')   := l_description;
            l_rate_hdr_data('START_DATE')    := l_start_date;
            l_rate_hdr_data('END_DATE')      := l_end_date;
            l_rate_hdr_data('CURRENCY')      := NULL;
            l_rate_hdr_data('ATTRIBUTE1')    := l_chart_type;

            l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header  => g_dummy_block_hdr_tbl,
                                                     p_block_data   => l_rate_hdr_block_tbl,
                                                     p_line_number  => p_line_number + i + 1,
                                                     p_validate_column => FALSE,
                                                     p_process_id   => l_process_id,
                                                     x_status       => x_status,
                                                     x_error_msg    => x_error_msg);
            l_rate_hdr_data.DELETE;
            l_rate_hdr_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            PROCESS_CHART_SURCHARGES( p_values      => l_values,
                                      p_chart_type  => l_chart_type,
                                      p_process_id  => l_process_id,
                                      x_linenum     => l_linenum,
                                      p_line_number => p_line_number,
                                      x_error_msg   => x_error_msg,
                                      x_status      => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            Link_ChartNames(Link_ChartNames.COUNT+1)       := l_rc_name;
            Link_ModifierNames(Link_ModifierNames.COUNT+1) := l_name;

        END LOOP;

        SUBMIT_TL_CHART(x_status, x_error_msg);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return status from SUBMIT_TL_CHART',x_status);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return Message from SUBMIT_TL_CHART',x_error_msg);
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN VALUE_ERROR THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR');
            FTE_UTIL_PKG.Write_OutFile(p_msg          => x_error_msg,
                                       p_module_name => l_module_name,
                                       p_category    => 'D',
                                       p_line_number => 0);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, SQLERRM);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_FACILITY_CHARGES;

    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_TL_SURCHARGES                                                --
    --                                                                                 --
    -- Purpose: This is called by PROCESS_DATA if the type to be processed   --
    --          is 'TL_SURCHARGES'.                                                    --
    -- IN Parameters                                                                   --
    --    1. p_block_header: An associative array with column names in the upload file,--
    --                       as indices and integers as values.                        --
    --    2. p_block_data  : A table of associative array. Each element in the table   --
    --                       represents a single line of data in the upload file.      --
    --    3. p_line_number : Specifies the line number in the file where this block    --
    --                       begins.This is used for error logging, which aims         --
    --                       at ease of loader usage.                                  --
    --    4. p_doValidate  : determines whether to validate the incoming data or not.  --
    --                       Normally it will have the vlue TRUE, enabling validation  --
    --                       When called from RATE CHART EDITOR UI, no need to validate--
    --                       so they will pass FALSE for this.                         --
    --                                                                                 --
    -- Out Parameters                                                                  --
    --    1. x_status  :  the return status, -1 for success                            --
    --                                        2 for failure.                           --
    --    2.x_error_msg: the corresponding error meassge,                              --
    --                   if any exception occurs during the process.                   --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_TL_SURCHARGES(p_block_header IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                    p_block_data   IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                    p_line_number  IN  NUMBER,
                                    p_doValidate   IN  BOOLEAN DEFAULT TRUE,
                                    x_error_msg    OUT   NOCOPY  VARCHAR2,
                                    x_status       OUT   NOCOPY  NUMBER) IS


    l_type                     VARCHAR2(30);
    l_service_level            VARCHAR2(20);
    l_currency                 VARCHAR2(20);
    l_start_date               VARCHAR2(20);
    l_end_date                 VARCHAR2(20);
    l_country                  VARCHAR2(60);
    l_state                    VARCHAR2(60);
    l_city                     VARCHAR2(60);
    l_zone_type                VARCHAR2(30);
    l_zipcode_from             VARCHAR2(30);
    l_zipcode_to               VARCHAR2(30);
    l_zone                     VARCHAR2(60);
    l_name                     VARCHAR2(60);
    l_description              VARCHAR2(240);
    l_process_id               NUMBER;
    l_linenum                  NUMBER;
    l_subtype                  VARCHAR2(50);
    l_carrier_name             VARCHAR2(100);
    l_carrier_id               NUMBER;
    l_region_id            NUMBER;
    l_rate                     NUMBER;
    l_wkend_layovr_dist_uom    VARCHAR2(20);
    l_wkend_layovr_dist_brk    NUMBER;

    l_chart_type     CONSTANT  VARCHAR2(50) := 'TL_MODIFIER';
    l_block_type     CONSTANT  VARCHAR2(25) := 'TL_SURCHARGES';
    l_region_info              wsh_regions_search_pkg.region_rec;

    l_rate_hdr_data            FTE_BULKLOAD_PKG.data_values_tbl;
    l_values                   FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_block_tbl       FTE_BULKLOAD_PKG.block_data_tbl;

    l_module_name    CONSTANT  VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_TL_SURCHARGES';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        --+
        -- Get the global unit UOM defined at Shipping->Setup->Global Parameters
        --+
        IF (g_unit_uom IS NULL) THEN
            g_unit_uom := GET_GLOBAL_UNIT_UOM (x_status, x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'g_unit_uom',g_unit_uom);
        END IF;

        IF( p_doValidate ) THEN
            FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                                p_type      => l_block_type,
                                                p_line_number => p_line_number-1,
                                                x_status    => x_status,
                                                x_error_msg => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'Return status from FTE_VALIDATION_PKG.VALIDATE_COLUMNS ', x_status);
                RETURN;
            END IF;
        END IF;


        FOR i IN 1..p_block_data.COUNT LOOP

            l_values := p_block_data(i);

            l_type := FTE_UTIL_PKG.GET_DATA('TYPE',l_values);
            l_type := UPPER(l_type);

            IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'i     ',i);
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'l_type',l_type);
            END IF;

            G_ACTION         := FTE_UTIL_PKG.GET_DATA('ACTION', l_values);

            /*
               C to specify stop-off, out-of-route, handling, minimum handling,
                  loading, minimum loading, assisted loading, minimum assisted loading,
                  unloading, minimum unloading, assisted unloading, minimum assisted unloading,
                  and weekday layover charges,
               O to specify origin surcharges,
               D to specify destination surcharges,
               B to specify weekend layover distance breaks and the associated weekend layover charges and
               F to specify fuel surcharges
            */

            IF (l_type NOT IN ('C','O','D','B','F')) THEN
               x_status := 2;
               x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_SURCHARGE_TYPE_INVALID');
                   FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => 0);
                   RETURN;
            END IF;

	  IF (NOT(g_action = 'DELETE' AND Upper(l_type) <> 'C')) THEN

            IF (l_type = 'C') THEN

                RESET_CHART_INFO;

                l_carrier_name   := FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', l_values);
                l_currency       := FTE_UTIL_PKG.GET_DATA('CURRENCY', l_values);
                l_start_date     := FTE_UTIL_PKG.GET_DATA('START_DATE', l_values);
                l_end_date       := FTE_UTIL_PKG.GET_DATA('END_DATE', l_values);
                l_service_level  := FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL', l_values);

                IF (NOT p_doValidate) THEN
                    --+
                    -- Get the carrier name from the ID for rate chart cretion.
                    --+
                    l_carrier_id := FTE_UTIL_PKG.GET_DATA('CARRIER_ID', l_values);
                    l_carrier_name := FTE_UTIL_PKG.GET_CARRIER_NAME(p_carrier_id => l_carrier_id);

                    l_values('CARRIER_NAME') := l_carrier_name;

                    --+
                    -- populate SERVICE LEVEL CODE.
                    --+
                    l_service_level := FTE_UTIL_PKG.GET_DATA('SERVICE_CODE', l_values);

                END IF;

                G_ACTION := UPPER(G_ACTION);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_ACTION       ',G_ACTION);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_name         ',l_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_service_level',l_service_level);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_carrier_name ',l_carrier_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_currency     ',l_currency);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_start_date   ',l_start_date);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_end_date     ',l_end_date);
                END IF;

                IF (p_doValidate) THEN
                    FTE_VALIDATION_PKG.VALIDATE_ACTION(p_action      => G_ACTION,
                                                       p_type        => l_block_type,
                                                       p_line_number => p_line_number + i + 1,
                                                       x_status      => x_status,
                                                       x_error_msg   => x_error_msg);
                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_VALIDATION_PKG.VALIDATE_ACTION failed');
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;

                IF (p_doValidate) THEN
                    IF (l_start_date IS NOT NULL) THEN
                        BEGIN
                            IF (p_doValidate) THEN
                                l_start_date := to_char(to_date(l_start_date, 'MM/DD/YYYY'),'MM/DD/YYYY');
                            END IF;
                        EXCEPTION
                            WHEN OTHERS THEN
                                x_status := 2;
                                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_INVALID_DATE');
                                FTE_UTIL_PKG.Write_OutFile( p_msg      => x_error_msg,
                                                             p_module_name => l_module_name,
                                                             p_category    => 'D',
                                                             p_line_number => p_line_number + i + 1);
                                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                                RETURN;
                        END;
                    END IF;

                    IF (l_end_date IS NOT NULL) THEN
                        BEGIN
                            IF (p_doValidate) THEN
                                l_end_date := to_char(to_date(l_end_date, 'MM/DD/YYYY'),'MM/DD/YYYY');
                            END IF;
                        EXCEPTION
                            WHEN OTHERS THEN
                                x_status := 2;
                                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_LOAD_INVALID_DATE');
                                FTE_UTIL_PKG.Write_OutFile(p_msg     => x_error_msg,
                                                           p_module_name => l_module_name,
                                                           p_category    => 'D',
                                                           p_line_number => p_line_number + i + 1);

                                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                                RETURN;
                        END;
                    END IF;
                END IF;

                IF (p_doValidate) THEN
                    l_service_level := FTE_VALIDATION_PKG.VALIDATE_SERVICE_LEVEL(p_carrier_id    => NULL,
                                                                                 p_carrier_name  => l_carrier_name,
                                                                                 p_service_level => l_service_level,
                                                                                 p_line_number   => p_line_number + i + 1,
                                                                                 x_error_msg     => x_error_msg,
                                                                                 x_status        => x_status);
                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;

                IF (p_doValidate) THEN
                    IF (l_currency IS NULL OR LENGTH(l_currency) = 0 AND  G_ACTION IN ('ADD', 'UPDATE')) THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name =>'FTE_LOAD_CURRENCY_MISSING');
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    => 'D',
                                                   p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;

                IF (p_doValidate) THEN
                    --+
                    -- We need the carrier ID in order
                    -- to create the modifier rate chart name.
                    --+
                    BEGIN
                        SELECT
                          'MOD_' || hz.party_id || '_' || l_service_level INTO l_name
                        FROM
                          HZ_PARTIES hz,
                          WSH_CARRIERS ca
                        WHERE
                          hz.party_name = l_carrier_name AND
                          hz.party_id   = ca.carrier_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            x_status := 2;
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name =>  'FTE_SEL_INVALID_CARRIER');
                            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number + i + 1);
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                        WHEN OTHERS THEN
                            x_status := 2;
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                    END;
                ELSE
                    l_name := 'MOD_'||l_carrier_id||'_'||l_service_level;
                END IF;

                IF (G_ACTION = 'DELETE') THEN

                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleting TL_MODIFIER ' || l_name);
                    END IF;

                    FTE_RATE_CHART_PKG.G_CHART_TYPE := l_chart_type;

                    FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id  => NULL,
                                                      p_name            => l_name,
                                                      p_action          => G_ACTION,
                                                      p_line_number     => p_line_number + i + 1,
                                                      x_status          => x_status,
                                                      x_error_msg       => x_error_msg);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                GET_CHART_DATA(p_chart_name    => l_name,
                               p_currency      => l_currency,
                               p_chart_type    => l_chart_type,
                               x_carrier_name  => l_carrier_name,
                               x_service_level => l_service_level,
                               x_cur_line      => l_linenum,
                               x_job_id        => l_process_id,
                               p_line_number   => p_line_number + i + 1,
                               x_error_msg     => x_error_msg,
                               x_status        => x_status);

                g_chart_name := l_name;

                --+
                -- If the linenum from GET_CHART_DATA is greater than o,
                -- it means that user is trying to upload a duplicate ratechart
                -- in the same spreadsheet.
                --+
                IF (l_linenum > 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DUPLICATE_CHART');
                    FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number =>  p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --
                -- Create Modifier Header
                --

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating Modifier Header For ' || l_name);
                END IF;

                l_description := 'Rate Chart ' || g_chart_name;

                l_rate_hdr_data('ACTION')        := G_ACTION;
                l_rate_hdr_data('TL_MODIFIER_NAME') := g_chart_name;
                l_rate_hdr_data('DESCRIPTION')   := l_description;
                l_rate_hdr_data('START_DATE')    := l_start_date;
                l_rate_hdr_data('END_DATE')      := l_end_date;
                l_rate_hdr_data('CURRENCY')      := l_currency;
                l_rate_hdr_data('CARRIER_NAME')  := l_carrier_name;
                l_rate_hdr_data('SERVICE_LEVEL') := l_service_level;
                l_rate_hdr_data('ATTRIBUTE1')    := 'TL_MODIFIER';

                l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header    => g_dummy_block_hdr_tbl,
                                                         p_block_data      => l_rate_hdr_block_tbl,
                                                         p_line_number     => p_line_number + i + 1,
                                                         p_validate_column => FALSE,
                                                         p_process_id      => l_process_id,
                                                         x_status          => x_status,
                                                         x_error_msg       => x_error_msg);


                l_rate_hdr_data.DELETE;
                l_rate_hdr_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, x_error_msg || ' [' || l_service_level || ', ' || l_carrier_name || ', TL]');
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                PROCESS_CHART_SURCHARGES(p_values      => l_values,
                                         p_chart_type  => l_chart_type,
                                         p_process_id  => l_process_id,
                                         p_doValidate  => p_doValidate,
                                         x_linenum     => l_linenum,
                                         p_line_number => p_line_number,
                                         x_error_msg   => x_error_msg,
                                         x_status      => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            ELSIF (l_type = 'B') THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Weekend Layover Break.');
                END IF;

                GET_CHART_DATA(p_chart_name    => g_chart_name,
                               p_currency      => l_currency,
                               p_chart_type    => l_chart_type,
                               x_carrier_name  => l_carrier_name,
                               x_service_level => l_service_level,
                               x_cur_line      => l_linenum,
                               x_job_id        => l_process_id,
                               p_line_number   => p_line_number + i + 1,
                               x_error_msg     => x_error_msg,
                               x_status        => x_status);


                l_wkend_layovr_dist_uom := FTE_UTIL_PKG.GET_DATA('DISTANCE_UOM_FOR_WEEKEND_LAYOVER_CHARGES', l_values);
                l_wkend_layovr_dist_brk := FTE_UTIL_PKG.GET_DATA('WEEKEND_LAYOVER_DISTANCE_BREAK', l_values);
                l_rate                  := FTE_UTIL_PKG.GET_DATA('CHARGES', l_values);

                l_wkend_layovr_dist_brk := Fnd_Number.Canonical_To_Number(l_wkend_layovr_dist_brk);
                l_rate                  := Fnd_Number.Canonical_To_Number(l_rate);

                IF (l_rate < 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                        p_tokens => STRINGARRAY('ENTITY'),
                                                        p_values => STRINGARRAY('RATE'));
                    FTE_UTIL_PKG.Write_OutFile(p_msg          => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate       ', l_rate);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_chart_name ', g_chart_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_linenum    ', l_linenum);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_process_id ', l_process_id);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_ACTION     ', G_ACTION);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_wkend_layovr_dist_uom',l_wkend_layovr_dist_uom );
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_wkend_layovr_dist_brk',l_wkend_layovr_dist_brk);
                END IF;

                IF (l_wkend_layovr_dist_uom IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_WKEND_DIST_UOM_MISSING');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (l_wkend_layovr_dist_brk IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_WKEND_NO_DIST_BREAK');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (l_rate IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_RATE_MISSING');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF (g_wknd_layovr_uom <> l_wkend_layovr_dist_uom) THEN
                    IF (g_layovr_breaks.EXISTS(1)) THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_DIST_UOM_MISMATCH');
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    => 'D',
                                                   p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                ELSE
                    g_wknd_layovr_uom := l_wkend_layovr_dist_uom;
                    g_layovr_breaks.EXTEND;
                    g_layovr_charges.EXTEND;
                    g_layovr_breaks(g_layovr_breaks.COUNT)   := Fnd_Number.Number_To_Canonical(l_wkend_layovr_dist_brk);
                    g_layovr_charges(g_layovr_charges.COUNT) := Fnd_Number.Number_To_Canonical(l_rate);
                END IF;

            ELSIF (l_type IN ('O', 'D', 'F')) THEN

                l_rate := Fnd_Number.Canonical_To_Number(FTE_UTIL_PKG.GET_DATA('SURCHARGES', l_values));

                IF (l_rate < 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                        p_tokens => STRINGARRAY('ENTITY'),
                                                        p_values => STRINGARRAY('RATE'));
                    FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                                 p_module_name => l_module_name,
                                                 p_category    => 'D',
                                                 p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (l_rate IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_SURCHARGE_MISSING');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                GET_CHART_DATA(p_chart_name    => g_chart_name,
                               p_currency      => l_currency,
                               p_chart_type    => l_chart_type,
                               x_carrier_name  => l_carrier_name,
                               x_service_level => l_service_level,
                               x_cur_line      => l_linenum,
                               x_job_id        => l_process_id,
                               p_line_number   => p_line_number + i + 1,
                               x_error_msg     => x_error_msg,
                               x_status        => x_status);

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                     FTE_UTIL_PKG.Write_LogFile(l_module_name, 'g_chart_name', g_chart_name);
                     FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_linenum',    l_linenum);
                     FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_process_id', l_process_id);
                END IF;

                IF (l_carrier_name IS NULL) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_RATECHART_NOT_DEFINED');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate', l_rate);
                END IF;

                IF (l_type IN ('O', 'D')) THEN

                    IF (l_type = 'O') THEN
                       l_zone_type := 'ORIGIN';
                    ELSE
                       l_zone_type := 'DESTINATION';
                    END IF;

                    IF (p_doValidate) THEN
                        l_country      := FTE_UTIL_PKG.GET_DATA('COUNTRY', l_values);
                        l_state        := FTE_UTIL_PKG.GET_DATA('STATE', l_values);
                        l_city         := FTE_UTIL_PKG.GET_DATA('CITY', l_values);
                        l_zipcode_from := FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_FROM', l_values);
                        l_zipcode_to   := FTE_UTIL_PKG.GET_DATA('POSTAL_CODE_TO', l_values);
                        l_zone         := FTE_UTIL_PKG.GET_DATA('ZONE', l_values);

                        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_country', l_country);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_state',   l_state);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_city',    l_city);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zipcode_to', l_zipcode_to);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zipcode_from', l_zipcode_from);
                            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_zone',    l_zone);
                        END IF;

                        IF (l_country IS NULL AND l_state IS NULL AND l_city IS NULL AND
                            l_zipcode_from IS NULL AND l_zipcode_to IS NULL AND l_zone IS NULL) THEN

                            x_status := 2;
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_REGION_INFO_SPECIFIED');
                            FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number + i + 1);
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                        END IF;

                        l_region_info.country          := l_country;
                        l_region_info.state            := l_state;
                        l_region_info.city             := l_city;
                        l_region_info.postal_code_from := l_zipcode_from;
                        l_region_info.postal_code_to   := l_zipcode_to;
                        l_region_info.zone             := l_zone;
                    ELSE
                        l_region_id := FTE_UTIL_PKG.GET_DATA('REGION_CODE', l_values);
                    END IF;

                    PROCESS_REGION_CHARGES(p_region_type  => l_zone_type,
                                           p_region_info  => l_region_info,
                                           p_charge       => l_rate,
                                           p_process_id   => l_process_id,
                                           x_linenum      => l_linenum,
                                           p_region_id    => l_region_id,
                                           p_line_number  => p_line_number + i + 1,
                                           x_error_msg    => x_error_msg,
                                           x_status       => x_status);

                ELSIF (l_type = 'F') THEN

                    PROCESS_FUEL_CHARGES( p_charge       => l_rate,
                                          p_process_id   => l_process_id,
                                          x_linenum      => l_linenum,
                                          p_line_number  => p_line_number + i + 1,
                                          x_error_msg    => x_error_msg,
                                          x_status       => x_status);

                END IF;

                IF (x_status <> -1) THEN
                    x_status := 2;
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;

            SET_CHART_LINE(g_chart_name, l_linenum, x_status);
	  END IF;
        END LOOP;

        SUBMIT_TL_CHART(x_status, x_error_msg);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return status from SUBMIT_TL_CHART',x_status);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return Message from SUBMIT_TL_CHART',x_error_msg);
        END IF;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN VALUE_ERROR THEN

            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'Numeric Value Error while reading file. Please ensure that all data is of the right type.');
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

        WHEN OTHERS THEN

            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_TL_SURCHARGES;

    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_TL_BASE_RATES                                                --
    --                                                                                 --
    -- Purpose: This is called by PROCESS_DATA if the type to be processed   --
    --          is 'TL_BASE_RATES'. By uploading a 'TL_BASE_RATES' block, the user is  --
    --          creating rate chart.                                                   --
    --                                                                                 --
    -- IN Parameters                                                                   --
    --    1. p_block_header: An associative array with column names in the upload file,--
    --                       as indices and integers as values.                        --
    --    2. p_block_data  : A table of associative array. Each element in the table   --
    --                       represents a single line of data in the upload file.      --
    --    3. p_line_number : Specifies the line number in the file where this block    --
    --                       begins.This is used for error logging, which aims         --
    --                       at ease of loader usage.                                  --
    --    4. p_doValidate  : determines whether to validate the incoming data or not.  --
    --                       Normally it will have the vlue TRUE, enabling validation  --
    --                       When called from RATE CHART EDITOR UI, no need to validate--
    --                       so they will pass FALSE for this.                         --
    --                                                                                 --
    -- Out Parameters                                                                  --
    --    1. x_status  :  the return status, -1 for success                            --
    --                                        2 for failure.                           --
    --    2.x_error_msg: the corresponding error meassge,                              --
    --                   if any exception occurs during the process.                   --
    --                                                                                 --
    --                                                                                 --
    --   Column headers. 13 columns                                                    --
    --   ACTION, CARRIER_NAME, RATE_CHART_NAME, CURRENCY, RATE_BASIS, RATE_BASIS_UOM,  --
    --   DISTANCE_TYPE, SERVICE_LEVEL,VEHICLE_TYPE, RATE, MINIMUM_CHARGE,              --
    --   START_DATE, END_DATE                                                          --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_TL_BASE_RATES(p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                    p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                    p_line_number     IN  NUMBER,
                                    p_doValidate      IN  BOOLEAN DEFAULT TRUE,
                                    x_status          OUT NOCOPY NUMBER,
                                    x_error_msg       OUT NOCOPY VARCHAR2) IS

    l_process_id            NUMBER;
    l_carrier_name          VARCHAR2(100);
    l_rate_chart_name       VARCHAR2(100);
    l_currency              VARCHAR2(20);
    l_rate_basis            VARCHAR2(30);
    l_rate_basis_uom        VARCHAR2(20);
    l_attribute             VARCHAR2(50);
    l_dist_type             VARCHAR2(100);
    l_service_level         VARCHAR2(100);
    l_chart_type            VARCHAR2(30);
    l_vehicle_type          VARCHAR2(100);
    l_rate                  NUMBER;
    l_min_charge            NUMBER;
    l_start_date            VARCHAR2(20);
    l_end_date              VARCHAR2(20);
    l_attribute_type        VARCHAR2(50);
    l_attribute_value       VARCHAR2(50);
    l_description           VARCHAR2(200);
    l_linenum               NUMBER;
    l_precedence            NUMBER;
    l_deadhead              BOOLEAN := FALSE;
    l_assoc_modifier_ids    STRINGARRAY;

    --+
    -- Used for Rate Chart Deletion
    --+
    l_deleted_rate_charts   STRINGARRAY;
    l_del_count             NUMBER := 0;


    --+
    -- Jiong's Requirement for UI
    --+
    l_carrier_id           NUMBER;


    l_values                FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_data         FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_line_data        FTE_BULKLOAD_PKG.data_values_tbl;
    l_rate_hdr_block_tbl    FTE_BULKLOAD_PKG.block_data_tbl;
    l_rate_line_block_tbl   FTE_BULKLOAD_PKG.block_data_tbl;

    l_type         CONSTANT VARCHAR2(25) := 'TL_BASE_RATES';
    l_module_name  CONSTANT VARCHAR2(100):= 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_TL_BASE_RATES';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status         := -1;

        l_chart_type     := 'TL_MODIFIER';
        l_precedence     := G_CONST_PRECEDENCE_HIGH;

        IF (g_unit_uom IS NULL) THEN
            g_unit_uom := GET_GLOBAL_UNIT_UOM (x_status, x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        IF (p_doValidate) THEN
            FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                                p_type      => l_type,
                                                p_line_number => p_line_number-1,
                                                x_status    => x_status,
                                                x_error_msg => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;
        END IF;

        --+
        -- Start processing the elements in p_block_data.
        --+

        FOR i IN 1..p_block_data.COUNT LOOP

            l_values := p_block_data(i);

            G_ACTION         := FTE_UTIL_PKG.GET_DATA('ACTION', l_values);
            l_carrier_name   := FTE_UTIL_PKG.GET_DATA('CARRIER_NAME', l_values);
            l_rate_chart_name:= FTE_UTIL_PKG.GET_DATA('RATE_CHART_NAME', l_values);
            l_currency       := FTE_UTIL_PKG.GET_DATA('CURRENCY', l_values);
            l_rate_basis_uom := FTE_UTIL_PKG.GET_DATA('RATE_BASIS_UOM', l_values);
            l_vehicle_type   := FTE_UTIL_PKG.GET_DATA('VEHICLE_TYPE', l_values);
            l_start_date     := FTE_UTIL_PKG.GET_DATA('START_DATE', l_values);
            l_end_date       := FTE_UTIL_PKG.GET_DATA('END_DATE', l_values);
            l_dist_type      := FTE_UTIL_PKG.GET_DATA('DISTANCE_TYPE', l_values);
            l_service_level  := FTE_UTIL_PKG.GET_DATA('SERVICE_LEVEL', l_values);
            l_rate_basis     := FTE_UTIL_PKG.GET_DATA('RATE_BASIS', l_values);

	    BEGIN
	       l_rate := FTE_UTIL_PKG.GET_DATA('RATE', l_values);
               IF (l_rate < 0 ) THEN
	            x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                        p_tokens => STRINGARRAY('ENTITY'),
                                                        p_values => STRINGARRAY('RATE'));
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
	       END IF;
	    EXCEPTION
	       WHEN OTHERS THEN
		        x_status := 2;
	                x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_NON_NUMERIC');
                        FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                    p_module_name => l_module_name,
                                                    p_category    => 'D',
                                                    p_line_number => p_line_number + i + 1);
			RETURN;
	    END;

            BEGIN
	       l_min_charge := FTE_UTIL_PKG.GET_DATA('MINIMUM_CHARGE', l_values);
	       IF (l_min_charge IS NOT NULL ) THEN
		  IF (l_min_charge < 0 ) THEN
	            x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                        p_tokens => STRINGARRAY('ENTITY'),
                                                        p_values => STRINGARRAY('MINIMUM_CHARGE'));
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
		 END IF;
	       END IF;
	     EXCEPTION
	       WHEN OTHERS THEN
		        x_status := 2;
	                x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_RATE_NON_NUMERIC');
                        FTE_UTIL_PKG.Write_OutFile( p_msg         => x_error_msg,
                                                    p_module_name => l_module_name,
                                                    p_category    => 'D',
                                                    p_line_number => p_line_number + i + 1);
			RETURN;
	    END;

            --+
            -- Added for Jiong's Requirement.
            -- No check for return status done, as the validations has been done at UI level.
            --+

            IF( NOT p_doValidate) THEN

                --+
                -- Get the carrier name from the ID for rate chart cretion.
                --+
                l_carrier_id := FTE_UTIL_PKG.GET_DATA('CARRIER_ID', l_values);
                l_carrier_name := FTE_UTIL_PKG.GET_CARRIER_NAME(p_carrier_id => l_carrier_id);

                --+
                -- populate SERVICE LEVEL CODE.
                --+
                l_service_level := FTE_UTIL_PKG.GET_DATA('SERVICE_CODE', l_values);

                --+
                -- populate VEHICLE_TYPE_ID
                --+
                l_vehicle_type := FTE_UTIL_PKG.GET_DATA('VEHICLE_CODE', l_values);
                l_rate_basis_uom := FTE_UTIL_PKG.GET_DATA('RATE_BASIS_UOM_CODE', l_values);

                IF (l_rate_basis IS NULL OR length(l_rate_basis) = 0 OR l_rate_basis = 'FLAT') THEN
                    l_rate_basis := 'FLAT';
                    l_rate_basis_uom := g_unit_uom;
                ELSIF (l_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,
                                        FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET)) THEN
                    l_rate_basis_uom := g_unit_uom;
                END IF;

            END IF;

            G_ACTION         := UPPER(G_ACTION);
            l_dist_type      := UPPER(l_dist_type);
            l_rate_basis     := UPPER(l_rate_basis);
            l_rate           := Fnd_Number.Canonical_To_Number(l_rate);
            l_min_charge     := Fnd_Number.Canonical_To_Number(l_min_charge);

            IF (p_doValidate) THEN

                FTE_VALIDATION_PKG.VALIDATE_ACTION(p_action      => G_ACTION,
                                                   p_type        => l_type,
                                                   p_line_number => p_line_number + i + 1,
                                                   x_status      => x_status,
                                                   x_error_msg   => x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_VALIDATION_PKG.VALIDATE_ACTION failed');
                    RETURN;
                END IF;

            END IF;

            IF (l_start_date IS NOT NULL) THEN
                BEGIN
                    IF (p_doValidate) THEN
                         l_start_date := to_char(to_date(l_start_date, 'MM/DD/YYYY'), FTE_BULKLOAD_PKG.G_DATE_FORMAT);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_DATE_FORMAT_ERROR');
                        FTE_UTIL_PKG.Write_OutFile( p_msg          => x_error_msg,
                                                     p_module_name => l_module_name,
                                                     p_category    => 'D',
                                                     p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;
            END IF;

            IF (l_end_date IS NOT NULL) THEN
                BEGIN
                    IF (p_doValidate) THEN
                        l_end_date := to_char(to_date(l_end_date, 'MM/DD/YYYY'), FTE_BULKLOAD_PKG.G_DATE_FORMAT);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG('FTE_CAT_DATE_FORMAT_ERROR');
                        FTE_UTIL_PKG.Write_OutFile( p_msg      => x_error_msg,
                                                     p_module_name => l_module_name,
                                                     p_category    => 'D',
                                                     p_line_number => p_line_number + i + 1);

                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                END;
            END IF;

            IF (p_doValidate) THEN
                IF (l_rate < 0 ) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                        p_tokens => STRINGARRAY('ENTITY'),
                                                        p_values => STRINGARRAY('RATE'));
                    FTE_UTIL_PKG.Write_OutFile(p_msg => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF (l_min_charge < 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VALUE_ERROR',
                                                      p_tokens => STRINGARRAY('ENTITY'),
                                                      p_values => STRINGARRAY('MINIMUM_CHARGE'));
                    FTE_UTIL_PKG.Write_OutFile(p_msg => x_error_msg,
                                             p_module_name => l_module_name,
                                             p_category    => 'D',
                                             p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'G_ACTION         ',G_ACTION);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_chart_name',l_rate_chart_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_carrier_name   ',l_carrier_name);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_currency       ',l_currency);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis     ',l_rate_basis);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_basis_uom ',l_rate_basis_uom);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_distance_type  ',l_dist_type);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_service_level  ',l_service_level);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_vehicle_type   ',l_vehicle_type);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate           ',l_rate);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_min_charge     ',l_min_charge);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_start_date',l_start_date);
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'l_rate_end_date  ',l_end_date);
                END IF;

                IF (l_rate_chart_name IS NULL OR LENGTH(l_rate_chart_name) = 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_PRICE_NAME_MISSING');
                    FTE_UTIL_PKG.Write_OutFile(p_msg    => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            END IF;

            IF (G_ACTION IN('UPDATE', 'DELETE')) THEN

                -- For both UPDATE and DELETE, delete the associated Mincharge Modifier of the rate chart

                l_assoc_modifier_ids := FTE_RATE_CHART_PKG.GET_ASSOC_MODIFIERS(NULL, l_rate_chart_name);

                FOR i IN 1..l_assoc_modifier_ids.COUNT
                LOOP
                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleting Modifier ' || l_assoc_modifier_ids(i) || ' of Rate Chart ' || l_rate_chart_name);
                    END IF;

                    FTE_RATE_CHART_PKG.G_CHART_TYPE := 'TL_MODIFIER';
                    FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id  => l_assoc_modifier_ids(i),
                                                      p_name            => NULL,
                                                      p_action          => 'DELETE',
                                                      p_line_number     => p_line_number + i + 1,
                                                      x_status          => x_status,
                                                      x_error_msg       => x_error_msg);


                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_RATE_CHART_PKG.DELETE_FROM_QP returned with error' || x_error_msg);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END LOOP;

                IF (G_ACTION = 'DELETE') THEN
                    --+
                    -- For Delete, we delete and exit
                    --+
                    FOR i IN 1..l_deleted_rate_charts.COUNT
                    LOOP
                       IF (l_rate_chart_name = l_deleted_rate_charts(i)) THEN
                           GOTO next_record;
                       END IF;
                    END LOOP;

                    IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Deleting TL_RATE_CHART ' || l_rate_chart_name);
                    END IF;

                    FTE_RATE_CHART_PKG.G_CHART_TYPE := 'TL_RATE_CHART';

                    FTE_RATE_CHART_PKG.DELETE_FROM_QP(p_list_header_id  => NULL,
                                                      p_name            => l_rate_chart_name,
                                                      p_action          => G_ACTION,
                                                      p_line_number     => p_line_number + i + 1,
                                                      x_status          => x_status,
                                                      x_error_msg       => x_error_msg);
                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Write_LogFile(l_module_name,'FTE_RATE_CHART_PKG.DELETE_FROM_QP returned with error' || x_error_msg);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;

                    l_del_count := l_del_count + 1;
                    l_deleted_rate_charts(l_del_count) := l_rate_chart_name;

                END IF;
            END IF;

            --+
            -- The Carrier associated with the lane and rate chart should be the same.
            --+
            IF (p_doValidate) THEN
                IF (l_carrier_name IS NULL OR LENGTH(l_carrier_name) = 0) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_CARRIER_MISSING');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
                --+
                -- Attribute : Rate Basis, Rate Basis UOM required
                --+
                IF (l_rate_basis IS NULL OR length(l_rate_basis) = 0 OR l_rate_basis = 'FLAT') THEN

                    l_rate_basis := 'FLAT';
                    l_rate_basis_uom := g_unit_uom;

                ELSIF (l_rate_basis NOT IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME,
                                            FTE_RTG_GLOBALS.G_TL_RATE_BASIS_FLAT)) THEN
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_BASIS_INVALID');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                             p_module_name => l_module_name,
                                             p_category    => 'D',
                                             p_line_number => p_line_number + i + 1); -- add tokens
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                ELSIF (l_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST,
                                        FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT,
                                        FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL,
                                        FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME)) THEN

                    --+
                    -- UOM is required for 'DISTANCE', 'TIME', 'VOLUME', 'WEIGHT'
                    -- Note that when called from UI, p_doValidate will be false and we have
                    -- already populated the l_rate_basis_uom with the l_rate_basis_uom_code
                    --+

                    IF (l_rate_basis_uom IS NULL OR LENGTH(l_rate_basis_uom) = 0) THEN
                            x_status := 2;
                            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_RATE_BASIS_UOM_MISSING');
                            FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                       p_module_name => l_module_name,
                                                       p_category    => 'D',
                                                       p_line_number => p_line_number + i + 1);
                            FTE_UTIL_PKG.Exit_Debug(l_module_name);
                            RETURN;
                    ELSE
                            l_rate_basis_uom := FTE_UTIL_PKG.GET_UOM_CODE(p_uom => l_rate_basis_uom);

                            IF (l_rate_basis_uom IS NULL) THEN
                                x_status := 2;
                                x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_UOM_INVALID');
                                FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                           p_module_name => l_module_name,
                                                           p_category    => 'B',
                                                           p_line_number =>  p_line_number + i + 1);
                                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                                RETURN;
                            END IF;
                     END IF;

                ELSIF (l_rate_basis IN (FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT,
                                    FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET)) THEN
                    l_rate_basis_uom := g_unit_uom;
                END IF;

                --+
                -- Distance Type(loaded, unloaded and continuous) is required if rate_basis is DISTANCE
                --+
                IF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST) THEN
                    IF (l_dist_type IS NULL OR LENGTH(l_dist_type) = 0) THEN
                        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_DISTANCE_TYPE_MISSING');
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    =>'D',
                                                   p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Service Level is required.
                --+
                l_service_level := FTE_VALIDATION_PKG.VALIDATE_SERVICE_LEVEL(p_carrier_id    => NULL,
                                                                             p_carrier_name  => l_carrier_name,
                                                                             p_service_level => l_service_level,
                                                                             p_line_number   => p_line_number + i + 1,
                                                                             x_error_msg     => x_error_msg,
                                                                             x_status        => x_status);
                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

		IF (l_vehicle_type IS NULL ) THEN
		        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VEHICLE_MISSING');
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    =>'D',
                                                   p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
		END IF;

                --+
                -- To populate l_vehicle_type with l_vehicle_type_id
                -- This call is not needed when called from UI
                --+
                l_vehicle_type := FTE_UTIL_PKG.GET_VEHICLE_TYPE(p_vehicle_type => l_vehicle_type);

		IF (l_vehicle_type IS NULL ) THEN
		        x_status := 2;
                        x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_CAT_VEH_NOT_DEFINED');
                        FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                                   p_module_name => l_module_name,
                                                   p_category    =>'D',
                                                   p_line_number => p_line_number + i + 1);
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
		END IF;

            END IF;

            --+
            -- Get the chart data, from the cache.
            --+
            GET_CHART_DATA(p_chart_name    => l_rate_chart_name,
                           p_currency      => l_currency,
                           p_chart_type    => 'TL_RATE_CHART',
                           x_carrier_name  => l_carrier_name,
                           x_service_level => l_service_level,
                           x_cur_line      => l_linenum,
                           x_job_id        => l_process_id,
                           p_line_number   => p_line_number + i + 1,
                           x_error_msg     => x_error_msg,
                           x_status        => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            GET_CARRIER_PREFERENCES (p_carrier_name   => l_carrier_name,
                                     p_service_level  => l_service_level,
                                     p_line_number    => p_line_number + i + 1,
                                     x_status         => x_status,
                                     x_error_msg      => x_error_msg);

            IF (p_doValidate) THEN

                --+
                -- Validate Against Carrier Preferences
                --+
                CHECK_RATE_BASIS(p_carrier_name       => l_carrier_name,
                                 p_rate_basis         => l_rate_basis,
                                 p_rate_basis_uom     => l_rate_basis_uom,
                                 p_service_level      => l_service_level,
                                 p_line_number        => p_line_number + i + 1,
                                 x_status             => x_status,
                                 x_error_msg          => x_error_msg);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            END IF;

            --+
            -- Set the precedence and rate type, store min charges
            --+
            IF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST) THEN

                IF (l_dist_type = FTE_RTG_GLOBALS.G_TL_DIST_TYPE_UNLOADED) THEN
                    l_attribute := FTE_RTG_GLOBALS.G_C_UNLOADED_DISTANCE_RT;
                    l_precedence := G_CONST_PRECEDENCE_LOW;
                    l_deadhead   := TRUE;
                ELSIF (l_dist_type = FTE_RTG_GLOBALS.G_TL_DIST_TYPE_CM) THEN
                    l_attribute := FTE_RTG_GLOBALS.G_C_CONTINUOUS_MOVE_DIST_RT;
                    l_precedence := G_CONST_PRECEDENCE_MID;
                ELSIF (l_dist_type = 'LOADED') THEN
                    l_attribute := FTE_RTG_GLOBALS.G_C_LOADED_DISTANCE_RT;
                ELSE
                    x_status := 2;
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_DISTANCE_TYPE_INVALID');
                    FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                                p_module_name => l_module_name,
                                                p_category    =>'D',
                                                p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_FLAT) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_FLAT_RT;
            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_TIME) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_TIME_RT;
            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_WT) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_UNIT_WT_RT;
            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_VOL) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_UNIT_VOL_RT;
            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_CONT) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_UNIT_CONT_RT;
            ELSIF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_PALLET) THEN
                l_attribute := FTE_RTG_GLOBALS.G_C_UNIT_PALLET_RT;
            END IF;

            --+
            -- For the first line of the RC, we have to create the header.
            --
            -- In the call to GET_CHART_DATA(), this l_line_num has been passed
            -- as an output parameter to get the value.
            --
            -- If it is the first time, then it should be zero
            -- else it will have a non-zero value equal to the number of lines processed + 1 (header)
            --+
            IF (l_linenum = 0) THEN

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating Rate Chart Header For ' || l_rate_chart_name);
                END IF;

                l_description := 'Rate Chart ' || l_rate_chart_name;

                l_rate_hdr_data('ACTION')        := G_ACTION;
                l_rate_hdr_data('TL_CHART_NAME') := l_rate_chart_name;
                l_rate_hdr_data('DESCRIPTION')   := l_description;
                l_rate_hdr_data('START_DATE')    := l_start_date;
                l_rate_hdr_data('END_DATE')      := l_end_date;
                l_rate_hdr_data('CURRENCY')      := l_currency;
                l_rate_hdr_data('CARRIER_NAME')  := l_carrier_name;
                l_rate_hdr_data('SERVICE_LEVEL') := l_service_level;
                l_rate_hdr_data('ATTRIBUTE1')    := 'TL_RATE_CHART';

                l_rate_hdr_block_tbl(1) := l_rate_hdr_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_CHART(p_block_header => g_dummy_block_hdr_tbl,
                                                         p_block_data   => l_rate_hdr_block_tbl,
                                                         p_line_number  => p_line_number + i + 1,
                                                         p_validate_column => FALSE,
                                                         p_process_id   => l_process_id,
                                                         x_status       => x_status,
                                                         x_error_msg    => x_error_msg);

                l_rate_hdr_data.DELETE;
                l_rate_hdr_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- The first two lines in each rate chart should be 'dummy' rate chart lines.
                -- The first one should have a rate type of 'STOP_CHARGE', and
                -- the second one should have a rate type of 'LOAD_CHARGE'.
                --
                -- Rate chart dummy line 1
                --+
                l_linenum := l_linenum + 1;
                l_description := 'Line ' || l_linenum || ' Of ' || l_rate_chart_name;

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating ' || l_description);
                END IF;

                l_rate_line_data('ACTION')      := G_ACTION;
                l_rate_line_data('LINE_NUMBER') := l_linenum;
                l_rate_line_data('DESCRIPTION') := l_description;
                l_rate_line_data('RATE')        := 0;
                l_rate_line_data('UOM')         := g_unit_uom;
                l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
                l_rate_line_data('ATTRIBUTE1')  := FTE_RTG_GLOBALS.G_C_STOP_LEVEL_CHARGES_RT;
                l_rate_line_data('PRECEDENCE')  := l_precedence;
                l_rate_line_data('RATE_TYPE')   := 'PER_UOM';
		l_rate_line_data('START_DATE_ACTIVE') := l_start_date;
		l_rate_line_data('END_DATE_ACTIVE') := l_end_date;

                l_rate_line_block_tbl(1) := l_rate_line_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_rate_line_block_tbl,
                                                        p_line_number   => p_line_number + i + 1,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);

                l_rate_line_data.DELETE;
                l_rate_line_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Add Rate Type Attribute 'STOP_CHARGE'
                --+
                l_attribute_type  := 'TL_RATE_TYPE';
                l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_STOP;
                ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                               p_attribute_value     => l_attribute_value,
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE,
                               p_linenum             => l_linenum,
                               p_comp_operator       => NULL,
                               p_process_id          => l_process_id,
                               p_line_number         => p_line_number + i + 1,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Rate Chart dummy line 2
                --+
                l_linenum := l_linenum + 1;
                l_description := 'Line ' || l_linenum || ' Of ' || l_rate_chart_name;

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating ' || l_description);
                END IF;

                l_rate_line_data('ACTION')     := G_ACTION;
                l_rate_line_data('LINE_NUMBER'):= l_linenum;
                l_rate_line_data('DESCRIPTION'):= l_description;
                l_rate_line_data('RATE')       := 0;
                l_rate_line_data('UOM')        := g_unit_uom;
                l_rate_line_data('VOLUME_TYPE'):= 'TOTAL_QUANTITY';
                l_rate_line_data('ATTRIBUTE1') := FTE_RTG_GLOBALS.G_C_LOAD_LEVEL_CHARGES_RT;
                l_rate_line_data('PRECEDENCE') := l_precedence;
                l_rate_line_data('RATE_TYPE')  := 'PER_UOM';
		l_rate_line_data('START_DATE_ACTIVE') := l_start_date;
		l_rate_line_data('END_DATE_ACTIVE') := l_end_date;

                l_rate_line_block_tbl(1) := l_rate_line_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_rate_line_block_tbl,
                                                        p_line_number   => p_line_number + i + 1,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);
                l_rate_line_data.DELETE;
                l_rate_line_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Add Rate Type Attribute 'LOAD_CHARGE'
                --+
                l_attribute_type := 'TL_RATE_TYPE';
                l_attribute_value := FTE_RTG_GLOBALS.G_TL_RATE_TYPE_LOAD;
                ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                              p_attribute_value     => l_attribute_value,
                              p_attribute_value_to  => NULL,
                              p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE,
                              p_linenum             => l_linenum,
                              p_comp_operator       => NULL,
                              p_process_id          => l_process_id,
                              p_line_number         => p_line_number + i + 1,
                              x_error_msg           => x_error_msg,
                              x_status              => x_status);

            END IF;

            --+
            -- Create a  RATE CHART LINE
            --+
            l_linenum := l_linenum + 1;
            l_description := 'Line ' || l_linenum || ' Of ' || l_rate_chart_name;

            IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating ' || l_description);
            END IF;

            l_rate_line_data('ACTION')      := G_ACTION;
            l_rate_line_data('LINE_NUMBER') := l_linenum;
            l_rate_line_data('DESCRIPTION') := l_description;
            l_rate_line_data('RATE')        := Fnd_Number.Number_To_Canonical(l_rate);
            l_rate_line_data('UOM')         := l_rate_basis_uom;
            l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
            l_rate_line_data('ATTRIBUTE1')  := l_attribute;
            l_rate_line_data('PRECEDENCE')  := l_precedence;
            l_rate_line_data('RATE_TYPE')   := 'PER_UOM';
	    l_rate_line_data('START_DATE_ACTIVE') := l_start_date;
            l_rate_line_data('END_DATE_ACTIVE') := l_end_date;

            l_rate_line_block_tbl(1) := l_rate_line_data;

            FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                    p_block_data    => l_rate_line_block_tbl,
                                                    p_line_number   => p_line_number + i + 1,
                                                    p_validate_column => FALSE,
                                                    x_status        => x_status,
                                                    x_error_msg     => x_error_msg);
            l_rate_line_data.DELETE;
            l_rate_line_block_tbl.DELETE;

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- RATE_BASIS Attribute should be attached to each line
            --+
            l_attribute_type := 'TL_RATE_BASIS';
            ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                           p_attribute_value     => l_rate_basis,
                           p_attribute_value_to  => NULL,
                           p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_BASIS,
                           p_linenum             => l_linenum,
                           p_comp_operator       => NULL,
                           p_process_id          => l_process_id,
                           p_line_number         => p_line_number + i + 1,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Add DISTANCE_TYPE attribute if rate basis is DISTANCE
            -- and distance type IS NOT LOADED
            --+
            IF (l_rate_basis = FTE_RTG_GLOBALS.G_TL_RATE_BASIS_DIST AND
                l_dist_type IN ('UNLOADED', 'CONTINUOUS_MOVE')) THEN

                l_attribute_type := 'TL_DISTANCE_TYPE';
                ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                              p_attribute_value     => l_dist_type,
                              p_attribute_value_to  => NULL,
                              p_context             => FTE_RTG_GLOBALS.G_AX_TL_DISTANCE_TYPE,
                              p_linenum             => l_linenum,
                              p_comp_operator       => NULL,
                              p_process_id          => l_process_id,
                              p_line_number         => p_line_number + i + 1,
                              x_error_msg           => x_error_msg,
                              x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;

            --+
            -- RATE_TYPE Attribute should be attached to each line
            --+
            l_attribute_type  := 'TL_RATE_TYPE';
            l_attribute_value := 'BASE_RATE';
            ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                           p_attribute_value     => l_attribute_value,
                           p_attribute_value_to  => NULL,
                           p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE,
                           p_linenum             => l_linenum,
                           p_comp_operator       => NULL,
                           p_process_id          => l_process_id,
                           p_line_number         => p_line_number + i + 1,
                           x_error_msg           => x_error_msg,
                           x_status              => x_status);

            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- Add the VEHICLE_TYPE attribute.
            --+
            IF (l_vehicle_type IS NOT NULL AND LENGTH(l_vehicle_type) > 0) THEN

                l_attribute_type := 'TL_VEHICLE_TYPE';
                ADD_ATTRIBUTE (p_attribute_type    => l_attribute_type,
                               p_attribute_value     => l_vehicle_type,
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_VEHICLE,
                               p_linenum             => l_linenum,
                               p_process_id          => l_process_id,
                               p_comp_operator       => NULL,
                               p_line_number         => p_line_number,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;

            --+
            -- If rate basis is 'DISTANCE' and distance type is 'UNLOADED', then
            -- we create an additional line and attach the
            -- 'CONTINUOUS_MOVE_DEADHEAD_RATING' attribute.
            --+
            IF (l_deadhead) THEN

                l_deadhead := FALSE;

                --+
                -- Create Rate Line
                --+
                l_linenum := l_linenum + 1;
                l_description := 'Line ' || l_linenum || ' Of ' || l_rate_chart_name;

                l_attribute := FTE_RTG_GLOBALS.G_C_CONTINUOUS_MOVE_DH_RT;
                l_precedence := G_CONST_PRECEDENCE_LOW;

                IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
                    FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Creating ' || l_description);
                END IF;

                l_rate_line_data('ACTION')      := G_ACTION;
                l_rate_line_data('LINE_NUMBER') := l_linenum;
                l_rate_line_data('DESCRIPTION') := l_description;
                l_rate_line_data('RATE')        := Fnd_Number.Number_To_Canonical(l_rate);
                l_rate_line_data('UOM')         := l_rate_basis_uom;
                l_rate_line_data('VOLUME_TYPE') := 'TOTAL_QUANTITY';
                l_rate_line_data('ATTRIBUTE1')  := l_attribute;
                l_rate_line_data('PRECEDENCE')  := l_precedence;
                l_rate_line_data('RATE_TYPE')   := 'PER_UOM';
		l_rate_line_data('START_DATE_ACTIVE') := l_start_date;
                l_rate_line_data('END_DATE_ACTIVE') := l_end_date;

                l_rate_line_block_tbl(1) := l_rate_line_data;

                FTE_RATE_CHART_LOADER.PROCESS_RATE_LINE(p_block_header  => g_dummy_block_hdr_tbl,
                                                        p_block_data    => l_rate_line_block_tbl,
                                                        p_line_number   => p_line_number + i + 1,
                                                        p_validate_column => FALSE,
                                                        x_status        => x_status,
                                                        x_error_msg     => x_error_msg);
                l_rate_line_data.DELETE;
                l_rate_line_block_tbl.DELETE;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Attach the DEADHEAD_RATING to the line
                --+
                l_attribute_type := 'TL_DEADHEAD_RT_VAR';
                ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                               p_attribute_value     => FTE_RTG_GLOBALS.G_TL_DEADHEAD_RT_VAR_YES,
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_TL_DEADHEAD_RT_VAR,
                               p_linenum             => l_linenum,
                               p_process_id          => l_process_id,
                               p_comp_operator       => NULL,
                               p_line_number         => p_line_number + i + 1,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Attach the Rate Basis Attribute to the line
                --+
                l_attribute_type := 'TL_RATE_BASIS';
                ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                              p_attribute_value     => l_rate_basis,
                              p_attribute_value_to  => NULL,
                              p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_BASIS,
                              p_linenum             => l_linenum,
                              p_process_id          => l_process_id,
                              p_comp_operator       => NULL,
                              p_line_number         => p_line_number + i + 1,
                              x_error_msg           => x_error_msg,
                              x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Attach the Distance Type 'CONTINUOUS_MOVE' to the line.
                --+
                l_attribute_type := 'TL_DISTANCE_TYPE';
                ADD_ATTRIBUTE (p_attribute_type      => l_attribute_type,
                               p_attribute_value     => FTE_RTG_GLOBALS.G_TL_DIST_TYPE_CM,
                               p_attribute_value_to  => NULL,
                               p_context             => FTE_RTG_GLOBALS.G_AX_TL_DISTANCE_TYPE,
                               p_linenum             => l_linenum,
                               p_comp_operator       => NULL,
                               p_process_id          => l_process_id,
                               p_line_number         => p_line_number + i + 1,
                               x_error_msg           => x_error_msg,
                               x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;

                --+
                -- Attach the Rate Type (BASE_RATE) Attribute
                --+
                l_attribute_type  := 'TL_RATE_TYPE';
                l_attribute_value := 'BASE_RATE';

                ADD_ATTRIBUTE(p_attribute_type      => l_attribute_type,
                              p_attribute_value     => l_attribute_value,
                              p_attribute_value_to  => NULL,
                              p_context             => FTE_RTG_GLOBALS.G_AX_TL_RATE_TYPE,
                              p_linenum             => l_linenum,
                              p_comp_operator       => NULL,
                              p_process_id          => l_process_id,
                              p_line_number         => p_line_number + i + 1,
                              x_error_msg           => x_error_msg,
                              x_status              => x_status);

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;


                --+
                -- Add the VEHICLE_TYPE (optional) attribute if the vehicle is specified
                --+
                IF (l_vehicle_type IS NOT NULL AND LENGTH(l_vehicle_type) > 0) THEN
                    --+
                    -- Vehicle Type has already been translated to ID format
                    --+
                    l_attribute_type := 'TL_VEHICLE_TYPE';
                    ADD_ATTRIBUTE ( p_attribute_type      => l_attribute_type,
                                    p_attribute_value     => l_vehicle_type,
                                    p_attribute_value_to  => NULL,
                                    p_context             => FTE_RTG_GLOBALS.G_AX_VEHICLE,
                                    p_linenum             => l_linenum,
                                    p_comp_operator       => NULL,
                                    p_process_id          => l_process_id,
                                    p_line_number         => p_line_number + i + 1,
                                    x_error_msg           => x_error_msg,
                                    x_status              => x_status);

                    IF (x_status <> -1) THEN
                        FTE_UTIL_PKG.Exit_Debug(l_module_name);
                        RETURN;
                    END IF;
                END IF;
            END IF;


            --+
            -- Validate and store the minimum charge, if it is specified.
            --+
            IF (l_min_charge IS NOT NULL) THEN
                IF (l_rate_basis <> FTE_RTG_GLOBALS.G_TL_RATE_BASIS_FLAT) THEN
                    STORE_MIN_CHARGE(p_chart_name => l_rate_chart_name,
                                     p_charge     => l_min_charge,
                                     p_basis      => l_rate_basis,
                                     p_uom        => l_rate_basis_uom,
                                     p_vehicle    => l_vehicle_type,
                                     p_line_number => p_line_number + i + 1,
                                     x_error_msg  => x_error_msg,
                                     x_status     => x_status);

                ELSE
                    x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_FLAT_MIN_NOT_ALLOWED');
                    FTE_UTIL_PKG.Write_OutFile(p_msg         => x_error_msg,
                                               p_module_name => l_module_name,
                                               p_category    => 'D',
                                               p_line_number => p_line_number + i + 1);
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    x_status := 2;
                    RETURN;
                END IF;

                IF (x_status <> -1) THEN
                    FTE_UTIL_PKG.Exit_Debug(l_module_name);
                    RETURN;
                END IF;
            END IF;

            SET_CHART_LINE(l_rate_chart_name, l_linenum, x_status);

        <<next_record>> NULL;

        END LOOP;

        SUBMIT_TL_CHART(x_status, x_error_msg);

        IF (FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return status from SUBMIT_TL_CHART  ', x_status);
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'Return Message from SUBMIT_TL_CHART ', x_error_msg);
        END IF;

        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
           x_status := 2;
           x_error_msg := sqlerrm;
           FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR occured in PROCESS_TL_BASE_RATES ', sqlerrm);
           FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_TL_BASE_RATES;

    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_TL_SERVICES                                                  --
    --                                                                                 --
    -- Purpose: This is called by PROCESS_DATA if the type to be processed   --
    --          is 'TL_SERVICES'. By uploading a 'TL_SERVICE' block, the user is       --
    --          creating a tl service, a ratechart - service association and           --
    --          a service level in the system.                                         --
    --                                                                                 --
    -- IN Parameters                                                                   --
    --    1. p_block_header: An associative array with column names in the upload file,--
    --                       as indices and integers as values.                        --
    --    2. p_block_data  : A table of associative array. Each element in the table   --
    --                       represents a single line of data in the upload file.      --
    --    3. p_line_number : Specifies the line number in the file where this block    --
    --                       begins.This is used for error logging, which aims         --
    --                       at ease of loader usage.                                  --
    --                                                                                 --
    -- Out Parameters                                                                  --
    --    x_status  :  the return status, -1 for success                               --
    --                                     2 for failure.                              --
    --    x_error_msg: the corresponding error meassge,                                --
    --                 if any exception occurs during the process.                     --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_TL_SERVICES(p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                                  p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                                  p_line_number     IN  NUMBER,
                                  x_status          OUT NOCOPY  NUMBER,
                                  x_error_msg       OUT NOCOPY  VARCHAR2) IS

        l_action       VARCHAR2(100);
        l_values       FTE_BULKLOAD_PKG.data_values_tbl;

        l_mode         CONSTANT VARCHAR2(50)  := 'TRUCK';
        l_type         VARCHAR2(25)  := 'TL_SERVICES';
        l_module_name  CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_TL_SERVICES';

        /* Columns in TL-Services.
        ACTION, CARRIER_NAME, SERVICE_NUMBER,
        ORIGIN_COUNTRY, ORIGIN_STATE, ORIGIN_CITY, ORIGIN_POSTAL_CODE_FROM, ORIGIN_POSTAL_CODE_TO, ORIGIN_ZONE,
        DESTINATION_COUNTRY, DESTINATION_STATE, DESTINATION_CITY, DESTINATION_POSTAL_CODE_FROM, DESTINATION_POSTAL_CODE_TO, DESTINATION_ZONE,
        SERVICE_START_DATE, SERVICE_END_DATE,
        SERVICE_LEVEL, RATE_CHART_NAME
        */

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        FTE_VALIDATION_PKG.VALIDATE_COLUMNS(p_keys      => p_block_header,
                                            p_type      => l_type,
                                            p_line_number => p_line_number+1,
                                            x_status    => x_status,
                                            x_error_msg => x_error_msg);
        IF (x_status <> -1) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'VALIDATE_COLUMNS returned with Error');
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        FOR i IN 1..p_block_data.COUNT LOOP

            l_values := p_block_data(i);

            -- Validate ACTION.
            -- The valid actions for TL are ADD, DELETE and  UPDATE.
            l_action := FTE_UTIL_PKG.GET_DATA('ACTION', l_values);


            FTE_VALIDATION_PKG.VALIDATE_ACTION(p_action      => l_action,
                                               p_type        => l_type,
                                               p_line_number => p_line_number + i + 1,
                                               x_status      => x_status,
                                               x_error_msg   => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'VALIDATE_ACTION returned with Error');
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

            --+
            -- VALIDATE_TL_SERVICE validates CARRIER,MODE etc., of the line
            -- and put the values in the pl/sql tables passed. We collect the values in these pl/sql
            -- tables and do a bulk insert after the processing all the lines.
            --+
            FTE_VALIDATION_PKG.VALIDATE_TL_SERVICE(p_values             => l_values,
                                                   p_line_number        => p_line_number + i + 1,
                                                   p_type               => l_type,
                                                   p_action             => l_action,
                                                   p_lane_tbl           => g_lane_tbl,
                                                   p_lane_service_tbl   => g_lane_service_tbl,
                                                   p_lane_rate_chart_tbl=> g_lane_rate_chart_tbl,
                                                   x_status             => x_status,
                                                   x_error_msg          => x_error_msg);
            IF (x_status <> -1) THEN
                FTE_UTIL_PKG.Write_LogFile(l_module_name, 'VALIDATE_TL_SERVICE returned with Error');
                FTE_UTIL_PKG.Exit_Debug(l_module_name);
                RETURN;
            END IF;

        END LOOP;

        FTE_LANE_PKG.INSERT_LANE_TABLES(p_lane_tbl            => g_lane_tbl,
                                        p_lane_rate_chart_tbl => g_lane_rate_chart_tbl,
                                        p_lane_commodity_tbl  => g_lane_commodity_tbl,
                                        p_lane_service_tbl    => g_lane_service_tbl,
                                        x_status              => x_status,
                                        x_error_msg           => x_error_msg);

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION
        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'UNEXPECTED ERROR OCCURED IN ' || l_module_name);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_TL_SERVICES;


    --_________________________________________________________________________________--
    --                                                                                 --
    -- PROCEDURE: PROCESS_DATA                                                         --
    --                                                                                 --
    -- PURPOSE: Call appropriate process_xxx based on the type.                        --
    --          where xxx is one of TL_SERVICES, TL_BASE_RATES,TL_SURCHARGES,          --
    --          and FACILITY_CHARGES                                                   --
    --                                                                                 --
    -- PARAMETERS:                                                                     --
    -- IN                                                                              --
    --    0. p_type        : Type of the block to be processed. This calls             --
    --                       the appropriate PROCESS_XXX depending on this parameter.  --
    --                       In R12, It can take the following four values.            --
    --                       TL_SERVICES, TL_BASE_RATES,TL_SURCHARGES                  --
    --                       and FACILITY_CHARGES                                      --
    --    1. p_block_header: An associative array with column names in the upload file,--
    --                       as indices and integers as values.                        --
    --    2. p_block_data  : A table of associative array. Each element in the table   --
    --                       represents a single line of data in the upload file.      --
    --    3. p_line_number : Specifies the line number in the file where this block    --
    --                       begins.This is used for error logging, which aims         --
    --                       at ease of loader usage.                                  --
    --                                                                                 --
    -- OUT parameters:                                                                 --
    --    1. x_status:    status of the processing, -1 means no error                  --
    --    2. x_error_msg: error message if any.                                        --
    --_________________________________________________________________________________--

    PROCEDURE PROCESS_DATA (  p_type            IN  VARCHAR2,
                              p_block_header    IN  FTE_BULKLOAD_PKG.block_header_tbl,
                              p_block_data      IN  FTE_BULKLOAD_PKG.block_data_tbl,
                              p_line_number     IN  NUMBER,
                              x_status          OUT NOCOPY NUMBER,
                              x_error_msg       OUT NOCOPY VARCHAR2) IS

    l_module_name       CONSTANT VARCHAR2(100) := 'FTE.PLSQL.' || G_PKG_NAME || '.PROCESS_DATA';

    BEGIN

        FTE_UTIL_PKG.Enter_Debug(l_module_name);
        x_status := -1;

        IF(FTE_BULKLOAD_PKG.g_debug_on) THEN
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_type              ', p_type);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_block_header count', p_block_header.COUNT);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_block_data.count  ', p_block_data.count);
            FTE_UTIL_PKG.Write_LogFile(l_module_name,'p_line_number       ', p_line_number);
        END IF;

        IF(p_block_header.COUNT =0 OR p_block_data.COUNT = 0 ) THEN
            x_status := 2;
            x_error_msg := FTE_UTIL_PKG.GET_MSG(p_name => 'FTE_COLUMN_OR_DATA_MISSING');
            FTE_UTIL_PKG.Write_OutFile( p_msg    => x_error_msg,
                                        p_module_name => l_module_name,
                                        p_category    => 'D',
                                        p_line_number => p_line_number);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);
            RETURN;
        END IF;

        IF (p_type = 'TL_SERVICES') THEN

            PROCESS_TL_SERVICES(p_block_header => p_block_header,
                                p_block_data   => p_block_data,
                                p_line_number  => p_line_number,
                                x_status       => x_status,
                                x_error_msg    => x_error_msg);

        ELSIF (p_type = 'TL_BASE_RATES') THEN

            PROCESS_TL_BASE_RATES(p_block_header => p_block_header,
                                  p_block_data   => p_block_data,
                                  p_line_number  => p_line_number,
                                  p_doValidate   => TRUE,
                                  x_status       => x_status,
                                  x_error_msg    => x_error_msg);

        ELSIF (p_type = 'TL_SURCHARGES') THEN

            PROCESS_TL_SURCHARGES(p_block_header => p_block_header,
                                  p_block_data   => p_block_data,
                                  p_line_number  => p_line_number,
                                  x_status       => x_status,
                                  x_error_msg    => x_error_msg);

        ELSIF (p_type = 'FACILITY_CHARGES') THEN

            PROCESS_FACILITY_CHARGES(p_block_header => p_block_header,
                                     p_block_data   => p_block_data,
                                     p_line_number  => p_line_number,
                                     x_status       => x_status,
                                     x_error_msg    => x_error_msg);
        ELSE
                -- Unreacheable code --
                x_status := 2;
                FTE_UTIL_PKG.Write_LogFile(l_module_name,'INVALID BLOCK TYPE');

        END IF;

        FTE_UTIL_PKG.Exit_Debug(l_module_name);

    EXCEPTION

        WHEN OTHERS THEN
            x_status := 2;
            FTE_UTIL_PKG.Write_LogFile(l_module_name, 'UNEXPECTED ERROR OCCURED IN ' || l_module_name || sqlerrm);
            FTE_UTIL_PKG.Exit_Debug(l_module_name);

    END PROCESS_DATA;

END FTE_TL_LOADER;

/
