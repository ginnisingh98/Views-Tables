--------------------------------------------------------
--  DDL for Package AME_CONDITION_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_BK4" AUTHID CURRENT_USER as
/* $Header: amconapi.pkh 120.2 2006/12/23 09:58:45 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_string_value_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_string_value_b(p_condition_id          in     number
                                 ,p_string_value          in     varchar2
                                 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_string_value_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_string_value_a(p_condition_id          in     number
                                   ,p_string_value          in     varchar2
                                   ,p_object_version_number in     number
                                   ,p_start_date            in     date
                                   ,p_end_date              in     date
                                   );
--
end ame_condition_bk4;

/
