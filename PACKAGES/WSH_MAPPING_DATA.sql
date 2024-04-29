--------------------------------------------------------
--  DDL for Package WSH_MAPPING_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_MAPPING_DATA" AUTHID CURRENT_USER AS
/* $Header: WSHMAPDS.pls 120.1.12010000.5 2010/02/25 16:10:12 sankarun ship $ */

   C_SDEBUG  CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL1;
   C_DEBUG   CONSTANT   NUMBER := wsh_debug_sv.C_LEVEL2;


   PROCEDURE Get_Delivery_Info ( p_delivery_id          IN   NUMBER,
                                 p_document_type        IN   VARCHAR2,
                                 x_name                 OUT NOCOPY   VARCHAR2,
                                 x_arrival_date         OUT NOCOPY   DATE,
                                 x_departure_date       OUT NOCOPY   DATE,
                                 x_vehicle_num_prefix   OUT NOCOPY   VARCHAR2,
                                 x_vehicle_number       OUT NOCOPY   VARCHAR2,
                                 x_route_id		OUT NOCOPY   VARCHAR2,
                                 x_routing_instructions OUT NOCOPY   VARCHAR2,
                                 x_departure_seal_code  OUT NOCOPY   VARCHAR2,
				 x_customer_name	OUT NOCOPY   VARCHAR2,
				 x_customer_number	OUT NOCOPY   VARCHAR2,
				 x_warehouse_type	OUT NOCOPY   VARCHAR2,
--Bug 3458160
                                 x_operator             OUT NOCOPY   VARCHAR2,
                                 x_ship_to_loc_code     OUT NOCOPY   VARCHAR2,
                                 x_cnsgn_cont_per_name  OUT NOCOPY  VARCHAR2, --4227777
                                 x_cnsgn_cont_per_ph    OUT NOCOPY  VARCHAR2, --4227777
                                 x_return_status        OUT NOCOPY   VARCHAR2
   );

   PROCEDURE get_part_addr_info(
	p_partner_type		IN	VARCHAR2,
	p_delivery_id		IN	NUMBER,
	x_party_name		OUT NOCOPY  	VARCHAR2,
	x_partner_location	OUT NOCOPY 	VARCHAR2,
	x_currency		OUT NOCOPY 	VARCHAR2,
	x_duns_number		OUT NOCOPY 	VARCHAR2,
	x_intmed_ship_to_location OUT NOCOPY  	VARCHAR2,
	x_pooled_ship_to_location OUT NOCOPY  	VARCHAR2,
	x_address1		OUT NOCOPY  	VARCHAR2,
	x_address2		OUT NOCOPY  	VARCHAR2,
	x_address3		OUT NOCOPY  	VARCHAR2,
	x_address4		OUT NOCOPY  	VARCHAR2,
	x_city			OUT NOCOPY  	VARCHAR2,
	x_country		OUT NOCOPY  	VARCHAR2,
	x_county		OUT NOCOPY  	VARCHAR2,
	x_postal_code		OUT NOCOPY  	VARCHAR2,
	x_region		OUT NOCOPY  	VARCHAR2,
	x_state			OUT NOCOPY  	VARCHAR2,
	x_fax_number		OUT NOCOPY  	VARCHAR2,
	x_telephone		OUT NOCOPY  	VARCHAR2,
	x_url			OUT NOCOPY  	VARCHAR2,
	x_return_status 	OUT NOCOPY 	VARCHAR2);

PROCEDURE get_ship_method_code(
        p_carrier_name              IN     VARCHAR2,
        p_service_level             IN     VARCHAR2 DEFAULT NULL,
        p_mode_of_transport         IN     VARCHAR2 DEFAULT NULL,
        p_doc_type                  IN     VARCHAR2,
        p_delivery_name             IN     VARCHAR2 DEFAULT NULL,
        x_ship_method_code          OUT NOCOPY     VARCHAR2,
        x_return_status             OUT NOCOPY     VARCHAR2);


    -- ---------------------------------------------------------------------
    -- Procedure:	Get_Locn_Cust_Info
    --
    -- Parameters:
    --
    -- Description:  This procedure gets the location, party_name, party_number
    --               that are required for SHIPITEM and SHIPUNIT during
    --                  940/945 outbound
    -- Created:   Locations Project. Patchset I. KVENKATE
    -- -----------------------------------------------------------------------
PROCEDURE get_locn_cust_info(
        p_location_id      IN   NUMBER,
        p_org_id           IN   NUMBER,
        p_customer_id      IN   NUMBER,
        x_location         OUT NOCOPY VARCHAR2,
        x_party_name       OUT NOCOPY VARCHAR2,
        x_party_number     OUT NOCOPY VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        p_delivery_detail_id IN     NUMBER,
	p_wsn_rowid	     IN     VARCHAR2,
        p_requested_quantity IN   NUMBER,
        p_fm_serial_number   IN   VARCHAR2,
        p_to_serial_number   IN   VARCHAR2,
	x_requested_quantity OUT  NOCOPY NUMBER,
	x_shipped_quantity   OUT  NOCOPY NUMBER,
         p_site_use_id      IN  NUMBER,
        --bug 4227777
        p_entity_type        IN VARCHAR2,
        x_cnsgn_cont_per_name OUT NOCOPY VARCHAR2,
        x_cnsgn_cont_per_ph OUT NOCOPY VARCHAR2
);

--R12.1.1 STANDALONE PROJECT NEW API
PROCEDURE Get_Stnd_Delivery_Info ( p_delivery_id          IN           NUMBER   ,
                                   x_name                 OUT NOCOPY   VARCHAR2 ,
                                   x_org_id               OUT NOCOPY   NUMBER   ,
                                   x_arrival_date         OUT NOCOPY   DATE     ,
                                   x_departure_date       OUT NOCOPY   DATE     ,
                                   x_vehicle_num_prefix   OUT NOCOPY   VARCHAR2 ,
                                   x_vehicle_number       OUT NOCOPY   VARCHAR2 ,
                                   x_route_id             OUT NOCOPY   VARCHAR2 ,
                                   x_routing_instructions OUT NOCOPY   VARCHAR2 ,
                                   x_departure_seal_code  OUT NOCOPY   VARCHAR2 ,
                                   x_operator             OUT NOCOPY   VARCHAR2 ,
                                   x_ship_to_loc_code     OUT NOCOPY   VARCHAR2 ,
                                   x_pack_slip_num        OUT NOCOPY   VARCHAR2 ,
                                   x_bill_of_lading_num   OUT NOCOPY   VARCHAR2 ,
                                   -- Distributed - TPW Changes
                                   x_customer_name        OUT NOCOPY   VARCHAR2 ,
                                   x_return_status        OUT NOCOPY   VARCHAR2
                                 );

--R12.1.1 STANDALONE PROJECT NEW API
PROCEDURE Get_Delivery_Detail_Info(
                                    p_src_line_id            IN         NUMBER  ,
                                    p_delivery_detail_id     IN         NUMBER  ,
                                    p_detail_seq_number      IN         NUMBER  ,
                                    p_locator_id             IN         NUMBER  ,
                                    -- Distributed - TPW Changes
                                    p_wsn_rowid              IN         VARCHAR2,
                                    p_serial_type            IN         VARCHAR2 ,
                                    p_requested_quantity     IN         NUMBER,
                                    x_requested_quantity     OUT NOCOPY NUMBER,
                                    x_shipped_quantity       OUT NOCOPY NUMBER,
                                    x_open_quantity          OUT NOCOPY NUMBER  ,
                                    x_bo_quantity            OUT NOCOPY NUMBER  ,
                                    x_locator_code           OUT NOCOPY VARCHAR2,
                                    x_shipto_cont_per_name   OUT NOCOPY VARCHAR2,
                                    x_shipto_cont_per_ph     OUT NOCOPY VARCHAR2,
                                    x_shipto_cont_per_id     OUT NOCOPY NUMBER  ,
                                    x_document_type          OUT NOCOPY VARCHAR2,
                                    x_document_id            OUT NOCOPY NUMBER  ,
                                    x_line_number            OUT NOCOPY NUMBER  ,
                                    x_return_status          OUT NOCOPY VARCHAR2
                                  );

--R12.1.1 STANDALONE PROJECT NEW API
PROCEDURE get_detail_part_addr_info(
                                    p_delivery_detail_id    IN              NUMBER  ,
                                    p_entity_type           IN              VARCHAR2,
                                    p_org_id                IN              NUMBER  ,
                                    p_partner_type          IN              VARCHAR2,
                                    x_partner_id            OUT NOCOPY      NUMBER  ,
                                    x_partner_name          OUT NOCOPY      VARCHAR2,
                                    x_partner_location      OUT NOCOPY      VARCHAR2,
                                    x_duns_number           OUT NOCOPY      VARCHAR2,
                                    x_address_id            OUT NOCOPY      NUMBER  ,
                                    x_address1              OUT NOCOPY      VARCHAR2,
                                    x_address2              OUT NOCOPY      VARCHAR2,
                                    x_address3              OUT NOCOPY      VARCHAR2,
                                    x_address4              OUT NOCOPY      VARCHAR2,
                                    x_city                  OUT NOCOPY      VARCHAR2,
                                    x_country               OUT NOCOPY      VARCHAR2,
                                    x_county                OUT NOCOPY      VARCHAR2,
                                    x_postal_code           OUT NOCOPY      VARCHAR2,
                                    x_region                OUT NOCOPY      VARCHAR2,
                                    x_state                 OUT NOCOPY      VARCHAR2,
                                    x_contact_id            OUT NOCOPY      NUMBER  ,
                                    x_contact_name          OUT NOCOPY      VARCHAR2,
                                    x_contact_telephone     OUT NOCOPY      VARCHAR2,
                                    x_return_status         OUT NOCOPY      VARCHAR2
                                    );

--R12.1.1 STANDALONE PROJECT NEW API
PROCEDURE Get_Cust_addr_Info (
                               p_site_id               IN              NUMBER  ,
                               p_contact_id            IN              NUMBER  ,
                               p_org_id                IN              NUMBER  ,
                               x_partner_id            OUT NOCOPY      NUMBER  ,
                               x_partner_name          OUT NOCOPY      VARCHAR2,
                               x_partner_location      OUT NOCOPY      VARCHAR2,
                               x_duns_number           OUT NOCOPY      VARCHAR2,
                               x_address_id            OUT NOCOPY      NUMBER  ,
                               x_address1              OUT NOCOPY      VARCHAR2,
                               x_address2              OUT NOCOPY      VARCHAR2,
                               x_address3              OUT NOCOPY      VARCHAR2,
                               x_address4              OUT NOCOPY      VARCHAR2,
                               x_city                  OUT NOCOPY      VARCHAR2,
                               x_country               OUT NOCOPY      VARCHAR2,
                               x_county                OUT NOCOPY      VARCHAR2,
                               x_postal_code           OUT NOCOPY      VARCHAR2,
                               x_region                OUT NOCOPY      VARCHAR2,
                               x_state                 OUT NOCOPY      VARCHAR2,
                               x_contact_name          OUT NOCOPY      VARCHAR2,
                               x_contact_telephone     OUT NOCOPY      VARCHAR2,
                               x_return_status         OUT NOCOPY      VARCHAR2
                             );

--R12.1.1 STANDALONE PROJECT NEW API
PROCEDURE Get_Del_Part_Addr_Info(
                                 p_partner_type            IN            VARCHAR2,
                                 p_delivery_id             IN            NUMBER  ,
                                 p_org_id                  IN            NUMBER  ,
                                 x_partner_id              OUT NOCOPY    NUMBER  ,
                                 x_partner_name            OUT NOCOPY    VARCHAR2,
                                 x_partner_location        OUT NOCOPY    VARCHAR2,
                                 x_duns_number             OUT NOCOPY    VARCHAR2,
                                 x_intmed_ship_to_location OUT NOCOPY    VARCHAR2,
                                 x_pooled_ship_to_location OUT NOCOPY    VARCHAR2,
                                 x_address_id              OUT NOCOPY    NUMBER  ,
                                 x_address1                OUT NOCOPY    VARCHAR2,
                                 x_address2                OUT NOCOPY    VARCHAR2,
                                 x_address3                OUT NOCOPY    VARCHAR2,
                                 x_address4                OUT NOCOPY    VARCHAR2,
                                 x_city                    OUT NOCOPY    VARCHAR2,
                                 x_country                 OUT NOCOPY    VARCHAR2,
                                 x_county                  OUT NOCOPY    VARCHAR2,
                                 x_postal_code             OUT NOCOPY    VARCHAR2,
                                 x_region                  OUT NOCOPY    VARCHAR2,
                                 x_state                   OUT NOCOPY    VARCHAR2,
                                 x_contact_id              OUT NOCOPY    NUMBER  ,
                                 x_contact_name            OUT NOCOPY    VARCHAR2,
                                 x_telephone               OUT NOCOPY    VARCHAR2,
                                 x_return_status           OUT NOCOPY    VARCHAR2
                                );


-- TPW - Distributed Organization Changes
PROCEDURE get_ship_method_details(
          p_ship_method_code  IN VARCHAR2,
          x_carrier_code      OUT NOCOPY VARCHAR2,
          x_service_level     OUT NOCOPY VARCHAR2,
          x_mode_of_transport OUT NOCOPY VARCHAR2,
          x_return_status   OUT NOCOPY VARCHAR2 );

PROCEDURE get_batch_addr_info (
          p_partner_type  IN  VARCHAR2,
          p_batch_id      IN  NUMBER,
          x_partner_id    OUT NOCOPY NUMBER,
          x_partner_name  OUT NOCOPY VARCHAR2,
          x_address_id    OUT NOCOPY NUMBER,
          x_address1      OUT NOCOPY VARCHAR2,
          x_address2      OUT NOCOPY VARCHAR2,
          x_address3      OUT NOCOPY VARCHAR2,
          x_address4      OUT NOCOPY VARCHAR2,
          x_city          OUT NOCOPY VARCHAR2,
          x_country       OUT NOCOPY VARCHAR2,
          x_county        OUT NOCOPY VARCHAR2,
          x_postal_code   OUT NOCOPY VARCHAR2,
          x_region        OUT NOCOPY VARCHAR2,
          x_state         OUT NOCOPY VARCHAR2,
          x_contact_id    OUT NOCOPY NUMBER,
          x_contact_name  OUT NOCOPY VARCHAR2,
          x_telephone     OUT NOCOPY VARCHAR2,
          x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE get_detail_line_info (
          p_reference_line_id      IN NUMBER,
          x_line_number            OUT NOCOPY NUMBER,
          x_line_quantity          OUT NOCOPY VARCHAR2,
          x_line_quantity_uom      OUT NOCOPY VARCHAR2,
          x_item_number            OUT NOCOPY VARCHAR2,
          x_item_description       OUT NOCOPY VARCHAR2,
          x_unit_selling_price     OUT NOCOPY NUMBER,
          x_packing_instructions   OUT NOCOPY VARCHAR2,
          x_shipping_instructions  OUT NOCOPY VARCHAR2,
          x_request_date           OUT NOCOPY DATE,
          x_schedule_date          OUT NOCOPY DATE,
          x_shipment_priority_code OUT NOCOPY VARCHAR2,
          x_ship_tolerance_above   OUT NOCOPY NUMBER,
          x_ship_tolerance_below   OUT NOCOPY NUMBER,
          x_set_name               OUT NOCOPY VARCHAR2,
          x_customer_item_number   OUT NOCOPY VARCHAR2,
          x_cust_po_number         OUT NOCOPY VARCHAR2,
          x_subinventory           OUT NOCOPY VARCHAR2,
          x_return_status          OUT NOCOPY VARCHAR2);

END WSH_MAPPING_DATA;

/
