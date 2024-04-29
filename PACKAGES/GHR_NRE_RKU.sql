--------------------------------------------------------
--  DDL for Package GHR_NRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NRE_RKU" AUTHID CURRENT_USER as
/* $Header: ghnrerhi.pkh 120.1 2005/07/01 02:54:09 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
 ,p_nature_of_action_id_o          in number
 ,p_remark_id_o                    in number
 ,p_required_flag_o                in varchar2
 ,p_enabled_flag_o                 in varchar2
 ,p_date_from_o                    in date
 ,p_date_to_o                      in date
 ,p_object_version_number_o        in number
  );
--
end ghr_nre_rku;

 

/
