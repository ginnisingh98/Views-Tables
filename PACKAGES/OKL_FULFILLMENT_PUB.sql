--------------------------------------------------------
--  DDL for Package OKL_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FULFILLMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPFULS.pls 115.6 2002/05/24 09:42:37 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OKL_FULFILLMENT_PUB';

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE create_fulfillment (p_api_version   IN  NUMBER,
                                p_init_msg_list IN  VARCHAR2,
                                p_agent_id      IN  NUMBER,
                                p_server_id     IN  NUMBER DEFAULT NULL,
                                p_content_id    IN  NUMBER,
                                p_from          IN  VARCHAR2,
                                p_subject       IN  VARCHAR2,
                                p_email         IN  VARCHAR2,
                                p_bind_var      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_val      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_var_type IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_commit        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_request_id    OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2);

END okl_fulfillment_pub;

 

/
