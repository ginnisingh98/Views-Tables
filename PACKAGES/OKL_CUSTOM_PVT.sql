--------------------------------------------------------
--  DDL for Package OKL_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CUSTOM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCPPS.pls 120.0 2005/08/10 21:36:36 stmathew noship $ */

PROCEDURE CUSTOM_CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2) ;

PROCEDURE CUSTOM_CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
	,p_rebook_adj_tbl	IN  OKL_REBOOK_CM_PVT.rebook_adj_tbl_type);

END OKL_CUSTOM_PVT;

 

/
