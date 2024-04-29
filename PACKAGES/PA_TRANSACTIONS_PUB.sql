--------------------------------------------------------
--  DDL for Package PA_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TRANSACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAXTTCPS.pls 120.2.12010000.2 2009/07/28 09:27:56 jravisha ship $ */

--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_transactions_pub.validate_transaction
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure performs basic transaction validation(project
--		  status is not closed, task is chargeable, transaction date
--		  between project/task start and end dates), it then performs
--		  validation against any existing transaction controls. If the
-- 	  transaction passes the validation, it calls the transaction
--		  control client extension(PACTX.tc_extension).
--
-- Parameters   :
--              X_project_id             IN NUMBER
--              X_task_id                IN NUMBER
--              X_ei_date  		IN DATE
--              X_expenditure_type       IN VARCHAR2
--              X_non_labor_resource     IN VARCHAR2
--              X_person_id              IN NUMBER
--              X_quantity               IN NUMBER
--              X_denom_currency_code    IN VARCHAR2
--              X_acct_currency_code     IN VARCHAR2
--              X_denom_raw_cost         IN NUMBER
--              X_acct_raw_cost          IN NUMBER
--              X_acct_rate_type         IN VARCHAR2
--              X_acct_rate_date         IN DATE
--              X_acct_exchange_rate     IN NUMBER
--              X_transfer_ei       	IN NUMBER
--              X_incurred_by_org_id     IN NUMBER
--              X_nl_resource_org_id     IN NUMBER
--              X_transaction_source     IN VARCHAR2
--              X_calling_module         IN VARCHAR2
--	        X_vendor_id		IN NUMBER
--              X_entered_by_user_id     IN NUMBER
--              X_attribute_category     IN VARCHAR2
--              X_attribute1             IN VARCHAR2
--              X_attribute2             IN VARCHAR2
--              X_attribute3             IN VARCHAR2
--              X_attribute4             IN VARCHAR2
--              X_attribute5             IN VARCHAR2
--              X_attribute6             IN VARCHAR2
--              X_attribute7             IN VARCHAR2
--              X_attribute8             IN VARCHAR2
--              X_attribute9             IN VARCHAR2
--              X_attribute10            IN VARCHAR2
--	        X_attribute11            IN VARCHAR2
--              X_attribute12            IN VARCHAR2
--              X_attribute13            IN VARCHAR2
--              X_attribute14            IN VARCHAR2
--              X_attribute15            IN VARCHAR2
--              X_msg_application        IN OUT VARCHAR2
--              X_msg_type               OUT VARCHAR2
--              X_msg_token1             OUT VARCHAR2
--              X_msg_token2             OUT VARCHAR2
--              X_msg_token3             OUT VARCHAR2
--              X_msg_count              OUT NUMBER
--              X_msg_data               OUT VARCHAR2
--              X_billable_flag          OUT VARCHAR2
--
-- Version      : Initial version 	11.1
/*----------------------------------------------------------------------------
The processing flow of the Transaction Controls package follows the description
in the "Using Transaction Controls" essay in the Release 11 Oracle Projects
Reference Manual.

If the transaction passes all of the basic validation checks ( project status
is not closed, task is chargeable, transaction date between project/task start
and end dates), then the transaction is checked against any existing
transaction controls.

The transaction is first validated against any task-level transaction controls.
Task-level transaction controls always override any project-level transaction
controls.  If an applicable transaction control is found at the task level, and
the item passes this control, then the item is valid.  Likewise, if it fails,
then the item is invalid.

If no applicable transaction control is found at the task level, then one of
the following occurs:
  - if the limit to transaction controls flag for the task is set to 'Yes',
    then the item is invalid and is rejected
  - if the flag is set to 'No', then the item is validated against any
    applicable project-level transaction controls.

There may be several transaction controls that are applicable for a given item.
However, transactions are evaluated ONLY against the applicable transaction
control with the highest level of precedence.  The order of precedence is as
follows:

1. Person - Expenditure Category - Expenditure Type - [Non-Labor Resource]
2. Person - Expenditure Category*
3. Expenditure Category - Expenditure Type - [Non-Labor Resource]
4. Expenditure Category

*If a transaction control specifies that a person CAN charge, but does not
 specify an expenditure category, then the procedure looks for any applicable
 transaction controls (the most granular control matching the transaction's
 expenditure category) that do not specify a particular person and then takes
 the intersection of these two transaction controls.  This is illustrated below
 in Example #2 below.



Example 1
---------

Transaction controls defined:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
         --      Expense         --	     --      Yes
         --      Assets          --          --      Yes
     Robinson    Expense     Meals           --      Yes
     Robinson        --          --          --      No
         --      Labor       Clerical        --      Yes
         --      Expense     Meals           --      No

If the transaction being entered is a 'Meals' item for Robinson, then the
following transaction controls are all applicable:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson    Expense     Meals           --      Yes
         --      Expense         --          --      Yes
     Robinson        --          --          --      No
         --      Expense     Meals           --      No

But given the precedence above, only one control is used to validate the item:

Employee       Expend Cat     Expend Type    NLR            Chargeable?
-------------  -------------  -------------  -------------  -------------
Robinson       Expense        Meals               --        Yes

Outcome:  The transaction is valid.


If the transaction being entered is an 'Air Travel' item for Robinson, then the
following transaction controls are both applicable:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson        --          --          --      No
         --      Expense         --          --      Yes

But given the precedence above, only one control is used to validate the item:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson        --          --          --      No

Outcome:  The item is invalid.

NOTE: An intersection of the two applicable transaction controls is not used in
      this case because Robinson is not chargeable.


Example 2
---------

Transaction Controls defined:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson        --          --          --      Yes
         --      Expense         --          --      No
         --      Expense     Meals           --      Yes

Again, if the transaction being entered is a 'Meals' item for Robinson, then
all of the transaction controls are applicable.  Transaction controls involving
a person take precedence over others, so the transaction is validated against
the following control:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson        --          --          --      Yes

But, since the person is chargeable, but an expenditure category is not
specified in this transaction control, then the procedure will check for any
existing transaction controls that match the expenditure category for 'Meals'
and take the INTERSECTION of the two transaction controls.  The following are
applicable:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
         --      Expense         --          --      No
         --      Expense     Meals           --      Yes

Since the most granular transaction control is the only control used to
validate the item, the following control is used in the intersection with
the 'person' control:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
         --      Expense     Meals           --      Yes

Outcome:  The item is valid.


If the item being entered is an 'Air Travel' item for Robinson, then the
following transaction controls are all applicable:

     Employee    Expend Cat  Expend Type NLR         Chargeable?
     ----------- ----------- ----------- ----------- -----------
     Robinson        --          --          --      Yes
         --      Expense         --          --      No

Again an INTERSECTION is necessary.  In this case, however, the item is invalid.

------------------------------------------------------------------------------

  Parameter              Description
  ---------------------- ---------------------------------------------
  X_project_id		 The identifier of the project

  X_task_id              The identifier of the task

  X_ei_date  		 The date of expenditure item

  X_expenditure_type     The type of expenditure

  X_non_labor_resource   The non-labor resource, for usage items only

  X_person_id            Identifier of the person incurring the
			 transaction

  X_quantity             The quantity of the transaction

  X_denom_currency_code  The transaction currency code of the transaction

  X_acct_currency_code   The functional currency code of the transaction

  X_denom_raw_cost       The transaction currency raw cost

  X_acct_raw_cost        The functional currency raw cost. The value of this
			 parameter will not be available for transactions
			 that are uncosted or unaccounted. If autorate
			 functionality is enabled in Oracle Payables then
			 X_acct_raw_cost may not be available.

  X_acct_rate_type       The conversion rate type used to convert the
			 transaction raw cost to functional raw cost.

  X_acct_rate_date       The conversion rate date used to convert the
			 transaction raw cost to functional raw cost.

  X_acct_exchange_rate   Exchange rate used to convert the transaction
			 raw cost to functional raw cost.  The value of this
			 parameter will not be available for transactions
			 that are uncosted or unaccounted. If autorate
			 functionality is enabled in Oracle Payables then
			 X_acct_exchange_rate may not be available.

  X_transfer_ei          The idenitifier of the original expenditure item
			 from which this transaction originated.

  X_incurred_by_org_id   The organization incurring the transaction.

  X_nl_resource_org_id   The identifier of the non-labor resource organization
			 For usageges only.

  X_transaction_source   The transaction source of the items imported using
			 transaction import.

  X_calling_module       The module calling the API. List of possible values
			 for X_calling_modules are:

			 APXINENT (Invoice Work bench form)
			 CreateRelatedItem ( Procedure )
			 PAVVIT ( Interface supplier invoices from payables)
			 PAXTREPE (Pre-Approved Expenditures form)
			 PAXTRTRX ( Transaction import)
			 PAXEXCOP ( Copy Pre-Approved timecards )
			 PAXTEXCB ( Copy Expenditures )
			 PAXPRRPE (Adjust Project Expenditures )
			 POXPOEPO ( Purchase Orders form)
			 POXRQERQ ( Requisitions Form in Oracle Purchasing)
			 POXPOERL ( Release form in Oracle Purchasing)
			 POXPOPRE ( Preferences form in Oracle Purchasing)
			 SelfService ( Web Wxpenses SelfService Application)

			 All values for X_calling_module are case sensitive.

  X_vendor_id		 Identifier of the vendor.

  X_entered_by_user_id   Identifier of the user that entered the transaction

  X_attribute_category   Expenditure item descriptive flexfield context
			 for transactions created in Orcale projects.
			 Invoice distributions descriptive flexfield context
			 for supplier invoices.
			 For project related requisitions and purchase orders
			 this will be equal to requisition/purchase order
			 distributions descriptive flexfield context

  X_attribute[1-15]	 Expenditure item descriptive flexfield segments
			 ( attribute1-10) for transactions created in Oracle
			 Projects.
			 Invoice distributions descriptive flexfields for
			 supplier invoices.
			 For project related requisitions and purchase orders
			 this will be equal to requisition/purchase order
			 distributions descriptive flexfields.
			 Attributes[11-15] are available for modules outside
			 Oracle Projects like AP,PO.

  X_msg_application      The application short name of the message owning
			 application

  X_msg_type             The outcome type of the procedure.
			 Valid Values: W for Warning, E for Errors

  X_msg_token[1-3]       Additional outcome tokens of the procedure. Used to
			 provide more descriptive error messages

  X_msg_count            Future Use.  This is introduced to support multiple
			 messages in future.  In current release we support
			 only 1 message

  X_msg_data             The outcome of the procedure.  The value of this
			 parameter will be equal to the message name.

  X_billable_flag        determine weather or not a transaction is billable
			 or capitalizable

  p_projfunc_currency_code  Project Functional currency code

  p_projfunc_cost_rate_type Project functional rate type is used to derive the project
                            functional raw and burden cost

  p_projfunc_cost_rate_date Project functional rate date is used to derive the project
                            functional raw and burden cost

  p_projfunc_cost_exchg_rate Project functional exchange rate is used to derive the project
                            functional raw and burden cost

  p_assignment_id        identifier of the Assignment

  p_work_type_id         identifier of the work type
---------------------------------------------------------------------------- */
-- Warning Processing in calling programs:
--
-- The following examples describe the usage of API and how to process warning
-- codes returned by the API in calling programs.
--
-- Example:
--
-- Usage in calling module:
--
--    pa_transactions_pub.validate_transaction( X_project_id => 121222
--                      , X_task_id => 1038
--                      , X_ei_date => '12-JAN-97'
--                      , X_expenditure_type => 'Supplies'
--                      , X_non_labor_resource => ''
--                      , X_person_id => 1211
--                      , X_quantity => 120
--		      	, X_denom_currency_code => 'INR'
--		      	, X_acct_currency_code => 'USD'
--		      	, X_denom_raw_cost => 120
--		      	, X_acct_raw_cost => 3
--		      	, X_acct_rate_type => 'Corporate'
--		      	, X_acct_rate_date => '12-FEB-97'
--		      	, X_acct_exchange_rate => .025
--                      , X_transfer_ei => ''
--                      , X_incurred_by_org_id => 129
--                      , X_nl_resource_org_id => ''
--                      , X_transaction_source => 'AP EXPENSE'
--                      , X_calling_module => 'PAXTRTRX'
--		      	, X_vendor_id => 11222
--                      , X_entered_by_user_id => 29
--                      , X_attribute_category => ''
--                      , X_attribute1 => ''
--                      , X_attribute2 => ''
--                      , X_attribute3 => ''
--                      , X_attribute4 => ''
--                      , X_attribute5 => ''
--                      , X_attribute6 => ''
--                      , X_attribute7 => ''
--                      , X_attribute8 => ''
--                      , X_attribute9 => ''
--                      , X_attribute10 => ''
--		      	, X_attribute11 => ''
--		      	, X_attribute12 => ''
--		      	, X_attribute13 => ''
--		      	, X_attribute14 => ''
--	              	, X_attribute15 => ''
--		      	, X_msg_application => X_msg_application
--	              	, X_msg_type => X_msg_type
--		      	, X_msg_token1 => X_msg_token1
--		      	, X_msg_token2 => X_msg_token2
--		      	, X_msg_token3 => X_msg_token3
--		      	, X_msg_count => X_msg_count
--                      , X_msg_data =>  X_msg_data
--                      , X_billable_flag => X_billable_flag);
--
--  After the call to the API, handle any Errors/Warnings returned
--  by the API. Lets assume that the API has returned with the following
--  values in the OUT parameters.
--
--    --------------------------------------------------------------------
--    X_msg_type = 'W'
--    X_msg_data = 'TK_TRANS_CURR_IS_NULL'
--    X_msg_application = 'TK'
--    where TK is application short name for custom application
--    X_msg_token1 = 1038 --Task id
--    X_msg_token2 = 100  -- Functional raw cost
--    X_msg_token3 = 80   -- Transaction Raw cost
--    ----------------------------------------------------------------------
--  The following section shows how to handle Warnings in calling programs
--
--    If X_msg_type = 'W' and X_msg_data is Not NULL then
--
--       if X_msg_application != 'PA' then
--
--	   Please do not customize messages owned by Oracle Projects. If
-- 	   you want to customize a message, create a new message in your
--	   custom application.
--
--
--	   FND_MESSAGE.SET_NAME(X_msg_application,X_msg_data);
--	   FND_MESSAGE.SET_TOKEN( patc_msg_token1,X_msg_token1)
--	   FND_MESSAGE.SET_TOKEN(patc_msg_token2,X_msg_token2)
--	   FND_MESSAGE.SET_TOKEN(patc_msg_token3,X_msg_token3)
--
-- 	 else -- for seeded messages, i.e messages owned by PA
--
--	   Tokens are not supported in Seeded messages
--
--	   FND_MESSAGE.set_name(X_msg_application,X_msg_data)
--
--	 end if;
--
--	 Display the Question Alert. Ask if the user wants to continue or
--	 abort the processing.  If the user chooses to continue, ignore
--	 the warning and continue, otherwise stop processing.
--
--    End if;
--
--       Note: Since warning's involves user interaction which is not possible
--	       in batch programs, hence batch programs will ignore warnings
--	       For Example: In Transaction Import, if validatte_transaction
--		            API returned a Warning, Transaction import would
--			    ignore the warning and continue as if the API
--			    completed successfully.
------------------------------------------------------------------------------
-- Error processing in calling programs:
--
-- The following examples describe how to process error codes returned by
-- validate_transaction procedure in calling programs.
--
-- Example:
--    pa_transactions_pub.validate_transaction( X_project_id => 121222
--                      , X_task_id => 1038
--                      , X_ei_date => '12-JAN-97'
--                      , X_expenditure_type => 'Supplies'
--                      , X_non_labor_resource => ''
--                      , X_person_id => 1211
--                      , X_quantity => 120
--		      	, X_denom_currency_code => 'INR'
--		      	, X_acct_currency_code => 'USD'
--		      	, X_denom_raw_cost => 120
--		      	, X_acct_raw_cost => 3
--		      	, X_acct_rate_type => 'Corporate'
--		      	, X_acct_rate_date => '12-FEB-97'
--		      	, X_acct_exchange_rate => .025
--                      , X_transfer_ei => ''
--                      , X_incurred_by_org_id => 129
--                      , X_nl_resource_org_id => ''
--                      , X_transaction_source => 'AP EXPENSE'
--                      , X_calling_module => 'PAXTRTRX'
--		      	, X_vendor_id => 11222
--                      , X_entered_by_user_id => 29
--                      , X_attribute_category => ''
--                      , X_attribute1 => ''
--                      , X_attribute2 => ''
--                      , X_attribute3 => ''
--                      , X_attribute4 => ''
--                      , X_attribute5 => ''
--                      , X_attribute6 => ''
--                      , X_attribute7 => ''
--                      , X_attribute8 => ''
--                      , X_attribute9 => ''
--                      , X_attribute10 => ''
--		      	, X_attribute11 => ''
--		      	, X_attribute12 => ''
--		      	, X_attribute13 => ''
--		      	, X_attribute14 => ''
--	              	, X_attribute15 => ''
--		      	, X_msg_application => X_msg_application
--	              	, X_msg_type => X_msg_type
--		      	, X_msg_token1 => X_msg_token1
--		      	, X_msg_token2 => X_msg_token2
--		      	, X_msg_token3 => X_msg_token3
--		      	, X_msg_count => X_msg_count
--                      , X_msg_data =>  X_msg_data
--                      , X_billable_flag => X_billable_flag);
--
--  After the call to the API, handle the any Errors/Warnings returned
--  by the API. Lets assume that the API has returned with the following
--  values in the OUT parameters.
--
--   -------------------------------------------------------------------
--   X_msg_type = 'E'
--   X_msg_data = 'TK_QTY_IS_NULL'
--   X_msg_application = 'TK'
--   where TK is application short name for custom application that
--   owns the message
--   X_msg_token1 = 110034   -- Project Id
--   X_msg_token2 =1038      -- Task Id
--   X_msg_token3 = Supplies -- Expenditure Type
--   --------------------------------------------------------------------
--  The following section shows how to handle Warnings in calling programs
--
--   If X_msg_type = 'E' and X_msg_data is not null then
--
--      if X_msg_application !='PA' then
--
--         FND_MESSAGE.SET_NAME(X_msg_application,X_msg_data);
--	   FND_MESSAGE.SET_TOKEN(patc_msg_token1,X_msg_token1);
--	   FND_MESSAGE.SET_TOKEN(patc_msg_token2,X_msg_token2);
--	   FND_MESSAGE.SET_TOKEN(patc_msg_token3,X_msg_token3);
--      else
--	   FND_MESSAGE.set_name(X_msg_application,X_msg_data);
--	end if;
--
--	Display Error Alert.( Similar to release 11 error handling).
--	Abort the processing.
--   End if;
--
-------------------------------------------------------------------------------
-- Custom Error/Warning Messages:
--
-- Prior to release 11.1 users were allowed to store customized error messages
-- for transaction control extension in Oracle Projects, However with release
-- 11.1 customized messages for transaction control extension will not be
-- upgraded.  Users should move all customized messages to a different custom
-- application.  All custom messages should follow the following standards.
--
-- Transaction control custom messages should always have 3 tokens defined in
-- the message text( Even if you do not intend to use the tokens).
--
-- Names of the tokens should be patc_msg_token1, patc_msg_token2 and
-- patc_msg_token3.
--
-- Examples of messages in release 11.0 and prior versions:
-- -------------------------------------------------------
-- Application Name: Oracle Projects
-- Message Name: PATXC_QTY_IS_NULL
-- Message text:  Quantity is null
--
-- Examples of Error messages in release 11.1
-- ------------------------------------------
-- Application Name: <Custom Application>
-- Message Name: TK_QTY_IS_NULL
-- Message text: Quantity is null.
--	         Project id is <patc_msg_token1>
--	         Task_id is <patc_msg_token2>
--	         Expenditure Type is <patc_msg_token3>
--
-- Examples of Warning Messages in release 11.1
-- --------------------------------------------
-- Application Name: <Custom Application>
-- Message Name: TK_TRANS_CURR_IS_NULL
-- Message text: Transaction Currency is null.  Do you want to continue?.
--	         Task Id is <patc_msg_token1>
--	         Functional currency raw cost is <patc_msg_token2>
--	         Transaction currency raw cost is <patc_msg_token3>

-------------------------------------------------------------------------------
  PROCEDURE  validate_transaction(
              X_project_id             IN NUMBER
            , X_task_id                IN NUMBER
            , X_ei_date  		IN DATE
            , X_expenditure_type       IN VARCHAR2
            , X_non_labor_resource     IN VARCHAR2
            , X_person_id              IN NUMBER
            , X_quantity               IN NUMBER DEFAULT NULL
            , X_denom_currency_code    IN VARCHAR2 DEFAULT NULL
            , X_acct_currency_code     IN VARCHAR2 DEFAULT NULL
            , X_denom_raw_cost         IN NUMBER DEFAULT NULL
            , X_acct_raw_cost          IN NUMBER DEFAULT NULL
            , X_acct_rate_type         IN VARCHAR2 DEFAULT NULL
            , X_acct_rate_date         IN DATE DEFAULT NULL
            , X_acct_exchange_rate     IN NUMBER DEFAULT NULL
            , X_transfer_ei       	IN NUMBER DEFAULT NULL
            , X_incurred_by_org_id     IN NUMBER DEFAULT NULL
            , X_nl_resource_org_id     IN NUMBER DEFAULT NULL
            , X_transaction_source     IN VARCHAR2 DEFAULT NULL
            , X_calling_module         IN VARCHAR2 DEFAULT NULL
	    , X_vendor_id		IN NUMBER DEFAULT NULL
            , X_entered_by_user_id     IN NUMBER DEFAULT NULL
            , X_attribute_category     IN VARCHAR2 DEFAULT NULL
            , X_attribute1             IN VARCHAR2 DEFAULT NULL
            , X_attribute2             IN VARCHAR2 DEFAULT NULL
            , X_attribute3             IN VARCHAR2 DEFAULT NULL
            , X_attribute4             IN VARCHAR2 DEFAULT NULL
            , X_attribute5             IN VARCHAR2 DEFAULT NULL
            , X_attribute6             IN VARCHAR2 DEFAULT NULL
            , X_attribute7             IN VARCHAR2 DEFAULT NULL
            , X_attribute8             IN VARCHAR2 DEFAULT NULL
            , X_attribute9             IN VARCHAR2 DEFAULT NULL
            , X_attribute10            IN VARCHAR2 DEFAULT NULL
	    , X_attribute11            IN VARCHAR2 DEFAULT NULL
            , X_attribute12            IN VARCHAR2 DEFAULT NULL
            , X_attribute13            IN VARCHAR2 DEFAULT NULL
            , X_attribute14            IN VARCHAR2 DEFAULT NULL
            , X_attribute15            IN VARCHAR2 DEFAULT NULL
            , X_msg_application        IN OUT NOCOPY VARCHAR2
            , X_msg_type               OUT NOCOPY VARCHAR2
            , X_msg_token1             OUT NOCOPY VARCHAR2
            , X_msg_token2             OUT NOCOPY VARCHAR2
            , X_msg_token3             OUT NOCOPY VARCHAR2
            , X_msg_count              OUT NOCOPY NUMBER
            , X_msg_data               OUT NOCOPY VARCHAR2
            , X_billable_flag          OUT NOCOPY VARCHAR2
            , P_ProjFunc_Currency_Code  IN VARCHAR2    default null
            , P_ProjFunc_Cost_rate_Type IN VARCHAR2    default null
            , P_ProjFunc_Cost_rate_Date IN DATE        default null
            , P_ProjFunc_Cost_Exchg_Rate IN NUMBER     default null
            , P_Assignment_Id           IN  NUMBER     default null
            , P_Work_type_Id            IN  NUMBER     default null
	    , P_Sys_Link_Function       IN  VARCHAR2   default null
	    , P_Po_Header_Id            IN  NUMBER     default null
	    , P_Po_Line_Id              IN  NUMBER     default null
	    , P_Person_Type             IN  VARCHAR2   default null
	    , P_Po_Price_Type           IN  VARCHAR2   default null
	    , P_Document_Type           IN  VARCHAR2   default null
	    , P_Document_Line_Type      IN  VARCHAR2   default null
	    , P_Document_Dist_Type      IN  VARCHAR2   default null
	    , P_pa_ref_num1             IN  NUMBER     default null
	    , P_pa_ref_num2             IN  NUMBER     default null
	    , P_pa_ref_num3             IN  NUMBER     default null
	    , P_pa_ref_num4             IN  NUMBER     default null
	    , P_pa_ref_num5             IN  NUMBER     default null
	    , P_pa_ref_num6             IN  NUMBER     default null
	    , P_pa_ref_num7             IN  NUMBER     default null
	    , P_pa_ref_num8             IN  NUMBER     default null
	    , P_pa_ref_num9             IN  NUMBER     default null
	    , P_pa_ref_num10            IN  NUMBER     default null
	    , P_pa_ref_var1             IN  VARCHAR2   default null
	    , P_pa_ref_var2             IN  VARCHAR2   default null
	    , P_pa_ref_var3             IN  VARCHAR2   default null
	    , P_pa_ref_var4             IN  VARCHAR2   default null
	    , P_pa_ref_var5             IN  VARCHAR2   default null
	    , P_pa_ref_var6             IN  VARCHAR2   default null
	    , P_pa_ref_var7             IN  VARCHAR2   default null
	    , P_pa_ref_var8             IN  VARCHAR2   default null
	    , P_pa_ref_var9             IN  VARCHAR2   default null
	    , P_pa_ref_var10            IN  VARCHAR2   default null);


-- DFF Upgrade -----------------------------------------------------------

-- The following record type is used to record for each context code,
-- which segment is enabled.

TYPE dff_segments_enabled_record IS RECORD (
   context_code fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE,
   context_name fnd_descr_flex_contexts_vl.descriptive_flex_context_name%TYPE,
   is_global           boolean,
   attribute1_enabled  boolean,
   attribute2_enabled  boolean,
   attribute3_enabled  boolean,
   attribute4_enabled  boolean,
   attribute5_enabled  boolean,
   attribute6_enabled  boolean,
   attribute7_enabled  boolean,
   attribute8_enabled  boolean,
   attribute9_enabled  boolean,
   attribute10_enabled  boolean
);

----------------------------------------------------------------------------

-- This table type is used to record, for a descriptive flex field, which
-- context code has which enabled segments.

TYPE dff_segments_enabled_table IS TABLE OF dff_segments_enabled_record
   INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------

-- This Global Variable is used mainly by validate_dff API to keep track of,
-- for a descriptive flexfield, which context code has which enabled segments.
-- We want to record all these information for performance purpose.  By storing
-- these information in a table, we do not need to call ATG API each time if
-- we want to find out which segments are enabled for a particular context code.

G_dff_segments_enabled_table dff_segments_enabled_table;


------------------------------------------------------------------------------
-- Start of Comments
-- API Name      : pop_dff_segments_enabled_table
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : Initialize the global variable G_dff_segments_enabled_table
-- Parameters    : None

/*----------------------------------------------------------------------------*/

PROCEDURE pop_dff_segments_enabled_table;


/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API Name      : populate_segments
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This API is called by pop_dff_segments_enabled_table.  It is
--                 called in a loop by the number of context codes for a
--                 descriptive flexfield.  By giving the segment detail info of
--                 a context code, this API initialize one record of
--                 G_dff_segments_enabled_table with the enabled segments of that
--                 context code.
-- Parameters    :
-- IN
--           p_segment_detail              fnd_dflex.segments_dr
-- IN/OUT
--           p_dff_segments_enabled_record dff_segments_enabled_record

/*----------------------------------------------------------------------------*/

PROCEDURE populate_segments (
      p_segment_detail IN fnd_dflex.segments_dr,
/* Start of bug# 2672653 */
/*    p_dff_segments_enabled_record IN OUT dff_segments_enabled_record); */
      p_dff_segments_enabled_record IN OUT NOCOPY dff_segments_enabled_record);
/* End of  bug# 2672653 */



--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : pa_transactions_pub.validate_dff
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure performs the following two tasks:
--                1. Call pop_dff_segments_enabled_table to initialize
--                   G_dff_segments_enabled_table if it hasn't been initialized
--                2. Validate DFF segments
--                3. Pass out enabled segment values in p_attribute_x parameters
--                   segments which are not enabled are pass out as NULL in p_attribute_x
--                   parameters
-- Parameters:
-- IN
--            p_dff_name              fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE
--            p_attribute_category    pa_expenditure_items_all.attribute_category%TYPE
--
-- IN/OUT
--            p_attribute1            IN OUT pa_expenditure_items_all.attribute1%TYPE
--            p_attribute2            IN OUT pa_expenditure_items_all.attribute2%TYPE
--            p_attribute3            IN OUT pa_expenditure_items_all.attribute3%TYPE
--            p_attribute4            IN OUT pa_expenditure_items_all.attribute4%TYPE
--            p_attribute5            IN OUT pa_expenditure_items_all.attribute5%TYPE
--            p_attribute6            IN OUT pa_expenditure_items_all.attribute6%TYPE
--            p_attribute7            IN OUT pa_expenditure_items_all.attribute7%TYPE
--            p_attribute8            IN OUT pa_expenditure_items_all.attribute8%TYPE
--            p_attribute9            IN OUT pa_expenditure_items_all.attribute9%TYPE
--            p_attribute10           IN OUT pa_expenditure_items_all.attribute10%TYPE
--
-- OUT
--            x_status_code           OUT VARCHAR2
--            x_error_message         OUT VARCHAR2
--
PROCEDURE validate_dff (
				p_dff_name              IN fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
            p_attribute_category    IN pa_expenditure_items_all.attribute_category%TYPE,
            p_attribute1            IN OUT NOCOPY pa_expenditure_items_all.attribute1%TYPE,
            p_attribute2            IN OUT NOCOPY pa_expenditure_items_all.attribute2%TYPE,
            p_attribute3            IN OUT NOCOPY pa_expenditure_items_all.attribute3%TYPE,
            p_attribute4            IN OUT NOCOPY pa_expenditure_items_all.attribute4%TYPE,
            p_attribute5            IN OUT NOCOPY pa_expenditure_items_all.attribute5%TYPE,
            p_attribute6            IN OUT NOCOPY pa_expenditure_items_all.attribute6%TYPE,
            p_attribute7            IN OUT NOCOPY pa_expenditure_items_all.attribute7%TYPE,
            p_attribute8            IN OUT NOCOPY pa_expenditure_items_all.attribute8%TYPE,
            p_attribute9            IN OUT NOCOPY pa_expenditure_items_all.attribute9%TYPE,
            p_attribute10           IN OUT NOCOPY pa_expenditure_items_all.attribute10%TYPE,
            x_status_code           OUT NOCOPY VARCHAR2,
			   x_error_message         OUT NOCOPY VARCHAR2);

/*--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : check_adjustment_of_proj_transactions
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure can be called from an external system
--                to check if an item imported to Projects from an external
--                system through Transaction Import has been adjusted in Projects.
--
--                The API will check the pa_expenditure_items_all.net_zero_adjustment_flag for
--                the item in Projects.
--
--                If the net_zero_adjustment_flag = 'Y'then the item has been adjusted
--                in Projects and the API will return x_adjustment_status = 'Adjusted'.
--
--                If the net_zero_adjustment_flag <> 'Y' then item has NOT been adjusted in
--                Projects and the API will return x_adjustment_status = 'Not Adjusted'.

--                If the item cannot be found in Projects based upon the parameters
--                passed into the API then the API will return
--                x_adjustment_status = 'Not Found'.
--
--                This API is NOT customizable.
--
-- Parameters:
--
-- IN
--                             x_transaction_source                   IN VARCHAR2
--                             x_orig_transaction_reference           IN VARCHAR2
--                             x_expenditure_type_class               IN VARCHAR2
--                             x_expenditure_type                     IN VARCHAR2
--                             x_expenditure_item_id                  IN NUMBER DEFAULT NULL
--                             x_expenditure_item_date                IN DATE
--                             x_employee_number                      IN VARCHAR2 DEFAULT NULL
--                             x_expenditure_organization_name        IN VARCHAR2 DEFAULT NULL
--                             x_project_number                       IN VARCHAR2
--                             x_task_number                          IN VARCHAR2
--                             x_non_labor_resource                   IN VARCHAR2 DEFAULT NULL
--                             x_non_labor_resource_org_name          IN VARCHAR2 DEFAULT NULL
--                             x_quantity                             IN NUMBER
--                             x_raw_cost                             IN NUMBER DEFAULT NULL
--                             x_attribute_category                   IN VARCHAR2 DEFAULT NULL
--                             x_attribute1                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute2                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute3                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute4                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute5                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute6                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute7                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute8                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute9                           IN VARCHAR2 DEFAULT NULL
--                             x_attribute10                          IN VARCHAR2 DEFAULT NULL
--                             x_org_id                               IN NUMBER DEFAULT NULL
--OUT
--                             x_adjustment_status                    OUT VARCHAR2
--                             x_adjustment_status_code               OUT VARCHAR2
--                             x_return_status                        OUT VARCHAR2
--                             x_message_data                         OUT VARCHAR2
--
--

------------------------------------------------------------------------------

  Parameter                            Description
  ----------------------               ---------------------------------------------
  X_transaction_source                 Identifies the external system from which the item
                                       imported by Transaction Import originated.

  X_orig_transaction_reference         Value used to identify the transaction in the external system from
                                       which the imported item originated.

  X_expenditure_type_class             System Linkage function of the expenditure item.

  X_expenditure_type                   The type of expenditure.

  X_expenditure_item_id                Unique identifier of the item in Projects.

  X_expenditure_item_date              Date of the expenditure item.

  X_employee_number                    The employee number of the person who incurred
                                       the expenditure.

  X_expenditure_org_name               The name of the organization that incurred the
                                       expenditure.

  X_project_number                     Number identifying the project to which the
                                       transaction is charged.

  X_task_number                        Number identifying the task to which the
                                       transaction is charged.

  X_non_labor_resource                 The non-labor resource.  For usage items only.

  X_non_labor_resource_org_name        The name of the organization that owns the non-labor
                                       resource utilized.  For usage items only.

  X_quantity                           Number of units for the transaction.

  X_raw_cost                           The total raw cost for the transaction as calculated by the
                                       original, external system.

  X_attribute_category                 Expenditure item descriptive flexfield context
			               for transactions created in Orcale projects.
			               Invoice distributions descriptive flexfield context
			               for supplier invoices.
			               For project related requisitions and purchase orders
			               this will be equal to requisition/purchase order
			               distributions descriptive flexfield context

  X_attribute[1-10]	               Expenditure item descriptive flexfield segments
			               (attribute1-10).

  X_adjustment_status                  Indicates if the item has been adjusted in Projects.
                                       'Adjusted' - Adjusted in Projects
                                       'Not Adjusted' - Not Adjusted in Projects
                                       'Not Found' - Not Found in Projects based upon the
                                                     parameters passed to the API.

  X_adjustment_status_code             Code indicating if the item has been adjusted in
                                       Projects.  Possible values are:
                                       'A' - Adjusted in Projects
                                       'NA' - Not Adjusted in Projects
                                       'NF' - Not Found in Projects based upon the
                                              parameters passed to the API.

  X_return_status                      Indicates the status of the procedure.  Possible values
                                       are:

                                       'S' - Success
                                       'E' - Expected Error
                                       'U' - Unexpected Error

                                       If the parameters passed to the API do not uniquely identify
                                       the transaction in Projects then the API will return
                                       X_return_status = 'E' (Expected Error).

  X_msg_data                           Will contain the error message if x_return_status = 'E' or 'U'.
                                       Will be NULL if x_return_status = 'S'.


  Please note that this API is NOT customizable.

  The following IN paramters are required:

       x_transaction_source
       x_orig_transaction_reference
       x_expenditure_type_class
       x_expenditure_type
       x_expenditure_item_date
       x_project_number
       x_task_number
       x_quantity

  The required parameters, along with any other parameters needed to uniquely identify
  the transaction in Projects, should be passed to the API.


---------------------------------------------------------------------------- */

PROCEDURE check_adjustment_of_proj_txn(
                             x_transaction_source                   IN VARCHAR2,
                             x_orig_transaction_reference           IN VARCHAR2,
                             x_expenditure_type_class               IN VARCHAR2,
                             x_expenditure_type                     IN VARCHAR2,
                             x_expenditure_item_id                  IN NUMBER DEFAULT NULL,
                             x_expenditure_item_date                IN DATE,
                             x_employee_number                      IN VARCHAR2 DEFAULT NULL,
                             x_expenditure_org_name                 IN VARCHAR2 DEFAULT NULL,
                             x_project_number                       IN VARCHAR2,
                             x_task_number                          IN VARCHAR2,
                             x_non_labor_resource                   IN VARCHAR2 DEFAULT NULL,
                             x_non_labor_resource_org_name          IN VARCHAR2 DEFAULT NULL,
                             x_quantity                             IN NUMBER,
                             x_raw_cost                             IN NUMBER DEFAULT NULL,
                             x_attribute_category                   IN VARCHAR2 DEFAULT NULL,
                             x_attribute1                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute2                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute3                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute4                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute5                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute6                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute7                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute8                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute9                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute10                          IN VARCHAR2 DEFAULT NULL,
                             x_org_id                               IN NUMBER DEFAULT NULL,
                             x_adjustment_status                    OUT NOCOPY VARCHAR2,
                             x_adjustment_status_code               OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_message_data                         OUT NOCOPY VARCHAR2);


/*--------------------------------------------------------------------------------
--
-- Start of comments
--
-- API Name     : allow_adjustment_extn
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This client extension will be called when a user attempts to make an adjustment
--                in Projects to an item which was imported from an external system through Transaction Import.
--                The extension can be used by customers to determine if adjustments in Projects
--                should be allowed on those items.
--
--                For example, if the item has been adjusted in the external system then you may
--                not want to allow adjustments to that item in Projects.
--
--                By default, the extension will return pa_transaction_sources.allow_adjustment_flag for
--                p_transaction source.
--
--                If the client extension returns x_allow_adjustment_code = 'Y' (Yes) then the adjustment
--                in Projects will be allowed.
--
--                If the client extension returns x_allow_adjustment_code = 'N' (No) then the adjustment
--                in Projects will NOT be allowed.
--
-- Parameters:
--
-- IN
--                             p_transaction_source                   IN VARCHAR2
--                             p_allow_adjustment_flag                IN VARCHAR2
--                             p_orig_transaction_reference           IN VARCHAR2
--                             p_expenditure_type_class               IN VARCHAR2
--                             p_expenditure_type                     IN VARCHAR2
--                             p_expenditure_item_id                  IN NUMBER
--                             p_expenditure_item_date                IN DATE
--                             p_employee_number                      IN VARCHAR2
--                             p_expenditure_org_name                 IN VARCHAR2
--                             p_project_number                       IN VARCHAR2
--                             p_task_number                          IN VARCHAR2
--                             p_non_labor_resource                   IN VARCHAR2
--                             p_non_labor_resource_org_name          IN VARCHAR2
--                             p_quantity                             IN NUMBER
--                             p_raw_cost                             IN NUMBER
--                             p_attribute_category                   IN VARCHAR2
--                             p_attribute1                           IN VARCHAR2
--                             p_attribute2                           IN VARCHAR2
--                             p_attribute3                           IN VARCHAR2
--                             p_attribute4                           IN VARCHAR2
--                             p_attribute5                           IN VARCHAR2
--                             p_attribute6                           IN VARCHAR2
--                             p_attribute7                           IN VARCHAR2
--                             p_attribute8                           IN VARCHAR2
--                             p_attribute9                           IN VARCHAR2
--                             p_attribute10                          IN VARCHAR2
--                             p_org_id                               IN NUMBER
--OUT
--                             x_allow_adjustment_code                OUT VARCHAR2
--                             x_return_status                        OUT VARCHAR2
--                             x_application_code                     OUT VARCHAR2,
--                             x_message_code                         OUT VARCHAR2,
--                             x_token_name1                          OUT VARCHAR2,
--                             x_token_val1                           OUT VARCHAR2,
--                             x_token_name2                          OUT VARCHAR2,
--                             x_token_val2                           OUT VARCHAR2,
--                             x_token_name3                          OUT VARCHAR2,
--                             x_token_val3                           OUT VARCHAR2);
--
--

  Parameter                            Description
  ----------------------               ---------------------------------------------
  p_transaction_source                 Identifies the external system from which the item
                                       imported by Transaction Import originated.

  p_orig_transaction_reference         Value used to identify the transaction in the external system from
                                       which the imported item originated.

  p_expenditure_type_class             System Linkage function of the expenditure item.

  p_expenditure_type                   The type of expenditure.

  p_expenditure_item_id                Unique identifier of the item in Projects.

  p_expenditure_item_date              Date of the expenditure item.

  p_employee_number                    The employee number of the person who incurred
                                       the expenditure.

  p_expenditure_org_name               The name of the organization that incurred the
                                       expenditure.

  p_project_number                     Number identifying the project to which the
                                       transaction is charged.

  p_task_number                        Number identifying the task to which the
                                       transaction is charged.

  p_non_labor_resource                 The non-labor resource.  For usage items only.

  p_non_labor_resource_org_name        The name of the organization that owns the non-labor
                                       resource utilized.  For usage items only.

  p_quantity                           Number of units for the transaction.

  p_raw_cost                           The total raw cost for the transaction as calculated by the
                                       original, external system.

  p_attribute_category                 Expenditure item descriptive flexfield context
			               for transactions created in Orcale projects.
			               Invoice distributions descriptive flexfield context
			               for supplier invoices.
			               For project related requisitions and purchase orders
			               this will be equal to requisition/purchase order
			               distributions descriptive flexfield context

  p_attribute[1-10]	               Expenditure item descriptive flexfield segments
			               (attribute1-10).

  p_org_id                             Operating unit identifier for multi-organization
                                       installations.

  x_allow_adjustment_code              Code indicating if the item may been adjusted in
                                       Projects.  Possible values are:
                                       'Y' -  Yes (Adjustment is allowed)
                                       'N' -  No  (Adjustment not allowed)

  X_return_status                      Indicates the status of the procedure.  Possible values
                                       are:

                                       'S' - Success
                                       'W' - Warning
                                       'E' - Error

  X_application_code                   The application short name of the message owning
			               application.

  X_message_code                       The message name.

  X_token_name[1-3]                    Name of the tokens in the message.

  X_token_val[1-3]                     Value of the tokens in the message.

--------------------------------------------------------------------------------------

--The following examples describe the usage of API and how to process error/warning
--codes returned by the API in calling programs.

--Example:

--allow_adjustment_extn is called from pa_adjustments.allow_adjustment

--PA_TRANSACTIONS_PUB.Allow_Adjustment_Extn(
--                             p_transaction_source => 'customer transaction source',
--                             p_allow_adjustment_flag => 'Y',
--                             p_orig_transaction_reference => 'Timecard-123',
--                             p_expenditure_type_class => 'ST',
--                             p_expenditure_type => 'Professional',
--                             p_expenditure_item_id => '',
--                             p_expenditure_item_date => '01-JAN-99',
--                             p_employee_number => '',
--                             p_expenditure_org_name => 'Consulting',
--                             p_project_number => '123',
--                             p_task_number => '456',
--                             p_non_labor_resource => '',
--                             p_non_labor_resource_org_name => '',
--                             p_quantity => 8,
--                             p_raw_cost => '',
--                             p_attribute_category => '',
--                             p_attribute1 => '',
--                             p_attribute2 => '',
--                             p_attribute3 => '',
--                             p_attribute4 => '',
--                             p_attribute5 => '',
--                             p_attribute6 => '',
--                             p_attribute7 => '',
--                             p_attribute8 => '',
--                             p_attribute9 => '',
--                             p_attribute10 => '',
--                             p_org_id => '',
--                             x_allow_adjustment_code => x_allow_adjustment_code,
--                             x_return_status => x_return_status,
--                             x_application_code => x_application_code,
--                             x_message_code => x_message_code,
--                             x_token_name1 => x_token_name1,
--                             x_token_val1 => x_token_val1,
--                             x_token_name2 => x_token_name2,
--                             x_token_val2 => x_token_val2,
--                             x_token_name3 => x_token_name3,
--                             x_token_val3 => x_token_val3);
--
--
--
--
--
--ERROR HANDLING
--
--After the call to the client extension, handle any Errors
--returned by the extension.  Assume the OUT parameters have the
--following values:
--
--X_return_status = 'E'
--X_application_code = 'AB' (AB is not application short name for the customer application)
--X_message_code = 'AB_ITEM_NOT_FOUND'
--X_token_name1 = 'TRANSACTION_SOURCE'
--X_token_val1 = 'Customer Transaction Source'
--X_token_name2 = 'EXTERNAL_ID'
--X_token_val2 = 'Timecard-123'
--X_Token_name3 = ''
--X_Token_val3 = ''
--
--The calling program will handle errors in the following way.
--
--    If X_return_status = 'E' and X_msg_data is NOT NULL THEN
--
--       if X_msg_application != 'PA' THEN
--
--	   Please do not customize messages owned by Oracle Projects. If
-- 	   you want to customize a message, create a new message in your
--	   custom application.
--
--
--	   FND_MESSAGE.SET_NAME(X_application_code,X_message_code);
--	   FND_MESSAGE.SET_TOKEN(X_token_name1,X_token_val1)
--	   FND_MESSAGE.SET_TOKEN(X_token_name2,X_token_val2)
--	   FND_MESSAGE.SET_TOKEN(X_token_name3,X_token_val3)
--
-- 	 ELSE -- for seeded messages, i.e messages owned by PA
--
--	   Tokens are not supported in Seeded messages
--
--	   FND_MESSAGE.set_name(X_msg_application,X_msg_data)
--
--	 end if;
--
--    End if;
--
--    Assume that the message_text for 'AB_ITEM_NOT_FOUND' is
--
--         'Unable to find <EXTERNAL_ID> in <TRANSACTION_SOURCE>'
--
--    The error message will then be displayed as follows, and the adjustment will be aborted.
--
--         'Unable to find Timecard-123 in Customer Transaction Source'
--
--
--WARNING HANDLING
--
--After the call to the client extension, handle any Warnings
--returned by the extension.  Assume the OUT parameters have the
--following values:
--
--X_return_status = 'W'
--X_application_code = 'AB' (AB is not application short name for the customer application)
--X_message_code = 'AB_ITEM_ALREADY_BILLED'
--X_token_name1 = 'TRANSACTION_SOURCE'
--X_token_val1 = 'Customer Transaction Source'
--X_token_name2 = 'EXTERNAL_ID'
--X_token_val2 = 'Timecard-123'
--X_Token_name3 = ''
--X_Token_val3 = ''
--
--Assume that the message_text for 'AB_ITEM_ALREADY_BILLED' is
--
--     '<EXTERNAL_ID> from <TRANSACTION_SOURCE> has already been billed.  Are you sure
--      you want to adjust this item?'
--
--
--The calling program will handle warnings in the following way.
--
--    If X_return_status = 'W' and X_msg_data is NOT NULL THEN
--
--       if X_msg_application != 'PA' THEN
--
--	   Please do not customize messages owned by Oracle Projects. If
-- 	   you want to customize a message, create a new message in your
--	   custom application.
--
--
--	   FND_MESSAGE.SET_NAME(X_application_code,X_message_code);
--	   FND_MESSAGE.SET_TOKEN(X_token_name1,X_token_val1)
--	   FND_MESSAGE.SET_TOKEN(X_token_name2,X_token_val2)
--	   FND_MESSAGE.SET_TOKEN(X_token_name3,X_token_val3)
--
-- 	 ELSE -- for seeded messages, i.e messages owned by PA
--
--	   Tokens are not supported in Seeded messages
--
--	   FND_MESSAGE.set_name(X_msg_application,X_msg_data)
--
--	 end if;
--
--    End if;
--
--  Assume that the message_text for 'AB_ITEM_ALREADY_BILLED' is
--
--         '<EXTERNAL_ID> from <TRANSACTION_SOURCE> has already been billed.  Are you sure
--          you want to adjust this item?'
--
--  The warning message will then be displayed as follows:
--
--         'Timecard-123 from Customer Transaction Source has already been billed.
--          Are you sure you want to adjust this item?'
--
--  The user will have be able to continue with the adjustment or abort the adjustment.

----------------------------------------------------------------------------------------*/



PROCEDURE allow_adjustment_extn(
                             p_transaction_source                   IN VARCHAR2,
                             p_allow_adjustment_flag                IN  VARCHAR2,
                             p_orig_transaction_reference           IN VARCHAR2,
                             p_expenditure_type_class               IN VARCHAR2,
                             p_expenditure_type                     IN VARCHAR2,
                             p_expenditure_item_id                  IN NUMBER,
                             p_expenditure_item_date                IN DATE,
                             p_employee_number                      IN VARCHAR2,
                             p_expenditure_org_name                 IN VARCHAR2,
                             p_project_number                       IN VARCHAR2,
                             p_task_number                          IN VARCHAR2,
                             p_non_labor_resource                   IN VARCHAR2,
                             p_non_labor_resource_org_name          IN VARCHAR2,
                             p_quantity                             IN NUMBER,
                             p_raw_cost                             IN NUMBER ,
                             p_attribute_category                   IN VARCHAR2 ,
                             p_attribute1                           IN VARCHAR2 ,
                             p_attribute2                           IN VARCHAR2 ,
                             p_attribute3                           IN VARCHAR2 ,
                             p_attribute4                           IN VARCHAR2 ,
                             p_attribute5                           IN VARCHAR2 ,
                             p_attribute6                           IN VARCHAR2 ,
                             p_attribute7                           IN VARCHAR2 ,
                             p_attribute8                           IN VARCHAR2 ,
                             p_attribute9                           IN VARCHAR2 ,
                             p_attribute10                          IN VARCHAR2 ,
                             p_org_id                               IN NUMBER ,
                             x_allow_adjustment_code                OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_application_code                     OUT NOCOPY VARCHAR2,
                             x_message_code                         OUT NOCOPY VARCHAR2,
                             x_token_name1                          OUT NOCOPY VARCHAR2,
                             x_token_val1                           OUT NOCOPY VARCHAR2,
                             x_token_name2                          OUT NOCOPY VARCHAR2,
                             x_token_val2                           OUT NOCOPY VARCHAR2,
                             x_token_name3                          OUT NOCOPY VARCHAR2,
                             x_token_val3                           OUT NOCOPY VARCHAR2);



/*Bug 8574986 BEGIN*/

          PROCEDURE validate_task(
              X_project_id             IN NUMBER
            , X_task_id                IN NUMBER
            , X_msg_type               OUT NOCOPY VARCHAR2
			, X_msg_token1             OUT NOCOPY VARCHAR2
			, X_msg_count              OUT NOCOPY NUMBER
            , X_msg_data               OUT NOCOPY VARCHAR2
            );

/*Bug 8574986 END*/

END  PA_TRANSACTIONS_PUB;

/
