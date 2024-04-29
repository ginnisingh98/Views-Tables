--------------------------------------------------------
--  DDL for Package PER_JP_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_EXTRA_PERSON_RULES" AUTHID CURRENT_USER as
/* $Header: pejpexpr.pkh 120.0.12000000.1 2007/01/21 23:49:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_kana_format >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_kana_format
  (p_last_name                     in     varchar2
  ,p_first_name                    in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_person_type_id                in     number -- Added for Bug#3613987
  );
--
end per_jp_extra_person_rules;

 

/
