--------------------------------------------------------
--  DDL for Package CSD_MASS_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_MASS_RCV_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvmsss.pls 120.1.12010000.3 2009/08/27 09:11:28 subhat ship $ */

   TYPE instance_rec_type IS RECORD (
      inventory_item_id        NUMBER,
      item_revision            VARCHAR2(3),   --swai: bug 7152053 (FP of 7134021)
      instance_id              NUMBER,
      instance_number          VARCHAR2 (30),
      serial_number            VARCHAR2 (30),
      lot_number               VARCHAR2 (80), -- fix for bug#4625226
      quantity                 NUMBER,
      uom                      VARCHAR2 (3),
      party_site_use_id        NUMBER,
      party_id                 NUMBER,
      account_id               NUMBER,
      mfg_serial_number_flag   VARCHAR2 (1),-- This indicates if the serial number being created
                                            -- is manufacted serial number. The value for this
                                            -- should always be 'N' for a new instance.
      external_reference       VARCHAR2(30) -- subhat, external reference support.
   );

-- This procedure will be called from the Serial number capture screen, when user
-- clicks the OK button
-- It is a wrapper API, which subsequntly calls other API
   PROCEDURE mass_create_ro (
      p_api_version            IN              NUMBER,
      p_commit                 IN              VARCHAR2,
      p_init_msg_list          IN              VARCHAR2,
      p_validation_level       IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_repair_order_line_id   IN              NUMBER,
      p_add_to_order_flag      IN              VARCHAR2
   );

-- This procedure will be called from mass_create_ro to create repair orders
   PROCEDURE process_ro (
      p_api_version         IN              NUMBER,
      p_commit              IN              VARCHAR2,
      p_init_msg_list       IN              VARCHAR2,
      p_validation_level    IN              NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_repair_line_id      IN             NUMBER,
      p_prod_txn_tbl        IN OUT NOCOPY   csd_process_pvt.product_txn_tbl,
      p_add_to_order_flag   IN              VARCHAR2,
      p_mass_ro_sn_id       IN              NUMBER,
      p_serial_number       IN              VARCHAR2,
      p_instance_id         IN              NUMBER,
      x_new_repln_id        OUT NOCOPY      NUMBER
   ) ;

-- This api would be called from the serial number capture screen.  If user enters
-- serialized and ib
-- trackable item,  and the serial number does not exist in IB, then message pops .
-- If users clicks OK
-- button then this API would be called to create a new instance.
   PROCEDURE create_item_instance (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      px_instance_rec       IN OUT NOCOPY   instance_rec_type,
      x_instance_id        OUT NOCOPY      NUMBER
   );


-- THis API will create the product transaction/charge line/submits and
-- books chargeline.
   PROCEDURE create_product_txn (
      p_api_version         IN              NUMBER,
      p_commit              IN              VARCHAR2,
      p_init_msg_list       IN              VARCHAR2,
      p_validation_level    IN              NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_product_txn_rec     IN OUT NOCOPY   csd_process_pvt.product_txn_rec,
      p_add_to_order_flag   IN              VARCHAR2
   );

--This api will identify if the item is ib trackable
   FUNCTION is_item_ib_trackable (p_inv_item_id IN NUMBER)
      RETURN BOOLEAN;
END csd_mass_rcv_pvt;                                          -- Package spec

/
