--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_BK4" AUTHID CURRENT_USER as
/* $Header: amatrapi.pkh 120.3.12010000.2 2019/09/12 12:02:21 jaakhtar ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_attribute_usage_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute_usage_b
  (p_attribute_id                  in     number
  ,p_application_id            in     number
  ,p_is_static                     in     varchar2
  ,p_query_string                  in     varchar2
  ,p_value_set_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_attribute_usage_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_attribute_usage_a
  (p_attribute_id                  in     number
  ,p_application_id                in     number
  ,p_is_static                     in     varchar2
  ,p_query_string                  in     varchar2
  ,p_value_set_id                  in     number
  ,p_object_version_number         in     number
  ,p_start_date                    in     date
  ,p_end_date                        in     date
  );
--
--
end ame_attribute_bk4;

/
