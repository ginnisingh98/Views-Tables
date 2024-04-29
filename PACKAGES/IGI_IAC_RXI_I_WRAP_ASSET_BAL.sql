--------------------------------------------------------
--  DDL for Package IGI_IAC_RXI_I_WRAP_ASSET_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_RXI_I_WRAP_ASSET_BAL" AUTHID CURRENT_USER AS
/* $Header: igiiaxcs.pls 120.1.12000000.1 2007/08/01 16:20:13 npandya noship $ */



  PROCEDURE run_report ( p_reptShrtName 	IN	VARCHAR2
			,p_bookType		IN	VARCHAR2
			,p_period		IN	VARCHAR2
			,p_categoryId		IN	VARCHAR2
			,p_chartOfAccts		IN	VARCHAR2 DEFAULT NULL
			,p_from_cc		IN	VARCHAR2 DEFAULT NULL
			,p_to_cc		IN	VARCHAR2 DEFAULT NULL
			,p_from_asset_num	IN	VARCHAR2 DEFAULT NULL
			,p_to_asset_num		IN	VARCHAR2 DEFAULT NULL
			,p_request_id		IN	NUMBER
			,p_retcode		OUT NOCOPY NUMBER
			,p_errbuf		OUT NOCOPY VARCHAR2);

END igi_iac_rxi_i_wrap_asset_bal;

 

/
