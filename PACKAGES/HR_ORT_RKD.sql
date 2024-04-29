--------------------------------------------------------
--  DDL for Package HR_ORT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORT_RKD" AUTHID CURRENT_USER as
/* $Header: hrortrhi.pkh 120.0 2005/05/31 01:52:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_organization_id              in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_name_o                       in varchar2
  );
--
end hr_ort_rkd;

 

/
