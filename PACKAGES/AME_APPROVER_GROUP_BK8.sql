--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_BK8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_BK8" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_approver_group_item_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approver_group_item_b
                                    (p_approval_group_item_id   in  number
                                    ,p_object_version_number    in  number
                                    );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_approver_group_item_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approver_group_item_a
        (p_approval_group_item_id  in  number
        ,p_object_version_number   in  number
        ,p_start_date              in  date
        ,p_end_date                in  date
        );
--
end ame_approver_group_bk8;

/
