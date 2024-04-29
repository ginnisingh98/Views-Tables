--------------------------------------------------------
--  DDL for Package PER_SG_PERWSEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SG_PERWSEPI" AUTHID CURRENT_USER as
/* $Header: pesgsepi.pkh 120.0.12000000.2 2007/02/21 05:59:40 snimmala noship $ */

  -- Package variable
  g_application_id  number := 800;

  procedure get_segment_attributes
    (p_flexfield_segment  in fnd_descr_flex_column_usages.application_column_name%type,
     p_form_prompt       out nocopy fnd_descr_flex_col_usage_tl.form_left_prompt%type,
     p_required_flag     out nocopy fnd_descr_flex_column_usages.required_flag%type);

  -- Called from POST-QUERY trigger to obtain all the values
  -- to display to the user in one hit.
  procedure get_pddf_lookup_meanings
    (p_country_code          in fnd_territories_vl.territory_code%type,
     p_permit_type_code      in hr_lookups.lookup_code%type,
     p_permit_category_code  in hr_lookups.lookup_code%type,
     p_nric_colour_code      in hr_lookups.lookup_code%type,
     p_religion_code         in hr_lookups.lookup_code%type,
     p_cpf_category_code     in hr_lookups.lookup_code%type,
     p_race_code             in hr_lookups.lookup_code%type,
     p_community_fund_code   in hr_lookups.lookup_code%type,
     p_ee_er_rate_code       in hr_lookups.lookup_code%type,
     p_payee_id_type_code    in hr_lookups.lookup_code%type,
     p_country              out nocopy fnd_territories_vl.territory_short_name%type,
     p_permit_type          out nocopy hr_lookups.meaning%type,
     p_permit_category      out nocopy hr_lookups.meaning%type,
     p_nric_colour          out nocopy hr_lookups.meaning%type,
     p_religion             out nocopy hr_lookups.meaning%type,
     p_cpf_category         out nocopy hr_lookups.meaning%type,
     p_race                 out nocopy hr_lookups.meaning%type,
     p_community_fund       out nocopy hr_lookups.meaning%type,
     p_ee_er_rate           out nocopy hr_lookups.meaning%type,
     p_payee_id_type        out nocopy hr_lookups.meaning%type);
end per_sg_perwsepi;

 

/
