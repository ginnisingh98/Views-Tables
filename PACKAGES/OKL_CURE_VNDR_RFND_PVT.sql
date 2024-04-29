--------------------------------------------------------
--  DDL for Package OKL_CURE_VNDR_RFND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_VNDR_RFND_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRFSS.pls 115.0 2003/04/25 04:11:50 smereddy noship $ */

 TYPE cure_rfnd_rec_type is record (
    cure_refund_stage_id OKL_CURE_REFUND_STAGE.cure_refund_stage_id%type ,
    received_amount   OKL_CURE_REFUND_STAGE.received_amount%type ,
    chr_id   OKL_CURE_REFUND_STAGE.chr_id%type ,
    vendor_id   OKL_CURE_REFUND_STAGE.vendor_id%type ,
    currency_code   okc_k_headers_b.currency_code%type ,
    contract_number   okc_k_headers_b.contract_number%type ,
    offset_amount   OKL_CURE_REFUNDS.offset_amount%type ,
    offset_contract_number   okc_k_headers_b.contract_number%type ,
    offset_contract_id   OKL_CURE_REFUNDS.offset_contract%type ,
    cure_refund_header_id   OKL_CURE_REFUND_HEADERS_B.cure_refund_header_id%type ,
    REFUND_HEADER_NUMBER   OKL_CURE_REFUND_HEADERS_B.REFUND_HEADER_NUMBER%type,
    cure_refund_line_id OKL_CURE_REFUNDS.cure_refund_id%type ,
    vendor_site_id OKL_CURE_REFUNDS.vendor_site_id%type,
    rl_object_version_number OKL_CURE_REFUNDS.object_version_number%type ,
    rh_object_version_number OKL_CURE_REFUND_HEADERS_B.object_version_number%type ,
    rs_object_version_number OKL_CURE_REFUND_STAGE.object_version_number%type
    );

 TYPE cure_rfnd_tbl_type is table of cure_rfnd_rec_type INDEX BY BINARY_INTEGER;

-- GLOBAL VARIABLES
G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_CURE_RFND_PVT';
G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE	     CONSTANT VARCHAR2(4)   := '_PVT';


PROCEDURE create_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
);

PROCEDURE update_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
);

PROCEDURE delete_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl         IN  cure_rfnd_tbl_type
);

END OKL_CURE_VNDR_RFND_PVT;

 

/
