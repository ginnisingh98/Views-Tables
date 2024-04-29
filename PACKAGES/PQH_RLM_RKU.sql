--------------------------------------------------------
--  DDL for Package PQH_RLM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLM_RKU" AUTHID CURRENT_USER as
/* $Header: pqrlmrhi.pkh 120.0 2005/05/29 02:31:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_role_id                        in number
 ,p_routing_list_id                in number
 ,p_routing_list_member_id         in number
 ,p_seq_no                         in number
 ,p_approver_flag                  in varchar2
 ,p_enable_flag                    in varchar2
 ,p_object_version_number          in number
 ,p_user_id                        in number
 ,p_effective_date                 in date
 ,p_role_id_o                      in number
 ,p_routing_list_id_o              in number
 ,p_seq_no_o                       in number
 ,p_approver_flag_o                in varchar2
 ,p_enable_flag_o                  in varchar2
 ,p_object_version_number_o        in number
 ,p_user_id_o                      in number
  );
--
end pqh_rlm_rku;

 

/
