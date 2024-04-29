--------------------------------------------------------
--  DDL for Package GME_MOBILE_RSRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MOBILE_RSRV" AUTHID CURRENT_USER AS
/*  $Header: GMEMORSS.pls 120.3.12010000.1 2008/07/25 10:29:01 appldev ship $   */
/*===========================================================================+
 |      Copyright (c) 2005 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 |===========================================================================|
 |                                                                           |
 | PL/SQL Package to support the (Java) GME Mobile Application.              |
 | Contains PL/SQL cursors used by the mobile reservation transactions       |
 |                                                                           |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 | Date          Who               What                                      |
 | ====          ===               ====                                      |
 | 26-Apr-05     Eddie Oumerretane First version                             |
 |                                                                           |
 +===========================================================================*/

TYPE t_genref IS REF CURSOR;

PROCEDURE Get_Material_Reservations(p_organization_id     IN         NUMBER,
                                    p_batch_id            IN         NUMBER,
                                    p_material_detail_id  IN         NUMBER,
                                    p_subinventory_code   IN         VARCHAR2,
                                    p_locator_id          IN         NUMBER,
                                    p_lot_number          IN         VARCHAR2,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_error_msg           OUT NOCOPY VARCHAR2,
                                    x_rsrv_cursor         OUT NOCOPY t_genref);

/* Bug#5663458
 * Created the following procedure
 */
PROCEDURE Get_Material_Dtl_Reservations(p_organization_id        IN         NUMBER,
                                           p_batch_id            IN         NUMBER,
                                           p_material_detail_id  IN         NUMBER,
                                           p_eff_loccontrol      IN         NUMBER,
                                           p_lotcontrol          IN         NUMBER,
                                           p_revcontrol          IN         NUMBER,
                                           x_return_status       OUT NOCOPY VARCHAR2,
                                           x_error_msg           OUT NOCOPY VARCHAR2,
                                           x_rsrv_cursor         OUT NOCOPY t_genref);


PROCEDURE Check_Rsrv_Exist(p_organization_id     IN         NUMBER,
                           p_batch_id            IN         NUMBER,
                           p_material_detail_id  IN         NUMBER,
                           p_subinventory_code   IN         VARCHAR2,
                           p_locator_id          IN         NUMBER,
                           p_lot_number          IN         VARCHAR2,
                           p_exclude_res_id      IN         NUMBER,
                           x_return_status       OUT NOCOPY VARCHAR2,
                           x_error_msg           OUT NOCOPY VARCHAR2,
                           x_rsrv_cursor         OUT NOCOPY t_genref);

PROCEDURE Get_Stacked_Messages(x_message OUT NOCOPY VARCHAR2);

PROCEDURE Create_Reservation(p_organization_id        IN NUMBER,
                               p_batch_id               IN NUMBER,
                               p_material_detail_id     IN NUMBER,
                               p_item_id                IN NUMBER,
                               p_revision               IN VARCHAR2,
                               p_subinventory_code      IN VARCHAR2,
                               p_locator_id             IN NUMBER,
                               p_lot_number             IN VARCHAR2,
                               p_reserved_qty           IN NUMBER,
                               p_reserved_uom_code      IN VARCHAR2,
                               p_sec_reserved_qty       IN NUMBER,
                               p_sec_reserved_uom_code  IN VARCHAR2,
                               p_requirement_date       IN DATE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_error_msg              OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Reservation(p_reservation_id         IN NUMBER,
                               p_revision               IN VARCHAR2,
                               p_subinventory_code      IN VARCHAR2,
                               p_locator_id             IN NUMBER,
                               p_lot_number             IN VARCHAR2,
                               p_reserved_qty           IN NUMBER,
                               p_reserved_uom_code      IN VARCHAR2,
                               p_sec_reserved_qty       IN NUMBER,
                               p_requirement_date       IN DATE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_error_msg              OUT NOCOPY VARCHAR2);



  PROCEDURE Get_Available_Qties (p_organization_id     IN NUMBER,
                                 p_inventory_item_id   IN NUMBER,
                                 p_revision            IN VARCHAR2,
                                 p_subinventory_code   IN VARCHAR2,
                                 p_locator_id          IN NUMBER,
                                 p_lot_number          IN VARCHAR2,
                                 p_revision_control IN VARCHAR2,
                                 p_lot_control      IN VARCHAR2,
                                 p_tree_mode        IN VARCHAR2,
                                 x_att_qty    OUT NOCOPY NUMBER,
                                 x_sec_att_qty OUT NOCOPY NUMBER,
                                 x_atr_qty    OUT NOCOPY NUMBER,
                                 x_sec_atr_qty OUT NOCOPY NUMBER);

PROCEDURE Check_UoM_Conv_Deviation(
                                   p_organization_id     IN  NUMBER
                                 , p_inventory_item_id   IN  NUMBER
                                 , p_lot_number          IN  VARCHAR2
                                 , p_primary_quantity    IN  NUMBER
                                 , p_primary_uom_code    IN  VARCHAR2
                                 , p_secondary_quantity  IN  NUMBER
                                 , p_secondary_uom_code  IN  VARCHAR2
                                 , x_return_status       OUT NOCOPY VARCHAR2
                                 , x_error_msg           OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Qty_Tree_For_Rsrv (p_organization_id     IN NUMBER,
                                  p_batch_id            IN NUMBER,
                                  p_material_detail_id  IN NUMBER,
                                  p_inventory_item_id   IN NUMBER,
                                  p_revision            IN VARCHAR2,
                                  p_subinventory_code   IN VARCHAR2,
                                  p_locator_id          IN NUMBER,
                                  p_lot_number          IN VARCHAR2,
                                  p_revision_control    IN VARCHAR2,
                                  p_lot_control         IN VARCHAR2,
                                  p_primary_qty         IN NUMBER,
                                  p_secondary_qty       IN NUMBER,
                                  x_tree_id             OUT NOCOPY NUMBER,
                                  x_atr                 OUT NOCOPY NUMBER,
                                  x_satr                OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_error_msg           OUT NOCOPY VARCHAR2);

  PROCEDURE Fetch_Atr_Qty (p_revision            IN VARCHAR2,
                           p_subinventory_code   IN VARCHAR2,
                           p_locator_id          IN NUMBER,
                           p_lot_number          IN VARCHAR2,
                           p_revision_control    IN VARCHAR2,
                           p_lot_control         IN VARCHAR2,
                           p_tree_id             IN NUMBER,
                           x_atr                 OUT NOCOPY NUMBER,
                           x_satr                OUT NOCOPY NUMBER,
                           x_return_status       OUT NOCOPY VARCHAR2,
                           x_error_msg           OUT NOCOPY VARCHAR2);

  PROCEDURE Fetch_Lot_Reservations(p_organization_id     IN         NUMBER,
                                   p_item_id            IN         NUMBER,
                                   p_lot_number          IN         VARCHAR2,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_error_msg           OUT NOCOPY VARCHAR2,
                                   x_rsrv_cursor         OUT NOCOPY t_genref);


END GME_MOBILE_RSRV;

/
