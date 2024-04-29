--------------------------------------------------------
--  DDL for Package PA_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUNDS_CONTROL_PKG" AUTHID CURRENT_USER as
-- $Header: PABCFCKS.pls 120.3 2006/06/27 06:07:36 cmishra noship $

-- Declare Global Variables
   g_debug_mode            VARCHAR2(10); -- Moved from body to spec so that PABCPKTB.pls can access ..

/*---------------------------------------------------------------------------------------------------------- +
--This is the Main funds check function which calls all the other functions and procedures.
--This API is called from the following places
--         GL - Funds check process
--         CBC - Funds check process
--         Costing - During Expenditure Cost Distribution process
--         Transaction Import Process
--         Baseline of Budget
--
--   Parameters :
--      p_set_of_books_id         : Set of Books ID   in GL accounts for the packet to funds checked.
--      p_calling_module          : Identifier of the module from which the funds checker will be invoked
--                                  The valid values are
--                                        GL  - General ledger
--                                        CBC  - Contract Conmmitment
--                                        CHECK_BASELINE  -  Budget Baselining
--					  RESERVE_BASELINE - Budget Baselining
--                                        TRXNIMPORT  -  Transaction Import
--                                        DISTVIADJ      -  Invoice Adjustments
--                                        DISTERADJ    -  Expense Report Adjustments
--                                        INTERFACVI    -  Interface VI to payables
--                                        INTERFACER      -  Interface ER to payables
--                                        EXPENDITURE   - For actuals entering through Projects
--
--      P_packet_id               : Packet ID of the packet to be funds checked.
--      P_mode                    : Funds Checker Operation Mode.
--                                        C  - Check funds
--                                        R  - Reserve funds.
--                                        U  - Un-reserve  (only for REQ,PO and AP)
--                                        B  - Called from budget baseline process  (Processed like check funds)
--                                        S  - Called from Budget submission     (Processed like check funds)
--      P_partial_flag            : Indicates the packet can be fundschecked/reserverd partially or not
--                                        Y  - Partial
--                                        N  - Full mode, default is N
--      P_reference1              If the p_mode  is  'R',U,C,F' and p_calling_module = 'CBC'or 'EXP' then
--                                        this parameter holds the document type info Document Type
--                                        EXP  - Expenditures originating from project
--                                        CC    -   Contract Commitments
--                                Elsif  p_mode is  B, S and p_calling_module = 'BASELINE' then
--                                        this parameter holds the ext_bdgt_link_flag
--                                End if;
--                                *  This param is not null for EXP , CC  document type and Base line mode
--      P_reference2              If the p_mode is  'R',U,C,F' and p_calling_module = 'CBC'   then
--                                        this parameter holds the document header info for Contract Commitment
--                                        document  Header Id  from Contract Commitments
--                                        IGC_CC_INTERFACE.CC_HEADER_ID
--                                Elsif  p_mode is  B, S and p_calling_module = 'BASELINE' then
--                                        this parameter holds the project_id
--                                End if;
--                                *  This param is not null for CC   document type   and Base line mode
--      P_reference3              If p_mode is  B, S and p_calling_module = 'BASELINE' then
--                                        this parameter holds the budget_version_id
--                                End if;
--                                *  This param is not null for  Base line mode and Contract commitments
--
--      p_conc_flag               : identifies when funds check is invoked from concurrent program.
--                                The valid values are
--                                        'N'  default
--                                        'Y'  - concurrent programm
--
--      x_return_status           : Fudscheck return status
--                                Valid Status are
--                                        S  -  Success
--                                        F  -  Failure
--                                        T  -  Fatal
--      x_error_stage             :Identifies the place where funds check process failed
--
--      x_error_messagee          :defines the type of error : SQLerror||sqlcode
-------------------------------------------------------------------------------------------------------------+ */
FUNCTION pa_funds_check
       (p_calling_module                IN      VARCHAR2
       ,p_conc_flag                     IN      VARCHAR2 DEFAULT 'N'
       ,p_set_of_book_id                IN      NUMBER
       ,p_packet_id                     IN      NUMBER
       ,p_mode                          IN      VARCHAR2 DEFAULT 'C'
       ,p_partial_flag                  IN      VARCHAR2 DEFAULT 'N'
       ,p_reference1                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference2                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference3                    IN      VARCHAR2 DEFAULT NULL
       ,x_return_status                 OUT NOCOPY     VARCHAR2
       ,x_error_msg                     OUT NOCOPY     VARCHAR2
       ,x_error_stage                   OUT NOCOPY     VARCHAR2
         )   RETURN BOOLEAN ;

-- This is an overloaded api in turn calls the main fund check function
PROCEDURE  pa_funds_check
       (p_calling_module                IN      VARCHAR2
       ,p_set_of_book_id                IN      NUMBER
       ,p_packet_id                     IN      NUMBER
       ,p_mode                          IN      VARCHAR2 DEFAULT 'C'
       ,p_partial_flag                  IN      VARCHAR2 DEFAULT 'N'
       ,p_reference1                    IN      VARCHAR2  DEFAULT NULL
       ,p_reference2                    IN      VARCHAR2  DEFAULT NULL
       ,x_return_status                 OUT NOCOPY     VARCHAR2
       ,x_error_msg                     OUT NOCOPY     VARCHAR2
       ,x_error_stage                   OUT NOCOPY     VARCHAR2
         ) ;
/*---------------------------------------------------------------------------------------------------------+
-- This is the Tie back api which updates the status  of pa_bc_packets table   after confirming the funds checking
-- status of  GL / Contract Commitments
--Parameters:
--	P_packet_id		:  Packet Identifier of the funds check process
--	P_mode			:Funds Checker Operation Mode
--					R  -   Reserve  Default
--					B  -    Base line
--	P_calling_module	:This holds  the info of  budget type
--					GL   --- Standard   Default
--					CBC  --- Contract Commitments
--	P_reference1		:This Param is not null in case of  Contract Commitment
--				If  P_ext_bdgt_type   = CBC
--					This param holds the information of document type
--					P_reference2 = Igc_cc_interface.document_type
--				elsif  p_mode  = B then
--					P_reference1 =  project_id
--				Else
--					P_reference1  = NULL;
--				End if;
--	P_reference2		:This Param is not null in case of  Contract Commitment
--				If  P_ext_bdgt_type   = CBC
--					This param holds the information of document Header Id
--					P_reference2 = Igc_cc_interface.CC_HEADER_ID
--				elsif  p_mode  = B then
--					P_reference2 =  budget_version_id
--				Else
--					P_reference2  = NULL;
--				End if;
--	p_partial_flag		:Partial reservation flag
--					Y  -   partial mode
--					N   -   full Mode  default
--	P_gl_cbc_return_code	:The return status of the GL /CBC funds check process
---------------------------------------------------------------------------------------------------------+ */

PROCEDURE   PA_GL_CBC_CONFIRMATION
	(p_calling_module       IN      VARCHAR2
        ,p_packet_id            IN      NUMBER
	,p_mode			IN	VARCHAR2  	DEFAULT 'C'
        ,p_partial_flag         IN      VARCHAR2        DEFAULT 'N'
	,p_reference1 		IN     	VARCHAR2   	DEFAULT  NULL  -- doc type = 'CC'
	,p_reference2 		IN 	VARCHAR2   	DEFAULT  NULL  ---- CC_HEADER_ID
	,p_gl_cbc_return_code	IN OUT NOCOPY	VARCHAR2
	,x_return_status        OUT NOCOPY     VARCHAR2
	) ;

---------------------------------------------------------------------------------------------------+
--This api is used to update the encumbrance balances and budget account balances after the
-- funds check process is complete and result of the funds check process is successful
-- this api will be called from Base line process during  tie back process
---------------------------------------------------------------------------------------------------+
PROCEDURE upd_bdgt_encum_bal(
                p_packet_id             IN NUMBER,
                p_calling_module        IN VARCHAR2,
                p_mode                  IN VARCHAR2,
                p_packet_status         IN VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------------------+
-- This api updates the status of bc packets based on the result code
--  and calling mode and partial flag
-- The valid status code values are
-- A - Approved
-- B - Base lined -- Intermediate status
-- R - Rejected
-- C - Checked   -- Intermediate status
-- F - Failed Check
-- S - Passed Check
-- E - Error
-- T - Fatal
-- V - Vendor Invoice - Intermediate status to avoid sweeper to pick
-- L - Intermediate status for Expense report to liquidate but avoid sweeper to pick
-- if the calling module is BASELINE  then use BULK FETCH AND BULK
-- update logic since the volume of records is more.
-----------------------------------------------------------------------------------------------+
PROCEDURE status_code_update (
        p_calling_module        IN VARCHAR2,
        p_packet_id             IN NUMBER,
        p_mode                  IN VARCHAR2,
        p_partial               IN VARCHAR2 DEFAULT 'N',
	p_packet_status         IN VARCHAR2 DEFAULT 'S',
        x_return_status         OUT NOCOPY varchar2 );

-----------------------------------------------------------------------------------------------+
-- This procedure is the autonomous version of status_code_udpate. Basically, this procedure
-- will call status_code_update
-- main procedure status_code_update is being made non-autonomous
-----------------------------------------------------------------------------------------------+
PROCEDURE status_code_update_autonomous (
        p_calling_module        IN VARCHAR2,
        p_packet_id             IN NUMBER,
        p_mode                  IN VARCHAR2,
        p_partial               IN VARCHAR2 DEFAULT 'N',
	p_packet_status         IN VARCHAR2 DEFAULT 'S',
        x_return_status         OUT NOCOPY varchar2 );

----------------------------------------------------------------+
-- This api writes message to log file / buffer / dummy table
-- and initalizes the final out NOCOPY params with values
----------------------------------------------------------------+
PROCEDURE log_message(
          p_stage    IN VARCHAR2 default null,
          p_error_msg IN VARCHAR2 default null,
	  p_return_status IN varchar2 default null,
          p_msg_token1   IN VARCHAR2 default null,
          p_msg_token2   IN VARCHAR2 default null
          ) ;

------------------------------------------------------------------+
-- This api updates the result and status code in pa bc packets
-- whenever there is error while  processing
-----------------------------------------------------------------+
PROCEDURE result_status_code_update
          ( p_status_code               IN VARCHAR2 default null
            ,p_result_code              IN VARCHAR2 default null
            ,p_res_result_code          IN VARCHAR2 default null
            ,p_res_grp_result_code      IN VARCHAR2 default null
            ,p_task_result_code         IN VARCHAR2 default null
            ,p_top_task_result_code     IN VARCHAR2 default null
            ,p_project_result_code      IN VARCHAR2 default null
            ,p_proj_acct_result_code    IN VARCHAR2 default null
            ,p_bc_packet_id             IN NUMBER   default null
            ,p_packet_id                IN NUMBER ) ;

-------------------------------------------------------------------------+
-- This api checks  whether the Invoice is coming after the
-- interface from projects if the invoice is already interfaced
-- from projects then donot derive burden components
-- if the invoice system_linkage function is 'VI' then
-- derive budget ccid, encum type id, etc and DONOT do funds check
-- mark the invoice as approved and donot create encum liqd
-- if the invoice system linkage func is 'ER' then
-- derive budget ccid, encum type id, etc and DONOT funds check
-- mark the invoice as approved and create encum liqd for raw only
-------------------------------------------------------------------------+
PROCEDURE is_ap_from_project
        (p_packet_id        IN  NUMBER,
         p_calling_module   IN  VARCHAR2,
         x_return_status    OUT NOCOPY VARCHAR2) ;

----------------------------------------------------------------------------+
-- This api checks whether the project is of burden on same or different
-- expenditure items
---------------------------------------------------------------------------+
FUNCTION check_bdn_on_sep_item(p_project_id  In number) return varchar2;
PRAGMA RESTRICT_REFERENCES (check_bdn_on_sep_item, WNDS);

/* The following API is added to tie back the status code of the
 * bc packets during the distribute vendor invoice adjustments
 * This API will be called from PABCCSTB.pls package and pro*c
 */
PROCEDURE tieback_pkt_status
                          (p_calling_module     in varchar2
                          ,p_packet_id          in number
                          ,p_partial_flag       in varchar2 default 'N'
                          ,p_mode               in varchar2 default 'R'
                          ,p_tieback_status     in varchar2 default 'T' --'S' for Success, 'T' -- fatal Error
                          ,p_request_id         in number
                          ,x_return_status      OUT NOCOPY varchar2);

/* This api derives the resource list member id for the given packet id
 * this api should be used only for project funds check records which are
 * inserted into pa_bc_packets */
PROCEDURE DERIVE_RLMI
        ( p_packet_id   IN pa_bc_packets.packet_id%type,
          p_mode        IN  varchar2,
          p_sob         IN NUMBER,
          p_reference1  IN varchar2 default null,
          p_reference2  IN varchar2 default null,
          p_calling_module IN varchar2 default 'GL'
        ) ;

/* This Api derives all the required funds check setup params required for projects funds check
 * if the mode is ForcePass then the transactions will be marked as Pass
 */
FUNCTION  funds_check_setup
        ( p_packet_id   IN pa_bc_packets.packet_id%type,
          p_mode        IN  varchar2,
          p_sob         IN NUMBER,
          p_reference1  IN varchar2 default null,
          p_reference2  IN varchar2 default null,
          p_calling_module IN varchar2
        ) return boolean ;


/* Function is_baseline_progress being made public as it will be accessed in
 * pa_trx_import.tieback_fc_records - Bug 3981458
 */

FUNCTION is_baseline_progress(p_project_id  number)
  return varchar2;

-- Bug 5354715 : This function is made public so that it can be used in other packages to check if the project is installed in this OU.
FUNCTION IS_PA_INSTALL_IN_OU RETURN VARCHAR2 ;

END PA_FUNDS_CONTROL_PKG;

 

/
