--------------------------------------------------------
--  DDL for Package GHR_NRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NRE_RKD" AUTHID CURRENT_USER as
/* $Header: ghnrerhi.pkh 120.1 2005/07/01 02:54:09 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_noac_remark_id                 in number
 ,p_nature_of_action_id_o          in number
 ,p_remark_id_o                    in number
 ,p_required_flag_o                in varchar2
 ,p_enabled_flag_o                 in varchar2
 ,p_date_from_o                    in date
 ,p_date_to_o                      in date
 ,p_object_version_number_o        in number
  );
--
end ghr_nre_rkd;

 

/
