--------------------------------------------------------
--  DDL for Package FTE_LTL_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LTL_LOADER" AUTHID CURRENT_USER AS
/* $Header: FTELTLRS.pls 120.0 2005/06/28 02:24:35 pkaliyam noship $ */
  --
  -- Package
  --    FTE_BULKLOAD_LTL
  --
  -- global package variables

    TYPE NUMBER_TAB          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE POSITIVE_NUMBER_TAB IS TABLE OF NATURAL INDEX BY BINARY_INTEGER;

    TYPE VAR_ARR40   IS TABLE OF VARCHAR2(1200);
    TYPE VAR_ARR4000 IS TABLE OF VARCHAR2(4000);
    TYPE VAR_ARR15   IS TABLE OF VARCHAR2(15);
    TYPE VAR_ARR10   IS TABLE OF VARCHAR2(10);
    TYPE NUMBER_ARR  IS TABLE OF NUMBER;
    TYPE VAR_ARR100  IS TABLE OF VARCHAR2(100);

    TYPE VAR_ARR10_INDEX IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
    TYPE VAR_ARR40_INDEX IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;

    TYPE LANES_TEMP_RECORD IS RECORD(
                                      rate_chart_string  var_arr40,
                                      dest_low           var_arr10,
                                      dest_high          var_arr10,
                                      class              var_arr100,
                                      min_charge1        var_arr10,
                                      rate_chart_name    var_arr40,
                                      origin_id          number_arr,
                                      dest_id            number_arr);

    TYPE ZONES_TEMP_RECORD IS RECORD(
                                    zone_name          var_arr40,
                                    dest_low           var_arr10,
                                    dest_high          var_arr10,
                                    hash_value         number_arr,
                                    dest_string        var_arr4000,
                                    row_number         number_arr,
                                    owner_id           number_arr);

    TYPE ZONE_INFO_RECORD IS RECORD(
                                   zone_name            var_arr40,
                                   sum_row_number       number_arr,
                                   max_row_number       number_arr,
                                   sum_hash_value       number_arr,
                                   sum_postal_code_from number_arr,
                                   sum_postal_code_to   number_arr);

    -- Used in Read_LTL_File

    TYPE  FL_SCAC_TAB           IS TABLE OF  FTE_BULKLOAD_FILE.SCAC%TYPE           INDEX BY BINARY_INTEGER;
    TYPE  FL_EFFECTIVE_DATE_TAB IS TABLE OF  FTE_BULKLOAD_FILE.EFFECTIVE_DATE%TYPE INDEX BY BINARY_INTEGER;
    TYPE  FL_OUTBOUND_FLAG_TAB  IS TABLE OF  FTE_BULKLOAD_FILE.OUTBOUND_FLAG%TYPE  INDEX BY BINARY_INTEGER;

    FL_LOAD_ID                  NUMBER_TAB;
    FL_SCAC                     FL_SCAC_TAB;
    FL_ORIGIN_LOW               VAR_ARR10_INDEX;
    FL_ORIGIN_HIGH              VAR_ARR10_INDEX;
    FL_DEST_LOW                 VAR_ARR10_INDEX;
    FL_DEST_HIGH                VAR_ARR10_INDEX;
    FL_CLASS                    NUMBER_TAB;
    FL_MIN_CHARGE1              POSITIVE_NUMBER_TAB;
    FL_L5C                      POSITIVE_NUMBER_TAB;
    FL_M5C                      POSITIVE_NUMBER_TAB;
    FL_M1M                      POSITIVE_NUMBER_TAB;
    FL_M2M                      POSITIVE_NUMBER_TAB;
    FL_M5M                      POSITIVE_NUMBER_TAB;
    FL_M10M                     POSITIVE_NUMBER_TAB;
    FL_M20M                     POSITIVE_NUMBER_TAB;
    FL_M30M                     POSITIVE_NUMBER_TAB;
    FL_M40M                     POSITIVE_NUMBER_TAB;
    FL_EFFECTIVE_DATE           FL_EFFECTIVE_DATE_TAB;
    FL_OUTBOUND_FLAG            FL_OUTBOUND_FLAG_TAB;
    FL_MILEAGE                  POSITIVE_NUMBER_TAB;

    TYPE LN_COMM_FC_CLASS_CODE_TAB IS TABLE OF FTE_LANES.COMM_FC_CLASS_CODE%TYPE INDEX BY BINARY_INTEGER;
    TYPE LN_LANE_TYPE_TAB          IS TABLE OF FTE_LANES.LANE_TYPE%TYPE          INDEX BY BINARY_INTEGER;
    TYPE LN_TARIFF_NAME_TAB        IS TABLE OF FTE_LANES.TARIFF_NAME%TYPE        INDEX BY BINARY_INTEGER;

    LN_LANE_ID             NUMBER_TAB;
    LN_CARRIER_ID          NUMBER_TAB;
    LN_ORIGIN_ID           NUMBER_TAB;
    LN_DEST_ID             NUMBER_TAB;
    LN_COMMODITY_CATG_ID   NUMBER_TAB;
    LN_COMM_FC_CLASS_CODE  LN_COMM_FC_CLASS_CODE_TAB;
    LN_LANE_TYPE           LN_LANE_TYPE_TAB;
    LN_TARIFF_NAME         LN_TARIFF_NAME_TAB;
    LN_START_DATE          var_arr40_index;
    LN_END_DATE            var_arr40_index;

    TYPE PRC_VALUE_FROM_TAB         IS TABLE OF FTE_PRC_PARAMETERS.VALUE_FROM%TYPE     INDEX BY BINARY_INTEGER;
    TYPE PRC_PARAMETER_ID_TAB       IS TABLE OF FTE_PRC_PARAMETERS.PARAMETER_ID%TYPE   INDEX BY BINARY_INTEGER;

    PRC_VALUE_FROM        PRC_VALUE_FROM_TAB;
    PRC_PARAMETER_ID      PRC_PARAMETER_ID_TAB;
    PRC_LANE_ID           NUMBER_TAB;

    TYPE CM_CATG_ID_TAB  IS TABLE OF FTE_LANE_COMMODITIES.COMMODITY_CATG_ID%TYPE   INDEX BY BINARY_INTEGER;

    CM_CATG_ID             CM_CATG_ID_TAB;
    CM_LANE_ID             NUMBER_TAB;


    TYPE LRC_LANE_ID_TAB            IS TABLE OF FTE_LANE_RATE_CHARTS.LANE_ID%TYPE            INDEX BY BINARY_INTEGER;
    TYPE LRC_LIST_HEADER_ID_TAB     IS TABLE OF FTE_LANE_RATE_CHARTS.LIST_HEADER_ID%TYPE     INDEX BY BINARY_INTEGER;

    LRC_LANE_ID            LRC_LANE_ID_TAB;
    LRC_LIST_HEADER_ID     LRC_LIST_HEADER_ID_TAB;
    LRC_START_DATE         var_arr40_index;
    LRC_END_DATE           var_arr40_index;


    TYPE lane_number_tab   IS TABLE OF fte_lanes.lane_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE zone_tab          IS TABLE OF wsh_regions_tl.zone%TYPE INDEX BY BINARY_INTEGER;
    TYPE carrier_name_tab  IS TABLE OF hz_parties.party_name%TYPE INDEX BY BINARY_INTEGER;
    TYPE min_charge_tab    IS TABLE OF fte_prc_parameters.value_from%TYPE INDEX BY BINARY_INTEGER;
    TYPE ZoneNamesTab      IS TABLE OF fte_interface_zones.zone_name%TYPE INDEX BY BINARY_INTEGER;
    TYPE RateChartNamesTab IS TABLE OF qp_list_headers_tl.name%TYPE INDEX BY BINARY_INTEGER;

    TYPE LTL_REPORT_HEADER IS RECORD(StartDate      VARCHAR2(100),
                                     EndDate        VARCHAR2(100),
                                     FileName       VARCHAR2(100),
                                     TariffName     VARCHAR2(150),
                                     ServiceLevel   VARCHAR2(60),
                                     Orig_Country   VARCHAR2(80),
                                     Dest_Country   VARCHAR2(80),
                                     Currency       VARCHAR2(50),
                                     UOM            VARCHAR2(25));

    FUNCTION VERIFY_TARIFF_CARRIER(p_tariff_name IN VARCHAR2,
                                   p_carrier_id  IN NUMBER,
                                   x_error_msg OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN;

    FUNCTION GET_TARIFF_RATECHARTS (p_tariff_name   IN  VARCHAR2,
                                    x_error_msg OUT NOCOPY VARCHAR2)
    RETURN WSH_UTIL_CORE.ID_TAB_TYPE;

   /* PROCEDURE PROCESS_LTL_DATA(p_load_id        IN  NUMBER,
                               p_src_filename   IN  VARCHAR2,
                               p_currency       IN  VARCHAR2,
                               p_uom_code       IN  VARCHAR2,
                               p_orig_country   IN  VARCHAR2,
                               p_dest_country   IN  VARCHAR2,
                               p_service_code   IN  VARCHAR2,
                               p_action_code    IN  VARCHAR2,
                               p_tariff_name    IN  VARCHAR2,
                               x_request_id     OUT NOCOPY NUMBER,
                               x_error_msg      OUT NOCOPY VARCHAR2);*/

    PROCEDURE QP_PROCESS ( errbuf            OUT   NOCOPY  VARCHAR2,
                           retcode           OUT   NOCOPY  VARCHAR2,
                           p_load_id           IN            NUMBER,
                           p_group_process_id  IN            NUMBER,
                           p_user_debug        IN            NUMBER);

    PROCEDURE PROCESS_LTL_DATA(errbuf           OUT NOCOPY  VARCHAR2,
                            retcode          OUT NOCOPY  VARCHAR2,
                            p_load_id        IN  NUMBER,
                            p_src_filename   IN  VARCHAR2,
                            p_currency       IN  VARCHAR2,
                            p_uom_code       IN  VARCHAR2,
                            p_orig_country   IN  VARCHAR2,
                            p_dest_country   IN  VARCHAR2,
                            p_service_code   IN  VARCHAR2,
                            p_action_code    IN  VARCHAR2,
                            p_tariff_name    IN  VARCHAR2,
                            p_user_debug     IN  NUMBER);

END FTE_LTL_LOADER;

 

/
