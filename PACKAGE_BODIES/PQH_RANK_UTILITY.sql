--------------------------------------------------------
--  DDL for Package Body PQH_RANK_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RANK_UTILITY" as
/* $Header: pqrnkutl.pkb 120.5 2005/06/23 13:31:10 nsanghal noship $ */

g_package constant Varchar2(30) := 'pqh_rank_utility.';
g_debug   constant boolean      := hr_utility.debug_enabled;


 -- ---------------------------------------------------------------------------
 -- ------------- <is_ranking_enabled_for_txn> --------------------------------
 -- ---------------------------------------------------------------------------
function is_ranking_enabled_for_txn(
	p_copy_entity_txn_id in number )
return varchar2 is
l_proc constant varchar2(72) := g_package||'.is_ranking_enabled_for_txn';
l_use_rank varchar2(1);
begin
	hr_utility.set_location('Entering:'|| l_proc, 10);
	select information12
	  into l_use_rank
	  from ben_copy_entity_results
	 where copy_entity_txn_id = p_copy_entity_txn_id
	   and table_alias = 'PGI' ;
	return l_use_rank ;
exception
	when others then
	raise ;
end ;


 -- ---------------------------------------------------------------------------
 -- ---------------- <get_ben_action_id> --------------------------------------
 -- ---------------------------------------------------------------------------
function get_ben_action_id(
	 p_per_in_ler_id	in number
	,p_pgm_id		in number
	,p_pl_id		in number)
return number is
l_proc constant varchar2(72) := g_package||'.get_ben_action_id';
l_ben_action_id number  ;
l_gl_option varchar2(80) ;
cursor csr_for_group_gl is
	select rp.benefit_action_id
	  from pqh_rank_processes rp
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id;

cursor csr_for_group_grade is
	select rp.benefit_action_id
	  from pqh_rank_processes rp
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
	   and rp.pl_id = p_pl_id ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);

 -- test for ranking enabled for this gl
if ( get_grade_ladder_option (p_pgm_id , 'RANK_ENABLED')= 'N' ) then
l_ben_action_id := -1 ;
return l_ben_action_id ;
end if ;

l_gl_option := get_grade_ladder_option (p_pgm_id , 'RANK_GROUP_CRITERIA');
if (l_gl_option = 'GRADE' )
then
    open csr_for_group_grade;
    fetch csr_for_group_grade into l_ben_action_id ;
    if csr_for_group_grade%notfound then
       l_ben_action_id := -1 ;
    End If;
    Close csr_for_group_grade;
else
    open csr_for_group_gl;
    fetch csr_for_group_gl into l_ben_action_id ;
    if csr_for_group_gl%notfound then
       l_ben_action_id := -1 ;
    End If;
    Close csr_for_group_gl;
end if;
return l_ben_action_id ;
exception
    when others then
        hr_utility.set_location('Problem in determining Total Score',10);
        raise;
end get_ben_action_id ;
 -- ---------------------------------------------------------------------------
 -- ------------- <update_proposed_rank> --------------------------------------
 -- ---------------------------------------------------------------------------
procedure update_proposed_rank ( p_proposed_rank    in number
                             	,p_per_in_ler_id	in number
                                ,p_pgm_id           in number
                                ,p_pl_id            in number   )
is
l_proc constant varchar2(72) := g_package||'.update_proposed_rank';
l_gl_option varchar2(80) ;
l_rank_process_approval_id  number;
l_rank_process_id           number;
l_date			    date  ;
l_object_version_number number ;

cursor csr_for_group_gl is
	select rpa.rank_process_approval_id
          ,rpa.rank_process_id
	   ,rpa.object_version_number
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id;

cursor csr_for_group_grade is
	select rpa.rank_process_approval_id
          ,rpa.rank_process_id
	  ,rpa.object_version_number
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id
       and rp.pl_id = p_pl_id ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
l_date := sysdate ;
-- Dont update If rank is not enabled for this grade ladder
if ( get_grade_ladder_option (p_pgm_id , 'RANK_ENABLED')= 'N' ) then
return ;
end if ;

l_gl_option := get_grade_ladder_option (p_pgm_id , 'RANK_GROUP_CRITERIA');
if (l_gl_option = 'GRADE')
then
    open csr_for_group_grade;
    fetch csr_for_group_grade
   into l_rank_process_approval_id,l_rank_process_id, l_object_version_number ;
    Close csr_for_group_grade;
else
    open csr_for_group_gl;
    fetch csr_for_group_gl
     into l_rank_process_approval_id,l_rank_process_id, l_object_version_number ;
    Close csr_for_group_gl;
end if;

--NS 04/24/05: Update to be called only if record exits
IF (l_rank_process_id is not null) Then
PQH_RANK_PROCESS_APPROVAL_API.update_rank_process_approval
  (p_effective_date            =>l_date
  ,p_rank_process_approval_id  =>l_rank_process_approval_id
  ,p_rank_process_id           =>l_rank_process_id
  ,p_approval_date             =>l_date
  ,p_proposed_rank             =>p_proposed_rank
  ,p_object_version_number     =>l_object_version_number
  );
End If;

exception
    when others then
        hr_utility.set_location('Problem in updating proposed Rank',10);
        raise;
end update_proposed_rank ;

 -- ---------------------------------------------------------------------------
 -- ------------- <update_proposed_rank> --------------------------------------
 -- -------- <OBSOLETE USE THE OVERLOADED METHOD WITH PER_IN_LER_ID > ---------
 -- ---------------------------------------------------------------------------
procedure update_proposed_rank ( p_proposed_rank    in number
                             	,p_assignment_id	in number
                                ,p_life_event_dt   in date
                                ,p_pgm_id           in number
                                ,p_pl_id            in number   )
is
l_proc constant varchar2(72) := g_package||'.update_proposed_rank';
l_gl_option varchar2(80) ;
l_rank_process_approval_id  number;
l_rank_process_id           number;
l_date			    date  ;
l_object_version_number number ;

cursor csr_for_group_gl is
	select rpa.rank_process_approval_id
          ,rpa.rank_process_id
	   ,rpa.object_version_number
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.assignment_id = p_assignment_id
       and rp.PROCESS_DATE = p_life_event_dt
       and rp.rank_process_id = rpa.rank_process_id;

cursor csr_for_group_grade is
	select rpa.rank_process_approval_id
          ,rpa.rank_process_id
	  ,rpa.object_version_number
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.assignment_id = p_assignment_id
       and rp.PROCESS_DATE = p_life_event_dt
       and rp.rank_process_id = rpa.rank_process_id
	   and rp.pl_id = p_pl_id ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
l_date := sysdate ;
-- Dont update If rank is not enabled for this grade ladder
if ( get_grade_ladder_option (p_pgm_id , 'RANK_ENABLED')= 'N' ) then
return ;
end if ;

l_gl_option := get_grade_ladder_option (p_pgm_id , 'RANK_GROUP_CRITERIA');
if (l_gl_option = 'GRADE')
then
    open csr_for_group_grade;
    fetch csr_for_group_grade
   into l_rank_process_approval_id,l_rank_process_id, l_object_version_number ;
    Close csr_for_group_grade;
else
    open csr_for_group_gl;
    fetch csr_for_group_gl
     into l_rank_process_approval_id,l_rank_process_id, l_object_version_number ;
    Close csr_for_group_gl;
end if;

--NS 04/24/05: Update to be called only if record exits
IF (l_rank_process_id is not null) Then
PQH_RANK_PROCESS_APPROVAL_API.update_rank_process_approval
  (p_effective_date            =>l_date
  ,p_rank_process_approval_id  =>l_rank_process_approval_id
  ,p_rank_process_id           =>l_rank_process_id
  ,p_approval_date             =>l_date
  ,p_proposed_rank             =>p_proposed_rank
  ,p_object_version_number     =>l_object_version_number
  );
End If;

exception
    when others then
        hr_utility.set_location('Problem in updating proposed Rank',10);
        raise;
end update_proposed_rank ;

 -- ---------------------------------------------------------------------------
 -- ------------------------- <get_rank> --------------------------------------
 -- ---------------------------------------------------------------------------
function get_rank (
	 p_rank_type		in varchar2
	,p_per_in_ler_id	in number
	,p_pgm_id		in number
	,p_pl_id		in number )
return number is
l_proc constant varchar2(72) := g_package||'.get_rank';
l_proposed_rank number  ;
l_rank number  ;
l_gl_option varchar2(80) ;

cursor csr_for_grp_gl_sys_rank is
	select rpa.system_rank
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id;

cursor csr_for_grp_grade_sys_rank is
	select rpa.system_rank
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id
	   and rp.pl_id = p_pl_id ;

cursor csr_for_grp_gl_pro_rank is
	select rpa.proposed_rank
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id;

cursor csr_for_grp_grade_pro_rank is
	select rpa.proposed_rank
	  from pqh_rank_processes rp
	      ,pqh_rank_process_approvals rpa
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.rank_process_id = rpa.rank_process_id
	   and rp.pl_id = p_pl_id ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
 -- Test for ranking enabled for this gl
if ( get_grade_ladder_option (p_pgm_id , 'RANK_ENABLED')= 'N' ) then
return 0 ;
end if ;

l_gl_option := get_grade_ladder_option (p_pgm_id , 'RANK_GROUP_CRITERIA');
if (l_gl_option = 'GRADE')
then
    if (p_rank_type = 'S') -- Grouping criteria Grade, System Rank
    then
        open csr_for_grp_grade_sys_rank;
        fetch csr_for_grp_grade_sys_rank into l_rank;
        if csr_for_grp_grade_sys_rank%notfound then
           l_rank := 0 ;
        End If;
        Close csr_for_grp_grade_sys_rank;
    else                  -- Grouping criteria Grade, Proposed Rank
        open csr_for_grp_grade_pro_rank;
        fetch csr_for_grp_grade_pro_rank into l_rank;
        if csr_for_grp_grade_pro_rank%notfound then
           l_rank := 0 ;
        End If;
        Close csr_for_grp_grade_pro_rank;
    end if ;
else
    if (p_rank_type = 'S') -- Grouping criteria GL, System Rank
    then
        open csr_for_grp_gl_sys_rank;
        fetch csr_for_grp_gl_sys_rank into l_rank;
        if csr_for_grp_gl_sys_rank%notfound then
           l_rank := 0 ;
        End If;
        Close csr_for_grp_gl_sys_rank;
    else                  -- Grouping criteria GL, Proposed Rank
        open csr_for_grp_gl_pro_rank;
        fetch csr_for_grp_gl_pro_rank into l_rank;
        if csr_for_grp_gl_pro_rank%notfound then
           l_rank := 0 ;
        End If;
        Close csr_for_grp_gl_pro_rank;
    end if ;
end if;
return l_rank ;
exception
    when others then
        hr_utility.set_location('Problem in determining Rank',10);
        raise;
end get_rank ;

 -- ---------------------------------------------------------------------------
 -- ------------------ <get_total_score> --------------------------------------
 -- ---------------------------------------------------------------------------
function get_total_score(
	 p_per_in_ler_id	in number
    ,p_pgm_id		in number
	,p_pl_id		in number )
return number is
l_proc constant varchar2(72):= g_package||'.get_total_score';
l_total_score number  ;
l_gl_option varchar2(80) ;
cursor csr_for_group_gl is
	select rp.total_score
	  from pqh_rank_processes rp
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id;

cursor csr_for_group_grade is
	select rp.total_score
	  from pqh_rank_processes rp
     where rp.pgm_id = p_pgm_id
       and rp.per_in_ler_id = p_per_in_ler_id
       and rp.pl_id = p_pl_id ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
 -- may be test for ranking enabled for this gl be doen
if ( get_grade_ladder_option (p_pgm_id , 'RANK_ENABLED')= 'N' ) then
l_total_score := 0 ;
return l_total_score ;
end if ;

l_gl_option := get_grade_ladder_option (p_pgm_id , 'RANK_GROUP_CRITERIA');
if (l_gl_option = 'GRADE' )
then
    open csr_for_group_grade;
    fetch csr_for_group_grade into l_total_score;
    if csr_for_group_grade%notfound then
       l_total_score := 0 ;
    End If;
    Close csr_for_group_grade;
else
    open csr_for_group_gl;
    fetch csr_for_group_gl into l_total_score;
    if csr_for_group_gl%notfound then
       l_total_score := 0 ;
    End If;
    Close csr_for_group_gl;
end if;
return l_total_score ;
exception
    when others then
        hr_utility.set_location('Problem in determining Total Score',10);
        raise;
end get_total_score ;


 -- ---------------------------------------------------------------------------
 -- ------------- <is_ranking_enabled_for_bg> ---------------------------------
 -- ---------------------------------------------------------------------------
function is_ranking_enabled_for_bg (p_business_group_id in Number)
return varchar2 is
l_proc constant varchar2(72) := g_package||'is_ranking_enabled_for_bg';
l_present_flag varchar2(1) ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
    begin
    select 'Y'
      into l_present_flag
      from ben_pgm_f pgm
          ,ben_pgm_extra_info pgmei
    where pgm.business_group_id = p_business_group_id
      and pgm.pgm_id = pgmei.pgm_id
      and pgmei.information_type = 'PQH_GSP_EXTRA_INFO'
      and pgmei.pgi_information2 = 'Y'  -- Verify and confirm
      and rownum < 2 ;
    exception
      when no_data_found then
        l_present_flag := 'N' ;
      when others then
         hr_utility.set_location('Problem in determining Ranking Enabled for BG ',10);
      raise;
    end ;
return l_present_flag ;
end is_ranking_enabled_for_bg;

 -- ---------------------------------------------------------------------------
 -- ------------- <get_grade_ladder_option> -----------------------------------
 -- ---------------------------------------------------------------------------
function get_grade_ladder_option (
	 p_pgm_id	in number
	,p_option	in varchar2)
return Varchar2 is
l_proc constant varchar2(72) := g_package||'.get_grade_ladder_option';
l_option_value varchar2(100);
l_present_flag varchar2(10);
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
l_present_flag := 'N';
    if (p_option = 'WORKFLOW_STATUS') then
        begin
            --NS 4/23/05: If not set, treat it as not found
            select NVL(pgi_information1,'NOT_FOUND')   -- Verify and confirm
              into l_option_value
              from ben_pgm_extra_info pgmei
             where pgmei.pgm_id = p_pgm_id
               and pgmei.information_type = 'PQH_GSP_EXTRA_INFO'
               and rownum < 2 ;
        exception
            when no_data_found then
            l_option_value := 'NOT_FOUND' ;
        end ;

    elsif (p_option = 'RANK_ENABLED') then
        begin
            --NS 4/23/05: If not set, treat it as N
            select NVL(pgi_information2,'N')   -- Verify and confirm
              into l_option_value
              from ben_pgm_extra_info pgmei
             where pgmei.pgm_id = p_pgm_id
               and pgmei.information_type = 'PQH_GSP_EXTRA_INFO'
               and rownum < 2 ;
        exception
            when no_data_found then
            l_option_value := 'N' ;
        end ;
    elsif (p_option = 'RANK_GROUP_CRITERIA') then
        begin
            --NS 4/23/05: If not set, treat it as not found
            select NVL(pgi_information3,'NOT_FOUND')   -- Verify and confirm
              into l_option_value
              from ben_pgm_extra_info pgmei
             where pgmei.pgm_id = p_pgm_id
               and pgmei.information_type = 'PQH_GSP_EXTRA_INFO'
               and rownum < 2 ;
        exception
            when no_data_found then
            l_option_value := 'NOT_FOUND' ;
        end ;

    end if ;
return l_option_value ;
exception
    when others then
        hr_utility.set_location('Problem in determining Ranking Enabled for BG ',10);
    raise;
end get_grade_ladder_option;

-- ---------------------------------------------------------------
-- ---- Added by Nischal to Initate workflow from approval UI ----
-- ---------- <on_approval_init_workflow > -----------------------
-- ---------------------------------------------------------------
/*  This procedure will check whether the workflow is enabled for the program.
 *  If it is enabled, a workflow process will be initiated. If not,
 *  the electable choice record will be marked approved as usual.
 */
procedure on_approval_init_workflow(
       p_elctbl_chc_id  in number
      ,p_pgm_id         in number
      ,p_person_id      in number
      ,p_person_name    in varchar2
      ,p_prog_dt        in date
      ,p_sal_chg_dt     in date
      ,p_comments       in varchar2
      ,p_ameTranType    in varchar2
      ,p_ameAppId       in varchar2
      ,p_itemType       in varchar2
      ,p_processName    in varchar2
      ,p_functionName   in varchar2
      ,p_currentUser    in varchar2
      ,p_supervisorId   in number  ) IS
-- Local Variables
l_workflow_enabled varchar2(10);
l_transaction_id   number(18);
l_itemKey          varchar2(240);
l_function_id      number(18);

-- Cursor to get function details.
 cursor csr_fun is
 select fff.function_id
 from   fnd_form_functions_vl fff
 where  fff.function_name = p_functionName;
--
 l_ovn  number(15);
 l_processDisplayName  varchar2(240);

 cursor csr_prc is
 SELECT wrpv.display_name displayName
 FROM   wf_runnable_processes_v wrpv
 WHERE  wrpv.item_type    = p_itemType
 AND    wrpv.process_name = p_processName;

 procedure approve_now is
 begin
    -- Call the procedure to mark the record as approved.
    Pqh_gsp_post_process.Approve_Reject_AUI (
      P_Elig_per_Elctbl_Chc_id => p_elctbl_chc_id
     ,P_Prog_Dt                => p_prog_dt
     ,P_Sal_Chg_Dt             => p_sal_chg_dt
     ,P_Comments               => p_comments
     ,P_Approve_Rej            => 'PQH_GSP_A' );
 end approve_now;
 --
begin
   -- If person has no supervisor , then approve immediately
   -- no need for further processing
   if ( p_supervisorId is null) then
        approve_now;
        return;
   end if;

   SAVEPOINT on_approval_workflow_process;
    -- Check if workflow is enabled.
   l_workflow_enabled :=  pqh_rank_utility.get_grade_ladder_option (
                             p_pgm_id  => p_pgm_id
                            ,p_option  => 'WORKFLOW_STATUS');

   -- Workflow not enabled
   If (l_workflow_enabled <> 'Y') then
      approve_now;
   Else
   -- Update the electable choice record, mark it as pending workflow approval
   Select object_version_number
     into l_ovn
     From ben_elig_per_elctbl_chc
    Where elig_per_elctbl_chc_id  = p_elctbl_chc_id;

    ben_elig_per_elc_chc_api.update_elig_per_elc_chc (
        p_elig_per_elctbl_chc_id  => p_elctbl_chc_id
       ,p_in_pndg_wkflow_flag     => 'Y'
       ,p_object_version_number   => l_ovn
       ,p_effective_date          => sysdate);

   -- create a transaction that AME will use to fetch appropriate info.
   -- Workflow is enabled, so initiate the workflow process,
   -- Set workflow attributes that will be used later on.
      -- -----------------------------------------------------
      -- Error Handling needed here for mandatory arguments
      -- p_itemType - Must check the function parameter
      -- FND User for person_id must be defined
      -- FND Users must be defined All managers
      -- These validations may be performed while initializing AME
      -- -----------------------------------------------------
      -- Get the itemKey from sequence.
      -- NOTE: This is a new item for the ODF and needs to be generated.
      --
      select pqh_workflow_item_key_s.nextval into l_itemKey from dual;
      --
      l_itemKey  := 'GSP'||l_itemKey;
      Open  csr_fun;
      Fetch csr_fun into l_function_id;
      Close csr_fun;
      --
      hr_transaction_api.create_transaction(
        	p_validate               => false
               ,p_creator_person_id      => p_person_id
               ,p_transaction_privilege  => 'PRIVATE'
               ,p_transaction_id         => l_transaction_id
               ,p_product_code           => 'PQH'
               ,p_status                 => 'N'  -- new txn
               ,p_function_id            => l_function_id
               ,p_selected_person_id     => p_person_id
               ,p_item_type              => p_itemtype
               ,p_item_key               => l_itemkey
               ,p_process_name           => p_processName );


      -- Kick off the workflow process.
     wf_engine.CreateProcess (p_itemtype,l_itemkey,p_processName);


     if p_currentUser is not null then
        wf_engine.SetItemOwner(p_itemtype,l_itemkey,p_currentUser);
     end if;

      -- Get Process Display Name
        Open  csr_prc;
        Fetch csr_prc into l_processDisplayName;
        Close csr_prc;

        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'TRANSACTION_NAME'
          ,avalue   => l_processDisplayName);

      -- Set the route by user (appears in from on worklist)
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'ROUTED_BY_USER'
          ,avalue   => p_currentUser);

      -- Set the electable choice id
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'PARAMETER1_VALUE'
          ,avalue   => p_elctbl_chc_id);

      -- Set the person Id
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'PERSON_ID'
          ,avalue   => p_person_id );

      -- Set the person name
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'PSV_PERSON_NAME'
          ,avalue   => p_person_name );

      -- Set the AME Transaction Type
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'PARAMETER2_VALUE'
          ,avalue   => p_AMETranType );

      -- Set the AME Application Id
        wf_engine.SetItemAttrText (
           itemtype => p_itemType
          ,itemkey  => l_ItemKey
          ,aname    => 'PARAMETER3_VALUE'
          ,avalue   => p_AMEAppId );

     wf_engine.StartProcess (p_itemtype,l_itemkey);

   end if;
Exception
   When Others Then
   ROLLBACK to on_approval_workflow_process;
   raise;
end on_approval_init_workflow;


-- ---------------------------------------------------------------------------
-- ------------- <is_ranking_enabled_for_person> ---------------------------------
-- ---------------------------------------------------------------------------
/*  This function will get the program id for a person and
 *  If Ranking is enabled for the grade ladder it will return RankEnabled
 *  else it will return RankDisabled
 */
function is_ranking_enabled_for_person(p_person_id            in number
                                      ,p_business_group_id    in number
                                      ,p_effective_date       in date)
return varchar2 is
l_proc constant    varchar2(72) := g_package||'is_ranking_enabled_for_person';
l_present_flag     varchar2(1) ;
l_persons_pgm_id   number ;
l_persons_plip_id  number ;
l_prog_style       varchar2(30) ;
l_rank_enabled     varchar2(10) ;
l_return_value     varchar2(30) ;
begin
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- fetch the grade ladder of the person
--
   pqh_gsp_post_process.get_persons_gl_and_grade(p_person_id          =>  p_person_id
                                                ,p_business_group_id  =>  p_business_group_id
                                                ,p_effective_date     =>  p_effective_date
                                                ,p_persons_pgm_id     =>  l_persons_pgm_id
                                                ,p_persons_plip_id    =>  l_persons_plip_id
                                                ,p_prog_style         =>  l_prog_style
                                                );
--
-- get rank status for the grade ladder
--
l_rank_enabled := get_grade_ladder_option (l_persons_pgm_id , 'RANK_ENABLED') ;

if ( l_rank_enabled = 'Y') then
l_return_value:='RankEnabled';
else
l_return_value:='RankDisabled';
end if ;

return l_return_value ;

end is_ranking_enabled_for_person;

End pqh_rank_utility;

/
