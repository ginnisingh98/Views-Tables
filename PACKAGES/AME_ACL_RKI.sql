--------------------------------------------------------
--  DDL for Package AME_ACL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACL_RKI" AUTHID CURRENT_USER as
/* $Header: amaclrhi.pkh 120.0 2005/09/02 03:48 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_action_id                    in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_description                  in varchar2
  );
end ame_acl_rki;

 

/
