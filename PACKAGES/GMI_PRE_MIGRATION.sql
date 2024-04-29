--------------------------------------------------------
--  DDL for Package GMI_PRE_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_PRE_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMIPMIGS.pls 120.0 2005/07/05 08:53:28 jgogna noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIPMIGS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |   Public                                                                 |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIPMIGS                                                              |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for pre-migration validation |
 |    of the OPM convergence migration.                                     |
 |                                                                          |
 | Contents                                                                 |
 |    validate                                                              |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE validate(
p_migration_run_id	IN	NUMBER);

END GMI_Pre_Migration;

 

/
