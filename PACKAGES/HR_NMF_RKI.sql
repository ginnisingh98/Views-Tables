--------------------------------------------------------
--  DDL for Package HR_NMF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NMF_RKI" AUTHID CURRENT_USER as
/* $Header: hrnmfrhi.pkh 120.0 2005/05/31 01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_name_format_id               in number
  ,p_format_name                  in varchar2
  ,p_legislation_code             in varchar2
  ,p_user_format_choice           in varchar2
  ,p_format_mask                  in varchar2
  ,p_object_version_number        in number
  );
end hr_nmf_rki;

 

/
