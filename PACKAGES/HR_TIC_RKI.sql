--------------------------------------------------------
--  DDL for Package HR_TIC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIC_RKI" AUTHID CURRENT_USER as
/* $Header: hrticrhi.pkh 120.0 2005/05/31 03:11:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_item_context_id     in number
  ,p_object_version_number        in number
  ,p_template_item_id             in number
  ,p_context_type                 in varchar2
  ,p_item_context_id              in number
  );
end hr_tic_rki;

 

/
