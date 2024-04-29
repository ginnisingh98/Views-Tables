--------------------------------------------------------
--  DDL for Package Body OKS_ENT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENT_UTIL_PVT" AS
/* $Header: OKSREUTB.pls 120.0 2005/05/25 17:56:14 appldev noship $ */

  FUNCTION get_duration_period(p_start_date IN Date, p_end_date IN Date, inp_type Varchar2) RETURN Varchar2
  IS
	x_duration  Number;
	x_timeunit  Varchar2(25);
	x_return_status Varchar2(1);
  BEGIN

	OKC_TIME_UTIL_PUB.get_duration(p_start_date	 => p_start_date,
					   p_end_date	 => p_end_date,
					   x_duration	 => x_duration,
					   x_timeunit	 => x_timeunit,
					   x_return_status => x_return_status);
	IF inp_type = 'D'
	THEN
		return(x_duration);
	ELSIF inp_type = 'P'
	THEN
		return(x_timeunit);
	END IF;
  END get_duration_period;

  FUNCTION get_contract_amount(p_hdr_id IN Number) RETURN Number
  IS
	---Except Usage.
	CURSOR l_amt_csr IS
	SELECT SUM(L.price_negotiated)
	FROM	 OKC_K_LINES_B	 L,
		 OKC_LINE_STYLES_B S
	WHERE	 S.ID = L.LSE_ID
	AND    S.ID IN(7, 8, 9, 10, 11, 18, 25, 35)
	AND	 L.DNZ_CHR_ID = NVL(p_hdr_id, L.DNZ_CHR_ID);

	l_amt		Number;
  BEGIN
	OPEN	l_amt_csr;
	FETCH l_amt_csr INTO l_amt;
	CLOSE l_amt_csr;
	RETURN(l_amt);
  END get_contract_amount;

  FUNCTION get_party(p_hdr_id IN Number) RETURN Varchar2
  IS
	CURSOR l_party_csr IS
	SELECT P.OBJECT1_ID1
	FROM	 OKC_K_HEADERS_B		 H
		,OKC_K_PARTY_ROLES_B	 P
	WHERE	H.ID			= P.DNZ_CHR_ID
      AND   P.JTOT_OBJECT1_CODE = 'OKX_PARTY'
	AND	H.ID 			= p_hdr_id;

	l_party_id	Varchar2(40);

  BEGIN
	OPEN	l_party_csr;
	FETCH l_party_csr INTO l_party_id;
	CLOSE l_party_csr;

	RETURN(l_party_id);
  END get_party;

  FUNCTION get_billtoshipto(p_hdr_id	IN Number --DEFAULT NULL
				   ,p_line_id	IN Number --DEFAULT NULL
				   ,p_inp_type	IN Varchar2) RETURN Varchar2
  IS

  /*
	CURSOR l_bth_csr IS
		SELECT RL.OBJECT1_ID1
		FROM	OKC_RULE_GROUPS_B 	RG,
			OKC_RULES_B			RL
		WHERE	RG.dnz_CHR_ID = p_hdr_id
		AND     RG.cle_id Is Null
		AND	RG.ID	= RL.RGP_ID
		AND	RL.JTOT_OBJECT1_CODE = p_inp_type;

	CURSOR l_btl_csr IS
		SELECT RL.OBJECT1_ID1
		FROM	OKC_RULE_GROUPS_B 	RG,
			OKC_RULES_B			RL
		WHERE	RG.CLE_ID = p_line_id
		AND	RG.ID	= RL.RGP_ID
		AND	RL.JTOT_OBJECT1_CODE = p_inp_type;
*/

	CURSOR l_bth_csr IS
		SELECT  CHR.BILL_TO_SITE_USE_ID,CHR.SHIP_TO_SITE_USE_ID
		FROM	OKC_K_HEADERS_B CHR
		WHERE	CHR.ID = p_hdr_id;

	CURSOR l_btl_csr IS
		SELECT  CLE.BILL_TO_SITE_USE_ID,CLE.SHIP_TO_SITE_USE_ID
		FROM	OKC_K_LINES_B CLE
		WHERE	CLE.ID = p_line_id;


	l_bt_id	 number ;
    l_st_id  number ;

  BEGIN

  	l_bt_id	 := Null;
    l_st_id  := null;

	IF p_line_id IS NOT NULL
	THEN
		OPEN	l_btl_csr;
		FETCH l_btl_csr INTO l_bt_id,l_st_id;
		CLOSE l_btl_csr;
	ELSIF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_bth_csr;
		FETCH l_bth_csr INTO l_bt_id,l_st_id;
		CLOSE l_bth_csr;
	END IF;
    IF p_inp_type = 'OKX_BILLTO' then
    	RETURN l_bt_id;
    elsif p_inp_type = 'OKX_SHIPTO' then
    	RETURN l_st_id;
    end if;
  END get_billtoshipto;

  FUNCTION get_pricelist(p_hdr_id	IN Number --DEFAULT NULL
				,p_line_id	IN Number --DEFAULT NULL
				,p_inp_type	IN Varchar2) RETURN Varchar2
  IS
  /*
	CURSOR l_plh_csr IS
	SELECT RL.OBJECT1_ID1, PL.CURRENCY_CODE
	FROM
		OKC_RULE_GROUPS_B		RG,
		OKC_RULES_B			RL,
		OKX_LIST_HEADERS_V	PL
	WHERE
			RG.dnz_CHR_ID		  = p_hdr_id
		AND    	RG.cle_id Is Null
		AND	RG.ID			  = RL.RGP_ID
		AND	RL.OBJECT1_ID1	  = PL.ID1
		AND	RL.OBJECT1_ID2	  = PL.ID2
            AND   RL.JTOT_OBJECT1_CODE = 'OKX_PRICE'
            AND   PL.LIST_TYPE_CODE   = 'PRL';

	CURSOR l_pll_csr IS
	SELECT PL.ID1, PL.CURRENCY_CODE
	FROM
		OKC_RULE_GROUPS_B		RG,
		OKC_RULES_B			RL,
		OKX_LIST_HEADERS_V	PL
	WHERE
			RG.CLE_ID		= p_line_id
		AND	RG.ID			  = RL.RGP_ID
		AND	RL.OBJECT1_ID1	  = PL.ID1
		AND	RL.OBJECT1_ID2	  = PL.ID2
            AND   RL.JTOT_OBJECT1_CODE = 'OKX_PRICE'
            AND   PL.LIST_TYPE_CODE   = 'PRL';
*/

	CURSOR l_plh_csr IS
		SELECT  CHR.PRICE_LIST_ID,CHR.CURRENCY_CODE
		FROM	OKC_K_HEADERS_B CHR
		WHERE	CHR.ID = p_hdr_id;

	CURSOR l_pll_csr IS
		SELECT  CLE.PRICE_LIST_ID,CLE.CURRENCY_CODE
		FROM	OKC_K_LINES_B CLE
		WHERE	CLE.ID = p_line_id;

	l_pl_id		    Varchar2(40);
	l_curr_code		Varchar2(15);

  BEGIN

	l_pl_id		:= Null;
	l_curr_code	:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_plh_csr;
		FETCH l_plh_csr INTO l_pl_id, l_curr_code;
		CLOSE l_plh_csr;
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN	l_pll_csr;
		FETCH l_pll_csr INTO l_pl_id, l_curr_code;
		CLOSE l_pll_csr;
	END IF;

	IF p_inp_type = 'P'
	THEN
		return(l_pl_id);
	ELSIF p_inp_type = 'C'
	THEN
		return(l_curr_code);
	END IF;
  END get_pricelist;

  FUNCTION get_discount(p_hdr_id	IN Number --DEFAULT NULL
				,p_line_id	IN Number --DEFAULT NULL
                ) RETURN Varchar2
  IS
  /*
	CURSOR l_dish_csr IS
	SELECT DI.ID1
	FROM
		OKC_RULE_GROUPS_B		RG,
		OKC_RULES_B			RL,
		OKX_LIST_HEADERS_V	DI
	WHERE
			RG.dnz_CHR_ID		  = p_hdr_id
		AND    RG.cle_id Is Null
		AND	RG.ID			  = RL.RGP_ID
		AND	RL.OBJECT1_ID1	  = DI.ID1
		AND	RL.OBJECT1_ID2	  = DI.ID2
            AND   RL.JTOT_OBJECT1_CODE = 'OKX_DISCOUNT'
		AND   DI.LIST_TYPE_CODE = 'DTL';

	CURSOR l_disl_csr IS
	SELECT DI.ID1
	FROM
		OKC_RULE_GROUPS_B		RG,
		OKC_RULES_B			RL,
		OKX_LIST_HEADERS_V	DI
	WHERE
			RG.CLE_ID		= p_line_id
		AND	RG.ID			  = RL.RGP_ID
		AND	RL.OBJECT1_ID1	  = DI.ID1
		AND	RL.OBJECT1_ID2	  = DI.ID2
            AND   RL.JTOT_OBJECT1_CODE = 'OKX_DISCOUNT'
		AND   DI.LIST_TYPE_CODE = 'DTL';
*/


	CURSOR l_disl_csr IS
		SELECT  OKSCLE.DISCOUNT_LIST
		FROM	OKS_K_LINES_B OKSCLE
		WHERE	OKSCLE.CLE_ID = p_line_id;


	l_dis_id		Varchar2(40); -- := Null;

  BEGIN

  	l_dis_id		:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
    /*
		OPEN	l_dish_csr;
		FETCH l_dish_csr INTO l_dis_id;
		CLOSE l_dish_csr;
    */
        l_dis_id    := '';
		return(l_dis_id);
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN  l_disl_csr;
		FETCH l_disl_csr INTO l_dis_id;
		CLOSE l_disl_csr;
		return(l_dis_id);
	END IF;
  END get_discount;

  FUNCTION	get_acc_rule(p_hdr_id	IN Number
				,p_line_id	IN Number) RETURN Varchar2
  IS
  /*
	CURSOR l_acch_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.dnz_CHR_ID		    = p_hdr_id
	AND     RGP.cle_id Is Null
	AND	RGP.ID		    = RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_ACCTRULE';

	CURSOR l_accl_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.CLE_ID		= p_line_id
	AND	RGP.ID		   = RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_ACCTRULE';
*/
	CURSOR l_acch_csr IS
		SELECT  OKSCHR.ACCT_RULE_ID
		FROM	OKS_K_HEADERS_B OKSCHR
		WHERE	OKSCHR.CHR_ID = p_hdr_id;

	CURSOR l_accl_csr IS
		SELECT  OKSCLE.ACCT_RULE_ID
		FROM	OKS_K_LINES_B OKSCLE
		WHERE	OKSCLE.CLE_ID = p_line_id;

	l_acc_id		Varchar2(40);

  BEGIN

	l_acc_id		:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_acch_csr;
		FETCH l_acch_csr INTO l_acc_id;
		CLOSE l_acch_csr;
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN	l_accl_csr;
		FETCH l_accl_csr INTO l_acc_id;
		CLOSE l_accl_csr;
	END IF;

	return(l_acc_id);

  END get_acc_rule;

  FUNCTION	get_inv_rule(p_hdr_id	IN Number
				,p_line_id	IN Number) RETURN Varchar2
  IS
  /*
	CURSOR l_invh_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.dnz_CHR_ID		    = p_hdr_id
	AND     RGP.cle_id Is Null
	AND	RGP.ID		    = RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_INVRULE';

	CURSOR l_invl_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.CLE_ID		= p_line_id
	AND	RGP.ID		   = RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_INVRULE';
*/

	CURSOR l_invh_csr IS
		SELECT  CHR.INV_RULE_ID
		FROM	OKC_K_HEADERS_B CHR
		WHERE	CHR.ID = p_hdr_id;

	CURSOR l_invl_csr IS
		SELECT  CLE.INV_RULE_ID
		FROM	OKC_K_LINES_B CLE
		WHERE	CLE.ID = p_line_id;

	l_inv_id		Varchar2(40);

  BEGIN

	l_inv_id		:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_invh_csr;
		FETCH l_invh_csr INTO l_inv_id;
		CLOSE l_invh_csr;
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN	l_invl_csr;
		FETCH l_invl_csr INTO l_inv_id;
		CLOSE l_invl_csr;
	END IF;

	return(l_inv_id);

  END get_inv_rule;

  FUNCTION	get_billingprofile(p_hdr_id	IN Number
					,p_line_id	IN Number) RETURN Varchar2
  IS
  /*
	CURSOR l_bph_csr IS
	SELECT RL.RULE_INFORMATION1
	FROM	 OKC_RULE_GROUPS_B	RG,
		 OKC_RULES_B		RL
	WHERE	 RG.dnz_ChR_ID	= p_hdr_id
	AND      RG.cle_id Is Null
	AND	 RG.ID	= RL.RGP_ID
	AND	 RL.RULE_INFORMATION_CATEGORY = 'BPF';

	CURSOR l_bpl_csr IS
	SELECT RL.RULE_INFORMATION1
	FROM	 OKC_RULE_GROUPS_B	RG,
		 OKC_RULES_B		RL
	WHERE	 RG.Cle_id	= p_line_id
	AND	 RG.ID	= RL.RGP_ID
	AND	 RL.RULE_INFORMATION_CATEGORY = 'BPF';
*/
	CURSOR l_bph_csr IS
		SELECT  OKSCHR.BILLING_PROFILE_ID
		FROM	OKS_K_HEADERS_B OKSCHR
		WHERE	OKSCHR.CHR_ID = p_hdr_id;

	l_bp_id		Varchar2(40);

  BEGIN

  	l_bp_id		:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_bph_csr;
		FETCH l_bph_csr INTO l_bp_id;
		CLOSE l_bph_csr;

	ELSIF p_line_id IS NOT NULL
	THEN
    /*
		OPEN	l_bpl_csr;
		FETCH l_bpl_csr INTO l_bp_id;
		CLOSE l_bpl_csr;
    */
      l_bp_id       := '';
	END IF;

	return(l_bp_id);

  END get_billingprofile;

  FUNCTION	get_billingschedule(p_hdr_id	 IN Number
					 ,p_line_id	 IN Number
					 ,p_inp_type IN Varchar2) RETURN Varchar2
  IS
/*
	CURSOR l_bsh_csr IS
	SELECT SUBSTR(RL.RULE_INFORMATION2,1,3) 				BF,
		 DECODE(RL.RULE_INFORMATION5, 0, 'ADV', 'ARR')   	BM,
		 TO_NUMBER(RL.RULE_INFORMATION5)				ROD,
		 RL.RULE_INFORMATION3				            FBT,
		 RL.RULE_INFORMATION4				            FBO
	FROM	 OKC_RULE_GROUPS_B	RG,
		 OKC_RULES_B		RL
	WHERE	 RG.dnz_CHR_ID	= p_hdr_id
	AND      RG.cle_id Is Null
	AND	 RG.ID	= RL.RGP_ID
	AND	 RL.RULE_INFORMATION_CATEGORY = 'SBG';

	CURSOR l_bsl_csr IS
	SELECT SUBSTR(RL.RULE_INFORMATION2,1,3) 				BF,
		 DECODE(RL.RULE_INFORMATION5, 0, 'ADV', 'ARR')   	BM,
		 TO_NUMBER(RL.RULE_INFORMATION5)				ROD,
		 RL.RULE_INFORMATION3				            FBT,
		 RL.RULE_INFORMATION4				            FBO
	FROM	 OKC_RULE_GROUPS_B	RG,
		 OKC_RULES_B		RL
	WHERE	 RG.Cle_ID	= p_line_id
	AND	 RG.ID	= RL.RGP_ID
	AND	 RL.RULE_INFORMATION_CATEGORY = 'SBG';
*/

	l_bfrq		Varchar2(40);
	l_bmth		Varchar2(3);
	l_brod		Number;
	l_bfbt		Varchar2(450);
	l_bfbo		Varchar2(450);


  BEGIN

	l_bfrq		:= Null;
	l_bmth		:= Null;
	l_brod		:= Null;
	l_bfbt		:= Null;
	l_bfbo		:= Null;

  -- this information is not valid anymore..this private function
  -- should not be used for getting billing schedule information.
  /*
	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_bsh_csr;
		FETCH l_bsh_csr INTO l_bfrq, l_bmth, l_brod, l_bfbt, l_bfbo;
		CLOSE l_bsh_csr;
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN	l_bsl_csr;
		FETCH l_bsl_csr INTO l_bfrq, l_bmth, l_brod, l_bfbt, l_bfbo;
		CLOSE l_bsl_csr;
	END IF;
*/

	IF p_inp_type = 'F'
	THEN
		return(l_bfrq);
	ELSIF p_inp_type = 'M'
	THEN
		return(l_bmth);
	ELSIF p_inp_type = 'R'
	THEN
		return(l_brod);
	ELSIF p_inp_type = 'T'
	THEN
		return(l_bfbt);
	ELSIF p_inp_type = 'O'
	THEN
		return(l_bfbo);
	END IF;

  END get_billingschedule;

  FUNCTION	get_renternotes(p_hdr_id	IN Number
				   ,p_inp_type	IN Varchar2) RETURN CLOB
  IS
/*
	CURSOR l_notes_csr IS
	SELECT REN.TEXT
	FROM	 OKC_K_ARTICLES_B	 KAR,
		 OKC_K_ARTICLES_TL REN,
		 FND_LOOKUPS	SBR
	WHERE	KAR.ID            = REN.ID
	AND   REN.SOURCE_LANG   = USERENV('LANG')
	AND   KAR.CHR_ID 		= p_hdr_id
	AND   KAR.CAT_TYPE      = 'NSD'
	AND	SBR.LOOKUP_CODE 	= KAR.SBT_CODE
	AND   SBR.LOOKUP_TYPE	= 'OKC_OPERATION'
	AND   SBR.LOOKUP_CODE	= p_inp_type;
*/
	l_notes	CLOB;

  BEGIN
-- due to a major change in articles and Terms and conditions datamodel...
-- this private function is not valid anymore.
/*
	OPEN	l_notes_csr;
	FETCH l_notes_csr into l_notes;
	CLOSE l_notes_csr;
*/
	return(l_notes);

  END get_renternotes;

  FUNCTION	get_terms(p_hdr_id	 IN Number
			   ,p_line_id	 IN Number) RETURN Varchar2
  IS
  /*
	CURSOR l_termsh_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.dnz_CHR_ID		= p_hdr_id
	AND     RGP.cle_id  Is Null
	AND	RGP.ID		= RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_RPAYTERM';

	CURSOR l_termsl_csr IS
	SELECT RLS.OBJECT1_ID1
	FROM	OKC_RULE_GROUPS_B		RGP,
		OKC_RULES_B			RLS
	WHERE	RGP.Cle_ID		= p_line_id
	AND	RGP.ID		= RLS.RGP_ID
      AND   RLS.JTOT_OBJECT1_CODE = 'OKX_RPAYTERM';
*/

	CURSOR l_termsh_csr IS
		SELECT  CHR.PAYMENT_TERM_ID
		FROM	OKC_K_HEADERS_B CHR
		WHERE	CHR.ID = p_hdr_id;

	CURSOR l_termsl_csr IS
		SELECT  CLE.PAYMENT_TERM_ID
		FROM	OKC_K_LINES_B CLE
		WHERE	CLE.ID = p_line_id;

	l_terms_id		Varchar2(40);

  BEGIN

  	l_terms_id		:= Null;

	IF p_hdr_id IS NOT NULL
	THEN
		OPEN	l_termsh_csr;
		FETCH l_termsh_csr INTO l_terms_id;
		CLOSE l_termsh_csr;
	ELSIF p_line_id IS NOT NULL
	THEN
		OPEN	l_termsl_csr;
		FETCH l_termsl_csr INTO l_terms_id;
		CLOSE l_termsl_csr;
	END IF;

	return(l_terms_id);
  END get_terms;

  FUNCTION get_product(p_line_id IN Number) RETURN l_pdt_rec
  IS

	CURSOR l_pdt_csr IS
	SELECT PDT.ID1,
		 PDT.QUANTITY
	FROM	 OKC_K_LINES_B			LIN,
		 OKC_K_ITEMS			ITM,
		 OKX_CUSTOMER_PRODUCTS_V	PDT
	WHERE	 LIN.ID		= ITM.CLE_ID
	AND	 ITM.OBJECT1_ID1	= PDT.ID1
	AND	 ITM.OBJECT1_ID2	= PDT.ID2
      AND    ITM.JTOT_OBJECT1_CODE = 'OKX_CUSTPROD'
	AND	 LIN.ID		= p_line_id;

	l_rec_type		l_pdt_rec;

  BEGIN

	OPEN	l_pdt_csr;
	FETCH l_pdt_csr INTO l_rec_type;
	CLOSE	l_pdt_csr;

	RETURN(l_rec_type);

  END get_product;

  FUNCTION get_product(p_line_id IN Number, p_inp_type IN Varchar2) RETURN Varchar2
  IS

	CURSOR l_pdt_csr IS
/*
	SELECT PDT.ID1,
		 PDT.CUSTOMER_ID,
		 CUS.NAME,
		 PDT.INSTALL_SITE_USE_ID,
		 SIT.NAME PARTY_SITE_NAME
	FROM	 OKC_K_LINES_B			LIN,
		 OKC_K_ITEMS			ITM,
		 OKX_CUSTOMER_PRODUCTS_V	PDT,
		 OKX_CUSTOMER_ACCOUNTS_V	CUS,
             OKX_PARTIES_V                PTY,
		 OKX_PARTY_SITES_V		SIT --OKX_PARTY_SITE_USES_V		SIT
	WHERE	 LIN.ID		    = ITM.CLE_ID
	AND	 ITM.OBJECT1_ID1	    = PDT.ID1
	AND	 ITM.OBJECT1_ID2	    = PDT.ID2
	AND	 PDT.CUSTOMER_ID	= CUS.ID1
      AND    PTY.ID1 = CUS.PARTY_ID
	AND	 PDT.INSTALL_SITE_USE_ID = SIT.PARTY_SITE_ID
	AND	 LIN.ID		= p_line_id;
*/
    	SELECT PDT.instance_id ID1, --PDT.ID1,
		 PDT.owner_party_account_id customer_id, --PDT.CUSTOMER_ID,
		 CUS.NAME cusname,
		 PDT.install_location_id install_location_id, --PDT.INSTALL_SITE_USE_ID,
		 SIT.NAME PARTY_SITE_NAME
	FROM	 OKC_K_LINES_B			LIN,
		 OKC_K_ITEMS			ITM,
		 CSI_ITEM_INSTANCES PDT, --OKX_CUSTOMER_PRODUCTS_V	PDT,
		 OKX_CUSTOMER_ACCOUNTS_V	CUS,
             OKX_PARTIES_V                PTY,
		 OKX_PARTY_SITES_V		SIT --OKX_PARTY_SITE_USES_V
	WHERE	 LIN.ID		    = ITM.CLE_ID
	AND	 ITM.OBJECT1_ID1	    = PDT.Inventory_item_id --PDT.ID1
	AND	 ITM.OBJECT1_ID2	    = PDT.Inv_Master_Organization_Id --PDT.ID2
    and  PDT.owner_party_account_id = CUS.ID1 --	AND	 PDT.CUSTOMER_ID	= CUS.ID1
    AND  PTY.ID1 = CUS.PARTY_ID
	AND	 PDT.install_location_id = SIT.ID1 --PDT.INSTALL_SITE_USE_ID = SIT.PARTY_SITE_ID
	AND	 LIN.ID		= p_line_id;

	l_pdt_id		Varchar2(40);
	l_cust_id		Varchar2(40);
	l_cust_name		Varchar2(255);
	l_site_id		Varchar2(40);
	l_site_name		Varchar2(40);
  BEGIN

	OPEN	l_pdt_csr;
	FETCH l_pdt_csr INTO l_pdt_id, l_cust_id, l_cust_name, l_site_id, l_site_name;
	CLOSE	l_pdt_csr;

	IF p_inp_type = 'PRDT'
	THEN
		RETURN(l_pdt_id);
	ELSIF p_inp_type = 'CUST'
	THEN
		RETURN(l_cust_id);
	ELSIF p_inp_type = 'NAME'
	THEN
		RETURN(l_cust_name);
	ELSIF p_inp_type = 'SITE'
	THEN
		RETURN(l_site_id);
	ELSIF p_inp_type = 'LOC'
	THEN
		RETURN(l_site_name);
	ELSE
		RETURN(Null);
	END IF;
  END get_product;

  FUNCTION get_system(p_line_id IN Number, p_org_id IN Number) RETURN l_sys_rec
  IS

	CURSOR l_sys_csr IS
	SELECT SY.ID1,
		 SY.NAME
	FROM	 OKC_K_HEADERS_B        HD,
             OKC_K_LINES_B		KL,
		 OKC_K_ITEMS		IT,
		 OKX_SYSTEMS_V		SY
	WHERE	 HD.ID            = KL.DNZ_CHR_ID
      AND    KL.ID		= IT.CLE_ID
	AND	 IT.OBJECT1_ID1	= SY.ID1
	AND	 IT.OBJECT1_ID2	= SY.ID2
      AND    IT.JTOT_OBJECT1_CODE = 'OKX_COVSYST'
      AND    KL.ID = p_line_id
      AND    HD.AUTHORING_ORG_ID = p_org_id;

	l_rec_type		l_sys_rec;

  BEGIN

	OPEN	l_sys_csr;
	FETCH l_sys_csr INTO l_rec_type;
	CLOSE	l_sys_csr;

	RETURN(l_rec_type);
  END get_system;

  FUNCTION get_system(p_line_id IN Number, p_inp_type IN Varchar2, p_org_id IN Number) RETURN Varchar2
  IS

-- commented as part of fix for bug 3597850
/*
	CURSOR l_sys_csr IS
	SELECT SY.ID1,
		 SY.NAME
	FROM	 OKC_K_HEADERS_B        HD,
             OKC_K_LINES_B		KL,
             OKC_K_ITEMS IT,
--		 OKC_RULE_GROUPS_B	RG,
--		 OKC_RULES_B		RL,
		 OKX_SYSTEMS_V		SY
	WHERE	 HD.ID            = KL.DNZ_CHR_ID
--      AND    KL.ID		= RG.CLE_ID
--	AND	 RG.ID		= RL.RGP_ID
	AND	 IT.OBJECT1_ID1	= SY.ID1
	AND	 IT.OBJECT1_ID2	= SY.ID2
    and  IT.jtot_object1_code = 'OKX_COVSYS'
      AND    HD.AUTHORING_ORG_ID = p_org_id;
*/

	l_sys_id		Varchar2(40);
	l_sys_name		Varchar2(50);

  BEGIN

	l_sys_id		:= '-99';
	l_sys_name		:= '  ';

-- commented as part of fix for bug 3597850
-- this function not used anywhere, so stubbed out.
/*
	OPEN	l_sys_csr;
	FETCH l_sys_csr INTO l_sys_id, l_sys_name;
	CLOSE	l_sys_csr;
*/
	IF p_inp_type = 'SYSID'
	THEN
		RETURN(l_sys_id);
	ELSIF	p_inp_type = 'SYSNAME'
	THEN
		RETURN(l_sys_name);
	ELSE
		RETURN(Null);
	END IF;

  END get_system;

  FUNCTION get_invitem(p_line_id IN Number, p_organization_id IN Number) RETURN l_inv_rec
  IS

	CURSOR l_inv_csr IS
	SELECT V.ID1,
		 V.DESCRIPTION
	FROM	 OKC_K_LINES_B		L,
		 OKC_K_ITEMS		I,
		 OKX_SYSTEM_ITEMS_V	V,
             OKC_K_HEADERS_B        H
	WHERE	 L.ID		= I.CLE_ID
	AND	 I.OBJECT1_ID1 = V.ID1
	AND	 I.OBJECT1_ID2 = V.ID2
      AND    I.JTOT_OBJECT1_CODE = 'OKX_COVITEM'
	AND	 L.ID = p_line_id
      AND    H.ID = L.DNZ_CHR_ID
      AND    H.INV_ORGANIZATION_ID = p_organization_id;

	l_rec_type		l_inv_rec;

  BEGIN

	OPEN	l_inv_csr;
	FETCH l_inv_csr INTO l_rec_type;
	CLOSE	l_inv_csr;

	RETURN(l_rec_type);

  END get_invitem;

  FUNCTION get_invitem(p_line_id IN Number, p_inp_type Varchar2, p_organization_id IN Number) RETURN Varchar2
  IS

	CURSOR l_inv_csr IS
	SELECT V.ID1,
		 V.DESCRIPTION
	FROM	 OKC_K_LINES_B		L,
		 OKC_K_ITEMS		I,
		 OKX_SYSTEM_ITEMS_V	V,
             OKC_K_HEADERS_B        H
	WHERE	 L.ID		= I.CLE_ID
	AND	 I.OBJECT1_ID1 = V.ID1
	AND	 I.OBJECT1_ID2 = V.ID2
	AND	 L.ID = p_line_id
      AND    H.ID = L.DNZ_CHR_ID
      AND    H.inv_organization_id = p_organization_id;

	l_item_id		Varchar2(40);
	l_item_name		Varchar2(240);

  BEGIN

	OPEN	l_inv_csr;
	FETCH l_inv_csr INTO l_item_id, l_item_name;
	CLOSE	l_inv_csr;

	IF p_inp_type = 'ITEMID'
	THEN
		RETURN(l_item_id);
	ELSIF p_inp_type = 'ITEMNAME'
	THEN
		RETURN(l_item_name);
	ELSE
		RETURN(Null);
	END IF;
  END get_invitem;

  FUNCTION get_qtyrate_rule(p_line_id IN Number) RETURN l_qtyrate_rec
  IS
/*
	CURSOR l_qrr_csr IS
	SELECT RQR.RULE_INFORMATION6			DEFAULT_AMCV_FLAG
		,TO_NUMBER(RQR.RULE_INFORMATION5)	DEFAULT_QTY
		,RQR.RULE_INFORMATION11			DEFAULT_UOM
		,TO_NUMBER(RQR.RULE_INFORMATION8)	DEFAULT_DURATION
		,RQR.RULE_INFORMATION2			DEFAULT_PERIOD
		,TO_NUMBER(RQR.RULE_INFORMATION4)	MINIMUM_QTY
		,RQR.RULE_INFORMATION11			MINIMUM_UOM
		,TO_NUMBER(RQR.RULE_INFORMATION8)	MINIMUM_DURATION
		,RQR.RULE_INFORMATION2			MINIMUM_PERIOD
		,TO_NUMBER(RQR.RULE_INFORMATION7)	FIXED_QTY
		,RQR.RULE_INFORMATION11			FIXED_UOM
		,TO_NUMBER(RQR.RULE_INFORMATION8)	FIXED_DURATION
		,RQR.RULE_INFORMATION2			FIXED_PERIOD
		,RQR.RULE_INFORMATION9			LEVEL_FLAG
	FROM	 OKC_K_LINES_B		LIN,
		 OKC_RULE_GROUPS_B	RGP,
		 OKC_RULES_B		RQR
	WHERE	 LIN.ID				 = RGP.CLE_ID
	AND	 RGP.ID				 = RQR.RGP_ID
	AND	 RQR.RULE_INFORMATION_CATEGORY = 'QRE'
	AND	 LIN.ID				 = p_line_id;
*/

	l_rec_type		l_qtyrate_rec;
  BEGIN
-- not valid anymore

/*
	OPEN	l_qrr_csr;
	FETCH l_qrr_csr INTO l_rec_type;
	CLOSE	l_qrr_csr;
*/

	RETURN(l_rec_type);

  END get_qtyrate_rule;

  FUNCTION	get_taxrule(p_hdr_id IN Number, p_inp_type IN Varchar2) RETURN Varchar2
  IS

/*
   CURSOR l_tax_csr IS
   SELECT object1_id1 TAX_EXEMPTION, object2_id1 TAX_STATUS
   FROM   OKC_K_HEADERS_B HD,
          OKC_RULE_GROUPS_B RG,
          OKC_RULES_B RL
   WHERE  HD.ID = RG.DNZ_CHR_ID
   AND    RG.ID = RL.RGP_ID
   AND    RL.RULE_INFORMATION_CATEGORY = 'TAX'
   AND    HD.ID = p_hdr_id;
*/

	CURSOR l_tax_csr IS
		SELECT  to_char(OKSCHR.TAX_EXEMPTION_ID),OKSCHR.TAX_STATUS
		FROM	OKS_K_HEADERS_B OKSCHR
		WHERE	OKSCHR.CHR_ID = p_hdr_id;

   l_object1_id1 varchar2(40); --OKC_RULES_B.OBJECT1_ID1%TYPE;
   l_object2_id1 varchar2(200); --OKC_RULES_B.OBJECT1_ID2%TYPE;

  BEGIN
    IF p_inp_type = 'TE' THEN
       OPEN  l_tax_csr;
       FETCH l_tax_csr INTO l_object1_id1, l_object2_id1;
       CLOSE l_tax_csr;

       RETURN(l_object1_id1);
    ELSIF p_inp_type = 'TS' THEN
       OPEN  l_tax_csr;
       FETCH l_tax_csr INTO l_object1_id1, l_object2_id1;
       CLOSE l_tax_csr;

       RETURN(l_object2_id1);
    END IF;

  END get_taxrule;

  FUNCTION	get_convrule(p_hdr_id IN Number) RETURN Varchar2
  IS
/*
   CURSOR l_cvn_csr IS
   SELECT object1_id1
   FROM   OKC_K_HEADERS_B HD,
          OKC_RULE_GROUPS_B RG,
          OKC_RULES_B RL
   WHERE  HD.ID = RG.DNZ_CHR_ID
   AND    RG.ID = RL.RGP_ID
   AND    RL.RULE_INFORMATION_CATEGORY = 'CVN'
   AND    RL.JTOT_OBJECT1_CODE = 'OKX_CONVTYPE'
   AND    HD.ID = p_hdr_id;
*/

	CURSOR l_cvn_csr IS
		SELECT  CHR.CONVERSION_TYPE
		FROM	OKC_K_HEADERS_B CHR
		WHERE	CHR.ID = p_hdr_id;

   l_object1_id1 varchar2(40); --OKC_RULES_B.OBJECT1_ID1%TYPE;

  BEGIN

       OPEN  l_cvn_csr;
       FETCH l_cvn_csr INTO l_object1_id1;
       CLOSE l_cvn_csr;

       RETURN(l_object1_id1);

  END get_convrule;

  FUNCTION	get_agreement(p_hdr_id IN Number) RETURN Number
  IS
   CURSOR l_agr_csr IS
   SELECT isa_agreement_id
   FROM   OKC_K_HEADERS_B HD,
          OKC_GOVERNANCES GV
   WHERE  HD.ID = GV.DNZ_CHR_ID
   AND    HD.ID = p_hdr_id;

   l_agreement_id   Number;

  BEGIN

       OPEN  l_agr_csr;
       FETCH l_agr_csr INTO l_agreement_id;
       CLOSE l_agr_csr;

       RETURN(l_agreement_id);

  END get_agreement;

  FUNCTION get_clvl_party(p_line_id IN Number) Return l_party_rec
  IS
   CURSOR l_pty_csr IS
   SELECT IT.OBJECT1_ID1, PY.NAME
   FROM   OKC_K_LINES_B KL,
          OKC_K_ITEMS IT,
          OKX_PARTIES_V PY
   WHERE  KL.ID = IT.CLE_ID
   AND    IT.OBJECT1_ID1 = PY.ID1
   AND    IT.OBJECT1_ID2 = PY.ID2
   AND    IT.JTOT_OBJECT1_CODE = 'OKX_PARTY'
   AND    KL.ID = p_line_id;

   l_rec_type   l_party_rec;

  BEGIN

    OPEN  l_pty_csr;
    FETCH l_pty_csr INTO l_rec_type;
    CLOSE l_pty_Csr;

    RETURN(l_rec_type);

  END get_clvl_party;


  FUNCTION get_clvl_customer(p_line_id IN Number) Return l_cust_rec
  IS
   CURSOR l_cust_csr IS
   SELECT IT.OBJECT1_ID1, CT.NAME
   FROM   OKC_K_LINES_B KL,
          OKC_K_ITEMS IT,
          OKX_CUSTOMER_ACCOUNTS_V CT
   WHERE  KL.ID = IT.CLE_ID
   AND    IT.OBJECT1_ID1 = CT.ID1
   AND    IT.OBJECT1_ID2 = CT.ID2
   AND    IT.JTOT_OBJECT1_CODE = 'OKX_CUSTACCT'
   AND    KL.ID = p_line_id;

   l_rec_type   l_cust_rec;

  BEGIN

    OPEN  l_cust_csr;
    FETCH l_cust_csr INTO l_rec_type;
    CLOSE l_cust_Csr;

    RETURN(l_rec_type);

  END get_clvl_customer;

  FUNCTION get_clvl_site(p_line_id IN Number, p_org_id IN Number) Return l_site_rec
  IS
   CURSOR l_site_csr IS
   SELECT IT.OBJECT1_ID1, SI.NAME LOCATION
   FROM   OKC_K_LINES_B KL,
          OKC_K_ITEMS IT,
          OKX_CUST_SITE_USES_V SI
   WHERE  KL.ID = IT.CLE_ID
   AND    IT.OBJECT1_ID1 = SI.ID1
   AND    IT.OBJECT1_ID2 = SI.ID2
   AND    IT.JTOT_OBJECT1_CODE = 'OKX_COVSITE'
   AND    KL.ID = p_line_id
   AND    SI.org_id = p_org_id;

   l_rec_type   l_site_rec;

  BEGIN

    OPEN  l_site_csr;
    FETCH l_site_csr INTO l_rec_type;
    CLOSE l_site_Csr;

    RETURN(l_rec_type);

  END get_clvl_site;

  FUNCTION get_coverage_type(p_line_id IN Number) Return Varchar2
  IS
  /*
   CURSOR l_cov_csr IS
   Select fd.meaning
   from   okc_k_lines_b kl,
          okc_rule_groups_b rg,
          okc_rules_b rl,
          fnd_lookups fd
   where  kl.id = rg.cle_id
   and    kl.lse_id in(2,15,20)
   and    rg.id = rl.rgp_id
   and    rl.rule_information1 = fd.lookup_code
   and    rl.rule_information_category = 'CVE'
   and    fd.lookup_type = 'OKSCVETYPE'
   and    kl.id = p_line_id;
*/

   CURSOR l_cov_csr IS
   Select covtyp.meaning
   from   oks_k_lines_b okscle,
          oks_cov_types_v covtyp
   where  okscle.coverage_type = covtyp.code
   and    okscle.cle_id = p_line_id;

   l_cov_name  FND_LOOKUPS.MEANING%TYPE;

  BEGIN

    OPEN  l_cov_csr;
    FETCH l_cov_csr INTO l_cov_name;
    CLOSE l_cov_csr;

    return(l_cov_name);

  END get_coverage_type;

  FUNCTION get_billrate(p_rate_code IN VARCHAR2) Return Varchar2
  IS
   CURSOR l_billratemng_csr IS
   SELECT MEANING
   FROM   FND_LOOKUPS
   WHERE  LOOKUP_TYPE='OKS_BILLING_RATE'
   AND    LOOKUP_CODE = p_rate_code;

   l_rate_mng    varchar2(30);

  BEGIN

    OPEN  l_billratemng_csr;
    FETCH l_billratemng_csr INTO l_rate_mng;
    CLOSE l_billratemng_csr;

    RETURN(l_rate_mng);

  END get_billrate;

END OKS_ENT_UTIL_PVT;

/
