--------------------------------------------------------
--  DDL for Package PQH_LCD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_LCD_RKI" AUTHID CURRENT_USER as
/* $Header: pqlcdrhi.pkh 120.0 2005/05/29 02:10:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_level_code_id                in number
  ,p_level_number_id              in number
  ,p_level_code                   in varchar2
  ,p_description                  in varchar2
  ,p_gradual_value_number         in number
  ,p_object_version_number        in number
  );
end pqh_lcd_rki;

 

/
