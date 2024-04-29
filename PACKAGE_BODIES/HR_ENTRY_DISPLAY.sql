--------------------------------------------------------
--  DDL for Package Body HR_ENTRY_DISPLAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ENTRY_DISPLAY" as
/* $Header: pyentdis.pkb 120.0 2005/05/29 04:36 appldev noship $ */
--
 /*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    hr_entry_display
  Purpose
    This package is used for maintaining entry level display utilities.

  Notes
    This was originally used for forms 2.3 usage and extended to more generic
    usage.

    Used by all 2.3 forms that display element entries. Element entries are
    displayed horizontally to aid data entry and therefore 2.3 forms cannot
    provide this without using special routines to fetch element entries which
    are then displayed using a loop within the form NB. the 4.0 forms that
    display element entries can use native 4.0 forms functionality to display
    the entries horizontally.
  History
    04-Mar-94  J.S.Hobbs   40.0         Date created.
    29-Jun-94  D.C.Harris  40.1         get_input_value_details element entry
                                        values select tuned to use
                                        PAY_ELEMENT_ENTRY_VALUES_F_N50 index.
    25-Feb-99  J. Moyano  115.1         MLS changes. Procedure affected:
                                        get_input_value_details.
    16-Sep-04  T.Habara   115.2         Added original_entry_name().
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   original_entry_name                                                   --
 -- Purpose                                                                 --
 --   This function is used for displaying the original entry name for      --
 --   the specified element entry id.                                       --
 --                                                                         --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 FUNCTION original_entry_name
 (p_original_entry_id       in number
 ) return varchar2
 is
   l_element_name              pay_element_types_f_tl.element_name%type;
   --
   cursor csr_element_name
   is
     select
       pettl.element_name
     from
       pay_element_entries_f    pee
      ,pay_element_links_f      pel
      ,pay_element_types_f_tl   pettl
     where
         pee.element_entry_id  = p_original_entry_id
     and pel.element_link_id   = pee.element_link_id
     and pee.effective_start_date between pel.effective_start_date
                                      and pel.effective_end_date
     and pettl.element_type_id = pel.element_type_id
     and pettl.language        = userenv('lang')
     ;
 begin
   --
   if p_original_entry_id is null then
     return null;
   end if;

   --
   -- Identify the element name for the entry.
   --
   open csr_element_name;
   fetch csr_element_name into l_element_name;
   close csr_element_name;

   --
   -- Return the entry name as "<Element Name> (<Entry ID>)".
   --
   if l_element_name is not null then
     return (l_element_name || ' (' || p_original_entry_id || ')');
   else
     return null;
   end if;
   --
 end original_entry_name;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   count_input_values (obsolete)                                         --
 -- Purpose                                                                 --
 --   This procedure is used for entry form(s) population. It counts how    --
 --   many input values are defined for the specified element type and      --
 --   also set a loop counter value to 1.                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This is no longer used.                                               --
 -----------------------------------------------------------------------------
--
--
 PROCEDURE count_input_values
 (
  p_element_type_id         in number,
  p_session_date            in date,
  p_number_of_input_values  out nocopy number,
  p_population_loop_counter out nocopy number
 ) is
--
 begin
--
   hr_utility.set_location('hr_entry_display.count_input_values', 1);
--
   -- Need to determine how many input values have been defined for the element.
   -- This value is used to control a loop which is used to select each input
   -- value definition in the correct order a row at a time.
   begin
     SELECT  COUNT(*)
     INTO    p_number_of_input_values
     FROM    PAY_INPUT_VALUES_F IV
     WHERE   IV.ELEMENT_TYPE_ID = p_element_type_id
     AND     p_session_date
     BETWEEN IV.EFFECTIVE_START_DATE AND IV.EFFECTIVE_END_DATE;
   end;
--
   -- Initialise the loop counter.
   p_population_loop_counter := 1;
--
 end count_input_values;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   get_input_value_details (obsolete)                                    --
 -- Purpose                                                                 --
 --   This procedure is used for selecting input value details and          --
 --   assocated entry values for the entry forms(s).                        --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This is no longer used.                                               --
 -----------------------------------------------------------------------------
--
 PROCEDURE get_input_value_details
 (
  p_element_type_id         in number,
  p_element_link_id         in number,
  p_session_date            in date,
  p_input_currency_code     in varchar2,
  p_input_value_id1         in number,
  p_input_value_id2         in number,
  p_input_value_id3         in number,
  p_input_value_id4         in number,
  p_input_value_id5         in number,
  p_input_value_id6         in number,
  p_element_entry_id        in number,
  p_input_value_id         out nocopy number,
  p_input_name             out nocopy varchar2,
  p_default_value          out nocopy varchar2,
  p_mandatory_flag         out nocopy varchar2,
  p_uom                    out nocopy varchar2,
  p_warning_or_error       out nocopy varchar2,
  p_hot_default_flag       out nocopy varchar2,
  p_lookup_type            out nocopy varchar2,
  p_formula_id             out nocopy number,
  p_database_format_value  out nocopy varchar2,
  p_screen_format_value    out nocopy varchar2
 ) is
--
   v_uom                     varchar2(30);
   v_select_input_value_id   number;
   v_screen_format_value     varchar2(60);
   v_database_format_value   varchar2(60);
   v_hot_default_flag        varchar2(30);
   v_lookup_type	     varchar2(30);
--
 begin
--
   hr_utility.set_location('hr_entry_display.get_input_value_details', 1);
--
   -- Select the input_value_id of the required input value as specified
   -- by the ordering criteria.
   -- The inner sub-query works by selecting the minimum order sequence of
   -- any input values which have not already been selected. Because the
   -- DISPLAY_SEQUENCE is optional, the parameter is defaulted to 0 to be used
   -- to ensure that a row is always returned from the inner query.
   -- The outer query will then select the minimum input value for the
   -- order sequence which has not already been selected.
   begin
     SELECT  HIV1.INPUT_VALUE_ID,
             HIV1_TL.NAME,
             HIV1.MANDATORY_FLAG,
             HIV1.UOM,
             DECODE(HIV1.HOT_DEFAULT_FLAG,'Y',
                    NVL(HLIV1.WARNING_OR_ERROR,HIV1.WARNING_OR_ERROR),
                    HIV1.WARNING_OR_ERROR),
             HIV1.HOT_DEFAULT_FLAG,
             HIV1.LOOKUP_TYPE,
             HIV1.FORMULA_ID
     INTO    v_select_input_value_id,
             p_input_name,
             p_mandatory_flag,
             v_uom,
             p_warning_or_error,
             v_hot_default_flag,
             v_lookup_type,
             p_formula_id
     FROM    PAY_INPUT_VALUES_F_TL HIV1_TL,
             PAY_INPUT_VALUES_F HIV1,
             PAY_LINK_INPUT_VALUES_F HLIV1
     WHERE   HIV1_TL.INPUT_VALUE_ID = HIV1.INPUT_VALUE_ID
     and     userenv('LANG') = HIV1_TL.language
     AND     p_session_date
     BETWEEN HLIV1.EFFECTIVE_START_DATE
     AND     HLIV1.EFFECTIVE_END_DATE
     AND     HLIV1.INPUT_VALUE_ID  = HIV1.INPUT_VALUE_ID
     AND     HLIV1.ELEMENT_LINK_ID = p_element_link_id
     AND     HIV1.ROWID =
             (SELECT  MIN(IV1.ROWID)
              FROM    PAY_INPUT_VALUES_F IV1
              WHERE   IV1.ELEMENT_TYPE_ID = p_element_type_id
              AND     p_session_date
              BETWEEN IV1.EFFECTIVE_START_DATE
              AND     IV1.EFFECTIVE_END_DATE
              AND     IV1.INPUT_VALUE_ID NOT IN
                     (NVL(p_input_value_id1,0),
                      NVL(p_input_value_id2,0),
                      NVL(p_input_value_id3,0),
                      NVL(p_input_value_id4,0),
                      NVL(p_input_value_id5,0),
                      NVL(p_input_value_id6,0))
              AND     IV1.DISPLAY_SEQUENCE =
                     (SELECT  MIN(IV2.DISPLAY_SEQUENCE)
                      FROM    PAY_INPUT_VALUES_F IV2
                      WHERE   IV2.ELEMENT_TYPE_ID = p_element_type_id
                      AND     p_session_date
                      BETWEEN IV2.EFFECTIVE_START_DATE
                      AND     IV2.EFFECTIVE_END_DATE
                      AND     IV2.INPUT_VALUE_ID NOT IN
                             (NVL(p_input_value_id1,0),
                              NVL(p_input_value_id2,0),
                              NVL(p_input_value_id3,0),
                              NVL(p_input_value_id4,0),
                              NVL(p_input_value_id5,0),
                              NVL(p_input_value_id6,0))));
   exception
     when NO_DATA_FOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'hr_entry_display.get_input_value_details');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
   end;
--
   p_input_value_id        := v_select_input_value_id;
   p_hot_default_flag      := v_hot_default_flag;
   p_uom                   := v_uom;
   p_lookup_type	   := v_lookup_type;
--
   -- Now that we have select the correct input_value_id and the input value
   -- details the entry value can now be selected provided the element entry id
   -- exists.
   if p_element_entry_id is not null then
--
     hr_utility.set_location('hr_entry_display.get_input_value_details', 3);
     begin
       SELECT  HEEV1.SCREEN_ENTRY_VALUE
       INTO    v_database_format_value
       FROM    PAY_ELEMENT_ENTRY_VALUES_F HEEV1
       WHERE   HEEV1.ELEMENT_ENTRY_ID    = p_element_entry_id
       AND     HEEV1.INPUT_VALUE_ID + 0  = v_select_input_value_id
       AND     p_session_date
       BETWEEN HEEV1.EFFECTIVE_START_DATE AND HEEV1.EFFECTIVE_END_DATE;
     exception
       when NO_DATA_FOUND then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'hr_entry_display.get_input_value_details');
       hr_utility.set_message_token('STEP','3');
       hr_utility.raise_error;
     end;
   end if;
--
   -- derive default value.
   -- If the entry value is being selected then
   --   If the entry value is null and hot defaulted then derived default
   --   Else format selected entry value.
   -- Else
   --   derive defaults.
   if p_element_entry_id is not null then
--
     if (v_hot_default_flag = 'Y'         and
         v_database_format_value is null) then
--
       hr_entry.derive_default_value
	 (p_element_link_id,
          v_select_input_value_id,
          p_session_date,
          p_input_currency_code,
          'DEF',
          v_screen_format_value,
          v_database_format_value);
--
     -- As the entry value is not using a default we must get the screen format
     -- value.
     elsif v_database_format_value is not null then
--
       if v_lookup_type is not null then
--
         hr_utility.set_location('hr_entry_display.get_input_value_details', 4);
         begin
           select h.meaning
           into   v_screen_format_value
           from   hr_lookups h
           where  h.lookup_type = v_lookup_type
           and    h.lookup_code = v_database_format_value;
         exception
           when NO_DATA_FOUND then
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE',
                                   'hr_entry_display.get_input_value_details');
             hr_utility.set_message_token('STEP','4');
             hr_utility.raise_error;
         end;
--
       else
--
         hr_chkfmt.changeformat
	   (v_database_format_value,
            v_screen_format_value,
            v_uom,
            p_input_currency_code);
--
       end if;
--
     end if;
--
   else
--
     -- As we are not selecting entry values then we must select the default
     -- value.
     hr_entry.derive_default_value
       (p_element_link_id,
        v_select_input_value_id,
        p_session_date,
        p_input_currency_code,
        'DEF',
        v_screen_format_value,
        v_database_format_value);
--
   end if;
--
   -- Set the p_screen_format_value, p_database_format_value
   p_screen_format_value   := v_screen_format_value;
   p_database_format_value := v_database_format_value;
--
 end get_input_value_details;
--
END HR_ENTRY_DISPLAY;

/
