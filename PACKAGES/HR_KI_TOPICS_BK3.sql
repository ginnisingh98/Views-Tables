--------------------------------------------------------
--  DDL for Package HR_KI_TOPICS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPICS_BK3" AUTHID CURRENT_USER as
/* $Header: hrtpcapi.pkh 120.1 2005/10/02 02:06:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_topic_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic_b
  (
   p_topic_id                      in     number
  ,p_object_version_number         in     number

  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_topic_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic_a
  (
   p_topic_id                      in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_topics_bk3;

 

/
