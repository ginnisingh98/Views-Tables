--------------------------------------------------------
--  DDL for Package OKC_STATUS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_STATUS_CHANGE_PVT" AUTHID CURRENT_USER as
/*$Header: OKCRSTSS.pls 120.0 2005/05/26 09:56:40 appldev noship $*/

-- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLCODE_TOKEN        	CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_STATUS_CHANGE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  ---------------------------------------------------------------------------
-- Global var holding the User Id
     user_id             NUMBER;

-- Global var to hold the ERROR value
     ERROR               NUMBER := 1;

-- Global var to hold the SUCCESS value
     SUCCESS           	NUMBER := 0;

-- Global var holding the Current Error code for the error encountered
     Current_Error_Code   Varchar2(20) := NULL;

-- Global var to hold the Concurrent Process return values
   	conc_ret_code          	NUMBER 	:= SUCCESS;
   	v_retcode   		NUMBER 	:= SUCCESS;
	CONC_STATUS 		BOOLEAN;


procedure change_status (
			ERRBUF     	   OUT NOCOPY VARCHAR2,
			RETCODE    	   OUT NOCOPY NUMBER,
			p_category 	   IN VARCHAR2 default null,
			p_from_k 	   IN VARCHAR2 default null,
			p_to_k 	      IN VARCHAR2 default null,
			p_from_m 	   IN VARCHAR2 default null,
			p_to_m 	      IN VARCHAR2 default null,
			p_debug 	      IN VARCHAR2  default 'N',
         p_last_rundate IN VARCHAR2 default null );

END okc_status_change_pvt;

 

/
