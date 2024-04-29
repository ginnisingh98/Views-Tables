--------------------------------------------------------
--  DDL for Package EAM_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_FORECAST_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVFORS.pls 120.7 2006/09/20 10:48:15 csprague noship $ */
    TYPE forecast_asset_cursor_type IS REF CURSOR;
    TYPE forecast_wo_cursor_type IS REF CURSOR;
    TYPE wdj_table_type IS table of EAM_FORECAST_WDJ%ROWTYPE;
    TYPE cebba_table_type IS table of EAM_FORECAST_CEBBA%ROWTYPE;
    TYPE wo_table_type IS table of NUMBER INDEX BY BINARY_INTEGER;

type eam_forecast_rec_type is record
(
FORECAST_ID                     eam_forecast_cebba.FORECAST_ID%type,
PERIOD_SET_NAME                 eam_forecast_cebba.period_set_name%type,
PERIOD_NAME                     eam_forecast_cebba.period_name%type,
ACCT_PERIOD_ID                  eam_forecast_cebba.acct_period_id%type,
WIP_ENTITY_ID                   eam_forecast_cebba.wip_entity_id%type,
ORGANIZATION_ID                 eam_forecast_cebba.organization_id%type,
OPERATIONS_DEPT_ID              eam_forecast_cebba.operations_dept_id%type,
OPERATION_SEQ_NUM              eam_forecast_cebba.operation_seq_num%type,
MAINT_COST_CATEGORY            eam_forecast_cebba.maint_cost_category%type,
txn_type                       eam_forecast_cebba.txn_type%type,
OWNING_DEPT_ID                 eam_forecast_cebba.owning_dept_id%type,
acct_VALUE                     eam_forecast_cebba.acct_value%type,
PERIOD_START_DATE              eam_forecast_cebba.period_start_date%type,
LAST_UPDATE_DATE               eam_forecast_cebba.last_update_date%type,
LAST_UPDATED_BY                eam_forecast_cebba.last_updated_by%type,
CREATION_DATE                  eam_forecast_cebba.creation_date%type,
CREATED_BY                     eam_forecast_cebba.created_by%type,
LAST_UPDATE_LOGIN              eam_forecast_cebba.last_update_login%type,
REQUEST_ID                     eam_forecast_cebba.request_id%type,
PROGRAM_APPLICATION_ID         eam_forecast_cebba.program_application_id%type,
PROGRAM_ID                     eam_forecast_cebba.program_id%type,
PROGRAM_UPDATE_DATE            eam_forecast_cebba.program_update_date%type,
CCID                           eam_forecast_cebba.ccid%type,
MFG_COST_ELEMENT_ID            eam_forecast_cebba.mfg_cost_element_id%type,
PERIOD_YEAR                    eam_forecast_cebba.period_year%type,
PERIOD_NUM                     eam_forecast_cebba.period_num%type
);


    Type eam_wo_relations_tbl_type is table of eam_forecast_rec_type
         INDEX BY BINARY_INTEGER;

    PROCEDURE insert_into_cebba_auto(p_cebba_table cebba_table_type);

    PROCEDURE Extract_Forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,
                     p_forecast_id       IN  eam_forecasts.forecast_id%TYPE,
	                 x_return_status		OUT	NOCOPY VARCHAR2		  	,
	                 x_msg_count			OUT	NOCOPY NUMBER				,
	                 x_msg_data			OUT	NOCOPY VARCHAR2

    );

    procedure convert_work_orders(p_pm_group_id number,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2);
    PROCEDURE insert_into_wdj_auto(p_wdj_table wdj_table_type);

    procedure delete_forecast_data(p_forecast_id IN number);

PROCEDURE Copy_CEBBA_To_Forecast_auto (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);
  PROCEDURE extract_historical_forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE extract_autonomous_forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

PROCEDURE Get_HistoricalCosts (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_id      IN  NUMBER,
                     p_organization_id  IN  NUMBER,
                     p_wip_entity_id    IN  NUMBER,
                     p_account_from     IN  VARCHAR2,
                     p_account_to       IN  VARCHAR2,
                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,


                     x_hist_cost_tbl    OUT NOCOPY eam_wo_relations_tbl_type,
                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);


  procedure Generate_Forecast(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_forecast_id    IN number);
  /* This is a private PROCEDURE that extracts a future forecast */

  PROCEDURE extract_future_forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);


  PROCEDURE Copy_WDJ_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE Copy_WDJ_To_Forecast_auto (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

procedure delete_work_order(p_forecast_id IN number, p_wip_id IN number);

procedure delete_forecast(p_forecast_id IN number);

  PROCEDURE Copy_WOR_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE Copy_WRO_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE Copy_WO_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);


    PROCEDURE Copy_CEBBA_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE Copy_WEDI_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2);

  PROCEDURE Populate_Test_Data(p_forecast_id IN NUMBER);
  FUNCTION get_wip_table(p_forecast_rec eam_forecasts%rowtype)
    RETURN wo_table_type;

  FUNCTION get_asset_cursor(p_forecast_rec eam_forecasts%rowtype)
    RETURN forecast_asset_cursor_type;

  FUNCTION get_asset_cursor(p_organization_id IN NUMBER,p_asset_number_from IN VARCHAR2,
    p_asset_number_to IN VARCHAR2, p_serial_number_from IN VARCHAR2,
    p_serial_number_to IN VARCHAR2 , p_asset_group_from IN VARCHAR2,
    p_asset_group_to IN VARCHAR2 , p_area_from IN VARCHAR2, p_area_to IN VARCHAR2)
    RETURN forecast_asset_cursor_type;

  FUNCTION get_asset_query(p_forecast_rec eam_forecasts%rowtype)
    RETURN VARCHAR2;

  FUNCTION get_asset_query(p_organization_id IN NUMBER,p_asset_number_from IN VARCHAR2,
    p_asset_number_to IN VARCHAR2, p_serial_number_from IN VARCHAR2,
    p_serial_number_to IN VARCHAR2 , p_asset_group_from IN VARCHAR2,
    p_asset_group_to IN VARCHAR2 , p_area_from IN VARCHAR2, p_area_to IN VARCHAR2)
    RETURN VARCHAR2;

  PROCEDURE debug(l_msg IN VARCHAR2, l_level IN NUMBER := 1);

  FUNCTION getForecastXml(p_forecast_id NUMBER)return CLOB;
END;

 

/
