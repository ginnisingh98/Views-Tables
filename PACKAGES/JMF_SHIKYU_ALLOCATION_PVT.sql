--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_ALLOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_ALLOCATION_PVT" AUTHID CURRENT_USER as
--$Header: JMFVSKAS.pls 120.5.12010000.1 2008/07/21 09:23:43 appldev ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME   :      JMFVSKAS.pls                                           |
--|                                                                           |
--|  DESCRIPTION:      Specification file of the Allocations package          |
--|                    for the Charge Based SHIKYU project.                   |
--|                                                                           |
--| PUBLIC FUNCTIONS/PROCEDURES:                                              |
--|   Allocate_Quantity                                                       |
--|   Allocate_Quantity                                                       |
--|   Get_Available_Replenishment_So                                          |
--|   Get_Available_Replenishment_Po                                          |
--|   Create_New_Replenishment_Po_So                                          |
--|   Create_New_Replenishment_So                                             |
--|   Create_New_Allocations                                                  |
--|   Allocate_Prepositioned_Comp                                             |
--|   Allocate_Syncship_Comp                                                  |
--|   Reduce_Allocations                                                      |
--|   Delete_Allocations                                                      |
--|   Reconcile_Partial_Shipments                                             |
--|   Reconcile_Closed_Shipments                                              |
--|   Reconcile_Replen_Excess_Qty                                             |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   29-APR-2005      vchu  Created.                                         |
--|   07-JUL-2005      vchu  Uncommented COMMIT and EXIT statements.          |
--|   12-AUG-2005      vchu  Changed type definitions because of code fixes   |
--|                          in package body.                                 |
--|   18-AUG-2005      vchu  Removed the global exceptions.                   |
--|   09-NOV-2005      vchu  Added schedule_ship_date to the                  |
--|                          g_replen_so_qty_rec_type record type, in order   |
--|                          to support the newly added order by statement of |
--|                          the c_avail_replen_so_cur cursor declared for    |
--|                          the Get_Available_Replenishment_So procedure.    |
--|   02-MAY-2006      vchu  Bug 5197415: Added the p_skip_po_replen_creation |
--|                          parameter to Create_New_Allocations and          |
--|                          Allocate_Syncship_Comp, in order to give the     |
--|                          option of skipping the creation of new           |
--|                          Replenishment POs for sync-ship components.      |
--|                          The Interlock Concurrent Program would use this  |
--|                          option if creation of Replenishment SOs has      |
--|                          already failed when trying to create             |
--|                          Replenishment SOs for the Replenishment POs      |
--|                          that do not yet present in the                   |
--|                          JMF_SHIKYU_REPLENISHMENTS table.                 |
--+===========================================================================+

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_ALLOCATIONS_PVT';

TYPE g_replen_so_qty_rec_type IS RECORD
  ( replenishment_so_line_id NUMBER
  , component_id             NUMBER
  , qty                      NUMBER
  , uom                      VARCHAR2(3)
  , primary_uom_qty          NUMBER
  , primary_uom              VARCHAR2(3)
  , schedule_ship_date       DATE
  );

TYPE g_replen_so_qty_tbl_type IS TABLE OF g_replen_so_qty_rec_type INDEX BY BINARY_INTEGER;

TYPE g_replen_po_qty_rec_type IS RECORD
  ( replenishment_po_shipment_id NUMBER
  , component_id                 NUMBER
  , qty                          NUMBER
  , uom                          VARCHAR2(3)
  , primary_uom_qty              NUMBER
  , primary_uom                  VARCHAR2(3)
  , po_shipment_need_by_date   PO_LINE_LOCATIONS_ALL.NEED_BY_DATE%TYPE
  , po_header_num              PO_HEADERS_ALL.SEGMENT1%TYPE
  , po_line_num                PO_LINES.LINE_NUM%TYPE
  , po_shipment_num            PO_LINE_LOCATIONS_ALL.SHIPMENT_NUM%TYPE
  );

TYPE g_replen_po_qty_tbl_type IS TABLE OF g_replen_po_qty_rec_type INDEX BY BINARY_INTEGER;

TYPE g_allocation_qty_rec_type IS RECORD
  ( subcontract_po_shipment_id NUMBER
  , replenishment_so_line_id   NUMBER
  , component_id               NUMBER
  , qty                        NUMBER
  , qty_uom                    VARCHAR2(3)
  );

TYPE g_allocation_qty_tbl_type IS TABLE OF g_allocation_qty_rec_type INDEX BY BINARY_INTEGER;

--==============================
-- PROCEDURES/FUNCTIONS
--==============================

PROCEDURE Allocate_Quantity
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_replen_so_line_id          IN  NUMBER
, p_primary_uom                IN  VARCHAR2
, p_qty_to_allocate            IN  NUMBER
, x_qty_allocated              OUT NOCOPY NUMBER
);

PROCEDURE Allocate_Quantity
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty_to_allocate            IN  NUMBER
, p_available_replen_tbl       IN  g_replen_so_qty_tbl_type
, x_qty_allocated              OUT NOCOPY NUMBER
);

PROCEDURE Get_Available_Replenishment_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_include_additional_supply  IN  VARCHAR2
, p_arrived_so_lines_only      IN  VARCHAR2
, x_available_replen_tbl       OUT NOCOPY g_replen_so_qty_tbl_type
, x_remaining_qty              OUT NOCOPY NUMBER
);

PROCEDURE Get_Available_Replenishment_Po
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, x_available_replen_tbl       OUT NOCOPY g_replen_po_qty_tbl_type
, x_remaining_qty              OUT NOCOPY NUMBER
);

PROCEDURE Create_New_Replenishment_Po_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, x_new_replen_so_rec          OUT NOCOPY g_replen_so_qty_rec_type
);

PROCEDURE Create_New_Replenishment_So
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_additional_supply          IN  VARCHAR2
, x_new_replen_tbl             OUT NOCOPY g_replen_so_qty_tbl_type
);

PROCEDURE Create_New_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_skip_po_replen_creation    IN  VARCHAR2
);

PROCEDURE Allocate_Prepositioned_Comp
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
);

PROCEDURE Allocate_Syncship_Comp
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_qty                        IN  NUMBER
, p_skip_po_replen_creation    IN  VARCHAR2
);

-- Reduce the current allocation quantity
PROCEDURE Reduce_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_replen_so_line_id          IN  NUMBER
, p_qty_to_reduce              IN  NUMBER
, x_actual_reduced_qty         OUT NOCOPY NUMBER
, x_reduced_allocations_tbl    OUT NOCOPY g_allocation_qty_tbl_type
);

-- Delete All Allocations
-- All allocations for the subtracting component would be removed
-- if p_replen_so_line_id is NULL
PROCEDURE Delete_Allocations
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_component_id               IN  NUMBER
, p_replen_so_line_id          IN  NUMBER
, x_deleted_allocations_tbl    OUT NOCOPY g_allocation_qty_tbl_type
);

-- Algorithm:
-- 1) Decrease Allocations
-- 2) Update JMF_SHIKYU_REPLENISHMENTS table:
-- i) the ORDERED_QUANTITY and ALLOCABLE_QUANTITY of the splitted (parent) line
-- ii) insert the child line into the table

PROCEDURE Reconcile_Partial_Shipments
( p_api_version       IN  NUMBER
, p_init_msg_list     IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, p_from_organization IN NUMBER
, p_to_organization   IN NUMBER
);

PROCEDURE Reconcile_Closed_Shipments
( p_api_version                IN  NUMBER
, p_init_msg_list              IN  VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
);

PROCEDURE Reconcile_Replen_Excess_Qty
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_replen_order_line_id IN  NUMBER
, p_excess_qty           IN  NUMBER
);

END JMF_SHIKYU_ALLOCATION_PVT;

/
