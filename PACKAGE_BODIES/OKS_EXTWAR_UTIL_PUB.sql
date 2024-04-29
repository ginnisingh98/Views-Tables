--------------------------------------------------------
--  DDL for Package Body OKS_EXTWAR_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_EXTWAR_UTIL_PUB" AS
/* $Header: OKSPUTLB.pls 120.4 2006/02/20 10:21:58 hmnair noship $ */

l_conc_program VARCHAR2(200) := 'Y';


 Procedure Get_Warranty_Info
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_Org_id              IN   Number,
  p_prod_item_id        IN   Number,
  p_date                IN   Date,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2,
  x_warranty_tbl        OUT  NOCOPY War_tbl
 )
 IS

   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_Warranty_Info';
  BEGIN

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;


   OKS_EXTWAR_UTIL_PVT.Get_Warranty_Info
            (p_Org_id => p_Org_id
            ,p_prod_item_id => p_prod_item_id
            ,p_date         => p_date
            ,x_return_status => l_return_status
            ,x_warranty_tbl => x_warranty_tbl);

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

       x_return_status := l_return_status;

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END Get_Warranty_Info;


Procedure Update_Hdr_Amount
 (
  p_api_version         IN   Number,
  p_init_msg_list       IN   Varchar2,
  p_chr_id              IN   Number,
  x_return_status       OUT  NOCOPY Varchar2,
  x_msg_count           OUT  NOCOPY Number,
  x_msg_data            OUT  NOCOPY Varchar2
 )
 IS

   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Update_Hdr_Amount';
   l_api_version        Number := 1.0;

--Contract Header
  	l_chrv_tbl_in             		okc_contract_pub.chrv_tbl_type;
  	l_chrv_tbl_out            		okc_contract_pub.chrv_tbl_type;


   Cursor l_line_csr Is Select Sum(Nvl(PRICE_NEGOTIATED,0))
                        From OKC_K_LINES_B
                        Where dnz_chr_id = p_chr_id And
                              lse_id in (7,8,9,10,11,35,25);

   l_hdr_amount Number;

  BEGIN

       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      Open  l_line_csr;
      Fetch l_line_csr into l_hdr_amount;
      Close l_line_csr;


	l_chrv_tbl_in(1).id		      := p_chr_id;
	l_chrv_tbl_in(1).estimated_amount	:= l_hdr_amount;

    	okc_contract_pub.update_contract_header
    	(
    		p_api_version						=> l_api_version,
    		p_init_msg_list						=> p_init_msg_list,
    		x_return_status						=> x_return_status,
    		x_msg_count							=> x_msg_count,
    		x_msg_data							=> x_msg_data,
    		p_chrv_tbl							=> l_chrv_tbl_in,
    		x_chrv_tbl							=> l_chrv_tbl_out
      );

       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

       x_return_status := l_return_status;

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');

  END Update_Hdr_Amount;



  FUNCTION Create_Timevalue (p_chr_id IN NUMBER,p_start_date IN DATE) RETURN NUMBER Is
    l_p_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
    l_x_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
    l_api_version    Number := 1.0;
    l_init_msg_list  Varchar2(1) := 'F';
    l_return_status  varchar2(200);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
  Begin
    l_p_tavv_tbl(1).id := NULL;
    l_p_tavv_tbl(1).object_version_number := NULL;
    l_p_tavv_tbl(1).sfwt_flag := 'N';
    l_p_tavv_tbl(1).spn_id := NULL;
    l_p_tavv_tbl(1).tve_id_generated_by := NULL;
    l_p_tavv_tbl(1).dnz_chr_id := NULL;
    l_p_tavv_tbl(1).tze_id := NULL;
    l_p_tavv_tbl(1).tve_id_limited := NULL;
    l_p_tavv_tbl(1).description := '';
    l_p_tavv_tbl(1).short_description := '';
    l_p_tavv_tbl(1).comments := '';
    l_p_tavv_tbl(1).datetime := null;
    l_p_tavv_tbl(1).attribute_category := '';
    l_p_tavv_tbl(1).attribute1 := '';
    l_p_tavv_tbl(1).attribute2 := '';
    l_p_tavv_tbl(1).attribute3 := '';
    l_p_tavv_tbl(1).attribute4 := '';
    l_p_tavv_tbl(1).attribute5 := '';
    l_p_tavv_tbl(1).attribute6 := '';
    l_p_tavv_tbl(1).attribute7 := '';
    l_p_tavv_tbl(1).attribute8 := '';
    l_p_tavv_tbl(1).attribute9 := '';
    l_p_tavv_tbl(1).attribute10 := '';
    l_p_tavv_tbl(1).attribute11 := '';
    l_p_tavv_tbl(1).attribute12 := '';
    l_p_tavv_tbl(1).attribute13 := '';
    l_p_tavv_tbl(1).attribute14 := '';
    l_p_tavv_tbl(1).attribute15 := '';
    l_p_tavv_tbl(1).created_by := NULL;
    l_p_tavv_tbl(1).creation_date := NULL;
    l_p_tavv_tbl(1).last_updated_by := NULL;
    l_p_tavv_tbl(1).last_update_date := NULL;
    l_p_tavv_tbl(1).last_update_login := NULL;

    l_p_tavv_tbl(1).datetime := p_start_date;
    l_p_tavv_tbl(1).dnz_chr_id := p_chr_id;

    okc_time_pub.create_tpa_value
       (p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_tavv_tbl      => l_p_tavv_tbl,
        x_tavv_tbl      => l_x_tavv_tbl) ;

     If l_return_status <> 'S' then
 null;
--action
     End If;

     RETURN(l_x_tavv_tbl(1).id);

  End Create_Timevalue;

-- This procedure should no longer be used.
-- Please use OKS_RENEW_PVT.GET_OKS_RESOURCE
PROCEDURE GET_OKS_RESOURCE (
                  p_party_id            IN NUMBER,
                  x_return_status       OUT  NOCOPY Varchar2,
                  x_msg_count           OUT  NOCOPY Number,
                  x_msg_data            OUT  NOCOPY Varchar2,
                  x_winning_res_id  OUT NOCOPY NUMBER, --l_salesrep_id,
                  x_winning_user_id OUT NOCOPY NUMBER
                  ) IS
  l_terrkren_rec      jtf_territory_pub.jtf_kren_rec_type;
  l_resource_type     varchar2(100)  := to_char(null);
  l_role              varchar2(100)  := to_char(null);
  l_return_status     varchar2(1);
  l_msg_count         NUMBER;
  l_msg_data          varchar2(2000);
  l_terrresource_tbl  jtf_territory_pub.winningterrmember_tbl_type;
  l_user_id           fnd_user.user_id%TYPE;

  CURSOR resource_details(p_resource_id number) IS
    SELECT fu.user_id
    FROM jtf_rs_resource_extns jrd,
         fnd_user fu
    WHERE jrd.resource_id=p_resource_id
    AND    fu.user_id = jrd.user_id;


  CURSOR l_party_name_csr Is select party_Name from hz_parties where party_id = p_party_id;
  l_party_name Varchar2(2000);


BEGIN

  fnd_msg_pub.initialize;

  IF (p_party_id = OKC_API.G_MISS_NUM OR p_party_id IS NULL) THEN
    null;
    -- Handle missing party ID
  END IF;

  Open  l_party_name_csr;
  Fetch l_party_name_csr Into l_party_name;
  close l_party_name_csr;

  l_terrkren_rec.PARTY_ID := p_party_id;
  l_terrkren_rec.COMP_NAME_RANGE   := l_party_name;


  jtf_terr_oks_pub.get_winningterrmembers(
               p_api_version_number => 1.0,
               p_terrkren_rec       => l_terrkren_rec,
               p_resource_type      => l_resource_type,
               p_role               => l_role,
               x_return_status      => l_return_status,      -- OUT
               x_msg_count          => l_msg_count,          -- OUT
               x_msg_data           => l_msg_data,           -- OUT
               x_terrresource_tbl   => l_terrresource_tbl);  -- OUT

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    -- Handle error from territory API
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      null;
  END IF;

  ----dbms_output.put_line('count res: '||l_terrresource_tbl.count);
  ----dbms_output.put_line('v_return_status: '||l_return_status);
  ----dbms_output.put_line('v_msg_count: '||l_msg_count);
  ----dbms_output.put_line('v_msg_data: '||l_msg_data);

  IF l_terrresource_tbl.count = 0 THEN

      OKC_API.set_message
     (
 G_APP_NAME,
 G_UNEXPECTED_ERROR,
 G_SQLCODE_TOKEN,
 SQLCODE,
 G_SQLERRM_TOKEN,
 'No resource found'
     );
     l_return_status := 'E';
     null;
  -- Handle no resource returned

  ELSIF l_terrresource_tbl.count > 1 THEN
     OKC_API.set_message
    (
    G_APP_NAME,
    G_UNEXPECTED_ERROR,
    G_SQLCODE_TOKEN,
    SQLCODE,
    G_SQLERRM_TOKEN,
    'Found more than one jtf resource'
    );
    l_return_status := 'E';
    null;
    -- Handle >1 resource returned

  ELSE  -- i.e. l_terrresource_tbl.count=1

       l_user_id := to_number(null);
       OPEN resource_details(p_resource_id => l_terrresource_tbl(0).resource_id);
       FETCH resource_details INTO l_user_id;
       IF resource_details%NOTFOUND THEN
           null;
        -- Handle no user_id found;
       END IF;
       CLOSE resource_details;

     ----dbms_output.put_line('l_user_id: '||l_user_id);

    -- Set OUT parameters
       x_winning_res_id := l_terrresource_tbl(0).resource_id;
       x_winning_user_id := l_user_id;
       l_return_status := OKC_API.G_RET_STS_SUCCESS;

  END IF;
  x_return_status := l_return_status;

EXCEPTION

  WHEN OTHERS THEN

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
END GET_OKS_RESOURCE;

FUNCTION GET_PARTY_ID (p_contract_id IN NUMBER) RETURN NUMBER IS
CURSOR cur_get_party_id  IS
  select object1_id1
  from okc_k_party_roles_b
  where dnz_chr_id = p_contract_id
  and cle_id is null
  and RLE_CODE = 'CUSTOMER';
  l_party_id     NUMBER;

BEGIN

FOR   c_cur_get_party_id in cur_get_party_id LOOP
 l_party_id := c_cur_get_party_id.object1_id1;
END LOOP;
  return(l_party_id);

END GET_PARTY_ID;


FUNCTION GET_SALESREP_ID (p_resource_id Number,p_org_id Number ) RETURN NUMBER IS
Cursor l_salesrep_csr IS
SELECT salesrep_id
From   jtf_rs_salesreps
Where  resource_id = p_resource_id and org_id = p_org_id;
l_salesrep_id   NUMBER;
BEGIN
FOR c_l_salesrep_csr in l_salesrep_csr LOOP
  l_salesrep_id := c_l_salesrep_csr.salesrep_id;
 END LOOP;
return(l_salesrep_id);
END GET_SALESREP_ID;



FUNCTION GET_RESOURCE_NAME (p_resource_id Number) RETURN VARCHAR2 IS
CURSOR resource_name IS
select resource_name from jtf_rs_resource_extns_tl
where resource_id = p_resource_id
and   language = userenv('LANG');

l_resource_name VARCHAR2(200);
BEGIN
FOR c_resource_name IN resource_name LOOP
  l_resource_name := c_resource_name.resource_name;
END LOOP;
return(l_resource_name);
END GET_RESOURCE_NAME;


FUNCTION GET_PARTY_NAME (p_party_id Number) RETURN VARCHAR2 IS
CURSOR cur_party_name IS
select party_Name from hz_parties
where party_id = p_party_id;
l_party_Name VARCHAR2(200);
BEGIN
FOR c_cur_party_name IN cur_party_name LOOP
  l_party_Name := c_cur_party_name.party_Name;
END LOOP;
return(l_party_Name);
END GET_PARTY_NAME;


PROCEDURE REASSIGNCONTACT (
                  p_api_version                  IN NUMBER,
                  p_init_msg_list                IN VARCHAR2,
                  x_return_status                OUT NOCOPY VARCHAR2,
                  x_msg_count                    OUT NOCOPY NUMBER,
                  x_msg_data                     OUT NOCOPY VARCHAR2,
                  p_contract_header_id IN NUMBER,
                  p_contract_number IN VARCHAR2,
                  p_contract_number_modifier IN VARCHAR2,
		  p_cro_code IN VARCHAR2,
		  p_salesrep_id IN NUMBER,
		  p_user_id IN NUMBER,
                  p_sales_group_id IN NUMBER
			) IS
l_api_version		CONSTANT	NUMBER	:= 1.0;
l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status	VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_msg_index_out		NUMBER;

CURSOR GET_CONTACT IS
SELECT object1_id1, cro_code, id
FROM OKC_CONTACTS
WHERE CRO_CODE = p_cro_code
AND dnz_chr_id = p_contract_header_id;

CURSOR GET_CPL_ID IS
select id from okc_k_party_roles_b
where dnz_chr_id = p_contract_header_id
and cle_id is null
and RLE_CODE = 'VENDOR';

no_of_matches NUMBER := 0;
l_cpl_id NUMBER;

BEGIN

l_return_status := OKC_API.G_RET_STS_SUCCESS;

FOR C_GET_CPL_ID in GET_CPL_ID LOOP
 l_cpl_id := C_GET_CPL_ID.id;
END LOOP;

FOR C_GET_CONTACT IN GET_CONTACT LOOP
 IF (C_GET_CONTACT.object1_id1 = p_salesrep_id) THEN
  no_of_matches := no_of_matches + 1;
 ELSE

  DELETE_CONTACT (
                 x_return_status => l_return_status,
                 p_contact_id    => C_GET_CONTACT.id
                 );
 END IF;
END LOOP;
log_messages('Inside REASSIGNCONTACT no_of_matches =  '  || no_of_matches);

IF no_of_matches = 0 THEN
 CREATE_CONTACT(
                 x_return_status => l_return_status,
                 p_cpl_id 	 => l_cpl_id,
                 p_dnz_chr_id    => p_contract_header_id,
                 p_cro_code      => p_cro_code,
                 p_jtot_object1_code => 'OKX_SALEPERS',
                 p_object1_id1   => p_salesrep_id,
                 p_sales_group_id => p_sales_group_id
                 );

      	     IF    (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
      	        NOTIFY_SALESREP
                (
                    p_user_id,
                    p_contract_header_id,
                    p_contract_number,
                    p_contract_number_modifier,
                    'You are assigned to contract '||p_contract_number || '-' || p_contract_number_modifier
                );
      	     ELSE

--Assemble Data for errorneous condition

      	        NOTIFY_CONTRACT_ADMIN
                (
                  p_contract_header_id,
                  p_contract_number,
                  p_contract_number_modifier,
                  GET_FND_MESSAGE
                );
      	     END IF;
END IF;

x_return_status := l_return_status;

END REASSIGNCONTACT;


PROCEDURE DELETE_CONTACT (
                           x_return_status                OUT NOCOPY VARCHAR2,
			   p_contact_id		IN NUMBER
			   ) IS
-- Contact Details
cursor contact_det is
select a.dnz_chr_id,a.object1_id1, a.object1_id2, a.jtot_object1_code
from   okc_contacts a
where  a.id = p_contact_id;

/*
-- Rule group
cursor rgp_cur(p_chr_id NUMBER) is
select id
from   okc_rule_groups_b
where  dnz_chr_id = p_chr_id
and    cle_id is null;
*/

-- Temporary variables
l_rgp_id   NUMBER;
l_chr_id   NUMBER;
l_obj_id1  Varchar2(2000);
l_obj_id2  Varchar2(2000);
l_jtot_cd  Varchar2(2000);

l_api_version		CONSTANT	NUMBER	:= 1.0;
l_init_msg_list	        VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status	        VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_msg_index_out		NUMBER;

-- Local PL/SQL tables
l_rgpv_tbl_in        okc_rule_pub.rgpv_tbl_type;
l_rgpv_tbl_out       okc_rule_pub.rgpv_tbl_type;
l_rulv_tbl_in        okc_rule_pub.rulv_tbl_type;
l_rulv_tbl_out       okc_rule_pub.rulv_tbl_type;
l_ctcv_tbl_in        okc_contract_party_pub.ctcv_tbl_type;
l_ctcv_tbl_out       okc_contract_party_pub.ctcv_tbl_type;

BEGIN

    -- Get the contact details (if any)
    Open contact_det;
    Fetch contact_det into l_chr_id,l_obj_id1,l_obj_id2,l_jtot_cd;
    Close contact_det;

/*
    --
    -- Create a rule group if one doesn't exist
    --
    Open rgp_cur(l_chr_id);
    Fetch rgp_cur into l_rgp_id;
    Close rgp_cur;
    If l_rgp_id is null Then
      l_rgpv_tbl_in(1).chr_id      := l_chr_id;
      l_rgpv_tbl_in(1).sfwt_flag   := 'N';
      l_rgpv_tbl_in(1).rgd_code    := 'SVC_K';
      l_rgpv_tbl_in(1).dnz_chr_id  := l_chr_id;
      l_rgpv_tbl_in(1).rgp_type    := 'KRG';
      okc_rule_pub.create_rule_group
              (p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_rgpv_tbl      => l_rgpv_tbl_in,
               x_rgpv_tbl      => l_rgpv_tbl_out
              );
      if x_return_status = 'S' then
        l_rgp_id := l_rgpv_tbl_out(1).id;
      else
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          LOG_MESSAGES('okc_rule_pub.create_rule_group - EAB rule l_msg_data = ' || l_msg_data);
    --    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          LOG_MESSAGES('okc_rule_pub.create_rule_group - EAB rule l_msg_data = ' || l_msg_data);
     --   RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

      end if;
    End If;

    --
    -- Now, create EAB Rule (Assuming that one doesn't exist already)
    --
    l_rulv_tbl_in(1).rgp_id            := l_rgp_id;
    l_rulv_tbl_in(1).rule_information_category := 'EAB';
    l_rulv_tbl_in(1).rule_information2 := l_jtot_cd;
    l_rulv_tbl_in(1).rule_information3 := l_obj_id1;
    l_rulv_tbl_in(1).rule_information4 := l_obj_id2;
    l_rulv_tbl_in(1).dnz_chr_id        := l_chr_id;
    okc_rule_pub.create_rule
            (p_api_version    => l_api_version,
             p_init_msg_list  => l_init_msg_list,
             x_return_status  => l_return_status,
             x_msg_count      => l_msg_count,
             x_msg_data       => l_msg_data,
             p_rulv_tbl       => l_rulv_tbl_in,
             x_rulv_tbl       => l_rulv_tbl_out
            );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      LOG_MESSAGES('okc_rule_pub.create_rule - EAB rule l_msg_data = ' || l_msg_data);
  --    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      LOG_MESSAGES('okc_rule_pub.create_rule - EAB rule l_msg_data = ' || l_msg_data);
   --   RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

*/
    l_ctcv_tbl_in(1).id      := p_contact_id;

    okc_contract_party_pub.delete_contact (
    	p_api_version		=> l_api_version,
    	p_init_msg_list		=> l_init_msg_list,
    	x_return_status		=> l_return_status,
    	x_msg_count		=> l_msg_count,
    	x_msg_data		=> l_msg_data,
    	p_ctcv_tbl		=> l_ctcv_tbl_in
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      LOG_MESSAGES('okc_contract_party_pub.delete_contact l_msg_data = ' || l_msg_data);
  --    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      LOG_MESSAGES('okc_contract_party_pub.delete_contact l_msg_data = ' || l_msg_data);
   --   RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
x_return_status := l_return_status;
END DELETE_CONTACT;

PROCEDURE CREATE_CONTACT (x_return_status                OUT NOCOPY VARCHAR2,
                        p_cpl_id IN NUMBER,
			p_dnz_chr_id IN NUMBER,
			p_cro_code IN VARCHAR2,
			p_jtot_object1_code IN VARCHAR2,
			p_object1_id1 IN NUMBER,
                        p_sales_group_id IN NUMBER
			) IS
l_api_version		CONSTANT	NUMBER	:= 1.0;
l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
l_return_status	VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_msg_index_out		NUMBER;
l_ctcv_tbl_in             okc_contract_party_pub.ctcv_tbl_type;
l_ctcv_tbl_out            okc_contract_party_pub.ctcv_tbl_type;

BEGIN
null;
    l_ctcv_tbl_in(1).cpl_id      := p_cpl_id;
    l_ctcv_tbl_in(1).cro_code    := p_cro_code;
    l_ctcv_tbl_in(1).dnz_chr_id  := p_dnz_chr_id;
    l_ctcv_tbl_in(1).OBJECT1_ID1 := p_object1_id1;
    l_ctcv_tbl_in(1).object1_id2 := '#';
    l_ctcv_tbl_in(1).JTOT_OBJECT1_CODE	:= p_jtot_object1_code;
    l_ctcv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
    l_ctcv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
    l_ctcv_tbl_in(1).creation_date                   := SYSDATE;
    l_ctcv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
    l_ctcv_tbl_in(1).last_update_date                := SYSDATE;
    l_ctcv_tbl_in(1).last_update_login               := OKC_API.G_MISS_NUM;
    l_ctcv_tbl_in(1).sales_group_id               := p_sales_group_id;

      okc_contract_party_pub.create_contact (
    	p_api_version		=> l_api_version,
    	p_init_msg_list		=> l_init_msg_list,
    	x_return_status		=> l_return_status,
    	x_msg_count		=> l_msg_count,
    	x_msg_data		=> l_msg_data,
    	p_ctcv_tbl		=> l_ctcv_tbl_in,
    	x_ctcv_tbl		=> l_ctcv_tbl_out
    );

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      LOG_MESSAGES('okc_contract_party_pub.delete_contact l_msg_data = ' || l_msg_data);
  --    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      LOG_MESSAGES('okc_contract_party_pub.delete_contact l_msg_data = ' || l_msg_data);
   --   RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

x_return_status := l_return_status;
END CREATE_CONTACT;

FUNCTION GET_FND_MESSAGE RETURN VARCHAR2 IS
i NUMBER := 0;
l_return_status	VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_msg_index_out		NUMBER;
l_mesg VARCHAR2(2000) := NULL;
BEGIN
        FOR i in 1..fnd_msg_pub.count_msg     Loop
        fnd_msg_pub.get
                     (
                         p_msg_index     => i,
                         p_encoded       => 'F',
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out
                     );
                     l_mesg := l_mesg || ':' || i || ':' || l_msg_data;
        END LOOP;
FND_MESSAGE.CLEAR;
return(l_mesg);
END GET_FND_MESSAGE;

PROCEDURE NOTIFY_SETUP_ADMIN  IS
l_setup_admin VARCHAR2(200) := FND_PROFILE.VALUE('OKS_SETUP_ADMIN_ID');
BEGIN
null;
   IF l_setup_admin IS NOT NULL THEN
     OKS_EXTWAR_UTIL_PUB.NOTIFY('NSA',l_setup_admin,NULL,NULL,NULL,'Profile Vendor Contact Role Not Set Up');
     LOG_MESSAGES('Profile Vendor Contact Role Not Set Up Notification Sent to ' || l_setup_admin);
   ELSE
     LOG_MESSAGES('OKS: Notify Setup Admin is NULL');
   END IF;
END NOTIFY_SETUP_ADMIN;

PROCEDURE NOTIFY_TERRITORY_ADMIN (p_chr_id IN Number,p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2, p_mesg IN VARCHAR2) IS
  CURSOR l_fnd_csr(p_user_id NUMBER) IS
        SELECT user_name
        FROM fnd_user
        WHERE user_id = p_user_id ;


 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(2000);
 l_return_status        VARCHAR2(3);
 l_terr_admin_id        NUMBER;
 l_contract_admin_id    NUMBER;
 l_contract_approver_id NUMBER;
 l_subj                 VARCHAR2(2000);
 l_msg                  VARCHAR2(2000);
 l_user_name            VARCHAR2(100);
 l_con_num_prompt       VARCHAR2(100);


BEGIN

   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'Inside NOTIFY_TERRITORY_ADMIN');
   END IF;

   l_terr_admin_id := FND_PROFILE.VALUE('OKS_TERR_ADMIN_ID');
   l_subj := FND_MESSAGE.get_string('OKS','OKS_TERR_SETUP_ERR_SUB');
   IF (l_terr_admin_id IS NULL) THEN
      l_contract_admin_id := FND_PROFILE.VALUE('OKS_CONTRACT_ADMIN_ID');
   END IF;
   IF l_terr_admin_id IS NOT NULL THEN
       OPEN  l_fnd_csr(l_terr_admin_id);
       FETCH l_fnd_csr INTO l_user_name;
       CLOSE l_fnd_csr;
       IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'Territory Admin is not null  - ' || l_user_name);
       END IF;
   ELSIF l_contract_admin_id IS NOT NULL THEN
       OPEN  l_fnd_csr(l_contract_admin_id);
       FETCH l_fnd_csr INTO l_user_name;
       CLOSE l_fnd_csr;
       IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'Contract Admin is not null  - ' || l_user_name);
       END IF;
   ELSE
      l_user_name :=  FND_PROFILE.VALUE('OKC_K_APPROVER');
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'Contract Approver is not null  - ' || l_user_name);
       END IF;

   END IF;

   l_con_num_prompt := FND_MESSAGE.get_string('OKS','OKS_CONTRACT_NUMBER');
   l_subj := l_subj || ' ' || l_con_num_prompt || ' - ' ||  p_contract_number ||' '||p_contract_number_modifier;

   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'p_recipient is ' || l_user_name ||
                         'p_contract_id is ' || p_chr_id  );
   END IF;
   OKC_ASYNC_PUB.msg_call(p_api_version   => 1,
                          x_return_status => l_return_status,
		          x_msg_count     => l_msg_count,
		          x_msg_data      => l_msg_data,
		          p_recipient     => l_user_name,
                          p_msg_body      => p_mesg,
                          p_msg_subj      => l_subj,
 		          p_contract_id   => p_chr_id );
   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                         'Exiting NOTIFY_TERR_ADMIN' || l_return_status);
   END IF;
END NOTIFY_TERRITORY_ADMIN;

PROCEDURE NOTIFY_CONTRACT_ADMIN (p_chr_id IN Number, p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2, p_mesg IN VARCHAR2) IS
l_contract_admin VARCHAR2(200) := FND_PROFILE.VALUE('OKS_CONTRACT_ADMIN_ID');
BEGIN

   IF l_contract_admin IS NOT NULL THEN
     OKS_EXTWAR_UTIL_PUB.NOTIFY('NCA',l_contract_admin,p_chr_id,p_contract_number,p_contract_number_modifier,p_mesg);
     --LOG_MESSAGES(p_mesg || ':' || p_contract_number || ':' || p_contract_number_modifier || ':' || l_contract_admin);
   END IF;
END NOTIFY_CONTRACT_ADMIN;

PROCEDURE NOTIFY_SALESREP (p_user_id IN NUMBER, p_chr_id IN Number, p_contract_number IN VARCHAR2, p_contract_number_modifier IN VARCHAR2, p_mesg IN VARCHAR2) IS
--l_salesperson_id VARCHAR2(200) := FND_PROFILE.VALUE('OKS_SALESPERSON_ID');
BEGIN

       OKS_EXTWAR_UTIL_PUB.NOTIFY('NSR',p_user_id,p_chr_id,p_contract_number,p_contract_number_modifier,p_mesg);
    -- LOG_MESSAGES(p_mesg || ':' || p_contract_number || ':' || p_contract_number_modifier || ':' || p_user_id);
END NOTIFY_SALESREP;

PROCEDURE SET_MSG (x_return_Status OUT Nocopy Varchar2, p_msg Varchar2)
Is
Begin
                 x_return_status := OKC_API.G_RET_STS_SUCCESS;

                 OKC_API.set_message(p_app_name      => g_app_name,
                                      p_msg_name      => 'CONTRACTS RE-ASSIGNED'
                                     );

                 OKC_API.set_message(p_app_name      => g_app_name,
                                     p_msg_name      => p_msg
                                    );


End;


PROCEDURE NOTIFY
(
 p_type IN VARCHAR2,
 p_notify_id IN Number,
 p_chr_id IN Number,
 p_contract_number IN VARCHAR2,
 p_contract_number_modifier IN VARCHAR2,
 p_mesg IN VARCHAR2) Is

 l_proc Varchar2(4000);
 l_return_status Varchar2(2000);
 l_msg_data Varchar2(4000);
 l_msg_count Number;
 l_user_name Varchar2(2000);
 l_subj      Varchar2(4000) := Null;

 cursor l_fnd_csr is select user_name from fnd_user where user_id = p_notify_id;

Begin

     if p_type = 'NSA' Then
        l_subj := 'Setup Error';
     elsif p_type = 'NTA' Then
        l_subj := 'Territory Setup Error';
     elsif p_type = 'NCA' Then
        l_subj := 'Vendor Contact Creation  Error';
     elsif p_type = 'NSR' Then
        l_subj := FND_MESSAGE.get_string('OKS','OKS_VENDOR_REASSIGNED');
     end if;

     open  l_fnd_csr;
     fetch l_fnd_csr into l_user_name;
     close l_fnd_csr;
     IF l_user_name IS NOT NULL THEN
        OKC_ASYNC_PUB.msg_call(
		    p_api_version   => 1,
		    x_return_status => l_return_status,
		    x_msg_count     => l_msg_count,
		    x_msg_data      => l_msg_data,
		    p_recipient     => l_user_name,
                    p_msg_body      => p_mesg,
                    p_msg_subj      => l_subj,
		    p_contract_id   => p_chr_id
		    );
	END IF;

End NOTIFY;



PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2) IS
 BEGIN
 IF l_conc_program = 'N' THEN
 -- errorout_ad(p_mesg);
  null;
 ELSE
  fnd_file.put_line(FND_FILE.LOG, p_mesg);
 END IF;
 END LOG_MESSAGES;


FUNCTION def_sts_code(p_ste_code VARCHAR2) RETURN VARCHAR2 IS
   CURSOR get_def_sts_code_csr IS
          SELECT code
          FROM okc_statuses_b
          WHERE ste_code = p_ste_code
          AND   default_yn = 'Y';
get_def_sts_code_rec get_def_sts_code_csr%ROWTYPE;
BEGIN

  OPEN get_def_sts_code_csr;
  FETCH get_def_sts_code_csr INTO get_def_sts_code_rec;
  CLOSE get_def_sts_code_csr;
  RETURN (get_def_sts_code_rec.code);

END def_sts_code;

FUNCTION get_ste_code(p_sts_code VARCHAR2) RETURN VARCHAR2 IS
   CURSOR get_ste_code_csr IS
          SELECT ste_code
          FROM okc_statuses_b
          WHERE code = p_sts_code;
get_ste_code_rec get_ste_code_csr%ROWTYPE;
BEGIN

  OPEN get_ste_code_csr;
  FETCH get_ste_code_csr INTO get_ste_code_rec;
  CLOSE get_ste_code_csr;
  RETURN (get_ste_code_rec.ste_code);

END get_ste_code;


Procedure get_duration( p_line_start_date IN DATE,
				    p_line_end_date   IN DATE,
				    x_line_duration   OUT NOCOPY NUMBER,
				    x_line_timeunit   OUT NOCOPY VARCHAR2,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        p_init_msg_list   IN VARCHAR2)
IS


Begin
    OKC_API.init_msg_list(p_init_msg_list);
    OKC_TIME_UTIL_PUB.get_duration(p_start_date => p_line_start_date,
							p_end_date =>   p_line_end_date,
							x_duration =>   x_line_duration,
							x_timeunit =>   x_line_timeunit,
							x_return_status => x_return_status);

END get_duration;

 FUNCTION GET_CHR_SALESREP_ID (p_resource_id Number,p_chr_id Number ) RETURN NUMBER IS
         Cursor l_salesrep_csr IS
                SELECT a.salesrep_id
                From   jtf_rs_salesreps a,
                       okc_k_headers_b b
                Where b.id = p_chr_id
                  and a.resource_id = p_resource_id
                  and a.org_id = b.authoring_org_id;
         l_salesrep_id   NUMBER;
 BEGIN
      FOR c_l_salesrep_csr in l_salesrep_csr LOOP
          l_salesrep_id := c_l_salesrep_csr.salesrep_id;
      END LOOP;
      return(l_salesrep_id);
 END GET_chr_SALESREP_ID;


/******* New concurrent Program ******************/
PROCEDURE SUBMIT_CONTACT_CREATION(ERRBUF            OUT NOCOPY VARCHAR2,
                                   RETCODE           OUT NOCOPY NUMBER,
                                   p_contract_hdr_id IN NUMBER,
                                   p_status_code     IN VARCHAR2,
                                   p_org_id          IN NUMBER,
                                   p_salesrep_id     IN NUMBER ) IS

  l_api_version       CONSTANT NUMBER := 1.0;
  l_init_msg_list     VARCHAR2(2000)  := OKC_API.G_FALSE;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_gen_bulk_Rec      JTF_TERR_ASSIGN_PUB.bulk_trans_rec_type;
  l_gen_return_Rec    JTF_TERR_ASSIGN_PUB.bulk_winners_rec_type;
  l_use_type          VARCHAR2(30);
  l_contract_id       NUMBER;
  l_contract_number   VARCHAR2(120);
  l_cro_code          VARCHAR2(200);
  l_org_id            NUMBER;
  l_resource_id       NUMBER;
  l_user_id           NUMBER;
  l_salesrep_id       NUMBER;
  l_party_id          NUMBER;

  idx1                NUMBER:=1;
  idx2                NUMBER:=1;
  idx3                NUMBER;
  idx4                NUMBER;
  idx5                NUMBER;
  idx6                NUMBER;


  l_count             NUMBER:=0;
  l_counter           NUMBER;
  l_cpl_id            NUMBER;
  l_temp_salesrep     NUMBER;
  l_temp_org_id       NUMBER;
  l_request_id        NUMBER:=0;
  l_terr_admin_msg    VARCHAR2(1000);
  l_admin_msg    VARCHAR2(1000);
  l_salesrep_msg      VARCHAR2(1000);
  l_cvmv_rec          OKC_CVM_PVT.cvmv_rec_type ;
  l_cvmv_upd_rec      OKC_CVM_PVT.cvmv_rec_type ;
  l_cvmv_out_rec      OKC_CVM_PVT.cvmv_rec_type ;
  l_cvmv_upd_out_rec  OKC_CVM_PVT.cvmv_rec_type ;
  l_chrv_rec          OKC_CONTRACT_PUB.chrv_rec_type;
  l_chrv_upd_rec      OKC_CONTRACT_PUB.chrv_rec_type;
  l_chrv_out_rec      OKC_CONTRACT_PUB.chrv_rec_type;
  l_chrv_upd_out_rec  OKC_CONTRACT_PUB.chrv_rec_type;
  l_e_contract_number     VARCHAR2(120);
  l_e_contract_number_mod VARCHAR2(120);
  l_f_chr_id              NUMBER;
  l_terr_res              VARCHAR2(3);

  Type winning_rec_type is record (chr_id number,
                                   resource_id number,
                                   user_id NUMBER);
  TYPE winning_tbl IS TABLE OF winning_rec_type INDEX BY BINARY_INTEGER;
  Type l_num       IS TABLE OF number index by binary_integer;
  Type l_varchar   IS TABLE OF varchar2(2000) index by binary_integer;
  l_winning_tbl               winning_tbl;
  l2_winning_tbl              winning_tbl;
  l_resource_id_tbl           l_num;
  l_user_id_tbl               l_num;
  lb_id                       l_num;
  lb_contract_number          l_varchar ;
  lb_contract_number_modifier l_varchar ;
  lb_contact_start_date       l_varchar;
  lb_authoring_org_id         l_num;
  lb_inv_organization_id      l_num;
  lb_party_id                 l_varchar;
  lb_cpl_id                   l_num;
  lb_party_name               l_varchar ;
  lb_country_code             l_varchar ;
  lb_state_code               l_varchar ;
  lb_contact_id               l_num;
  lb_salesrep_id              l_varchar;
  lb_status                   l_varchar;
  lj_id                       l_num;
  lr_cpl_id                   l_num;
  lr_del_cpl_id               l_num;
  lr_del_cpl_org_id           l_num;
  lr_upd_cpl_org_id           l_num;
  lj_chr_id                   l_num;
  lj_cpl_id                   l_num;
  lj_salesrep_id              l_varchar;
  lj_org_id                   l_num;
  lj_resource_id              l_num;
  lj_user_id                  l_num;

  l_current_salesrep_id NUMBER := -9999;
  l_current_salesgrp_id NUMBER := -1;


 -- Sepearte static SQLs are defined due to performance reason.
 -- Contract Number not null , Status not null, Salesrep not null
 CURSOR GET_ALL_CONTRACTS_1 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.id = p_contract_hdr_id
  AND hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND hdr.sts_code  = p_status_code
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn   = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id    = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id   = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+)     = party2.id
  AND cont.object1_id1(+) = p_salesrep_id
  AND cont.cro_code(+)    = p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

 -- Contract Number is not null , Status is not null
 CURSOR GET_ALL_CONTRACTS_2 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
        SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
             ,hdr.contract_number_modifier
             ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
             ,Party2.id,hz.party_name, hzl.country, hzl.state
             ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
        FROM OKC_K_HEADERS_B hdr,
             okc_k_party_roles_b party1,
             okc_k_party_roles_b party2,
             okc_contacts    cont,
             hz_parties hz,
             hz_party_sites hzs,
             hz_locations hzl
        WHERE hdr.id = p_contract_hdr_id
          AND hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
          AND hdr.sts_code  = p_status_code
          AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
          AND hdr.template_yn = 'N'
          AND party1.dnz_chr_id = hdr.id
          AND party1.cle_id is null
          AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
          AND hz.party_id = party1.object1_id1
          AND hzs.party_id   =   hz.party_id
          AND hzs.identifying_address_flag ='Y'
          AND hzl.location_id = hzs.location_id
          AND party2.dnz_chr_id = party1.dnz_chr_id
          AND party2.chr_id = party1.dnz_chr_id
          AND party2.cle_id is null
          AND party2.rle_code IN ('VENDOR','MERCHANT')
          AND cont.cpl_id (+) = party2.id
          AND cont.cro_code(+)    = p_cro_code
          AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

-- Contract number is not null, salesrep is not null
CURSOR GET_ALL_CONTRACTS_3 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.id = p_contract_hdr_id
  AND hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND stat.STE_CODE  IN ('ENTERED','ACTIVE','SIGNED','HOLD')
  AND hdr.sts_code  = stat.CODE
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+) = party2.id
  AND cont.object1_id1(+) = p_salesrep_id
  AND cont.cro_code(+)    = p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

-- Status is not null and Salesrep is not null
CURSOR GET_ALL_CONTRACTS_4 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND hdr.sts_code  =  p_status_code
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id   = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id     = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+)     = party2.id
  AND cont.object1_id1(+) = p_salesrep_id
  AND cont.cro_code(+)    = p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

 -- Contract Number is not null
CURSOR GET_ALL_CONTRACTS_5 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.id = p_contract_hdr_id
  AND hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND stat.STE_CODE  IN ('ENTERED','ACTIVE','SIGNED','HOLD')
  AND hdr.sts_code  = stat.CODE
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+)  = party2.id
  AND cont.cro_code(+) = p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE)) ;

-- Status is not null
CURSOR GET_ALL_CONTRACTS_6 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
     SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND hdr.sts_code  = p_status_code
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn   = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id  = party1.object1_id1
  AND hzs.party_id = hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id     = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+)  = party2.id
  AND cont.cro_code(+) = p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

-- Sales rep is not null
CURSOR GET_ALL_CONTRACTS_7 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND stat.STE_CODE  IN ('ENTERED','ACTIVE','SIGNED','HOLD')
  AND hdr.sts_code  = stat.CODE
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id   = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id     = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id      = party2.id
  AND cont.object1_id1 = p_salesrep_id
  AND cont.end_date is  null
  AND cont.cro_code    = p_cro_code
  AND (TRUNC(NVL(cont.end_date,SYSDATE)) >= TRUNC(SYSDATE));

-- All params are null
CURSOR GET_ALL_CONTRACTS_8 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
      SELECT /*+ PARALLEL(hdr) */  hdr.id,hdr.contract_number
      ,hdr.contract_number_modifier
      ,hdr.authoring_org_id,hdr.inv_organization_id, party1.object1_id1
      ,Party2.id,hz.party_name, hzl.country, hzl.state
      ,cont.id,cont.object1_id1,cont.start_date,hdr.sts_code
  FROM OKC_K_HEADERS_B hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts    cont,
       hz_parties hz,
       hz_party_sites hzs,
       hz_locations hzl
  WHERE hdr.authoring_org_id=nvl(p_org_id,hdr.authoring_org_id)
  AND stat.STE_CODE  IN ('ENTERED','ACTIVE','SIGNED','HOLD')
  AND hdr.sts_code  = stat.CODE
  AND hdr.scs_code  IN ('SERVICE','WARRANTY','SUBSCRIPTION')
  AND hdr.template_yn = 'N'
  AND party1.dnz_chr_id = hdr.id
  AND party1.cle_id is null
  AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
  AND hz.party_id = party1.object1_id1
  AND hzs.party_id   =   hz.party_id
  AND hzs.identifying_address_flag ='Y'
  AND hzl.location_id   = hzs.location_id
  AND party2.dnz_chr_id = party1.dnz_chr_id
  AND party2.chr_id     = party1.dnz_chr_id
  AND party2.cle_id is null
  AND party2.rle_code IN ('VENDOR','MERCHANT')
  AND cont.cpl_id (+) = party2.id
  AND cont.cro_code(+)= p_cro_code
  AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE));

---------------------------------------------------------------------
 -- Sepearte static SQLs are defined due to performance reason.
 -- Contract Number not null , Status not null, Salesrep not null

 CURSOR GET_ALL_CONTRACTS_9 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.id = p_contract_hdr_id
   AND hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = p_status_code
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id  = party1.dnz_chr_id
   AND party2.chr_id      = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id      = party2.id
   AND cont.object1_id1 = p_salesrep_id
   AND cont.cro_code    = p_cro_code
   AND (TRUNC(NVL(cont.end_date,SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;


 -- Contract Number is not null , Status is not null
 CURSOR GET_ALL_CONTRACTS_10 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.id = p_contract_hdr_id
   AND hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code  = p_status_code
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id(+)   = party2.id
   AND cont.cro_code(+) = p_cro_code
   AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;


-- Contract number is not null, salesrep is not null
CURSOR GET_ALL_CONTRACTS_11 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.id = p_contract_hdr_id
   AND hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = stat.code
   AND stat.ste_code IN ('ENTERED','ACTIVE','SIGNED','HOLD')
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE))
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id      = party2.id
   AND cont.object1_id1 = p_salesrep_id
   AND cont.cro_code    = p_cro_code
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;


-- Status is not null and Salesrep is not null
CURSOR GET_ALL_CONTRACTS_12 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = p_status_code
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id      = party2.id
   AND cont.object1_id1 = p_salesrep_id
   AND cont.cro_code    = p_cro_code
   AND (TRUNC(NVL(cont.end_date,SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;

   -- Contract Number is not null
CURSOR GET_ALL_CONTRACTS_13 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.id = p_contract_hdr_id
   AND hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = stat.code
   AND stat.ste_code IN ('ENTERED','ACTIVE','SIGNED','HOLD')
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id     = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id(+) = party2.id
   AND cont.cro_code(+) = p_cro_code
   AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;


-- Status is not null
CURSOR GET_ALL_CONTRACTS_14 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = p_status_code
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id(+)  = party2.id
   AND cont.cro_code(+) = p_cro_code
   AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;

-- Sales rep is not null
CURSOR GET_ALL_CONTRACTS_15 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = stat.code
   AND stat.ste_code IN ('ENTERED','ACTIVE','SIGNED','HOLD')
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id      = party2.id
   AND cont.object1_id1 = p_salesrep_id
   AND cont.cro_code    = p_cro_code
   AND (TRUNC(NVL(cont.end_date,SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;

-- All params are null
CURSOR GET_ALL_CONTRACTS_16 (p_cro_code in VARCHAR2, p_org_id NUMBER)is
SELECT /*+ PARALLEL(HDR) */
       hdr.ID,
       hdr.contract_number,
       hdr.contract_number_modifier,
       hdr.authoring_org_id,
       hdr.inv_organization_id,
       party1.object1_id1,
       party2.ID,
       hz.party_name,
       c.country,
       c.region_2 state,
       cont.ID,
       cont.object1_id1,
       cont.start_date,
       hdr.sts_code
  FROM okc_k_headers_b hdr,
       okc_statuses_b stat,
       okc_k_party_roles_b party1,
       okc_k_party_roles_b party2,
       okc_contacts cont,
       hz_parties hz,
       hr_all_organization_units b,
       hr_locations_all c
 WHERE hdr.authoring_org_id = NVL( p_org_id, hdr.authoring_org_id )
   AND hdr.sts_code = stat.code
   AND stat.ste_code IN ('ENTERED','ACTIVE','SIGNED','HOLD')
   AND hdr.scs_code IN( 'SERVICE', 'WARRANTY', 'SUBSCRIPTION' )
   AND hdr.template_yn = 'N'
   AND party1.dnz_chr_id = hdr.ID
   AND party1.cle_id IS NULL
   AND party1.rle_code IN ('CUSTOMER','SUBSCRIBER')
   AND party1.object1_id1 = hz.party_id
   AND party2.dnz_chr_id = party1.dnz_chr_id
   AND party2.chr_id = party1.dnz_chr_id
   AND party2.cle_id IS NULL
   AND party2.rle_code IN ('VENDOR','MERCHANT')
   AND cont.cpl_id(+) = party2.id
   AND cont.cro_code(+) = p_cro_code
   AND (TRUNC(NVL(cont.end_date(+),SYSDATE)) >= TRUNC(SYSDATE))
   AND party2.object1_id1 = b.organization_id
   AND b.location_id = c.location_id;


---------------------------------------------------------------------

  CURSOR resource_details(p_resource_id number) IS
         SELECT fu.user_id
         FROM   jtf_rs_resource_extns jrd,fnd_user fu
         WHERE  jrd.resource_id=p_resource_id
         AND    fu.user_id = jrd.user_id;

  CURSOR create_contact_resource IS
         SELECT chr_id,resource_id,user_id,
                salesrep_id,org_id
         FROM oks_jtf_res_temp;

  CURSOR update_contact_resource IS
         SELECT contact_id,authoring_org_id
         FROM oks_k_res_temp
         WHERE status  IN
                (SELECT code
                 FROM okc_statuses_v
                 WHERE ste_code IN('ACTIVE','SIGNED','HOLD'))
         AND contact_id IS NOT NULL;

 CURSOR delete_contact_resource IS
         SELECT contact_id,authoring_org_id
         FROM oks_k_res_temp
         WHERE status  IN
               (SELECT code
                FROM okc_statuses_v
                WHERE ste_code = 'ENTERED')
         AND contact_id IS NOT NULL;

 CURSOR  contact_resource_in_future IS
         SELECT id,contract_number,contract_number_modifier
         FROM oks_k_res_temp
         WHERE  status  IN
                (SELECT code
                FROM okc_statuses_v
                WHERE ste_code IN('ACTIVE','SIGNED','HOLD'))
         AND contact_start_date >= trunc(sysdate) ;

  CURSOR contract_noresource IS
         SELECT id,contract_number, contract_number_modifier,party_name
         FROM   OKS_K_RES_TEMP
         WHERE  id not in (SELECT chr_id FROM OKS_JTF_RES_TEMP);

  CURSOR get_contract_num_mod(p_chr_id NUMBER) IS
         SELECT contract_number, contract_number_modifier
         FROM  okc_k_headers_b
         WHERE id = p_chr_id;

  l_ctcv_tbl_in      okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_in_del  okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_in_upd  okc_contract_party_pub.ctcv_tbl_type;

  l_ctcv_tbl_out     okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out_upd okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out_del okc_contract_party_pub.ctcv_tbl_type;

  l_ctcv_rec_out_upd okc_contract_party_pub.ctcv_rec_type;
  l_ctcv_rec_out_ins okc_contract_party_pub.ctcv_rec_type;
  l_ctcv_rec_out_del okc_contract_party_pub.ctcv_rec_type;




  FUNCTION GET_CONTRACT_NUMBER (p_chr_id Number ) RETURN VARCHAR2 IS
    CURSOR l_contract_csr IS
           SELECT contract_number
           FROM   okc_k_headers_b
           WHERE  id = p_chr_id;
    l_contract_number   VARCHAR2(120);
    BEGIN
      FOR c_l_contract_csr in l_contract_csr LOOP
          l_contract_number := c_l_contract_csr.contract_number;
          EXIT;
     END LOOP;
     return(l_contract_number);
  END GET_CONTRACT_NUMBER;

  FUNCTION GET_CPL_ID (p_chr_id Number ) RETURN NUMBER IS

   CURSOR get_cpl_id_csr(p_chr_id number) IS
      SELECT id
      FROM okc_k_party_roles_b
      WHERE dnz_chr_id = p_chr_id
      AND rle_code  IN ('VENDOR','MERCHANT')
      AND cle_id is null;

   l_cpl_id   NUMBER;
   BEGIN
    FOR c_l_salesrep_csr in get_cpl_id_csr(P_CHR_ID) LOOP
        l_cpl_id := c_l_salesrep_csr.id;
        EXIT;
    END LOOP;
      return(l_cpl_id);
 END GET_CPL_ID;

 FUNCTION GET_ORG_ID (p_chr_id Number ) RETURN NUMBER IS

  CURSOR get_org_id(p_chr_id number) IS
         SELECT authoring_org_id
         FROM   okc_k_headers_b
         WHERE  id = p_chr_id;

  l_org_id NUMBER;
  BEGIN
    OPEN   get_org_id(p_chr_id);
    FETCH  get_org_id INTO l_org_id;
    CLOSE  get_org_id;

    return(l_org_id);
 END GET_ORG_ID;

 BEGIN

fnd_file.put_line(FND_FILE.LOG,'Start Time ' || to_char(sysdate,'HH:MI:SS'));
-- l_request_id :=  FND_GLOBAL.CONC_REQUEST_ID;

 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT   ||'.SUBMIT_CONTACT_CREATION',
                     'Reassign: start time= '
                   ||to_char(sysdate,'HH:MI:SS') ||' '
                   || ' p_org_id : '         || p_org_id
                   || ' p_salesrep_id: '     || p_salesrep_id
                   || ' p_contract_number: ' || p_contract_hdr_id
                   || ' p_contract_status: ' || p_status_code);
 END IF;


  l_org_id := p_org_id;

  IF (FND_PROFILE.VALUE('OKS_USE_JTF') = 'YES') THEN
     fnd_file.put_line(FND_FILE.LOG,'OKS: Use Territories to Default Sales Person: Yes');
     l_cro_code := FND_PROFILE.VALUE('OKS_VENDOR_CONTACT_ROLE');

     -- set org context when the org parameter is not null
     IF l_org_id IS NOT NULL THEN
                  OKC_CONTEXT.set_okc_org_context(l_org_id,null);
     END IF;

     IF l_cro_code IS NULL THEN
        fnd_file.put_line(FND_FILE.LOG,'Invalid CRO Code');
        NOTIFY_SETUP_ADMIN;
     ELSE
      IF NVL(fnd_profile.value('OKS_SRC_TERR_QUALFIERS'),'V')='V' THEN
          l_terr_res := 'V';
      ELSE
          l_terr_res := 'C';
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                'Profile Value for OKS_SRC_TERR_QUALFIERS is '||  l_terr_res);
      END IF;

      IF l_terr_res = 'V' THEN

           IF  (p_contract_hdr_id IS NOT NULL AND p_status_code IS NOT NULL AND p_salesrep_id IS NOT NULL ) THEN
               OPEN GET_ALL_CONTRACTS_9(l_cro_code,l_org_id);
           ELSIF  (p_contract_hdr_id IS NOT NULL AND p_status_code IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_10(l_cro_code,l_org_id);
           ELSIF  (p_contract_hdr_id IS NOT NULL AND p_salesrep_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_11(l_cro_code,l_org_id);
           ELSIF  (p_status_code     IS NOT NULL AND p_salesrep_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_12(l_cro_code,l_org_id) ;
           ELSIF (p_contract_hdr_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_13(l_cro_code,l_org_id) ;
           ELSIF (p_status_code     IS NOT NULL) THEN
              OPEN GET_ALL_CONTRACTS_14(l_cro_code,l_org_id);
           ELSIF (p_salesrep_id     IS NOT NULL) THEN
              OPEN GET_ALL_CONTRACTS_15(l_cro_code,l_org_id);
           ELSE
              OPEN GET_ALL_CONTRACTS_16(l_cro_code,l_org_id);
           END IF;
      ELSE
           -- OPEN THE CURSOR BASED ON THE INPUT PARAMETERS
           IF  (p_contract_hdr_id IS NOT NULL AND p_status_code IS NOT NULL AND p_salesrep_id IS NOT NULL ) THEN
               OPEN GET_ALL_CONTRACTS_1(l_cro_code,l_org_id);
           ELSIF  (p_contract_hdr_id IS NOT NULL AND p_status_code IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_2(l_cro_code,l_org_id);
           ELSIF  (p_contract_hdr_id IS NOT NULL AND p_salesrep_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_3(l_cro_code,l_org_id);
           ELSIF  (p_status_code     IS NOT NULL AND p_salesrep_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_4(l_cro_code,l_org_id) ;
           ELSIF (p_contract_hdr_id IS NOT NULL) THEN
               OPEN GET_ALL_CONTRACTS_5(l_cro_code,l_org_id) ;
           ELSIF (p_status_code     IS NOT NULL) THEN
              OPEN GET_ALL_CONTRACTS_6(l_cro_code,l_org_id);
           ELSIF (p_salesrep_id     IS NOT NULL) THEN
              OPEN GET_ALL_CONTRACTS_7(l_cro_code,l_org_id);
           ELSE
              OPEN GET_ALL_CONTRACTS_8(l_cro_code,l_org_id);
           END IF;
      END IF;
      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Before Cursor Fetch');
      END IF;
    LOOP
      IF GET_ALL_CONTRACTS_1%ISOPEN THEN
         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_1%ISOPEN - ');
         END IF;
         FETCH GET_ALL_CONTRACTS_1 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_2%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_2%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_2 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status  limit 1000;
      ELSIF GET_ALL_CONTRACTS_3%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_3%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_3 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_4%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_4%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_4 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;

      ELSIF GET_ALL_CONTRACTS_5%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_5%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_5 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_6%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_6%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_6 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_7%ISOPEN THEN
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_7%ISOPEN - ');
             END IF;
             FETCH GET_ALL_CONTRACTS_7 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_8%ISOPEN THEN
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_8%ISOPEN - ');
             END IF;
             FETCH GET_ALL_CONTRACTS_8 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status  limit 1000;

      ELSIF GET_ALL_CONTRACTS_9%ISOPEN THEN
         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_9%ISOPEN - ');
         END IF;
         FETCH GET_ALL_CONTRACTS_9 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_10%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_10%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_10 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status  limit 1000;
      ELSIF GET_ALL_CONTRACTS_11%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_11%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_11 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_12%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_12%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_12 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status limit 1000;

      ELSIF GET_ALL_CONTRACTS_13%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_13%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_13 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_14%ISOPEN THEN
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_14%ISOPEN - ');
            END IF;
            FETCH GET_ALL_CONTRACTS_14 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_15%ISOPEN THEN
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_15%ISOPEN - ');
             END IF;
             FETCH GET_ALL_CONTRACTS_15 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id ,
                                         lb_contact_start_date,
                                         lb_status limit 1000;
      ELSIF GET_ALL_CONTRACTS_16%ISOPEN THEN
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' GET_ALL_CONTRACTS_16%ISOPEN - ');
             END IF;
             FETCH GET_ALL_CONTRACTS_16 BULK COLLECT INTO lb_id,lb_contract_number,
                                         lb_contract_number_modifier,
                                         lb_authoring_org_id,
                                         lb_inv_organization_id,
                                         lb_party_id,lb_cpl_id,
                                         lb_party_name,lb_country_code,
                                         lb_state_code,lb_contact_id,
                                         lb_salesrep_id,
                                         lb_contact_start_date,
                                         lb_status  limit 1000;

     END IF;

     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                       ' Main cursor count : ' ||   lb_id.count ||
                       ' After Main Cursor Fetch time: ' || to_char(sysdate,'HH:MI:SS'));
     END IF;

     l_gen_return_Rec.trans_object_id.delete;
     l_gen_return_Rec.resource_id.delete;
     l_gen_bulk_rec.trans_object_id.delete;
     l_gen_bulk_rec.trans_detail_object_id.delete;
     l_gen_bulk_rec.SQUAL_CHAR01.delete;
     l_gen_bulk_rec.SQUAL_CHAR04.delete;
     l_gen_bulk_rec.SQUAL_CHAR07.delete;
     l_gen_bulk_rec.SQUAL_NUM01.delete;



     IF lb_id.count > 0 THEN
        FOR i in lb_id.first..lb_id.last
        LOOP
             l_gen_bulk_rec.trans_object_id.EXTEND;
             l_gen_bulk_rec.trans_detail_object_id.EXTEND;
             l_gen_bulk_rec.SQUAL_CHAR01.EXTEND;
             l_gen_bulk_rec.SQUAL_CHAR04.EXTEND;
             l_gen_bulk_rec.SQUAL_CHAR07.EXTEND;
             l_gen_bulk_rec.SQUAL_NUM01.EXTEND;
             l_gen_bulk_rec.trans_object_id(i)         := lb_id(i);
             l_gen_bulk_rec.trans_detail_object_id(i)  := lb_id(i);
             l_gen_bulk_rec.SQUAL_CHAR01(i) := lb_party_name(i);
             l_gen_bulk_rec.SQUAL_CHAR04(i) := lb_state_code(i);
             l_gen_bulk_rec.SQUAL_CHAR07(i) := lb_country_code(i);
             l_gen_bulk_rec.SQUAL_NUM01(i) := lb_party_id(i);
             l_use_type := 'RESOURCE';

             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' Parameters Passed to Territory: ' ||
                            ' Party Name ' || lb_party_name(i)  ||
                            ' State      ' || lb_state_code(i)  ||
                            ' Country    ' || lb_country_code(i)||
                            ' Party Id   ' || lb_party_id(i)  );
             END IF;
             INSERT INTO OKS_K_RES_TEMP (id,contract_number,contract_number_modifier,status,
                                         authoring_org_id,inv_organization_id,party_id,cpl_id,
                                         party_name,country_code,state_code,contact_id,salesrep_id,
                                         contact_start_date,contact_end_date,contract_start_date,contract_end_date)
             values (lb_id(i)
                    ,lb_contract_number(i)
                    ,lb_contract_number_modifier(i)
                    ,lb_status(i)
                    ,lb_authoring_org_id(i)
                    ,lb_inv_organization_id(i)
                    ,lb_party_id(i)
                    ,lb_cpl_id(i)
                    ,lb_party_name(i)
                    ,lb_country_code(i)
                    ,lb_state_code(i)
                    ,lb_contact_id(i)
                    ,lb_salesrep_id(i)
                    ,lb_contact_start_date(i)
                    ,null
                    ,null
                    ,null
                    );

        END LOOP;

        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                 'INSERTED INTO oks_reassign_resource_TMP : Successful'
               || 'Nmber of Recs passedto JTF: '
               || l_gen_bulk_rec.trans_object_id.count
               || 'JTF_TERR_ASSIGN_PUB.get_winners start :'
               || to_char(sysdate,'HH:MI:SS'));
        END IF;

        -- Call JTT API to get the winners
        JTF_TERR_ASSIGN_PUB.get_winners
           (   p_api_version_number       => 1.0,
               p_init_msg_list            => OKC_API.G_FALSE,
               p_use_type                 => l_use_type,
               p_source_id                => -1500,
               p_trans_id                 => -1501,
               p_trans_rec                => l_gen_bulk_rec,
               p_resource_type            => FND_API.G_MISS_CHAR,
               p_role                     => FND_API.G_MISS_CHAR,
               p_top_level_terr_id        => FND_API.G_MISS_NUM,
               p_num_winners              => FND_API.G_MISS_NUM,
               x_return_status            => l_return_status,
               x_msg_count                => l_msg_count,
               x_msg_data                 => l_msg_data,
               x_winners_rec              => l_gen_return_rec
           );

        fnd_file.put_line(FND_FILE.LOG,'After JTF API Call :  ' || l_return_status ) ;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               -- Handle error from territory API
               fnd_file.put_line(FND_FILE.LOG,'Exception in JTF Territory call');
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSE
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                               'JTF_TERR_ASSIGN_PUB.get_winners end :'
                               || to_char(sysdate,'HH:MI:SS') );
             END IF;

        END IF;

        l_winning_tbl.delete;
        l_counter := l_gen_return_Rec.trans_object_id.FIRST;
        l2_winning_tbl(1).chr_id:=0;
        WHILE (l_counter <= l_gen_return_Rec.trans_object_id.LAST)
         LOOP
              IF  l2_winning_tbl(1).chr_id<> l_gen_return_rec.trans_object_id(l_counter)    THEN
                 l_user_id := to_number(null);
                -- Set OUT parameters
                l_winning_tbl(l_counter).resource_id :=l_gen_return_Rec.RESOURCE_ID(l_counter);
                l_winning_tbl(l_counter).user_id     := l_user_id;
                l_winning_tbl(l_counter).chr_id := l_gen_return_rec.trans_object_id(l_counter);
                l2_winning_tbl(1).chr_id:= l_gen_return_rec.trans_object_id(l_counter);

                IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                   ' Resource Returned from JTT API for Contract : ' || l_gen_return_rec.trans_object_id(l_counter)
                                   || ' is ' || l_gen_return_Rec.RESOURCE_ID(l_counter));
                END IF;
              END IF;
              l_counter := l_counter + 1;
         END LOOP;


         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT                                                                ||'.SUBMIT_CONTACT_CREATION',
                            'l_winning_tbl count is : '|| l_winning_tbl.count ||
                           ' Completed time '||  to_char(sysdate,'HH:MI:SS'));
         END IF;

         IF l_winning_tbl.count>0 THEN
            idx4:= l_winning_tbl.FIRST;
            LOOP
               IF l_winning_tbl(idx4).resource_id IS NOT NULL THEN
                    l_temp_salesrep := GET_CHR_SALESREP_ID(l_winning_tbl(idx4).resource_id,
                                                           l_winning_tbl(idx4).chr_id);
                    l_temp_org_id   := GET_ORG_ID(l_winning_tbl(idx4).chr_id);
                    IF  l_temp_salesrep IS NOT NULL  THEN
                        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                   ' Contract selected to insert into JTF_RES_TEMP : ' || l_winning_tbl(idx4).chr_id);
                        END IF;

                        INSERT INTO OKS_JTF_RES_TEMP (chr_id,resource_id,user_id,salesrep_id
                                                      ,org_id,inv_organization_id,contract_start_date,contract_end_date)
                        values(l_winning_tbl(idx4).chr_id
                              ,l_winning_tbl(idx4).resource_id
                              ,l_winning_tbl(idx4).user_id
                              ,l_temp_salesrep
                              ,l_temp_org_id
                              ,null
                              ,null
                              ,null);
                    ELSE
                        l_admin_msg :=  FND_MESSAGE.GET_STRING('OKS','OKS_INVALID_SALES_PERSON');
                        OPEN  get_contract_num_mod(l_winning_tbl(idx4).chr_id);
                        FETCH get_contract_num_mod into l_e_contract_number,l_e_contract_number_mod;
                        CLOSE get_contract_num_mod;

                        IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                   ' Invalid salesrep returned for this Contract : ' || l_e_contract_number || ' ' || l_e_contract_number_mod);
                        END IF;

                        --Delete this contract
                        DELETE FROM oks_k_res_temp
                        WHERE  id = l_winning_tbl(idx4).chr_id;

                        NOTIFY_TERRITORY_ADMIN
                        ( 1,
                          l_e_contract_number,
                          l_e_contract_number_mod,
                          l_admin_msg);
                        fnd_file.put_line(FND_FILE.LOG,l_admin_msg || ' Contract Number - ' || l_e_contract_number);
                    END IF;
                    EXIT WHEN idx4 =l_winning_tbl.LAST;
                    idx4 := l_winning_tbl.NEXT(idx4);
               END IF;
            END LOOP;
            IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT                                                             ||'.SUBMIT_CONTACT_CREATION',
                              'oks_jtf_resource_TMP Table population completed');
            END IF;
         END IF;


           -- Delete all contracts which has a salesrep (not end dated),which is same as the resource setup.
          DELETE  FROM oks_k_res_temp a
                  WHERE exists
                       ( SELECT null
                         FROM oks_k_res_temp b,
                              oks_jtf_res_temp c
                         WHERE b.id = a.id
                           AND b.salesrep_id = c.salesrep_id
                           AND c.chr_id = a.id
            );

          -- Send notification for those contracts with no resource setup
          FOR contract_noresource_rec in contract_noresource
          LOOP
              l_terr_admin_msg := FND_MESSAGE.GET_STRING('OKS','OKS_NO_TERR_RESOURCES');
              IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                'Contract with no resource setup : ' || contract_noresource_rec.Contract_number || ' '
                                || contract_noresource_rec.Contract_number_modifier);
              end if;
              NOTIFY_TERRITORY_ADMIN
              ( contract_noresource_rec.id,
                contract_noresource_rec.Contract_number,
                contract_noresource_rec.Contract_number_modifier,l_terr_admin_msg);
              DELETE FROM oks_k_res_temp
              WHERE id =  contract_noresource_rec.id;
              fnd_file.put_line(FND_FILE.LOG,'There is no resource setup. Contract Number - '|| contract_noresource_rec.Contract_number);
          END LOOP;

         -- Send notification for those contracts which has a vendor contact starting in future.
         l_f_chr_id := 0;
         FOR contact_resource_inf_rec IN contact_resource_in_future
         LOOP
             l_terr_admin_msg := FND_MESSAGE.GET_STRING('OKS','OKS_VENDOR_STAMP_ERROR');
             IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                'Contract with vendor contact starting in future: ' || contact_resource_inf_rec.Contract_number || ' '
                                || contact_resource_inf_rec.Contract_number_modifier);
             end if;
             IF ( l_f_chr_id <> contact_resource_inf_rec.id) THEN
                 NOTIFY_TERRITORY_ADMIN
                  ( contact_resource_inf_rec.id,
                    contact_resource_inf_rec.Contract_number,
                    contact_resource_inf_rec.Contract_number_modifier,l_terr_admin_msg);
                 fnd_file.put_line(FND_FILE.LOG,'Unable to terminate current vendor contact. Contract Number - ' || contact_resource_inf_rec.Contract_number);
             END IF;
             l_f_chr_id := contact_resource_inf_rec.id;
         END LOOP;

         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT                                                             ||'.SUBMIT_CONTACT_CREATION',
                           'Notifications sends for no resources and resources in future date');
         END IF;


          -- Delete all contracts which has a salesrep with start date in future.
         DELETE FROM oks_k_res_temp a
                WHERE exists
                      ( SELECT null
                        FROM oks_k_res_temp b
                        WHERE b.id = a.id
                        AND b.contact_start_date >= trunc(sysdate)
                        AND b.status IN (SELECT code
                         		 FROM okc_statuses_v
                                         WHERE ste_code IN('ACTIVE','SIGNED','HOLD'))
                      );

          -- Now delete those contracts from oks_jtf_res_temp which are deleted from oks_k_res_temp
          DELETE FROM oks_jtf_res_temp a
                 WHERE not exists
                      ( SELECT null
                        FROM oks_k_res_temp b
                        WHERE a.chr_id = b.id
                      );


          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Before fetching create_contact_resource cursor');
          END IF;

          -- Get all contracts to be stamped with new salesrep.
          OPEN    create_contact_resource;
          LOOP
              FETCH   create_contact_resource BULK COLLECT INTO
                      lj_chr_id
                      ,lj_resource_id
                      ,lj_user_id
                      ,lj_salesrep_id
                      ,lj_org_id limit 1000;
            IF lj_chr_id.count > 0 THEN
               FOR i2 in lj_chr_id.first..lj_chr_id.last
                 LOOP
                      l_cpl_id := get_cpl_id(lj_chr_id(i2));
                      l_contract_number := get_contract_number(lj_chr_id(i2));
                      l_ctcv_tbl_in(idx1).cpl_id            := l_cpl_id;
                      l_ctcv_tbl_in(idx1).cro_code          := l_cro_code;
                      l_ctcv_tbl_in(idx1).dnz_chr_id        := lj_chr_id(i2);
                      l_ctcv_tbl_in(idx1).OBJECT1_ID1       := lj_salesrep_id(i2);
                      l_ctcv_tbl_in(idx1).object1_id2       := '#';
                      l_ctcv_tbl_in(idx1).JTOT_OBJECT1_CODE := 'OKX_SALEPERS';
                      l_ctcv_tbl_in(idx1).attribute1        := lj_user_id(i2);
                      l_ctcv_tbl_in(idx1).attribute2        := l_contract_number;
                      l_ctcv_tbl_in(idx1).object_version_number := OKC_API.G_MISS_NUM;
                      l_ctcv_tbl_in(idx1).created_by       := OKC_API.G_MISS_NUM;
                      l_ctcv_tbl_in(idx1).creation_date    := SYSDATE;
                      l_ctcv_tbl_in(idx1).last_updated_by  := OKC_API.G_MISS_NUM;
                      l_ctcv_tbl_in(idx1).last_update_date := SYSDATE;
                      l_ctcv_tbl_in(idx1).last_update_login := OKC_API.G_MISS_NUM;
                      l_ctcv_tbl_in(idx1).start_date    := SYSDATE;
                      l_ctcv_tbl_in(idx1).attribute3    := lj_org_id(i2);
                      -- Bug Fix 4749200
                      IF l_current_salesrep_id <> lj_salesrep_id(i2) THEN
                         l_current_salesgrp_id := jtf_rs_integration_pub.get_default_sales_group( p_salesrep_id => lj_salesrep_id(i2) ,
                                                                                                  p_org_id      => lj_org_id(i2),
                                                                                                  p_date       => SYSDATE );
                         l_ctcv_tbl_in(idx1).sales_group_id := l_current_salesgrp_id ;
                         l_current_salesrep_id := lj_salesrep_id(i2) ;
                      ELSE
                         l_ctcv_tbl_in(idx1).sales_group_id := l_current_salesgrp_id ;
                      END IF;

                      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'contract selected to create new contact : ' || l_contract_number
                            || ' ' || 'ID ' || lj_chr_id(i2) );
                      END IF;
                      idx1 := idx1 +1;
                END LOOP ;
            END IF;
            IF create_contact_resource%ISOPEN THEN
                  EXIT WHEN create_contact_resource%NOTFOUND;
            END IF;
          END LOOP;
          IF create_contact_resource%ISOPEN THEN
             CLOSE create_contact_resource;
          END IF;


          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Populating l_ctcv_tbl_in completed');
          END IF;

         -- Get all contacts that has to be updated.
         OPEN  update_contact_resource;
         LOOP
           FETCH update_contact_resource BULK COLLECT INTO
               lr_cpl_id,lr_upd_cpl_org_id limit 1000;
           IF (lr_cpl_id.count > 0 ) THEN
             FOR i3 in lr_cpl_id.first .. lr_cpl_id.last
               LOOP
                 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Contacts selected for update ' || lr_cpl_id(i3) );
                 END IF;
                 l_ctcv_tbl_in_upd(idx2).id := lr_cpl_id(i3);
                 l_ctcv_tbl_in_upd(idx2).end_date := sysdate-1;
                 l_ctcv_tbl_in_upd(idx2).attribute1 := lr_upd_cpl_org_id(i3);
                 idx2 := idx2 +1;
               END LOOP;
           END IF;
           IF  update_contact_resource%ISOPEN THEN
               EXIT WHEN update_contact_resource%NOTFOUND;
           END IF;
         END LOOP;
         IF update_contact_resource%ISOPEN THEN
            CLOSE update_contact_resource;
         END IF;
         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Populating l_ctcv_tbl_in_upd completed');
          END IF;

         -- Get all contacts that has to be deleted.
         OPEN  delete_contact_resource;
         LOOP
           FETCH delete_contact_resource BULK COLLECT INTO
               lr_del_cpl_id,lr_del_cpl_org_id limit 1000;
           IF (lr_del_cpl_id.count >0 ) THEN
              FOR i4 in lr_del_cpl_id.first .. lr_del_cpl_id.last
              LOOP
                 IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Contacts selected for delete ' || lr_del_cpl_id(i4));
                 END IF;
                 l_ctcv_tbl_in_del(i4).id         := lr_del_cpl_id(i4);
                 l_ctcv_tbl_in_del(i4).attribute1 := lr_del_cpl_org_id(i4);
              END LOOP;
           END IF;
           IF    delete_contact_resource%ISOPEN THEN
                  EXIT WHEN delete_contact_resource%NOTFOUND;
            END IF;
         END LOOP;

         IF delete_contact_resource%ISOPEN THEN
            CLOSE delete_contact_resource;
         END IF;

          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Completed populating PL/SQL tables for create, update and delete');
          END IF;

         IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            ' Number of records selected for update ' || l_ctcv_tbl_in_upd.count || ' ' ||
                            ' Number of records selected for delete ' || l_ctcv_tbl_in_del.count || ' ' ||
                            ' Number of records selected for create ' || l_ctcv_tbl_in.count) ;
         END IF;

         IF (l_ctcv_tbl_in_upd.count  > 0 ) THEN
            idx5 := l_ctcv_tbl_in_upd.FIRST;
            LOOP
               -- If org id is null, need to set org context for each contract.
               IF l_org_id IS NULL THEN
                  OKC_CONTEXT.set_okc_org_context(l_ctcv_tbl_in_upd(idx5).attribute1,null);
               END IF;
               l_ctcv_tbl_in_upd(idx5).attribute1 := NULL;
               okc_contract_party_pub.update_contact ( p_api_version   => l_api_version,
                                                       p_init_msg_list => l_init_msg_list,
                                                       x_return_status => l_return_status,
                                                       x_msg_count     => l_msg_count,
                                                       x_msg_data      => l_msg_data,
                                                       p_ctcv_rec      => l_ctcv_tbl_in_upd(idx5),
                                                       x_ctcv_rec      => l_ctcv_rec_out_upd );
               EXIT WHEN idx5 = l_ctcv_tbl_in_upd.LAST;
               idx5 := l_ctcv_tbl_in_upd.NEXT(idx5);
            END LOOP;
         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Exception in update contact ');
               END IF;
               fnd_file.put_line(FND_FILE.LOG,'Exception in update contact');
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         IF (l_ctcv_tbl_in_del.count  > 0 ) THEN
            idx6 := l_ctcv_tbl_in_del.FIRST;
            LOOP
               -- If org id is null, need to set org context for each contract.
               IF l_org_id IS NULL THEN
                  OKC_CONTEXT.set_okc_org_context(l_ctcv_tbl_in_del(idx6).attribute1,null);
               END IF;
               l_ctcv_tbl_in_del(idx6).attribute1 := NULL;
               okc_contract_party_pub.delete_contact ( p_api_version   => l_api_version,
                                                       p_init_msg_list => l_init_msg_list,
                                                       x_return_status => l_return_status,
                                                       x_msg_count     => l_msg_count,
                                                       x_msg_data      => l_msg_data,
                                                       p_ctcv_rec      => l_ctcv_tbl_in_del(idx6));

               EXIT WHEN idx6 = l_ctcv_tbl_in_del.LAST;
               idx6 := l_ctcv_tbl_in_del.NEXT(idx6);
            END LOOP;
         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Exception in delete contact ');
               END IF;
               fnd_file.put_line(FND_FILE.LOG,'Exception in delete contact');
               RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;

         IF (l_ctcv_tbl_in.count  > 0 ) THEN
            idx3 := l_ctcv_tbl_in.FIRST;
            LOOP
               IF l_org_id IS NULL THEN
                  OKC_CONTEXT.set_okc_org_context(l_ctcv_tbl_in(idx3).attribute3,null);
               END IF;
               l_ctcv_tbl_in(idx3).attribute3 := NULL;
               okc_contract_party_pub.create_contact (p_api_version   => l_api_version,
			                              p_init_msg_list => l_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => l_msg_count,
                                                      x_msg_data      => l_msg_data,
                                                      p_ctcv_rec      => l_ctcv_tbl_in(idx3),
                                                      x_ctcv_rec          => l_ctcv_rec_out_ins);

                 IF (l_return_status = OKC_API.G_RET_STS_SUCCESS ) THEN
                     okc_cvm_pvt.g_trans_id := 'XXX';
	             l_cvmv_rec.chr_id := l_ctcv_rec_out_ins.dnz_chr_id;
                     OKC_CVM_PVT.update_contract_version(p_api_version    => l_api_version,
	  	                                         p_init_msg_list  => l_init_msg_list,
 	                                                 x_return_status  => l_return_status,
	                                                 x_msg_count      => l_msg_count,
 	                                                 x_msg_data       => l_msg_data,
  	                                                 p_cvmv_rec       => l_cvmv_rec,
                                                         x_cvmv_rec       => l_cvmv_out_rec);


                     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                       'Contract ID: ' || l_cvmv_rec.chr_id
                                       ||' Update contract version return status '
                                       || l_return_status );
                     END IF;
                     l_chrv_rec.id :=  l_ctcv_rec_out_ins.dnz_chr_id;
                     l_chrv_rec.last_update_date := sysdate;
                     OKC_CONTRACT_PUB.update_contract_header(p_api_version  => l_api_version,
				                                         p_init_msg_list => OKC_API.G_TRUE,
                                                             x_return_status => l_return_status,
	                                                        x_msg_count => l_msg_count,
	                                                        x_msg_data  => l_msg_data,
	                                                        p_restricted_update => OKC_API.G_TRUE,
	                                                        p_chrv_rec => l_chrv_rec,
	                                                        x_chrv_rec => l_chrv_out_rec);

                     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                         'Update contract header return status '
                                       || l_return_status );
                     END IF;
                     FND_MESSAGE.SET_NAME('OKS','OKS_NOTIFY_SALESREP');
		     FND_MESSAGE.SET_TOKEN(token => 'CONTRACTNUM',
		                           Value => l_ctcv_rec_out_ins.attribute2);
                     l_salesrep_msg := FND_MESSAGE.GET;
                     NOTIFY_SALESREP(to_number(l_ctcv_rec_out_ins.attribute1),
                                  l_ctcv_rec_out_ins.dnz_chr_id,
                                  l_ctcv_rec_out_ins.attribute2,
                                  NULL,
                                  l_salesrep_msg);


                 ELSE

                     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                                       'This contract could not create vendor contact : '
                                       || l_ctcv_rec_out_ins.attribute1 || ' '
                                       || l_ctcv_rec_out_ins.attribute2  );
                     END IF;
                   --Assemble Data for errorneous condition
                     NOTIFY_CONTRACT_ADMIN(l_ctcv_rec_out_ins.dnz_chr_id,
                                         NULL,
                                         NULL,
                                         GET_FND_MESSAGE );
                 END IF;
                 EXIT WHEN idx3 = l_ctcv_tbl_in.LAST;
                 idx3 := l_ctcv_tbl_in.NEXT(idx3);
             END LOOP;
         END IF;

          IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Start upadate and create contact process :  No of contacts : '
                            ||l_ctcv_tbl_in.count );
          END IF;

     END IF;--b_id.count > 0

     -- Now cleanup the temp tables for next steup of records.
     l_ctcv_tbl_in.delete;
     l_ctcv_tbl_in_del.delete;
     l_ctcv_tbl_in_upd.delete;

     DELETE FROM oks_k_res_temp;
     DELETE FROM oks_jtf_res_temp;

     IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Completed Processing *****');
     END IF;

     IF    GET_ALL_CONTRACTS_1%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_1%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_2%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_2%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_3%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_3%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_4%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_4%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_5%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_5%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_6%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_6%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_7%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_7%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_8%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_8%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_9%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_9%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_10%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_10%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_11%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_11%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_12%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_12%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_13%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_13%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_14%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_14%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_15%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_15%NOTFOUND;
     ELSIF GET_ALL_CONTRACTS_16%ISOPEN THEN
           EXIT WHEN GET_ALL_CONTRACTS_16%NOTFOUND;

     END IF;
  END LOOP;

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Out of Main Loop');
  END IF;

  IF  GET_ALL_CONTRACTS_1%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_1;
  ELSIF GET_ALL_CONTRACTS_2%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_2;
  ELSIF GET_ALL_CONTRACTS_3%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_3;
  ELSIF GET_ALL_CONTRACTS_4%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_4;
  ELSIF GET_ALL_CONTRACTS_5%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_5;
  ELSIF GET_ALL_CONTRACTS_6%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_6;
  ELSIF GET_ALL_CONTRACTS_7%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_7;
  ELSIF GET_ALL_CONTRACTS_8%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_8;
  ELSIF  GET_ALL_CONTRACTS_9%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_9;
  ELSIF GET_ALL_CONTRACTS_10%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_10;
  ELSIF GET_ALL_CONTRACTS_11%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_11;
  ELSIF GET_ALL_CONTRACTS_12%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_12;
  ELSIF GET_ALL_CONTRACTS_13%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_13;
  ELSIF GET_ALL_CONTRACTS_14%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_14;
  ELSIF GET_ALL_CONTRACTS_15%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_15;
  ELSIF GET_ALL_CONTRACTS_16%ISOPEN THEN
      CLOSE GET_ALL_CONTRACTS_16;
  END IF;

END IF; --CRO_CODE
END IF; --Use JTF
IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                  'Reassugn End Time ' ||
                  to_char(sysdate,'HH:MI:SS') );
END IF;
fnd_file.put_line(FND_FILE.LOG,'Program completed successfully ' || to_char(sysdate,'HH:MI:SS'));
EXCEPTION

      WHEN OKC_API.G_EXCEPTION_ERROR THEN
           fnd_file.put_line(FND_FILE.LOG,'Exception occured');
           IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Error occured : ' || get_fnd_message() );
          END IF;
          rollback;
          RAISE_APPLICATION_ERROR(-20001, 'Exception occured');
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR  THEN
           fnd_file.put_line(FND_FILE.LOG,'Exception occured');
           IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                            'Unexpected Error : ' || get_fnd_message() );
           END IF;
           rollback;
           RAISE_APPLICATION_ERROR(-20001, 'Exception occured');
      WHEN OTHERS THEN
           fnd_file.put_line(FND_FILE.LOG,'Exception occured');
           OKC_API.set_message(p_app_name => g_app_name,
                               p_msg_name => g_unexpected_error,
                               p_token1 => g_sqlcode_token,
                               p_token1_value => sqlcode,
                               p_token2 => g_sqlerrm_token,
                               p_token2_value => sqlerrm);

           IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT ||'.SUBMIT_CONTACT_CREATION',
                  'Other Exception occured ' || sqlerrm);
           END IF;
           rollback;
           RAISE_APPLICATION_ERROR(-20001, 'Exception occured: other exception');

END SUBMIT_CONTACT_CREATION;


END OKS_EXTWAR_UTIL_PUB;


/
