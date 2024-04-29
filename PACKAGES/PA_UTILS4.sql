--------------------------------------------------------
--  DDL for Package PA_UTILS4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILS4" AUTHID CURRENT_USER AS
/* $Header: PAXGUT4S.pls 120.4 2006/01/23 14:35:48 vgade noship $*/

     -- Added these global variables for CWK changes.
     G_INCURRED_BY_PERSON_ID   NUMBER := null ;
     G_full_name VARCHAR2(240) := NULL ;
     G_employee_number VARCHAR2(30):= NULL ;


  /* The following global variables are declared for caching in MRC trigger PAMRCEIA.pls */
     G_P_SOB         NUMBER := null;
     G_P_org_id_new  Number := null;
     G_P_org_id_old  Number := null;
     G_R_SOB         NUMBER := null;
     G_R_org_id_new  Number := null;
     G_R_org_id_old  Number := null;
     G_prvdr_sob     NUMBER := null;
     G_prvdr_currency Varchar2(15) := null;
     G_recvr_sob     NUMBER := null;
     G_recvr_currency Varchar2(15) := null;


     G_Tabreporting_set_of_books_id PA_PLSQL_DATATYPES.Idtabtyp;
     G_Tabreporting_currency_code   PA_PLSQL_DATATYPES.char50TabTyp;
     G_Tabprvdr_recvr_flag          PA_PLSQL_DATATYPES.char50TabTyp;

   /* End of MRC global variable declrations */

  /* The following global variables are declared for caching in MRC trigger PAMRCCDL.pls */
     G_CDL_SOB         NUMBER := null;
     G_CDL_org_id_new  Number := null;
     G_CDL_org_id_old  Number := null;
     G_CDL_currency Varchar2(15) := null;


     G_Tabcdlreporting_set_of_books PA_PLSQL_DATATYPES.Idtabtyp;
     G_Tabcdlreporting_currency_cod PA_PLSQL_DATATYPES.char50TabTyp;
     G_Tabcdlenabled_flag           PA_PLSQL_DATATYPES.char50TabTyp;

   /* End of MRC global variable declrations */


  /* Declare Global variables to store the profile values */
    G_PRM_INSTALLED_FLAG   VARCHAR2(1) := null;
    G_WORKTYPE_ENABLED     VARCHAR2(1) := null;
    G_WORKTYPE_BILLABILITY VARCHAR2(1) := null;

  /* Declare Global plsql tabs and Recs to store the Ids */

     TYPE WorkAssignRec  IS RECORD (
        Person_Id NUMBER,
        project_id NUMBER,
        task_id    NUMBER,
        ei_date    NUMBER,
        system_linkage VARCHAR2(100),
        tp_amt_type_code VARCHAR2(100),
        assignment_id NUMBER,
        assignment_name VARCHAR2(100),
        work_type_id NUMBER,
	work_type_name VARCHAR2(100),
	return_status VARCHAR2(100),
	error_message_code VARCHAR2(100) );

  TYPE WorkAssignRecTab IS TABLE OF WorkAssignRec
        INDEX BY BINARY_INTEGER;

  TYPE WorkTypeIdRec  IS RECORD (
        project_id NUMBER,
        task_id    NUMBER,
        assignment_id NUMBER,
        work_type_id NUMBER
        );

  TYPE WorkTypeRecIdTab IS TABLE OF WorkTypeIdRec
        INDEX BY BINARY_INTEGER;


  TYPE WorkTypeNameRec  IS RECORD (
        work_type_id NUMBER,
	work_type_name  varchar2(100)
        );

  TYPE WorkTypeNameRecTab  IS TABLE OF WorkTypeNameRec
        INDEX BY BINARY_INTEGER;

  TYPE TpAmtTypeRec  IS RECORD (
        work_type_id NUMBER,
        tp_amt_type_code varchar2(100)
        );

  TYPE TpAmtTypeRecTab IS TABLE OF TpAmtTypeRec
        INDEX BY BINARY_INTEGER;

  TYPE AssignIdRec IS RECORD (
        Person_Id NUMBER,
        project_id NUMBER,
        task_id    NUMBER,
        ei_date    NUMBER,
        assignment_id NUMBER
        );

  TYPE AssignIdRecTab  IS TABLE OF AssignIdRec
        INDEX BY BINARY_INTEGER;

  TYPE AssignNameRec IS RECORD (
        assignment_name  varchar2(100)
        );

  TYPE AssignNameRecTab  IS TABLE OF AssignNameRec
        INDEX BY BINARY_INTEGER;

  G_WorkTypeRecIdTab   WorkTypeRecIdTab;
  G_WorkTypeNameRecTab WorkTypeNameRecTab;
  G_TpAmtTypeRecTab    TpAmtTypeRecTab;
  G_AssignIdRecTab     AssignIdRecTab;
  G_WorkAssignRecTab   WorkAssignRecTab;
  G_AssignNameRecTab   AssignNameRecTab;

  PROCEDURE get_work_assignment(p_person_id             IN  NUMBER
                             ,p_project_id              IN  NUMBER
                             ,p_task_id                 IN  NUMBER
                             ,p_ei_date                 IN  DATE
                             ,p_system_linkage          IN  VARCHAR2
                             ,x_tp_amt_type_code        OUT NOCOPY VARCHAR2
                             ,x_assignment_id           OUT NOCOPY NUMBER
                             ,x_assignment_name         IN OUT NOCOPY VARCHAR2
                             ,x_work_type_id            OUT NOCOPY NUMBER
                             ,x_work_type_name          IN VARCHAR2
                             ,x_return_status           OUT NOCOPY VARCHAR2
                             ,x_error_message_code      OUT NOCOPY VARCHAR2 );

  FUNCTION get_work_type_id ( p_project_id               IN  NUMBER
                             ,p_task_id                 IN  NUMBER
                             ,p_assignment_id           IN  NUMBER
                           ) RETURN NUMBER;

  --PRAGMA RESTRICT_REFERENCES ( get_work_type_id, WNDS );

  FUNCTION get_work_type_name(p_work_type_id  IN NUMBER)
         RETURN varchar2;

  --PRAGMA RESTRICT_REFERENCES ( get_work_type_name, WNDS );

  FUNCTION get_assignment_name(p_assignment_id  IN NUMBER)
         RETURN varchar2;

  --PRAGMA RESTRICT_REFERENCES ( get_assignment_name, WNDS );

  FUNCTION get_assignment_id(p_person_id               IN  NUMBER
                           ,p_project_id              IN  NUMBER
                           ,p_task_id                 IN  NUMBER
                           ,p_ei_date                 IN  DATE
                         ) RETURN NUMBER;
  -- commented out prgrama restrict as it voilates pragma references of get_person_details
  --PRAGMA RESTRICT_REFERENCES ( get_assignment_id, WNDS );

  FUNCTION get_tp_amt_type_code(p_work_type_id  IN NUMBER)
         RETURN varchar2;

  --PRAGMA RESTRICT_REFERENCES ( get_tp_amt_type_code, WNDS );

  /** This api derives the site level profile value of
   *  Transaction Billablity derived from work type
   **/
  FUNCTION is_worktype_billable_enabled RETURN VARCHAR2;

  --PRAGMA RESTRICT_REFERENCES (is_worktype_billable_enabled, WNDS );

  /** This api derives the billability of the
   *  transaction based on the work type and profile option
   */
  FUNCTION get_trxn_work_billabilty(p_work_type_id  IN  NUMBER
                            ,p_tc_extn_bill_flag  IN  VARCHAR2  )
      RETURN varchar2;

  --PRAGMA RESTRICT_REFERENCES (get_trxn_work_billabilty, WNDS );

   /** This api derives the site level profile value of
    *  Transaction work type enabled
    **/
   FUNCTION is_exp_work_type_enabled RETURN VARCHAR2;

  --PRAGMA RESTRICT_REFERENCES (is_exp_work_type_enabled, WNDS );

/* BUG # 3220230 Added the function to get the billability of reversals in OIT */
 FUNCTION GetOrig_EiBillability_SST(orig_eid IN NUMBER,billable_flag IN VARCHAR2,trans_source IN VARCHAR2) RETURN VARCHAR2;

/* Bug# 4057474 Added the function to get the bill_hold_flag of reversals in external transaction source like OTL*/
 FUNCTION GetOrig_EiBill_hold(orig_eid IN NUMBER,bill_hold_flag IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE check_txn_exists (p_project_id   IN NUMBER,
                              p_task_id      IN NUMBER DEFAULT NULL,
                              x_status_code  OUT NOCOPY NUMBER,
                              x_err_code     OUT NOCOPY VARCHAR2,
                              x_err_stage    OUT NOCOPY VARCHAR2);

  G_PrevAsgPerId  NUMBER;
  G_PrevAsgPrjId  NUMBER;
  G_PrevAsgEIDate DATE;
  G_PrevAsgAsgnId NUMBER;

  G_PrevWkPrjId   NUMBER;
  G_PrevWkTskId   NUMBER;
  G_PrevWkAsgnId  NUMBER;
  G_PrevWkTypeId  NUMBER;

  /** This api checks if a bill rate schedule is used
   *  in any organization assignment.
   */
  FUNCTION IsUsedInCosting(p_bill_rate_sch_id  IN  NUMBER )
      RETURN BOOLEAN;

  /** This API validates the given IN param is Number or Not
   *  If not Number return -9999
   */

  FUNCTION getNumericString(p_reference1  IN varchar2) RETURN NUMBER;

 /** This API will return Implementaion OrgId and uses cacheing logic
  */
  FUNCTION get_org_id RETURN NUMBER;

 /** This API returns set_of_books_id from the implementations
  **/
  FUNCTION get_primary_sob RETURN NUMBER;

 /** This API returns the Implementation values **/
  PROCEDURE get_imp_values(x_prim_sob  OUT NOCOPY Number
			  ,x_org_id    OUT NOCOPY NUmber
			  ,x_book_type_code OUT NOCOPY varchar2
                          ,x_business_group OUT NOCOPY number
                          );

  G_imp_sob_id  NUMBER;
  G_imp_org_id  NUMBER;
  G_imp_book_type_code VARCHAR2(100);
  G_imp_bus_group NUMBER;

 /** This API returns the Business group Id for the given Organization Id **/
  FUNCTION GetOrgBusinessGrpId(p_organization_id IN Number) RETURN NUMBER;

/* This is an public API, which in turn calls a private function CheckCCTxnsExists
 * This api will be called from project and task Form before deleting
 * any of the task or project
 */
PROCEDURE Check_CC_TxnExists(p_project_id       Number
                            ,p_task_id          Number
                            ,x_return_status OUT NOCOPY varchar2
                            ,x_msg_data      OUT NOCOPY varchar2
                            ,x_msg_count     OUT NOCOPY Number );


/* This is an public API, which in turn calls a private functions
 * This api will be called from budgetary controls form to check any
 * transactions exists for project or task. If so the budgetary control form
 * will be modified to read only mode
 */
PROCEDURE CheckToEnableBdgtCtrl(p_project_id       Number
                                ,p_task_id          Number
				,p_mode             Varchar2  Default 'BDGTCTRL'
                                ,x_return_status    OUT NOCOPY varchar2
                                ,x_error_msg_code   OUT NOCOPY varchar2
                                ,x_error_stage      OUT NOCOPY varchar2
                                 );

FUNCTION get_unit_of_measure ( p_expenditure_type IN VARCHAR2 ) Return VARCHAR2 ;

FUNCTION get_unit_of_measure_m ( p_unit_of_measure IN VARCHAR2 DEFAULT NULL,
                                 p_expenditure_type IN VARCHAR2 DEFAULT NULL ) Return VARCHAR2  ;


FUNCTION get_emp_name_number( p_incurred_by_person_id IN NUMBER,
                              p_expenditure_ending_date IN DATE,
                              p_mode IN VARCHAR2 )Return VARCHAR2;

FUNCTION get_wip_resource_code(p_wip_resource_id IN NUMBER ) Return VARCHAR2;

FUNCTION get_inventory_item(p_inventory_item_id  IN NUMBER) Return VARCHAR2;

FUNCTION get_invoice_payment_num(p_transaction_source IN VARCHAR2,p_inv_payment_id  IN VARCHAR2) Return NUMBER;

FUNCTION get_ledger_cash_basis_flag Return VARCHAR2;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : IsProjectsImplemented
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To check if Projects is implemented for a given OU
-- Return Value                  : VARCHAR2
-- Prameters
-- p_org_id               IN    NUMBER  REQUIRED
--  History
--  12-JUL-05   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/
FUNCTION IsProjectsImplemented(p_org_id IN Number) RETURN VARCHAR2;

END PA_UTILS4;

 

/
