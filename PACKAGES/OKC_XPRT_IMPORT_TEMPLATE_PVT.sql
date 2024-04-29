--------------------------------------------------------
--  DDL for Package OKC_XPRT_IMPORT_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_IMPORT_TEMPLATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXTMPLS.pls 120.0 2005/05/26 09:41:21 appldev noship $ */

PROCEDURE import_template
(
 p_api_version              IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_commit	            IN	VARCHAR2,
 p_template_id   	    IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) ;

/*
   This Procedure would rebuild all templates attached to rules to be
   Published or Disable
*/
PROCEDURE rebuild_tmpl_pub_disable
(
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
);

PROCEDURE rebuild_tmpl_sync
(
 p_org_id                   IN  NUMBER,
 p_intent                   IN  VARCHAR2,
 p_template_id   	    IN	NUMBER DEFAULT NULL,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
);




END OKC_XPRT_IMPORT_TEMPLATE_PVT;

 

/
