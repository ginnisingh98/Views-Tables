--------------------------------------------------------
--  DDL for Package HR_WIP_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WIP_TXNS" 
/* $Header: hrwiptxn.pkh 115.2 2003/01/17 21:59:26 pbrimble ship $ */
AUTHID CURRENT_USER AS
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_transaction_creator >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_transaction_creator(p_creator_user_id in fnd_user.user_id%TYPE
                                 ,p_current_user_id in fnd_user.user_id%TYPE
                                 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Function create_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ) RETURN hr_wip_transactions.transaction_id%TYPE;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure create_transaction
     (p_item_type             IN wf_items.item_type%TYPE
     ,p_item_key              IN wf_items.item_key%TYPE
     ,p_function_id           IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id       IN fnd_user.user_id%TYPE
     ,p_dml_mode              IN hr_wip_transactions.dml_mode%TYPE
     ,p_vo_xml                IN VARCHAR2
     ,p_context_display_text  IN hr_wip_transactions.context_display_text%TYPE
     ,p_transaction_id        OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
     );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_query_only_transaction >-----------------|
-- ----------------------------------------------------------------------------
Function create_query_only_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ) RETURN hr_wip_transactions.transaction_id%TYPE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_query_only_transaction >-----------------|
-- ----------------------------------------------------------------------------
Procedure create_query_only_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_function_id          IN fnd_form_functions.function_id%TYPE
     ,p_creator_user_id      IN fnd_user.user_id%TYPE
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
     ,p_transaction_id       OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
     );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later
     (p_item_type       IN wf_items.item_type%TYPE
     ,p_item_key        IN wf_items.item_key%TYPE
     ,p_current_user_id IN fnd_user.user_id%TYPE
     ,p_vo_xml          IN VARCHAR2
     ,p_sub_state       IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
     ,p_transaction_id        OUT NOCOPY hr_wip_transactions.transaction_id%TYPE
       );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_sub_state       IN hr_wip_transactions.sub_state%TYPE
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
       );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< save_for_later_append >-----------------------|
-- ----------------------------------------------------------------------------
Procedure save_for_later_append
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< pending_approval >-----------------------|
-- ----------------------------------------------------------------------------
Procedure pending_approval
       (p_item_type       IN wf_items.item_type%TYPE
       ,p_item_key        IN wf_items.item_key%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
       );
-- ----------------------------------------------------------------------------
-- |-----------------------< pending_approval >-----------------------|
-- ----------------------------------------------------------------------------
Procedure pending_approval
       (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
       ,p_current_user_id IN fnd_user.user_id%TYPE
       ,p_vo_xml          IN VARCHAR2
       ,p_dml_mode        IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
       ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
       );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reject_for_correction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure reject_for_correction
              (p_item_type       IN wf_items.item_type%TYPE
              ,p_item_key        IN wf_items.item_key%TYPE
              );
-- ----------------------------------------------------------------------------
-- |-----------------------< reject_for_correction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure reject_for_correction
              (p_transaction_id  IN hr_wip_transactions.transaction_id%TYPE
              );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_transaction
              (p_item_type             IN wf_items.item_type%TYPE
              ,p_item_key              IN wf_items.item_key%TYPE
              );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure delete_transaction
             (p_transaction_id        IN hr_wip_transactions.transaction_id%TYPE
             );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_transaction
     (p_item_type            IN wf_items.item_type%TYPE
     ,p_item_key             IN wf_items.item_key%TYPE
     ,p_state                IN hr_wip_transactions.state%TYPE
     ,p_sub_state            IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
     );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction >-----------------------|
-- ----------------------------------------------------------------------------
Procedure update_transaction
     (p_transaction_id       IN hr_wip_transactions.transaction_id%TYPE
     ,p_state                IN hr_wip_transactions.state%TYPE
     ,p_sub_state            IN hr_wip_transactions.sub_state%TYPE
     ,p_dml_mode             IN hr_wip_transactions.dml_mode%TYPE
                             default hr_api.g_varchar2
     ,p_vo_xml               IN VARCHAR2
     ,p_context_display_text IN hr_wip_transactions.context_display_text%TYPE
                             default hr_api.g_varchar2
     );
--
END hr_wip_txns;

 

/
