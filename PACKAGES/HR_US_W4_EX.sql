--------------------------------------------------------
--  DDL for Package HR_US_W4_EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_W4_EX" AUTHID CURRENT_USER AS
/* $Header: pyusw4ex.pkh 120.0.12000000.1 2007/01/18 03:14:22 appldev noship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+


Name        : hr_us_w4_ex (Header)
File        : pyusw4ex.pkh
Description : This package declares functions and procedures which are
              used to return values for the Tax Form Exception Report.

Change List
-----------

Version Date      Author                 ER/CR No. Description of Change
-------+---------+----------------------+---------+--------------------------
115.0   11/06/00  Asasthan               Created.
115.2   01/14/04  Ardsouza               3349705   Added dbdrv lines and
                                                   OSERROR check.
=============================================================================

*/

FUNCTION get_tax_info   (w4_tax_unit_id   in number,
                         w4_jurisdiction_code in varchar2,
                         w4_person_id in number,
                         w4_allowance in varchar2,
                         w4_exempt in varchar2,
                         w4_state_code in varchar2,
                         w4_start_date in date,
                         w4_end_date in date)
                         RETURN NUMBER;
        -- PRAGMA RESTRICT_REFERENCES(get_tax_info, WNDS,WNPS);
end hr_us_w4_ex;


 

/
