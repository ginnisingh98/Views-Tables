--------------------------------------------------------
--  DDL for Package HR_TIC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIC_RKU" AUTHID CURRENT_USER as
/* $Header: hrticrhi.pkh 120.0 2005/05/31 03:11:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_template_item_context_id     in number
  ,p_object_version_number        in number
  ,p_template_item_id             in number
  ,p_context_type                 in varchar2
  ,p_item_context_id              in number
  ,p_object_version_number_o      in number
  ,p_template_item_id_o           in number
  ,p_context_type_o               in varchar2
  ,p_item_context_id_o            in number
  );
--
end hr_tic_rku;

 

/
