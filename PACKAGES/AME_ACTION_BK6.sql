--------------------------------------------------------
--  DDL for Package AME_ACTION_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_BK6" AUTHID CURRENT_USER as
/* $Header: amatyapi.pkh 120.3 2006/09/28 14:03:56 avarri noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< <update_ame_action_type_conf_b >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_type_conf_b
  (p_ame_application_id      in  number
        ,p_action_type_id          in  number
        ,p_voting_regime           in  varchar2
        ,p_order_number            in  number
        ,p_chain_ordering_mode     in  varchar2
  ,p_object_version_number   in  number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_action_type_conf_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_action_type_conf_a
  (p_ame_application_id      in  number
        ,p_action_type_id          in  number
        ,p_voting_regime           in  varchar2
        ,p_order_number            in  number
        ,p_chain_ordering_mode     in  varchar2
  ,p_object_version_number   in  number
  ,p_start_date              in  date
  ,p_end_date                in  date
  );
end ame_action_bk6;

 

/
