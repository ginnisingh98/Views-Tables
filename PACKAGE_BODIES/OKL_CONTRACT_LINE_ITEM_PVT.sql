--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_LINE_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_LINE_ITEM_PVT" as
/* $Header: OKLRCLIB.pls 120.26 2007/10/31 04:53:18 rpillay noship $ */

-- Start of comments
--
-- Procedure Name  : create_contract_line
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  G_API_TYPE		CONSTANT VARCHAR2(4) := '_PVT';

/*
-- vthiruva, 09/01/2004
-- Added Constants to enable Business Event
*/
G_WF_EVT_ASSET_FEE_REMOVED CONSTANT VARCHAR2(60) := 'oracle.apps.okl.la.lease_contract.remove_asset_fee';
G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(20) := 'CONTRACT_ID';
G_WF_ITM_FEE_LINE_ID CONSTANT VARCHAR2(20) := 'FEE_LINE_ID';
G_WF_ITM_ASSET_ID CONSTANT VARCHAR2(20) := 'ASSET_ID';

/*
 * sjalasut: aug 18, 04 added constants used in raising business event. BEGIN
 */
G_WF_EVT_ASSET_SERV_FEE_RMVD CONSTANT VARCHAR2(65) := 'oracle.apps.okl.la.lease_contract.remove_asset_service_fee';
G_WF_ITM_SERV_LINE_ID        CONSTANT VARCHAR2(30) := 'SERVICE_LINE_ID';
G_WF_ITM_SERV_CHR_ID         CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT_ID';
G_WF_ITM_SERV_CLE_ID         CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT_LINE_ID';
G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(30)   := 'CONTRACT_PROCESS';
/*
 * sjalasut: aug 18, 04 added constants used in raising business event. END
 */

--For Object code 'OKL_STRMTYP'

CURSOR okl_strmtyp_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT ssv.id1,
       ssv.id2,
       ssv.name,
       ssv.description
FROM okl_strmtyp_source_v ssv
WHERE ssv.status = 'A'
AND   ssv.name = NVL(p_name,ssv.name)
AND   ssv.id1  = NVL(p_id1,ssv.id1)
AND   ssv.id2  = NVL(p_id2,ssv.id2)
ORDER BY ssv.name;

-- FOr Object COde 'OKL_USAGE'

CURSOR okl_usage_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2,p_chr_id NUMBER) IS
select cle.id ID1,
       '#' ID2,
       tl.name NAME,
       tl.item_description DESCRIPTION
from OKC_K_LINES_B CLE,
OKC_K_LINES_TL TL,
OKC_LINE_STYLES_B LSE,
OKC_K_HEADERS_B CHR
where
cle.lse_id = lse.id
and lse.lty_code = 'USAGE'
and cle.chr_id = chr.id
and tl.id = cle.id
and tl.language = userenv('LANG')
and chr.scs_code = 'SERVICE'
and tl.name = nvl(p_name,tl.name)
and   cle.id   = nvl(p_id1,cle.id )
and   '#'  = nvl(p_id2,'#')
and cle.dnz_chr_id=p_chr_id
order by tl.name;

/* commented for performance issue bug#5484903
SELECT ulv.id1,
       ulv.id2,
       ulv.name,
       ulv.description
FROM okl_usage_lines_v ulv
WHERE ulv.name = NVL(p_name,ulv.name)
AND   ulv.id1  = NVL(p_id1,ulv.id1)
AND   ulv.id2  = NVL(p_id2,ulv.id2)
ORDER BY ulv.name; */

-- For Object Code 'OKX_ASSET'

CURSOR okx_asset_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT asv.id1,
       asv.id2,
       asv.name,
       asv.description
FROM okx_assets_v asv
WHERE asv.name = p_name --for performance issue bug#5484903
AND   asv.id1  = NVL(p_id1,asv.id1)
AND   asv.id2  = NVL(p_id2,asv.id2)
ORDER BY asv.name;

-- For Object Code 'OKX_COVASST'
-- Updated the cursor for performance fix bug#5484903
CURSOR okx_covasst_csr(p_dnz_chr_id NUMBER,p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT cas.id1,
       cas.id2,
       cas.name,
       cas.description
FROM OKX_COVERED_ASSET_V cas
WHERE cas.okc_line_status NOT IN ('EXPIRED','TERMINATED','CANCELLED','ABANDONED')
AND   cas.dnz_chr_id = p_dnz_chr_id  -- included for bug#5484903
AND   cas.name = NVL(p_name,cas.name)
AND   cas.id1  = NVL(p_id1,cas.id1)
AND   cas.id2  = NVL(p_id2,cas.id2)
ORDER BY cas.name;

-- For Object Code 'OKX_IB_ITEM'

CURSOR okx_ib_item_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT itv.id1,
       itv.id2,
       itv.name,
       itv.description
FROM OKX_INSTALL_ITEMS_V itv
WHERE itv.name =p_name --for performance issue bug#5484903
AND   itv.id1  = NVL(p_id1,itv.id1)
AND   itv.id2  = NVL(p_id2,itv.id2)
ORDER BY itv.name;




-- For Object Code 'OKX_LEASE'
-- removed the cursor okx_lease_csr for try_code 'SHARED'
--since it is not needed --fixed as part of the performance issue bug#5484903

-- For Object Code 'OKX_SERVICE'

CURSOR okx_service_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT syi.id1,
       syi.id2,
       syi.name,
       syi.description
FROM OKX_SYSTEM_ITEMS_V syi
WHERE syi.VENDOR_WARRANTY_FLAG='N'
AND   syi.SERVICE_ITEM_FLAG='Y'
AND   syi.ORGANIZATION_ID = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID')
AND   syi.name = NVL(p_name,syi.name)
AND   syi.id1  = NVL(p_id1,syi.id1)
AND   syi.id2  = NVL(p_id2,syi.id2)
ORDER BY syi.NAME;

-- For Object Code  'OKX_SYSITEM'

CURSOR okx_sysitem_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT syi.id1,
       syi.id2,
       syi.name,
       syi.description
FROM OKX_SYSTEM_ITEMS_V syi
WHERE syi.ORGANIZATION_ID = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID')
AND   syi.name = NVL(p_name,syi.name)
AND   syi.id1  = NVL(p_id1,syi.id1)
AND   syi.id2  = NVL(p_id2,syi.id2)
ORDER BY syi.NAME;

  /*
  -- vthiruva, 09/01/2004
  -- START, Added PROCEDURE to enable Business Event
  */
  -- Start of comments
  --
  -- Procedure Name  : raise_business_event
  -- Description     : local_procedure, raises business event by making a call to
  --                   okl_wf_pvt.raise_event
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  --
  PROCEDURE raise_business_event(
                  p_api_version       IN NUMBER,
                  p_init_msg_list     IN VARCHAR2,
                  x_return_status     OUT NOCOPY VARCHAR2,
                  x_msg_count         OUT NOCOPY NUMBER,
                  x_msg_data          OUT NOCOPY VARCHAR2,
                  p_event_name        IN WF_EVENTS.NAME%TYPE,
                  p_event_param_list  IN WF_PARAMETER_LIST_T) IS

    l_event_parameter_list        wf_parameter_list_t := p_event_param_list;
    l_contract_process VARCHAR2(20);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- wrapper API to get contract process. this API determines in which status the
    -- contract in question is.
    l_contract_process := okl_lla_util_pvt.get_contract_process(
                                            p_chr_id => wf_event.GetValueForParameter(G_WF_ITM_CONTRACT_ID, l_event_parameter_list)
                                           );
    -- add the contract status to the event parameter list
    wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS, l_contract_process, l_event_parameter_list);

    OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => p_event_name,
                           p_parameters     => l_event_parameter_list);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END raise_business_event;

 /*
 -- vthiruva, 09/01/2004
 -- END, PROCEDURE to enable Business Event
 */

  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS

-- Changed the sql for performance issue #5484903
	Select  AAT.attribute_label_long
	FROM    FND_APPLICATION_VL FAV ,
		AK_ATTRIBUTES_TL AAT ,
		AK_ATTRIBUTES AA
	WHERE AA.ATTRIBUTE_APPLICATION_ID = AAT.ATTRIBUTE_APPLICATION_ID
	AND AA.ATTRIBUTE_CODE = AAT.ATTRIBUTE_CODE
	AND AAT.LANGUAGE = USERENV('LANG')
	AND AA.ATTRIBUTE_APPLICATION_ID = FAV.APPLICATION_ID
	and aa.attribute_code = p_ak_attribute
	and exists (select 'x' from     ak_regions r
		where  r.region_code = p_ak_region)
	and exists (select 'x' from  ak_region_items ri
		where ri.region_code  =  p_ak_region
                and ri.attribute_code = aa.attribute_code );

  /*  --commented for performance issue bug#5484903
	SELECT a.attribute_label_long
	FROM ak_region_items ri, AK_REGIONS r, AK_ATTRIBUTES_vL a
	WHERE ri.region_code = r.region_code
	AND ri.attribute_code = a.attribute_code
	AND ri.region_code  =  p_ak_region
	AND ri.attribute_code = p_ak_attribute;  */

  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	return(l_ak_prompt);
  END;

    --Start of Comments
    --Procedure   : Validate_Item
    --Description : Returns Name, Description for a given role or all the roles
    --              attached to a contract
    --End of Comments
    Procedure Validate_Link_Asset (p_api_version   IN	NUMBER,
                         p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status	   OUT  NOCOPY	VARCHAR2,
                         x_msg_count	           OUT  NOCOPY	NUMBER,
                         x_msg_data	           OUT  NOCOPY	VARCHAR2,
                         p_chr_id                  IN	NUMBER,
                         p_parent_cle_id           IN	NUMBER,
                         p_id1            	   IN   OUT  NOCOPY VARCHAR2,
                         p_id2                 IN   OUT  NOCOPY VARCHAR2,
                         p_name                IN   VARCHAR2,
                         p_object_code         IN   VARCHAR2
                         ) is
    l_select_clause     varchar2(2000) default null;
    l_from_clause       varchar2(2000) default null;
    l_where_clause      varchar2(2000) default null;
    l_order_by_clause   varchar2(2000) default null;
    l_query_string      varchar2(2000) default null;

    l_id1               OKC_K_ITEMS_V.OBJECT1_ID1%TYPE default Null;
    l_id2               OKC_K_ITEMS_V.OBJECT1_ID2%TYPE default Null;
    l_name              VARCHAR2(250) Default Null;
    l_description       VARCHAR2(250) Default Null;
    l_object_code       VARCHAR2(30) Default Null;

    l_id11               OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
    l_id22               OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;

    type                item_curs_type is REF CURSOR;
    item_curs           item_curs_type;

    row_count           Number default 0;

    l_chr_id	        okl_k_headers.id%type;
    l_parent_cle_id     okl_k_lines.id%type;
    l_cle_id            okl_k_lines.id%type;
    l_lty_code          okc_line_styles_b.lty_code%type;
    l_id                okl_k_lines.id%type;

    l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Link_Asset';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR get_item_csr(p_chr_id NUMBER, p_parent_cle_id NUMBER, p_link_ast_id1 VARCHAR2, p_link_ast_id2 VARCHAR2) IS
    SELECT link_ast.id
    from okl_k_lines_full_v sub_line, okc_k_items_v link_ast
    where sub_line.id = link_ast.cle_id
    and link_ast.object1_id1 = p_link_ast_id1
    and link_ast.object1_id2 = p_link_ast_id2
    and sub_line.cle_id = p_parent_cle_id
    and sub_line.dnz_chr_id = p_chr_id;

    -- Cursor to fetch the lty_code
   CURSOR get_lty_code_csr(p_chr_id NUMBER,
                           p_cle_id NUMBER) IS
   SELECT  lty_code
   FROM    okc_line_styles_b lse,
           okc_k_lines_b cle
   WHERE  lse.lse_parent_id = cle.lse_id
   AND    cle.id = p_cle_id
   AND    cle.chr_id = p_chr_id;


    Begin

      l_chr_id := p_chr_id;
      If okl_context.get_okc_org_id  is null then
    	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
      End If;

      If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
      Then
      	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElsIf ( p_parent_cle_id is null or p_parent_cle_id =  OKC_API.G_MISS_NUM)
      Then
      	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)
      Then
      	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      End If;

      OPEN get_lty_code_csr(p_chr_id => p_chr_id,
                            p_cle_id => p_parent_cle_id );

      FETCH get_lty_code_csr INTO l_lty_code;

      If get_lty_code_csr%NotFound Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

      CLOSE get_lty_code_csr;

--Added by kthiruva 23-Sep-2003 Bug No.3156265

--For Object code 'OKL_STRMTYP'

       IF (l_lty_code = 'FEE') THEN

         OPEN okl_strmtyp_csr(p_name => p_name,
                              p_id1  => l_id1,
                              p_id2  => l_id2);


             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okl_strmtyp_csr into  l_id1,l_id2,l_name,l_description;

         If okl_strmtyp_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okl_strmtyp_csr into  l_id1,l_id2,l_name,l_description;
         If okl_strmtyp_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okl_strmtyp_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okl_strmtyp_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okl_strmtyp_csr;
     END IF;

-- For Object Code 'OKL_USAGE'

   IF (l_lty_code = 'USAGE') THEN


         OPEN okl_usage_csr(p_name => p_name,
                            p_id1  => l_id1,
                            p_id2  => l_id2,
			    p_chr_id=>p_chr_id); -- added for performance issue bug#5484903


             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okl_usage_csr into  l_id1,l_id2,l_name,l_description;

         If okl_usage_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okl_usage_csr into  l_id1,l_id2,l_name,l_description;
         If okl_usage_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okl_usage_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okl_usage_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okl_usage_csr;

     END IF;

-- For Object Code ' OKX_ASSET '

   IF (l_lty_code = 'FIXED_ASSET') THEN

         OPEN okx_asset_csr(p_name => p_name,
                            p_id1  => l_id1,
                            p_id2  => l_id2);

             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okx_asset_csr into  l_id1,l_id2,l_name,l_description;

         If okx_asset_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okx_asset_csr into  l_id1,l_id2,l_name,l_description;
         If okx_asset_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okx_asset_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_asset_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okx_asset_csr;

     END IF;

 -- For Object Code 'OKX_COVASST'

--   IF (l_lty_code ='LINK_SERV_ASSET' OR l_lty_code = 'LINK_USAGE_ASSET') THEN
   IF (l_lty_code = 'LINK_USAGE_ASSET') THEN


       OPEN okx_covasst_csr(p_dnz_chr_id => p_chr_id,
                            p_name => p_name,
                            p_id1  => l_id1,
                            p_id2  => l_id2);

             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okx_covasst_csr into  l_id1,l_id2,l_name,l_description;

         If okx_covasst_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okx_covasst_csr into  l_id1,l_id2,l_name,l_description;
         If okx_covasst_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okx_covasst_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_covasst_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okx_covasst_csr;

     END IF;

-- For Object Code 'OKX_IB_ITEM'

    IF (l_lty_code = 'INST_ITEM') THEN

      OPEN okx_ib_item_csr(p_name => p_name,
                           p_id1  => l_id1,
                           p_id2  => l_id2);

             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okx_ib_item_csr into  l_id1,l_id2,l_name,l_description;

         If okx_ib_item_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okx_ib_item_csr into  l_id1,l_id2,l_name,l_description;
         If okx_ib_item_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okx_ib_item_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_ib_item_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okx_ib_item_csr;

     END IF;

-- For Object Code 'OKX_LEASE'
-- Removed the code for --   IF (l_lty_code = 'SHARED') THEN -- since it is not needed anymore.
-- pls. refer the earlier version of this file from ARCS for referrence.
-- Fixed as part of performance bug#5484903-- varangan - 25-9-06



-- For Object Code 'OKX_SERVICE'

     IF (l_lty_code ='SOLD_SERVICE') THEN

     OPEN okx_service_csr(p_name => p_name,
                          p_id1  => l_id1,
                          p_id2  => l_id2 );

             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okx_service_csr into  l_id1,l_id2,l_name,l_description;

         If okx_service_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okx_service_csr into  l_id1,l_id2,l_name,l_description;
         If okx_service_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okx_service_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_service_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okx_service_csr;

     END IF;

-- For Object Code 'OKX_SYSITEM'

   IF (l_lty_code = 'ITEM' or l_lty_code ='ADD_ITEM') THEN

   OPEN okx_sysitem_csr(p_name => p_name,
                        p_id1  => l_id1,
                        p_id2  => l_id2);

             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

         FETCH okx_sysitem_csr into  l_id1,l_id2,l_name,l_description;

         If okx_sysitem_csr%NotFound Then
           x_return_status := OKC_API.g_ret_sts_error;
           OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

         l_id11 := l_id1;
         l_id22 := l_id2;

         FETCH okx_sysitem_csr into  l_id1,l_id2,l_name,l_description;
         If okx_sysitem_csr%Found Then

            If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
    	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
     	      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset from lov
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

            Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
    	          l_id11 := l_id1;
          	  l_id22 := l_id2;
          	  row_count := 1;
          	  Exit;
             End If;
             Fetch okx_sysitem_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_sysitem_csr%NotFound;
            End Loop;

    	    If row_count <> 1 Then
    	    	x_return_status := OKC_API.g_ret_sts_error;
    	 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED'); -- duplicate values found; pl. select an asset
    	 	raise OKC_API.G_EXCEPTION_ERROR;
    	    End If;

         End If;

        p_id1 := l_id11;
        p_id2 := l_id22;

      CLOSE okx_sysitem_csr;

     END IF;

      -- check for the link asset in the subline
      open get_item_csr(p_chr_id, p_parent_cle_id, p_id1, p_id2);
      Fetch get_item_csr into  l_id;

       If get_item_csr%Found Then
        Close get_item_csr;
    	x_return_status := OKC_API.g_ret_sts_error;
 	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_NUMBER'); -- duplicate values found; pl. select an asset
 	raise OKC_API.G_EXCEPTION_ERROR;
       End If;

      Close get_item_csr;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;


      EXCEPTION
        when OKC_API.G_EXCEPTION_ERROR then
            x_return_status := OKC_API.HANDLE_EXCEPTIONS(
      			p_api_name  => l_api_name,
      			p_pkg_name  => g_pkg_name,
      			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
      			x_msg_count => x_msg_count,
      			x_msg_data  => x_msg_data,
      			p_api_type  => g_api_type);

         IF okl_strmtyp_csr%ISOPEN THEN
             CLOSE okl_strmtyp_csr;
         END IF;

         IF okl_usage_csr%ISOPEN THEN
             CLOSE okl_usage_csr;
         END IF;

         IF okx_asset_csr%ISOPEN THEN
             CLOSE okx_asset_csr;
         END IF;

         IF okx_covasst_csr%ISOPEN THEN
             CLOSE okx_covasst_csr;
         END IF;

         IF okx_ib_item_csr%ISOPEN THEN
             CLOSE okx_ib_item_csr;
         END IF;

         IF okx_service_csr%ISOPEN THEN
             CLOSE okx_service_csr;
         END IF;

         IF okx_sysitem_csr%ISOPEN THEN
             CLOSE okx_sysitem_csr;
         END IF;

          when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
            x_return_status := OKC_API.HANDLE_EXCEPTIONS(
      			p_api_name  => l_api_name,
      			p_pkg_name  => g_pkg_name,
      			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
      			x_msg_count => x_msg_count,
      			x_msg_data  => x_msg_data,
      			p_api_type  => g_api_type);

         IF okl_strmtyp_csr%ISOPEN THEN
             CLOSE okl_strmtyp_csr;
         END IF;

         IF okl_usage_csr%ISOPEN THEN
             CLOSE okl_usage_csr;
         END IF;

         IF okx_asset_csr%ISOPEN THEN
             CLOSE okx_asset_csr;
         END IF;

         IF okx_covasst_csr%ISOPEN THEN
             CLOSE okx_covasst_csr;
         END IF;

         IF okx_ib_item_csr%ISOPEN THEN
             CLOSE okx_ib_item_csr;
         END IF;

         IF okx_service_csr%ISOPEN THEN
             CLOSE okx_service_csr;
         END IF;

         IF okx_sysitem_csr%ISOPEN THEN
             CLOSE okx_sysitem_csr;
         END IF;

          when OTHERS then
            x_return_status := OKC_API.HANDLE_EXCEPTIONS(
      			p_api_name  => l_api_name,
      			p_pkg_name  => g_pkg_name,
      			p_exc_name  => 'OTHERS',
      			x_msg_count => x_msg_count,
      			x_msg_data  => x_msg_data,
      			p_api_type  => g_api_type);
            IF okl_strmtyp_csr%ISOPEN THEN
             CLOSE okl_strmtyp_csr;
            END IF;

            IF okl_usage_csr%ISOPEN THEN
             CLOSE okl_usage_csr;
            END IF;

            IF okx_asset_csr%ISOPEN THEN
             CLOSE okx_asset_csr;
            END IF;

            IF okx_covasst_csr%ISOPEN THEN
             CLOSE okx_covasst_csr;
            END IF;

            IF okx_ib_item_csr%ISOPEN THEN
             CLOSE okx_ib_item_csr;
            END IF;

            IF okx_service_csr%ISOPEN THEN
             CLOSE okx_service_csr;
            END IF;

            IF okx_sysitem_csr%ISOPEN THEN
             CLOSE okx_sysitem_csr;
            END IF;

  End Validate_Link_Asset;

  PROCEDURE delete_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type
      ) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'delete_contract_line_item';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_chr_id		NUMBER;

    lp_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lp_cimv_tbl OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lp_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    lx_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lx_cimv_tbl OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lx_klev_tbl OKL_KLE_PVT.klev_tbl_type;

  BEGIN

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

    If (p_line_item_tbl.COUNT > 0) Then

          i := p_line_item_tbl.FIRST;

          --Bug# 4959361
          OKL_LLA_UTIL_PVT.check_line_update_allowed
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_cle_id          => p_line_item_tbl(i).cle_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --Bug# 4959361

	  l_chr_id := p_line_item_tbl(i).chr_id;
	  If okl_context.get_okc_org_id  is null then
	     okl_context.set_okc_org_context(p_chr_id => l_chr_id );
	  End If;

	  LOOP
            lp_clev_tbl(i).cle_id := p_line_item_tbl(i).parent_cle_id;
            lp_clev_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;
            lp_clev_tbl(i).id := p_line_item_tbl(i).cle_id;

            lp_klev_tbl(i).kle_id := p_line_item_tbl(i).cle_id;

            lp_cimv_tbl(i).id := p_line_item_tbl(i).item_id;
            lp_cimv_tbl(i).cle_id := p_line_item_tbl(i).cle_id;
            lp_cimv_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;


          EXIT WHEN (i = p_line_item_tbl.LAST);
	         i := p_line_item_tbl.NEXT(i);
	  END LOOP;

    End If;

    delete_contract_line_item(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_clev_tbl		=> lp_clev_tbl,
	p_klev_tbl		=> lp_klev_tbl,
	p_cimv_tbl		=> lp_cimv_tbl);

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

  END;

  PROCEDURE create_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type,
      x_line_item_tbl                OUT NOCOPY line_item_tbl_type
      )  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_line_item';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_chr_id		NUMBER;
    l_parent_cle_id	NUMBER;
    l_cnt number := 0;

    l_currency_code okl_k_headers_full_v.currency_code%type := null;
    l_sts_code okl_k_headers_full_v.sts_code%type := null;
    l_lse_id   okc_line_styles_b.id%type := null;
    l_lty_code okc_line_styles_b.lty_code%type := null;
    l_item_id1 okc_k_items.object1_id1%type := null;
    l_item_id2 okc_k_items.object1_id2%type := null;
    l_amount number := null;

    CURSOR get_link_fee_asset_csr(p_chr_id number, p_cle_id number, p_name varchar2) IS
    SELECT ID1, ID2
    FROM OKL_LA_FEE_COVERED_ASSET_UV
    WHERE DNZ_CHR_ID = p_chr_id
    AND CLE_ID = p_cle_id
    AND NAME = p_name;

    CURSOR get_link_service_asset_csr(p_chr_id number, p_cle_id number, p_name varchar2) IS
    SELECT ID1,id2
    FROM OKL_LA_SRV_COV_AST_UV
    WHERE CHR_ID = p_chr_id
    and name = p_name;

    CURSOR is_serv_contract_csr(p_cle_id number) IS
    select count(1)
    from okc_k_rel_objs rel
    where rel.cle_id = p_cle_id and
    rel.rty_code = 'OKLSRV';

    CURSOR get_k_info_csr(p_chr_id number) IS
    SELECT currency_code,sts_code
    from okc_k_headers_v chr
    where chr.id = p_chr_id;

    CURSOR get_lse_id_csr(p_chr_id number, p_cle_id number) IS
    select lse.id,lse.lty_code
    from   okc_line_styles_b lse
    ,      okc_k_lines_b cle
    where  lse.lse_parent_id = cle.lse_id
    and    cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

    CURSOR get_fee_type_csr(p_chr_id number, p_cle_id number) IS
    select cle.fee_type
    from   okl_k_lines_full_v cle
    where  cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

    lp_clev_tbl         OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lp_cimv_tbl         OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lp_klev_tbl         OKL_KLE_PVT.klev_tbl_type;
    lp_srv_cov_tbl      okl_service_integration_pvt.srv_cov_tbl_type;

    lx_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lx_cimv_tbl OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lx_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    --Bug# 3877032
    l_fin_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    l_fin_klev_rec    okl_contract_pub.klev_rec_type;
    lx_fin_clev_rec   okl_okc_migration_pvt.clev_rec_type;
    lx_fin_klev_rec   okl_contract_pub.klev_rec_type;

    --cursor to find out the fee type from okl_k_lines
    cursor l_fee_type_csr (p_cle_id in number) is
    select fee_type
    from   okl_k_lines kle
    where  kle.id       = p_cle_id;

    l_fee_type okl_k_lines.fee_type%TYPE;
    --Bug#3877032

  BEGIN

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


    If (p_line_item_tbl.COUNT > 0) Then
      i := p_line_item_tbl.FIRST;

      --Bug# 4959361
      OKL_LLA_UTIL_PVT.check_line_update_allowed
        (p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_cle_id          => p_line_item_tbl(i).parent_cle_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Bug# 4959361

      l_chr_id := p_line_item_tbl(i).chr_id;
      If okl_context.get_okc_org_id  is null then
        okl_context.set_okc_org_context(p_chr_id => l_chr_id );
      End If;

      open get_k_info_csr(p_line_item_tbl(i).chr_id);
      fetch get_k_info_csr into l_currency_code,l_sts_code;
      close get_k_info_csr;

      l_parent_cle_id := p_line_item_tbl(i).parent_cle_id;
      l_lty_code := null;
      open get_lse_id_csr(l_chr_id,l_parent_cle_id);
      fetch get_lse_id_csr into l_lse_id,l_lty_code;
      close get_lse_id_csr;

      l_fee_type := null;
      open get_fee_type_csr(l_chr_id,l_parent_cle_id);
      fetch get_fee_type_csr into l_fee_type;
      close get_fee_type_csr;
      LOOP
         -- Not null Validation for Asset Number
        IF (p_line_item_tbl(i).name = OKC_API.G_MISS_CHAR OR p_line_item_tbl(i).name IS NULL) THEN
          OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
                              x_return_status := OKC_API.g_ret_sts_error;
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF( l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then

          -- Not null Validation for capital Amount
          IF (p_line_item_tbl(i).capital_amount IS NULL OR p_line_item_tbl(i).capital_amount = OKC_API.G_MISS_NUM) THEN
            l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
            OKC_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => 'OKL_AMOUNT_FORMAT'
                               , p_token1 => 'COL_NAME'
                               , p_token1_value => l_ak_prompt
                               );
            x_return_status := OKC_API.g_ret_sts_error;
            RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          --Bug#4664176
          --Bug#4635028
     -- ELSIF(l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
        ELSIF(l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then

          IF( p_line_item_tbl(i).capital_amount IS NOT NULL ) Then
            l_amount := p_line_item_tbl(i).capital_amount;
          END IF;

            -- Not null Validation for Amount
          IF(l_amount IS NULL OR l_amount = OKC_API.G_MISS_NUM) THEN
            l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
            OKC_API.SET_MESSAGE(p_app_name => g_app_name
                              , p_msg_name => 'OKL_AMOUNT_FORMAT'
                              , p_token1 => 'COL_NAME'
                              , p_token1_value => l_ak_prompt
                                 );
            x_return_status := OKC_API.g_ret_sts_error;
            RAISE OKC_API.G_EXCEPTION_ERROR;

          END IF;
        END IF;

        If(l_lty_code  = 'LINK_FEE_ASSET') Then -- do the validation for fee link asset
          l_item_id1 := null;
          l_item_id2 := null;
          open get_link_fee_asset_csr(l_chr_id, l_parent_cle_id, p_line_item_tbl(i).name);
          fetch get_link_fee_asset_csr into l_item_id1, l_item_id2;
          close get_link_fee_asset_csr;

          If(l_item_id1 is null or l_item_id2 is null) Then -- through error message
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ASSET');
            OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                              , p_token1 => 'COL_NAME'
                              , p_token1_value => l_ak_prompt
                                );
            raise OKC_API.G_EXCEPTION_ERROR;
          End If;

          lp_cimv_tbl(i).object1_id1 := l_item_id1;
          lp_cimv_tbl(i).object1_id2 := l_item_id2;

        ElsIf(l_lty_code  = 'LINK_SERV_ASSET') Then -- do the validation for service link asset
          lp_klev_tbl(i).capital_amount := p_line_item_tbl(i).capital_amount;
          l_cnt := 0;
          open is_serv_contract_csr(l_parent_cle_id);
          fetch is_serv_contract_csr into l_cnt;
          close is_serv_contract_csr;
          If( l_cnt = 0) Then -- service contract not attached
            l_item_id1 := null;
            l_item_id2 := null;
            open get_link_service_asset_csr(l_chr_id, l_parent_cle_id, p_line_item_tbl(i).name);
            fetch get_link_service_asset_csr into l_item_id1, l_item_id2;
            close get_link_service_asset_csr;
            If(l_item_id1 is null or l_item_id2 is null) Then -- through error message
              x_return_status := OKC_API.g_ret_sts_error;
              l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ASSET');
              OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                                , p_token1 => 'COL_NAME'
                                , p_token1_value => l_ak_prompt

              );
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;
            lp_cimv_tbl(i).object1_id1 := l_item_id1;
            lp_cimv_tbl(i).object1_id2 := l_item_id2;
          Else
            lp_cimv_tbl(i).object1_id1 := p_line_item_tbl(i).item_id1;
            lp_cimv_tbl(i).object1_id2 := p_line_item_tbl(i).item_id2;

            -- sjalasut, bug 4648686. START
            -- l_item_id1 is being assigned to lp_cimv_tbl(i).object1_id1 further down from here
            -- if none of the if conditions above satisfy, these local variables would have null values
            -- to prevent such a scenario, assigning p_line_item_tbl(i).item_id1 and p_line_item_tbl(i).item_id2 to them
            l_item_id1 := p_line_item_tbl(i).item_id1;
            l_item_id2 := p_line_item_tbl(i).item_id2;
            -- sjalasut, bug 4648686. END
          End If;
        End If;


        lp_clev_tbl(i).line_number := '1';
        lp_clev_tbl(i).exception_yn := 'N';
        lp_clev_tbl(i).display_sequence := 1;
        lp_clev_tbl(i).chr_id := null;
        lp_clev_tbl(i).cle_id := p_line_item_tbl(i).parent_cle_id;
        lp_clev_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;
        lp_clev_tbl(i).name := p_line_item_tbl(i).name;
--      lp_clev_tbl(i).item_description := p_line_item_tbl(i).item_description;
        lp_clev_tbl(i).id := p_line_item_tbl(i).cle_id;
        lp_clev_tbl(i).currency_code := l_currency_code;
        lp_clev_tbl(i).sts_code := l_sts_code;
        lp_clev_tbl(i).lse_id := l_lse_id;

            --Bug#4664176
            --Bug#4635028
      --IF(l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
        IF(l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then
          lp_klev_tbl(i).amount := l_amount;
          lp_klev_tbl(i).capital_amount := null;

        ELSIF(l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then
          lp_klev_tbl(i).capital_amount := p_line_item_tbl(i).capital_amount;
          lp_klev_tbl(i).amount := null;

        END IF;

        lp_klev_tbl(i).kle_id := p_line_item_tbl(i).cle_id;

        lp_cimv_tbl(i).id := p_line_item_tbl(i).item_id;
        lp_cimv_tbl(i).cle_id := p_line_item_tbl(i).cle_id;
        lp_cimv_tbl(i).cle_id_for := null;
        lp_cimv_tbl(i).chr_id := null;
        lp_cimv_tbl(i).exception_yn := 'N';
        lp_cimv_tbl(i).number_of_items := 1;
        lp_cimv_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;
        lp_cimv_tbl(i).object1_id1 := l_item_id1;
        lp_cimv_tbl(i).object1_id2 := l_item_id2;
        lp_cimv_tbl(i).jtot_object1_code := p_line_item_tbl(i).item_object1_code;

        lp_srv_cov_tbl(i).oks_cov_prod_line_id := p_line_item_tbl(i).serv_cov_prd_id;

        EXIT WHEN (i = p_line_item_tbl.LAST);
        i := p_line_item_tbl.NEXT(i);
      END LOOP;
    End If;

    If l_lty_code = 'LINK_SERV_ASSET' Then
      If( l_cnt = 0) Then -- service contract not attached
        create_contract_line_item(
          p_api_version		=> p_api_version,
          p_init_msg_list		=> p_init_msg_list,
          x_return_status 	=> x_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_clev_tbl		=> lp_clev_tbl,
          p_klev_tbl		=> lp_klev_tbl,
          p_cimv_tbl		=> lp_cimv_tbl,
          x_clev_tbl		=> lx_clev_tbl,
          x_klev_tbl		=> lx_klev_tbl,
          x_cimv_tbl		=> lx_cimv_tbl);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        END IF;
      ELSE

        okl_service_integration_pub.create_cov_asset_line(
          p_api_version		=> p_api_version,
          p_init_msg_list		=> p_init_msg_list,
          x_return_status 	=> x_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_clev_tbl		=> lp_clev_tbl,
          p_klev_tbl		=> lp_klev_tbl,
          p_cimv_tbl		=> lp_cimv_tbl,
          p_cov_tbl               => lp_srv_cov_tbl,
          x_clev_tbl		=> lx_clev_tbl,
          x_klev_tbl		=> lx_klev_tbl,
          x_cimv_tbl		=> lx_cimv_tbl);

        If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;
      End If;
    Elsif l_lty_code = 'LINK_FEE_ASSET' Then
      create_contract_line_item(
        p_api_version		=> p_api_version,
        p_init_msg_list		=> p_init_msg_list,
        x_return_status 	=> x_return_status,
        x_msg_count     	=> x_msg_count,
        x_msg_data      	=> x_msg_data,
        p_clev_tbl		=> lp_clev_tbl,
        p_klev_tbl		=> lp_klev_tbl,
        p_cimv_tbl		=> lp_cimv_tbl,
        x_clev_tbl		=> lx_clev_tbl,
        x_klev_tbl		=> lx_klev_tbl,
        x_cimv_tbl		=> lx_cimv_tbl);

      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    --Bug# 3877032
    --update capital amount field
       If lx_cimv_tbl.COUNT > 0 then
         For i in lx_cimv_tbl.FIRST..lx_cimv_tbl.LAST  Loop
           l_fee_type := null;
           open l_fee_type_csr(p_cle_id => lx_clev_tbl(i).cle_id);
           fetch l_fee_type_csr into l_fee_type;
           close l_fee_type_csr;
           if nvl(l_fee_type,'GENERAL') = 'CAPITALIZED' then
             l_fin_clev_rec.id    := lx_cimv_tbl(i).object1_id1;
             l_fin_klev_rec.id    := lx_cimv_tbl(i).object1_id1;
             OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_formula_name  => 'LINE_CAP_AMNT',
                                             p_contract_id   => lx_cimv_tbl(i).dnz_chr_id,
                                             p_line_id       => lx_cimv_tbl(i).object1_id1,
                                             x_value         => l_fin_klev_rec.capital_amount);
             If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
               raise OKC_API.G_EXCEPTION_ERROR;
             End If;

             okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_clev_rec      => l_fin_clev_rec,
                                                   p_klev_rec      => l_fin_klev_rec,
                                                   x_clev_rec      => lx_fin_clev_rec,
                                                   x_klev_rec      => lx_fin_klev_rec);
             If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
               raise OKC_API.G_EXCEPTION_ERROR;
             End If;

             --Bug# 4899328
             -- Recalculate Asset depreciation cost when there
             -- is a change to Capitalized Fee
             okl_activate_asset_pvt.recalculate_asset_cost
              (p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_chr_id        => lx_cimv_tbl(i).dnz_chr_id,
               p_cle_id        => TO_NUMBER(lx_cimv_tbl(i).object1_id1)
               );

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             --Bug# 4899328

           End If;
         End Loop;
       End If;
       --Bug# 3877032
    End If;


    If (p_line_item_tbl.COUNT > 0) Then
      i := p_line_item_tbl.FIRST;
      LOOP
        x_line_item_tbl(i).chr_id := p_line_item_tbl(i).chr_id;
        x_line_item_tbl(i).parent_cle_id := p_line_item_tbl(i).parent_cle_id;
        x_line_item_tbl(i).cle_id := lx_clev_tbl(i).id;
        x_line_item_tbl(i).item_id := lx_cimv_tbl(i).id;
        x_line_item_tbl(i).item_id1 := lx_cimv_tbl(i).object1_id1;
        x_line_item_tbl(i).item_id2 := lx_cimv_tbl(i).object1_id2;
        x_line_item_tbl(i).item_object1_code := lx_cimv_tbl(i).jtot_object1_code;
        x_line_item_tbl(i).item_description := p_line_item_tbl(i).item_description;
        x_line_item_tbl(i).name := p_line_item_tbl(i).name;
        x_line_item_tbl(i).capital_amount := p_line_item_tbl(i).capital_amount;
        x_line_item_tbl(i).serv_cov_prd_id := p_line_item_tbl(i).serv_cov_prd_id;

        EXIT WHEN (i = p_line_item_tbl.LAST);
        i := p_line_item_tbl.NEXT(i);
      END LOOP;
    End If;


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

   END;

  PROCEDURE update_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_line_item_tbl                IN  line_item_tbl_type,
      x_line_item_tbl                OUT NOCOPY line_item_tbl_type
      )  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'update_contract_line_item';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_chr_id		NUMBER;
    l_parent_cle_id		NUMBER;
    l_cnt number := 0;
    l_fee_type okl_k_lines_full_v.fee_type%type := null;
    l_amount number := null;

    l_currency_code okl_k_headers_full_v.currency_code%type := null;
    l_sts_code okl_k_headers_full_v.sts_code%type := null;
    l_lse_id   okc_line_styles_b.id%type := null;
    l_lty_code okc_line_styles_b.lty_code%type := null;
    l_item_id1 okc_k_items.object1_id1%type := null;
    l_item_id2 okc_k_items.object1_id2%type := null;

    CURSOR get_link_fee_asset_csr(p_chr_id number, p_cle_id number, p_name varchar2) IS
    SELECT ID1, ID2
    FROM OKL_LA_FEE_COVERED_ASSET_UV
    WHERE DNZ_CHR_ID = p_chr_id
    AND CLE_ID = p_cle_id
    AND NAME = p_name;

    CURSOR get_link_service_asset_csr(p_chr_id number, p_cle_id number, p_name varchar2) IS
    SELECT ID1,id2
    FROM OKL_LA_SRV_COV_AST_UV
    WHERE CHR_ID = p_chr_id
    and name = p_name;

    CURSOR is_serv_contract_csr(p_cle_id number) IS
    select count(1)
    from okc_k_rel_objs rel
    where rel.cle_id = p_cle_id and
    rel.rty_code = 'OKLSRV';

    CURSOR get_k_info_csr(p_chr_id number) IS
    SELECT currency_code,sts_code
    from okc_k_headers_v chr
    where chr.id = p_chr_id;

    CURSOR get_lse_id_csr(p_chr_id number, p_cle_id number) IS
    select lse.id,lse.lty_code
    from   okc_line_styles_b lse
    ,      okc_k_lines_b cle
    where  lse.lse_parent_id = cle.lse_id
    and    cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

    lp_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lp_cimv_tbl OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lp_klev_tbl OKL_KLE_PVT.klev_tbl_type;
    lp_srv_cov_tbl      okl_service_integration_pvt.srv_cov_tbl_type;

    lx_clev_tbl OKL_OKC_MIGRATION_PVT.clev_tbl_type;
    lx_cimv_tbl OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    lx_klev_tbl OKL_KLE_PVT.klev_tbl_type;

    l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

    --Bug# 3877032
    l_fin_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    l_fin_klev_rec    okl_contract_pub.klev_rec_type;
    lx_fin_clev_rec   okl_okc_migration_pvt.clev_rec_type;
    lx_fin_klev_rec   okl_contract_pub.klev_rec_type;

    --cursor to find out the fee type from okl_k_lines
    cursor l_fee_type_csr (p_cle_id in number) is
    select fee_type
    from   okl_k_lines kle
    where  kle.id       = p_cle_id;

    --cursor to get old asset id
    cursor l_old_ast_csr (p_cim_id in number) is
    select object1_id1, dnz_chr_id
    from   okc_k_items
    where  id = p_cim_id;

    l_fin_clev_tbl    okl_okc_migration_pvt.clev_tbl_type;
    l_fin_klev_tbl    okl_contract_pub.klev_tbl_type;
    lx_fin_clev_tbl   okl_okc_migration_pvt.clev_tbl_type;
    lx_fin_klev_tbl   okl_contract_pub.klev_tbl_type;
    j                 number;
    --Bug# 3877032

    CURSOR get_fee_type_csr(p_chr_id number, p_cle_id number) IS
    select cle.fee_type
    from   okl_k_lines_full_v cle
    where  cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

  BEGIN


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

    If (p_line_item_tbl.COUNT > 0) Then

          i := p_line_item_tbl.FIRST;

          --Bug# 4959361
          OKL_LLA_UTIL_PVT.check_line_update_allowed
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_cle_id          => p_line_item_tbl(i).cle_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          --Bug# 4959361

	  l_chr_id := p_line_item_tbl(i).chr_id;
	  If okl_context.get_okc_org_id  is null then
		okl_context.set_okc_org_context(p_chr_id => l_chr_id );
	  End If;

          open get_k_info_csr(l_chr_id);
          fetch get_k_info_csr into l_currency_code,l_sts_code;
          close get_k_info_csr;

          l_parent_cle_id := p_line_item_tbl(i).parent_cle_id;
          open get_lse_id_csr(l_chr_id,l_parent_cle_id);
          fetch get_lse_id_csr into l_lse_id,l_lty_code;
          close get_lse_id_csr;

	  l_fee_type := null;
          open get_fee_type_csr(l_chr_id,l_parent_cle_id);
          fetch get_fee_type_csr into l_fee_type;
          close get_fee_type_csr;

	  LOOP


   	  -- Not null Validation for Asset Number
   	  IF (p_line_item_tbl(i).name = OKC_API.G_MISS_CHAR OR p_line_item_tbl(i).name IS NULL) THEN

		OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
		x_return_status := OKC_API.g_ret_sts_error;
		RAISE OKC_API.G_EXCEPTION_ERROR;

   	  END IF;

          IF(l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then

            -- Not null Validation for capitol Amount
   	    IF (p_line_item_tbl(i).capital_amount IS NULL OR p_line_item_tbl(i).capital_amount = OKC_API.G_MISS_NUM) THEN

   	 	l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
		OKC_API.SET_MESSAGE(      p_app_name => g_app_name
					, p_msg_name => 'OKL_AMOUNT_FORMAT'
					, p_token1 => 'COL_NAME'
					, p_token1_value => l_ak_prompt
				   );
		x_return_status := OKC_API.g_ret_sts_error;
		RAISE OKC_API.G_EXCEPTION_ERROR;

   	    END IF;

          --Bug#4664176
          --Bug#4635028
   	  --ELSIF(l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
   	  ELSIF(l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then

	     IF( p_line_item_tbl(i).capital_amount IS NOT NULL ) Then
	       l_amount := p_line_item_tbl(i).capital_amount;
	     END IF;

            -- Not null Validation for Amount
   	    IF (l_amount IS NULL OR l_amount = OKC_API.G_MISS_NUM) THEN

   	 	l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
		OKC_API.SET_MESSAGE(      p_app_name => g_app_name
					, p_msg_name => 'OKL_AMOUNT_FORMAT'
					, p_token1 => 'COL_NAME'
					, p_token1_value => l_ak_prompt
				   );
		x_return_status := OKC_API.g_ret_sts_error;
		RAISE OKC_API.G_EXCEPTION_ERROR;

   	    END IF;

   	  END IF;

          If(l_lty_code  = 'LINK_FEE_ASSET') Then -- do the validation for fee link asset

            l_item_id1 := null;
            l_item_id2 := null;
            open get_link_fee_asset_csr(l_chr_id, l_parent_cle_id, p_line_item_tbl(i).name);
            fetch get_link_fee_asset_csr into l_item_id1, l_item_id2;
            close get_link_fee_asset_csr;

            If(l_item_id1 is null or l_item_id2 is null) Then -- through error message
              x_return_status := OKC_API.g_ret_sts_error;
              l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ASSET');
              OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
               				, p_token1 => 'COL_NAME'
	       				, p_token1_value => l_ak_prompt

              );
              raise OKC_API.G_EXCEPTION_ERROR;
            End If;

          ElsIf(l_lty_code  = 'LINK_SERV_ASSET') Then -- do the validation for service link asset

            lp_klev_tbl(i).capital_amount := p_line_item_tbl(i).capital_amount;

            l_cnt := 0;
            open is_serv_contract_csr(l_parent_cle_id);
            fetch is_serv_contract_csr into l_cnt;
            close is_serv_contract_csr;

            If( l_cnt = 0) Then -- service contract not attached

              l_item_id1 := null;
              l_item_id2 := null;
              open get_link_service_asset_csr(l_chr_id, l_parent_cle_id, p_line_item_tbl(i).name);
              fetch get_link_service_asset_csr into l_item_id1, l_item_id2;
              close get_link_service_asset_csr;

              If(l_item_id1 is null or l_item_id2 is null) Then -- through error message

                x_return_status := OKC_API.g_ret_sts_error;
                l_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_ASSET');
                OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
               				, p_token1 => 'COL_NAME'
	       				, p_token1_value => l_ak_prompt

                );
                raise OKC_API.G_EXCEPTION_ERROR;

              End If;

            End If;

          End If;

	    lp_clev_tbl(i).line_number := '1';
            lp_clev_tbl(i).exception_yn := 'N';
	    lp_clev_tbl(i).display_sequence := 1;
            lp_clev_tbl(i).chr_id := null;
            lp_clev_tbl(i).cle_id := p_line_item_tbl(i).parent_cle_id;
            lp_clev_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;
            lp_clev_tbl(i).currency_code := l_currency_code;
            lp_clev_tbl(i).sts_code := l_sts_code;
            lp_clev_tbl(i).lse_id := l_lse_id;
            lp_clev_tbl(i).name := p_line_item_tbl(i).name;
            -- lp_clev_tbl(i).item_description := p_line_item_tbl(i).item_description;
            lp_clev_tbl(i).id := p_line_item_tbl(i).cle_id;

            --Bug#4664176
            --Bug#4635028
   	    --IF(l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
   	    IF(l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then

              lp_klev_tbl(i).amount := l_amount;
              lp_klev_tbl(i).capital_amount := null;

            ELSIF(l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then

              lp_klev_tbl(i).capital_amount := p_line_item_tbl(i).capital_amount;
              lp_klev_tbl(i).amount := null;

            END IF;
            lp_klev_tbl(i).kle_id := p_line_item_tbl(i).cle_id;

            lp_cimv_tbl(i).id := p_line_item_tbl(i).item_id;
            lp_cimv_tbl(i).cle_id := p_line_item_tbl(i).cle_id;
            lp_cimv_tbl(i).cle_id_for := null;
            lp_cimv_tbl(i).chr_id := null;
            lp_cimv_tbl(i).exception_yn := 'N';
            lp_cimv_tbl(i).number_of_items := 1;
            lp_cimv_tbl(i).dnz_chr_id := p_line_item_tbl(i).chr_id;
            lp_cimv_tbl(i).object1_id1 := l_item_id1;
            lp_cimv_tbl(i).object1_id2 := l_item_id2;
            lp_cimv_tbl(i).jtot_object1_code := p_line_item_tbl(i).item_object1_code;

            lp_srv_cov_tbl(i).oks_cov_prod_line_id := p_line_item_tbl(i).serv_cov_prd_id;


          EXIT WHEN (i = p_line_item_tbl.LAST);
	         i := p_line_item_tbl.NEXT(i);
	 END LOOP;
    End If;

 If l_lty_code = 'LINK_SERV_ASSET' Then

   l_cnt := 0;
   open is_serv_contract_csr(l_parent_cle_id);
   fetch is_serv_contract_csr into l_cnt;
   close is_serv_contract_csr;

   If( l_cnt = 0) Then -- service contract not attached

   	UPDATE_CONTRACT_LINE_ITEM (
                                 p_api_version    => p_api_version,
                                 p_init_msg_list  => OKL_API.G_FALSE,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 p_clev_tbl       => lp_clev_tbl,
                                 p_klev_tbl       => lp_klev_tbl,
                                 p_cimv_tbl       => lp_cimv_tbl,
                                 x_clev_tbl       => lx_clev_tbl,
                                 x_klev_tbl       => lx_klev_tbl,
                                 x_cimv_tbl       => lx_cimv_tbl
                                );

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
   	 END IF;

   ELSE

    okl_service_integration_pub.update_cov_asset_line(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_clev_tbl		=> lp_clev_tbl,
	p_klev_tbl		=> lp_klev_tbl,
	p_cimv_tbl		=> lp_cimv_tbl,
	p_cov_tbl               => lp_srv_cov_tbl,
	x_clev_tbl		=> lx_clev_tbl,
	x_klev_tbl		=> lx_klev_tbl,
	x_cimv_tbl		=> lx_cimv_tbl);

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  End If;

 Elsif l_lty_code = 'LINK_FEE_ASSET' Then

    --Bug# 3877032
    j := 0;
    For l_old_ast_rec in l_old_ast_csr(p_cim_id => lp_cimv_tbl(i).id)
    Loop
        If nvl(l_old_ast_rec.object1_id1,okl_api.g_miss_char) <> nvl(lp_cimv_tbl(i).object1_id1,okl_api.g_miss_char) then
            l_fin_clev_tbl(j).id            := to_number(l_old_ast_rec.object1_id1);
            l_fin_klev_tbl(j).id            := to_number(l_old_ast_rec.object1_id1);
            l_fin_clev_tbl(j).dnz_chr_id    := l_old_ast_rec.dnz_chr_id;
        End If;
    End Loop;

    update_contract_line_item(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_clev_tbl		=> lp_clev_tbl,
	p_klev_tbl		=> lp_klev_tbl,
	p_cimv_tbl		=> lp_cimv_tbl,
	x_clev_tbl		=> lx_clev_tbl,
	x_klev_tbl		=> lx_klev_tbl,
	x_cimv_tbl		=> lx_cimv_tbl);

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    --Bug# 3877032
    --update capital amount field
    If lx_cimv_tbl.COUNT > 0 then
       For i in lx_cimv_tbl.FIRST..lx_cimv_tbl.LAST
       Loop

           l_fee_type := null;
           open l_fee_type_csr(p_cle_id => lx_clev_tbl(i).cle_id);
           fetch l_fee_type_csr into l_fee_type;
           close l_fee_type_csr;
           if nvl(l_fee_type,'GENERAL') = 'CAPITALIZED' then
               l_fin_clev_rec.id    := to_number(lx_cimv_tbl(i).object1_id1);
               l_fin_klev_rec.id    := to_number(lx_cimv_tbl(i).object1_id1);
               OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                               p_init_msg_list => p_init_msg_list,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_formula_name  => 'LINE_CAP_AMNT',
                                               p_contract_id   => lx_cimv_tbl(i).dnz_chr_id,
                                               p_line_id       => to_number(lx_cimv_tbl(i).object1_id1),
                                               x_value         => l_fin_klev_rec.capital_amount);
               If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	               raise OKC_API.G_EXCEPTION_ERROR;
               End If;

               okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_clev_rec      => l_fin_clev_rec,
                                                     p_klev_rec      => l_fin_klev_rec,
                                                     x_clev_rec      => lx_fin_clev_rec,
                                                     x_klev_rec      => lx_fin_klev_rec);
               If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	               raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	               raise OKC_API.G_EXCEPTION_ERROR;
               End If;

               --Bug# 4899328
               -- Recalculate Asset depreciation cost when there
               -- is a change to Capitalized Fee
               okl_activate_asset_pvt.recalculate_asset_cost
                 (p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_chr_id        => lx_cimv_tbl(i).dnz_chr_id,
                  p_cle_id        => TO_NUMBER(lx_cimv_tbl(i).object1_id1)
                 );

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
               --Bug# 4899328

           End If;
       End Loop;
   End If;

    --Bug# 3877032
    -- : for old assets
    If l_fin_klev_tbl.COUNT > 0 then
    For j in l_fin_klev_tbl.FIRST..l_fin_klev_tbl.LAST
    Loop
           OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_formula_name  => 'LINE_CAP_AMNT',
                                           p_contract_id   => l_fin_clev_tbl(j).dnz_chr_id,
                                           p_line_id       => l_fin_clev_tbl(j).id,
                                           x_value         => l_fin_klev_tbl(j).capital_amount);
               If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                       raise OKC_API.G_EXCEPTION_ERROR;
               End If;
     End Loop;

     okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_clev_tbl      => l_fin_clev_tbl,
                                           p_klev_tbl      => l_fin_klev_tbl,
                                           x_clev_tbl      => lx_fin_clev_tbl,
                                           x_klev_tbl      => lx_fin_klev_tbl);

     If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
             raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     --Bug# 4899328
     -- Recalculate Asset depreciation cost when there
     -- is a change to Capitalized Fee
     For j in l_fin_klev_tbl.FIRST..l_fin_klev_tbl.LAST
     Loop
         okl_activate_asset_pvt.recalculate_asset_cost
            (p_api_version   => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data,
             p_chr_id        => l_fin_clev_tbl(j).dnz_chr_id,
             p_cle_id        => l_fin_clev_tbl(j).id
             );

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     End Loop;
     --Bug# 4899328

    End If;
    --Bug# 3877032


 End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

  END;

  PROCEDURE create_contract_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) IS

    l_clev_rec clev_rec_type;
    l_klev_rec klev_rec_type;
    l_cimv_rec cimv_rec_type;

    l_chr_id  l_clev_rec.dnz_chr_id%type;
    l_amt_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_line_item';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR get_k_dates_csr(l_id NUMBER) IS
    select chr.start_date, chr.end_date
    from okc_k_lines_b chr
    where id = l_id;

    l_start_date okc_k_lines_b.start_date%type := null;
    l_end_date okc_k_lines_b.end_date%type := null;
    l_amount number;
    l_fee_type okl_k_lines_full_v.fee_type%type := null;

    CURSOR get_fee_type_csr(p_chr_id number, p_cle_id number) IS
    select cle.fee_type
    from   okl_k_lines_full_v cle
    where  cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

  BEGIN

    -- udhenuko Modification Start. Moving the initialization of records before checking context.
    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    l_cimv_rec := p_cimv_rec;
    l_chr_id := l_clev_rec.dnz_chr_id;

    If okl_context.get_okc_org_id  is null then
    	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;
    -- udhenuko Modification End.
/*
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
*/

    IF( l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then

      -- Not null Validation for Asset Number
      IF ((l_clev_rec.name = OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NULL) AND
      (l_klev_rec.capital_amount IS NOT NULL OR l_klev_rec.capital_amount <> OKC_API.G_MISS_NUM)) THEN
	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Not null Validation for Amount
      IF ((l_clev_rec.name <> OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NOT NULL) AND
      (l_klev_rec.capital_amount IS NULL OR l_klev_rec.capital_amount = OKC_API.G_MISS_NUM)) THEN

    	l_amt_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_AMOUNT_FORMAT'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_amt_ak_prompt
			   );
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    --Bug#4664176
    --Bug#4635028
    --ELSIF( l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
    ELSIF( l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then

     IF( l_klev_rec.capital_amount IS NOT NULL ) Then
       l_amount := l_klev_rec.capital_amount;
     ELSIF( l_klev_rec.amount IS NOT NULL ) Then
      l_amount := l_klev_rec.amount;
     END IF;

     -- Not null Validation for Asset Number
     IF ((l_clev_rec.name = OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NULL) AND
     (l_amount IS NOT NULL OR l_amount <> OKC_API.G_MISS_NUM)) THEN

	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;

     -- Not null Validation for Amount
     IF ((l_clev_rec.name <> OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NOT NULL) AND
      (l_amount IS NULL OR l_amount = OKC_API.G_MISS_NUM)) THEN

    	l_amt_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_AMOUNT_FORMAT'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_amt_ak_prompt
			   );
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;

    END IF;


    Validate_Link_Asset(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_chr_id		=> l_clev_rec.dnz_chr_id,
	p_parent_cle_id		=> l_clev_rec.cle_id,
	p_id1			=> l_cimv_rec.object1_id1,
	p_id2			=> l_cimv_rec.object1_id2,
	p_name			=> l_clev_rec.name,
	p_object_code		=> l_cimv_rec.jtot_object1_code
    );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    open get_k_dates_csr(l_clev_rec.cle_id);
    fetch get_k_dates_csr into l_start_date, l_end_date;
    close get_k_dates_csr;

    l_clev_rec.start_date := l_start_date;
    l_clev_rec.end_date := l_end_date;

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

    --
    -- call procedure in complex API
    --
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
/*
  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	x_msg_data	=> x_msg_data);
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
  END create_contract_line_item;

-- Start of comments
--
-- Procedure Name  : create_contract_line_item
-- Description     : creates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE create_contract_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'create_contract_line_item';
    l_api_version	CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
  BEGIN

/*
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
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		create_contract_line_item(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i));

	    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	       raise OKC_API.G_EXCEPTION_ERROR;
	    End If;

	   EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

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

  END create_contract_line_item;


-- Start of comments
--
-- Procedure Name  : update_contract_line_item
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type,
    x_clev_rec                     OUT NOCOPY clev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) IS

    l_clev_rec clev_rec_type;
    l_klev_rec klev_rec_type;
    l_cimv_rec cimv_rec_type;

    l_chr_id  l_clev_rec.dnz_chr_id%type;
    l_amt_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_api_name		CONSTANT VARCHAR2(30) := 'update_contract_line_item';
    l_api_version		CONSTANT NUMBER	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;

    CURSOR get_k_dates_csr(l_id NUMBER) IS
    select chr.start_date, chr.end_date
    from okc_k_lines_b chr
    where id = l_id;

    l_fee_type          okl_k_lines.fee_type%type := null;
    l_amount            NUMBER := null;
    l_start_date okc_k_lines_b.start_date%type := null;
    l_end_date okc_k_lines_b.end_date%type := null;

    CURSOR get_fee_type_csr(p_chr_id number, p_cle_id number) IS
    select cle.fee_type
    from   okl_k_lines_full_v cle
    where  cle.id = p_cle_id
    and    cle.dnz_chr_id = p_chr_id;

    -- Bug# 6598350
    CURSOR c_orig_cle_csr(p_cle_id IN NUMBER) IS
    SELECT cle.start_date
    FROM   okc_k_lines_b cle
    WHERE  cle.id = p_cle_id;

    l_orig_cle_rec c_orig_cle_csr%ROWTYPE;
  BEGIN

    -- udhenuko Modification Start. Moving the initialization of records before checking context.
    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    l_cimv_rec := p_cimv_rec;
    l_chr_id := l_clev_rec.dnz_chr_id;

    If okl_context.get_okc_org_id  is null then
    	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
    End If;
    -- udhenuko Modification End.
/*
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
*/

    l_fee_type := null;
    open get_fee_type_csr(l_chr_id,p_clev_rec.cle_id);
    fetch get_fee_type_csr into l_fee_type;
    close get_fee_type_csr;

    IF( l_fee_type is not null and l_fee_type = 'CAPITALIZED') Then

      -- Not null Validation for Asset Number
      IF ((l_clev_rec.name = OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NULL) AND
      (l_klev_rec.capital_amount IS NOT NULL OR l_klev_rec.capital_amount <> OKC_API.G_MISS_NUM)) THEN
	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Not null Validation for Amount
      IF ((l_clev_rec.name <> OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NOT NULL) AND
      (l_klev_rec.capital_amount IS NULL OR l_klev_rec.capital_amount = OKC_API.G_MISS_NUM)) THEN

    	l_amt_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_AMOUNT_FORMAT'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_amt_ak_prompt
			   );
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

    --Bug#4664176
    --Bug#4635028
    --ELSIF( l_fee_type is not null and l_fee_type in ('ROLLOVER','FINANCED')) Then
    ELSIF( l_fee_type is not null and l_fee_type <> 'CAPITALIZED') Then

     IF( l_klev_rec.capital_amount IS NOT NULL ) Then
       l_amount := l_klev_rec.capital_amount;
     ELSIF( l_klev_rec.amount IS NOT NULL ) Then
      l_amount := l_klev_rec.amount;
     END IF;

     -- Not null Validation for Asset Number
     IF ((l_clev_rec.name = OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NULL) AND
     (l_amount IS NOT NULL OR l_amount <> OKC_API.G_MISS_NUM)) THEN

	OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;

     -- Not null Validation for Amount
     IF ((l_clev_rec.name <> OKC_API.G_MISS_CHAR OR l_clev_rec.name IS NOT NULL) AND
      (l_amount IS NULL OR l_amount = OKC_API.G_MISS_NUM)) THEN

    	l_amt_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE_AMOUNT');
	OKC_API.SET_MESSAGE(      p_app_name => g_app_name
				, p_msg_name => 'OKL_AMOUNT_FORMAT'
				, p_token1 => 'COL_NAME'
				, p_token1_value => l_amt_ak_prompt
			   );
	x_return_status := OKC_API.g_ret_sts_error;
	RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;

    END IF;
/*
    Validate_Link_Asset(
	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
	x_return_status 	=> x_return_status,
	x_msg_count     	=> x_msg_count,
	x_msg_data      	=> x_msg_data,
	p_chr_id		=> l_clev_rec.dnz_chr_id,
	p_parent_cle_id		=> l_clev_rec.cle_id,
	p_id1			=> l_cimv_rec.object1_id1,
	p_id2			=> l_cimv_rec.object1_id2,
	p_name			=> l_clev_rec.name,
	p_object_code		=> l_cimv_rec.jtot_object1_code
    );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;
*/

    -- Bug# 6598350
    -- Fetch covered asset line start date for checking
    -- whether start date has been changed
    -- This check needs to be done only for
    -- Service lines
    IF l_fee_type IS NULL THEN
      OPEN c_orig_cle_csr(p_cle_id => l_clev_rec.id);
      FETCH c_orig_cle_csr INTO l_orig_cle_rec;
      CLOSE c_orig_cle_csr;
    END IF;

    open get_k_dates_csr(l_clev_rec.cle_id);
    fetch get_k_dates_csr into l_start_date, l_end_date;
    close get_k_dates_csr;

    l_clev_rec.start_date := l_start_date;
    l_clev_rec.end_date := l_end_date;

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

    -- Bug# 6598350
    -- When the service line start date is changed, update the
    -- start dates for all service sub-line payments based on
    -- the new line start date
    IF l_fee_type IS NULL THEN
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
    END IF;
    -- Bug# 6598350

/*
    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	x_msg_data	=> x_msg_data);
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
  END update_contract_line_item;


-- Start of comments
--
-- Procedure Name  : update_contract_line_item
-- Description     : updates contract line for shadowed contract
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  PROCEDURE update_contract_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_tbl                     IN  clev_tbl_type,
    p_klev_tbl                     IN  klev_tbl_type,
    p_cimv_tbl                     IN  cimv_tbl_type,
    x_clev_tbl                     OUT NOCOPY clev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'update_contract_line_item';
    l_api_version	CONSTANT NUMBER	:= 1.0;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status 	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i			NUMBER;
    l_klev_tbl   	klev_tbl_type := p_klev_tbl;
    l_cimv_tbl   	cimv_tbl_type := p_cimv_tbl;
  BEGIN
/*
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
*/

    If (p_clev_tbl.COUNT > 0) Then
	   i := p_clev_tbl.FIRST;
	   LOOP
		-- call procedure in complex API for a record
		update_contract_line_item(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status 	=> x_return_status,
			x_msg_count     	=> x_msg_count,
			x_msg_data      	=> x_msg_data,
			p_clev_rec		=> p_clev_tbl(i),
      			p_klev_rec		=> l_klev_tbl(i),
      			p_cimv_rec		=> l_cimv_tbl(i),
			x_clev_rec		=> x_clev_tbl(i),
      			x_klev_rec		=> x_klev_tbl(i),
      			x_cimv_rec		=> x_cimv_tbl(i));

    If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  raise OKC_API.G_EXCEPTION_ERROR;
    End If;

        EXIT WHEN (i = p_clev_tbl.LAST);
		i := p_clev_tbl.NEXT(i);
	   END LOOP;

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

  END update_contract_line_item;


  PROCEDURE delete_contract_line_item(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clev_rec                     IN  clev_rec_type,
    p_klev_rec                     IN  klev_rec_type,
    p_cimv_rec                     IN  cimv_rec_type) IS

   /*
   -- vthiruva, 09/01/2004
   -- START, Code change to enable Business Event
   */
   --cursor to fetch the line style code for line style id of the record.
    CURSOR lty_code_csr(p_id okc_k_lines_b.id%TYPE) IS
     SELECT lse.lty_code lty_code, items.object1_id1 asset_id
     FROM okc_line_styles_b lse, okc_k_lines_b lines, okc_k_items items
     WHERE lines.id = p_id
     AND lse.id = lines.lse_id
     AND items.cle_id = lines.id;

    CURSOR get_serv_chr_from_serv(p_chr_id okc_k_headers_b.id%TYPE,
                                  p_line_id okc_k_lines_b.id%TYPE) IS
    SELECT rlobj.object1_id1
      FROM okc_k_rel_objs_v rlobj
     WHERE rlobj.chr_id = p_chr_id
       AND rlobj.cle_id = p_line_id
       AND rlobj.rty_code = 'OKLSRV'
       AND rlobj.jtot_object1_code = 'OKL_SERVICE_LINE';

    l_service_top_line_id okc_k_lines_b.id%TYPE;

    CURSOR get_serv_cle_from_serv (p_serv_top_line_id okc_k_lines_b.id%TYPE) IS
    SELECT dnz_chr_id
      FROM okc_k_lines_b
     WHERE id = p_serv_top_line_id;

    l_serv_contract_id okc_k_headers_b.id%TYPE;

    l_lty_code okc_line_styles_b.lty_code%TYPE;
    l_asset_id okc_k_lines_b.id%TYPE;
    l_raise_business_event VARCHAR2(1) := OKL_API.G_FALSE;
    l_business_event_name WF_EVENTS.NAME%TYPE;
    l_parameter_list WF_PARAMETER_LIST_T;

   /*
   -- vthiruva, 09/01/2004
   -- END, Code change to enable Business Event
   */

    l_clev_rec clev_rec_type;
    l_klev_rec klev_rec_type;
    l_cimv_rec cimv_rec_type;

    l_api_name		CONSTANT VARCHAR2(30)     := 'delete_contract_line_item';
    l_api_version	CONSTANT NUMBER	  	  := 1.0;
    l_return_status	VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;

    --Bug# 3877032 : cursor to determine if linked asset line
    -- corresponding to CAPITALIZED fee is being deleted
    cursor l_cap_fee_asst_csr (p_cle_id in number,
                               p_cim_id in number) is
       select cim.object1_id1,
           cim.dnz_chr_id
    from   okc_k_items       cim,
           okc_k_lines_b     lnk_fee_cleb,
           okc_line_styles_b lnk_fee_lseb,
           okc_k_lines_b     fee_cleb,
           okl_k_lines       fee_kle
    where  cim.id                           = p_cim_id
    and    lnk_fee_cleb.id                  = p_cle_id
    and    cim.dnz_chr_id                   = lnk_fee_cleb.dnz_chr_id
    and    lnk_fee_cleb.lse_id              = lnk_fee_lseb.id
    and    lnk_fee_lseb.lty_code            = 'LINK_FEE_ASSET'
    and    fee_cleb.id                      = lnk_fee_cleb.cle_id
    and    fee_cleb.dnz_chr_id              = lnk_fee_cleb.dnz_chr_id
    and    fee_kle.id                       = fee_cleb.id
    and    nvl(fee_kle.fee_type,'GENERAL')  = 'CAPITALIZED';

    l_cap_fee_asst_rec l_cap_fee_asst_csr%ROWTYPE;

    l_fin_clev_tbl    okl_okc_migration_pvt.clev_tbl_type;
    l_fin_klev_tbl    okl_contract_pub.klev_tbl_type;
    lx_fin_clev_tbl   okl_okc_migration_pvt.clev_tbl_type;
    lx_fin_klev_tbl   okl_contract_pub.klev_tbl_type;
    i                 number;
    --Bug# 3877032

    --Bug# 4899328
    --cursor to check if contract is a rebook copy contract
    Cursor l_rbk_asst_csr(p_cle_id IN NUMBER) is
    Select 'Y' rbk_asst_flag
    from   okc_k_lines_b  cleb,
           okc_k_headers_b chrb
    where  chrb.id                      =   cleb.dnz_chr_id
    and    chrb.scs_code                =   'LEASE'
    and    chrb.orig_system_source_code =   'OKL_REBOOK'
    and    cleb.id                      =   p_cle_id
    and    cleb.orig_system_id1 is not NULL
    and    exists (select '1'
                   from    okc_k_headers_b orig_chrb,
                           okc_k_lines_b   orig_cleb
                   where   orig_chrb.id          = chrb.orig_system_id1
                   and     orig_cleb.id          = cleb.orig_system_id1
                   and     orig_cleb.sts_code    <> 'ABANDONED'
                   and     orig_cleb.dnz_chr_id  = orig_chrb.id);

    l_rbk_asst_rec l_rbk_asst_csr%ROWTYPE;
    --Bug# 4899328

  BEGIN
/*
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
*/

    --Bug# 4899328
    --check if user is trying to delete a covered asset line on a lease rebook copy
    l_rbk_asst_rec := Null;
    For l_rbk_asst_rec in l_rbk_asst_csr(p_cle_id => p_clev_rec.id)
    Loop
       If NVL(l_rbk_asst_rec.rbk_asst_flag,'N') = 'Y' then
           OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                               p_msg_name      => 'OKL_LA_RBK_COV_ASSET_DELETE');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;
       End If;
    End Loop;
    --Bug# 4899328

       --Bug# 3877032
     i := 0;
     For l_cap_fee_asst_rec in l_cap_fee_asst_csr (p_cle_id => p_clev_rec.id,
                                                    p_cim_id => p_cimv_rec.id)
     Loop
               i := i+1;
               l_fin_clev_tbl(i).id            := to_number(l_cap_fee_asst_rec.object1_id1);
               l_fin_klev_tbl(i).id            := to_number(l_cap_fee_asst_rec.object1_id1);
               l_fin_clev_tbl(i).dnz_chr_id    := l_cap_fee_asst_rec.dnz_chr_id;
     End Loop;
     --Bug# 3877032


    l_klev_rec := p_klev_rec;
    l_clev_rec := p_clev_rec;
    l_cimv_rec := p_cimv_rec;

   /*
   -- vthiruva, 09/01/2004
   -- START, Code change to enable Business Event
   */
    --fetch the line style code for the record
    Open  lty_code_csr(p_id => p_clev_rec.id);
        Fetch lty_code_csr into l_lty_code, l_asset_id;
    Close lty_code_csr;
   /*
   -- vthiruva, 09/01/2004
   -- END, Code change to enable Business Event
   */

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

       --Bug# 3877032
    If l_fin_klev_tbl.COUNT > 0 then
    For i in l_fin_klev_tbl.FIRST..l_fin_klev_tbl.LAST
    Loop
           OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_formula_name  => 'LINE_CAP_AMNT',
                                           p_contract_id   => l_fin_clev_tbl(i).dnz_chr_id,
                                           p_line_id       => l_fin_clev_tbl(i).id,
                                           x_value         => l_fin_klev_tbl(i).capital_amount);
               If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                       raise OKC_API.G_EXCEPTION_ERROR;
               End If;
     End Loop;

     okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_clev_tbl      => l_fin_clev_tbl,
                                           p_klev_tbl      => l_fin_klev_tbl,
                                           x_clev_tbl      => lx_fin_clev_tbl,
                                           x_klev_tbl      => lx_fin_klev_tbl);

     If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
             raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     --Bug# 4899328
     -- Recalculate Asset depreciation cost when there
     -- is a change to Capitalized Fee
     For i in l_fin_klev_tbl.FIRST..l_fin_klev_tbl.LAST
     Loop
       okl_activate_asset_pvt.recalculate_asset_cost
         (p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_chr_id        => l_fin_clev_tbl(i).dnz_chr_id,
          p_cle_id        => l_fin_clev_tbl(i).id
          );

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     End Loop;
     --Bug# 4899328

    End If;
    --Bug# 3877032

   /*
   -- vthiruva, 09/01/2004
   -- START, Code change to enable Business Event
   */
    IF(l_lty_code = 'LINK_FEE_ASSET')THEN
      l_raise_business_event := OKL_API.G_TRUE;
      l_business_event_name := G_WF_EVT_ASSET_FEE_REMOVED;
      wf_event.AddParameterToList(G_WF_ITM_FEE_LINE_ID, l_clev_rec.cle_id, l_parameter_list);
    ELSIF(l_lty_code = 'LINK_SERV_ASSET')THEN
      l_raise_business_event := OKL_API.G_TRUE;
      l_business_event_name := G_WF_EVT_ASSET_SERV_FEE_RMVD;
      wf_event.AddParameterToList(G_WF_ITM_SERV_LINE_ID, l_clev_rec.cle_id, l_parameter_list);
      -- check if the service line in context has a service contract associated with it
      -- if so, pass the service contract id and service contract line id as parameters
      OPEN get_serv_chr_from_serv(l_clev_rec.dnz_chr_id, l_clev_rec.cle_id);
      FETCH get_serv_chr_from_serv INTO l_service_top_line_id;
      CLOSE get_serv_chr_from_serv;
      IF(l_service_top_line_id IS NOT NULL)THEN
        OPEN get_serv_cle_from_serv(l_service_top_line_id);
        FETCH get_serv_cle_from_serv INTO l_serv_contract_id;
        CLOSE get_serv_cle_from_serv;
        wf_event.AddParameterToList(G_WF_ITM_SERV_CHR_ID, l_serv_contract_id, l_parameter_list);
        wf_event.AddParameterToList(G_WF_ITM_SERV_CLE_ID, l_service_top_line_id, l_parameter_list);
      END IF;
    END IF;

    IF(l_raise_business_event = OKL_API.G_TRUE AND l_business_event_name IS NOT NULL AND
       OKL_LLA_UTIL_PVT.is_lease_contract(l_clev_rec.dnz_chr_id)= OKL_API.G_TRUE)THEN
      wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID, l_clev_rec.dnz_chr_id, l_parameter_list);
      wf_event.AddParameterToList(G_WF_ITM_ASSET_ID, l_asset_id, l_parameter_list);
      raise_business_event(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_event_name     => l_business_event_name,
                           p_event_param_list => l_parameter_list);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   /*
   -- vthiruva, 09/01/2004
   -- END, Code change to enable Business Event
   */

/*
    OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	x_msg_data	=> x_msg_data);
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
  END delete_contract_line_item;

  -- Start of comments
  --
  -- Procedure Name  : delete_contract_line_item
  -- Description     : deletes contract line for shadowed contract
  -- Business Rules  : line can be deleted only if there is no sublines attached
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
    PROCEDURE delete_contract_line_item(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clev_tbl                     IN  clev_tbl_type,
      p_klev_tbl                     IN  klev_tbl_type,
      p_cimv_tbl                     IN  cimv_tbl_type) IS

      l_api_name		CONSTANT VARCHAR2(30) := 'delete_contract_line_item';
      l_api_version		CONSTANT NUMBER	:= 1.0;
      l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_overall_status 		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i				NUMBER;
      l_klev_tbl   		klev_tbl_type := p_klev_tbl;
      l_cimv_tbl   		cimv_tbl_type := p_cimv_tbl;
    BEGIN
/*
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
*/

      If (p_clev_tbl.COUNT > 0) Then
  	   i := p_clev_tbl.FIRST;
  	   LOOP
  		-- call procedure in complex API for a record
  		delete_contract_line_item(
  			p_api_version		=> p_api_version,
  			p_init_msg_list		=> p_init_msg_list,
  			x_return_status 	=> x_return_status,
  			x_msg_count     	=> x_msg_count,
  			x_msg_data      	=> x_msg_data,
  			p_clev_rec		=> p_clev_tbl(i),
        		p_klev_rec		=> l_klev_tbl(i),
        		p_cimv_rec		=> l_cimv_tbl(i));

	      If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
	  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
	  	  raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

          EXIT WHEN (i = p_clev_tbl.LAST);
  		i := p_clev_tbl.NEXT(i);
  	   END LOOP;

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

    END delete_contract_line_item;

END OKL_CONTRACT_LINE_ITEM_PVT;

/
