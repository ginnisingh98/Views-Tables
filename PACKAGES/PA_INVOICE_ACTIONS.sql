--------------------------------------------------------
--  DDL for Package PA_INVOICE_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INVOICE_ACTIONS" AUTHID CURRENT_USER as
/* $Header: PAXVIACS.pls 120.1 2005/08/19 17:22:45 mwasowic noship $ */

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Validate_Approval
-- Type          : Private
-- Pre-Reqs      : None
-- Function      : Perform Validation Checks for Approving Customer invoices
--                 Depending on the validation Level
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Draft_Invoice_Num   IN   NUMBER     Required
--                          Draft Invoice Number. Corresponds to the Column
--                          DRAFT_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 P_Validation_Level    IN   VARCHAR2   Required
--                          Validation Check that needs to be performed.
--                          Valid Values R - Record Level  C - Commit Level
-- OUT             X_Error_Message_Code  OUT   NUMBER    Optional
--                          Application Error Message Code. Value of Null
--                          Indicates no Application error encountered
--
-- End of Comments
/*----------------------------------------------------------------------------*/
  Procedure Validate_Approval ( P_Project_ID         in  number,
                                P_Draft_Invoice_Num  in  number,
                                P_Validation_Level   in  varchar2,
                                X_Error_Message_Code out NOCOPY varchar2 ); --File.Sql.39 bug 4440895



/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Validate_Release
-- Type          : Private
-- Pre-Reqs      : None
-- Function      : Perform Validation Checks for Releasing Customer invoices
--                 Depending on the validation Level. This Procedure will also
--                 get the next RA Invoice Number if Implementation option has
--                 been defined as 'AUTOMATIC'
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Draft_Invoice_Num   IN   NUMBER     Required
--                          Draft Invoice Number. Corresponds to the Column
--                          DRAFT_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 P_Validation_Level    IN   VARCHAR2   Required
--                          Validation Check that needs to be performed.
--                          Valid Values R - Record Level
--                                       C - Commit Level
--                                 P_INV_DT- Invoice Date Level
--                                P_INV_NUM- Invoice Number Level
--                 X_User_ID             IN   NUMBER     Required
--                          Logged in UserId.
--                 P_RA_Invoice_Date     IN   DATE       Optional
--                          AR's INvoice Date. Corresponds to the Column
--                          RA_INVOICE_DATE of PA_DRAFT_INVOICES_ALL Table
--                 P_RA_Invoice_Num      IN   VARCHAR2   Optional
--                          AR's Invoice Num. Corresponds to the Column
--                          RA_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 P_Credit_Memo_Reason_Code  IN OUT VARCHAR2 Optional
--                          P_Credit_Memo_Reason_Code Corresponds to the Column
--                          Credit_Memo_Reason_Code of PA_DRAFT_INVOICES_ALL Table
-- OUT             X_RA_Invoice_Num      OUT   VARCHAR2   Optional
--                          AR's Invoice Num. Corresponds to the Column
--                          RA_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table.
--                          Invoice Number will be the same as P_RA_INVOICE_NUM
--                          for Mannual entry Implementation Option. For
--                          AUTOMATIC Imp. Option this will be generated during
--                          Commit Level Validation.
--                 X_Error_Message_Code  OUT   NUMBER    Optional
--                          Application Error Message Code. Value of Null
--                          Indicates no Application error encountered
--
-- End of Comments
/*----------------------------------------------------------------------------*/
  Procedure Validate_Release  ( P_Project_ID              in     number,
                                P_Draft_Invoice_Num       in     number,
                                P_Validation_Level        in     varchar2,
                                P_User_ID                 in     number,
                                P_RA_Invoice_Date         in     date,
                                P_RA_Invoice_Num          in     varchar2,
			        P_Credit_Memo_Reason_Code in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_RA_Invoice_Num          out    NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_Error_Message_Code      out    NOCOPY varchar2); --File.Sql.39 bug 4440895

  /* Overloaded Procedure validate_release for Credit Memo Reason ARU Compatibility*/
  Procedure Validate_Release  ( P_Project_ID              in     number,
                                P_Draft_Invoice_Num       in     number,
                                P_Validation_Level        in     varchar2,
                                P_User_ID                 in     number,
                                P_RA_Invoice_Date         in     date,
                                P_RA_Invoice_Num          in     varchar2,
                                X_RA_Invoice_Num          out    NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_Error_Message_Code      out    NOCOPY varchar2); --File.Sql.39 bug 4440895



/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Validate_Multi_Customer
-- Type          : Private
-- Pre-Reqs      : None
-- Function      : Validate Invoice Approval/Release Multi-Customer Check
-- Parameters    :
-- IN              P_Invoice_Set_ID      IN   NUMBER     Required
--                          Set Id for set of Project Invoices. Corresponds to
--                          INVOICE_SET_ID of PA_DRAFT_INVOICES_ALL Table
-- OUT             X_Error_Message_Code  OUT   VARCHAR2  Optional
--                          Application Error Message Code. Value of Null
--                          Indicates no Application error encountered
--
--
-- End of Comments
/*----------------------------------------------------------------------------*/
  Procedure Validate_Multi_Customer( P_Invoice_Set_ID     in  number,
                                     X_Error_Message_Code out NOCOPY varchar2);  --File.Sql.39 bug 4440895



/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Post_Update_Release
-- Type          : Private
-- Pre-Reqs      : None
-- Function      : Post Update Invoice Release Steps
-- Parameters    :
-- IN              P_Project_ID          IN   NUMBER     Required
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--                 P_Draft_Invoice_Num   IN   NUMBER     Required
--                          Draft Invoice Number. Corresponds to the Column
--                          DRAFT_INVOICE_NUM of PA_DRAFT_INVOICES_ALL Table
--                 X_User_ID             IN   NUMBER     Required
--                          Logged in UserId.
--                 X_Employee_ID         IN   NUMBER     Required
--                          Employee_ID attached to the userid.
-- End of Comments
/*----------------------------------------------------------------------------*/
  Procedure Post_Update_Release ( P_Project_ID         in  number,
                                  P_Draft_Invoice_Num  in  number,
                                  P_User_ID            in  number,
                                  P_Employee_ID        in  number);




/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : Client_Extn_Driver
-- Type          : Private
-- Pre-Reqs      : None
-- Function      : Call Client billing extension for Automatic Approval/Release
--                 of on Invoice from Generate Draft Invoice
-- Parameters    :
-- IN              P_Request_ID          IN   NUMBER     Required
--                          Request ID of the Generate Draft Invoice Process.
--                          Corresponds to REQUEST_ID of PA_DRAFT_INVOICES_ALL
--                 X_User_ID             IN   NUMBER     Required
--                          Logged in UserId.
--                 X_Calling_Place       IN   varchar2   Required
--                          Calling Place from Generate Invoice (PAIGEN) i
--                          Program. Valid Values are
--                             INV_CR_MEMO  - Invoice/Credit Memo Processing
--                             WRITE_OFF    - Write Off Processing
--                             CANCEL       - Cancel Processing
--                 P_Project_ID          IN   NUMBER     Optional
--                          Project Identifier. Corresponds to the Column
--                          PROJECT_ID of PA_PROJECTS_ALL Table
--
-- End of Comments
/*----------------------------------------------------------------------------*/
  Procedure Client_Extn_Driver( P_Request_ID         in  number,
                                P_User_ID            in  number,
                                P_Calling_Place      in  varchar2,
                                P_Project_ID         in  number    );


  /* Begin Concession invoice modification */

  PROCEDURE init_draft_inv_lines(
             p_project_id        IN     NUMBER,
             p_draft_invoice_num IN     NUMBER,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2);

  Procedure update_credit_qual_lines (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_draft_invoice_line_num IN NUMBER,
             p_line_credit_amount     IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

  Procedure validate_line_credit_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_draft_invoice_line_num IN NUMBER,
             p_inv_amount             IN NUMBER,
             p_credit_amount          IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

  Procedure distribute_credit_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_total_credit_amount    IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

  Procedure distribute_credit_amount_retn (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   ;

  Procedure compute_retn_credit_amount (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             p_retention_rule_id      IN NUMBER,
             p_retention_line_num     IN NUMBER,
             p_retained_amount        IN NUMBER,
             p_amount                 IN NUMBER,
             p_credit_amount          IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

 Procedure check_concurrency_issue (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             p_rec_version_number     IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

 Procedure validate_invoice_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_invoice_amount         IN NUMBER,
             p_net_inv_amount         IN NUMBER,
             p_credit_amount          IN NUMBER,
             p_balance_due            IN NUMBER,
             x_tot_credited_amt       OUT   NOCOPY NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2);

end PA_Invoice_Actions;

 

/
