--------------------------------------------------------
--  DDL for Package AME_CONDITION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_BK3" AUTHID CURRENT_USER as
/* $Header: amconapi.pkh 120.2 2006/12/23 09:58:45 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_condition_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_condition_b(p_condition_id          in     number
                                ,p_object_version_number in     number
                                );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_condition_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_condition_a(p_condition_id          in     number
                                ,p_object_version_number in     number
                                ,p_start_date            in     date
                                ,p_end_date              in     date
                                );
--
end ame_condition_bk3;

/
