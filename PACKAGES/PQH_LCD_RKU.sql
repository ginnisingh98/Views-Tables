--------------------------------------------------------
--  DDL for Package PQH_LCD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_LCD_RKU" AUTHID CURRENT_USER as
/* $Header: pqlcdrhi.pkh 120.0 2005/05/29 02:10:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_level_code_id                in number
  ,p_level_number_id              in number
  ,p_level_code                   in varchar2
  ,p_description                  in varchar2
  ,p_gradual_value_number         in number
  ,p_object_version_number        in number
  ,p_level_number_id_o            in number
  ,p_level_code_o                 in varchar2
  ,p_description_o                in varchar2
  ,p_gradual_value_number_o       in number
  ,p_object_version_number_o      in number
  );
--
end pqh_lcd_rku;

 

/
