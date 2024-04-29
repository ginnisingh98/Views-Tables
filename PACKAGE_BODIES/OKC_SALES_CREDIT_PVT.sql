--------------------------------------------------------
--  DDL for Package Body OKC_SALES_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SALES_CREDIT_PVT" AS
/* $Header: OKCCSCRB.pls 120.0 2005/05/25 22:45:43 appldev noship $  */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_SALES_CREDIT_PVT';
  G_CHILD_RECORD_FOUND        CONSTANT   varchar2(200) := 'OKC_CHILD_RECORD_FOUND';
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;


-- Start of comments
--
-- Procedure Name  : create_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type,
                              x_scrv_rec	OUT NOCOPY	scrv_rec_type) is
begin
  okC_scr_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_scrv_rec      => p_scrv_rec,
                         x_scrv_rec      => x_scrv_rec);
--V

  -- Update minor version
  If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
      x_return_status := OKC_CONTRACT_PUB.Increment_Minor_Version(x_scrv_rec.dnz_chr_id);
  End If;

  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end create_Sales_Credit;



-- Start of comments
--
-- Procedure Name  : create_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_tbl        IN  scrv_tbl_type,
                              x_scrv_tbl        OUT NOCOPY scrv_tbl_type) is
begin
  okC_scr_pvt.insert_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_scrv_tbl      => p_scrv_tbl,
                         x_scrv_tbl      => x_scrv_tbl);
--V
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end create_Sales_Credit;



-- Start of comments
--
-- Procedure Name  : update_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type,
                              x_scrv_rec	OUT NOCOPY	scrv_rec_type) is
begin
  okC_scr_pvt.update_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_scrv_rec      => p_scrv_rec,
                         x_scrv_rec      => x_scrv_rec);
--V

  -- Update minor version
  If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
      x_return_status := OKC_CONTRACT_PUB.Increment_Minor_Version(x_scrv_rec.dnz_chr_id);
  End If;

  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
end update_Sales_Credit;

-- Start of comments
--
-- Procedure Name  : delete_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type) is
begin
  okC_scr_pvt.delete_row(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         x_return_status => x_return_status,
                         p_scrv_rec      => p_scrv_rec);
--V

  -- Update minor version
  If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
      x_return_status := OKC_CONTRACT_PUB.Increment_Minor_Version(p_scrv_rec.dnz_chr_id);
  End If;


  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    return;
  end if;
exception
    WHEN OTHERS THEN
	NULL;
end delete_Sales_Credit;

-- Start of comments
--
-- Procedure Name  : lock_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure lock_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type) is
begin
  okC_scr_pvt.lock_row(p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       x_return_status => x_return_status,
                       p_scrv_rec      => p_scrv_rec);
end lock_Sales_Credit;

-- Start of comments
--
-- Procedure Name  : validate_Sales_Credit
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_Sales_Credit(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_scrv_rec	IN	scrv_rec_type) is
begin
  okC_scr_pvt.validate_row(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_return_status => x_return_status,
                           p_scrv_rec      => p_scrv_rec);
end validate_Sales_Credit;

end OKC_Sales_Credit_PVT;

/
