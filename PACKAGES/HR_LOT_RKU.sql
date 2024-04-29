--------------------------------------------------------
--  DDL for Package HR_LOT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOT_RKU" AUTHID CURRENT_USER as
/* $Header: hrlotrhi.pkh 120.0 2005/05/31 01:22:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_location_id                    in number
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
 ,p_location_code                  in varchar2
 ,p_description                    in varchar2
 ,p_source_lang_o                  in varchar2
 ,p_location_code_o                in varchar2
 ,p_description_o                  in varchar2
  );
--
end hr_lot_rku;

 

/
