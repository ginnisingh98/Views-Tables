--------------------------------------------------------
--  DDL for Package Body WSH_DOCUMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DOCUMENT_PUB" AS
-- $Header: WSHPPACB.pls 120.1 2006/01/18 13:47:47 parkhj noship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_Document_PUB';

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
)
IS

-- bug 4891939, sql 15038246
-- Merge Join Cartesian between wsh_document_instances and
-- wsh_delivery_details due to decode in join condition.
-- document_csr is divided into two cursors document_csr_del
-- and document_csr_leg

CURSOR document_csr_del IS
  SELECT
    doc.document_instance_id
  , doc.document_type
  , doc.entity_name
  , doc.entity_id
  , doc.doc_sequence_category_id
  , doc.sequence_number
  , doc.status
  , doc.final_print_date
/* Commented for Shipping Data Model Changes Bug#1918342
  , doc.pod_flag
  , doc.pod_by
  , doc.pod_date
  , doc.reason_of_transport
  , doc.description
  , doc.cod_amount
  , doc.cod_currency_code
  , doc.cod_remit_to
  , doc.cod_charge_paid_by
  , doc.problem_contact_reference
  , doc.bill_freight_to
  , doc.carried_by
  , doc.port_of_loading
  , doc.port_of_discharge
  , doc.booking_office
  , doc.booking_number
  , doc.service_contract
  , doc.shipper_export_ref
  , doc.carrier_export_ref
  , doc.bol_notify_party
  , doc.supplier_code
  , doc.aetc_number
  , doc.shipper_signed_by
  , doc.shipper_date
  , doc.carrier_signed_by
  , doc.carrier_date
  , doc.bol_issue_office
  , doc.bol_issued_by
  , doc.bol_date_issued
  , doc.shipper_hm_by
  , doc.shipper_hm_date
  , doc.carrier_hm_by
  , doc.carrier_hm_date*/
  , doc.created_by
  , doc.creation_date
  , doc.last_updated_by
  , doc.last_update_date
  , doc.last_update_login
  , doc.program_application_id
  , doc.program_id
  , doc.program_update_date
  , doc.request_id
  , doc.attribute_category
  , doc.attribute1
  , doc.attribute2
  , doc.attribute3
  , doc.attribute4
  , doc.attribute5
  , doc.attribute6
  , doc.attribute7
  , doc.attribute8
  , doc.attribute9
  , doc.attribute10
  , doc.attribute11
  , doc.attribute12
  , doc.attribute13
  , doc.attribute14
  , doc.attribute15
  FROM
    wsh_document_instances   doc
  , wsh_delivery_details     det
  , wsh_delivery_assignments_v del
  WHERE det.source_line_id = p_order_line_id
    AND det.delivery_detail_id = del.delivery_detail_id
    and det.container_flag = 'N'
    AND doc.entity_id = del.delivery_id
    AND doc.entity_name = 'WSH_NEW_DELIVERIES'
    AND nvl(det.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
    AND doc.status = 'OPEN';

CURSOR document_csr_leg IS
  SELECT
    doc.document_instance_id
  , doc.document_type
  , doc.entity_name
  , doc.entity_id
  , doc.doc_sequence_category_id
  , doc.sequence_number
  , doc.status
  , doc.final_print_date
/* Commented for Shipping Data Model Changes Bug#1918342
  , doc.pod_flag
  , doc.pod_by
  , doc.pod_date
  , doc.reason_of_transport
  , doc.description
  , doc.cod_amount
  , doc.cod_currency_code
  , doc.cod_remit_to
  , doc.cod_charge_paid_by
  , doc.problem_contact_reference
  , doc.bill_freight_to
  , doc.carried_by
  , doc.port_of_loading
  , doc.port_of_discharge
  , doc.booking_office
  , doc.booking_number
  , doc.service_contract
  , doc.shipper_export_ref
  , doc.carrier_export_ref
  , doc.bol_notify_party
  , doc.supplier_code
  , doc.aetc_number
  , doc.shipper_signed_by
  , doc.shipper_date
  , doc.carrier_signed_by
  , doc.carrier_date
  , doc.bol_issue_office
  , doc.bol_issued_by
  , doc.bol_date_issued
  , doc.shipper_hm_by
  , doc.shipper_hm_date
  , doc.carrier_hm_by
  , doc.carrier_hm_date*/
  , doc.created_by
  , doc.creation_date
  , doc.last_updated_by
  , doc.last_update_date
  , doc.last_update_login
  , doc.program_application_id
  , doc.program_id
  , doc.program_update_date
  , doc.request_id
  , doc.attribute_category
  , doc.attribute1
  , doc.attribute2
  , doc.attribute3
  , doc.attribute4
  , doc.attribute5
  , doc.attribute6
  , doc.attribute7
  , doc.attribute8
  , doc.attribute9
  , doc.attribute10
  , doc.attribute11
  , doc.attribute12
  , doc.attribute13
  , doc.attribute14
  , doc.attribute15
  FROM
    wsh_document_instances   doc
  , wsh_delivery_details     det
  , wsh_delivery_assignments_v del
  , wsh_delivery_legs        leg
  WHERE det.source_line_id = p_order_line_id
    AND det.delivery_detail_id = del.delivery_detail_id
    and det.container_flag = 'N'
    AND del.delivery_id = leg.delivery_id
    AND doc.entity_id = leg.delivery_leg_id
    AND doc.entity_name = 'WSH_DELIVERY_LEGS'
    AND nvl(det.LINE_DIRECTION , 'O') IN ('O', 'IO')   -- J Inbound Logistics jckwok
    AND doc.status = 'OPEN';

l_api_name      CONSTANT VARCHAR2(30) := 'Get_Document';
l_api_version   CONSTANT NUMBER       := 1.0;

BEGIN
  -- standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call ( l_api_version
			                      , p_api_version
				                 , l_api_name
                                     , g_pkg_name ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.to_boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize API return status to success
  x_return_status := WSH_UTIL_CORE.g_ret_sts_success;

  IF p_document_type = 'PACK_TYPE' THEN
    OPEN document_csr_del;
    FETCH document_csr_del INTO x_document_rec;
    CLOSE document_csr_del;
  ELSIF p_document_type = 'BOL' THEN
    OPEN document_csr_leg;
    FETCH document_csr_leg INTO x_document_rec;
    CLOSE document_csr_leg;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count
			      , p_data  => x_msg_data );
    IF document_csr_del%ISOPEN THEN
      CLOSE document_csr_del;
    END IF;
    IF document_csr_leg%ISOPEN THEN
      CLOSE document_csr_leg;
    END IF;

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count
			      , p_data  => x_msg_data );
    IF document_csr_del%ISOPEN THEN
      CLOSE document_csr_del;
    END IF;
    IF document_csr_leg%ISOPEN THEN
      CLOSE document_csr_leg;
    END IF;

  WHEN others THEN
    FND_MESSAGE.set_name('WSH', 'WSH_UNEXP_ERROR');
    FND_MESSAGE.set_token('PACKAGE',g_pkg_name);
    FND_MESSAGE.set_token('ORA_ERROR',to_char(sqlcode));
    FND_MESSAGE.set_token('ORA_TEXT','Failure in performing action');
    x_return_status := WSH_UTIL_CORE.g_ret_sts_unexp_error;
    WSH_UTIL_CORE.add_message (x_return_status);
    IF FND_MSG_PUB.check_msg_level THEN
      FND_MSG_PUB.count_and_get ( p_count => x_msg_count
   			                 , p_data  => x_msg_data );
    END IF;

    IF document_csr_del%ISOPEN THEN
      CLOSE document_csr_del;
    END IF;
    IF document_csr_leg%ISOPEN THEN
      CLOSE document_csr_leg;
    END IF;
END Get_Document;

END WSH_Document_PUB;

/
