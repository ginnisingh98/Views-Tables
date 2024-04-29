--------------------------------------------------------
--  DDL for Package AME_APPROVER_TYPE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_TYPE_BK2" AUTHID CURRENT_USER as
/* $Header: amaptapi.pkh 120.3 2006/09/28 14:03:55 avarri noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_approver_type_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_type_b
  (p_approver_type_id        in     number
  ,p_object_version_number   in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_approver_type_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_type_a
  (p_approver_type_id        in     number
  ,p_object_version_number   in     number
  ,p_start_date              in     date
  ,p_end_date                in     date
  );

end ame_approver_type_bk2;

 

/
