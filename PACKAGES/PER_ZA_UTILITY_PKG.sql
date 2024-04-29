--------------------------------------------------------
--  DDL for Package PER_ZA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: pezautly.pkh 120.1 2005/08/05 19:22:58 nragavar noship $ */
/* Copyright (c) Oracle Corporation 2002. All rights reserved. */
/*
   PRODUCT
      Oracle Human Resources - ZA Utility Package
   NAME
      pezautly.pkh

   DESCRIPTION
      .

   PUBLIC FUNCTIONS
      per_za_table_meaning
         This function returns the value from a specific user_table
         References
            PER_ZA_LEARNERSHIP_AGREEMENT_V

   PUBLIC PROCEDURES
      maintain_ipv_links
         This procedure checks for any seeded input value that has been
         linked on element level, but for which no input value link exists
         It will then create the link based on the element link's values and
         also create a dummy element entry value if an element entry is found
         The procedure is called from perlegza.sql during the legislative
         install process


   PRIVATE FUNCTIONS
      <none>
   NOTES
      .

   MODIFICATION HISTORY
   Person        Date        Version Bug     Comments
   ------------- ----------- ------- ------- -------------------------------
   Nageswara     24/06/2005  115.4   4346970 Modified procedure insert_ee_value
                                             to public for migration scripts
                                             Added new procedure insert_rr_value
   J.N. Louw     06/11/2002  115.3   2224332 Added maintain_ipv_links
   L.Kloppers    16/10/2002  115.2           Added za_term_cat_update
   L.Kloppers    02/05/2002  115.1   2266156 Added overloaded version of
                                             FUNCTION get_table_value
   J.N. Louw     25/04/2002  115.0   2266156 New version of the package
                                             For previous history see
                                             pezatbme.pkh
*/
-------------------------------------------------------------------------------
-- ZA_TERM_CAT_UPDATE
-------------------------------------------------------------------------------
PROCEDURE za_term_cat_update (
          p_existing_leaving_reason IN hr_lookups.lookup_code%TYPE
        , p_seeded_leaving_reason   IN hr_lookups.lookup_code%TYPE
        );

----------------------------------------------------------------------------
-- PER_ZA_TABLE_MEANING
----------------------------------------------------------------------------
FUNCTION per_za_table_meaning (
           p_table_name        in varchar2
         , p_column            in varchar2
         , p_value             in varchar2
         , p_business_group_id in number
         , p_effective_date    in date     default null
         ) RETURN                 varchar2;

----------------------------------------------------------------------------
-- CHK_ENTRY_IN_LOOKUP
----------------------------------------------------------------------------
FUNCTION chk_entry_in_lookup (
    p_lookup_type    IN  hr_leg_lookups.lookup_type%TYPE
  , p_entry_val      IN  hr_leg_lookups.meaning%TYPE
  , p_effective_date IN  hr_leg_lookups.start_date_active%TYPE
  , p_message        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2;

----------------------------------------------------------------------------
-- GET_TABLE_VALUE
----------------------------------------------------------------------------
FUNCTION get_table_value (
     p_table_name        IN VARCHAR2
   , p_col_name          IN VARCHAR2
   , p_row_value         IN VARCHAR2
   , p_effective_date    IN DATE     DEFAULT NULL
   ) RETURN VARCHAR2;

----------------------------------------------------------------------------
-- GET_TABLE_VALUE Overloaded version to select for a Business Group
----------------------------------------------------------------------------
FUNCTION get_table_value (
     p_table_name        IN VARCHAR2
   , p_col_name          IN VARCHAR2
   , p_row_value         IN VARCHAR2
   , p_effective_date    IN DATE     DEFAULT NULL
   , p_business_group_id IN VARCHAR2
   ) RETURN VARCHAR2;

----------------------------------------------------------------------------
-- MAINTAIN_IPV_LINKS
----------------------------------------------------------------------------
PROCEDURE maintain_ipv_links;

----------------------------------------------------------------------------
-- INSERT_EE_VALUE
-- Update the procedure to public as a part of migration scripts for
--   Context Balances functionality
----------------------------------------------------------------------------
PROCEDURE insert_ee_value (
  p_effective_start_date IN pay_element_entry_values_f.effective_start_date%TYPE
, p_effective_end_date   IN pay_element_entry_values_f.effective_end_date%TYPE
, p_input_value_id       IN pay_element_entry_values_f.input_value_id%TYPE
, p_element_entry_id     IN pay_element_entry_values_f.element_entry_id%TYPE
, p_screen_entry_value   IN pay_element_entry_values_f.screen_entry_value%TYPE
 );

----------------------------------------------------------------------------
-- Procedure inserts input value for a perticular run result and input value
----------------------------------------------------------------------------

PROCEDURE insert_rr_value (
 p_input_value_id        IN pay_input_values_f.input_value_id%TYPE
,p_run_result_id         IN pay_run_results.run_result_id%TYPE
,p_result_value          IN pay_run_result_values.result_value%TYPE
 );

PRAGMA RESTRICT_REFERENCES (per_za_table_meaning, WNDS);
----------------------------------------------------------------------------
END per_za_utility_pkg;
----------------------------------------------------------------------------

 

/
