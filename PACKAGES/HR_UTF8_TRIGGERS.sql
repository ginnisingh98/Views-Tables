--------------------------------------------------------
--  DDL for Package HR_UTF8_TRIGGERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTF8_TRIGGERS" AUTHID CURRENT_USER AS
/* $Header: hrutf8tr.pkh 120.2.12000000.1 2007/01/21 19:14:54 appldev ship $ */

/*
+==========================================================================+
|                       Copyright (c) 2002 Oracle Corporation              |
|                          Redwood Shores, California, USA                 |
|                               All rights reserved.                       |
+==========================================================================+
Name
        HR Functionality to maintain UTF8 triggers.
Purpose
        The procedures within dynamically create or drop database triggers
        for UTF8.  These triggers validate the length of columns based on
        their pre-UTF8 length and raise a message if the value has been
        exceeded in length.

        This includes several procedures: one initialises a static
        global pl/sql table of triggers and the other, modify_all_triggers,
        creates, modifies or drops all UTF8 triggers listed in the plsql
        table.

        It takes a single parameter, p_restriction_mode which can take the
        following values:
         <NULL> Defaults to whatever is in pay_action_parameters. If this
                row does not exist it creates one using BYTE.
          BYTE  The triggers restrict the length using lengthb to the
                pre-extended column value.  All character sets continue
                as if the columns were never extended in length.
          CHAR  The triggers restrict using length  so the characters
                available remain the same regardless of the character set.
                A multi-byte character set will typically have 3 times
                as many characters available.  Single-byte character sets
                will behave as if the length was never extended.
          UNRESTRICTED  All UTF8 triggers will be dropped.  The extended
                        column definitions are available to all character
                        sets so will typically allow 3 times as many
                        characters, e.g., a length of 50 that has been
                        extended to 150 means that 150 characters can be
                        used in a single-byte character set and 50
                        characters can be used in a 3-byte character set.

Change History
-------+--------+-----------+-------+--------------------------------------|
        dcasemor 25-MAR-2002 115.0   Created.
        dcasemor 15-APR-2002 115.1   Added chk_utf8_col_lengths. This
                                     procedure is used exclusively by
                                     PERWSHRG and should be nulled out when
                                     a standalone patch is delivered to
                                     drop the constraints.
        dcasemor 02-JUL-2002 115.2   Renamed create_all_triggers to
                                     modify_all_triggers and made
                                     drop_all_triggers private.
	brsinha	 08-JUL-2006 120.2   Changed for bug # 5353498
				     This file is obsoleted in R12.
				     As the package is not required anymore.
---------------------------------------------------------------------------|
*/

  /**     This Package has been obsoleted. Bug # 5353498                  **/


 END hr_utf8_triggers;

 

/
