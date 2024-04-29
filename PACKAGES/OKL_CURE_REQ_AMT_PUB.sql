--------------------------------------------------------
--  DDL for Package OKL_CURE_REQ_AMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_REQ_AMT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCRKS.pls 115.0 2003/04/25 04:15:33 smereddy noship $ */

 subtype cure_req_rec_type is OKL_CURE_REQ_AMT_PVT.cure_req_rec_type;
 subtype cure_req_tbl_type is OKL_CURE_REQ_AMT_PVT.cure_req_tbl_type;

-- GLOBAL VARIABLES

G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_CURE_REQ_AMT_PUB';
G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE		CONSTANT VARCHAR2(4) := '_PUB';

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


END OKL_CURE_REQ_AMT_PUB;

 

/
