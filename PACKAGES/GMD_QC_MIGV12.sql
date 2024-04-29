--------------------------------------------------------
--  DDL for Package GMD_QC_MIGV12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_MIGV12" AUTHID CURRENT_USER AS
/* $Header: gmdmv12s.pls 120.0 2005/06/30 11:33:02 jdiiorio noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmv12s.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIGV12                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains migration validation procedures for Quality     |
 |    for 12 migration.                                                     |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/


PROCEDURE GMD_QC_MIGRATE_VALIDATION
( p_migration_run_id IN  NUMBER
, x_exception_count  OUT NOCOPY NUMBER
);

END GMD_QC_MIGV12;

 

/
