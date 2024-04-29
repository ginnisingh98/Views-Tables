--------------------------------------------------------
--  DDL for Package OKL_FULFILLMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FULFILLMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRFULS.pls 115.7 2002/07/30 21:19:44 rfedane noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_MULTIPLE_FM_SERVERS         CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_MULTIPLE_FM_SERVERS';
  G_SERVER                      CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_FM_SERVER';
  G_NO_FM_SERVER                CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_FM_SERVER_NOT_FOUND';


  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT   VARCHAR2(200) := 'OKL_FULFILLMENT_PVT';
  G_APP_NAME			CONSTANT   VARCHAR2(3)   := 'OKL';
  G_API_VERSION                 CONSTANT   NUMBER        := 1;
  G_UNEXPECTED_ERROR            CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN               CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

  G_COMMIT                      CONSTANT   VARCHAR2(1)   := FND_API.G_FALSE;
  G_INIT_MSG_LIST               CONSTANT   VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT   NUMBER        := FND_API.G_VALID_LEVEL_FULL;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE create_fulfillment (p_api_version   IN  NUMBER,
                                p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                                p_agent_id      IN  NUMBER,
                                p_server_id     IN  NUMBER,
                                p_content_id    IN  NUMBER,
                                p_from          IN  VARCHAR2,
                                p_subject       IN  VARCHAR2,
                                p_email         IN  VARCHAR2,
                                p_bind_var      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_val      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_var_type IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_commit        IN  VARCHAR2,
                                x_request_id    OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2);


END OKL_FULFILLMENT_PVT;

 

/
