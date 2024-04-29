--------------------------------------------------------
--  DDL for Package AME_AYL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_AYL_RKI" AUTHID CURRENT_USER as
/* $Header: amaylrhi.pkh 120.0 2005/09/02 03:53 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_action_type_id               in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_action_type_name        in varchar2
  ,p_description                  in varchar2
  );
end ame_ayl_rki;

 

/
