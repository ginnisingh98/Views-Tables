--------------------------------------------------------
--  DDL for Package OKL_EVERGREEN_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EVERGREEN_BILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLREGBS.pls 115.0 2002/04/05 09:55:55 pkm ship        $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_EVERGREEN_BILLING_PVT';

  PROCEDURE bill_evergreen_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data			OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL);

END OKL_EVERGREEN_BILLING_PVT;

 

/
