--------------------------------------------------------
--  DDL for Package AME_CONDITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_BK2" AUTHID CURRENT_USER as
/* $Header: amconapi.pkh 120.2 2006/12/23 09:58:45 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ame_condition_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_condition_b
  (p_condition_id                in     number
  ,p_parameter_one               in     varchar2
  ,p_parameter_two               in     varchar2
  ,p_parameter_three             in     varchar2
  ,p_include_upper_limit         in     varchar2
  ,p_include_lower_limit         in     varchar2
  ,p_object_version_number       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_ame_condition_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_condition_a
  (p_condition_id                in     number
  ,p_parameter_one               in     varchar2
  ,p_parameter_two               in     varchar2
  ,p_parameter_three             in     varchar2
  ,p_include_upper_limit         in     varchar2
  ,p_include_lower_limit         in     varchar2
  ,p_object_version_number       in     number
  ,p_start_date                  in     date
  ,p_end_date                    in     date
  );
--
end ame_condition_bk2;

/
