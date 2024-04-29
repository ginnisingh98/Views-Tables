--------------------------------------------------------
--  DDL for Package AME_CONDITION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_BK1" AUTHID CURRENT_USER as
/* $Header: amconapi.pkh 120.2 2006/12/23 09:58:45 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ame_condition_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_condition_b(p_condition_key       in     varchar2
                                ,p_condition_type      in     varchar2
                                ,p_attribute_id        in     number
                                ,p_parameter_one       in     varchar2
                                ,p_parameter_two       in     varchar2
                                ,p_parameter_three     in     varchar2
                                ,p_include_upper_limit in     varchar2
                                ,p_include_lower_limit in     varchar2
                                ,p_string_value        in     varchar2
                                );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ame_condition_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_condition_a(p_condition_key             in     varchar2
                                ,p_condition_type            in     varchar2
                                ,p_attribute_id              in     number
                                ,p_parameter_one             in     varchar2
                                ,p_parameter_two             in     varchar2
                                ,p_parameter_three           in     varchar2
                                ,p_include_upper_limit       in     varchar2
                                ,p_include_lower_limit       in     varchar2
                                ,p_string_value              in     varchar2
                                ,p_condition_id              in     number
                                ,p_con_object_version_number in     number
                                ,p_con_start_date            in     date
                                ,p_con_end_date              in     date
                                ,p_stv_object_version_number in     number
                                ,p_stv_start_date            in     date
                                ,p_stv_end_date              in     date
                                );
--
end ame_condition_bk1;

/
