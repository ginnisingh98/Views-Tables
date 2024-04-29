--------------------------------------------------------
--  DDL for Package AME_ACTION_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_BK4" AUTHID CURRENT_USER as
/* $Header: amatyapi.pkh 120.3 2006/09/28 14:03:56 avarri noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< <create_ame_action_b >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_b
  (p_language_code        in varchar2
  ,p_action_type_id       in  number
  ,p_parameter            in  varchar2
  ,p_parameter_two        in  varchar2
  ,p_description          in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_action_a >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_action_a
  (p_language_code        in varchar2
  ,p_action_type_id          in  number
  ,p_parameter               in  varchar2
  ,p_parameter_two           in  varchar2
  ,p_description             in  varchar2
  ,p_action_id               in  number
  ,p_object_version_number   in  number
  ,p_start_date              in  date
  ,p_end_date                in  date
        );
end ame_action_bk4;

 

/
