--------------------------------------------------------
--  DDL for Package Body OKL_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CUSTOM_PVT" AS
/* $Header: OKLRCPPB.pls 120.0 2005/08/10 21:37:42 stmathew noship $ */

PROCEDURE CUSTOM_CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2)
IS
BEGIN
    NULL;
EXCEPTION
    WHEN OTHERS THEN
         NUll;
END CUSTOM_CM_Bill_adjustments;

PROCEDURE CUSTOM_CM_Bill_adjustments
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
	,p_rebook_adj_tbl	IN  OKL_REBOOK_CM_PVT.rebook_adj_tbl_type)
IS
BEGIN
    NULL;
EXCEPTION
    WHEN OTHERS THEN
         NUll;
END CUSTOM_CM_Bill_adjustments;

END OKL_CUSTOM_PVT;

/
