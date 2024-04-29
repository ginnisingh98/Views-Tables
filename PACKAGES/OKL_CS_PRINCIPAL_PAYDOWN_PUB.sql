--------------------------------------------------------
--  DDL for Package OKL_CS_PRINCIPAL_PAYDOWN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CS_PRINCIPAL_PAYDOWN_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPPDS.pls 120.2 2005/10/26 13:04:43 rkuttiya noship $ */


 ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_APP_NAME                    CONSTANT VARCHAR2(3)   := 'OKL';
  G_PKG_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_PRINCIPAL_PAYDOWN_PUB';
  G_API_NAME                    CONSTANT VARCHAR2(30)  := 'OKL_CS_PRINCIPAL_PAYDOWN';
  G_API_VERSION                 CONSTANT NUMBER        := 1;
  G_COMMIT                      CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INIT_MSG_LIST               CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_VALIDATION_LEVEL            CONSTANT NUMBER        := FND_API.G_VALID_LEVEL_FULL;


 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2 := OKL_API.G_FALSE,
                p_commit                 IN      VARCHAR2 := OKL_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER);


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

 PROCEDURE process_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_ppd_request_id       IN  NUMBER);

 PROCEDURE process_lpd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER);


END OKL_CS_PRINCIPAL_PAYDOWN_PUB;

 

/
