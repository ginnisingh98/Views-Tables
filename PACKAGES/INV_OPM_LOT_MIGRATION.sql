--------------------------------------------------------
--  DDL for Package INV_OPM_LOT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_OPM_LOT_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: INVLTMGS.pls 120.1 2006/10/25 16:11:34 jgogna noship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    INVLTMDS.pls                                                          |
 |                                                                          |
 | TYPE                                                                     |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    INV_OPM_Lot_Migration                                                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains the procedure used for lot migration in OPM     |
 |    convergence project. These procedures are meant for migration only.   |
 |                                                                          |
 | Contents                                                                 |
 |    get_ODM_lot                                                           |
 |                                                                          |
 | HISTORY                                                                  |
 |    Created - Jatinder Gogna - 3/22/05                                    |
 |                                                                          |
 |                                                                          |
 +==========================================================================+
*/

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_inventory_item_id		IN		NUMBER
, p_lot_no			IN		VARCHAR2
, p_sublot_no			IN		VARCHAR2
, p_organization_id		IN		NUMBER
, p_locator_id			IN		NUMBER
, p_commit			IN		VARCHAR2
, x_lot_number			OUT NOCOPY	VARCHAR2
, x_parent_lot_number		OUT NOCOPY	VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_lot_no			IN		VARCHAR2
, p_sublot_no			IN		VARCHAR2
, p_whse_code			IN		VARCHAR2
, p_orgn_code			IN		VARCHAR2
, p_location			IN		VARCHAR2
, p_get_parent_only		IN		NUMBER
, p_commit			IN		VARCHAR2
, x_lot_number			OUT NOCOPY	VARCHAR2
, x_parent_lot_number		OUT NOCOPY	VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER);

PROCEDURE get_ODM_lot
( p_migration_run_id		IN		NUMBER
, p_item_id			IN		NUMBER
, p_lot_id			IN		NUMBER
, p_whse_code			IN		VARCHAR2
, p_orgn_code			IN		VARCHAR2
, p_location			IN		VARCHAR2
, p_commit			IN		VARCHAR2
, x_lot_number			OUT NOCOPY	VARCHAR2
, x_parent_lot_number		OUT NOCOPY	VARCHAR2
, x_failure_count		OUT NOCOPY	NUMBER
, p_organization_id		IN		NUMBER	DEFAULT	NULL);


END INV_OPM_Lot_Migration;

 

/
