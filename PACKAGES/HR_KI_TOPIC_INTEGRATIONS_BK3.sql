--------------------------------------------------------
--  DDL for Package HR_KI_TOPIC_INTEGRATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPIC_INTEGRATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: hrtisapi.pkh 120.2 2008/01/25 13:49:50 avarri ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_topic_integration_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic_integration_b
  (
   p_topic_integrations_id         in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_topic_integration_a>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic_integration_a
  (
   p_topic_integrations_id         in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_topic_integrations_bk3;

/
