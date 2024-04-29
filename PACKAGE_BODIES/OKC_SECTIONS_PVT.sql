--------------------------------------------------------
--  DDL for Package Body OKC_SECTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SECTIONS_PVT" AS
/* $Header: OKCCSCNB.pls 120.0 2005/05/25 23:02:01 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME		 CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_EXCEPTION_HALT_VALIDATION exception;
  NO_CONTRACT_FOUND exception;
  G_NO_UPDATE_ALLOWED_EXCEPTION exception;
  G_NO_UPDATE_ALLOWED CONSTANT VARCHAR2(200) := 'OKC_NO_UPDATE_ALLOWED';
  G_EXCEPTION_HALT_PROCESS exception;
  ---------------------------------------------------------------------------

  FUNCTION Update_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
	l_api_version                 NUMBER := 1;
	l_init_msg_list               VARCHAR2(1) := 'F';
	x_return_status               VARCHAR2(1);
	x_msg_count                   NUMBER;
	x_msg_data                    VARCHAR2(2000);
	x_out_rec                     OKC_CVM_PVT.cvmv_rec_type;
	l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

	-- initialize return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- assign/populate contract header id
	l_cvmv_rec.chr_id := p_chr_id;

	OKC_CVM_PVT.update_contract_version(
		p_api_version    => l_api_version,
		p_init_msg_list  => l_init_msg_list,
		x_return_status  => x_return_status,
		x_msg_count      => x_msg_count,
		x_msg_data       => x_msg_data,
		p_cvmv_rec       => l_cvmv_rec,
		x_cvmv_rec       => x_out_rec);

	-- Error handling....
	-- calls OTHERS exception
	return (x_return_status);
  EXCEPTION
    when OTHERS then
	   -- notify caller of an error
	   x_return_status := OKC_API.G_RET_STS_ERROR;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	return (x_return_status);
  END;
  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN  OKC_SCN_PVT.scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY  OKC_SCN_PVT.scnv_rec_type) IS

    l_scnv_rec		OKC_SCN_PVT.scnv_rec_type := p_scnv_rec;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OKC_SCN_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_scnv_rec		=> l_scnv_rec,
            x_scnv_rec		=> x_scnv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
	   p_scnv_rec.chr_id > 0)
    Then
	  x_return_status := Update_Minor_Version(p_scnv_rec.chr_id);
    End If;

  END create_section;

  PROCEDURE create_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN  OKC_SCN_PVT.scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY  OKC_SCN_PVT.scnv_tbl_type) IS

  BEGIN
    OKC_SCN_PVT.Insert_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_tbl		=> p_scnv_tbl,
      x_scnv_tbl		=> x_scnv_tbl);
  END create_section;

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type,
    x_scnv_rec                     OUT NOCOPY OKC_SCN_PVT.scnv_rec_type) IS

  BEGIN

    OKC_SCN_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_scnv_rec			=> p_scnv_rec,
      x_scnv_rec			=> x_scnv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
	   p_scnv_rec.chr_id > 0)
    Then
	  x_return_status := Update_Minor_Version(p_scnv_rec.chr_id);
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_section;

  PROCEDURE update_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type,
    x_scnv_tbl                     OUT NOCOPY OKC_SCN_PVT.scnv_tbl_type) IS

  BEGIN
    OKC_SCN_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_scnv_tbl			=> p_scnv_tbl,
      x_scnv_tbl			=> x_scnv_tbl);
  END update_section;

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type) IS

    l_chr_id NUMBER;
    Cursor l_scn_csr IS
		SELECT chr_id
		FROM okc_sections_b
		WHERE id = p_scnv_rec.ID;
  BEGIN

    open l_scn_csr;
    fetch l_scn_csr into l_chr_id;
    close l_scn_csr;

    OKC_SCN_PVT.Delete_Row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_scnv_rec		=> p_scnv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS AND
	   l_chr_id > 0)
    Then
	  x_return_status := Update_Minor_Version(l_chr_id);
    End If;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_section;

  PROCEDURE delete_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type) IS

  BEGIN
    OKC_SCN_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_tbl		=> p_scnv_tbl);
  END delete_section;

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type) IS

  BEGIN
    OKC_SCN_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> p_scnv_rec);
  END lock_section;

  PROCEDURE lock_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type) IS

  BEGIN
    OKC_SCN_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_tbl		=> p_scnv_tbl);
  END lock_section;

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_rec                     IN OKC_SCN_PVT.scnv_rec_type) IS

  BEGIN
    OKC_SCN_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_rec		=> p_scnv_rec);
  END validate_section;

  PROCEDURE validate_section(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scnv_tbl                     IN OKC_SCN_PVT.scnv_tbl_type) IS

  BEGIN
    OKC_SCN_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_scnv_tbl		=> p_scnv_tbl);
  END validate_section;

  FUNCTION Get_CHR_ID_For_Section(p_scn_id NUMBER) RETURN NUMBER IS
    Cursor l_scn_csr Is
		SELECT chr_id
		FROM okc_sections_b
		WHERE id = p_scn_id;

     l_chr_id NUMBER := -1;
  BEGIN
     open l_scn_csr;
     fetch l_scn_csr into l_chr_id;
     close l_scn_csr;
     return l_chr_id;
  EXCEPTION
    when OTHERS then
	   return l_chr_id;
  END Get_CHR_ID_For_Section;

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN  OKC_SCC_PVT.sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY  OKC_SCC_PVT.sccv_rec_type) IS

    l_sccv_rec		OKC_SCC_PVT.sccv_rec_type := p_sccv_rec;
    l_chr_id NUMBER;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OKC_SCC_PVT.Insert_Row(
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_sccv_rec		=> l_sccv_rec,
            x_sccv_rec		=> x_sccv_rec);


    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
	   l_chr_id := Get_CHR_ID_For_Section(p_sccv_rec.SCN_ID);
	   If (l_chr_id > 0) Then
	       x_return_status := Update_Minor_Version(l_chr_id);
        End If;
    End If;
  END create_section_content;

  PROCEDURE create_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN  OKC_SCC_PVT.sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY  OKC_SCC_PVT.sccv_tbl_type) IS

  BEGIN
    OKC_SCC_PVT.Insert_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_tbl		=> p_sccv_tbl,
      x_sccv_tbl		=> x_sccv_tbl);
  END create_section_content;

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type,
    x_sccv_rec                     OUT NOCOPY OKC_SCC_PVT.sccv_rec_type) IS

     l_chr_id NUMBER := -1;
  BEGIN

    OKC_SCC_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_sccv_rec			=> p_sccv_rec,
      x_sccv_rec			=> x_sccv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
	   l_chr_id := Get_CHR_ID_For_Section(p_sccv_rec.SCN_ID);
	   If (l_chr_id > 0) Then
	       x_return_status := Update_Minor_Version(l_chr_id);
        End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END update_section_content;

  PROCEDURE update_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type,
    x_sccv_tbl                     OUT NOCOPY OKC_SCC_PVT.sccv_tbl_type) IS

  BEGIN
    OKC_SCC_PVT.Update_Row(
	 p_api_version			=> p_api_version,
	 p_init_msg_list		=> p_init_msg_list,
      x_return_status 		=> x_return_status,
      x_msg_count     		=> x_msg_count,
      x_msg_data      		=> x_msg_data,
      p_sccv_tbl			=> p_sccv_tbl,
      x_sccv_tbl			=> x_sccv_tbl);
  END update_section_content;

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type) IS

    l_chr_id NUMBER;
  BEGIN

    OKC_SCC_PVT.Delete_Row(
	 		p_api_version		=> p_api_version,
	 		p_init_msg_list	=> p_init_msg_list,
      		x_return_status 	=> x_return_status,
      		x_msg_count     	=> x_msg_count,
      		x_msg_data      	=> x_msg_data,
      		p_sccv_rec		=> p_sccv_rec);

    -- Update minor version
    If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
	   l_chr_id := Get_CHR_ID_For_Section(p_sccv_rec.SCN_ID);
	   If (l_chr_id > 0) Then
	       x_return_status := Update_Minor_Version(l_chr_id);
        End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END delete_section_content;

  PROCEDURE delete_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type) IS

  BEGIN
    OKC_SCC_PVT.Delete_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_tbl		=> p_sccv_tbl);
  END delete_section_content;

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type) IS

  BEGIN
    OKC_SCC_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> p_sccv_rec);
  END lock_section_content;

  PROCEDURE lock_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type) IS

  BEGIN
    OKC_SCC_PVT.Lock_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_tbl		=> p_sccv_tbl);
  END lock_section_content;

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_rec                     IN OKC_SCC_PVT.sccv_rec_type) IS

  BEGIN
    OKC_SCC_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_rec		=> p_sccv_rec);
  END validate_section_content;

  PROCEDURE validate_section_content(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sccv_tbl                     IN OKC_SCC_PVT.sccv_tbl_type) IS

  BEGIN
    OKC_SCC_PVT.Validate_Row(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_sccv_tbl		=> p_sccv_tbl);
  END validate_section_content;

  PROCEDURE add_language IS
  BEGIN
	OKC_SCN_PVT.add_language;
  END add_language;

END OKC_SECTIONS_PVT;

/
