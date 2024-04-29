--------------------------------------------------------
--  DDL for Package FEM_REFRESH_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_REFRESH_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: fem_refresh_utl.pls 120.0 2005/10/19 19:21:33 appldev noship $
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_refresh_utl.pls
 |
 | DESCRIPTION
 |  Package Spec for the procedures called by the Refresh Engine for the
 |  purpose of returning a database to its install state.
 |
 |  possible output status are:
 |     SUCCESS
 |     ERROR
 |
 | MODIFICATION HISTORY
 |    Rob Flippo         07/06/2005   Created - Refresh Engine requires the
 |                                    the ability to call all of the deletes
 |                                    for removing obsolete seeded data
 |
 *=======================================================================*/


PROCEDURE del_obsolete_seed_data (x_status OUT NOCOPY VARCHAR2);

END fem_refresh_util_pkg;

 

/
