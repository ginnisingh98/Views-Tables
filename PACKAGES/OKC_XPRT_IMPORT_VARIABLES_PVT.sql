--------------------------------------------------------
--  DDL for Package OKC_XPRT_IMPORT_VARIABLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_IMPORT_VARIABLES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXVARS.pls 120.1 2005/07/01 08:48:35 arsundar noship $ */

---------------------------------------------------
--  Procedure: This procedure will rebuild the Variable Model for the given Org Id
--
--  Parameters: p_org_id For Org Rules
---------------------------------------------------
PROCEDURE import_variables
(
 p_api_version              IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_commit	            IN	VARCHAR2,
 p_org_id        	    IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) ;



END OKC_XPRT_IMPORT_VARIABLES_PVT;

 

/
