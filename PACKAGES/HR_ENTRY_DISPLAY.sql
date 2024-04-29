--------------------------------------------------------
--  DDL for Package HR_ENTRY_DISPLAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ENTRY_DISPLAY" AUTHID CURRENT_USER as
/* $Header: pyentdis.pkh 120.0 2005/05/29 04:36 appldev noship $ */
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
    16-Sep-04  T.Habara   115.2         Added original_entry_name().
 ============================================================================*/
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   original_entry_name                                                   --
 -- Purpose                                                                 --
 --   This function is used for displaying the original entry name for      --
 --   the specified element entry id.                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 FUNCTION original_entry_name
 (p_original_entry_id       in number
 ) return varchar2;
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
 );
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
 );
--
END HR_ENTRY_DISPLAY;

 

/
