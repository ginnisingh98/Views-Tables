--------------------------------------------------------
--  DDL for Package OKC_SALES_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_SALES_CREDIT_PVT" AUTHID CURRENT_USER as
/* $Header: OKCCSCRS.pls 120.0 2005/05/25 18:29:33 appldev noship $  */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- simple entity object subtype definitions
  subtype scrv_rec_type is OKC_scr_PVT.scrv_rec_type;
  subtype scrv_tbl_type is OKC_scr_PVT.scrv_tbl_type;

  -- public procedure declarations
procedure create_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type,
                              x_scrv_rec	OUT NOCOPY	scrv_rec_type);

procedure create_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_tbl        IN  scrv_tbl_type,
                              x_scrv_tbl        OUT NOCOPY scrv_tbl_type);


procedure update_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type,
                              x_scrv_rec	OUT NOCOPY	scrv_rec_type);
procedure delete_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type);
procedure lock_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type);
procedure validate_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type);
end OKC_SALES_CREDIT_PVT;

 

/
