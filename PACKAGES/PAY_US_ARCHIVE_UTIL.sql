--------------------------------------------------------
--  DDL for Package PAY_US_ARCHIVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ARCHIVE_UTIL" AUTHID CURRENT_USER AS
/* $Header: payusarchiveutil.pkh 120.0 2005/05/29 11:52:30 appldev noship $ */

   /*
    +=====================================================================+
    |              Copyright (c) 1997 Orcale Corporation                  |
    |                 Redwood Shores, California, USA                     |
    |                      All rights reserved.                           |
    +=====================================================================+
   Name        : payusarchiveutil.pkh
   Description : This package contains utilities to fetch archived values.

   Change List
   -----------

   Version Date      Author          Bug No.   Description of Change
   -------+---------+---------------+---------+--------------------------
   115.0   20-AUG-04  rsethupa       3393493   Created
   115.1   08-NOV-04  rsethupa       3180532   Added function
                                               get_ff_archive_value
   115.2   10-NOV-04  meshah                   removed function
                                               get_ff_archive_value and
                                               moved it to
                                               pay_us_reporting_utils_pkg
                                               for extract reasons.
   ----------------------------------------------------------------------
   */
   TYPE user_entity_record IS RECORD (
      user_entity_id     NUMBER (15),
      user_entity_name   VARCHAR2 (240)
   );

   TYPE user_entity_tabrec IS TABLE OF user_entity_record
      INDEX BY BINARY_INTEGER;

   ltr_user_entity_table   user_entity_tabrec;

   /*********************************************************************
    Name        : get_archive_value

    Description : gets the archived value for a particular Action ID
                  (Assignment Action or Payroll Action). Jurisdiction
        code is optional.

    ********************************************************************/
   FUNCTION get_archive_value (
      p_action_id           NUMBER,
      p_user_entity_name    VARCHAR2,
      p_tax_unit_id         NUMBER,
      p_jurisdiction_code   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;

END pay_us_archive_util;

 

/
