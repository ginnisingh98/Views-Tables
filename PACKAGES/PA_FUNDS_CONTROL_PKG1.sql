--------------------------------------------------------
--  DDL for Package PA_FUNDS_CONTROL_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FUNDS_CONTROL_PKG1" AUTHID CURRENT_USER as
-- $Header: PABCPKTS.pls 120.8.12000000.2 2007/10/30 17:20:51 vchilla ship $
----------------------------------------------------------------------------------------
-- This Api gets the Start and End date based on amount type and boundary code
-- set up for the project. funds availability will be checked based on this
-- start and end dates.
-- The following combinations are supported
-- Amount Type       Boundary Code
-- ==============   ==============
-- Project           Project to Date
-- Project           Year to Date
-- Project           Period to Date
-- Year              Year to Date
-- Year              Period to Date
-- Period            Period to Date
-- ========================================
PROCEDURE setup_start_end_date (
      	p_packet_id                IN       NUMBER,
      	p_bc_packet_id             IN       NUMBER,
      	p_project_id               IN       pa_bc_packets.project_id%TYPE,
      	p_budget_version_id        IN       pa_bc_packets.budget_version_id%TYPE,
      	p_time_phase_type_code     IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
      	p_expenditure_item_date    IN       DATE,
      	p_amount_type              IN       pa_budgetary_control_options.amount_type%TYPE,
      	p_boundary_code            IN       pa_budgetary_control_options.boundary_code%TYPE,
      	p_set_of_books_id          IN       pa_bc_packets.set_of_books_id%TYPE,
      	x_start_date               OUT      NOCOPY DATE,
      	x_end_date                 OUT      NOCOPY DATE,
      	x_error_code               OUT      NOCOPY NUMBER,
      	x_err_buff                 OUT      NOCOPY VARCHAR2,
	x_return_status		   OUT      NOCOPY VARCHAR2,
	x_result_code		   OUT	    NOCOPY VARCHAR2 ) ;


-----------------------------------------------------------------------------------------------------------------
--This Api  copies the project related records from gl_bc_packets to pa_bc_packets  for document type  AP,PO,REQ,
--CONTRACT PAYMENTS. For the document types CONTRACT COMMITMENT it copies records from
--IGC_CC_INTERFACE table , for the document type = EXP   records are inserted into pa bc packets during costing
------------------------------------------------------------------------------------------------------------------

-- R12 Funds Management Uptake : Renamed procedure populate_plsql_tabs to copy_gl_pkt_to_pa_pkt. This procedure
-- will be fired from Main GL budgetary control API.

PROCEDURE create_proj_encumbrance_events  (p_application_id      IN         NUMBER ,
                               		   p_partial_flag        IN         VARCHAR2 DEFAULT 'N',
					   p_bc_mode             IN         VARCHAR2 DEFAULT 'C',
                                           x_return_code         OUT NOCOPY VARCHAR2 );

---------------------------------------------------------------------
-- this api creates the burden lines for the purchase order and
-- supplier invoice lines in pa_bc_packets
---------------------------------------------------------------------
FUNCTION  create_ap_po_bdn_lines
		(p_packet_id  	  IN  NUMBER,
		 p_bc_packet_id   IN  NUMBER,
		 p_burden_type    IN  VARCHAR2,
		 P_entered_dr     IN  NUMBER,
		 P_entered_cr     IN  NUMBER,
		 P_period_name    IN  VARCHAR2,
		 p_doc_type       IN  VARCHAR2,
		 p_related_link   IN  VARCHAR2,
                 p_exp_type       IN  VARCHAR2,
		 p_accounted_dr   IN  NUMBER,
		 p_accounted_cr   IN  NUMBER,
		 p_compiled_multiplier IN  NUMBER
		) RETURN boolean ;
------------------------------------------------------------------------------------------------------------------
--This  Api insert new records into pa bc packets if the project type is burdened.If the PO is based on REQ, or
--Invoice is based on PO  then  it takes the burden amount for the REQ or PO from pa_bc_commitments table
--and ensures that for  req or po the old burden amount is used when reversing lines are passed in gl_bc_packets
------------------------------------------------------------------------------------------------------------------
PROCEDURE   Populate_burden_cost
        (p_packet_id            IN NUMBER
        ,p_calling_module       IN  VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_err_msg_code         OUT NOCOPY VARCHAR2
        )  ;

-------------------------------------------------------------------------------------------------------
--This api copies the unreserved transaction into to the packet.
-- when the calling mode is unreserved then copy all the transactions from pa_bc_packets
-- for the old packet id(which is funds cheked and approved) to new packet by swapping the amount
-- columns and all other columns values remain same. Approve the packets with status Approved
-- donot create encumbrance liquidation as GL funds checker will create reversing lines
-- for the old packet id and donot populate burden rows / donot check for the unreserved packet
--------------------------------------------------------------------------------------------------------
FUNCTION create_unrsvd_lines
        ( x_packet_id           IN OUT NOCOPY  NUMBER
        ,p_mode                 IN      VARCHAR2
        ,p_calling_module       IN      VARCHAR2
        ,p_reference1           IN      varchar2 default null
        ,p_reference2           IN      varchar2 default null
        )  RETURN BOOLEAN ;
-----------------------------------------------------------------------------------------------------

-- R12:Funds Managment Uptake: Deleting obsolete function get_period_name definition

/** This api returns the start date or end date for the given amount type boundary code
 *  conditions, this in turn make calls the setup_start_end_date api
 *  if p_type param is START_DATE then this api returns start-date
 *  if p_type param is END_DATE  then this api returns end date
 */

FUNCTION get_start_or_end_date(
        p_packet_id                IN       NUMBER,
        p_bc_packet_id             IN       NUMBER,
        p_project_id               IN       pa_bc_packets.project_id%TYPE,
        p_budget_version_id        IN       pa_bc_packets.budget_version_id%TYPE,
        p_time_phase_type_code     IN       pa_budget_entry_methods.time_phased_type_code%TYPE,
        p_expenditure_item_date    IN       DATE,
        p_amount_type              IN       pa_budgetary_control_options.amount_type%TYPE,
        p_boundary_code            IN       pa_budgetary_control_options.boundary_code%TYPE,
        p_set_of_books_id          IN       pa_bc_packets.set_of_books_id%TYPE,
        p_type                     IN       varchar2  -- START_DATE or END_DATE
        ) return DATE ;

-- R12:Funds Managment Uptake: Deleting obsolete PROCEDURE checkCWKbdExp definition


/* This api will update the summary level flag, compiled multiplier etc
 * attributes required for contingent worker related transactions
 */
PROCEDURE upd_cwk_attributes(p_calling_module  varchar2
                        ,p_packet_id   number
                        ,p_mode        varchar2
                        ,p_reference   varchar2
                        ,x_return_status OUT NOCOPY varchar2 );

--PRAGMA RESTRICT_REFERENCES (get_start_or_end_date, WNDS);

PROCEDURE   check_exp_of_cost_base(p_task_id    IN  number,
                                   p_exp_type   IN  varchar2,
                                   p_ei_date    IN  date,
                                   p_sch_type   IN  varchar2 default 'C',
                                   x_base       OUT NOCOPY varchar2,
                                   x_cp_structure OUT NOCOPY varchar2,
                                   x_return_status  OUT NOCOPY varchar2,
                                   x_error_msg_code   OUT NOCOPY varchar2);

/* The APi will return the compiled multiplier that needs to be stamped on the summary
 * record line for the contingent worker transactions
 */
FUNCTION get_cwk_multiplier(p_project_id        IN Number
                        ,p_task_id              IN Number
                        ,p_budget_version_id    IN Number
                        ,p_document_line_id     IN Number
                        ,p_document_type        IN Varchar2
                        ,p_expenditure_type     IN Varchar2
                        ,p_bd_disp_method       IN Varchar2
                        ,p_reference            IN Varchar2  default 'GL'
                        ) Return Number ;


-- R12 Funds Management Uptake : This tieback procedure is called from PSA_BC_XLA_PVT.Budgetary_control
-- if SLA accounting fails.This API will mark the pa_bc_packet records to failed status.
PROCEDURE TIEBACK_FAILED_ACCT_STATUS (p_bc_mode  IN VARCHAR2 DEFAULT 'C');

-- R12 Funds Management Uptake : This Procedure is called from "PRC: Generate Cost accounting events"
-- Process. After events are generated for BTC/TBC actuals which are eligible to get interfaced to SLA ,
-- The below procedure stamps these events on the associated commitments .

PROCEDURE INTERFACE_TBC_BTC_COMT_UPDATE (p_calling_module IN VARCHAR2,
                                         P_request_id     IN NUMBER  ,
					 x_result_code    OUT NOCOPY VARCHAR2);


-- ----------------------------------------------------------------------------+
-- Function get_ration will determine the burden to raw ratio.
-- This is used in cursor po_amounts and pkt_po_amounts in procedure
-- populate_burden_cost
-- ----------------------------------------------------------------------------+
Function get_ratio(p_document_header_id       in number,
                   p_document_distribution_id in number,
                   p_document_type            in varchar2,
                   p_mode                     in varchar2,
                   p_dr_cr                    in varchar2)
                   return number;

----------------------------------------------------------------------
--   Created the following two Procedures POPULATE_PLSQL_TABS_CBC and
--   CREATE_CBC_PKT_LINES for Contract Commitments Enhancement.
----------------------------------------------------------------------
-------->6599207 ------As part of CC Enhancements
PROCEDURE populate_plsql_tabs_CBC
		(p_packet_id  IN number
		,p_calling_module  IN varchar2
		,p_reference1  IN  varchar2
		,p_reference2  IN  varchar2
		,p_mode        IN  varchar2);

PROCEDURE create_CBC_pkt_lines(p_calling_module   IN varchar2,
			   p_packet_id        IN number
			   ,p_reference1      IN VARCHAR2
			   ,p_reference2      IN VARCHAR2
			   ,p_mode        IN  varchar2);
-------->6599207 ------END
----------------------------------------------------------------------

END PA_FUNDS_CONTROL_PKG1;

 

/
