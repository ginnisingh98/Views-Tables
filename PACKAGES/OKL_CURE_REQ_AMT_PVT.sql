--------------------------------------------------------
--  DDL for Package OKL_CURE_REQ_AMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_REQ_AMT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRCRKS.pls 115.0 2003/04/25 04:15:16 smereddy noship $ */

 subtype camv_rec_type is OKL_cure_amounts_pub.camv_rec_type;
 subtype camv_tbl_type is OKL_cure_amounts_pub.camv_tbl_type;

 TYPE cure_req_rec_type is record (
     CURE_AMOUNT_ID OKL_CURE_AMOUNTS.cure_amount_id%type,
     CURE_REPORT_ID OKL_CURE_AMOUNTS.CRT_ID%type,
     CHR_ID OKL_CURE_AMOUNTS.CHR_ID%type,
     VENDOR_ID OKL_CURE_REPORTS.VENDOR_ID%type );

 TYPE cure_req_tbl_type is table of cure_req_rec_type INDEX BY BINARY_INTEGER;

-- GLOBAL VARIABLES
G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_CURE_REQ_AMT_PVT';
G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE		CONSTANT VARCHAR2(4) := '_PVT';
G_INVALID_VALUE      CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';


PROCEDURE update_cure_request(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_req_tbl      IN  cure_req_tbl_type,
            x_cure_req_tbl      OUT NOCOPY cure_req_tbl_type
);

PROCEDURE update_cure_request(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_vendor_id                IN  NUMBER,
            p_cure_report_id        IN  NUMBER
);

END OKL_CURE_REQ_AMT_PVT;

 

/
