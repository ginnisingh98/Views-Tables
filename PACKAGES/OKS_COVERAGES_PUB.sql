--------------------------------------------------------
--  DDL for Package OKS_COVERAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COVERAGES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPMCVS.pls 120.0 2005/05/25 18:27:00 appldev noship $*/
   --------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKS_COVERAGES_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
 --------------------------------------------------------------------------
  --Global Exception
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

subtype ac_rec_type IS oks_coverages_pvt.ac_rec_type;

PROCEDURE CREATE_ACTUAL_COVERAGE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_ac_rec_in    	    IN  ac_rec_type,
    p_restricted_update     IN VARCHAR2 DEFAULT 'F',
    x_Actual_coverage_id    OUT NOCOPY NUMBER);

PROCEDURE Undo_Header(
    p_api_version	    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Header_id    	    IN NUMBER);
PROCEDURE Undo_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER);

 PROCEDURE Update_cov_eff(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER,
    p_new_start_date        IN DATE,
    p_new_end_date          IN DATE);

 PROCEDURE Instantiate_coverage(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER,
    x_actual_coverage_id    OUT NOCOPY NUMBER);

PROCEDURE Delete_coverage(
    p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_service_Line_Id       IN NUMBER);

    Procedure CHECK_COVERAGE_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_coverage_match         OUT NOCOPY VARCHAR2);

PROCEDURE  CREATE_ADJUSTED_COVERAGE(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_Actual_coverage_id            OUT NOCOPY NUMBER);

 PROCEDURE OKS_BILLRATE_MAPPING(
                                p_api_version           IN NUMBER ,
                                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_business_process_id   IN NUMBER,
                                p_time_labor_tbl_in     IN OKS_COVERAGES_PVT.time_labor_tbl,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2);



PROCEDURE Version_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER);


PROCEDURE Restore_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER);


PROCEDURE	Delete_History(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER);

PROCEDURE Delete_Saved_Version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER);



END OKS_COVERAGES_PUB;

 

/
