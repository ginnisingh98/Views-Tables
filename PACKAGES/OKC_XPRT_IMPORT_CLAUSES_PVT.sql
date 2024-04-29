--------------------------------------------------------
--  DDL for Package OKC_XPRT_IMPORT_CLAUSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_IMPORT_CLAUSES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXCLAS.pls 120.0 2005/05/25 23:00:34 appldev noship $ */

---------------------------------------------------
--  Procedure: import_clauses
--  Parameters: p_org_id For Org Rules to be published
---------------------------------------------------
PROCEDURE import_clauses
(
 p_api_version              IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_commit	            IN	VARCHAR2,
 p_org_id        	    IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	            OUT	NOCOPY NUMBER
) ;



END OKC_XPRT_IMPORT_CLAUSES_PVT;

 

/
