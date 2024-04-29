--------------------------------------------------------
--  DDL for Package PATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PATC" AUTHID CURRENT_USER AS
/* $Header: PAXTTXCS.pls 120.2.12000000.4 2007/07/16 07:01:46 rmsubram ship $ */

-- ======================================================================
/*
The processing flow of the Transaction Controls package follows the description
in the "Using Transaction Controls" essay in the Release 10 OPA Reference
Manual, especially the flow diagramed in Figure 9-4.

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

*/

/* Declare Global variable to hold the Assignment_id IN OUT param from
 * patcx procedure. Instead of adding a new IN OUT variable for PATC,
 * PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION,AP FORM, PO FORM , EXP FORM
 * a global variable is declared in PATC and is accessed from all the
 * above the places to copy the overide value of the assignment id
 **/

 G_OVERIDE_ASSIGNMENT_ID   pa_expenditure_items_all.assignment_id%type := NULL;
/* Added for bug 2648550 */
/* When the assignment_id is overwritten work_type_id,TP_AMT_TYPE_CODE,assignment_name
 * and WORK_TYPE_NAME too needs to be modified.So instead of using IN OUT parameters
 * global variables are declared to hold these parameters and can be referenced from
 * anywhere
 **/
 G_OVERIDE_WORK_TYPE_ID        pa_tasks.work_type_id%type :=NULL;
 G_OVERIDE_TP_AMT_TYPE_CODE    pa_expenditure_items_all.TP_AMT_TYPE_CODE%type :=NULL;
 G_OVERIDE_ASSIGNMENT_NAME     pa_project_assignments.assignment_name%type :=NULL;
 G_OVERIDE_WORK_TYPE_NAME      pa_work_types_tl.name%type :=NULL;
/* End of bug 2648550 */

PROCEDURE set_billable_flag ( txn_cntrl_bill_flag  IN VARCHAR2
                            , task_bill_flag       IN VARCHAR2);

PROCEDURE get_status ( X_project_id             IN NUMBER
                     , X_task_id                IN NUMBER
                     , X_ei_date                IN DATE
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
                     , X_transfer_ei            IN NUMBER DEFAULT NULL
                     , X_incurred_by_org_id     IN NUMBER DEFAULT NULL
                     , X_nl_resource_org_id     IN NUMBER DEFAULT NULL
                     , X_transaction_source     IN VARCHAR2 DEFAULT NULL
                     , X_calling_module         IN VARCHAR2 DEFAULT NULL
                     , X_vendor_id              IN NUMBER DEFAULT NULL
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
                     , X_status                 OUT NOCOPY VARCHAR2
                     , X_billable_flag          OUT NOCOPY VARCHAR2
            	     , p_projfunc_currency_code  IN VARCHAR2    default null
            	     , p_projfunc_cost_rate_type IN VARCHAR2    default null
            	     , p_projfunc_cost_rate_date IN DATE        default null
            	     , p_projfunc_cost_exchg_rate IN NUMBER     default null
            	     , p_assignment_id           IN  NUMBER     default null
            	     , p_work_type_id            IN  NUMBER     default null
                     , p_sys_link_function       IN VARCHAR2    default null
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


   G_PREV_EI_DATE         DATE;
   G_PREV_EXP_TYPE        VARCHAR2(30);
   G_PREV_EXP_TYPE_ACTIVE NUMBER(1);
   G_PREV_LEVEL           VARCHAR2(1);
   G_PREV_PROJ_ID         NUMBER(15);
   G_PREV_TASK_ID         NUMBER(15);

/* Added the following for bug 2831477 */
   G_EXP_TYPE		  VARCHAR2(30);
   G_EXP_TYPE_SYS_LINK    VARCHAR2(30);
   G_EXP_TYPE_START_DATE  DATE;
   G_EXP_TYPE_END_DATE    DATE;

/* Added Procedure check_termination for Bug#4604614 (BaseBug#4118885) */
procedure check_termination (p_person_id in per_all_people_f.person_id%type,
                             p_ei_date   in pa_expenditure_items_all.expenditure_item_date%type,
			     x_actual_termination_date out nocopy per_periods_of_service.actual_termination_date%type);

/* Bug 6156072: Base Bug 6045051: procedure check_termination_for_cwk added */
procedure check_termination_for_cwk (p_person_id in per_all_people_f.person_id%type,
                             p_ei_date   in pa_expenditure_items_all.expenditure_item_date%type,
			     x_actual_termination_date out nocopy per_periods_of_placement.actual_termination_date%type);

END PATC;

 

/
