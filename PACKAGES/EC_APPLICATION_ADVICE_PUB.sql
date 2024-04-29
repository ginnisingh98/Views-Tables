--------------------------------------------------------
--  DDL for Package EC_APPLICATION_ADVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_APPLICATION_ADVICE_PUB" AUTHID CURRENT_USER AS
-- $Header: ECPADVOS.pls 120.3 2005/09/29 11:29:54 arsriniv ship $

--  Global constants holding the package and file names to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'EC_Application_Advice_PUB';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'ECPADVOB.pls';


PROCEDURE create_advice(
   p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_communication_method	IN	VARCHAR2,
   p_related_document_id	IN	VARCHAR2,
   p_tp_header_id		IN	NUMBER,
   p_tp_location_code		IN	VARCHAR2,
   p_document_type		IN	VARCHAR2,
   p_document_code		IN	VARCHAR2,
   p_transaction_control1	IN	VARCHAR2 default NULL,
   p_transaction_control2	IN	VARCHAR2 default NULL,
   p_transaction_control3	IN	VARCHAR2 default NULL,
   p_entity_code		IN	VARCHAR2 default NULL,
   p_entity_name		IN	VARCHAR2 default NULL,
   p_entity_address1		IN	VARCHAR2 default NULL,
   p_entity_address2		IN	VARCHAR2 default NULL,
   p_entity_address3		IN	VARCHAR2 default NULL,
   p_entity_address4		IN	VARCHAR2 default NULL,
   p_entity_city		IN	VARCHAR2 default NULL,
   p_entity_postal_code		IN	VARCHAR2 default NULL,
   p_entity_country		IN	VARCHAR2 default NULL,
   p_entity_state		IN	VARCHAR2 default NULL,
   p_entity_province		IN	VARCHAR2 default NULL,
   p_entity_county		IN	VARCHAR2 default NULL,
   p_external_reference_1	IN	VARCHAR2 default NULL,
   p_external_reference_2	IN	VARCHAR2 default NULL,
   p_external_reference_3	IN	VARCHAR2 default NULL,
   p_external_reference_4	IN	VARCHAR2 default NULL,
   p_external_reference_5	IN	VARCHAR2 default NULL,
   p_external_reference_6	IN	VARCHAR2 default NULL,
   p_internal_reference_1	IN	VARCHAR2 default NULL,
   p_internal_reference_2	IN	VARCHAR2 default NULL,
   p_internal_reference_3	IN	VARCHAR2 default NULL,
   p_internal_reference_4	IN	VARCHAR2 default NULL,
   p_internal_reference_5	IN	VARCHAR2 default NULL,
   p_internal_reference_6	IN	VARCHAR2 default NULL,
   p_advice_header_id		OUT NOCOPY	NUMBER
);

PROCEDURE create_advice_line(
   p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_advice_header_id		IN	NUMBER,
   p_advice_date_time		IN	DATE,
   p_advice_status_code		IN	VARCHAR2,
   p_external_reference_1	IN	VARCHAR2 default NULL,
   p_external_reference_2	IN	VARCHAR2 default NULL,
   p_external_reference_3	IN	VARCHAR2 default NULL,
   p_external_reference_4	IN	VARCHAR2 default NULL,
   p_external_reference_5	IN	VARCHAR2 default NULL,
   p_external_reference_6	IN	VARCHAR2 default NULL,
   p_internal_reference_1	IN	VARCHAR2 default NULL,
   p_internal_reference_2	IN	VARCHAR2 default NULL,
   p_internal_reference_3	IN	VARCHAR2 default NULL,
   p_internal_reference_4	IN	VARCHAR2 default NULL,
   p_internal_reference_5	IN	VARCHAR2 default NULL,
   p_internal_reference_6	IN	VARCHAR2 default NULL,
   p_advo_message_code		IN	VARCHAR2 default NULL,
   p_advo_message_desc		IN	VARCHAR2 default NULL,
   p_advo_data_bad		IN	VARCHAR2 default NULL,
   p_advo_data_good		IN	VARCHAR2 default NULL
);

END;


 

/
