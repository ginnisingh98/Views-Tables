--------------------------------------------------------
--  DDL for Package OKC_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AQ_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPAQS.pls 120.0 2005/05/26 09:34:07 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- SUB TYPES
  subtype corrid_rec_typ is okc_aq_pvt.corrid_rec_typ;
  subtype msg_tab_typ    is okc_aq_pvt.msg_tab_typ;
  ---------------------------------------------------------------------------
  -- CONSTANTS
  ---------------------------------------------------------------------------
  g_msg_expire         CONSTANT  BINARY_INTEGER default  dbms_aq.never;
  g_event_queue_name   CONSTANT  VARCHAR2(100) default OKC_QUEUE_PVT.event_queue_name;
  g_outcome_queue_name CONSTANT  VARCHAR2(100)  default OKC_QUEUE_PVT.outcome_queue_name;
  g_dequeue_wait       CONSTANT  BINARY_INTEGER default  5;
  ---------------------------------------------------------------------------

  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
   G_PKG_NAME          CONSTANT VARCHAR2(200) := 'OKC_AQ_PUB';
   G_APP_NAME          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR  CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  --------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
    G_EXCEPTION_HALT_VALIDATION   EXCEPTION;

  ------------------------------------------------------------------------------

  -- Procedures and Functions
  ---------------------------------------------------------------------------
  -- overloaded send_message procedure supports
  -- varchar2 and clob message payloads

PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     p_commit        IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_corrid_rec    IN  okc_aq_pub.corrid_rec_typ,
     p_msg_tab       IN  okc_aq_pub.msg_tab_typ,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  INTEGER default dbms_aq.no_delay
     );

/*PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     p_commit        IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_msg           IN  VARCHAR2,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  number default 0
     );                                                                         */

END okc_aq_pub;

 

/
