--------------------------------------------------------
--  DDL for Package HR_NMF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NMF_RKD" AUTHID CURRENT_USER as
/* $Header: hrnmfrhi.pkh 120.0 2005/05/31 01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_name_format_id               in number
  ,p_format_name_o                in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_user_format_choice_o         in varchar2
  ,p_format_mask_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_nmf_rkd;

 

/
