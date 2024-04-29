--------------------------------------------------------
--  DDL for Package OKL_PAY_CURE_REFUNDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAY_CURE_REFUNDS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRPCRS.pls 115.12 2003/10/16 19:31:23 jsanju noship $ */


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME              CONSTANT VARCHAR2(200)
                                            := 'OKL_PAY_CURE_REFUNDS_PVT';
  G_APP_NAME              CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200)
                                            := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  PG_DEBUG NUMBER     := TO_NUMBER(NVL(FND_PROFILE.value('OKL_DEBUG_LEVEL'), '20'));
  ---------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Global Record Type
  ------------------------------------------------------------------------------
 TYPE pay_cure_refunds_rec_type IS RECORD (
  refund_number        okl_cure_refunds.refund_number%type
 ,vendor_site_id       okl_cure_refunds.vendor_site_id%type
 ,chr_id               okl_cure_refunds.chr_id%type
 ,invoice_date         DATE
 ,pay_terms            okl_trx_ap_invoices_b.ippt_id%type
 ,payment_method_code  okl_trx_ap_invoices_b.payment_method_code%type
 ,currency             okl_trx_ap_invoices_b.currency_code%type
 ,refund_header_id     okl_cure_refund_headers_b.cure_refund_header_id%type
 ,refund_id           okl_cure_refunds.cure_refund_id%type
 ,description          okl_cure_refund_headers_tl.description%type
 ,received_amount    okl_cure_refund_headers_b.received_amount%type
 ,negotiated_amount  okl_cure_refund_headers_b.negotiated_amount%type
 ,offset_amount      okl_cure_refunds.offset_amount%type
 ,offset_contract      okl_cure_refunds.offset_contract%type
  ,refund_amount_due    okl_cure_refunds.total_refund_due%type
 ,refund_amount        okl_cure_refunds.disbursement_amount%type
 ,refund_type          okl_cure_refund_headers_b.refund_type%type
 ,vendor_id             po_vendor_sites_all.vendor_id%type
 ,vendor_site_cure_due  okl_cure_refund_headers_b.vendor_site_cure_due%type
 ,vendor_cure_due      okl_cure_refund_headers_b.vendor_cure_due%type
 );
 g_miss_pay_crf_rec_type      pay_cure_refunds_rec_type;

TYPE pay_cure_refunds_tbl_type IS TABLE OF pay_cure_refunds_rec_type
INDEX BY BINARY_INTEGER;

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

PROCEDURE submit_cure_refunds
             (  p_api_version          IN NUMBER
               ,p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_TRUE
               ,p_commit               IN VARCHAR2 DEFAULT OKC_API.G_FALSE
               ,p_status               IN VARCHAR2
               ,p_refund_header_id     IN NUMBER
               ,x_return_status       OUT NOCOPY VARCHAR2
               ,x_msg_count           OUT NOCOPY NUMBER
               ,x_msg_data            OUT NOCOPY VARCHAR2
               );



/**
  called from the workflow to update cure refunds based on
  the approval
 **/

  PROCEDURE set_approval_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2);


  PROCEDURE set_reject_status (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 result       out nocopy varchar2);
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

-- to generate a table of Offset contracts
PROCEDURE gen_doc (document_id IN VARCHAR2
                  ,display_type IN VARCHAR2
                  ,document IN OUT NOCOPY VARCHAR2
                  ,document_type IN OUT NOCOPY VARCHAR2);

end OKL_PAY_CURE_REFUNDS_PVT;

 

/
