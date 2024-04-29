--------------------------------------------------------
--  DDL for Package PA_CC_ENC_IMPORT_FCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_ENC_IMPORT_FCK" AUTHID CURRENT_USER as
-- $Header: PACCENCS.pls 115.2 2003/04/17 22:37:50 riyengar noship $
-- variable to hold a table of record for pa_bc_packets
TYPE FC_Record IS RECORD (
 PACKET_ID                       pa_bc_packets.PACKET_ID%type,
 BC_PACKET_ID             	 pa_bc_packets.BC_PACKET_ID%type,
 PARENT_BC_PACKET_ID             pa_bc_packets.PARENT_BC_PACKET_ID%type default Null, -- should be populated for burden rows
 EXT_BUDGET_TYPE                 varchar2(100) default 'GL', -- defaule values are 'CC' or 'GL'
 BC_COMMITMENT_ID                pa_bc_packets.BC_COMMITMENT_ID%type default Null,
 PROJECT_ID                      pa_bc_packets.PROJECT_ID%type,
 TASK_ID                         pa_bc_packets.TASK_ID%type,
 EXPENDITURE_TYPE                pa_bc_packets.EXPENDITURE_TYPE%type,
 EXPENDITURE_ITEM_DATE           pa_bc_packets.EXPENDITURE_ITEM_DATE%type,
 SET_OF_BOOKS_ID                 pa_bc_packets.SET_OF_BOOKS_ID%type,
 JE_CATEGORY_NAME                pa_bc_packets.JE_CATEGORY_NAME%type,
 JE_SOURCE_NAME                  pa_bc_packets.JE_SOURCE_NAME%type,
 STATUS_CODE            	 pa_bc_packets.STATUS_CODE%type  default 'P',  -- P pending
 DOCUMENT_TYPE         		 pa_bc_packets.DOCUMENT_TYPE%type,
 FUNDS_PROCESS_MODE              pa_bc_packets.FUNDS_PROCESS_MODE%type default 'T',
 EXPENDITURE_ORGANIZATION_ID     pa_bc_packets.EXPENDITURE_ORGANIZATION_ID%type,
 DOCUMENT_HEADER_ID              pa_bc_packets.DOCUMENT_HEADER_ID%type,
 DOCUMENT_DISTRIBUTION_ID        pa_bc_packets.DOCUMENT_DISTRIBUTION_ID%type,
 BUDGET_VERSION_ID          	 pa_bc_packets.BUDGET_VERSION_ID%type default Null,
 BURDEN_COST_FLAG          	 pa_bc_packets.BURDEN_COST_FLAG%type default 'N',
 BALANCE_POSTED_FLAG     	 pa_bc_packets.BALANCE_POSTED_FLAG%type default 'N',
 ACTUAL_FLAG            	 pa_bc_packets.ACTUAL_FLAG%type default 'E',  -- 'A' for Actual , 'E' for Encumbrance
 GL_DATE               		 pa_bc_packets.GL_DATE%type default Null,
 PERIOD_NAME         		 pa_bc_packets.PERIOD_NAME%type,  -- must be populated
 PERIOD_YEAR        	         pa_bc_packets.PERIOD_YEAR%type,
 PERIOD_NUM        		 pa_bc_packets.PERIOD_NUM%type,
 ENCUMBRANCE_TYPE_ID             pa_bc_packets.ENCUMBRANCE_TYPE_ID%type, -- must be populated
 PROJ_ENCUMBRANCE_TYPE_ID        pa_bc_packets.PROJ_ENCUMBRANCE_TYPE_ID%type default Null,
 TOP_TASK_ID                     pa_bc_packets.TOP_TASK_ID%type default null,
 PARENT_RESOURCE_ID              pa_bc_packets.PARENT_RESOURCE_ID%type default null,
 RESOURCE_LIST_MEMBER_ID         pa_bc_packets.RESOURCE_LIST_MEMBER_ID%type default null,
 ENTERED_DR                      pa_bc_packets.ENTERED_DR%type,
 ENTERED_CR                      pa_bc_packets.ENTERED_CR%type,
 ACCOUNTED_DR                    pa_bc_packets.ACCOUNTED_DR%type,
 ACCOUNTED_CR                    pa_bc_packets.ACCOUNTED_CR%type,
 RESULT_CODE                     pa_bc_packets.RESULT_CODE%type default null,
 OLD_BUDGET_CCID       		 pa_bc_packets.OLD_BUDGET_CCID%type default null,
 TXN_CCID             		 pa_bc_packets.TXN_CCID%type, -- it should be populated with code combinationid
 ORG_ID              		 pa_bc_packets.ORG_ID%type, -- it shoudl be populated
 LAST_UPDATE_DATE   		 pa_bc_packets.LAST_UPDATE_DATE%type,  -- standard who columns
 LAST_UPDATED_BY  		 pa_bc_packets.LAST_UPDATED_BY%type,   -- standard who columns
 CREATED_BY      		 pa_bc_packets.CREATED_BY%type,        -- standard who columns
 CREATION_DATE                   pa_bc_packets.CREATION_DATE%type,     -- standard who columns
 LAST_UPDATE_LOGIN               pa_bc_packets.LAST_UPDATE_LOGIN%type  -- standard who columns
);

TYPE FC_Rec_Table IS TABLE OF FC_Record INDEX BY BINARY_INTEGER;

/** This is an autonmous Transaction API, which inserts records into
 *  pa_bc_packets. If the operation is success ,x_return_status will be set to 'S'
 *  else it will be set to 'T' - for fatal error and x_error_msg will return the sqlcode and sqlerrm
 **/
PROCEDURE Load_pkts(
                p_calling_module    IN varchar2 default 'CCTRXIMPORT'
		,p_ext_budget_type  IN varchar2 default 'GL'
                , p_packet_id       IN number
		, p_fc_rec_tab      IN PA_CC_ENC_IMPORT_FCK.FC_Rec_Table
                , x_return_status   OUT NOCOPY varchar2
                , x_error_msg       OUT NOCOPY varchar2
               );

/** This is a wrapper API created on top of pa_funds_chedk for Contract commitments transactions
 *  During import of CC transactions, since the amounts are already encumbered in GL and CC
 *  the respective funds check process will not be called. Ref to bug:2877072 for further details
 *  so the PA encumbrnace entries were missing. In order to fix the above bug this API is created
 *  which calls pa funds check in TRXIMPORT mode so that, the liquidation entries need not be
 *  posted to GL and CBC.
 *  This API will be called twice for each batch of import.
 *  for documnet type - 'CC_C_CO','CC_P_CO'  create a unique packet_id and p_ext_budget_type = 'CC'
 *      documnet type - 'CC_C_PAY','CC_P_PAY','AP' create a unique packet_id and p_ext_budget_type = 'GL'
 *  The return status of this API will be 'S' - success, 'F' - Failure, 'T' - Fatal error
 **/
PROCEDURE Pa_enc_import_fck(
                p_calling_module   IN varchar2 default 'CCTRXIMPORT'
		,p_ext_budget_type  IN varchar2 default 'GL'
                , p_conc_flag       IN varchar2 default 'N'
                , p_set_of_book_id  IN number
                , p_packet_id       IN number
                , p_mode            IN varchar2 default 'R'
                , p_partial_flag    IN varchar2 default 'N'
                , x_return_status   OUT NOCOPY varchar2
                , x_error_msg       OUT NOCOPY varchar2
               );
/** This is tieback API for Contract commitment import process,Once the import process is completed
 *  this api will be called by passing the cbc result code. based on the cbc_result_code the
 *  status of the pa_bc_packets and pa_bdgt_acct_balances will be updated
 *  The return status of this API will be 'S' - success, 'F' - Failure, 'T' - Fatal error
 **/
PROCEDURE Pa_enc_import_fck_tieback(
	         p_calling_module   IN varchar2
		,p_ext_budget_type  IN varchar2 default 'GL'
                 ,p_packet_id       IN number
                 ,p_mode            IN varchar2 default 'R'
                 ,p_partial_flag    IN varchar2 default 'N'
		 ,p_cbc_return_code IN varchar2
                 ,x_return_status   OUT NOCOPY varchar2
                  );

/** This API checks whether the PA is installed in the OU or not to avoid cross charage project
 *  transactions funds check The return status of this API will be 'Y' or 'N'
 **/
FUNCTION IS_PA_INSTALL_IN_OU RETURN VARCHAR2 ;

/** This API checks whether the budgetary control is enabled or Not for the given project and budget type
 *  The return status of this API will be 'Y' or 'N' */
FUNCTION get_fc_reqd_flag(p_project_id  number,p_ext_budget_code varchar2) RETURN varchar2;

/** This API returns budget version id for the given project and external budget type */
FUNCTION get_bdgt_version_id(p_project_id  number,p_ext_budget_code varchar2) RETURN NUMBER ;

/** Update the result code of the transactions based on the partial flag, calling mode and p_mode
 *  in autonomous transaction. After updating the result code call the status_code update API
 *  NOTE: THIS API will UPDATE only the RESULT CODE if IMPORT process is FAILS . THIS api marks
 *  all the transactions in pa_bc_packets to 'F155 or F156'
 */
PROCEDURE tie_back_result_code
                         (p_calling_module     in varchar2,
                          p_packet_id          in number,
                          p_partial_flag       in varchar2,
                          p_mode               in varchar2,
                          p_glcbc_return_code  in varchar2,
                          x_return_status      OUT NOCOPY varchar2);

end PA_CC_ENC_IMPORT_FCK;

 

/
