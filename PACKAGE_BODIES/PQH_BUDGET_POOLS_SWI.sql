--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_POOLS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_POOLS_SWI" As
/* $Header: pqbplswi.pkb 115.7 2003/04/28 11:41:20 kgowripe noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_budget_pools_swi.';
--
--
PROCEDURE delete_trxn_amts(p_transaction_type in varchar2 , p_bdgt_trnx_amount_id in number) is

/*

This is a private function which deletes Donor / Receiver Transaction Amount
for a given bdgt_trnx_amount_id

Transaction Type :
=================
DD - Donor Details
RD - Receiver Details

*/
cursor csr_bdgt_trnx_amt is
select reallocation_id, object_version_number
from   pqh_bdgt_pool_realloctions
where  reallocation_id = p_bdgt_trnx_amount_id
and    transaction_type = p_transaction_type;

cursor csr_receiver_prd_count is
select nvl(count(reallocation_id),0)
from pqh_bdgt_pool_realloctions
where txn_detail_id in (select txn_detail_id
                        from pqh_bdgt_pool_realloctions
                        where reallocation_id = p_bdgt_trnx_amount_id
                        and transaction_type = 'RD');
/* Modified by  mvanakda
   Bug No : 2924364
   Fix :  Modified the cursor csr_receiver_id to fetch the receiver id
   and ovn based on receiver period id (p_bdgt_trnx_amount_id)

*/
/* mvankada
cursor csr_receiver_id is
select txn_detail_id, object_version_number
from pqh_bdgt_pool_realloctions
where reallocation_id = p_bdgt_trnx_amount_id
and transaction_type = 'RD';
*/

cursor csr_receiver_id is
select reallocation_id, object_version_number
from pqh_bdgt_pool_realloctions
where reallocation_id in ( select TXN_DETAIL_ID
                           from pqh_bdgt_pool_realloctions
                           where reallocation_id = p_bdgt_trnx_amount_id
                           and transaction_type = 'RD');

l_ovn number(15);
l_bdgt_trnx_amount_id number;
l_count number;
l_receiver_id number;
l_receiver_ovn number;
l_proc    varchar2(72) := g_package ||'delete_trxn_amts';

BEGIN

  /*
      If the Receiver has only one period then delete receiver and receiver period.
      If the reciver has more than one receiver periods then delete only the given receiver period.
   */
 hr_utility.set_location(' Entering:' || l_proc,10);
If p_transaction_type = 'RD' then
   open csr_receiver_prd_count;
   fetch csr_receiver_prd_count into l_count;
   close csr_receiver_prd_count;
   hr_utility.set_location(' Count :' || l_count,15);

   open csr_receiver_id;
   fetch csr_receiver_id into l_receiver_id, l_receiver_ovn;
   close csr_receiver_id;

End If;

open csr_bdgt_trnx_amt;
fetch csr_bdgt_trnx_amt into l_bdgt_trnx_amount_id, l_ovn;
close csr_bdgt_trnx_amt;
hr_utility.set_location(' l_bdgt_trnx_amount_id :' || l_bdgt_trnx_amount_id,20);
--
-- Added IF condition to call delete API only when there is a row for the ID passed
--
IF l_bdgt_trnx_amount_id IS NOT NULL THEN
   pqh_bdgt_pool_realloctions_api.delete_realloc_txn_period
     (p_validate   		=> false
     ,p_reallocation_period_id     => l_bdgt_trnx_amount_id
     ,p_object_version_number      => l_ovn
     );
END IF;
  If (p_transaction_type = 'RD') and (l_count = 1) then
    pqh_bdgt_pool_realloctions_api.delete_realloc_txn_dtl
          ( p_validate   		 => false
           ,p_txn_detail_id              => l_receiver_id
           ,p_object_version_number      => l_receiver_ovn
           );
  End if;
   hr_utility.set_location(' Leaving:' || l_proc,25);
END delete_trxn_amts;

PROCEDURE delete_trxn_dtls(p_transaction_type in varchar2 , p_bdgt_trnx_detail_id in number) is

/*
This is a private function which Deletes Donor / Receiver  Transaction Details
for a given bdgt_trnx_detail_id
Transaction Type :
=================
D - Donor
R - Receiver
*/

cursor csr_donor_receiver_details is
select reallocation_id,transaction_type
from pqh_bdgt_pool_realloctions
where txn_detail_id = p_bdgt_trnx_detail_id;

cursor csr_bdgt_trnx_dtl is
select reallocation_id,object_version_number
from   pqh_bdgt_pool_realloctions
where  reallocation_id = p_bdgt_trnx_detail_id
and    transaction_type = p_transaction_type;

l_ovn number(15);
l_bdgt_trnx_detail_id   number;
l_bdgt_trnx_amt_id      number;
l_transaction_type      varchar2(15);
l_proc    varchar2(72) := g_package ||'delete_trxn_dtls';

BEGIN
 hr_utility.set_location(' Entering:' || l_proc,10);
If p_transaction_type in ('D','R') then
   open csr_donor_receiver_details;
   loop
      fetch csr_donor_receiver_details into l_bdgt_trnx_amt_id,l_transaction_type;
      exit when csr_donor_receiver_details%notfound;


      /* Delete all Donor/Receiver Amount Details */
      hr_utility.set_location(' l_bdgt_trnx_amt_id:' || l_bdgt_trnx_amt_id,15);
      hr_utility.set_location(' l_transaction_type:' || l_transaction_type,20);
      delete_trxn_amts
        (p_transaction_type    => l_transaction_type,
         p_bdgt_trnx_amount_id => l_bdgt_trnx_amt_id);

    end loop;
    close csr_donor_receiver_details;

   /* Delete Donor/Receiver Details */
     open csr_bdgt_trnx_dtl;
     fetch csr_bdgt_trnx_dtl into l_bdgt_trnx_detail_id, l_ovn;
     close csr_bdgt_trnx_dtl;
   hr_utility.set_location(' l_bdgt_trnx_detail_id :' || l_bdgt_trnx_detail_id ,25);
     if l_bdgt_trnx_detail_id is not null then

      pqh_bdgt_pool_realloctions_api.delete_realloc_txn_dtl
          ( p_validate   		 => false
           ,p_txn_detail_id        => l_bdgt_trnx_detail_id
           ,p_object_version_number      => l_ovn
           );
      end if;
 end if;
  hr_utility.set_location(' Leaving:' || l_proc,30);
END delete_trxn_dtls;


PROCEDURE delete_bgt_transaction (p_transaction_id in number) is

/*
This is a private function which Deletes Budget Transaction for
a given Budget Transaction Id
*/

cursor csr_bdgt_trnx_details  is
select reallocation_id ,transaction_type
from pqh_bdgt_pool_realloctions
where pool_id = p_transaction_id;

cursor csr_bdgt_transaction is
select pool_id,object_version_number
from   pqh_budget_pools
where  pool_id = p_transaction_id;

l_ovn number;
l_transaction_id number;
l_transaction_type varchar2(15);
l_proc    varchar2(72) := g_package ||'delete_bgt_transaction';

BEGIN
 hr_utility.set_location(' Entering:' || l_proc,10);
/* fetch all budget transaction details */
open csr_bdgt_trnx_details;
loop
   fetch csr_bdgt_trnx_details into l_transaction_id , l_transaction_type ;
   exit when csr_bdgt_trnx_details%notfound;
    hr_utility.set_location(' l_transaction_id :' || l_transaction_id ,15);
    hr_utility.set_location(' l_transaction_type :' || l_transaction_type ,20);
  delete_trxn_dtls
    (p_transaction_type    => l_transaction_type
    ,p_bdgt_trnx_detail_id => l_transaction_id );
 end loop;
 close csr_bdgt_trnx_details;


open csr_bdgt_transaction;
fetch csr_bdgt_transaction into l_transaction_id, l_ovn;
close csr_bdgt_transaction;
    hr_utility.set_location(' l_transaction_id :' || l_transaction_id ,25);
if l_transaction_id is not null then
  pqh_budget_pools_api.delete_reallocation_txn
    (p_validate   		=> false
    ,p_transaction_id             => l_transaction_id
    ,p_object_version_number      => l_ovn
    ,p_effective_date             => sysdate
    );
end if;
  hr_utility.set_location(' Leaving:' || l_proc,30);
END delete_bgt_transaction;



PROCEDURE delete_bgt_folder(p_folder_id in number) is
/*
This is a private function which Deletes Budget Transaction for a
given Budget Folder Id
*/

cursor csr_bdgt_transaction is
select pool_id
from   pqh_budget_pools
where  parent_pool_id = p_folder_id;


cursor csr_bdgt_folder is
select pool_id,object_version_number
from   pqh_budget_pools
where  pool_id = p_folder_id;

--added by kgowripe for bug#2875736
-- Modifed start with caluse for bug 2880128
Cursor csr_process_log_ids IS
SELECT process_log_id,object_version_number
FROM   pqh_process_log
WHERE    module_cd = 'BUDGET_REALLOCATION'
START WITH process_log_id = (SELECT process_log_id
                             FROM   pqh_process_log
			     WHERE  module_cd = 'BUDGET_REALLOCATION'
		             AND    master_process_log_id IS NULL
		             AND    txn_id = p_folder_id)
CONNECT BY master_process_log_id = PRIOR process_log_id
ORDER BY level DESC;

-- Added by mvankada
-- Bug : 2880151
Cursor csr_txn_cat_id IS
Select wf_transaction_category_id
From pqh_budget_pools
Where pool_id = p_folder_id;

l_ovn number;
l_folder_id number;
l_transaction_id number;
l_itemkey varchar2(2000);
l_txn_cat_id number;
l_proc    varchar2(72) := g_package ||'delete_trxn_dtls';

BEGIN
 hr_utility.set_location(' Entering:' || l_proc,10);
 open csr_txn_cat_id;
 fetch csr_txn_cat_id into l_txn_cat_id;
 close csr_txn_cat_id;
  hr_utility.set_location(' Txn Cat Id :' || l_txn_cat_id , 12);
  if l_txn_cat_id is not null then
    l_itemkey := l_txn_cat_id || '-' || p_folder_id;
  end if;
  hr_utility.set_location(' Item Key :' || l_itemkey , 12);
/* fetch all budget transactions*/
open csr_bdgt_transaction;
loop
   fetch csr_bdgt_transaction into l_transaction_id;
   exit when csr_bdgt_transaction%notfound;
   delete_bgt_transaction
    (p_transaction_id    => l_transaction_id);
 end loop;
 close csr_bdgt_transaction;

open csr_bdgt_folder;
fetch csr_bdgt_folder into l_folder_id, l_ovn;
close csr_bdgt_folder;
 hr_utility.set_location(' Folder Id :' || l_folder_id ,15);

if l_folder_id is not null then

  pqh_budget_pools_api.delete_reallocation_folder
    (p_validate   		=> false
    ,p_folder_id                  => l_folder_id
    ,p_object_version_number      => l_ovn
    ,p_effective_date             => sysdate
     );
end if;

--Added by kgowripe for bug#2875736
--For deleting the process log entries for a folder
  FOR plg IN csr_process_log_ids
  LOOP
 hr_utility.set_location(' Process Log Id :' || plg.process_log_id ,25);
 hr_utility.set_location(' OVN :' || plg.object_version_number ,35);

    pqh_process_log_api.delete_process_log(p_process_log_id => plg.process_log_id
                                          ,p_object_version_number=> plg.object_version_number
                                          ,p_effective_date => sysdate);
  END LOOP;
-- Added by mvanakda
-- Bug : 2880151
hr_utility.set_location(' call to delete folder from inbox:' || l_proc,40);
wf_engine.AbortProcess(itemtype     => 'PQHGEN',
                        itemkey      => l_itemkey  ,
                        process      => 'PQH_ROUTING',
                        result       => null);

    hr_utility.set_location(' Leaving:' || l_proc,45);
Exception
  When others then
    Null;
END delete_bgt_folder;
--

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_folder_id                       out nocopy number
  ,p_name                         in     varchar2
  ,p_budget_version_id            in     number
  ,p_budget_unit_id               in     number
  ,p_entity_type                  in     varchar2
  ,p_approval_status              in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_wf_transaction_category_id   in number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_reallocation_folder';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_reallocation_folder_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.create_reallocation_folder
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_folder_id                    => p_folder_id
    ,p_name                         => p_name
    ,p_budget_version_id            => p_budget_version_id
    ,p_budget_unit_id               => p_budget_unit_id
    ,p_entity_type                  => p_entity_type
    ,p_approval_status              => p_approval_status
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_wf_transaction_category_id   => p_wf_transaction_category_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_reallocation_folder_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_folder_id                    := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_reallocation_folder_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_folder_id                    := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_reallocation_folder;
-- ----------------------------------------------------------------------------
-- |------------------------< create_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id                  out nocopy number
  ,p_name                         in     varchar2
  ,p_parent_folder_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_reallocation_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_reallocation_txn_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.create_reallocation_txn
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_transaction_id               => p_transaction_id
    ,p_name                         => p_name
    ,p_parent_folder_id               => p_parent_folder_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_reallocation_txn_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_transaction_id               := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_reallocation_txn_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_transaction_id               := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_reallocation_txn;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_folder_id                    in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_reallocation_folder';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_reallocation_folder_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.delete_reallocation_folder
    (p_validate                     => l_validate
    ,p_folder_id                    => p_folder_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_reallocation_folder_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_reallocation_folder_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_reallocation_folder;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_transaction_id               in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_reallocation_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_reallocation_txn_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.delete_reallocation_txn
    (p_validate                     => l_validate
    ,p_transaction_id               => p_transaction_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => p_effective_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_reallocation_txn_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_reallocation_txn_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_reallocation_txn;
-- ----------------------------------------------------------------------------
-- |----------------------< update_reallocation_folder >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_reallocation_folder
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_folder_id                    in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_budget_version_id            in     number    default hr_api.g_number
  ,p_budget_unit_id               in     number    default hr_api.g_number
  ,p_entity_type                  in     varchar2  default hr_api.g_varchar2
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_wf_transaction_category_id   in number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_reallocation_folder';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_reallocation_folder_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.update_reallocation_folder
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_folder_id                    => p_folder_id
    ,p_name                         => p_name
    ,p_budget_version_id            => p_budget_version_id
    ,p_budget_unit_id               => p_budget_unit_id
    ,p_entity_type                  => p_entity_type
    ,p_approval_status              => p_approval_status
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_wf_transaction_category_id   => p_wf_transaction_category_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_reallocation_folder_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_reallocation_folder_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_reallocation_folder;
-- ----------------------------------------------------------------------------
-- |------------------------< update_reallocation_txn >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_reallocation_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_parent_folder_id               in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_reallocation_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_reallocation_txn_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_budget_pools_api.update_reallocation_txn
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_transaction_id               => p_transaction_id
    ,p_name                         => p_name
    ,p_parent_folder_id               => p_parent_folder_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_reallocation_txn_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_reallocation_txn_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_reallocation_txn;

PROCEDURE bgt_realloc_delete(p_node_type  in varchar2, p_node_id in number)
is

/*
Node Type :
==========
F-  Folder
T - Transaction
D - Donor
DD - Donor Details
R - Receiver
RD - Receiver Details
*/
l_proc    varchar2(72) := g_package ||'bgt_realloc_delete';
BEGIN

hr_utility.set_location(' Entering:' || l_proc,10);
hr_utility.set_location(' Node Type :' || p_node_type ,20);
--added by kgowripe for bug#2875736
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;

If p_node_type in ('DD','RD') then
  delete_trxn_amts
   ( p_transaction_type    => p_node_type
    ,p_bdgt_trnx_amount_id => p_node_id);

Elsif p_node_type in ('D','R') then
  delete_trxn_dtls
      (p_transaction_type    => p_node_type
      ,p_bdgt_trnx_detail_id => p_node_id);

Elsif  p_node_type = 'T' then
 delete_bgt_transaction
   (p_transaction_id => p_node_id);

Else
   delete_bgt_folder
   (p_folder_id => p_node_id);

End if;
hr_utility.set_location(' Leaving:' || l_proc,30);

END bgt_realloc_delete;
end pqh_budget_pools_swi;

/
