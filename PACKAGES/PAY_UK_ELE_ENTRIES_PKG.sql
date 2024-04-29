--------------------------------------------------------
--  DDL for Package PAY_UK_ELE_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_UK_ELE_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: pygbeent.pkh 120.0.12010000.1 2008/07/27 22:43:48 appldev ship $ */
--
/*  +=======================================================================+
    |           Copyright (c) 1993 Oracle Corporation                       |
    |              Redwood Shores, California, USA                          |
    |                   All rights reserved.                                |
    +=======================================================================+
  Name
    pay_uk_ele_entries_pkg
  Purpose
    Supports the PAYE block in the NI block in the form PAYGBTAX.

Notes

  History
    19-AUG-94  H.Minton   40.0         Date created.
    14-JAN-97  T.Inekuku  40.5         Included new I. Value in update to
                                       NI procedure.
    06-OCT-00  G.Butler   115.1	       Updated parameters in update_paye_entries
    				       procedure to include x_entry_information1
    				       ,x_entry_information2 and x_entry_information_category
    10-Jun-02  K.Thampan  115.2        Add dbdrv command
    24-Jan-03  M.Ahmad    115.3        Added NOCOPY
============================================================================*/
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   update_paye_entries                                                   --
-- Purpose                                                                 --
--   calls the hr_element_entry_api to perform updates to the PAYE element.--
-----------------------------------------------------------------------------
--
PROCEDURE update_paye_entries(
                            x_dt_update_mode     varchar2,
                            x_session_date       date,
                            x_element_entry_id   number,
                            x_input_value_id1    number,
                            x_entry_value1       varchar2,
                            x_input_value_id2    number,
                            x_entry_value2       varchar2,
                            x_input_value_id4    number,
                            x_entry_value4       varchar2,
                            x_input_value_id5    number,
                            x_entry_value5       varchar2,
                            x_input_value_id3    number,
                            x_entry_value3       varchar2,
                            x_input_value_id6    number,
                            x_entry_value6       varchar2,
                            x_entry_information1 varchar2,
                            x_entry_information2 varchar2,
                            x_entry_information_category varchar2,
                            p_effective_end_date in out nocopy date);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   get_paye_formula_id                                                   --
-- Purpose                                                                 --
--   this function finds the formula id for the validation of the PAYE     --
--   tax_code element entry value.
-----------------------------------------------------------------------------
--
FUNCTION get_paye_formula_id RETURN NUMBER;
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   update_ni_entries                                                     --
-- Purpose                                                                 --
--   calls the hr_element_entry_api to perform updates to the NI element.  --
-----------------------------------------------------------------------------
--
PROCEDURE update_ni_entries(
                            x_dt_update_mode     varchar2,
                            x_session_date       date,
                            x_element_entry_id   number,
                            x_input_value_id1    number,
                            x_entry_value1       varchar2,
                            x_input_value_id2    number,
                            x_entry_value2       varchar2,
                            x_input_value_id3    number,
                            x_entry_value3       varchar2,
                            x_input_value_id4    number,
                            x_entry_value4       varchar2,
                            x_input_value_id5    number,
                            x_entry_value5       varchar2,
                            x_input_value_id6    number,
                            x_entry_value6       varchar2,
                            x_input_value_id7    number,
                            x_entry_value7       varchar2,
                            x_input_value_id8    number,
                            x_entry_value8       varchar2,
                            p_effective_end_date in out nocopy date);

-------------------------------------------------------------------------------
end PAY_UK_ELE_ENTRIES_PKG;

/
