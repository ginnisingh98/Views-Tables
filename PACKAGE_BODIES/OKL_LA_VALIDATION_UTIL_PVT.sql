--------------------------------------------------------
--  DDL for Package Body OKL_LA_VALIDATION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_VALIDATION_UTIL_PVT" as
/* $Header: OKLPDVUB.pls 120.14.12010000.2 2009/12/19 00:13:54 gkadarka ship $ */

   G_RLE_CODE  VARCHAR2(10) := 'LESSEE';

--Added by kthiruva 23-Sep-2003 Bug 3156265

--For Object Code 'OKX_SALEPERS'

  CURSOR okx_salepers_csr(p_name VARCHAR2 ,p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
--Start modified abhsaxen for performance SQLID 20562570
	SELECT srv.SALESREP_ID ID1,
		 '#' ID2,
		 srv.NAME NAME,
		 NULL DESCRIPTION
	  FROM JTF_RS_SALESREPS_MO_V srv
	  WHERE srv.ORG_ID = mo_global.get_current_org_id
	  AND   srv.name = p_name
	  AND   srv.SALESREP_ID = NVL(p_id1,srv.SALESREP_ID)
	  AND   '#'  = NVL(p_id2,'#')
	  ORDER BY srv.NAME
	--end modified abhsaxen for performance SQLID 20562570
	;
-- For Object Code 'OKX_PCONTACT'

  CURSOR okx_pcontact_csr(p_name VARCHAR2 ,p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT pcv.ID1,
         pcv.ID2,
         pcv.NAME,
         pcv.DESCRIPTION
  FROM okx_party_contacts_v pcv
  WHERE pcv.name = NVL(p_name,pcv.name)
  AND   pcv.ID1  = NVL(p_id1,pcv.ID1)
  AND   pcv.ID2  = NVL(p_id2,pcv.ID2)
  ORDER BY pcv.NAME;


--For Object Code 'OKX_PARTY'
  CURSOR okx_party_csr(p_name VARCHAR2 , p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562584
	select prv.id1,
		 prv.id2,
		 prv.name,
		 prv.description
	  from  okx_parties_v prv
	  where prv.name = p_name
	  and   prv.id1  = nvl(p_id1,prv.id1)
	  and   prv.id2  = nvl(p_id2,prv.id2)
	  order by prv.name
	--end modified abhsaxen for performance SQLID 20562584
	;
--For Object Code 'OKX_OPERUNIT'
  CURSOR okx_operunit_csr(p_name VARCHAR2 , p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT ord.id1,
         ord.id2,
         ord.name,
         ord.description
  FROM  okx_organization_defs_v ord
  WHERE ord.organization_type = 'OPERATING_UNIT'
  AND   ord.information_type = 'Operating Unit Information'
  AND   ord.name = NVL(p_name,ord.name)
  AND   ord.id1  = NVL(p_id1,ord.id1)
  AND   ord.id2  = NVL(p_id2,ord.id2)
  ORDER BY ord.NAME;


 --For Object Code 'OKX_VENDOR'
  CURSOR okx_vendor_csr(p_name VARCHAR2 , p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562594
	SELECT  vev.id1,
		  vev.id2,
		  vev.name,
		  vev.description
	  FROM okx_vendors_v vev
	  WHERE vev.name = p_name
	  AND   vev.id1  = NVL(p_id1,vev.id1)
	  AND   vev.id2  = NVL(p_id2,vev.id2)
	  ORDER BY vev.NAME
	--end modified abhsaxen for performance SQLID 20562594
	;
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

CURSOR okl_usage_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562604
	select ulvb.id id1,
	       '#' id2,
	       ulv.name,
	       ulv.item_description description
	from okc_k_lines_b ulvb,
	      okc_k_lines_tl ulv
	where ulv.name = p_name
	and   ulvb.id  = nvl(p_id1,ulvb.id)
	and   '#' = nvl(p_id2,'#')
	and ulvb.id = ulv.id
	and ulv.language =USERENV('LANG')
	order by ulv.name
	--end modified abhsaxen for performance SQLID 20562604
	;
-- For Object Code 'OKX_ASSET'

CURSOR okx_asset_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562609
	select asv.id1,
	       asv.id2,
	       asv.name,
	       asv.description
	from okx_assets_v asv
	where asv.name = p_name
	and   asv.id1  = nvl(p_id1,asv.id1)
	and   asv.id2  = nvl(p_id2,asv.id2)
	order by asv.name
	--end modified abhsaxen for performance SQLID 20562609
	;
-- For Object Code 'OKX_COVASST'

CURSOR okx_covasst_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562614
	select cas.id1,
	       cas.id2,
	       cas.name,
	       cas.description
	from okx_covered_asset_v cas
	where   cas.name = p_name
	and   cas.id1  = nvl(p_id1,cas.id1)
	and   cas.id2  = nvl(p_id2,cas.id2)
	order by cas.name
	--end modified abhsaxen for performance SQLID 20562614
	;

-- For Object Code 'OKX_IB_ITEM'

CURSOR okx_ib_item_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562621
	select itv.id1,
	       itv.id2,
	       itv.name,
	       itv.description
	from okx_install_items_v itv
	where itv.name = p_name
	and   itv.id1  = nvl(p_id1,itv.id1)
	and   itv.id2  = nvl(p_id2,itv.id2)
	order by itv.name
	--end modified abhsaxen for performance SQLID 20562621
	;



-- For Object Code 'OKX_LEASE'

CURSOR okx_lease_csr(p_name VARCHAR2,p_id1 VARCHAR2 ,p_id2 VARCHAR2) IS
SELECT cnt.id1,
       cnt.id2,
       cnt.name,
       cnt.description
FROM OKX_CONTRACTS_V cnt
WHERE cnt.SCS_CODE IN ('LEASE','LOAN')
AND   NVL(cnt.ORG_ID, -99) = mo_global.get_current_org_id
AND   cnt.name = NVL(p_name,cnt.name)
AND   cnt.id1  = NVL(p_id1,cnt.id1)
AND   cnt.id2  = NVL(p_id2,cnt.id2)
ORDER BY cnt.NAME;

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


FUNCTION GET_AK_PROMPT(p_ak_region    IN VARCHAR2, p_ak_attribute    IN VARCHAR2)

  RETURN VARCHAR2 IS



    CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	--start modified abhsaxen for performance SQLID 20562645
	    select a.attribute_label_long
	 from ak_region_items ri, ak_regions r, ak_attributes_vl a
	 where ri.region_code = r.region_code
	 and ri.region_application_id = r.region_application_id
	 and ri.attribute_code = a.attribute_code
	 and ri.attribute_application_id = a.attribute_application_id
	 and ri.region_code  =  p_ak_region
	 and ri.attribute_code = p_ak_attribute
	--end modified abhsaxen for performance SQLID 20562645
	;


      l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;

  BEGIN
      OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
      FETCH ak_prompt_csr INTO l_ak_prompt;
      CLOSE ak_prompt_csr;
      return(l_ak_prompt);
  END;



  FUNCTION GET_RLE_CODE_MEANING(p_rle_code    IN VARCHAR2, p_chr_id NUMBER)
  RETURN VARCHAR2 IS

      CURSOR l_rle_code_meaning_csr
      IS
        select fnd.meaning
        from   okc_subclass_roles sur,
               okc_k_headers_b    chr,
               fnd_lookup_values  fnd
        where  fnd.lookup_code = sur.rle_code
        and    sur.rle_code  = p_rle_code
        and    fnd.lookup_type = 'OKC_ROLE'
        and    fnd.language = userenv('LANG')
        and    sur.scs_code = chr.scs_code
        and    chr.id = p_chr_id
        and    nvl(sur.start_date,sysdate) <= sysdate
        and    nvl(sur.end_date,sysdate+1) > sysdate;



      l_rle_code_meaning fnd_lookup_values.meaning%TYPE;

  BEGIN

      OPEN l_rle_code_meaning_csr;
      FETCH l_rle_code_meaning_csr INTO l_rle_code_meaning;
      CLOSE l_rle_code_meaning_csr;
      return(l_rle_code_meaning);

  END;






Procedure Get_Rule_Jtot_Metadata (p_api_version          IN    NUMBER,
                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY    VARCHAR2,
                     x_msg_count       OUT  NOCOPY    NUMBER,
                     x_msg_data               OUT  NOCOPY    VARCHAR2,
                     p_chr_id              IN    NUMBER,
                     p_rgd_code            IN   VARCHAR2,
                     p_rdf_code            IN   VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_id1                 IN   VARCHAR2,
                     p_id2                 IN   VARCHAR2,
                     x_select_clause       OUT  NOCOPY VARCHAR2,
                     x_from_clause         OUT  NOCOPY VARCHAR2,
                     x_where_clause        OUT  NOCOPY VARCHAR2,
                     x_order_by_clause     OUT  NOCOPY VARCHAR2,
                     x_object_code         OUT  NOCOPY VARCHAR2) is


CURSOR  jtf_rule_cur (p_chr_id NUMBER, p_rgd_code VARCHAR2, p_rdf_code VARCHAR2) is



select job.object_code OBJECT_CODE,job.object_code||'.ID1, '||job.object_code||'.ID2, '||
       job.object_code||'.NAME, '||job.object_code||'.DESCRIPTION ' SELECT_CLAUSE,
       from_table FROM_CLAUSE,where_clause WHERE_CLAUSE,order_by_clause ORDER_BY_CLAUSE
from   okc_k_headers_b chr,
okc_subclass_rg_defs rgdfsrc,
OKC_RULE_DEF_SOURCES rdfsrc,
jtf_objects_b job
where job.object_code = rdfsrc.jtot_object_code
and   nvl(job.start_date_active,sysdate) <= sysdate
and   nvl(job.end_date_active,sysdate + 1) > sysdate
and   chr.id = p_chr_id
and   chr.scs_code = rgdfsrc.scs_code
and   rgdfsrc.rgd_code = p_rgd_code -- 'LACAN'
and   rdfsrc.rgr_rgd_code = p_rgd_code -- 'LACAN'
and   rdfsrc.rgr_rdf_code = p_rdf_code -- 'CAN'
and   chr.buy_or_sell = rdfsrc.buy_or_sell
and   rdfsrc.object_id_number = 1
and   nvl(rgdfsrc.start_date,sysdate) <= sysdate
and   nvl(rgdfsrc.end_date,sysdate + 1) > sysdate
and   nvl(rdfsrc.start_date,sysdate) <= sysdate
and   nvl(rdfsrc.end_date,sysdate + 1) > sysdate;



jtf_rule_rec jtf_rule_cur%rowtype;


l_query_string    VARCHAR2(2000)                 default Null;
l_where_clause    VARCHAR2(2000)                 default Null;
l_from_clause     jtf_objects_b.from_table%type         default Null;



Begin



    Open jtf_rule_cur(p_chr_id, p_rgd_code, p_rdf_code);
         Fetch jtf_rule_cur into jtf_rule_rec;
         If jtf_rule_cur%NOTFOUND Then
             x_object_code     := null;
             x_select_clause   := null;
             x_from_clause     := null;
             x_where_clause    := null;
             x_order_by_clause := null;
         Else
             x_object_code     := jtf_rule_rec.object_code;
             x_select_clause   := jtf_rule_rec.select_clause;
             x_from_clause     := jtf_rule_rec.from_clause;
             x_where_clause    := jtf_rule_rec.where_clause;
             x_order_by_clause := jtf_rule_rec.order_by_clause;
             If ( p_name is not null and p_name <> OKC_API.G_MISS_CHAR) then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' DESCRIPTION like :name'
                into   l_where_clause
                from   dual;
                x_where_clause := l_where_clause;
             End If;

             If p_id1 is not null and p_id1 <> OKC_API.G_MISS_CHAR
                     and p_id2 is not null and p_id2 <> OKC_API.G_MISS_CHAR then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' ID1 = '||''''||p_id1||''''||' AND '||' ID2 = '||''''||p_id2||''''
                into   l_where_clause
                from   dual;
                x_where_clause := l_where_clause;
             End If;
         End If;
     Close jtf_rule_cur;

End Get_Rule_Jtot_Metadata;


--Start of Comments
--Procedure   : Validate_Item
--Description : Returns Name, Description for a given role or all the roles
--              attached to a contract
--End of Comments

Procedure Validate_Rule (p_api_version    IN        NUMBER,
                         p_init_msg_list       IN        VARCHAR2 default OKC_API.G_FALSE,
                         x_return_status       OUT      NOCOPY    VARCHAR2,
                         x_msg_count       OUT      NOCOPY    NUMBER,
                         x_msg_data               OUT      NOCOPY    VARCHAR2,
                         p_chr_id              IN        NUMBER,
                         p_rgd_code            IN           VARCHAR2,
                         p_rdf_code            IN           VARCHAR2,
                         p_id1                   IN OUT   NOCOPY    VARCHAR2,
                         p_id2                 IN OUT   NOCOPY    VARCHAR2,
                         p_name                IN       VARCHAR2,
                         p_object_code         IN OUT  NOCOPY    VARCHAR2,
                         p_ak_region           IN           VARCHAR2,
                         p_ak_attribute        IN           VARCHAR2

                     ) is

l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;



l_id1               OKC_RULES_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_RULES_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_description       VARCHAR2(250) Default Null;

l_object_code       VARCHAR2(30) Default Null;



l_id11            OKC_RULES_V.OBJECT1_ID1%TYPE default Null;
l_id22            OKC_RULES_V.OBJECT1_ID2%TYPE default Null;



type              rule_curs_type is REF CURSOR;
rule_curs         rule_curs_type;

row_count         Number default 0;
l_chr_id      okl_k_headers.id%type;
l_rdf_code        okc_rules_v.rule_information_category%type;
l_rgd_code        okc_rule_groups_v.rgd_code%type;


l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Rule';
l_api_version      CONSTANT NUMBER    := 1.0;



--x_return_status       := OKC_API.G_RET_STS_SUCCESS;



ERR_MSG           VARCHAR2(50) := 'DEFAULT';



CURSOR check_rule_csr(p_chr_id NUMBER, p_rgd_code VARCHAR2, p_rdf_code VARCHAR2, p_id1 VARCHAR2, p_id2 VARCHAR2) IS
select count(1)
from okc_rule_groups_v rgp, okc_rules_v rul
where rgp.id = rul.rgp_id
and rgp.rgd_code = p_rgd_code
and rul.rule_information_category = p_rdf_code
and rgp.dnz_chr_id = p_chr_id
and rgp.chr_id = p_chr_id
and rul.dnz_chr_id = p_chr_id
and rul.object1_id1 = p_id1
and rul.object1_id2 = p_id2;



-- CURSOR get_rule_csr(p_cpl_id NUMBER) IS

-- SELECT rul.object1_id1, object1_id2

-- FROM okc_k_party_roles_v

-- WHERE id = p_cpl_id;


l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;



Begin

  If okl_context.get_okc_org_id  is null then
    l_chr_id := p_chr_id;
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



  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_chr_id');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_rgd_code is null or p_rgd_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_rgd_code');
      raise OKC_API.G_EXCEPTION_ERROR;

  ElsIf ( p_rdf_code is null or p_rdf_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_rdf_code');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_name');
      raise OKC_API.G_EXCEPTION_ERROR;
--      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;

  Get_Rule_Jtot_Metadata ( p_api_version         => p_api_version ,
                           p_init_msg_list   => p_init_msg_list ,
                         x_return_status   => x_return_status ,
                         x_msg_count       => x_msg_count ,
                         x_msg_data      => x_msg_data ,
                         p_chr_id          => p_chr_id ,
                         p_rgd_code        => p_rgd_code ,
                         p_rdf_code        => p_rdf_code ,
                         p_name            => p_name ,
                         p_id1             => l_id1 ,
                         p_id2             => l_id2 ,
                         x_select_clause   => l_select_clause ,
                         x_from_clause     => l_from_clause ,
                         x_where_clause    => l_where_clause ,
                         x_order_by_clause => l_order_by_clause ,
                         x_object_code     => l_object_code);
  p_object_code  := l_object_code;


  l_query_string := 'SELECT '||ltrim(rtrim(l_select_clause,' '),' ')||' '||
                    'FROM '||ltrim(rtrim(l_from_clause,' '),' ')||' '||
                    'WHERE '||ltrim(rtrim(l_where_clause,' '),' ');


  Open rule_curs for l_query_string using p_name;
         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;

   Fetch rule_curs into  l_id1,l_id2,l_name,l_description;
   If rule_curs%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;
      l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
      OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;


    l_id11 := l_id1;
    l_id22 := l_id2;

    Fetch rule_curs into  l_id1,l_id2,l_name,l_description;

    If rule_curs%Found Then
        If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
            OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                 , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
            x_return_status := OKC_API.g_ret_sts_error;
            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
             OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



       If(l_id11 = p_id1 and l_id22 = p_id2) Then

          row_count := 1;

       Else

        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then
             l_id11 := l_id1;
             l_id22 := l_id2;
            row_count := 1;
            Exit;
         End If;
         Fetch rule_curs into  l_id1,l_id2,l_name,l_description;
         Exit When rule_curs%NotFound;
        End Loop;
       End If;

    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

         l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

         OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;



  Close rule_curs;

/*

  If p_lty_code is null or p_lty_code =  OKC_API.G_MISS_CHAR  Then



    If p_cpl_id is null or p_cpl_id =  OKC_API.G_MISS_NUM  Then

      OPEN check_rule_csr(p_chr_id, p_rle_code, p_id1, p_id2 );

      FETCH check_rule_csr INTO row_count;

      CLOSE check_rule_csr;

      If row_count = 1 Then

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_name_already_exists');

         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

    Else

      OPEN get_rule_csr(p_cpl_id );

      FETCH get_rule_csr INTO l_rle_code, l_id1, l_id2;

      CLOSE get_rule_csr;



      If l_rle_code = p_rle_code and l_id1 <> p_id1 Then

          OPEN check_rule_csr(p_chr_id, p_rle_code, p_id1, p_id2);

          FETCH check_rule_csr INTO row_count;

          CLOSE check_rule_csr;

           If row_count = 1 Then

           x_return_status := OKC_API.g_ret_sts_error;

          OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_name_already_exists');

          raise OKC_API.G_EXCEPTION_ERROR;

         End If;

      End If;

    End If;



  End If;

*/

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
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

     IF rule_curs%ISOPEN THEN
         CLOSE rule_curs;
     END IF;

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

End Validate_Rule;

--Added by dpsingh for LE Uptake
--Start of Comments

--Procedure   : Validate_Legal_Entity

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments
Procedure Validate_Legal_Entity(
                                                x_return_status     OUT     NOCOPY    VARCHAR2,
                                                p_chrv_rec            IN         OKL_OKC_MIGRATION_PVT.CHRV_REC_TYPE,
						p_mode IN VARCHAR2) IS

CURSOR check_upd_le_fund_csr (p_khr_id NUMBER) IS
SELECT 1
FROM OKL_TRX_AP_INVOICES_B
WHERE KHR_ID = p_khr_id
AND FUNDING_TYPE_CODE IS NOT NULL
AND TRX_STATUS_CODE <> 'CANCELED';

CURSOR check_upd_le_adv_rcpt_csr (p_khr_id NUMBER) IS
SELECT 1
FROM OKL_TRX_CSH_RECEIPT_B A,
OKL_TXL_RCPT_APPS_B B
WHERE A.ID = B.RCT_ID_DETAILS
AND A.RECEIPT_TYPE = 'ADV'
AND B.KHR_ID = p_khr_id;

CURSOR check_upd_le_ins_qte_csr (p_khr_id NUMBER) IS
SELECT 1
FROM OKL_INS_POLICIES_B
WHERE KHR_ID =p_khr_id;

l_exists                       NUMBER(1);
l_not_upd              NUMBER;

BEGIN
x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_exists  := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_chrv_rec.legal_entity_id) ;

     IF (l_exists<>1) THEN
          Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF p_mode = 'UPD'
     THEN
       OPEN check_upd_le_fund_csr(p_chrv_rec.id);
       FETCH check_upd_le_fund_csr INTO l_not_upd;
       CLOSE check_upd_le_fund_csr;
       IF l_not_upd = 1 THEN
            OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                                    p_msg_name => 'OKL_LA_LE_UPD_FUND');
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       OPEN check_upd_le_adv_rcpt_csr(p_chrv_rec.id);
       FETCH check_upd_le_adv_rcpt_csr INTO l_not_upd;
       CLOSE check_upd_le_adv_rcpt_csr;
        IF l_not_upd = 1 THEN
            OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                                    p_msg_name => 'OKL_LA_LE_UPD_ADV_RCPT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       OPEN check_upd_le_ins_qte_csr(p_chrv_rec.id);
       FETCH check_upd_le_ins_qte_csr INTO l_not_upd;
       CLOSE check_upd_le_ins_qte_csr;
        IF l_not_upd = 1 THEN
            OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                                    p_msg_name => 'OKL_LA_LE_UPD_INS_QT');
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.G_RET_STS_ERROR;

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
               x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS then
               x_return_status := OKL_API.G_RET_STS_ERROR;
END Validate_Legal_Entity;

--Start of Comments

--Procedure   : Validate_Item

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments

Procedure Validate_Contact (p_api_version    IN        NUMBER,
                     p_init_msg_list       IN        VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT      NOCOPY    VARCHAR2,
                     x_msg_count       OUT      NOCOPY    NUMBER,
                     x_msg_data               OUT      NOCOPY    VARCHAR2,
                     p_chr_id              IN        NUMBER,
                     p_rle_code            IN           VARCHAR2,
                     p_cro_code            IN           VARCHAR2,
                     p_id1                   IN OUT   NOCOPY    VARCHAR2,
                     p_id2                 IN OUT   NOCOPY    VARCHAR2,
                     p_name                IN       VARCHAR2,
                     p_object_code         IN OUT  NOCOPY    VARCHAR2,
                     p_ak_region           IN           VARCHAR2,
                     p_ak_attribute        IN           VARCHAR2
                     ) is

l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;



l_id1               OKC_RULES_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_RULES_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_description       VARCHAR2(250) Default Null;
l_object_code       VARCHAR2(30) Default Null;



l_id11            OKC_RULES_V.OBJECT1_ID1%TYPE default Null;
l_id22            OKC_RULES_V.OBJECT1_ID2%TYPE default Null;



type              contact_curs_type is REF CURSOR;
contact_curs      contact_curs_type;



row_count         Number default 0;



l_chr_id      okl_k_headers.id%type;
l_rdf_code        okc_rules_v.rule_information_category%type;
l_rgd_code        okc_rule_groups_v.rgd_code%type;



l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Contact';
l_api_version      CONSTANT NUMBER    := 1.0;



--x_return_status       := OKC_API.G_RET_STS_SUCCESS;



ERR_MSG           VARCHAR2(50) := 'DEFAULT';



CURSOR check_rule_csr(p_chr_id NUMBER, p_rgd_code VARCHAR2, p_rdf_code VARCHAR2, p_id1 VARCHAR2, p_id2 VARCHAR2) IS

select count(1)
from okc_rule_groups_v rgp, okc_rules_v rul
where rgp.id = rul.rgp_id
and rgp.rgd_code = p_rgd_code
and rul.rule_information_category = p_rdf_code
and rgp.dnz_chr_id = p_chr_id
and rgp.chr_id = p_chr_id
and rul.dnz_chr_id = p_chr_id
and rul.object1_id1 = p_id1
and rul.object1_id2 = p_id2;


-- CURSOR get_rule_csr(p_cpl_id NUMBER) IS

-- SELECT rul.object1_id1, object1_id2

-- FROM okc_k_party_roles_v

-- WHERE id = p_cpl_id;








l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;




Begin



  If okl_context.get_okc_org_id  is null then

    l_chr_id := p_chr_id;

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



  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)

  Then

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_chr_id');

      raise OKC_API.G_EXCEPTION_ERROR;

  ElsIf ( p_rle_code is null or p_rle_code =  OKC_API.G_MISS_CHAR)

  Then

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_rle_code');

      raise OKC_API.G_EXCEPTION_ERROR;

  ElsIf ( p_cro_code is null or p_cro_code =  OKC_API.G_MISS_CHAR)

  Then

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_cro_code');

      raise OKC_API.G_EXCEPTION_ERROR;

  ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)

  Then

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_name');

        raise OKC_API.G_EXCEPTION_ERROR;

  End If;



  If okl_context.get_okc_org_id  is null then

    l_chr_id := p_chr_id;

    okl_context.set_okc_org_context(p_chr_id => l_chr_id );

  End If;
--Added by kthiruva 23-Sep-2003 Bug No.3156265

    IF (p_rle_code = 'LESSOR' and p_cro_code = 'SALESPERSON') THEN

        OPEN okx_salepers_csr(p_name =>p_name,
                              p_id1  =>l_id1 ,
                              p_id2  =>l_id2);
        Fetch okx_salepers_csr into  l_id1,l_id2,l_name,l_description;

        If okx_salepers_csr%NotFound Then

            x_return_status := OKC_API.g_ret_sts_error;

            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

            OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                         , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'

                    , p_token1 => 'COL_NAME'

                    , p_token1_value => l_ak_prompt



                             );

            raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        l_id11 := l_id1;

        l_id22 := l_id2;


        Fetch okx_salepers_csr into  l_id1,l_id2,l_name,l_description;

        If okx_salepers_csr%Found Then

              If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

               x_return_status := OKC_API.g_ret_sts_error;

               l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

               OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

               raise OKC_API.G_EXCEPTION_ERROR;

           End If;

              If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

              x_return_status := OKC_API.g_ret_sts_error;

              l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

              OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

              raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If (l_id11 = p_id1 and l_id22 = p_id2) Then

              row_count := 1;

           Else

               Loop

                  If(l_id1 = p_id1 and l_id2 = p_id2) Then

                   l_id11 := l_id1;
                      l_id22 := l_id2;

                   row_count := 1;

                  Exit;

                  End If;

                  Fetch okx_salepers_csr into  l_id1,l_id2,l_name,l_description;

                  Exit When okx_salepers_csr%NotFound;

                End Loop;

          End If;

          If row_count <> 1 Then

        x_return_status := OKC_API.g_ret_sts_error;

            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

            OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                         , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'

                    , p_token1 => 'COL_NAME'

                    , p_token1_value => l_ak_prompt

                     );

            raise OKC_API.G_EXCEPTION_ERROR;

       End If;

           End If;

           p_id1 := l_id11;
        p_id2 := l_id22;

        Close okx_salepers_csr;

     ELSE

     OPEN okx_pcontact_csr(p_name =>p_name,
                              p_id1  =>l_id1,
                              p_id2  =>l_id2);

        Fetch okx_pcontact_csr into  l_id1,l_id2,l_name,l_description;

        If okx_pcontact_csr%NotFound Then

            x_return_status := OKC_API.g_ret_sts_error;

            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

            OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                         , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'

                    , p_token1 => 'COL_NAME'

                    , p_token1_value => l_ak_prompt



                             );

            raise OKC_API.G_EXCEPTION_ERROR;

         End If;

         l_id11 := l_id1;

         l_id22 := l_id2;

         Fetch okx_pcontact_csr into  l_id1,l_id2,l_name,l_description;

         If okx_pcontact_csr%Found Then

                If ( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

                x_return_status := OKC_API.g_ret_sts_error;

                l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

                OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

                raise OKC_API.G_EXCEPTION_ERROR;

            End If;

              If (p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

                 x_return_status := OKC_API.g_ret_sts_error;

                 l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

                 OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

                 raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If (l_id11 = p_id1 and l_id22 = p_id2) Then

                row_count := 1;

           Else

             Loop

               If (l_id1 = p_id1 and l_id2 = p_id2) Then

                      l_id11 := l_id1;

                      l_id22 := l_id2;

                     row_count := 1;

                      Exit;

                End If;

                Fetch okx_pcontact_csr into  l_id1,l_id2,l_name,l_description;

                Exit when okx_pcontact_csr%NotFound;

            End Loop;

          End If;


      If row_count <> 1 Then

        x_return_status := OKC_API.g_ret_sts_error;

            l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);

            OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                         , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'

                    , p_token1 => 'COL_NAME'

                    , p_token1_value => l_ak_prompt

                     );

            raise OKC_API.G_EXCEPTION_ERROR;

       End If;

             End If;

           p_id1 := l_id11;

        p_id2 := l_id22;

        Close okx_pcontact_csr;

     END IF;


  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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

     IF okx_pcontact_csr%ISOPEN THEN
         CLOSE okx_pcontact_csr;

     END IF;

     IF okx_salepers_csr%ISOPEN THEN
         CLOSE okx_salepers_csr;

     END IF;


      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then

        x_return_status := OKC_API.HANDLE_EXCEPTIONS(

              p_api_name  => l_api_name,

              p_pkg_name  => g_pkg_name,

              p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',

              x_msg_count => x_msg_count,

              x_msg_data  => x_msg_data,

              p_api_type  => g_api_type);

     IF okx_pcontact_csr%ISOPEN THEN
         CLOSE okx_pcontact_csr;

     END IF;

     IF okx_salepers_csr%ISOPEN THEN
         CLOSE okx_salepers_csr;

     END IF;


     When OTHERS then

        x_return_status := OKC_API.HANDLE_EXCEPTIONS(

              p_api_name  => l_api_name,

              p_pkg_name  => g_pkg_name,

              p_exc_name  => 'OTHERS',

              x_msg_count => x_msg_count,

              x_msg_data  => x_msg_data,

              p_api_type  => g_api_type);

     IF okx_pcontact_csr%ISOPEN THEN
         CLOSE okx_pcontact_csr;

     END IF;

     IF okx_salepers_csr%ISOPEN THEN
         CLOSE okx_salepers_csr;

     END IF;


End Validate_Contact;




--Start of Comments

--Procedure   : Validate_Item

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments

Procedure Validate_Party (p_api_version    IN        NUMBER,
                          p_init_msg_list       IN        VARCHAR2 default OKC_API.G_FALSE,
                          x_return_status       OUT      NOCOPY    VARCHAR2,
                          x_msg_count       OUT      NOCOPY    NUMBER,
                          x_msg_data               OUT      NOCOPY    VARCHAR2,
                          p_chr_id              IN        NUMBER,
                          p_cle_id              IN        NUMBER,
                          p_cpl_id              IN        NUMBER,
                          p_lty_code            IN            VARCHAR2,
                          p_rle_code            IN        VARCHAR2,
                          p_id1                   IN OUT    NOCOPY   VARCHAR2,
                          p_id2                 IN OUT    NOCOPY   VARCHAR2,
                          p_name                IN       VARCHAR2,
                          p_object_code         IN       VARCHAR2
                     ) is



l_select_clause   varchar2(2000) default null;
l_from_clause     varchar2(2000) default null;
l_where_clause    varchar2(2000) default null;
l_order_by_clause varchar2(2000) default null;
l_query_string    varchar2(2000) default null;


l_id1             OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id2             OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_name            VARCHAR2(250) Default Null;
l_description     VARCHAR2(250) Default Null;
l_object_code     VARCHAR2(30) Default Null;


l_id11            OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id22            OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;


type              party_curs_type is REF CURSOR;
party_curs        party_curs_type;


row_count         Number default 0;



l_chr_id      okl_k_headers.id%type;
l_rle_code        okc_k_party_roles_v.rle_code%type;
l_cle_id          okl_k_lines.id%type;
l_lty_code        okc_line_styles_b.lty_code%type;



l_api_name        CONSTANT VARCHAR2(30) := 'okl_la_jtot_extract';
l_api_version      CONSTANT NUMBER    := 1.0;


-- x_return_status       := OKC_API.G_RET_STS_SUCCESS;



ERR_MSG           VARCHAR2(50) := 'DEFAULT';



CURSOR check_party_csr(p_chr_id NUMBER, p_rle_code VARCHAR2,p_id1 VARCHAR2, p_id2 VARCHAR2) IS

--Start modified abhsaxen for performance SQLID 20562697
select count(1)
from okc_k_party_roles_B
where dnz_chr_id = p_chr_id
and chr_id = p_chr_id
and rle_code = p_rle_code
and object1_id1 = p_id1
and object1_id2 = p_id2
--end modified abhsaxen for performance SQLID 20562697
;


CURSOR get_party_csr(p_cpl_id NUMBER) IS
SELECT rle_code, object1_id1, object1_id2
FROM okc_k_party_roles_v
WHERE id = p_cpl_id;




Begin

  If okl_context.get_okc_org_id  is null then
    l_chr_id := p_chr_id;
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



  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_chr_id');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_rle_code is null or p_rle_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_rle_code');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_name');
        raise OKC_API.G_EXCEPTION_ERROR;
--      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;



 --Added by kthiruva 23-Sep-2003 Bug No.3156265

  --For object_code
   l_object_code := null;

   IF ( p_rle_code IN ('BROKER', 'DEALER','GUARANTOR','INVESTOR' ,'LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL'))
   THEN
     OPEN okx_party_csr(p_name => p_name,
                        p_id1  =>l_id1,
                        p_id2  =>l_id2);

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code := 'OKX_PARTY';

     Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;

     If okx_party_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
         raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     l_id11 := l_id1;
     l_id22 := l_id2;


      If(l_id1 = p_id1 and l_id2 = p_id2) Then
         null;
      Else

        Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
        If okx_party_csr%Found Then

              If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
                 x_return_status := OKC_API.g_ret_sts_error;
                 OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                 raise OKC_API.G_EXCEPTION_ERROR;

              End If;

              If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
                 x_return_status := OKC_API.g_ret_sts_error;
                 OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                 raise OKC_API.G_EXCEPTION_ERROR;
              End If;

              Loop

                  If(l_id1 = p_id1 and l_id2 = p_id2) Then
                     l_id11 := l_id1;
                     l_id22 := l_id2;
                     row_count := 1;
                     Exit;
                  End If;
                  Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
                  Exit When okx_party_csr%NotFound;
              End Loop;

              If row_count <> 1 Then
                 x_return_status := OKC_API.g_ret_sts_error;
                 OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
                 raise OKC_API.G_EXCEPTION_ERROR;
       End If;

    End If;

   End If;

    p_id1 := l_id11;
    p_id2 := l_id22;
   Close okx_party_csr;

  END IF;

 -- For Object_code 'OKX_OPERUNIT'

  IF ( p_rle_code = 'LESSOR' OR
       p_rle_code = 'SYNDICATOR')
  THEN
     OPEN okx_operunit_csr(p_name => p_name,
                           p_id1  =>l_id1,
                           p_id2  =>l_id2);

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code := 'OKX_OPERUNIT';

     Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;

     If okx_operunit_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
         raise OKC_API.G_EXCEPTION_ERROR;
     End If;


     l_id11 := l_id1;
     l_id22 := l_id2;

     If(l_id1 = p_id1 and l_id2 = p_id2) Then
        null;
     Else
        Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;
        If okx_operunit_csr%Found Then
                If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
                   x_return_status := OKC_API.g_ret_sts_error;
                   OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                   raise OKC_API.G_EXCEPTION_ERROR;
                 End If;
                 If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
                   x_return_status := OKC_API.g_ret_sts_error;
                   OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                   raise OKC_API.G_EXCEPTION_ERROR;
                 End If;
                 Loop
                    If(l_id1 = p_id1 and l_id2 = p_id2) Then
                       l_id11 := l_id1;
                       l_id22 := l_id2;
                       row_count := 1;
                       Exit;
                    End If;
                    Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;
                    Exit When okx_operunit_csr%NotFound;
                End Loop;

     If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
        raise OKC_API.G_EXCEPTION_ERROR;
     End If;

    End If;

   End If;

    p_id1 := l_id11;
    p_id2 := l_id22;

    Close okx_operunit_csr;

  END IF;

 --For Object Code 'OKX_VENDOR'

  IF ( p_rle_code = 'OKL_VENDOR')
  THEN
     OPEN okx_vendor_csr(p_name => p_name,
                         p_id1   => l_id1,
                         p_id2   => l_id2);

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code := 'OKX_VENDOR';

     Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;

     If okx_vendor_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
         raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     l_id11 := l_id1;
     l_id22 := l_id2;

     If(l_id1 = p_id1 and l_id2 = p_id2) Then
         null;
     Else
        Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;
        If okx_vendor_csr%Found Then
              If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
                  x_return_status := OKC_API.g_ret_sts_error;
                  OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                  raise OKC_API.G_EXCEPTION_ERROR;
              End If;

              If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
                  x_return_status := OKC_API.g_ret_sts_error;
                  OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_MULTIPLE_DATA_FOUND');
                  raise OKC_API.G_EXCEPTION_ERROR;
              End If;

              Loop

                  If (l_id1 = p_id1 and l_id2 = p_id2) Then
                      l_id11 := l_id1;
                      l_id22 := l_id2;
                      row_count := 1;
                      Exit;
                  End If;

                  Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;
                  Exit When okx_vendor_csr%NotFound;
              End Loop;

     If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;
        OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_NO_DATA_FOUND');
        raise OKC_API.G_EXCEPTION_ERROR;
     End If;

   End If;

 End If;

   p_id1 := l_id11;
   p_id2 := l_id22;

   Close okx_vendor_csr;

END IF;

If p_lty_code is null or p_lty_code =  OKC_API.G_MISS_CHAR  Then
   If p_cpl_id is null or p_cpl_id =  OKC_API.G_MISS_NUM  Then
      OPEN check_party_csr(p_chr_id, p_rle_code, p_id1, p_id2 );
      FETCH check_party_csr INTO row_count;
      CLOSE check_party_csr;

      If row_count = 1 Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_name_already_exists');
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    Else

      OPEN get_party_csr(p_cpl_id );
      FETCH get_party_csr INTO l_rle_code, l_id1, l_id2;
      CLOSE get_party_csr;

      If l_rle_code = p_rle_code and l_id1 <> p_id1 Then
          OPEN check_party_csr(p_chr_id, p_rle_code, p_id1, p_id2);
          FETCH check_party_csr INTO row_count;
          CLOSE check_party_csr;

          If row_count = 1 Then
             x_return_status := OKC_API.g_ret_sts_error;
             OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Party_name_already_exists');
             raise OKC_API.G_EXCEPTION_ERROR;
          End If;
      End If;

    End If;
 End If;

--p_object_code := l_object_code ;

 x_return_status := OKC_API.G_RET_STS_SUCCESS;

 OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

  EXCEPTION

    WHEN OKC_API.G_EXCEPTION_ERROR then

        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => g_api_type);

        IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
        END IF;

        IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
        END IF;

        IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
        END IF;


      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => g_api_type);

        IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
        END IF;

        IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
        END IF;

        IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
        END IF;


      WHEN OTHERS then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OTHERS',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => g_api_type);

        IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
        END IF;

        IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
        END IF;

        IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
        END IF;


End Validate_Party;






--Start of Comments

--Procedure   : Validate_Item

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments

Procedure Get_Party_Jtot_data (p_api_version    IN        NUMBER,
                     p_init_msg_list       IN        VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT      NOCOPY    VARCHAR2,
                     x_msg_count       OUT      NOCOPY    NUMBER,
                     x_msg_data               OUT      NOCOPY    VARCHAR2,
                     p_scs_code            IN    VARCHAR2,
                     p_buy_or_sell         IN    VARCHAR2,
                     p_rle_code            IN    VARCHAR2,
                     p_id1                   IN OUT NOCOPY VARCHAR2,
                     p_id2                 IN OUT NOCOPY VARCHAR2,
                     p_name                IN   VARCHAR2,
                     p_object_code         IN OUT NOCOPY  VARCHAR2,
                     p_ak_region          IN    VARCHAR2,
                     p_ak_attribute         IN    VARCHAR2
                     ) is

l_select_clause   varchar2(2000) default null;
l_from_clause     varchar2(2000) default null;
l_where_clause    varchar2(2000) default null;
l_order_by_clause varchar2(2000) default null;
l_query_string    varchar2(2000) default null;

l_id1             OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id2             OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_name            VARCHAR2(250) Default Null;
l_description     VARCHAR2(250) Default Null;
l_object_code     VARCHAR2(30) Default Null;

l_id11            OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id22            OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;

type              party_curs_type is REF CURSOR;
party_curs        party_curs_type;

row_count         Number default 0;

l_chr_id          okl_k_headers.id%type;
l_rle_code        okc_k_party_roles_v.rle_code%type;
l_cle_id          okl_k_lines.id%type;
l_lty_code        okc_line_styles_b.lty_code%type;

l_api_name        CONSTANT VARCHAR2(30) := 'Get_Party_Jtot_data';
l_api_version      CONSTANT NUMBER    := 1.0;

-- x_return_status       := OKC_API.G_RET_STS_SUCCESS;

ERR_MSG           VARCHAR2(50) := 'DEFAULT';

l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

Begin

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

  If ( p_rle_code is null or p_rle_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_rle_code');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_name');
      raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  -- Added by kthiruva 23-Sep-2003 Bug No.3156265

  --For object_code 'OKX_PARTY'
   l_object_code :=  null;

   IF ( p_rle_code IN ('BROKER', 'DEALER','GUARANTOR','INVESTOR' ,'LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL'))

   THEN


     OPEN okx_party_csr(p_name => p_name,
                        p_id1  => l_id1,
                        p_id2  => l_id2 );

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code :=  'OKX_PARTY';

     Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;

     If okx_party_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
         OKC_API.SET_MESSAGE(p_app_name => g_app_name
                  , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                 , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

         raise OKC_API.G_EXCEPTION_ERROR;
     End If;


     l_id11 := l_id1;
     l_id22 := l_id2;


      IF (l_id1 = p_id1 and l_id2 = p_id2) Then
         null;
      ELSE
        Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
        IF okx_party_csr%Found Then
              If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
                  x_return_status := OKC_API.g_ret_sts_error;
                  l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
                  OKC_API.SET_MESSAGE(p_app_name => g_app_name
                 , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
                   );

                 raise OKC_API.G_EXCEPTION_ERROR;
             End If;

             If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
                x_return_status := OKC_API.g_ret_sts_error;
                l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
                 OKC_API.SET_MESSAGE(p_app_name => g_app_name
                               , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                               , p_token1 => 'COL_NAME'
                               , p_token1_value => l_ak_prompt
                        );

                 raise OKC_API.G_EXCEPTION_ERROR;

            End If;

            If(l_id11 = p_id1 and l_id22 = p_id2) Then
               row_count := 1;
            ELSE
               LOOP
                 If(l_id1 = p_id1 and l_id2 = p_id2) Then
                    l_id11 := l_id1;
                    l_id22 := l_id2;
                    row_count := 1;
                    Exit;
                 End If;
                 Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
                 Exit When okx_party_csr%NotFound;
               End Loop;
           End If;

         If row_count <> 1 Then
           x_return_status := OKC_API.g_ret_sts_error;
           l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
           OKC_API.SET_MESSAGE(  p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

           raise OKC_API.G_EXCEPTION_ERROR;
         End If;

      End If;

    End If;

    p_id1 := l_id11;
    p_id2 := l_id22;

    Close okx_party_csr;

  END IF;


--- For Object_code 'OKX_OPERUNIT'

  IF ( p_rle_code = 'LESSOR' OR
       p_rle_code = 'SYNDICATOR')
  THEN
     OPEN okx_operunit_csr(p_name => p_name,
                           p_id1  => l_id1,
                           p_id2  => l_id2 );

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code :=  'OKX_OPERUNIT';

     Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;

     If okx_operunit_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
         OKC_API.SET_MESSAGE(p_app_name => g_app_name
                           , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                           , p_token1 => 'COL_NAME'
                          , p_token1_value => l_ak_prompt
               );

         raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     l_id11 := l_id1;
     l_id22 := l_id2;

     If(l_id1 = p_id1 and l_id2 = p_id2) Then
         null;
     Else
        Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;
        If okx_operunit_csr%Found Then
           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
               l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
               OKC_API.SET_MESSAGE(p_app_name => g_app_name
                                 , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                                 , p_token1 => 'COL_NAME'
                                 , p_token1_value => l_ak_prompt );

               raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
               l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
                OKC_API.SET_MESSAGE(p_app_name => g_app_name
                 , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                  , p_token1 => 'COL_NAME'
                 , p_token1_value => l_ak_prompt );

               raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If(l_id11 = p_id1 and l_id22 = p_id2) Then
                    row_count := 1;
           Else
              Loop
                 If(l_id1 = p_id1 and l_id2 = p_id2) Then
                     l_id11 := l_id1;
                     l_id22 := l_id2;
                     row_count := 1;
                     Exit;
                 End If;
                 Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;
                 Exit When okx_operunit_csr%NotFound;
             End Loop;
           End If;

   If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
            OKC_API.SET_MESSAGE(  p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt);

        raise OKC_API.G_EXCEPTION_ERROR;

   End If;

  End If;

  End If;

  p_id1 := l_id11;
  p_id2 := l_id22;

  Close okx_operunit_csr;

END IF;

 --For Object Code 'OKX_VENDOR'

  IF ( p_rle_code = 'OKL_VENDOR')
  THEN

     OPEN okx_vendor_csr(p_name => p_name,
                         p_id1  => l_id1,
                         p_id2  => l_id2 );

     l_id1  := Null;
     l_id2  := Null;
     l_name := Null;
     l_description := Null;
     l_object_code :=  'OKX_VENDOR';

     Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;

     If okx_vendor_csr%NotFound Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
         OKC_API.SET_MESSAGE(p_app_name => g_app_name
                  , p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                 , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

         raise OKC_API.G_EXCEPTION_ERROR;
     End If;

     l_id11 := l_id1;
     l_id22 := l_id2;

     If(l_id1 = p_id1 and l_id2 = p_id2) Then
         null;
     Else
        Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;
        If okx_vendor_csr%Found Then
              If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
                   x_return_status := OKC_API.g_ret_sts_error;
                   l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
                   OKC_API.SET_MESSAGE(p_app_name => g_app_name
                                     , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                                     , p_token1 => 'COL_NAME'
                                    , p_token1_value => l_ak_prompt
                   );

              raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
               l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
               OKC_API.SET_MESSAGE(p_app_name => g_app_name
                                 , p_msg_name => 'OKL_LLA_DUP_LOV_VALUES'
                                 , p_token1 => 'COL_NAME'
                                 , p_token1_value => l_ak_prompt);

               raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        If(l_id11 = p_id1 and l_id22 = p_id2) Then
           row_count := 1;
        Else
           Loop
             If(l_id1 = p_id1 and l_id2 = p_id2) Then
                l_id11 := l_id1;
                l_id22 := l_id2;
                row_count := 1;
                Exit;
             End If;

             Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;
             Exit When okx_vendor_csr%NotFound;
           End Loop;
        End If;

     If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT(p_ak_region, p_ak_attribute);
        OKC_API.SET_MESSAGE(p_app_name => g_app_name
                           ,p_msg_name => 'OKL_LLA_NO_DATA_FOUND'
                           ,p_token1 => 'COL_NAME'
                          , p_token1_value => l_ak_prompt);

        raise OKC_API.G_EXCEPTION_ERROR;

     End If;

   End If;

  End If;

  p_id1 := l_id11;
  p_id2 := l_id22;

  Close okx_vendor_csr;

END IF;

 p_object_code := l_object_code;

 x_return_status := OKC_API.G_RET_STS_SUCCESS;

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

     IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;

     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;

     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;

     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
          x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => g_api_type);

     IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;

     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;

     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;


     when OTHERS then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OTHERS',
              x_msg_count => x_msg_count,
              x_msg_data  => x_msg_data,
              p_api_type  => g_api_type);

     IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;

     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;

     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;

End Get_Party_Jtot_data;

--Start of Comments
--Procedure   : Validate_Item
--Description : Returns Name, Description for a given role or all the roles
--              attached to a contract
--End of Comments

Procedure Validate_Link_Asset (p_api_version    IN    NUMBER,
                               p_init_msg_list  IN    VARCHAR2 default OKC_API.G_FALSE,
                               x_return_status  OUT  NOCOPY    VARCHAR2,
                               x_msg_count      OUT  NOCOPY    NUMBER,
                               x_msg_data               OUT  NOCOPY    VARCHAR2,
                               p_chr_id              IN    NUMBER,
                               p_parent_cle_id       IN    NUMBER,
                               p_id1                   IN   OUT NOCOPY VARCHAR2,
                               p_id2                 IN   OUT NOCOPY VARCHAR2,
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


l_chr_id        okl_k_headers.id%type;
l_parent_cle_id     okl_k_lines.id%type;
l_cle_id            okl_k_lines.id%type;
l_lty_code          okc_line_styles_b.lty_code%type;



l_api_name      CONSTANT VARCHAR2(30) := 'okl_la_jtot_extract';
l_api_version    CONSTANT NUMBER      := 1.0;
l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

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



  If okl_context.get_okc_org_id  is null then
    l_chr_id := p_chr_id;
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



  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
               p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ElsIf ( p_parent_cle_id is null or p_parent_cle_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
               p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ElsIf ( p_name is null or p_name =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
               p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;


 --Added by kthiruva 23-Sep-2003 Bug No.3156265


  OPEN get_lty_code_csr(p_chr_id ,
                        p_parent_cle_id );
  FETCH get_lty_code_csr INTO l_lty_code;
  If get_lty_code_csr%NotFound Then
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
      raise OKC_API.G_EXCEPTION_ERROR;
  End If;
  CLOSE get_lty_code_csr;


--For Object code 'OKL_STRMTYP'
    IF (l_lty_code = 'FEE') THEN
       OPEN okl_strmtyp_csr(p_name,
                            p_id1,
                            p_id2 );

       l_id1  := Null;
       l_id2  := Null;
       l_name := Null;
       l_description := Null;


      FETCH okl_strmtyp_csr INTO l_id1,l_id2,l_name,l_description;

      IF okl_strmtyp_csr%NotFound THEN
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_id11 := l_id1;
      l_id22 := l_id2;

      FETCH okl_strmtyp_csr INTO l_id1,l_id2,l_name,l_description;
      If okl_strmtyp_csr%Found Then
           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
               OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
               raise OKC_API.G_EXCEPTION_ERROR;
           End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
               OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
               raise OKC_API.G_EXCEPTION_ERROR;
           End If;

           Loop

              If(l_id1 = p_id1 and l_id2 = p_id2) Then
                 l_id11 := l_id1;
                 l_id22 := l_id2;
                 row_count := 1;
                 Exit;
              End If;

              FETCH okl_strmtyp_csr INTO l_id1,l_id2,l_name,l_description;
              Exit When okl_strmtyp_csr%NotFound;

          End Loop;

          If row_count <> 1 Then
             x_return_status := OKC_API.g_ret_sts_error;
             OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
             raise OKC_API.G_EXCEPTION_ERROR;
          End If;
      End If;

    p_id1 := l_id11;
    p_id2 := l_id22;

    Close okl_strmtyp_csr;

   END IF;

-- For Object Code 'OKL_USAGE'

   IF (l_lty_code = 'USAGE') THEN
      OPEN okl_usage_csr(p_name => p_name,
                         p_id1  => l_id1,
                         p_id2  => l_id2);

      l_id1  := Null;
      l_id2  := Null;
      l_name := Null;
      l_description := Null;

      FETCH okl_usage_csr INTO l_id1,l_id2,l_name,l_description;

      IF okl_usage_csr%NotFound THEN
          x_return_status := OKC_API.g_ret_sts_error;
          OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
          raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_id11 := l_id1;
      l_id22 := l_id2;

      FETCH okl_usage_csr INTO l_id1,l_id2,l_name,l_description;
      If okl_usage_csr%Found Then
         If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
             OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
             raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
            raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then
            l_id11 := l_id1;
            l_id22 := l_id2;
            row_count := 1;
            Exit;
         End If;

         FETCH okl_usage_csr INTO l_id1,l_id2,l_name,l_description;
         Exit When okl_usage_csr%NotFound;

       End Loop;

       If row_count <> 1 Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
         raise OKC_API.G_EXCEPTION_ERROR;
       End If;
    End If;

    p_id1 := l_id11;
    p_id2 := l_id22;

    Close okl_usage_csr;

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


      FETCH okx_asset_csr INTO l_id1,l_id2,l_name,l_description;



      IF okx_asset_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

         raise OKC_API.G_EXCEPTION_ERROR;


      END IF;


    l_id11 := l_id1;

    l_id22 := l_id2;



      FETCH okx_asset_csr INTO l_id1,l_id2,l_name,l_description;

      If okx_asset_csr%Found Then



           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

       OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then

      l_id11 := l_id1;

            l_id22 := l_id2;

            row_count := 1;

            Exit;

         End If;



         FETCH okx_asset_csr INTO l_id1,l_id2,l_name,l_description;

         Exit When okx_asset_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;




    Close okx_asset_csr;
   END IF;


 -- For Object Code 'OKX_COVASST'

   IF (l_lty_code ='LINK_SERV_ASSET' OR l_lty_code = 'LINK_USAGE_ASSET') THEN

       OPEN okx_covasst_csr(p_name => p_name,
                            p_id1  => l_id1,
                            p_id2  => l_id2);

         l_id1  := Null;

         l_id2  := Null;

         l_name := Null;

         l_description := Null;


       FETCH okx_asset_csr INTO l_id1,l_id2,l_name,l_description;



      IF okx_covasst_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

         raise OKC_API.G_EXCEPTION_ERROR;


      END IF;


    l_id11 := l_id1;

    l_id22 := l_id2;



      FETCH okx_covasst_csr INTO l_id1,l_id2,l_name,l_description;

      If okx_covasst_csr%Found Then



           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

       OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then

      l_id11 := l_id1;

            l_id22 := l_id2;

            row_count := 1;

            Exit;

         End If;



         FETCH okx_covasst_csr INTO l_id1,l_id2,l_name,l_description;

         Exit When okx_covasst_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;




    Close okx_covasst_csr;
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


      FETCH okx_ib_item_csr INTO l_id1,l_id2,l_name,l_description;



      IF okx_ib_item_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

         raise OKC_API.G_EXCEPTION_ERROR;


      END IF;


    l_id11 := l_id1;

    l_id22 := l_id2;



      FETCH okx_ib_item_csr INTO l_id1,l_id2,l_name,l_description;

      If okx_ib_item_csr%Found Then



           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

       OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then

      l_id11 := l_id1;

            l_id22 := l_id2;

            row_count := 1;

            Exit;

         End If;



         FETCH okx_ib_item_csr INTO l_id1,l_id2,l_name,l_description;

         Exit When okx_ib_item_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;




    Close okx_ib_item_csr;
   END IF;

-- For Object Code 'OKX_LEASE'

     IF (l_lty_code = 'SHARED') THEN

      OPEN okx_lease_csr(p_name => p_name,
                         p_id1  => l_id1,
                         p_id2  => l_id2);

        l_id1  := Null;

        l_id2  := Null;

        l_name := Null;

        l_description := Null;

      FETCH okx_lease_csr INTO l_id1,l_id2,l_name,l_description;



      IF okx_lease_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

         raise OKC_API.G_EXCEPTION_ERROR;


      END IF;


    l_id11 := l_id1;

    l_id22 := l_id2;



      FETCH okx_lease_csr INTO l_id1,l_id2,l_name,l_description;

      If okx_lease_csr%Found Then



           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

       OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then

      l_id11 := l_id1;

            l_id22 := l_id2;

            row_count := 1;

            Exit;

         End If;



         FETCH okx_lease_csr INTO l_id1,l_id2,l_name,l_description;

         Exit When okx_lease_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;




    Close okx_lease_csr;
   END IF;




-- For Object Code 'OKX_SERVICE'

     IF (l_lty_code ='SOLD_SERVICE') THEN

     OPEN okx_service_csr(p_name => p_name,
                          p_id1  => l_id1,
                          p_id2  => l_id2 );

       l_id1  := Null;

       l_id2  := Null;

       l_name := Null;

       l_description := Null;

     FETCH okx_service_csr INTO l_id1,l_id2,l_name,l_description;



      IF okx_service_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

         raise OKC_API.G_EXCEPTION_ERROR;


      END IF;


    l_id11 := l_id1;

    l_id22 := l_id2;



      FETCH okx_service_csr INTO l_id1,l_id2,l_name,l_description;

      If okx_service_csr%Found Then



           If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;

       OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_id1 = p_id1 and l_id2 = p_id2) Then

      l_id11 := l_id1;

            l_id22 := l_id2;

            row_count := 1;

            Exit;

         End If;



         FETCH okx_service_csr INTO l_id1,l_id2,l_name,l_description;

         Exit When okx_service_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



    p_id1 := l_id11;

    p_id2 := l_id22;




    Close okx_service_csr;
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

   FETCH okx_sysitem_csr INTO l_id1,l_id2,l_name,l_description;
   IF okx_sysitem_csr%NotFound THEN

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
         raise OKC_API.G_EXCEPTION_ERROR;

    END IF;

    l_id11 := l_id1;
    l_id22 := l_id2;

    FETCH okx_sysitem_csr INTO l_id1,l_id2,l_name,l_description;

    If okx_sysitem_csr%Found Then
         If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
          x_return_status := OKC_API.g_ret_sts_error;
          OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
          raise OKC_API.G_EXCEPTION_ERROR;
         End If;
         If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
            raise OKC_API.G_EXCEPTION_ERROR;
         End If;
         Loop
         If(l_id1 = p_id1 and l_id2 = p_id2) Then
            l_id11 := l_id1;
            l_id22 := l_id2;
            row_count := 1;
            Exit;
         End If;

         FETCH okx_sysitem_csr INTO l_id1,l_id2,l_name,l_description;
         Exit When okx_sysitem_csr%NotFound;
        End Loop;

    If row_count <> 1 Then
      x_return_status := OKC_API.g_ret_sts_error;
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_LLA_ASSET_REQUIRED');
      raise OKC_API.G_EXCEPTION_ERROR;

    End If;

   End If;

    p_id1 := l_id11;
    p_id2 := l_id22;

    Close okx_sysitem_csr;

   END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count,x_msg_data => x_msg_data);

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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
     END IF;

     IF okx_service_csr%ISOPEN THEN
        CLOSE okx_service_csr;
     END IF;

     IF okx_sysitem_csr%ISOPEN THEN
        CLOSE okx_sysitem_csr;
     END IF;

     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then

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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
     END IF;

     IF okx_service_csr%ISOPEN THEN
        CLOSE okx_service_csr;
     END IF;

     IF okx_sysitem_csr%ISOPEN THEN
        CLOSE okx_sysitem_csr;
     END IF;


End Validate_Link_Asset;








--Start of Comments

--Procedure   : Validate_Item

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments

Procedure Validate_Service (p_api_version     IN    NUMBER,
                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY    VARCHAR2,
                     x_msg_count       OUT  NOCOPY    NUMBER,
                     x_msg_data               OUT  NOCOPY    VARCHAR2,
                     p_chr_id              IN    NUMBER,
                     p_cle_id              IN    NUMBER,
                     p_lty_code            IN   VARCHAR2,
                     p_item_id1            IN OUT NOCOPY VARCHAR2,
                     p_item_id2            IN OUT NOCOPY VARCHAR2,
                     p_item_name           IN  VARCHAR2,
                     p_item_object_code    IN OUT NOCOPY VARCHAR2,
                     p_cpl_id              IN  NUMBER,
                     p_rle_code            IN  VARCHAR2,
                     p_party_id1             IN OUT NOCOPY VARCHAR2,
                     p_party_id2           IN OUT NOCOPY VARCHAR2,
                     p_party_name          IN  VARCHAR2,
                     p_party_object_code   IN OUT NOCOPY VARCHAR2
                     ) is

l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;

l_item_id1          OKC_K_ITEMS_V.OBJECT1_ID1%TYPE default Null;
l_item_id2          OKC_K_ITEMS_V.OBJECT1_ID2%TYPE default Null;
l_item_name         VARCHAR2(250) Default Null;

l_item_description  VARCHAR2(250) Default Null;
l_item_object_code  VARCHAR2(30) Default Null;



l_item_id11         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE default Null;
l_item_id22         OKC_K_ITEMS_V.OBJECT1_ID2%TYPE default Null;



l_party_id1         OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_party_id2         OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_party_name        VARCHAR2(250) Default Null;
l_party_object_code VARCHAR2(30) Default Null;



type                item_curs_type is REF CURSOR;

item_curs           item_curs_type;



row_count           Number default 0;



l_chr_id        okl_k_headers.id%type;
l_cle_id            okl_k_lines.id%type;
l_cle_id            okl_k_lines.id%type;
l_lty_code          okc_line_styles_b.lty_code%type;


l_fee_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;


l_api_name      CONSTANT VARCHAR2(30) := 'validate_service';
l_api_version    CONSTANT NUMBER      := 1.0;

l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;



CURSOR check_item_csr(p_chr_id NUMBER, p_lty_code VARCHAR2, p_id1 VARCHAR2, p_id2 VARCHAR2) IS

select count(1)

from  okc_k_items cim
      , okc_k_lines_b cle
      , okc_line_style_sources lss
      , okc_line_styles_b lse
where  nvl(lss.start_date,sysdate) <= sysdate
and    nvl(lss.end_date,sysdate + 1) > sysdate
and    lse.id = lss.lse_id
and    cle.lse_id = lse.id
and    cle.id = cim.cle_id
and    cim.object1_id1 = p_id1
and    cim.object1_id2 = p_id2
and    cim.chr_id = p_chr_id
and    cim.dnz_chr_id = p_chr_id
and    lse.lty_code = p_lty_code;



CURSOR get_item_csr(p_chr_id NUMBER, p_cle_id NUMBER) IS
SELECT lse.lty_code, cim.object1_id1, cim.object1_id2
from  okc_k_items cim
      , okc_k_lines_b cle
      , okc_line_style_sources lss
      , okc_line_styles_b lse
where  nvl(lss.start_date,sysdate) <= sysdate
and    nvl(lss.end_date,sysdate + 1) > sysdate
and    lse.id = lss.lse_id
and    cle.lse_id = lse.id
and    cle.id = cim.cle_id
and    cim.chr_id = p_chr_id
and    cim.dnz_chr_id = p_chr_id
and    cle.id = p_cle_id;


Begin

  If okl_context.get_okc_org_id  is null then
    l_chr_id := p_chr_id;
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


  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_Chr_Name');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf ( p_item_name is null or p_item_name =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
               p_msg_name => 'Missing_Service_Name');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ElsIf ( p_lty_code is null or p_lty_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
               p_msg_name => 'Missing_Lty_Code');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;

--Added by kthiruva 23-Sep-2003 Bug No.3156265

   IF (p_lty_code = 'FEE') THEN

      OPEN okl_strmtyp_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2 );

         l_item_id1  := Null;
         l_item_id2  := Null;
         l_item_name := Null;
         l_item_description := Null;

      FETCH okl_strmtyp_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;

      IF okl_strmtyp_csr%NotFound THEN
         x_return_status := OKC_API.g_ret_sts_error;

         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(p_app_name => g_app_name
                           , p_msg_name => 'OKL_INVALID_VALUE'
                           , p_token1 => 'COL_NAME'
                           , p_token1_value => l_fee_ak_prompt
                       );

         raise OKC_API.G_EXCEPTION_ERROR;

      END IF;
      l_item_id11 := l_item_id1;
      l_item_id22 := l_item_id2;

      Fetch okl_strmtyp_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
      If okl_strmtyp_csr%Found Then
           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
               l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
               OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                       , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

          raise OKC_API.G_EXCEPTION_ERROR;

       End If;

       If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then
           x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then
               l_item_id11 := l_item_id1;
               l_item_id22 := l_item_id2;
               row_count := 1;
               Exit;
         End If;

         Fetch okl_strmtyp_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;
         Exit When okl_strmtyp_csr%NotFound;

        End Loop;

    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
          OKC_API.SET_MESSAGE(p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

    End If;

  End If;

  p_item_id1 := l_item_id11;
  p_item_id2 := l_item_id22;

  Close okl_strmtyp_csr;
 END IF;

-- For Object Code 'OKL_USAGE'
   IF (p_lty_code = 'USAGE') THEN

      OPEN okl_usage_csr(p_name => p_item_name,
                         p_id1  => l_item_id1,
                         p_id2  => l_item_id2 );


      l_item_id1  := Null;
      l_item_id2  := Null;
      l_item_name := Null;
      l_item_description := Null;

      FETCH okl_usage_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;

      IF okl_usage_csr%NotFound THEN
         x_return_status := OKC_API.g_ret_sts_error;

         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                         , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                       );

         raise OKC_API.G_EXCEPTION_ERROR;

      END IF;
      l_item_id11 := l_item_id1;
      l_item_id22 := l_item_id2;

      Fetch okl_usage_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okl_usage_csr%Found Then
           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
                x_return_status := OKC_API.g_ret_sts_error;
             -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
                l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
                OKC_API.SET_MESSAGE( p_app_name => g_app_name
                                   , p_msg_name => 'OKL_INVALID_VALUE'
                                   , p_token1 => 'COL_NAME'
                                   , p_token1_value => l_fee_ak_prompt);

                raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
              l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
              OKC_API.SET_MESSAGE(p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

              raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then
            l_item_id11 := l_item_id1;
            l_item_id22 := l_item_id2;
            row_count := 1;
            Exit;
         End If;
         Fetch okl_usage_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;
         Exit When okl_usage_csr%NotFound;

        End Loop;

    If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;
         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
        l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

         OKC_API.SET_MESSAGE(p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

         raise OKC_API.G_EXCEPTION_ERROR;

    End If;

   End If;

   p_item_id1 := l_item_id11;
   p_item_id2 := l_item_id22;

   Close okl_usage_csr;

 END IF;

-- For Object Code ' OKX_ASSET '

   IF (p_lty_code = 'FIXED_ASSET') THEN

      OPEN okx_asset_csr(p_name => p_item_name,
                         p_id1  => l_item_id1,
                         p_id2  => l_item_id2 );


         l_item_id1  := Null;
         l_item_id2  := Null;
         l_item_name := Null;
         l_item_description := Null;

      FETCH okx_asset_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;

      IF okx_asset_csr%NotFound THEN
         x_return_status := OKC_API.g_ret_sts_error;
         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                         , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt );

         raise OKC_API.G_EXCEPTION_ERROR;

      END IF;

      l_item_id11 := l_item_id1;
      l_item_id22 := l_item_id2;

      Fetch okx_asset_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
      If okx_asset_csr%Found Then
           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
               l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
               OKC_API.SET_MESSAGE(p_app_name => g_app_name
                             , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

              raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then
               x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
               l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
               OKC_API.SET_MESSAGE(p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt );

               raise OKC_API.G_EXCEPTION_ERROR;

           End If;

        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then
            l_item_id11 := l_item_id1;
            l_item_id22 := l_item_id2;
            row_count := 1;
            Exit;
         End If;

         Fetch okx_asset_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;
         Exit When okx_asset_csr%NotFound;

       End Loop;


    If row_count <> 1 Then
        x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;

   End If;

     p_item_id1 := l_item_id11;
     p_item_id2 := l_item_id22;

  Close okx_asset_csr;
  END IF;

 -- For Object Code 'OKX_COVASST'

   IF (p_lty_code ='LINK_SERV_ASSET' OR p_lty_code = 'LINK_USAGE_ASSET') THEN

      OPEN okx_covasst_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2 );


         l_item_id1  := Null;
         l_item_id2  := Null;
         l_item_name := Null;
         l_item_description := Null;

      FETCH okx_covasst_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;

      IF okx_covasst_csr%NotFound THEN
         x_return_status := OKC_API.g_ret_sts_error;
         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                         , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_fee_ak_prompt
                       );

         raise OKC_API.G_EXCEPTION_ERROR;



      END IF;



      l_item_id11 := l_item_id1;

      l_item_id22 := l_item_id2;



      Fetch okx_covasst_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okx_covasst_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_covasst_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_covasst_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



     p_item_id1 := l_item_id11;

     p_item_id2 := l_item_id22;



    Close okx_covasst_csr;
   END IF;

-- For Object Code 'OKX_IB_ITEM'

    IF (p_lty_code = 'INST_ITEM') THEN

      OPEN okx_ib_item_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2 );


         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;


      FETCH okx_ib_item_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;



      IF okx_ib_item_csr%NotFound THEN



         x_return_status := OKC_API.g_ret_sts_error;



         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

         OKC_API.SET_MESSAGE(     p_app_name => g_app_name

                         , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                       );

         raise OKC_API.G_EXCEPTION_ERROR;



      END IF;



      l_item_id11 := l_item_id1;

      l_item_id22 := l_item_id2;



      Fetch okx_ib_item_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okx_ib_item_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_ib_item_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_ib_item_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



     p_item_id1 := l_item_id11;

     p_item_id2 := l_item_id22;



    Close okx_ib_item_csr;
   END IF;

-- For Object Code 'OKX_LEASE'

     IF (p_lty_code = 'SHARED') THEN

      OPEN okx_lease_csr(p_name => p_item_name,
                         p_id1  => l_item_id1,
                         p_id2  => l_item_id2 );


         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;


      FETCH okx_lease_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;



      IF okx_lease_csr%NotFound THEN



         x_return_status := OKC_API.g_ret_sts_error;



         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

         OKC_API.SET_MESSAGE(     p_app_name => g_app_name

                         , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                       );

         raise OKC_API.G_EXCEPTION_ERROR;



      END IF;



      l_item_id11 := l_item_id1;

      l_item_id22 := l_item_id2;



      Fetch okx_lease_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okx_lease_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_lease_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_lease_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



     p_item_id1 := l_item_id11;

     p_item_id2 := l_item_id22;



    Close okx_lease_csr;
   END IF;

-- For Object Code 'OKX_SERVICE'

     IF (p_lty_code ='SOLD_SERVICE') THEN

      OPEN okx_service_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2 );


         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;



      FETCH okx_service_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;



      IF okx_service_csr%NotFound THEN



         x_return_status := OKC_API.g_ret_sts_error;



         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

         OKC_API.SET_MESSAGE(     p_app_name => g_app_name

                         , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                       );

         raise OKC_API.G_EXCEPTION_ERROR;



      END IF;



      l_item_id11 := l_item_id1;

      l_item_id22 := l_item_id2;



      Fetch okx_service_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okx_service_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_service_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_service_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



     p_item_id1 := l_item_id11;

     p_item_id2 := l_item_id22;



    Close okx_service_csr;
   END IF;

-- For Object Code 'OKX_SYSITEM'

   IF (p_lty_code = 'ITEM' or p_lty_code ='ADD_ITEM') THEN

      OPEN okx_sysitem_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2 );


         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;


      FETCH okx_sysitem_csr INTO l_item_id1,l_item_id2,l_item_name,l_item_description;



      IF okx_sysitem_csr%NotFound THEN



         x_return_status := OKC_API.g_ret_sts_error;



         -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



         l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

         OKC_API.SET_MESSAGE(     p_app_name => g_app_name

                         , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                       );

         raise OKC_API.G_EXCEPTION_ERROR;



      END IF;



      l_item_id11 := l_item_id1;

      l_item_id22 := l_item_id2;



      Fetch okx_sysitem_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

      If okx_sysitem_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        Loop

         If(l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2) Then

          l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_sysitem_csr INTO  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_sysitem_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_fee_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_FEE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_fee_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



      End If;



     p_item_id1 := l_item_id11;

     p_item_id2 := l_item_id22;



    Close okx_sysitem_csr;
   END IF;



  If p_cle_id is null or p_cle_id =  OKC_API.G_MISS_NUM  Then

      OPEN check_item_csr(p_chr_id, p_lty_code, p_item_id1, p_item_id2 );

      FETCH check_item_csr INTO row_count;

      CLOSE check_item_csr;

      If row_count = 1 Then

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_DUPLICATE_SERVICE_FEE');

         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

  Else

      OPEN get_item_csr(p_chr_id, p_cle_id );

      FETCH get_item_csr INTO l_lty_code, l_item_id1, l_item_id2;

      CLOSE get_item_csr;



      If l_lty_code = p_lty_code and l_item_id1 <> p_item_id1 Then

          OPEN check_item_csr(p_chr_id, p_lty_code, p_item_id1, p_item_id2);

          FETCH check_item_csr INTO row_count;

          CLOSE check_item_csr;

           If row_count = 1 Then

           x_return_status := OKC_API.g_ret_sts_error;

          OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_DUPLICATE_SERVICE_FEE');

          raise OKC_API.G_EXCEPTION_ERROR;

         End If;

      End If;

  End If;



  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  Validate_Party ( p_api_version  => p_api_version ,
                   p_init_msg_list   => p_init_msg_list ,
                   x_return_status   => x_return_status ,
                   x_msg_count       => x_msg_count ,
                   x_msg_data      => x_msg_data ,
                   p_chr_id          => p_chr_id ,
                   p_cle_id          => p_cle_id ,
                   p_cpl_id          => p_cpl_id ,
                   p_lty_code        => p_lty_code ,
                   p_rle_code        => p_rle_code ,
                   p_id1             => l_party_id1 ,
                   p_id2             => l_party_id2 ,
                   p_name            => p_party_name ,
                   p_object_code     => p_party_object_code );

  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
     raise OKC_API.G_EXCEPTION_ERROR;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count,x_msg_data => x_msg_data);

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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
     END IF;

     IF okx_service_csr%ISOPEN THEN
        CLOSE okx_service_csr;
     END IF;

     IF okx_sysitem_csr%ISOPEN THEN
        CLOSE okx_sysitem_csr;
     END IF;





End Validate_Service;



--Start of Comments

--Procedure   : Validate_Item

--Description : Returns Name, Description for a given role or all the roles

--              attached to a contract

--End of Comments

Procedure Validate_Fee (p_api_version     IN    NUMBER,
                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY    VARCHAR2,
                     x_msg_count       OUT  NOCOPY    NUMBER,
                     x_msg_data               OUT  NOCOPY    VARCHAR2,
                     p_chr_id              IN    NUMBER,
                     p_cle_id              IN    NUMBER,
                     p_lty_code            IN   VARCHAR2,
                     p_item_id1            IN OUT NOCOPY VARCHAR2,
                     p_item_id2            IN OUT NOCOPY VARCHAR2,
                     p_item_name           IN  VARCHAR2,
                     p_item_object_code    IN OUT NOCOPY VARCHAR2
                     ) is

l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;


l_item_id1          OKC_K_ITEMS_V.OBJECT1_ID1%TYPE default Null;
l_item_id2          OKC_K_ITEMS_V.OBJECT1_ID2%TYPE default Null;
l_item_name         VARCHAR2(250) Default Null;
l_item_description  VARCHAR2(250) Default Null;
l_item_object_code  VARCHAR2(30) Default Null;



l_item_id11         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE default Null;
l_item_id22         OKC_K_ITEMS_V.OBJECT1_ID2%TYPE default Null;



l_service_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;


type            item_curs_type is REF CURSOR;
item_curs       item_curs_type;



row_count       Number default 0;


l_chr_id    okl_k_headers.id%type;
l_cle_id        okl_k_lines.id%type;
l_cle_id        okl_k_lines.id%type;
l_lty_code      okc_line_styles_b.lty_code%type;



l_api_name      CONSTANT VARCHAR2(30) := 'validate_fee';
l_api_version    CONSTANT NUMBER      := 1.0;

l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;



CURSOR check_item_csr(p_chr_id NUMBER, p_lty_code VARCHAR2, p_id1 VARCHAR2, p_id2 VARCHAR2) IS

select count(1)

from  okc_k_items cim
      , okc_k_lines_b cle
      , okc_line_style_sources lss
      , okc_line_styles_b lse
where  nvl(lss.start_date,sysdate) <= sysdate
and    nvl(lss.end_date,sysdate + 1) > sysdate
and    lse.id = lss.lse_id
and    cle.lse_id = lse.id
and    cle.id = cim.cle_id
and    cim.object1_id1 = p_id1
and    cim.object1_id2 = p_id2
and    cim.chr_id = p_chr_id
and    cim.dnz_chr_id = p_chr_id
and    lse.lty_code = p_lty_code;



CURSOR get_item_csr(p_chr_id NUMBER, p_cle_id NUMBER) IS

SELECT lse.lty_code, cim.object1_id1, cim.object1_id2
from  okc_k_items cim
     , okc_k_lines_b cle
     , okc_line_style_sources lss
     , okc_line_styles_b lse
where  nvl(lss.start_date,sysdate) <= sysdate
and    nvl(lss.end_date,sysdate + 1) > sysdate
and    lse.id = lss.lse_id
and    cle.lse_id = lse.id
and    cle.id = cim.cle_id
and    cim.chr_id = p_chr_id
and    cim.dnz_chr_id = p_chr_id
and    cle.id = p_cle_id;



Begin

  If okl_context.get_okc_org_id  is null then
    l_chr_id := p_chr_id;
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



  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then

      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_Chr_Id');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ElsIf ( p_item_name is null or p_item_name =  OKC_API.G_MISS_CHAR)

  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_Fee_Name');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ElsIf ( p_lty_code is null or p_lty_code =  OKC_API.G_MISS_CHAR)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_Lty_Code');
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;


--Added by kthiruva 23-Sep-2003 Bug No.3156265

-- For Object code 'OKX_STRMTYP'

   IF (p_lty_code = 'FEE') THEN

      OPEN okl_strmtyp_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;
         l_item_id2  := Null;
         l_item_name := Null;
         l_item_description := Null;

     Fetch okl_strmtyp_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

     If okl_strmtyp_csr%NotFound Then

        x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
        l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

        OKC_API.SET_MESSAGE(p_app_name => g_app_name
                          , p_msg_name => 'OKL_INVALID_VALUE'
                          , p_token1 => 'COL_NAME'
                         , p_token1_value => l_service_ak_prompt
                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;


    l_item_id11 := l_item_id1;
    l_item_id22 := l_item_id2;


   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okl_strmtyp_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

    If okl_strmtyp_csr%Found Then

           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
              x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
             l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
             OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                          , p_msg_name => 'OKL_INVALID_VALUE'
                          , p_token1 => 'COL_NAME'
                         , p_token1_value => l_service_ak_prompt
                      );

              raise OKC_API.G_EXCEPTION_ERROR;

           End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

               x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_service_ak_prompt
                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        row_count := 0;

        Loop

         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then
            l_item_id11 := l_item_id1;
            l_item_id22 := l_item_id2;
            row_count := 1;
            Exit;
         End If;
         Fetch okl_strmtyp_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
         Exit When okl_strmtyp_csr%NotFound;
        End Loop;

    If row_count <> 1 Then
          x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
          OKC_API.SET_MESSAGE(p_app_name => g_app_name
                      , p_msg_name => 'OKL_INVALID_VALUE'
                      , p_token1 => 'COL_NAME'
                      , p_token1_value => l_service_ak_prompt
                     );

          raise OKC_API.G_EXCEPTION_ERROR;

    End If;
  End If;
   End If;

    p_item_id1 := l_item_id11;
    p_item_id2 := l_item_id22;

  Close okl_strmtyp_csr;

 END IF;

-- For Object Code 'OKL_USAGE'

    IF (p_lty_code = 'USAGE') THEN
        OPEN okl_usage_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);

         l_item_id1  := Null;
         l_item_id2  := Null;
         l_item_name := Null;
         l_item_description := Null;
         Fetch okl_usage_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
         If okl_usage_csr%NotFound Then
            x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
            l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
             OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                        , p_msg_name => 'OKL_INVALID_VALUE'
                        , p_token1 => 'COL_NAME'
                        , p_token1_value => l_service_ak_prompt
                     );

             raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;
    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then
       null;
   Else
    Fetch okl_usage_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

     If okl_usage_csr%Found Then
           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
          x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(p_app_name => g_app_name
                            , p_msg_name => 'OKL_INVALID_VALUE'
                            , p_token1 => 'COL_NAME'
                           , p_token1_value => l_service_ak_prompt);

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then
           x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
          OKC_API.SET_MESSAGE(p_app_name => g_app_name
                             , p_msg_name => 'OKL_INVALID_VALUE'
                            , p_token1 => 'COL_NAME'
                           , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okl_usage_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okl_usage_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okl_usage_csr;

 END IF;

-- For Object Code ' OKX_ASSET '

   IF (p_lty_code = 'FIXED_ASSET') THEN

      OPEN okx_asset_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_asset_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_asset_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_asset_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;





      If okx_asset_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_asset_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_asset_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okx_asset_csr;

 END IF;

-- For Object Code 'OKX_COVASST'

   IF (p_lty_code ='LINK_SERV_ASSET' OR p_lty_code = 'LINK_USAGE_ASSET') THEN

     OPEN okx_covasst_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_covasst_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_covasst_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_covasst_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
      If okx_covasst_csr%Found Then
           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then
          x_return_status := OKC_API.g_ret_sts_error;
          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');
          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

        row_count := 0;
        Loop
         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then
      l_item_id11 := l_item_id1;
            l_item_id22 := l_item_id2;
            row_count := 1;
            Exit;
         End If;
         Fetch okx_covasst_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;
         Exit When okx_covasst_csr%NotFound;
        End Loop;


    If row_count <> 1 Then
     x_return_status := OKC_API.g_ret_sts_error;

          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');

          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');
          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okx_covasst_csr;

 END IF;

-- For Object Code 'OKX_IB_ITEM'

    IF (p_lty_code = 'INST_ITEM') THEN

      OPEN okx_ib_item_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_ib_item_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_ib_item_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_ib_item_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;





      If okx_ib_item_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_ib_item_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_ib_item_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okx_ib_item_csr;

 END IF;

-- For Object Code 'OKX_LEASE'

     IF (p_lty_code = 'SHARED') THEN

         OPEN okx_lease_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_lease_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_lease_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_lease_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;





      If okx_lease_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_lease_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_lease_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okx_lease_csr;

 END IF;

-- For Object Code 'OKX_SERVICE'

     IF (p_lty_code ='SOLD_SERVICE') THEN

        OPEN okx_service_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_service_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_service_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_service_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;





      If okx_service_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_service_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_service_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;



  Close okx_service_csr;

 END IF;

-- For Object Code 'OKX_SYSITEM'

   IF (p_lty_code = 'ITEM' or p_lty_code ='ADD_ITEM') THEN

      OPEN okx_sysitem_csr(p_name => p_item_name,
                           p_id1  => l_item_id1,
                           p_id2  => l_item_id2);



         l_item_id1  := Null;

         l_item_id2  := Null;

         l_item_name := Null;

         l_item_description := Null;

     Fetch okx_sysitem_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;



    If okx_sysitem_csr%NotFound Then

      x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

      raise OKC_API.G_EXCEPTION_ERROR;

    End If;



    l_item_id11 := l_item_id1;

    l_item_id22 := l_item_id2;



   If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

       null;

   Else



    Fetch okx_sysitem_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;





      If okx_sysitem_csr%Found Then



           If( p_item_id1 is null or p_item_id1 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;

           If( p_item_id2 is null or p_item_id2 = OKC_API.G_MISS_CHAR) then

          x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

          raise OKC_API.G_EXCEPTION_ERROR;

        End If;



        row_count := 0;



        Loop



         If l_item_id1 = p_item_id1 and l_item_id2 = p_item_id2  Then

      l_item_id11 := l_item_id1;

            l_item_id22 := l_item_id2;

            row_count := 1;

            Exit;

         End If;

         Fetch okx_sysitem_csr into  l_item_id1,l_item_id2,l_item_name,l_item_description;

         Exit When okx_sysitem_csr%NotFound;

        End Loop;



    If row_count <> 1 Then

     x_return_status := OKC_API.g_ret_sts_error;



          -- OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_INVALID_VALUE');



          l_service_ak_prompt := GET_AK_PROMPT('OKL_LA_SERVICE_LINE', 'OKL_LA_SERVICE');

          OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                      , p_msg_name => 'OKL_INVALID_VALUE'

                      , p_token1 => 'COL_NAME'

                      , p_token1_value => l_service_ak_prompt

                     );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



     End If;



   End If;



    p_item_id1 := l_item_id11;

    p_item_id2 := l_item_id22;

  Close okx_sysitem_csr;

 END IF;



  If p_cle_id is null or p_cle_id =  OKC_API.G_MISS_NUM  Then

      OPEN check_item_csr(p_chr_id, p_lty_code, p_item_id1, p_item_id2 );

      FETCH check_item_csr INTO row_count;

      CLOSE check_item_csr;

      If row_count = 1 Then

         x_return_status := OKC_API.g_ret_sts_error;

         OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_DUPLICATE_SERVICE_FEE');

         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

  Else

      OPEN get_item_csr(p_chr_id, p_cle_id );

      FETCH get_item_csr INTO l_lty_code, l_item_id1, l_item_id2;

      CLOSE get_item_csr;



      If l_lty_code = p_lty_code and l_item_id1 <> p_item_id1 Then

          OPEN check_item_csr(p_chr_id, p_lty_code, p_item_id1, p_item_id2);

          FETCH check_item_csr INTO row_count;

          CLOSE check_item_csr;

           If row_count = 1 Then

           x_return_status := OKC_API.g_ret_sts_error;

          OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_DUPLICATE_SERVICE_FEE');

          raise OKC_API.G_EXCEPTION_ERROR;

         End If;

      End If;

  End If;



  x_return_status := OKC_API.G_RET_STS_SUCCESS;



  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count,x_msg_data => x_msg_data);



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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
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

     IF okx_lease_csr%ISOPEN THEN
        CLOSE okx_lease_csr;
     END IF;

     IF okx_service_csr%ISOPEN THEN
        CLOSE okx_service_csr;
     END IF;

     IF okx_sysitem_csr%ISOPEN THEN
        CLOSE okx_sysitem_csr;
     END IF;



End Validate_Fee;



-- Start of comments
--
-- Procedure Name  : Validate_Creditline
-- Description     : creates a deal based on the information that comes
--                   from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
Procedure Validate_Creditline (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER,
                     p_deal_type           IN   VARCHAR2,
                     p_mla_no              IN   VARCHAR2,
                     p_cl_no               IN   VARCHAR2
                     ) AS
    l_api_name        VARCHAR2(30) := 'validate_creditline';
    l_api_version     CONSTANT NUMBER     := 1.0;

    l_ak_prompt       AK_ATTRIBUTES_VL.attribute_label_long%type;
    l_chr_id          okc_k_headers_b.id%type := null;
    l_mla_cl_id       okc_k_headers_b.id%type := null;
    l_mla_id          okc_k_headers_b.id%type := null;
    l_cl_k_no         okc_k_headers_b.contract_number%type := null;
    l_cl_id           okc_k_headers_b.id%type := null;
    l_mla_no          okc_k_headers_b.contract_number%type := null;
    l_fund_yn         varchar2(1) := null;
    l_mla_cl_yn       varchar2(1) := null;
    l_yes             varchar2(1) := null;
    l_cl_rev_yn       okl_k_headers.revolving_credit_yn%type := null;
    l_mla_cl_rev_yn   okl_k_headers.revolving_credit_yn%type := null;

    cursor is_cl_exsts_csr is
     select cl.id, cl.contract_number
     from   okc_governances gvr,
            okc_k_headers_b chr,
            okc_k_headers_b cl,
            okl_k_headers khr
     where  chr.id = gvr.chr_id
     and    chr.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = cl.id
     and    cl.id = khr.id
     and    cl.scs_code = 'CREDITLINE_CONTRACT'
     and    chr.id = p_chr_id;

    cursor is_mla_cl_yn_csr is
     select 'Y'
     from   okc_governances gvr,
            okc_k_headers_b mla,
            okc_k_headers_b cl,
            okl_k_headers khr
     where  mla.id = gvr.chr_id
     and    mla.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = cl.id
     and    cl.id = khr.id
     and    cl.scs_code = 'CREDITLINE_CONTRACT'
     and    mla.contract_number = p_mla_no;

/* Bug 4502554
 *
 *  cursor is_mla_cl_exsts_csr is
 *   select cl.id, mla.contract_number, khr.revolving_credit_yn
 *   from   okc_governances gvr,
 *          okc_k_headers_b mla,
 *          okc_k_headers_b cl,
 *          okl_k_headers khr
 *   where  mla.id = gvr.chr_id
 *   and    mla.id = gvr.dnz_chr_id
 *   and    gvr.cle_id is null
 *   and    gvr.chr_id_referred = cl.id
 *   and    cl.id = khr.id
 *   and    cl.scs_code = 'CREDITLINE_CONTRACT'
 *   and    exists ( select 1
 *                   from okc_k_headers_b chr,
 *                        okc_governances mla_gvr
 *                   where chr.id =  mla_gvr.chr_id
 *                   and   chr.id =  mla_gvr.dnz_chr_id
 *                   and   mla_gvr.cle_id is null
 *                   and   mla_gvr.chr_id_referred = mla.id
 *                   and   chr.id = p_chr_id
 *              );
*/
    -- Modifed cursor, Bug 4502554
    cursor is_mla_cl_exsts_csr is
    select cl.id, mla.contract_number, khr.revolving_credit_yn
    from   okc_governances gvr,
           okc_k_headers_b mla,
           okc_k_headers_b cl,
           okl_k_headers khr,
           okc_governances mla_gvr
    where  mla.id              = gvr.chr_id
    and    mla.id              = gvr.dnz_chr_id
    and    gvr.cle_id          is null
    and    gvr.chr_id_referred = cl.id
    and    cl.id               = khr.id
    and    cl.scs_code         = 'CREDITLINE_CONTRACT'
    and    mla_gvr.dnz_chr_id  = p_chr_id -- contract id
    and    mla_gvr.cle_id      is null
    and    mla.id              = mla_gvr.chr_id_referred
    and    mla.scs_code        = 'MASTER_LEASE';

    cursor is_k_fund_aprvd_csr is
        select 'Y'
        from  okl_trx_ap_invoices_b ap
        where ap.khr_id =  p_chr_id
        and  ap.funding_type_code is not null
        and  ap.trx_status_code in ('APPROVED', 'PROCESSED');

    cursor is_cl_revlvng_csr(l_cl_no in varchar2) is
     select khr.revolving_credit_yn
     from   okc_k_headers_b cl1,
            okl_k_headers khr
     where  cl1.scs_code = 'CREDITLINE_CONTRACT'
     and    khr.id = cl1.id
     and    cl1.contract_number = l_cl_no;

    cursor is_mla_cl_rev_yn_csr is
     select khr.revolving_credit_yn
     from   okc_governances gvr,
            okc_k_headers_b mla,
            okc_k_headers_b cl,
            okl_k_headers khr
     where  mla.id = gvr.chr_id
     and    mla.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = cl.id
     and    cl.id = khr.id
     and    cl.scs_code = 'CREDITLINE_CONTRACT'
     and    mla.contract_number = p_mla_no;

    cursor get_k_id_csr(p_k_no IN VARCHAR2) is
      select id
      from okl_k_headers_full_v
      where contract_number = p_k_no;

  BEGIN

  l_chr_id := p_chr_id;
  If okl_context.get_okc_org_id  is null then
        okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

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

  l_fund_yn := null;
  open is_k_fund_aprvd_csr;
  fetch is_k_fund_aprvd_csr into l_fund_yn;
  close is_k_fund_aprvd_csr;

-- check the contract master lease
  l_mla_cl_id := null;
  l_mla_no := null;
  l_mla_cl_rev_yn := null;
  open  is_mla_cl_exsts_csr;
  fetch is_mla_cl_exsts_csr into l_mla_cl_id,l_mla_no,l_mla_cl_rev_yn;
  close is_mla_cl_exsts_csr;

-- check the contract credit line
  l_cl_k_no := null;
  l_cl_id := null;
  open  is_cl_exsts_csr;
  fetch is_cl_exsts_csr into l_cl_id,l_cl_k_no;
  close is_cl_exsts_csr;

  If ( l_cl_id is not null and l_fund_yn = 'Y') Then

     If( p_cl_no is null or l_cl_k_no <> p_cl_no) Then

         x_return_status := OKC_API.g_ret_sts_error;
              l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
              OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_CL_FUND_STS_CHK'
                                , p_token1 => 'COL_NAME'
                                , p_token1_value => l_cl_k_no
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

     End If;

  ElsIf ( p_cl_no is not null and l_cl_k_no is null and l_mla_cl_id is not null and l_fund_yn = 'Y') Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_CL_FUND_STS_CHK1'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

  End If;

-- check the mla contract credit line
  l_mla_cl_yn := 'N';
  open  is_mla_cl_yn_csr;
  fetch is_mla_cl_yn_csr into l_mla_cl_yn;
  close is_mla_cl_yn_csr;

  --if mla exists
  If ( l_mla_cl_id is not null and  l_fund_yn = 'Y' ) Then

    -- funding approved, can not change mla
    If( p_mla_no is null or l_mla_no <> p_mla_no) Then

         x_return_status := OKC_API.g_ret_sts_error;
           l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
           OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_MLA_CL_FUND_APRVD'
                                , p_token1 => 'COL_NAME'
                                , p_token1_value => l_mla_no
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

    End If;
  -- mla cl not attached
  ElsIf ( p_mla_no is not null and l_mla_cl_yn = 'Y' and l_cl_id is not null and l_fund_yn = 'Y') Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_MLA_CL_FUND_APRVD1'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

  End If;

  l_cl_rev_yn := null;
  If( p_cl_no is not null ) Then

   open is_cl_revlvng_csr(p_cl_no);
   fetch is_cl_revlvng_csr into l_cl_rev_yn;
   close is_cl_revlvng_csr;

  End If;

  l_mla_cl_rev_yn := null;
  If( p_mla_no is not null ) Then

   open is_mla_cl_rev_yn_csr;
   fetch is_mla_cl_rev_yn_csr into l_mla_cl_rev_yn;
   close is_mla_cl_rev_yn_csr;

  End If;

  -- validation for loan revolving
  If (p_deal_type = 'LOAN-REVOLVING') Then

      If (p_cl_no is not null and (l_cl_rev_yn is null or l_cl_rev_yn = 'N')) Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_REVOLVING_CREDIT'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

      -- if master lease exists and mla cl exists and rev yn is not null and cl rev yn is N

      If ( p_mla_no is not null and
            (l_mla_cl_yn is not null and l_mla_cl_yn = 'Y')  and
               (l_mla_cl_rev_yn is not null and l_mla_cl_rev_yn = 'N') ) Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_REVOLVING_CREDIT'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

  Else

      If (p_cl_no is not null and l_cl_rev_yn is not null and l_cl_rev_yn = 'Y') Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_NOT_REVOLVING_CREDIT'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

      If (p_mla_no is not null and
           (l_mla_cl_yn is not null and l_mla_cl_yn = 'Y')  and
              (l_mla_cl_rev_yn is not null and l_mla_cl_rev_yn = 'Y')) Then

         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_NOT_REVOLVING_CREDIT'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;

      End If;

  End If; -- end of loan revolving

  l_mla_id := null;
  open get_k_id_csr(p_mla_no);
  fetch get_k_id_csr into l_mla_id;
  close get_k_id_csr;

  l_cl_id := null;
  open get_k_id_csr(p_cl_no);
  fetch get_k_id_csr into l_cl_id;
  close get_k_id_csr;

  OKL_FUNDING_PVT.refresh_fund_chklst (
      p_api_version    => p_api_version,
      p_init_msg_list  => p_init_msg_list,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_chr_id         => p_chr_id,
      p_MLA_id         => l_mla_id,
      p_creditline_id  => l_cl_id
      );

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OKC_API.END_ACTIVITY(x_msg_count => x_msg_count,  x_msg_data => x_msg_data);

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



-- Start of comments
--

-- Procedure Name  : validate_deal
-- Description     : creates a deal based on the information that comes
--                 from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE validate_deal(
            p_api_version                  IN NUMBER,
            p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_msg_count                    OUT NOCOPY NUMBER,
            x_msg_data                     OUT NOCOPY VARCHAR2,
            p_chr_id                       IN NUMBER,
            p_scs_code                     IN VARCHAR2,
            p_contract_number              IN VARCHAR2,
            p_customer_id1                 IN OUT NOCOPY VARCHAR2,
            p_customer_id2                 IN OUT NOCOPY VARCHAR2,
            p_customer_code                IN OUT NOCOPY VARCHAR2,
            p_customer_name                IN  VARCHAR2,
            p_chr_cust_acct_id             OUT NOCOPY NUMBER,
            p_customer_acc_name            IN  VARCHAR2,
            p_product_name                 IN  VARCHAR2,
            p_product_id                   IN OUT NOCOPY VARCHAR2,
            p_product_desc                 IN OUT NOCOPY VARCHAR2,
            p_contact_id1                  IN OUT NOCOPY VARCHAR2,
            p_contact_id2                  IN OUT NOCOPY VARCHAR2,
            p_contact_code                 IN OUT NOCOPY VARCHAR2,
            p_contact_name                 IN  VARCHAR2,
            p_mla_no                       IN  VARCHAR2,
            p_mla_id                       IN OUT NOCOPY VARCHAR2,
            p_program_no                   IN  VARCHAR2,
            p_program_id                   IN OUT NOCOPY VARCHAR2,
            p_credit_line_no               IN  VARCHAR2,
            p_credit_line_id               IN OUT NOCOPY VARCHAR2,
            p_currency_name               IN  VARCHAR2,
            p_currency_code               IN OUT NOCOPY VARCHAR2,
            p_start_date                  IN  DATE,
            p_deal_type                   IN  VARCHAR2
            ) AS



    l_api_name            VARCHAR2(30) := 'validate_deal';
    l_api_version    CONSTANT NUMBER      := 1.0;

    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    -- Removed the assignment p_product_des from l_temp_yn
    l_temp_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;
    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;
    l_object_code     VARCHAR2(30) Default Null;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;
    l_chr_id    okl_k_headers_full_v.id%type;
    l_revolving_credit_yn okl_k_headers_full_v.revolving_credit_yn%type;
    l_row_count number;
    l_currency_code fnd_currencies_vl.currency_code%type := null;

    cursor l_chk_cust_acc_csr(p_cust_acc_id1 VARCHAR2, p_name VARCHAR2) is
    select ca.id1
    from okx_customer_accounts_v ca, okx_parties_v p
    where p.id1 = ca.party_id
    and ca.description = p_cust_acc_id1
    and p.name = p_name;

    cursor l_product_csr is
    select id, description
    from OKL_PRODUCTS_V
    where name = p_product_name
    and nvl(from_date,p_start_date) <= p_start_date
    and nvl(to_date,p_start_date+1) > p_start_date;

    cursor l_mla_csr is
    select id
    from OKL_k_headers_full_V
    where contract_number = p_mla_no
    and   scs_code = 'MASTER_LEASE'
    and STS_CODE = 'ACTIVE'
    and TEMPLATE_YN = 'N'
    and BUY_OR_SELL = 'S';

    cursor l_program_csr is
    select id
    from OKL_k_headers_full_V prg_hdr
    where contract_number = p_program_no
    and scs_code = 'PROGRAM'
    and nvl(TEMPLATE_YN, 'N') = 'N'
    and sts_code = 'ACTIVE'
    and exists (select 1 from okc_k_headers_b
            where id = p_chr_id
            and authoring_org_id = prg_hdr.authoring_org_id);

    cursor l_credit_line_csr(p_curr_code VARCHAR2) is
    select id, revolving_credit_yn
    from okl_k_hdr_crdtln_uv
    where  contract_number = p_credit_line_no
    and currency_code = p_curr_code
    and end_date >= p_start_date
    and cust_name  = p_customer_name
    and cust_acc_number = p_customer_acc_name;

    cursor l_currency_csr is
    select CURRENCY_CODE
    from okl_la_currencies_uv
    where CURRENCY_CODE = p_currency_code;


    row_cnt  number;
    l_orig_lse_object1_id1 okc_k_party_roles_b.object1_id1%type := null;
    l_re_book okc_k_headers_b.orig_system_source_code%type := null;
    l_orig_cust_acct_id okc_k_headers_b.cust_acct_id%type := null;

    cursor l_re_book_csr is
     select chr.orig_system_source_code, chr.cust_acct_id
     from OKC_K_HEADERS_B chr
     where chr.id = p_chr_id;

    cursor l_get_cust_csr is
     select object1_id1
     from okc_k_party_roles_b
     where rle_code = 'LESSEE'
     and  dnz_chr_id = p_chr_id
     and  chr_id =   p_chr_id;

      l_rollover_yn varchar2(1) := null;
      cursor l_rollover_fee_csr is
      select 'Y'
      from okc_k_lines_b cle,
           okl_k_lines kle
      where cle.id = kle.id
      and  cle.dnz_chr_id = p_chr_id
      and  cle.chr_id =   p_chr_id
      and  kle.fee_type = 'ROLLOVER';

      l_template_type_code OKL_K_HEADERS.TEMPLATE_TYPE_CODE%TYPE := NULL;
      CURSOR l_tmpl_type_code_csr IS
          SELECT chrb.template_yn,
                 khr.template_type_code
          FROM   okc_k_headers_b chrb,
                 okl_k_headers khr
          WHERE   chrb.id = khr.id
          AND chrb.id = p_chr_id;


 BEGIN



  If okl_context.get_okc_org_id  is null then

    l_chr_id := p_chr_id;

    okl_context.set_okc_org_context(p_chr_id => l_chr_id );

  End If;



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

-- contract number validation

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





-- mla validation



    If(p_mla_no is not null) Then

    p_mla_id := null;



    open l_mla_csr;

    fetch l_mla_csr into p_mla_id;

    close l_mla_csr;



     If p_mla_id is null Then

     x_return_status := OKC_API.g_ret_sts_error;

         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_MASTER_LEASE_NUMBER');

         OKC_API.SET_MESSAGE(     p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

     raise OKC_API.G_EXCEPTION_ERROR;

     End If;



    End If;


   l_temp_yn := null;
   l_template_type_code := null;
   open l_tmpl_type_code_csr;
   fetch l_tmpl_type_code_csr into l_temp_yn, l_template_type_code;
   close l_tmpl_type_code_csr;

   IF(l_template_type_code IS NULL) THEN
     l_template_type_code := 'XXX';
   END IF;

   IF(l_temp_yn IS NULL OR l_temp_yn = 'N') THEN
     l_temp_yn := 'N';
   END IF;


-- customer validation

  If(l_temp_yn = 'Y') Then



   If(p_customer_name  is not null) Then



    okl_la_validation_util_pvt.Get_Party_Jtot_data (

      p_api_version    => p_api_version,

      p_init_msg_list  => p_init_msg_list,

      x_return_status  => x_return_status,

      x_msg_count      => x_msg_count,

      x_msg_data       => x_msg_data,

      p_scs_code       => p_scs_code,

      p_buy_or_sell    => 'S',

      p_rle_code       => G_RLE_CODE,

      p_id1            => p_customer_id1,

      p_id2            => p_customer_id2,

      p_name           => p_customer_name,

      p_object_code    => p_customer_code,

      p_ak_region      => 'OKL_LA_DEAL_CREAT',

      p_ak_attribute   => 'OKL_CUSTOMER_NAME'

      );



    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then

       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then

       raise OKC_API.G_EXCEPTION_ERROR;

    End If;



  End If;



 Else

 if (l_template_type_code <> 'CONTRACT') THEN


   If(p_customer_name is null) Then

     x_return_status := OKC_API.g_ret_sts_error;

         l_ak_prompt := GET_AK_PROMPT('OKL_LA_DEAL_CREAT', 'OKL_CUSTOMER_NAME');

         OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_REQUIRED_VALUE'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;

okl_la_validation_util_pvt.Get_Party_Jtot_data (

      p_api_version    => p_api_version,

      p_init_msg_list  => p_init_msg_list,

      x_return_status  => x_return_status,

      x_msg_count      => x_msg_count,

      x_msg_data       => x_msg_data,

      p_scs_code       => p_scs_code,

      p_buy_or_sell    => 'S',

      p_rle_code       => G_RLE_CODE,

      p_id1            => p_customer_id1,

      p_id2            => p_customer_id2,

      p_name           => p_customer_name,

      p_object_code    => p_customer_code,

      p_ak_region      => 'OKL_LA_DEAL_CREAT',

      p_ak_attribute   => 'OKL_CUSTOMER_NAME'

      );



    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then

       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then

       raise OKC_API.G_EXCEPTION_ERROR;

    End If;

    End If;

 /*   okl_la_validation_util_pvt.Get_Party_Jtot_data (

      p_api_version    => p_api_version,

      p_init_msg_list  => p_init_msg_list,

      x_return_status  => x_return_status,

      x_msg_count      => x_msg_count,

      x_msg_data       => x_msg_data,

      p_scs_code       => p_scs_code,

      p_buy_or_sell    => 'S',

      p_rle_code       => G_RLE_CODE,

      p_id1            => p_customer_id1,

      p_id2            => p_customer_id2,

      p_name           => p_customer_name,

      p_object_code    => p_customer_code,

      p_ak_region      => 'OKL_LA_DEAL_CREAT',

      p_ak_attribute   => 'OKL_CUSTOMER_NAME'

      );



    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then

       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then

       raise OKC_API.G_EXCEPTION_ERROR;

    End If; */

-- rebook validation

   open l_re_book_csr;
   fetch l_re_book_csr into l_re_book, l_orig_cust_acct_id;
   close l_re_book_csr;

   If( l_re_book is not null and l_re_book = 'OKL_REBOOK') Then

    open l_get_cust_csr;
    fetch l_get_cust_csr into l_orig_lse_object1_id1;
    close l_get_cust_csr;


     If not( p_customer_id1 is not null and l_orig_lse_object1_id1 is not null and l_orig_lse_object1_id1 = p_customer_id1) Then
              OKC_API.SET_MESSAGE( p_app_name => g_app_name
                         , p_msg_name => 'OKL_REBOOK_CUST_VALIDATION'
               );

      raise OKC_API.G_EXCEPTION_ERROR;
     End If;

    End If;

   End If;

-- customer account validation

  If(l_temp_yn = 'Y') Then

   If(p_customer_acc_name  is not null) Then

    p_chr_cust_acct_id := null;

    open l_chk_cust_acc_csr(p_customer_acc_name,p_customer_name);

    fetch l_chk_cust_acc_csr into p_chr_cust_acct_id;

    close l_chk_cust_acc_csr;



    If p_chr_cust_acct_id is null Then

     x_return_status := OKC_API.g_ret_sts_error;

         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');

         OKC_API.SET_MESSAGE(      p_app_name => g_app_name

                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'

                , p_token1 => 'COL_NAME'

                , p_token1_value => l_ak_prompt

               );

     raise OKC_API.G_EXCEPTION_ERROR;

    End If;



   End If;



 Else

IF (l_template_type_code <> 'CONTRACT') THEN
    If(p_customer_acc_name is null) Then
        x_return_status := OKC_API.g_ret_sts_error;
        l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
        OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_REQUIRED_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
     raise OKC_API.G_EXCEPTION_ERROR;
    End If;
end if;

    p_chr_cust_acct_id := null;
    open l_chk_cust_acc_csr(p_customer_acc_name,p_customer_name);
    fetch l_chk_cust_acc_csr into p_chr_cust_acct_id ;
    close l_chk_cust_acc_csr;

IF (l_template_type_code <> 'CONTRACT') THEN
    If p_chr_cust_acct_id is null Then
     x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CUSTOMER_ACCOUNT_N');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
     raise OKC_API.G_EXCEPTION_ERROR;
    End If;
end if;
   -- rebook validation

   If( l_re_book is not null and l_re_book = 'OKL_REBOOK') Then

    If not( p_chr_cust_acct_id is not null and l_orig_cust_acct_id is not null and l_orig_cust_acct_id = p_chr_cust_acct_id) Then
              OKC_API.SET_MESSAGE( p_app_name => g_app_name
                         , p_msg_name => 'OKL_REBOOK_CUST_VALIDATION'
               );

      raise OKC_API.G_EXCEPTION_ERROR;
     End If;

    End If;

  End If;


  If(l_temp_yn = 'Y') Then

   l_rollover_yn := null;
   open l_rollover_fee_csr;
   fetch l_rollover_fee_csr into  l_rollover_yn;
   close l_rollover_fee_csr;

    If (l_rollover_yn = 'Y') Then
     x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_RQ_NO_K_TMP' -- Rollover Fee attached, cannot create teplate contract
               );
     raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  End If;

-- product validation

  If(l_temp_yn = 'Y' AND l_template_type_code IN ('PROGRAM','LEASEAPP')) Then

   If( p_product_name is not null) Then

    p_product_id := null;
    p_product_desc := null;

    open l_product_csr;
    fetch l_product_csr into p_product_id,p_product_desc;
    close l_product_csr;

    If p_product_id is null Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;
    End If;

   End If;

  Else

    If(p_product_name is null) Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(      p_app_name => g_app_name
                , p_msg_name => 'OKL_REQUIRED_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;
    End If;


    p_product_id := null;
    p_product_desc := null;

    open l_product_csr;
    fetch l_product_csr into p_product_id,p_product_desc;
    close l_product_csr;

    If p_product_id is null Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PRODUCT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;

    End If;

  End If;


-- program validation

    p_program_id := null;

    If(p_program_no is not null) Then

     open l_program_csr;
     fetch l_program_csr into p_program_id;
     close l_program_csr;

     If p_program_id is null Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_PROGRAM');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );
         raise OKC_API.G_EXCEPTION_ERROR;

     End If;

    End If;



-- Currency validation

    If(p_currency_code is null) Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CURRENCY');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

         raise OKC_API.G_EXCEPTION_ERROR;

     End If;


     l_currency_code := null;

     open l_currency_csr;
     fetch l_currency_csr into l_currency_code;
     close l_currency_csr;

     If l_currency_code is null Then

         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CURRENCY');
         OKC_API.SET_MESSAGE(
                  p_app_name => g_app_name
                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                , p_token1 => 'COL_NAME'
                , p_token1_value => l_ak_prompt
               );

         raise OKC_API.G_EXCEPTION_ERROR;

     End If;

    -- creditline validation

    If(p_credit_line_no is not null) Then

      p_credit_line_id := null;
      l_revolving_credit_yn := null;

      open l_credit_line_csr(p_currency_code);
      fetch l_credit_line_csr into p_credit_line_id,l_revolving_credit_yn;
      close l_credit_line_csr;

      If p_credit_line_id is null Then
         x_return_status := OKC_API.g_ret_sts_error;
         l_ak_prompt := GET_AK_PROMPT('OKL_CONTRACT_DTLS', 'OKL_KDTLS_CREDIT_CONTRACT');
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_LLA_INVALID_LOV_VALUE'
                                , p_token1 => 'COL_NAME'
                                , p_token1_value => l_ak_prompt

                           );
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;
    End If;



-- contact validation

   If(p_contact_name is not null) Then

     okl_la_validation_util_pvt.Validate_Contact (

       p_api_version    => p_api_version,

       p_init_msg_list  => p_init_msg_list,

       x_return_status  => x_return_status,

       x_msg_count      => x_msg_count,

       x_msg_data       => x_msg_data,

       p_chr_id         => p_chr_id,

       p_rle_code       => 'LESSOR',

       p_cro_code       => 'SALESPERSON',

       p_id1            => p_contact_id1,

       p_id2            => p_contact_id2,

       p_name           => p_contact_name,

       p_object_code    => p_contact_code,

       p_ak_region      => 'OKL_CONTRACT_DTLS',

       p_ak_attribute   => 'OKL_KDTLS_SALES_REPRESENTATIVE'

       );



     If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then

        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

     Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then

        raise OKC_API.G_EXCEPTION_ERROR;

     End If;



   End If;





   OKC_API.END_ACTIVITY(x_msg_count    => x_msg_count,

             x_msg_data    => x_msg_data);

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



Procedure Validate_Service (p_api_version  IN   NUMBER,

                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,

                     x_return_status       OUT  NOCOPY    VARCHAR2,

                     x_msg_count       OUT  NOCOPY    NUMBER,

                     x_msg_data               OUT  NOCOPY    VARCHAR2,

                     p_chr_id              IN    NUMBER,

                     p_cle_id              IN    NUMBER,

                     p_lty_code            IN   VARCHAR2,

                     p_item_id1            IN OUT NOCOPY VARCHAR2,

                     p_item_id2            IN OUT NOCOPY VARCHAR2,

                     p_item_name           IN   VARCHAR2,

                     p_item_object_code    IN OUT NOCOPY VARCHAR2,

                     p_cpl_id              IN    NUMBER,

                     p_rle_code            IN    VARCHAR2,

                     p_party_id1             IN OUT NOCOPY VARCHAR2,

                     p_party_id2           IN OUT NOCOPY VARCHAR2,

                     p_party_name          IN   VARCHAR2,

                     p_party_object_code   IN OUT NOCOPY VARCHAR2,

                     p_amount              IN NUMBER

                     ) AS

    l_api_name            VARCHAR2(30) := 'validate_deal';

    l_api_version    CONSTANT NUMBER      := 1.0;



    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;

    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;

    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;

    l_object_code     VARCHAR2(30) Default Null;



    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_chr_id    NUMBER;



    row_cnt  number;



  BEGIN



  If okl_context.get_okc_org_id  is null then

    l_chr_id := p_chr_id;

    okl_context.set_okc_org_context(p_chr_id => l_chr_id );

  End If;



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



   OKC_API.END_ACTIVITY(x_msg_count    => x_msg_count,

             x_msg_data    => x_msg_data);

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



Procedure Validate_Fee (p_api_version  IN   NUMBER,

                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,

                     x_return_status       OUT  NOCOPY    VARCHAR2,

                     x_msg_count       OUT  NOCOPY    NUMBER,

                     x_msg_data               OUT  NOCOPY    VARCHAR2,

                     p_chr_id              IN    NUMBER,

                     p_cle_id              IN    NUMBER,

                     p_lty_code            IN   VARCHAR2,

                     p_item_id1            IN OUT NOCOPY VARCHAR2,

                     p_item_id2            IN OUT NOCOPY VARCHAR2,

                     p_item_name           IN   VARCHAR2,

                     p_item_object_code    IN OUT  NOCOPY VARCHAR2,

                     p_cpl_id              IN    NUMBER,

                     p_rle_code            IN    VARCHAR2,

                     p_party_id1             IN OUT NOCOPY VARCHAR2,

                     p_party_id2           IN OUT NOCOPY VARCHAR2,

                     p_party_name          IN   VARCHAR2,

                     p_party_object_code   IN OUT NOCOPY VARCHAR2,

                     p_amount              IN NUMBER

                     ) AS

    l_api_name            VARCHAR2(30) := 'validate_deal';

    l_api_version    CONSTANT NUMBER      := 1.0;



    l_template_yn        OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;

    l_chr_type           OKC_K_HEADERS_B.CHR_TYPE%TYPE;

    l_contract_number    OKC_K_HEADERS_B.CHR_TYPE%TYPE;

    l_object_code     VARCHAR2(30) Default Null;



    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_chr_id    NUMBER;



    row_cnt  number;



  BEGIN



  If okl_context.get_okc_org_id  is null then

    l_chr_id := p_chr_id;

    okl_context.set_okc_org_context(p_chr_id => l_chr_id );

  End If;



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



   OKC_API.END_ACTIVITY(x_msg_count    => x_msg_count,

             x_msg_data    => x_msg_data);

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



Procedure Validate_Fee (p_api_version  IN   NUMBER,

                     p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,

                     x_return_status       OUT  NOCOPY    VARCHAR2,

                     x_msg_count       OUT  NOCOPY    NUMBER,

                     x_msg_data               OUT  NOCOPY    VARCHAR2,

                     p_chr_id              IN    NUMBER,

                     p_cle_id              IN    NUMBER,

                     p_amount              IN   NUMBER,

                     p_init_direct_cost    IN   NUMBER

                     ) AS

    l_api_name            VARCHAR2(30) := 'validate_fee';

    l_api_version    CONSTANT NUMBER      := 1.0;



    l_object_code     VARCHAR2(30) Default Null;

    l_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;

    l_chr_id    NUMBER;



  BEGIN



  l_chr_id := p_chr_id;

  If okl_context.get_okc_org_id  is null then

    okl_context.set_okc_org_context(p_chr_id => l_chr_id );

  End If;



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



  IF ( (p_init_direct_cost is not null) and (p_init_direct_cost > p_amount)) THEN



      x_return_status := OKC_API.G_RET_STS_ERROR;

      OKC_API.SET_MESSAGE(        p_app_name => g_app_name

                  , p_msg_name => 'OKL_LLA_IDC_FEE'

                 );

      raise OKC_API.G_EXCEPTION_ERROR;



  END IF;



  x_return_status := OKC_API.G_RET_STS_SUCCESS;



  OKC_API.END_ACTIVITY(x_msg_count    => x_msg_count,

             x_msg_data    => x_msg_data);

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





----------Validation for Roles---------------------

--This Procedure validates jtot object detail for roles.

-----------------------------------------------------



PROCEDURE  VALIDATE_ROLE_JTOT (p_api_version         IN   NUMBER,

                               p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,

                               x_return_status       OUT  NOCOPY    VARCHAR2,

                               x_msg_count       OUT  NOCOPY    NUMBER,

                               x_msg_data             OUT  NOCOPY    VARCHAR2,

                               p_object_name    IN VARCHAR2,

                               p_id1            IN VARCHAR2,

                               p_id2            IN VARCHAR2)



IS







----OKX_OPERUNIT



CURSOR operunit_csr IS

select '1'

From   OKX_ORGANIZATION_DEFS_V OKX_OPERUNIT

WHERE    OKX_OPERUNIT.ORGANIZATION_TYPE = 'OPERATING_UNIT' AND

         OKX_OPERUNIT.INFORMATION_TYPE = 'Operating Unit Information'

AND      ID1 = p_id1

AND      ID2 = p_id2;





--OKX_VENDOR



CURSOR vendor_csr IS

select '1'

from OKX_VENDORS_V OKX_VENDOR

WHERE ID1 = p_id1

AND   ID2 = p_id2;





--OKX_PARTY



CURSOR party_csr IS

select '1'

FROM OKX_PARTIES_V OKX_PARTY

WHERE ID1 = p_id1

AND   ID2 = p_id2;



l_exist VARCHAR2(1);



l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'VALIDATE_ROLE_JTOT';





BEGIN



x_return_status := OKC_API.START_ACTIVITY(

            p_api_name      => l_api_name,

            p_pkg_name      => g_pkg_name,

            p_init_msg_list => p_init_msg_list,

            l_api_version   => l_api_version,

            p_api_version   => p_api_version,

            p_api_type      => g_api_type,

            x_return_status => x_return_status);



---- Validate Object Name





   IF (p_object_name IS NOT NULL) AND (p_object_name <> OKC_API.G_MISS_CHAR) AND

      (p_id1 IS NOT NULL) AND (p_id1 <> OKC_API.G_MISS_CHAR)  THEN



       IF p_object_name = 'OKX_OPERUNIT' THEN

          OPEN operunit_csr;

          FETCH operunit_csr INTO l_exist;

          CLOSE operunit_csr;

       ELSIF p_object_name = 'OKX_VENDOR' THEN

          OPEN vendor_csr;

          FETCH vendor_csr INTO l_exist;

          CLOSE vendor_csr;

       ELSIF p_object_name =  'OKX_PARTY' THEN

          OPEN party_csr;

          FETCH party_csr INTO l_exist;

          CLOSE party_csr;

       ELSE

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_OBJ',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);

           RAISE OKC_API.G_EXCEPTION_ERROR;

      END IF;



      IF (l_exist IS NULL)  THEN

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_IDS',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);



           RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;



 END IF;



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



END VALIDATE_ROLE_JTOT;





----------------------------------------------------------------------

----------Validation for Contacts-------------------------------------

--This function validates jtot object detail for Contact.

----------------------------------------------------------------------





PROCEDURE  VALIDATE_CONTACT_JTOT (p_api_version         IN   NUMBER,

                                  p_init_msg_list       IN    VARCHAR2 default OKC_API.G_FALSE,

                                  x_return_status       OUT  NOCOPY    VARCHAR2,

                                  x_msg_count       OUT  NOCOPY    NUMBER,

                                  x_msg_data             OUT  NOCOPY    VARCHAR2,

                                  p_object_name    IN VARCHAR2,

                                  p_id1            IN VARCHAR2,

                                  p_id2            IN VARCHAR2)



IS





--OKX_SALEPERS



CURSOR salepers_csr IS

select '1' from

OKX_SALESREPS_V OKX_SALEPERS

WHERE

((nvl(OKX_SALEPERS.ORG_ID, -99) =  nvl(mo_global.get_current_org_id, -99))

or (nvl(mo_global.get_current_org_id, -99) = -99))

AND ID1 = p_id1

AND ID2 = p_id2;





--OKX_PCONTACT



CURSOR pcontact_csr IS

select '1' from

OKX_PARTY_CONTACTS_V OKX_PCONTACT

WHERE ID1 = p_id1

AND   ID2 = p_id2;



l_Exist varchar2(1);

l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'VALIDATE_CONTACT_JTOT';







BEGIN



x_return_status := OKC_API.START_ACTIVITY(

            p_api_name      => l_api_name,

            p_pkg_name      => g_pkg_name,

            p_init_msg_list => p_init_msg_list,

            l_api_version   => l_api_version,

            p_api_version   => p_api_version,

            p_api_type      => g_api_type,

            x_return_status => x_return_status);



---- Validate Object Name



   IF (p_object_name IS NOT NULL) AND (p_object_name <> OKC_API.G_MISS_CHAR) AND

      (p_id1 IS NOT NULL) AND (p_id1 <> OKC_API.G_MISS_CHAR)  THEN



       IF p_object_name = 'OKX_SALEPERS' THEN

          OPEN salepers_csr;

          FETCH salepers_csr INTO l_exist;

          CLOSE salepers_csr;

       ELSIF p_object_name =  'OKX_PCONTACT' THEN

          OPEN pcontact_csr;

          FETCH pcontact_csr INTO l_exist;

          CLOSE pcontact_csr;

       ELSE

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_OBJ',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);

           RAISE OKC_API.G_EXCEPTION_ERROR;

      END IF;



     IF (l_exist IS NULL)  THEN

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_IDS',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);



           RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;



  END IF;





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

END VALIDATE_CONTACT_JTOT;







----------------------------------------------------------------------

----------Validation for Line Styles----------------------------------

----------------------------------------------------------------------





PROCEDURE  VALIDATE_STYLE_JTOT (p_api_version         IN   NUMBER,

                               p_init_msg_list       IN      VARCHAR2  default OKC_API.G_FALSE,

                               x_return_status       OUT  NOCOPY    VARCHAR2,

                               x_msg_count       OUT  NOCOPY    NUMBER,

                               x_msg_data             OUT  NOCOPY    VARCHAR2,

                               p_object_name       IN   VARCHAR2,

                               p_id1               IN   VARCHAR2,

                               p_id2               IN   VARCHAR2)

IS



--OKL_STRMTYP



CURSOR strmtyp_csr IS

SELECT '1'

from OKL_STRMTYP_SOURCE_V OKL_STRMTYP

where OKL_STRMTYP.STATUS = 'A'

AND    ID1 = p_id1

AND   ID2 = p_id2;





--OKL_USAGE



CURSOR usage_csr IS

SELECT '1'

from OKL_USAGE_LINES_V OKL_USAGE

WHERE ID1 = p_id1

AND   ID2 = p_id2;







---OKX_ASSET



CURSOR asset_csr IS

SELECT '1'

from OKX_ASSETS_V OKX_ASSET

WHERE ID1 = p_id1

AND   ID2 = p_id2;





--OKX_COVASST



CURSOR covasst_csr IS

SELECT '1'

from OKX_COVERED_ASSET_V OKX_COVASST

where OKX_COVASST.OKC_LINE_STATUS NOT IN ('EXPIRED','TERMINATED','CANCELLED')

AND   ID1 = p_id1

AND   ID2 = p_id2;



---OKX_IB_ITEM



CURSOR ib_item_csr IS

SELECT '1'

from OKX_INSTALL_ITEMS_V OKX_IB_ITEM

WHERE   ID1 = p_id1

AND   ID2 = p_id2;





--OKX_LEASE



CURSOR lease_csr IS

SELECT '1'

from OKX_CONTRACTS_V OKX_LEASE

where OKX_LEASE.SCS_CODE IN ('LEASE','LOAN') AND NVL(OKX_LEASE.ORG_ID, -99) = mo_global.get_current_org_id

AND   ID1 = p_id1

AND   ID2 = p_id2;





--OKX_SERVICE





CURSOR service_csr IS

SELECT '1'

from OKX_SYSTEM_ITEMS_V OKX_SERVICE

where OKX_SERVICE.VENDOR_WARRANTY_FLAG='N' AND OKX_SERVICE.SERVICE_ITEM_FLAG='Y' AND OKX_SERVICE.ORGANIZATION_ID = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID')

AND   ID1 = p_id1

AND   ID2 = p_id2;





--OKX_SYSITEM



CURSOR system_csr IS

SELECT '1'

from OKX_SYSTEM_ITEMS_V OKX_SYSITEM

where
-- 4374085
-- OKX_SYSITEM.ORGANIZATION_ID = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID')

--AND
ID1 = p_id1

AND   ID2 = p_id2;

Cursor ins_policy_csr is

SELECT  '1'

FROM   OKL_I_POLICIES_V

WHERE  ID1  = p_id1

AND    ID2  = p_id2;



l_Exist VARCHAR2(1);

l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'VALIDATE_STYLE_JTOT';


BEGIN



   x_return_status := OKC_API.START_ACTIVITY(

            p_api_name      => l_api_name,

            p_pkg_name      => g_pkg_name,

            p_init_msg_list => p_init_msg_list,

            l_api_version   => l_api_version,

            p_api_version   => p_api_version,

            p_api_type      => g_api_type,

            x_return_status => x_return_status);



   IF (p_object_name IS NOT NULL) AND (p_object_name <> OKC_API.G_MISS_CHAR) AND

      (p_id1 IS NOT NULL) AND (p_id1 <> OKC_API.G_MISS_CHAR)  THEN



    IF p_object_name =  'OKL_STRMTYP' THEN

          OPEN strmtyp_csr;

          FETCH strmtyp_csr INTO l_exist;

          CLOSE strmtyp_csr;

       ELSIF p_object_name =  'OKL_USAGE' THEN

          OPEN usage_csr;

          FETCH usage_csr INTO l_exist;

          CLOSE usage_csr;

       ELSIF p_object_name =  'OKX_ASSET' THEN

          OPEN asset_csr;

          FETCH asset_csr INTO l_exist;

          CLOSE asset_csr;

       ELSIF p_object_name =  'OKX_COVASST' THEN

          OPEN covasst_csr;

          FETCH covasst_csr INTO l_exist;

          CLOSE covasst_csr;

       ELSIF p_object_name =  'OKX_IB_ITEM' THEN

          OPEN ib_item_csr;

          FETCH ib_item_csr INTO l_exist;

          CLOSE ib_item_csr;

       ELSIF p_object_name =  'OKX_LEASE' THEN

          OPEN lease_csr;

          FETCH lease_csr INTO l_exist;

          CLOSE lease_csr;

       ELSIF p_object_name =  'OKX_SERVICE' THEN

          OPEN service_csr;

          FETCH service_csr INTO l_exist;

          CLOSE service_csr;

       ELSIF p_object_name =  'OKX_SYSITEM' THEN

          OPEN system_csr;

          FETCH system_csr INTO l_exist;

          CLOSE system_csr;

       ELSIF p_object_name =  'OKL_INPOLICY' THEN

          OPEN ins_policy_csr;

          FETCH ins_policy_csr INTO l_exist;

          CLOSE ins_policy_csr;

       ELSE

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_OBJ',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);

           RAISE OKC_API.G_EXCEPTION_ERROR;

      END IF;



     IF (l_exist IS NULL) THEN

           OKC_API.Set_Message(p_app_name     => G_APP_NAME,

                               p_msg_name     => 'OKL_LLA_INVALID_IDS',

                               p_token1       => 'OBJECT_NAME',

                               p_token1_value => p_object_name);



           RAISE OKC_API.G_EXCEPTION_ERROR;

     END IF;



  END IF;



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



END VALIDATE_STYLE_JTOT;

-- Start of comments
--
-- Procedure Name  : validate_crdtln_wrng
-- Description     : creates a deal based on the information that comes
--                   from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
Procedure validate_crdtln_wrng (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     ) AS
    l_api_name        VARCHAR2(30) := 'validate_crdtln_wrng';
    l_api_version     CONSTANT NUMBER     := 1.0;

    l_mla_cl_gvr_id         okc_k_headers_b.id%type := null;
    l_k_cl_gvr_id           okc_k_headers_b.id%type := null;
    l_chr_id                okc_k_headers_b.id%type := null;

    cursor is_k_cl_gvr_exsts_csr is
     select gvr.id
     from   okc_governances gvr,
            okc_k_headers_b chr,
            okc_k_headers_b cl
     where  chr.id = gvr.chr_id
     and    chr.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = cl.id
     and    cl.scs_code = 'CREDITLINE_CONTRACT'
     and    chr.id = p_chr_id;

    cursor is_mla_cl_gvr_exsts_csr is
     select gvr.id
     from   okc_governances gvr,
            okc_k_headers_b chr,
            okc_k_headers_b mla
     where  chr.id = gvr.chr_id
     and    chr.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = mla.id
     and    mla.scs_code = 'MASTER_LEASE'
     and    chr.id = p_chr_id
     and    exists (select 1
                     from   okc_governances cl_gvr,
                            okc_k_headers_b cl
                     where   cl_gvr.chr_id = mla.id
                     and     cl_gvr.cle_id is null
                     and     cl_gvr.chr_id_referred = cl.id
                     and     cl.scs_code = 'CREDITLINE_CONTRACT'
                   );


  BEGIN

  l_chr_id := p_chr_id;
  If okl_context.get_okc_org_id  is null then
        okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

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

-- check the contract master lease cl
  l_mla_cl_gvr_id := null;
  open  is_mla_cl_gvr_exsts_csr;
  fetch is_mla_cl_gvr_exsts_csr into l_mla_cl_gvr_id;
  close is_mla_cl_gvr_exsts_csr;

-- check the contract credit line
  l_k_cl_gvr_id := null;
  open  is_k_cl_gvr_exsts_csr;
  fetch is_k_cl_gvr_exsts_csr into l_k_cl_gvr_id;
  close is_k_cl_gvr_exsts_csr;

  --if both exists, warning
  If ( l_mla_cl_gvr_id is not null and l_k_cl_gvr_id is not null) Then
         x_return_status := OKC_API.g_ret_sts_error;
         OKC_API.SET_MESSAGE(     p_app_name => g_app_name
                                , p_msg_name => 'OKL_MLA_CRDTLN'
                           );
         raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OKC_API.END_ACTIVITY(x_msg_count      => x_msg_count,
                         x_msg_data     => x_msg_data);
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

-- Start of comments
--
-- Procedure Name  : validate_crdtln_err
-- Description     : creates a deal based on the information that comes
--                   from the deal creation screen
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
Procedure validate_crdtln_err (p_api_version  IN   NUMBER,
                     p_init_msg_list       IN   VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status       OUT  NOCOPY  VARCHAR2,
                     x_msg_count           OUT  NOCOPY  NUMBER,
                     x_msg_data            OUT  NOCOPY  VARCHAR2,
                     p_chr_id              IN   NUMBER
                     ) AS
    l_api_name        VARCHAR2(30) := 'validate_crdtln_err';
    l_api_version     CONSTANT NUMBER     := 1.0;

    l_ak_prompt       AK_ATTRIBUTES_VL.attribute_label_long%type;
    l_chr_id          okc_k_headers_b.id%type := null;
    l_k_cl_no         okc_k_headers_b.contract_number%type := null;
    l_mla_no          okc_k_headers_b.contract_number%type := null;
    l_deal_type       okl_k_headers.deal_type%type := null;

    cursor get_deal_type_csr is
     select chr.deal_type
     from   okl_k_headers chr
     where  chr.id = p_chr_id;

    cursor is_cl_exsts_csr is
     select cl.contract_number
     from   okc_governances gvr,
            okc_k_headers_b chr,
            okc_k_headers_b cl
     where  chr.id = gvr.chr_id
     and    chr.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = cl.id
     and    cl.scs_code = 'CREDITLINE_CONTRACT'
     and    chr.id = p_chr_id;

    cursor is_mla_exsts_csr is
     select mla.contract_number
     from   okc_governances gvr,
            okc_k_headers_b chr,
            okc_k_headers_b mla
     where  chr.id = gvr.chr_id
     and    chr.id = gvr.dnz_chr_id
     and    gvr.cle_id is null
     and    gvr.chr_id_referred = mla.id
     and    mla.scs_code = 'MASTER_LEASE'
     and    chr.id = p_chr_id;


  BEGIN

  l_chr_id := p_chr_id;
  If okl_context.get_okc_org_id  is null then
        okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;

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

-- get contract deal type
  l_deal_type := null;
  open get_deal_type_csr;
  fetch get_deal_type_csr into l_deal_type;
  close get_deal_type_csr;

-- check for the contract credit line
  l_k_cl_no := null;
  open  is_cl_exsts_csr;
  fetch is_cl_exsts_csr into l_k_cl_no;
  close is_cl_exsts_csr;

-- check the contract master lease check
  l_mla_no := null;
  open  is_mla_exsts_csr;
  fetch is_mla_exsts_csr into l_mla_no;
  close is_mla_exsts_csr;

  validate_creditline(
       p_api_version    => p_api_version,
       p_init_msg_list  => p_init_msg_list,
       x_return_status  => x_return_status,
       x_msg_count      => x_msg_count,
       x_msg_data       => x_msg_data,
       p_chr_id         => p_chr_id,
       p_deal_type      => l_deal_type,
       p_mla_no         => l_mla_no,
       p_cl_no          => l_k_cl_no
       );

     If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
     End If;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OKC_API.END_ACTIVITY(x_msg_count      => x_msg_count, x_msg_data      => x_msg_data);

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

END okl_la_validation_util_pvt;

/
