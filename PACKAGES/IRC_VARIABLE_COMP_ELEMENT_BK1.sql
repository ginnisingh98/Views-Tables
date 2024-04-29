--------------------------------------------------------
--  DDL for Package IRC_VARIABLE_COMP_ELEMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VARIABLE_COMP_ELEMENT_BK1" AUTHID CURRENT_USER as
/* $Header: irvceapi.pkh 120.2 2008/02/21 14:39:44 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_VARIABLE_COMPENSATION_B >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLE_COMPENSATION_B
  (p_vacancy_id           in  number
  ,p_variable_comp_lookup in  varchar2
  ,p_effective_date       in  date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< CREATE_VARIABLE_COMPENSATION_A >---------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_VARIABLE_COMPENSATION_A
  (p_vacancy_id             in  number
  ,p_variable_comp_lookup   in  varchar2
  ,p_effective_date         in  date
  ,p_object_version_number  in  number
  );
--
end IRC_VARIABLE_COMP_ELEMENT_BK1;

/
