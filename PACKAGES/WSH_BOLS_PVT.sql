--------------------------------------------------------
--  DDL for Package WSH_BOLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BOLS_PVT" AUTHID CURRENT_USER AS
-- $Header: WSHBLTHS.pls 120.0 2005/05/26 18:48:58 appldev noship $

PROCEDURE update_Row
  (   p_api_version               IN      NUMBER
    , p_init_msg_list             IN      VARCHAR2
    , p_commit                    IN      VARCHAR2
    , p_validation_level          IN      NUMBER
    , x_return_status             OUT NOCOPY      VARCHAR2
    , x_msg_count                 OUT NOCOPY      NUMBER
    , x_msg_data                  OUT NOCOPY      VARCHAR2
    , p_entity_name               IN      VARCHAR2
    , x_entity_id                 IN  OUT NOCOPY  NUMBER
    , p_document_type             IN      VARCHAR2
/* Commented for shipping datamodel changes bug#1918342
    , p_pod_flag                  IN      VARCHAR2
    , p_pod_by                    IN      VARCHAR2
    , p_pod_date                  IN      DATE
    , p_reason_of_transport       IN      VARCHAR2
    , p_description               IN      VARCHAR2
    , p_cod_amount                IN      NUMBER
    , p_cod_currency_code         IN      VARCHAR2
    , p_cod_remit_to              IN      VARCHAR2
    , p_cod_charge_paid_by        IN      VARCHAR2
    , p_problem_contact_reference IN      VARCHAR2
    , p_bill_freight_to           IN      VARCHAR2
    , p_carried_by                IN      VARCHAR2
    , p_port_of_loading           IN      VARCHAR2
    , p_port_of_discharge         IN      VARCHAR2
    , p_booking_office            IN      VARCHAR2
    , p_booking_number            IN      VARCHAR2
    , p_service_contract          IN      VARCHAR2
    , p_shipper_export_ref        IN      VARCHAR2
    , p_carrier_export_ref        IN      VARCHAR2
    , p_bol_notify_party          IN      VARCHAR2
    , p_supplier_code             IN      VARCHAR2
    , p_aetc_number               IN      VARCHAR2
    , p_shipper_signed_by         IN      VARCHAR2
    , p_shipper_date              IN      DATE
    , p_carrier_signed_by         IN      VARCHAR2
    , p_carrier_date              IN      DATE
    , p_bol_issue_office          IN      VARCHAR2
    , p_bol_issued_by             IN      VARCHAR2
    , p_bol_date_issued           IN      DATE
    , p_shipper_hm_by             IN      VARCHAR2
    , p_shipper_hm_date           IN      DATE
    , p_carrier_hm_by             IN      VARCHAR2
    , p_carrier_hm_date           IN      DATE
    , p_ledger_id                 IN      NUMBER  */ -- LE Uptake
    , p_consolidate_option        IN      VARCHAR2
    , x_trip_id                   IN OUT NOCOPY   NUMBER
    , x_trip_name                 IN OUT NOCOPY   VARCHAR2
    , p_pick_up_location_id       IN      NUMBER
    , p_drop_off_location_id      IN      NUMBER
    , p_carrier_id                IN      NUMBER
    , p_ship_method               IN      VARCHAR2
    , p_delivery_id               IN      NUMBER
    , x_document_number           IN OUT NOCOPY   VARCHAR2
  );



PROCEDURE insert_row
  (x_return_status             IN OUT NOCOPY  VARCHAR2,
   x_msg_count                 IN OUT NOCOPY  VARCHAR2,
   x_msg_data                  IN OUT NOCOPY  VARCHAR2,
   p_entity_name               IN     VARCHAR2,
   x_entity_id                 IN OUT NOCOPY  NUMBER,
   p_application_id            IN     NUMBER,
   p_location_id               IN     NUMBER,
   p_document_type             IN     VARCHAR2,
   p_document_sub_type         IN     VARCHAR2,
/* Commented for shipping Data model changes bug#1918342
   p_pod_flag                  IN     VARCHAR2,
   p_pod_by                    IN     VARCHAR2,
   p_pod_date                  IN     DATE,
   p_reason_of_transport       IN     VARCHAR2,
   p_description               IN     VARCHAR2,
   p_cod_amount                IN     NUMBER,
   p_cod_currency_code         IN     VARCHAR2,
   p_cod_remit_to              IN     VARCHAR2,
   p_cod_charge_paid_by        IN     VARCHAR2,
   p_problem_contact_reference IN     VARCHAR2,
   p_bill_freight_to           IN     VARCHAR2,
   p_carried_by                IN     VARCHAR2,
   p_port_of_loading           IN     VARCHAR2,
   p_port_of_discharge         IN     VARCHAR2,
   p_booking_office            IN     VARCHAR2,
   p_booking_number            IN     VARCHAR2,
   p_service_contract          IN     VARCHAR2,
   p_shipper_export_ref        IN     VARCHAR2,
   p_carrier_export_ref        IN     VARCHAR2,
   p_bol_notify_party          IN     VARCHAR2,
   p_supplier_code             IN     VARCHAR2,
   p_aetc_number               IN     VARCHAR2,
   p_shipper_signed_by         IN     VARCHAR2,
   p_shipper_date              IN     DATE,
   p_carrier_signed_by         IN     VARCHAR2,
   p_carrier_date              IN     DATE,
   p_bol_issue_office          IN     VARCHAR2,
   p_bol_issued_by             IN     VARCHAR2,
   p_bol_date_issued           IN     DATE,
   p_shipper_hm_by             IN     VARCHAR2,
   p_shipper_hm_date           IN     DATE,
   p_carrier_hm_by             IN     VARCHAR2,
   p_carrier_hm_date           IN     DATE,
   p_ledger_id           IN     NUMBER,   */      -- LE Uptake
   x_document_number           IN OUT NOCOPY  VARCHAR2,
   x_trip_id                   IN OUT NOCOPY  NUMBER,
   x_trip_name                 IN OUT NOCOPY  VARCHAR2,
   x_delivery_id               IN OUT NOCOPY  NUMBER,
   p_pick_up_location_id       IN     NUMBER,
   p_drop_off_location_id      IN     NUMBER,
   p_carrier_id                IN     NUMBER);


PROCEDURE delete_row
  ( p_api_version                 IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
    );
PROCEDURE cancel_bol
  ( p_trip_id			  IN NUMBER
    ,p_old_ship_method_code       IN VARCHAR2
    ,p_new_ship_method_code       IN VARCHAR2
    , x_return_status		  OUT NOCOPY  VARCHAR2
  );


END WSH_BOLS_PVT;

 

/
