--------------------------------------------------------
--  DDL for Package CS_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_MESSAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmesgs.pls 120.1 2005/08/04 01:56:12 varnaray noship $ */


PROCEDURE Send_Message
    (
        p_source_object_type   IN  VARCHAR2
    ,   p_source_obj_type_code IN  VARCHAR2
    ,   p_source_object_int_id IN  NUMBER
    ,   p_source_object_ext_id IN  VARCHAR2
    ,   p_sender               IN  VARCHAR2
    ,   p_sender_role          IN  VARCHAR2 DEFAULT NULL
    ,   p_receiver             IN  VARCHAR2
    ,   p_receiver_role        IN  VARCHAR2
    ,   p_priority             IN  VARCHAR2
    ,   p_expand_roles         IN  VARCHAR2
    ,   p_action_type          IN  VARCHAR2 DEFAULT NULL
    ,   p_action_code          IN  VARCHAR2 DEFAULT NULL
    ,   p_confirmation         IN  VARCHAR2
    ,   p_message              IN  VARCHAR2 DEFAULT NULL
    ,   p_function_name        IN  VARCHAR2 DEFAULT NULL
    ,   p_function_params      IN  VARCHAR2 DEFAULT NULL
    );


PROCEDURE Notification_Callback
    (
        command      IN  VARCHAR2
    ,   context      IN  VARCHAR2
    ,   attr_name    IN  VARCHAR2 DEFAULT NULL
    ,   attr_type    IN  VARCHAR2 DEFAULT NULL
    ,   text_value   IN OUT NOCOPY  VARCHAR2
    ,   number_value IN OUT NOCOPY  NUMBER
    ,   date_value   IN OUT NOCOPY DATE
    );

PROCEDURE delete_message
(
  p_api_version_number IN  NUMBER   := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
);

END CS_MESSAGES_PKG;


 

/
