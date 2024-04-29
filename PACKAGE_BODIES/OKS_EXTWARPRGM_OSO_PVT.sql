--------------------------------------------------------
--  DDL for Package Body OKS_EXTWARPRGM_OSO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_EXTWARPRGM_OSO_PVT" AS
/* $Header: OKSRXRXB.pls 120.3 2005/08/10 03:41:36 hkamdar ship $ */



Procedure   Party_Role ( p_ChrId          IN Number,
					p_cleid          IN Number,
                         p_Rle_Code       IN Varchar2,
                         p_PartyId        IN Number,
                         p_Object_Code    IN Varchar2,
                         x_roleid        OUT NOCOPY Number,
                         x_msg_count     OUT NOCOPY Number,
                         x_msg_data      OUT NOCOPY Varchar2
                       )
Is

  l_api_version   CONSTANT NUMBER      := 1.0;
  l_init_msg_list	CONSTANT VARCHAR2(1) := 'F';
  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index                  VARCHAR2(240);

--Party Role
  l_cplv_tbl_in             		okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out            		okc_contract_party_pub.cplv_tbl_type;

  Cursor l_party_csr  Is            Select Id From OKC_K_PARTY_ROLES_V
                                    Where  dnz_chr_id = p_chrid
                                    And    cle_id Is Null
							 And    chr_id = p_chrid
                                    And rle_code = p_rle_code;

  Cursor l_lparty_csr  Is           Select Id From OKC_K_PARTY_ROLES_V
                                    Where  dnz_chr_id = p_chrid
                                    And    chr_id Is Null
							 And    cle_id = p_cleid
                                    And rle_code = p_rle_code;

  l_roleid                          Number;

Begin

    If p_cleid Is Null Then

       Open  l_party_csr;
       Fetch l_party_csr Into l_roleid;
       Close l_party_csr;

       If l_roleid Is Not Null Then
          x_roleid := l_roleid;
          Return;
       End If;

       l_cplv_tbl_in(1).chr_id                	    := p_chrid;

    Else

       Open  l_lparty_csr;
       Fetch l_lparty_csr Into l_roleid;
       Close l_lparty_csr;

       If l_roleid Is Not Null Then
          x_roleid := l_roleid;
          Return;
       End If;

	  l_cplv_tbl_in(1).cle_id                   := p_cleid;

    End If;

    l_cplv_tbl_in(1).sfwt_flag                      := 'N';

    l_cplv_tbl_in(1).rle_code       		    := p_rle_code;
    l_cplv_tbl_in(1).object1_id1                    := p_partyid;
    l_cplv_tbl_in(1).Object1_id2                    := '#';
    l_cplv_tbl_in(1).jtot_object1_code		    := p_object_code;
    l_cplv_tbl_in(1).dnz_chr_id			    := p_chrid;

    okc_contract_party_pub.create_k_party_role
    (
    	p_api_version					     => l_api_version,
    	p_init_msg_list					     => l_init_msg_list,
    	x_return_status					     => l_return_status,
    	x_msg_count						     => x_msg_count,
    	x_msg_data						     => x_msg_data,
    	p_cplv_tbl						     => l_cplv_tbl_in,
    	x_cplv_tbl						     => l_cplv_tbl_out
    );

    if l_return_status = 'S' then
    	 x_roleid := l_cplv_tbl_out(1).id;
    else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_rle_code || ' Party Role (HEADER)');
	 Raise G_EXCEPTION_HALT_VALIDATION;
    end if;

End;


Function Get_K_Hdr_Id
(
            P_Type             Varchar2
,		P_Object_ID  IN    NUMBER
,           P_EndDate    IN    Date

)
Return Number
Is

	   	Cursor l_kexists_csr (p_jtf_id VARCHAR2) is
					Select	Chr_id
					From		OKC_K_REL_OBJS
					Where		OBJECT1_ID1 = P_Object_id
					And         jtot_object1_code  = p_jtf_id;



	   	Cursor l_wexists_csr (p_jtf_id VARCHAR2) is
					Select	Chr_id
					From		OKC_K_REL_OBJS
					Where		OBJECT1_ID1 = P_Object_id
					And         jtot_object1_code  = p_jtf_id
                              And         rty_code = 'CONTRACTWARRANTYORDER';

            l_wchrid                Number;
		l_kchrid                Number;
		l_jtf_id			Varchar2(30);

            Cursor l_hdr_csr Is
                             Select Id Chr_Id
                             From   OKC_K_HEADERS_V
                             Where  Attribute1 = p_Object_Id
                             And    End_date   = p_EndDate ;

Begin

   If P_type = 'ORDER' Then

            l_jtf_id := G_JTF_ORDER_HDR;

		Open l_kexists_csr (l_jtf_id);
		Fetch l_kexists_csr into l_kchrid;

		If l_kexists_csr%Notfound then
			Close l_kexists_csr;
			Return (Null);
 		End If;

		Close l_kexists_csr;
		Return (l_kchrid);

   ElsIf P_Type = 'RENEW' Then
            Open  l_hdr_csr;
            Fetch l_hdr_csr Into l_kchrid;

		If l_hdr_csr%Notfound then
			Close l_hdr_csr;
			Return (Null);
 		End If;

            close l_hdr_csr;
		Return (l_kchrid);
   ElsIf P_Type = 'WARR' Then
            l_jtf_id := G_JTF_ORDER_HDR;

		Open  l_wexists_csr (l_jtf_id);
		Fetch l_wexists_csr into l_wchrid;

		If l_wexists_csr%Notfound then
			Close l_wexists_csr;
			Return (Null);
 		End If;

		Close   l_wexists_csr;
		Return (l_wchrid);
   End If;

End Get_K_Hdr_Id;



Function Get_K_Cle_Id (p_ChrId        Number
                    ,  p_InvServiceId Number
                    ,  p_StartDate    Date
                    ,  p_EndDate      Date )  Return Number Is

   Cursor l_Service_Csr  Is
                     Select KL.Id Cle_Id
                     From   OKC_K_LINES_V  KL
                           ,OKC_K_ITEMS_V  KI
                     Where  KL.dnz_chr_id  =  p_ChrId
                     And    KL.lse_id      In (14, 19)
                     And    KL.Id          =  KI.cle_Id
                     And    KI.Object1_Id1 =  p_InvServiceId
--                   And    KL.StartDate   >= p_StartDate
                     And    KL.End_Date    =  p_EndDate;


   l_cle_Id          Number;

Begin
   l_cle_id := Null;

   Open l_Service_Csr;
   Fetch l_Service_Csr Into l_cle_Id;
   Close l_Service_csr;

   Return (l_cle_id);

End Get_K_Cle_Id;

Function Priced_YN(P_LSE_ID IN NUMBER) RETURN VARCHAR2 IS
  Cursor C_PRICED_YN IS
  Select PRICED_YN
  From  okc_line_styles_B
  Where ID = P_LSE_ID;
  V_PRICED VARCHAR2(50) := 'N';
Begin
   For CUR_C_PRICED_YN IN C_PRICED_YN
   Loop
    V_PRICED := CUR_C_PRICED_YN.PRICED_YN;
    EXIT;
   End Loop;
   Return (V_PRICED);
End Priced_YN;


Function CHECK_RULE_Group_EXISTS
(
		p_chr_id IN NUMBER,
		p_cle_id IN NUMBER
) Return NUMBER
Is
            v_id NUMBER;
Begin
	If (p_chr_id IS NOT NULL) Then
		SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V WHERE Dnz_CHR_ID = p_chr_id And cle_id Is Null;
		If V_ID IS NULL Then
			return(NULL);
		Else
			return(V_ID);
		End If;
	End If;

	If (p_cle_id IS NOT NULL) Then
		SELECT ID INTO V_ID FROM OKC_RULE_GROUPS_V WHERE CLE_ID = p_cle_id;
		If V_ID IS NULL Then
			return(NULL);
		Else
			return(V_ID);
		End If;
	End If;

	Exception
	When OTHERS Then
		RETURN(NULL);

End CHECK_RULE_Group_EXISTS;


Procedure Create_Rule_Group
(
       p_rgpv_tbl       IN okc_rule_pub.rgpv_tbl_type
      ,x_rgpv_tbl      OUT NOCOPY okc_rule_pub.rgpv_tbl_type
      ,x_return_status OUT NOCOPY Varchar2
      ,x_msg_count     OUT NOCOPY Number
      ,x_msg_data      OUT NOCOPY Varchar2
)
Is
  l_rgpv_tbl_in            okc_rule_pub.rgpv_tbl_type;
  l_rgpv_tbl_out           okc_rule_pub.rgpv_tbl_type;

  l_api_version   CONSTANT NUMBER      := 1.0;
  l_init_msg_list	CONSTANT VARCHAR2(1) := 'F';
  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index                  VARCHAR2(240);

Begin

  x_return_status := l_return_status;

  l_rgpv_tbl_in := p_rgpv_tbl;

  okc_rule_pub.create_rule_group
  (
   	  p_api_version					=> l_api_version,
  	  p_init_msg_list					=> l_init_msg_list,
     	  x_return_status					=> l_return_status,
        x_msg_count					=> x_msg_count,
        x_msg_data					=> x_msg_data,
        p_rgpv_tbl					=> l_rgpv_tbl_in,
    	  x_rgpv_tbl					=> l_rgpv_tbl_out
  );

  If l_return_status = 'S'
  Then
  	x_rgpv_tbl := l_rgpv_tbl_out;
  Else
      x_return_status := l_return_status;
  End If;

Exception
When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End Create_Rule_Group;


Function Check_Rule_Exists
(
	p_rgp_id 	IN NUMBER,
	p_rule_type IN VARCHAR2
) 	Return NUMBER
Is
	v_id NUMBER;
Begin
	If p_rgp_id is null Then
		Return(null);
	Else
		Select ID Into V_ID From OKC_RULES_V
		Where  rgp_id = p_rgp_id
		And 	 Rule_information_category = p_rule_type;

		If v_id Is NULL Then
			return(null);
		Else
			return(V_ID);
		End If;
	End if;


Exception
  WHEN No_Data_Found Then
		     Return (null);

End Check_Rule_Exists;


Procedure create_rules
(
	p_rulv_tbl        IN  okc_rule_pub.rulv_tbl_type
      ,x_rulv_tbl      OUT NOCOPY okc_rule_pub.rulv_tbl_type
      ,x_return_status OUT NOCOPY Varchar2
      ,x_msg_count     OUT NOCOPY Number
      ,x_msg_data      OUT NOCOPY Varchar2
)
Is
  l_rulv_tbl_in            okc_rule_pub.rulv_tbl_type;
  l_rulv_tbl_out           okc_rule_pub.rulv_tbl_type;

  l_api_version   CONSTANT NUMBER     	:= 1.0;
  l_init_msg_list CONSTANT VARCHAR2(1) := 'F';
  l_return_status		  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_index                  NUMBER;
  l_module                 VARCHAR2(50) := 'TBL_RULE.CREATE_ROWS';
  l_debug                  BOOLEAN      := TRUE;

Begin

  x_return_status := l_return_status;

  l_rulv_tbl_in := p_rulv_tbl;

  okc_rule_pub.create_rule
  (
      p_api_version		     				=> l_api_version,
      p_init_msg_list						=> l_init_msg_list,
      x_return_status					     => l_return_status,
      x_msg_count							=> x_msg_count,
      x_msg_data							=> x_msg_data,
      p_rulv_tbl							=> l_rulv_tbl_in,
    	 x_rulv_tbl							=> l_rulv_tbl_out
   );

  If l_return_status = 'S'
  Then
  	x_rulv_tbl := l_rulv_tbl_out;
  Else
      x_return_status := l_return_status;
  End If;


Exception
When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End create_rules;

Procedure Check_Line_Effectivity
(
	p_cle_id	  IN NUMBER,
	p_srv_sdt	  IN DATE,
	p_srv_edt	  IN DATE,
	x_line_sdt    OUT NOCOPY DATE,
	x_line_edt    OUT NOCOPY DATE,
	x_status     OUT NOCOPY VarChar2
)
Is
	Cursor l_line_csr		Is
					Select Start_Date, End_Date From OKC_K_LINES_V
					Where  id = p_cle_id;

	l_line_csr_rec 		l_line_csr%ROWTYPE;

Begin

	Open l_line_csr;
	Fetch l_line_csr Into l_line_csr_rec;

	If l_line_csr%FOUND Then
		If p_srv_sdt >= l_line_csr_rec.Start_Date And p_srv_edt <= l_line_csr_rec.End_Date Then
			x_Status := 'N';
		Else
			If p_srv_sdt >= l_line_csr_rec.Start_Date Then
				x_line_sdt := l_line_csr_rec.Start_Date;
			Else
				x_line_sdt := p_srv_sdt;
			End If;

			If p_srv_edt >= l_line_csr_rec.End_Date Then
				x_line_edt := p_srv_edt;
			Else
				x_line_edt := l_line_csr_rec.End_Date;
			End If;
			x_Status := 'Y';

		End If;
	Else
		x_Status := 'E';
	End If;

End;

Procedure Update_Line_Dates
(
	p_cle_id	 IN Number,
	p_new_sdt	 IN Date,
	p_new_edt	 IN Date,
	p_warranty_flag  IN Varchar2,
	x_status    OUT NOCOPY VarChar2,
      x_msg_count OUT NOCOPY Number,
      x_msg_data  OUT NOCOPY Number
)
Is
	Cursor l_rulegroup_csr Is
				Select     	Id
				From	   	okc_rule_groups_v     rg
				Where   	rg.cle_id = p_cle_id;

--General
  	l_api_version		CONSTANT	NUMBER	:= 1.0;
  	l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  	l_return_status				VARCHAR2(1) := 'S';
  	l_index					VARCHAR2(2000);

--Contract Line
   	l_clev_tbl_in             		okc_contract_pub.clev_tbl_type;
  	l_clev_tbl_out             		okc_contract_pub.clev_tbl_type;

--Rule Related
  	l_rulv_tbl_in             		okc_rule_pub.rulv_tbl_type;
  	l_rulv_tbl_out            		okc_rule_pub.rulv_tbl_type;


	l_cleid					NUMBER;
	l_rgp_id					NUMBER;
	l_rule_id					NUMBER;

Begin

      x_status := OKC_API.G_RET_STS_SUCCESS;

--Contract Header Date Update

	l_clev_tbl_in(1).id		:= p_cle_id;
	l_clev_tbl_in(1).Start_Date	:= p_new_sdt;
	l_clev_tbl_in(1).End_Date	:= p_new_edt;

    	okc_contract_pub.update_contract_line
    	(
    		p_api_version						=> l_api_version,
    		p_init_msg_list						=> l_init_msg_list,
    		x_return_status						=> l_return_status,
    		x_msg_count							=> x_msg_count,
    		x_msg_data							=> x_msg_data,
    		p_clev_tbl							=> l_clev_tbl_in,
    		x_clev_tbl							=> l_clev_tbl_out
      );

	If l_return_status = 'S' then
          l_cleid := l_clev_tbl_out(1).id;
	Else
          x_status := 'E';
          Raise G_EXCEPTION_HALT_VALIDATION;
    	End if;

--Schedule Billing Update

  IF p_warranty_flag <> 'W' THEN

    Open l_rulegroup_csr;
    Fetch l_rulegroup_csr Into l_rgp_id;

    If l_rulegroup_csr%NOTFOUND Then
	 x_status := 'E';
	 Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    Close l_rulegroup_csr;

    l_rule_id     := Check_Rule_Exists(l_rgp_id, 'SBG');

    If l_rule_id Is Not NULL Then

      l_rulv_tbl_in(1).id	       	     := l_rule_id;
      l_rulv_tbl_in(1).rule_information4       := to_char(p_new_sdt,'YYYY/MM/DD HH24:MI:SS');
      l_rulv_tbl_in(1).rule_information3       := to_char(p_new_edt,'YYYY/MM/DD HH24:MI:SS');

  	okc_rule_pub.update_rule
  	(
      	p_api_version				=> l_api_version,
      	p_init_msg_list				=> l_init_msg_list,
     		x_return_status				=> l_return_status,
      	x_msg_count					=> x_msg_count,
      	x_msg_data					=> x_msg_data,
      	p_rulv_tbl					=> l_rulv_tbl_in,
		x_rulv_tbl					=> l_rulv_tbl_out
   	);

  	If l_return_status = 'S' Then
	       l_rule_id := l_rulv_tbl_out(1).id;
	Else
             x_status := 'E';
             Raise G_EXCEPTION_HALT_VALIDATION;
  	End If;
    Else
      x_status := 'E';
	Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

  END IF; -- warranty flag check;


Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		Null;
	When  Others Then
	      x_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
End;




Procedure Create_Obj_Rel
(
	p_K_id           IN Number
,	p_line_id        IN Number
,	p_orderhdrid     IN Number
,	p_orderlineid    IN Number
,     x_return_status OUT NOCOPY Varchar2
,     x_msg_count     OUT NOCOPY Number
,     x_msg_data      OUT NOCOPY Varchar2
,     x_crjv_tbl_out  OUT NOCOPY OKC_K_REL_OBJS_PUB.crjv_tbl_type
)
Is

 l_api_version   CONSTANT NUMBER       := 1.0;
 l_init_msg_list CONSTANT VARCHAR2(1)  := 'F';
 l_return_status          VARCHAR2(1)  := 'S';
 l_crjv_tbl_in            OKC_K_REL_OBJS_PUB.crjv_tbl_type;
 l_crjv_tbl_out           OKC_K_REL_OBJS_PUB.crjv_tbl_type;

Begin

x_return_status := l_return_status;

If p_orderhdrid Is Not Null Then

   l_crjv_tbl_in(1).chr_id := p_K_id;
   l_crjv_tbl_in(1).object1_id1 := p_orderhdrid;
   l_crjv_tbl_in(1).jtot_object1_code := 'OKX_ORDERHEAD';
   l_crjv_tbl_in(1).rty_code := 'CONTRACTSERVICESORDER';

   OKC_K_REL_OBJS_PUB.CREATE_ROW
   (
     P_API_VERSION    => l_api_version,
     P_INIT_MSG_LIST  => l_init_msg_list,
     X_RETURN_STATUS  => l_return_status,
     X_MSG_COUNT      => x_msg_count,
     X_MSG_DATA       => x_msg_data,
     P_CRJV_TBL       => l_crjv_tbl_in,
     X_CRJV_TBL       => l_crjv_tbl_out
   );

   If l_return_status = 'S' Then
      x_crjv_tbl_out  := l_crjv_tbl_out;
   Else
      x_return_status := l_return_status;
   End If;

ElsIf p_orderlineid Is Not Null Then

   l_crjv_tbl_in(1).cle_id := p_line_id;
   l_crjv_tbl_in(1).object1_id1 := p_orderlineid;
   l_crjv_tbl_in(1).jtot_object1_code := 'OKX_ORDERLINE';
   l_crjv_tbl_in(1).rty_code := 'CONTRACTSERVICESORDER';

   OKC_K_REL_OBJS_PUB.CREATE_ROW
   (
     P_API_VERSION    => l_api_version,
     P_INIT_MSG_LIST  => l_init_msg_list,
     X_RETURN_STATUS  => l_return_status,
     X_MSG_COUNT      => x_msg_count,
     X_MSG_DATA       => x_msg_data,
     P_CRJV_TBL       => l_crjv_tbl_in,
     X_CRJV_TBL       => l_crjv_tbl_out
   );

   If l_return_status = 'S' Then
      x_crjv_tbl_out  := l_crjv_tbl_out;
   Else
      x_return_status := l_return_status;
   End If;

End If;

Exception
When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
End;

Procedure Check_hdr_Effectivity
(
	p_chr_id	  IN NUMBER,
	p_srv_sdt	  IN DATE,
	p_srv_edt	  IN DATE,
	x_hdr_sdt    OUT NOCOPY DATE,
	x_hdr_edt    OUT NOCOPY DATE,
	x_org_id     OUT NOCOPY Number,
	x_status     OUT NOCOPY VarChar2
)
Is
	Cursor l_hdr_csr		Is
					Select Start_Date, End_Date ,
					Authoring_Org_Id From OKC_K_HEADERS_V
					Where  id = p_chr_id;

	l_hdr_csr_rec 		l_hdr_csr%ROWTYPE;

Begin

	Open l_hdr_csr;
	Fetch l_hdr_csr Into l_hdr_csr_rec;

	If l_hdr_csr%FOUND Then
	x_org_id := l_hdr_csr_rec.authoring_org_id;
		If p_srv_sdt >= l_hdr_csr_rec.Start_Date And p_srv_edt <= l_hdr_csr_rec.End_Date Then
			x_Status := 'N';
		Else
			If p_srv_sdt >= l_hdr_csr_rec.Start_Date Then
				x_hdr_sdt := l_hdr_csr_rec.Start_Date;
			Else
				x_hdr_sdt := p_srv_sdt;
			End If;

			If p_srv_edt >= l_hdr_csr_rec.End_Date Then
				x_hdr_edt := p_srv_edt;
			Else
				x_hdr_edt := l_hdr_csr_rec.End_Date;
			End If;
			x_Status := 'Y';

		End If;
	Else
		x_Status := 'E';
	End If;

End;

Procedure Update_Hdr_Dates
(
	p_chr_id	 IN Number,
	p_new_sdt	 IN Date,
	p_new_edt	 IN Date,
	x_status    OUT NOCOPY VarChar2,
      x_msg_count OUT NOCOPY Number,
      x_msg_data  OUT NOCOPY Number
)
Is
	Cursor l_timevalue_csr Is
				Select     	rule_information1
				From	   	okc_rules_v           rl
					,  	okc_rule_groups_v     rg
					,  	okc_k_headers_v       hd
				Where   	hd.id     = p_chr_id
				And     	rg.chr_id = hd.id
				And     	rl.rgp_id = rg.id
				And    	rl.rule_information_category = 'EFY';

	Cursor l_rulegroup_csr Is
				Select     	Id
				From	   	okc_rule_groups_v     rg
				Where   	rg.dnz_chr_id = p_chr_id
				And             rg.cle_id Is Null;


--General
  	l_api_version		CONSTANT	NUMBER	:= 1.0;
  	l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  	l_return_status				VARCHAR2(1) := 'S';
  	l_index					VARCHAR2(2000);

--Contract Header
  	l_chrv_tbl_in             		okc_contract_pub.chrv_tbl_type;
  	l_chrv_tbl_out            		okc_contract_pub.chrv_tbl_type;

--Rule Related
  	l_rulv_tbl_in             		okc_rule_pub.rulv_tbl_type;
  	l_rulv_tbl_out            		okc_rule_pub.rulv_tbl_type;


--Time Value Related
  	l_isev_ext_tbl_in         		okc_time_pub.isev_ext_tbl_type;
  	l_isev_ext_tbl_out        		okc_time_pub.isev_ext_tbl_type;

	l_chrid					NUMBER;
	l_timevalue_id				NUMBER;
	l_rgp_id					NUMBER;
	l_rule_id					NUMBER;

Begin

      x_status := OKC_API.G_RET_STS_SUCCESS;

--Contract Header Date Update

	l_chrv_tbl_in(1).id		:= p_chr_id;
	l_chrv_tbl_in(1).Start_Date	:= p_new_sdt;
	l_chrv_tbl_in(1).End_Date	:= p_new_edt;

    	okc_contract_pub.update_contract_header
    	(
    		p_api_version						=> l_api_version,
    		p_init_msg_list						=> l_init_msg_list,
    		x_return_status						=> l_return_status,
    		x_msg_count							=> x_msg_count,
    		x_msg_data							=> x_msg_data,
    		p_chrv_tbl							=> l_chrv_tbl_in,
    		x_chrv_tbl							=> l_chrv_tbl_out
      );

	If l_return_status = 'S' then
          l_chrid := l_chrv_tbl_out(1).id;
	Else
          x_status := 'E';
          Raise G_EXCEPTION_HALT_VALIDATION;
    	End if;

--Schedule Billing Update

    Open l_rulegroup_csr;
    Fetch l_rulegroup_csr Into l_rgp_id;

    If l_rulegroup_csr%NOTFOUND Then
	 x_status := 'E';
	 Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    Close l_rulegroup_csr;

    l_rule_id     := Check_Rule_Exists(l_rgp_id, 'SBG');

    If l_rule_id Is Not NULL Then

      l_rulv_tbl_in(1).id	       	     := l_rule_id;
      l_rulv_tbl_in(1).rule_information4       := to_char(p_new_sdt,'YYYY/MM/DD HH24:MI:SS');
      l_rulv_tbl_in(1).rule_information3       := to_char(p_new_edt,'YYYY/MM/DD HH24:MI:SS');

  	okc_rule_pub.update_rule
  	(
      	p_api_version				=> l_api_version,
      	p_init_msg_list				=> l_init_msg_list,
     		x_return_status				=> l_return_status,
      	x_msg_count					=> x_msg_count,
      	x_msg_data					=> x_msg_data,
      	p_rulv_tbl					=> l_rulv_tbl_in,
		x_rulv_tbl					=> l_rulv_tbl_out
   	);

  	If l_return_status = 'S' Then
	       l_rule_id := l_rulv_tbl_out(1).id;
	Else
             x_status := 'E';
             Raise G_EXCEPTION_HALT_VALIDATION;
  	End If;
    Else
      x_status := 'E';
	Raise G_EXCEPTION_HALT_VALIDATION;
    End If;


Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		Null;
	When  Others Then
	      x_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
End;


Procedure Clear_Rule_Table (X_rulv_tbl OUT NOCOPY okc_rule_pub.rulv_tbl_type)
Is
Begin

	x_rulv_tbl(1).id					:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).rgp_id				:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).object1_id1			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).object2_id1			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).object3_id1			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).object1_id2			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).object2_id2			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).object3_id2			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).jtot_object1_code		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).jtot_object2_code		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).jtot_object3_code		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).dnz_chr_id			:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).std_template_yn			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).warn_yn				:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).priority				:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).object_version_number		:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).created_by			:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).creation_date			:= OKC_API.G_MISS_DATE;
	x_rulv_tbl(1).last_updated_by			:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).last_update_date		:= OKC_API.G_MISS_DATE;
	x_rulv_tbl(1).last_update_login		:= OKC_API.G_MISS_NUM;
	x_rulv_tbl(1).attribute_category		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute1			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute2			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute3			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute4			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute5			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute6			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute7			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute8			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute9			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute10			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute11			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute12			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute13			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute14			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).attribute15			:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information_category	:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information1		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information2		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information3		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information4		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information5		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information6		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information7		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information8		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information9		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information10		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information11		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information12		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information13		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information14		:= OKC_API.G_MISS_CHAR;
	x_rulv_tbl(1).rule_information15		:= OKC_API.G_MISS_CHAR;
End;


FUNCTION GET_CONTRACT_NUMBER (p_hdrid IN Number) RETURN VARCHAR2
Is
          Cursor l_hdr_Csr is
					Select contract_number From OKC_K_HEADERS_V
					Where  id = p_hdrid;

          l_contract_number   VARCHAR2(120);

Begin
      Open  l_hdr_csr;
      Fetch l_hdr_csr Into l_contract_number;
      Close l_hdr_csr;

      Return l_contract_number;
End;


PROCEDURE LAUNCH_WORKFLOW (P_MSG IN VARCHAR2) Is


--Workflow attributes

	l_itemtype 	            Varchar2(40)  := 'OKSWARWF';
	l_itemkey	            Varchar2(240) := 'OKS-'||to_char(sysdate,'MMDDYYYYHH24MISS');
	l_process	            Varchar2(40)  := 'OKSWARPROC';
      l_notify                Varchar2(10)   := 'Y';
      l_receiver              Varchar2(30);

BEGIN

      l_notify   := Nvl(Fnd_Profile.Value ('OKS_INTEGRATION_NOTIFY_YN'),'NO');
      l_receiver := Nvl(Fnd_Profile.Value ('OKS_INTEGRATION_NOTIFY_TO'),'SYSADMIN');


      If upper(l_notify) = 'YES' Then

         l_itemkey := 'OKS-'||to_char(sysdate,'MMDDYYYYHH24MISS');

         WF_ENGINE.CreateProcess
	   (
		itemtype     => l_itemtype,
		itemkey	 => l_itemkey,
		process	 => l_process
	   );

	   WF_ENGINE.SetItemAttrText
	   (
		itemtype	=> l_itemtype,
		itemkey	=> l_itemkey,
		aname		=> 'MSG_TXT',
		avalue	=> p_msg
	   );

	   WF_ENGINE.SetItemAttrText
	   (
		itemtype	=> l_itemtype,
		itemkey	=> l_itemkey,
		aname		=> 'MSG_RECV',
		avalue	=> l_receiver
	   );


    	   WF_ENGINE.StartProcess
	   (
		itemtype	=> l_itemtype,
		itemkey	=> l_itemkey
	   );

     End If;

END;


Procedure Update_Cov_level
(
	p_covered_line_id	    IN Number,
	p_new_end_date	    IN Date,
	p_K_item_id		    IN Number,
	p_new_negotiated_amt  IN Number,
	p_new_cp_qty	    IN Number,
	x_return_status	   OUT NOCOPY Varchar2,
      x_msg_count          OUT NOCOPY Number,
      x_msg_data           OUT NOCOPY Varchar2
)
Is
	Cursor l_parent_line_Csr is
					Select cle_id From OKC_K_LINES_V
					Where  id = p_covered_line_id;

  	l_api_version		CONSTANT	NUMBER	:= 1.0;
  	l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  	l_return_status				VARCHAR2(1) := 'S';
  	l_index					VARCHAR2(2000);

--Contract Line Table
  	l_clev_tbl_in             		okc_contract_pub.clev_tbl_type;
  	l_clev_tbl_out            		okc_contract_pub.clev_tbl_type;

--Contract Item
      l_cimv_tbl_in          			okc_contract_item_pub.cimv_tbl_type;
  	l_cimv_tbl_out         			okc_contract_item_pub.cimv_tbl_type;


	l_parent_line_id				NUMBER;
	l_line_id					NUMBER;
	l_line_item_id				NUMBER;


Begin

	If p_new_end_date Is Not Null Then

	x_return_status			:= OKC_API.G_RET_STS_SUCCESS;
      l_clev_tbl_in(1).id		:= p_covered_line_id;
	l_clev_tbl_in(1).end_date	:= p_new_end_date;

  	okc_contract_pub.update_contract_line
      (
   	  p_api_version					=> l_api_version,
  	  p_init_msg_list					=> l_init_msg_list,
     	  x_return_status					=> l_return_status,
        x_msg_count					=> x_msg_count,
        x_msg_data					=> x_msg_data,
        p_clev_tbl					=> l_clev_tbl_in,
    	  x_clev_tbl					=> l_clev_tbl_out
      );
      FND_FILE.PUT_LINE (FND_FILE.LOG,'UPDATE COV LVL : update contract line   status: '||l_return_status );
      If l_return_status = 'S' then
    	   l_line_id := l_clev_tbl_out(1).id;
	   Open  l_parent_line_csr;
	   Fetch l_parent_line_csr Into l_parent_line_id;
	   Close l_parent_line_csr;

	   x_return_status		:= OKC_API.G_RET_STS_SUCCESS;
         l_clev_tbl_in(1).id		:= l_parent_line_id;
	   l_clev_tbl_in(1).end_date	:= p_new_end_date;

     	   okc_contract_pub.update_contract_line
         (
   	     p_api_version   => l_api_version,
  	     p_init_msg_list => l_init_msg_list,
     	     x_return_status => l_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_clev_tbl      => l_clev_tbl_in,
    	     x_clev_tbl      => l_clev_tbl_out
         );

         If l_return_status = 'S' then
    	     l_line_id := l_clev_tbl_out(1).id;
         Else
	     Raise G_EXCEPTION_HALT_VALIDATION;
         End if;
      Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract Line Update(UPDATE SUB LINE)');
	   Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

    End If;

    If p_new_negotiated_amt Is Not Null Then

	x_return_status				:= OKC_API.G_RET_STS_SUCCESS;
      l_clev_tbl_in(1).id			:= p_covered_line_id;
	l_clev_tbl_in(1).price_negotiated   := p_new_negotiated_amt;

  	okc_contract_pub.update_contract_line
      (
   	  p_api_version					=> l_api_version,
  	  p_init_msg_list					=> l_init_msg_list,
     	  x_return_status					=> l_return_status,
        x_msg_count					=> x_msg_count,
        x_msg_data					=> x_msg_data,
        p_clev_tbl					=> l_clev_tbl_in,
    	  x_clev_tbl					=> l_clev_tbl_out
      );

      If l_return_status = 'S' then
    	   l_line_id := l_clev_tbl_out(1).id;
      Else
         Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

	End If;

	If p_new_cp_qty Is Not Null Then

      l_cimv_tbl_in(1).id	  		:= p_k_item_id;
      l_cimv_tbl_in(1).number_of_items	:= p_new_cp_qty;

    	okc_contract_item_pub.update_contract_item
      (
    		p_api_version					=> l_api_version,
    		p_init_msg_list					=> l_init_msg_list,
    		x_return_status					=> l_return_status,
    		x_msg_count						=> x_msg_count,
    		x_msg_data						=> x_msg_data,
    		p_cimv_tbl						=> l_cimv_tbl_in,
    		x_cimv_tbl						=> l_cimv_tbl_out
      );
FND_FILE.PUT_LINE (FND_FILE.LOG,'UPDATE COV LVL : update contract item   status: '||l_return_status );
    	If l_return_status = 'S' then
    	   l_line_item_id := l_cimv_tbl_out(1).id;
    	Else
	   Raise G_EXCEPTION_HALT_VALIDATION;
    	End if;

    End If;

Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
		Null;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
End;



PROCEDURE Create_K_Hdr
(
					 p_k_header_rec	  IN   K_HEADER_REC_TYPE
,                              p_Contact_tbl      IN   Contact_Tbl
,					 x_chr_id		  OUT  NOCOPY Number
,					 x_return_status	  OUT  NOCOPY Varchar2
,                              x_msg_count        OUT  NOCOPY Number
,                              x_msg_data         OUT  NOCOPY Varchar2
)
IS


  Cursor l_thirdparty_csr (p_id Number)
                               Is
                                    Select Party_Id From OKX_CUST_SITE_USES_V
                                    Where  ID1 = p_id;

  Cursor l_cust_csr (p_contactid Number)
                               Is
                                    Select Party_Id From OKX_CUST_CONTACTS_V
                                    Where  Id1 = p_contactid And id2 = '#';

  Cursor l_ra_hcontacts_cur (p_contact_id number) Is
                        Select hzr.object_id
                                --, subject_id
                                , hzr.party_id
                        --NPALEPU
                        --18-JUN-2005,08-AUG-2005
                        --TCA Project
                        --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts with OKS_RA_HCONTACTS_V
                        --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                        /* From
                        ra_hcontacts rah,
                        hz_party_relationships hzr
                        Where  rah.contact_id  = p_contact_id
                        and    rah.party_relationship_id = hzr.party_relationship_id;*/
                        From
                        OKS_RA_HCONTACTS_V rah,
                        hz_relationships hzr
                        Where  rah.contact_id  = p_contact_id
                        and    rah.party_relationship_id = hzr.relationship_id
                        AND hzr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                        AND hzr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
                        AND hzr.DIRECTIONAL_FLAG = 'F';
                        --END NPALEPU


  l_rah_party_id                    NUMBER;
  l_rah_hdr_object1_id1             NUMBER;

  l_thirdparty_id                   NUMBER;
  l_thirdparty_role                 VARCHAR2(30);

  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  l_return_status				VARCHAR2(1) := 'S';
  l_index					VARCHAR2(2000);

  i                                 Number;
--Contract Header
  l_chrv_tbl_in             		okc_contract_pub.chrv_tbl_type;
  l_chrv_tbl_out            		okc_contract_pub.chrv_tbl_type;

--Contract Groupings
  l_cgcv_tbl_in                     okc_contract_group_pub.cgcv_tbl_type;
  l_cgcv_tbl_out                    okc_contract_group_pub.cgcv_tbl_type;

--Contacts
  l_ctcv_tbl_in             		okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out            		okc_contract_party_pub.ctcv_tbl_type;

--Agreements/Governance

  l_gvev_tbl_in             		okc_contract_pub.gvev_tbl_type;
  l_gvev_tbl_out            		okc_contract_pub.gvev_tbl_type;

--Rule Related

  l_rgpv_tbl_in            		okc_rule_pub.rgpv_tbl_type;
  l_rgpv_tbl_out            		okc_rule_pub.rgpv_tbl_type;

  l_rulv_tbl_in             		okc_rule_pub.rulv_tbl_type;
  l_rulv_tbl_out            		okc_rule_pub.rulv_tbl_type;

--Time Value Related
  l_isev_ext_tbl_in         		okc_time_pub.isev_ext_tbl_type;
  l_isev_ext_tbl_out        		okc_time_pub.isev_ext_tbl_type;

--Approval WorkFlow
  l_cpsv_tbl_in                     okc_contract_pub.cpsv_tbl_type;
  l_cpsv_tbl_out                    okc_contract_pub.cpsv_tbl_type;

--REL OBJS
  l_crjv_tbl_out                    okc_k_rel_objs_pub.crjv_tbl_type;


--Return IDs

  l_chrid					NUMBER;
  l_partyid					NUMBER;
  l_partyid_v				NUMBER;
  l_partyid_t				NUMBER;
  l_add2partyid                     NUMBER;
  l_rule_group_id		    		NUMBER;
  l_rule_id			    		NUMBER;
  l_govern_id				NUMBER;
  l_time_value_id           		NUMBER;
  l_contact_id				NUMBER;
  l_grpid                           NUMBER;
  l_pdfid                           NUMBER;
  l_ctrgrp                          NUMBER;

  l_cust_partyid                    NUMBER;
  l_findparty_id                    NUMBER;

  l_hdr_contactid                   NUMBER;

BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- MERGE TYPE ' || p_k_header_rec.merge_type );
    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- MERGE   ID ' || p_k_header_rec.merge_object_id);


    If p_k_header_rec.merge_type = 'NEW' Then
       l_chrid := Null;
    ElsIf p_k_header_rec.merge_type = 'LTC' Then
       l_chrid := p_k_header_rec.merge_object_id;
    ElsIf p_k_header_rec.merge_type Is Not Null Then
       l_chrid := GET_K_HDR_ID (
                                    p_type        => p_k_header_rec.merge_type
                                   ,p_object_id   => p_k_header_rec.merge_object_id
                                   ,p_enddate     => p_k_header_rec.end_date
                                );
    End If;


    If l_chrid Is Not Null Then
          FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- CHR ID IS NULL ');
          x_chr_id := l_chrid;
          l_return_status := OKC_API.G_RET_STS_SUCCESS;
	    Raise G_EXCEPTION_HALT_VALIDATION;
    End If;

--Contract Header Routine

    If Nvl(p_k_header_rec.sts_code,'ENTERED') = 'ACTIVE' Then
       l_chrv_tbl_in(1).date_signed			    := p_k_header_rec.start_date;
       l_chrv_tbl_in(1).date_approved               := p_k_header_rec.start_date;
    Else
       l_chrv_tbl_in(1).date_signed			    := Null;
       l_chrv_tbl_in(1).date_approved               := Null;
    End If;

    If p_k_header_rec.cust_po_number is not null then
             l_chrv_tbl_in(1).cust_po_number_req_yn := 'Y';
    Else
             l_chrv_tbl_in(1).cust_po_number_req_yn := 'N';
    End If;


    l_chrv_tbl_in(1).sfwt_flag                      := 'N';
    l_chrv_tbl_in(1).contract_number                := p_k_header_rec.contract_number;
    l_chrv_tbl_in(1).sts_code                       := p_k_header_rec.sts_code;
    l_chrv_tbl_in(1).scs_code                       := 'WARRANTY';
    l_chrv_tbl_in(1).authoring_org_id               := p_k_header_rec.authoring_org_id;
    l_chrv_tbl_in(1).inv_organization_id            := okc_context.get_okc_organization_id;
    l_chrv_tbl_in(1).pre_pay_req_yn                 := 'N';
    l_chrv_tbl_in(1).cust_po_number                 := p_k_header_rec.cust_po_number;
    l_chrv_tbl_in(1).qcl_id                         := OKC_API.G_MISS_NUM;
    l_chrv_tbl_in(1).short_description              := Nvl(p_k_header_rec.short_description,'Warranty/Extended Warranty');
    l_chrv_tbl_in(1).template_yn                    := 'N';
    l_chrv_tbl_in(1).start_date                     := p_k_header_rec.start_date;
    l_chrv_tbl_in(1).end_date                       := p_k_header_rec.end_date;
    l_chrv_tbl_in(1).chr_type                       := OKC_API.G_MISS_CHAR;
    l_chrv_tbl_in(1).archived_yn                    := 'N';
    l_chrv_tbl_in(1).deleted_yn                     := 'N';
    l_chrv_tbl_in(1).created_by                     := OKC_API.G_MISS_NUM;
    l_chrv_tbl_in(1).creation_date			    := OKC_API.G_MISS_DATE;
    l_chrv_tbl_in(1).currency_code			    := p_k_header_rec.currency;
    l_chrv_tbl_in(1).buy_or_sell			    := 'S';
    l_chrv_tbl_in(1).issue_or_receive               := 'I';
    l_chrv_tbl_in(1).Attribute1                     := p_k_header_rec.attribute1;
    l_chrv_tbl_in(1).Attribute2                     := p_k_header_rec.attribute2;
    l_chrv_tbl_in(1).Attribute3                     := p_k_header_rec.attribute3;
    l_chrv_tbl_in(1).Attribute4                     := p_k_header_rec.attribute4;
    l_chrv_tbl_in(1).Attribute5                     := p_k_header_rec.attribute5;
    l_chrv_tbl_in(1).Attribute6                     := p_k_header_rec.attribute6;
    l_chrv_tbl_in(1).Attribute7                     := p_k_header_rec.attribute7;
    l_chrv_tbl_in(1).Attribute8                     := p_k_header_rec.attribute8;
    l_chrv_tbl_in(1).Attribute9                     := p_k_header_rec.attribute9;
    l_chrv_tbl_in(1).Attribute10                    := p_k_header_rec.attribute10;
    l_chrv_tbl_in(1).Attribute11                    := p_k_header_rec.attribute11;
    l_chrv_tbl_in(1).Attribute12                    := p_k_header_rec.attribute12;
    l_chrv_tbl_in(1).Attribute13                    := p_k_header_rec.attribute13;
    l_chrv_tbl_in(1).Attribute14                    := p_k_header_rec.attribute14;
    l_chrv_tbl_in(1).Attribute15                    := p_k_header_rec.attribute15;

    If p_k_header_rec.merge_type = 'RENEW' Then
       l_chrv_tbl_in(1).Attribute1 := p_k_header_rec.merge_object_id;
    End If;

    okc_contract_pub.create_contract_header
    (
    	p_api_version						=> l_api_version,
    	p_init_msg_list						=> l_init_msg_list,
    	x_return_status						=> l_return_status,
    	x_msg_count							=> x_msg_count,
    	x_msg_data							=> x_msg_data,
    	p_chrv_tbl							=> l_chrv_tbl_in,
    	x_chrv_tbl							=> l_chrv_tbl_out
    );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- HDR STATUS ' || l_return_status);

    If l_return_status = 'S' then
    	 l_chrid := l_chrv_tbl_out(1).id;
    Else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'HEADER (HEADER)');
	 Raise G_EXCEPTION_HALT_VALIDATION;
    end if;


--Party Role Routine ('VENDOR')

    Party_Role (         p_ChrId          => l_chrid,
					p_cleId          => Null,
                         p_Rle_Code       => 'VENDOR',
                         p_PartyId        => p_k_header_rec.authoring_org_id,
                         p_Object_Code    => G_JTF_PARTY_VENDOR,
                         x_roleid         => l_partyid_v,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data
               );

    FND_FILE.PUT_LINE (FND_FILE.LOG,' VENDOR ROLE CREATION :- CPL ID ' || l_partyid_v);

--Party Role Routine ('CUSTOMER')

    Party_Role (         p_ChrId          => l_chrid,
					p_cleId          => Null,
                         p_Rle_Code       => 'CUSTOMER',
                         p_PartyId        => p_k_header_rec.party_id,
                         p_Object_Code    => G_JTF_PARTY,
                         x_roleid         => l_partyid,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data
               );

    FND_FILE.PUT_LINE (FND_FILE.LOG,' CUSTOMER ROLE CREATION :- CPL ID ' || l_partyid);


    Open  l_thirdparty_csr (p_k_header_rec.bill_to_id);
    Fetch l_thirdparty_csr Into l_thirdparty_id;
    Close l_thirdparty_csr;

    If l_thirdparty_Id Is Not Null Then
       If Not l_thirdparty_Id = p_k_header_rec.party_Id Then
--Party Role Routine ('THIRD_PARTY')
          l_thirdparty_role := Nvl(p_k_header_rec.third_party_role, 'THIRD_PARTY');

          Party_Role (   p_ChrId          => l_chrid,
					p_cleId          => Null,
                         p_Rle_Code       => l_thirdparty_role,
                         p_PartyId        => l_thirdparty_id,
                         p_Object_Code    => G_JTF_PARTY,
                         x_roleid         => l_partyid_t,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data
                      );

          FND_FILE.PUT_LINE (FND_FILE.LOG,' THIRD PARTY ROLE CREATION :- CPL ID ' || l_partyid_t);

       End If;
    End If;

    If p_contact_tbl.count > 0 Then

    i := p_Contact_Tbl.First;

    Loop

        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- PARTY ROLE ' ||p_Contact_tbl (i).party_role);
        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- CONTACT ID ' ||p_Contact_tbl (i).contact_id );


        If    p_Contact_tbl (i).party_role = 'VENDOR' And l_partyid_v Is Not Null Then
              l_add2partyid     := l_partyid_v;
              l_hdr_contactid   := p_Contact_tbl (i).contact_id;
        Else

              Open  l_ra_hcontacts_cur (p_Contact_tbl (i).contact_id);
              fetch l_ra_hcontacts_cur into l_rah_party_id, l_hdr_contactid;
              close l_ra_hcontacts_cur;

/*
Ramesh commented this portion due to TCA change

              Open  l_cust_csr (p_Contact_tbl (i).contact_id);
              Fetch l_cust_csr Into l_findparty_id;
              Close l_cust_csr;
*/
--		    if l_findparty_id = l_thirdparty_id Then

                FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- THIRDP  ID ' ||l_thirdparty_id);
                FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- CUSTMR  ID ' ||p_k_header_rec.party_id);
                FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- ORG CTC ID ' ||p_Contact_tbl (i).contact_id );
                FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- RAH PTY ID ' ||l_rah_party_id );
                FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- RAH CTC ID ' ||l_hdr_contactid);

		    if l_rah_party_id = l_thirdparty_id And l_partyid_t Is Not Null Then
                 l_add2partyid     := l_partyid_t;
		    else
                 l_add2partyid     := l_partyid;
		    end if;

        End If;

        If l_add2partyid Is Null Then
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_Contact_tbl (i).contact_role
                              || ' Contact (HEADER) Missing Role Id ' || p_Contact_tbl (i).contact_object_code);
          Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- CPL ID ' || l_add2partyid);
        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- CRO CD ' || p_Contact_tbl (i).contact_role);
        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- CTC CD ' || l_hdr_contactid);
        FND_FILE.PUT_LINE (FND_FILE.LOG,' CONTACT CREATION :- JTO CD ' || p_Contact_tbl (i).contact_object_code);



        l_ctcv_tbl_in(1).cpl_id           := l_add2partyid;
        l_ctcv_tbl_in(1).dnz_chr_id       := l_chrid;
        l_ctcv_tbl_in(1).cro_code         := p_Contact_tbl (i).contact_role;
        l_ctcv_tbl_in(1).object1_id1      := l_hdr_contactid;
        l_ctcv_tbl_in(1).object1_id2      := '#';
        l_ctcv_tbl_in(1).jtot_object1_code:= p_Contact_tbl (i).contact_object_code;

        okc_contract_party_pub.create_contact
        (
    	    p_api_version					      => l_api_version,
    	    p_init_msg_list					=> l_init_msg_list,
    	    x_return_status					=> l_return_status,
    	    x_msg_count						=> x_msg_count,
    	    x_msg_data						=> x_msg_data,
    	    p_ctcv_tbl						=> l_ctcv_tbl_in,
    	    x_ctcv_tbl						=> l_ctcv_tbl_out
        );

        If l_return_status = 'S' then
    	     l_contact_id := l_ctcv_tbl_out(1).id;
        Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_Contact_tbl (i).contact_role
                                             || ' Contact (HEADER) ' || p_Contact_tbl (i).contact_object_code);
	     Raise G_EXCEPTION_HALT_VALIDATION;
        End if;

        Exit When i = p_Contact_Tbl.Last;

        i := p_Contact_Tbl.Next(i);

    End Loop;

    End If;


--Grouping Routine

    l_ctrgrp                                         := Nvl(p_k_header_rec.chr_group, Nvl(Fnd_Profile.Value ('OKS_WARR_CONTRACT_GROUP'),2));
    l_cgcv_tbl_in(1).cgp_parent_id                   := l_ctrgrp;
    l_cgcv_tbl_in(1).included_chr_id                 := l_chrid;
    l_cgcv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
    l_cgcv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
    l_cgcv_tbl_in(1).creation_date                   := OKC_API.G_MISS_DATE;
    l_cgcv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
    l_cgcv_tbl_in(1).last_update_date                := OKC_API.G_MISS_DATE;
    l_cgcv_tbl_in(1).last_update_login               := OKC_API.G_MISS_NUM;
    l_cgcv_tbl_in(1).included_cgp_id                 := NULL;

    okc_contract_group_pub.create_contract_grpngs
    (
      p_api_version       => l_api_version,
      p_init_msg_list     => l_init_msg_list,
      x_return_status     => l_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_cgcv_tbl          => l_cgcv_tbl_in,
      x_cgcv_tbl          => l_cgcv_tbl_out
    );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- GROUPING STATUS ' || l_return_status);

    If l_return_status = 'S' then
    	 l_grpid := l_cgcv_tbl_out(1).id;
    Else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract Group (HEADER)');
	 Raise G_EXCEPTION_HALT_VALIDATION;
    end if;


    If p_k_header_rec.pdf_id Is Not Null Then

    l_cpsv_tbl_in(1).pdf_id                          := p_k_header_rec.pdf_id;
    l_cpsv_tbl_in(1).CHR_ID                          := l_chrid;
    l_cpsv_tbl_in(1).USER_ID                         := FND_global.user_id;
    l_cpsv_tbl_in(1).IN_PROCESS_YN                   := OKC_API.G_MISS_CHAR;
    l_cpsv_tbl_in(1).object_version_number           := OKC_API.G_MISS_NUM;
    l_cpsv_tbl_in(1).created_by                      := OKC_API.G_MISS_NUM;
    l_cpsv_tbl_in(1).creation_date                   := OKC_API.G_MISS_DATE;
    l_cpsv_tbl_in(1).last_updated_by                 := OKC_API.G_MISS_NUM;
    l_cpsv_tbl_in(1).last_update_date                := OKC_API.G_MISS_DATE;
    l_cpsv_tbl_in(1).last_update_login               := OKC_API.G_MISS_NUM;

    okc_contract_pub.create_contract_process
    (
    	p_api_version						=> l_api_version,
    	p_init_msg_list				       	=> l_init_msg_list,
    	x_return_status					      => l_return_status,
    	x_msg_count							=> x_msg_count,
    	x_msg_data							=> x_msg_data,
    	p_cpsv_tbl							=> l_cpsv_tbl_in,
    	x_cpsv_tbl							=> l_cpsv_tbl_out
    );


    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- PROCESS DEF STATUS ' || l_return_status);

    If l_return_status = 'S' then
    	 l_pdfid := l_cpsv_tbl_out(1).id;
    Else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract WorkFlow (HEADER)');
	 Raise G_EXCEPTION_HALT_VALIDATION;
    end if;



    End If;


--Rule Group Routine

    l_rule_group_id	:= Check_Rule_Group_Exists(l_chrid,NULL);

    If l_rule_group_id Is NULL Then

		     	l_rgpv_tbl_in(1).chr_id     := l_chrid;
		    	l_rgpv_tbl_in(1).sfwt_flag  := 'N';
    		      l_rgpv_tbl_in(1).rgd_code   := G_RULE_GROUP_CODE;
			l_rgpv_tbl_in(1).dnz_chr_id := l_chrid;
                  l_rgpv_tbl_in(1).rgp_type   := 'KRG';

                 	create_rule_group
                  (
				p_rgpv_tbl      => l_rgpv_tbl_in,
    	                  x_rgpv_tbl      => l_rgpv_tbl_out,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data
                  );

                  FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- RULE GROUP STATUS '||l_return_status);


                  If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  			   l_rule_group_id := l_rgpv_tbl_out(1).id;
                  Else
                     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Rule Group (HEADER)');
                     Raise G_EXCEPTION_HALT_VALIDATION;
                  End If;
    End If;

    if p_k_header_rec.tax_exemption_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'TAX');

    If l_rule_id Is NULL Then

	      l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
  		l_rulv_tbl_in(1).rule_information_category := 'TAX';
  		l_rulv_tbl_in(1).object1_id1	  		 := p_k_header_rec.tax_exemption_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).JTOT_OBJECT1_CODE		 := G_JTF_TAXEXEMP;
  		l_rulv_tbl_in(1).object2_id1	  		 := 'TAX_CONTROL_FLAG';
  		l_rulv_tbl_in(1).object2_id2			 := p_k_header_rec.tax_status_flag;
  		l_rulv_tbl_in(1).JTOT_OBJECT2_CODE		 := G_JTF_TAXCTRL;
     		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- TAX RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'TAX EXEMPTION (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;




    if p_k_header_rec.price_list_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'PRE');

    If l_rule_id Is NULL Then

	      l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
  		l_rulv_tbl_in(1).rule_information_category := 'PRE';
  		l_rulv_tbl_in(1).object1_id1	  		 := p_k_header_rec.price_list_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).JTOT_OBJECT1_CODE		 := G_JTF_PRICE;
     		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- PRE RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRICE LIST (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;


    if p_k_header_rec.payment_term_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'PTR');

    If l_rule_id Is NULL Then

	      l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
  		l_rulv_tbl_in(1).rule_information_category := 'PTR';
  		l_rulv_tbl_in(1).object1_id1	  		 := p_k_header_rec.payment_term_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).JTOT_OBJECT1_CODE		 := G_JTF_PAYMENT_TERM;
     		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );
            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- PTR RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PAYMENT TERM (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;


    if p_k_header_rec.cvn_type Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'CVN');

    If l_rule_id Is NULL Then

	      l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
  		l_rulv_tbl_in(1).rule_information_category := 'CVN';
  		l_rulv_tbl_in(1).object1_id1	  		 := p_k_header_rec.cvn_type;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).JTOT_OBJECT1_CODE		 := G_JTF_CONV_TYPE;
     		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;
     		l_rulv_tbl_in(1).rule_information1		 := p_k_header_rec.cvn_rate;
     		l_rulv_tbl_in(1).rule_information2		 := p_k_header_rec.cvn_date;
     		l_rulv_tbl_in(1).rule_information3		 := p_k_header_rec.cvn_euro_rate;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- CVN RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CONVERSION TYPE (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;

--Schedule Billing Routine

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'SBG');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		    l_rulv_tbl_in(1).rule_information_category := 'SBG';
        	l_rulv_tbl_in(1).rule_information1         := 1;
   	    	l_rulv_tbl_in(1).rule_information2         := p_k_header_rec.Billing_freq;
            l_rulv_tbl_in(1).rule_information3         := p_k_header_rec.first_billupto_date;
            l_rulv_tbl_in(1).rule_information4         := p_k_header_rec.first_billon_date;

    		l_rulv_tbl_in(1).rule_information5         := 1;
    		l_rulv_tbl_in(1).rule_information6         := p_k_header_rec.Billing_freq;
    		l_rulv_tbl_in(1).rule_information7         := p_k_header_rec.offset_duration;
    		l_rulv_tbl_in(1).rule_information8         := 'DAY';
    		l_rulv_tbl_in(1).rule_information9         := 'N';

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );


            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- SBG RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Schedule Billing Rule (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;



--Bill To Routine

    If p_k_header_rec.bill_to_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'BTO');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'BTO';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_header_rec.bill_to_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_BILLTO;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- BTO RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BillTo Id (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


    End If;

--Ship To Routine

    If p_k_header_rec.ship_to_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'STO');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'STO';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_header_rec.ship_to_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_SHIPTO;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- STO RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ShipTo Id (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


    End If;

    If p_k_header_rec.agreement_id Is Not Null Then

--Agreement ID Routine

    l_gvev_tbl_in(1).chr_id                      := l_chrid;
    l_gvev_tbl_in(1).isa_agreement_id            := p_k_header_rec.agreement_id;
    l_gvev_tbl_in(1).copied_only_yn			 := 'Y';
    l_gvev_tbl_in(1).dnz_chr_id			 := l_chrid;

    okc_contract_pub.create_governance
    (
    	p_api_version	=> l_api_version,
    	p_init_msg_list	=> l_init_msg_list,
    	x_return_status	=> l_return_status,
    	x_msg_count		=> x_msg_count,
    	x_msg_data		=> x_msg_data,
    	p_gvev_tbl		=> l_gvev_tbl_in,
    	x_gvev_tbl		=> l_gvev_tbl_out
    );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- AGREEMENT RULE STATUS ' || l_return_Status);


    If l_return_status = 'S' then
    	 l_govern_id := l_gvev_tbl_out(1).id;
    Else
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Agreement Id (HEADER)');
	 Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    End If;

--Accounting Rule ID  Routine

    If p_k_header_rec.accounting_rule_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'ARL');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'ARL';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_header_rec.accounting_rule_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_ARL;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- ARL RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Accounting Id (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;
    End If;

    End If;

--Invoice Rule ID  Routine

    If p_k_header_rec.invoice_rule_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRE');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'IRE';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_header_rec.invoice_rule_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_IRE;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );


            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- IRE RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Invoice Id (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;
    End If;


--Renewal Type Routine

    If p_k_header_rec.renewal_type Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'REN');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'REN';
  		l_rulv_tbl_in(1).rule_information1      	 := p_k_header_rec.renewal_type;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- REN RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal Type (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;


--Renewal Pricing Type

    If p_k_header_rec.renewal_pricing_type Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'RPT');

    If l_rule_id Is NULL Then

            If p_k_header_rec.renewal_pricing_type = 'PCT' Then
               l_rulv_tbl_in(1).rule_information2  := p_k_header_rec.renewal_markup;
            Else
               l_rulv_tbl_in(1).rule_information2  := Null;
            End If;

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'RPT';
  		l_rulv_tbl_in(1).object1_id1	  		 := p_k_header_rec.renewal_price_list_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).JTOT_OBJECT1_CODE		 := G_JTF_PRICE;
            l_rulv_tbl_in(1).rule_information1         := p_k_header_rec.renewal_pricing_type;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- RPT RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal Pricing  (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;
    End If;

--Renewal PO Required

    If p_k_header_rec.renewal_po Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'RPO');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'RPO';
  		l_rulv_tbl_in(1).rule_information1      	 := p_k_header_rec.renewal_po;
		l_rulv_tbl_in(1).dnz_chr_id			 := l_chrid;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- RPO RULE STATUS ' || l_return_Status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Renewal PO (HEADER)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;
    If  p_k_header_rec.order_hdr_id Is Not Null Then
    Create_Obj_Rel
    (
	p_K_id		=> l_chrid,
	p_line_id		=> Null,
	p_orderhdrid 	=> p_k_header_rec.order_hdr_id,
	p_orderlineid 	=> Null,
      x_return_status   => l_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_crjv_tbl_out    => l_crjv_tbl_out
     );
    End If;
     FND_FILE.PUT_LINE (FND_FILE.LOG,'K HDR CREATION :- OBJ RULE STATUS ' || l_return_Status);


     If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Header Id (HEADER)');
        Raise G_EXCEPTION_HALT_VALIDATION;
     End If;


     x_chr_id := l_chrid;

Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

END Create_K_Hdr;


Procedure Create_OSO_K_Service_Lines
(
	p_k_line_rec			IN	K_line_Service_Rec_type
,    p_Contact_tbl      IN   Contact_Tbl
,    p_salescredit_tbl_in          IN    SalesCredit_Tbl
,	x_service_line_id	     	     OUT	NOCOPY Number
,	x_return_status		     OUT	NOCOPY Varchar2
,    x_msg_count                  OUT    NOCOPY Number
,    x_msg_data                   OUT    NOCOPY Varchar2
)
Is

  	l_api_version		               CONSTANT	NUMBER	:= 1.0;
  	l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  	l_return_status				VARCHAR2(1) := 'S';
  	l_index					     VARCHAR2(2000);

	l_ctcv_tbl_in             		okc_contract_party_pub.ctcv_tbl_type;
     l_ctcv_tbl_out            		okc_contract_party_pub.ctcv_tbl_type;



     Cursor l_mtl_csr(p_inventory_id Number, p_organization_id Number) Is
                  Select  MTL.SERVICE_ITEM_FLAG
                         ,MTL.USAGE_ITEM_FLAG
                  From    OKX_SYSTEM_ITEMS_V MTL
                  Where   MTL.id1   = p_Inventory_id
                  And     MTL.Organization_id = p_organization_id;

     l_mtl_rec     l_mtl_csr%rowtype;

	Cursor l_ctr_csr (p_id Number) Is
								Select Counter_Group_id
								From   OKX_CTR_ASSOCIATIONS_V
								Where  Source_Object_Id = p_id;

     Cursor l_billto_csr (p_billto Number) Is
								Select cust_account_id from OKX_CUST_SITE_USES_V
								where  id1 = p_billto and id2 = '#';

     Cursor l_ra_hcontacts_cur (p_contact_id number) Is
				    Select hzr.object_id
                                    , hzr.party_id
                                    --NPALEPU
                                    --18-JUN-2005
                                    --TCA Project
                                    --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts view with OKS_RA_HCONTACTS_V
                                    --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
                                   /* From
                          ra_hcontacts rah,
                                          hz_party_relationships hzr
                                     Where  rah.contact_id  = p_contact_id
                                     and    rah.party_relationship_id = hzr.party_relationship_id;*/
                                   From  OKS_RA_HCONTACTS_V rah,
                                         hz_relationships hzr
                                   WHERE  rah.contact_id  = p_contact_id
                                   and rah.party_relationship_id = hzr.relationship_id
                                   AND hzr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
                                   AND hzr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
                                   AND hzr.DIRECTIONAL_FLAG = 'F';
                                   --END NPALEPU

     l_ctr_grpid                        Varchar2(40);

--Contract Line Table
  	l_clev_tbl_in             		okc_contract_pub.clev_tbl_type;
  	l_clev_tbl_out             		okc_contract_pub.clev_tbl_type;

--Contract Item
      l_cimv_tbl_in          			okc_contract_item_pub.cimv_tbl_type;
  	l_cimv_tbl_out         			okc_contract_item_pub.cimv_tbl_type;

--Rule Related

  	l_rgpv_tbl_in            		okc_rule_pub.rgpv_tbl_type;
  	l_rgpv_tbl_out            		okc_rule_pub.rgpv_tbl_type;

  	l_rulv_tbl_in             		okc_rule_pub.rulv_tbl_type;
  	l_rulv_tbl_out            		okc_rule_pub.rulv_tbl_type;

--Time Value Related
  	l_isev_ext_tbl_in         		okc_time_pub.isev_ext_tbl_type;
  	l_isev_ext_tbl_out        		okc_time_pub.isev_ext_tbl_type;

--SalesCredit
      l_scrv_tbl_in                       oks_sales_credit_pub.scrv_tbl_type;
      l_scrv_tbl_out                       oks_sales_credit_pub.scrv_tbl_type;

--Obj Rel
      l_crjv_tbl_out                      OKC_K_REL_OBJS_PUB.crjv_tbl_type;

--Coverage
      l_cov_rec                           OKS_COVERAGES_PUB.ac_rec_type;

--Counters
      l_ctr_grp_id_template               NUMBER;
      l_ctr_grp_id_instance               NUMBER;

--Return IDs

  	l_line_id					NUMBER;
  	l_rule_group_id		    		NUMBER;
  	l_rule_id			    		NUMBER;
  	l_line_item_id		    		NUMBER;
	l_time_value_id				NUMBER;
      l_cov_id                            NUMBER;
      l_salescredit_id                    NUMBER;


--TimeUnits
      l_duration                          NUMBER;
      l_timeunits                         VARCHAR2(240);


--General
	l_hdrsdt					DATE;
	l_hdredt					DATE;
	l_hdrstatus				CHAR;
	l_hdrorgid				Number;
     l_lsl_id                      NUMBER;
     l_jtot_object                 VARCHAR2(30) := NULL;
     i                             NUMBER;
     l_can_object                  NUMBER;
     l_line_party_role_id          NUMBER;
     l_lin_party_id                NUMBER;
     l_lin_contactid               NUMBER;
     l_line_contact_id             NUMBER;
     l_role                        VARCHAR2(40);
     l_obj                         VARCHAR2(40);

Begin

	x_return_status				:= OKC_API.G_RET_STS_SUCCESS;
      Okc_context.set_okc_org_context (p_k_line_rec.org_id, p_k_line_rec.organization_id);
      l_Line_id := Get_K_Cle_Id
                  (
                       p_ChrId        => p_k_line_rec.k_id
                    ,  p_InvServiceId => p_k_line_rec.srv_id
                    ,  p_StartDate    => p_k_line_rec.srv_sdt
                    ,  p_EndDate      => p_k_line_rec.srv_edt
                  );


      FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- LINE ID ' || l_line_id);

      If l_line_id Is Not Null Then
         x_Service_Line_id := l_line_id;
         l_return_status := OKC_API.G_RET_STS_SUCCESS;
         Raise G_EXCEPTION_HALT_VALIDATION;
      End If;

     check_hdr_effectivity
     (
	p_chr_id	  =>	p_k_line_rec.k_id,
	p_srv_sdt	  =>  p_k_line_rec.srv_sdt,
	p_srv_edt	  =>  p_k_line_rec.srv_edt,
	x_hdr_sdt     =>	l_hdrsdt,
	x_hdr_edt     =>	l_hdredt,
	x_org_id      =>	l_hdrorgid,
	x_status      =>	l_hdrstatus
      );

      If l_hdrstatus = 'E' Then
	       l_return_status := OKC_API.G_RET_STS_ERROR;
	       Raise G_EXCEPTION_HALT_VALIDATION;

      ElsIf l_hdrstatus = 'Y' Then

 	   Update_Hdr_Dates
    	   (
	     	p_chr_id	=>  p_k_line_rec.k_id,
	     	p_new_sdt	=>  l_hdrsdt,
	     	p_new_edt	=>  l_hdredt,
	     	x_status	=>  l_return_status,
               x_msg_count =>  x_msg_count,
               x_msg_data  =>  x_msg_data
    	   );

         FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- UPDATE HDR ' || l_return_status);


         If Not l_return_Status = 'S' Then
	 	l_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Header Effectivity Update (LINE)');
	  	Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

      End If;

      Open l_mtl_csr(p_k_line_rec.srv_id,p_k_line_rec.organization_id);

      Fetch l_mtl_csr into l_mtl_rec;

      If l_mtl_csr%notfound Then
             FND_FILE.PUT_LINE (FND_FILE.LOG,'L_LINE_CSR FAILURE');
             Close l_mtl_csr ;
             l_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','INVENTORY_ITEM',p_k_line_rec.srv_id);
             Raise G_EXCEPTION_HALT_VALIDATION;
      End if;
      Close l_mtl_csr;

	    l_lsl_id := 12;
         l_jtot_object := 'OKX_USAGE';

     l_clev_tbl_in(1).chr_id			:= p_k_line_rec.k_id;
	l_clev_tbl_in(1).sfwt_flag	  	:= 'N';
	l_clev_tbl_in(1).lse_id			:= l_lsl_id;
	l_clev_tbl_in(1).line_number  	:= p_k_line_rec.k_line_number;
	l_clev_tbl_in(1).sts_code		:= NVL(p_k_line_rec.line_sts_code, 'ACTIVE');
	l_clev_tbl_in(1).display_sequence			:= 1;
	l_clev_tbl_in(1).dnz_chr_id				:= p_k_line_rec.k_id;
	--l_clev_tbl_in(1).name					:= Substr(p_k_line_rec.srv_segment1,1,50);
	l_clev_tbl_in(1).name					:= Null;
	l_clev_tbl_in(1).item_description			:= p_k_line_rec.srv_desc;
	l_clev_tbl_in(1).start_date				:= p_k_line_rec.srv_sdt;
	l_clev_tbl_in(1).end_date				:= p_k_line_rec.srv_edt;
	l_clev_tbl_in(1).exception_yn				:= 'N';
	l_clev_tbl_in(1).currency_code			:= p_k_line_rec.currency;
      l_clev_tbl_in(1).price_level_ind                := Priced_YN(l_lsl_id);
	l_clev_tbl_in(1).trn_code			      := p_k_line_rec.reason_code;
      l_clev_tbl_in(1).comments                       := p_k_line_rec.reason_comments;
      l_clev_tbl_in(1).Attribute1                     := p_k_line_rec.attribute1;
      l_clev_tbl_in(1).Attribute2                     := p_k_line_rec.attribute2;
      l_clev_tbl_in(1).Attribute3                     := p_k_line_rec.attribute3;
      l_clev_tbl_in(1).Attribute4                     := p_k_line_rec.attribute4;
      l_clev_tbl_in(1).Attribute5                     := p_k_line_rec.attribute5;
      l_clev_tbl_in(1).Attribute6                     := p_k_line_rec.attribute6;
      l_clev_tbl_in(1).Attribute7                     := p_k_line_rec.attribute7;
      l_clev_tbl_in(1).Attribute8                     := p_k_line_rec.attribute8;
      l_clev_tbl_in(1).Attribute9                     := p_k_line_rec.attribute9;
      l_clev_tbl_in(1).Attribute10                    := p_k_line_rec.attribute10;
      l_clev_tbl_in(1).Attribute11                    := p_k_line_rec.attribute11;
      l_clev_tbl_in(1).Attribute12                    := p_k_line_rec.attribute12;
      l_clev_tbl_in(1).Attribute13                    := p_k_line_rec.attribute13;
      l_clev_tbl_in(1).Attribute14                    := p_k_line_rec.attribute14;
      l_clev_tbl_in(1).Attribute15                    := p_k_line_rec.attribute15;


  	okc_contract_pub.create_contract_line
      (
   	  p_api_version					=> l_api_version,
  	  p_init_msg_list					=> l_init_msg_list,
     	  x_return_status					=> l_return_status,
        x_msg_count					=> x_msg_count,
        x_msg_data					=> x_msg_data,
        p_clev_tbl					=> l_clev_tbl_in,
    	  x_clev_tbl					=> l_clev_tbl_out
      );


      FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- LINE STATUS ' || l_return_status);

      If l_return_status = 'S' then
    	   l_line_id := l_clev_tbl_out(1).id;
      Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Line (LINE)');
	   Raise G_EXCEPTION_HALT_VALIDATION;
      End if;

     okc_time_util_pub.get_duration
     (
          p_start_date    => p_k_line_rec.srv_sdt,
          p_end_date      => p_k_line_rec.srv_edt,
          x_duration      => l_duration,
          x_timeunit      => l_timeunits,
          x_return_status => l_return_status
     );

     If Not l_return_status = 'S' Then
       Raise G_EXCEPTION_HALT_VALIDATION;
     End If;

--Create Contract Item

    l_cimv_tbl_in(1).cle_id	  		:= l_line_id;
    l_cimv_tbl_in(1).dnz_chr_id	  	:= p_k_line_rec.k_id;
    l_cimv_tbl_in(1).object1_id1		:= p_k_line_rec.srv_id;
    l_cimv_tbl_in(1).object1_id2		:= p_k_line_rec.organization_id;
    l_cimv_tbl_in(1).jtot_object1_code	:= l_jtot_object;
    l_cimv_tbl_in(1).exception_yn		:= 'N';
    l_cimv_tbl_in(1).number_of_items	:= l_duration;
    l_cimv_tbl_in(1).uom_code             := l_timeunits;

    okc_contract_item_pub.create_contract_item
    (
    	p_api_version				=> l_api_version,
    	p_init_msg_list				=> l_init_msg_list,
    	x_return_status				=> l_return_status,
    	x_msg_count					=> x_msg_count,
    	x_msg_data					=> x_msg_data,
    	p_cimv_tbl					=> l_cimv_tbl_in,
    	x_cimv_tbl					=> l_cimv_tbl_out
    );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- KITEM STATUS ' || l_return_status);


    If l_return_status = 'S' then
    	   l_line_item_id := l_cimv_tbl_out(1).id;
    Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Service Inventory Item ID ' || p_k_line_rec.srv_id || ' ORG ' + okc_context.get_okc_organization_id);
	   Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

--Create SalesCredits

    If p_salescredit_tbl_in.count > 0 Then

    i := p_salescredit_Tbl_in.First;

    Loop

        l_scrv_tbl_in (1).percent                 := p_salescredit_tbl_in(i).percent;
        l_scrv_tbl_in (1).chr_id                  := p_k_line_rec.k_id;
        l_scrv_tbl_in (1).cle_id                  := l_line_id;
        l_scrv_tbl_in (1).ctc_id                  := p_salescredit_tbl_in(i).ctc_id;
        l_scrv_tbl_in (1).sales_credit_type_id1   := p_salescredit_tbl_in(i).sales_credit_type_id;
        l_scrv_tbl_in (1).sales_credit_type_id2   := '#';


        OKS_SALES_CREDIT_PUB.Insert_Sales_Credit(
                              p_api_version	=> 1.0,
                              p_init_msg_list	=> OKC_API.G_FALSE,
                              x_return_status	=> x_return_status,
                              x_msg_count	      => x_msg_count,
                              x_msg_data	      => x_msg_data,
                              p_scrv_tbl	      => l_scrv_tbl_in,
                              x_scrv_tbl        => l_scrv_tbl_out);

        FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- SALESCREDIT STATUS ' || l_return_status);


        If l_return_status = 'S' then
    	     l_salescredit_id := l_scrv_tbl_out(1).id;
        Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Sales Credit Failure');
	     Raise G_EXCEPTION_HALT_VALIDATION;
        End if;

        Exit When i = p_salescredit_Tbl_in.Last;

        i := p_SalesCredit_Tbl_in.Next(i);

    End Loop;

    End If;


--Rule Group Routine

    l_rule_group_id	:= Check_Rule_Group_Exists(NULL,l_line_id);

    If l_rule_group_id Is NULL Then

			l_rgpv_tbl_in(1).chr_id	    := NULL;
		     	l_rgpv_tbl_in(1).cle_id     := l_line_id;
		    	l_rgpv_tbl_in(1).sfwt_flag  := 'N';
    		      l_rgpv_tbl_in(1).rgd_code   := G_RULE_GROUP_CODE;
			l_rgpv_tbl_in(1).dnz_chr_id := p_k_line_rec.k_id;
			l_rgpv_tbl_in(1).rgp_type   := 'KRG';

                	create_rule_group
                  (
				p_rgpv_tbl      => l_rgpv_tbl_in,
    	                  x_rgpv_tbl      => l_rgpv_tbl_out,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data
                  );

                  FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- RULE GROUP STATUS ' || l_return_status);


                  If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  			   l_rule_group_id := l_rgpv_tbl_out(1).id;
                  Else
                     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Rule Group (LINE)');
                     Raise G_EXCEPTION_HALT_VALIDATION;
                  End If;

    End If;

--Customer Account


   open  l_billto_csr (p_k_line_rec.bill_to_id);
   fetch l_billto_csr into l_can_object;
   close l_billto_csr;

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'CAN');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'CAN';
  		l_rulv_tbl_in(1).object1_id1			 := l_can_object;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_CUSTACCT;
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- CAN RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(
                                    p_app_name     => 'OKS',
                                    p_msg_name     => G_REQUIRED_VALUE,
                                    p_token1       => G_COL_NAME_TOKEN,
                                    p_token1_value => 'Customer Account (LINE)'
                                  );


                Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


    --CONTACT CREATION ROUTINE STARTS


    If p_contact_tbl.count > 0 Then

    i := p_Contact_Tbl.First;

    Loop
              Open  l_ra_hcontacts_cur (p_Contact_tbl (i).contact_id);
              fetch l_ra_hcontacts_cur into l_lin_party_id, l_lin_contactid;
              close l_ra_hcontacts_cur;

    if i = p_contact_tbl.first Then

    Party_Role (         p_chrId          => p_k_line_rec.k_id,
					p_cleId          => l_line_id,
                         p_Rle_Code       => 'CUSTOMER',
                         p_PartyId        => l_lin_party_id,
                         p_Object_Code    => G_JTF_PARTY,
                         x_roleid         => l_line_party_role_id,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data
               );

    FND_FILE.PUT_LINE (FND_FILE.LOG,' LINE PARTY ROLE  CREATION :- CPL ID ' || l_line_party_role_id);

    End If;


		if p_contact_tbl(i).contact_role like '%BILLING%' Then
			l_role := 'CUST_BILLING';
			l_obj  := 'OKX_CONTBILL';
		elsif p_contact_tbl(i).contact_role like '%ADMIN%' Then
		     l_role := 'CUST_ADMIN';
		     l_obj  := 'OKX_CONTADMN';
		elsif p_contact_tbl(i).contact_role like '%SHIP%' Then
		     l_role := 'CUST_SHIPPING';
		     l_obj  := 'OKX_CONTSHIP';
          end if;

FND_FILE.PUT_LINE (FND_FILE.LOG,'LINE CONTACT CREATION :- LIN PARTY ID ' ||l_lin_party_id);
FND_FILE.PUT_LINE (FND_FILE.LOG,'LINE CONTACT CREATION :- ORG CTC ID ' ||p_Contact_tbl (i).contact_id );
FND_FILE.PUT_LINE (FND_FILE.LOG,'LINE CONTACT CREATION :- RAH CTC ID ' ||l_lin_contactid);

FND_FILE.PUT_LINE (FND_FILE.LOG,'LINE CONTACT CREATION :- CONT  ROLE ' ||p_Contact_tbl (i).contact_role);
FND_FILE.PUT_LINE (FND_FILE.LOG,'LINE CONTACT CREATION :- CON OBJ CD ' ||p_Contact_tbl (i).contact_object_code);

        l_ctcv_tbl_in(1).cpl_id           := l_line_party_role_id;
        l_ctcv_tbl_in(1).dnz_chr_id       := p_k_line_rec.k_id;
        l_ctcv_tbl_in(1).cro_code         := l_role;
        l_ctcv_tbl_in(1).object1_id1      := p_contact_tbl(i).contact_id;
        l_ctcv_tbl_in(1).object1_id2      := '#';
        l_ctcv_tbl_in(1).jtot_object1_code:= l_obj;

        okc_contract_party_pub.create_contact
        (
    	    p_api_version		               => l_api_version,
    	    p_init_msg_list				     => l_init_msg_list,
    	    x_return_status					=> l_return_status,
    	    x_msg_count					=> x_msg_count,
    	    x_msg_data						=> x_msg_data,
    	    p_ctcv_tbl						=> l_ctcv_tbl_in,
    	    x_ctcv_tbl						=> l_ctcv_tbl_out
        );

        If l_return_status = 'S' then
    	     l_line_contact_id := l_ctcv_tbl_out(1).id;
        Else
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, p_Contact_tbl (i).contact_role
                                             || ' Contact (LINE) ' || p_Contact_tbl (i).contact_object_code);
	     Raise G_EXCEPTION_HALT_VALIDATION;
        End if;

        Exit When i = p_Contact_Tbl.Last;

        i := p_Contact_Tbl.Next(i);

    End Loop;

    End If;



    --CONTACT CREATION ROUTINE ENDS


--Accounting Rule ID  Routine

    If p_k_line_rec.accounting_rule_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'ARL');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    	l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    	l_rulv_tbl_in(1).std_template_yn           := 'N';
    	l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'ARL';
  	l_rulv_tbl_in(1).object1_id1			 := p_k_line_rec.accounting_rule_id;
  	l_rulv_tbl_in(1).object1_id2			 := '#';
  	l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_ARL;
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- ARL RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(
                                    p_app_name     => 'OKS',
                                    p_msg_name     => G_REQUIRED_VALUE,
                                    p_token1       => G_COL_NAME_TOKEN,
                                    p_token1_value => 'Customer Account (LINE)'
                                  );


                Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    End If;



--QRE rule for usage only

  If l_lsl_id = 12 THEN

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'QRE');

    If l_rule_id Is NULL Then

	   l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    	   l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    	   l_rulv_tbl_in(1).std_template_yn           := 'N';
    	   l_rulv_tbl_in(1).warn_yn                   := 'N';
	   l_rulv_tbl_in(1).rule_information_category := 'QRE';
      --  l_rulv_tbl_in(1).rule_information1         := Substr(p_k_line_rec.srv_desc,1,50);
          l_rulv_tbl_in(1).rule_information11        := 'DAY';
	  l_rulv_tbl_in(1).rule_information2         := p_k_line_rec.period;
	  l_rulv_tbl_in(1).rule_information6         := p_k_line_rec.amcv_flag;
	  l_rulv_tbl_in(1).rule_information9         := p_k_line_rec.level_yn;
	  l_rulv_tbl_in(1).ATTRIBUTE11		   := 'DAY';

        l_rulv_tbl_in(1).rule_information10        := p_k_line_rec.l_usage_type;
	   l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

	   create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data
				  );

        FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- QRE RULE STATUS ' || l_return_status);


        If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  	         l_rule_id	:= l_rulv_tbl_out(1).id;
        Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'USAGE ITEM (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

    End If;

  End if;
-- Line Invoicing Rule
    If p_k_line_rec.invoicing_rule_id Is Not Null Then

       clear_rule_table (l_rulv_tbl_in);

       l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRE');

       If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'IRE';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_line_rec.invoicing_rule_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_IRE;
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );


            FND_FILE.PUT_LINE (FND_FILE.LOG, 'K Line CREATION :- IRE RULE STATUS ' || l_return_Status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Invoice Id (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

       End If;

    End If;

--Invoice Text Routine

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRT');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'IRT';
            l_rulv_tbl_in(1).rule_information1         := Substr(p_k_line_rec.srv_desc,1,50);
                        l_rulv_tbl_in(1).rule_information2         := 'Y';

		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- IRT RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INVOICE TEXT (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


--Line Renewal Type To Routine

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'LRT');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'LRT';
            l_rulv_tbl_in(1).rule_information1         := Nvl(p_k_line_rec.line_renewal_type,'FUL');
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- LRT RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE RENEWAL TYPE (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

--Bill To Routine

    If p_k_line_rec.bill_to_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'BTO');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'BTO';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_line_rec.bill_to_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_BILLTO;
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- BTO RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'BillTo ID (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


    End If;

--Ship To Routine

    If p_k_line_rec.ship_to_id Is Not Null Then

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'STO');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'STO';
  		l_rulv_tbl_in(1).object1_id1			 := p_k_line_rec.ship_to_id;
  		l_rulv_tbl_in(1).object1_id2			 := '#';
  		l_rulv_tbl_in(1).jtot_object1_code		 := G_JTF_SHIPTO;
		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_line_rec.k_id;

		create_rules  (
					p_rulv_tbl      =>  l_rulv_tbl_in,
  					x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- STO RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ShipTo ID (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;


    End If;


    If p_k_line_rec.warranty_flag <> 'W' OR
         l_mtl_rec.USAGE_ITEM_FLAG = 'Y' OR
         l_mtl_rec.SERVICE_ITEM_FLAG = 'Y'   THEN

--Schedule Billing Routine

    clear_rule_table (l_rulv_tbl_in);

    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'SBG');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		    l_rulv_tbl_in(1).rule_information_category := 'SBG';
	    	l_rulv_tbl_in(1).dnz_chr_id			       := p_k_line_rec.k_id;
        	l_rulv_tbl_in(1).rule_information1         := 1;
   	    	l_rulv_tbl_in(1).rule_information2         := p_k_line_rec.Billing_freq;
            l_rulv_tbl_in(1).rule_information3         := p_k_line_rec.first_billupto_date;
            l_rulv_tbl_in(1).rule_information4         := p_k_line_rec.first_billon_date;

    		l_rulv_tbl_in(1).rule_information5         := 1;
    		l_rulv_tbl_in(1).rule_information6         := p_k_line_rec.Billing_freq;
    		l_rulv_tbl_in(1).rule_information7         := p_k_line_rec.offset_duration;
    		l_rulv_tbl_in(1).rule_information8         := 'DAY';
    		l_rulv_tbl_in(1).rule_information9         := 'N';


		create_rules  (
					     p_rulv_tbl      =>  l_rulv_tbl_in,
  					     x_rulv_tbl      =>  l_rulv_tbl_out,
                              x_return_status => l_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data
				  );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- SBG RULE STATUS ' || l_return_status);


            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Sched Billing Rule (LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

    End If;

    If  p_k_line_rec.order_line_id Is Not Null Then

    Create_Obj_Rel
    (
	 p_K_id	      => Null,
 	 p_line_id	      => l_line_id,
	 p_orderhdrid 	=> Null,
	 p_orderlineid    => p_k_line_rec.order_line_id,
      x_return_status   => l_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      x_crjv_tbl_out    => l_crjv_tbl_out
     );

     FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- OBJ REL STATUS ' || l_return_status);
End If;

     If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Order Line Id (LINE)');
        Raise G_EXCEPTION_HALT_VALIDATION;
     End If;


     End If;


	IF l_lsl_id <> 12 THEN  --- No coverages for usage lines

        l_cov_rec.Svc_cle_Id := l_line_id;
        l_cov_rec.Tmp_cle_Id := p_k_line_rec.coverage_template_id;
        l_cov_rec.Start_date := p_k_line_rec.srv_sdt;
        l_cov_rec.End_Date   := p_k_line_rec.srv_edt;

        OKS_COVERAGES_PUB.CREATE_ACTUAL_COVERAGE
        (
          p_api_version	      => 1.0,
          p_init_msg_list         => OKC_API.G_FALSE,
          x_return_status         => l_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          P_ac_rec_in    	      => l_cov_rec,
          x_Actual_coverage_id    => l_cov_id
        );

        FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- COV STATUS ' || l_return_status);

        If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'CoverageInstantiate (LINE)');
             Raise G_EXCEPTION_HALT_VALIDATION;
        End If;

	End if; -- for coverages

     l_ctr_grpid := Null;

     Open  l_ctr_csr (p_k_line_rec.srv_id);
     Fetch l_ctr_csr Into l_ctr_grpid;
     Close l_ctr_csr;

     If l_ctr_grpid Is Not Null Then

         cs_counters_pub.autoinstantiate_counters
         (
              P_API_VERSION                  => 1.0,
              P_INIT_MSG_LIST                => 'T',
              P_COMMIT                       => 'F',
              X_RETURN_STATUS                => l_return_status,
              X_MSG_COUNT                    => x_msg_count,
              X_MSG_DATA                     => x_msg_data,
              P_SOURCE_OBJECT_ID_TEMPLATE    => p_k_line_rec.srv_id,
              P_SOURCE_OBJECT_ID_INSTANCE    => l_line_id,
              X_CTR_GRP_ID_TEMPLATE          => l_ctr_grp_id_template,
              X_CTR_GRP_ID_INSTANCE          => l_ctr_grp_id_instance
         );

         FND_FILE.PUT_LINE (FND_FILE.LOG,'K LINE CREATION :- CTR STATUS ' || l_return_status);

         If Not l_return_status = OKC_API.G_RET_STS_SUCCESS Then
             OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Counter Instantiate (LINE)');
             Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

     End If;

     x_service_line_id := l_line_id;

Exception

	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End Create_OSO_K_Service_Lines;

Procedure Create_OSO_K_Covered_Levels
(
	p_k_covd_rec			IN	K_line_Covered_Level_Rec_type
,     p_PRICE_ATTRIBS               IN    Pricing_attributes_Type
,	x_return_status		     OUT	NOCOPY Varchar2
,     x_msg_count                  OUT    NOCOPY Number
,     x_msg_data                   OUT    NOCOPY Varchar2
)
Is

  	l_api_version		CONSTANT	NUMBER	:= 1.0;
  	l_init_msg_list		CONSTANT	VARCHAR2(1) := OKC_API.G_FALSE;
  	l_return_status				VARCHAR2(1) := 'S';
  	l_index					VARCHAR2(2000);

--Contract Line Table
  	l_clev_tbl_in             		okc_contract_pub.clev_tbl_type;
  	l_clev_tbl_out             		okc_contract_pub.clev_tbl_type;

--Contract Item
      l_cimv_tbl_in          			okc_contract_item_pub.cimv_tbl_type;
  	l_cimv_tbl_out         			okc_contract_item_pub.cimv_tbl_type;

--Pricing Attributes
      l_pavv_tbl_in                       okc_price_adjustment_pvt.pavv_tbl_type;
      l_pavv_tbl_out                      okc_price_adjustment_pvt.pavv_tbl_type;


--Rule Related

  	l_rgpv_tbl_in            		okc_rule_pub.rgpv_tbl_type;
	l_rgpv_tbl_out            		okc_rule_pub.rgpv_tbl_type;

  	l_rulv_tbl_in             		okc_rule_pub.rulv_tbl_type;
  	l_rulv_tbl_out            		okc_rule_pub.rulv_tbl_type;

--Return IDs
  	l_line_id					NUMBER;
  	l_rule_group_id		    		NUMBER;
  	l_rule_id			    		NUMBER;
  	l_line_item_id		    		NUMBER;

     l_lsl_id                            NUMBER;
     l_jtot_object                       VARCHAR2(30) := NULL;
     l_hdrsdt                            DATE;
     l_hdredt                            DATE;
     l_hdrorgid                          Number;
     l_line_sdt                          DATE;
     l_line_edt                          DATE;
     l_hdrstatus                         VARCHAR2(3);
     l_line_status                       VARCHAR2(3);
     l_priceattrib_id                    NUMBER;

      Cursor l_mtl_csr(p_inventory_id Number, p_organization_id Number) Is
                  Select  MTL.SERVICE_ITEM_FLAG
                         ,MTL.USAGE_ITEM_FLAG
                  From    OKX_SYSTEM_ITEMS_V MTL
                  Where   MTL.id1   = p_Inventory_id
                  And     MTL.Organization_id = p_organization_id;

      l_mtl_rec     l_mtl_csr%rowtype;

Begin

	x_return_status			:= OKC_API.G_RET_STS_SUCCESS;

      check_line_effectivity
      (
	p_cle_id	  =>	p_k_covd_rec.Attach_2_Line_Id,
	p_srv_sdt	  =>  p_k_covd_rec.Product_start_date,
	p_srv_edt	  =>  p_k_covd_rec.Product_end_date,
	x_line_sdt     =>	l_line_sdt,
	x_line_edt     =>	l_line_edt,
	x_status      =>	l_line_status
      );

      If l_line_status = 'E' Then

	   l_return_status := OKC_API.G_RET_STS_ERROR;
	   Raise G_EXCEPTION_HALT_VALIDATION;

      ElsIf l_line_status = 'Y' Then

         check_hdr_effectivity
         (
            p_chr_id	  =>	p_k_covd_rec.k_id,
	   	p_srv_sdt	  =>  l_line_sdt,
	   	p_srv_edt	  =>  l_line_edt,
	   	x_hdr_sdt     =>	l_hdrsdt,
	   	x_hdr_edt     =>	l_hdredt,
	   	x_org_id      =>	l_hdrorgid,
	   	x_status      =>	l_hdrstatus
	   );

         If l_hdrstatus = 'E' Then

	      l_return_status := OKC_API.G_RET_STS_ERROR;
	      Raise G_EXCEPTION_HALT_VALIDATION;

         ElsIf l_hdrstatus = 'Y' Then

 	      Update_Hdr_Dates
    	      (
		  p_chr_id	=>  p_k_covd_rec.k_id,
		  p_new_sdt	=>  l_hdrsdt,
		  p_new_edt	=>  l_hdredt,
		  x_status	=>  l_return_status,
              x_msg_count =>  x_msg_count,
              x_msg_data  =>  x_msg_data
     	      );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- UPDATE HDR STATUS ' || l_return_status);


            If Not l_return_Status = 'S' Then
	 	  l_return_status := OKC_API.G_RET_STS_ERROR;
              OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Header Effectivity Update (SUB LINE)');
	  	  Raise G_EXCEPTION_HALT_VALIDATION;
            End If;
         End If;

 	   Update_Line_Dates
    	   (
		p_cle_id	=>  p_k_covd_rec.Attach_2_Line_Id,
		p_new_sdt	=>  l_line_sdt,
		p_new_edt	=>  l_line_edt,
          p_warranty_flag => p_k_covd_rec.warranty_flag,
		x_status	=>  l_return_status,
            x_msg_count =>  x_msg_count,
            x_msg_data  =>  x_msg_data
     	   );

         FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- UPDATE LINE STATUS ' || l_return_status);

         If Not l_return_Status = 'S' Then
	 	l_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE Effectivity Update (SUB LINE)');
	  	Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

      End If;

     /* Open l_mtl_csr(p_k_covd_rec.srv_id,l_hdrorgid);

      Fetch l_mtl_csr into l_mtl_rec;

      If l_mtl_csr%notfound Then
             FND_FILE.PUT_LINE (FND_FILE.LOG,'L_LINE_CSR FAILURE');
             Close l_mtl_csr ;
             l_return_status := OKC_API.G_RET_STS_ERROR;
             OKC_API.set_message(G_APP_NAME,'OKS_CUST_PROD_DTLS_NOT_FOUND','CUSTOMER_PRODUCT',p_k_covd_rec.Customer_Product_Id);
             Raise G_EXCEPTION_HALT_VALIDATION;
      End if;
      Close l_mtl_csr;
*/

	    l_lsl_id := 13;
         l_jtot_object := G_JTF_COUNTER;


     l_clev_tbl_in(1).chr_id					:= Null;
	l_clev_tbl_in(1).sfwt_flag	  		      := 'N';
	l_clev_tbl_in(1).lse_id			  		:= l_lsl_id;
	l_clev_tbl_in(1).line_number  			:= p_k_covd_rec.line_number;
	l_clev_tbl_in(1).sts_code		  		:= Nvl(p_k_covd_rec.product_sts_code,'ACTIVE');
	l_clev_tbl_in(1).display_sequence			:= 2;
	l_clev_tbl_in(1).dnz_chr_id				:= p_k_covd_rec.k_id;
	--l_clev_tbl_in(1).name					:= Substr(p_k_covd_rec.Product_segment1,1,50);
	l_clev_tbl_in(1).name					:= Null;
	l_clev_tbl_in(1).item_description			:= p_k_covd_rec.Product_desc;
	l_clev_tbl_in(1).start_date				:= p_k_covd_rec.Product_start_date;
	l_clev_tbl_in(1).end_date				:= p_k_covd_rec.Product_end_date;
	l_clev_tbl_in(1).exception_yn				:= 'N';
	l_clev_tbl_in(1).price_negotiated			:= p_k_covd_rec.negotiated_amount;
	l_clev_tbl_in(1).currency_code               := p_k_covd_rec.currency_code;
	l_clev_tbl_in(1).price_unit			:= p_k_covd_rec.list_price;
	l_clev_tbl_in(1).cle_id					:= p_k_covd_rec.Attach_2_Line_Id;
      l_clev_tbl_in(1).price_level_ind                := Priced_YN(l_lsl_id);
	l_clev_tbl_in(1).trn_code			      := p_k_covd_rec.reason_code;
      l_clev_tbl_in(1).comments                       := p_k_covd_rec.reason_comments;
      l_clev_tbl_in(1).Attribute1                     := p_k_covd_rec.attribute1;
      l_clev_tbl_in(1).Attribute2                     := p_k_covd_rec.attribute2;
      l_clev_tbl_in(1).Attribute3                     := p_k_covd_rec.attribute3;
      l_clev_tbl_in(1).Attribute4                     := p_k_covd_rec.attribute4;
      l_clev_tbl_in(1).Attribute5                     := p_k_covd_rec.attribute5;
      l_clev_tbl_in(1).Attribute6                     := p_k_covd_rec.attribute6;
      l_clev_tbl_in(1).Attribute7                     := p_k_covd_rec.attribute7;
      l_clev_tbl_in(1).Attribute8                     := p_k_covd_rec.attribute8;
      l_clev_tbl_in(1).Attribute9                     := p_k_covd_rec.attribute9;
      l_clev_tbl_in(1).Attribute10                    := p_k_covd_rec.attribute10;
      l_clev_tbl_in(1).Attribute11                    := p_k_covd_rec.attribute11;
      l_clev_tbl_in(1).Attribute12                    := p_k_covd_rec.attribute12;
      l_clev_tbl_in(1).Attribute13                    := p_k_covd_rec.attribute13;
      l_clev_tbl_in(1).Attribute14                    := p_k_covd_rec.attribute14;
      l_clev_tbl_in(1).Attribute15                    := p_k_covd_rec.attribute15;


  	okc_contract_pub.create_contract_line
      (
   	  p_api_version					=> l_api_version,
  	  p_init_msg_list					=> l_init_msg_list,
     	  x_return_status					=> l_return_status,
        x_msg_count					=> x_msg_count,
        x_msg_data					=> x_msg_data,
        p_clev_tbl					=> l_clev_tbl_in,
    	  x_clev_tbl					=> l_clev_tbl_out
      );

      FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- LINE  STATUS ' || l_return_status);


      If l_return_status = 'S' then
    	   l_line_id := l_clev_tbl_out(1).id;
      Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'K LINE (SUB LINE)');
	   Raise G_EXCEPTION_HALT_VALIDATION;
    End if;


--Create Contract Item

    l_cimv_tbl_in(1).cle_id	  		:= l_line_id;
    l_cimv_tbl_in(1).dnz_chr_id	  	:= p_k_covd_rec.k_id;
    l_cimv_tbl_in(1).object1_id1		:= p_k_covd_rec.Customer_Product_Id;
    l_cimv_tbl_in(1).object1_id2		:= '#';
    l_cimv_tbl_in(1).jtot_object1_code  := l_jtot_object;
    l_cimv_tbl_in(1).exception_yn		:= 'N';
    l_cimv_tbl_in(1).number_of_items	:= p_k_covd_rec.quantity;
    l_cimv_tbl_in(1).uom_code           := p_k_covd_rec.uom_code;

    okc_contract_item_pub.create_contract_item
    (
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count						=> x_msg_count,
    	x_msg_data						=> x_msg_data,
    	p_cimv_tbl						=> l_cimv_tbl_in,
    	x_cimv_tbl						=> l_cimv_tbl_out
    );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- KITEM  STATUS ' || l_return_status);


    If l_return_status = 'S' then
    	   l_line_item_id := l_cimv_tbl_out(1).id;
    Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'KItem (SUB LINE)');
	   Raise G_EXCEPTION_HALT_VALIDATION;
    End if;


--Rule Group Routine

    l_rule_group_id	:= Check_Rule_Group_Exists(NULL,l_line_id);

    If l_rule_group_id Is NULL Then

	    l_rgpv_tbl_in(1).chr_id	    := NULL;
	    l_rgpv_tbl_in(1).cle_id     := l_line_id;
	    l_rgpv_tbl_in(1).sfwt_flag  := 'N';
    	    l_rgpv_tbl_in(1).rgd_code   := G_RULE_GROUP_CODE;
	    l_rgpv_tbl_in(1).dnz_chr_id := p_k_covd_rec.k_id;
	    l_rgpv_tbl_in(1).rgp_type   := 'KRG';

         create_rule_group
         (
				p_rgpv_tbl      => l_rgpv_tbl_in,
    	               x_rgpv_tbl      => l_rgpv_tbl_out,
                    x_return_status => l_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data
         );

         FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- RGP  STATUS ' || l_return_status);


         If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  			l_rule_group_id := l_rgpv_tbl_out(1).id;
         Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Rule Group (SUB LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
         End If;

    End If;


    --Invoice Text Routine

    clear_rule_table (l_rulv_tbl_in);
    l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'IRT');

    If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'IRT';
                l_rulv_tbl_in(1).rule_information1         := 'Counter'||Substr(p_k_covd_rec.Product_desc,1,50);
                    l_rulv_tbl_in(1).rule_information2         := 'Y';

		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_covd_rec.k_id;

		create_rules  (
			p_rulv_tbl      =>  l_rulv_tbl_in,
  			x_rulv_tbl      =>  l_rulv_tbl_out,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data
	      );

           FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- IRT RULE STATUS ' || l_return_status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		     l_rule_id	:= l_rulv_tbl_out(1).id;
           Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'INVOICE TEXT (SUB LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
           End If;

    End If;


    IF l_lsl_id = 13 THEN -- validation for usage rules

    --- QRE rule for usages
       clear_rule_table (l_rulv_tbl_in);
       l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'QRE');

       If l_rule_id Is NULL Then

		l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		l_rulv_tbl_in(1).std_template_yn           := 'N';
    		l_rulv_tbl_in(1).warn_yn                   := 'N';
		l_rulv_tbl_in(1).rule_information_category := 'QRE';
       --   l_rulv_tbl_in(1).rule_information1         := Substr(p_k_covd_rec.Product_desc,1,50);
          l_rulv_tbl_in(1).rule_information2     := p_k_covd_rec.period;
          l_rulv_tbl_in(1).rule_information4     := p_k_covd_rec.minimum_qty;
          l_rulv_tbl_in(1).rule_information5     := p_k_covd_rec.default_qty;
          l_rulv_tbl_in(1).rule_information6     := p_k_covd_rec.amcv_flag;
          l_rulv_tbl_in(1).rule_information7     := p_k_covd_rec.fixed_qty;
         -- l_rulv_tbl_in(1).rule_information8     := p_k_covd_rec.duration;
          l_rulv_tbl_in(1).rule_information9     := p_k_covd_rec.level_yn;
          l_rulv_tbl_in(1).rule_information12    := p_k_covd_rec.base_reading;

		l_rulv_tbl_in(1).dnz_chr_id			 := p_k_covd_rec.k_id;

		create_rules  (
			p_rulv_tbl      =>  l_rulv_tbl_in,
  			x_rulv_tbl      =>  l_rulv_tbl_out,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data
	      );

           FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- QRE RULE STATUS ' || l_return_status);

           If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		     l_rule_id	:= l_rulv_tbl_out(1).id;
           Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'USAGE ITEM (SUB LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
           End If;

       End If;  -- end if for QRE rule

    ELSE

       --Line Renewal Type To Routine

       clear_rule_table (l_rulv_tbl_in);

       l_rule_id     := Check_Rule_Exists(l_rule_group_id, 'LRT');

       If l_rule_id Is NULL Then

		     l_rulv_tbl_in(1).rgp_id	       		 := l_rule_group_id;
    		     l_rulv_tbl_in(1).sfwt_flag                 := 'N';
    		     l_rulv_tbl_in(1).std_template_yn           := 'N';
    		     l_rulv_tbl_in(1).warn_yn                   := 'N';
		     l_rulv_tbl_in(1).rule_information_category := 'LRT';
               l_rulv_tbl_in(1).rule_information1         := Nvl(p_k_covd_rec.line_renewal_type,'FUL');
		     l_rulv_tbl_in(1).dnz_chr_id			 := p_k_covd_rec.k_id;

		     create_rules  (
				p_rulv_tbl      =>  l_rulv_tbl_in,
  			     x_rulv_tbl      =>  l_rulv_tbl_out,
                    x_return_status => l_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data
		     );

            FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- LRT RULE STATUS ' || l_return_status);

            If l_return_status = OKC_API.G_RET_STS_SUCCESS Then
  		   l_rule_id	:= l_rulv_tbl_out(1).id;
            Else
               OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'LINE RENEWAL TYPE (SUB LINE)');
               Raise G_EXCEPTION_HALT_VALIDATION;
            End If;

        End If;

    End if;  -- validation for usage rules

--Create Pricing Attributes

   If p_price_attribs.pricing_context Is Not Null Then

   l_pavv_tbl_in(1).cle_id	            :=   l_line_id;
   l_pavv_tbl_in(1).flex_title	      :=   'QP_ATTR_DEFNS_PRICING';
   l_pavv_tbl_in(1).pricing_context    	:=   p_price_attribs.PRICING_CONTEXT;
   l_pavv_tbl_in(1).pricing_attribute1 	:=   p_price_attribs.PRICING_ATTRIBUTE1;
   l_pavv_tbl_in(1).pricing_attribute2 	:=   p_price_attribs.PRICING_ATTRIBUTE2;
   l_pavv_tbl_in(1).pricing_attribute3	:=   p_price_attribs.PRICING_ATTRIBUTE3;
   l_pavv_tbl_in(1).pricing_attribute4 	:=   p_price_attribs.PRICING_ATTRIBUTE4;
   l_pavv_tbl_in(1).pricing_attribute5 	:=   p_price_attribs.PRICING_ATTRIBUTE5;
   l_pavv_tbl_in(1).pricing_attribute6 	:=   p_price_attribs.PRICING_ATTRIBUTE6;
   l_pavv_tbl_in(1).pricing_attribute7 	:=   p_price_attribs.PRICING_ATTRIBUTE7;
   l_pavv_tbl_in(1).pricing_attribute8 	:=   p_price_attribs.PRICING_ATTRIBUTE8;
   l_pavv_tbl_in(1).pricing_attribute9	:=   p_price_attribs.PRICING_ATTRIBUTE9;
   l_pavv_tbl_in(1).pricing_attribute10	:=   p_price_attribs.PRICING_ATTRIBUTE10;
   l_pavv_tbl_in(1).pricing_attribute11	:=   p_price_attribs.PRICING_ATTRIBUTE11;
   l_pavv_tbl_in(1).pricing_attribute12	:=   p_price_attribs.PRICING_ATTRIBUTE12;
   l_pavv_tbl_in(1).pricing_attribute13	:=   p_price_attribs.PRICING_ATTRIBUTE13;
   l_pavv_tbl_in(1).pricing_attribute14	:=   p_price_attribs.PRICING_ATTRIBUTE14;
   l_pavv_tbl_in(1).pricing_attribute15	:=   p_price_attribs.PRICING_ATTRIBUTE15;
   l_pavv_tbl_in(1).pricing_attribute16	:=   p_price_attribs.PRICING_ATTRIBUTE16;
   l_pavv_tbl_in(1).pricing_attribute17	:=   p_price_attribs.PRICING_ATTRIBUTE17;
   l_pavv_tbl_in(1).pricing_attribute18	:=   p_price_attribs.PRICING_ATTRIBUTE18;
   l_pavv_tbl_in(1).pricing_attribute19	:=   p_price_attribs.PRICING_ATTRIBUTE19;
   l_pavv_tbl_in(1).pricing_attribute20	:=   p_price_attribs.PRICING_ATTRIBUTE20;
   l_pavv_tbl_in(1).pricing_attribute21	:=   p_price_attribs.PRICING_ATTRIBUTE21;
   l_pavv_tbl_in(1).pricing_attribute22	:=   p_price_attribs.PRICING_ATTRIBUTE22;
   l_pavv_tbl_in(1).pricing_attribute23	:=   p_price_attribs.PRICING_ATTRIBUTE23;
   l_pavv_tbl_in(1).pricing_attribute24	:=   p_price_attribs.PRICING_ATTRIBUTE24;
   l_pavv_tbl_in(1).pricing_attribute25	:=   p_price_attribs.PRICING_ATTRIBUTE25;
   l_pavv_tbl_in(1).pricing_attribute26	:=   p_price_attribs.PRICING_ATTRIBUTE26;
   l_pavv_tbl_in(1).pricing_attribute27	:=   p_price_attribs.PRICING_ATTRIBUTE27;
   l_pavv_tbl_in(1).pricing_attribute28	:=   p_price_attribs.PRICING_ATTRIBUTE28;
   l_pavv_tbl_in(1).pricing_attribute29	:=   p_price_attribs.PRICING_ATTRIBUTE29;
   l_pavv_tbl_in(1).pricing_attribute30	:=   p_price_attribs.PRICING_ATTRIBUTE30;
   l_pavv_tbl_in(1).pricing_attribute31	:=   p_price_attribs.PRICING_ATTRIBUTE31;
   l_pavv_tbl_in(1).pricing_attribute32	:=   p_price_attribs.PRICING_ATTRIBUTE32;
   l_pavv_tbl_in(1).pricing_attribute33	:=   p_price_attribs.PRICING_ATTRIBUTE33;
   l_pavv_tbl_in(1).pricing_attribute34	:=   p_price_attribs.PRICING_ATTRIBUTE34;
   l_pavv_tbl_in(1).pricing_attribute35	:=   p_price_attribs.PRICING_ATTRIBUTE35;
   l_pavv_tbl_in(1).pricing_attribute36	:=   p_price_attribs.PRICING_ATTRIBUTE36;
   l_pavv_tbl_in(1).pricing_attribute37	:=   p_price_attribs.PRICING_ATTRIBUTE37;
   l_pavv_tbl_in(1).pricing_attribute38	:=   p_price_attribs.PRICING_ATTRIBUTE38;
   l_pavv_tbl_in(1).pricing_attribute39	:=   p_price_attribs.PRICING_ATTRIBUTE39;
   l_pavv_tbl_in(1).pricing_attribute40	:=   p_price_attribs.PRICING_ATTRIBUTE40;
   l_pavv_tbl_in(1).pricing_attribute41	:=   p_price_attribs.PRICING_ATTRIBUTE41;
   l_pavv_tbl_in(1).pricing_attribute42	:=   p_price_attribs.PRICING_ATTRIBUTE42;
   l_pavv_tbl_in(1).pricing_attribute43	:=   p_price_attribs.PRICING_ATTRIBUTE43;
   l_pavv_tbl_in(1).pricing_attribute44	:=   p_price_attribs.PRICING_ATTRIBUTE44;
   l_pavv_tbl_in(1).pricing_attribute45	:=   p_price_attribs.PRICING_ATTRIBUTE45;
   l_pavv_tbl_in(1).pricing_attribute46	:=   p_price_attribs.PRICING_ATTRIBUTE46;
   l_pavv_tbl_in(1).pricing_attribute47	:=   p_price_attribs.PRICING_ATTRIBUTE47;
   l_pavv_tbl_in(1).pricing_attribute48	:=   p_price_attribs.PRICING_ATTRIBUTE48;
   l_pavv_tbl_in(1).pricing_attribute49	:=   p_price_attribs.PRICING_ATTRIBUTE49;
   l_pavv_tbl_in(1).pricing_attribute50	:=   p_price_attribs.PRICING_ATTRIBUTE50;
   l_pavv_tbl_in(1).pricing_attribute51	:=   p_price_attribs.PRICING_ATTRIBUTE51;
   l_pavv_tbl_in(1).pricing_attribute52	:=   p_price_attribs.PRICING_ATTRIBUTE52;
   l_pavv_tbl_in(1).pricing_attribute53	:=   p_price_attribs.PRICING_ATTRIBUTE53;
   l_pavv_tbl_in(1).pricing_attribute54	:=   p_price_attribs.PRICING_ATTRIBUTE54;
   l_pavv_tbl_in(1).pricing_attribute55	:=   p_price_attribs.PRICING_ATTRIBUTE55;
   l_pavv_tbl_in(1).pricing_attribute56	:=   p_price_attribs.PRICING_ATTRIBUTE56;
   l_pavv_tbl_in(1).pricing_attribute57	:=   p_price_attribs.PRICING_ATTRIBUTE57;
   l_pavv_tbl_in(1).pricing_attribute58	:=   p_price_attribs.PRICING_ATTRIBUTE58;
   l_pavv_tbl_in(1).pricing_attribute59	:=   p_price_attribs.PRICING_ATTRIBUTE59;
   l_pavv_tbl_in(1).pricing_attribute60	:=   p_price_attribs.PRICING_ATTRIBUTE60;
   l_pavv_tbl_in(1).pricing_attribute61	:=   p_price_attribs.PRICING_ATTRIBUTE61;
   l_pavv_tbl_in(1).pricing_attribute62	:=   p_price_attribs.PRICING_ATTRIBUTE62;
   l_pavv_tbl_in(1).pricing_attribute63	:=   p_price_attribs.PRICING_ATTRIBUTE63;
   l_pavv_tbl_in(1).pricing_attribute64	:=   p_price_attribs.PRICING_ATTRIBUTE64;
   l_pavv_tbl_in(1).pricing_attribute65	:=   p_price_attribs.PRICING_ATTRIBUTE65;
   l_pavv_tbl_in(1).pricing_attribute66	:=   p_price_attribs.PRICING_ATTRIBUTE66;
   l_pavv_tbl_in(1).pricing_attribute67	:=   p_price_attribs.PRICING_ATTRIBUTE67;
   l_pavv_tbl_in(1).pricing_attribute68	:=   p_price_attribs.PRICING_ATTRIBUTE68;
   l_pavv_tbl_in(1).pricing_attribute69	:=   p_price_attribs.PRICING_ATTRIBUTE69;
   l_pavv_tbl_in(1).pricing_attribute70	:=   p_price_attribs.PRICING_ATTRIBUTE70;
   l_pavv_tbl_in(1).pricing_attribute71	:=   p_price_attribs.PRICING_ATTRIBUTE71;
   l_pavv_tbl_in(1).pricing_attribute72	:=   p_price_attribs.PRICING_ATTRIBUTE72;
   l_pavv_tbl_in(1).pricing_attribute73	:=   p_price_attribs.PRICING_ATTRIBUTE73;
   l_pavv_tbl_in(1).pricing_attribute74	:=   p_price_attribs.PRICING_ATTRIBUTE74;
   l_pavv_tbl_in(1).pricing_attribute75	:=   p_price_attribs.PRICING_ATTRIBUTE75;
   l_pavv_tbl_in(1).pricing_attribute76	:=   p_price_attribs.PRICING_ATTRIBUTE76;
   l_pavv_tbl_in(1).pricing_attribute77	:=   p_price_attribs.PRICING_ATTRIBUTE77;
   l_pavv_tbl_in(1).pricing_attribute78	:=   p_price_attribs.PRICING_ATTRIBUTE78;
   l_pavv_tbl_in(1).pricing_attribute79	:=   p_price_attribs.PRICING_ATTRIBUTE79;
   l_pavv_tbl_in(1).pricing_attribute80	:=   p_price_attribs.PRICING_ATTRIBUTE80;
   l_pavv_tbl_in(1).pricing_attribute81	:=   p_price_attribs.PRICING_ATTRIBUTE81;
   l_pavv_tbl_in(1).pricing_attribute82	:=   p_price_attribs.PRICING_ATTRIBUTE82;
   l_pavv_tbl_in(1).pricing_attribute83	:=   p_price_attribs.PRICING_ATTRIBUTE83;
   l_pavv_tbl_in(1).pricing_attribute84	:=   p_price_attribs.PRICING_ATTRIBUTE84;
   l_pavv_tbl_in(1).pricing_attribute85	:=   p_price_attribs.PRICING_ATTRIBUTE85;
   l_pavv_tbl_in(1).pricing_attribute86	:=   p_price_attribs.PRICING_ATTRIBUTE86;
   l_pavv_tbl_in(1).pricing_attribute87	:=   p_price_attribs.PRICING_ATTRIBUTE87;
   l_pavv_tbl_in(1).pricing_attribute88	:=   p_price_attribs.PRICING_ATTRIBUTE88;
   l_pavv_tbl_in(1).pricing_attribute89	:=   p_price_attribs.PRICING_ATTRIBUTE89;
   l_pavv_tbl_in(1).pricing_attribute90	:=   p_price_attribs.PRICING_ATTRIBUTE90;
   l_pavv_tbl_in(1).pricing_attribute91	:=   p_price_attribs.PRICING_ATTRIBUTE91;
   l_pavv_tbl_in(1).pricing_attribute92	:=   p_price_attribs.PRICING_ATTRIBUTE92;
   l_pavv_tbl_in(1).pricing_attribute93	:=   p_price_attribs.PRICING_ATTRIBUTE93;
   l_pavv_tbl_in(1).pricing_attribute94	:=   p_price_attribs.PRICING_ATTRIBUTE94;
   l_pavv_tbl_in(1).pricing_attribute95	:=   p_price_attribs.PRICING_ATTRIBUTE95;
   l_pavv_tbl_in(1).pricing_attribute96	:=   p_price_attribs.PRICING_ATTRIBUTE96;
   l_pavv_tbl_in(1).pricing_attribute97	:=   p_price_attribs.PRICING_ATTRIBUTE97;
   l_pavv_tbl_in(1).pricing_attribute98	:=   p_price_attribs.PRICING_ATTRIBUTE98;
   l_pavv_tbl_in(1).pricing_attribute99	:=   p_price_attribs.PRICING_ATTRIBUTE99;
   l_pavv_tbl_in(1).pricing_attribute100	:=   p_price_attribs.PRICING_ATTRIBUTE100;

   okc_price_adjustment_pvt.create_price_att_value
   (
      p_api_version		=> l_api_version,
      p_init_msg_list		=> l_init_msg_list,
      x_return_status		=> l_return_status,
      x_msg_count			=> x_msg_count,
      x_msg_data			=> x_msg_data,
      p_pavv_tbl			=> l_pavv_tbl_in,
      x_pavv_tbl			=> l_pavv_tbl_out
   );

    FND_FILE.PUT_LINE (FND_FILE.LOG,'K COVD LINE CREATION :- PRICE ATTRIB STATUS ' || l_return_status);

    If l_return_status = 'S' then
    	   l_priceattrib_id := l_pavv_tbl_out(1).id;
    Else
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'PRICE ATTRIBUTES (SUB LINE)');
	   Raise G_EXCEPTION_HALT_VALIDATION;
    End if;

    End If;

Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
		Null;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End Create_OSO_K_Covered_Levels;


Procedure Create_OSO_Contract_IBNEW
(
	p_extwar_rec		IN	ExtWar_Rec_Type
,     p_contact_tbl_in        IN    OKS_EXTWARPRGM_OSO_PVT.contact_tbl
,     p_salescredit_tbl_in    IN    OKS_EXTWARPRGM_OSO_PVT.salescredit_tbl
,     p_price_attribs_in      IN    OKS_EXTWARPRGM_OSO_PVT.pricing_attributes_type
,     x_chrid                OUT    NOCOPY Number
,	x_return_status	     OUT 	NOCOPY Varchar2
,     x_msg_count            OUT    NOCOPY Number
,     x_msg_data             OUT    NOCOPY Varchar2
)
Is


	l_hdr_rec			K_Header_Rec_Type;
	l_line_rec			K_Line_Service_Rec_Type;
	l_covd_rec			K_Line_Covered_level_Rec_Type;

	l_return_status		Varchar2(5) := OKC_API.G_RET_STS_SUCCESS;
	l_chrid			NUMBER	:= NULL;
	l_lineid			NUMBER	:= NULL;

      Cursor l_party_csr      Is  Select Name From OKX_PARTIES_V
                                  Where  ID1 = p_extwar_rec.hdr_party_id;

      l_party_name            OKX_PARTIES_V.name%TYPE;

--Contact
      l_Contact_tbl_in                OKS_EXTWARPRGM_OSO_PVT.Contact_tbl;

--SalesCredit
      l_salescredit_tbl_in            OKS_EXTWARPRGM_OSO_PVT.SalesCredit_Tbl;

Begin
	x_return_status 	:= OKC_API.G_RET_STS_SUCCESS;
      Okc_context.set_okc_org_context (p_extwar_rec.hdr_org_id, p_extwar_rec.organization_id);

      Open  l_party_csr;
      Fetch l_party_csr Into l_party_name;
      Close l_party_csr;

      l_hdr_rec.contract_number		:= OKC_API.G_MISS_CHAR;
	l_hdr_rec.start_date			:= p_extwar_rec.hdr_sdt;
	l_hdr_rec.end_date			:= p_extwar_rec.hdr_edt;
	l_hdr_rec.sts_code			:= 'ACTIVE';
	l_hdr_rec.class_code			:= 'SVC';
	l_hdr_rec.authoring_org_id		:= p_extwar_rec.hdr_org_id;
	l_hdr_rec.party_id			:= p_extwar_rec.hdr_party_id;
      l_hdr_rec.third_party_role          := p_extwar_rec.hdr_third_party_role;
	l_hdr_rec.bill_to_id			:= p_extwar_rec.hdr_bill_2_id;
	l_hdr_rec.ship_to_id			:= p_extwar_rec.hdr_ship_2_id;
	l_hdr_rec.chr_group			:= p_extwar_rec.hdr_chr_group;
      l_hdr_rec.short_description         := 'CUSTOMER : ' || l_party_name || ' Warranty/Extended Warranty Contract';
      l_hdr_rec.price_list_id             := p_extwar_rec.hdr_price_list_id;
	l_hdr_rec.cust_po_number		:= p_extwar_rec.hdr_cust_po_number;
	l_hdr_rec.agreement_id			:= p_extwar_rec.hdr_agreement_id;
	l_hdr_rec.currency			:= p_extwar_rec.hdr_currency;
	l_hdr_rec.accounting_rule_id		:= p_extwar_rec.hdr_acct_rule_id;
	l_hdr_rec.invoice_rule_id		:= p_extwar_rec.hdr_inv_rule_id;
	l_hdr_rec.order_hdr_id			:= p_extwar_rec.hdr_order_hdr_id;
      l_hdr_rec.payment_term_id           := p_extwar_rec.hdr_payment_term_id;

      l_hdr_rec.merge_type                := p_extwar_rec.merge_type;
      l_hdr_rec.merge_object_id           := p_extwar_rec.merge_object_id;
            l_hdr_rec.first_billon_date           := p_extwar_rec.first_billon_date;
      l_hdr_rec.first_billupto_date            := p_extwar_rec.first_billupto_date ;
      l_hdr_rec.billing_freq           := p_extwar_rec.billing_freq;
      l_hdr_rec.offset_duration           := p_extwar_rec.offset_duration;



      FND_FILE.PUT_LINE (FND_FILE.LOG,'OSO IBNEW :- CREATE HDR STATUS ' || l_return_status );


	OKS_EXTWARPRGM_OSO_PVT.create_k_hdr
	(       p_k_header_rec		=> l_hdr_rec
,             p_Contact_Tbl         => p_Contact_tbl_in
, 		  x_chr_id			=> l_chrid
, 		  x_return_status 	=> l_return_status
,             x_msg_count           => x_msg_count
,             x_msg_data            => x_msg_data
	);

	If Not l_return_status = 'S' then
		Raise G_EXCEPTION_HALT_VALIDATION;
   	End if;

      x_chrid := l_chrid;
      FND_FILE.PUT_LINE (FND_FILE.LOG,'OSO IBNEW :- CREATE HDR STATUS  l_chrid' || l_chrid);

	l_line_rec.k_id		:= l_chrid;
	l_line_rec.k_line_number:= OKC_API.G_MISS_CHAR;
	l_line_rec.org_id		:= p_extwar_rec.hdr_org_id;
	l_line_rec.accounting_rule_id		:= p_extwar_rec.hdr_acct_rule_id;
	l_line_rec.srv_id		:= p_extwar_rec.srv_id;
	l_line_rec.srv_segment1	:= p_extwar_rec.srv_name;
	l_line_rec.srv_desc	:= p_extwar_rec.srv_desc;
	l_line_rec.srv_sdt	:= p_extwar_rec.srv_sdt;
	l_line_rec.srv_edt	:= p_extwar_rec.srv_edt;
	l_line_rec.bill_to_id	:= p_extwar_rec.srv_bill_2_id;
	l_line_rec.ship_to_id	:= p_extwar_rec.srv_ship_2_id;
	l_line_rec.order_line_id:= p_extwar_rec.srv_order_line_id;
	l_line_rec.warranty_flag:= p_extwar_rec.warranty_flag;
	l_line_rec.currency	:= p_extwar_rec.srv_currency;
      l_line_rec.coverage_template_id := p_extwar_rec.srv_Cov_template_id;
      l_line_rec.cust_account := p_extwar_rec.cust_account;
      l_line_rec.l_usage_type := p_extwar_rec.l_usage_type;
      l_line_rec.first_billon_date := p_extwar_rec.first_billon_date;
            l_line_rec.first_billupto_date := p_extwar_rec.first_billupto_date;
      l_line_rec.billing_freq           := p_extwar_rec.billing_freq;
      l_line_rec.offset_duration           := p_extwar_rec.offset_duration;
      l_line_rec.organization_id         := p_extwar_rec.organization_id;
      l_line_rec.period                  := p_extwar_rec.period;
	OKS_EXTWARPRGM_OSO_PVT.create_OSO_k_Service_lines
	( p_k_line_rec		=> l_line_rec
,             p_Contact_Tbl         => p_Contact_tbl_in
,       p_salescredit_tbl_in  => l_SalesCredit_Tbl_in
, 	  x_service_line_id	=> l_lineid
, 	  x_return_status 	=> l_return_status
,       x_msg_count           => x_msg_count
,       x_msg_data            => x_msg_data
	);

      FND_FILE.PUT_LINE (FND_FILE.LOG,'IBNEW :- CREATE LINE STATUS ' || l_return_status );
     If Not l_return_status = 'S' then
		     Raise G_EXCEPTION_HALT_VALIDATION;
	End if;

	l_covd_rec.k_id				:= l_chrid;
	l_covd_rec.Attach_2_Line_id		:= l_lineid;
	l_covd_rec.line_number			:= OKC_API.G_MISS_CHAR;
	l_covd_rec.Customer_Product_Id	:= p_extwar_rec.lvl_cp_id;
	l_covd_rec.Product_Segment1		:= p_extwar_rec.lvl_inventory_name;
	l_covd_rec.Product_Desc			:= p_extwar_rec.lvl_inventory_desc;
	l_covd_rec.Product_Start_Date		:= p_extwar_rec.srv_sdt;
	l_covd_rec.Product_End_Date		:= p_extwar_rec.srv_edt;
	l_covd_rec.Quantity			:= p_extwar_rec.lvl_quantity;
	l_covd_rec.list_price			:= p_extwar_rec.srv_unit_price;
     l_covd_rec.uom_code                 := p_extwar_rec.lvl_uom_code;
	l_covd_rec.negotiated_amount		:= p_extwar_rec.srv_amount;
     l_covd_rec.warranty_flag            := p_extwar_rec.warranty_flag;
     l_covd_rec.product_sts_code	      := p_extwar_rec.lvl_sts_code;
     l_covd_rec.line_renewal_type	      := p_extwar_rec.lvl_line_renewal_type;
     l_covd_rec.currency_code           := p_extwar_rec.srv_currency;
     l_covd_rec.period           := p_extwar_rec.period;
     l_covd_rec.minimum_qty           := p_extwar_rec.minimum_qty;
     l_covd_rec.default_qty           := p_extwar_rec.default_qty;
     l_covd_rec.amcv_flag           := p_extwar_rec.amcv_flag;
     l_covd_rec.fixed_qty           := p_extwar_rec.fixed_qty;
     l_covd_rec.duration           := p_extwar_rec.duration;
     l_covd_rec.level_yn           := p_extwar_rec.level_yn;
     l_covd_rec.base_reading           := p_extwar_rec.base_reading;
	l_covd_rec.srv_id		:= p_extwar_rec.srv_id;
    l_covd_rec.org_id       := p_extwar_rec.hdr_org_id;

      OKS_EXTWARPRGM_OSO_PVT.Create_OSO_K_Covered_Levels
      (
                      	p_k_covd_rec		     => l_covd_rec
                  ,     p_PRICE_ATTRIBS              => p_price_attribs_in
                  ,	x_return_status		     => l_return_status
                  ,     x_msg_count                  => x_msg_count
                  ,     x_msg_data                   => x_msg_data
      );

      FND_FILE.PUT_LINE (FND_FILE.LOG,'IBNEW :- CREATE COV STATUS ' || l_return_status );


     	If Not l_return_status = 'S' then
		Raise G_EXCEPTION_HALT_VALIDATION;
	End if;
        Update Okc_k_headers_b
        Set Estimated_amount = (Select sum(price_negotiated) from Okc_k_lines_v
                                Where dnz_chr_id = l_chrid)
        Where id = l_chrid ;
	Launch_Workflow (         'INSTALL BASE ACTIVITY : NEW ' || fnd_global.local_chr(10) ||
                                'Contract Number       :     ' || get_contract_number (l_chrid) || fnd_global.local_chr(10) ||
                                'Service Added         :     ' || p_extwar_rec.srv_name || fnd_global.local_chr(10) ||
                                'Customer Product      :     ' || p_extwar_rec.lvl_cp_id
                       );

Exception
	When  G_EXCEPTION_HALT_VALIDATION Then
		x_return_status := l_return_status;
		Null;
	When  Others Then
	      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

End Create_OSO_Contract_IBNEW;




END OKS_EXTWARPRGM_OSO_PVT;

/
