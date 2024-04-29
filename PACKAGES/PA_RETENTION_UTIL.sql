--------------------------------------------------------
--  DDL for Package PA_RETENTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RETENTION_UTIL" AUTHID CURRENT_USER as
/* $Header: PAXIRUTS.pls 120.1 2005/08/19 17:14:53 mwasowic noship $ */
   FUNCTION IsBillingCycleQualified(p_project_id IN NUMBER,
				 p_task_id	IN NUMBER,
                                 P_bill_thru_date IN DATE,
                                 p_billing_cycle_id IN NUMBER) RETURN VARCHAR2;

   PROCEDURE Write_Log(p_message IN VARCHAR2);

   PROCEDURE copy_retention_setup (
            p_fr_project_id                  IN      NUMBER DEFAULT NULL, /* bug 2463257 */
            p_to_project_id                  IN      NUMBER  DEFAULT NULL, /* bug 2463257 */
            p_fr_customer_id                 IN      NUMBER DEFAULT NULL,
            p_to_customer_id                 IN      NUMBER DEFAULT NULL,
            p_fr_date                        IN      DATE DEFAULT NULL,
            p_to_date                        IN      DATE DEFAULT NULL,
            p_call_mode                      IN      VARCHAR2 DEFAULT 'PROJECT',
            x_return_status                  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                       OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE copy_retention_setup (
            p_fr_project_id                  IN      NUMBER ,
            p_to_project_id                  IN      NUMBER DEFAULT NULL,
            p_fr_customer_id                 IN      NUMBER DEFAULT NULL,
            p_to_customer_id_tab             IN      PA_NUM_1000_NUM,
            p_rec_version_tab                IN      PA_NUM_1000_NUM,
            p_fr_date                        IN      DATE DEFAULT NULL,
            p_to_date                        IN      DATE DEFAULT NULL,
            p_call_mode                      IN      VARCHAR2 DEFAULT 'PROJECT',
            x_return_status                  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                       OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE delete_retn_rules_customer (
            p_project_id                  IN      NUMBER,
            p_customer_id                 IN      NUMBER,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

   PROCEDURE delete_retention_rules (
            p_project_id                  IN      NUMBER,
            p_task_id                     IN      NUMBER DEFAULT NULL,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

   PROCEDURE insert_retention_rules (
            p_fr_project_id               IN      NUMBER,
            p_fr_customer_id              IN      NUMBER,
            p_to_project_id               IN      NUMBER,
            p_to_customer_id              IN      NUMBER,
            p_fr_date                     IN      DATE,
            p_to_date                     IN      DATE,
            p_delta                       IN      NUMBER,
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE get_currency_code(
            p_project_id               IN      NUMBER,
            x_invproc_currency_type       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_project_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_projfunc_currency_code      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_funding_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_invproc_currency_code       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE get_corresponding_task (
            p_fr_project_id    IN NUMBER,
            p_fr_task_id       IN NUMBER,
            p_to_project_id    IN NUMBER,
            x_task_id          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_fr_start_date    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
            x_to_start_date    OUT NOCOPY DATE, --File.Sql.39 bug 4440895
            x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE get_project_info (
            p_project_id              IN     NUMBER,
            x_project_name            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_project_number          OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_invproc_currency_type   OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_invproc_currency_code   OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_projfunc_currency_code  OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status           OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count               OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                OUT    NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

   PROCEDURE calculate_date_factor (
            p_fr_project_id               IN      NUMBER,
            p_to_project_id               IN      NUMBER,
            x_delta                       OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE get_rec_version_num ( p_project_id          IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    x_version_num         OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

   FUNCTION check_rec_version_num ( p_project_id          IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_version_num         IN NUMBER) RETURN VARCHAR2;

   PROCEDURE set_rec_version_num ( p_project_id          IN NUMBER,
                                   p_customer_id         IN NUMBER,
                                   p_version_num         IN NUMBER,
/*                                 x_version_num         OUT NUMBER, */
                                   x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE retn_billing_method_single(
                          p_billing_mode                IN      VARCHAR2,
                          P_retention_level             IN      VARCHAR2,
                          p_project_id                  IN      VARCHAR2,
                          p_task_id                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retn_billing_cycle_id       IN      VARCHAR2,
                          p_billing_method_code         IN      VARCHAR2,
                          p_invproc_currency_code       IN      VARCHAR2,
                          p_completed_percentage        IN      VARCHAR2,
                          p_total_retention_amount      IN      VARCHAR2,
                          p_client_extension_flag       IN      VARCHAR2,
                          p_retn_billing_percentage     IN      VARCHAR2,
                          p_retn_billing_amount         IN      VARCHAR2,
                          p_version_num                 IN      NUMBER,
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE retn_billing_method_PerComp(
                          p_billing_mode                IN      VARCHAR2,
                          P_retention_level             IN      VARCHAR2,
                          p_project_id                  IN      VARCHAR2,
                          p_task_id                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retn_billing_cycle_id       IN      VARCHAR2,
                          p_billing_method_code         IN      VARCHAR2,
                          p_invproc_currency_code       IN      VARCHAR2,
                          p_completed_percentage        IN      PA_VC_1000_25,
                          p_total_retention_amount      IN      VARCHAR2,
                          p_client_extension_flag       IN      VARCHAR2,
                          p_retn_billing_percentage     IN      PA_VC_1000_25,
                          p_retn_billing_amount         IN      PA_VC_1000_25,
                          p_version_num                 IN      NUMBER,
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE retn_billing_task_validate(
                          p_project_id                  IN      VARCHAR2,
                          P_task_name                   IN      VARCHAR2,
                          p_task_no                     IN      VARCHAR2,
                          p_customer_id                 IN      VARCHAR2,
                          p_retention_level             IN      VARCHAR2,
                          x_task_id                     OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_return_status               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count                   OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data                    OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

----- Following APIs are added by Bhumesh K.

  PROCEDURE Check_For_Overlap_Dates (
    P_RowID				VARCHAR2,
    P_Project_ID			NUMBER,
    P_Task_ID				NUMBER,
    P_Customer_ID			NUMBER,
    P_Retention_Level_Code		VARCHAR2,
    P_Expenditure_Category		VARCHAR2,
    P_Expenditure_Type			VARCHAR2,
    P_Non_Labor_Resource		VARCHAR2,
    P_Revenue_Category_Code		VARCHAR2,
    P_Event_Type			VARCHAR2,
    P_Effective_Start_Date		DATE,
    P_Effective_End_Date		DATE,
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code 	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Validate_Expenditure_Category (
    P_Expenditure_Category	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Expenditure_Type		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Non_Labor_Resource	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Validate_Revenue_Category (
    P_Revenue_Category_Code	   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Revenue_Category		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Event_Type		IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Delete_Retentions (
    P_Project_ID			NUMBER,
    P_Customer_ID			NUMBER,
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Delete_Bill_Retentions (
    P_Bill_Rule_ID                      NUMBER,
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Check_Top_Task_Details (
    P_Project_ID			NUMBER,
    P_Task_Number			VARCHAR2,
    P_Task_Name				VARCHAR2,
    X_Task_ID			IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  PROCEDURE Validate_Retention_Data (
    P_RowID                         VARCHAR2,
    P_Project_ID                    NUMBER,
    P_Task_Number		    VARCHAR2,
    P_Task_Name			    VARCHAR2,
    P_Customer_ID                   NUMBER,
    P_Retention_Level_Code  IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Expenditure_Category  IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Expenditure_Type      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Non_Labor_Resource    IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Revenue_Category      IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Event_Type            IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    P_Retention_Percentage          NUMBER,
    P_Retention_Amount              NUMBER,
    P_Threshold_Amount              NUMBER,
    P_Effective_Start_Date          DATE,
    P_Effective_End_Date            DATE,
    P_Task_Flag			    VARCHAR2,
    X_Task_ID               IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Revenue_Category_Code IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Return_Status_code    IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code    IN OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Check_Retention_Rules  (
    P_Project_ID			NUMBER,
    P_Customer_ID			NUMBER,
    X_Return_Value              IN OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  PROCEDURE Check_Billing_Retentions  (
    P_Project_ID			NUMBER,
    P_Customer_ID			NUMBER,
    X_Return_Status_Code	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Error_Message_Code	IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );
   FUNCTION CheckRetnInvFormat(p_project_id IN NUMBER,
			      p_retn_inv_fmt IN NUMBER) RETURN NUMBER;

END pa_retention_util;

 

/
