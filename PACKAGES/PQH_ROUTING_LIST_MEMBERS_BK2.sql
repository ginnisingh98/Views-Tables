--------------------------------------------------------
--  DDL for Package PQH_ROUTING_LIST_MEMBERS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROUTING_LIST_MEMBERS_BK2" AUTHID CURRENT_USER as
/* $Header: pqrlmapi.pkh 120.1 2005/10/02 02:27:30 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_routing_list_member_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list_member_b
  (
   p_role_id                        in  number
  ,p_routing_list_id                in  number
  ,p_routing_list_member_id         in  number
  ,p_seq_no                         in  number
  ,p_approver_flag                  in  varchar2
  ,p_enable_flag		    in  varchar2
  ,p_object_version_number          in  number
  ,p_user_id                        in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_routing_list_member_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_routing_list_member_a
  (
   p_role_id                        in  number
  ,p_routing_list_id                in  number
  ,p_routing_list_member_id         in  number
  ,p_seq_no                         in  number
  ,p_approver_flag                  in  varchar2
  ,p_enable_flag		    in  varchar2
  ,p_object_version_number          in  number
  ,p_user_id                        in  number
  ,p_effective_date                 in  date
  );
--
end PQH_ROUTING_LIST_MEMBERS_bk2;

 

/
