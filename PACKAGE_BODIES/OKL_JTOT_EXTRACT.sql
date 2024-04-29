--------------------------------------------------------
--  DDL for Package Body OKL_JTOT_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_JTOT_EXTRACT" as
/* $Header: OKLRJEXB.pls 120.4 2006/09/22 12:04:36 zrehman noship $ */
--------------------------------------------------------------------------------
--GLOBAL MESSAGE VARIABLES
--------------------------------------------------------------------------------
G_JTF_OBJECT_QUERY_FAILED   CONSTANT Varchar2(200) := 'OKL_LLA_JTF_OBJ_QUERY';
G_RLE_CODE_TOKEN            CONSTANT Varchar2(30)  := 'JTOT_OBJECT_CODE';
G_MISS_CHR_CLE              CONSTANT Varchar2(200) := 'OKL_LLA_MISSING_PARMETERS';
G_MISS_PARA_TOKEN           CONSTANT Varchar2(30)  := 'P1';
G_UNABLE_TO_FIND_PARTY_ROLE CONSTANT Varchar2(200) := 'OKL_LLA_JTF_OBJ_QUERY_FAIL';
G_PARTY_ROLE_TOKEN          CONSTANT Varchar2(30)  := 'ENTITY';
G_PARTY_ROLE_CODE_TOKEN     CONSTANT Varchar2(30)  := 'ENTITY_CODE';
G_MISSING_CONTRACT          CONSTANT Varchar2(200) := 'OKL_LLA_CONTRACT_NOT_FOUND';
G_CONTRACT_ID_TOKEN         CONSTANT Varchar2(30)  := 'CONTRACT_ID';


--Added by kthiruva 23-Sep-2003  Bug No.3156265

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





--Start of Comments
--Procedure   : Get Party
--Description : Returns Name, Description for a given role or all the roles
--              attached to a contract
--End of Comments
Procedure Get_Party (
          p_api_version        IN NUMBER,
          p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2,
          p_chr_id		       IN  VARCHAR2,
          p_cle_id             IN  VARCHAR2,
          p_role_code          IN  OKC_K_PARTY_ROLES_V.rle_code%Type,
          p_intent             IN  VARCHAR2 default 'S',
          x_party_tab          OUT NOCOPY party_tab_type
          ) is
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

l_return_status		           VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'GET_PARTY2';
l_api_version		           CONSTANT NUMBER	     := 1.0;

Begin
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
     --dbms_output.put_line('Error : Either line_id or header id required to find party_role');
      OKL_API.SET_MESSAGE(p_app_name           => g_app_name,
                          p_msg_name           => G_MISS_CHR_CLE,
                          p_token1             => G_MISS_PARA_TOKEN,
                          p_token1_value       => 'p_chr_id or p_cle_id');

      RAISE OKL_API.G_EXCEPTION_ERROR; --raise appropriate exception here
  End If;
  Open party_role_curs(l_chr_id,l_cle_id,l_dnz_chr_id,p_role_code);
  Loop
      Fetch party_role_curs into party_role_rec;
      Exit When party_role_curs%NotFound;
      i := party_role_curs%rowcount;

--Added by kthiruva 23-Sep-2003 Bug No.3156265

      --For object_code 'OKX_PARTY'

    IF ( (party_role_rec.rle_code IN ('BROKER', 'DEALER','GUARANTOR','LESSEE' , 'MANUFACTURER' , 'PRIVATE_LABEL') AND p_intent ='S')
          OR (party_role_rec.rle_code = 'INVESTOR' AND p_intent='B'))
     THEN
          OPEN okx_party_csr(p_name => null,
                             p_id1  => party_role_rec.object1_id1,
                             p_id2  => party_role_rec.object1_id2 );

          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          Fetch okx_party_csr into  l_id1,
                                 l_id2,
                                 l_name,
                                 l_description;

         If okx_party_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||party_role_rec.rle_code||'"');
            --Null;--raise appropriate exception here
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  party_role_rec.rle_code);
            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
        Close okx_party_csr;
      END IF;

   --For object_code 'OKX_OPERUNIT'

    IF ( (party_role_rec.rle_code ='LESSOR' AND p_intent ='S') OR (party_role_rec.rle_code ='SYNDICATOR' AND p_intent ='B'))
     THEN
          OPEN okx_operunit_csr(p_name => null,
                                p_id1  => party_role_rec.object1_id1,
                                p_id2  => party_role_rec.object1_id2 );

          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          Fetch okx_operunit_csr into  l_id1,
                                 l_id2,
                                 l_name,
                                 l_description;

         If okx_operunit_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||party_role_rec.rle_code||'"');
            --Null;--raise appropriate exception here
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  party_role_rec.rle_code);
            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
        Close okx_operunit_csr;
      END IF;

    --For object_code 'OKX_VENDOR'

    IF ( party_role_rec.rle_code ='OKL_VENDOR' AND p_intent='S')
     THEN
          OPEN okx_vendor_csr(p_name => null,
                              p_id1  => party_role_rec.object1_id1,
                              p_id2  => party_role_rec.object1_id2 );

          l_id1  := Null;
          l_id2  := Null;
          l_name := Null;
          l_description := Null;

          Fetch okx_vendor_csr into  l_id1,
                                     l_id2,
                                     l_name,
                                     l_description;

         If okx_vendor_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||party_role_rec.rle_code||'"');
            --Null;--raise appropriate exception here
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  party_role_rec.rle_code);
            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_party_tab(i).rle_code         := party_role_rec.rle_code;
         x_party_tab(i).id1              := l_id1;
         x_party_tab(i).id2              := l_id2;
         x_party_tab(i).name             := l_name;
         x_party_tab(i).description      := l_description;
         x_party_tab(i).object_code      := l_object_code;
        Close okx_vendor_csr;
      END IF;


     End Loop;
   Close party_role_curs;
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
    IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;
     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;
     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;


    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
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

End Get_Party;
--Start of Comments
--Procedure     : Get_Party
--Description   : Fetches Name, Description of a Party role for a given
--                object1_id1 and object2_id2
--End of comments
Procedure Get_Party (p_api_version        IN NUMBER,
                     p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                     x_return_status      OUT NOCOPY VARCHAR2,
                     x_msg_count          OUT NOCOPY NUMBER,
                     x_msg_data           OUT NOCOPY VARCHAR2,
                     p_role_code          IN  VARCHAR2,
                     p_intent             IN  VARCHAR2,
                     p_id1                IN  VARCHAR2,
                     p_id2                IN  VARCHAR2,
                     x_id1                OUT NOCOPY VARCHAR2,
                     x_id2                OUT NOCOPY VARCHAR2,
                     x_name               OUT NOCOPY VARCHAR2,
                     x_description        OUT NOCOPY VARCHAR2) is

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

l_return_status		           VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'GET_PARTY3';
l_api_version		           CONSTANT NUMBER	     := 1.0;

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


--Added by kthiruva 23-Sep-2003 Bug No.3156265

-- For Object Code 'OKX_PARTY'

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
         Fetch okx_party_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_party_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||p_role_code||'"');
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  p_role_code);

            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;
         Close okx_party_csr;
        END IF;

-- For Object Code 'OKX_OPERUNIT'

     IF ( (p_role_code ='LESSOR' AND p_intent ='S') OR (p_role_code ='SYNDICATOR' AND p_intent ='B')) THEN


         OPEN okx_operunit_csr(p_name => null,
                               p_id1  => p_id1,
                               p_id2  => p_id2);


         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;
         Fetch okx_operunit_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_operunit_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||p_role_code||'"');
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  p_role_code);

            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;
         Close okx_operunit_csr;
        END IF;

-- For Object Code 'OKX_VENDOR'

       IF ( p_role_code ='OKL_VENDOR' AND p_intent='S') THEN


         OPEN okx_vendor_csr(p_name => null,
                             p_id1  => p_id1,
                             p_id2  => p_id2);


         l_id1  := Null;
         l_id2  := Null;
         l_name := Null;
         l_description := Null;
         Fetch okx_vendor_csr into  l_id1,
                                   l_id2,
                                   l_name,
                                   l_description;

         If okx_vendor_csr%NotFound Then
            --dbms_output.put_line('Not able to find data for role "'||p_role_code||'"');
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party role',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  p_role_code);

            RAISE OKL_API.G_EXCEPTION_ERROR;
         End If;
         x_id1 := l_id1;
         x_id2 := l_id2;
         x_name := l_name;
         x_description := l_description;
         Close okx_vendor_csr;
        END IF;

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
     IF okx_party_csr%ISOPEN THEN
         CLOSE okx_party_csr;
     END IF;
     IF okx_operunit_csr%ISOPEN THEN
         CLOSE okx_operunit_csr;
     END IF;
     IF okx_vendor_csr%ISOPEN THEN
         CLOSE okx_vendor_csr;
     END IF;


    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
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


End Get_Party;
--Start of Comments
--Procedure   : Get_Subclass_Roles
--Description : fetches Party Roles for a Subclass
--End of Comments
Procedure Get_SubClass_Def_Roles
          (p_api_version        IN NUMBER,
           p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_scs_code           IN  OKC_SUBCLASSES_V.CODE%TYPE,
           x_rle_code_tbl       OUT NOCOPY rle_code_tbl_type) is
CURSOR   scs_rle_curs is
    select scs_code,
           rle_code
    from   okc_subclass_roles
    where  scs_code = p_scs_code
    and    nvl(start_date,sysdate) <= sysdate
    and    nvl(end_date,sysdate+1) > sysdate;
scs_rle_rec scs_rle_curs%rowType;
i  Number;

l_return_status		           VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'GET_SUBCLASS_ROLES';
l_api_version		           CONSTANT NUMBER	     := 1.0;

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

   Open scs_rle_curs;
   Loop
    Fetch scs_rle_curs into scs_rle_rec;
    Exit When scs_rle_curs%NotFound;
    i := scs_rle_curs%RowCount;
    x_rle_code_tbl(i).scs_code := scs_rle_rec.scs_code;
    x_rle_code_tbl(i).rle_code := scs_rle_rec.rle_code;
   End Loop;
  Close scs_rle_curs;
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

End Get_SubClass_Def_Roles;
--Start of Comments
--Procedure   : Get_Contract_Def
--Description : fetches Party Roles for a contract
--End of Comments
Procedure Get_Contract_Def_Roles
          (p_api_version        IN NUMBER,
           p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status      OUT NOCOPY VARCHAR2,
           x_msg_count          OUT NOCOPY NUMBER,
           x_msg_data           OUT NOCOPY VARCHAR2,
           p_chr_id             IN  VARCHAR2,
           x_rle_code_tbl       OUT NOCOPY rle_code_tbl_type) is
Cursor chr_scs_curs is
       select scs_code
       from   OKC_K_HEADERS_B
       where  id = p_chr_id;
l_scs_code           OKC_K_HEADERS_B.SCS_CODE%TYPE;

l_return_status		           VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTRACT_DEF_ROLES';
l_api_version		           CONSTANT NUMBER	     := 1.0;

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

    Open chr_scs_curs;
       Fetch chr_scs_curs into l_scs_code;
       If chr_scs_curs%NotFound Then
          --dbms_output.put_line('Subclass not found for chr id "'||p_chr_id||'"');
          --null; --handle appropriate exception
           OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                               p_msg_name           =>  G_MISSING_CONTRACT,
                               p_token1             =>  G_CONTRACT_ID_TOKEN,
                               p_token1_value       =>  p_chr_id);
            RAISE OKL_API.G_EXCEPTION_ERROR;
       Else
          Get_Subclass_Def_Roles(p_api_version     =>  p_api_version,
                                 p_init_msg_list   =>  p_init_msg_list,
                                 x_return_status   =>  x_return_status,
                                 x_msg_count       =>  x_msg_count,
                                 x_msg_data        =>  x_msg_data,
                                 p_scs_code        => l_scs_code,
                                 x_rle_code_tbl    => x_rle_code_tbl);
           	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		    RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

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

End Get_Contract_Def_Roles;
------------------------------
Procedure Get_Contact(
          p_api_version        IN NUMBER,
          p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
          x_return_status      OUT NOCOPY VARCHAR2,
          x_msg_count          OUT NOCOPY NUMBER,
          x_msg_data           OUT NOCOPY VARCHAR2,
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

l_return_status		           VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'GET_CONTACT';
l_api_version		           CONSTANT NUMBER	     := 1.0;

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

   If okc_context.get_okc_org_id  is null then
      okc_context.set_okc_org_context(null,null);
   End If;

     Open jtf_contacts_cur(p_contact_code,p_role_code,p_intent);
          Fetch jtf_contacts_cur into jtf_contacts_rec;
          If jtf_contacts_cur%NOTFOUND Then
             --dbms_output.put_line('falied in getting jtot query for contact : "'||p_contact_code||'"');
             --handle exception appropriately
                  --dbms_output.put_line('Not able to find data for role "'||p_role_code||'"');
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_UNABLE_TO_FIND_PARTY_ROLE,
                                p_token1             =>  G_PARTY_ROLE_TOKEN,
                                p_token1_value       =>  'party contract',
                                p_token2             =>  G_PARTY_ROLE_CODE_TOKEN,
                                p_token2_value       =>  p_contact_code);

            RAISE OKL_API.G_EXCEPTION_ERROR;
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

END Get_Contact;
END OKL_JTOT_EXTRACT;

/
