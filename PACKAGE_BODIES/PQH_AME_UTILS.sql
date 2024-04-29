--------------------------------------------------------
--  DDL for Package Body PQH_AME_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_AME_UTILS" AS
/* $Header: pqameutl.pkb 120.0 2005/05/29 01:24:12 appldev noship $ */
--
--
--
g_package  constant varchar2(30) := 'pqh_ame_utils.';
g_debug constant boolean := hr_utility.debug_enabled;

-- ---------------------------------------------------------------------------
-- ---------------<Populate_Txn_Details> -------------------------------------
-- ---------------------------------------------------------------------------
procedure populate_txn_details (
         p_transaction_id in number) is

  cursor csr_txn is
  select item_type ,item_key, process_name, selected_person_id, creator_person_id
  from   hr_api_transactions
  where  transaction_id  =  p_transaction_id;
  l_proc varchar2(72);
  begin
     l_proc := g_package||'populate_txn_details';
     hr_utility.set_location('Entering:'||l_proc, 5);
     if (g_transaction_id = p_transaction_id ) then
       return;
     else
        g_transaction_id := p_transaction_id;
        open csr_txn;
        fetch csr_txn into g_item_type, g_item_key, g_process_name,
              g_person_id, g_creator_person_id;
        close csr_txn;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc, 10);
   Exception
     WHEN others THEN
       Raise;
 end populate_txn_details;


-- ---------------------------------------------------------------------------
-- ---------------<Get_Item_Type> --------------------------------------------
-- ---------------------------------------------------------------------------
  function get_item_type( p_transaction_id in varchar2) return varchar2 is
  l_proc varchar2(72);
   begin
     l_proc := g_package||'get_item_type';
     hr_utility.set_location('Entering:'||l_proc, 5);
 populate_txn_details(p_transaction_id);
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 return g_item_type;
   Exception
     WHEN others THEN
       wf_core.context(g_package,'.get_final_approver',g_item_type,g_item_key);
       Raise;
   end;
   --
-- ---------------------------------------------------------------------------
-- ---------------<Get_Item_Key> ---------------------------------------------
-- ---------------------------------------------------------------------------
   function get_item_key( p_transaction_id in varchar2) return varchar2   is
  l_proc varchar2(72);
    begin
     l_proc := g_package||'get_item_key';
     hr_utility.set_location('Entering:'||l_proc, 5);
 populate_txn_details(p_transaction_id);
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 return g_item_key;
   Exception
     WHEN others THEN
       wf_core.context(g_package,'.get_final_approver',g_item_type,g_item_key);
       Raise;
   end;
   --
-- ---------------------------------------------------------------------------
-- ---------------<Get_Process_Name> -----------------------------------------
-- ---------------------------------------------------------------------------
   function get_process_name( p_transaction_id in varchar2) return varchar2 is
  l_proc varchar2(72);
   begin
     l_proc := g_package||'get_process_name';
     hr_utility.set_location('Entering:'||l_proc, 5);
populate_txn_details(p_transaction_id);
   hr_utility.set_location(' Leaving:'||l_proc, 10);
 return g_process_name;

   Exception
     WHEN others THEN
       wf_core.context(g_package,'.get_final_approver',g_item_type,g_item_key);
       Raise;
   end;
   --
-- ---------------------------------------------------------------------------
-- ---------------<Get_Final_Approver> ---------------------------------------
-- ---------------------------------------------------------------------------
   function get_final_approver( p_transaction_id in varchar2) return varchar2 is
   approvers ame_util.approversTable;
   l_txn_type   varchar2(240);
   l_txn_app_id number(18);
   l_cnt number;

   l_creator_person_id number(18);
   l_final_approver_id number(18);
   l_response          varchar2(10);
  l_proc varchar2(72);
   begin
     l_proc := g_package||'get_final_approver';
     hr_utility.set_location('Entering:'||l_proc, 5);
      populate_txn_details(p_transaction_id);

      l_creator_person_id := g_person_id;
      l_final_approver_id := g_person_id;

      l_response := hr_approval_custom.Check_Final_approver(
                            p_forward_to_person_id => l_creator_person_id,
                            p_person_id            => l_creator_person_id );

      while l_response='N' loop

         l_final_approver_id := hr_approval_custom.Get_Next_Approver(
                                       p_person_id =>l_final_approver_id);

         l_response := hr_approval_custom.Check_Final_approver(
                            p_forward_to_person_id => l_final_approver_id,
                            p_person_id            => l_creator_person_id );

      end loop;
   hr_utility.set_location(' Leaving:'||l_proc, 10);

      return l_final_approver_id;

   Exception
     WHEN others THEN
       wf_core.context(g_package,'.get_final_approver',g_item_type,g_item_key);
       Raise;
   end;
   --
-- ---------------------------------------------------------------------------
-- ---------------<Get_Requestor_Person_Id> ----------------------------------
-- ---------------------------------------------------------------------------
   function get_requestor_person_id( p_transaction_id in varchar2) return varchar2 is
   cursor csr_mgr (c_person_id in number) is
   select supervisor_id
   from   per_all_assignments_f
   where  person_id = c_person_id
   and    sysdate between effective_start_date and effective_end_date;
   --
   l_supervisor_id  number(18);
   --
  l_proc varchar2(72);
   begin
     l_proc := g_package||'get_requestor_person_id';
     hr_utility.set_location('Entering:'||l_proc, 5);
     populate_txn_details(p_transaction_id);
     open  csr_mgr(g_person_id);
     fetch csr_mgr into l_supervisor_id;
     close csr_mgr ;

   hr_utility.set_location(' Leaving:'||l_proc, 10);
     return g_person_id;

   Exception
     WHEN others THEN
       wf_core.context(g_package,'.get_final_approver',g_item_type,g_item_key);
       Raise;
   end;


END; -- Package Body PQH_AME_UTILS

/
