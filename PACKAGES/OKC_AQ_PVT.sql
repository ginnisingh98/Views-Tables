--------------------------------------------------------
--  DDL for Package OKC_AQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AQ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRAQS.pls 120.0 2005/05/25 19:19:10 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- TYPES
  -- declaring record of msg_rec_typ
     TYPE msg_rec_typ IS RECORD (
       element_name    okc_action_attributes_v.element_name%TYPE,
       element_value   okc_action_att_vals.value%TYPE
       );
  -- declaring table of msg_tab_typ
     TYPE msg_tab_typ IS TABLE OF msg_rec_typ;

  -- declaring corrid record type
     TYPE corrid_rec_typ IS RECORD (
       corrid   okc_actions_b.correlation%TYPE
       );
  ---------------------------------------------------------------------------
  -- CONSTANTS

  g_msg_expire       CONSTANT  BINARY_INTEGER default  dbms_aq.never;
  g_event_queue_name CONSTANT  VARCHAR2(100)  := OKC_QUEUE_PVT.event_queue_name;
g_outcome_queue_name CONSTANT VARCHAR2(100) := OKC_QUEUE_PVT.outcome_queue_name;
  g_app_name           CONSTANT  VARCHAR2(3)    := OKC_API.G_APP_NAME;
  g_dequeue_wait       CONSTANT  BINARY_INTEGER default  5;
  ---------------------------------------------------------------------------
  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
  -- EXCEPTIONS
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  -- overloaded send_message procedure supports
  -- varchar2 and clob message payloads


FUNCTION get_acn_type(p_corrid IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     p_commit        IN  VARCHAR2 DEFAULT okc_api.G_FALSE,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_corrid_rec    IN  corrid_rec_typ,
     p_msg_tab       IN  msg_tab_typ,
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
     );*/

PROCEDURE listen_event (
		        errbuf  OUT NOCOPY VARCHAR2
		       ,retcode  OUT NOCOPY VARCHAR2
		       , p_wait  IN INTEGER
		       , p_sleep IN NUMBER
		       );

PROCEDURE listen_outcome (
		        errbuf  OUT NOCOPY VARCHAR2
		       ,retcode  OUT NOCOPY VARCHAR2
		       , p_wait  IN INTEGER
		       , p_sleep IN NUMBER
		       );

PROCEDURE dequeue_event;
PROCEDURE dequeue_date_event;
PROCEDURE dequeue_outcome;
PROCEDURE dequeue_exception ( errbuf   OUT NOCOPY VARCHAR2
		             ,retcode  OUT NOCOPY VARCHAR2
		             ,p_msg_id  IN VARCHAR2
			    );

PROCEDURE remove_message  ( errbuf   OUT NOCOPY VARCHAR2
		          ,retcode  OUT NOCOPY VARCHAR2
		          ,p_msg_id  IN VARCHAR2
			  );
PROCEDURE clear_message  ( errbuf   OUT NOCOPY VARCHAR2
		          ,retcode  OUT NOCOPY VARCHAR2
			  );
PROCEDURE stop_listener;

END okc_aq_pvt;

 

/
