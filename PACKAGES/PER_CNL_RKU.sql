--------------------------------------------------------
--  DDL for Package PER_CNL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CNL_RKU" AUTHID CURRENT_USER as
/* $Header: pecnlrhi.pkh 120.0 2005/05/31 06:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_configuration_code           in varchar2
  ,p_configuration_context        in varchar2
  ,p_location_id                  in number
  ,p_location_code                in varchar2
  ,p_description                  in varchar2
  ,p_style                        in varchar2
  ,p_address_line_1               in varchar2
  ,p_address_line_2               in varchar2
  ,p_address_line_3               in varchar2
  ,p_town_or_city                 in varchar2
  ,p_country                      in varchar2
  ,p_postal_code                  in varchar2
  ,p_region_1                     in varchar2
  ,p_region_2                     in varchar2
  ,p_region_3                     in varchar2
  ,p_telephone_number_1           in varchar2
  ,p_telephone_number_2           in varchar2
  ,p_telephone_number_3           in varchar2
  ,p_loc_information13            in varchar2
  ,p_loc_information14            in varchar2
  ,p_loc_information15            in varchar2
  ,p_loc_information16            in varchar2
  ,p_loc_information17            in varchar2
  ,p_loc_information18            in varchar2
  ,p_loc_information19            in varchar2
  ,p_loc_information20            in varchar2
  ,p_object_version_number        in number
  ,p_configuration_code_o         in varchar2
  ,p_configuration_context_o      in varchar2
  ,p_location_code_o              in varchar2
  ,p_description_o                in varchar2
  ,p_style_o                      in varchar2
  ,p_address_line_1_o             in varchar2
  ,p_address_line_2_o             in varchar2
  ,p_address_line_3_o             in varchar2
  ,p_town_or_city_o               in varchar2
  ,p_country_o                    in varchar2
  ,p_postal_code_o                in varchar2
  ,p_region_1_o                   in varchar2
  ,p_region_2_o                   in varchar2
  ,p_region_3_o                   in varchar2
  ,p_telephone_number_1_o         in varchar2
  ,p_telephone_number_2_o         in varchar2
  ,p_telephone_number_3_o         in varchar2
  ,p_loc_information13_o          in varchar2
  ,p_loc_information14_o          in varchar2
  ,p_loc_information15_o          in varchar2
  ,p_loc_information16_o          in varchar2
  ,p_loc_information17_o          in varchar2
  ,p_loc_information18_o          in varchar2
  ,p_loc_information19_o          in varchar2
  ,p_loc_information20_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_cnl_rku;

 

/
