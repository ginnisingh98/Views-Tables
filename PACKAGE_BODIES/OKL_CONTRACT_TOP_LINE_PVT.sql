--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_TOP_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_TOP_LINE_PVT" as
 /* $Header: OKLRKTLB.pls 120.10.12010000.2 2009/06/11 04:27:57 rpillay ship $ */

-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  G_API_TYPE		      CONSTANT VARCHAR2(4)   := '_PVT';
  G_INVALID_NO_OF_PAYMENTS    CONSTANT VARCHAR2(200) := 'OKL_INVALID_NO_OF_PAYMNTS';
  G_FT_FINANCED		      CONSTANT VARCHAR2(200) := 'FINANCED';
  G_FT_ABSORBED		      CONSTANT VARCHAR2(200) := 'ABSORBED';

  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	SELECT a.attribute_label_long
	FROM ak_region_items ri, AK_REGIONS r, AK_ATTRIBUTES_vL a
	WHERE ri.region_code = r.region_code
	AND ri.attribute_code = a.attribute_code
	AND ri.region_code  =  p_ak_region
	AND ri.attribute_code = p_ak_attribute;

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	return(l_ak_prompt);
  END;

-- Start of comments
--
-- Procedure Name  : create_contract_link_serv
-- Description     : link service contract to lease
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_contract_link_serv (
            p_api_version    		IN  NUMBER,
            p_init_msg_list  		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  		OUT NOCOPY VARCHAR2,
            x_msg_count      		OUT NOCOPY NUMBER,
            x_msg_data       		OUT NOCOPY VARCHAR2,
            p_chr_id			IN  NUMBER,
	    p_contract_number           IN  VARCHAR2,
	    p_item_name                 IN  VARCHAR2,
	    p_supplier_name             IN  VARCHAR2,
	    x_cle_id			OUT NOCOPY NUMBER ) IS

    CURSOR l_serv_contract_csr IS
    select id
    from okc_k_headers_b k
    where contract_number = p_contract_number
    and scs_code = 'SERVICE';

    CURSOR l_rel_vers_csr IS
    Select id
    from   okc_class_operations
    where  cls_code = 'SERVICE'
    and    opn_code = 'CHECK_RULE';

    CURSOR l_serv_contract9_csr IS
    select id
    from okc_k_headers_b k
    where contract_number = p_contract_number
    and scs_code = 'SERVICE';

    CURSOR l_serv_line_csr IS
    select to_number(cle_id)
    from okl_la_link_service_uv
    where contract_number = p_contract_number
    and item_name = p_item_name;

    CURSOR l_supp_name_csr IS
    select id1
    from okx_vendors_v
    where name = p_supplier_name;

    CURSOR l_k_sts_csr IS
    select k.sts_code, sts.ste_code
    from OKC_K_HEADERS_B K,
     OKC_STATUSES_B STS
    where STS.CODE = K.STS_CODE
    and K.ID = p_chr_id;

    Cursor l_strmtyp_id_csr  IS
    SELECT  sty_id
    FROM okl_strm_tmpt_full_uv
    WHERE STY_PURPOSE = 'SERVICE_PAYMENT'
    and exists (SELECT 1
                FROM OKC_K_HEADERS_B chr,
                     OKL_K_HEADERS khr
		WHERE chr.id = khr.id
		AND khr.pdt_id = okl_strm_tmpt_full_uv.PDT_ID
		AND trunc(chr.start_date) BETWEEN trunc(okl_strm_tmpt_full_uv.START_DATE) AND nvl(trunc(okl_strm_tmpt_full_uv.END_DATE),chr.start_date+1)
		AND chr.id = p_chr_id)
    and sty_name = p_item_name;

    l_chr_id    okc_k_headers_b.id%type := null;
    l_s_chr_id  okc_k_headers_b.id%type := null;
    l_s_cle_id  okc_k_lines_b.id%type := null;
    l_supp_id   okx_vendors_v.id1%type := null;
    x_okl_cle_id    okc_k_lines_b.id%type := null;
    l_rel_vers_id number := null;
    l_strmtyp_id okl_strm_tmpt_full_uv.sty_id%type := null;
    l_sts_code OKC_K_HEADERS_B.sts_code%type:= null;
    l_ste_code OKC_STATUSES_B.STE_CODE%type:= null;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_link_serv';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_auth number := null;
    l_inv number := null;

  BEGIN


  l_chr_id := p_chr_id;

  If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(p_contract_number is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
--  				, p_token1_value => 'a'||l_chr_id
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   l_rel_vers_id := null;
   open  l_rel_vers_csr;
   fetch l_rel_vers_csr into l_rel_vers_id;
   close l_rel_vers_csr;

  If(l_rel_vers_id is null) Then

   open  l_serv_contract9_csr;
   fetch l_serv_contract9_csr into l_s_chr_id;
   close l_serv_contract9_csr;

  Else

   open  l_serv_contract_csr;
   fetch l_serv_contract_csr into l_s_chr_id;
   close l_serv_contract_csr;

  End If;

   If l_s_chr_id is null Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(p_item_name is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  -- If(NOT(p_item_name is not null and p_item_name = 'RELINK_SERV_INTGR')) Then

   l_strmtyp_id := null;
   open  l_strmtyp_id_csr;
   fetch l_strmtyp_id_csr into l_strmtyp_id;
   close l_strmtyp_id_csr;

   If(l_strmtyp_id is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_PAYMENT_TYPE');
      If(l_ak_prompt is null) Then
       l_ak_prompt := 'Payment Type';
      End If;
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  -- End If;

   If(p_supplier_name is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   open  l_supp_name_csr;
   fetch l_supp_name_csr into l_supp_id;
   close l_supp_name_csr;

   If(l_supp_id is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   l_sts_code := null;
   l_ste_code := null;
   open  l_k_sts_csr;
   fetch l_k_sts_csr into l_sts_code, l_ste_code;
   close l_k_sts_csr;

   --If(p_item_name is not null and p_item_name = 'RELINK_SERV_INTGR') Then
   If(NOT( l_ste_code is not null AND (l_ste_code = 'ENTERED' OR l_ste_code = 'SIGNED'))) Then

      OKL_SERVICE_INTEGRATION_PVT.relink_service_contract(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_okl_chr_id          => l_chr_id,
          p_oks_chr_id          => l_s_chr_id, -- Service Contract Header ID
          p_supplier_id         => l_supp_id,
          p_sty_id              => l_strmtyp_id, -- payment type
          x_okl_service_line_id => x_okl_cle_id   -- Returns Contract Service TOP Line ID
         );

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   Else

       OKL_SERVICE_INTEGRATION_PVT.create_service_from_oks(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_okl_chr_id          => l_chr_id,
          p_oks_chr_id          => l_s_chr_id, -- Service Contract Header ID
          p_supplier_id         => l_supp_id, -- supplier id
          p_sty_id              => l_strmtyp_id, -- payment type
          x_okl_service_line_id => x_okl_cle_id   -- Returns Contract Service TOP Line ID
       );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  End If;

  x_cle_id := x_okl_cle_id;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_contract_link_serv;

-- Start of comments
--
-- Procedure Name  : create_contract_link_serv
-- Description     : link service contract to lease
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE update_contract_link_serv (
            p_api_version    		IN  NUMBER,
            p_init_msg_list  		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  		OUT NOCOPY VARCHAR2,
            x_msg_count      		OUT NOCOPY NUMBER,
            x_msg_data       		OUT NOCOPY VARCHAR2,
            p_chr_id			IN  NUMBER,
            p_cle_id			IN  NUMBER,
	    p_contract_number           IN  VARCHAR2,
	    p_item_name                 IN  VARCHAR2,
	    p_supplier_name             IN  VARCHAR2,
	    x_cle_id			OUT NOCOPY NUMBER ) IS

    CURSOR l_serv_contract_csr IS
    select id
    from okc_k_headers_b k
    where contract_number = p_contract_number
    and scs_code = 'SERVICE';

    CURSOR l_rel_vers_csr IS
    Select id
    from   okc_class_operations
    where  cls_code = 'SERVICE'
    and    opn_code = 'CHECK_RULE';

    CURSOR l_serv_contract9_csr IS
    select id
    from okc_k_headers_b k
    where contract_number = p_contract_number
    and scs_code = 'SERVICE';

    CURSOR l_serv_line_csr IS
    select to_number(cle_id)
    from okl_la_link_service_uv
    where contract_number = p_contract_number
    and item_name = p_item_name;

    CURSOR l_supp_name_csr IS
    select id1
    from okx_vendors_v
    where name = p_supplier_name;

    l_chr_id    okc_k_headers_b.id%type := null;
    l_s_chr_id  okc_k_headers_b.id%type := null;
    l_s_cle_id  okc_k_lines_b.id%type := null;
    l_supp_id   okx_vendors_v.id1%type := null;
    x_okl_cle_id    okc_k_lines_b.id%type := null;
    l_rel_vers_id number := null;

    lp_clev_rec OKL_SERVICE_INTEGRATION_PUB.clev_rec_type;
    lp_klev_rec OKL_SERVICE_INTEGRATION_PUB.klev_rec_type;


    l_api_name		CONSTANT VARCHAR2(30) := 'update_contract_link_serv';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

  BEGIN

  l_chr_id := p_chr_id;
  If okl_context.get_okc_org_id  is null then
      okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
   l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

   -- check if activity started successfully
   If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   If(p_contract_number is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   l_rel_vers_id := null;
   open  l_rel_vers_csr;
   fetch l_rel_vers_csr into l_rel_vers_id;
   close l_rel_vers_csr;

  If(l_rel_vers_id is null) Then

   open  l_serv_contract9_csr;
   fetch l_serv_contract9_csr into l_s_chr_id;
   close l_serv_contract9_csr;

  Else

   open  l_serv_contract_csr;
   fetch l_serv_contract_csr into l_s_chr_id;
   close l_serv_contract_csr;

  End If;

   If l_s_chr_id is null Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CONTRACT_NUMBER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

/*
   If(p_item_name is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;


   open  l_serv_line_csr;
   fetch l_serv_line_csr into l_s_cle_id;
   close l_serv_line_csr;

   If l_s_cle_id is null Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;
*/

   If(p_supplier_name is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   open  l_supp_name_csr;
   fetch l_supp_name_csr into l_supp_id;
   close l_supp_name_csr;

   If(l_supp_id is null) Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_SUPPLIER');
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
  				, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
  				, p_token1 => 'COL_NAME'
  				, p_token1_value => l_ak_prompt
  			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   lp_clev_rec.dnz_chr_id := l_chr_id;
   lp_clev_rec.id := p_cle_id;
   lp_klev_rec.id := p_cle_id;


   OKL_SERVICE_INTEGRATION_PUB.update_service_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_okl_chr_id          => l_chr_id,
          p_oks_chr_id          => l_s_chr_id, -- Service Contract Header ID
          p_oks_service_line_id => l_s_cle_id, -- Service Contract Service Top Line ID
          p_supplier_id         => l_supp_id,
          p_clev_rec            => lp_clev_rec,
          p_klev_rec            => lp_klev_rec,
          x_okl_service_line_id => x_okl_cle_id   -- Returns Contract Service TOP Line ID
      );

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
           raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
           raise OKC_API.G_EXCEPTION_ERROR;
   End If;

  x_cle_id := x_okl_cle_id;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END update_contract_link_serv;


  PROCEDURE create_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_chr_id  l_clev_rec.dnz_chr_id%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR get_k_dates_csr(l_id NUMBER) IS
    select chr.start_date, chr.end_date
    from okc_k_headers_b chr
    where chr.id = l_id;

    l_start_date okc_k_headers_b.start_date%type := null;
    l_end_date okc_k_headers_b.end_date%type := null;

    l_cap_yn OKL_STRMTYP_SOURCE_V.CAPITALIZE_YN%type := null;
    l_lty_code OKC_LINE_STYLES_V.LTY_CODE%type := null;

    CURSOR get_capitalize_yn_csr(cap_yn VARCHAR2) IS
      SELECT CAPITALIZE_YN
      FROM OKL_STRMTYP_SOURCE_V  OKL_STRMTYP
      WHERE OKL_STRMTYP.NAME = cap_yn
      AND  OKL_STRMTYP.STATUS = 'A';

    CURSOR get_lty_code_csr(lse_id NUMBER) IS
      select lty_code
      from okc_line_styles_v
      where id = lse_id;


  BEGIN

	l_chr_id := l_clev_rec.dnz_chr_id;
    	If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    	End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_clev_rec.name := l_clev_rec.item_description;

    open get_lty_code_csr(l_clev_rec.lse_id);
    fetch get_lty_code_csr into l_lty_code;
    close get_lty_code_csr;

    If (l_lty_code is not null and l_lty_code = 'FEE') Then

     open get_capitalize_yn_csr(l_clev_rec.item_description);
     fetch get_capitalize_yn_csr into l_cap_yn;
     close get_capitalize_yn_csr;
     If (l_cap_yn is not null and l_cap_yn = 'Y') Then
          l_klev_rec.capital_amount := p_klev_rec.amount;
     Else
     	l_klev_rec.capital_amount := null;
     End If;

    End If;


    If ( (l_clev_rec.start_date is null or l_clev_rec.start_date = OKC_API.G_MISS_DATE)
        or (l_clev_rec.end_date is null or l_clev_rec.end_date = OKC_API.G_MISS_DATE) )then

        open get_k_dates_csr(l_clev_rec.dnz_chr_id);
        fetch get_k_dates_csr into l_start_date, l_end_date;
        close get_k_dates_csr;

        If ( l_clev_rec.start_date is null or l_clev_rec.start_date = OKC_API.G_MISS_DATE) then
         l_clev_rec.start_date := l_start_date;
        End If;

        If ( l_clev_rec.end_date is null or l_clev_rec.end_date = OKC_API.G_MISS_DATE) then
         l_clev_rec.end_date := l_end_date;
        End If;

    End If;

    --Bug# 4558486
    -- To validate DFF data for Service Line
    l_klev_rec.validate_dff_yn := 'Y';

    okl_contract_pvt.create_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec);

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

   l_cimv_rec.cle_id :=  x_clev_rec.id;

    okl_okc_migration_pvt.create_contract_item(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cimv_rec		=> l_cimv_rec,
	 x_cimv_rec		=> x_cimv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;


   l_cplv_rec.cle_id :=  x_clev_rec.id;

--Murthy commented out supplier is not created at line creation.
/*   if ( l_cplv_rec.object1_id1 is not null and l_cplv_rec.object1_id2 is not null) then

    okl_okc_migration_pvt.create_k_party_role(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   end if;*/

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_contract_top_line;

-- Start of comments
--
-- Procedure Name  : create_contract_top_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    p_cplv_tbl                     IN  cplv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CREATE_contract_top_line';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
    l_cplv_tbl   	cplv_tbl_type := p_cplv_tbl;
  BEGIN

/*
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_contract_top_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
      			p_cplv_rec		=> l_cplv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i),
      			x_cplv_rec		=> x_cplv_tbl(i));

	    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
		  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
		  raise OKC_API.G_EXCEPTION_ERROR;
	    End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END create_contract_top_line;


-- Start of comments
--
-- Procedure Name  : update_contract_top_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type,
    x_cplv_rec                     OUT NOCOPY cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_chr_id  l_clev_rec.dnz_chr_id%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_contract_top_line';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;

    CURSOR get_k_dates_csr(l_id number) IS
    select chr.start_date, chr.end_date
    from okc_k_headers_b chr
    where chr.id = l_id;

    l_start_date okc_k_headers_b.start_date%type := null;
    l_end_date okc_k_headers_b.end_date%type := null;

    l_cap_yn OKL_STRMTYP_SOURCE_V.CAPITALIZE_YN%type := null;
    l_lty_code OKC_LINE_STYLES_V.LTY_CODE%type := null;

    CURSOR get_capitalize_yn_csr(cap_yn VARCHAR2) IS
      SELECT CAPITALIZE_YN
      FROM OKL_STRMTYP_SOURCE_V  OKL_STRMTYP
      WHERE OKL_STRMTYP.NAME = cap_yn
      AND  OKL_STRMTYP.STATUS = 'A';

    CURSOR get_lty_code_csr(lse_id NUMBER) IS
      select lty_code
      from okc_line_styles_v
      where id = lse_id;

    -- Bug# 6438785
    CURSOR c_orig_cle_csr(p_cle_id IN NUMBER) IS
    SELECT cle.start_date
    FROM   okc_k_lines_b cle
    WHERE  cle.id = p_cle_id;

    l_orig_cle_rec c_orig_cle_csr%ROWTYPE;

    -- added below cursor for bug 7323444 -- start
    CURSOR service_subline_csr (p_cle_id IN NUMBER,
                                p_chr_id IN NUMBER) IS
    SELECT cle.id,
           cle.start_date,
           cle.end_date
    FROM   okc_k_lines_b cle
    WHERE  cle.cle_id   = p_cle_id
    AND    cle.dnz_chr_id = p_chr_id;

    l_sub_clev_rec okl_okc_migration_pvt.clev_rec_type;
    l_sub_klev_rec okl_kle_pvt.klev_rec_type;

    x_sub_clev_rec okl_okc_migration_pvt.clev_rec_type;
    x_sub_klev_rec okl_kle_pvt.klev_rec_type;

    -- added above cursor for bug 7323444 -- end

  BEGIN

	l_chr_id := l_clev_rec.dnz_chr_id;
    	If okl_context.get_okc_org_id  is null then
      		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    	End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    l_clev_rec.name := l_clev_rec.item_description;

    open get_lty_code_csr(l_clev_rec.lse_id);
    fetch get_lty_code_csr into l_lty_code;
    close get_lty_code_csr;

    If (l_lty_code is not null and l_lty_code = 'FEE') Then

     open get_capitalize_yn_csr(l_clev_rec.item_description);
     fetch get_capitalize_yn_csr into l_cap_yn;
     close get_capitalize_yn_csr;
     If (l_cap_yn is not null and l_cap_yn = 'Y') Then
          l_klev_rec.capital_amount := p_klev_rec.amount;
     Else
     	l_klev_rec.capital_amount := null;
     End If;

    End If;


    If ( (l_clev_rec.start_date is null or l_clev_rec.start_date = OKC_API.G_MISS_DATE )
        or (l_clev_rec.end_date is null or l_clev_rec.end_date = OKC_API.G_MISS_DATE) )then

        open get_k_dates_csr(l_clev_rec.dnz_chr_id);
        fetch get_k_dates_csr into l_start_date, l_end_date;
        close get_k_dates_csr;

        If ( l_clev_rec.start_date is null or l_clev_rec.start_date = OKC_API.G_MISS_DATE) then
         l_clev_rec.start_date := l_start_date;
        End If;

        If ( l_clev_rec.end_date is null or l_clev_rec.end_date = OKC_API.G_MISS_DATE) then
         l_clev_rec.end_date := l_end_date;
        End If;

    End If;

    --Bug# 4558486
    -- To validate DFF data for Service Line
    l_klev_rec.validate_dff_yn := 'Y';

    -- Bug# 6438785
    -- Fetch original service line start date for checking
    -- whether start date has been changed
    OPEN c_orig_cle_csr(p_cle_id => l_clev_rec.id);
    FETCH c_orig_cle_csr INTO l_orig_cle_rec;
    CLOSE c_orig_cle_csr;

    okl_contract_pvt.update_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec,
      x_clev_rec      => x_clev_rec,
      x_klev_rec      => x_klev_rec
      );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

     -- added below  for bug 7323444 -- start
     For service_subline_rec In service_subline_csr(p_cle_id => l_clev_rec.id,
                                                    p_chr_id => l_clev_rec.dnz_chr_id) Loop

      If ( (NVL(l_clev_rec.start_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE AND
            service_subline_rec.start_date <> l_clev_rec.start_date) OR
           (NVL(l_clev_rec.end_date,OKL_API.G_MISS_DATE) <> OKL_API.G_MISS_DATE AND
            service_subline_rec.end_date <> l_clev_rec.end_date) ) Then

        l_sub_clev_rec.id := service_subline_rec.id;
        l_sub_klev_rec.id := service_subline_rec.id;
        l_sub_clev_rec.start_date :=l_clev_rec.start_date;
        l_sub_clev_rec.end_date :=l_clev_rec.end_date;

        OKL_CONTRACT_PVT.update_contract_line(
          p_api_version         => p_api_version,
          p_init_msg_list       => p_init_msg_list,
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          p_clev_rec            => l_sub_clev_rec,
          p_klev_rec            => l_sub_klev_rec,
          x_clev_rec            => x_sub_clev_rec,
          x_klev_rec            => x_sub_klev_rec
        );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      End If;
    End Loop;

    l_cimv_rec.cle_id :=  x_clev_rec.id;
    -- added above for bug 7323444 -- end

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.update_contract_item(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cimv_rec		=> l_cimv_rec,
	 x_cimv_rec		=> x_cimv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    -- Bug# 6438785
    -- When the service line start date is changed, update the
    -- start dates for all service and sub-line payments based on
    -- the new line start date
    IF (x_clev_rec.start_date <> l_orig_cle_rec.start_date) THEN

      OKL_LA_PAYMENTS_PVT.update_pymt_start_date
        (p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_chr_id         => x_clev_rec.dnz_chr_id,
         p_cle_id         => x_clev_rec.id);

      If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

    END IF;
    -- Bug# 6438785

--Murthy commented out supplier information is not created at line creation time.
/*    if ( l_cplv_rec.object1_id1 is not null and l_cplv_rec.object1_id2 is not null) then

    if ( l_cplv_rec.id is null ) then

     okl_okc_migration_pvt.create_k_party_role(
	 p_api_version	=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);

        -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    else

    okl_okc_migration_pvt.update_k_party_role(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
	 x_cplv_rec		=> x_cplv_rec);

        -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

 end if;

 Elsif ( l_cplv_rec.id is not null ) then

 -- delete party
  okl_okc_migration_pvt.delete_k_party_role(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;
 end if;*/

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END update_contract_top_line;


-- Start of comments
--
-- Procedure Name  : update_contract_top_line
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    p_cplv_tbl                     IN  cplv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type,
    x_cplv_tbl                     OUT NOCOPY cplv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_contract_top_line';
    l_api_version	CONSTANT NUMBER	:= 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
    l_cplv_tbl   	cplv_tbl_type := p_cplv_tbl;
  BEGIN
/*
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_top_line(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
      			p_cplv_rec		=> l_cplv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i),
      			x_cplv_rec		=> x_cplv_tbl(i));

		    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
			  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
			  raise OKC_API.G_EXCEPTION_ERROR;
		    End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

    End If;

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;
/*
    OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
				x_msg_data	=> x_msg_data);
*/
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END update_contract_top_line;


    PROCEDURE delete_contract_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  number,
            p_cle_id         IN  number) IS

    lp_clev_rec OKL_SERVICE_INTEGRATION_PUB.clev_rec_type;
    lp_klev_rec OKL_SERVICE_INTEGRATION_PUB.klev_rec_type;

    l_api_name		CONSTANT VARCHAR2(30)     := 'delete_contract_line';
    l_api_version	CONSTANT NUMBER	  	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;

    l_chr_id number := null;

  BEGIN

  l_chr_id := p_chr_id;
  If okl_context.get_okc_org_id  is null then
	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    lp_clev_rec.dnz_chr_id := l_chr_id;
    lp_clev_rec.id := p_cle_id;
    lp_klev_rec.id := p_cle_id;

    OKL_SERVICE_INTEGRATION_PUB.delete_service_line(
      				p_api_version   => p_api_version,
      				p_init_msg_list => p_init_msg_list,
      				x_return_status => x_return_status,
      				x_msg_count     => x_msg_count,
      				x_msg_data      => x_msg_data,
                                p_clev_rec      => lp_clev_rec,
                                p_klev_rec      => lp_klev_rec
                               );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count, x_msg_data	=> x_msg_data);

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END delete_contract_line;


PROCEDURE delete_contract_top_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    p_cplv_rec                     IN  cplv_rec_type) IS

    l_clev_rec clev_rec_type := p_clev_rec;
    l_klev_rec klev_rec_type := p_klev_rec;
    l_cimv_rec cimv_rec_type := p_cimv_rec;
    l_cplv_rec cplv_rec_type := p_cplv_rec;

    l_api_name		CONSTANT VARCHAR2(30)     := 'DELETE_contract_top_line';
    l_api_version	CONSTANT NUMBER	  	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;

    --Bug# 4558486
    l_kplv_rec okl_k_party_roles_pvt.kplv_rec_type;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    okl_contract_pvt.delete_contract_line(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_clev_rec      => l_clev_rec,
      p_klev_rec      => l_klev_rec
      );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    --
    -- call procedure in complex API
    --
    okl_okc_migration_pvt.delete_contract_item(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cimv_rec		=> l_cimv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
   --              to delete records in tables
   --              okc_k_party_roles_b and okl_k_party_roles
   /*
   okl_okc_migration_pvt.delete_k_party_role(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec);
   */

   l_kplv_rec.id := p_cplv_rec.id;
   okl_k_party_roles_pvt.delete_k_party_role(
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_cplv_rec		=> l_cplv_rec,
       p_kplv_rec		=> l_kplv_rec);

    -- check return status
    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			x_msg_data	=> x_msg_data);
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END delete_contract_top_line;

  -- Start of comments
  --
  -- Procedure Name  : delete_contract_top_line
  -- Description     : deletes contract line for shadowed contract
  -- Business Rules  : line can be deleted only if there is no sublines attached
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE delete_contract_top_line(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clev_tbl                     IN  clev_tbl_type,
      p_klev_tbl                     IN  klev_tbl_type,
      p_cimv_tbl                     IN  cimv_tbl_type,
      p_cplv_tbl                     IN  cplv_tbl_type
      ) IS

      l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_contract_top_line';
      l_api_version		CONSTANT NUMBER	:= 1.0;
      l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_overall_status 		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i				NUMBER;
      l_klev_tbl   		klev_tbl_type := p_klev_tbl;
      l_cimv_tbl   		cimv_tbl_type := p_cimv_tbl;
      l_cplv_tbl   		cplv_tbl_type := p_cplv_tbl;
    BEGIN
  /*
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      l_return_status := OKC_API.START_ACTIVITY(
  			p_api_name      => l_api_name,
  			p_pkg_name      => g_pkg_name,
  			p_init_msg_list => p_init_msg_list,
  			l_api_version   => l_api_version,
  			p_api_version   => p_api_version,
  			p_api_type      => g_api_type,
  			x_return_status => x_return_status);

      -- check if activity started successfully
      If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
  */
      If (p_clev_tbl.COUNT > 0) Then
  	   i := p_clev_tbl.FIRST;
  	   LOOP
  		-- call procedure in complex API for a record
  		delete_contract_top_line(
  			p_api_version		=> p_api_version,
  			p_init_msg_list		=> p_init_msg_list,
  			x_return_status 	=> x_return_status,
  			x_msg_count     	=> x_msg_count,
  			x_msg_data      	=> x_msg_data,
  			p_clev_rec		=> p_clev_tbl(i),
        		p_klev_rec		=> l_klev_tbl(i),
        		p_cimv_rec		=> l_cimv_tbl(i),
        		p_cplv_rec		=> l_cplv_tbl(i)
        		);

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;

          EXIT WHEN (i = p_clev_tbl.LAST);
  		i := p_clev_tbl.NEXT(i);
  	   END LOOP;

      End If;

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
      End If;
  /*
      OKC_API.END_ACTIVITY(	x_msg_count	=> x_msg_count,
  				x_msg_data	=> x_msg_data);
  */
    EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

      when OTHERS then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OTHERS',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => g_api_type);

    END delete_contract_top_line;
  -- Start of comments
  --
  -- Procedure Name  : validate_fee_expense_rule
  -- Description     : validates expense rules at FEE line
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_fee_expense_rule(
                                      p_api_version         IN  NUMBER,
                                      p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2,
                                      p_chr_id              IN  OKC_K_HEADERS_V.ID%TYPE,
                                      p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                      p_no_of_period        IN  NUMBER,
                                      p_frequency           IN  VARCHAR2,
                                      p_amount_per_period   IN  NUMBER
                                     ) IS

  l_api_name    VARCHAR2(35)    := 'validate_fee_expense_rule';
  l_proc_name   VARCHAR2(35)    := 'VALIDATE_FEE_EXPENSE_RULE';
  l_api_version NUMBER          := 1.0;

  l_id1  VARCHAR2(30);
  scscode OKC_K_HEADERS_B.SCS_CODE%TYPE ;

  CURSOR contract_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                       p_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT line.start_date,
         line.end_date,
         line.amount,
         line.capital_amount,
         style.lty_code,
         line.initial_direct_cost,
         line.fee_type
  FROM   okc_k_headers_b head,
         okl_k_lines_full_v line,
         okc_line_styles_b style
  WHERE  head.id     = line.dnz_chr_id
  AND    line.lse_id = style.id
  AND    head.id     = p_chr_id
  AND    line.id     = p_line_id;
  CURSOR scscode_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE ) IS
  SELECT head.scs_code
  FROM   okc_k_headers_b head
  WHERE  head.id     = p_chr_id ;

  CURSOR strm_cap_csr (p_chr_id  OKC_K_HEADERS_B.ID%TYPE,
                       p_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT stream.capitalize_yn
  FROM   okl_k_lines_full_v line,
         okc_k_items_v      item,
         okl_strmtyp_source_v stream
  WHERE  line.id              = p_line_id
  AND    line.dnz_chr_id      = p_chr_id
  AND    line.id              = item.cle_id
  AND    item.object1_id1     = stream.id1;

  CURSOR freq_csr (p_frequency VARCHAR2) IS
  SELECT id1
  FROM   okl_time_units_v
  WHERE  name = p_frequency
  AND    status = 'A'
  AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) AND
                                NVL(TRUNC(end_date_active), TRUNC(SYSDATE));

  l_start_date        OKC_K_lineS_B.START_DATE%TYPE;
  l_end_date          OKC_K_lineS_B.END_DATE%TYPE;
  l_amount            NUMBER;
  l_capital_amount    NUMBER;
  l_line_type         OKC_LINE_STYLES_B.LTY_CODE%TYPE;
  l_fee_type          OKL_K_LINES.FEE_TYPE%TYPE := null;
  l_cap_yn            VARCHAR2(3);
  l_mult_factor       NUMBER;
  l_line_amount       NUMBER;
  l_initial_direct_cost okl_k_lines.initial_direct_cost%type := null;
  l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

  l_clev_rec clev_rec_type ;
  l_klev_rec klev_rec_type ;
  x_clev_rec clev_rec_type ;
  x_klev_rec klev_rec_type ;

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

    If(p_chr_id is null or p_chr_id = OKL_API.G_MISS_NUM) Then
       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_INVALID_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'CHR_ID'
    			   );
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    If(p_line_id is null or p_line_id = OKL_API.G_MISS_NUM) Then
       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_INVALID_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => 'CLE_ID'
    			   );
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN contract_csr (p_chr_id,
                        p_line_id);
     FETCH contract_csr INTO l_start_date,
                             l_end_date,
                             l_amount,
                             l_capital_amount,
                             l_line_type,
                             l_initial_direct_cost,
                             l_fee_type;
     CLOSE contract_csr;
         OPEN scscode_csr (p_chr_id);
     FETCH scscode_csr INTO scscode;
     CLOSE scscode_csr ;
     if(scscode='INVESTOR' and p_amount_per_period < 0) then

       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_PRDAMNT_CHCK'
    			   );
    raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   IF (l_line_type = 'FEE') THEN

    If(p_no_of_period is null or p_no_of_period = OKL_API.G_MISS_NUM) Then
       l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_NO_OF_PERIOD');
       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_REQUIRED_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => l_ak_prompt
    			   );
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If(p_amount_per_period is null or p_amount_per_period = OKL_API.G_MISS_NUM) Then
       l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_AMT_PER_PERIOD');
       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_REQUIRED_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => l_ak_prompt
    			   );
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    If(p_frequency is null or p_frequency = OKL_API.G_MISS_CHAR) Then
       l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_FREEQUENCY');
       x_return_status := OKL_API.g_ret_sts_error;
       OKL_API.SET_MESSAGE(      p_app_name => g_app_name
    				, p_msg_name => 'OKL_REQUIRED_VALUE'
    				, p_token1 => 'COL_NAME'
    				, p_token1_value => l_ak_prompt
    			   );
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

   End If;

     -- Fee Expense rules are only valid for FEE and SERVICE line type
     IF (l_line_type IN ('FEE', 'SOLD_SERVICE')) THEN

        --Bug# 4959361
        OKL_LLA_UTIL_PVT.check_line_update_allowed
          (p_api_version     => p_api_version,
           p_init_msg_list   => p_init_msg_list,
           x_return_status   => x_return_status,
           x_msg_count       => x_msg_count,
           x_msg_data        => x_msg_data,
           p_cle_id          => p_line_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --Bug# 4959361

        l_id1 := '?';
        IF (p_frequency IS NOT NULL) THEN

           OPEN freq_csr (p_frequency);
           FETCH freq_csr INTO l_id1;
           CLOSE freq_csr;

           IF (l_id1 = '?') THEN
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INVALID_VALUE,
                                  'COL_NAME',
                                  'FREQUENCY'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
           END IF;

           IF (p_no_of_period IS NULL) THEN
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INCOMPLETE_RULE,
                                  'COL_NAME',
                                  'NO_OF_PERIOD'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
           ELSE
              IF (p_amount_per_period IS NULL) THEN
                 okl_api.set_message(
                                     G_APP_NAME,
                                     G_INCOMPLETE_RULE,
                                     'COL_NAME',
                                     'AMOUNT_PER_PERIOD'
                                    );

                 x_return_status := OKL_API.G_RET_STS_ERROR;
              END IF;
           END IF;
        ELSE
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INCOMPLETE_RULE,
                                  'COL_NAME',
                                  'FREQUENCY'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

     ELSIF (p_no_of_period IS NOT NULL
            OR
            p_frequency IS NOT NULL
            OR
            p_amount_per_period IS NOT NULL
           ) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_LINE_RULE,
                               'VALUE',
                               'FEE_NO_OF_PERIOD, FREQUENCY OR AMOUNT_PER_PERIOD',
                               'LINE_TYPE',
                               l_line_type,
                               'ACT_LINE_TYPE',
                               'FEE or SERVICE'
                              );

           x_return_status := OKL_API.G_RET_STS_ERROR;

     END IF;

     -- cross validation

     IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        OPEN strm_cap_csr (p_chr_id,
                           p_line_id);
        FETCH strm_cap_csr INTO l_cap_yn;
        CLOSE strm_cap_csr;

        IF (l_cap_yn = 'Y') THEN
            l_line_amount := l_capital_amount;
        ELSE
            l_line_amount := l_amount;
        END IF;

        IF (l_id1 = 'M') THEN
           l_mult_factor := 1;
        ELSIF (l_id1 = 'Q') THEN
           l_mult_factor := 3;
        ELSIF (l_id1 = 'S') THEN
           l_mult_factor := 6;
        ELSIF (l_id1 = 'A') THEN
           l_mult_factor := 12;
        ELSE
           okl_api.set_message(
                               G_APP_NAME,
                               G_UOM_SETUP_ERROR,
                               'COL_VALUE',
                               l_id1
                              );
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        IF (l_end_date < (ADD_MONTHS(l_start_date, p_no_of_period * l_mult_factor)-1)) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_PERIOD,
                               'START_DATE',
                               l_start_date,
                               'END_DATE',
                               l_end_date
                              );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    If(l_fee_type is not null and (l_fee_type = G_FT_ABSORBED or l_fee_type = G_FT_FINANCED) and p_no_of_period <> 1) Then
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_NO_OF_PAYMENTS
                              );
           RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

-- this validation is commented for summing recurring exp amt to service/fee line
      /*
        IF (l_line_amount <> (p_amount_per_period * p_no_of_period)) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_EXP_AMOUNT
                              );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      */
-- update line amount with recurring exp amount

       IF (l_line_type IN ('FEE', 'SOLD_SERVICE')) THEN

            l_clev_rec.id := p_line_id;
            l_klev_rec.id := p_line_id;
            l_clev_rec.dnz_chr_id := p_chr_id;
            l_clev_rec.chr_id := p_chr_id;

            l_line_amount := p_amount_per_period * p_no_of_period;
            l_klev_rec.amount := l_line_amount;
            IF (l_cap_yn = 'Y') THEN
             l_klev_rec.capital_amount := l_line_amount;
            END IF;

            IF (l_line_type = 'FEE' and l_initial_direct_cost is not null and l_initial_direct_cost > l_klev_rec.amount) THEN
                  x_return_status := OKL_API.g_ret_sts_error;
	          OKL_API.SET_MESSAGE(    p_app_name => g_app_name
	      				, p_msg_name => 'OKL_LLA_IDC_FEE'
	      			   );
	          raise OKL_API.G_EXCEPTION_ERROR;
	    END IF;

	    okl_contract_pvt.update_contract_line(
	      p_api_version   => p_api_version,
	      p_init_msg_list => p_init_msg_list,
	      x_return_status => x_return_status,
	      x_msg_count     => x_msg_count,
	      x_msg_data      => x_msg_data,
	      p_clev_rec      => l_clev_rec,
	      p_klev_rec      => l_klev_rec,
	      x_clev_rec      => x_clev_rec,
	      x_klev_rec      => x_klev_rec
	      );

	     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	       raise OKL_API.G_EXCEPTION_ERROR;
	     END IF;

       END IF;

     END IF;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;


     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

  EXCEPTION

      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END validate_fee_expense_rule;


  -- Start of comments
  --
  -- Procedure Name  : validate_passthru_rule
  -- Description     : validates Passthru rules at SERVICE and FEE line
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
 PROCEDURE validate_passthru_rule(
                                  p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_line_id             IN  OKC_K_LINES_V.ID%TYPE,
                                  p_vendor_id           IN  NUMBER,
                                  p_payment_term        IN  VARCHAR2,
                                  p_payment_term_id     IN  NUMBER,
                                  p_pay_to_site         IN  VARCHAR2,
                                  p_pay_to_site_id      IN  NUMBER,
                                  p_payment_method_code IN  VARCHAR2,
                                  x_payment_term_id1    OUT NOCOPY VARCHAR2,
                                  x_pay_site_id1        OUT NOCOPY VARCHAR2,
                                  x_payment_method_id1  OUT NOCOPY VARCHAR2
                                 ) IS

  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_TOP_LINE_PVT';
  G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

  G_INVALID_VALUE     CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_INVALID_LINE_RULE CONSTANT VARCHAR2(200) := 'OKL_LLA_INVALID_LINE_RULE';


  l_api_name    VARCHAR2(35)    := 'validate_passthru_rule';
  l_proc_name   VARCHAR2(35)    := 'VALIDATE_PASSTHRU_RULE';
  l_api_version NUMBER          := 1.0;

  CURSOR line_style_csr (p_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT style.lty_code
  FROM   okc_k_lines_b line,
         okc_line_styles_b style
  WHERE  line.lse_id = style.id
  AND    line.id     = p_line_id;

  CURSOR pay_term_csr (p_id   NUMBER,
                       p_name VARCHAR2) IS
  SELECT id1
  FROM   okx_payables_terms_v
  WHERE  (name   = p_name
          AND
          p_name IS NOT NULL)
  OR     (id1 = p_id
          AND
          p_id IS NOT NULL)
  AND    status = 'A'
  AND    TRUNC(SYSDATE) BETWEEN NVL(TRUNC(start_date_active), TRUNC(SYSDATE)) AND
                                NVL(TRUNC(end_date_active), TRUNC(SYSDATE));

  CURSOR pay_site_csr (p_id        NUMBER,
                       p_name      VARCHAR2,
                       p_vendor_id NUMBER) IS

  SELECT id1
  FROM   okx_vendor_sites_v
  WHERE  (name   = p_name
          AND
          p_name IS NOT NULL)
  OR     (id1 = p_id
          AND
          p_id IS NOT NULL)
  AND    status         = 'A'
  AND    vendor_id      = p_vendor_id
  AND    TRUNC(SYSDATE) >= NVL(TRUNC(start_date_active), TRUNC(SYSDATE));

  CURSOR pay_method_csr (p_code VARCHAR2) IS
  SELECT lookup_code
  FROM   fnd_lookup_values
  WHERE  lookup_type           = 'PAYMENT METHOD'
  AND    nvl(enabled_flag,'N') = 'Y'
  AND    lookup_code           = p_code
  AND    trunc(nvl(start_date_active,sysdate)) <= trunc(sysdate)
  AND    trunc(nvl(end_date_active,sysdate+1)) > trunc(sysdate);

  l_id1       VARCHAR2(30);
  l_line_type OKC_LINE_STYLES_B.LTY_CODE%TYPE;

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


     OPEN line_style_csr (p_line_id);
     FETCH line_style_csr INTO l_line_type;
     CLOSE line_style_csr;


     -- Passthru rules are only for SERVICE and FEE line
     IF (l_line_type IN ('SOLD_SERVICE', 'FEE')) THEN

        l_id1 := '?';
        IF (p_payment_term IS NOT NULL) THEN

           OPEN pay_term_csr (p_payment_term_id,
                              p_payment_term);
           FETCH pay_term_csr INTO l_id1;
           CLOSE pay_term_csr;

           IF (l_id1 = '?') THEN
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INVALID_VALUE,
                                  'COL_NAME',
                                  'PAYMENT_TERM'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
           ELSE
              x_payment_term_id1 := l_id1;
           END IF;

        END IF;

        l_id1 := '?';
        IF (p_pay_to_site IS NOT NULL
            OR
            p_pay_to_site_id IS NOT NULL) THEN

           OPEN pay_site_csr (p_pay_to_site_id,
                              p_pay_to_site,
                              p_vendor_id);
           FETCH pay_site_csr INTO l_id1;
           CLOSE pay_site_csr;

           IF (l_id1 = '?') THEN
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INVALID_VALUE,
                                  'COL_NAME',
                                  'PAY_TO_SITE'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
           ELSE
              x_pay_site_id1 := l_id1;
           END IF;

        END IF;

        l_id1 := '?';
        IF (p_payment_method_code IS NOT NULL) THEN

           OPEN pay_method_csr (p_payment_method_code);
           FETCH pay_method_csr INTO l_id1;
           CLOSE pay_method_csr;

           IF (l_id1 = '?') THEN
              okl_api.set_message(
                                  G_APP_NAME,
                                  G_INVALID_VALUE,
                                  'COL_NAME',
                                  'PAYMENT_METHOD_CODE'
                                 );

              x_return_status := OKL_API.G_RET_STS_ERROR;
           ELSE
              x_payment_method_id1 := l_id1;
           END IF;
        END IF;

     ELSIF (p_payment_term IS NOT NULL
            OR
            p_payment_term_id IS NOT NULL
            OR
            p_pay_to_site IS NOT NULL
            OR
            p_pay_to_site_id IS NOT NULL
            OR
            p_payment_method_code IS NOT NULL
           ) THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_LINE_RULE,
                               'VALUE',
                               'PAYMENT_TERM, PAY_TO_SITE, PAYMENT_METHOD',
                               'LINE_TYPE',
                               l_line_type,
                               'ACT_LINE_TYPE',
                               'SERVICE or FEE'
                              );

           x_return_status := OKL_API.G_RET_STS_ERROR;

     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END validate_passthru_rule;
END OKL_CONTRACT_TOP_LINE_PVT;

/
