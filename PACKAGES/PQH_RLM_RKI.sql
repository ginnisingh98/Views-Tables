--------------------------------------------------------
--  DDL for Package PQH_RLM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLM_RKI" AUTHID CURRENT_USER as
/* $Header: pqrlmrhi.pkh 120.0 2005/05/29 02:31:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end pqh_rlm_rki;

 

/
