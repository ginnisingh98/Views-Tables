--------------------------------------------------------
--  DDL for Package IEU_MSG_PRODUCER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_MSG_PRODUCER_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUPMSGS.pls 120.0 2005/06/02 15:52:07 appldev noship $ */


REQUIRED_PARAM_NULL EXCEPTION;
pragma exception_init (REQUIRED_PARAM_NULL, -20000);

PARAM_EXCEEDS_MAX EXCEPTION;
pragma exception_init (PARAM_EXCEEDS_MAX, -20001);


PROCEDURE SEND_PLAIN_TEXT_MSG (
  p_api_version      IN NUMBER,
  p_init_msg_list    IN VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit           IN VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_application_id   IN NUMBER,
  p_resource_id      IN NUMBER,
  p_resource_type    IN VARCHAR2  DEFAULT 'RS_INDIVIDUAL',
  p_title            IN VARCHAR2,
  p_body             IN VARCHAR2,
  p_workitem_obj_code IN VARCHAR2,
  p_workitem_pk_id    IN NUMBER,
  x_message_id      OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
  );


END IEU_MSG_PRODUCER_PUB;

 

/
