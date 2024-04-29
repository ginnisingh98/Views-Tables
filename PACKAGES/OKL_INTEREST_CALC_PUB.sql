--------------------------------------------------------
--  DDL for Package OKL_INTEREST_CALC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTEREST_CALC_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPITUS.pls 120.5 2008/02/29 10:50:53 nikshah ship $ */


PROCEDURE CALC_INTEREST_ACTIVATE(p_api_version 	    IN 	NUMBER,
                                 p_init_msg_list    IN 	VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count 	    OUT NOCOPY NUMBER,
     	                         x_msg_data 	    OUT NOCOPY VARCHAR2,
				 p_contract_number  IN  VARCHAR2,
                                 p_activation_date  IN  DATE,
                                 x_amount           OUT NOCOPY NUMBER,
				 x_source_id        OUT NOCOPY NUMBER);


FUNCTION SUBMIT_CALCULATE_INTEREST(p_api_version    IN NUMBER,
                                   p_init_msg_list  IN VARCHAR2,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count 	    OUT NOCOPY NUMBER,
                                   x_msg_data 	    OUT NOCOPY VARCHAR2,
                                   p_period_name    IN VARCHAR2 )
         RETURN NUMBER;

G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_INTEREST_CALC_PUB' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

END OKL_INTEREST_CALC_PUB;

/
