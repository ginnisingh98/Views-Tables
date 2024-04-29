--------------------------------------------------------
--  DDL for Package AME_APPROVER_GROUP_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_GROUP_BK3" AUTHID CURRENT_USER as
/* $Header: amapgapi.pkh 120.4 2006/12/23 09:54:34 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_approver_group_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_group_b
                    (p_approval_group_id        in  number
                    ,p_object_version_number    in  number
                    );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_approver_group_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_group_a
                  (p_approval_group_id       in  number
                  ,p_object_version_number   in  number
                  ,p_start_date              in  date
                  ,p_end_date                in  date
                  );
--
end ame_approver_group_bk3;

/
