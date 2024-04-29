--------------------------------------------------------
--  DDL for Package Body OKL_RULE_APIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_APIS_PVT" As
/* $Header: OKLRRAPB.pls 120.5 2005/10/30 03:41:19 appldev noship $ */
--Start of Comments
--Procedure Name :  Get_Contract_Rgs
--Description    :  Get Contract Rule Groups for a chr_id, cle_id
--                 if chr_id is given gets data for header
--                 if only cle_id or cle_id and chr_id(dnz_chr_id) are given
--                 fetches data for line
--End of comments
--GLOBAL MESSAGES
G_DFF_FETCH_FAILED        CONSTANT Varchar2(200) := 'OKL_LLA_DFF_FETCH';
G_DFF_TABLE_QUERY_FAILED  CONSTANT Varchar2(200) := 'OKL_LLA_DFF_TABLE_QUERY';
G_DFF_VSET_QUERY_FAILED   CONSTANT Varchar2(200) := 'OKL_LLA_DFF_VSET_QUERY';
G_JTF_OBJECT_QUERY_FAILED CONSTANT Varchar2(200) := 'OKL_LLA_JTF_OBJ_QUERY';
G_JTF_OBJECT_TOKEN        CONSTANT Varchar2(200) := 'JTOT_OBJECT_CODE';
G_APPLICATION_COL_TOKEN   CONSTANT Varchar2(200) := 'APPLICATION_COLUMN';
G_RULE_CODE_TOKEN         CONSTANT Varchar2(200) := 'RULE_CODE';
Procedure Get_Contract_Rgs(p_api_version    IN  NUMBER,
                           p_init_msg_list  IN  VARCHAR2,
                           p_chr_id		    IN  NUMBER,
                           p_cle_id         IN  NUMBER,
                           p_rgd_code       IN  VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_rgpv_tbl       OUT NOCOPY rgpv_tbl_type,
                           x_rg_count       OUT NOCOPY NUMBER) is
l_No_RG_Found  BOOLEAN default True;
    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RGS';
    l_api_version		           CONSTANT NUMBER	:= 1.0;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULE_GROUPS_V
---------------------------------------------------------------------------
FUNCTION get_rgpv_tab (
    p_chr_id                     IN    NUMBER,
    p_cle_id                     IN    NUMBER,
    p_rgd_code                   IN    VARCHAR2,
    x_rg_count                   OUT NOCOPY NUMBER
  ) RETURN rgpv_tbl_type IS
    --BUG# 3562881:
    CURSOR okc_chr_rgpv_csr (p_chr_id     IN NUMBER,
                             p_rgd_code   IN VARCHAR2) IS
    SELECT
            rgpv.ID,
            rgpv.OBJECT_VERSION_NUMBER,
            rgpv.SFWT_FLAG,
            rgpv.RGD_CODE,
            rgpv.SAT_CODE,
            rgpv.RGP_TYPE,
            rgpv.CLE_ID,
            rgpv.CHR_ID,
            rgpv.DNZ_CHR_ID,
            rgpv.PARENT_RGP_ID,
            rgpv.COMMENTS,
            rgpv.ATTRIBUTE_CATEGORY,
            rgpv.ATTRIBUTE1,
            rgpv.ATTRIBUTE2,
            rgpv.ATTRIBUTE3,
            rgpv.ATTRIBUTE4,
            rgpv.ATTRIBUTE5,
            rgpv.ATTRIBUTE6,
            rgpv.ATTRIBUTE7,
            rgpv.ATTRIBUTE8,
            rgpv.ATTRIBUTE9,
            rgpv.ATTRIBUTE10,
            rgpv.ATTRIBUTE11,
            rgpv.ATTRIBUTE12,
            rgpv.ATTRIBUTE13,
            rgpv.ATTRIBUTE14,
            rgpv.ATTRIBUTE15,
            rgpv.CREATED_BY,
            rgpv.CREATION_DATE,
            rgpv.LAST_UPDATED_BY,
            rgpv.LAST_UPDATE_DATE,
            rgpv.LAST_UPDATE_LOGIN
     FROM   Okc_Rule_Groups_V rgpv
     WHERE  rgpv.chr_id     = p_chr_id
     AND    rgpv.dnz_chr_id = p_chr_id
     AND    rgpv.cle_id is NULL
     AND    rgpv.RGD_CODE = decode(p_rgd_code,null,rgpv.RGD_CODE,p_rgd_code);

    CURSOR okc_cle_rgpv_csr (p_chr_id     IN NUMBER,
                             p_cle_id     IN NUMBER,
                             p_rgd_code   IN VARCHAR2) IS
    SELECT
            rgpv.ID,
            rgpv.OBJECT_VERSION_NUMBER,
            rgpv.SFWT_FLAG,
            rgpv.RGD_CODE,
            rgpv.SAT_CODE,
            rgpv.RGP_TYPE,
            rgpv.CLE_ID,
            rgpv.CHR_ID,
            rgpv.DNZ_CHR_ID,
            rgpv.PARENT_RGP_ID,
            rgpv.COMMENTS,
            rgpv.ATTRIBUTE_CATEGORY,
            rgpv.ATTRIBUTE1,
            rgpv.ATTRIBUTE2,
            rgpv.ATTRIBUTE3,
            rgpv.ATTRIBUTE4,
            rgpv.ATTRIBUTE5,
            rgpv.ATTRIBUTE6,
            rgpv.ATTRIBUTE7,
            rgpv.ATTRIBUTE8,
            rgpv.ATTRIBUTE9,
            rgpv.ATTRIBUTE10,
            rgpv.ATTRIBUTE11,
            rgpv.ATTRIBUTE12,
            rgpv.ATTRIBUTE13,
            rgpv.ATTRIBUTE14,
            rgpv.ATTRIBUTE15,
            rgpv.CREATED_BY,
            rgpv.CREATION_DATE,
            rgpv.LAST_UPDATED_BY,
            rgpv.LAST_UPDATE_DATE,
            rgpv.LAST_UPDATE_LOGIN
     FROM   Okc_Rule_Groups_V rgpv
     WHERE  rgpv.cle_id     = p_cle_id
     AND    rgpv.dnz_chr_id = p_chr_id
     AND    rgpv.chr_id is NULL
     AND    rgpv.RGD_CODE = decode(p_rgd_code,null,rgpv.RGD_CODE,p_rgd_code);

    --CURSOR to fetch contract header id
    CURSOR l_cle_csr (p_cle_id IN NUMBER) is
    select cleb.dnz_chr_id
    from   okc_k_lines_b cleb
    where  cleb.id       = p_cle_id;
    --BUG# 3562881 (END)


    l_rgpv_rec                 rgpv_rec_type;
    l_rgpv_tab                 rgpv_tbl_type;
    i                          NUMBER ;
    l_chr_id     NUMBER;
    l_cle_id     NUMBER;
    l_dnz_chr_id NUMBER;

  BEGIN
    i := 0;
    If p_chr_id is null and p_cle_id is not null Then

       --BUG# 3562881:
       l_dnz_chr_id := null;
       --get the contract header id
       open l_cle_csr (p_cle_id => p_cle_id);
       fetch l_cle_csr into l_dnz_chr_id;
       If l_cle_csr%NOTFOUND then
           NULL; --will not raise error as this api was not raising error prior to this fix
       End If;
       close l_cle_csr;
       l_cle_id     := p_cle_id;

       If l_dnz_chr_id is NOT NULL then
          -- Get current database values
           OPEN okc_cle_rgpv_csr (p_chr_id => l_dnz_chr_id,
                                  p_cle_id => l_cle_id,
                                  p_rgd_code => p_rgd_code);
           Loop
           FETCH okc_cle_rgpv_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
            Exit When okc_cle_rgpv_csr%NotFound;
            i := okc_cle_rgpv_csr%RowCount;
            l_rgpv_tab(i) := l_rgpv_rec;
          END Loop;
          CLOSE okc_cle_rgpv_csr;
        End If;

    Elsif p_chr_id is null and p_cle_id is null Then
       --BUG : 3562881
       --  error : blind query not allowed
       NULL; --not raising error here as this API does not raise error
    Elsif p_chr_id is not null and p_cle_id is null Then
       --BUG# 3562881
       l_chr_id := p_chr_id;
       -- Get current database values
       OPEN okc_chr_rgpv_csr (p_chr_id   => l_chr_id,
                              p_rgd_code => p_rgd_code);
       Loop
       FETCH okc_chr_rgpv_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
        Exit When okc_chr_rgpv_csr%NotFound;
        i := okc_chr_rgpv_csr%RowCount;
        l_rgpv_tab(i) := l_rgpv_rec;
        END Loop;
        CLOSE okc_chr_rgpv_csr;

    Elsif p_chr_id is not null and p_cle_id is not null Then
       --BUG# 3562881
       l_cle_id     := p_cle_id;
       l_dnz_chr_id := p_chr_id;
       -- Get current database values
       OPEN okc_cle_rgpv_csr (p_chr_id => l_dnz_chr_id,
                              p_cle_id => l_cle_id,
                              p_rgd_code => p_rgd_code);
       Loop
       FETCH okc_cle_rgpv_csr INTO
              l_rgpv_rec.ID,
              l_rgpv_rec.OBJECT_VERSION_NUMBER,
              l_rgpv_rec.SFWT_FLAG,
              l_rgpv_rec.RGD_CODE,
              l_rgpv_rec.SAT_CODE,
              l_rgpv_rec.RGP_TYPE,
              l_rgpv_rec.CLE_ID,
              l_rgpv_rec.CHR_ID,
              l_rgpv_rec.DNZ_CHR_ID,
              l_rgpv_rec.PARENT_RGP_ID,
              l_rgpv_rec.COMMENTS,
              l_rgpv_rec.ATTRIBUTE_CATEGORY,
              l_rgpv_rec.ATTRIBUTE1,
              l_rgpv_rec.ATTRIBUTE2,
              l_rgpv_rec.ATTRIBUTE3,
              l_rgpv_rec.ATTRIBUTE4,
              l_rgpv_rec.ATTRIBUTE5,
              l_rgpv_rec.ATTRIBUTE6,
              l_rgpv_rec.ATTRIBUTE7,
              l_rgpv_rec.ATTRIBUTE8,
              l_rgpv_rec.ATTRIBUTE9,
              l_rgpv_rec.ATTRIBUTE10,
              l_rgpv_rec.ATTRIBUTE11,
              l_rgpv_rec.ATTRIBUTE12,
              l_rgpv_rec.ATTRIBUTE13,
              l_rgpv_rec.ATTRIBUTE14,
              l_rgpv_rec.ATTRIBUTE15,
              l_rgpv_rec.CREATED_BY,
              l_rgpv_rec.CREATION_DATE,
              l_rgpv_rec.LAST_UPDATED_BY,
              l_rgpv_rec.LAST_UPDATE_DATE,
              l_rgpv_rec.LAST_UPDATE_LOGIN;
        Exit When okc_cle_rgpv_csr%NotFound;
        i := okc_cle_rgpv_csr%RowCount;
        l_rgpv_tab(i) := l_rgpv_rec;
        END Loop;
        CLOSE okc_cle_rgpv_csr;
    End If;

    x_rg_count      := i;
    RETURN(l_rgpv_tab);
END get_rgpv_tab;

begin
   --BUG# 3562881:
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
  --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);

 	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_rgpv_tbl := get_rgpv_tab(p_chr_id         => p_chr_id,
                               p_cle_id         => p_cle_id,
                               p_rgd_code       => p_rgd_code,
                               x_rg_count       => x_rg_count);
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

end Get_Contract_Rgs;
--Start of Comments
--Procedure    : Get Contract Rules
--Description  : Gets all or specific rules for a rule group id
-- End of Comments
Procedure Get_Contract_Rules(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2,
                             p_rgpv_rec       IN  rgpv_rec_type,
                             p_rdf_code       IN  VARCHAR2,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             x_rulv_tbl       OUT NOCOPY rulv_tbl_type,
                             x_rule_count     OUT NOCOPY NUMBER ) is


  l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RULES';
  l_api_version		               CONSTANT NUMBER	:= 1.0;
---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_RULES_V
---------------------------------------------------------------------------
  FUNCTION get_rulv_tab (
    p_rgpv_rec                     IN  rgpv_rec_type,
    p_rdf_code                     IN  VARCHAR2,
    x_Rule_Count                   OUT NOCOPY NUMBER
  ) RETURN rulv_tbl_type IS
    CURSOR okc_rulv_csr (p_rgp_id IN NUMBER,
                         p_rdf_code IN VARCHAR2) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            OBJECT1_ID1,
            OBJECT2_ID1,
            OBJECT3_ID1,
            OBJECT1_ID2,
            OBJECT2_ID2,
            OBJECT3_ID2,
            JTOT_OBJECT1_CODE,
            JTOT_OBJECT2_CODE,
            JTOT_OBJECT3_CODE,
            DNZ_CHR_ID,
            RGP_ID,
            PRIORITY,
            STD_TEMPLATE_YN,
            COMMENTS,
            WARN_YN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            --TEXT,
            RULE_INFORMATION_CATEGORY,
            RULE_INFORMATION1,
            RULE_INFORMATION2,
            RULE_INFORMATION3,
            RULE_INFORMATION4,
            RULE_INFORMATION5,
            RULE_INFORMATION6,
            RULE_INFORMATION7,
            RULE_INFORMATION8,
            RULE_INFORMATION9,
            RULE_INFORMATION10,
            RULE_INFORMATION11,
            RULE_INFORMATION12,
            RULE_INFORMATION13,
            RULE_INFORMATION14,
            RULE_INFORMATION15,
            TEMPLATE_YN,
            ans_set_jtot_object_code,
            ans_set_jtot_object_id1,
            ans_set_jtot_object_id2,
            DISPLAY_SEQUENCE
     FROM Okc_Rules_V
     WHERE okc_rules_v.rgp_id    = p_rgp_id
     AND   RULE_INFORMATION_CATEGORY = decode(p_rdf_code,null,RULE_INFORMATION_CATEGORY,p_rdf_code);
     l_rulv_rec                  rulv_rec_type;
     l_rulv_tab                  rulv_tbl_type;
     i                           NUMBER default 0;
  BEGIN

    -- Get current database values
    OPEN okc_rulv_csr (p_rgpv_rec.id,p_rdf_code);
    LOOP
    FETCH okc_rulv_csr INTO
                l_rulv_rec.ID,
              l_rulv_rec.OBJECT_VERSION_NUMBER,
              l_rulv_rec.SFWT_FLAG,
              l_rulv_rec.OBJECT1_ID1,
              l_rulv_rec.OBJECT2_ID1,
              l_rulv_rec.OBJECT3_ID1,
              l_rulv_rec.OBJECT1_ID2,
              l_rulv_rec.OBJECT2_ID2,
              l_rulv_rec.OBJECT3_ID2,
              l_rulv_rec.JTOT_OBJECT1_CODE,
              l_rulv_rec.JTOT_OBJECT2_CODE,
              l_rulv_rec.JTOT_OBJECT3_CODE,
              l_rulv_rec.DNZ_CHR_ID,
              l_rulv_rec.RGP_ID,
              l_rulv_rec.PRIORITY,
              l_rulv_rec.STD_TEMPLATE_YN,
              l_rulv_rec.COMMENTS,
              l_rulv_rec.WARN_YN,
              l_rulv_rec.ATTRIBUTE_CATEGORY,
              l_rulv_rec.ATTRIBUTE1,
              l_rulv_rec.ATTRIBUTE2,
              l_rulv_rec.ATTRIBUTE3,
              l_rulv_rec.ATTRIBUTE4,
              l_rulv_rec.ATTRIBUTE5,
              l_rulv_rec.ATTRIBUTE6,
              l_rulv_rec.ATTRIBUTE7,
              l_rulv_rec.ATTRIBUTE8,
              l_rulv_rec.ATTRIBUTE9,
              l_rulv_rec.ATTRIBUTE10,
              l_rulv_rec.ATTRIBUTE11,
              l_rulv_rec.ATTRIBUTE12,
              l_rulv_rec.ATTRIBUTE13,
              l_rulv_rec.ATTRIBUTE14,
              l_rulv_rec.ATTRIBUTE15,
              l_rulv_rec.CREATED_BY,
              l_rulv_rec.CREATION_DATE,
              l_rulv_rec.LAST_UPDATED_BY,
              l_rulv_rec.LAST_UPDATE_DATE,
              l_rulv_rec.LAST_UPDATE_LOGIN,
              --l_rulv_rec.TEXT,
              l_rulv_rec.RULE_INFORMATION_CATEGORY,
              l_rulv_rec.RULE_INFORMATION1,
              l_rulv_rec.RULE_INFORMATION2,
              l_rulv_rec.RULE_INFORMATION3,
              l_rulv_rec.RULE_INFORMATION4,
              l_rulv_rec.RULE_INFORMATION5,
              l_rulv_rec.RULE_INFORMATION6,
              l_rulv_rec.RULE_INFORMATION7,
              l_rulv_rec.RULE_INFORMATION8,
              l_rulv_rec.RULE_INFORMATION9,
              l_rulv_rec.RULE_INFORMATION10,
              l_rulv_rec.RULE_INFORMATION11,
              l_rulv_rec.RULE_INFORMATION12,
              l_rulv_rec.RULE_INFORMATION13,
              l_rulv_rec.RULE_INFORMATION14,
              l_rulv_rec.RULE_INFORMATION15,
              l_rulv_rec.TEMPLATE_YN,
              l_rulv_rec.ans_set_jtot_object_code,
              l_rulv_rec.ans_set_jtot_object_id1,
              l_rulv_rec.ans_set_jtot_object_id2,
              l_rulv_rec.DISPLAY_SEQUENCE ;
    EXIT When okc_rulv_csr%NOTFOUND;
      i := okc_rulv_csr%RowCount;
      l_rulv_tab(i) := l_rulv_rec;
    END LOOP;
    CLOSE okc_rulv_csr;
    x_rule_count := i;
    RETURN(l_rulv_tab);
  END get_rulv_tab;
BEGIN
  --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);

 	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   x_rulv_tbl := get_rulv_tab(p_rgpv_rec     => p_rgpv_rec,
                              p_rdf_code     => p_rdf_code,
                              x_Rule_Count   => x_rule_Count);
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

END Get_Contract_Rules;
-- Start of comments
--Procedure   : Get Rule Information
--Description : Fetches the display value (name) and select clause of the
--              rule information column in a rule if stored value(p_rule_info)
--              is provided else just returns the select clause
--              IN p_rdf_code      : rule_code
--                 p_appl_col_name : segment column name ('RULE_INFORMATION1',...)
--                 p_rule_info     : segment column value default Null
-- End of Comments
Procedure Get_rule_Information (p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2,
                                p_rdf_code       IN  VARCHAR2,
                                p_appl_col_name  IN  VARCHAR2,
                                p_rule_info      IN  VARCHAR2,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                x_name           OUT NOCOPY VARCHAR2,
                                x_select         OUT NOCOPY VARCHAR2) is

Cursor rule_dff_cur is
--  select dflex.descriptive_flex_context_code
--  ,      dflex.flex_value_set_id
--  from  fnd_descr_flex_col_usage_vl dflex
--  where  dflex.application_id=510
--  and   dflex.descriptive_flexfield_name='OKC Rule Developer DF'
--  and   dflex.descriptive_flex_context_code = p_rdf_code
--  and   dflex.application_column_name = p_appl_col_name
--code added for rule striping (remove top union when finalized)
--union
  select dflex.descriptive_flex_context_code
  ,      dflex.flex_value_set_id
  from  fnd_descr_flex_col_usage_vl dflex,
        okc_rule_defs_v             rdefv
  where  dflex.application_id               = rdefv.application_id
  and   dflex.descriptive_flexfield_name    = rdefv.descriptive_flexfield_name
  and   dflex.descriptive_flex_context_code = rdefv.rule_code
  and   dflex.application_column_name       = p_appl_col_name
  and   rdefv.rule_code                     = p_rdf_code
  order by dflex.descriptive_flex_context_code;
--  order by 1;
  rule_dff_rec rule_dff_cur%rowtype;
  l_object_code          varchar2(30);
  l_flex_value_set_id    Number;

Cursor flex_value_set_cur(p_flex_value_set_id IN Number) is
   Select validation_type
   from   fnd_flex_value_sets
   where  flex_value_set_id = p_flex_value_set_id;
flex_value_set_rec flex_value_set_cur%RowType;

Cursor flex_query_t_cur(p_flex_value_set_id NUMBER) is
     SELECT fvt.id_column_name,
            fvt.value_column_name,
            fvt.meaning_column_name,
            fvt.application_table_name,
            fvt.additional_where_clause,
            fvt.enabled_column_name,
            fvt.start_date_column_name,
            fvt.end_date_column_name
     FROM   fnd_flex_validation_tables fvt
     WHERE  fvt.flex_value_set_id = p_flex_value_set_id;
flex_query_t_rec flex_query_t_cur%rowtype;

type                         flex_val_curs_type is REF CURSOR;
flex_val_curs                flex_val_curs_type;
type flex_val_rec_type is record (val      Varchar2(100)  := OKL_API.G_MISS_CHAR,
                                  meaning  Varchar2(2000) := OKL_API.G_MISS_CHAR
								    );
flex_val_rec flex_val_rec_type;
l_query_string           varchar2(2000) default Null;
l_success                number;
l_mapping_code           Varchar2(10)   default null;
l_inc_user_where_clause  varchar2(1)    default 'N';
l_user_where_clause      varchar2(1000) default null;
l_select_clause          varchar2(2000) default null;
l_from_clause            varchar2(2000) default null;
l_where_clause           varchar2(2000) default null;
l_add_where_clause       varchar2(2000) default null;
l_order_by_clause        varchar2(2000) default null;

l_return_status		     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name			     CONSTANT VARCHAR2(30) := 'GET_CONTRACT_RULES';
l_api_version		     CONSTANT NUMBER	:= 1.0;
Begin
----
   --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Get metadata from fnd_flex_column_usages
    Open rule_dff_cur;
       Fetch rule_dff_cur into rule_dff_rec;
       If rule_dff_cur%NotFound Then
           --dbms_output.put_line('failed in select from fnd_descr_flex_col_usages');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_DFF_FETCH_FAILED,
				               p_token1       => G_APPLICATION_COL_TOKEN,
				               p_token1_value => p_appl_col_name,
                               p_token2       => G_RULE_CODE_TOKEN,
                               p_token2_value => p_rdf_code
				               );
          RAISE OKL_API.G_EXCEPTION_ERROR;
       Elsif rule_dff_rec.flex_value_set_id is null Then
          x_name := p_rule_info; -- no validation
       Elsif rule_dff_rec.flex_value_set_id is not null Then
          Open flex_value_set_cur(rule_dff_rec.flex_value_set_id);
          Fetch flex_value_set_cur into flex_value_set_rec;
          If flex_value_set_rec.validation_type = 'N' Then --No Validation
             x_name := p_rule_info;
          Elsif flex_value_set_rec.validation_type in ('I') Then --Independent
            If p_rule_info is Not Null Then
               l_inc_user_where_clause := 'Y';
               l_user_where_clause     := ' flex_value = '||''''||p_rule_info||'''';
            End If;
            fnd_flex_val_api.get_independent_vset_select(p_value_set_id          => rule_dff_rec.flex_value_set_id,
                                                         p_inc_id_col            => 'N',
                                                         p_inc_user_where_clause => l_inc_user_where_clause,
                                                         p_user_where_clause     => l_user_where_clause,
                                                         x_select                => l_query_string,
                                                         x_mapping_code          => l_mapping_code,
                                                         x_success               => l_success);
          Elsif flex_value_set_rec.validation_type in ('D') Then --Dependent
          If p_rule_info is Not Null Then
            l_inc_user_where_clause := 'Y';
            l_user_where_clause     := ' flex_value = '||''''||p_rule_info||'''';
          End If;
          fnd_flex_val_api.get_dependent_vset_select(  p_value_set_id          => rule_dff_rec.flex_value_set_id,
                                                       p_inc_id_col            => 'N',
                                                       p_inc_user_where_clause => l_inc_user_where_clause,
                                                       p_user_where_clause     => l_user_where_clause,
                                                       x_select                => l_query_string,
                                                       x_mapping_code          => l_mapping_code,
                                                       x_success               => l_success);
          Elsif flex_value_set_rec.validation_type in ('F') Then --Table
            Open flex_query_t_cur(rule_dff_rec.flex_value_set_id);
                Fetch flex_query_t_cur into flex_query_t_rec;
                If flex_query_t_cur%NotFound Then
                   --dbms_output.put_line('DFF type : failed to fetch table validated query');
                   --Null;--raise appropriate exception
                    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				                        p_msg_name     => G_DFF_TABLE_QUERY_FAILED,
				                        p_token1       => G_APPLICATION_COL_TOKEN,
				                        p_token1_value => p_appl_col_name,
                                        p_token2       => G_RULE_CODE_TOKEN,
                                        p_token2_value => p_rdf_code);
                Else
                --For Rules always use id col
				   If flex_query_t_rec.id_column_name is null Then
                      l_select_clause := ' SELECT '||l_select_clause||' '||flex_query_t_rec.value_column_name||' , ';
                   Else
                      l_select_clause := ' SELECT '||l_select_clause||' '||flex_query_t_rec.id_column_name||' , ';
                   End If;
                --For Rules always use  id col and value column
                   l_select_clause := l_select_clause||' '||flex_query_t_rec.value_column_name;
                   l_from_clause  := ' FROM '||l_from_clause||flex_query_t_rec.application_table_name||' ';
                   l_where_clause := ' WHERE '||l_where_clause||' '||flex_query_t_rec.enabled_column_name||' = ';
                   l_where_clause := l_where_clause||' '||''''||'Y'||'''';
                   l_where_clause := l_where_clause||' AND ';
                   l_where_clause := l_where_clause||' nvl('||flex_query_t_rec.start_date_column_name||',sysdate) <= sysdate';
                   l_where_clause := l_where_clause||' AND ';
                   l_where_clause := l_where_clause||' nvl('||flex_query_t_rec.end_date_column_name||',sysdate+1) > sysdate';
                   --add user where clause
                   If p_rule_info is not null then
                      l_where_clause := l_where_clause||' AND '||flex_query_t_rec.id_column_name||' = '||''''||p_rule_info||'''';
                   End If;

                   If flex_query_t_rec.additional_where_clause is null Then
                      Null;
                   Else
                      flex_query_t_rec.additional_where_clause:= REPLACE(upper(flex_query_t_rec.additional_where_clause),'WHERE',' ');
                      --dbms_output.put_line('additional where :'||flex_query_t_rec.additional_where_clause);
                      l_add_where_clause := null;
                      select l_where_clause||' '||decode(l_where_clause,null,' ',decode(instr(ltrim(flex_query_t_rec.additional_where_clause,' '),'ORDER BY'),1,' ',' AND '))||flex_query_t_rec.additional_where_clause
                      into   l_add_where_clause from dual;
                      l_where_clause := l_add_where_clause;
                   End If;
                   l_query_string          := rtrim(ltrim(l_select_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_from_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_where_clause,' '),' ')||' '||
                                              rtrim(ltrim(l_order_by_clause,' '),' ');
             End If;
             Close flex_query_t_cur;
           End If;
        Close flex_value_set_cur;
        End If;
        If l_query_string is not null  and
           p_rule_info is not null then
           --dbms_output.put_line(l_query_string);
           Open flex_val_curs for l_query_string;
               Fetch flex_val_curs into flex_val_rec;
               If flex_val_curs%NotFound Then
                  --dbms_output.put_line('Flex Value not Found for column name "'||p_appl_col_name||'"');
                  OKL_API.SET_MESSAGE(p_app_name       => g_app_name,
				                        p_msg_name     => G_DFF_VSET_QUERY_FAILED,
				                        p_token1       => G_APPLICATION_COL_TOKEN,
				                        p_token1_value => p_appl_col_name,
                                        p_token2       => G_RULE_CODE_TOKEN,
                                        p_token2_value => p_rdf_code);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
               Else
                  x_name := flex_val_rec.meaning;
               End If;
           Close flex_val_curs;
        End If;
        x_select := l_query_string;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
    EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

End Get_Rule_Information;
-- Start of comments
--Procedure   : Get_jtot_object
--Description : Fetches the display values (name,description)  and additional
--              columns status, start_date, end_date, org_id, inv_org_id,
--              book_type_code, if present if id1 and id2 are given
--              Also returns the select clause associated with the jtf_object
-- End of Comments
Procedure Get_jtot_object(p_api_version     IN  NUMBER,
                          p_init_msg_list   IN  VARCHAR2,
                          p_object_code     IN  VARCHAR2,
                          p_id1             IN  VARCHAR2,
                          p_id2             IN  VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_id1             OUT NOCOPY VARCHAR2,
                          x_id2             OUT NOCOPY VARCHAR2,
                          x_name            OUT NOCOPY VARCHAR2,
                          x_description     OUT NOCOPY VARCHAR2,
                          x_status          OUT NOCOPY VARCHAR2,
                          x_start_date      OUT NOCOPY DATE,
                          x_end_date        OUT NOCOPY DATE,
                          x_org_id          OUT NOCOPY NUMBER,
                          x_inv_org_id      OUT NOCOPY NUMBER,
                          x_book_type_code  OUT NOCOPY VARCHAR2,
                          x_select          OUT NOCOPY VARCHAR2) is

  l_return_status		      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name			      CONSTANT VARCHAR2(30) := 'GET_JTOT_OBJECT';
  l_api_version		          CONSTANT NUMBER	:= 1.0;

  l_select_clause             Varchar2(2000) default Null;
  l_from_clause               Varchar2(2000) default Null;
  l_where_clause              Varchar2(2000) default Null;
  l_order_by_clause           Varchar2(2000) default Null;
  l_query_string              VARCHAR2(2000) default Null;
  l_from_table                VARCHAR2(200)  default Null;

  Cursor jtf_obj_curs is
  Select job.from_table from_table,
         ' FROM '||job.from_table from_clause,
         decode(where_clause,null,null,' WHERE ')||job.where_clause where_clause,
         decode(order_by_clause,null,null,' ORDER BY ')||job.order_by_clause order_by_clause
  From   jtf_objects_vl job
  Where  job.object_code = p_object_code
  And    nvl(job.start_date_active,sysdate) <= sysdate
  And    nvl(job.end_date_active,sysdate+1) > sysdate;

  Cursor check_col_curs(p_table_name IN Varchar2,p_col_name IN Varchar2) is
  Select 'Y'
  From   dba_tab_columns
  Where  table_name =  p_table_name
  And    column_name = p_col_name
  -----------------
  --Bug# 3431854 :
  -----------------
  And    owner      = USER;

  l_col_exists Varchar2(1)  default 'N';
  l_table_name Varchar2(30) default Null;
  l_col_name   Varchar2(30) default Null;

  Type jtot_ref_curs_type is REF CURSOR;
  jtot_ref_curs jtot_ref_curs_type;

Begin
   --Bug# 3024752:
   --If okc_context.get_okc_organization_id  is null then
      --okc_context.set_okc_org_context(204,204);
   --End If;
 --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  Open jtf_obj_curs;
    Fetch jtf_obj_curs into l_from_table, l_from_clause, l_where_clause, l_order_by_clause;
    If jtf_obj_curs%NotFound Then
       --dbms_output.put_line('jtf object not found for object code "'||p_object_code||'"');
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     =>G_JTF_OBJECT_QUERY_FAILED,
                           p_token1       =>G_JTF_OBJECT_TOKEN ,
                           p_token1_value => p_object_code);
          RAISE OKL_API.G_EXCEPTION_ERROR;
    Else
      -- Bug# 3838403 - Remove table alias from select clause to handle
      -- objects not having table alias.
      l_select_clause := 'SELECT ID1,ID2,NAME,DESCRIPTION';
       --get okx view table name

       -- Bug# 3838403 - Append space to l_from_table in instr call
       -- to handle table names with no alias
       l_table_name := upper(substr(l_from_table,1,instr(l_from_table||' ',' ',1)));

       --Bug# 3431854 :
       l_table_name := ltrim(rtrim(l_table_name,' '),' ');
       --chek for presense of columns
       -- as all columns may not exist in OKX View
       for i in 1..6
       loop
          l_col_exists := 'N';
          l_col_name := null;
          If i = 1 Then
             l_col_name := 'STATUS';
          Elsif i = 2 Then
             l_col_name := 'START_DATE_ACTIVE';
          Elsif i = 3 Then
             l_col_name := 'END_DATE_ACTIVE';
          Elsif i = 4 Then
             l_col_name := 'ORG_ID';
          Elsif i = 5 Then
             l_col_name := 'INV_ORG_ID';
          Elsif i = 6 Then
             l_col_name := 'BOOK_TYPE_CODE';
          End If;
          open check_col_curs(l_table_name,l_col_name);
               Fetch check_col_curs into l_col_exists;
               If    check_col_curs%NotFound --l_col_exist is 'N' column does not exist
               Then
                    If  i in (1,2,3,6) Then
                       l_select_clause := l_select_clause||','||'null';
                    elsif i in (4,5) Then
                       l_select_clause := l_select_clause||','||'to_number(null)';
                    end if;
               Else
                   l_select_clause := l_select_clause||','||l_col_name;
               End If;
          Close check_col_curs;
       End Loop;
       -- Add p_id1 and p_id2 to the where clause
       If p_id1 is not null and p_id2 is not null Then

          -- Bug# 3838403 - Remove table alias from where clause to handle
          -- objects not having table alias.
          If l_where_clause is null Then
             l_where_clause := ' WHERE ID1 ='||''''||p_id1||''''||
                               ' AND ID2 ='||''''||p_id2||'''';
          Else
             l_where_clause := l_where_clause||
                               ' AND ID1 ='||''''||p_id1||''''||
                               ' AND ID2 ='||''''||p_id2||'''';
          End If;
       End If;
       -- compose sql query for jtot object
       l_query_string := ltrim(rtrim(l_select_clause,' '),' ')||' '||
                         ltrim(rtrim(l_from_clause,' '),' ')||' '||
                         ltrim(rtrim(l_where_clause,' '),' ')||' '||
                         ltrim(rtrim(l_order_by_clause,' '),' ');
       --dbms_output.put_line(l_where_clause);
       x_select := l_query_string;
       --execute sql query to get values
       If p_id1 is not null and p_id2 is not null Then
          open  jtot_ref_curs for l_query_string;
          Fetch jtot_ref_curs into x_id1,
                                  x_id2,
                                  x_name,
                                  x_description,
                                  x_status,
                                  x_start_date,
                                  x_end_date,
                                  x_org_id,
                                  x_inv_org_id,
                                  x_book_type_code;
          If jtot_ref_curs%notfound Then
             --dbms_output.put_line('Not able to fetch ref cursor record using jtot query string');
             null;--handle appropriate exception here
          End If;
          Close jtot_ref_curs;
       End If;
    End If;
    Close jtf_obj_curs;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

End Get_jtot_object;

--Start of Comments
--Procedure    : Get_Rule_disp_value
--Description  : Fetches the displayed values of rule segments
--End of Comments
Procedure Get_Rule_disp_value    (p_api_version    IN  NUMBER,
                                  p_init_msg_list  IN  VARCHAR2,
                                  p_rulv_rec       IN Rulv_rec_type,
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_msg_count      OUT NOCOPY NUMBER,
                                  x_msg_data       OUT NOCOPY VARCHAR2,
                                  x_rulv_disp_rec  OUT  NOCOPY rulv_disp_rec_type) is

l_return_status		      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name			      CONSTANT VARCHAR2(30) := 'GET_RULE_DISP_VALUE';
l_api_version		      CONSTANT NUMBER	:= 1.0;

l_rulv_disp_rec rulv_disp_rec_type;
l_name        Varchar2(500) default null;
l_description Varchar2(2000) default null;
l_status      Varchar2(30) default null;
l_start_date  date default null;
l_end_date    date default null;
l_org_id      Number;
l_inv_org_id  Number;
l_book_type_code Varchar2(30) default null;
l_select        Varchar2(2000) default null;
l_id1           Varchar2(40) default Null;
l_id2           Varchar2(200) default Null;

begin
    --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_rulv_disp_rec.id       := p_rulv_rec.id;
    l_rulv_disp_rec.rdf_code := p_rulv_rec.rule_information_category;

    If p_rulv_rec.jtot_object1_code is not null then
      l_id1  := null;
      l_id2 := null;
      l_name := null;
      l_description := null;
      l_status := null;
      l_start_date := null;
      l_end_date := null;
      l_org_id   := to_number(null);
      l_inv_org_id := to_number(null);
      l_book_type_code := null;
      l_select := null;

      Get_jtot_object(p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      p_object_code    => p_rulv_rec.jtot_object1_code,
                      p_id1            => p_rulv_rec.object1_id1,
                      p_id2            => p_rulv_rec.object1_id2,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      x_id1            => l_id1,
                      x_id2            => l_id2,
                      x_name           => l_name,
                      x_description    => l_description,
                      x_status         => l_status,
                      x_start_date     => l_start_date,
                      x_end_date       => l_end_date,
                      x_org_id         => l_org_id,
                      x_inv_org_id     => l_inv_org_id,
                      x_book_type_code => l_book_type_code,
                      x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.obj1_name           := l_name;
         l_rulv_disp_rec.obj1_descr          := l_description;
         l_rulv_disp_rec.obj1_status         := l_status;
         l_rulv_disp_rec.obj1_start_date     := l_start_date;
         l_rulv_disp_rec.obj1_end_date       := l_end_date;
         l_rulv_disp_rec.obj1_org_id         := l_org_id;
         l_rulv_disp_rec.obj1_inv_org_id     := l_inv_org_id;
         l_rulv_disp_rec.obj1_book_type_code := l_book_type_code;
         l_rulv_disp_rec.obj1_select         := l_select;
         --dbms_output.put_line('Name '||l_name);
    End If;

    If p_rulv_rec.jtot_object2_code is not null then
      l_id1  := null;
      l_id2 := null;
      l_name := null;
      l_description := null;
      l_status := null;
      l_start_date := null;
      l_end_date := null;
      l_org_id   := to_number(null);
      l_inv_org_id := to_number(null);
      l_book_type_code := null;
      l_select := null;

      Get_jtot_object(p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      p_object_code    => p_rulv_rec.jtot_object2_code,
                      p_id1            => p_rulv_rec.object2_id1,
                      p_id2            => p_rulv_rec.object2_id2,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      x_id1            => l_id1,
                      x_id2            => l_id2,
                      x_name           => l_name,
                      x_description    => l_description,
                      x_status         => l_status,
                      x_start_date     => l_start_date,
                      x_end_date       => l_end_date,
                      x_org_id         => l_org_id,
                      x_inv_org_id     => l_inv_org_id,
                      x_book_type_code => l_book_type_code,
                      x_select         => l_select);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.obj2_name           := l_name;
         l_rulv_disp_rec.obj2_descr          := l_description;
         l_rulv_disp_rec.obj2_status         := l_status;
         l_rulv_disp_rec.obj2_start_date     := l_start_date;
         l_rulv_disp_rec.obj2_end_date       := l_end_date;
         l_rulv_disp_rec.obj2_org_id         := l_org_id;
         l_rulv_disp_rec.obj2_inv_org_id     := l_inv_org_id;
         l_rulv_disp_rec.obj2_book_type_code := l_book_type_code;
         l_rulv_disp_rec.obj2_select         := l_select;
         --dbms_output.put_line('Name '||l_name);
    End If;

    If p_rulv_rec.jtot_object3_code is not null then
      l_id1  := null;
      l_id2 := null;
      l_name := null;
      l_description := null;
      l_status := null;
      l_start_date := null;
      l_end_date := null;
      l_org_id   := to_number(null);
      l_inv_org_id := to_number(null);
      l_book_type_code := null;
      l_select := null;

      Get_jtot_object(p_api_version    => p_api_version,
                      p_init_msg_list  => p_init_msg_list,
                      p_object_code    => p_rulv_rec.jtot_object3_code,
                      p_id1            => p_rulv_rec.object3_id1,
                      p_id2            => p_rulv_rec.object3_id2,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      x_id1            => l_id1,
                      x_id2            => l_id2,
                      x_name           => l_name,
                      x_description    => l_description,
                      x_status         => l_status,
                      x_start_date     => l_start_date,
                      x_end_date       => l_end_date,
                      x_org_id         => l_org_id,
                      x_inv_org_id     => l_inv_org_id,
                      x_book_type_code => l_book_type_code,
                      x_select         => l_select);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.obj3_name           := l_name;
         l_rulv_disp_rec.obj3_descr          := l_description;
         l_rulv_disp_rec.obj3_status         := l_status;
         l_rulv_disp_rec.obj3_start_date     := l_start_date;
         l_rulv_disp_rec.obj3_end_date       := l_end_date;
         l_rulv_disp_rec.obj3_org_id         := l_org_id;
         l_rulv_disp_rec.obj3_inv_org_id     := l_inv_org_id;
         l_rulv_disp_rec.obj3_book_type_code := l_book_type_code;
         l_rulv_disp_rec.obj3_select         := l_select;
         --dbms_output.put_line('Name '||l_name);
         --all the jtots done now reinitialize the columns
         l_id1  := null;
         l_id2 := null;
         l_name := null;
         l_description := null;
         l_status := null;
         l_start_date := null;
         l_end_date := null;
         l_org_id   := to_number(null);
         l_inv_org_id := to_number(null);
         l_book_type_code := null;
        l_select := null;
    End If;

    If   p_rulv_rec.rule_information1 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION1',
                                p_rule_info      => p_rulv_rec.rule_information1,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info1_name   := l_name;
         l_rulv_disp_rec.rul_info1_select := l_select;
    End If;

    If   p_rulv_rec.rule_information2 is not null then
          l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION2',
                                p_rule_info      => p_rulv_rec.rule_information2,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info2_name   := l_name;
         l_rulv_disp_rec.rul_info2_select := l_select;
    End If;

    If   p_rulv_rec.rule_information3 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION3',
                                p_rule_info      => p_rulv_rec.rule_information3,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info3_name   := l_name;
         l_rulv_disp_rec.rul_info3_select := l_select;
    End If;
    If   p_rulv_rec.rule_information4 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION4',
                                p_rule_info      => p_rulv_rec.rule_information4,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info4_name   := l_name;
         l_rulv_disp_rec.rul_info4_select := l_select;
    End If;
    If   p_rulv_rec.rule_information5 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION5',
                                p_rule_info      => p_rulv_rec.rule_information5,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info5_name   := l_name;
         l_rulv_disp_rec.rul_info5_select := l_select;
    End If;
    If   p_rulv_rec.rule_information6 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION6',
                                p_rule_info      => p_rulv_rec.rule_information6,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info6_name   := l_name;
         l_rulv_disp_rec.rul_info6_select := l_select;
    End If;
    If   p_rulv_rec.rule_information7 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION7',
                                p_rule_info      => p_rulv_rec.rule_information7,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info7_name   := l_name;
         l_rulv_disp_rec.rul_info7_select := l_select;
    End If;
    If   p_rulv_rec.rule_information8 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION8',
                                p_rule_info      => p_rulv_rec.rule_information8,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info8_name   := l_name;
         l_rulv_disp_rec.rul_info8_select := l_select;
    End If;
    If   p_rulv_rec.rule_information9 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION9',
                                p_rule_info      => p_rulv_rec.rule_information9,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info9_name   := l_name;
         l_rulv_disp_rec.rul_info9_select := l_select;
    End If;
    If   p_rulv_rec.rule_information10 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION10',
                                p_rule_info      => p_rulv_rec.rule_information10,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info10_name   := l_name;
         l_rulv_disp_rec.rul_info10_select := l_select;
    End If;
    If   p_rulv_rec.rule_information11 is not null then
    l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION11',
                                p_rule_info      => p_rulv_rec.rule_information11,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info11_name   := l_name;
         l_rulv_disp_rec.rul_info11_select := l_select;
    End If;
    If   p_rulv_rec.rule_information12 is not null then
          l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION12',
                                p_rule_info      => p_rulv_rec.rule_information12,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info12_name   := l_name;
         l_rulv_disp_rec.rul_info12_select := l_select;

    End If;
    If   p_rulv_rec.rule_information13 is not null then
    l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION13',
                                p_rule_info      => p_rulv_rec.rule_information13,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info13_name   := l_name;
         l_rulv_disp_rec.rul_info13_select := l_select;
    End If;
    If  p_rulv_rec.rule_information14 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION14',
                                p_rule_info      => p_rulv_rec.rule_information14,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info14_name   := l_name;
         l_rulv_disp_rec.rul_info14_select := l_select;
    End If;
    If   p_rulv_rec.rule_information15 is not null then
         l_name := null;
         l_select := null;
         Get_rule_Information  (p_api_version     => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                p_rdf_code       => p_rulv_rec.rule_information_category,
                                p_appl_col_name  => 'RULE_INFORMATION15',
                                p_rule_info      => p_rulv_rec.rule_information15,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                x_name           => l_name,
                                x_select         => l_select);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

         l_rulv_disp_rec.rul_info15_name   := l_name;
         l_rulv_disp_rec.rul_info15_select := l_select;
    End If;
    x_rulv_disp_rec := l_rulv_disp_rec;

    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

End Get_Rule_Disp_Value;
--Start of Comments
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires exact screen prompt label of the segment
--               to be passed as p_rdf_name
--End of Comments
Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_rdf_name        IN  VARCHAR2,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2) is

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_SEGMENT_VALUE';
    l_api_version		           CONSTANT NUMBER	:= 1.0;

    l_rgpv_tbl                     rgpv_tbl_type;
    l_rulv_tbl                     rulv_tbl_type;
    l_rgpv_rec                     rgpv_rec_type;
    l_rulv_rec                     rulv_rec_type;

    l_rg_count                     NUMBER;
    l_rule_count                   NUMBER;

    Cursor rule_dff_app_col_cur is
--    select dflex.descriptive_flex_context_code
--    ,      dflex.application_column_name
--    from   fnd_descr_flex_col_usage_vl dflex
--    where  dflex.application_id=510
--    and    dflex.descriptive_flexfield_name='OKC Rule Developer DF'
--    and    dflex.descriptive_flex_context_code = p_rdf_code
--    and    dflex.form_left_prompt = p_rdf_name
--union
--added for rule striping (once finalized remove the top portion of union)
    Select dflex.descriptive_flex_context_code
    ,      dflex.application_column_name
    from   fnd_descr_flex_col_usage_vl dflex,
           okc_rule_defs_v             rdefv
    where  dflex.application_id                = rdefv.application_id
    and    dflex.descriptive_flexfield_name    = rdefv.descriptive_flexfield_name
    and    dflex.descriptive_flex_context_code = rdefv.rule_code
    and    dflex.form_left_prompt              = p_rdf_name
    and    rdefv.rule_code                     = p_rdf_code
--    order by 1;
    order by dflex.descriptive_flex_context_code;

     rule_dff_app_col_rec rule_dff_app_col_cur%rowtype;
Begin
    --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --get rule group record for the rgd code
    Get_Contract_Rgs(p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     p_chr_id		  => p_chr_id,
                     p_cle_id         => p_cle_id,
                     p_rgd_code       => p_rgd_code,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     x_rgpv_tbl       => l_rgpv_tbl,
                     x_rg_count       => l_rg_count);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    if l_rgpv_tbl.FIRST is null Then
       x_name := NULL;
    Else
    l_rgpv_rec := l_rgpv_tbl(1);

    --get rule record for rdf_code
    Get_Contract_Rules(p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       p_rgpv_rec       => l_rgpv_rec,
                       p_rdf_code       => p_rdf_code,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_rulv_tbl       => l_rulv_tbl,
                       x_rule_count     => l_rule_count);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    If l_rulv_tbl.FIRST is null Then
        x_name := Null;
    Else
    l_rulv_rec := l_rulv_tbl(1);

    --bug# 3024752 :
    If okl_context.get_okc_organization_id  is null then
       okl_context.set_okc_org_context(p_chr_id => l_rulv_rec.dnz_chr_id);
    End If;

    Open rule_dff_app_col_cur;
        Fetch rule_dff_app_col_cur into rule_dff_app_col_rec;
        If rule_dff_app_col_cur%NOTFOUND Then
           --dbms_output.put_line('failed in select from fnd_descr_flex_col_usages');
           OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
				               p_msg_name     => G_DFF_FETCH_FAILED,
				               p_token1       => G_APPLICATION_COL_TOKEN,
				               p_token1_value => p_rdf_name,
                               p_token2       => G_RULE_CODE_TOKEN,
                               p_token2_value => p_rdf_code
				               );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION1'
            and l_rulv_rec.RULE_INFORMATION1 is not Null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION1,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION2'
        and l_rulv_rec.RULE_INFORMATION2 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION2,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION3'
        and l_rulv_rec.RULE_INFORMATION3 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION3,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION4'
        and l_rulv_rec.RULE_INFORMATION4 is not null  Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION4,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION5'
        and   l_rulv_rec.RULE_INFORMATION5 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION5,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION6'
        and l_rulv_rec.RULE_INFORMATION6 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION6,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION7'
        and l_rulv_rec.RULE_INFORMATION7 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION7,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION8'
       and l_rulv_rec.RULE_INFORMATION8 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION8,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION9'
       and l_rulv_rec.RULE_INFORMATION9 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION9,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION10'
       and l_rulv_rec.RULE_INFORMATION10 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION10,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION11'
       and l_rulv_rec.RULE_INFORMATION11 is not Null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION11,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION12'
       and l_rulv_rec.RULE_INFORMATION12 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION12,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION13'
       and l_rulv_rec.RULE_INFORMATION13 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION13,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION14'
       and l_rulv_rec.RULE_INFORMATION14 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION14,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'RULE_INFORMATION15'
       and l_rulv_rec.RULE_INFORMATION15 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => rule_dff_app_col_rec.application_column_name,
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION15,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'JTOT_OBJECT1_CODE'
       and l_rulv_rec.object1_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object1_code,
                             p_id1            => l_rulv_rec.object1_id1,
                             p_id2            => l_rulv_rec.object1_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'JTOT_OBJECT2_CODE'
       and   l_rulv_rec.object2_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object2_code,
                             p_id1            => l_rulv_rec.object2_id1,
                             p_id2            => l_rulv_rec.object2_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       Elsif rule_dff_app_col_rec.application_column_name = 'JTOT_OBJECT3_CODE'
       and l_rulv_rec.object3_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object3_code,
                             p_id1            => l_rulv_rec.object3_id1,
                             p_id2            => l_rulv_rec.object3_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       End If;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    Close rule_dff_app_col_cur;
    End If;
    End If;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_Rule_Segment_Value;
--Start of Comments
--Bug#2525946   : overloaded to take rule segment numbers as input
--Procedure    : Get_Rule_Segment_value
--Description  : Fetches the displayed value and select clauses of
--               of specific rule segment.
--Note         : This API requires segment number
--               Segment number 1 to 15 are mapped to RULE_INFORMATION1 to
--               RULE_INFORMATION15. Segment Numbers 16, 17 and 18 are mapped
--               to jtot_object1, jtot_object2 and jtot_object3 respectively
--End of Comments
Procedure Get_rule_Segment_Value(p_api_version     IN  NUMBER,
                                 p_init_msg_list   IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 p_chr_id          IN  NUMBER,
                                 p_cle_id          IN  NUMBER,
                                 p_rgd_code        IN  VARCHAR2,
                                 p_rdf_code        IN  VARCHAR2,
                                 p_segment_number  IN  NUMBER,
                                 x_id1             OUT NOCOPY VARCHAR2,
                                 x_id2             OUT NOCOPY VARCHAR2,
                                 x_name            OUT NOCOPY VARCHAR2,
                                 x_description     OUT NOCOPY VARCHAR2,
                                 x_status          OUT NOCOPY VARCHAR2,
                                 x_start_date      OUT NOCOPY DATE,
                                 x_end_date        OUT NOCOPY DATE,
                                 x_org_id          OUT NOCOPY NUMBER,
                                 x_inv_org_id      OUT NOCOPY NUMBER,
                                 x_book_type_code  OUT NOCOPY VARCHAR2,
                                 x_select          OUT NOCOPY VARCHAR2) is

    l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name			           CONSTANT VARCHAR2(30) := 'GET_RULE_SEGMENT_VALUE';
    l_api_version		           CONSTANT NUMBER	:= 1.0;

    l_rgpv_tbl                     rgpv_tbl_type;
    l_rulv_tbl                     rulv_tbl_type;
    l_rgpv_rec                     rgpv_rec_type;
    l_rulv_rec                     rulv_rec_type;

    l_rg_count                     NUMBER;
    l_rule_count                   NUMBER;

Begin
    --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --get rule group record for the rgd code
    Get_Contract_Rgs(p_api_version    => p_api_version,
                     p_init_msg_list  => p_init_msg_list,
                     p_chr_id		  => p_chr_id,
                     p_cle_id         => p_cle_id,
                     p_rgd_code       => p_rgd_code,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data,
                     x_rgpv_tbl       => l_rgpv_tbl,
                     x_rg_count       => l_rg_count);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    if l_rgpv_tbl.FIRST is null Then
       x_name := NULL;
    Else
    l_rgpv_rec := l_rgpv_tbl(1);

    --get rule record for rdf_code
    Get_Contract_Rules(p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       p_rgpv_rec       => l_rgpv_rec,
                       p_rdf_code       => p_rdf_code,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_rulv_tbl       => l_rulv_tbl,
                       x_rule_count     => l_rule_count);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    If l_rulv_tbl.FIRST is null Then
        x_name := Null;
    Else
    l_rulv_rec := l_rulv_tbl(1);

    --bug# 3024752 :
    If okl_context.get_okc_organization_id  is null then
       okl_context.set_okc_org_context(p_chr_id => l_rulv_rec.dnz_chr_id);
    End If;


        if p_segment_number = 1
            and l_rulv_rec.RULE_INFORMATION1 is not Null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION1',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION1,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif p_segment_number = 2
        and l_rulv_rec.RULE_INFORMATION2 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION2',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION2,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif p_segment_number = 3
        and l_rulv_rec.RULE_INFORMATION3 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION3',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION3,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif  p_segment_number = 4
        and l_rulv_rec.RULE_INFORMATION4 is not null  Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION4',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION4,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif  p_segment_number = 5
        and   l_rulv_rec.RULE_INFORMATION5 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION5',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION5,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif p_segment_number = 6
        and l_rulv_rec.RULE_INFORMATION6 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION6',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION6,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
        Elsif p_segment_number = 7
        and l_rulv_rec.RULE_INFORMATION7 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION7',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION7,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 8
       and l_rulv_rec.RULE_INFORMATION8 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION8',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION8,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 9
       and l_rulv_rec.RULE_INFORMATION9 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION9',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION9,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 10
       and l_rulv_rec.RULE_INFORMATION10 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION10',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION10,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 11
       and l_rulv_rec.RULE_INFORMATION11 is not Null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION11',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION11,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 12
       and l_rulv_rec.RULE_INFORMATION12 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION12',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION12,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 13
       and l_rulv_rec.RULE_INFORMATION13 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION13',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION13,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 14
       and l_rulv_rec.RULE_INFORMATION14 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION14',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION14,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 15
       and l_rulv_rec.RULE_INFORMATION15 is not null Then
            Get_rule_Information (p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  p_rdf_code       => p_rdf_code,
                                  p_appl_col_name  => 'RULE_INFORMATION15',
                                  p_rule_info      => l_rulv_rec.RULE_INFORMATION15,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  x_name           => x_name,
                                  x_select         => x_select);
       Elsif p_segment_number = 16
       and l_rulv_rec.object1_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object1_code,
                             p_id1            => l_rulv_rec.object1_id1,
                             p_id2            => l_rulv_rec.object1_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       Elsif p_segment_number = 17
       and   l_rulv_rec.object2_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object2_code,
                             p_id1            => l_rulv_rec.object2_id1,
                             p_id2            => l_rulv_rec.object2_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       Elsif p_segment_number = 18
       and l_rulv_rec.object3_id1 is not null Then
             Get_jtot_object(p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             p_object_code    => l_rulv_rec.jtot_object3_code,
                             p_id1            => l_rulv_rec.object3_id1,
                             p_id2            => l_rulv_rec.object3_id2,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             x_id1            => x_id1,
                             x_id2            => x_id2,
                             x_name           => x_name,
                             x_description    => x_description,
                             x_status         => x_status,
                             x_start_date     => x_start_date,
                             x_end_date       => x_end_date,
                             x_org_id         => x_org_id,
                             x_inv_org_id     => x_inv_org_id,
                             x_book_type_code => x_book_type_code,
                             x_select         => x_select);
       End If;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    End If;
    End If;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
   when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
End Get_Rule_Segment_Value;
End OKL_RULE_APIS_PVT;

/
