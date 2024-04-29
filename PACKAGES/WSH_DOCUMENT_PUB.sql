--------------------------------------------------------
--  DDL for Package WSH_DOCUMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DOCUMENT_PUB" AUTHID CURRENT_USER AS
-- $Header: WSHPPACS.pls 115.6 2002/11/18 20:29:21 nparikh ship $

--------------------
-- TYPE DECLARATIONS
--------------------

TYPE document_rectype IS RECORD
 ( document_instance_id   wsh_document_instances.document_instance_id%type
 , document_type          wsh_document_instances.document_type%type
 , entity_name            wsh_document_instances.entity_name%type
 , entity_id              wsh_document_instances.entity_id%type
 , doc_sequence_category_id
                          wsh_document_instances.doc_sequence_category_id%type
 , sequence_number        wsh_document_instances.sequence_number%type
 , status                 wsh_document_instances.status%type
 , final_print_date       wsh_document_instances.final_print_date%type
/* Commented for Shipping Data Model Changes Bug#1918342
 , pod_flag               wsh_document_instances.pod_flag%type
 , pod_by                 wsh_document_instances.pod_by%type
 , pod_date               wsh_document_instances.pod_date%type
 , reason_of_transport    wsh_document_instances.reason_of_transport%type
 , description            wsh_document_instances.description%type
 , cod_amount             wsh_document_instances.cod_amount%type
 , cod_currency_code      wsh_document_instances.cod_currency_code%type
 , cod_remit_to           wsh_document_instances.cod_remit_to%type
 , cod_charge_paid_by     wsh_document_instances.cod_charge_paid_by%type
 , problem_contact_reference
                          wsh_document_instances.problem_contact_reference%type
 , bill_freight_to        wsh_document_instances.bill_freight_to%type
 , carried_by             wsh_document_instances.carried_by%type
 , port_of_loading        wsh_document_instances.port_of_loading%type
 , port_of_discharge      wsh_document_instances.port_of_discharge%type
 , booking_office         wsh_document_instances.booking_office%type
 , booking_number         wsh_document_instances.booking_number%type
 , service_contract       wsh_document_instances.service_contract%type
 , shipper_export_ref     wsh_document_instances.shipper_export_ref%type
 , carrier_export_ref     wsh_document_instances.carrier_export_ref%type
 , bol_notify_party       wsh_document_instances.bol_notify_party%type
 , supplier_code          wsh_document_instances.supplier_code%type
 , aetc_number            wsh_document_instances.aetc_number%type
 , shipper_signed_by      wsh_document_instances.shipper_signed_by%type
 , shipper_date           wsh_document_instances.shipper_date%type
 , carrier_signed_by      wsh_document_instances.carrier_signed_by%type
 , carrier_date           wsh_document_instances.carrier_date%type
 , bol_issue_office       wsh_document_instances.bol_issue_office%type
 , bol_issued_by          wsh_document_instances.bol_issued_by%type
 , bol_date_issued        wsh_document_instances.bol_date_issued%type
 , shipper_hm_by          wsh_document_instances.shipper_hm_by%type
 , shipper_hm_date        wsh_document_instances.shipper_hm_date%type
 , carrier_hm_by          wsh_document_instances.carrier_hm_by%type
 , carrier_hm_date        wsh_document_instances.carrier_hm_date%type*/
 , created_by             wsh_document_instances.created_by%type
 , creation_date          wsh_document_instances.creation_date%type
 , last_updated_by        wsh_document_instances.last_updated_by%type
 , last_update_date       wsh_document_instances.last_update_date%type
 , last_update_login      wsh_document_instances.last_update_login%type
 , program_application_id wsh_document_instances.program_application_id%type
 , program_id             wsh_document_instances.program_id%type
 , program_update_date    wsh_document_instances.program_update_date%type
 , request_id             wsh_document_instances.request_id%type
 , attribute_category     wsh_document_instances.attribute_category%type
 , attribute1             wsh_document_instances.attribute1%type
 , attribute2             wsh_document_instances.attribute2%type
 , attribute3             wsh_document_instances.attribute3%type
 , attribute4             wsh_document_instances.attribute4%type
 , attribute5             wsh_document_instances.attribute5%type
 , attribute6             wsh_document_instances.attribute6%type
 , attribute7             wsh_document_instances.attribute7%type
 , attribute8             wsh_document_instances.attribute8%type
 , attribute9             wsh_document_instances.attribute9%type
 , attribute10            wsh_document_instances.attribute10%type
 , attribute11            wsh_document_instances.attribute11%type
 , attribute12            wsh_document_instances.attribute12%type
 , attribute13            wsh_document_instances.attribute13%type
 , attribute14            wsh_document_instances.attribute14%type
 , attribute15            wsh_document_instances.attribute15%type
 );

TYPE document_tabtype IS TABLE of document_rectype;

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
--  PROCEDURE  : Get_Document        PUBLIC
--  VERSION    : 1.0
--  COMMENT    : Returns as an out-param a record containing all attributes
--               of the the currently open document of the specified type
--               ( packing slip, bill of lading, etc.) for a OE order line.
--
--  PARAMETER LIST :
--
--     IN
--
--     p_api_version          known API version
--     p_init_msg_list        should API reset message stack (default: false)
--     p_commit               should API do a commit (default: false)
--     p_validation_level     extent of validation done in the API (not used)
--     p_order_line_id        OE order line id for which doc info is needed
--     p_document_type        type codes (PACK_TYPE, BOL, ASN, etc.)

--     OUT
--
--     x_msg_count            number of messages in stack
--     x_msg_data             message if there is only one message in stack
--     x_return_status        API return status ('S', 'E', 'U')
--     x_document_rec         record that contains all attributes of the doc
--
--     PRE-CONDITIONS  :  There should be only one open document of a specific
--                        type for a delivery. If more than one open doc is
--                        available the API returns the first available one.
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------

PROCEDURE Get_Document
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.g_false
, p_commit                    IN  VARCHAR2 DEFAULT FND_API.g_false
, p_validation_level          IN  NUMBER   DEFAULT FND_API.g_valid_level_full
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
, p_order_line_id             IN  NUMBER
, p_document_type             IN  VARCHAR2
, x_document_rec              OUT NOCOPY  document_rectype
);

END WSH_Document_PUB;

 

/
