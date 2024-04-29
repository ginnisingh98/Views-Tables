--------------------------------------------------------
--  DDL for Package RCV_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: RCVAVALS.pls 120.0 2005/06/02 01:06:52 appldev noship $*/
   PROCEDURE get_available_supply_demand(
      x_return_status             OUT NOCOPY    VARCHAR2,
      x_msg_count                 OUT NOCOPY    NUMBER,
      x_msg_data                  OUT NOCOPY    VARCHAR2,
      x_available_quantity        OUT NOCOPY    NUMBER,
      x_source_uom_code           OUT NOCOPY    VARCHAR2,
      x_source_primary_uom_code   OUT NOCOPY    VARCHAR2,
      p_supply_demand_code        IN            NUMBER,
      p_organization_id           IN            NUMBER DEFAULT NULL,
      p_item_id                   IN            NUMBER DEFAULT NULL,
      p_revision                  IN            VARCHAR2 DEFAULT NULL,
      p_lot_number                IN            VARCHAR2 DEFAULT NULL,
      p_subinventory_code         IN            VARCHAR2 DEFAULT NULL,
      p_locator_id                IN            NUMBER DEFAULT NULL,
      p_supply_demand_type_id     IN            NUMBER,
      p_supply_demand_header_id   IN            NUMBER,
      p_supply_demand_line_id     IN            NUMBER,
      p_supply_demand_line_detail IN            NUMBER DEFAULT fnd_api.g_miss_num,
      p_lpn_id                    IN            NUMBER DEFAULT fnd_api.g_miss_num,
      p_project_id                IN            NUMBER DEFAULT NULL,
      p_task_id                   IN            NUMBER DEFAULT NULL,
      p_api_version_number        IN            NUMBER DEFAULT 1.0,
      p_init_msg_lst              IN            VARCHAR2 DEFAULT fnd_api.g_false
   );

   PROCEDURE validate_supply_demand(
      x_return_status             OUT NOCOPY    VARCHAR2,
      x_msg_count                 OUT NOCOPY    NUMBER,
      x_msg_data                  OUT NOCOPY    VARCHAR2,
      x_valid_status              OUT NOCOPY    VARCHAR2,
      p_organization_id           IN            NUMBER,
      p_item_id                   IN            NUMBER,
      p_supply_demand_code        IN            NUMBER,
      p_supply_demand_type_id     IN            NUMBER,
      p_supply_demand_header_id   IN            NUMBER,
      p_supply_demand_line_id     IN            NUMBER,
      p_supply_demand_line_detail IN            NUMBER DEFAULT fnd_api.g_miss_num,
      p_demand_ship_date          IN            DATE,
      p_expected_receipt_date     IN            DATE,
      p_api_version_number        IN            NUMBER DEFAULT 1.0,
      p_init_msg_lst              IN            VARCHAR2 DEFAULT fnd_api.g_false
   );
END rcv_availability;

 

/