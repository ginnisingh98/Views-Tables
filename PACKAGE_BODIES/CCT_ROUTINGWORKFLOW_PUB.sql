--------------------------------------------------------
--  DDL for Package Body CCT_ROUTINGWORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ROUTINGWORKFLOW_PUB" as
/* $Header: cctprwfb.pls 120.1 2005/11/14 13:47:36 ibyon noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_RoutingWorkflow_PUB';
G_ITEMTYPE CONSTANT VARCHAR2(30) := 'ALLROUTE';
G_MAXAGENTS CONSTANT INTEGER := 1000;
G_PROCESS_NAME  VARCHAR2(200) := NULL;
G_TEST_MODE     VARCHAR2(20) := 'OFF';

procedure KevinTest (
     p_number              IN NUMBER
     , p_varchar           out nocopy  VARCHAR2
     , p_varchar2          IN out nocopy  VARCHAR2
 ) IS
 begin
    p_varchar := p_varchar2 || ' + ' || p_varchar2;
    p_varchar2 := p_varchar2 || ' + ' || TO_CHAR(p_number);
    return;
 end;


/* ---------------------------------------------------------------------
   Local Procedures
*  ------------------------------------------------------------------ */
  procedure Randomize_Agents(
	x_agents_tbl IN out nocopy  agent_tbl_type
	, totalCount     IN     NUMBER
  ) is
    l_random NUMBER;
    l_temp   NUMBER;
    l_maxCounter NUMBER:=G_MAXAGENTS;
  begin
    if (totalCount<G_MAXAGENTs) then
	   l_maxCounter:=totalCount-1;
    end if;
    FOR counter in 1..l_maxCounter LOOP
	-- pick a random number between counter and totalCount
	l_random := CCT_Random_UTIL.Rand_Between(counter, totalCount);
        -- swap positions of counter object and randomly picked object
        l_temp := x_agents_tbl(l_random);
        x_agents_tbl(l_random)  := x_agents_tbl(counter);
        x_agents_tbl(counter) := l_temp;
    END LOOP;
  Exception
	 When others then
	    null;
  end Randomize_Agents;



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
     p_MCM_ID                  IN     NUMBER
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
  )
 IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Launch_Workflow_Version2';
    l_api_version CONSTANT NUMBER   := 1.0;

--    l_msg_count		NUMBER;
--    l_msg_data		VARCHAR2(2000);

    l_dummy		VARCHAR2(240);
    l_wf_process_id	NUMBER;
    l_nowait            BOOLEAN := FALSE;
    l_process_status    VARCHAR2(30);
    l_process_result    VARCHAR2(30);
    l_num_dummy         NUMBER;
    l_datetime          DATE := TO_DATE(p_datetime, 'yyyy-mm-dd hh24:mi:ss');

    l_return_status 	VARCHAR2(100);
    l_agent		VARCHAR2(32);
    l_agent1		VARCHAR2(32);
    l_agent2		VARCHAR2(32);
    l_agent3		VARCHAR2(32);
    l_agent4		VARCHAR2(32);
    l_agent5		VARCHAR2(32);
    l_agent6		VARCHAR2(32);
    l_agent7		VARCHAR2(32);
    l_agent8		VARCHAR2(32);
    l_agent9		VARCHAR2(32);
    l_agent10		VARCHAR2(32);
    l_delimiter		VARCHAR2(3) := ';:;' ;
    p_agent_list	VARCHAR2(512);

    l_WORKFLOW_IN_PROGRESS	EXCEPTION;

    CURSOR l_WorkflowProcID_csr IS
	SELECT cct_wf_process_id_s.nextval
	  FROM dual;

    l_itemkey	VARCHAR2(240);
    l_itemtype	VARCHAR2(30) := G_ITEMTYPE;

    l_counter   NUMBER := 0;
    l_numAgents NUMBER := 5;
    l_no_result_Exception 	EXCEPTION;

    CURSOR l_results_csr IS
        SELECT agent_ID
          FROM CCT_ROUTING_RESULTS
          WHERE call_ID = p_call_ID
          ORDER BY sort_num;

    err_name VARCHAR2(30);
    err_msg VARCHAR2(2000);
    err_stack VARCHAR2(32000);

  BEGIN
    -- Initialize return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the new workflow process ID
    OPEN  l_WorkflowProcID_csr;
    FETCH l_WorkflowProcID_csr INTO l_wf_process_id;
    CLOSE l_WorkflowProcID_csr;

    -- Construct the unique item key
    --This step is redundant for Synchronous Workflow
    -- 2:04 PM 2/13/99 Savvas Xenophontos
       l_itemkey := Encode_Call_Itemkey(p_call_ID, l_wf_process_ID);
    IF G_TEST_MODE <> 'ON' THEN
       l_itemkey := wf_engine.eng_synch;
    END IF;

    -- Create and launch the Workflow process
    WF_ENGINE.CreateProcess(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		process		=> null );

    -- Set Item Attributes
   WF_ENGINE.SetItemAttrNumber  (l_itemtype, l_itemkey, 'MCM_ID', p_mcm_id);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'OCCTMEDIAITEMID', p_call_id);

   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'OCCTANI', p_ANI);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'CONTACTNUM',p_contact_num);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'CONTRACTNUM',
			p_contract_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID, p_customer_ID);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'CUSTOMERNAME',
			 p_customer_name);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'CUSTOMERNUM',
			p_customer_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'CUSTOMERPRODUCTID',
			p_customer_product_ID);
   WF_ENGINE.SetItemAttrText  (l_itemtype, l_itemkey, 'OCCTDNIS', p_DNIS);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'INVENTORYITEMID',
			p_inventory_item_ID);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'INVOICENUM', p_invoice_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'LOTNUM', p_lot_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'ORDERNUM', p_order_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'PROBCODE',
			p_problem_code);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'PRODUCTNAME',
			p_product_name);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'PURCHASEORDERNUM', p_po_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'REFERENCENUM', p_reference_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'REVISONNUM', p_revision_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'RMANUM', p_rma_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'SCRPOPTYP',
			p_screen_pop_type);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'SERIALNUM', p_serial_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'SERVICEREQUESTNUM', p_sr_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'SYSTEMNAME', p_system_name);
   WF_ENGINE.SetItemAttrDate  (l_itemtype, l_itemkey, 'OCCTCREATIONTIME', l_datetime);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'ACCOUNTCODE',
			p_account_code);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'PREFERREDID',
			p_preferred_ID);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'PROMOTIONCODE',
			p_promotion_code);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'QUOTENUM', p_quote_num);

   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'LANGUAGECOMPETENCY',
			p_competency_lang);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'KNOWLEDGECOMPETENCY',
			p_competency_know);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'PRODUCTCOMPETENCY',
			p_competency_prod);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'ACCOUNTNUM',
			p_account_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'SITENUM',
			p_site_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'REPAIRNUM',
			p_repair_num);
   WF_ENGINE.SetItemAttrNumber(l_itemtype, l_itemkey, 'DEFECTNUM',
			p_defect_num);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'CUSTOMERSTATUS',
			p_cust_status);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'EVENTCODE',
			p_event_code);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'COLLATERALREQ',
			p_coll_req);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'OCCTCLASSIFICATION',
			p_classification);
   WF_ENGINE.SetItemAttrText(l_itemtype, l_itemkey, 'EMAILICENTERMAPID',
			p_email_icntr_map_id);

    -- Set the engine threshold to a very high number to prevent
    -- this process from ever being deferred
    WF_ENGINE.THRESHOLD := 999999;

    --
    -- Start the process
    -- This procedure call will return only after the process
    -- completes since only function activities are used.
    WF_ENGINE.StartProcess(l_itemtype, l_itemkey );

   /************************************************************
    IF FND_API.To_Boolean(p_commit  ) THEN
      --COMMIT WORK;
    END IF;
   ************************************************************/
   -- Get all the OUT or IN OUT variables from the Workflow

   p_contact_num := WF_ENGINE.GetItemAttrText  (l_itemtype, l_itemkey
                       , 'CONTACTNUM');
   p_customer_name := WF_ENGINE.GetItemAttrNumber(l_itemtype,l_itemkey,
			'CUSTOMERNAME');
   p_product_name := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
				    , 'PRODUCTNAME');
   p_contract_num := WF_ENGINE.GetItemAttrText  (l_itemtype, l_itemkey
				   , 'CONTRACTNUM');
   p_customer_ID := WF_ENGINE.GetItemAttrNumber(l_itemtype,l_itemkey,CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID);
   p_customer_num := WF_ENGINE.GetItemAttrText  (l_itemtype, l_itemkey
				   , 'CUSTOMERNUM');
   p_inventory_item_ID := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
					   , 'INVENTORYITEMID');
   p_invoice_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'INVOICENUM');
   p_lot_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'LOTNUM');
   p_order_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
				, 'ORDERNUM');
   p_problem_code := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
				   , 'PROBCODE');
   p_po_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'PURCHASEORDERNUM');
   p_reference_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
					, 'REFERENCENUM');
   p_revision_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'REVISONNUM');
   p_rma_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey, 'RMANUM');
   p_screen_pop_type := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
					 , 'SCRPOPTYP');
   p_serial_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'SERIALNUM');
   p_sr_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'SERVICEREQUESTNUM');
   p_system_name := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'SYSTEMNAME');
   p_account_code := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
				   , 'ACCOUNTCODE');
   p_preferred_ID := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
				, 'PREFERREDID');
   p_promotion_code := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
					, 'PROMOTIONCODE');
   p_quote_num := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'QUOTENUM');
   p_customer_product_ID := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey,
			                'CUSTOMERPRODUCTID');
   p_account_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
				   , 'ACCOUNTNUM');
   p_site_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey, 'SITENUM');
   p_repair_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
				 , 'REPAIRNUM');
   p_defect_num := WF_ENGINE.GetItemAttrNumber(l_itemtype, l_itemkey
				 , 'DEFECTNUM');
   p_cust_status := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
				  , 'CUSTOMERSTATUS');
   p_event_code := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
			      , 'EVENTCODE');
   p_coll_req  := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey, 'COLLATERALREQ');
   p_classification  := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
					 , 'OCCTCLASSIFICATION');
   p_email_icntr_map_id := WF_ENGINE.GetItemAttrText(l_itemtype, l_itemkey
					 , 'EMAILICENTERMAPID');

  /* ***************************************************************
       Retreive results from CCT_ROUTING_RESULTS tables
       *************************************************************** */
    begin

      open  l_results_csr;

      FOR counter in 1..G_MAXAGENTS LOOP
         fetch l_results_csr into l_agent;
         if l_results_csr%NOTFOUND then raise l_no_result_Exception; end if;
		 if counter = 1 then
             p_agent_list := l_agent;
		 else
             p_agent_list := p_agent_list || l_delimiter  || l_agent;
           end if;

      END LOOP;

     raise l_no_result_exception;
   exception
     WHEN l_no_result_exception THEN
	   CLOSE l_results_csr;
--        p_return_val := p_return_val || l_delimiter || p_agent_list;
        p_return_val := p_agent_list;
        -- delete the results for this call from the CCT_ROUTING_RESULTS
        begin
          DELETE from CCT_ROUTING_RESULTS
          WHERE call_ID = p_call_ID;
		--commit work;
        exception
          WHEN OTHERS THEN
		null;
        end;
   end;

  EXCEPTION
     WHEN OTHERS THEN
      WF_CORE.Get_error(err_name, err_msg, err_stack);
      if (err_name IS NULL) then
	l_return_status := 'ORA ERROR : err_name is ' ||
		to_char(sqlcode) || ' and err_msg is '
		|| sqlerrm;

      else
      l_return_status := 'WF ERROR : err_name is ' ||
		err_name || ' and err_msg is  ' || err_msg;
      end if;
        -- delete the results for this call from the CCT_ROUTING_RESULTS
        begin
          DELETE from CCT_ROUTING_RESULTS
          WHERE call_ID = p_call_ID;
	  --commit work;
        exception
          WHEN OTHERS THEN
		null;
        end;

  END Launch_Workflow_Version2 ;


-- ---------------------------------------------------------------------------
-- Start of comments
--  API Name    : Cancel_Workflow
--  Type        : Public
--  Description : Abort an active Workflow process for the given call
--                request.
--  Pre-reqs    :
--
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
  ) IS
    l_itemtype    VARCHAR2(30) := G_ITEMTYPE;
    l_itemkey     VARCHAR2(30) :=
	Encode_Call_ItemKey(p_call_ID, p_wf_process_ID);
    l_api_name    CONSTANT VARCHAR2(30) := 'Cancel_Workflow';
    l_api_version CONSTANT NUMBER       := 1.0;

    l_not_active  EXCEPTION;
  BEGIN
    -- API Savepoint
    SAVEPOINT Cancel_Workflow_PUB;

    -- Check version number
    IF NOT FND_API.Compatible_API_Call(
			    l_api_version,
                            p_api_version,
                            l_api_name,
                            G_PKG_NAME ) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize return status to SUCCESS
    p_return_status := FND_API.G_RET_STS_SUCCESS;

 /**********************************************************************
    --
    -- Make sure that the item is still active
    --
    IF (CS_Workflow_PKG.Is_Routing_Item_Active (
          p_request_number    =>  p_request_number,
          p_wf_process_id     =>  p_wf_process_id ) = 'N') THEN
      raise l_NOT_ACTIVE;
    END IF;
 **********************************************************************/

    -- Call Workflow API to abort the process
    WF_ENGINE.AbortProcess(
               itemtype  =>  l_itemtype,
               itemkey   =>  l_itemkey );

  EXCEPTION
    WHEN l_NOT_ACTIVE THEN
      ROLLBACK TO Cancel_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CCT', 'CCT_ROUTING_WFLOW_NOT_ACTIVE');
        FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get(
		p_count     => p_msg_count,
                p_data      => p_msg_data,
                p_encoded   => FND_API.G_FALSE );

    WHEN OTHERS THEN
      ROLLBACK TO Cancel_Workflow_PUB;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('CCT', 'CCT_ROUTING_WFLOW_NOT_ACTIVE');
        FND_MSG_PUB.Add;
      END IF;
      FND_MSG_PUB.Count_And_Get(
		p_count     => p_msg_count,
                p_data      => p_msg_data,
                p_encoded   => FND_API.G_FALSE );

  END Cancel_Workflow;


-- ------------------------------------------------------------------------
-- Start of comments
--  API Name    : Selector
--  Type        : Public
--  Description : Selects the root process to run.
--
--  Version     : Initial Version     1.0
--
-- ------------------------------------------------------------------------
  procedure Selector (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
   ) IS
        l_select_process VARCHAR2(30) := 'SELECTOR';
   begin

      select WIA.TEXT_DEFAULT
      into   resultout
      from   WF_ITEM_ATTRIBUTES WIA
      where  WIA.ITEM_TYPE = itemtype
      and    WIA.NAME      = l_select_process;
   exception
      WHEN OTHERS THEN
        null;   -- resultout value is not changed.

   end Selector;


-- ------------------------------------------------------------------------
-- Start of comments
--  API Name    : Get_Agents
--  Type        : Public
--  Description : Select the group of agents as determined by the Filter flags
--		   set.
--
--  Version     : Initial Version     1.0
--  Notes : Create a dynamic sql statement by concatenating the clause(s)
--          needed for each flag that is set.
--          The dynamic sql statement is run on the table CCT_TEMPAGENTS
--          and the resulting agents are inserted into CCT_ROUTING_RESULTS
--          with sort order info added.
-- ------------------------------------------------------------------------
 procedure Get_Agents (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
   ) IS
   l_call_ID            VARCHAR2(40);
   l_wf_process_ID      NUMBER;
   l_dynamic_select     VARCHAR2(4000);
   l_filter_flag        VARCHAR2(1);
   l_filter_type        VARCHAR2(40);
   l_select_csr         INTEGER;
   l_sort_num           NUMBER := 0;
   l_dummy              INTEGER;
   l_agent_ID           VARCHAR(32);
   l_agents_tbl         agent_tbl_type;
   l_available		    VARCHAR2(5) := '''T''';
   l_MCM_ID 		    NUMBER ;
   l_default_select     VARCHAR2(200);
   l_apos			    VARCHAR2(4) := '''';
   l_reroute            VARCHAR2(20);

   CURSOR l_filters_csr	IS
	select FILTER_TYPE from CCT_TEMPAGENTS
	where call_id = l_call_id
	and   agent_id  = '-1' ;


  BEGIN
   -- set default result
   -- If reouted do not reroute again
   l_reroute := WF_ENGINE.GetItemAttrText(
				  itemtype
				  , itemkey
				  ,'REROUTED');

   resultout := wf_engine.eng_completed ;

   IF ( l_reroute IS NULL) OR ( l_reroute <> 'Y')
   THEN

     -- get the callid and wf_process_id from the item key
	l_call_ID := WF_ENGINE.GetItemAttrText(itemtype, itemkey,
					'OCCTMEDIAITEMID');
	l_MCM_ID := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey,
					'MCM_ID');
     l_default_select :=
	             'Select distinct(A.agent_id) from cct_tempagents a '||
	             'where a.call_id ='||l_apos||l_call_ID||l_apos||
			   ' and a.agent_id <> '||l_apos||-1||l_apos;

      -- Start the dynamic string
      l_dynamic_select := l_default_select;


      FOR l_filter IN l_filters_csr LOOP
          l_dynamic_select :=  l_dynamic_select ||
          ' AND A.agent_ID IN (SELECT agent_ID from CCT_TEMPAGENTS ' ||
          ' WHERE CALL_ID = '   || l_apos || l_call_ID || l_apos ||
          ' AND FILTER_TYPE = ' || l_apos || l_filter.FILTER_TYPE || l_apos || ')';
      END LOOP;


      -- now run the select clause using dynamic sql
      begin
        l_select_csr := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_select_csr, l_dynamic_select, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID, 32);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          if DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 then
	     EXIT;
          end if;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          l_agents_tbl(l_sort_num) := l_agent_ID;

        END LOOP;

        IF (l_sort_num = 0) THEN
        --
        -- no agents were found
        -- use any call center agent
           l_dynamic_select :=  l_default_select;

	   DBMS_SQL.PARSE(l_select_csr, l_dynamic_select, DBMS_SQL.NATIVE);
           DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID, 32);
           l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

           l_sort_num  := 0;

           LOOP
             if DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 then
	        EXIT;
             end if;

             DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

             -- insert the cursor record into the l_agents_tbl Table
             l_sort_num := l_sort_num + 1;
             l_agents_tbl(l_sort_num) := l_agent_ID;

           END LOOP;
        END IF;

        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);

        -- delete the entries for this call from CCT_TEMPAGENTS
        -- delete the entries for this call from CCT_TEMPAGENTS
        -- Donot delete if in testmode, then need to explicitly delete this table later
       IF G_TEST_MODE <> 'ON' THEN
         DELETE from CCT_TEMPAGENTS
         WHERE CALL_ID = l_call_ID;
       END IF;

        -- do the randomization to reduce number of agents returned to TEN
        if (l_sort_num <= G_MAXAGENTS) then
 	   -- randomization needed insert all into CCT_ROUTING_RESULTS
           Randomize_Agents(l_agents_tbl, l_sort_num);
           FOR counter IN 1..l_sort_num
	   LOOP
             INSERT INTO CCT_ROUTING_RESULTS
             (call_id,itemkey,agent_id,sort_num,
              routing_Result_id,last_update_date,last_updated_by,
              creation_Date,created_by)
 	        VALUES (l_call_ID, itemkey,l_agents_tbl(counter), counter,
              1001,sysdate,1,sysdate,1);
           END LOOP;
        else
           -- do the randomization to reduce number of agents returned to TEN
           Randomize_Agents(l_agents_tbl, l_sort_num);
           FOR counter IN 1..G_MAXAGENTS
	   LOOP
             INSERT INTO CCT_ROUTING_RESULTS
             (call_id,itemkey,agent_id,sort_num,
              routing_Result_id,last_update_date,last_updated_by,
              creation_Date,created_by)
 	        VALUES (l_call_ID, itemkey,l_agents_tbl(counter), counter,
              1001,sysdate,1,sysdate,1);
           END LOOP;
           null;
        end if;

        --commit work;
     exception
	WHEN OTHERS THEN
          -- close the cursor
          DBMS_SQL.CLOSE_CURSOR (l_select_csr);
          RAISE;
     end;
  END IF;

 END Get_Agents;


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
--     p_call_ID 	   out nocopy  NUMBER     Required
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
  ) IS
   l_dash_pos   NUMBER;
  BEGIN
    p_call_ID := NULL;
    p_wf_process_ID := NULL;

    l_dash_pos := instr(p_itemkey, '-');
    IF (l_dash_pos = 0) THEN
      return;
    END IF;

    p_call_ID := substr(p_itemkey, 1, l_dash_pos - 1);
    p_wf_process_id := to_number(substr(p_itemkey,
					l_dash_pos + 1,
					length(p_itemkey) - l_dash_pos));
  END Decode_Call_Itemkey;



-- ---------------------------------------------------------------------------
-- Start of comments
--  API Name	: Encode_Call_Itemkey
--  Type	: Public
--  Description	: Given a Call ID  and a Workflow process
--		  ID, this procedure will construct the corresponding
--		  itemkey for the Call item type.
--  Pre-reqs	: None
--  Parameters	:
--     p_call_ID	   IN  NUMBER   Required
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
  )  return VARCHAR2
  IS
    l_returnVal VARCHAR2(100);
  BEGIN
    l_returnVal :=  p_call_ID || '-' || TO_CHAR(p_wf_process_id);
    return l_returnVal;
  END Encode_Call_Itemkey;

 FUNCTION AddParam(p_name VARCHAR2, p_val varchar2, p_type varchar2) return integer is
  begin
       num_params := num_params + 1;
       param_name(num_params) := upper(p_name);
       param_val(num_params) := p_val;
       param_type(num_params) := p_type;
       return num_params;
  end AddParam;

  procedure init_param_table is
  begin
       param_name.delete;
       param_val.delete;
       param_type.delete;
       num_params := 0;
  end init_param_table;

  procedure setParamValue(p_param varchar2, p_val varchar2) is
  begin
    for i in 1..param_name.count loop
        if param_name(i) = p_param then
            param_val(i) := p_val;
            exit;
        end if;
    end loop;
  end setParamValue;

  FUNCTION getParamValue(p_name varchar2) return varchar2 is
  begin
    for i in 1..param_name.count loop
        if param_name(i) = p_name then
            return param_val(i);
        end if;
    end loop;
    return null;
  end getParamValue;

  FUNCTION getParamType(p_name varchar2) return varchar2 is
  begin
    for i in 1..param_name.count loop
        if param_name(i) = p_name then
            return param_type(i);
        end if;
    end loop;
    return null;
  end getParamType;

PROCEDURE Varchar2Table (InString IN varchar2) IS
	idx BINARY_INTEGER := 1;
	pos number := 1;
	str varchar2(32766);
	flag boolean := true;
BEGIN
     paramHash.delete;
     str := InString;
     while flag
     loop
      pos := instr(str,'::');
      if pos = 1 then
        paramHash (idx) := -1; -- When no response
        idx := idx + 1;
      elsif pos <> 0 then
        paramHash (idx) := substr(str,1,pos-1);
        idx := idx + 1;
      else
        paramHash(idx) := substr(str,1);
        flag := false;
      end if;
      str := substr(str,pos+2);
     end loop;
END;

FUNCTION  Launch_Workflow_Version4
    return    VARCHAR2
   IS

    l_api_name	  CONSTANT VARCHAR2(30) := 'Launch_Workflow_Version4';
    l_api_version CONSTANT NUMBER   := 1.0;
    l_return_status 	VARCHAR2(100);
    l_no_result_Exception 	EXCEPTION;
    l_wf_process_id	NUMBER;
    l_itemkey	VARCHAR2(240);
    l_itemtype	VARCHAR2(30) := G_ITEMTYPE;
    p_call_ID           VARCHAR2(200) := getParamValue('OCCTMEDIAITEMID');

    l_counter   NUMBER := 0;
    l_numAgents NUMBER := 5;
    l_agent		VARCHAR2(32);
    p_agent_list	VARCHAR2(4000);
    l_delimiter		VARCHAR2(3) := ';:;' ;

    l_WORKFLOW_IN_PROGRESS	EXCEPTION;

    CURSOR l_WorkflowProcID_csr IS
	SELECT cct_wf_process_id_s.nextval
	  FROM dual;

    CURSOR l_results_csr IS
        SELECT agent_ID
          FROM CCT_ROUTING_RESULTS
         -- WHERE call_ID = p_call_ID
          WHERE call_ID = p_call_ID
          ORDER BY sort_num;

    err_name VARCHAR2(30);
    err_msg VARCHAR2(2000);
    err_stack VARCHAR2(32000);

  BEGIN
    --dbms_output.put_line('p_call_id '|| p_call_id);
    -- Initialize return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Get the new workflow process ID
    OPEN  l_WorkflowProcID_csr;
    FETCH l_WorkflowProcID_csr INTO l_wf_process_id;
    CLOSE l_WorkflowProcID_csr;

    -- Construct the unique item key
    --This step is redundant for Synchronous Workflow
    -- 2:04 PM 2/13/99 Savvas Xenophontos
       l_itemkey := Encode_Call_Itemkey(p_call_ID, l_wf_process_ID);
    -- Do not SYNCH if test mode is ON, all other case SYNCH
    IF G_TEST_MODE <> 'ON' THEN
       l_itemkey := wf_engine.eng_synch;
    END IF;

    begin
    -- Create and launch the Workflow process
    WF_ENGINE.CreateProcess(
		itemtype	=> l_itemtype,
		itemkey		=> l_itemkey,
		process		=> G_PROCESS_NAME );


    exception when others then
        --dbms_output.put_line('Error::'|| SQLERRM);
	   null;
    end;

    --dbms_output.put_line('In Launch 4:: After Create Process');

    -- Set Item Attributes
     --DBMS_OUTPUT.PUT_LINE('Call ID is : ' || p_call_id  );
     --DBMS_OUTPUT.PUT_LINE('itemType is : ' || l_itemtype || '    itemKey is : ' || l_itemkey );
    FOR nIndex IN 1..PARAM_NAME.COUNT LOOP
      Begin
        IF param_type(nIndex) = 'VARCHAR' THEN
            WF_ENGINE.SetItemAttrText (l_itemtype, l_itemkey, param_name(nIndex), param_val(nIndex));
        ELSIF param_type(nIndex)='NUMBER' THEN
            WF_ENGINE.SetItemAttrNumber  (l_itemtype, l_itemkey, param_name(nIndex), param_val(nIndex));
        ELSE
            WF_ENGINE.SetItemAttrDate  (l_itemtype, l_itemkey, param_name(nIndex), to_date(param_val(nIndex),'yyyy-mm-dd hh24:mi:ss'));

        END IF;
      Exception
        when others then
             --dbms_output.put_line('error in setting attribute '||param_name(nIndex)||':'||param_val(nIndex)||sqlerrm);
		null;
      end;
    END LOOP;

    -- Set the engine threshold to a very high number to prevent
    -- this process from ever being deferred
    WF_ENGINE.THRESHOLD := 999999;

    --
    -- Start the process
    -- This procedure call will return only after the process
    -- completes since only function activities are used.
    WF_ENGINE.StartProcess(l_itemtype, l_itemkey );

    --dbms_output.put_line('Getting Attribute value for ScreenpopApp:'||WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SCREENPOPAPP'));
  /* ***************************************************************
       Retreive results from CCT_ROUTING_RESULTS tables
       *************************************************************** */
    begin

      open  l_results_csr;

      FOR counter in 1..G_MAXAGENTS LOOP

         fetch l_results_csr into l_agent;
         if l_results_csr%NOTFOUND then raise l_no_result_Exception; end if;
		 if counter = 1 then
             p_agent_list := l_agent;
		 else
		  if (length(p_agent_list)>3800) then
		     --this is required because of 4000 length limitation
		     raise l_no_result_Exception;
	    	  end if;
            p_agent_list := p_agent_list || l_delimiter  || l_agent;
           end if;

      END LOOP;

     raise l_no_result_exception;
   exception
     WHEN l_no_result_exception THEN
	   CLOSE l_results_csr;
--        p_return_val := p_return_val || l_delimiter || p_agent_list

        -- delete the results for this call from the CCT_ROUTING_RESULTS
        begin
          DELETE from CCT_ROUTING_RESULTS
          WHERE call_ID = p_call_ID;


		--commit work;
        exception
          WHEN OTHERS THEN
		null;
        end;
        --dbms_output.put_line('IN .....exe');
     return p_agent_list;
   end;

  EXCEPTION
     WHEN OTHERS THEN
      WF_CORE.Get_error(err_name, err_msg, err_stack);
      if (err_name IS NULL) then
	l_return_status := 'ORA ERROR : err_name is ' ||
		to_char(sqlcode) || ' and err_msg is '
		|| sqlerrm;

      else
      l_return_status := 'WF ERROR : err_name is ' ||
		err_name || ' and err_msg is  ' || err_msg;
      end if;
        -- delete the results for this call from the CCT_ROUTING_RESULTS

        begin
          DELETE from CCT_ROUTING_RESULTS
          WHERE call_ID = p_call_ID;
	  --commit work;
        exception
          WHEN OTHERS THEN
	        null;
        end;

  END Launch_Workflow_Version4 ;

FUNCTION  Launch_Workflow_Version5(InString varchar2) return varchar2 is
BEGIN
    Varchar2Table(InString);
    fillParamArray;
    RETURN Launch_Workflow_Version4;
end;

PROCEDURE fillParamArray is
    ind number := 1;
    p_ind number := 1;
begin
    if paramHash.count <= 0 then
        return;
    end if;
    init_param_table;
    loop
         param_name(ind) := UPPER(paramHash(p_ind));
	    --dbms_output.put_line('Processing Param Name:'||param_name(ind));

	    -- If SELECTOR is sent as part of string set the global G_PROCESS_NAME
	    --  this process name will be used to start the wf process
	    IF param_name(ind) = 'SELECTOR' THEN
		    G_PROCESS_NAME := paramHash(p_ind+1);
	    END IF;
	    -- If TEST MODE is passed set g_test_mode to turn of wf synch
	    IF param_name(ind) = 'TESTMODE' THEN
              G_TEST_MODE := paramHash(p_ind+1);
	    END IF;
         param_val(ind) := paramHash(p_ind+1);
	    --dbms_output.put_line('           Param Value:'||param_val(ind));
         IF (paramHash(p_ind+2) = '1') THEN
            param_type(ind) := 'VARCHAR';
         ELSIF (paramHash(p_ind+2)='2') THEN
            param_type(ind) := 'NUMBER';
         ELSE
		  param_type(ind) :='DATE';
         END IF;

         ind := ind + 1;
         p_ind := p_ind + 3;
         IF (p_ind >= paramHash.COUNT) THEN
            RETURN;
         END IF;
    end loop;
end;

-- This PROC is for NO AGENTS reroute
procedure reroute (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy  varchar2
   ) IS
   l_call_ID            VARCHAR2(40);
   l_wf_process_ID      NUMBER;
   l_dynamic_select     VARCHAR2(4000);
   l_filter_flag        VARCHAR2(1);
   l_filter_type        VARCHAR2(40);
   l_select_csr         INTEGER;
   l_sort_num           NUMBER := 0;
   l_dummy              INTEGER;
   l_agent_ID           VARCHAR(32);
   l_agents_tbl         agent_tbl_type;
   l_available		    VARCHAR2(5) := '''T''';
   l_MCM_ID 		    NUMBER ;
   l_default_select     VARCHAR2(200);
   l_apos			    VARCHAR2(4) := '''';
   l_reroute            VARCHAR2(20);

   CURSOR l_filters_csr	IS
	select FILTER_TYPE from CCT_TEMPAGENTS
	where call_id = l_call_id
	and   agent_id  = '-1' ;


  BEGIN
   -- set default result
   -- If reouted do not reroute again
   l_reroute := WF_ENGINE.GetItemAttrText(
				  itemtype
				  , itemkey
				  ,'REROUTED');

      IF  (l_reroute = 'Y') THEN
        resultout := 'COMPLETE:N';
      END IF;
    --resultout := wf_engine.eng_completed ;

     -- get the callid and wf_process_id from the item key
	l_call_ID := WF_ENGINE.GetItemAttrText(itemtype, itemkey,
					'OCCTMEDIAITEMID');
	l_MCM_ID := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey,
					'MCM_ID');
     l_default_select :=
	             'Select distinct(A.agent_id) from cct_tempagents a '||
	             'where a.call_id ='||l_apos||l_call_ID||l_apos||
			   ' and a.agent_id <> '||l_apos||-1||l_apos;

      -- Start the dynamic string
      l_dynamic_select := l_default_select;


      FOR l_filter IN l_filters_csr LOOP
          l_dynamic_select :=  l_dynamic_select ||
          ' AND A.agent_ID IN (SELECT agent_ID from CCT_TEMPAGENTS ' ||
          ' WHERE CALL_ID = '   || l_apos || l_call_ID || l_apos ||
          ' AND FILTER_TYPE = ' || l_apos || l_filter.FILTER_TYPE || l_apos || ')';
      END LOOP;


      -- now run the select clause using dynamic sql
      begin
        l_select_csr := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_select_csr, l_dynamic_select, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID, 32);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          if DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 then
	     EXIT;
          end if;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          l_agents_tbl(l_sort_num) := l_agent_ID;

        END LOOP;

        IF (l_sort_num = 0) THEN
        --
        -- no agents were found
        -- use any call center agent
           l_dynamic_select :=  l_default_select;

	   DBMS_SQL.PARSE(l_select_csr, l_dynamic_select, DBMS_SQL.NATIVE);
           DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID, 32);
           l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

           l_sort_num  := 0;

           LOOP
             if DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 then
                IF l_reroute is NULL THEN
                 -- If the call is already rerouted once don't reroute again
                 -- even if no agents found
                 -- Set Rerouted to Y as this call is about to be rerouted
                  WF_ENGINE.SetItemAttrText  (
                               itemtype
                                , itemkey
                                , 'REROUTED'
                                , 'Y');
                   -- set reroute to Y
                   resultout := 'COMPLETE:Y';
                    --dbms_output.put_line ('COMPLETE:Y');
                 ELSE
                 --dbms_output.put_line ('COMPLETE:N');
                   resultout := 'COMPLETE:N';
                 END IF;
	             EXIT;
             end if;

             DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

             -- insert the cursor record into the l_agents_tbl Table
             l_sort_num := l_sort_num + 1;
             l_agents_tbl(l_sort_num) := l_agent_ID;

           END LOOP;
	   ELSE
	     -- some agents were found hence set wf to no for reroute
	     --  as agents were found.
	     resultout := 'COMPLETE:N';
        END IF;

        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);

        -- delete the entries for this call from CCT_TEMPAGENTS
       DELETE from CCT_TEMPAGENTS
         WHERE CALL_ID = l_call_ID;


        -- do the randomization to reduce number of agents returned to TEN
        if (l_sort_num <= G_MAXAGENTS) then
 	   -- randomization needed insert all into CCT_ROUTING_RESULTS
           Randomize_Agents(l_agents_tbl, l_sort_num);
           FOR counter IN 1..l_sort_num
	   LOOP
             INSERT INTO CCT_ROUTING_RESULTS
             (call_id,itemkey,agent_id,sort_num,
              routing_Result_id,last_update_date,last_updated_by,
              creation_Date,created_by)
 	        VALUES (l_call_ID, itemkey,l_agents_tbl(counter), counter,
              1001,sysdate,1,sysdate,1);
           END LOOP;
        else
           -- do the randomization to reduce number of agents returned to TEN
           Randomize_Agents(l_agents_tbl, l_sort_num);
           FOR counter IN 1..G_MAXAGENTS
	   LOOP
             INSERT INTO CCT_ROUTING_RESULTS
             (call_id,itemkey,agent_id,sort_num,
              routing_Result_id,last_update_date,last_updated_by,
              creation_Date,created_by)
 	        VALUES (l_call_ID, itemkey,l_agents_tbl(counter), counter,
              1001,sysdate,1,sysdate,1);
           END LOOP;
           null;
        end if;

        --commit work;
     exception
	WHEN OTHERS THEN
          -- close the cursor
          DBMS_SQL.CLOSE_CURSOR (l_select_csr);
          RAISE;
     end;
 END reroute;

 PROCEDURE number_of_reroutes  (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy  varchar2
   ) IS
  l_number_of_reroutes VARCHAR2(20) := '0';
 BEGIN
   l_number_of_reroutes := WF_ENGINE.GetItemAttrText(
                      itemtype
                      , itemkey
                      ,'OCCTREROUTE');
   -- Return the number of reroutes between 0 and 5,
   -- if number if reroutes is more than 5 return 5 only.
   IF l_number_of_reroutes = '0' THEN
     resultout := wf_engine.eng_completed||':0';
   ELSIF  l_number_of_reroutes = '1' THEN
     resultout := wf_engine.eng_completed||':1';
   ELSIF l_number_of_reroutes = '2' THEN
     resultout := wf_engine.eng_completed||':2';
   ELSIF l_number_of_reroutes = '3' THEN
     resultout := wf_engine.eng_completed||':3';
   ELSIF l_number_of_reroutes = '4' THEN
     resultout := wf_engine.eng_completed||':4';
   ELSIF l_number_of_reroutes = '5' THEN
     resultout := wf_engine.eng_completed||':5';
   ELSE
     resultout := wf_engine.eng_completed||':5';
   END IF;

 END number_of_reroutes;

END CCT_RoutingWorkflow_PUB;

/
