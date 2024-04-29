--------------------------------------------------------
--  DDL for Package HR_ORT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORT_RKI" AUTHID CURRENT_USER as
/* $Header: hrortrhi.pkh 120.0 2005/05/31 01:52:48 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_organization_id              in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  );
end hr_ort_rki;

 

/
