--------------------------------------------------------
--  DDL for Package PQH_CET_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CET_RKD" AUTHID CURRENT_USER as
/* $Header: pqcetrhi.pkh 120.2 2005/10/01 10:57:00 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_copy_entity_txn_id             in number
 ,p_transaction_category_id_o      in number
 ,p_txn_category_attribute_id_o    in number
 ,p_context_business_group_id_o        in number
 ,p_datetrack_mode_o                   in varchar2
 ,p_context_o                      in varchar2
 ,p_action_date_o                  in  date
 ,p_src_effective_date_o           in  date
 ,p_number_of_copies_o             in number
 ,p_display_name_o                 in varchar2
 ,p_replacement_type_cd_o          in varchar2
 ,p_start_with_o                   in varchar2
 ,p_increment_by_o                 in number
 ,p_status_o                       in varchar2
 ,p_object_version_number_o        in number
  );
--
end pqh_cet_rkd;

 

/
