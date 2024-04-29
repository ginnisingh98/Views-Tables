--------------------------------------------------------
--  DDL for Package OKL_CURE_VNDR_RFND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CURE_VNDR_RFND_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRFSS.pls 115.0 2003/04/25 04:15:04 smereddy noship $ */

 subtype cure_rfnd_rec_type is OKL_CURE_VNDR_RFND_PVT.cure_rfnd_rec_type;
 subtype cure_rfnd_tbl_type is OKL_CURE_VNDR_RFND_PVT.cure_rfnd_tbl_type;

-- GLOBAL VARIABLES
G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_CURE_VNDR_RFND_PUB';
G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE	     CONSTANT VARCHAR2(4)   := '_PUB';


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

END OKL_CURE_VNDR_RFND_PUB;

 

/
