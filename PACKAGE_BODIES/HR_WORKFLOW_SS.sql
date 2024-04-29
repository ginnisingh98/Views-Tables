--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOW_SS" AS
/* $Header: hrwkflss.pkb 120.10.12010000.8 2010/05/14 10:18:45 gpurohit ship $ */
/*
   This package contails new (v4.0+)workflow related business logic
*/
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_workflow_ss.';
g_asg_api_name          constant  varchar2(80)
                         default 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
-- Salary Basis Enhancement Change Begins
g_mid_pay_period_change  constant varchar2(30) := 'HR_MID_PAY_PERIOD_CHANGE';
g_oa_media     constant varchar2(100) DEFAULT fnd_web_config.web_server||'OA_MEDIA/';
g_oa_html      constant varchar2(100) DEFAULT fnd_web_config.jsp_agent;

g_debug boolean := hr_utility.debug_enabled;
gv_item_name                  VARCHAR2(100) DEFAULT 'ADDITIONAL_APPROVER_';
-- cursor determines if an attribute exists
  cursor csr_wiav (p_item_type in     varchar2
                  ,p_item_key  in     varchar2
                  ,p_name      in     varchar2)
    IS
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< branch_on_approval_flag>------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will read the HR_RUNTIME_APPROVAL_REQ_FLAG item level
-- attribute value and branch accordingly. This value will be set by the review
-- page by reading its attribute level attribute HR_APPROVAL_REQ_FLAG
-- (YES/NO/YES_DYNAMIC)
-- For
--  YES          => branch with Yes result
--  YES_DYNAMIC  => branch with Yes result
--  NO           => branch with No result
-- ----------------------------------------------------------------------------
PROCEDURE branch_on_approval_flag
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2)
is
l_text_value            wf_activity_attr_values.text_value%type;
l_trans_ref_table	hr_api_transactions.transaction_ref_Table%type;
begin
--
l_text_value := wf_engine.GetItemAttrText(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'HR_RUNTIME_APPROVAL_REQ_FLAG');
     if   ( l_text_value  in ('YES_DYNAMIC', 'YES','Y','YD')) then
        -- Approval Process is required
        resultout := 'COMPLETE:'|| 'Y';
    /* elsif l_text_value = 'YES' then
        -- Approval Process is required
        resultout := 'COMPLETE:'|| 'Y';*/
     select transaction_ref_table into l_trans_ref_table
     from hr_api_transactions
     where item_type=itemtype and item_key=itemkey;

     if l_trans_ref_table = 'IRC_OFFERS' then
	     wf_engine.setItemAttrDate(itemtype => itemtype,
                               itemkey => itemkey,
                               aname => 'CURRENT_EFFECTIVE_DATE',
                               avalue => trunc(sysdate)
                               );
     end if;

     else
        -- Approval is not required
        resultout := 'COMPLETE:'|| 'N';
     end if;
--
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package
                   ,'branch_on_approval_flag'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
end branch_on_approval_flag;
--

-- ----------------------------------------------------------------------------
-- |----------------------< set_rejected_by_payroll > -------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will set the item attribute HR_REJECTED_BY_PAYROLL
-- to 'Y'.
-- ----------------------------------------------------------------------------
PROCEDURE set_rejected_by_payroll
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2)
is

begin
--
 IF ( funcmode = 'RUN' )
 THEN
    wf_engine.SetItemAttrText(itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'HR_REJECTED_BY_PAYROLL'
                          ,avalue   => 'Y');

    resultout := 'COMPLETE:';
 ELSE
    --
    NULL;
    --
 END IF;


--
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package
                   ,'set_rejected_by_payroll'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
end set_rejected_by_payroll;
--

-- ----------------------------------------------------------------------------
-- |----------------------- < copy_payroll_comment > -------------------------|
-- ----------------------------------------------------------------------------
-- Purpose: This procedure will populate the wf_note from WF and set the item
--          attribute HR_SALBASISCHG_PAYROLL_COMMENT with that value.
-- ----------------------------------------------------------------------------
PROCEDURE copy_payroll_comment
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2)
IS
  lv_prev_payroll_comment  varchar2(32000) default null;

BEGIN
--
   IF ( funcmode = 'RUN' )
   THEN
      --
      -- Save the previous comment from Payroll first
      lv_prev_payroll_comment := wf_engine.GetItemAttrText
                   (itemtype      => itemtype,
                    itemkey       => itemkey,
                    aname         => 'HR_SALBASISCHG_PAYROLL_COMMENT');


      IF lv_prev_payroll_comment is NOT NULL
      THEN
         lv_prev_payroll_comment := lv_prev_payroll_comment || '<br>';
      END IF;

      wf_engine.SetItemAttrText
        (itemtype => itemtype,
         itemkey  => itemkey,
         aname    => 'HR_SALBASISCHG_PAYROLL_COMMENT',
         avalue   => lv_prev_payroll_comment ||
                     wf_engine.GetItemAttrText (itemtype      => itemtype,
                                                itemkey       => itemkey,
                                                aname         => 'WF_NOTE'));
      --
      resultout := 'COMPLETE:';
   ELSE
      NULL;
   END IF;
--

--
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package
                   ,'copy_payroll_comment'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    RAISE;
end copy_payroll_comment;
--

-------------------------------------------------------------------------------
---------   function get_item_type  --------------------------------------------

----------  private function to get item type for current transaction ---------
-------------------------------------------------------------------------------
function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_type    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.item_type
    into c_item_type
    from hr_api_transactions t
    where transaction_id=get_item_type.p_transaction_id;
  exception
    when no_data_found then
     -- get the data from the steps
     if g_debug then
      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
     select ts.item_type
     into get_item_type.c_item_type
     from hr_api_transaction_steps ts
     where ts.transaction_id=get_item_type.p_transaction_id
     and ts.item_type is not null and rownum <=1;
  end;

return c_item_type;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_type',p_transaction_id);
    RAISE;

end get_item_type;



-------------------------------------------------------------------------------
---------   function get_item_key  --------------------------------------------
----------  private function to get item key for current transaction ---------
-------------------------------------------------------------------------------

function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_key    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.item_key
    into get_item_key.c_item_key
    from hr_api_transactions t
    where transaction_id=get_item_key.p_transaction_id;
  exception
    when no_data_found then
     -- get the data from the steps
     if g_debug then
      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
     end if;
     select ts.item_key
     into get_item_key.c_item_key
     from hr_api_transaction_steps ts
     where ts.transaction_id=get_item_key.p_transaction_id
     and ts.item_type is not null and rownum <=1;
  end;

return get_item_key.c_item_key;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_key',p_transaction_id);
    RAISE;

end get_item_key;

function get_process_name
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_process_name varchar2(100);
c_item_type    varchar2(50);
c_item_key     varchar2(100);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);
c_process_name := wf_engine.GetItemAttrText (itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname    => 'PROCESS_NAME');
return c_process_name;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_process_name',c_item_type,c_item_key);
    RAISE;
end get_process_name ;

function get_approval_level
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is

c_approval_level number;
c_item_type    varchar2(50);
c_item_key     varchar2(100);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);

c_approval_level := wf_engine.GetItemAttrNumber (itemtype => c_item_type ,
                                                 itemkey  => c_item_key ,
                                                 aname => 'APPROVAL_LEVEL');
return c_approval_level;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_approval_level',c_item_type,c_item_key);
    RAISE;


end get_approval_level ;



function get_effective_date
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return date is
c_effective_date date;
c_item_type    varchar2(50);
c_item_key     varchar2(100);
begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);

c_effective_date := wf_engine.GetItemAttrDate(itemtype => c_item_type ,
                                              itemkey => c_item_key,
                                              aname => 'CURRENT_EFFECTIVE_DATE');

return c_effective_date;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_effective_date',c_item_type,c_item_key);
    RAISE;


end get_effective_date;

function get_assignment_id
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number is
c_assignment_id number;
c_item_type    varchar2(50);
c_item_key     varchar2(100);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);

c_assignment_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CURRENT_ASSIGNMENT_ID');
return c_assignment_id;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_assignment_id',c_item_type,c_item_key);
    RAISE;


end get_assignment_id ;



-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
-- This procedure confirms to the Workflow API specification standards.
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
as
-- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_creator_person_id     per_people_f.person_id%type;
  l_forward_from_person_id    per_people_f.person_id%type;
  l_forward_from_username     wf_users.name%type;
  l_forward_from_disp_name    wf_users.display_name%type;
  l_forward_to_person_id      per_people_f.person_id%type;
  l_forward_to_username       wf_users.name%type;
  l_forward_to_disp_name      wf_users.display_name%type;
  l_proc_name                 varchar2(61) := g_package||'get_next_approver';
  l_current_forward_to_id     per_people_f.person_id%type;
  l_current_forward_from_id   per_people_f.person_id%type;

-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;

v_approvalprocesscompleteynout varchar2(5);
v_next_approver_rec ame_util.approverstable2;

begin

--

if ( funmode = 'RUN' ) then

-- get the current forward from person
    l_current_forward_from_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'FORWARD_FROM_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));
    -- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => itemtype
            ,itemkey  => itemkey
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));





c_application_id :=wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_APP_ID_ATTR');

c_application_id := nvl(c_application_id,800);



c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'TRANSACTION_ID');



c_transaction_type := wf_engine.GetItemAttrText(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


/*
ame_api.getNextApprover(applicationIdIn =>c_application_id,
                        transactionIdIn =>c_transaction_id,
                        transactionTypeIn =>c_transaction_type,
                        nextApproverOut =>c_next_approver_rec); */

ame_api2.getNextApprovers4
	    (applicationIdIn  => c_application_id
	    ,transactionTypeIn => c_transaction_type
	    ,transactionIdIn => c_transaction_id
	    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
	    ,approvalProcessCompleteYNOut => v_approvalprocesscompleteynout
	    ,nextApproversOut => v_next_approver_rec);
--
    -- set the next forward to
    --
    if(v_approvalprocesscompleteynout<>'Y') then
	l_forward_to_person_id := v_next_approver_rec(1).orig_system_id;
   end if;


   if(l_forward_to_person_id is null) then
     result := 'COMPLETE:F';

   else
--
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_forward_to_person_id
          ,p_name           => l_forward_to_username
          ,p_display_name   => l_forward_to_disp_name);
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'FORWARD_TO_PERSON_ID'
          ,avalue      => l_forward_to_person_id);
        --
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_USERNAME'
          ,avalue   => l_forward_to_username);
        --
        Wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_DISPLAY_NAME'
          ,avalue   => l_forward_to_disp_name);
        --
        -- set forward from to old forward to
        --

       wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'FORWARD_FROM_PERSON_ID'
          ,avalue      => l_current_forward_to_id);
       --
       -- Get the username and display name for forward from person
       -- and save to item attributes
       --
       wf_directory.GetUserName
         (p_orig_system       => 'PER'
         ,p_orig_system_id    => l_current_forward_to_id
         ,p_name              => l_forward_from_username
         ,p_display_name      => l_forward_from_disp_name);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_USERNAME'
        ,avalue   => l_forward_from_username);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_DISPLAY_NAME'
        ,avalue   => l_forward_from_disp_name);
        --

      result := 'COMPLETE:T';

end if;

elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
end if;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.Get_Next_Approver',itemtype,itemkey,funmode);
    RAISE;


end Get_Next_Approver;


--
-- ------------------------------------------------------------------------
-- |------------------------< update_approval_status >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Update the status of the current approvers' approval notification
-- This procedure confirms to the Workflow API specification standards.
--
--
procedure update_approval_status (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     )
as

l_forward_to_person_id      per_people_f.person_id%type;

-- Variables required for AME API
c_application_id integer;
c_transaction_id varchar2(25);
c_transaction_type varchar2(25);
c_next_approver_rec ame_util.approverRecord;

l_current_forward_to_username   wf_users.name%type;

begin

--

if ( funmode = 'RUN' ) then

c_application_id :=wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_APP_ID_ATTR');

c_application_id := nvl(c_application_id,800);

c_transaction_id := wf_engine.GetItemAttrNumber(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'TRANSACTION_ID');



c_transaction_type := wf_engine.GetItemAttrText(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_AME_TRAN_TYPE_ATTR');


l_forward_to_person_id := wf_engine.GetItemAttrNumber
                                     (itemtype    => itemtype,
                                      itemkey     => itemkey,
                                      aname       => 'FORWARD_TO_PERSON_ID');
/*
ame_api.updateApprovalStatus2(applicationIdIn =>c_application_id,
                                  transactionIdIn =>c_transaction_id,
                                  approvalStatusIn =>ame_util.approvedStatus,
                                  approverPersonIdIn =>l_forward_to_person_id,
                                  approverUserIdIn =>null,
                                  transactionTypeIn =>c_transaction_type,
                                  forwardeeIn  =>null); */


l_current_forward_to_username:=   Wf_engine.GetItemAttrText(itemtype => itemtype
                                                                     ,itemkey  => itemkey
                                                                     ,aname    => 'FORWARD_TO_USERNAME');

l_current_forward_to_username := nvl(l_current_forward_to_username,wf_engine.GetItemAttrText(itemtype => itemtype ,
                                               itemkey => itemkey,
                                               aname   => 'RETURN_TO_USERNAME'));

   ame_api2.updateApprovalStatus2(applicationIdIn=>c_application_id,
	transactionTypeIn =>c_transaction_type,
	transactionIdIn=>c_transaction_id,
	approvalStatusIn =>ame_util.approvedStatus,
	approverNameIn =>l_current_forward_to_username,
	itemClassIn => null,
	itemIdIn =>null,
	actionTypeIdIn=> null,
	groupOrChainIdIn =>null,
	occurrenceIn =>null,
	forwardeeIn =>ame_util.emptyApproverRecord2,
	updateItemIn =>false);

elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
end if;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.update_approval_status',itemtype,itemkey,funmode);
    RAISE;



end update_approval_status;

-------------------------------------------------------------------------------
---------   function get_final_approver  --------------------------------------------
----------  Function to get the final approver from the supervisor chain for current transaction ---------
-------------------------------------------------------------------------------

function get_final_approver
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number
is
c_item_type    varchar2(50);
c_item_key     number;
c_creator_person_id per_all_people_f.person_id%type default null;
c_final_appprover_id per_all_people_f.person_id%type default null;
c_forward_to_person_id per_all_people_f.person_id%type default null;
lv_response varchar2(3);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

-- bug 4333335 begins
hr_approval_custom.g_itemtype := c_item_type;
hr_approval_custom.g_itemkey := c_item_key;
-- bug 4333335 ends

/*c_creator_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CREATOR_PERSON_ID');
*/
c_creator_person_id := getApprStartingPointPersonId(p_transaction_id);
c_final_appprover_id := c_creator_person_id;

lv_response := hr_approval_custom.Check_Final_approver(p_forward_to_person_id       => c_creator_person_id,
                                                       p_person_id                  => c_creator_person_id );


while lv_response='N' loop

  c_forward_to_person_id := hr_approval_custom.Get_Next_Approver(p_person_id =>c_final_appprover_id);

  c_final_appprover_id := c_forward_to_person_id;

  lv_response := hr_approval_custom.Check_Final_approver(p_forward_to_person_id       => c_forward_to_person_id,
                                                         p_person_id                  => c_creator_person_id );

 end loop;

return c_final_appprover_id;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_final_approver',c_item_type,c_item_key);
    RAISE;


end get_final_approver;



function allow_requestor_approval
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is

c_item_type    varchar2(50);
c_item_key     varchar2(100);
c_final_approver number;
c_creator_person_id number;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);
c_final_approver := get_final_approver(p_transaction_id);
/*c_creator_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CREATOR_PERSON_ID');
*/
c_creator_person_id := getApprStartingPointPersonId(p_transaction_id);
if(c_final_approver=c_creator_person_id) then
 return 'true';
else return 'false';
end if;


EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.allow_requestor_approval',c_item_type,c_item_key);
    RAISE;
end allow_requestor_approval ;

--
-- ------------------------------------------------------------------------
-- |------------------ < check_mid_pay_period_change > --------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if a mid pay period change was performed when a salary basis
--  was changed.  If yes, we need to set the WF item attribute
--  HR_MID_PAY_PERIOD_CHANGE ='Y' so that a notification will be sent to the
--  Payroll Contact.
--
--  This procedure is invoked by the WF HR_CHK_SAL_BASIS_MID_PAY_PERIOD process.
--
-- ------------------------------------------------------------------------
procedure check_mid_pay_period_change
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result         out nocopy varchar2 ) IS


l_assignment_id     per_all_assignments_f.assignment_id%type default null;
l_payroll_id        per_all_assignments_f.payroll_id%type default null;
l_old_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_new_pay_basis_id  per_all_assignments_f.pay_basis_id%type default null;
l_pay_period_start_date    date default null;
l_pay_period_end_date      date default null;

l_asg_txn_step_id          hr_api_transaction_steps.transaction_step_id%type
                           default null;
l_effective_date           date default null;


CURSOR csr_check_mid_pay_period(p_eff_date_csr   in date
                                 ,p_payroll_id_csr in number) IS
select start_date, end_date
from   per_time_periods
where  p_eff_date_csr > start_date
and    p_eff_date_csr <= end_date
and    payroll_id = p_payroll_id_csr;

-- The following cursor is copied from hr_transaction_ss.process_transaction.
CURSOR csr_trs is
select trs.transaction_step_id
      ,trs.api_name
      ,trs.item_type
      ,trs.item_key
      ,trs.activity_id
      ,trs.creator_person_id
from   hr_api_transaction_steps trs
where  trs.item_type = p_item_type
and    trs.item_key = p_item_key
order by trs.processing_order
            ,trs.transaction_step_id ; --#2313279
--

-- Get existing assignment data
CURSOR csr_get_old_asg_data IS
SELECT pay_basis_id
FROM   per_all_assignments_f
WHERE  assignment_id = l_assignment_id
AND    l_effective_date between effective_start_date
                            and effective_end_date
AND    assignment_type = 'E';


BEGIN
  IF ( funmode = 'RUN' )
  THEN

     -- Get the ASG and Pay Rate transaction step id
     FOR I in  csr_trs
     LOOP
        IF I.api_name = g_asg_api_name
        THEN
           l_asg_txn_step_id := I.transaction_step_id;
           EXIT;
        END IF;
     END LOOP;
 IF l_asg_txn_step_id IS NOT NULL
     THEN

        l_effective_date := to_date(
        hr_transaction_ss.get_wf_effective_date
          (p_transaction_step_id => l_asg_txn_step_id),
                        hr_transaction_ss.g_date_format);

        -- Get the pay_basis_id and payroll_id
        l_new_pay_basis_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAY_BASIS_ID');

        l_payroll_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_PAYROLL_ID');

        l_assignment_id := hr_transaction_api.get_number_value
           (p_transaction_step_id => l_asg_txn_step_id
           ,p_name                => 'P_ASSIGNMENT_ID');

        -- Now get the old pay basis id
        OPEN csr_get_old_asg_data;
        FETCH csr_get_old_asg_data into l_old_pay_basis_id;
        IF csr_get_old_asg_data%NOTFOUND
        THEN
           -- could be a new hire or applicant hire, there is no asg rec

CLOSE csr_get_old_asg_data;
        ELSE
           CLOSE csr_get_old_asg_data;
        END IF;

        IF l_old_pay_basis_id IS NOT NULL and
           l_new_pay_basis_id IS NOT NULL and
           l_old_pay_basis_id <> l_new_pay_basis_id and
           l_payroll_id IS NOT NULL
        THEN
           -- perform mid pay period check
           OPEN csr_check_mid_pay_period
              (p_eff_date_csr   => l_effective_date
              ,p_payroll_id_csr => l_payroll_id);
           FETCH csr_check_mid_pay_period into l_pay_period_start_date
                                             ,l_pay_period_end_date;
           IF csr_check_mid_pay_period%NOTFOUND
           THEN
              -- That means the effective date is not in mid pay period
              CLOSE csr_check_mid_pay_period;
              -- Need to set the item attribute to 'N' because this may be
              -- a Return For Correction and the value of the item attribute
              -- was set to 'Y' previously.
              wf_engine.setItemAttrText
                  (itemtype => p_item_type
                  ,itemkey  => p_item_key
                  ,aname    => g_mid_pay_period_change
                  ,avalue   => 'N');
           ELSE
              -- Only set the WF Item attribute HR_MID_PAY_PERIOD_CHANGE to
              -- 'Y' when there is payroll installed and the employee is not a
              -- new hire (ie. first time salary basis was entered).
              -- We determine New Hire by looking at the old db assignment rec
              -- pay_basis_id.  If that is null, then this is the first time
              -- salary basis was entered.  We don't need to perform the check
              -- because there is no element type changed.
              CLOSE csr_check_mid_pay_period;
              wf_engine.setItemAttrText
                  (itemtype => p_item_type
                  ,itemkey  => p_item_key
                  ,aname    => g_mid_pay_period_change
                  ,avalue   => 'Y');

              result := 'COMPLETE:'||'Y';

           END IF;
        END IF;
     ELSE
        result := 'COMPLETE:'||'N';
     END IF;   -- asg txn step is not null
  ELSIF ( funmode = 'CANCEL' ) then
     --
     NULL;
     --
  END IF;
END check_mid_pay_period_change;


--
-- ------------------------------------------------------------------------
-- |------------------ < apps_initialize > --------------------|
--  Method to initialize the session apps context if there is no context already
--  set.
--  The method checks the current session context userid ,
  -- If the userid is not same stored in the item attribute HR_USER_ID_ATTR
  -- then the  fnd_global.apps_initialize called with
 -- user id as stored in the item attribute HR_USER_ID_ATTR.
-- ------------------------------------------------------------------------


PROCEDURE apps_initialize
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
)
IS
l_user_id NUMBER;
l_resp_id NUMBER;
l_resp_appl_id NUMBER;
l_fnd_user_id  fnd_user.user_id%type default null;
l_session_user_id varchar2(100);
l_session_resp_id NUMBER;
BEGIN

  IF (p_funcmode = 'RUN' and wf_engine.GetItemAttrText(itemtype =>p_itemtype,
                                                     itemkey =>p_itemkey,
                                                     aname =>'HR_DEFER_COMMIT_ATTR',
                                                     ignore_notfound=>true)='Y'
                                                         ) THEN
    -- Code that compares current session context
    -- with the work item context required to execute
    -- the workflow safely
    l_session_user_id := FND_GLOBAL.USER_ID;
    l_session_resp_id := FND_GLOBAL.RESP_ID;
    l_fnd_user_id     := wf_engine.GetItemAttrNumber(itemtype =>p_itemtype,
                                                     itemkey =>p_itemkey,
                                                      aname =>'HR_USER_ID_ATTR',
                                                      ignore_notfound=>true);

    l_resp_id :=wf_engine.GetItemAttrNumber(itemtype =>p_itemtype,
                                             itemkey =>p_itemkey,
                                             aname =>'HR_RESP_ID_ATTR',
                                             ignore_notfound=>true);

    IF ((l_session_user_id = l_fnd_user_id) and (l_session_resp_id = l_resp_id)) then
        -- session already has proper values ignore reset
        p_result := 'COMPLETE';
    else
       -- HR_RESP_ID_ATTR
       l_resp_id :=wf_engine.GetItemAttrNumber(itemtype =>p_itemtype,
                                               itemkey =>p_itemkey,
                                               aname =>'HR_RESP_ID_ATTR',
                                               ignore_notfound=>true);
       -- HR_RESP_APPL_ID_ATTR
       l_resp_appl_id := wf_engine.GetItemAttrNumber(itemtype =>p_itemtype,
                                                     itemkey =>p_itemkey,
                                                     aname =>'HR_RESP_APPL_ID_ATTR',
                                                     ignore_notfound=>true);

       -- set the fnd session context with the last approver user id
       fnd_global.apps_initialize(user_id =>l_fnd_user_id,
                                  resp_id =>l_resp_id,
                                  resp_appl_id=> l_resp_appl_id);


       p_result := 'COMPLETE';
    end if;
ELSE
   p_result := 'COMPLETE';
END IF;

EXCEPTION
WHEN OTHERS THEN NULL;
WF_CORE.Context(g_package, '.apps_initialize',
p_itemtype, p_itemkey, p_actid, p_funcmode);
RAISE;
END apps_initialize;

--
-- ------------------------------------------------------------------------
-- |------------------ < defer_commit > --------------------|
--  Method to read profile value (HR_DEFER_UPDATE)
--  and branch the workflow accordingly.
-- ------------------------------------------------------------------------
procedure defer_commit
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_act_id       in number,
              funmode        in varchar2,
              result         in out  nocopy varchar2 ) is
	-- userid
	l_defer_commit  fnd_lookups.lookup_code%type;

  begin
	IF ( funmode = 'RUN' )
	  THEN
	  -- get the profile value
	  -- HR_DEFER_UPDATE
	  -- Oracle Human Resources
	  -- HR:Defer Update After Approval
	     fnd_profile.get(name=>'HR_DEFER_UPDATE',val=>l_defer_commit);
	   if    l_defer_commit = 'N' then
	        -- Commit immediately
		hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'HR_DEFER_COMMIT_ATTR');

               wf_engine.SetItemAttrText(itemtype =>p_item_type,
                                  itemkey =>p_item_key,
                                  aname =>'HR_DEFER_COMMIT_ATTR',
                                  avalue      => 'N' );
	        result := 'COMPLETE:'|| 'N';
	   else
	        -- Defer commit.
		-- get the current login user id and populate it into item attribute HR_USER_ID_ATTR
		--
        hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'HR_USER_ID_ATTR');
        wf_engine.SetItemAttrNumber (itemtype   => p_item_type,
                                     itemkey     => p_item_key,
                                     aname       => 'HR_USER_ID_ATTR',
                                     avalue      => FND_GLOBAL.USER_ID ) ;
        -- get the resp_id,  FND_GLOBAL.RESP_ID
        hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'HR_RESP_ID_ATTR');
        wf_engine.SetItemAttrNumber (itemtype   => p_item_type,
                                     itemkey     => p_item_key,
                                     aname       => 'HR_RESP_ID_ATTR',
                                     avalue      => FND_GLOBAL.RESP_ID ) ;

        -- get resp_appl_id ,  FND_GLOBAL.RESP_APPL_ID
        hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'HR_RESP_APPL_ID_ATTR');
        wf_engine.SetItemAttrNumber (itemtype   => p_item_type,
                                     itemkey     => p_item_key,
                                     aname       => 'HR_RESP_APPL_ID_ATTR',
                                     avalue      => FND_GLOBAL.RESP_APPL_ID ) ;
       hr_approval_wf.create_item_attrib_if_notexist
                               (p_item_type  => p_item_type
                               ,p_item_key   => p_item_key
                               ,p_name   => 'HR_DEFER_COMMIT_ATTR');

        wf_engine.SetItemAttrText(itemtype =>p_item_type,
                                  itemkey =>p_item_key,
                                  aname =>'HR_DEFER_COMMIT_ATTR',
                                  avalue      => 'Y' );
            result := 'COMPLETE:'|| 'Y';
	     end if;

	END IF;

   EXCEPTION
   WHEN OTHERS THEN
	 WF_CORE.CONTEXT(g_package,'.defer_commit',p_item_type,p_item_key);
    RAISE;

  END defer_commit;


/*
  Methods added to provide java wrapper to WF_ENGINE API's, may be obsoleted
  once the Java interface for them is provided. These new procedures are with
  new signature adding the boolean parameter ignore_notfound.

*/

function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in varchar2 default 'FALSE')
return varchar2 is
c_proc  varchar2(30) default 'GetActivityAttrText';


begin
  g_debug := hr_utility.debug_enabled;

 if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;


  if(ignore_notfound='TRUE') then
   if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrText  ', 2);
    end if;
     return WF_ENGINE.GetActivityAttrText(itemtype=>itemtype,
				 itemkey=>itemkey,
				 actid=>actid,
				 aname=>aname,
				 ignore_notfound=>TRUE);
  elsif (ignore_notfound='FALSE') then
     if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrText  ', 2);
     end if;

     return WF_ENGINE.GetActivityAttrText(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 actid=>actid,
                                 aname=>aname,
                                 ignore_notfound=>FALSE);
  else
    return null;
  end if;
exception
when others then
    Wf_Core.Context('hr_workflow_ss', 'GetActivityAttrText', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrText;


function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in varchar2 default 'FALSE')
return date is
c_proc  varchar2(30) default 'GetActivityAttrDate';

begin
   g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  if(ignore_notfound='TRUE') then
     if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrDate  ', 2);
    end if;
     return WF_ENGINE.GetActivityAttrDate(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 actid=>actid,
                                 aname=>aname,
                                 ignore_notfound=>TRUE);
  elsif (ignore_notfound='FALSE') then
      if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrDate  ', 2);
     end if;
     return WF_ENGINE.GetActivityAttrDate(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 actid=>actid,
                                 aname=>aname,
                                 ignore_notfound=>FALSE);
  else
    return null;
  end if;
exception
when others then
    Wf_Core.Context('hr_workflow_ss', 'GetActivityAttrDate', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrDate;




function GetActivityAttrNumber(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in varchar2 default 'FALSE')
return number is
c_proc  varchar2(30) default 'GetActivityAttrNumber';

begin
  g_debug := hr_utility.debug_enabled;

 if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  if(ignore_notfound='TRUE') then
      if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrNumber  ', 2);
      end if;
     return WF_ENGINE.GetActivityAttrNumber(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 actid=>actid,
                                 aname=>aname,
                                 ignore_notfound=>TRUE);
  elsif (ignore_notfound='FALSE') then
     if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetActivityAttrNumber  ', 2);
      end if;

     return WF_ENGINE.GetActivityAttrNumber(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 actid=>actid,
                                 aname=>aname,
                                 ignore_notfound=>FALSE);
  else
    return null;
  end if;
exception
when others then
    Wf_Core.Context('hr_workflow_ss', 'GetActivityAttrNumber', itemtype, itemkey,
                    to_char(actid), aname);
    raise;
end GetActivityAttrNumber;

PROCEDURE getPageDetails
             (p_item_type    in varchar2,
              p_item_key     in varchar2,
              p_activityId   out nocopy  number,
              p_page         out nocopy varchar2,
              p_page_type    out nocopy  varchar2,
              p_page_applicationId out nocopy  varchar2,
              p_additional_params out nocopy  varchar2 )is
	-- local variables
    lv_procedure_name varchar2(30) default 'getPageDetails';
    ln_activityId wf_item_activity_statuses.process_activity%type;
    lv_page  wf_item_attribute_values.text_value%type;
    lv_page_type  wf_item_attribute_values.text_value%type;
    ln_page_applicationId wf_item_attribute_values.number_value%type;
    lv_additional_params  wf_item_attribute_values.text_value%type;
 BEGIN
  hr_utility.set_location(lv_procedure_name,1);
  if(hr_utility.debug_enabled) then
    -- write debug statements
    hr_utility.set_location('Entered'||lv_procedure_name||'with itemtype:'||p_item_type, 2);
    hr_utility.set_location('Entered'||lv_procedure_name||'with itemkey:'||p_item_key, 2);
  end if;
  -- get the activity id for blocked page activity
  -- activity used for page should have activity attribute
  -- of type 'FORM'
     begin
       if(hr_utility.debug_enabled) then
        -- write debug statements
        hr_utility.set_location('Querying WF_ITEM_ACTIVITY_STATUSES for notified activity of type FORM'||lv_procedure_name||'with itemtype:', 3);
       end if;

       -- Fix for bug 3719338
       SELECT process_activity
       into ln_activityId
       from
           (select process_activity
            FROM   WF_ITEM_ACTIVITY_STATUSES IAS
             WHERE  ias.item_type          = p_item_type
               and    ias.item_key           = p_item_key
               and    ias.activity_status    = 'NOTIFIED'
               and    ias.process_activity   in (
                                                 select  wpa.instance_id
                                                 FROM    WF_PROCESS_ACTIVITIES     WPA,
                                                         WF_ACTIVITY_ATTRIBUTES    WAA,
                                                         WF_ACTIVITIES             WA,
                                                         WF_ITEMS                  WI
                                                 WHERE   wpa.process_item_type   = ias.item_type
                                                 and     wa.item_type           = wpa.process_item_type
                                                 and     wa.name                = wpa.activity_name
                                                 and     wi.item_type           = ias.item_type
                                                 and     wi.item_key            = ias.item_key
                                                 and     wi.begin_date         >= wa.begin_date
                                                 and     wi.begin_date         <  nvl(wa.end_date,wi.begin_date+1)
                                                 and     waa.activity_item_type  = wa.item_type
                                                 and     waa.activity_name       = wa.name
                                                 and     waa.activity_version    = wa.version
                                                 and     waa.type                = 'FORM'
                                               )
            order by begin_date desc)
      where rownum<=1;

     exception
     when no_data_found then
           if(hr_utility.debug_enabled) then
          -- write debug statements
           hr_utility.set_location('no notified activity found in WF_ITEM_ACTIVITY_STATUSES of type FORM for itemtype:'|| p_item_type||' and item key:'||p_item_key, 4);
          end if;
      ln_activityId := null;
     when others then
       ln_activityId := null;
       fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
       hr_utility.raise_error;
     end;

     if(ln_activityId is not null) then
       -- we have a blocked page activity in the wf root process
       -- get the activity attribute values
       if(hr_utility.debug_enabled) then
         -- write debug statements
         hr_utility.set_location('getting activity attributes for activity id:'||ln_activityId ||', itemtype:'|| p_item_type||' and item key:'||p_item_key, 5);
       end if;
      lv_page     := wf_engine.GetActivityAttrText(
                            itemtype    => p_item_type
                           ,itemkey     => p_item_key
                           ,actid       => ln_activityId
                           ,aname       => 'HR_ACTIVITY_TYPE_VALUE' );
      lv_page_type := wf_engine.GetActivityAttrText(
                            itemtype    => p_item_type
                           ,itemkey     => p_item_key
                           ,actid       => ln_activityId
                           ,aname       => 'HR_ACTIVITY_TYPE' );
      -- 'APPLICATION_ID'
      ln_page_applicationId :=nvl( wf_engine.GetActivityAttrText(
                            itemtype    => p_item_type
                           ,itemkey     => p_item_key
                           ,actid       => ln_activityId
                           ,aname       => 'APPLICATION_ID'
                           ,ignore_notfound=>true),'800');


      -- get the additional params
      -- 'P_CALLED_FROM' and ???
      lv_additional_params := wf_engine.getitemattrtext(
                                           itemtype    => p_item_type
                                           ,itemkey     => p_item_key
                                           ,aname       => 'P_CALLED_FROM' );

       p_activityId   :=ln_activityId;
       p_page         :=lv_page;
       p_page_type    := lv_page_type;
       p_page_applicationId :=ln_page_applicationId;
       p_additional_params := lv_additional_params;
     else
       -- there is no blocked page activity, check for additional details
       if(hr_utility.debug_enabled) then
         -- write debug statements
         hr_utility.set_location(' itemtype:'|| p_item_type||' and item key:'||p_item_key, 6);
         p_activityId   :='0'; -- fix for bug 3823494
       end if;
     end if;

   if(hr_utility.debug_enabled) then
     -- write debug statements
     hr_utility.set_location('Leaving '||lv_procedure_name||'with itemtype:'||p_item_type, 10);
   end if;

 EXCEPTION
 WHEN OTHERS THEN
	fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
    hr_utility.raise_error;
 END getPageDetails;

function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2,
                         ignore_notfound in varchar2 default 'FALSE')
return varchar2 is
c_proc  varchar2(30) default 'GetItemAttrText';


begin
  g_debug := hr_utility.debug_enabled;

 if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;


  if(ignore_notfound='TRUE') then
   if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetItemAttrText  ', 2);
    end if;
     return WF_ENGINE.GetItemAttrText(itemtype=>itemtype,
				 itemkey=>itemkey,
				 aname=>aname,
				 ignore_notfound=>TRUE);
  elsif (ignore_notfound='FALSE') then
     if g_debug then
      hr_utility.set_location('calling WF_ENGINE.GetItemAttrText  ', 2);
     end if;

     return WF_ENGINE.GetItemAttrText(itemtype=>itemtype,
                                 itemkey=>itemkey,
                                 aname=>aname,
                                 ignore_notfound=>FALSE);
  else
    return null;
  end if;
exception
when others then
    Wf_Core.Context('hr_workflow_ss', 'GetItemAttrText', itemtype, itemkey,
                     aname);
    raise;
end GetItemAttrText;

PROCEDURE get_item_type_and_key (
              p_ntfId       IN NUMBER
             ,p_itemType   OUT NOCOPY VARCHAR2
             ,p_itemKey    OUT NOCOPY VARCHAR2 ) IS
c_proc  varchar2(30) default 'get_item_type_and_key';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
lv_activity_id wf_item_activity_statuses.process_activity%type;
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  -- get the itemtype and item key for the notification id
  begin
    select item_type, item_key, process_activity
      into lv_item_type, lv_item_key,lv_activity_id
      from wf_item_activity_statuses
     where notification_id = p_ntfid;
  exception
    when no_data_found then
      begin
         -- try getting from the notification context
         select substr(context,1,instr(context,':',1)-1)
          ,substr(context,instr(context,':')+1, ( instr(context,':',instr(context,':')+1 ) - instr(context,':')-1) )
         into  lv_item_type, lv_item_key
         from   wf_notifications
         where  notification_id   = p_ntfid;
      exception
        when no_data_found then
            hr_utility.set_location('Error in '|| g_package||'.'||c_proc ||SQLERRM ||' '||to_char(SQLCODE), 20);
            raise;
        when others then
	  raise;
     end;
     when others then
	raise;

   end;
p_itemType := lv_item_type;
p_itemKey  :=  lv_item_key;

exception
when others then
    hr_utility.set_location('hr_workflow_ss.get_item_type_and_key errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context('hr_workflow_ss', 'get_item_type_and_key', p_ntfId);
    raise;
end get_item_type_and_key;

procedure build_edit_link(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2) is
c_proc  varchar2(30) default 'GetItemAttrText';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
lv_checkProfile   VARCHAR2(10);
lv_profileValue   VARCHAR2(1);
lv_status         hr_api_transactions.status%type;
lv_link_label wf_message_attributes_vl.display_name%type;
lv_pageFunc       wf_item_attribute_values.text_value%type;
lv_web_html_call  fnd_form_functions_vl.web_html_call%type;
lv_params         fnd_form_functions_vl.parameters%type;
lv_addtnlParams   VARCHAR2(30)  ;
lv_restrict_edit_to_owner varchar2(3);
-- fix for bug#3333763
lv_ntf_role      WF_NOTIFICATIONS.RECIPIENT_ROLE%type;
lv_ntf_msg_typ   WF_NOTIFICATIONS.MESSAGE_TYPE%type;
lv_ntf_msg_name  WF_NOTIFICATIONS.MESSAGE_NAME%type;
lv_ntf_prior     WF_NOTIFICATIONS.PRIORITY%type;
lv_ntf_due       WF_NOTIFICATIONS.DUE_DATE%type;
lv_ntf_status    WF_NOTIFICATIONS.STATUS%type;

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

-- fix for bug#3333763
-- check the status of the notification before doing any iterations.
-- Get notification recipient and status
  Wf_Notification.GetInfo(document_id, lv_ntf_role, lv_ntf_msg_typ, lv_ntf_msg_name, lv_ntf_prior, lv_ntf_due, lv_ntf_status);

  if (lv_ntf_status <> 'OPEN') then
    -- no more iteration return
    document :=null;
    document_type:=null;
    return;
  end if;

  -- get the itemtype and item key for the notification id
     hr_workflow_ss.get_item_type_and_key(document_id,lv_item_type,lv_item_key);

  -- check if the workflow process has been configured to
  --restrict edit to transaction owner/creator
  -- HR_RESTRICT_EDIT_ATTR
     if g_debug then
       hr_utility.set_location('querying wf_engine.GetItemAttrText for HR_RESTRICT_EDIT_ATTR with itemtype:itemkey '||lv_item_type||':'||lv_item_key, 2);
     end if;

     lv_restrict_edit_to_owner :=wf_engine.GetItemAttrText(itemtype=>lv_item_type,
		                                           itemkey=>lv_item_key,
                                       			   aname=>'HR_RESTRICT_EDIT_ATTR',
                                 			   ignore_notfound=>TRUE);
     if g_debug then
	hr_utility.set_location('HR_RESTRICT_EDIT_ATTR value:'||lv_restrict_edit_to_owner,3);
     end if;

     if(lv_restrict_edit_to_owner='Y') then
        hr_utility.set_location('process configured to restrict edit to owner/creator, no edit so returning',4);
       -- get the current login user name and compare with the creator user name
       if(fnd_global.USER_NAME=wf_engine.GetItemAttrText(itemtype=>lv_item_type,
                                                         itemkey=>lv_item_key,
                                                         aname=>'CREATOR_PERSON_USERNAME',
                                 			 ignore_notfound=>TRUE))then
        null;
       else
       -- no more iteration return
       document :=null;
       document_type:=null;
       return;
       end if;
     end if;

  -- get the hr_api_transaction.status and profile value
     begin
       select  nvl(status,'N'), nvl(fnd_profile.value('PQH_ALLOW_APPROVER_TO_EDIT_TXN'),'N')
       into    lv_status,   lv_profileValue
       from     hr_api_transactions
       where    item_type   = lv_item_type
       and      item_key    = lv_item_key;
       exception
       when no_data_found then
       raise;
       end;
   -- No need to check profile option (i.e. must render edit link)
   -- in following cases
     IF (INSTR(lv_status,'S') > 0 OR lv_status IN ('RI','N','C','W') ) THEN
         lv_checkProfile := 'N';
     END IF;

     IF (lv_checkProfile = 'N' OR lv_profileValue ='Y' ) THEN
         -- get the translated display name for the url link
         begin
            select wma.display_name
             into   lv_link_label
             from   wf_notifications  wn, wf_message_attributes_vl  wma
             where  wn.notification_id  = document_id
             and    wn.message_name     = wma.message_name
             and    wma.message_type    = lv_item_type
             and    wma.name            = 'EDIT_TXN_URL';
          exception
          when others then
                lv_link_label:= 'EDIT_TXN_URL';
         end;

       -- build the url link
          --  get the link details
          --  get the item attribute holding the FND function name corresponding
          --  to the MDS document.
          lv_pageFunc :=  nvl(wf_engine.GetItemAttrText(lv_item_type,lv_item_key,'HR_OAF_EDIT_URL_ATTR',TRUE),'PQH_SS_EFFDATE');
          -- get the web_html_call value and params for this function
          begin
            select web_html_call,parameters
            into lv_web_html_call,lv_params
            from fnd_form_functions_vl
            where function_name=lv_pageFunc;
          exception
          when no_data_found then
             hr_utility.set_location('Unable to retrieve function details,web_html_call and parameters for:'||lv_pageFunc||' '|| g_package||'.'||c_proc, 10);
          when others then
           raise;
       end;
        -- set the out variables
	lv_addtnlParams := '&'||'retainAM=Y'||'&'||'NtfId='||'&'||'#NID';
          document :=  '<tr><td> '||
            '<IMG SRC="'||g_oa_media||'afedit.gif"/>'||
            '</td><td>'||
            '<a class="OraLinkText" href='||g_oa_html||lv_web_html_call||lv_params||lv_addtnlParams||'>'
            ||lv_link_label||'</a></td></tr> ';
         -- set the document type
          document_type  := wf_notification.doc_html;

     else
        document := null;
     end if;

 if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
 end if;

exception
when others then
    document := null;
    document_type  :=null;
    hr_utility.set_location('hr_workflow_ss.build_edit_link errored : '||SQLERRM ||' '||to_char(SQLCODE), 20);
    Wf_Core.Context('hr_workflow_ss', 'build_edit_link', document_id, display_type);
    raise;
end build_edit_link;



function GetAttrNumber (nid in number,
                      aname in varchar2,
                      ignore_notfound in varchar2 default 'FALSE')
return number is
  c_proc  varchar2(30) default 'GetAttrNumber';
  lvalue wf_notification_attributes.NUMBER_VALUE%type;
begin
 g_debug := hr_utility.debug_enabled;

 if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  begin
    if g_debug then
      hr_utility.set_location('querying wf_notification_attributes.number_value for aname:nid'||aname||':'||nid, 2);
    end if;
    select WNA.NUMBER_VALUE
    into   lvalue
    from   WF_NOTIFICATION_ATTRIBUTES WNA
    where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
  exception
    when no_data_found then
     if(ignore_notfound='TRUE') then
       return null;
     else
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
     end if;
  end;

  return(lvalue);
exception
  when others then
    wf_core.context('hr_workflow_ss', 'GetAttrNumber', to_char(nid), aname);
    hr_utility.set_location('Error querying wf_notification_attributes.NUMBER_VALUE for aname:nid'||aname||':'||nid||'-'||SQLERRM ||' '||to_char(SQLCODE), 10);
    raise;
end GetAttrNumber;

function GetAttrText (nid in number,
                      aname in varchar2,
                      ignore_notfound in varchar2 default 'FALSE')
return varchar2 is
  c_proc  varchar2(30) default 'GetAttrText';
  lvalue wf_notification_attributes.text_value%type;
begin
 g_debug := hr_utility.debug_enabled;

 if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;
  if ((nid is null) or (aname is null)) then
    wf_core.token('NID', to_char(nid));
    wf_core.token('ANAME', aname);
    wf_core.raise('WFSQL_ARGS');
  end if;

  begin
    if g_debug then
      hr_utility.set_location('querying wf_notification_attributes.text_value for aname:nid'||aname||':'||nid, 2);
    end if;
    select WNA.TEXT_VALUE
    into   lvalue
    from   WF_NOTIFICATION_ATTRIBUTES WNA
    where  WNA.NOTIFICATION_ID = nid and WNA.NAME = aname;
  exception
    when no_data_found then
     if(ignore_notfound='TRUE') then
       return null;
     else
      wf_core.token('NID', to_char(nid));
      wf_core.token('ATTRIBUTE', aname);
      wf_core.raise('WFNTF_ATTR');
     end if;
  end;

  return(lvalue);
exception
  when others then
    wf_core.context('hr_workflow_ss', 'GetAttrText', to_char(nid), aname);
    hr_utility.set_location('Error querying wf_notification_attributes.text_value for aname:nid'||aname||':'||nid||'-'||SQLERRM ||' '||to_char(SQLCODE), 10);
    raise;
end GetAttrText;

function getApprStartingPointPersonId
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number
is
c_item_type    varchar2(50);
c_item_key     number;
c_creator_person_id per_all_people_f.person_id%type default null;
lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
lv_transaction_ref_id hr_api_transactions.transaction_ref_id%type;

begin
   -- get the creator person_id from hr_api_transactions
   -- this would be the default  for all SSHR approvals.
   begin
     select hr_api_transactions.creator_person_id
     into c_creator_person_id
     from hr_api_transactions
     where hr_api_transactions.transaction_id=getApprStartingPointPersonId.p_transaction_id;
   exception
   when others then
       raise;
   end;

   -- if the transaction is for appraisal we need go through
   -- Main Appraiser chain for approvals.
   begin
      select hr_api_transactions.transaction_ref_table,hr_api_transactions.transaction_ref_id
      into lv_transaction_ref_table,lv_transaction_ref_id
      from hr_api_transactions
      where hr_api_transactions.transaction_id=getApprStartingPointPersonId.p_transaction_id;

      if(lv_transaction_ref_table='PER_APPRAISALS') then
        begin
          select per_appraisals.main_appraiser_id
          into c_creator_person_id
          from per_appraisals
          where per_appraisals.appraisal_id=getApprStartingPointPersonId.lv_transaction_ref_id;
        exception
        when others then
          -- do not raise, return
          null;
        end;
      end if;
   exception
   when others then
        hr_utility.trace(' exception in checking the hr_api_transactions.transaction_ref_table:'||
                             'rollback_transaction'||' : ' || sqlerrm);
        -- just log the message no need to raise it
   end;

return c_creator_person_id;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.getApprStartingPointPersonId',c_item_type,c_item_key);
    RAISE;
end getApprStartingPointPersonId;


procedure updateSFLTransaction (itemtype    in varchar2,
                                itemkey     in varchar2,
				actid       in number,
				funmode     in varchar2,
				result      out nocopy varchar2 )
as
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  c_proc  varchar2(30) default 'updateSFLTransaction';
  dynamicQuery varchar2(4000) default null;
  queryProcedure varchar2(4000) default 'pqh_ss_workflow.set_transaction_status';
  actionStatus varchar2(3) default 'SFL';
  begin
   g_debug := hr_utility.debug_enabled;

  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
  end if;

   -- fix for bug 4454439
    begin

      -- re-intialize the performer roles
      hr_approval_ss.reinitperformerroles(p_notification_id=>null
                                          ,p_transaction_id=>null
                                          ,p_item_type=>itemtype
                                          ,p_item_key=>itemKey);
    exception
    when others then
      null;
    end;


  if ( funmode = wf_engine.eng_run ) then
    --  code to update status and history
    if g_debug then
      hr_utility.set_location('Calling queryProcedure: '||queryProcedure, 20);
      hr_utility.set_location('itemType: '|| itemType, 21);
      hr_utility.set_location('itemKey: '|| itemKey, 22);
      hr_utility.set_location('actId: '|| actId, 23);
    end if;

    dynamicQuery :=
        'begin ' ||
        queryProcedure ||
        '(:itemTypeIn, :itemKeyIn, :actIdIn, :actionStatusIn, :resultOut); end;';
      execute immediate dynamicQuery
        using
          in itemType,
          in itemKey,
          in actId,
          in actionStatus,
          out result;
    if g_debug then
      hr_utility.set_location('After queryProcedure: '||queryProcedure, 40);
      hr_utility.set_location('result: '|| result, 41);
    end if;


  --
  elsif ( funmode = wf_engine.eng_cancel ) then
    --
    if g_debug then
      hr_utility.set_location(g_package ||'.updateSFLTransaction called in funmode:'||funmode, 50);
      hr_utility.set_location('itemType: '|| itemType, 51);
      hr_utility.set_location('itemKey: '|| itemKey, 52);
      hr_utility.set_location('actId: '|| actId, 53);
    end if;
  end if;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT(g_package,'.updateSFLTransaction',itemtype,itemkey,funmode);
      hr_utility.set_location(''||SQLERRM ||' '||to_char(SQLCODE), 100);
      RAISE;


end updateSFLTransaction;

function getProcessDisplayName(itemtype    in varchar2,
                               itemkey     in varchar2)
			       return wf_runnable_processes_v.display_name%type
is
  lv_display_name wf_runnable_processes_v.display_name%type;
  c_proc  varchar2(30) default 'getProcessDisplayName';

  lv_ntf_sub_msg           wf_item_attribute_values.text_value%type;

begin
    if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
    end if;
    if g_debug then
       hr_utility.set_location('Querying wf_runnable_processes_v',11);
       hr_utility.set_location('ItemType:'||itemtype,12);
       hr_utility.set_location('ItemKey:'||itemkey,13);
    end if;

   begin
      lv_ntf_sub_msg := wf_engine.GetItemAttrText(itemtype => itemtype ,
                                               itemkey  => itemkey,
                                               aname => 'HR_NTF_SUB_FND_MSG_ATTR',
                                               ignore_notfound=>true);
     if(lv_ntf_sub_msg is null) then
       SELECT wrpv.display_name displayName
       into getProcessDisplayName.lv_display_name
       FROM   wf_runnable_processes_v wrpv
       WHERE wrpv.item_type = itemtype
       AND wrpv.process_name = wf_engine.GetItemAttrText (itemtype,itemkey,'PROCESS_NAME')
       AND rownum <=1;
     else
       fnd_message.set_name('PER',lv_ntf_sub_msg);
       getProcessDisplayName.lv_display_name := fnd_message.get;
     end if;

   exception
     when others then
       getProcessDisplayName.lv_display_name := itemtype||':'||itemkey;
   end;
   if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 20);
   end if;

   return   getProcessDisplayName.lv_display_name;
   exception
   when others then
     raise;
end getProcessDisplayName;


procedure getProcessDisplayName(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2)
is
c_proc  varchar2(30) default 'getProcessDisplayName';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

     if g_debug then
       hr_utility.set_location('Calling hr_workflow_ss.get_item_type_and_key for NtfId:'||document_id, 11);
     end if;
-- get the itemtype and item key for the notification id
     hr_workflow_ss.get_item_type_and_key(document_id,lv_item_type,lv_item_key);
-- set the document type
     document_type  := wf_notification.doc_html;
-- set the document
     if g_debug then
       hr_utility.set_location('Calling getProcessDisplayName',12);
       hr_utility.set_location('ItemType:'||lv_item_type,13);
       hr_utility.set_location('ItemKey:'||lv_item_key,14);
     end if;
     document := hr_workflow_ss.getProcessDisplayName(lv_item_type,lv_item_key);

if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
 end if;

exception
when others then
    document  :=null;
    hr_utility.set_location('hr_workflow_ss.getProcessDisplayName errored : '||SQLERRM ||' '||to_char(SQLCODE), 20);
    Wf_Core.Context('hr_workflow_ss', 'getProcessDisplayName', document_id, display_type);
    raise;
end getProcessDisplayName;


procedure getApprovalMsgSubject(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2)
is
c_proc  varchar2(30) default 'getApprovalMsgSubject';
lv_item_type wf_item_activity_statuses.item_type%type;
lv_item_key wf_item_activity_statuses.item_key%type;
l_creator_person_id      per_people_f.person_id%type;
l_creator_disp_name      wf_users.display_name%type;
l_creator_username       wf_users.name%type;
l_current_person_id      per_people_f.person_id%type;
l_current_disp_name      wf_users.display_name%type;
l_current_username       wf_users.name%type;
lv_process_display_name wf_runnable_processes_v.display_name%type;
lv_ntf_sub_msg           wf_item_attribute_values.text_value%type;
lv_custom_callBack       varchar2(60);
l_sqlbuf  Varchar2(1000);

begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 10);
  end if;

  -- check if we have custom callback for the Approval Ntf subject
--
    begin
      lv_custom_callBack := hr_xml_util.get_node_value(
                              p_transaction_id => getattrnumber(document_id,'HR_TRANSACTION_REF_ID_ATTR','TRUE')
                             ,p_desired_node_value => 'ApprNtfSubCallBack'
                             ,p_xpath  => 'Transaction/TransCtx');
      If lv_custom_callBack is not null Then
        l_sqlbuf:= 'BEGIN ' || lv_custom_callBack
                 || ' (document_id => :1 '
                 || ' ,display_type => :2 '
                 || ' ,document => :3 '
                 || ' ,document_type =>  :4 ); END; ';
         EXECUTE IMMEDIATE l_sqlbuf using in document_id,
                                           in display_type,
                                           in out document,
                                           in out document_type;
       return;
      End If;
    exception
    when others then
       document  :=null;
       hr_utility.set_location('hr_workflow_ss.getApprovalMsgSubject errored  for custom call: '||SQLERRM ||' '||to_char(SQLCODE), 100);
       Wf_Core.Context('hr_workflow_ss', 'getApprovalMsgSubject', document_id, display_type);
       raise;
    end;



-- get the itemtype and item key for the notification id
     if g_debug then
       hr_utility.set_location('Calling hr_workflow_ss.get_item_type_and_key for NtfId:'||document_id, 11);
     end if;
     hr_workflow_ss.get_item_type_and_key(document_id,lv_item_type,lv_item_key);

-- get the process display name
   if g_debug then
       hr_utility.set_location('Calling getProcessDisplayName',12);
       hr_utility.set_location('ItemType:'||lv_item_type,13);
       hr_utility.set_location('ItemKey:'||lv_item_key,14);
   end if;
--   lv_process_display_name := hr_workflow_ss.getProcessDisplayName(lv_item_type,lv_item_key);

       lv_ntf_sub_msg := wf_engine.GetItemAttrText(itemtype => lv_item_type ,
                                               itemkey  => lv_item_key,
                                               aname => 'HR_NTF_SUB_FND_MSG_ATTR',
                                               ignore_notfound=>true);

   if(lv_ntf_sub_msg is null) then
     lv_process_display_name := hr_workflow_ss.getProcessDisplayName(lv_item_type,lv_item_key);
   else
      fnd_message.set_name('PER',lv_ntf_sub_msg);
      lv_process_display_name:= fnd_message.get;
   end if;


   l_creator_person_id:= wf_engine.GetItemAttrNumber
            (itemtype   => lv_item_type
            ,itemkey    => lv_item_key
            ,aname      => 'CREATOR_PERSON_ID');


  l_current_person_id:= wf_engine.GetItemAttrNumber
            (itemtype   => lv_item_type
            ,itemkey    => lv_item_key
            ,aname      => 'CURRENT_PERSON_ID');
  if g_debug then
       hr_utility.set_location('Creator_person_id:'||l_creator_person_id,15);
       hr_utility.set_location('Current_person_id:'||l_current_person_id,16);
   end if;
 if g_debug then
       hr_utility.set_location('Building subject for NtfId:'||document_id,17);
   end if;
 if(l_creator_person_id=l_current_person_id) then
      if g_debug then
        hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_creator_person_id,18);
      end if;

       -- get creator display name from role
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_creator_person_id
          ,p_name           => l_creator_username
          ,p_display_name   => l_creator_disp_name);

      if getOrganizationManagersubject(lv_item_type,lv_item_key) is not null then
        l_creator_disp_name := getOrganizationManagersubject(lv_item_type,lv_item_key) || ' (proposed by ' || l_creator_disp_name || ')';
      end if;
      -- Subject pattern
      -- "Change Job for Doe, John "
      if g_debug then
        hr_utility.set_location('Getting message HR_SS_APPROVER_MSG_SUB_SELF',19);
      end if;
      fnd_message.set_name('PER','HR_SS_APPROVER_MSG_SUB_SELF');
      fnd_message.set_token('PROCESS_DISPLAY_NAME',lv_process_display_name,false);
      fnd_message.set_token('CURRENT_PERSON_DISPLAY_NAME',l_creator_disp_name,false);
      document := fnd_message.get;

 else
 -- get creator display name from role
        if g_debug then
          hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_creator_person_id,20);
        end if;
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_creator_person_id
          ,p_name           => l_creator_username
          ,p_display_name   => l_creator_disp_name);

  -- get current person display name from role
        if g_debug then
        hr_utility.set_location('calling  wf_directory.GetUserName for person_id:'||l_current_person_id,21);
        end if;
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_current_person_id
          ,p_name           => l_current_username
          ,p_display_name   => l_current_disp_name);

  -- check if the username/wfrole is null or display name is null
      if(l_current_username is null OR l_current_disp_name is null) then
         -- To support name format, should not rely on the stored person name.
         -- Should rely on the person_id to get the name in correct format

         begin
             if l_current_person_id is not null then
                 l_current_disp_name := hr_person_name.get_person_name(l_current_person_id,sysdate );
             end if;
         exception
           when others then
           l_current_disp_name := null;
         end;

	 if(l_current_disp_name is null ) then
	  -- cud still be null if person doesnot exist in per_all_people_f as of now.
	   -- resort to the existing code of fetching from wf item attribute.
           l_current_disp_name := wf_engine.GetItemAttrText
                                           (itemtype   => lv_item_type
                                           ,itemkey    => lv_item_key
                                           ,aname      => 'CURRENT_PERSON_DISPLAY_NAME');
          end if;

      end if;

      -- Subject pattern
      -- "Change Job for Doe, John (proposed by Bond, James)"
      if g_debug then
        hr_utility.set_location('Getting message HR_SS_APPROVER_MSG_SUB_REPORTS',22);
      end if;

    fnd_message.set_name('PER','HR_SS_APPROVER_MSG_SUB_REPORTS');
    fnd_message.set_token('PROCESS_DISPLAY_NAME',lv_process_display_name,false);
    fnd_message.set_token('CURRENT_PERSON_DISPLAY_NAME',l_current_disp_name,false);
    fnd_message.set_token('CREATOR_PERSON_DISPLAY_NAME',l_creator_disp_name,false);
    document := fnd_message.get;
 end if;


-- set the document type
          document_type  := wf_notification.doc_html;

if g_debug then
    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);
 end if;

exception
when others then
    document  :=null;
    hr_utility.set_location('hr_workflow_ss.getApprovalMsgSubject errored : '||SQLERRM ||' '||to_char(SQLCODE), 40);
    Wf_Core.Context('hr_workflow_ss', 'getApprovalMsgSubject', document_id, display_type);
    raise;
end getApprovalMsgSubject;


function getNextApproverForHist(p_item_type    in varchar2, p_item_key     in varchar2) return varchar2
as
-- local variables
lv_procedure_name varchar2(30) default 'getNextApproverForHist';
ln_transaction_id  hr_api_transactions.transaction_id%TYPE;
ln_creator_person_id per_all_people_f.person_id%type default null;
ln_currentApprover_person_id      per_people_f.person_id%type;
ln_nextApprover_person_id      per_people_f.person_id%type;
ln_nextApprover_userName wf_users.name%type;
ln_nextApprover_dispName wf_users.display_name%type;
lv_last_approver_def        VARCHAR2(10) DEFAULT 'Y';
ln_last_default_approver_id per_people_f.person_id%type;
ln_current_approver_index   NUMBER ;
ln_curr_def_appr_index      NUMBER;
ln_addntl_approvers         NUMBER;
lv_exists                   VARCHAR2(10);
lv_dummy                    VARCHAR2(20);
lv_isvalid                  VARCHAR2(10);
lv_item_name                VARCHAR2(100) DEFAULT gv_item_name;
-- Variables for AME API
ln_application_id integer;
lv_transaction_id varchar2(25);
lv_transaction_type varchar2(25);
l_next_approver_rec ame_util.approverRecord;
l_default_approvers ame_util.approversTable;
l_foundApprLoc boolean default false;

v_approvalprocesscompleteynout varchar2(5);
v_next_approver_rec ame_util.approverstable2;
v_default_approvers  ame_util.approversTable2;

  begin
    hr_utility.set_location(lv_procedure_name,1);
    if(hr_utility.debug_enabled) then
      -- write debug statements
      hr_utility.set_location('Entered'||lv_procedure_name||'with itemtype:'||p_item_type, 2);
      hr_utility.set_location('Entered'||lv_procedure_name||'with itemkey:'||p_item_key, 2);
    end if;

    -- processing logic
   if(p_item_type is null OR p_item_key is null) then
      -- no processing return null
      return null;
   else
     -- get the transaction id
     ln_transaction_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                      itemkey  => p_item_key,
                                                      aname => 'TRANSACTION_ID');
     -- check if we have transaction id, if not no more iteration
     -- will this condition ever meet ???
     if(ln_transaction_id is null) then
       -- this is needed as AME depends on hr_api_transactions.transaction_id
       -- for processing the ame rules and approvers list
       return null;
     end if ;

     -- get the AME transaction type and app id
     ln_application_id :=wf_engine.GetItemAttrNumber(itemtype => p_item_type ,
                                                     itemkey  => p_item_key,
                                                     aname => 'HR_AME_APP_ID_ATTR');
     lv_transaction_type := wf_engine.GetItemAttrText(itemtype => p_item_type ,
                                                      itemkey  => p_item_key,
                                                         aname => 'HR_AME_TRAN_TYPE_ATTR');
     -- check if the flow is using AME
     if(lv_transaction_type is null) then
       -- flow is using custom package for approvals
       -- -----------------------------------------------------------------------
       -- expose the wf control variables to the custom package
       -- -----------------------------------------------------------------------
       hr_approval_custom.g_itemtype := p_item_type;
       hr_approval_custom.g_itemkey  := p_item_key;

       -- process the additional approvers and default approvers
       -- get the total number of additional approvers for this transaction
       ln_addntl_approvers := NVL(wf_engine.GetItemAttrNumber(itemtype   => p_item_type
                                                             ,itemkey    => p_item_key
                                                             ,aname      => 'ADDITIONAL_APPROVERS_NUMBER'
                                                         ,ignore_notfound=>true), 0);


       -- attribute to hold the last_default approver from the heirarchy tree.
       OPEN csr_wiav(p_item_type,p_item_key,'CURRENT_APPROVER_INDEX');
       FETCH csr_wiav into lv_dummy;
         IF csr_wiav%notfound THEN
           -- create new wf_item_attribute_value to hold
           hr_approval_wf.create_item_attrib_if_notexist(p_item_type  => p_item_type
                                                        ,p_item_key   => p_item_key
                                                            ,p_name   => 'CURRENT_APPROVER_INDEX');

           wf_engine.SetItemAttrNumber (itemtype    => p_item_type,
                                        itemkey     => p_item_key,
                                        aname       => 'CURRENT_APPROVER_INDEX',
                                        avalue      => NULL);

        END IF;
       CLOSE csr_wiav;





       -- get the current_approver_index
       ln_current_approver_index := NVL(wf_engine.GetItemAttrNumber(itemtype   => p_item_type
                                                                   ,itemkey    => p_item_key
                                                                   ,aname      => 'CURRENT_APPROVER_INDEX'
                                                               ,ignore_notfound=>true), 0);
       -- set the item name
       lv_item_name := gv_item_name || to_char(ln_current_approver_index + 1);

       -- check if we have additional approver for the next index.
       IF ln_current_approver_index <= ln_addntl_approvers THEN
         OPEN csr_wiav(p_item_type,p_item_key,lv_item_name);
         FETCH csr_wiav into lv_dummy;

           IF csr_wiav%notfound THEN
             lv_exists := 'N';
           ELSE
             lv_exists := 'Y';
             lv_isvalid := wf_engine.GetItemAttrText(itemtype   => p_item_type,
                                                     itemkey    => p_item_key,
                                                     aname      => lv_item_name
                                                ,ignore_notfound=>true);
             lv_isvalid := NVL(lv_isvalid,' ');

           END IF;
         CLOSE csr_wiav;
       ELSE
         lv_exists := 'N';
       END IF;


       IF lv_exists <>'N' AND lv_isvalid <>'DELETED' THEN
         ln_nextApprover_person_id :=wf_engine.GetItemAttrNumber(itemtype    => p_item_type,
                                                                 itemkey     => p_item_key,
                                                                 aname       => lv_item_name
                                                                );

       ELSE
         -- get the last default approver index

         ln_last_default_approver_id := wf_engine.GetItemAttrNumber(itemtype    => p_item_type,
                                                                    itemkey     => p_item_key,
                                                                    aname       => 'LAST_DEFAULT_APPROVER'
                                                                ,ignore_notfound=>true);



         -- get the next approver from the heirarchy tree.
         -- the l_current_forward_to_id resetting was removed for default approver.
         -- now the from column will show the last approver approved.
         ln_nextApprover_person_id :=
	                hr_approval_custom.Get_Next_Approver(
	                           p_person_id =>NVL(ln_last_default_approver_id,
                                                       wf_engine.GetItemAttrNumber
                                                                   (itemtype   => p_item_type
                                                                   ,itemkey    => p_item_key
                                                                   ,aname      => 'CREATOR_PERSON_ID')));


       end if;
     else
       -- flow is using AME for approvals
       -- get the current approver
       ln_currentApprover_person_id := wf_engine.GetItemAttrNumber
                                                   (p_item_type,
                                                    p_item_key,
                                                   'FORWARD_TO_PERSON_ID',
                                                    true);
       -- check if the current approver and creator or same
       if(ln_currentApprover_person_id is not null
                AND (ln_currentApprover_person_id=getApprStartingPointPersonId(ln_transaction_id))) then
         -- call ame getNextApprover method directly as this is intial approval
         /*
         ame_api.getNextApprover(applicationIdIn =>ln_application_id,
                                 transactionIdIn =>ln_transaction_id,
                               transactionTypeIn =>lv_transaction_type,
                                 nextApproverOut =>l_next_approver_rec); */

         ame_api2.getNextApprovers4
	    (applicationIdIn  => ln_application_id
	    ,transactionTypeIn => lv_transaction_type
	    ,transactionIdIn => ln_transaction_id
	    ,flagApproversAsNotifiedIn=>ame_util.booleanFalse
	    ,approvalProcessCompleteYNOut => v_approvalprocesscompleteynout
	    ,nextApproversOut => v_next_approver_rec);

         --ln_nextApprover_person_id :=l_next_approver_rec.person_id;

         if(v_approvalprocesscompleteynout<>'Y') then
		ln_nextApprover_person_id := v_next_approver_rec(1).orig_system_id;
	end if;

       else
         -- get all approvers
	 -- we need this as AME does not return next approver
	 -- unless the approval status of current approver is set
	 /*
	 ame_api.getAllApprovers(applicationIdIn =>ln_application_id,
                                  transactionIdIn=>ln_transaction_id,
                               transactionTypeIn =>lv_transaction_type,
                                     approversOut=>l_default_approvers); */

         ame_api2.getAllApprovers7(applicationIdIn =>ln_application_id,
                             transactionTypeIn=>lv_transaction_type,
                             transactionIdIn =>ln_transaction_id,
                             approvalProcessCompleteYNOut=>v_approvalProcessCompleteYNOut ,
                             approversOut=>v_default_approvers );

         -- special case AME always returns intiator as first approver
         -- so need to eliminate intiator
         if (ln_currentApprover_person_id is null) then
           ln_nextApprover_person_id :=v_default_approvers(1).orig_system_id;
         else
           -- loop through the approvers list to get the next approver
           -- set the default , creator is default approver
           ln_nextApprover_person_id :=getApprStartingPointPersonId(ln_transaction_id);

           for i in 1..v_default_approvers.count loop
             if(l_foundApprLoc) then
               ln_nextApprover_person_id :=v_default_approvers(i).orig_system_id;
               exit;
             elsif(ln_currentApprover_person_id=v_default_approvers(i).orig_system_id) then
               l_foundApprLoc := true;
             else
               ln_nextApprover_person_id :=v_default_approvers(i).orig_system_id;
             end if;
           end loop;
           end if;

         end if;
       end if;


     -- check if the ln_nextApprover_person_id is null
     if(ln_nextApprover_person_id is null) then
       return  fnd_global.user_name;
     else
       wf_directory.GetUserName(p_orig_system    => 'PER'
                               ,p_orig_system_id => ln_nextApprover_person_id
                               ,p_name           => ln_nextApprover_userName
                               ,p_display_name   => ln_nextApprover_dispName);

       return ln_nextApprover_userName;
     end if;
   end if;



 if(hr_utility.debug_enabled) then
   -- write debug statements
   hr_utility.set_location('Leaving '||lv_procedure_name||'with itemtype:'||p_item_type, 10);
 end if;

EXCEPTION
 WHEN OTHERS THEN
    fnd_message.set_name('PER', SQLERRM ||' '||to_char(SQLCODE));
    hr_utility.raise_error;
    return null;
end getNextApproverForHist;

function Authenticate(p_username in varchar2,
                      p_nid in number,
                      p_nkey in varchar2)
return varchar2
is
  recipient      varchar2(320);
  orig_recipient varchar2(320);
  from_role      varchar2(320);
  more_info_role varchar2(320);

  l_username fnd_user.user_name%TYPE default null;
  userRoles Wf_Directory.RoleTable;
  matchFound boolean;
begin

  l_username := wf_advanced_worklist.Authenticate(p_username, p_nid, p_nkey);

  if(l_username = p_username) then
      select RECIPIENT_ROLE, ORIGINAL_RECIPIENT, FROM_ROLE, MORE_INFO_ROLE
      into recipient, orig_recipient, from_role, more_info_role
      from WF_NOTIFICATIONS WN
      where WN.NOTIFICATION_ID = p_nid;

      Wf_Directory.GetUserRoles(p_username,userRoles);
      matchFound := false;

      -- loop through the roles and validate if the user role matches
      -- to orig_recipient
      for i in 1..userRoles.count loop
         -- fix for bug 4308800
         -- more info case
         if(userRoles(i) in (orig_recipient,more_info_role,recipient)) then
           matchFound := true;
           exit;
         end if;
      end loop;

      if matchFound then
        return l_username;
      else
        return '';
      end if;


  end if;

exception
  when others then
    raise;
end  Authenticate;



function Authenticate(p_username in varchar2,
                      p_txn_id in number
                      )
return varchar2
is
  ntfId number;
begin
  ntfId := hr_approval_ss.getApproverNtfId(p_txn_id);
  if (pqh_ss_workflow.is_notification_closed(ntfId) = 'Y') then
   return '';
  end if;
  return Authenticate(p_username,ntfId,null);
exception
  when others then
    raise;
end  Authenticate;

function getOrganizationManagersubject
         (p_item_type IN varchar2,
         p_item_key IN varchar2)
        return varchar2
is
l_process_name varchar2(500) default null;
l_txn_id number;
l_txn_step_id number;
l_current_person_id number;
l_creator_person_id number;
l_organization_name varchar2(500) default null;
cursor csr_txn_steps
IS
    select * from hr_api_transaction_steps where transaction_id = l_txn_id
    and api_name = 'HR_CCMGR_SS.PROCESS_API';
type transaction_type is table of hr_api_transaction_steps%rowtype;
txn_steps_rc transaction_type;
l_counter number default 0;

cursor is_term_txn is
    select transaction_step_id from hr_api_transaction_steps where transaction_id = l_txn_id
    and api_name = 'HR_TERMINATION_SS.PROCESS_API';
l_term_txn number;

begin
l_txn_id := wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'TRANSACTION_ID',true);
l_creator_person_id:= wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'CREATOR_PERSON_ID',true);
l_current_person_id := wf_engine.GetItemAttrNumber(p_item_type,p_item_key,'CURRENT_PERSON_ID',true);
l_process_name := null;

open is_term_txn;
fetch is_term_txn into l_term_txn;
if is_term_txn%found then
  close is_term_txn;
  return l_process_name;
else
  close is_term_txn;
end if;

open csr_txn_steps;
fetch csr_txn_steps bulk collect into txn_steps_rc;
l_counter := txn_steps_rc.count;
if l_counter = 0 then
   return l_process_name;
end if;
if l_counter = 1 then
    l_organization_name  := hr_transaction_api.get_varchar2_value(txn_steps_rc(1).transaction_step_id,'P_ORGANIZATION_NAME');
else
    for i in 1 .. txn_steps_rc.count loop
        l_txn_step_id := txn_steps_rc(i).transaction_step_id;
        if(l_counter = 1) then
            l_organization_name  := l_organization_name || hr_transaction_api.get_varchar2_value(l_txn_step_id,'P_ORGANIZATION_NAME');
         else
                l_organization_name  := l_organization_name || hr_transaction_api.get_varchar2_value(l_txn_step_id,'P_ORGANIZATION_NAME') || ', ';
         end if;

        l_counter := l_counter - 1;
    end loop;
end if;
close csr_txn_steps;
if( (l_organization_name is not null) and  (l_creator_person_id = l_current_person_id) ) then
    l_process_name :=  l_organization_name;
end if;
return l_process_name;
end getOrganizationManagersubject;

  PROCEDURE isFyiNtfDet
 (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funcmode in     varchar2
  ,resultout   out nocopy varchar2)
IS

   l_details varchar2(30) := null;
BEGIN

  l_details := wf_engine.getitemattrtext(itemtype,
                             itemkey,
                             'FYI_NTF_DETAILS',true);

if l_details = 'Y' then
resultout := 'COMPLETE:'|| 'Y';
else
resultout := 'COMPLETE:'|| 'N';
end if;

EXCEPTION
WHEN OTHERS THEN NULL;
RAISE;
END isFyiNtfDet;


END hr_workflow_ss;

/
