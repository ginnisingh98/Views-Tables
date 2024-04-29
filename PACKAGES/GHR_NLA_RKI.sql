--------------------------------------------------------
--  DDL for Package GHR_NLA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NLA_RKI" AUTHID CURRENT_USER as
/* $Header: ghnlarhi.pkh 120.1 2005/07/01 02:40:41 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_noac_la_id                     in number
 ,p_nature_of_action_id            in number
 ,p_lac_lookup_code                in varchar2
 ,p_enabled_flag                   in varchar2
 ,p_date_from                      in date
 ,p_date_to                        in date
 ,p_object_version_number          in number
 ,p_valid_first_lac_flag           in varchar2
 ,p_valid_second_lac_flag          in varchar2
 ,p_effective_date                 in date
  );
end ghr_nla_rki;

 

/
