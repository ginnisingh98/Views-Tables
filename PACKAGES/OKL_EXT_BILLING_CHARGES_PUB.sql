--------------------------------------------------------
--  DDL for Package OKL_EXT_BILLING_CHARGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXT_BILLING_CHARGES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBCGS.pls 120.1 2005/08/26 15:49:36 stmathew noship $ */

  G_PKG_NAME	CONSTANT VARCHAR2(30)  := 'OKL_EXT_BILLING_CHARGES_PUB';

  PROCEDURE billing_charges_conc
  	(errbuf  			  OUT NOCOPY   VARCHAR2
    ,retcode 			  OUT NOCOPY   NUMBER
	,p_name  			  IN    VARCHAR2	DEFAULT NULL
	,p_sequence_number    IN 	NUMBER		DEFAULT NULL
	,p_date_transmission  IN	DATE		DEFAULT NULL
	,p_origin             IN	VARCHAR2	DEFAULT NULL
	,p_destination        IN 	VARCHAR2	DEFAULT NULL);

  PROCEDURE billing_charges
	(p_api_version		  IN  NUMBER
	,p_init_msg_list	  IN  VARCHAR2	DEFAULT Okl_Api.G_FALSE
	,x_return_status	  OUT NOCOPY VARCHAR2
	,x_msg_count		  OUT NOCOPY NUMBER
	,x_msg_data			  OUT NOCOPY VARCHAR2
	,p_name               IN  VARCHAR2	DEFAULT NULL
	,p_sequence_number    IN  NUMBER		DEFAULT NULL
	,p_date_transmission  IN  DATE		DEFAULT NULL
	,p_origin             IN  VARCHAR2	DEFAULT NULL
	,p_destination        IN  VARCHAR2	DEFAULT NULL);

END Okl_Ext_Billing_Charges_Pub;

 

/
