--------------------------------------------------------
--  DDL for Package PQH_LCD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_LCD_RKD" AUTHID CURRENT_USER as
/* $Header: pqlcdrhi.pkh 120.0 2005/05/29 02:10:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_level_code_id                in number
  ,p_level_number_id_o            in number
  ,p_level_code_o                 in varchar2
  ,p_description_o                in varchar2
  ,p_gradual_value_number_o       in number
  ,p_object_version_number_o      in number
  );
--
end pqh_lcd_rkd;

 

/
