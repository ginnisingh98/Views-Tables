--------------------------------------------------------
--  DDL for Package HR_KI_TOPIC_INTEGRATIONS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPIC_INTEGRATIONS_BK1" AUTHID CURRENT_USER as
/* $Header: hrtisapi.pkh 120.2 2008/01/25 13:49:50 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_topic_integration_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_integration_b
  (
   p_topic_id                      in     number
  ,p_integration_id                in     number
  ,p_param_name1                   in     varchar2
  ,p_param_value1                  in     varchar2
  ,p_param_name2                   in     varchar2
  ,p_param_value2                  in     varchar2
  ,p_param_name3                   in     varchar2
  ,p_param_value3                  in     varchar2
  ,p_param_name4                   in     varchar2
  ,p_param_value4                  in     varchar2
  ,p_param_name5                   in     varchar2
  ,p_param_value5                  in     varchar2
  ,p_param_name6                   in     varchar2
  ,p_param_value6                  in     varchar2
  ,p_param_name7                   in     varchar2
  ,p_param_value7                  in     varchar2
  ,p_param_name8                   in     varchar2
  ,p_param_value8                  in     varchar2
  ,p_param_name9                   in     varchar2
  ,p_param_value9                  in     varchar2
  ,p_param_name10                  in     varchar2
  ,p_param_value10                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_topic_integration_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_integration_a
  (
   p_topic_id                      in     number
  ,p_integration_id                in     number
  ,p_param_name1                   in     varchar2
  ,p_param_value1                  in     varchar2
  ,p_param_name2                   in     varchar2
  ,p_param_value2                  in     varchar2
  ,p_param_name3                   in     varchar2
  ,p_param_value3                  in     varchar2
  ,p_param_name4                   in     varchar2
  ,p_param_value4                  in     varchar2
  ,p_param_name5                   in     varchar2
  ,p_param_value5                  in     varchar2
  ,p_param_name6                   in     varchar2
  ,p_param_value6                  in     varchar2
  ,p_param_name7                   in     varchar2
  ,p_param_value7                  in     varchar2
  ,p_param_name8                   in     varchar2
  ,p_param_value8                  in     varchar2
  ,p_param_name9                   in     varchar2
  ,p_param_value9                  in     varchar2
  ,p_param_name10                  in     varchar2
  ,p_param_value10                 in     varchar2
  ,p_topic_integrations_id         in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_topic_integrations_bk1;

/
