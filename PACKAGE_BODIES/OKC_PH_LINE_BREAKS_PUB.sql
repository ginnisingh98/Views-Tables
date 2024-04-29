--------------------------------------------------------
--  DDL for Package Body OKC_PH_LINE_BREAKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PH_LINE_BREAKS_PUB" AS
/* $Header: OKCPPHLB.pls 120.0 2005/05/25 23:05:30 appldev noship $  */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PH_LINE_BREAKS_PUB';
  G_okc_ph_line_breaks_v_rec    okc_ph_line_breaks_v_rec_type;


-- Start of comments
--
-- Procedure Name  : create_Price_Hold_Line_Breaks
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_Price_Hold_Line_Breaks(p_api_version	IN NUMBER,
                              p_init_msg_list	IN	   VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec IN         okc_ph_line_breaks_v_rec_type,
                              x_okc_ph_line_breaks_v_rec OUT NOCOPY okc_ph_line_breaks_v_rec_type) is




l_api_name                     CONSTANT VARCHAR2(30) := 'create_Price_Hold_Line_Breaks';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin

   OKC_PH_LINE_BREAKS_PVT.create_Price_Hold_Line_Breaks(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_okc_ph_line_breaks_v_rec,
                              x_okc_ph_line_breaks_v_rec);


  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end create_Price_Hold_Line_Breaks;

-- Start of comments
--
-- Procedure Name  : create_Price_Hold_Line_Breaks
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_Price_Hold_Line_Breaks(p_api_version	IN NUMBER,
                              p_init_msg_list	IN	   VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_tbl IN         okc_ph_line_breaks_v_tbl_type,
                              x_okc_ph_line_breaks_v_tbl OUT NOCOPY okc_ph_line_breaks_v_tbl_type) is




i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_okc_ph_line_breaks_v_tbl.COUNT>0) then
        i := p_okc_ph_line_breaks_v_tbl.FIRST;
        LOOP
	    create_Price_Hold_Line_Breaks(p_api_version => p_api_version,
                              p_init_msg_list => OKC_API.G_FALSE,
                              x_return_status => l_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data,
                              p_okc_ph_line_breaks_v_rec => p_okc_ph_line_breaks_v_tbl(i),
                              x_okc_ph_line_breaks_v_rec => x_okc_ph_line_breaks_v_tbl(i));


          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
          i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end create_Price_Hold_Line_Breaks;



procedure delete_Price_Hold_Line_Breaks(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_okc_ph_line_breaks_v_rec        IN  okc_ph_line_breaks_v_rec_type) is


l_api_name                     CONSTANT VARCHAR2(30) := 'delete_Price_Hold_Line_Breaks';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin

   OKC_PH_LINE_BREAKS_PVT.delete_Price_Hold_Line_Breaks(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_okc_ph_line_breaks_v_rec);


  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end delete_Price_Hold_Line_Breaks;




end OKC_PH_LINE_BREAKS_PUB;

/
