--------------------------------------------------------
--  DDL for Package INV_GMI_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GMI_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: INVGMIMS.pls 120.2 2005/12/23 15:47:59 jgogna noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVGMIMS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INV_GMI_Migration                                                     |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for inventory  migration for |
 |    OPM convergence project. These procedure are meant for migration only.|
 |                                                                          |
 | Contents                                                                 |
 |    migrate_inventory_types                                               |
 |    migrate_item_categories                                               |
 |    migrate_default_category_sets                                         |
 |    migrate_lot_status                                                    |
 |    migrate_actions                                                       |
 |    migrate_opm_grades                                                    |
 |    migrate_odm_grades                                                    |
 |    migrate_lot_conversions                                               |
 |    migrate_inventory_balances                                            |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE migrate_inventory_types
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_item_categories
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, p_start_rowid			IN		ROWID
, p_end_rowid			IN		ROWID
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_default_category_sets
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_lot_status
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_actions
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_opm_grades
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_odm_grades
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_lot_conversions
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, p_start_rowid			IN		ROWID
, p_end_rowid			IN		ROWID
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE migrate_inventory_balances
( p_migration_run_id		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

FUNCTION ditem
( p_organization_id		IN		NUMBER,
  p_ditem_id			IN		NUMBER) RETURN VARCHAR2;

FUNCTION item
( p_item_id			IN		NUMBER) RETURN VARCHAR2;

FUNCTION lot
( p_lot_id			IN		NUMBER) RETURN VARCHAR2;

FUNCTION org
( p_organization_id		IN		NUMBER) RETURN VARCHAR2;

END INV_GMI_Migration;

 

/
