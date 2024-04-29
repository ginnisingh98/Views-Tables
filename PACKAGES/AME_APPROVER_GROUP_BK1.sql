--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_BK1" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_approver_group_b>--------------------|
-- ----------------------------------------------------------------------------
--
--
procedure create_ame_approver_group_b
                         (p_name           in  varchar2
                         ,p_description    in  varchar2
                         ,p_is_static      in  varchar2
                         ,p_query_string   in  varchar2
                         );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_approver_group_a>---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_approver_group_a
                   (p_name                  in  varchar2
                   ,p_description           in  varchar2
                   ,p_is_static             in  varchar2
                   ,p_query_string          in  varchar2
                   ,p_approval_group_id     in  number
                   ,p_object_version_number in  number
                   ,p_start_date            in  date
                   ,p_end_date              in  date
                   );
end ame_approver_group_bk1;

/
