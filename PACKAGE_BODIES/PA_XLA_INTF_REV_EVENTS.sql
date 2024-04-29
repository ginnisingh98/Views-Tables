--------------------------------------------------------
--  DDL for Package Body PA_XLA_INTF_REV_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_XLA_INTF_REV_EVENTS" AS
/* $Header: PAXLARVB.pls 120.13 2006/09/20 10:28:14 smaroju noship $ */

/*----------------------------------------------------------------------------------------+
|   Procedure  :   create_events                                                          |
|   Purpose    :   Will create accounting event for revenues eligible for transfer to SLA |
|                  by calling XLA Create_Event API.
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                    Mode            Description                                 |
|     ==================================================================================  |
|                                                                                         |
|      p_request_id           IN              Request id of the run                       |
|                                                                                         |
|      p_return_status        OUT NOCOPY      Return status of the API                    |
|                                                                                         |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/
PROCEDURE create_events (p_request_id 		NUMBER,
			 p_return_status OUT NOCOPY VARCHAR2)
IS

l_project_id_tab  		PA_PLSQL_DATATYPES.Num15TabTyp;
l_project_id_tab_tmp  		PA_PLSQL_DATATYPES.Num15TabTyp;
l_revenue_num_tab		PA_PLSQL_DATATYPES.Num15TabTyp;
l_revenue_num_tab_tmp		PA_PLSQL_DATATYPES.Num15TabTyp;
l_gl_date_tab			PA_PLSQL_DATATYPES.DateTabTyp;
l_event_entity_info 		XLA_EVENTS_PUB_PKG.t_array_entity_event_info_s;
l_event_entity_info_out 	XLA_EVENTS_PUB_PKG.t_array_entity_event_info_s;
l_fetch_complete 		BOOLEAN DEFAULT  FALSE;
l_event_id_tab 			PA_PLSQL_DATATYPES.Num15TabTyp;
l_commit_size 			NUMBER DEFAULT 200;
l_debug_mode 			VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_ledger_id			NUMBER;
l_legal_entity_id		NUMBER;
l_org_id			NUMBER;
l_reject_reason			VARCHAR2(250);
l_project_num_tab		PA_PLSQL_DATATYPES.Char25TabTyp;

--for Revenue Adjustments
l_revenue_num_cr_tab		PA_PLSQL_DATATYPES.Num15TabTyp;

/*Reverted Changes of Bug 5488439 for Bug 5533484
--For Bug 5488439
l_source_appl_id		NUMBER := fnd_profile.value('RESP_APPL_ID'); */
l_source_appl_id		NUMBER := 275;

---Select the eligible revenue(s)for creating corresponding events in SLA.
CURSOR c_revenue_cursor
IS
SELECT 	rev.project_id,
	rev.draft_revenue_num,
	rev.gl_date,
        p.segment1,
	rev.draft_revenue_num_credited  -- for Revenue Adjustments
FROM 	pa_draft_revenues rev,
        pa_projects p
WHERE 	rev.transfer_rejection_reason IS NULL
AND 	rev.transfer_status_code = 'R'
AND 	rev.request_id 		 = p_request_id
AND 	rev.event_id IS NULL
AND     rev.project_id = p.project_id
ORDER BY rev.project_id, rev.draft_revenue_num;

--Cursor to fetch the Legal Entity and Ledger attached to an Operating Unit
CURSOR c_ledger
IS
SELECT  set_of_books_id,
	org_id
FROM    pa_implementations;

CURSOR c_legal_entity(p_org_id number)
IS
SELECT TO_NUMBER(org_information2)
FROM   hr_organization_information
WHERE  organization_id = p_org_id
AND    org_information_context = 'Operating Unit Information';


CURSOR c_event_cursor
Is Select Event_ID, source_id_int_1 , source_id_int_2
   From XLA_EVENTS_INT_GT;


--Fetch the revenues eligible for transfer and create a plsql record for each of the revenue header.
BEGIN



IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Into PA_XLA_REVENUE_EVENTS.Create_Events');
END IF;

	select meaning
	  into l_reject_reason
	  from pa_lookups
	 where lookup_type = 'TRANSFER REJECTION REASON'
	   and  lookup_code = 'PA_SLA_AC_CR_FAIL';

OPEN  c_ledger;
FETCH c_ledger    INTO	 l_ledger_id, l_org_id;
CLOSE c_ledger;

OPEN  c_legal_entity(l_org_id);
FETCH c_legal_entity    INTO  l_legal_entity_id;
CLOSE c_legal_entity;

OPEN c_revenue_cursor;

IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PA_XLA_REVENUE_EVENTS.Create_Events : Before Loop');
END IF;

LOOP
	FETCH c_revenue_cursor BULK COLLECT INTO l_project_id_tab,
						 l_revenue_num_tab,
						 l_gl_date_tab,
                                                 l_project_num_tab,
						 l_revenue_num_cr_tab LIMIT l_commit_size; -- for Revenue Adjustments


	IF c_revenue_cursor%NOTFOUND THEN
		CLOSE c_revenue_cursor;
		l_fetch_complete := TRUE;
	END IF;

DELETE FROM XLA_EVENTS_INT_GT;


IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PA_XLA_REVENUE_EVENTS.Create_Events : Before Insert into XLA_EVENTS_INT_GT');
END IF;

FORALL i IN 1..l_revenue_num_tab.count
	INSERT INTO XLA_EVENTS_INT_GT
	(
	event_type_code		,
	event_date		,
	event_status_code	,
	source_id_int_1		,
	source_id_int_2		,
	security_id_int_1	,
	APPLICATION_ID		,
	LEDGER_ID		,
	LEGAL_ENTITY_ID		,
	ENTITY_CODE		,
	event_id                ,
        security_id_char_1      ,
        transaction_number	,
	event_class_code            -- inserting for Revenue Adjustments
	)
	VALUES
	(
        decode(l_revenue_num_cr_tab(i), NULL, 'REVENUE', 'REVENUE_ADJ')   ,
	l_gl_date_tab(i)			,
	XLA_EVENTS_PUB_PKG.C_EVENT_UNPROCESSED	,
	l_project_id_tab(i)			,
	l_revenue_num_tab(i)			,
	l_org_id				,
	275					,
	l_ledger_id				,
	l_legal_entity_id			,
	'REVENUE'				,
	xla_events_s.nextval * -1               ,
	NULL,
        --'Revenue'                               ,
        l_project_num_tab(i)||'-'||l_revenue_num_tab(i)		       ,
	decode(l_revenue_num_cr_tab(i), NULL, 'REVENUE', 'REVENUE_ADJ')
	);

IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PA_XLA_REVENUE_EVENTS.Create_Events : Before call to CREATE_BULK_EVENTS');
END IF;

--For Bug 5488439 :Changed source_application_id
xla_events_pub_pkg.create_bulk_events ( p_source_application_id   => l_source_appl_id,
					p_application_id 	  => 275,
					p_legal_entity_id 	  => NULL,
					p_ledger_id 		  => l_ledger_id,
					p_entity_type_code 	  => 'REVENUE');

IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PA_XLA_REVENUE_EVENTS.Create_Events : After call to CREATE_BULK_EVENTS');
END IF;


Open c_event_cursor;
Fetch c_event_cursor BULK COLLECT INTO l_event_id_tab, l_project_id_tab_tmp, l_revenue_num_tab_tmp;
Close c_event_cursor;


--Update event_id of pa_draft_revenues_all with the generated event_id in successful
--cases.

IF l_debug_mode = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('PA_XLA_REVENUE_EVENTS.Create_Events : Before draft revenue updation ');
END IF;

FORALL l_index IN l_revenue_num_tab_tmp.first .. l_revenue_num_tab_tmp.last
UPDATE  pa_draft_revenues_all
SET     event_id 		= l_event_id_tab(l_index),
	transfer_rejection_reason = DECODE(sign(nvl(l_event_id_tab(l_index), -1)), 1 , NULL, l_reject_reason)
WHERE   project_id 		= l_project_id_tab_tmp(l_index)
AND 	draft_revenue_num 	= l_revenue_num_tab_tmp(l_index);


l_project_id_tab.delete;
l_revenue_num_tab_tmp.delete;
l_revenue_num_tab.delete;
l_project_id_tab_tmp.delete;
l_gl_date_tab.delete;
l_event_id_tab.delete;
l_project_num_tab.delete;
l_revenue_num_cr_tab.delete;

IF l_fetch_complete THEN
EXIT;
END IF;

END LOOP;


EXCEPTION
WHEN OTHERS THEN
	PA_MCB_INVOICE_PKG.log_message('CREATE_EVENTS: In Exception');
	PA_MCB_INVOICE_PKG.log_message(sqlerrm);
	p_return_status := sqlerrm;
	RAISE;

END create_events;

FUNCTION Get_Sla_Ccid(
                         P_Acct_Event_Id                IN PA_Draft_Revenues_All.Event_Id%TYPE
                        ,P_Transfer_Status_Code         IN PA_Draft_Revenues_All.Transfer_Status_Code%TYPE
                        ,P_Source_Distribution_Id_Num_1 IN XLA_Distribution_Links.Source_Distribution_Id_Num_1%TYPE
                        ,P_Source_Distribution_Id_Num_2 IN XLA_Distribution_Links.Source_Distribution_Id_Num_2%TYPE
                        ,P_Distribution_Type            IN XLA_Distribution_Links.SOURCE_DISTRIBUTION_TYPE%TYPE
                        ,P_Ledger_Id                    IN PA_Implementations_All.Set_Of_Books_Id%TYPE
                       )
    RETURN NUMBER
    IS
        l_ccid                         PA_Cost_Distribution_Lines_All.Dr_Code_Combination_Id%TYPE;
    BEGIN
        SELECT code_combination_id
	INTO l_ccid
    FROM xla_distribution_links xdl,
         xla_ae_headers aeh,
         xla_ae_lines ael
   WHERE xdl.source_distribution_id_num_1 	= P_Source_Distribution_Id_Num_1
     AND xdl.source_distribution_id_num_2	= P_Source_Distribution_Id_Num_2
     AND xdl.Source_Distribution_Type 		= P_Distribution_Type
     AND xdl.application_id 			= 275
     AND xdl.ae_header_id 			=  aeh.ae_header_id
     AND xdl.ae_line_num 			= ael.ae_line_num
     AND xdl.ae_header_id 			= ael.ae_header_id
     AND aeh.application_id 			= ael.application_id
     AND ael.application_id 			= xdl.application_id
     AND aeh.balance_type_code			= 'A'
     AND aeh.accounting_entry_status_code 	= 'F'
     AND aeh.ledger_id 				= P_Ledger_Id
     AND xdl.event_id				= P_Acct_Event_Id;

	return(l_ccid);
EXCEPTION
WHEN OTHERS THEN
	return(NULL);
END Get_Sla_CCID;

END PA_XLA_INTF_REV_EVENTS;

/
