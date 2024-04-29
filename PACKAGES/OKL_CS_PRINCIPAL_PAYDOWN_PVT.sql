--------------------------------------------------------
--  DDL for Package OKL_CS_PRINCIPAL_PAYDOWN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_PRINCIPAL_PAYDOWN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPPDS.pls 120.4 2005/12/20 19:10:22 rkuttiya noship $ */

--Added for 11i10+

  TYPE payment_rec_type IS RECORD (
    KHR_ID                 NUMBER,
    KLE_ID                 NUMBER,
    STY_ID                 NUMBER,
    start_date             DATE,
    structure              VARCHAR2(1),
    arrears_yn             VARCHAR2(1),
    periods                NUMBER,
    frequency              VARCHAR2(1),
    amount                 NUMBER,
    stub_days              NUMBER,
    stub_amount            NUMBER);


  TYPE payment_tbl_type IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;


    G_FIN_ASSET_OBJECT_TYPE           CONSTANT VARCHAR2(30) := 'FINANCIAL_ASSET_LINE';
    G_OBJECT_SRC_TABLE            CONSTANT VARCHAR2(30) := 'OKL_TRX_REQUESTS';
    G_PROPOSED_STATUS             CONSTANT VARCHAR2(30) := 'PROPOSED';
    G_CASH_FLOW_TYPE              CONSTANT VARCHAR2(30) := 'PAYMENT_SCHEDULE';
    G_PPD_REASON_CODE              CONSTANT VARCHAR2(30) := 'PRINCIPAL_PAYDOWN';


--End Addn for 11i10+

 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                p_commit	        IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER);

 PROCEDURE update_hdr_info(
                x_return_status  	OUT NOCOPY VARCHAR2,
                x_msg_count      	OUT NOCOPY NUMBER,
                x_msg_data       	OUT NOCOPY VARCHAR2,
                p_working_copy_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                p_start_date     	IN  OKL_K_HEADERS_FULL_V.START_DATE%TYPE,
                p_end_date       	IN  OKL_K_HEADERS_FULL_V.END_DATE%TYPE,
                p_term_duration  	IN  OKL_K_HEADERS_FULL_V.TERM_DURATION%TYPE);


 PROCEDURE calculate(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_trqv_tbl              IN okl_trx_requests_pub.trqv_tbl_type,
                x_trqv_tbl              OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type);

 PROCEDURE update_ppd_request(
     		p_api_version           IN  NUMBER
    		,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    		,x_return_status        OUT  NOCOPY VARCHAR2
    		,x_msg_count            OUT  NOCOPY NUMBER
    		,x_msg_data             OUT  NOCOPY VARCHAR2
    		,p_trqv_rec             IN  okl_trx_requests_pub.trqv_rec_type
    		,x_trqv_rec             OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type);

 PROCEDURE create_ppd_invoice (
		p_khr_id          	IN NUMBER,
                p_ppd_amount        	IN NUMBER,
                p_ppd_desc          	IN VARCHAR2 DEFAULT NULL,
                p_syndication_code  	IN VARCHAR2 DEFAULT NULL,
                p_factoring_code    	IN VARCHAR2 DEFAULT NULL,
                x_tai_id            	OUT NOCOPY NUMBER,
                x_return_status     	OUT NOCOPY VARCHAR2,
                x_msg_count         	OUT NOCOPY NUMBER,
                x_msg_data          	OUT NOCOPY VARCHAR2);

--Added the following for 11i10+ project
 PROCEDURE cancel_ppd(
     		p_api_version           IN  NUMBER
    		,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    		,x_return_status        OUT  NOCOPY VARCHAR2
    		,x_msg_count            OUT  NOCOPY NUMBER
    		,x_msg_data             OUT  NOCOPY VARCHAR2
    		,p_khr_id               IN  NUMBER);

 PROCEDURE invoice_apply_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER
                ,p_trx_id               IN  NUMBER);

 FUNCTION check_for_ppd (
		p_khr_id    IN      NUMBER
		,p_effective_date IN DATE)
 RETURN VARCHAR2;

  FUNCTION check_if_ppd
   (p_request_id    IN      NUMBER)
  RETURN VARCHAR2;


  PROCEDURE store_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_ppd_request_id            IN  NUMBER,
    p_ppd_khr_id                IN  NUMBER,
    p_payment_structure         IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_cfo_id                    OUT NOCOPY NUMBER);

 PROCEDURE store_principal_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_ppd_request_id            IN  NUMBER,
    p_ppd_khr_id                IN  NUMBER,
    p_payment_structure         IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type,
    x_cfo_id                    OUT NOCOPY NUMBER);


 PROCEDURE store_esg_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_ppd_request_id            IN  NUMBER,
    p_ppd_khr_id                IN  NUMBER,
    p_payment_tbl               IN payment_tbl_type);

 PROCEDURE store_stm_payments(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_ppd_request_id            IN  NUMBER,
    p_ppd_khr_id                IN  NUMBER,
    p_payment_tbl               IN payment_tbl_type,
    x_cfo_id                    OUT NOCOPY NUMBER);


 PROCEDURE process_ppd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER);

	--This will be called from WF
 PROCEDURE invoice_bill_apply(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER
                ,p_req_id               IN  NUMBER);

--rkuttiya added for 11i OKL.H Variable Rate
 PROCEDURE process_lpd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER) ;

END OKL_CS_PRINCIPAL_PAYDOWN_PVT;

/
