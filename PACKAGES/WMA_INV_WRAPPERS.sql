--------------------------------------------------------
--  DDL for Package WMA_INV_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMA_INV_WRAPPERS" AUTHID CURRENT_USER AS
/* $Header: wmainvws.pls 115.8 2003/06/09 18:59:02 kmreddy ship $ */

  PROCEDURE validateLot(p_inventory_item_id IN NUMBER,
                        p_organization_id   IN NUMBER,
                        p_lot_number        IN VARCHAR2,
                        x_lot_exp           OUT NOCOPY DATE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_err_msg           OUT NOCOPY VARCHAR2);

  PROCEDURE insertLot(p_header_id     IN NUMBER,
                      p_lot_number    IN VARCHAR2,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2);

  PROCEDURE updateLSAttributes(p_header_id     IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_err_msg       OUT NOCOPY VARCHAR2);

  PROCEDURE backflush(p_header_id     IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2);

  PROCEDURE createLpn(p_api_version     IN NUMBER,
                      p_commit          IN VARCHAR2,
                      p_lpn             IN VARCHAR2,
                      p_organization_id IN NUMBER,
                      p_source          IN NUMBER,
                      p_source_type_id  IN NUMBER,
                      x_return_status   OUT NOCOPY VARCHAR2,
                      x_err_msg         OUT NOCOPY VARCHAR2,
                      x_lpn_id          OUT NOCOPY VARCHAR2);

  PROCEDURE packLpnContainer(p_api_version IN NUMBER,
                      p_commit             IN VARCHAR2,
                      p_lpn_id             IN NUMBER,
                      p_content_item_id    IN NUMBER,
                      p_revision           IN VARCHAR2,
                      p_lot_number         IN VARCHAR2,
                      p_from_serial_number IN VARCHAR2,
                      p_to_serial_number   IN VARCHAR2,
                      p_quantity           IN NUMBER,
                      p_organization_id    IN NUMBER,
                      p_source_type_id     IN NUMBER,
                      p_uom                IN VARCHAR2,
                      x_return_status      OUT NOCOPY VARCHAR2,
                      x_err_msg            OUT NOCOPY VARCHAR2);

  PROCEDURE packSerials(p_api_version IN NUMBER,
                       p_commit             IN VARCHAR2,
                       p_lpn_id             IN NUMBER,
                       p_content_item_id    IN NUMBER,
                       p_revision           IN VARCHAR2,
                       p_lot_number         IN VARCHAR2,
                       p_from_serial_number IN VARCHAR2,
                       p_to_serial_number   IN VARCHAR2,
                       p_quantity           IN NUMBER,
                       p_organization_id    IN NUMBER,
                       p_source_type_id     IN NUMBER,
                       p_uom                IN VARCHAR2,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_err_msg            OUT NOCOPY VARCHAR2);

  PROCEDURE createMO(p_organization_id             IN NUMBER,
                     p_inventory_item_id           IN NUMBER,
                     p_quantity                    IN NUMBER,
                     p_uom                         IN VARCHAR2,
                     p_lpn_id                      IN NUMBER,
                     p_reference_id                IN NUMBER,
                     p_lot_number                  IN VARCHAR2,
                     p_revision                    IN VARCHAR2,
                     p_transaction_source_id       IN NUMBER,
                     p_transaction_type_id         IN NUMBER,
                     p_transaction_source_type_id  IN NUMBER,
                     p_wms_process_flag            IN NUMBER,
                     p_project_id                  IN NUMBER,
                     p_task_id                     IN NUMBER,
                     p_header_id                   IN OUT NOCOPY NUMBER,
                     x_line_id                     OUT NOCOPY NUMBER,
                     x_return_status               OUT NOCOPY VARCHAR2,
                     x_err_msg                     OUT NOCOPY VARCHAR2);

  PROCEDURE OkMOLines(p_lpn_id        IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2,
                      x_err_msg       OUT NOCOPY VARCHAR2);

  PROCEDURE updateLpnContext(p_api_version   IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             p_commit        IN VARCHAR2,
                             p_lpn_id        IN NUMBER,
                             p_lpn_context   IN NUMBER,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_err_msg       OUT NOCOPY VARCHAR2);

  --transferReservation -- transfers the sales order reservation from wip to inventory
  --                       for lpn completions.
  --
  --called by inventory for lpn completions. We can not process the sales order reservation
  --immediately as for lpn completions, the destination of the move order is not known, and
  --the assembly will not even be in that location until the move order is transacted. Thus,
  --inventory calls this procedure when the move order is transacted. This procedure may be
  --obsoleted if we ever change lpn completions to complete into a staging sub.
  --
  -- parameters:
  -- + p_header_id: unique key into the wip_lpn_completions table (header_id column)
  -- + p_subinventory_code: the destination subinv
  -- + p_locator_id: the destination locator id
  -- + p_primary_quantity: the quantity being transacted (not necessarily the quantity that
  --                       was completed. It could be a lesser value.
  -- + p_lpn_id: The lpn id to pass to the inventory API inv_reservation_pub.transfer_reservation()
  --             This value is:
  --             + The lpn_id of the completion if the entire txn quantity is being dropped.
  --             + The to lpn_id if the quantity is being dropped into an lpn
  --             + null if a partial quantity is being dropped loose into inventory
  -- + x_returnStatus: FND_API.G_RET_STS_SUCCESS on success.
  -- + x_msg_count: Number of messages on the message stack
  -- + x_msg
  PROCEDURE transferReservation(p_header_id      IN NUMBER, --the header_id to the wlc table
                                p_subinventory_code IN VARCHAR2,
                                p_locator_id        IN NUMBER,
                                p_primary_quantity  IN NUMBER,
                                p_lpn_id            IN NUMBER,
                                p_lot_number        IN VARCHAR2,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_err_msg           OUT NOCOPY VARCHAR2);

  PROCEDURE clearQtyTrees(x_return_status OUT NOCOPY VARCHAR2,
                          x_err_msg OUT NOCOPY VARCHAR2);

END wma_inv_wrappers;

 

/
