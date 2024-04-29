--------------------------------------------------------
--  DDL for Package INV_TABLE_LOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TABLE_LOCK_PVT" AUTHID CURRENT_USER AS
/* $Header: INVLOCKS.pls 120.4.12010000.2 2009/05/15 22:34:02 musinha ship $ */

 FUNCTION lock_onhand_records (
          p_organization_id   IN NUMBER
        , p_inventory_item_id IN NUMBER
        , p_revision          IN VARCHAR2
        , p_lot               IN VARCHAR2
        , p_subinventory      IN VARCHAR2
        , p_locator           IN VARCHAR2
	      , p_issue_receipt     IN NUMBER
        , p_header_id         IN NUMBER) RETURN BOOLEAN;

 PROCEDURE get_lock_handle (
          p_header_id   IN         NUMBER
        , p_lock_name   IN         VARCHAR2
			  , x_lock_handle OUT NOCOPY VARCHAR2);

 PROCEDURE release_locks;

 PROCEDURE release_locks(
          p_header_id IN NUMBER
        , p_commit    IN NUMBER DEFAULT 0);

 -- Bug 6636261: Acquiring lock for a row in MLN
 PROCEDURE lock_lot_record ( p_organization_id   IN NUMBER
                            ,p_inventory_item_id IN NUMBER
                            ,p_lot IN VARCHAR2);

 -- Bug 6636261: Acquiring lock handle for a row in MLN
 PROCEDURE get_lot_lock_handle ( p_lock_name IN VARCHAR2
                                ,x_lock_handle OUT NOCOPY VARCHAR2 );


END INV_TABLE_LOCK_PVT;

/
