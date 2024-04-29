--------------------------------------------------------
--  DDL for Package PQH_CET_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CET_RKU" AUTHID CURRENT_USER as
/* $Header: pqcetrhi.pkh 120.2 2005/10/01 10:57:00 scnair noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_copy_entity_txn_id             in number
 ,p_transaction_category_id        in number
 ,p_txn_category_attribute_id           in number
 ,p_context_business_group_id          in number
 ,p_datetrack_mode                     in varchar2
 ,p_context                        in varchar2
 ,p_action_date                    in  date
 ,p_src_effective_date             in  date
 ,p_number_of_copies               in number
 ,p_display_name                   in varchar2
 ,p_replacement_type_cd            in varchar2
 ,p_start_with                     in varchar2
 ,p_increment_by                   in number
 ,p_status                         in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_transaction_category_id_o      in number
 ,p_txn_category_attribute_id_o         in number
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
end pqh_cet_rku;

 

/
