--------------------------------------------------------
--  DDL for Package Body OKL_VP_JTF_PARTY_NAME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_JTF_PARTY_NAME_PVT" AS
/* $Header: OKLRCTSB.pls 120.7.12010000.2 2009/02/09 15:00:04 nikshah ship $ */
--Start of Comments
--Procedure   : Get Party
--Description : Returns the SQL string for LOV of a party Role
--End of Comments


 --Added by kthiruva 23-Sep-2003 Bug No.3156265

 --For Object Code 'OKX_PARTY'
  CURSOR okx_party_csr(p_name VARCHAR2 , p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT prv.id1,
         prv.id2,
         prv.name,
         prv.description
  FROM  okx_parties_v prv
  WHERE prv.name = NVL(p_name,prv.name)
  AND   prv.id1  = NVL(p_id1,prv.id1)
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
 -- Updated the cursor In parameter and Sql statement, as confirmed by VP team, to improve the performance
 -- Performance bug#5484903 -- varangan - 28-9-06
  CURSOR okx_vendor_csr(p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT  vev.id1,
          vev.id2,
          vev.name,
          vev.description
  FROM okx_vendors_v vev
  WHERE vev.id1  = p_id1
  AND   vev.id2  = NVL(p_id2,vev.id2)
  ORDER BY vev.NAME;

--For Object Code 'OKX_SALEPERS'
-- Updated the cursor In parameter and Sql statement,as confirmed by VP team, to improve the performance
-- Performance bug#5484903 -- varangan - 28-9-06
  CURSOR okx_salepers_csr(p_id1 VARCHAR2 , p_id2 VARCHAR2) IS
  SELECT srv.ID1,
         srv.ID2,
         srv.NAME,
         srv.DESCRIPTION
  FROM OKX_SALESREPS_V srv
  WHERE ((nvl(srv.ORG_ID, -99) =  nvl(mo_global.get_current_org_id, -99)) or (nvl(mo_global.get_current_org_id, -99) = -99))
  AND   srv.ID1  = p_id1
  AND   srv.ID2  = NVL(p_id2,srv.ID2)
  ORDER BY srv.NAME;

-- For Object Code 'OKX_PCONTACT'
--removed the cursor okx_pcontact_csr - since it is not used in the code
-- performance issue -bug#5484903 - varangan - 25-9-06


--Bug# 3336870
--Start of Comments
--Procedure   : Get Party (Introduced for user defined party roles, with JTF indirection)
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
             --Fix for bug 3613832. Added the NVL for the where_clause
             --by rvaduri
             x_where_clause    := nvl(jtf_party_role_rec.where_clause,'1=1');
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
                     x_party_tab   out nocopy party_tab_type) is
CURSOR party_role_curs(p_chr_id     IN NUMBER,
                       p_cle_id     IN NUMBER,
                       p_dnz_chr_id IN NUMBER,
                       p_role_code  IN VARCHAR2) is

	-- Updated the sql for performance fix -bug#5484903 - varangan - 25-9-06
	SELECT
	CPLB.OBJECT1_ID1 object1_id1,
	CPLB.OBJECT1_ID2 object1_id2,
	CPLB.JTOT_OBJECT1_CODE jtot_object1_code,
	CPLB.RLE_CODE rle_code
	FROM OKC_K_PARTY_ROLES_B CPLB,
	     FND_LOOKUPS FNDV
	WHERE     CPLB.RLE_CODE = FNDV.lookup_code
	AND   FNDV.lookup_type = 'OKC_ROLE'
	AND   CPLB.rle_code = nvl(p_role_code,CPLB.rle_code)
	and    nvl(CPLB.cle_id,-99999)   = p_cle_id
	and    nvl(CPLB.chr_id,-99999)   = p_chr_id
	and    CPLB.dnz_chr_id           = decode(p_chr_id,null,CPLB.dnz_chr_id,p_dnz_chr_id)
	order  by rle_code;

       /* -- commented for improving the performance - bug#5484903
       select object1_id1,
              object1_id2,
              jtot_object1_code,
              rle_code
       from   OKC_K_PARTY_ROLES_V
       where  rle_code = nvl(p_role_code,rle_code)
       and    nvl(cle_id,-99999)   = p_cle_id
       and    nvl(chr_id,-99999)   = p_chr_id
       and    dnz_chr_id           = decode(p_chr_id,null,dnz_chr_id,p_dnz_chr_id)
       order  by rle_code; */

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

--Added by kthiruva 23-Sep-2003 Bug No.3156265

-- For Object Code 'OKX_PARTY'

      -- Changed by manu 02-Oct-2003

            --  IF ( (party_role_rec.rle_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL') AND p_intent ='S')
            --     OR (party_role_rec.rle_code = 'INVESTOR' AND p_intent='B')) THEN
        IF ( (party_role_rec.rle_code IN ('BROKER', 'DEALER','GUARANTOR', 'INVESTOR' , 'MANUFACTURER') AND p_intent ='S')) THEN

	   OPEN okx_party_csr(p_name => null,
                              p_id1  =>	party_role_rec.object1_id1,
                              p_id2  => party_role_rec.object1_id2);



             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

             FETCH okx_party_csr into  l_id1,
                                    l_id2,
                                    l_name,
                                    l_description;

             IF okx_party_csr%NotFound THEN
               Null;--raise appropriate exception here
             END IF;

             x_party_tab(i).rle_code         := party_role_rec.rle_code;
             x_party_tab(i).id1              := l_id1;
             x_party_tab(i).id2              := l_id2;
             x_party_tab(i).name             := l_name;
             x_party_tab(i).description      := l_description;
             x_party_tab(i).object_code      := l_object_code;
           CLOSE okx_party_csr;
         --END IF;


--For Object Code 'OKX_OPERUNIT'

        ELSIF ( (party_role_rec.rle_code ='LESSOR' AND p_intent ='S') OR (party_role_rec.rle_code ='SYNDICATOR' AND p_intent ='B')) THEN

	   OPEN okx_operunit_csr(p_name => null,
                              p_id1  =>	party_role_rec.object1_id1,
                              p_id2  => party_role_rec.object1_id2);



             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

             FETCH okx_operunit_csr into  l_id1,
                                          l_id2,
                                          l_name,
                                          l_description;

             IF okx_operunit_csr%NotFound THEN
               Null;--raise appropriate exception here
             END IF;

             x_party_tab(i).rle_code         := party_role_rec.rle_code;
             x_party_tab(i).id1              := l_id1;
             x_party_tab(i).id2              := l_id2;
             x_party_tab(i).name             := l_name;
             x_party_tab(i).description      := l_description;
             x_party_tab(i).object_code      := l_object_code;
           CLOSE okx_operunit_csr;
        --END IF;

-- For Object COde 'OKX_VENDOR'

     ELSIF ( p_role_code ='OKL_VENDOR' AND p_intent='S') THEN
	   OPEN okx_vendor_csr(p_id1  => party_role_rec.object1_id1,
                               p_id2  => party_role_rec.object1_id2);



             l_id1  := Null;
             l_id2  := Null;
             l_name := Null;
             l_description := Null;

             FETCH okx_vendor_csr into  l_id1,
                                          l_id2,
                                          l_name,
                                          l_description;

             IF okx_vendor_csr%NotFound THEN
               Null;--raise appropriate exception here
             END IF;

             x_party_tab(i).rle_code         := party_role_rec.rle_code;
             x_party_tab(i).id1              := l_id1;
             x_party_tab(i).id2              := l_id2;
             x_party_tab(i).name             := l_name;
             x_party_tab(i).description      := l_description;
             x_party_tab(i).object_code      := l_object_code;
           CLOSE okx_vendor_csr;
       ELSE
         --bug# 3336870 : User definable party roles will be fetched by dynamic sql as before
         --               (taking care of OKC indirection)
         Get_Party (p_api_version     => '1.0',
                 p_init_msg_list   => 'T'  ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
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
       END IF;

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

-- For Object Code 'OKX_PARTY'

-- Changed by manu 02-Oct-2003

  -- IF ( (p_role_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL') AND p_intent ='S')
  --       OR (p_role_code = 'INVESTOR' AND p_intent='B')) THEN
  IF ( (p_role_code IN ('BROKER', 'DEALER','GUARANTOR','INVESTOR' , 'MANUFACTURER') AND p_intent ='S')) THEN

      OPEN okx_party_csr(p_name => null,
                         p_id1  => p_id1,
                         p_id2  => p_id2);

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

         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;

     Close okx_party_csr;
    --END IF;

-- For Object Code 'OKX_OPERUNIT'

   ELSIF ( (p_role_code ='LESSOR' AND p_intent ='S') OR (p_role_code ='SYNDICATOR' AND p_intent ='B')) THEN

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

     CLOSE okx_operunit_csr;
    --END IF;

-- For Object Code 'OKX_VENDOR'

   ELSIF ( p_role_code ='OKL_VENDOR' AND p_intent='S') THEN

       OPEN okx_vendor_csr(p_id1  => p_id1,
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

     CLOSE okx_vendor_csr;
   ELSE
          --Bug# 3336870 : User definable party roles will have to be fetched the old-way(using OKC indirection)
          Get_Party (p_api_version => 1.0,
                 p_init_msg_list   => 'T'  ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
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
   END IF;

End Get_Party;
--Start of Comments
--Procedure   : Get_Subclass_Roles
--Description : fetches Party Roles for a Subclass
--End of Comments
Procedure Get_SubClass_Def_Roles
          (p_scs_code       IN  OKC_SUBCLASSES_V.CODE%TYPE,
           x_rle_code_tbl   OUT NOCOPY rle_code_tbl_type) is
CURSOR   scs_rle_curs is
    select scs_code,
           rle_code
    from   okc_subclass_roles
    where  scs_code = p_scs_code
    and    nvl(start_date,sysdate) <= sysdate
    and    nvl(end_date,sysdate+1) > sysdate;
scs_rle_rec scs_rle_curs%rowType;
i  Number;
Begin
   Open scs_rle_curs;
   Loop
    Fetch scs_rle_curs into scs_rle_rec;
    Exit When scs_rle_curs%NotFound;
    i := scs_rle_curs%RowCount;
    x_rle_code_tbl(i).scs_code := scs_rle_rec.scs_code;
    x_rle_code_tbl(i).rle_code := scs_rle_rec.rle_code;
   End Loop;
  Close scs_rle_curs;
End Get_SubClass_Def_Roles;
--Start of Comments
--Procedure   : Get_Subclass_Roles
--Description : fetches Party Roles for a Subclass
--End of Comments
Procedure Get_Contract_Def_Roles
          (p_chr_id           IN  VARCHAR2,
           x_rle_code_tbl     OUT NOCOPY rle_code_tbl_type) is
Cursor chr_scs_curs is
       select scs_code
       from   OKC_K_HEADERS_V
       where  id = p_chr_id;
l_scs_code OKC_K_HEADERS_V.SCS_CODE%TYPE;
Begin
    Open chr_scs_curs;
       Fetch chr_scs_curs into l_scs_code;
       If chr_scs_curs%NotFound Then
          null; --handle appropriate exception
       Else
          Get_Subclass_Def_Roles(p_scs_code       => l_scs_code,
                             x_rle_code_tbl   => x_rle_code_tbl);
       End If;
End Get_Contract_Def_Roles;

--Bug# 3325281
--Start of Comments
--Procedure   : Get contact
--Description : Returns the SQL string for LOV of a contact
--              (Introduced user defined party roles, with JTF indirection)
--End of Comments
Procedure Get_Contact (p_rle_code            IN VARCHAR2,
                       p_cro_code           IN  VARCHAR2,
                       p_intent              IN  VARCHAR2 DEFAULT 'S',
                       p_id1                 IN  VARCHAR2,
                       p_id2                 IN  VARCHAR2,
                       p_name                IN  VARCHAR2,
                       x_select_clause       OUT NOCOPY VARCHAR2,
                       x_from_clause         OUT NOCOPY VARCHAR2,
                       x_where_clause        OUT NOCOPY VARCHAR2,
                       x_order_by_clause     OUT NOCOPY VARCHAR2,
                       x_object_code         OUT NOCOPY VARCHAR2) is
CURSOR  jtf_contact_cur (p_cro_code VARCHAR2, p_intent VARCHAR2) is
        select job.object_code OBJECT_CODE,
               job.object_code||'.ID1, '||
               job.object_code||'.ID2, '||
               job.object_code||'.NAME, '||
                       job.object_code||'.DESCRIPTION ' SELECT_CLAUSE,
               from_table FROM_CLAUSE,
               where_clause WHERE_CLAUSE,
               order_by_clause ORDER_BY_CLAUSE
       from    jtf_objects_b job,
               okc_contact_sources rs
       where   job.object_code = rs.jtot_object_code
       and     nvl(job.start_date_active,sysdate) <= sysdate
       and     nvl(job.end_date_active,sysdate + 1) > sysdate
       and     rs.rle_code = p_rle_code
       and     rs.cro_code     = p_cro_code
       and     rs.start_date <= sysdate
       and     nvl(rs.end_date,sysdate+1) > sysdate
       and     rs.buy_or_sell = p_intent;
jtf_contact_rec jtf_contact_cur%rowtype;
l_query_string      VARCHAR2(2000)     default Null;
l_where_clause      VARCHAR2(2000)     default Null;
Begin
    -- sjalasut, modified for bug 4755238, earlier it was hard coded to 204
    If okc_context.get_okc_org_id  is null then
      okc_context.set_okc_org_context(null,null);
    End If;

    Open jtf_contact_cur(p_cro_code, p_intent);
         Fetch jtf_contact_cur into jtf_contact_rec;
         If jtf_contact_cur%NOTFOUND Then
             --handle exception appropriately
             x_object_code     := 'NOT FOUND';
             x_select_clause   := 'NOT FOUND';
             x_from_clause     := 'NOT FOUND';
             x_where_clause    := 'NOT FOUND';
             x_order_by_clause := 'NOT FOUND';
         Else
             x_object_code     := jtf_contact_rec.object_code;
             x_select_clause   := jtf_contact_rec.select_clause;
             x_from_clause     := jtf_contact_rec.from_clause;
             --Fix for bug 3613832. Added the NVL for the where_clause
             --by rvaduri
             x_where_clause    := nvl(jtf_contact_rec.where_clause,'1=1');
             x_order_by_clause := jtf_contact_rec.order_by_clause;
             If p_id1 is not null and p_id2 is not null and p_name is null then
                select '(' || x_where_clause || ')' || decode(x_where_clause,null,null,' AND ')||
                       ' ID1 = '||''''||p_id1||''''||' AND '||' ID2 = '||''''||p_id2||''''
                into   l_where_clause
                from   dual;
                x_where_clause := l_where_clause;
             Elsif p_name is not null then
                select '(' || x_where_clause || ')' ||  decode(x_where_clause,null,null,' AND ')||
                       ' NAME like '||''''||p_name||'%'||''''
                into   l_where_clause
                from   dual;
             End If;
         End If;
     Close jtf_contact_cur;
End get_contact;


--Start of Comments
--Procedure   : Get contact
--Description : Returns Name, Description for a given contact or all the contacts
--              attached to a contract party role.
--End of Comments
Procedure Get_Contact(p_api_version	IN	NUMBER,
                      p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                      x_return_status	OUT NOCOPY	VARCHAR2,
                      x_msg_count	OUT NOCOPY	NUMBER,
                      x_msg_data	OUT NOCOPY	VARCHAR2,
                      p_rle_code           IN VARCHAR2,
                      p_cro_code            IN  VARCHAR2,
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
l_id1               OKC_CONTACTS_V.OBJECT1_ID1%TYPE default Null;
l_id2               OKC_CONTACTS_V.OBJECT1_ID2%TYPE default Null;
l_name              VARCHAR2(250) Default Null;
l_Description       VARCHAR2(250) Default Null;
l_object_code       VARCHAR2(30) Default Null;
type                CONTACT_curs_type is REF CURSOR;
contact_curs          contact_curs_type;
Begin


--Added by kthiruva 23-Sep-2003 Bug No.3156265

     IF (p_rle_code = 'LESSOR' and p_cro_code = 'SALESPERSON' and p_intent = 'S') THEN

       OPEN okx_salepers_csr(p_id1  => p_id1,
                             p_id2  => p_id2);

         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;

         Fetch okx_salepers_csr into  l_id1,
                                      l_id2,
                                      l_name,
                                      l_description;

         If okx_salepers_csr%NotFound Then
            Null;--raise appropriate exception here
         End If;

         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;

       CLOSE okx_salepers_csr;

     ELSE
       --Bug# 3325281 Introduced user defined party roles, with JTF indirection

       /*******

       OPEN okx_pcontact_csr(p_name => null,
                             p_id1  => p_id1,
                             p_id2  => p_id2);

         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;

         Fetch okx_pcontact_csr into  l_id1,
                                      l_id2,
                                      l_name,
                                      l_description;

         If okx_pcontact_csr%NotFound Then
            Null;--raise appropriate exception here
         End If;

         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;

       CLOSE okx_pcontact_csr;
       ********/
           Get_contact (p_rle_code        =>  p_rle_code,
                        p_cro_code        =>   p_cro_code,
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
             Open contact_curs for l_query_string;
                l_id1  := Null;
                l_id2  := Null;
                l_name := Null;
                l_description := Null;
                Fetch contact_curs into  l_id1,
                                       l_id2,
                                       l_name,
                                       l_description;
                If contact_curs%NotFound Then
                   Null;--raise appropriate exception here
                End If;
                x_id1 := l_id1;
                x_id2 := l_id2;
                x_name := l_name;
                x_description := l_description;
            Close contact_curs;

     END IF;

End Get_contact;

--Start of Comments
--Procedure   :Get Party_name
--Description : Returns Name of the party. This will be called from the VO for
--		VP.
--End of Comments

FUNCTION get_party_name (p_role_code IN VARCHAR2
			,p_intent IN VARCHAR2
			,p_id1 IN VARCHAR2
			,p_id2 IN VARCHAR2) RETURN VARCHAR2
AS

x_return_status VARCHAR2(100);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(100);
x_id1           VARCHAR2(100);
x_id2           VARCHAR2(200);
x_name          VARCHAR2(500);
x_description   VARCHAR2(1000);

BEGIN

          OKL_VP_JTF_PARTY_NAME_PVT.Get_Party(p_api_version        => 1.0,
                     			p_init_msg_list	  => OKC_API.G_FALSE,
                     			x_return_status	  => x_return_status,
                    			x_msg_count	  => x_msg_count,
                     			x_msg_data	  => x_msg_data,
                     			p_role_code       => p_role_code,
                     			p_intent          => p_intent,
                     			p_id1             => p_id1,
                     			p_id2             => p_id2,
                     			x_id1             => x_id1,
                     			x_id2             => x_id2,
                     			x_name            => x_name,
                     			x_description     => x_description);

	RETURN x_name;

END get_party_name;

--Start of Comments
--Procedure   :Get Party contact name
--Description : Returns Name of the party contact. This will be called from the VO for
--		VP.
--End of Comments

FUNCTION get_party_contact_name (p_rle_code IN VARCHAR2
			,p_cro_code IN VARCHAR2
			,p_intent IN VARCHAR2
			,p_id1 IN VARCHAR2
			,p_id2 IN VARCHAR2) RETURN VARCHAR2
AS

x_return_status VARCHAR2(100);
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(100);
x_id1           VARCHAR2(100);
x_id2           VARCHAR2(200);
x_name          VARCHAR2(500);
x_description   VARCHAR2(1000);

BEGIN

          OKL_VP_JTF_PARTY_NAME_PVT.Get_Contact(p_api_version        => 1.0,
                     			p_init_msg_list	  => OKC_API.G_FALSE,
                     			x_return_status	  => x_return_status,
                    			x_msg_count	  => x_msg_count,
                     			x_msg_data	  => x_msg_data,
                     			p_rle_code        => p_rle_code,
                     			p_cro_code        => p_cro_code,
                     			p_intent          => p_intent,
                     			p_id1             => p_id1,
                     			p_id2             => p_id2,
                     			x_id1             => x_id1,
                     			x_id2             => x_id2,
                     			x_name            => x_name,
                     			x_description     => x_description);

	RETURN x_name;

END get_party_contact_name;


PROCEDURE get_party_lov_sql (p_role_code IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT  NOCOPY VARCHAR2
                            ,x_lov_sql OUT  NOCOPY VARCHAR2)
AS

 l_object_code     VARCHAR2(1000);
 l_select_clause   VARCHAR2(1000);
 l_from_clause     VARCHAR2(1000);
 l_where_clause    VARCHAR2(1000);
 l_order_by_clause VARCHAR2(1000);

l_sql_str   VARCHAR2(4000);


CURSOR  jtf_party_role_cur (p_role_code VARCHAR2, p_intent VARCHAR2) is
        select job.object_code OBJECT_CODE,
               job.object_code||'.ID1 ID1, '||
               job.object_code||'.ID2 ID2, '||
               job.object_code||'.NAME PARTY_NAME, '||
               job.object_code||'.DESCRIPTION DESCRIPTION, ' ||
               ''''|| job.object_code ||''''|| ' JTOT_OBJECT_CODE' SELECT_CLAUSE,
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

BEGIN

   Open jtf_party_role_cur(p_role_code, p_intent);
   Fetch jtf_party_role_cur into jtf_party_role_rec;
   If jtf_party_role_cur%NOTFOUND Then
             --handle exception appropriately
             l_object_code     := 'NOT FOUND';
             l_select_clause   := 'NOT FOUND';
             l_from_clause     := 'NOT FOUND';
             l_where_clause    := 'NOT FOUND';
             l_order_by_clause := 'NOT FOUND';
   Else
             l_object_code     := jtf_party_role_rec.object_code;
             l_select_clause   := jtf_party_role_rec.select_clause;
             l_from_clause     := jtf_party_role_rec.from_clause;
             l_where_clause    := jtf_party_role_rec.where_clause;
             l_order_by_clause := jtf_party_role_rec.order_by_clause;

  END IF;
  l_sql_str := 'SELECT ' || l_select_clause ||' FROM '|| l_from_clause
		 ||' WHERE '|| NVL(l_where_clause,'1=1 ')
		 ||'ORDER BY '|| l_order_by_clause;
  CLOSE jtf_party_role_cur;
  x_lov_sql := l_sql_str;
  x_jtot_object_code := l_object_code;

END get_party_lov_sql;


PROCEDURE get_party_contact_lov_sql (p_rle_code IN VARCHAR2
                            ,p_cro_code IN VARCHAR2
                            ,p_intent IN VARCHAR2
                            ,x_jtot_object_code OUT  NOCOPY VARCHAR2
                            ,x_lov_sql OUT  NOCOPY VARCHAR2)
AS

 l_object_code     VARCHAR2(1000);
 l_select_clause   VARCHAR2(1000);
 l_from_clause     VARCHAR2(1000);
 l_where_clause    VARCHAR2(1000);
 l_order_by_clause VARCHAR2(1000);

l_sql_str   VARCHAR2(4000);

CURSOR  jtf_contact_cur (c_rle_code VARCHAR2,c_cro_code VARCHAR2
			, c_intent VARCHAR2) is
        select job.object_code OBJECT_CODE,
               job.object_code||'.ID1, '||
               job.object_code||'.ID2, '||
               job.object_code||'.NAME, '||
               job.object_code||'.DESCRIPTION, ' ||
               ''''|| job.object_code ||''''|| ' JTOT_OBJECT_CODE' SELECT_CLAUSE,
               from_table FROM_CLAUSE,
               where_clause WHERE_CLAUSE,
               order_by_clause ORDER_BY_CLAUSE
       from    jtf_objects_b job,
               okc_contact_sources rs
       where   job.object_code = rs.jtot_object_code
       and     nvl(job.start_date_active,sysdate) <= sysdate
       and     nvl(job.end_date_active,sysdate + 1) > sysdate
       and     rs.rle_code = c_rle_code
       and     rs.cro_code     = c_cro_code
       and     rs.start_date <= sysdate
       and     nvl(rs.end_date,sysdate+1) > sysdate
       and     rs.buy_or_sell = c_intent;


jtf_contact_rec jtf_contact_cur%rowtype;


BEGIN
  -- sjalasut, added for bug 4755238
  IF okc_context.get_okc_org_id  IS NULL THEN
    okc_context.set_okc_org_context(NULL,NULL);
  END IF;

        Open jtf_contact_cur(p_rle_code,p_cro_code, p_intent);
         Fetch jtf_contact_cur into jtf_contact_rec;
         If jtf_contact_cur%NOTFOUND Then
             --handle exception appropriately
             l_object_code     := 'NOT FOUND';
             l_select_clause   := 'NOT FOUND';
             l_from_clause     := 'NOT FOUND';
             l_where_clause    := 'NOT FOUND';
             l_order_by_clause := 'NOT FOUND';
         Else
             l_object_code     := jtf_contact_rec.object_code;
             l_select_clause   := jtf_contact_rec.select_clause;
             l_from_clause     := jtf_contact_rec.from_clause;
             l_where_clause    := jtf_contact_rec.where_clause;
             l_order_by_clause := jtf_contact_rec.order_by_clause;

          END IF;
  l_sql_str := 'SELECT ' || l_select_clause ||' FROM '|| l_from_clause
		 ||' WHERE '|| NVL(l_where_clause,'1=1 ')
		 ||' ORDER BY '|| l_order_by_clause;
  CLOSE jtf_contact_cur;
  x_lov_sql := l_sql_str;
  x_jtot_object_code := l_object_code;

END get_party_contact_lov_sql;

END; -- Package Body OKL_VP_JTF_PARTY_NAME_PVT

/
