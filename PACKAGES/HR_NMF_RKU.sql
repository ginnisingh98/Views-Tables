--------------------------------------------------------
--  DDL for Package HR_NMF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NMF_RKU" AUTHID CURRENT_USER as
/* $Header: hrnmfrhi.pkh 120.0 2005/05/31 01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_name_format_id               in number
  ,p_format_mask                  in varchar2
  ,p_object_version_number        in number
  ,p_format_name_o                in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_user_format_choice_o         in varchar2
  ,p_format_mask_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_nmf_rku;

 

/
