--------------------------------------------------------
--  DDL for Package HR_KI_TOPICS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TOPICS_BK2" AUTHID CURRENT_USER as
/* $Header: hrtpcapi.pkh 120.1 2005/10/02 02:06:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_topic_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_topic_b
  (
   p_language_code                 in     varchar2
  ,p_handler                       in     varchar2
  ,p_name                          in     varchar2
  ,p_topic_id                      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_topic_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_topic_a
  (
   p_language_code                 in     varchar2
  ,p_handler                       in     varchar2
  ,p_name                          in     varchar2
  ,p_topic_id                      in     number
  ,p_object_version_number         in     number
  );
--
end hr_ki_topics_bk2;

 

/
