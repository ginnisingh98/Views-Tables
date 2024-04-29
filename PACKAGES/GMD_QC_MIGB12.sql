--------------------------------------------------------
--  DDL for Package GMD_QC_MIGB12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_MIGB12" AUTHID CURRENT_USER AS
/* $Header: gmdmb12s.pls 120.0 2006/01/13 11:05:11 jdiiorio noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    gmdmb12s.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMD_QC_MIGB12                                                         |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains 12.0 Quality migration procedures for Quality   |
 |    Batch migration.                                                      |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 +==========================================================================+
*/


PROCEDURE GMD_QC_MIGRATE_BATCH_ID
( p_migration_run_id IN  NUMBER
, p_commit           IN  VARCHAR2
, x_exception_count  OUT NOCOPY NUMBER
);

END GMD_QC_MIGB12;

 

/
