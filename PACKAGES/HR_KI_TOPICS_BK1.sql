--------------------------------------------------------
--  DDL for Package HR_KI_TOPICS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPICS_BK1" AUTHID CURRENT_USER as
/* $Header: hrtpcapi.pkh 120.1 2005/10/02 02:06:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_topic_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_b
  (
   p_language_code                 in     varchar2
  ,p_topic_key                     in     varchar2
  ,p_handler                       in     varchar2
  ,p_name                          in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_topic_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_a
  (
   p_language_code                 in     varchar2
  ,p_topic_key                     in     varchar2
  ,p_handler                       in     varchar2
  ,p_name                          in     varchar2
  ,p_topic_id                      in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_topics_bk1;

 

/
