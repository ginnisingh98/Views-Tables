--------------------------------------------------------
--  DDL for Package AME_APPROVER_TYPE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_APPROVER_TYPE_BK1" AUTHID CURRENT_USER as
/* $Header: amaptapi.pkh 120.3 2006/09/28 14:03:55 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_approver_type_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_approver_type_b
  (p_approver_type_id          in     number
  ,p_orig_system               in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_approver_type_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_approver_type_a
  (p_orig_system                  in     varchar2
  ,p_approver_type_id             in     number
  ,p_object_version_number        in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  );
--
end ame_approver_type_bk1;

 

/
