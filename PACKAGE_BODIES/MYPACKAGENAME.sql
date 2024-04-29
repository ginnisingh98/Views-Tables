--------------------------------------------------------
--  DDL for Package Body MYPACKAGENAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MYPACKAGENAME" AS
/* $Header: PAXITMPB.pls 120.0.12010000.2 2009/01/23 06:38:28 nkapling noship $ */

------------------------------------
-- FUNCTION/PROCEDURE IMPLEMENTATION
--
-- Replace all occurrences of 'MyProcName' in this file with the name of
-- your main procedure.
--
-- The template assumes that the calling place is 'ADJ' or 'REG' only
-- if other calling place is used then the logic should be modified.
--
-- *** WARNING! DO NOT CHANGE THE PARAMETERS TO MyProcName ***
--

PROCEDURE MyProcName(	X_project_id               IN     NUMBER,
	             	X_top_task_id              IN     NUMBER DEFAULT NULL,
                     	X_calling_process          IN     VARCHAR2 DEFAULT NULL,
                     	X_calling_place            IN     VARCHAR2 DEFAULT NULL,
                     	X_amount                   IN     NUMBER DEFAULT NULL,
                     	X_percentage               IN     NUMBER DEFAULT NULL,
                     	X_rev_or_bill_date         IN     DATE DEFAULT NULL,
                     	X_bill_extn_assignment_id  IN     NUMBER DEFAULT NULL,
                     	X_bill_extension_id        IN     NUMBER DEFAULT NULL,
                     	X_request_id               IN     NUMBER DEFAULT NULL) IS

-- Declare any cursors that your procedure might need here.

CURSOR AdjLogic IS
SELECT event_num, event_type, organization_id
FROM   pa_billing_orig_events_v oe
-- Add a WHERE clause if needed. Example:
-- ,pa_billing_assignments ba
-- WHERE ba.billing_assignment_id = oe.billing_assignment_id
-- AND   ba.billing_extension_id = X_extn_id
;

-- Here you should define all the variable needed by your main procedure
-- for example :
--    revenue_amount	REAL;
-- or new_org_id	NUMBER(6);
-- or project_name	VARCHAR2(30);
L_amount_to_bill    REAL := 0;
L_amount_to_accrue  REAL := 0;

amount  NUMBER(22,5);
revenue NUMBER(10,2) := 0;
invoice	NUMBER(10,2) := 0;
cost    NUMBER(10,2) := 0;
L_event_num_reversed NUMBER;
L_event_type         VARCHAR2(30);
L_organization_id    NUMBER;
l_error_message      VARCHAR2(240);
l_status	     NUMBER;
l_cost_budget_type_code VARCHAR2(30);
l_rev_budget_type_code VARCHAR2(30);

BEGIN

-- Perform processing here.
-- You may remove parameters that are optional and that you do not need to
-- specify from the pre-defined public procedures listed below:
-- Look at documentation in $PA_TOP/install/sql/PAXIPUBS.pls for parameter
-- descriptions and details.
-- You may select amounts being processed in the current run from the two
-- views as below. The rows returned by these views are restricted to
-- the rows being processed by the current run for the project/task being
-- currently processed.

IF (X_calling_process = 'Revenue') THEN
	SELECT	sum(nvl(revenue_amount,0))
	INTO	revenue
	FROM	pa_billing_rev_transactions_v;
ELSE
	SELECT	sum(nvl(bill_amount,0))
	INTO	invoice
	FROM	pa_billing_inv_transactions_v;
END IF;


pa_billing_pub.get_budget_amount(
			 X2_project_id		=> X_project_id,
			 X2_task_id		=> X_top_task_id,
			 X2_revenue_amount	=> revenue,
			 X2_cost_amount		=> cost,
			 X_cost_budget_type_code => l_cost_budget_type_code,
			 X_rev_budget_type_code  => l_rev_budget_type_code,
			 X_status 		=> l_status,
			 X_error_message        => l_error_message);

-- You need to put proper logic to get the original event num from
-- the pa_billing_orig_events_v view.

IF (X_calling_place = 'ADJ' AND X_calling_process = 'Invoice') THEN

    FOR AdjEv IN AdjLogic LOOP

       -- Do Your Own ADJustment logic.
       L_event_num_reversed := AdjEv.event_num;
       L_event_type := AdjEv.event_type;
       L_organization_id := AdjEv.organization_id;
       -- Need your own logic to get proper event info to insert a new event.
       -- For example,
       L_amount_to_accrue := revenue;
       L_amount_to_bill := invoice;

       -- Need to pass proper parameters for your own billing extension
       -- when you call the pa_billing_PUB.Insert_Event procedure.
       -- You must pass in either a revenue amount or a bill amount to
       -- insert_event. See Manual for details.
       pa_billing_pub.Insert_Event (X_rev_amt       => L_amount_to_accrue,
                            X_bill_amt              => L_amount_to_bill,
                            X_project_id            => X_project_id,
                            X_event_type            => L_event_type,
                            X_top_task_id           => X_top_task_id,
                            X_organization_id       => L_organization_id,
                            X_completion_date       => SYSDATE,
                            X_event_num_reversed => L_event_num_reversed,
			    X_status => l_status,
			    X_error_message => l_error_message);

    END LOOP;

ELSE

    -- Do your own logic here.
    L_event_num_reversed := NULL;
    -- Need your own logic to get proper event info to insert a new event.
    -- For example,
    L_amount_to_accrue := revenue;
    L_amount_to_bill := invoice;

    -- Need to pass proper parameters for your own billing extension
    -- when you call the pa_billing_PUB.Insert_Event procedure.
    -- You must pass in either a revenue amount or a bill amount to
    -- insert_event. See Manual for details.
    pa_billing_PUB.Insert_Event (
                     X_rev_amt => L_amount_to_accrue,
                     X_bill_amt => L_amount_to_bill,
                     X_event_description => '',
                     X_event_num_reversed => L_event_num_reversed,
		     X_status => l_status,
		     X_error_message => l_error_message);

END IF;


EXCEPTION
	WHEN OTHERS THEN
	pa_billing_pub.Insert_Message(X_inserting_procedure_name =>'MyProcName',
			 X_message 		=> 'Error Message',
			 X_status 		=> l_status,
			 X_error_message        => l_error_message);
END MyProcName;

END MyPackageName;

/
