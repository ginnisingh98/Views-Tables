--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_BK2" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_approver_group_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_approver_group_b
        (p_approval_group_id        in  number
        ,p_language_code            in  varchar2
        ,p_description              in  varchar2
        ,p_is_static                in  varchar2
        ,p_query_string             in  varchar2
        ,p_object_version_number    in  number
        );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_approver_group_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_approver_group_a
        (p_approval_group_id        in  number
        ,p_language_code            in  varchar2
        ,p_description              in  varchar2
        ,p_is_static                in  varchar2
        ,p_query_string             in  varchar2
        ,p_object_version_number    in  number
        ,p_start_date               in  date
        ,p_end_date                 in  date
        );
--
end ame_approver_group_bk2;

/
