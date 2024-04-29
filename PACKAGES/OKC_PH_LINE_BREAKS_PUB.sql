--------------------------------------------------------
--  DDL for Package OKC_PH_LINE_BREAKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PH_LINE_BREAKS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPPHLS.pls 120.0 2005/05/25 23:11:39 appldev noship $  */


  subtype okc_ph_line_breaks_v_rec_type is OKC_PHL_PVT.okc_ph_line_breaks_v_rec_type;
  subtype okc_ph_line_breaks_v_tbl_type is OKC_PHL_PVT.okc_ph_line_breaks_v_tbl_type;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
   procedure create_Price_Hold_Line_Breaks(p_api_version	IN NUMBER,
                              p_init_msg_list	IN	   VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec IN         okc_ph_line_breaks_v_rec_type,
                              x_okc_ph_line_breaks_v_rec OUT NOCOPY okc_ph_line_breaks_v_rec_type);


   procedure create_Price_Hold_Line_Breaks(p_api_version	IN NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_tbl        IN  okc_ph_line_breaks_v_tbl_type,
                              x_okc_ph_line_breaks_v_tbl        OUT NOCOPY okc_ph_line_breaks_v_tbl_type);



   procedure delete_Price_Hold_Line_Breaks(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec        IN  okc_ph_line_breaks_v_rec_type);



END OKC_PH_LINE_BREAKS_PUB;

 

/
