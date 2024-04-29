--------------------------------------------------------
--  DDL for Package WSH_DOCUMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DOCUMENT_PVT" AUTHID CURRENT_USER AS
-- $Header: WSHVPACS.pls 120.1 2005/10/11 02:54:40 sgumaste noship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

------------------------------------------------------------------------------
--  PROCEDURE  : Create_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Creates a document (packing slip, bill of lading) for a
--               delivery and assigns(or validates) a sequence number
--               as per pre-defined document category definitions
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being created
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_application_id       Application which is creating the document (
--                            should be same as the one that owns the
--			      document category )
--     p_location_id          Location id which the document is being created
--     p_document_type        type codes (PACK_TYPE, BOL, ASN, etc.)
--     p_document_sub_type    for packing slips (SALES_ORDER, etc) and
--                            for Bills of Lading the ship method codes
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_ledger_id            Ledger id attached to the calling program (
--                            should be same as ledger used to setup the
--                            document category/assignment )
--     p_consolidate_option   calling program's choice to create document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--     p_manual_sequence_number  user defined sequence number ( used only
--                            if the document falls in a category  that has
--                            manual type suquence assigned to it (else null)
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_document_number      the document number (generated/manual sequence
--                            with concatenated prefix and suffix).
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  The delivery should be existing in the Database
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Create_Document
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2 DEFAULT NULL
, p_entity_id                 IN  NUMBER
, p_application_id            IN  NUMBER
, p_location_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_document_sub_type         IN  VARCHAR2
/*Commented for Shipping Data model Changes - Bug#1918342*/
/*, p_pod_flag                  IN  VARCHAR2
, p_pod_by                    IN  VARCHAR2
, p_pod_date                  IN  DATE
, p_reason_of_transport       IN  VARCHAR2
, p_description               IN  VARCHAR2
, p_cod_amount                IN  NUMBER
, p_cod_currency_code         IN  VARCHAR2
, p_cod_remit_to              IN  VARCHAR2
, p_cod_charge_paid_by        IN  VARCHAR2
, p_problem_contact_reference IN  VARCHAR2
, p_bill_freight_to           IN  VARCHAR2
, p_carried_by                IN  VARCHAR2
, p_port_of_loading           IN  VARCHAR2
, p_port_of_discharge         IN  VARCHAR2
, p_booking_office            IN  VARCHAR2
, p_booking_number            IN  VARCHAR2
, p_service_contract          IN  VARCHAR2
, p_shipper_export_ref        IN  VARCHAR2
, p_carrier_export_ref        IN  VARCHAR2
, p_bol_notify_party          IN  VARCHAR2
, p_supplier_code             IN  VARCHAR2
, p_aetc_number               IN  VARCHAR2
, p_shipper_signed_by         IN  VARCHAR2
, p_shipper_date              IN  DATE
, p_carrier_signed_by         IN  VARCHAR2
, p_carrier_date              IN  DATE
, p_bol_issue_office          IN  VARCHAR2
, p_bol_issued_by             IN  VARCHAR2
, p_bol_date_issued           IN  DATE
, p_shipper_hm_by             IN  VARCHAR2
, p_shipper_hm_date           IN  DATE
, p_carrier_hm_by             IN  VARCHAR2
, p_carrier_hm_date           IN  DATE*/
, p_ledger_id                 IN  NUMBER    -- LE Uptake
, p_consolidate_option        IN  VARCHAR2 DEFAULT 'BOTH'
, p_manual_sequence_number    IN  NUMBER   DEFAULT NULL
, x_document_number           OUT NOCOPY  VARCHAR2
);


------------------------------------------------------------------------------
--  PROCEDURE  : Update_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates a document (pack slip, bill of lading) for a delivery
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being updated
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_ledger_id            Ledger id attached to the calling program (
--                            should be same as ledger used to setup the
--                            document category/assignment )
--     p_consolidate_option   calling program's choice to update document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------


PROCEDURE Update_Document
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2 DEFAULT NULL
, p_entity_id                 IN  NUMBER
, p_document_type             IN  VARCHAR2
/* Commented for Shipping Data Model Changes Bug#1918342*/
/*, p_pod_flag                  IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_pod_by                    IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_pod_date                  IN  DATE     DEFAULT FND_API.g_miss_date
, p_reason_of_transport       IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_description               IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_cod_amount                IN  NUMBER   DEFAULT FND_API.g_miss_num
, p_cod_currency_code         IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_cod_remit_to              IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_cod_charge_paid_by        IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_problem_contact_reference IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_bill_freight_to           IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_carried_by                IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_port_of_loading           IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_port_of_discharge         IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_booking_office            IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_booking_number            IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_service_contract          IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_shipper_export_ref        IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_carrier_export_ref        IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_bol_notify_party          IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_supplier_code             IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_aetc_number               IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_shipper_signed_by         IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_shipper_date              IN  DATE     DEFAULT FND_API.g_miss_date
, p_carrier_signed_by         IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_carrier_date              IN  DATE     DEFAULT FND_API.g_miss_date
, p_bol_issue_office          IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_bol_issued_by             IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_bol_date_issued           IN  DATE     DEFAULT FND_API.g_miss_date
, p_shipper_hm_by             IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_shipper_hm_date           IN  DATE     DEFAULT FND_API.g_miss_date
, p_carrier_hm_by             IN  VARCHAR2 DEFAULT FND_API.g_miss_char
, p_carrier_hm_date           IN  DATE     DEFAULT FND_API.g_miss_date*/
, p_ledger_id                 IN  NUMBER   -- LE Uptake
, p_consolidate_option        IN  VARCHAR2 DEFAULT 'BOTH'
);


------------------------------------------------------------------------------
--  PROCEDURE  : Cancel_Document       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'CANCELLED'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to cancel document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Cancel_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
);

------------------------------------------------------------------------------
--  PROCEDURE  : Open_Document       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'OPEN'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being opened
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to open document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Open_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
);

------------------------------------------------------------------------------
--  PROCEDURE  : Complete_Document       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates the status of a document to 'COMPLETE'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being completed
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_consolidate_option   calling program's choice to complete document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Complete_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2 DEFAULT NULL
, p_entity_id          IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_consolidate_option IN  VARCHAR2 DEFAULT 'BOTH'
);
------------------------------------------------------------------------------
--  FUNCTION   : Get_Sequence_Type        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Checks and returns the type of a sequence assigned
--               to a specific document category
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_application_id       appl id of the calling program. Should be same
--                            as the application that owns the doc category
--     p_ledger_id            Ledger id of the calling program. Should be as the
--                            ledger used to setup the doc category/assignment
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_document_code        For pack slips this means document sub types (
--                            'SALES_ORDER') and for BOL ship method codes
--     p_location_id          Ship Location of the current delivery.
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--     x_document_valid       status of the document ('OPEN','CANCEL')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

FUNCTION Get_Sequence_Type
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_application_id            IN  NUMBER
, p_ledger_id                 IN  NUMBER    -- LE Uptake
, p_document_type             IN  VARCHAR2
, p_document_code             IN  VARCHAR2
, p_location_id               IN  NUMBER
)
RETURN VARCHAR2;

------------------------------------------------------------------------------
--  FUNCTION   : Is_Final        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Checks the status of all documents for the delivery
--               including its children.  If any such document is final,
--               returns true.  Else return false.  This is used by
--               print document routine and packing slip report to bail
--               out if any of the document has final_print_date set.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery_id of the delivery to check
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     RETURN                 VARCHAR2, value 'T' or 'F'
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

FUNCTION Is_Final
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_delivery_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
)
RETURN VARCHAR2;

------------------------------------------------------------------------------
--  PROCEDURE  : Set_Final_Print_Date        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Set the FINAL_PRINT_DATE column of all document instances
--               of the delivery and/or its child delivery to SYSDATE.
--               This procedure is called when user chooses print option
--               as FINAL.  This means later the same document instances
--               cannot be printed as they fail the Is_Final check.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery_id of the delivery to check
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_final_print_date     the final_print_date to be set
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--
--     PRE-CONDITIONS  :  FINAL_PRINT_DATE column of WSH_DOCUMENT_INSTANCES
--                        rows of related deliveries have NULL value
--     POST-CONDITIONS :  such FINAL_PRINT_DATE columns have SYSDATE value
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Set_Final_Print_Date
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_delivery_id               IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_final_print_date          IN  DATE
);

------------------------------------------------------------------------------
--  PROCEDURE  : Print_Document       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Submit the report WSHRDPAK.rdf to print the packing slip.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_delivery_id          delivery id for which document is being printed
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_departure_date_lo    delivery date (low)
--     p_departure_date_hi    delivery date (high)
--     p_item_display         display FLEX, DESC or BOTH (default BOTH)
--     p_print_cust_item      print customer item information or not (default
--                            NO)
--     p_print_mode           print FINAL or DRAFT (default DRAFT)
--     p_print_all            calling program's choice to cancel document(s)
--                            for this parent delivery only ('CONSOLIDATE')
--                            or for child dels of this delivery ('SEPARATE')
--                            or both parent and child deliveries ('BOTH')
--     p_sort                 sort the report by customer item or inventory
--                            item (INV or CUST, default INV)
--     p_freight_carrier      carrier_id of the freight carrier
--     p_warehouse_id         current organization_id
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Print_Document
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_delivery_id        IN  NUMBER
, p_document_type      IN  VARCHAR2
, p_departure_date_lo  IN  DATE     DEFAULT NULL
, p_departure_date_hi  IN  DATE     DEFAULT NULL
, p_item_display       IN  VARCHAR2 DEFAULT 'D'
, p_print_cust_item    IN  VARCHAR2 DEFAULT 'N'
, p_print_mode         IN  VARCHAR2 DEFAULT 'DRAFT'
, p_print_all          IN  VARCHAR2 DEFAULT 'BOTH'
, p_sort               IN  VARCHAR2 DEFAULT 'INV'
, p_freight_carrier    IN  VARCHAR2 DEFAULT NULL
, p_warehouse_id       IN  NUMBER
, x_conc_request_id    OUT NOCOPY  NUMBER
);

------------------------------------------------------------------------------
--  FUNCTION   : Get_CumQty        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Obtain cummulative quantity value based on the inputs
--               by calling Automotive's CUM Management API.  Return such
--               value.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_customer_id          from delivery details
--     p_oe_order_line_id     from delivery details for getting line level
--                            information to be passed to cal_cum api
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     RETURN                 NUMBER, cum quantity value
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

FUNCTION Get_CumQty
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_customer_id               IN  NUMBER
, p_oe_order_line_id          IN  NUMBER
)
RETURN NUMBER;

------------------------------------------------------------------------------
--  PROCEDURE  : Cancel_All_Documents       PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Updates status of all documents of all types that
--               belong to a specific entity
--               to 'CANCELLED'
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--
--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
--     NOTES           :     In consolidation situation, the child documents
--                           are not cancelled. Call this routine recursively
--                           for all entities where cancellation is reqd.
------------------------------------------------------------------------------

PROCEDURE Cancel_All_Documents
( p_api_version        IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level   IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
, p_entity_name        IN  VARCHAR2
, p_entity_id          IN  NUMBER
);

------------------------------------------------------------------------------
--  PROCEDURE  : Get_All_Documents        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Returns as an out-param a table of records of all documents
--               (packing slip, bill of lading, etc.) that belong to a
--               specific entity (delivery, delivery_leg, etc.)
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_entity_name          Entity for which the document is being cancelled
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc

--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--     x_document_tab         table that contains all documents of the entity
--
--     PRE-CONDITIONS      :  None
--     POST-CONDITIONS     :  None
--     EXCEPTIONS          :  None
------------------------------------------------------------------------------

PROCEDURE Get_All_Documents
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_entity_name               IN  VARCHAR2
, p_entity_id                 IN  NUMBER
, x_document_tab              OUT NOCOPY  wsh_document_pub.document_tabtype
);

------------------------------------------------------------------------------
--  PROCEDURE  : Lock_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Locks a document row
--
--  PARAMETER LIST :
--
--     IN
--
--     p_rowid                Rowid of wsh_document_instances table
--     p_document_instance_id document instance id
--     p_document_type        document type codes (PACK_TYPE, BOL, ASN etc.)
--     p_sequence_number      sequence number of the document
--     p_status               status of the document
--     p_final_print_date     final print date
--     p_entity_name          Entity for which the document is being updated
--                            examples: WSH_NEW_DELIVERIES, WSH_DELIVERY_LEGS
--     p_entity_id            Entity id that the document belongs to
--                            example: delivery_id, delivery_leg_id, etc
--     p_doc_sequence_cateogory_id   document sequence category id
--     p_pod_flag             pod_flag for the document
--     p_pod_by               pod_by for the document
--     p_pod_date             pod_date for the document
--     p_reason_of_transport  reason of transport that describes the delivery
--     p_description          external aspect of the delivery
--     p_cod_amount           cod_amount of the document
--     p_cod_currency_code    cod_currency_code of the document
--     p_cod_remit_to         cod_remit_to of the document
--     p_cod_charge_paid_by   cod_charge_paid_by of the document
--     p_problem_contact_reference   problem_contact_referene of the document
--     p_bill_freight_to      bill_freight_to of the document
--     p_carried_by           carried_by of the document
--     p_port_of_loading      port_of_loading of the docucent
--     p_port_of_discharge    port_of_discharge of the document
--     p_booking_office       booking_office of the document
--     p_booking_number       booking_number of the document
--     p_service_contract     service_contract of the document
--     p_shipper_export_ref   shipper_export_ref of the document
--     p_carrier_export_ref   carrier_export_ref of the document
--     p_bol_notify_party     bol_notify_party of the document
--     p_supplier_code        supplier_code of the document
--     p_aetc_number          aetc_number of the document
--     p_shipper_signed_by    shipper_signed_by of the document
--     p_shipper_date         shipper_date of the document
--     p_carrier_signed_by    carrier_signed_by of the document
--     p_carrier_date         carrier_date of the document
--     p_bol_issue_office     bol_issue_office of the document
--     p_bol_issued_by        bol_issued_by of the document
--     p_bol_date_issued      bol_date_issued of the document
--     p_shipper_hm_by        shipper_bm_by of the document
--     p_shipper_hm_date      shipper_hm_date of the document
--     p_carrier_hm_by        carrier_hm_by of the document
--     p_carrier_hm_date      carrier_hm_date of the document
--     p_created_by           standard who column
--     p_creation_date        standard who column
--     p_last_updated_by      standard who column
--     p_last_update_date     standard who column
--     p_last_update_login    standard who column
--     p_program_application_id   standard who column
--     p_program_id           standard who column
--     p_program_update_date  standard who column
--     p_request_id           standard who column
--     p_attribute_category   Descriptive Flex field context
--     p_attribute1           Descriptive Flex field
--     p_attribute2           Descriptive Flex field
--     p_attribute3           Descriptive Flex field
--     p_attribute4           Descriptive Flex field
--     p_attribute5           Descriptive Flex field
--     p_attribute6           Descriptive Flex field
--     p_attribute7           Descriptive Flex field
--     p_attribute8           Descriptive Flex field
--     p_attribute9           Descriptive Flex field
--     p_attribute10          Descriptive Flex field
--     p_attribute11          Descriptive Flex field
--     p_attribute12          Descriptive Flex field
--     p_attribute13          Descriptive Flex field
--     p_attribute14          Descriptive Flex field
--     p_attribute15          Descriptive Flex field
--
--     OUT
--
--     x_return_status        API return status ('S', 'E', 'U')
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
--
--     NOTES           :  1. Called from Shipping trx form only. Not an API.
--					    Does not conform to API standards.
--
--					 2. In a consolidation situation, this routine looks
--					    for a lock only on the parent document only.
--
------------------------------------------------------------------------------


PROCEDURE Lock_Document
( p_rowid                     IN  VARCHAR2
, p_document_instance_id      IN  NUMBER
, p_document_type             IN  VARCHAR2
, p_sequence_number           IN  VARCHAR2
, p_status                    IN  VARCHAR2
, p_final_print_date          IN  DATE
, p_entity_name               IN  VARCHAR2
, p_entity_id                 IN  NUMBER
, p_doc_sequence_category_id  IN  NUMBER
/* Commented for Shipping Data Model Changes Bug#1918342 */
/*, p_pod_flag                  IN  VARCHAR2
, p_pod_by                    IN  VARCHAR2
, p_pod_date                  IN  DATE
, p_reason_of_transport       IN  VARCHAR2
, p_description               IN  VARCHAR2
, p_cod_amount                IN  NUMBER
, p_cod_currency_code         IN  VARCHAR2
, p_cod_remit_to              IN  VARCHAR2
, p_cod_charge_paid_by        IN  VARCHAR2
, p_problem_contact_reference IN  VARCHAR2
, p_bill_freight_to           IN  VARCHAR2
, p_carried_by                IN  VARCHAR2
, p_port_of_loading           IN  VARCHAR2
, p_port_of_discharge         IN  VARCHAR2
, p_booking_office            IN  VARCHAR2
, p_booking_number            IN  VARCHAR2
, p_service_contract          IN  VARCHAR2
, p_shipper_export_ref        IN  VARCHAR2
, p_carrier_export_ref        IN  VARCHAR2
, p_bol_notify_party          IN  VARCHAR2
, p_supplier_code             IN  VARCHAR2
, p_aetc_number               IN  VARCHAR2
, p_shipper_signed_by         IN  VARCHAR2
, p_shipper_date              IN  DATE
, p_carrier_signed_by         IN  VARCHAR2
, p_carrier_date              IN  DATE
, p_bol_issue_office          IN  VARCHAR2
, p_bol_issued_by             IN  VARCHAR2
, p_bol_date_issued           IN  DATE
, p_shipper_hm_by             IN  VARCHAR2
, p_shipper_hm_date           IN  DATE
, p_carrier_hm_by             IN  VARCHAR2
, p_carrier_hm_date           IN  DATE     */
, p_created_by                IN  NUMBER
, p_creation_date             IN  DATE
, p_last_updated_by           IN  NUMBER
, p_last_update_date          IN  DATE
, p_last_update_login         IN  NUMBER
, p_program_application_id    IN  NUMBER
, p_program_id                IN  NUMBER
, p_program_update_date       IN  DATE
, p_request_id                IN  NUMBER
, p_attribute_category        IN  VARCHAR2
, p_attribute1                IN  VARCHAR2
, p_attribute2                IN  VARCHAR2
, p_attribute3                IN  VARCHAR2
, p_attribute4                IN  VARCHAR2
, p_attribute5                IN  VARCHAR2
, p_attribute6                IN  VARCHAR2
, p_attribute7                IN  VARCHAR2
, p_attribute8                IN  VARCHAR2
, p_attribute9                IN  VARCHAR2
, p_attribute10               IN  VARCHAR2
, p_attribute11               IN  VARCHAR2
, p_attribute12               IN  VARCHAR2
, p_attribute13               IN  VARCHAR2
, p_attribute14               IN  VARCHAR2
, p_attribute15               IN  VARCHAR2
, x_return_status             OUT NOCOPY  VARCHAR2
);


------------------------------------------------------------------------------
--  PROCEDURE   : set_template        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : This procedure is called before calling fnd_request.submit to
--               set the layout template so that pdf output is generated.
--		 Template is obtained from shipping parameters based on the
--               organization_id.
--  PARAMETER LIST :
--
--     IN
--
--     p_organization_id          Organization Id
--     p_report                   'BOL'/'MBL'/'PAK'
--     p_template_name             BOL_TEMPLATE/MBOL_TEMPLATE/PACKSLIP_TEMPLATE
--
--     OUT
--
--     x_conc_prog_name       'WSHRDBOL'/'WSHRDBOLX'/'WSHRDMBL'/'WSHRDMBLX'/'WSHRDPAK'/'WSHRDPAKX'
--     x_return_status        API return status ('S', 'E', 'U')
--
--
--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE set_template ( p_organization_id	NUMBER,
			 p_report		VARCHAR2,
			 p_template_name        VARCHAR2,
			 x_conc_prog_name	OUT NOCOPY VARCHAR2,
			 x_return_status        OUT NOCOPY VARCHAR2	);

END WSH_Document_PVT;

 

/
