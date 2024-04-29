--------------------------------------------------------
--  DDL for Package INV_OPM_ITEM_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_OPM_ITEM_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: INVGIMGS.pls 120.3 2006/10/26 21:11:18 jgogna noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVGIMGS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |    Public                                                                |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INV_OPM_Item_Migration                                                |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for item migration for OPM   |
 |    convergence project. These procedure are meant for migration only.    |
 |                                                                          |
 | Contents                                                                 |
 |    get_ODM_item                                                          |
 |    get_ODM_regulatory_item                                               |
 |    migrate_opm_items                                                     |
 |    migrate_obsolete_columns                                              |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE get_ODM_item
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_organization_id		IN		NUMBER
, p_mode			IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_inventory_item_id		OUT NOCOPY	NUMBER
, x_failure_count               OUT NOCOPY	NUMBER
, p_item_code			IN		VARCHAR2 DEFAULT NULL
, p_item_source			IN		VARCHAR2 DeFAULT 'GMI'
);

PROCEDURE get_ODM_regulatory_item
( p_migration_run_id		IN		NUMBER
, p_item_code			IN		VARCHAR2
, p_organization_id		IN		NUMBER
, p_mode			IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_inventory_item_id		OUT NOCOPY	NUMBER
, x_failure_count               OUT NOCOPY	NUMBER);

PROCEDURE migrate_obsolete_columns
( p_migration_run_id		IN		NUMBER
, p_obsolete_column_name	IN		VARCHAR2
, p_flexfield_column_name	IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE validate_item_controls
( p_migration_run_id		IN	NUMBER);

PROCEDURE validate_desc_flex_definition
( p_migration_run_id		IN	NUMBER);

g_desc_flex_conflict	PLS_INTEGER;
g_attribute_context	PLS_INTEGER;
g_attribute1	PLS_INTEGER;
g_attribute2	PLS_INTEGER;
g_attribute3	PLS_INTEGER;
g_attribute4	PLS_INTEGER;
g_attribute5	PLS_INTEGER;
g_attribute6	PLS_INTEGER;
g_attribute7	PLS_INTEGER;
g_attribute8	PLS_INTEGER;
g_attribute9	PLS_INTEGER;
g_attribute10	PLS_INTEGER;
g_attribute11	PLS_INTEGER;
g_attribute12	PLS_INTEGER;
g_attribute13	PLS_INTEGER;
g_attribute14	PLS_INTEGER;
g_attribute15	PLS_INTEGER;
g_attribute16	PLS_INTEGER;
g_attribute17	PLS_INTEGER;
g_attribute18	PLS_INTEGER;
g_attribute19	PLS_INTEGER;
g_attribute20	PLS_INTEGER;
g_attribute21	PLS_INTEGER;
g_attribute22	PLS_INTEGER;
g_attribute23	PLS_INTEGER;
g_attribute24	PLS_INTEGER;
g_attribute25	PLS_INTEGER;
g_attribute26	PLS_INTEGER;
g_attribute27	PLS_INTEGER;
g_attribute28	PLS_INTEGER;
g_attribute29	PLS_INTEGER;
g_attribute30	PLS_INTEGER;

END INV_OPM_Item_Migration;

 

/
