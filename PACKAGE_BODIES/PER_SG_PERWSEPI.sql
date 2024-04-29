--------------------------------------------------------
--  DDL for Package Body PER_SG_PERWSEPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SG_PERWSEPI" as
/* $Header: pesgsepi.pkb 120.0.12000000.2 2007/02/21 06:00:54 snimmala noship $ */
  ---------------------------------------------------------------------------
  -- Passes out the Prompt for the Flexfield segment so the form knows what
  -- to give it as a prompt.
  -- Passes out the Required Flag for the Flexfield segment so the form knows
  -- whether or not to make the field Required or not.
  ---------------------------------------------------------------------------
  procedure get_segment_attributes
    (p_flexfield_segment  in fnd_descr_flex_column_usages.application_column_name%type,
     p_form_prompt       out nocopy fnd_descr_flex_col_usage_tl.form_left_prompt%type,
     p_required_flag     out nocopy fnd_descr_flex_column_usages.required_flag%type)
  is
    l_flexfield_name     fnd_descr_flex_column_usages.descriptive_flexfield_name%type := 'Person Developer DF';
    l_flexfield_context  fnd_descr_flex_column_usages.descriptive_flex_context_code%type := 'SG';

    l_form_prompt        fnd_descr_flex_col_usage_tl.form_left_prompt%type;
    l_required_flag      fnd_descr_flex_column_usages.required_flag%type;

    cursor segment_info
      (c_flexfield_name     fnd_descr_flex_column_usages.descriptive_flexfield_name%type,
       c_flexfield_context  fnd_descr_flex_column_usages.descriptive_flex_context_code%type,
       c_flexfield_segment  fnd_descr_flex_column_usages.application_column_name%type) is
      select fct.form_left_prompt,
             fcu.required_flag
      from   fnd_descr_flex_col_usage_tl fct,
             fnd_descr_flex_column_usages fcu
      where  fcu.application_id                = fct.application_id
      and    fcu.descriptive_flexfield_name    = fct.descriptive_flexfield_name
      and    fcu.descriptive_flex_context_code = fct.descriptive_flex_context_code
      and    fcu.application_column_name       = fct.application_column_name
      and    fct.language                      = userenv('LANG')
      and    fcu.descriptive_flexfield_name    = c_flexfield_name
      and    fcu.descriptive_flex_context_code = c_flexfield_context
      and    fcu.application_column_name       = c_flexfield_segment;

  begin
    open segment_info (l_flexfield_name, l_flexfield_context, p_flexfield_segment);
    fetch segment_info into p_form_prompt, p_required_flag;
    close segment_info;
  end get_segment_attributes;
  ---------------------------------------------------------------------------
  -- This procedure will be called from the Post-Query on the Person block in
  -- the main Person (PERWSEPI) and Combined Assignment (PERWSHRG) forms.
  -- Selects ALL the values to be seen by the user, according to the codes.
  ---------------------------------------------------------------------------
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
     p_payee_id_type        out nocopy hr_lookups.meaning%type)
  is

    l_meaning  hr_lookups.meaning%type;

    cursor sg_countries
      (c_territory_code  fnd_territories_vl.territory_code%type) is
    select territory_short_name
    from   fnd_territories_vl
    where  territory_code = c_territory_code;

    cursor sg_lookups
      (c_lookup_type  hr_lookups.lookup_type%type,
       c_lookup_code  hr_lookups.lookup_code%type) is
    select meaning
    from   hr_lookups
    where  lookup_type    = c_lookup_type
    and    lookup_code    = c_lookup_code
    and    application_id = g_application_id;
  begin
    -- Copy lookup values of developer flexfield segment values into
    -- blank text fields
    open sg_countries (p_country_code);
    fetch sg_countries into p_country;
    close sg_countries;

    open sg_lookups ('SG_PERMIT_TYPE',p_permit_type_code);
    fetch sg_lookups into p_permit_type;
    close sg_lookups;

    open sg_lookups ('SG_PERMIT_CATEGORY',p_permit_category_code);
    fetch sg_lookups into p_permit_category;
    close sg_lookups;

    open sg_lookups ('SG_NRIC_COLOUR',p_nric_colour_code);
    fetch sg_lookups into p_nric_colour;
    close sg_lookups;

    open sg_lookups ('SG_RELIGION',p_religion_code);
    fetch sg_lookups into p_religion;
    close sg_lookups;

    open sg_lookups ('SG_CPF_CATEGORY',p_cpf_category_code);
    fetch sg_lookups into p_cpf_category;
    close sg_lookups;

    open sg_lookups ('SG_RACE',p_race_code);
    fetch sg_lookups into p_race;
    close sg_lookups;

    open sg_lookups ('SG_COMMUNITY_FUND',p_community_fund_code);
    fetch sg_lookups into p_community_fund;
    close sg_lookups;

    open sg_lookups ('SG_EE_ER_RATE',p_ee_er_rate_code);
    fetch sg_lookups into p_ee_er_rate;
    close sg_lookups;

    open sg_lookups ('SG_PAYEE_ID_TYPE',p_payee_id_type_code);
    fetch sg_lookups into p_payee_id_type;
    close sg_lookups;

  end get_pddf_lookup_meanings;
-----------------------------------------------------------------------------
end per_sg_perwsepi;

/
