--------------------------------------------------------
--  DDL for Package Body PQH_AME_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_AME_APPROVALS" AS
/* $Header: pqameapr.pkb 120.5 2005/06/23 13:37:24 nsanghal noship $ */
--

g_package constant varchar2(32) := ' pqh_ame_approvals.';

-- ---------------------------------------------------------------------------
-- ------------------- <set_route_to_user> -----------------------------------
-- ---------------------------------------------------------------------------
procedure   set_route_to_user (
	      p_itemType  in varchar2
	     ,p_itemKey   in varchar2
	     ,p_forward_to_person_id in number
             ,p_result    out nocopy varchar2 ) Is
--
l_forward_to_username          varchar2(240);
l_forward_to_disp_name         varchar2(240);
l_proc  constant varchar2(72):= g_package||'set_route_to_user';
--
BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
   wf_directory.GetUserName
    (p_orig_system    => 'PER'
    ,p_orig_system_id => p_forward_to_person_id
    ,p_name           => l_forward_to_username
    ,p_display_name   => l_forward_to_disp_name);

    wf_engine.SetItemAttrText
     (itemtype => p_itemtype
     ,itemkey  => p_itemkey
     ,aname    => 'PARAMETER10_VALUE'
     ,avalue   => p_forward_to_person_id);

   if (l_forward_to_username is null) then
      p_result := 'NO_USER';
   else
        wf_engine.SetItemAttrText
          (itemtype => p_itemtype
          ,itemkey  => p_itemkey
          ,aname    => 'ROUTE_TO_USER'
          ,avalue   => l_forward_to_username);
   end if;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    Raise;
END set_route_to_user;


-- ---------------------------------------------------------------------------
-- ------------------- <get_txn_type_info> -----------------------------------
-- ---------------------------------------------------------------------------
procedure  get_txn_type_info(
            p_item_type      in varchar2
           ,p_item_key       in varchar2
           ,p_txn_type       out nocopy varchar2
           ,p_txn_app_id     out nocopy number ) is

l_proc constant  varchar2(72):= g_package||'get_txn_type_info';
begin

   hr_utility.set_location('Entering:'||l_proc, 5);
   p_txn_type := wf_engine.GetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'PARAMETER2_VALUE' );

   p_txn_app_id := wf_engine.GetItemAttrText
                    (itemtype    => p_item_type,
                     itemkey     => p_item_key,
                     aname       => 'PARAMETER3_VALUE' );
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    Raise;
end;
--
-- ---------------------------------------------------------------------------
-- ------------------- <Check_Final_Approver> --------------------------------
-- ---------------------------------------------------------------------------
PROCEDURE check_final_approver (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS
--
l_forward_from_username  varchar2(30);
l_forward_from_person_id number;
l_forward_to_person_id number;
c_next_approver_rec ame_util.approverRecord;
--
l_transaction_id number(18);
l_txn_type       varchar2(30);
l_txn_app_id     number(18);
--
l_proc constant  varchar2(72):= g_package||'check_final_approver';
BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);

   if ( p_funmode = 'RUN' ) then
       l_transaction_id  := pqh_ss_workflow.get_transaction_id(p_itemType, p_itemKey);

       l_forward_from_person_id := wf_engine.GetItemAttrText (
                     itemtype    => p_itemtype,
                     itemkey     => p_itemkey,
                     aname       => 'PARAMETER10_VALUE' );

       get_txn_type_info(
            p_item_type      => p_itemType
           ,p_item_key       => p_itemKey
           ,p_txn_type       => l_txn_type
           ,p_txn_app_id     => l_txn_app_id );

       -- Status not to be updated to approved for the first time
       -- when the forward to person is null
       if ( l_forward_from_person_id is not null) then
           ame_api.updateApprovalStatus2(
                 applicationIdIn    => l_txn_app_id,
                 transactionIdIn    => l_transaction_id,
                 transactionTypeIn  => l_txn_type,
                 approvalStatusIn   => ame_util.approvedStatus,
                 approverPersonIdIn => l_forward_from_person_id,
                 approverUserIdIn   => null,
                 forwardeeIn        => null);
       end if;

        ame_api.getNextApprover(applicationIdIn=> l_txn_app_id,
                        transactionIdIn   => l_transaction_id,
                        transactionTypeIn => l_txn_type,
                        nextApproverOut   => c_next_approver_rec);

         if ( c_next_approver_rec.person_id is null) then
             p_result := 'COMPLETE:T';
         else
             p_result := 'COMPLETE:F';
         end if;
    --
   end if;
   hr_utility.set_location(' Leaving:'||l_proc, 10);

 Exception
   When Others Then
      -- Set error attribute and complete activity with result error
      wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => p_ItemKey
          ,aname    => 'SYSTEM_ERROR'
          ,avalue   => sqlerrm);

      p_result := 'COMPLETE:E';
 END;

-- ---------------------------------------------------------------------------
-- ------------------- <Approve_Reject_Elctbl_Chc> ---------------------------
-- ---------------------------------------------------------------------------
   PROCEDURE  approve_reject_elctbl_chc (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_app_rej     in varchar2 ) IS
     l_elctbl_chc_id  number(18);
     l_proc constant  varchar2(72):= g_package||'approve_reject_elctbl_chc';
     l_ovn  number(15);
   BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
     -- Get The electable choice id from WF attribute
          l_elctbl_chc_id := wf_engine.GetItemAttrText
                    (itemtype    => p_itemtype,
                     itemkey     => p_itemkey,
                     aname       => 'PARAMETER1_VALUE' );

     -- Get the OVN to call update api
     Select object_version_number
     into   l_ovn
     From   ben_elig_per_elctbl_chc
     Where  elig_per_elctbl_chc_id  = l_elctbl_chc_id;

     -- Call the API to update the status code
     ben_elig_per_elc_chc_api.update_elig_per_elc_chc (
        p_elig_per_elctbl_chc_id  => l_elctbl_chc_id
       ,p_approval_status_cd      => p_app_rej
       ,p_object_version_number   => l_ovn
       ,p_effective_date          => sysdate);

    hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    Raise;
   END approve_reject_elctbl_chc ;

-- ---------------------------------------------------------------------------
-- ------------------- <Mark_Elctbl_Chc_Approved> ----------------------------
-- ---------------------------------------------------------------------------
   PROCEDURE mark_elctbl_chc_approved (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS

   l_elctbl_chc_id  varchar2(30);

l_proc constant  varchar2(72):= g_package||'mark_elctbl_chc_approved';
   BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
     if ( p_funmode = 'RUN' ) then
          approve_reject_elctbl_chc (
              p_itemType => p_itemType
             ,p_itemKey  => p_itemKey
             ,p_app_rej  => 'PQH_GSP_A');

         --get electable choice id
     end if;

     p_result := 'COMPLETE:T';

   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    wf_core.context(g_package,'mark_elctbl_chc_approved',p_itemType,p_itemKey);
    Raise;
   END;

-- ---------------------------------------------------------------------------
-- ------------------- <Mark_Elctbl_Chc_Rejected> ----------------------------
-- ---------------------------------------------------------------------------
   PROCEDURE mark_elctbl_chc_rejected (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS

   l_elctbl_chc_id  varchar2(30);

l_proc constant  varchar2(72):= g_package||'mark_elctbl_chc_rejected';
   BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
     if ( p_funmode = 'RUN' ) then
          approve_reject_elctbl_chc (
              p_itemType => p_itemType
             ,p_itemKey  => p_itemKey
             ,p_app_rej  => 'PQH_GSP_R');
     end if;

     p_result := 'COMPLETE:T';
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    wf_core.context(g_package,'mark_elctbl_chc_rejected',p_itemType,p_itemKey);
    Raise;
   END mark_elctbl_chc_rejected;
  --
 PROCEDURE unmark_wf_flag_for_elctbl_chc (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS
   l_proc constant  varchar2(72):= g_package||'unmark_wf_flag_for_elctbl_chc';
   l_ovn            number;
   l_elctbl_chc_id  number;
   BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if ( p_funmode = 'RUN' ) then
      l_elctbl_chc_id  := wf_engine.GetItemAttrText (
                     itemtype    => p_itemtype,
                     itemkey     => p_itemkey,
                     aname       => 'PARAMETER1_VALUE' );
     Select object_version_number
     into l_ovn
     From ben_elig_per_elctbl_chc
    Where elig_per_elctbl_chc_id  = l_elctbl_chc_id;

    ben_elig_per_elc_chc_api.update_elig_per_elc_chc (
        p_elig_per_elctbl_chc_id  => l_elctbl_chc_id
       ,p_in_pndg_wkflow_flag     => 'N'
       ,p_object_version_number   => l_ovn
       ,p_effective_date          => sysdate);
   end if;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
    wf_core.context(g_package,'unmark_wf_flag_for_elctbl_chc',p_itemType,p_itemKey);
    Raise;
 END unmark_wf_flag_for_elctbl_chc;


-- ---------------------------------------------------------------------------
-- ---------------------- <Initialize_AME> -----------------------------------
-- ---------------------------------------------------------------------------
   PROCEDURE initialize_ame (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS
--
l_txn_id                       number ;
l_txn_type                     varchar2(30);
l_txn_app_id                   number(18);
l_person_id                    number(18);
--
l_proc constant  varchar2(72):= g_package||'initialize_ame';
l_result         varchar2(30);
   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 5);

   if ( p_funmode = 'RUN' ) then
        p_result := 'COMPLETE:T';
   end if;
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
      -- Set error attribute and complete activity with result error
      wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => p_ItemKey
          ,aname    => 'SYSTEM_ERROR'
          ,avalue   => sqlerrm);

      p_result := 'COMPLETE:E';
   END;

-- ---------------------------------------------------------------------------
-- ------------------- <Find_Next_Approver> ----------------------------------
-- ---------------------------------------------------------------------------
  PROCEDURE find_next_approver (
                p_itemType    IN varchar2,
                p_itemKey     in varchar2,
                p_actId       in number,
                p_funmode     in varchar2,
                p_result      out nocopy varchar2     ) IS
--
c_next_approver_rec ame_util.approverRecord;
l_forward_to_person_id  number;
l_forward_from_username        varchar2(240);
l_forward_from_person_id       number;
l_forward_to_username          varchar2(240);
l_forward_to_disp_name         varchar2(240);
l_final_approver               varchar2(10);
l_txn_id                       number ;
l_txn_type                     varchar2(30);
l_txn_app_id                   number(18);
l_dummy                        varchar2(240);
l_result                       varchar2(30);

l_proc constant  varchar2(72):= g_package||'find_next_approver';
BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);

l_txn_id := pqh_ss_workflow.get_transaction_id(p_itemType, p_itemKey);

if ( p_funmode = 'RUN' ) then
   get_txn_type_info(
            p_item_type      => p_itemType
           ,p_item_key       => p_itemKey
           ,p_txn_type       => l_txn_type
           ,p_txn_app_id     => l_txn_app_id );

   ame_api.getNextApprover(applicationIdIn=> l_txn_app_id,
                        transactionIdIn   => l_txn_id,
                        transactionTypeIn => l_txn_type,
                        nextApproverOut   => c_next_approver_rec);

    l_forward_to_person_id := c_next_approver_rec.person_id;

    if ( l_forward_to_person_id is null ) then
        --
        p_result := 'COMPLETE:F';
        --
    else
        --
      set_route_to_user (
           p_itemType   => p_itemType
          ,p_itemKey    => p_itemKey
          ,p_forward_to_person_id => l_forward_to_person_id
          ,p_result     => l_result);

        --
        -- Might have to fetch previous value of route_to_user and set to
        -- routed_by_user
        p_result := 'COMPLETE:T';
        --
    end if;
    --
--
end if;

   hr_utility.set_location(' Leaving:'||l_proc, 10);
 Exception
   When Others Then
      wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => p_ItemKey
          ,aname    => 'SYSTEM_ERROR'
          ,avalue   => sqlerrm);

      p_result := 'COMPLETE:E';

   END;

END; -- Package Body PQH_AME_APPROVALS

/
