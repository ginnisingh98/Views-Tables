--------------------------------------------------------
--  DDL for Package IEM_MC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MC_PUB" AUTHID CURRENT_USER AS
/* $Header: iemmcps.pls 115.8 2003/12/03 22:11:32 txliu noship $ */

TYPE QualifierRecord IS RECORD (
  QUALIFIER_NAME    VARCHAR2(256),
  QUALIFIER_VALUE   VARCHAR2(256)
  );

TYPE QualifierRecordList IS
  TABLE OF QualifierRecord INDEX BY BINARY_INTEGER;


PROCEDURE prepareMessageComponent
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  );

PROCEDURE prepareMessageComponent
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_relationship_id       IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  );


PROCEDURE prepareMessageComponentII
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   p_message_type          IN   VARCHAR2,
   p_encoding		   IN   VARCHAR2,
   p_character_set         IN   VARCHAR2,
   p_relationship_id       IN   NUMBER,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  );


END IEM_MC_PUB;

 

/
