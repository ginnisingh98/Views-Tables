--------------------------------------------------------
--  DDL for Package AME_ACTION_BK7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_BK7" AUTHID CURRENT_USER as
/* $Header: amatyapi.pkh 120.3 2006/09/28 14:03:56 avarri noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_action_b >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_b
  (p_language_code             in varchar2
  ,p_action_id                 in     number
  ,p_parameter                 in     varchar2
  ,p_parameter_two             in     varchar2
  ,p_description               in     varchar2
  ,p_object_version_number     in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_action_a >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_a
  (p_language_code             in varchar2
  ,p_action_id                 in     number
  ,p_parameter                 in     varchar2
  ,p_parameter_two             in     varchar2
  ,p_description               in     varchar2
  ,p_object_version_number     in     number
  ,p_start_date                in     date
  ,p_end_date                  in     date
  );
end ame_action_bk7;

 

/
