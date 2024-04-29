--------------------------------------------------------
--  DDL for Package Body HR_UTF8_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTF8_TRIGGERS" AS
/* $Header: hrutf8tr.pkb 120.3.12000000.1 2007/01/21 19:14:52 appldev ship $ */
/*
+==========================================================================+
|                       Copyright (c) 2002 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+

Change History
-------+--------+-----------+-------+--------------------------------------|
        dcasemor 25-MAR-2002 115.0   Created.
        dcasemor 15-APR-2002 115.1   Added chk_utf8_col_lengths. This
                                     procedure is used exclusively by
                                     PERWSHRG and should be nulled out when
                                     a standalone patch is delivered to
                                     drop the constraints.
        dcasemor 30-APR-2002 115.2   Added missing trigger validation to
                                     BEN_EXT_RSLT_DTL.
        dcasemor 21-MAY-2002 115.3   Commented out body of
                                     chk_utf8_col_lengths.
        dcasemor 03-JUL-2002 115.4   Added facility to select trigger
                                     mode: BYTE (uses lengthb)
                                           CHAR (uses length) and
                                           UNRESTRICTED (drops all
                                                         triggers).

        tjesumic 21-APR-2006 115.5  ben_Ext_fld.short_name max length changed]
                                    to 30   # 5139976
	brsinha	 08-JUL-2006 120.2  Changed for bug # 5353498
				    This file is obsoleted in R12. As the
				    package is not required anymore.
---------------------------------------------------------------------------|
*/

 /**     This Package has been obsoleted. Bug # 5353498                  **/

END hr_utf8_triggers;

/
