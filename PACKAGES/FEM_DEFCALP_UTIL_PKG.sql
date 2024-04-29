--------------------------------------------------------
--  DDL for Package FEM_DEFCALP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DEFCALP_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: fem_defcalp_utl.pls 120.0 2005/06/06 21:47:36 appldev noship $
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_defcalp_utl.pls
 |
 | DESCRIPTION
 |  Package Spec for the procedure that creates a default Calendar Period
 |  member during install based on the current sysdate and
 |  create a default calendar period hierarchy using this member
 |
 |  possible output status are:
 |     SUCCESS
 |     ERROR
 |
 | MODIFICATION HISTORY
 |    Rob Flippo         05/06/2005   Created - bug#4344994 converted
 |                                    fem_defcalp.sql to a package
 |                                    so that it can be easily called
 |                                    by the Refresh engine
 *=======================================================================*/


PROCEDURE main (x_status OUT NOCOPY VARCHAR2);

END fem_defcalp_util_pkg;

 

/
