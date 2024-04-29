--------------------------------------------------------
--  DDL for Package HR_PFT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PFT_RKI" AUTHID CURRENT_USER as
/* $Header: hrpftrhi.pkh 120.0 2005/05/31 02:07:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_position_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name                         in varchar2
  );
end hr_pft_rki;

 

/
