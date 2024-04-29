--------------------------------------------------------
--  DDL for Package Body OKC_PH_LINE_BREAKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PH_LINE_BREAKS_PVT" AS
/* $Header: OKCRPHLB.pls 120.0 2005/05/25 23:00:44 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PH_LINE_BREAKS_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;


-- Start of comments
--
-- Procedure Name  : create_Price_Hold_Line_Breaks
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_Price_Hold_Line_Breaks(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec  IN	okc_ph_line_breaks_v_rec_type,
                              x_okc_ph_line_breaks_v_rec  OUT NOCOPY	okc_ph_line_breaks_v_rec_type) is
begin

  okc_phl_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_okc_ph_line_breaks_v_rec  =>  p_okc_ph_line_breaks_v_rec,
                         x_okc_ph_line_breaks_v_rec  =>  x_okc_ph_line_breaks_v_rec);

--V

end create_Price_Hold_Line_Breaks;



-- Start of comments
--
-- Procedure Name  : create_Price_Hold_Line_Breaks
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_Price_Hold_Line_Breaks(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_tbl  IN	okc_ph_line_breaks_v_tbl_type,
                              x_okc_ph_line_breaks_v_tbl  OUT NOCOPY	okc_ph_line_breaks_v_tbl_type) is
begin

  okc_phl_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_okc_ph_line_breaks_v_tbl  =>  p_okc_ph_line_breaks_v_tbl,
                         x_okc_ph_line_breaks_v_tbl  =>  x_okc_ph_line_breaks_v_tbl);

--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end create_Price_Hold_Line_Breaks;



-- Start of comments
--
-- Procedure Name  : delete_Price_Hold_Line_Breaks
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_Price_Hold_Line_Breaks(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec        IN  okc_ph_line_breaks_v_rec_type) is



begin
--V
  okc_phl_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_okc_ph_line_breaks_v_rec  =>  p_okc_ph_line_breaks_v_rec);


  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;

end delete_Price_Hold_Line_Breaks;



end OKC_PH_LINE_BREAKS_PVT;

/
