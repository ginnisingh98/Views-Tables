--------------------------------------------------------
--  DDL for Package OKL_VARIABLE_INTEREST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VARIABLE_INTEREST_PUB" AUTHID CURRENT_USER AS
    /* $Header: OKLPVARS.pls 120.1 2005/10/22 01:30:10 rseela noship $ */
     ------------------------------------------------------------------------------
     -- Global Variables
     ------------------------------------------------------------------------------

     G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_VARIABLE_INTEREST_PUB';
     G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
     G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
     G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
     G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';

     ---------------------------------------------------------------------------
     -- Procedures and Functions
     ---------------------------------------------------------------------------

 SUBTYPE csm_periodic_expenses_tbl_type IS okl_process_streams_pvt.srlv_tbl_type;
 SUBTYPE csm_loan_level_tbl_type IS okl_create_streams_pvt.csm_loan_level_tbl_type;


       PROCEDURE VARIABLE_INTEREST
         (p_api_version		IN  NUMBER
    	,p_init_msg_list		IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
    	,x_return_status		OUT NOCOPY VARCHAR2
    	,x_msg_count		OUT NOCOPY NUMBER
    	,x_msg_data		    	OUT NOCOPY VARCHAR2
        ,p_contract_number VARCHAR2
        ,P_to_date       DATE);


       PROCEDURE var_int_rent_level(
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_chr_id        IN NUMBER,
        p_trx_id        IN NUMBER,
        p_trx_status    IN VARCHAR2,
        p_rent_tbl      IN csm_periodic_expenses_tbl_type);



        PROCEDURE VARIABLE_INTEREST
        (errbuf	 OUT NOCOPY  VARCHAR2
    	,retcode OUT NOCOPY  NUMBER
        ,p_contract_number  IN  VARCHAR2 DEFAULT NULL
    	,p_to_date	 IN  VARCHAR2	DEFAULT NULL);

/*   4682018 Redudant procedure
       PROCEDURE initiate_request
        (p_api_version        IN  NUMBER,
         p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
         p_contract_number             IN  VARCHAR2,
		 p_from_date          IN  DATE,
		 p_to_date            IN  DATE,
		 x_return_status      OUT NOCOPY VARCHAR2,
		 x_msg_count          OUT NOCOPY NUMBER,
		 x_msg_data           OUT NOCOPY VARCHAR2,
		 x_request_id         OUT NOCOPY NUMBER,
		 x_trans_status       OUT NOCOPY VARCHAR2);
*/
END;


 

/
