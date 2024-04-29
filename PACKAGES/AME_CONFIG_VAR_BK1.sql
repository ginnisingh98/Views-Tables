--------------------------------------------------------
--  DDL for Package AME_CONFIG_VAR_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONFIG_VAR_BK1" AUTHID CURRENT_USER as
/* $Header: amcfvapi.pkh 120.3 2006/12/23 09:58:54 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_config_variable_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_config_variable_b
  (p_application_id              in     number
  ,p_variable_name               in     varchar2
  ,p_variable_value              in     varchar2
  ,p_object_version_number       in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_config_variable_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_config_variable_a
  (p_application_id              in     number
  ,p_variable_name               in     varchar2
  ,p_variable_value              in     varchar2
  ,p_object_version_number       in     number
  ,p_start_date                  in     date
  ,p_end_date                    in     date
  );
--
end ame_config_var_bk1;

/
