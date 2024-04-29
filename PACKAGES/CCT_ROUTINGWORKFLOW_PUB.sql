--------------------------------------------------------
--  DDL for Package CCT_ROUTINGWORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ROUTINGWORKFLOW_PUB" AUTHID CURRENT_USER as
/* $Header: cctprwfs.pls 120.0 2005/06/02 09:56:34 appldev noship $ */

------------------------------------------------------------------------------
--  Type  : emp_tbl_type
--  Usage : Used by the Get_Agent function to temporarily store the routing
--          results to faciliate sorting/randomization to limit the number
--          of agents returned by the Routing process to 10 agents.
------------------------------------------------------------------------------
TYPE agent_tbl_type IS TABLE OF PER_ALL_PEOPLE_F.PERSON_ID%TYPE
  INDEX BY BINARY_INTEGER;

TYPE ParamTable IS TABLE OF VARCHAR(200) INDEX BY BINARY_INTEGER;
paramHash ParamTable;

type vc_arr is table of varchar2(32600) index by binary_integer;
param_name vc_arr;
param_val  vc_arr;
param_type vc_arr;
num_params number := 0;

procedure KevinTest (
     p_number              IN NUMBER
     , p_varchar           out nocopy  VARCHAR2
     , p_varchar2          IN out nocopy  VARCHAR2

 );


/* -----------------------------------------------------------------------
   Start of comments
    API Name    : Launch_Workflow_Version2
    Type        : Public
    Description : Launch a Workflow process to route the specified call
                  Wait for workflow completion
		  Get results and send back to Routing Module on Server
   Parameters  :
      l_return_val is a concatenation of call_id, customer_name, product_name,
		and the list of agents. The delimiter is ';:;'

   Version     : Initial Version     1.0

   End of comments
* ----------------------------------------------------------------------*/

  PROCEDURE  Launch_Workflow_Version2 (
     p_mcm_id                  IN     NUMBER
     , p_call_ID               IN     VARCHAR2
     , p_ANI                   IN     VARCHAR2
     , p_contact_num           IN out nocopy  VARCHAR2
     , p_customer_name         IN out nocopy  VARCHAR2
     , p_product_name          IN out nocopy  VARCHAR2
     , p_contract_num          IN out nocopy  VARCHAR2
     , p_customer_ID           IN out nocopy  NUMBER
     , p_customer_num          IN out nocopy  VARCHAR2
     , p_DNIS                  IN     VARCHAR2
     , p_inventory_item_ID     IN out nocopy  NUMBER
     , p_invoice_num           IN out nocopy  VARCHAR2
     , p_lot_num               IN out nocopy  VARCHAR2
     , p_order_num             IN out nocopy  NUMBER
     , p_problem_code          IN out nocopy  VARCHAR2
     , p_po_num                IN out nocopy  VARCHAR2
     , p_reference_num         IN out nocopy  VARCHAR2
     , p_revision_num          IN out nocopy  VARCHAR2
     , p_rma_num               IN out nocopy  NUMBER
     , p_screen_pop_type       IN out nocopy  VARCHAR2
     , p_serial_num            IN out nocopy  VARCHAR2
     , p_sr_num                IN out nocopy  VARCHAR2
     , p_system_name           IN out nocopy  VARCHAR2
     , p_datetime              IN     VARCHAR2
     , p_account_code          IN out nocopy  VARCHAR2
     , p_preferred_id          IN out nocopy  NUMBER
     , p_promotion_code        IN out nocopy  VARCHAR2
     , p_quote_num             IN out nocopy  VARCHAR2
     , p_competency_lang       IN     VARCHAR2
     , p_competency_know       IN     VARCHAR2
     , p_competency_prod       IN     VARCHAR2
     , p_customer_product_ID      out nocopy  NUMBER
     , p_account_num           IN out nocopy  NUMBER
     , p_site_num              IN out nocopy  NUMBER
     , p_repair_num            IN out nocopy  NUMBER
     , p_defect_num            IN out nocopy  NUMBER
     , p_cust_status           IN out nocopy  VARCHAR2
     , p_event_code            IN out nocopy  VARCHAR2
     , p_coll_req              IN out nocopy  VARCHAR2
     , p_classification        IN out nocopy  VARCHAR2
     , p_email_icntr_map_id    IN out nocopy  NUMBER
     , p_return_val               out nocopy  VARCHAR2
  ) ;


-- -----------------------------------------------------------------------
-- Start of comments
--  API Name    : Cancel_Workflow
--  Type        : Public
--  Description : Abort an active Workflow process for the given call
--                request.
--  Pre-reqs    :
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments
-- --------------------------------------------------------------------------

  PROCEDURE Cancel_Workflow (
       p_api_version          IN     NUMBER
       , p_init_msg_list      IN     VARCHAR2  DEFAULT FND_API.G_FALSE
       , p_commit             IN     VARCHAR2  DEFAULT FND_API.G_FALSE
       , p_return_status         out nocopy  VARCHAR2
       , p_msg_count             out nocopy  NUMBER
       , p_msg_data              out nocopy  VARCHAR2
       , p_call_ID            IN     NUMBER
       , p_wf_process_id      IN     NUMBER
       , p_user_id            IN     NUMBER
  );


-- --------------------------------------------------------------------------
-- Start of comments
--  API Name    : Selector
--  Type        : Public
--  Description : Select a process from among the many possible processes
--		  for the item.
--  Pre-reqs    :
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments
-- --------------------------------------------------------------------------

  PROCEDURE Selector (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
   );

-- --------------------------------------------------------------------------
-- Start of comments
--  API Name    : Get_Agents
--  Type        : Public
--  Description : Select the group of agents as determined by the Filter flags
--		   set.
--  Pre-reqs    :
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments
-- --------------------------------------------------------------------------

  PROCEDURE Get_Agents (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
  );



-- --------------------------------------------------------------------------
-- Start of comments
--  API Name	: Decode_Call_Itemkey
--  Type	: Public
--  Description	: Given an encoded Routing Request itemkey, this procedure
--  		  will return the components of the key - call ID, and
--		  workflow process ID.
--  Pre-reqs	: None
--  Parameters	:
--     p_itemkey	IN     VARCHAR2   Requried
--     p_call_ID 	   out nocopy  VARCHAR2   Required
--     p_wf_process_id	   out nocopy  NUMBER     Required
--
--  Version	: Initial Version	1.0
--
--  Notes:	:
--
-- End of comments
-- ----------------------------------------------------------------------------

  PROCEDURE Decode_Call_Itemkey(
	p_itemkey	   IN     VARCHAR2
	, p_call_ID  	      out nocopy  VARCHAR2
	, p_wf_process_ID     out nocopy  NUMBER
  );


-- ---------------------------------------------------------------------------
-- Start of comments
--  API Name	: Encode_Call_Itemkey
--  Type	: Public
--  Description	: Given a Call ID  and a Workflow process
--		  ID, this procedure will construct the corresponding
--		  itemkey for the Call item type.
--  Pre-reqs	: None
--  Parameters	:
--     p_call_ID	   IN  VARCHAR2   Required
--     p_wf_process_id     IN  NUMBER	Required
--  Return Value
--     itemkey	               VARCHAR2
--
--  Version	: Initial Version	1.0
--
-- End of comments
-- ---------------------------------------------------------------------------

  FUNCTION Encode_Call_Itemkey(
	p_call_ID           IN VARCHAR2
	, p_wf_process_id   IN NUMBER
  )  return VARCHAR2;


  FUNCTION AddParam(
     p_name VARCHAR2
     , p_val varchar2
     , p_type varchar2)
  return integer;

  procedure init_param_table;

  FUNCTION getParamValue(
      p_name varchar2)
  return varchar2;

  procedure setParamValue(
      p_param varchar2,
      p_val varchar2);

  PROCEDURE Varchar2Table (
      InString varchar2);

  PROCEDURE fillParamArray;

  FUNCTION  Launch_Workflow_Version4
  return varchar2;

  FUNCTION  Launch_Workflow_Version5(
	 InString varchar2)
  return varchar2;

  PROCEDURE reroute (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
  );

  PROCEDURE number_of_reroutes (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
  );


END CCT_RoutingWorkflow_PUB;

 

/
