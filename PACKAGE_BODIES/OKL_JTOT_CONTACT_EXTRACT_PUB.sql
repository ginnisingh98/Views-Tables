--------------------------------------------------------
--  DDL for Package Body OKL_JTOT_CONTACT_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_JTOT_CONTACT_EXTRACT_PUB" as
/* $Header: OKLPJCXB.pls 120.9 2007/08/21 07:30:13 pagarg noship $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_JTOT_CONTACT_EXTRACT_PUB';

   /*
   -- mvasudev, 09/09/2004
   -- Added Constants to enable Business Event
   */
  G_WF_EVT_KHR_PARTY_REMOVE  CONSTANT VARCHAR2(50) := 'oracle.apps.okl.la.lease_contract.remove_party';

   G_WF_ITM_CONTRACT_ID CONSTANT VARCHAR2(20)  := 'CONTRACT_ID';
   G_WF_ITM_PARTY_ID CONSTANT VARCHAR2(15)    := 'PARTY_ID';
   G_WF_ITM_CONTRACT_PROCESS CONSTANT VARCHAR2(20) := 'CONTRACT_PROCESS';
   G_WF_ITM_PARTY_ROLE_ID CONSTANT VARCHAR2(15)    := 'PARTY_ROLE_ID';

--For Object Code 'OKX_PARTY'
  CURSOR okx_party_csr(p_name VARCHAR2 , p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT prv.id1,
         prv.id2,
         prv.name,
         prv.description
  FROM  okx_parties_v prv
  WHERE prv.name = NVL(p_name,prv.name)
  AND   prv.id1  = p_id1
  AND   prv.id2  = NVL(p_id2,prv.id2)
  ORDER BY prv.name;

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
  SELECT  vev.id1,
          vev.id2,
          vev.name,
          vev.description
  FROM okx_vendors_v vev
  WHERE vev.name = NVL(p_name,vev.name)
  AND   vev.id1  = NVL(p_id1,vev.id1)
  AND   vev.id2  = NVL(p_id2,vev.id2)
  ORDER BY vev.NAME;


  FUNCTION GET_AK_PROMPT(p_ak_region	IN VARCHAR2, p_ak_attribute	IN VARCHAR2)
  RETURN VARCHAR2 IS

  	CURSOR ak_prompt_csr(p_ak_region VARCHAR2, p_ak_attribute VARCHAR2) IS
	--start modified abhsaxen for performance SQLID 20562543
	    select a.attribute_label_long
	 from ak_region_items ri, ak_regions r, ak_attributes_vl a
	 where ri.region_code = r.region_code
	 and ri.region_application_id = r.region_application_id
	 and ri.attribute_code = a.attribute_code
	 and ri.attribute_application_id = a.attribute_application_id
	 and ri.region_code  =  p_ak_region
	 and ri.attribute_code = p_ak_attribute
	--end modified abhsaxen for performance SQLID 20562543
	;
  	l_ak_prompt AK_ATTRIBUTES_VL.attribute_label_long%TYPE;
  BEGIN
  	OPEN ak_prompt_csr(p_ak_region, p_ak_attribute);
  	FETCH ak_prompt_csr INTO l_ak_prompt;
  	CLOSE ak_prompt_csr;
  	return(l_ak_prompt);
  END;

  FUNCTION GET_RLE_CODE_MEANING(p_rle_code	IN VARCHAR2, p_chr_id NUMBER)
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

--Bug# 2761680
--Start of Comments
--Procedure   : Get Party
--Description : Returns the SQL string for LOV of a party Role
--End of Comments
Procedure Get_Party (p_api_version         IN   NUMBER,
                     p_init_msg_list      IN    VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status      OUT NOCOPY    VARCHAR2,
                     x_msg_count                OUT NOCOPY      NUMBER,
                     x_msg_data         OUT NOCOPY      VARCHAR2,
                     p_role_code           IN  VARCHAR2,
                     p_intent              IN  VARCHAR2,
                     p_id1                 IN  VARCHAR2,
                     p_id2                 IN  VARCHAR2,
                     p_name                IN  VARCHAR2,
                     x_select_clause       OUT NOCOPY  VARCHAR2,
                     x_from_clause         OUT NOCOPY  VARCHAR2,
                     x_where_clause        OUT NOCOPY  VARCHAR2,
                     x_order_by_clause     OUT NOCOPY  VARCHAR2,
                     x_object_code         OUT NOCOPY  VARCHAR2) is
CURSOR  jtf_party_role_cur (p_role_code VARCHAR2, p_intent VARCHAR2) is
        select job.object_code OBJECT_CODE,
               job.object_code||'.ID1, '||
               job.object_code||'.ID2, '||
               job.object_code||'.NAME, '||
                       job.object_code||'.DESCRIPTION ' SELECT_CLAUSE,
               from_table FROM_CLAUSE,
               where_clause WHERE_CLAUSE,
               order_by_clause ORDER_BY_CLAUSE
       from    jtf_objects_b job,
               okc_role_sources rs
       where   job.object_code = rs.jtot_object_code
       and     nvl(job.start_date_active,sysdate) <= sysdate
       and     nvl(job.end_date_active,sysdate + 1) > sysdate
       and     rs.rle_code     = p_role_code
       and     rs.start_date <= sysdate
       and     nvl(rs.end_date,sysdate+1) > sysdate
       and     rs.buy_or_sell = p_intent;
jtf_party_role_rec jtf_party_role_cur%rowtype;
l_query_string      VARCHAR2(2000)     default Null;
l_where_clause      VARCHAR2(2000)     default Null;
Begin
    Open jtf_party_role_cur(p_role_code, p_intent);
         Fetch jtf_party_role_cur into jtf_party_role_rec;
         If jtf_party_role_cur%NOTFOUND Then
             --handle exception appropriately
             x_object_code     := 'NOT FOUND';
             x_select_clause   := 'NOT FOUND';
             x_from_clause     := 'NOT FOUND';
             x_where_clause    := 'NOT FOUND';
             x_order_by_clause := 'NOT FOUND';
         Else
             x_object_code     := jtf_party_role_rec.object_code;
             x_select_clause   := jtf_party_role_rec.select_clause;
             x_from_clause     := jtf_party_role_rec.from_clause;
             x_where_clause    := jtf_party_role_rec.where_clause;
             x_order_by_clause := jtf_party_role_rec.order_by_clause;
             If p_id1 is not null and p_id2 is not null and p_name is null then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' ID1 = '||''''||p_id1||''''||' AND '||' ID2 = '||''''||p_id2||''''
                into   l_where_clause
                from   dual;
                x_where_clause := l_where_clause;
             Elsif p_name is not null then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' NAME like '||''''||p_name||'%'||''''
                into   l_where_clause
                from   dual;
             End If;
         End If;
     Close jtf_party_role_cur;
End Get_Party;
--End Bug# 2761680

--Start of Comments
--Procedure   : Get Party
--Description : Returns Name, Description for a given role or all the roles
--              attached to a contract
--End of Comments
Procedure Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_chr_id		IN  VARCHAR2,
                     p_cle_id      IN  VARCHAR2,
                     p_role_code   IN  OKC_K_PARTY_ROLES_V.rle_code%Type,
                     p_intent      IN  VARCHAR2 default 'S',
                     x_party_tab   out NOCOPY party_tab_type) is

CURSOR party_role_curs(p_chr_id     IN NUMBER,
                       p_cle_id     IN NUMBER,
                       p_dnz_chr_id IN NUMBER,
                       p_role_code  IN VARCHAR2) is
       select object1_id1,
              object1_id2,
              jtot_object1_code,
              rle_code
       from   OKC_K_PARTY_ROLES_V
       where  rle_code = nvl(p_role_code,rle_code)
       and    nvl(cle_id,-99999)   = p_cle_id
       and    nvl(chr_id,-99999)   = p_chr_id
       and    dnz_chr_id           = decode(p_chr_id,null,dnz_chr_id,p_dnz_chr_id)
       order  by rle_code;
party_role_rec      party_role_curs%RowType;
l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;
l_id1               OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_Description       VARCHAR2(250) Default Null;
l_object_code       VARCHAR2(30) Default Null;
type                party_curs_type is REF CURSOR;
party_curs          party_curs_type;
i                   Number default 0;
l_chr_id			Number;
l_dnz_chr_id        Number;
l_cle_id            Number;
Begin

  If okl_context.get_okc_org_id  is null then
    	okl_context.set_okc_org_context(p_chr_id => l_chr_id );
  End If;


  If p_chr_id is not null and p_cle_id is null
  Then
     l_chr_id     := p_chr_id;
     l_cle_id     := -99999;
     l_dnz_chr_id := p_chr_id;
  ElsIf p_chr_id is null and p_cle_id is not null
  Then
     l_chr_id     := -99999;
     l_cle_id     := p_cle_id;
     l_dnz_chr_id := -99999;
  ElsIf p_chr_id is not null and p_cle_id is not null
  Then
     l_chr_id     := -99999;
     l_cle_id     := p_cle_id;
     l_dnz_chr_id := p_chr_id;
  Elsif p_chr_id is null and p_cle_id is null
  Then
     null; --raise appropriate exception here
  End If;
  Open party_role_curs(l_chr_id,l_cle_id,l_dnz_chr_id,p_role_code);
  Loop
      Fetch party_role_curs into party_role_rec;
      Exit When party_role_curs%NotFound;
      i := party_role_curs%rowcount;

   -- introduced by suresh
   l_object_code := party_role_rec.jtot_object1_code;

--Added by kthiruva 23-Sep-2003 Bug No.3156265

-- For Object Code is 'OKX_PARTY'


     IF ( (party_role_rec.rle_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL') AND p_intent ='S')
          OR (party_role_rec.rle_code = 'INVESTOR' AND p_intent='B')) THEN

       OPEN okx_party_csr(p_name => null,
                          p_id1  => party_role_rec.object1_id1,
                          p_id2  => party_role_rec.object1_id2);


         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;
         Fetch okx_party_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_party_csr%NotFound Then
            Null;--raise appropriate exception here
         End If;

         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
      CLOSE okx_party_csr;
     --bug# 2761680
     --END IF;

 -- For Object Code 'OKX_OPERUNIT'
    ELSIF ( (party_role_rec.rle_code ='LESSOR' AND p_intent ='S') OR (party_role_rec.rle_code ='SYNDICATOR' AND p_intent ='B'))
      THEN
        OPEN okx_operunit_csr(p_name => null,
                          p_id1  => party_role_rec.object1_id1,
                          p_id2  => party_role_rec.object1_id2);


         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;
         Fetch okx_operunit_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_operunit_csr%NotFound Then
            Null;--raise appropriate exception here
         End If;

         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
      CLOSE okx_operunit_csr;
     --bug# 2761680
     --END IF;

-- For Object Code 'OKX_VENDOR'

        ELSIF ( party_role_rec.rle_code ='OKL_VENDOR' AND p_intent='S')
        THEN
	OPEN okx_vendor_csr(p_name => null,
                          p_id1  => party_role_rec.object1_id1,
                          p_id2  => party_role_rec.object1_id2);


         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;
         Fetch okx_vendor_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_vendor_csr%NotFound Then
            Null;--raise appropriate exception here
         End If;

         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
      CLOSE okx_vendor_csr;
     ELSE
         --bug# 2761680 : User definable party roles will be fetched by dynamic sql as before
         --               (taking care of OKC indirection)
         Get_Party (p_api_version     => '1.0',
                 p_init_msg_list   => 'T'  ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data            => x_msg_data,
                 p_role_code       => party_role_rec.rle_code,
                 p_intent          => p_intent,
                 p_id1             => party_role_rec.object1_id1,
                 p_id2             => party_role_rec.object1_id2,
                 p_name            => null,
                 x_select_clause   => l_select_clause,
                 x_from_clause     => l_from_clause ,
                 x_where_clause    => l_where_clause,
                 x_order_by_clause => l_order_by_clause,
                 x_object_code     => l_object_code);
          l_query_string := 'SELECT '||ltrim(rtrim(l_select_clause,' '),' ')||' '||
                        'FROM '||ltrim(rtrim(l_from_clause,' '),' ')||' '||
                        'WHERE '||ltrim(rtrim(l_where_clause,' '),' ')||' '||
                        'ORDER BY '||ltrim(rtrim(l_order_by_clause,' '),' ');
          Open party_curs for l_query_string;
             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;
             Fetch party_curs into  l_id1,
                                l_id2,
                                l_name,
                                l_description;
             If party_curs%NotFound Then
                Null;--raise appropriate exception here
             End If;
             x_party_tab(i).rle_code         := party_role_rec.rle_code;
             x_party_tab(i).id1              := l_id1;
             x_party_tab(i).id2              := l_id2;
             x_party_tab(i).name             := l_name;
             x_party_tab(i).description      := l_description;
             x_party_tab(i).object_code      := l_object_code;

         --bug# 2761680 : User definable party roles will be fetched by dynamic sql as before
         --               (taking care of OKC indirection)
     END IF;

   l_object_code := null;

   End Loop;
   Close party_role_curs;
End Get_Party;
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
Procedure Get_Party (p_api_version         IN	NUMBER,
                     p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	  OUT NOCOPY	VARCHAR2,
                     x_msg_count	        OUT NOCOPY	NUMBER,
                     x_msg_data	        OUT NOCOPY	VARCHAR2,
                     p_role_code           IN  VARCHAR2,
                     p_intent              IN  VARCHAR2,
                     p_id1                 IN  VARCHAR2,
                     p_id2                 IN  VARCHAR2,
                     x_id1                 OUT NOCOPY VARCHAR2,
                     x_id2                 OUT NOCOPY VARCHAR2,
                     x_name                OUT NOCOPY VARCHAR2,
                     x_description         OUT NOCOPY VARCHAR2) is

l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;
l_id1               OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_Description       VARCHAR2(250) Default Null;
l_object_code       VARCHAR2(30) Default Null;
type                party_curs_type is REF CURSOR;
party_curs          party_curs_type;
Begin


--Added by kthiruva 23-Sep-2003 Bug No.3156265
-- For Object Code is 'OKX_PARTY'

       IF ( (p_role_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL') AND p_intent ='S')
          OR (p_role_code = 'INVESTOR' AND p_intent='B'))
       THEN

         OPEN okx_party_csr(p_name => null,
                            p_id1  => p_id1,
                            p_id2  => p_id2);



          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          FETCH okx_party_csr into  l_id1,
                                    l_id2,
                                    l_name,
                                    l_description;

          If okx_party_csr%NotFound Then
            Null;--raise appropriate exception here
          End If;

          x_id1 := l_id1;
          x_id2 := l_id2;
          x_name := l_name;
          x_description := l_description;

         Close okx_party_csr;
        --Bug# 2761680
        --END IF;

-- For Object Code 'OKX_OPERUNIT'
       ELSIF ( (p_role_code ='LESSOR' AND p_intent ='S') OR (p_role_code ='SYNDICATOR' AND p_intent ='B'))
        THEN

         OPEN okx_operunit_csr(p_name => null,
                            p_id1  => p_id1,
                            p_id2  => p_id2);



          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          FETCH okx_operunit_csr into  l_id1,
                                    l_id2,
                                    l_name,
                                    l_description;

          If okx_operunit_csr%NotFound Then
            Null;--raise appropriate exception here
          End If;

          x_id1 := l_id1;
          x_id2 := l_id2;
          x_name := l_name;
          x_description := l_description;

         Close okx_operunit_csr;
        --Bug# 2761680
        --END IF;

-- For Object Code 'OKX_VENDOR'

        ELSIF ( p_role_code ='OKL_VENDOR' AND p_intent='S')
          THEN

          OPEN okx_vendor_csr(p_name => null,
                                p_id1  => p_id1,
                                p_id2  => p_id2);



          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          FETCH okx_vendor_csr into  l_id1,
                                    l_id2,
                                    l_name,
                                    l_description;

          If okx_vendor_csr%NotFound Then
            Null;--raise appropriate exception here
          End If;

          x_id1 := l_id1;
          x_id2 := l_id2;
          x_name := l_name;
          x_description := l_description;

         Close okx_vendor_csr;
        ELSE
          --Bug# 2761680 : User definable party roles will have to be fetched the old-way(using OKC indirection)
          Get_Party (p_api_version     => '1.0',
                 p_init_msg_list   => 'T'  ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data            => x_msg_data,
                 p_role_code       =>   p_role_code,
                 p_intent          => p_intent,
                 p_id1             => p_id1,
                 p_id2             => p_id2,
                 p_name            => null,
                 x_select_clause   => l_select_clause,
                 x_from_clause     => l_from_clause ,
                 x_where_clause    => l_where_clause,
                 x_order_by_clause => l_order_by_clause,
                 x_object_code     => l_object_code);
          l_query_string := 'SELECT '||ltrim(rtrim(l_select_clause,' '),' ')||' '||
                        'FROM '||ltrim(rtrim(l_from_clause,' '),' ')||' '||
                        'WHERE '||ltrim(rtrim(l_where_clause,' '),' ')||' '||
                        'ORDER BY '||ltrim(rtrim(l_order_by_clause,' '),' ');
          Open party_curs for l_query_string;
             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;
             Fetch party_curs into  l_id1,
                                l_id2,
                                l_name,
                                l_description;
             If party_curs%NotFound Then
                Null;--raise appropriate exception here
             End If;
             x_id1 := l_id1;
             x_id2 := l_id2;
             x_name := l_name;
             x_description := l_description;
         Close party_curs;
          --Bug# 2761680 : User definable party roles will have to be fetched the old-way(using OKC indirection)

        END IF;
End Get_Party;



Procedure Get_Contact(p_api_version         IN	NUMBER,
                      p_init_msg_list	  IN	VARCHAR2 default OKC_API.G_FALSE,
                      x_return_status	  OUT NOCOPY	VARCHAR2,
                      x_msg_count	        OUT NOCOPY	NUMBER,
                      x_msg_data	        OUT NOCOPY	VARCHAR2,
                      p_role_code           IN  VARCHAR2,
                      p_contact_code        IN  VARCHAR2,
                      p_intent              IN  VARCHAR2 DEFAULT 'S',
                      p_id1                 IN  VARCHAR2,
                      p_id2                 IN  VARCHAR2,
                      p_name                IN  VARCHAR2,
                      x_select_clause       OUT NOCOPY VARCHAR2,
                      x_from_clause         OUT NOCOPY VARCHAR2,
                      x_where_clause        OUT NOCOPY VARCHAR2,
                      x_order_by_clause     OUT NOCOPY VARCHAR2,
                      x_object_code         OUT NOCOPY VARCHAR2) is
CURSOR jtf_contacts_cur(p_contact_code VARCHAR2, p_role_code VARCHAR2, p_intent VARCHAR2) is
       select job.object_code OBJECT_CODE,
              job.object_code||'.ID1, '||
              job.object_code||'.ID2, '||
              job.object_code||'.NAME, '||
		      job.object_code||'.DESCRIPTION ' SELECT_CLAUSE,
              from_table FROM_CLAUSE,
              where_clause WHERE_CLAUSE,
              order_by_clause ORDER_BY_CLAUSE
       from   jtf_objects_b job,
              okc_contact_sources cs
       where  job.object_code = cs.jtot_object_code
       and     nvl(job.start_date_active,sysdate) <= sysdate
       and     nvl(job.end_date_active,sysdate + 1) > sysdate
       and    cs.cro_code = p_contact_code
       and    cs.rle_code = p_role_code
       and    cs.start_date <= sysdate
       and    nvl(cs.end_date,sysdate+1) > sysdate
       and    cs.buy_or_sell = p_intent;
jtf_contacts_rec    jtf_contacts_cur%rowtype;
l_query_string      VARCHAR2(2000)     default Null;
l_where_clause      VARCHAR2(2000)     default Null;
type                contact_curs_type is REF CURSOR;
contact_count_curs  contact_curs_type;
l_rec_count         NUMBER default 0;
Begin
   If okc_context.get_okc_org_id  is null then
      okc_context.set_okc_org_context(204,204);
   End If;
     Open jtf_contacts_cur(p_contact_code,p_role_code,p_intent);
          Fetch jtf_contacts_cur into jtf_contacts_rec;
          If jtf_contacts_cur%NOTFOUND Then
             --handle exception appropriately
             x_object_code     := 'NOT FOUND';
             x_select_clause   := 'NOT FOUND';
             x_from_clause     := 'NOT FOUND';
             x_where_clause    := 'NOT FOUND';
             x_order_by_clause := 'NOT FOUND';
          Else
             x_object_code     := jtf_contacts_rec.object_code;
             x_select_clause   := jtf_contacts_rec.select_clause;
             x_from_clause     := jtf_contacts_rec.from_clause;
             x_where_clause    := jtf_contacts_rec.where_clause;
             x_order_by_clause := jtf_contacts_rec.order_by_clause;
             If p_id1 is not null and p_id2 is not null and p_name is null then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' ID1 = '||''''||p_id1||''''||' AND '||' ID2 = '||''''||p_id2||''''
                into   l_where_clause
                from   dual;
                x_where_clause := l_where_clause;
             Elsif p_name is not null then
                select x_where_clause || decode(x_where_clause,null,null,' AND ')||
                       ' NAME = '||''''||p_name||''''
                into   l_where_clause
                from   dual;
             End If;
             /*
             select ' SELECT count(*) rec_count'||
                    ' FROM '||x_from_clause||
                    decode(x_where_clause,null,' ',' WHERE ')||x_where_clause||
                    decode(x_order_by_clause,null,null,' ORDER BY ')||x_order_by_clause
             into   l_query_string from dual;
             l_rec_count := 0;
             Open contact_count_curs for l_query_string;
                 Fetch contact_count_curs into l_rec_count;
                 If l_rec_count = 0
                 Then
                     Null; -- trying to avoid internal error
                 End If;
             Close contact_count_curs;
             x_record_count := l_rec_count;
             */
         End If;
    Close jtf_contacts_cur;
END Get_Contact;


-- Start of comments
--
-- Procedure Name  : get_contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure get_contact(p_api_version	   IN	NUMBER,
                      p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                      x_return_status	   OUT NOCOPY	VARCHAR2,
                      x_msg_count	   OUT NOCOPY	NUMBER,
                      x_msg_data	   OUT NOCOPY	VARCHAR2,
                      p_rle_code           IN VARCHAR2,
                      p_cro_code           IN  VARCHAR2,
                      p_intent             IN  VARCHAR2,
                      p_id1                IN  VARCHAR2,
                      p_id2                IN  VARCHAR2,
                      x_id1                OUT NOCOPY VARCHAR2,
                      x_id2                OUT NOCOPY VARCHAR2,
                      x_name               OUT NOCOPY VARCHAR2,
                      x_description        OUT NOCOPY VARCHAR2) is
l_api_name                     CONSTANT VARCHAR2(30) := 'get_contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OKL_JTOT_CONTACT_EXTRACT_PVT.get_contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_rle_code,
                              p_cro_code,
                              p_intent,
                              p_id1,
                              p_id2,
                              x_id1,
                              x_id2,
                              x_name,
                              x_description);

  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --

  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
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
end get_contact;

Procedure Validate_Party (p_api_version    IN		NUMBER,
                     p_init_msg_list	   IN		VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  	NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  	NOCOPY	NUMBER,
                     x_msg_data	           OUT  	NOCOPY	VARCHAR2,
                     p_chr_id              IN		NUMBER,
                     p_cle_id              IN		NUMBER,
                     p_cpl_id              IN		NUMBER,
                     p_lty_code            IN	        VARCHAR2,
                     p_rle_code            IN		VARCHAR2,
                     p_id1            	   IN OUT       NOCOPY VARCHAR2,
                     p_id2                 IN OUT       NOCOPY VARCHAR2,
                     p_name                IN   	VARCHAR2,
                     p_object_code         IN   	VARCHAR2
                     ) is
l_select_clause     varchar2(2000) default null;
l_from_clause       varchar2(2000) default null;
l_where_clause      varchar2(2000) default null;
l_order_by_clause   varchar2(2000) default null;
l_query_string      varchar2(2000) default null;

l_id1               OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_description       VARCHAR2(250) Default Null;
l_object_code       VARCHAR2(30) Default Null;

l_id11            OKC_K_PARTY_ROLES_V.OBJECT1_ID1%TYPE default Null;
l_id22            OKC_K_PARTY_ROLES_V.OBJECT1_ID2%TYPE default Null;

type              party_curs_type is REF CURSOR;
party_curs        party_curs_type;

row_count         Number default 0;

l_chr_id	  okl_k_headers.id%type;
l_rle_code        okc_k_party_roles_v.rle_code%type;
l_cle_id          okl_k_lines.id%type;
l_lty_code        okc_line_styles_b.lty_code%type;

l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Party';
l_api_version	  CONSTANT NUMBER	:= 1.0;

-- x_return_status	   := OKC_API.G_RET_STS_SUCCESS;

ERR_MSG           VARCHAR2(50) := 'DEFAULT';

l_amt_ak_prompt  AK_ATTRIBUTES_VL.attribute_label_long%type;


CURSOR check_party_csr(p_chr_id NUMBER, p_rle_code VARCHAR2,p_id1 VARCHAR2, p_id2 VARCHAR2) IS
	--Start modified abhsaxen for performance SQLID 20562561
	   select count(1)
	from okc_k_party_roles_b
	where dnz_chr_id = p_chr_id
	and chr_id = p_chr_id
	and rle_code = p_rle_code
	and object1_id1 = p_id1
	and object1_id2 = p_id2
	--end modified abhsaxen for performance SQLID 20562561
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
			p_api_type      => '_PUB',
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
--  	raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  End If;

  l_amt_ak_prompt := GET_AK_PROMPT('OKL_LA_CONTRACT_PRTS', 'OKL_LA_KPRTS_NAME');




--Added by kthiruva 23-Sep-2003 Bug No.3156265

-- For Object Code is 'OKX_PARTY'

       IF  (p_rle_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL','INVESTOR','EXTERNAL_PARTY'))  -- added 'EXTERNAL_PARTY for bug 4893490

       THEN

         OPEN okx_party_csr(p_name => p_name,
                            p_id1  => p_id1,
                            p_id2  => p_id2);


           l_id1  := Null;
           l_id2  := Null;
           l_name := Null;
           l_description := Null;

         FETCH okx_party_csr into  l_id1,l_id2,l_name,l_description;

         If okx_party_csr%NotFound Then
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
      		    	        p_msg_name => 'OKL_REQUIRED_VALUE',
      			        p_token1 => 'COL_NAME',
      			        p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
            raise OKC_API.G_EXCEPTION_ERROR;
         End If;

    	 l_id11 := l_id1;
         l_id22 := l_id2;

         Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
         If okx_party_csr%Found Then

       	   If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
	     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_REQUIRED_VALUE',
      		   	         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
             raise OKC_API.G_EXCEPTION_ERROR;
           End If;

       	   If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
 	     OKC_API.SET_MESSAGE(p_app_name => g_app_name,
 	                         p_msg_name => 'OKL_REQUIRED_VALUE',
      			         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
             raise OKC_API.G_EXCEPTION_ERROR;


           End If;

           If(l_id1 = p_id1 and l_id2 = p_id2) Then
	      l_id11 := l_id1;
      	      l_id22 := l_id2;
     	      row_count := 1;
     	   Else

             Loop

               Fetch okx_party_csr into  l_id1,l_id2,l_name,l_description;
               If(l_id1 = p_id1 and l_id2 = p_id2) Then
         	      l_id11 := l_id1;
         	      l_id22 := l_id2;
        	      row_count := 1;
        	      Exit;
                End If;
               Exit When okx_party_csr%NotFound;

             End Loop;

           End If;

	   If row_count <> 1 Then
	      x_return_status := OKC_API.g_ret_sts_error;
	      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
	                          p_msg_name => 'OKL_REQUIRED_VALUE',
      	                          p_token1 => 'COL_NAME',
      			          p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
	      raise OKC_API.G_EXCEPTION_ERROR;
	   End If;

         End If;

      p_id1 := l_id11;
      p_id2 := l_id22;

   Close okx_party_csr;
  END IF;

-- For Object Code 'OKX_OPERUNIT'
       IF  (p_rle_code IN ('LESSOR','SYNDICATOR') )
        THEN
         OPEN okx_operunit_csr(p_name => p_name,
                               p_id1  => l_id1,
                               p_id2  => p_id2);


           l_id1  := Null;
           l_id2  := Null;
           l_name := Null;
           l_description := Null;

         FETCH okx_operunit_csr into  l_id1,l_id2,l_name,l_description;

         If okx_operunit_csr%NotFound Then
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
      		    	        p_msg_name => 'OKL_REQUIRED_VALUE',
      			        p_token1 => 'COL_NAME',
      			        p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
            raise OKC_API.G_EXCEPTION_ERROR;
         End If;

    	 l_id11 := l_id1;
         l_id22 := l_id2;

         Fetch okx_operunit_csr into  l_id1,l_id2,l_name,l_description;
         If okx_operunit_csr%Found Then

       	   If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
	     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_REQUIRED_VALUE',
      		   	         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
             raise OKC_API.G_EXCEPTION_ERROR;
           End If;

       	   If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
 	     OKC_API.SET_MESSAGE(p_app_name => g_app_name,
 	                         p_msg_name => 'OKL_REQUIRED_VALUE',
      			         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
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
	      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
	                          p_msg_name => 'OKL_REQUIRED_VALUE',
      	                          p_token1 => 'COL_NAME',
      			          p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
	      raise OKC_API.G_EXCEPTION_ERROR;
	   End If;

         End If;

      p_id1 := l_id11;
      p_id2 := l_id22;

   Close okx_operunit_csr;
  END IF;

-- For Object Code 'OKX_VENDOR'

        IF ( p_rle_code ='OKL_VENDOR' )
        THEN
         OPEN okx_vendor_csr(p_name => p_name,
                             p_id1  => l_id1,
                             p_id2  => p_id2);


           l_id1  := Null;
           l_id2  := Null;
           l_name := Null;
           l_description := Null;

         FETCH okx_vendor_csr into  l_id1,l_id2,l_name,l_description;

         If okx_vendor_csr%NotFound Then
            x_return_status := OKC_API.g_ret_sts_error;
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
      		    	        p_msg_name => 'OKL_REQUIRED_VALUE',
      			        p_token1 => 'COL_NAME',
      			        p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
            raise OKC_API.G_EXCEPTION_ERROR;
         End If;

    	 l_id11 := l_id1;
         l_id22 := l_id2;

         Fetch okx_vendor_csr into  l_id1,l_id2,l_name,l_description;
         If okx_vendor_csr%Found Then

       	   If( p_id1 is null or p_id1 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
	     OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'OKL_REQUIRED_VALUE',
      		   	         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
             raise OKC_API.G_EXCEPTION_ERROR;
           End If;

       	   If( p_id2 is null or p_id2 = OKC_API.G_MISS_CHAR) then
             x_return_status := OKC_API.g_ret_sts_error;
 	     OKC_API.SET_MESSAGE(p_app_name => g_app_name,
 	                         p_msg_name => 'OKL_REQUIRED_VALUE',
      			         p_token1 => 'COL_NAME',
      			         p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
             raise OKC_API.G_EXCEPTION_ERROR;


           End If;

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

	   If row_count <> 1 Then
	      x_return_status := OKC_API.g_ret_sts_error;
	      OKC_API.SET_MESSAGE(p_app_name => g_app_name,
	                          p_msg_name => 'OKL_REQUIRED_VALUE',
      	                          p_token1 => 'COL_NAME',
      			          p_token1_value => l_amt_ak_prompt); --please_select_a_value_from_lov
	      raise OKC_API.G_EXCEPTION_ERROR;
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
  	   OKC_API.SET_MESSAGE(p_app_name => g_app_name,
  	                  p_msg_name => 'OKL_LLA_DUP_SELECTION',
      			  p_token1 => 'TOKEN',
      			  p_token1_value => l_amt_ak_prompt); --Party_name_already_exists
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
  	    OKC_API.SET_MESSAGE(p_app_name => g_app_name,
  	                  p_msg_name => 'OKL_LLA_DUP_SELECTION',
      			  p_token1 => 'TOKEN',
      			  p_token1_value => l_amt_ak_prompt); --Party_name_already_exists
  	    raise OKC_API.G_EXCEPTION_ERROR;
  	   End If;
  	End If;
    End If;

  End If;

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
  			p_api_type  => '_PUB');
     IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;
     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;
     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;


      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
        x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => g_pkg_name,
  			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => '_PUB');
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
  			p_api_type  => '_PUB');
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



  Procedure Delete_Party (p_api_version  IN   NUMBER,
                     p_init_msg_list	   IN	VARCHAR2 default OKC_API.G_FALSE,
                     x_return_status	   OUT  NOCOPY	VARCHAR2,
                     x_msg_count	   OUT  NOCOPY	NUMBER,
                     x_msg_data	           OUT  NOCOPY	VARCHAR2,
                     p_chr_id       	   IN	NUMBER,
                     p_cpl_id       	   IN	NUMBER
                     ) AS

   l_api_name	         VARCHAR2(30) := 'Validate_Party';
   l_api_version	 CONSTANT NUMBER	  := 1.0;
   l_chr_id	         NUMBER;
   l_rle_code_meaning    fnd_lookup_values.meaning%type;

   row_count  number;

   l_k_vendor_id1 okc_k_party_roles_v.object1_id1%type;
   l_rle_code okc_k_party_roles_v.rle_code%type;
   l_id1 okx_vendor_sites_v.vendor_id%type;

   l_id okc_rg_party_roles_v.id%type;
   l_rgp_id okc_rg_party_roles_v.rgp_id%type;
   l_rul_id okc_rules_v.id%type;

   lp_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;
   lx_cplv_rec OKL_OKC_MIGRATION_PVT.cplv_rec_type;

   lp_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
   lx_rgpv_rec OKL_OKC_MIGRATION_PVT.rgpv_rec_type;
   lp_rulv_rec Okl_Rule_Pub.rulv_rec_type;
   lx_rulv_rec Okl_Rule_Pub.rulv_rec_type;

   lp_rmpv_rec OKL_OKC_MIGRATION_PVT.rmpv_rec_type;
   lx_rmpv_rec OKL_OKC_MIGRATION_PVT.rmpv_rec_type;

   lp_rulv_tbl Okl_Rule_Pub.rulv_tbl_type;

   cursor l_vendor_csr is
   select object1_id1,rle_code from okc_k_party_roles_v
   where id = p_cpl_id;

   -- sjalasut, modified the cursor to include okl_txl_ap_inv_lns_all_b and khr_id
   -- be referred from this table instead of okl_trx_ap_invoices_b. changes made
   -- as part of OKLR12B disbursements project
   cursor l_funding_chk_csr(p_id1 varchar2) IS
   select count(*)   from okx_vendor_sites_v
   where exists (select 1 from okl_trx_ap_invoices_b a
                              ,okl_txl_ap_inv_lns_all_b b
              where a.id = b.tap_id
                and a.ipvs_id = okx_vendor_sites_v.id1
                and b.khr_id = p_chr_id)
   and vendor_id = p_id1;

   cursor l_line_csr(p_id1 varchar2) IS
	--Start modified abhsaxen for performance SQLID 20562568
	    select count(*)
	   from okc_k_party_roles_b
	   where chr_id is null
	   and cle_id is not null
	   and rle_code = 'OKL_VENDOR'
	   and dnz_chr_id = p_chr_id
	   and object1_id1 = p_id1
	--end modified abhsaxen for performance SQLID 20562568
	;
   cursor l_rg_party_csr is
   select rgpr.id ,rgpr.rgp_id
   from okc_rg_party_roles_v rgpr, okc_rule_groups_v rgp
   where rgpr.dnz_chr_id = p_chr_id
   and rgpr.cpl_id = p_cpl_id
   and rgpr.dnz_chr_id = rgp.dnz_chr_id
   and rgpr.dnz_chr_id = rgp.chr_id
   and rgpr.rgp_id = rgp.id;

   cursor l_r_party_csr is
   select rul.id
   from okc_rg_party_roles_v rgpr, okc_rule_groups_v rgp, okc_rules_v rul
   where rgpr.dnz_chr_id = p_chr_id
   and rgpr.cpl_id = p_cpl_id
   and rgpr.dnz_chr_id = rgp.dnz_chr_id
   and rgpr.dnz_chr_id = rgp.chr_id
   and rgpr.dnz_chr_id = rul.dnz_chr_id
   and rgpr.rgp_id = rgp.id
   and rgp.id = rul.rgp_id;

   i                   Number default 0;

   --Bug# 4558486
   lp_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
   lx_kplv_rec      OKL_K_PARTY_ROLES_PVT.kplv_rec_type;

    /*
    -- mvasudev, 09/09/2004
    -- Added PROCEDURE to enable Business Event
    */
	PROCEDURE raise_business_event(
	   x_return_status OUT NOCOPY VARCHAR2
    )
	IS
       l_process VARCHAR2(20);
      l_parameter_list           wf_parameter_list_t;
	BEGIN
	  IF (     okl_lla_util_pvt.is_lease_contract(p_chr_id) = OKL_API.G_TRUE)
	  THEN

                 l_process := Okl_Lla_Util_Pvt.get_contract_process(p_chr_id);

  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_ID,p_chr_id,l_parameter_list);
                 --vthiruva..04-jan-2004.. Modified to pass object1_id1 as party id and
                 --added party_role_id to list of paramters passed to raise business event.
  		 wf_event.AddParameterToList(G_WF_ITM_PARTY_ID,l_k_vendor_id1,l_parameter_list);
                 wf_event.AddParameterToList(G_WF_ITM_PARTY_ROLE_ID,p_cpl_id,l_parameter_list);
  		 wf_event.AddParameterToList(G_WF_ITM_CONTRACT_PROCESS,l_process,l_parameter_list);

         OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
								 x_return_status  => x_return_status,
								 x_msg_count      => x_msg_count,
								 x_msg_data       => x_msg_data,
								 p_event_name     => G_WF_EVT_KHR_PARTY_REMOVE,
								 p_parameters     => l_parameter_list);
      END IF;

     EXCEPTION
     WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END raise_business_event;


    /*
    -- mvasudev, 09/09/2004
    -- END, PROCEDURE to enable Business Event
    */

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

  If ( p_chr_id is null or p_chr_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_chr_id');
      raise OKC_API.G_EXCEPTION_ERROR;
  ElsIf ( p_cpl_id is null or p_cpl_id =  OKC_API.G_MISS_NUM)
  Then
      OKC_API.SET_MESSAGE(p_app_name => g_app_name, p_msg_name => 'Missing_cpl_id');
      raise OKC_API.G_EXCEPTION_ERROR;
  End If;

   open  l_vendor_csr;
   fetch l_vendor_csr into l_k_vendor_id1,l_rle_code;
   close l_vendor_csr;

 If l_rle_code = 'LESSEE' or l_rle_code = 'LESSOR' Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_rle_code_meaning := GET_RLE_CODE_MEANING(l_rle_code,p_chr_id);
      OKC_API.SET_MESSAGE(     p_app_name => g_app_name
			     , p_msg_name => 'OKL_LLA_DELETE_PARTY1'
                             , p_token1 => 'COL_NAME'
                             , p_token1_value => l_rle_code_meaning
			   );
      raise OKC_API.G_EXCEPTION_ERROR;
 End If;

 --Bug# 3340949:
 --If l_rle_code = 'GUARANTOR' or l_rle_code = 'PRIVATE_LABEL' or l_rle_code = 'OKL_VENDOR' Then

 If l_rle_code = 'OKL_VENDOR' Then

   open l_funding_chk_csr(l_k_vendor_id1);
   fetch  l_funding_chk_csr into row_count;
   close l_funding_chk_csr;

   If row_count <> 0 Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_rle_code_meaning := GET_RLE_CODE_MEANING(l_rle_code,p_chr_id);
      OKC_API.SET_MESSAGE(     p_app_name => g_app_name
			     , p_msg_name => 'OKL_LLA_DELETE_PARTY'
                             , p_token1 => 'COL_NAME'
                             , p_token1_value => l_rle_code_meaning
			   );
	 raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   open  l_line_csr(l_k_vendor_id1);
   fetch l_line_csr into row_count;
   close l_line_csr;

   If row_count <> 0 Then
      x_return_status := OKC_API.g_ret_sts_error;
      l_rle_code_meaning := GET_RLE_CODE_MEANING(l_rle_code,p_chr_id);
      OKC_API.SET_MESSAGE(     p_app_name => g_app_name
			     , p_msg_name => 'OKL_LLA_DELETE_PARTY'
                             , p_token1 => 'COL_NAME'
                             , p_token1_value => l_rle_code_meaning
			   );
      raise OKC_API.G_EXCEPTION_ERROR;
   End If;
  End If;

  l_id := null;
  l_rgp_id := null;
  l_rul_id := null;

/*
  OPEN  l_r_party_csr;
  Loop
   Fetch l_r_party_csr into  l_rul_id;
   Exit When l_r_party_csr%NotFound;
   i := l_r_party_csr%rowcount;
   lp_rulv_tbl(i).id := l_rul_id;
  End Loop;
  CLOSE l_r_party_csr;

  OKL_RULE_PUB.delete_rule(
           p_api_version    => p_api_version,
           p_init_msg_list  => p_init_msg_list,
           x_return_status  => x_return_status,
           x_msg_count      => x_msg_count,
           x_msg_data       => x_msg_data,
           p_rulv_tbl       => lp_rulv_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
            raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/

  open  l_rg_party_csr;
  fetch l_rg_party_csr into l_id, l_rgp_id;
  close l_rg_party_csr;

  lp_rgpv_rec.id := l_rgp_id;
  OKL_RULE_PUB.delete_rule_group(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rgpv_rec       => lp_rgpv_rec);

  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  lp_rmpv_rec.id := l_id;
  OKL_RULE_PUB.delete_rg_mode_pty_role(
         p_api_version    => p_api_version,
         p_init_msg_list  => p_init_msg_list,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_rmpv_rec       => lp_rmpv_rec);

  If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
  End If;

  lp_cplv_rec.id := p_cpl_id;
  --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
  --              to delete records in tables
  --              okc_k_party_roles_b and okl_k_party_roles
  /*
  OKL_OKC_MIGRATION_PVT.delete_k_party_role(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_cplv_rec       => lp_cplv_rec);
  */

   lp_kplv_rec.id := lp_cplv_rec.id;
   OKL_K_PARTY_ROLES_PVT.delete_k_party_role(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_cplv_rec       => lp_cplv_rec,
        p_kplv_rec       => lp_kplv_rec);

   If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
   End If;

 --Bug# 3340949:
 --End If;

    /*
    -- mvasudev, 09/09/2004
    -- Code change to enable Business Event
    */
 	raise_business_event(x_return_status => x_return_status);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    /*
    -- mvasudev, 09/09/2004
    -- END, Code change to enable Business Event
   */

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
  END Delete_Party;


end OKL_JTOT_CONTACT_EXTRACT_PUB;


/
