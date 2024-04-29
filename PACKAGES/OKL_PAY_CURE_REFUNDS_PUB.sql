--------------------------------------------------------
--  DDL for Package OKL_PAY_CURE_REFUNDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_CURE_REFUNDS_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPPCRS.pls 115.7 2003/04/19 16:41:14 jsanju noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200)
                                            := 'OKL_PAY_CURE_REFUNDS_PUB';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200)
                                            := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  PG_DEBUG NUMBER     := TO_NUMBER(NVL(FND_PROFILE.value('OKL_DEBUG_LEVEL'), '20'));
  ---------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Global Record Type
  ------------------------------------------------------------------------------
 SUBTYPE pay_cure_refunds_rec_type IS
           okl_pay_cure_refunds_pvt.pay_cure_refunds_rec_type;

 SUBTYPE pay_cure_refunds_tbl_type IS
           okl_pay_cure_refunds_pvt.pay_cure_refunds_tbl_type;

PROCEDURE create_refund_hdr
             (  p_api_version           IN NUMBER
               ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id OUT NOCOPY  NUMBER
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               );

PROCEDURE update_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );

PROCEDURE submit_cure_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );

PROCEDURE delete_refund_hdr
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );

PROCEDURE  approve_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );




PROCEDURE create_refund_headers
             (  p_api_version           IN NUMBER
               ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_cure_refund_header_id OUT NOCOPY  NUMBER
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               );

PROCEDURE update_refund_headers
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_rec IN pay_cure_refunds_rec_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );

PROCEDURE create_refund_details
             (  p_api_version           IN NUMBER
               ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit                IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status         OUT NOCOPY VARCHAR2
               ,x_msg_count             OUT NOCOPY NUMBER
               ,x_msg_data              OUT NOCOPY VARCHAR2
               );

PROCEDURE update_refund_details
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );

PROCEDURE delete_refund_details
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_pay_cure_refunds_tbl IN pay_cure_refunds_tbl_type
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );


end OKL_PAY_CURE_REFUNDS_PUB;

 

/
