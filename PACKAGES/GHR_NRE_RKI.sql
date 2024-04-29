--------------------------------------------------------
--  DDL for Package GHR_NRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NRE_RKI" AUTHID CURRENT_USER as
/* $Header: ghnrerhi.pkh 120.1 2005/07/01 02:54:09 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_noac_remark_id                 in number
 ,p_nature_of_action_id            in number
 ,p_remark_id                      in number
 ,p_required_flag                  in varchar2
 ,p_enabled_flag                   in varchar2
 ,p_date_from                      in date
 ,p_date_to                        in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ghr_nre_rki;

 

/
