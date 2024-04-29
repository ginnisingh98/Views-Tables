--------------------------------------------------------
--  DDL for Package PA_MCB_REVENUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MCB_REVENUE_PKG" AUTHID CURRENT_USER AS
--$Header: PAXMCRUS.pls 120.4 2007/12/28 11:59:21 hkansal ship $


G_LAST_UPDATE_LOGIN      NUMBER;
G_REQUEST_ID             NUMBER;
G_PROGRAM_APPLICATION_ID NUMBER;
G_PROGRAM_ID             NUMBER;
G_LAST_UPDATED_BY        NUMBER;
G_CREATED_BY             NUMBER;
G_DEBUG_MODE             VARCHAR2(1);
/* Variable added for bug 5907315 */
fnd_profile_revenue_orig_rate VARCHAR2(1) := 'N';


PROCEDURE event_amount_conversion( p_project_id         IN       NUMBER,
                                   p_request_id         IN       NUMBER,
                                   p_event_type         IN       VARCHAR2,
                                   p_calling_place      IN       VARCHAR2,
                                   p_acc_thru_dt        IN       DATE,
                                   p_project_rate_date  IN       DATE,
                                   p_projfunc_rate_date IN       DATE,
                                   x_return_status      IN OUT NOCOPY   VARCHAR2,
                                   x_msg_count          IN OUT NOCOPY   NUMBER,
                                   x_msg_data           IN OUT NOCOPY   VARCHAR2);


PROCEDURE ei_amount_conversion( p_project_id       IN       NUMBER,
                                p_ei_id            IN       PA_PLSQL_DATATYPES.IdTabTyp,
                                p_request_id       IN       NUMBER,
                                p_pa_date          IN       VARCHAR2,
                                x_return_status    IN OUT NOCOPY   VARCHAR2,
                                x_msg_count        IN OUT NOCOPY   NUMBER,
                                x_msg_data         IN OUT NOCOPY   VARCHAR2,
                                x_rej_reason       IN OUT NOCOPY   VARCHAR2);


PROCEDURE rdl_amount_conversion( p_project_id                IN       NUMBER,
                                 p_request_id                IN       NUMBER,
                                 p_ei_id                     IN       PA_PLSQL_DATATYPES.IdTabTyp,
                                 p_raw_revenue               IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                                 p_bill_trans_raw_revenue    IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                                 p_project_raw_revenue       IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                                 p_projfunc_raw_revenue      IN       PA_PLSQL_DATATYPES.Char30TabTyp,
                                 p_funding_rate_date         IN       VARCHAR2,
                                 x_return_status             IN OUT NOCOPY   VARCHAR2,
                                 x_msg_count                 IN OUT NOCOPY   NUMBER,
                                 x_msg_data                  IN OUT NOCOPY   VARCHAR2);


PROCEDURE erdl_amount_conversion( p_project_id               IN     NUMBER,
                                  p_draft_revenue_num        IN     NUMBER,
                                  p_btc_code                 IN     VARCHAR2,
                                  p_btc_amount               IN     VARCHAR2,
                                  p_funding_rate_date        IN     VARCHAR2,
                                  p_funding_curr_code        IN     VARCHAR2,
                                  x_funding_rate_type        IN OUT NOCOPY VARCHAR2,
                                  x_funding_rate_date        IN OUT NOCOPY VARCHAR2,
                                  x_funding_exchange_rate    IN OUT NOCOPY VARCHAR2,
                                  x_funding_amount           IN OUT NOCOPY VARCHAR2,
                                  x_funding_convert_status   IN OUT NOCOPY VARCHAR2,
                                   p_projfunc_curr_code     IN     VARCHAR2,
                                    p_projfunc_amount        IN     VARCHAR2,
                                    p_projfunc_rate_type     IN     VARCHAR2,
                                    p_projfunc_rate_date     IN     VARCHAR2,
                                    p_projfunc_exch_rate     IN     VARCHAR2,
                                    p_revtrans_curr_code     IN     VARCHAR2,
                                    p_calling_place          IN     VARCHAR2,
                                    x_revtrans_rate_type     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_rate_date     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_exch_rate     IN OUT NOCOPY VARCHAR2,
                                    x_revtrans_amount        IN OUT NOCOPY VARCHAR2,
                                  x_return_status            IN OUT NOCOPY VARCHAR2,
                                  x_msg_count                IN OUT NOCOPY NUMBER,
                                  x_msg_data                 IN OUT NOCOPY VARCHAR2
                                );

PROCEDURE ei_fcst_amount_conversion(
                               p_project_id       IN       NUMBER,
                               p_ei_id            IN       PA_PLSQL_DATATYPES.IdTabTyp,
                               p_request_id       IN       NUMBER,
                               p_pa_date          IN       VARCHAR2,
                               x_return_status    IN OUT NOCOPY   VARCHAR2,
                               x_msg_count        IN OUT NOCOPY   NUMBER,
                               x_msg_data         IN OUT NOCOPY   VARCHAR2);


PROCEDURE log_message (p_log_msg IN VARCHAR2);

PROCEDURE Init (
        P_DEBUG_MODE             VARCHAR2);

/*----------------------------------------------------------------------------------------+
|   Procedure  :   RTC_UBR_UER_CALC                                                       |
|   Purpose    :   To compute transaction level ie, draft revenue level UBR/UER values in |
|                  Revenue transaction currency.                                          |
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                    Mode            Description                                 |
|     ==================================================================================  |
|      P_PFC_REV_AMOUNT        IN           Total revenue amount for a revenue in PFC     |
|      P_REVTRANS_AMOUNT       IN           Total revenue amount for a revenue in RTC     |
|      P_PROJFUNC_UBR          IN           UBR amount in project functional currency     |
|      P_PROJFUNC_UER          IN           UBR amount in project functional currency     |
|      P_UBR_CORR              IN           UBR correction amt in proj functional currency|
|      P_UER_CORR              IN           UER correction amt in proj functional currency|
|      P_REVTRANS_UBR          OUT NOCOPY   UBR amount in revenue transaction currency    |
|      P_REVTRANS_UER          OUT NOCOPY   UER amount in revenue transaction currency    |
|      X_RETURN_STATUS         OUT NOCOPY   Return status                                 |
|      X_MSG_COUNT             OUT NOCOPY   Error messages count                          |
|      X_MSG_DATA              OUT NOCOPY   Error message                                 |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
PROCEDURE RTC_UBR_UER_CALC(
                        P_PFC_REV_AMOUNT        IN              NUMBER,
                        P_REVTRANS_AMOUNT       IN              NUMBER,
                        P_PROJFUNC_UBR          IN              NUMBER,
			P_PROJFUNC_UER		IN		NUMBER,
                        P_UBR_CORR              IN              NUMBER,
                        P_UER_CORR              IN              NUMBER,
                        P_REVTRANS_UBR          OUT NOCOPY      VARCHAR,
                        P_REVTRANS_UER          OUT NOCOPY      VARCHAR,
                        X_RETURN_STATUS         OUT NOCOPY      VARCHAR,
                        X_MSG_COUNT             OUT NOCOPY      NUMBER,
                        X_MSG_DATA              OUT NOCOPY      VARCHAR);

END PA_MCB_REVENUE_PKG;

/
