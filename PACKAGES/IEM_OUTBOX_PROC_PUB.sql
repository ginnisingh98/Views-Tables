--------------------------------------------------------
--  DDL for Package IEM_OUTBOX_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_OUTBOX_PROC_PUB" AUTHID CURRENT_USER as
/* $Header: iemobprs.pls 120.2 2006/01/24 09:01:57 txliu noship $*/

TYPE QualifierRecord IS RECORD (
  QUALIFIER_NAME    VARCHAR2(256),
  QUALIFIER_VALUE   VARCHAR2(256)
  );

TYPE QualifierRecordList IS
  TABLE OF QualifierRecord INDEX BY BINARY_INTEGER;


TYPE keyVals_rec_type is RECORD (
    key     iem_route_rules.key_type_code%type,
    value   iem_route_rules.value%type,
    datatype varchar2(1));

--Table of Key-Values
TYPE keyVals_tbl_type is TABLE OF keyVals_rec_type INDEX BY BINARY_INTEGER;


TYPE AcctRec IS RECORD (
    ACCOUNT_NAME   VARCHAR2(100),
    ACCOUNT_ID     NUMBER);

TYPE AcctRecList is TABLE OF AcctRec INDEX BY BINARY_INTEGER;


PROCEDURE createOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_resource_id           IN   NUMBER,
    p_application_id        IN   NUMBER,
    p_responsibility_id     IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_sr_id                 IN   NUMBER,
    p_customer_id           IN   NUMBER,
    p_contact_id            IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_message_type          IN   VARCHAR2,
    p_encoding		          IN   VARCHAR2,
    p_character_set         IN   VARCHAR2,
    p_option                IN   VARCHAR2,  -- 'A' for auto-ack started from mini R
    p_relationship_id       IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE cancelOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outbox_item_id        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE submitOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outbox_item_id        IN   NUMBER,
    p_preview_bool           IN  VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE writeOutboxError(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_rt_media_item_id      IN   NUMBER,
    p_error_summary         IN   VARCHAR2,
    p_error_msg             IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );


PROCEDURE createAutoReply(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_rfc822_message_id     IN   VARCHAR2,
    p_folder_name           IN   VARCHAR2,
    p_message_uid           IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_mdt_message_id        IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );


PROCEDURE insertBodyText(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_outbox_item_id        IN   NUMBER,
    p_text                  IN   BLOB,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE insertDocument(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_outbox_item_id        IN   NUMBER,
    p_document_source       IN   VARCHAR2,
    p_document_id           IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE attachDocument(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_outbox_item_id        IN   NUMBER,
    p_document_source       IN   VARCHAR2,
    p_document_id           IN   NUMBER,
    p_binary_source         IN   BLOB,
    p_attachment_name       IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE getAccountList(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
    p_resource_id           IN   NUMBER,
    x_account_list          OUT  NOCOPY AcctRecList,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE redirectMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_mdt_msg_id            IN   NUMBER,
    p_to_account_id         IN   NUMBER,
    p_resource_id           IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );


PROCEDURE autoForward(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_rfc822_message_id     IN   VARCHAR2,
    p_folder_name           IN   VARCHAR2,
    p_message_uid           IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_attach_inb            IN   VARCHAR2,  -- if 'A' attach original inbound, if 'I' inbound is inlined
    p_mdt_message_id        IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );

PROCEDURE createSRAutoNotification(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_message_id            IN   NUMBER,
    p_sr_id                 IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    );


END IEM_OUTBOX_PROC_PUB;

 

/
