--------------------------------------------------------
--  DDL for Package Body OKS_ATTR_DEFAULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ATTR_DEFAULTS_PVT" AS
/* $Header: OKSRDFTB.pls 120.29.12010000.2 2009/03/04 05:52:34 spingali ship $*/
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
--Fix for Bug# 3542273
 FUNCTION FND_MEANING(P_LOOKUP_CODE IN VARCHAR2,P_LOOKUP_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
  CURSOR C_LOOKUP_CODE IS
  SELECT MEANING FROM FND_LOOKUPS
  WHERE LOOKUP_CODE = P_LOOKUP_CODE
  AND LOOKUP_TYPE = P_LOOKUP_TYPE;

  V_FOUND BOOLEAN := FALSE;
  V_NAME VARCHAR2(150);
 BEGIN
    FOR C_CUR_MEANING IN C_LOOKUP_CODE
    LOOP
       V_FOUND := TRUE;
       V_NAME := C_CUR_MEANING.MEANING;
       EXIT;
    END LOOP;

    IF (V_FOUND = TRUE)
    THEN
       RETURN(V_NAME);
    ELSE
       RETURN(NULL);
    END IF;
 END FND_MEANING;
--Fix for Bug# 3542273

PROCEDURE validate_date
  ( p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_hdr_id                       IN NUMBER,
    p_top_line_id                  IN NUMBER,
    p_sub_line_id                  IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_flag                         OUT NOCOPY BOOLEAN ) IS

/******************************************
 Note 1: For header to top lines
        p_hdr_id      = Header id .
        p_top_line_id = Top line id.
        p_sub_line_id = null

  Note 2: For top line to sub lines
        p_hdr_id      = null.
        p_top_line_id = Top line id.
        p_sub_line_id = Sub line id.
*******************************************/

CURSOR L_GET_TOP_LINE_DATE_CSR ( P_TOP_LINE_ID IN NUMBER ) IS
SELECT TRUNC(MIN(BCL.DATE_BILLED_FROM)) DATE_BILLED_FROM
     , TRUNC(MAX(BCL.DATE_BILLED_TO))   DATE_BILLED_TO
  FROM OKS_BILL_CONT_LINES BCL
 WHERE BCL.CLE_ID = P_TOP_LINE_ID ;

L_GET_TOP_LINE_DATE_REC L_GET_TOP_LINE_DATE_CSR%ROWTYPE;

CURSOR L_GET_HDR_DATES_CSR(P_HDR_ID IN NUMBER ) IS
SELECT TRUNC(START_DATE) START_DATE
     , TRUNC(END_DATE) END_DATE
  FROM OKC_K_HEADERS_B
 WHERE ID = P_HDR_ID ;

L_GET_HDR_DATES_REC L_GET_HDR_DATES_CSR%ROWTYPE;

CURSOR L_GET_SUB_LINE_DATE_CSR ( P_SUB_LINE_ID IN NUMBER ) IS
SELECT TRUNC(MIN(BSL.DATE_BILLED_FROM))  DATE_BILLED_FROM
     , TRUNC(MAX(BSL.DATE_BILLED_TO))  DATE_BILLED_TO
  FROM OKS_BILL_SUB_LINES BSL
 WHERE BSL.CLE_ID = P_SUB_LINE_ID;

L_GET_SUB_LINE_DATE_REC  L_GET_SUB_LINE_DATE_CSR%ROWTYPE;

CURSOR L_GET_TOP_LINE_DATES_CSR(P_TOP_LINE_ID IN NUMBER ) IS
SELECT TRUNC(START_DATE) START_DATE
     , TRUNC(END_DATE) END_DATE
  FROM OKC_K_LINES_B
 WHERE ID = P_TOP_LINE_ID;

L_GET_TOP_LINE_DATES_REC  L_GET_TOP_LINE_DATES_CSR%ROWTYPE;


BEGIN
x_flag := TRUE ;
x_return_status := OKC_API.G_RET_STS_SUCCESS;
-- Start of if for Header to Top line validation.

If (p_hdr_id is not null and p_hdr_id > 0 ) and (p_top_line_id is not null
and p_top_line_id > 0 ) and (p_sub_line_id is null) then
    -- SQL call to get the max and min top line billing dates
    OPEN  L_GET_TOP_LINE_DATE_CSR(p_top_line_id);
    FETCH L_GET_TOP_LINE_DATE_CSR INTO L_GET_TOP_LINE_DATE_REC;
    CLOSE L_GET_TOP_LINE_DATE_CSR;

    -- SQL call to get header start date and end date
    OPEN L_GET_HDR_DATES_CSR(P_HDR_ID);
    FETCH L_GET_HDR_DATES_CSR INTO L_GET_HDR_DATES_REC;
    CLOSE L_GET_HDR_DATES_CSR;

    -- If billed, and the start date of hdr and top line dosen't match then
    --return false.
    IF L_GET_TOP_LINE_DATE_REC.DATE_BILLED_FROM IS NOT NULL THEN
       IF L_GET_TOP_LINE_DATE_REC.DATE_BILLED_FROM <>
          L_GET_HDR_DATES_REC.START_DATE THEN
          X_FLAG := FALSE;
          RETURN;
       END IF;
    END IF;

    -- If billed, and the end date of hdr < max bill to date of top line
    --then return false.
    IF L_GET_TOP_LINE_DATE_REC.DATE_BILLED_TO IS NOT NULL THEN
       IF L_GET_TOP_LINE_DATE_REC.DATE_BILLED_TO >
          L_GET_HDR_DATES_REC.END_DATE THEN
          X_FLAG := FALSE;
          RETURN;
       END IF;
    END IF;
    RETURN;
End If;


-- Start of if for Top line to sub line validation.
If (p_top_line_id is not null and p_top_line_id > 0 ) and (p_sub_line_id is
not null and p_sub_line_id > 0) and (p_hdr_id is null ) then

    -- SQL call to get the max and min sub line billing dates
    OPEN  L_GET_SUB_LINE_DATE_CSR(P_SUB_LINE_ID);
    FETCH L_GET_SUB_LINE_DATE_CSR INTO L_GET_SUB_LINE_DATE_REC;
    CLOSE L_GET_SUB_LINE_DATE_CSR;

    -- SQL call to get top line start date and end date
    OPEN  L_GET_TOP_LINE_DATES_CSR(P_TOP_LINE_ID);
    FETCH L_GET_TOP_LINE_DATES_CSR INTO L_GET_TOP_LINE_DATES_REC;
    CLOSE L_GET_TOP_LINE_DATES_CSR;

     -- If billed, and the start date of top and sub line dosen't match then
     --return false.

    IF L_GET_SUB_LINE_DATE_REC.DATE_BILLED_FROM IS NOT NULL THEN
       IF L_GET_SUB_LINE_DATE_REC.DATE_BILLED_FROM <>
          L_GET_TOP_LINE_DATES_REC.START_DATE THEN
          X_FLAG := FALSE;

          RETURN;
       END IF;
    END IF;

    -- If billed and the end date of top line < max bill to date of sub line
    --then return false.
    IF L_GET_TOP_LINE_DATE_REC.DATE_BILLED_TO IS NOT NULL THEN
       IF L_GET_SUB_LINE_DATE_REC.DATE_BILLED_TO >
          L_GET_TOP_LINE_DATES_REC.END_DATE THEN
          X_FLAG := FALSE;

          RETURN;
       END IF;
    END IF;
    RETURN;
END IF;
x_flag := FALSE;
x_return_status := OKC_API.G_RET_STS_ERROR;

EXCEPTION
WHEN OTHERS THEN

  x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message('OKS',
                      'OKC_CONTRACTS_UNEXP_ERROR',
                      'SQLcode',
                       SQLCODE,
                      'SQLerrm',
                       SQLERRM);

END;


PROCEDURE update_line
(
 p_clev_tbl      IN  okc_contract_pub.clev_tbl_type
,x_clev_tbl      OUT NOCOPY okc_contract_pub.clev_tbl_type
,x_return_status OUT NOCOPY Varchar2
,x_msg_count     OUT NOCOPY Number
,x_msg_data      OUT NOCOPY Varchar2
)
 IS
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list   CONSTANT    VARCHAR2(1) := 'F';
  l_return_status				VARCHAR2(1);
  l_msg_count					NUMBER;
  l_msg_data					VARCHAR2(2000);
  l_clev_tbl_in                 okc_contract_pub.clev_tbl_type;
  l_clev_tbl_out                okc_contract_pub.clev_tbl_type;
  l_msg_index_out				NUMBER;
  i						NUMBER; -- 5381082
BEGIN
  x_return_status := l_return_status;
  l_clev_tbl_in   := p_clev_tbl;

    -- Bug 5381082--
  IF l_clev_tbl_in.count >0
  THEN
	i := l_clev_tbl_in.FIRST;
	LOOP
	  l_clev_tbl_in(i).validate_yn :='N';
	EXIT WHEN (i = l_clev_tbl_in.LAST);
	  i := l_clev_tbl_in.NEXT(i);
	END LOOP;
  END IF;
  -- Bug 5381082--

  okc_contract_pub.update_contract_line
       (
    	p_api_version			=> l_api_version,
    	p_init_msg_list			=> l_init_msg_list,
    	x_return_status			=> l_return_status,
    	x_msg_count			=> l_msg_count,
    	x_msg_data			=> l_msg_data,
    	p_restricted_update		=> 'F',
    	p_clev_tbl			=> l_clev_tbl_in,
    	x_clev_tbl			=> l_clev_tbl_out
       );

  If l_return_status = 'S'
  Then
      x_clev_tbl := l_clev_tbl_out;
      x_return_status := l_return_status;
  Else
      x_return_status := l_return_status;
  End If;

Exception
When Others Then
  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
END update_line;

FUNCTION CHECK_LINE_PARTY_ROLE(p_dnz_chr_id IN NUMBER,
                               P_Cle_Id     IN NUMBER,
			       p_party_id   IN NUMBER) RETURN NUMBER
IS
CURSOR l_role_csr IS
  SELECT ID
  FROM   OKC_K_PARTY_ROLES_B
  WHERE DNZ_CHR_ID = p_dnz_chr_id
  AND   CLE_ID = P_Cle_Id
  AND   OBJECT1_ID1 = p_party_id  ; -- Bug 5219132


  l_cle_id   Number;
  l_cpl_id   Number;
  l_chr_id   Number;
BEGIN

  OPEN  l_role_csr;
  FETCH l_role_csr INTO l_cpl_id;
  CLOSE l_role_csr;

  IF l_cpl_id IS NULL THEN
     RETURN(l_cpl_id);
  ELSE
     RETURN(l_cpl_id);
  END IF;
END CHECK_LINE_PARTY_ROLE;

PROCEDURE CREATE_LINE_PARTY_ROLE(p_dnz_chr_id IN NUMBER,
                                 p_cle_id     IN NUMBER,
                                 P_billto_Id  IN NUMBER,
                                 p_can_id     IN NUMBER,
                                 x_cpl_id     OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2) IS

   l_can_id         NUMBER;
   l_msg_index                NUMBER;

CURSOR get_party(p_can_id in number) IS
   SELECT party_id
   FROM   okx_customer_accounts_v
   WHERE  id1=p_can_id;
   l_party_id         NUMBER;

CURSOR role_csr IS
    SELECT rle_code,OBJECT1_ID1,object1_id2,JTOT_OBJECT1_CODE
    FROM   OKC_K_PARTY_ROLES_B
    WHERE object1_id1= l_party_id
    and   dnz_chr_id = p_dnz_chr_id;

  Cursor get_contract_type IS
   Select SCS_CODE from OKC_K_HEADERS_B
   where id = p_dnz_chr_id;


    role_csr_Rec     role_csr%rowtype;
    l_api_version    CONSTANT	NUMBER	:= 1.0;
    l_init_msg_list  CONSTANT	VARCHAR2(1) := 'F';
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_msg_index_out  NUMBER;

    l_cplv_tbl_in    okc_contract_party_pub.cplv_tbl_type;
    l_cplv_tbl_out   okc_contract_party_pub.cplv_tbl_type;

    l_type           OKC_K_HEADERS_B.SCS_CODE%TYPE;
    l_rle_code       VARCHAR2(2000);
BEGIN
    l_can_id := p_can_id;
    OPEN   get_party(l_can_id) ;
    FETCH   get_party   INTO  l_party_id;
    CLOSE   get_party ;

    open get_contract_type;
    fetch get_contract_type into l_type;
    close get_contract_type;

    /* OPEN    role_csr;
    FETCH   role_csr  INTO  role_csr_rec;
    CLOSE   role_csr; */

    IF l_type = 'SUBSCRIPTION'
    THEN
      l_rle_code := 'SUBSCRIBER';
    ELSE
      l_rle_code:= 'CUSTOMER';
    END IF;

    l_cplv_tbl_in(1).sfwt_flag              := 'N';
    l_cplv_tbl_in(1).cle_id                 := p_cle_id;
    l_cplv_tbl_in(1).dnz_chr_id             := p_dnz_chr_id;
    l_cplv_tbl_in(1).chr_id                 := null;
    -- l_cplv_tbl_in(1).rle_code               := role_csr_rec.RLE_CODE;
    l_cplv_tbl_in(1).rle_code               := l_rle_code;
    --- l_cplv_tbl_in(1).OBJECT1_ID1            := role_csr_rec.OBJECT1_ID1;
    l_cplv_tbl_in(1).OBJECT1_ID1            := l_party_id;
    -- l_cplv_tbl_in(1).object1_id2            := role_csr_rec.object1_id2;
    l_cplv_tbl_in(1).object1_id2            := '#';
    -- l_cplv_tbl_in(1).JTOT_OBJECT1_CODE      := role_csr_rec.JTOT_OBJECT1_CODE;
    l_cplv_tbl_in(1).JTOT_OBJECT1_CODE      := 'OKX_PARTY';
    l_cplv_tbl_in(1).cognomen               := Null;
    l_cplv_tbl_in(1).SMALL_BUSINESS_FLAG    := 'N';
    l_cplv_tbl_in(1).women_owned_flag       := 'N';
    l_cplv_tbl_in(1).alias                  := Null;

    okc_contract_party_pub.create_k_party_role
        (p_api_version    => l_api_version,
         p_init_msg_list  => l_init_msg_list,
         x_return_status  => l_return_status,
         x_msg_count      => l_msg_count,
         x_msg_data       => l_msg_data,
         p_cplv_tbl       => l_cplv_tbl_in,
         x_cplv_tbl       => l_cplv_tbl_out);
       -- Bug 5227077 --
       x_return_status :=l_return_status;
       IF l_return_status = FND_API.G_RET_STS_SUCCESS
       THEN
	    IF l_cplv_tbl_out.COUNT > 0 THEN
    		x_cpl_id := l_cplv_tbl_out(l_cplv_tbl_out.FIRST).id;
            END IF;
       END IF;

       -- Bug 5227077 --

END CREATE_LINE_PARTY_ROLE;

FUNCTION CHECK_LINE_CONTACT(p_dnz_chr_id IN NUMBER,
                            P_CPL_Id     IN NUMBER
			   ) RETURN NUMBER
IS

CURSOR l_contact_csr IS
  SELECT ID
  FROM   OKC_CONTACTS
  WHERE  DNZ_CHR_ID = p_dnz_chr_id
  AND    CPL_ID = P_CPL_Id;

  l_cle_id   Number;
  l_cpl_id   Number;
  l_chr_id   Number;
  l_contact_id   Number;

BEGIN
  OPEN  l_contact_csr;
  FETCH l_contact_csr INTO l_contact_id;
  CLOSE l_contact_csr;
  IF l_contact_id IS NULL THEN
     RETURN(l_contact_id);
  ELSE
     RETURN(l_contact_id);
  END IF;
END CHECK_LINE_CONTACT;

FUNCTION CHECK_LINE_BILL_CONTACT(p_dnz_chr_id IN NUMBER,
                            P_CPL_Id     IN NUMBER,
			    p_jtot_code  IN VARCHAR2,
			    p_cro_code   IN VARCHAR2) RETURN NUMBER
IS

CURSOR l_contact_csr IS
  SELECT ID
  FROM   OKC_CONTACTS
  WHERE  DNZ_CHR_ID = p_dnz_chr_id
  AND    CPL_ID = P_CPL_Id
  AND   JTOT_OBJECT1_CODE =p_jtot_code
  AND   cro_code          =p_cro_code ;

  l_cle_id   Number;
  l_cpl_id   Number;
  l_chr_id   Number;
  l_contact_id   Number;

BEGIN
  OPEN  l_contact_csr;
  FETCH l_contact_csr INTO l_contact_id;
  CLOSE l_contact_csr;
  IF l_contact_id IS NULL THEN
     RETURN(l_contact_id);
  ELSE
     RETURN(l_contact_id);
  END IF;
END CHECK_LINE_BILL_CONTACT;

PROCEDURE Default_header_to_lines
                   (header_lines_tbl  IN   header_lines_tbl_type
                   ,X_return_status   OUT  NOCOPY Varchar2
                   ,x_msg_tbl         IN   OUT NOCOPY attr_msg_tbl_type)
IS

Cursor cur_header_dates(p_chr_id in NUMBER) is
  select start_date,
         end_date,
         inv_organization_id,
         authoring_org_id
  from okc_k_headers_v
  where id = p_chr_id;
  header_dates_rec   cur_header_dates%ROWTYPE;

Cursor cur_line_dates(p_cle_id in NUMBER) is
  select start_date,
         end_date,
         lse_id
  from okc_k_lines_b
  where id = p_cle_id;
  line_dates_rec   cur_line_dates%ROWTYPE;

Cursor LineCov_cur(p_cle_id IN Number) Is
  Select id
  From   OKC_K_LINES_V
  Where  cle_id = p_cle_id
  and    lse_id in (2,13,15,20);

Cursor cur_okc_headers(p_chr_id in NUMBER) is
  select
         id,
         inv_rule_id,
         cust_acct_id,
         bill_to_site_use_id,
         ship_to_site_use_id,
         cust_po_number,
         cust_po_number_req_yn,
	 -- BANK ACCOUNT CONSOLIDATION --
	 payment_instruction_type,
	 authoring_org_id,
	 -- BANK ACCOUNT CONSOLIDATION --
	 price_list_id, -- hkamdar 8/23/05 R12 Partial Period
         currency_code -- gchadha for Partial Period
  from okc_k_headers_b
  where id = p_chr_id;
  l_okc_headers_rec   cur_okc_headers%ROWTYPE;

Cursor cur_okc_lines(p_cle_id in NUMBER) is
  select
         id,
         inv_rule_id,
         cust_acct_id,
         lse_id,
         price_negotiated,
         bill_to_site_use_id,
         ship_to_site_use_id
  from okc_k_lines_b
  where id = p_cle_id;
  l_okc_lines_rec   cur_okc_lines%ROWTYPE;

  Cursor cur_oks_headers(p_chr_id in NUMBER) is
  select
         id,
         acct_rule_id,   --for ARL rule
         tax_status,
--Fixed bug#4026268 --gbgupta
        -- tax_code,
         tax_exemption_id,
         payment_type,   --for payment method
         -- Bank Account Consolidation --
	 /* cc_no,
         cc_expiry_date,
         cc_bank_acct_id,
         cc_auth_code, */
	 trxn_extension_id,
	 -- Bank Account Consolidation --
         commitment_id,
         grace_duration,
         grace_period,   --for payment method
         object_version_number,
	 price_uom, -- hkamdar 8/23/05 R12 Partial Period
	 -- Ebtax --
	 exempt_certificate_number,
	 exempt_reason_code,
	 tax_classification_code
	 -- Ebtax --
  from oks_k_headers_v
  where chr_id = p_chr_id;

  l_oks_headers_rec   cur_oks_headers%ROWTYPE;

Cursor cur_oks_lines(p_cle_id in NUMBER) is
  select
         id,
         acct_rule_id,  --for ARL rule
         tax_amount,
         tax_inclusive_yn,
         tax_status,
         tax_code,
         tax_exemption_id,
         payment_type,   --for payment method
	 -- Bank Account Consolidation --
         /*cc_no,
         cc_expiry_date,
         cc_bank_acct_id,
         cc_auth_code, */
	 trxn_extension_id,
	 -- Bank Account Consolidation --
         commitment_id,
         grace_duration,
         grace_period,  --for payment method
         object_version_number,
         invoice_text,
--Fix for Bug# 3542273
         usage_type,
--Fix for Bug# 3542273
         -- Ebtax --
	 tax_classification_code,
	 exempt_certificate_number,
	 exempt_reason_code,
	 standard_cov_yn -- Issue#14   Bug 4566346
	 -- Ebtax --
  from oks_k_lines_v
  where cle_id = p_cle_id;
  l_oks_lines_rec   cur_oks_lines%ROWTYPE;

Cursor cur_head_cust_acct(p_object1_id1 IN NUMBER) IS
  select cust_account_id
  from okx_cust_site_uses_v
  where id1=p_object1_id1;

Cursor cur_line_cust_acct(p_cle_id IN NUMBER) IS
  select cust_acct_id
  from okc_k_lines_b
  where id =p_cle_id;
--commenting out, because it is not beeing used any where, 05/04/2004
--Cursor line_contact(p_contact_id in number ) IS
--  select * from okc_contacts
--  where id = p_contact_id;
--  line_contact_rec  line_contact%rowtype;


-- Gets sublines
--  Bug 4717842 --
--  Ignore the cancelled lines.
Cursor cur_sub_line(l_cle_id number) IS
  select id, price_negotiated, cle_id, price_unit
  from okc_k_lines_v
  where lse_id in (7,8,9,10,11,13,18,25,35)
  and  date_cancelled is NULL -- new
  and cle_id = l_cle_id;
--  Bug 4717842 --
   l_sub_line_rec    cur_sub_line%ROWTYPE;

Cursor cur_bpf_cust_acct(l_billing_profile_id IN NUMBER, l_org_id IN NUMBER) IS
   select distinct cust_account_id
   from   okx_cust_site_uses_v
   where  id1 In
      (
       select bill_to_address_id1
       from oks_billing_profiles_b
       where OWNED_PARTY_ID1 IS NOT NULL
       and id = l_billing_profile_id)
       AND site_use_code = 'BILL_TO'
       AND org_id = l_org_id;

Cursor cur_bill_to_address_id1  (l_billing_profile_id IN NUMBER) IS
   select bill_to_address_id1
   from oks_billing_profiles_b
   where id = l_billing_profile_id
   AND OWNED_PARTY_ID1 IS NOT NULL;

Cursor cur_billing_profile  (l_billing_profile_id IN NUMBER) IS
   select account_object1_id1
         ,invoice_object1_id1
   from oks_billing_profiles_b
   where id = l_billing_profile_id;

 -- Bug 5191587 --
 -- Added condition to verify Service and Extended Warranty Lines
Cursor cur_service_req_number (p_cle_id IN NUMBER, p_chr_id IN NUMBER) IS
   select distinct incident_id,
          contract_number,
          contract_service_id,
          incident_number
   from cs_incidents_all_b cs , okc_k_lines_b line
   where cs.contract_service_id = p_cle_id
   and   cs.contract_id         =p_chr_id
   and   cs.contract_id         =line.dnz_chr_id
   and   line.cle_id = p_cle_id
   and   line.lse_id  in ('18','9','25');
 -- Bug 5191587 --

   l_service_req_rec    cur_service_req_number%ROWTYPE;
   l_sr_number          VARCHAR2(2000);
   l_sr_flag               NUMBER:=0;

--new
  cursor Scredit_csr(P_header_id IN NUMBER) Is
       Select id
              ,Percent
              ,Ctc_id
              ,Sales_credit_type_id1
              ,Sales_credit_type_id2
              --new
              ,sales_group_id
              --new
       From   OKS_K_SALES_CREDITS_V
       Where  chr_id = p_header_id
	  And    cle_id Is NULL;

   l_sales_credit_rec    Scredit_csr%ROWTYPE;


  Cursor Scredit_csr_line(p_header_id IN NUMBEr,P_line_id IN NUMBER) Is
       Select count(*),id
       From   OKS_K_SALES_CREDITS_V
       Where  chr_id = p_header_id
	   And    cle_id =p_line_id
       group by id;

  Cursor cur_line_number(p_cle_id IN VARCHAR2) Is
       select line_number
       from okc_k_lines_b
       where id = p_cle_id;
----new
  Cursor cur_cust_acct_id(p_chr_id    in NUMBER,
                        p_billto_id in NUMBER) is
    Select cust_acct_id
    from okx_cust_contacts_v
    where party_id in
      (select object1_id1 from okc_k_party_roles_b
       where  dnz_chr_id = p_chr_id--:PARAMETER.OKSDEFLT_CHR_ID
       and        chr_id = p_chr_id--:PARAMETER.OKSDEFLT_CHR_ID
       and cle_id IS NULL
       and rle_code <> 'VENDOR'
       )
    and status = 'A'
    and id1 = p_billto_id;
    -- IKON ENHANCEMENT --
    -- 2/11/2005 --
    -- GCHADHA --

    -- GET CUST ACCT --
    CURSOR CUR_CUST_ACCT (l_object1_id1 IN NUMBER,use IN VARCHAR2) IS
    SELECT DISTINCT b.id1, a.party_id
    FROM okx_cust_site_uses_v a, okx_customer_accounts_v b
    WHERE a.id1 = l_object1_id1
    AND b.id1 = a.cust_account_id
    AND a.site_use_code =  use;

    CURSOR Party_role_csr (p_dnz_chr_id IN NUMBER,p_cle_id IN NUMBER)  IS
    SELECT  id, cle_id, dnz_chr_id
    FROM   OKC_K_PARTY_ROLES_B
    WHERE DNZ_CHR_ID = p_dnz_chr_id
    AND   CLE_ID = P_Cle_Id;
   -- AND OBJECT1_ID1 =l_party_id;

    l_party_role          Party_role_csr%ROWTYPE;


    Cursor Get_Contact_Cust_Acct ( l_contact_id IN nUMBER)IS
    Select cust_acct_id
    FROM OKX_CUST_CONTACTS_V
    WHERE ROLE_TYPE = 'CONTACT'
    AND ID1 = l_contact_id ;


    CURSOR CUR_LINE_PARTY_ROLE ( P_CHR_ID IN NUMBER,   P_CLE_ID IN NUMBER, l_party_id IN NUMBER) IS
    SELECT id
    FROM   OKC_K_PARTY_ROLES_B
    WHERE DNZ_CHR_ID = p_chr_id
    AND   CLE_ID = p_cle_id
    AND   OBJECT1_ID1 =l_party_id;

    Cursor  Get_Party_Id (p_cust_acct_id IN NUMBER) IS
    Select Party_id,name
    from okx_customer_accounts_v
    where id1= p_cust_acct_id;



    Cursor line_contact_jtot(p_cpl_id in number,p_chr_id IN NUMBER, p_jtot_object_code IN VARCHAR2) IS
       select * from okc_contacts
       where cpl_id = p_cpl_id
       AND JTOT_OBJECT1_CODE <>  p_jtot_object_code
       AND DNZ_CHR_ID  = p_chr_id;

    Cursor cur_get_line_number(p_cle_id in NUMBER, p_chr_id IN NUMBER) IS
    Select line_number
    from okc_k_lines_v
    where cle_id =p_cle_id
    and dnz_chr_id = p_chr_id;


   -- BUG 4394382 --
   -- GCHADHA --
   -- 5/30/2005 --
   Cursor cur_oks_comm_line(p_cle_id in NUMBER) is
   select
         cust_po_number,
         cust_po_number_req_yn,
	 payment_instruction_type,
	 trxn_extension_id
   from oks_k_lines_b oks, okc_k_lines_b okc
   where okc.id =  p_cle_id
   and oks.cle_id = okc.id;
   -- END GCHADHA --

  l_oks_comm_line_rec   cur_oks_comm_line%ROWTYPE;

  -- Bank Account Consolidation --
  Cursor cur_get_party_id (p_cust_acct_id IN NUMBER) IS
  Select party_id
  FROM HZ_CUST_ACCOUNTS CA
  WHERE CA.cust_account_ID = p_cust_acct_id;

  l_oks_party_rec   cur_get_party_id%ROWTYPE;

 -- Bank Account Consolidation --

 -- hkamdar 8/23/05 R12 Partial Period
 -- Cursor for Checking price list lock

  Cursor cur_get_lines_details (p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
  Select  locked_price_list_id  ,
          locked_price_list_line_id
  FROM    OKS_k_LINES_B
  WHERE   dnz_chr_id = p_chr_id
  and     cle_id = p_cle_id ;

  -- Ebtax --
  CURSOR tax_exemption_number_csr(p_tax_exemption_id IN NUMBER) IS
  Select ex.exempt_certificate_number CUSTOMER_EXCEPTION_NUMBER,  nvl(lk.lookup_code,ex.exempt_reason_code) Description
  from  zx_exemptions ex, fnd_lookups lk
  where ex.tax_exemption_id = p_tax_exemption_id
  and lk.lookup_type(+) = 'ZX_EXEMPTION_REASON_CODE'
  and lk.lookup_code(+) = ex.exempt_reason_code;

  tax_exemption_number_rec tax_exemption_number_csr%rowtype;
  -- Recalculate Tax --
  -- Bug 4717842 --
  CURSOR get_topline_tax_amt_csr (p_cle_id IN NUMBER) IS
	Select	nvl(sum(nvl(tax_amount,0)),0) tax_amount
	from    okc_k_lines_b cle, oks_k_lines_b sle
	where   cle.cle_id = p_cle_id
	and     cle.lse_id in (7,8,9,10,11,13,25,35)
	and     cle.id = sle.cle_id
	and     cle.dnz_chr_id = sle.dnz_chr_id
	and     cle.date_cancelled is null;

  Cursor get_hdr_tax_amt_csr (p_chr_id in number) IS
        Select  nvl(sum(nvl(tax_amount,0)),0) tax_amount
        from    okc_k_lines_b cle, oks_k_lines_b sle
        where   cle.chr_id = p_chr_id
        and     cle.id = sle.cle_id
        and     cle.dnz_chr_id = sle.dnz_chr_id
        and     cle.date_cancelled is null;

   l_line_tax_amt get_topline_tax_amt_csr%RowType;
   l_hdr_tax_amt  get_hdr_tax_amt_csr%RowType;


   l_khrv_tbl_type_in   oks_contract_hdr_pub.khrv_tbl_type;
   l_khrv_tbl_type_out  oks_contract_hdr_pub.khrv_tbl_type;
  -- Recalculate Tax --

  -- Ebtax --
 -- End hkamdar 8/23/05 R12 Partial Period

    l_header_sca               VARCHAR2(3);
    l_header_bca               VARCHAR2(3) ;
    l_header_cust_acct          NUMBER;
    line_contact_cust_acct      NUMBER;
    l_contact                   NUMBER;
    l_party_id                  NUMBER;
    l_line_party_id             NUMBER;
    l_temp_contact_id           NUMBER;
    l_temp_party_name           VARCHAR2(150); -- Stores the party Name for Lines Level BTO/STO Account
    l_can_success               NUMBER  :=0;
    l_temp_line_number          NUMBER  ; -- Temporary Variable used to Keep the Line Number
    l_tax_exempt_status         NUMBER :=0;
    l_oks_header_id             NUMBER :=0; --Variable to ascertain whether OKS_K_HEADERS_B should be
					    -- Updated or not.

    -- END GCHADHA --
    -- IKON ENHANCEMENT --
----new



   l_sc_index    NUMBER;
   l_scr_rec                   Scredit_csr%rowtype;
   l_scrv_tbl_in               OKS_SALES_CREDIT_PUB.SCRV_TBL_TYPE;
   l_scrv_tbl_out              OKS_SALES_CREDIT_PUB.SCRV_TBL_TYPE;
   l_scredit_count             NUMBER;
   l_scredit_id                NUMBER;
   l_sales_group_id            NUMBER;
--new

  l_index                    NUMBER;
  i                          NUMBER;
  l_chr_id                   NUMBER;
  l_cle_id                   NUMBER;
  l_subline_id               NUMBER;
  l_cpl_id                   NUMBER;
  l_contact_id               NUMBER;
  l_header_sto               VARCHAR2(150);
  l_header_bto               VARCHAR2(150);
  l_header_dates             VARCHAR2(150);
  l_header_arl               VARCHAR2(150);
  l_header_ire               VARCHAR2(150);
  l_header_tax               VARCHAR2(150);
  l_header_sales_credits     VARCHAR2(150);
  l_header_exception_number  VARCHAR2(150);
  l_header_tax_code          VARCHAR2(150);
  -- Ebtax --
  l_header_tax_cls_code      VARCHAR2(150);
  -- Ebtax --
--Fixed bug#4026268 --gbgupta
  l_header_tax_code_id       NUMBER;

  l_header_billto_contact    VARCHAR2(150);
  l_line_tax_status          VARCHAR2(150);
  l_head_cust_acct           NUMBER;
  l_line_cust_acct           NUMBER;
  l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
  l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
  l_api_version              Number      := 1.0;
  l_init_msg_list            Varchar2(1) := 'F';
  l_msg_count                Number;
  l_msg_data                 Varchar2(1000);
  l_return_status            Varchar2(1) := 'S';
  l_tot_msg_count            NUMBER:=0;
  tbl_index                  NUMBER:=1;
  l_bill_sch_out_tbl         OKS_BILL_SCH.ItemBillSch_tbl;
  l_id                       Number;
  x_cpl_id                   NUMBER;
  l_billto_id                NUMBEr;
  l_cplv_tbl_in              okc_contract_party_pub.cplv_tbl_type;
  l_cplv_tbl_out             okc_contract_party_pub.cplv_tbl_type;
  l_ctcv_tbl_in              okc_contract_party_pub.ctcv_tbl_type;
  l_ctcv_tbl_out             okc_contract_party_pub.ctcv_tbl_type;
  --l_insupd_flag              BOOLEAN := FALSE;
  l_msg_index                NUMBER;
  l_Invoice_Rule_Id          NUMBER;
  l_Account_Rule_Id          NUMBER;
  l_rec                      OKS_BILLING_PROFILES_PUB.Billing_profile_rec;
  l_sll_tbl_out              OKS_BILLING_PROFILES_PUB.Stream_Level_tbl;
  l_top_line_id              NUMBER;
  l_calculate_tax            VARCHAR2(150);
  x_msg_count	             NUMBER;
  x_msg_data	             VARCHAR2(2000);
  G_RAIL_REC                 OKS_TAX_UTIL_PVT.ra_rec_type;
  l_UNIT_SELLING_PRICE       G_RAIL_REC.UNIT_SELLING_PRICE%TYPE;
  l_QUANTITY                 G_RAIL_REC.QUANTITY%TYPE;
  l_sub_total                G_RAIL_REC.AMOUNT%TYPE;
  l_total                    G_RAIL_REC.AMOUNT%TYPE;
  l_total_amt                G_RAIL_REC.AMOUNT%TYPE;
  l_AMOUNT_INCLUDES_TAX_FLAG G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG%TYPE;
  l_Tax_Code                 G_RAIL_REC.TAX_CODE%TYPE;
  l_TAX_RATE                 G_RAIL_REC.TAX_RATE%TYPE;
  l_Tax_Value                G_RAIL_REC.TAX_VALUE%TYPE;
  l_price_negotiated         G_RAIL_REC.AMOUNT%TYPE;
  l_lse_id                   NUMBER;
  l_bill_to_address_id1      VARCHAR2(40) ;
  l_bpf_cust_acct            NUMBER;
  l_can_id                   NUMBER;
  l_billing_profile          VARCHAR2(150);
  l_billing_profile_id       NUMBER;
  l_bpf_start_date           DATE;
  l_bpf_end_date             DATE;
  l_bpf_lse_id               NUMBER;
  L_bil_sch_out_tbl         OKS_BILL_SCH.ItemBillSch_tbl;
  l_top_bs_tbl              oks_bill_level_elements_pvt.letv_tbl_type;
  l_sll_tbl                 OKS_BILL_SCH.StreamLvl_tbl;
  l_error_tbl               OKC_API.ERROR_TBL_TYPE;
  p_klnv_tbl                oks_kln_pvt.klnv_tbl_type;
  l_klnv_tbl                oks_kln_pvt.klnv_tbl_type := p_klnv_tbl;
  x_klnv_tbl                oks_kln_pvt.klnv_tbl_type;
  l_payment_method          VARCHAR2(150);--for payment method
  l_klnv_tbl_in             oks_contract_line_pub.klnv_tbl_type;
  l_klnv_tbl_out            oks_contract_line_pub.klnv_tbl_type;

  /*added for bug 7387293*/
  l_kslnv_tbl_in            oks_contract_line_pub.klnv_tbl_type;
  l_kslnv_tbl_out           oks_contract_line_pub.klnv_tbl_type;
 /*added for bug 7387293*/

  l_billing_type            VARCHAR2 (450);
  l_bpf_acct_rule_id        NUMBER;
  l_bpf_invoice_rule_id     NUMBER;
  l_line_number             VARCHAR2 (150);
  l_flag                    BOOLEAN;

--Fix for Bug# 3542273
  l_usage_type              VARCHAR2 (10);
  l_token1_value            VARCHAR2 (1000);
--Fix for Bug# 3542273
--new....
    l_lov_cust_acct            NUMBER;
--new....
--BUG#4089834
  l_status_flag             BOOLEAN := FALSE;
  l_exmpt_num_flag          BOOLEAN := FALSE;

  -- GCHADHA --
  -- BUG 4394382 --
  l_cust_po_flag            NUMBER := 0; -- Flag to mark PO number change
  l_payment_method_com      NUMBER := 0; -- Flag to mark Commitment number details
  l_payment_method_ccr      NUMBER := 0; -- Flag to mark Credit card Change
  l_trxn_extension_id       NUMBER := 0; -- Bank Account Consolidation
  -- END GCHADHA --


 -- hkamdar 8/23/05 R12 Partial Period
  l_price_uom               VARCHAR2(100);
  l_error                   VARCHAR2(1);
  l_locked_prl_cnt          NUMBER := 0;
  l_header_price_uom        VARCHAR2(150);
  l_header_price_list       VARCHAR2(150);
  l_source_price_list_line_id NUMBER;
  l_locked_price_list_id      NUMBER;
  l_locked_price_list_line_id NUMBER;

  l_input_details             OKS_QP_PKG.INPUT_DETAILS;
  l_output_details            OKS_QP_PKG.PRICE_DETAILS;
  l_modif_details             QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  l_pb_details                OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
  l_status_tbl                oks_qp_int_pvt.PRICING_STATUS_TBL;
  l_pricing_effective_date    DATE;
  l_validate_result           VARCHAR2(10);
 -- End hkamdar 8/23/05 R12 Partial Period

  -- mkarra 06/21/07 Import Contracts Bug 6128632
  l_bill_y_n VARCHAR2(1);
  l_disp_warning VARCHAR2(1) ;

Begin

fnd_msg_pub.initialize;
IF NOT header_lines_tbl.COUNT=0 THEN


   i:=header_lines_tbl.FIRST;
   LOOP
      l_error := 'N'; -- 8/23/2005 hkamdar R12 Partial Period

      l_chr_id                    :=  header_lines_tbl(i).chr_id;
      l_cle_id                    :=  header_lines_tbl(i).cle_id;
      l_header_sto                :=  header_lines_tbl(i).header_sto;
      l_header_bto                :=  header_lines_tbl(i).header_bto;
      l_header_dates              :=  header_lines_tbl(i).header_dates;
      l_header_arl                :=  header_lines_tbl(i).header_arl;
      l_header_ire                :=  header_lines_tbl(i).header_ire;
      l_header_tax                :=  header_lines_tbl(i).header_tax;
      l_header_exception_number   :=  header_lines_tbl(i).header_exception_number;
      l_header_tax_code           :=  header_lines_tbl(i).header_tax_code;
      --Fixed bug#4026268 --gbgupta

      l_header_tax_code_id        :=  header_lines_tbl(i).header_tax_code_id;

      l_header_sales_credits      :=  header_lines_tbl(i).header_sales_credits;
      l_header_billto_contact     :=  header_lines_tbl(i).header_billto_contact;
      l_billto_id                 :=  header_lines_tbl(i).billto_id;
      l_billing_profile           :=  header_lines_tbl(i).billing_profile;
      l_billing_profile_id        :=  header_lines_tbl(i).billing_profile_id;
      l_calculate_tax             :=  header_lines_tbl(i).calculate_tax;
      l_payment_method            :=  header_lines_tbl(i).payment_method;
      -- GCHADHA --
      -- IKON --
      l_header_bca                :=  header_lines_tbl(i).header_bca;
      l_header_sca                :=  header_lines_tbl(i).header_sca;
      -- END GCHADHA --

       -- 8/23/2005 hkamdar R12 Partial Period
      l_header_price_uom 	  :=  header_lines_tbl(i).price_uom;
      l_header_price_list	  :=  header_lines_tbl(i).price_list;
       -- End 8/23/2005 hkamdar R12 Partial Period
      --Ebtax --
      l_header_tax_cls_code       :=  header_lines_tbl(i).header_tax_cls_code;
      --Ebtax --

      l_klnv_tbl_in.DELETE;
      l_clev_tbl_in.DELETE;
      l_kslnv_tbl_in.DELETE;-- /* Added for 7387293 */

-- check if the contract has been imported and fully billed at source or not

IF(l_chr_id IS NOT NULL) THEN
	select billed_at_source INTO l_bill_y_n FROM okc_k_headers_all_b where id = l_chr_id ;
END IF;

IF ((l_bill_y_n IS NOT NULL) AND (l_bill_y_n = 'Y')) THEN
	l_disp_warning :='Y';
ELSE
	l_disp_warning :='N';
END IF;



   OPEN  cur_okc_headers(l_chr_id );
   FETCH cur_okc_headers INTO l_okc_headers_rec;
   IF cur_okc_headers%NOTFOUND then
     CLOSE cur_okc_headers;
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     CLOSE cur_okc_headers;
   END IF;

   OPEN  cur_okc_lines(l_cle_id );
   FETCH cur_okc_lines INTO l_okc_lines_rec;
   IF cur_okc_lines%NOTFOUND then
     CLOSE cur_okc_lines;
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     CLOSE cur_okc_lines;
   END IF;

   OPEN  cur_oks_headers(l_chr_id );
   FETCH cur_oks_headers INTO l_oks_headers_rec;
   IF cur_oks_headers%NOTFOUND then
     CLOSE cur_oks_headers;
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     CLOSE cur_oks_headers;
   END IF;

   OPEN  cur_oks_lines(l_cle_id );
   FETCH cur_oks_lines INTO l_oks_lines_rec;
   IF cur_oks_lines%NOTFOUND then
     CLOSE cur_oks_lines;
     x_return_status := 'E';
     RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
     CLOSE cur_oks_lines;
   END IF;

   OPEN cur_header_dates(l_chr_id );
   FETCH cur_header_dates INTO header_dates_rec;
   IF cur_header_dates%NOTFOUND then
      CLOSE cur_header_dates;
      x_return_status := 'E';
   RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
      CLOSE cur_header_dates;
   END IF;

   OPEN cur_line_number(l_cle_id );
   FETCH cur_line_number INTO l_line_number;
   IF cur_line_number%NOTFOUND then
      CLOSE cur_line_number;
      x_return_status := 'E';
   RAISE G_EXCEPTION_HALT_VALIDATION;
   ELSE
      CLOSE cur_line_number;
   END IF;

 -- Bug 5191587 --
   If l_okc_lines_rec.lse_id in ('1','14','19') then
   l_sr_flag :=0;
    FOR cur_rec in cur_service_req_number(l_cle_id,l_chr_id)
    LOOP
        IF l_sr_flag <> 0 THEN
	l_sr_number := l_sr_number || ' ; ';
	END IF;
	l_sr_number := l_sr_number || cur_rec.incident_number;
	l_sr_flag :=1;
    END LOOP;

   /*   OPEN cur_service_req_number(l_cle_id );
      FETCH cur_service_req_number INTO l_service_req_rec;
      IF cur_service_req_number%NOTFOUND then
         CLOSE cur_service_req_number;
      ELSE
         l_sr_number := l_service_req_rec.incident_number;
         CLOSE cur_service_req_number;
      END IF;
   */
   End If;
    -- Bug 5191587 --

   l_klnv_tbl_in(1).OBJECT_VERSION_NUMBER         := l_oks_lines_rec.OBJECT_VERSION_NUMBER;

   If l_header_dates is not null then

--new

      If oks_extwar_util_pvt.check_already_billed(
                                                 p_chr_id => null,
                                                 p_cle_id => header_lines_tbl(i).cle_id,
                                                 p_lse_id => l_okc_lines_rec.lse_id,
                                                 p_end_date => null) Then


            validate_date
                      (p_api_version    => l_api_version
                      ,p_init_msg_list  => l_init_msg_list
                      ,p_hdr_id         => l_chr_id
                      ,p_top_line_id    => l_cle_id
                      ,p_sub_line_id    => NULL
                      ,x_return_status  => l_return_status
                      ,x_msg_count      => l_msg_count
                      ,x_msg_data       => l_msg_data
                      ,x_flag           => l_flag);

	    -- Bug 5227077 --
            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     FOR i in 1..fnd_msg_pub.count_msg
	     Loop
		fnd_msg_pub.get
		(
		 p_msg_index     => i,
		 p_encoded       => 'F',
                 p_data          => l_msg_data,
		 p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
		l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
	      Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Else
              If l_flag <> TRUE then
	         fnd_msg_pub.initialize;

                 OKC_API.SET_MESSAGE(
                    p_app_name        => 'OKS', --G_APP_NAME_OKS,
                    p_msg_name        => 'OKS_BA_UPDATE_NOT_ALLOWED',
                    p_token1	      => 'Line No ',
                    p_token1_value    => l_line_number);

	         l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                 p_encoded   => fnd_api.g_false);
                 x_msg_tbl(l_tot_msg_count).status       := 'E';
                 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                 l_tot_msg_count := l_tot_msg_count + 1;
                 l_msg_data := NULL;
                 Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              End If;
            End If;

      End If;

--new

        l_clev_tbl_in(1).id					 := l_cle_id;
        l_clev_tbl_in(1).chr_id				         := l_chr_id;
        l_clev_tbl_in(1).start_date		                 := header_dates_rec.start_date;
        l_clev_tbl_in(1).end_date		                 := header_dates_rec.end_date;
        l_clev_tbl_in(1).dnz_chr_id				 := l_chr_id;

        If l_okc_lines_rec.lse_id = '14' Then
           If l_clev_tbl_in(1).start_date > SYSDATE THen
              l_clev_tbl_in(1).sts_code  := 'SIGNED';
           Elsif l_clev_tbl_in(1).start_date <= SYSDATE And l_clev_tbl_in(1).end_date >= SYSDATE  THEN
              l_clev_tbl_in(1).sts_code  := 'ACTIVE';
           ELSIF l_clev_tbl_in(1).end_date < SYSDATE Then
              l_clev_tbl_in(1).sts_code :='EXPIRED';
           End if;
        End if;

   END IF;

   If  l_header_bto is not null then

       Open cur_head_cust_acct(l_okc_headers_rec.bill_to_site_use_id);
       fetch cur_head_cust_acct into l_head_cust_acct;
       close cur_head_cust_acct;

       Open cur_line_cust_acct(l_okc_lines_rec.id);
       fetch cur_line_cust_acct into l_line_cust_acct;
       close cur_line_cust_acct;
          If l_head_cust_acct = l_line_cust_acct or
             l_line_cust_acct is NULL and l_head_cust_acct is not NULL Then

             l_clev_tbl_in(1).id                    := l_cle_id;
	     l_clev_tbl_in(1).bill_to_site_use_id   := l_okc_headers_rec.bill_to_site_use_id;
             l_clev_tbl_in(1).cust_acct_id          := l_head_cust_acct;

             IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
              fnd_msg_pub.initialize;
              OKC_API.SET_MESSAGE(
                  p_app_name        => G_APP_NAME_OKS,
                  p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                  p_token1	    => 'ATTRIBUTE',
                  p_token1_value    => 'Bill To Address');

              l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                                        p_encoded   => fnd_api.g_false);

              x_msg_tbl(l_tot_msg_count).status       := 'S';
              x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
              l_tot_msg_count := l_tot_msg_count + 1;
              l_msg_data := NULL;

            END IF;
	    -- IKON ENHANCEMENT
         /* ElsIf l_head_cust_acct <> l_line_cust_acct  and
                l_line_cust_acct is not NULL and l_head_cust_acct is not NULL Then
                fnd_msg_pub.initialize;

              OKC_API.SET_MESSAGE(
                  p_app_name        => G_APP_NAME_OKS,
                  p_msg_name        => 'OKS_CASCADE_ACCOUNT_MISMATCH',
                  p_token1	    => 'Line No ',
                  p_token1_value    => l_line_number);

              l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                                            p_encoded   => fnd_api.g_false);

              x_msg_tbl(l_tot_msg_count).status       := 'E';
              x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
              l_tot_msg_count := l_tot_msg_count + 1;
              l_msg_data := NULL;
              If header_lines_tbl.FIRST = header_lines_tbl.LAST Then
                 Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              End If; */


          END IF; --l_head_cust_acct check
   END IF;

   If  l_header_sto is not null then
       -- IKON ENHANCEMENT --
       -- 2/11/2005
       Open cur_head_cust_acct(l_okc_headers_rec.ship_to_site_use_id);
       fetch cur_head_cust_acct into l_header_cust_acct;
       close cur_head_cust_acct;

    	Open CUR_CUST_ACCT(l_okc_lines_rec.ship_to_site_use_id,'SHIP_TO');
        fetch CUR_CUST_ACCT into l_line_cust_acct,l_party_id;
        close CUR_CUST_ACCT;

       --npalepu modified on 22-FEB-2007 for bug # 5742807. Added extra condition.
       /* If l_header_cust_acct = l_line_cust_acct THEN */

       If (l_header_cust_acct = l_line_cust_acct) or
             (l_line_cust_acct is NULL and l_header_cust_acct is not NULL) Then
       --end bug # 5742807

         l_clev_tbl_in(1).id		      := l_cle_id;
       	 l_clev_tbl_in(1).ship_to_site_use_id   := l_okc_headers_rec.ship_to_site_use_id;

       	 IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       	    fnd_msg_pub.initialize;
       	    OKC_API.SET_MESSAGE(
       	            p_app_name        => G_APP_NAME_OKS,
       	            p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
       	            p_token1	    => 'ATTRIBUTE',
       	            p_token1_value    => 'Ship To Address');

       	 --  fnd_msg_pub.initialize;
       	 l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
       	 p_encoded   => fnd_api.g_false);
       	 x_msg_tbl(l_tot_msg_count).status       := 'S';
       	 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
       	 l_tot_msg_count := l_tot_msg_count + 1;
       	 l_msg_data := NULL;
       	 END IF;
       END IF;
       -- IKON ENHANCEMENT --
   END IF;

  -- *******************************************************************
  -- IKON ENHANCEMENT --
   IF  l_header_bca is not null then

           -- l_oks_header_id is used to mark whether
	   -- OKS_K_HEADERS_B table should be update or not
	   -- If l_oks_header_id is 0 then
	   -- OKS_K_HEADERS_B should not be updated.
	   -- Else should be Updated.
	   -- Used only with l_header_bca variable.
	   l_oks_header_id :=0;

	   Open cur_head_cust_acct(l_okc_headers_rec.bill_to_site_use_id);
           fetch cur_head_cust_acct into l_header_cust_acct;
       	   close cur_head_cust_acct;

       	   Open cur_line_cust_acct(l_okc_lines_rec.id);
       	   fetch cur_line_cust_acct into l_line_cust_acct;
       	   close cur_line_cust_acct;


           -- CASE I If no BTO rule is there then create a BTO rule
	   -- CASE II If there is a BTO RULE then
	   --         Update the BTO rule at lines leve with header
	   --         level Customer account if the accounts are
	   --         not same.
	   --         Delete all contacts which are not
	   --         billing contact and are belonging to
	   --         ship to account Party Role
	   -- CASE I
	   IF l_header_cust_acct <> nvl(l_line_cust_acct, -1) THEN
             -- Create/UPDATE a CAN RULE  and Create/UPDATE the BTO Rule  --
               l_clev_tbl_in(1).id                    := l_cle_id;
	       l_clev_tbl_in(1).bill_to_site_use_id   := l_okc_headers_rec.bill_to_site_use_id;
               l_clev_tbl_in(1).cust_acct_id          := l_header_cust_acct;
	       l_klnv_tbl_in(1).ID                    := l_oks_lines_rec.ID;
	       l_oks_header_id                        := 1;

	       IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
		   IF l_line_cust_acct IS NULL THEN
		   fnd_msg_pub.initialize;
                      OKC_API.SET_MESSAGE(
                          p_app_name        => G_APP_NAME_OKS,
                          p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                          p_token1	    => 'ATTRIBUTE',
                          p_token1_value    => 'Bill To Address');

                       --  fnd_msg_pub.initialize;
                       l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                       p_encoded   => fnd_api.g_false);
                       x_msg_tbl(l_tot_msg_count).status       := 'S';
                       x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                       l_tot_msg_count := l_tot_msg_count + 1;
                       l_msg_data := NULL;
		   END IF;



		   fnd_msg_pub.initialize;
                   OKC_API.SET_MESSAGE(
                         p_app_name        => G_APP_NAME_OKS, -- bug 5468539 G_APP_NAME,
                         p_msg_name        =>'OKS_DEFAULT_ATTR_SUCCESS_NEW',
                         p_token1	   => 'TOKEN1' , -- bug 5468539 'RULE',
                         p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'));

                    --  fnd_msg_pub.initialize;
                    l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                    p_encoded   => fnd_api.g_false);
                    x_msg_tbl(l_tot_msg_count).status       := 'S';
                    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                    l_tot_msg_count := l_tot_msg_count + 1;
                    l_msg_data := NULL;

               END IF;
            END IF;
	   IF l_line_cust_acct is not NULL AND l_header_cust_acct <> l_line_cust_acct THEN
	        open Get_Party_Id (l_line_cust_acct);
             	fetch Get_party_id into l_line_party_id,l_temp_party_name;
             	close get_party_id;
		-- DELETE THE TAX EXEMPTION IF THERE
		-- Bug 5202208 --
		-- Modified code to keep a check for both Exempt_certificate_number
		-- and tax_exemption_id for contracts migrated from 11.5.10.
	--	IF l_oks_lines_rec.TAX_STATUS ='E' AND l_oks_lines_rec.TAX_EXEMPTION_ID IS NOT NULL THEN
                IF (l_oks_lines_rec.TAX_STATUS ='E' AND ( l_oks_lines_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL
						  OR l_oks_lines_rec.TAX_EXEMPTION_ID IS NOT NULL))
		THEN
                       l_klnv_tbl_in(1).ID                       := l_oks_lines_rec.ID;
		       l_klnv_tbl_in(1).TAX_STATUS               := NUll;
		       l_klnv_tbl_in(1).TAX_EXEMPTION_ID         := NULL;
		       l_klnv_tbl_in(1).EXEMPT_REASON_CODE       := NULL;
      		       l_klnv_tbl_in(1).EXEMPT_CERTIFICATE_NUMBER:= NULL;
		       l_klnv_tbl_in(1).CLE_ID                   := l_cle_id;
		       l_oks_header_id				 := 1;
		       -- Display a message --
		       IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
			   fnd_msg_pub.initialize;
                  	   OKC_API.SET_MESSAGE(
             	                p_app_name        => G_APP_NAME,
             	                p_msg_name        =>'OKS_CASCADE_DELETE_EXEMPTION',
             	                p_token1	    =>'TOKEN1' ,
                                p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'),
                                p_token2          => 'TOKEN2',
                                p_token2_value    =>  l_temp_party_name,
                                p_token3          => 'TOKEN3',
                                p_token3_value    =>  l_temp_line_number);
                  	    --  fnd_msg_pub.initialize;
                  	    l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                  	    p_encoded   => fnd_api.g_false);
                  	    x_msg_tbl(l_tot_msg_count).status       := 'S';
                  	    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                  	    l_tot_msg_count := l_tot_msg_count + 1;
                            l_msg_data := NULL;
                       END IF;
		END IF;
		-- Bug 5202208 --
		--GCHADHA --
		-- BUG 4394382 --
		-- DELETE COMMITMENT NUMBER
		IF l_oks_lines_rec.payment_type = 'COM' THEN
                       l_klnv_tbl_in(1).ID                       := l_oks_lines_rec.ID;
		       l_klnv_tbl_in(1).CLE_ID                   := l_cle_id;
		       l_klnv_tbl_in(1).commitment_id		 := NULL ;
                       l_klnv_tbl_in(1).payment_type		 := NULL ;
		       -- Display a message --
		       IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
			   fnd_msg_pub.initialize;
                  	   OKC_API.SET_MESSAGE(
             	                p_app_name        => G_APP_NAME,
             	                p_msg_name        =>'OKS_CASCADE_DELETE_COMMITMENT',
             	                p_token1	    =>'TOKEN1' ,
                                p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'),
                                p_token2          => 'TOKEN2',
                                p_token2_value    =>  l_temp_party_name,
                                p_token3          => 'TOKEN3',
                                p_token3_value    =>  l_temp_line_number);
                  	    --  fnd_msg_pub.initialize;
                  	    l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                  	    p_encoded   => fnd_api.g_false);
                  	    x_msg_tbl(l_tot_msg_count).status       := 'S';
                  	    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                  	    l_tot_msg_count := l_tot_msg_count + 1;
                            l_msg_data := NULL;
                       END IF;

		END IF;

		-- END GCHADHA --

		-- DELETE CONTACTS --

             	FOR  CUR_PARTY_REC IN CUR_LINE_PARTY_ROLE(l_chr_id, l_cle_id,l_line_party_id ) LOOP
             		l_cpl_id  := CUR_PARTY_REC.ID;

             	  	IF l_cpl_id is NOT NULL THEN
             	  	     l_contact_id := CHECK_LINE_CONTACT(l_chr_id,l_cpl_id); -- 5485054
             	  	     IF l_contact_id is NOT NULL THEN
		  	       	l_contact :=0;
             	  	        -- When Cascading Bill to Cust Account then Don't check for Shipping Contact
             	  	        FOR contact_rec in line_contact_jtot(l_cpl_id,l_chr_id,'OKX_CONTSHIP') LOOP

             	  	           Open Get_Contact_Cust_Acct(contact_rec.object1_id1);
             	  	           fetch Get_Contact_Cust_Acct into l_line_cust_acct;
             	  	           close Get_Contact_Cust_Acct;
             	  	           -- Delete the  contact when Contact Account Id is not same as
             	  	           -- header Account Id
             	  	           IF l_header_cust_acct <> l_line_cust_acct THEN

             	  	              l_ctcv_tbl_in(l_contact).id                    := contact_rec.id;
             	  	              l_ctcv_tbl_in(l_contact).cpl_id                := l_cpl_id;
             	  	              l_ctcv_tbl_in(l_contact).dnz_chr_id            := contact_rec.dnz_chr_ID;

             	  	              l_ctcv_tbl_in(l_contact).cro_code              := contact_rec.cro_code;
             	  	              l_ctcv_tbl_in(l_contact).OBJECT1_ID1           := contact_rec.object1_id1;
             	  	              l_ctcv_tbl_in(l_contact).object1_id2           := contact_rec.OBJECT1_ID2;
             	  	              l_ctcv_tbl_in(l_contact).JTOT_OBJECT1_CODE     := contact_rec.JTOT_OBJECT1_CODE ;
             	  	              l_ctcv_tbl_in(l_contact).start_date            := contact_rec.START_DATE;
             	  	              l_ctcv_tbl_in(l_contact).end_date              := contact_rec.END_DATE;
             	  	              l_ctcv_tbl_in(l_contact).attribute_category    := contact_rec.ATTRIBUTE_CATEGORY;
             	  	              l_ctcv_tbl_in(l_contact).attribute1            := contact_rec.ATTRIBUTE1;
             	  	              l_ctcv_tbl_in(l_contact).attribute2            := contact_rec.ATTRIBUTE2;
             	  	              l_ctcv_tbl_in(l_contact).attribute3            := contact_rec.ATTRIBUTE3;
             	  	              l_ctcv_tbl_in(l_contact).attribute4            := contact_rec.ATTRIBUTE4;
             	  	              l_ctcv_tbl_in(l_contact).attribute5            := contact_rec.ATTRIBUTE5;
             	  	              l_ctcv_tbl_in(l_contact).attribute6            := contact_rec.ATTRIBUTE6;
             	  	              l_ctcv_tbl_in(l_contact).attribute7            := contact_rec.ATTRIBUTE7;
             	  	              l_ctcv_tbl_in(l_contact).attribute8            := contact_rec.ATTRIBUTE8;
             	  	              l_ctcv_tbl_in(l_contact).attribute9            := contact_rec.ATTRIBUTE9;
             	  	              l_ctcv_tbl_in(l_contact).attribute10           := contact_rec.ATTRIBUTE10;
             	  	              l_ctcv_tbl_in(l_contact).attribute11           := contact_rec.ATTRIBUTE11;
             	  	              l_ctcv_tbl_in(l_contact).attribute12           := contact_rec.ATTRIBUTE12;
             	  	              l_ctcv_tbl_in(l_contact).attribute13           := contact_rec.ATTRIBUTE13;
             	  	              l_ctcv_tbl_in(l_contact).attribute14           := contact_rec.ATTRIBUTE14;
             	  	              l_ctcv_tbl_in(l_contact).attribute15           := contact_rec.ATTRIBUTE15;
             	  	              l_ctcv_tbl_in(l_contact).object_version_number := contact_rec.object_version_number;
             	  	              l_ctcv_tbl_in(l_contact).created_by            := contact_rec.created_by;
             	  	              l_ctcv_tbl_in(l_contact).creation_date         := contact_rec.creation_date;
             	  	              l_ctcv_tbl_in(l_contact).last_updated_by       := contact_rec.last_updated_by;
             	  	              l_ctcv_tbl_in(l_contact).last_update_date      := contact_rec.last_update_date;
             	  	              l_ctcv_tbl_in(l_contact).last_update_login     := contact_rec.last_update_login;
             	  	              l_contact  := l_contact+1;
             	  	           END IF ;-- line_contact_cust_acct
             	  	         END LOOP;

             	  	         IF l_header_cust_acct <> l_line_cust_acct OR l_contact > 1 THEN

             	  	             okc_contract_party_pub.delete_contact
             	  	              (p_api_version    => l_api_version,
             	  	               p_init_msg_list  => l_init_msg_list,
             	  	               x_return_status  => l_return_status,
             	  	               x_msg_count      => l_msg_count,
             	  	               x_msg_data       => l_msg_data,
             	  	               p_ctcv_tbl       => l_ctcv_tbl_in
             	  	              );

             	  	                  -- Delete Party Role --
             	  	                 IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
             	  	                 -- Check if there is any contaact Present belonging to the party role ---
             	  	                     l_temp_contact_id := CHECK_LINE_CONTACT(l_chr_id,l_cpl_id);-- 5485054
             	  	                     IF nvl(l_temp_contact_id,0) = 0 THEN


             	  	                          l_cplv_tbl_in(i).id             := l_cpl_id ;--l_party_role.id;
             	   	                          l_cplv_tbl_in(i).cle_id         := l_cle_id ;-- l_party_role.cle_id;
             	   	                          l_cplv_tbl_in(i).dnz_chr_id     := l_chr_id ; --l_party_role.dnz_chr_id;
		  	                         okc_contract_party_pub.delete_k_party_role
             	  	                           (p_api_version   => l_api_version,
             	  	                            p_init_msg_list  => l_init_msg_list,
             	  	                            x_return_status  => l_return_status,
             	  	                            x_msg_count      => l_msg_count,
             	  	                            x_msg_data       => l_msg_data,
             	  	                            p_cplv_tbl       => l_cplv_tbl_in);


             	  	                           IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
						           Open cur_get_line_number(l_cle_id, l_chr_id);
							   fetch cur_get_line_number into l_temp_line_number;
							   close cur_get_line_number;
							  fnd_msg_pub.initialize;
             	  	                                  OKC_API.SET_MESSAGE(
             	  	                                  p_app_name        => G_APP_NAME,
             	  	                                  p_msg_name        =>'OKS_CASCADE_CHANGE_ACCOUNT',
             	  	                                  p_token1	    =>'TOKEN1' ,
                  	                                  p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'),
                  	        			  p_token2          => 'TOKEN2',
                  	        			  p_token2_value    =>  l_temp_party_name,
                  	        			  p_token3          => 'TOKEN3',
                  	                                  p_token3_value    =>  l_temp_line_number);
							   --  fnd_msg_pub.initialize;
       							  l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
       	                 				  p_encoded   => fnd_api.g_false);
       	                 				  x_msg_tbl(l_tot_msg_count).status       := 'S';
       	                 				  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
       	                 				  l_tot_msg_count := l_tot_msg_count + 1;
       	 						  l_msg_data := NULL;
             	  	                            END IF;
             	  	                     ELSE
             	  	                          IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
						           Open cur_get_line_number(l_cle_id, l_chr_id);
							   fetch cur_get_line_number into l_temp_line_number;
							   close cur_get_line_number;
							  fnd_msg_pub.initialize;
             	  	                                  OKC_API.SET_MESSAGE(
             	  	                                  p_app_name        => G_APP_NAME,
             	  	                                  p_msg_name        =>'OKS_CASCADE_CHANGE_ACCOUNT',
             	  	                                  p_token1	    =>'TOKEN1' ,
                  	                                  p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'),
                  	        			  p_token2          => 'TOKEN2',
                  	        			  p_token2_value    =>  l_temp_party_name,
                  	        			  p_token3          => 'TOKEN3',
                  	                                  p_token3_value    =>  l_temp_line_number);
							   --  fnd_msg_pub.initialize;
       							  l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
       	                 				  p_encoded   => fnd_api.g_false);
       	                 				  x_msg_tbl(l_tot_msg_count).status       := 'S';
       	                 				  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
       	                 				  l_tot_msg_count := l_tot_msg_count + 1;
       	 						  l_msg_data := NULL;
             	  	                            END IF;

             	  	                     END IF;     -- IF nvl(l_temp_contact_id,0) = 0 THEN
					 -- Bug 5227077 --
					 ELSIF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
					     FOR i in 1..fnd_msg_pub.count_msg
					     Loop
					         fnd_msg_pub.get
						 (
						     p_msg_index     => i,
					             p_encoded       => 'F',
					             p_data          => l_msg_data,
					             p_msg_index_out => l_msg_index
					          );
						x_msg_tbl(l_tot_msg_count).status       := l_return_status;
					        x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
					        l_tot_msg_count := l_tot_msg_count + 1;
					        l_msg_data := NULL;
					      End Loop;
					      Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             	  	                 END IF;
					 -- Bug 5227077 --
             	  	               END IF;
         	  	          END IF; -- IF l_contact_id is NOT NULL THEN
	 	      END IF; --  IF l_cpl_id is NOT NULL THEN
             	 END LOOP; -- CUR_PARTY_REC
	   END IF;


   END IF;
  -- IKON ENHANCEMENT --
  -- *******************************************************************
  -- *******************************************************************
  -- IKON ENHANCEMENT --
   IF  l_header_sca is not null then

	   Open cur_head_cust_acct(l_okc_headers_rec.ship_to_site_use_id);
           fetch cur_head_cust_acct into l_header_cust_acct;
       	   close cur_head_cust_acct;


	   Open CUR_CUST_ACCT(l_okc_lines_rec.ship_to_site_use_id,'SHIP_TO');
           fetch CUR_CUST_ACCT into l_line_cust_acct,l_party_id;
           close CUR_CUST_ACCT;



           -- CASE I If no STO rule is there then create a BTO rule
	   -- CASE II If there is a STO RULE then
	   --         Update the STO rule at lines leve with header
	   --         level Customer account if the accounts are
	   --         not same.
	   --         Delete all contacts which are not
	   --         billing contact and are belonging to
	   --         ship to account Party Role
	   -- CASE I
	   IF l_header_cust_acct <> nvl(l_line_cust_acct, -1) THEN
             -- Create/UPDATE a CAN RULE  and Create/UPDATE the BTO Rule  --
               l_clev_tbl_in(1).id                    := l_cle_id;
	       l_clev_tbl_in(1).ship_to_site_use_id   := l_okc_headers_rec.ship_to_site_use_id;
               IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

		   IF l_line_cust_acct IS NULL THEN
		   fnd_msg_pub.initialize;
                      OKC_API.SET_MESSAGE(
                          p_app_name        => G_APP_NAME_OKS,
                          p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                          p_token1	    => 'ATTRIBUTE',
                          p_token1_value    => 'Ship To Address');

                       --  fnd_msg_pub.initialize;
                       l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                       p_encoded   => fnd_api.g_false);
                       x_msg_tbl(l_tot_msg_count).status       := 'S';
                       x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                       l_tot_msg_count := l_tot_msg_count + 1;
                       l_msg_data := NULL;
		   END IF;

		   fnd_msg_pub.initialize;
                   OKC_API.SET_MESSAGE(
                         p_app_name        => G_APP_NAME_OKS, -- bug 5468539 G_APP_NAME,
                         p_msg_name        =>'OKS_DEFAULT_ATTR_SUCCESS_NEW',
                         p_token1	   => 'TOKEN1', -- bug 5468539 'RULE',
                         p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_SHIP_TO_CUSTOMER_ACCOUNT'));

                    --  fnd_msg_pub.initialize;
                    l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                    p_encoded   => fnd_api.g_false);
                    x_msg_tbl(l_tot_msg_count).status       := 'S';
                    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                    l_tot_msg_count := l_tot_msg_count + 1;
                    l_msg_data := NULL;

       	       END IF;

            -- CASE II
           END IF;
	   IF l_line_cust_acct is not NULL AND l_header_cust_acct <> l_line_cust_acct THEN
	        open Get_Party_Id (l_line_cust_acct);
             	fetch Get_party_id into l_line_party_id,l_temp_party_name;
             	close get_party_id;

		-- DELETE CONTACTS --

             	FOR  CUR_PARTY_REC IN CUR_LINE_PARTY_ROLE(l_chr_id, l_cle_id,l_line_party_id ) LOOP
             		l_cpl_id  := CUR_PARTY_REC.ID;

             	  	IF l_cpl_id is NOT NULL THEN
             	  	     l_contact_id := CHECK_LINE_CONTACT(l_chr_id,l_cpl_id );-- 5485054
             	  	     IF l_contact_id is NOT NULL THEN
		  	       	l_contact :=0;
             	  	        -- When Cascading Bill to Cust Account then Don't check for Shipping Contact
             	  	        FOR contact_rec in line_contact_jtot(l_cpl_id,l_chr_id,'OKX_CONTBILL') LOOP

             	  	           Open Get_Contact_Cust_Acct(contact_rec.object1_id1);
             	  	           fetch Get_Contact_Cust_Acct into l_line_cust_acct;
             	  	           close Get_Contact_Cust_Acct;
             	  	           -- Delete the  contact when Contact Account Id is not same as
             	  	           -- header Account Id
             	  	           IF l_header_cust_acct <> l_line_cust_acct THEN

             	  	              l_ctcv_tbl_in(l_contact).id                    := contact_rec.id;
             	  	              l_ctcv_tbl_in(l_contact).cpl_id                := l_cpl_id;
             	  	              l_ctcv_tbl_in(l_contact).dnz_chr_id            := contact_rec.dnz_chr_ID;

             	  	              l_ctcv_tbl_in(l_contact).cro_code              := contact_rec.cro_code;
             	  	              l_ctcv_tbl_in(l_contact).OBJECT1_ID1           := contact_rec.object1_id1;
             	  	              l_ctcv_tbl_in(l_contact).object1_id2           := contact_rec.OBJECT1_ID2;
             	  	              l_ctcv_tbl_in(l_contact).JTOT_OBJECT1_CODE     := contact_rec.JTOT_OBJECT1_CODE ;
             	  	              l_ctcv_tbl_in(l_contact).start_date            := contact_rec.START_DATE;
             	  	              l_ctcv_tbl_in(l_contact).end_date              := contact_rec.END_DATE;
             	  	              l_ctcv_tbl_in(l_contact).attribute_category    := contact_rec.ATTRIBUTE_CATEGORY;
             	  	              l_ctcv_tbl_in(l_contact).attribute1            := contact_rec.ATTRIBUTE1;
             	  	              l_ctcv_tbl_in(l_contact).attribute2            := contact_rec.ATTRIBUTE2;
             	  	              l_ctcv_tbl_in(l_contact).attribute3            := contact_rec.ATTRIBUTE3;
             	  	              l_ctcv_tbl_in(l_contact).attribute4            := contact_rec.ATTRIBUTE4;
             	  	              l_ctcv_tbl_in(l_contact).attribute5            := contact_rec.ATTRIBUTE5;
             	  	              l_ctcv_tbl_in(l_contact).attribute6            := contact_rec.ATTRIBUTE6;
             	  	              l_ctcv_tbl_in(l_contact).attribute7            := contact_rec.ATTRIBUTE7;
             	  	              l_ctcv_tbl_in(l_contact).attribute8            := contact_rec.ATTRIBUTE8;
             	  	              l_ctcv_tbl_in(l_contact).attribute9            := contact_rec.ATTRIBUTE9;
             	  	              l_ctcv_tbl_in(l_contact).attribute10           := contact_rec.ATTRIBUTE10;
             	  	              l_ctcv_tbl_in(l_contact).attribute11           := contact_rec.ATTRIBUTE11;
             	  	              l_ctcv_tbl_in(l_contact).attribute12           := contact_rec.ATTRIBUTE12;
             	  	              l_ctcv_tbl_in(l_contact).attribute13           := contact_rec.ATTRIBUTE13;
             	  	              l_ctcv_tbl_in(l_contact).attribute14           := contact_rec.ATTRIBUTE14;
             	  	              l_ctcv_tbl_in(l_contact).attribute15           := contact_rec.ATTRIBUTE15;
             	  	              l_ctcv_tbl_in(l_contact).object_version_number := contact_rec.object_version_number;
             	  	              l_ctcv_tbl_in(l_contact).created_by            := contact_rec.created_by;
             	  	              l_ctcv_tbl_in(l_contact).creation_date         := contact_rec.creation_date;
             	  	              l_ctcv_tbl_in(l_contact).last_updated_by       := contact_rec.last_updated_by;
             	  	              l_ctcv_tbl_in(l_contact).last_update_date      := contact_rec.last_update_date;
             	  	              l_ctcv_tbl_in(l_contact).last_update_login     := contact_rec.last_update_login;
             	  	              l_contact  := l_contact+1;
             	  	           END IF ;-- line_contact_cust_acct
             	  	         END LOOP;

             	  	         IF l_header_cust_acct <> l_line_cust_acct OR l_contact > 1 THEN
             	  	             okc_contract_party_pub.delete_contact
             	  	              (p_api_version    => l_api_version,
             	  	               p_init_msg_list  => l_init_msg_list,
             	  	               x_return_status  => l_return_status,
             	  	               x_msg_count      => l_msg_count,
             	  	               x_msg_data       => l_msg_data,
             	  	               p_ctcv_tbl       => l_ctcv_tbl_in
             	  	              );

             	  	                  -- Delete Party Role --
             	  	                 IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
             	  	                 -- Check if there is any contaact Present belonging to the party role ---
             	  	                     l_temp_contact_id := CHECK_LINE_CONTACT(l_chr_id,l_cpl_id);-- 5485054
             	  	                     IF nvl(l_temp_contact_id,0) = 0 THEN
             	  	                        --  Open Party_role_csr(l_chr_id,l_cle_id);
             	  	                        --  fetch Party_role_csr into l_party_role;
             	  	                      --    close Party_role_csr;

             	  	                          l_cplv_tbl_in(i).id             := l_cpl_id ;--l_party_role.id;
             	   	                          l_cplv_tbl_in(i).cle_id         := l_cle_id ;-- l_party_role.cle_id;
             	   	                          l_cplv_tbl_in(i).dnz_chr_id     := l_chr_id ; --l_party_role.dnz_chr_id;
		  	                         okc_contract_party_pub.delete_k_party_role
             	  	                           (p_api_version   => l_api_version,
             	  	                            p_init_msg_list  => l_init_msg_list,
             	  	                            x_return_status  => l_return_status,
             	  	                            x_msg_count      => l_msg_count,
             	  	                            x_msg_data       => l_msg_data,
             	  	                            p_cplv_tbl       => l_cplv_tbl_in);


             	  	                           IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
						          Open cur_get_line_number(l_cle_id, l_chr_id);
							  fetch cur_get_line_number into l_temp_line_number;
							  close cur_get_line_number;
							  fnd_msg_pub.initialize;
             	  	                                  OKC_API.SET_MESSAGE(
             	  	                                  p_app_name        => G_APP_NAME,
             	  	                                  p_msg_name        =>'OKS_CASCADE_CHANGE_ACCOUNT',
             	  	                                  p_token1	    =>'TOKEN1' ,
                  	                                  p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_BILL_TO_CUSTOMER_ACCOUNT'),
                  	        			  p_token2          => 'TOKEN2',
                  	        			  p_token2_value    =>  l_temp_party_name,
                  	        			  p_token3          => 'TOKEN3',
                  	                                  p_token3_value    =>  l_temp_line_number);
							   --  fnd_msg_pub.initialize;
       							  l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
       	                 				  p_encoded   => fnd_api.g_false);
       	                 				  x_msg_tbl(l_tot_msg_count).status       := 'S';
       	                 				  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
       	                 				  l_tot_msg_count := l_tot_msg_count + 1;
       	 						  l_msg_data := NULL;
             	  	                            END IF;
             	  	                     ELSE
             	  	                          IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
						          Open cur_get_line_number(l_cle_id, l_chr_id);
							   fetch cur_get_line_number into l_temp_line_number;
							   close cur_get_line_number;
							  fnd_msg_pub.initialize;
             	  	                                  OKC_API.SET_MESSAGE(
             	  	                                  p_app_name        => G_APP_NAME,
             	  	                                  p_msg_name        =>'OKS_CASCADE_CHANGE_ACCOUNT',
             	  	                                  p_token1	    =>'TOKEN1' ,
                  	                                  p_token1_value    => FND_MESSAGE.GET_STRING('OKS','OKS_SHIP_TO_CUSTOMER_ACCOUNT'),
                  	        			  p_token2          => 'TOKEN2',
                  	        			  p_token2_value    =>  l_temp_party_name,
                  	        			  p_token3          => 'TOKEN3',
                  	                                  p_token3_value    =>  l_temp_line_number);
							   --  fnd_msg_pub.initialize;
       							  l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
       	                 				  p_encoded   => fnd_api.g_false);
       	                 				  x_msg_tbl(l_tot_msg_count).status       := 'S';
       	                 				  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
       	                 				  l_tot_msg_count := l_tot_msg_count + 1;
       	 						  l_msg_data := NULL;
             	  	                            END IF;

             	  	                     END IF;     -- IF nvl(l_temp_contact_id,0) = 0 THEN
					 -- Bug 5227077 --
					 ELSIF  l_return_status <> OKC_API.G_RET_STS_SUCCESS
					 THEN
						FOR i in 1..fnd_msg_pub.count_msg
						Loop
						     fnd_msg_pub.get
					             (
					    	        p_msg_index     => i,
						        p_encoded       => 'F',
					                p_data          => l_msg_data,
						        p_msg_index_out => l_msg_index
						      );
						    x_msg_tbl(l_tot_msg_count).status       := l_return_status;
						    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
						    l_tot_msg_count := l_tot_msg_count + 1;
						    l_msg_data := NULL;
						 End Loop;
						 Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

             	  	                 END IF;
             	  			 -- Bug 5227077 --
				       END IF;
         	  	          END IF; -- IF l_contact_id is NOT NULL THEN
	 	      END IF; --  IF l_cpl_id is NOT NULL THEN
             	 END LOOP; -- CUR_PARTY_REC
	   END IF;


   END IF;
  -- IKON ENHANCEMENT --
  -- *******************************************************************
 If  (l_header_billto_contact is not null) and (l_billto_id is not null) then -- GC

         /*OPEN cur_cust_acct_id(l_chr_id, l_billto_id);
         FETCH cur_cust_acct_id INTO l_lov_cust_acct;
         CLOSE cur_cust_acct_id; */

	 Open cur_head_cust_acct(l_okc_headers_rec.bill_to_site_use_id);
         fetch cur_head_cust_acct into l_header_cust_acct;
         close cur_head_cust_acct;

       	 Open cur_line_cust_acct(l_okc_lines_rec.id);
       	 fetch cur_line_cust_acct into l_line_cust_acct;
       	 close cur_line_cust_acct;


	--l_header_cust_acct is the customer account associated with the header level
	--l_line_cust_acct is the customer account associated with the contract line

	 IF ( l_header_cust_acct = l_line_cust_acct) then
	        Open cur_get_party_id(l_line_cust_acct);
		fetch cur_get_party_id into l_party_id;
       		close cur_get_party_id;

		l_cpl_id  := CHECK_LINE_PARTY_ROLE(P_DNZ_Chr_Id =>l_chr_id,
                                          P_cle_id     =>l_cle_id,
					  p_party_id   => l_party_id);

		l_can_id := l_line_cust_acct;

		If l_cpl_id IS NULL Then -- GC --00
		    CREATE_LINE_PARTY_ROLE
		      (P_DNZ_Chr_Id => l_chr_id ,
		       P_Cle_Id     => l_cle_id,
		       P_billto_Id  => l_billto_id,
		       p_can_id     => l_can_id,
		       x_cpl_id     => l_cpl_id,
		       x_return_status => l_return_status -- 5219132 --
			);
		     -- Bug 5219132 --

		    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS)
		    THEN
		      FOR i in 1..fnd_msg_pub.count_msg
		      Loop
		         fnd_msg_pub.get
			(
			  p_msg_index     => i,
			  p_encoded       => 'F',
			  p_data          => l_msg_data,
			  p_msg_index_out => l_msg_index
			);
			x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
		        l_tot_msg_count := l_tot_msg_count + 1;
			l_msg_data := NULL;
		       End Loop;
		       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		     END IF;

    		    -- Bug 5219132 --
		    l_contact_id := CHECK_LINE_BILL_CONTACT(l_chr_id,l_cpl_id, 'OKX_CONTBILL', 'CUST_BILLING');-- Bug 5485054

                ELSE
		    l_contact_id := CHECK_LINE_BILL_CONTACT(l_chr_id,l_cpl_id, 'OKX_CONTBILL', 'CUST_BILLING'); -- 5485054
		END IF; -- GC --00

		IF l_contact_id IS  NULL AND l_header_billto_contact IS NOT NULL THEN -- GC-01

		        l_ctcv_tbl_in(1).cpl_id                := l_cpl_id;
			l_ctcv_tbl_in(1).dnz_chr_id            := l_chr_id ;
			l_ctcv_tbl_in(1).cro_code              := 'CUST_BILLING';
			l_ctcv_tbl_in(1).OBJECT1_ID1           := l_billto_id;
			l_ctcv_tbl_in(1).object1_id2           := '#';
			--- l_ctcv_tbl_in(1).JTOT_OBJECT1_CODE     := cur_header_contact_rec.JTOT_OBJECT1_CODE;
			l_ctcv_tbl_in(1).JTOT_OBJECT1_CODE     :='OKX_CONTBILL';
		        okc_contract_party_pub.create_contact
			( p_api_version     => l_api_version,
    			  p_init_msg_list   => l_init_msg_list,
    			  x_return_status   => l_return_status,
    			  x_msg_count       => l_msg_count,
    			  x_msg_data        => l_msg_data,
    			  p_ctcv_tbl        => l_ctcv_tbl_in,
    			  x_ctcv_tbl        => l_ctcv_tbl_out);


		       IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		        -- Bug 5227077 --
			  FOR i in 1..fnd_msg_pub.count_msg
			  Loop
			    fnd_msg_pub.get
			       (
				p_msg_index     => i,
				p_encoded       => 'F',
				p_data          => l_msg_data,
				p_msg_index_out => l_msg_index
				);
			     x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			     l_tot_msg_count := l_tot_msg_count + 1;
			     l_msg_data := NULL;
			 End Loop;
			-- Bug 5227077 --
		         Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		       ELSE
		  	 fnd_msg_pub.initialize;
			 OKC_API.SET_MESSAGE(
			 p_app_name        => G_APP_NAME_OKS,
			 p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
			 p_token1	       => 'ATTRIBUTE',
			 p_token1_value    => 'Bill To Contact');
 			 l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
			 p_encoded   => fnd_api.g_false);
			 x_msg_tbl(l_tot_msg_count).status       := 'S';
			 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			 l_tot_msg_count := l_tot_msg_count + 1;
			 l_msg_data := NULL;
	               END IF;
		ELSIF (l_contact_id IS NOT NULL) AND (l_header_billto_contact IS NOT NULL) THEN
		       l_ctcv_tbl_in(1).id                    := l_contact_id;
		       l_ctcv_tbl_in(1).cpl_id                := l_cpl_id;
		       l_ctcv_tbl_in(1).OBJECT1_ID1           := l_billto_id;
	               okc_contract_party_pub.update_contact
		       (p_api_version    => l_api_version,
			p_init_msg_list  => l_init_msg_list,
			x_return_status  => l_return_status,
			x_msg_count      => l_msg_count,
			x_msg_data       => l_msg_data,
			p_ctcv_tbl       => l_ctcv_tbl_in,
			x_ctcv_tbl       => l_ctcv_tbl_out);

			IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			-- Bug 5227077 --
			   FOR i in 1..fnd_msg_pub.count_msg
			   Loop
			     fnd_msg_pub.get
				(
				  p_msg_index     => i,
				  p_encoded       => 'F',
				  p_data          => l_msg_data,
				  p_msg_index_out => l_msg_index
				);
			      x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			      x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			      l_tot_msg_count := l_tot_msg_count + 1;
			      l_msg_data := NULL;
			   End Loop;
			-- Bug 5227077 --
			   Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
			ELSE
			   fnd_msg_pub.initialize;
			   OKC_API.SET_MESSAGE(
			 	p_app_name        => G_APP_NAME_OKS,
				p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
				p_token1	       => 'ATTRIBUTE',
				p_token1_value    => 'Bill To Contact');
		                l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
				p_encoded   => fnd_api.g_false);
				x_msg_tbl(l_tot_msg_count).status       := 'S';
				x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				l_tot_msg_count := l_tot_msg_count + 1;
				l_msg_data := NULL;

		        END IF;


		END IF; --End GC-01

	ELSIF(l_header_cust_acct <> l_line_cust_acct)
	THEN
	       fnd_msg_pub.initialize;
               OKC_API.SET_MESSAGE(
                  p_app_name        => G_APP_NAME,
                  p_msg_name        => 'OKS_CASCADE_BTOACCT_MISMATCH',
                  p_token1	    => 'Line No ',
                  p_token1_value    => l_line_number);

                  l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                                            p_encoded   => fnd_api.g_false);

                  x_msg_tbl(l_tot_msg_count).status       := 'W'; -- Bug 5219132
                  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                  l_tot_msg_count := l_tot_msg_count + 1;
                  l_msg_data := NULL;

	 END IF; --  l_header_cust_acct

   END IF; --GC

   --l_line_tax_status := 'Z'; --BUG#4089834 hkamdar
   l_line_tax_status := l_oks_lines_rec.tax_status;

   IF l_header_tax IS NOT NULL OR l_header_exception_number IS NOT NULL THEN
    -- IKON ENHANCEMENT --
       Open cur_head_cust_acct(l_okc_headers_rec.bill_to_site_use_id);
       fetch cur_head_cust_acct into l_header_cust_acct;
       close cur_head_cust_acct;
       l_line_cust_acct := l_okc_lines_rec.cust_acct_id;
    -- IKON ENHANCEMENT --
       IF l_header_tax IS NOT NULL THEN
         --l_insupd_flag := TRUE;
          l_status_flag := TRUE;
         --Fixed bug#4026268 --gbgupta
         --IF l_oks_headers_rec.tax_status = 'R' THEN
            --l_oks_headers_rec.tax_code       := l_header_tax_code;

         --ELSIF l_oks_headers_rec.tax_status = 'E' THEN

	 --IF l_oks_headers_rec.tax_status = 'E'  THEN
         IF l_oks_headers_rec.tax_status = 'E'  THEN

           l_klnv_tbl_in(1).tax_code     := NULL;
	   -- Ebtax --
           /*
	   IF l_header_exception_number IS NULL THEN
              l_line_tax_status := l_oks_lines_rec.tax_status;
              IF NVL(l_line_tax_status,'X') = 'E' THEN --hkamdar added NVL BUG# 4089834
                -- l_insupd_flag := FALSE;
                 l_status_flag := FALSE;
              END IF;
           END IF; -- For l_header_exception_number
	   */
          -- 12/1/2005 --
	  --GCHADHA --
	  /*
	   -- When the Tax Status is Exempt then Tax Classification Code should
	   -- be Nullified.
	   l_klnv_tbl_in(1).tax_classification_code     := NULL;
	   -- Ebtax --
	   */
	   -- END GCHADHA --
         END IF;
       ELSIF l_header_exception_number IS NOT NULL THEN
         l_line_tax_status := l_oks_lines_rec.tax_status;
       --Fixed Tax exemption is cascading to line along with bug#4026268 --gbgupta
       --Checking else part first. so that it can handle null tax status
       /*
         IF l_line_tax_status IN('R','S') THEN
            l_insupd_flag := FALSE;
         ELSE
           l_insupd_flag := TRUE;
         END IF;
       */
         IF NVL(l_line_tax_status,'X') = 'E' THEN--hkamdar added NVL BUG# 4089834
            --l_insupd_flag := TRUE;
            l_exmpt_num_flag := TRUE;
         ELSE
           --l_insupd_flag := FALSE;
           l_exmpt_num_flag := FALSE;
         END IF;
       ELSE
         --l_insupd_flag := FALSE;
         l_status_flag := FALSE;
         l_exmpt_num_flag := FALSE;
      END IF; --l_header_tax

--      IF l_insupd_flag THEN
      -- IKON ENHANCEMENT --
      IF  l_header_cust_acct <> l_line_cust_acct AND l_oks_headers_rec.tax_status = 'E'
      AND l_header_bca is NULL -- 5/30/2005
      THEN
         l_status_flag := FALSE;
         l_exmpt_num_flag := FALSE;
      END IF ;
      -- IKON ENHANCEMENT --

      IF l_status_flag or l_exmpt_num_flag THEN

         l_klnv_tbl_in(1).ID           := l_oks_lines_rec.ID;
         --Fixed bug#4026268 --gbgupta
        -- l_klnv_tbl_in(1).tax_code     := l_oks_headers_rec.tax_code;
         --BUG# 4089834 HKAMDAR
	 -- IKON ENHANCEMENT --
         -- if l_status_flag   then
         If l_status_flag   then
	 -- IKON ENHANCEMENT --
	    l_klnv_tbl_in(1).tax_status   := l_oks_headers_rec.tax_status;
	    -- If l_header_tax_code is not null  THEN
	    If l_header_tax_cls_code is not null  THEN
	       -- ebtax --
	       l_klnv_tbl_in(1).tax_classification_code := l_header_tax_cls_code;
	       l_klnv_tbl_in(1).tax_code      := NULL;
	       l_klnv_tbl_in(1).tax_exemption_id := NULL;
	     --   l_klnv_tbl_in(1).exempt_certificate_number := NULL;
	     --   l_klnv_tbl_in(1).exempt_reason_code := NULL;

            ELSE
	       l_klnv_tbl_in(1).tax_exemption_id := NULL;
	      -- l_klnv_tbl_in(1).exempt_certificate_number := NULL;
	      -- l_klnv_tbl_in(1).exempt_reason_code := NULL;
	    End if;
           -- Ebtax --
            If  NVL(l_oks_headers_rec.tax_status, 'X') = 'E' THEN
	        -- Ebtax --
		-- l_klnv_tbl_in(1).tax_exemption_id := l_oks_headers_rec.tax_exemption_id;
		IF l_oks_headers_rec.tax_exemption_id IS NOT NULL
		THEN

			OPEN tax_exemption_number_csr(l_oks_headers_rec.tax_exemption_id);
			FETCH tax_exemption_number_csr INTO tax_exemption_number_rec;
			CLOSE tax_exemption_number_csr;
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
	  		l_klnv_tbl_in(1).exempt_reason_code := tax_exemption_number_rec.description;
			l_klnv_tbl_in(1).exempt_certificate_number := tax_exemption_number_rec.customer_exception_number;


		ELSIF l_oks_headers_rec.exempt_certificate_number is NOT NULL
		THEN
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
			l_klnv_tbl_in(1).exempt_reason_code := l_oks_headers_rec.exempt_reason_code;
			l_klnv_tbl_in(1).exempt_certificate_number := l_oks_headers_rec.exempt_certificate_number;
		END IF;
		-- Ebtax --

	    End if;
         End if;
	 -- IKON ENHANCEMENT --
         IF l_exmpt_num_flag then
	 -- IKON ENHANCEMENT --

	         -- Ebtax --
		-- l_klnv_tbl_in(1).tax_exemption_id := l_oks_headers_rec.tax_exemption_id;
		IF l_oks_headers_rec.tax_exemption_id IS NOT NULL
		THEN
			OPEN tax_exemption_number_csr(l_oks_headers_rec.tax_exemption_id);
			FETCH tax_exemption_number_csr INTO tax_exemption_number_rec;
			CLOSE tax_exemption_number_csr;
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
	  		l_klnv_tbl_in(1).exempt_reason_code := tax_exemption_number_rec.description;
			l_klnv_tbl_in(1).exempt_certificate_number := tax_exemption_number_rec.customer_exception_number;
     		ELSIF l_oks_headers_rec.exempt_certificate_number is NOT NULL
		THEN
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
			l_klnv_tbl_in(1).exempt_reason_code := l_oks_headers_rec.exempt_reason_code;
			l_klnv_tbl_in(1).exempt_certificate_number := l_oks_headers_rec.exempt_certificate_number;
		END IF;
		-- Ebtax --
         end if;
/*hkamdar
         IF NVL(l_oks_headers_rec.tax_status, 'X') = 'E' THEN
            l_klnv_tbl_in(1).tax_code     := NULL;
         END IF;
         l_klnv_tbl_in(1).tax_status   := l_oks_headers_rec.tax_status;
        --Fixed Tax exemption is cascading to line along with bug#4026268 --gbgupta
        --assigning tax exemption id
         l_klnv_tbl_in(1).tax_exemption_id := l_oks_headers_rec.tax_exemption_id;
*/
         IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	     fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                     p_app_name        => G_APP_NAME_OKS,
                     p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                     p_token1	       => 'ATTRIBUTE',
                     p_token1_value    => 'Tax');
             --fnd_msg_pub.initialize;
             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;

         END IF;
      END IF;-- For l_insupd_flag
   END IF; -- For l_header_tax

  --Fixed bug#4026268 --gbgupta
   IF l_header_tax_code IS NOT NULL THEN
         l_klnv_tbl_in(1).ID           := l_oks_lines_rec.ID;
--      IF NVL(l_line_tax_status,'X') <> 'E' AND l_exmpt_num_flag THEN --BUG#4089834 hkamdar

      IF l_status_flag AND (NVL(l_oks_headers_rec.tax_status, 'X') = 'E') THEN
         l_klnv_tbl_in(1).tax_code		      := NULL;
	-- GCHADHA --
	--  l_klnv_tbl_in(1).tax_classification_code     := NULL;
        -- GCHADHA --
	      -- Ebtax --
		-- l_klnv_tbl_in(1).tax_exemption_id := l_oks_headers_rec.tax_exemption_id;
		IF l_oks_headers_rec.tax_exemption_id IS NOT NULL
		THEN

			OPEN tax_exemption_number_csr(l_oks_headers_rec.tax_exemption_id);
			FETCH tax_exemption_number_csr INTO tax_exemption_number_rec;
			CLOSE tax_exemption_number_csr;
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
	  		l_klnv_tbl_in(1).exempt_reason_code := tax_exemption_number_rec.description;
			l_klnv_tbl_in(1).exempt_certificate_number := tax_exemption_number_rec.customer_exception_number;


		ELSIF l_oks_headers_rec.exempt_certificate_number is NOT NULL
		THEN
			l_klnv_tbl_in(1).tax_exemption_id   := NULL;
			l_klnv_tbl_in(1).exempt_reason_code := l_oks_headers_rec.exempt_reason_code;
			l_klnv_tbl_in(1).exempt_certificate_number := l_oks_headers_rec.exempt_certificate_number;
		END IF;
	     -- Ebtax --
      ELSE
       --  IF NVL(l_line_tax_status,'X') <> 'E' THEN -- GCHADHA 12/1/2005
          --   l_klnv_tbl_in(1).tax_code     := l_header_tax_code_id;
	    -- Ebtax --
	       l_klnv_tbl_in(1).tax_classification_code     := l_header_tax_cls_code;
	    -- Ebtax --

           IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	     fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                     p_app_name        => G_APP_NAME_OKS,
                     p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                     p_token1	       => 'ATTRIBUTE',
                     p_token1_value    => 'Tax Code');
             --fnd_msg_pub.initialize;
             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;

           END IF;
       --  END IF; -- Gchadha  12/1/2005
	END IF;-- BUG#4089834 hkamdar
  END IF;

   IF l_billing_profile IS NOT NULL THEN
    IF l_billing_profile_id IS NOT NULL THEN
--Fix for Bug# 3542273
       OPEN  cur_billing_profile(l_billing_profile_id);
       FETCH cur_billing_profile INTO l_bpf_acct_rule_id,l_bpf_invoice_rule_id;
       IF cur_billing_profile%NOTFOUND then
          CLOSE cur_billing_profile;
          x_return_status := 'E';
       RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          CLOSE cur_billing_profile;
       END IF;

       If l_okc_lines_rec.lse_id = '12' then

          l_usage_type  := l_oks_lines_rec.usage_type;

          If l_usage_type in ('VRT','QTY') then
             IF l_bpf_invoice_rule_id = -2  THEN
                l_token1_value := fnd_meaning(l_usage_type,'OKS_USAGE_TYPE');

                fnd_msg_pub.initialize;
	           OKC_API.SET_MESSAGE
	           (
                    p_app_name        => G_APP_NAME_OKS,
                    p_msg_name        => 'OKS_USAGE_ATTR_CHECK',
                    p_token1	      => 'TOKEN1',
                    p_token1_value    => l_token1_value,
                    p_token2	      => 'Line No ',
                    p_token2_value    => l_line_number
	           );

                l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                p_encoded   => fnd_api.g_false);
                x_msg_tbl(l_tot_msg_count).status       := 'E';
                x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                l_tot_msg_count := l_tot_msg_count + 1;
                l_msg_data := NULL;
                Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             End If;
          End If;
       End If;
--Fix for Bug# 3542273
      OPEN  cur_line_dates(header_lines_tbl(i).cle_id);
      FETCH cur_line_dates INTO l_bpf_start_date, l_bpf_end_Date, l_bpf_lse_id;
      CLOSE cur_line_dates;

      OPEN  cur_sub_line(l_cle_id);
      FETCH cur_sub_line INTO l_sub_line_rec;
      CLOSE cur_sub_line;

      If NOT oks_extwar_util_pvt.check_already_billed(
                                                 p_chr_id   => null,
                                                 p_cle_id   => header_lines_tbl(i).cle_id,
                                                 p_lse_id   => l_bpf_lse_id,
                                                 p_end_date => null
                                                 )

      THEN

       l_rec.start_date          := l_bpf_start_date;
       l_rec.end_date            := l_bpf_end_Date;
       l_rec.cle_Id              := header_lines_tbl(i).cle_id;
       l_rec.chr_Id              := header_lines_tbl(i).chr_id;
       l_rec.Billing_Profile_Id  := header_lines_tbl(i).billing_profile_id;

       OKS_BILLING_PROFILES_PUB.Get_Billing_Schedule
           (p_api_version                  => 1.0,
            p_init_msg_list                =>'T',
            p_billing_profile_rec          => l_rec,
            x_sll_tbl_out                  => l_sll_tbl_out,
            x_return_status                => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data                     => l_msg_data);

	    -- Bug 5227077 --
	    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
	        Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;
	    -- Bug 5227077 --


-- Delete_Sll_If_Exists(l_rec.cle_id);
            l_top_line_id         := l_rec.cle_id;

            OKS_BILL_SCH.Del_rul_elements
                      (
                       p_top_line_id     =>  l_top_line_id,
                       x_return_status   =>  l_return_status,
                       x_msg_count       =>  l_msg_count,
                       x_msg_data        =>  l_msg_data
                      );

	    -- Bug 5227077 --
	    IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    END IF;
	    -- Bug 5227077 --



       l_invoice_rule_id                  := l_bpf_invoice_rule_id;

       --new
       l_clev_tbl_in(1).inv_rule_id       := l_invoice_rule_id;
       --new

       l_klnv_tbl_in(1).acct_rule_id      := l_bpf_acct_rule_id;
       l_sll_tbl(1).Sequence_no           := l_sll_tbl_out(1).seq_no;
       l_sll_tbl(1).uom_code              := l_sll_tbl_out(1).timeunit;
       l_sll_tbl(1).uom_per_period        := l_sll_tbl_out(1).duration;
       l_sll_tbl(1).level_periods         := l_sll_tbl_out(1).target_quantity;
       l_sll_tbl(1).invoice_offset_days   := l_sll_tbl_out(1).Invoice_Offset;
       l_sll_tbl(1).interface_offset_days := l_sll_tbl_out(1).Interface_Offset;
       -- Bug 5406141 --
       --  l_sll_tbl(1).Chr_Id                := l_sll_tbl_out(1).Chr_Id;
       l_sll_tbl(1).Cle_Id                := l_sll_tbl_out(1).Cle_Id;
       l_billing_type                     := l_sll_tbl_out(1).billing_type;
       -- Bug 5406141 --

            OKS_BILL_SCH.Create_Bill_Sch_Rules
                   (
                    p_billing_type      => l_billing_type
                   ,p_sll_tbl           => l_sll_tbl
                   ,p_invoice_rule_id   => l_invoice_rule_id
                   ,x_bil_sch_out_tbl	=> l_bil_sch_out_tbl
                   ,x_return_status     => l_return_status
                   );

            IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               FOR i in 1..fnd_msg_pub.count_msg
	       Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	       End Loop;
		 Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
               fnd_msg_pub.initialize;
               OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Billing Schedule');
             --fnd_msg_pub.initialize;
               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'S';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;

            END IF;

      END IF; --for check already billed

      Open cur_bill_to_address_id1(l_billing_profile_id);
      fetch cur_bill_to_address_id1 into l_bill_to_address_id1;
      close cur_bill_to_address_id1;

      IF (l_bill_to_address_id1 IS NOT NULL) THEN

          l_cle_Id              := header_lines_tbl(i).cle_id;
          l_chr_Id              := header_lines_tbl(i).chr_id;
          l_line_cust_acct      := l_okc_headers_rec.cust_acct_id;

          Open cur_bpf_cust_acct(l_billing_profile_id, header_dates_rec.authoring_org_id);
          fetch cur_bpf_cust_acct into l_bpf_cust_acct;
          close cur_bpf_cust_acct;

          IF l_line_cust_acct = l_bpf_cust_acct THEN

             l_clev_tbl_in(1).id		    := l_cle_id;
	     l_clev_tbl_in(1).bill_to_site_use_id   := l_okc_headers_rec.bill_to_site_use_id;

             IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
               fnd_msg_pub.initialize;
               OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Bill To Address');
             --fnd_msg_pub.initialize;
               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'S';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;

            END IF;
          END IF;
      END IF;
    Elsif l_billing_profile_id is NULL then
--Display error message, saying required value missing.
               fnd_msg_pub.initialize;
               OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_CASCADE_MISSING_REQD_ATTR',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Billing Profile');

               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'E';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;

    END IF; --l_billing_profile_id
   END IF;--l_billing_profile

---------------------------------------------------------------------------------
   IF  l_header_arl is not null then
       IF l_billing_profile IS NOT NULL and
          l_billing_profile_id is not null THEN

          l_klnv_tbl_in(1).acct_rule_id     :=l_bpf_acct_rule_id;
       ELSE
          l_klnv_tbl_in(1).acct_rule_id     := l_oks_headers_rec.acct_rule_id;
       END IF;
       l_klnv_tbl_in(1).ID                  := l_oks_lines_rec.ID;

       IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
           fnd_msg_pub.initialize;
           OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Accounting Rule');

             --fnd_msg_pub.initialize;
               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'S';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;

       END IF;

   ELSIF  l_header_arl is NULL AND l_billing_profile IS NOT NULL and
          l_billing_profile_id is not null then

--Fix for Bug# 3542273

          If l_okc_lines_rec.lse_id = '12' then

             l_usage_type  := l_oks_lines_rec.usage_type;

             If l_usage_type in ('VRT','QTY') then
                IF l_bpf_invoice_rule_id = -2  THEN
                   l_token1_value := fnd_meaning(l_usage_type,'OKS_USAGE_TYPE');

                   fnd_msg_pub.initialize;
	           OKC_API.SET_MESSAGE
	             (
                      p_app_name        => G_APP_NAME_OKS,
                      p_msg_name        => 'OKS_USAGE_ATTR_CHECK',
                      p_token1	       => 'TOKEN1',
                      p_token1_value    => l_token1_value,
                      p_token2	       => 'Line No ',
                      p_token2_value    => l_line_number
	             );

                   l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                   p_encoded   => fnd_api.g_false);
                   x_msg_tbl(l_tot_msg_count).status       := 'E';
                   x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                   l_tot_msg_count := l_tot_msg_count + 1;
                   l_msg_data := NULL;
                   Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		End If;
             End If;
          End If;
--Fix for Bug# 3542273

          l_klnv_tbl_in(1).ID               := l_oks_lines_rec.ID;
          l_klnv_tbl_in(1).acct_rule_id     := l_bpf_acct_rule_id;

          IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
             fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Accounting Rule');

             --fnd_msg_pub.initialize;
               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'S';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;
          END IF;
   END IF;


-----------------------------------------------------------------------
   IF  l_header_ire is not null then
--Fix for Bug# 3542273
       IF l_billing_profile IS NOT NULL and
          l_billing_profile_id is not null THEN

          l_clev_tbl_in(1).inv_rule_id   :=l_invoice_rule_id;
       ELSE
          l_clev_tbl_in(1).inv_rule_id   := l_okc_headers_rec.inv_rule_id;
       END IF;

       If l_okc_lines_rec.lse_id = '12' then

          l_usage_type  := l_oks_lines_rec.usage_type;

          If l_usage_type in ('VRT','QTY') then
             If l_clev_tbl_in(1).inv_rule_id = -2 then
                l_token1_value := fnd_meaning(l_usage_type,'OKS_USAGE_TYPE');

                fnd_msg_pub.initialize;
	            OKC_API.SET_MESSAGE
	             (
                      p_app_name        => G_APP_NAME_OKS,
                      p_msg_name        => 'OKS_USAGE_ATTR_CHECK',
                      p_token1	        => 'TOKEN1',
                      p_token1_value    => l_token1_value,
                      p_token2	        => 'Line No ',
                      p_token2_value    => l_line_number
	             );

                l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                p_encoded   => fnd_api.g_false);
                x_msg_tbl(l_tot_msg_count).status       := 'E';
                x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                l_tot_msg_count := l_tot_msg_count + 1;
                l_msg_data := NULL;
                Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             End If;
          End If;
       End If;
--Fix for Bug# 3542273

       l_clev_tbl_in(1).id	         := l_cle_id;

       OKS_BILL_SCH.update_bs_interface_date
                (
                 p_top_line_id         => l_cle_id,
                 p_invoice_rule_id     => l_clev_tbl_in(1).inv_rule_id,
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data
                );

       IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          fnd_msg_pub.initialize;
          OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Invoicing Rule');

             --fnd_msg_pub.initialize;
               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
               p_encoded   => fnd_api.g_false);
               x_msg_tbl(l_tot_msg_count).status       := 'S';
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;
       -- Bug 5227077 --
       Elsif NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
       -- Bug 5227077 --

   ELSIF  l_header_ire is NULL AND l_billing_profile IS NOT NULL and
          l_billing_profile_id is not null then
--Fix for Bug# 3542273

          If l_okc_lines_rec.lse_id = '12' then

             l_usage_type  := l_oks_lines_rec.usage_type;

             If l_usage_type in ('VRT','QTY') then
	        IF l_bpf_invoice_rule_id = -2  THEN
                   l_token1_value := fnd_meaning(l_usage_type,'OKS_USAGE_TYPE');
                   fnd_msg_pub.initialize;
	              OKC_API.SET_MESSAGE
	               (
                        p_app_name        => G_APP_NAME_OKS,
                        p_msg_name        => 'OKS_USAGE_ATTR_CHECK',
                        p_token1	  => 'TOKEN1',
                        p_token1_value    => l_token1_value,
                        p_token2	  => 'Line No ',
                        p_token2_value    => l_line_number
	               );
                   l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                   p_encoded   => fnd_api.g_false);
                   x_msg_tbl(l_tot_msg_count).status       := 'E';
                   x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                   l_tot_msg_count := l_tot_msg_count + 1;
                   l_msg_data := NULL;
                   Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                End If;
             End If;
          End If;
--Fix for Bug# 3542273
          l_clev_tbl_in(1).id	         := l_cle_id;
-- changed for Bug 4064138
-- for billed contractflow dosenot go inside check if billed
-- hence the value for l_invoice_rule_id dosenot get assigned.
          l_clev_tbl_in(1).inv_rule_id   :=l_bpf_invoice_rule_id; --l_invoice_rule_id;
-- change for bug 4064138.

          OKS_BILL_SCH.update_bs_interface_date
                (
                 p_top_line_id         => l_cle_id,
                 p_invoice_rule_id     => l_clev_tbl_in(1).inv_rule_id,
                 x_return_status       => l_return_status,
                 x_msg_count           => l_msg_count,
                 x_msg_data            => l_msg_data
                );
          IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

          ELSE
	     fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Invoicing Rule');

             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
          END IF;
   END IF;

   If  l_header_sales_credits is not null then
      --Fetch was doing only for one line. Now the Fetch is in a loop(Bug#2374793)
           l_sc_index := 1;
	       l_scrv_tbl_in.DELETE;


           OPEN Scredit_csr_line(l_chr_id,L_cle_id);
	       LOOP
             FETCH Scredit_csr_line into l_scredit_count,l_scredit_id;

	         EXIT WHEN Scredit_csr_line%NOTFOUND;
	              l_scrv_tbl_in(l_sc_index).id := l_scredit_id;

	              l_sc_index := l_sc_index + 1;
           END LOOP;
           CLOSE Scredit_csr_line;

	       IF l_scrv_tbl_in.COUNT > 0 THEN
              OKS_SALES_CREDIT_PUB.delete_Sales_credit
            (
             p_api_version         => 1.0,
             p_init_msg_list       => 'T',
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data,
             p_scrv_tbl            => l_scrv_tbl_in);
	    -- Bug 527077 --
	    if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	     FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            End if;
	    -- Bug 5227077 --

	       END IF; -- End if for plsql table count.

           OKS_EXTWAR_UTIL_PVT.CREATE_SALES_CREDITS
               (
                P_header_id       =>l_chr_id
               ,P_line_id        => l_cle_id
               ,X_return_status  => l_return_status
               );


            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                fnd_msg_pub.initialize;
                OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Sales Credit');

                l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                p_encoded   => fnd_api.g_false);
                x_msg_tbl(l_tot_msg_count).status       := 'S';
                x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                l_tot_msg_count := l_tot_msg_count + 1;
                l_msg_data := NULL;
	    -- Bug 5227077 --
	    Elsif not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            End if;
	    -- Bug 5227077 --

        END IF;

  -- Made changes for bug 4394382 --
  -- When we cascade payment method from header to line in case of Commitment number
  -- verify the bill to cust Account on header and lines level. If same then cascaded
  -- the commitment number.

 IF l_payment_method IS NOT NULL THEN

        l_klnv_tbl_in(1).ID                 := l_oks_lines_rec.ID;
     --  l_klnv_tbl_in(1).payment_type       := l_oks_headers_rec.payment_type; -- BUG 4394382

     -- BUG 3691147 AND 3675745 --
     -- PROVIDE FIX FOR ISSUE 3675745 AS WELL --
     -- GCHADHA  15 - JUN - 2004 --
	l_klnv_tbl_in(1).cust_po_number             := l_okc_headers_rec.cust_po_number;
        l_klnv_tbl_in(1).cust_po_number_req_yn      := l_okc_headers_rec.cust_po_number_req_yn;
	-- Bank Account Consolidation --
	l_clev_tbl_in(1).id                        := l_cle_id;
        l_clev_tbl_in(1).payment_instruction_type  := l_okc_headers_rec.payment_instruction_type;
	-- Bank Account Consolidation --

       Open cur_oks_comm_line(l_okc_lines_rec.id);
       fetch cur_oks_comm_line into l_oks_comm_line_rec;
       close cur_oks_comm_line;

       Open cur_get_Party_Id (l_okc_lines_rec.cust_acct_id);
       fetch cur_get_party_id into l_oks_party_rec ;
       close cur_get_party_id;

       IF nvl(l_oks_comm_line_rec.cust_po_number,-1) =  nvl(l_okc_headers_rec.cust_po_number, -1)
       AND Nvl(l_oks_comm_line_rec.cust_po_number_req_yn,'X') = nvl(l_okc_headers_rec.cust_po_number_req_yn, 'X')
       AND Nvl(l_oks_comm_line_rec.payment_instruction_type,'X') = nvl(l_okc_headers_rec.payment_instruction_type, 'X')
       THEN
	    l_cust_po_flag := 1;
       END IF ;
       Open cur_head_cust_acct(l_okc_headers_rec.bill_to_site_use_id);
       fetch cur_head_cust_acct into l_header_cust_acct;
       close cur_head_cust_acct;
       l_line_cust_acct := l_okc_lines_rec.cust_acct_id;

	IF l_oks_headers_rec.payment_type = 'COM' THEN

	       IF l_oks_headers_rec.commitment_id is NULL THEN
			l_klnv_tbl_in(1).payment_type       := l_oks_headers_rec.payment_type;
			-- Bank Account Consolidation --
			/*  l_klnv_tbl_in(1).cc_no              := NULL;
			    l_klnv_tbl_in(1).cc_expiry_date     := NULL;
			    l_klnv_tbl_in(1).cc_bank_acct_id    := NULL;
			    l_klnv_tbl_in(1).cc_auth_code       := NULL; */
			-- Bank Account Consolidation --
			-- Call the delete API to Delete Credit card details
			-- if the credit card details are present on the line level
			IF l_oks_comm_line_rec.trxn_extension_id IS NOT NULL
			THEN
				 Delete_credit_Card
				(p_trnx_ext_id => l_oks_comm_line_rec.trxn_extension_id,
				 p_line_id      => l_cle_id,
				 p_party_id     => l_oks_party_rec.party_id ,
				 p_cust_account_id => l_line_cust_acct,
				 x_return_status => l_return_status,
				 x_msg_data => l_msg_data );
				 -- Bug 5227077 --
				 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				     FOR i in 1..fnd_msg_pub.count_msg
				     Loop
					fnd_msg_pub.get
					(
					  p_msg_index     => i,
					  p_encoded       => 'F',
					  p_data          => l_msg_data,
					  p_msg_index_out => l_msg_index
					);
					x_msg_tbl(l_tot_msg_count).status       := l_return_status;
					x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				        l_tot_msg_count := l_tot_msg_count + 1;
					l_msg_data := NULL;
				    End Loop;
				    Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				 end if;
				 -- Bug 5227077 --

			END IF;
			l_klnv_tbl_in(1).trxn_extension_id  := NULL;
			l_klnv_tbl_in(1).commitment_id      := NULL;
			l_payment_method_com                := 1; -- 4394382
	       ELSIF  nvl(l_header_cust_acct,-1) = nvl(l_line_cust_acct , -9)  or l_header_bca is NOT NULL
	       THEN
			l_klnv_tbl_in(1).payment_type       := l_oks_headers_rec.payment_type;
			-- Bank Account Consolidation --
			/* l_klnv_tbl_in(1).cc_no           := NULL;
			l_klnv_tbl_in(1).cc_expiry_date     := NULL;
			l_klnv_tbl_in(1).cc_bank_acct_id    := NULL;
			l_klnv_tbl_in(1).cc_auth_code       := NULL; */
			-- Call the delete API to Delete Credit card details--
			IF l_oks_comm_line_rec.trxn_extension_id IS NOT NULL
			THEN
				Delete_credit_Card
				(p_trnx_ext_id => l_oks_comm_line_rec.trxn_extension_id,
				 p_line_id      => l_cle_id,
				 p_party_id     => l_oks_party_rec.party_id ,
				 p_cust_account_id => l_header_cust_acct,
				 x_return_status => l_return_status,
				 x_msg_data => l_msg_data );

				 -- Bug 5227077 --
				 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				     FOR i in 1..fnd_msg_pub.count_msg
				     Loop
				        fnd_msg_pub.get
					 (
					  p_msg_index     => i,
					  p_encoded       => 'F',
					  p_data          => l_msg_data,
					  p_msg_index_out => l_msg_index
					);
					x_msg_tbl(l_tot_msg_count).status       := l_return_status;
					x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				        l_tot_msg_count := l_tot_msg_count + 1;
					l_msg_data := NULL;
				      End Loop;
			             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
				 End if;
				 -- Bug 5227077 --

			END IF;
			l_klnv_tbl_in(1).trxn_extension_id  := NULL;
			-- Bank Account Consolidation --
			l_klnv_tbl_in(1).commitment_id      := l_oks_headers_rec.commitment_id;
			l_payment_method_com                := 1; -- 4394382
	       END IF;
	         -- END GCHADHA --

	-- BUG 3691147 --
	-- GCHADHA 3691147 --
	 /*
  	 -- FIX FOR THE BUG 3675745
  	 -- GCHADHA 9-06-2004 --
  	      l_klnv_tbl_in(1).cust_po_number             := l_okc_headers_rec.cust_po_number;
  	   -  l_klnv_tbl_in(1).cust_po_number_req_yn      := l_okc_headers_rec.cust_po_number_req_yn;
  	 -- END GCHADHA --
  	 */
  	 -- END GCHADHA --
 	--       l_klnv_tbl_in(1).cust_po_number      := NULL;
 	--       l_klnv_tbl_in(1).cust_po_number_req_yn      := NULL;


     ELSIF l_oks_headers_rec.payment_type =  'CCR' THEN
        -- Bank Account consolidation --
	IF l_oks_headers_rec.trxn_extension_id is NULL THEN
		IF l_oks_comm_line_rec.trxn_extension_id IS NOT NULL
		THEN
			Delete_credit_Card
			(p_trnx_ext_id     => l_oks_comm_line_rec.trxn_extension_id,
			 p_line_id         => l_cle_id,
			 -- p_party_id        => l_party_id ,
			 p_party_id        =>l_oks_party_rec.party_id,
			 p_cust_account_id => l_line_cust_acct,
			 x_return_status => l_return_status,
			 x_msg_data => l_msg_data );

			 -- Bug 5227077 --
			 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			     FOR i in 1..fnd_msg_pub.count_msg
			     Loop
			         fnd_msg_pub.get
				(
				  p_msg_index     => i,
				  p_encoded       => 'F',
				  p_data          => l_msg_data,
				  p_msg_index_out => l_msg_index
				);
				x_msg_tbl(l_tot_msg_count).status       := l_return_status;
				x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				l_tot_msg_count := l_tot_msg_count + 1;
				l_msg_data := NULL;
			    End Loop;
	                    Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
			 End if;
			 -- Bug 5227077 --

		END IF;
		l_klnv_tbl_in(1).payment_type        := l_oks_headers_rec.payment_type;
	        l_klnv_tbl_in(1).trxn_extension_id   := NULL;
		l_klnv_tbl_in(1).commitment_id       := NULL;
		l_payment_method_ccr                 := 1; -- 4394382
	-- Cascade the credit card number only when the header and lines level
	-- bill to accounts are same or if we have already marked cascade of
	-- billto account from header to lines.
	ELSIF nvl(l_header_cust_acct,-1) = nvl(l_line_cust_acct , -9) or l_header_bca is NOT NULL
	THEN
		l_klnv_tbl_in(1).payment_type        := l_oks_headers_rec.payment_type;

		/*  l_klnv_tbl_in(1).cc_no           := l_oks_headers_rec.cc_no;
		    l_klnv_tbl_in(1).cc_expiry_date  := l_oks_headers_rec.cc_expiry_date;
		    l_klnv_tbl_in(1).cc_bank_acct_id := l_oks_headers_rec.cc_bank_acct_id;
	            l_klnv_tbl_in(1).cc_auth_code    := l_oks_headers_rec.cc_auth_code; */
		IF l_oks_comm_line_rec.trxn_extension_id IS NOT NULL
		THEN
			Delete_credit_Card
			(p_trnx_ext_id => l_oks_comm_line_rec.trxn_extension_id,
			 p_line_id      => l_cle_id,
			 -- p_party_id     => l_party_id ,
			 p_party_id        =>l_oks_party_rec.party_id,
			 p_cust_account_id => l_header_cust_acct,
			 x_return_status => l_return_status,
			 x_msg_data => l_msg_data );
			 -- Bug 5227077 --
			 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			     FOR i in 1..fnd_msg_pub.count_msg
			     Loop
			         fnd_msg_pub.get
				(
				  p_msg_index     => i,
			          p_encoded       => 'F',
				  p_data          => l_msg_data,
				  p_msg_index_out => l_msg_index
				);
				x_msg_tbl(l_tot_msg_count).status       := l_return_status;
				x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				l_tot_msg_count := l_tot_msg_count + 1;
				l_msg_data := NULL;
			     End Loop;
		             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
			 End if;
			 -- Bug 5227077 --

		END IF;
		-- Create Credit Card Details --
		l_trxn_extension_id := Create_credit_Card
			    	     ( p_line_id         => l_cle_id ,
				       p_party_id        => l_oks_party_rec.party_id ,
				       p_org	         => l_okc_headers_rec.authoring_org_id,
				       p_account_site_id => l_okc_lines_rec.bill_to_site_use_id ,
				       p_cust_account_id => l_header_cust_acct,
				       p_trnx_ext_id     => l_oks_headers_rec.trxn_extension_id,
				       x_return_status   => l_return_status,
				       x_msg_data        => l_msg_data);

		 -- Bug 5227077 --
		 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		     FOR i in 1..fnd_msg_pub.count_msg
		     Loop
			fnd_msg_pub.get
			(
			p_msg_index     => i,
			p_encoded       => 'F',
			p_data          => l_msg_data,
			p_msg_index_out => l_msg_index
			);
			x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			l_tot_msg_count := l_tot_msg_count + 1;
			l_msg_data := NULL;
		     End Loop;
	             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		 End if;
		 -- Bug 5227077 --


		l_klnv_tbl_in(1).trxn_extension_id   := l_trxn_extension_id;
		l_klnv_tbl_in(1).commitment_id       := NULL;
		l_payment_method_ccr                 := 1; -- 4394382
	END IF;
	-- Bank Account Consolidation --
    -- BUG 3691147 --
    -- GCHADHA 3691147 --
    /*
    -- FIX FOR THE BUG 3675745
    -- GCHADHA 9-06-2004 --
        l_klnv_tbl_in(1).cust_po_number             := l_okc_headers_rec.cust_po_number;
        l_klnv_tbl_in(1).cust_po_number_req_yn      := l_okc_headers_rec.cust_po_number_req_yn;
    -- END GCHADHA --
    */
    -- GCHADHA --
 --       l_klnv_tbl_in(1).cust_po_number         := NULL;
 --       l_klnv_tbl_in(1).cust_po_number_req_yn := NULL;
  -- GCHADHA --
  -- Case when the payment method at header level is null
  -- and at line level payment method is not null
     ELSIF l_oks_headers_rec.payment_type is NULL THEN

	l_klnv_tbl_in(1).payment_type        := NULL;
        -- Bank Account Consolidation --
	/* l_klnv_tbl_in(1).cc_no            := NULL;
        l_klnv_tbl_in(1).cc_expiry_date      := NULL;
        l_klnv_tbl_in(1).cc_bank_acct_id     := NULL;
        l_klnv_tbl_in(1).cc_auth_code        := NULL; */

	IF l_oks_comm_line_rec.trxn_extension_id IS NOT NULL
	THEN
		Delete_credit_Card
		(p_trnx_ext_id => l_oks_comm_line_rec.trxn_extension_id,
		 p_line_id      => l_cle_id,
		 p_party_id     => l_oks_party_rec.party_id ,
		 p_cust_account_id =>l_line_cust_acct,
		 x_return_status => l_return_status,
		 x_msg_data => l_msg_data );

		 -- Bug 5227077 --
		 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		     FOR i in 1..fnd_msg_pub.count_msg
		     Loop
			 fnd_msg_pub.get
			(
			  p_msg_index     => i,
			  p_encoded       => 'F',
			  p_data          => l_msg_data,
			  p_msg_index_out => l_msg_index
			);
			x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			l_tot_msg_count := l_tot_msg_count + 1;
			l_msg_data := NULL;
		    End Loop;
	             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		 End if;
		 -- Bug 5227077 --

	END IF;
	l_klnv_tbl_in(1).trxn_extension_id   :=NULL;
        --  Bank Account Consolidation --
        l_klnv_tbl_in(1).commitment_id       := NULL;
        l_payment_method_ccr                 := 1; -- 4394382

    END IF;

       IF l_payment_method_com = 1 OR  l_cust_po_flag = 0 OR l_payment_method_ccr = 1 THEN
	IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

	     fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Payment Method');

	     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
	 END IF;
       END IF;

 END IF;

 -- 8/23/2005 hkamdar R12 Partial Period
 -- Price UOM Cascading
 IF  l_header_price_uom is not null then
 ----errorout('Price uom not null');

     l_klnv_tbl_in(1).ID          	:= l_oks_lines_rec.ID;
     l_klnv_tbl_in(1).price_uom         := l_oks_headers_rec.price_uom;
----errorout('UOM-'||l_klnv_tbl_in(1).price_uom);
     fnd_msg_pub.initialize;
     OKC_API.SET_MESSAGE(
                  p_app_name        => G_APP_NAME_OKS,
                  p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                  p_token1	    => 'ATTRIBUTE',
                  p_token1_value    => 'Price UOM');

     l_msg_data := fnd_msg_pub.get(	p_msg_index => fnd_msg_pub.g_first,
			 		p_encoded   => fnd_api.g_false);

     x_msg_tbl(l_tot_msg_count).status       := 'S';
     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
     l_tot_msg_count := l_tot_msg_count + 1;
     l_msg_data := NULL;

 END IF;

--- price list cascading

 IF  l_header_price_list is not null then

     -- Validate before cascading the Price List wheather the
     -- price list is valid or not.
      QP_UTIL_PUB.Validate_Price_list_Curr_code(
          l_price_list_id	     => l_okc_headers_rec.price_list_id
         ,l_currency_code          => l_okc_headers_rec.currency_code
         ,l_pricing_effective_date => l_pricing_effective_date
         ,l_validate_result        => l_validate_result);

      IF  NVL(l_validate_result,'N') IN ('U' ,'N') then -- Unexpected Error
  	   fnd_msg_pub.initialize;
	   l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,p_encoded   => fnd_api.g_false);
           OKC_API.SET_MESSAGE(
               p_app_name        => 'OKS', --G_APP_NAME_OKS,
               p_msg_name        => 'OKS_INVALID_PRICE_LIST');
              x_msg_tbl(l_tot_msg_count).status       := 'E';
              x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
              l_tot_msg_count := l_tot_msg_count + 1;
              l_msg_data := NULL;
              Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

     l_clev_tbl_in(1).ID           := l_okc_lines_rec.ID;
     l_clev_tbl_in(1).price_list_id   := l_okc_headers_rec.price_list_id;

     If l_okc_lines_rec.lse_id = '12' then -- Usage line
	open cur_get_lines_details (l_chr_id , l_okc_lines_rec.ID);
	fetch cur_get_lines_details into
	    l_locked_price_list_id,l_locked_price_list_line_id;
	close cur_get_lines_details;

	l_source_price_list_line_id := l_locked_price_list_line_id;

	If  l_source_price_list_line_id IS NOT NULL THEN
	    oks_qp_pkg.delete_locked_pricebreaks(l_api_version,
	 	                                 l_source_price_list_line_id,
						 l_init_msg_list,
						 l_return_status,
						 l_msg_count,
						 l_msg_data);
  	 -- Bug 5227077 --
	 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		FOR i in 1..fnd_msg_pub.count_msg
		Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	        End Loop;
                Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 End if;
	 -- Bug 5227077 --

 	    l_locked_prl_cnt := l_locked_prl_cnt + 1;

	    l_klnv_tbl_in(1).ID	:= l_oks_lines_rec.id;
	    l_klnv_tbl_in(1).locked_price_list_id := null;
	    l_klnv_tbl_in(1).locked_price_list_line_id := null;


	    fnd_msg_pub.initialize;
       	    OKC_API.SET_MESSAGE(
                	 p_app_name => G_APP_NAME_OKS,
                 	 p_msg_name => 'OKS_HEADER_CASCADE_WARNING',
                 	 p_token1	  => 'ATTRIBUTE',
                 	 p_token1_value => 'Price List');

	    l_msg_data := fnd_msg_pub.get(	p_msg_index => fnd_msg_pub.g_first,
				 	        p_encoded   => fnd_api.g_false);
	    x_msg_tbl(l_tot_msg_count).status       := 'S';
	    x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	    l_tot_msg_count := l_tot_msg_count + 1;
	    l_msg_data := NULL;
        ELSE
		-- To display the Cascade Message when
		-- Usage lines is not locked and the cascade take place --
		fnd_msg_pub.initialize;
	       	OKC_API.SET_MESSAGE(
                	 p_app_name => G_APP_NAME_OKS,
                 	 p_msg_name => 'OKS_HEADER_CASCADE_SUCCESS',
                 	 p_token1	  => 'ATTRIBUTE',
                 	 p_token1_value => 'Price List');

		l_msg_data := fnd_msg_pub.get(	p_msg_index => fnd_msg_pub.g_first,
				 	p_encoded   => fnd_api.g_false);
		x_msg_tbl(l_tot_msg_count).status       := 'S';
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
		l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;

        END IF;
     Else
	fnd_msg_pub.initialize;
       	OKC_API.SET_MESSAGE(
                	 p_app_name => G_APP_NAME_OKS,
                 	 p_msg_name => 'OKS_HEADER_CASCADE_SUCCESS',
                 	 p_token1	  => 'ATTRIBUTE',
                 	 p_token1_value => 'Price List');

	l_msg_data := fnd_msg_pub.get(	p_msg_index => fnd_msg_pub.g_first,
				 	p_encoded   => fnd_api.g_false);
	x_msg_tbl(l_tot_msg_count).status       := 'S';
	x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	l_tot_msg_count := l_tot_msg_count + 1;
	l_msg_data := NULL;

       End If;

 END IF;

  -- End 8/23/2005 hkamdar R12 Partial Period

 --Fixed Tax exemption is cascading to line along with bug#4026268 --gbgupta
 --checking l_insupd_flag flag along with l_header_tax              IS NOT NULL
 --l_header_exception_number IS NOT NULL
-- IKON ENHANCEMENT --
 IF (l_header_tax              IS NOT NULL AND (l_status_flag or l_exmpt_num_flag)) OR --l_insupd_flag)  OR
    l_header_tax_code         IS NOT NULL  OR
   ( l_header_bca            IS NOT NULL AND l_oks_header_id = 1) OR
   (l_billing_profile         IS NOT NULL  AND
    l_billing_profile_id      IS NOT NULL) OR
    l_header_arl              IS NOT NULL  OR
    (l_header_exception_number IS NOT NULL AND (l_status_flag or l_exmpt_num_flag)) OR --l_insupd_flag)  OR
    l_payment_method          IS NOT NULL  OR
   -- 8/23/2005 hkamdar R12 Partial Period
   -- additional condition is added to the if statement to update the oks_k_lines.
   -- if price_uom is changed
    l_header_price_uom IS NOT NULL
   OR  (l_header_price_list is not null and l_locked_prl_cnt > 0)
--    and l_locked_prl_cnt > 0  THEN
   THEN
--       Resetting the locked price counter.
		l_locked_prl_cnt := 0;
  -- End 8/23/2005 hkamdar R12 Partial Period
--Update oks lines
      oks_contract_line_pub.update_line
              (
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_klnv_tbl                     => l_klnv_tbl_in,
               x_klnv_tbl                     => l_klnv_tbl_out,
               p_validate_yn                  => 'N'
               );
--errorout('Return status -'||l_return_status);
          IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	         FOR i in 1..fnd_msg_pub.count_msg
             Loop
                     fnd_msg_pub.get
                     (
	                 p_msg_index     => i,
                         p_encoded       => 'F',
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index
                     );

             x_msg_tbl(l_tot_msg_count).status       := l_return_status; --'E';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
             End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          End If;


 END IF;
-- IKON ENHANCEMENT --
IF l_header_sto            IS NOT NULL  OR
    l_header_bto            IS NOT NULL  OR
    l_header_sca            IS NOT NULL  OR
    l_header_bca            IS NOT NULL  OR
    l_header_billto_contact IS NOT NULL  OR
    l_header_ire            IS NOT NULL  OR
   (l_billing_profile       IS NOT NULL  AND
    l_billing_profile_id    IS NOT NULL) OR
    l_header_dates          IS NOT NULL  OR
    l_payment_method	    IS NOT NULL  OR-- Payment Instruction Type
   -- 8/23/2005 hkamdar R12 Partial Period
   -- additional condition is added to the if statement to update the okc_k_lines.
   -- if price list is changed
    l_header_price_list 	    IS NOT NULL


    THEN
          update_line(
	               p_clev_tbl      => l_clev_tbl_in,
        	       x_clev_tbl      => l_clev_tbl_out,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data
                     );


          IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	         FOR i in 1..fnd_msg_pub.count_msg
             Loop
                     fnd_msg_pub.get
                     (
	                 p_msg_index     => i,
                         p_encoded       => 'F',
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index
                     );

             x_msg_tbl(l_tot_msg_count).status       := l_return_status; --'E';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
      	    End Loop;
            Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          End If;

 END IF;

   -- 8/23/2005 hkamdar R12 Partial Period

 IF l_header_price_list IS NOT NULL and l_return_status = FND_API.G_RET_STS_SUCCESS
 then
     -- Bug  4668385 --
     l_input_details.line_id := l_cle_id;
     If l_okc_lines_rec.lse_id = '46' Then
           l_input_details.intent := 'SB_P';
     Else
           l_input_details.intent := 'LP';
     End If;
     -- Bug  4668385 --

    oks_qp_int_pvt.compute_Price
          	 (
                  p_api_version         => 1.0,
                  p_init_msg_list       => 'T',
                  p_detail_rec          => l_input_details,
                  x_price_details       => l_output_details,
                  x_modifier_details    => l_modif_details,
                  x_price_break_details => l_pb_details,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data
               );




     l_status_tbl := oks_qp_int_pvt.get_Pricing_Messages;

     if l_status_tbl.Count > 0 Then
	For i in l_status_tbl.FIRST..l_status_tbl.LAST
        Loop
           x_msg_tbl(l_tot_msg_count).status       :=  l_status_tbl(i).Status_Code;
           x_msg_tbl(l_tot_msg_count).description  :=  l_status_tbl(i).Status_Text;
 	   l_tot_msg_count := l_tot_msg_count + 1;

	End Loop;
     end if;
     -- Bug 5381082 --
      If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	    FOR i in 1..fnd_msg_pub.count_msg
            Loop
                 fnd_msg_pub.get
                     (
	              p_msg_index     => i,
                      p_encoded       => 'F',
                      p_data          => l_msg_data,
                      p_msg_index_out => l_msg_index
                     );
                  x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                  l_tot_msg_count := l_tot_msg_count + 1;
                  l_msg_data := NULL;
      	   End Loop;
           Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      End If;
     -- BUg 5381082 --
 END IF;
-- End 8/23/2005 hkamdar R12 Partial Period

 If  l_header_dates is not null and l_return_status = FND_API.G_RET_STS_SUCCESS then
   --Fix for bug#3424479
 -- FIX DONE FOR USAGE CONTRACT SHOWING INCORRECT MESSAGE WHEN CASCADING DATES.
 -- ADDED CHECK FOR USAGE LINE lse_id <> 12
 -- GCHADHA 8-JULY-2004
   If l_okc_lines_rec.lse_id not in (46, 12) AND nvl(l_oks_lines_rec.standard_cov_yn, 'N') <> 'Y' then

	Open  LineCov_cur(l_cle_id);
        Fetch LineCov_cur into l_id;
        If LineCov_cur%Found Then

              OKS_COVERAGES_PVT.Update_COVERAGE_Effectivity(
                  p_api_version     => l_api_version,
                  p_init_msg_list   => l_init_msg_list,
                  x_return_status   => l_return_status,
                  x_msg_count	    => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_service_Line_Id => l_cle_id,
                  p_New_Start_Date  => header_dates_rec.start_date,
                  p_New_End_Date    => header_dates_rec.end_date  );

          IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

             FOR i in 1..fnd_msg_pub.count_msg
             Loop
                     fnd_msg_pub.get
                     (
                         p_msg_index     => i,
                         p_encoded       => 'F',
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index
                     );

               x_msg_tbl(l_tot_msg_count).status       := l_return_status;
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
               l_tot_msg_count := l_tot_msg_count + 1;
               l_msg_data := NULL;
      	     End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

         ELSE
            -- Bug 5191587 --
            If l_okc_lines_rec.lse_id in ('1','14', '19') and l_sr_number IS NOT NULL
	    then
	       fnd_msg_pub.initialize;

	             OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_SR_SUCCESS',
                           p_token1	     => 'SR#',
                           p_token1_value    => l_sr_number,
                           p_token2	     => 'Line No ',
                           p_token2_value    => l_line_number
			   );

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'W';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

                     fnd_msg_pub.initialize;

		     -- Issue a warning message if dates are cascaded from header to lines for a fully billed contract.
		     IF(l_disp_warning ='Y') THEN

			OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_DATES_WARN');

			   x_msg_tbl(l_tot_msg_count).status       := 'W';
		     ELSE

                     OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                           p_token1	     => 'ATTRIBUTE',
                           p_token1_value    => 'Date');
			 x_msg_tbl(l_tot_msg_count).status       := 'S';
		   END IF;

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                    -- x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

            Else
	             fnd_msg_pub.initialize;

		 -- Issue a warning message if dates are cascaded from header to lines for a fully billed contract.
                      IF(l_disp_warning ='Y') THEN

				OKC_API.SET_MESSAGE(
					p_app_name        => G_APP_NAME_OKS,
					p_msg_name        => 'OKS_HEADER_CASCADE_DATES_WARN');

			 x_msg_tbl(l_tot_msg_count).status       := 'W';
		      ELSE
			OKC_API.SET_MESSAGE(
					p_app_name        => G_APP_NAME_OKS,
					p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
					p_token1	         => 'ATTRIBUTE',
					p_token1_value    => 'Date');
		   x_msg_tbl(l_tot_msg_count).status       := 'S';
		      END IF;
                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                    -- x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

            End If;
         END IF;

        Else    --LineCov_cur% not Found Then
             fnd_msg_pub.initialize;
	     OKC_API.SET_MESSAGE
	    (
             p_app_name        => G_APP_NAME_OKS,
             p_msg_name        => 'OKS_CASCADE_COV_NOT_FOUND',
             p_token2	       => 'Line No ',
             p_token2_value    => l_line_number
	    );

             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'E';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;

        END IF;

        close LINEcov_cur;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

           OKS_PM_PROGRAMS_PVT.ADJUST_PM_PROGRAM_SCHEDULE
              (p_api_version          => l_api_version,
               p_init_msg_list        => l_init_msg_list,
               p_contract_line_id     => l_cle_id,
               p_new_start_date       => header_dates_rec.start_date,
               p_new_end_date         => header_dates_rec.end_date,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data
               );
    	  -- Bug 5227077 --
	  if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	      FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
              Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	  end if;
	  -- Bug 5227077 --

        End If;
	-- Bug 5191587 --
      ELSIf l_okc_lines_rec.lse_id in ('1','14','19') AND nvl(l_oks_lines_rec.standard_cov_yn, 'N') = 'Y' then
            If l_sr_number IS NOT NULL  then
	       fnd_msg_pub.initialize;
	             OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_SR_SUCCESS',
                           p_token1	     => 'SR#',
                           p_token1_value    => l_sr_number,
                           p_token2	     => 'Line No ',
                           p_token2_value    => l_line_number
			   );

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'W';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

                     fnd_msg_pub.initialize;
                   -- Issue a warning message if dates are cascaded from header to lines for a fully billed contract.
		     IF(l_disp_warning ='Y') THEN

			OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_DATES_WARN');

		       x_msg_tbl(l_tot_msg_count).status       := 'W';
		     ELSE

		      OKC_API.SET_MESSAGE(
                           p_app_name        => G_APP_NAME_OKS,
                           p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
                           p_token1	     => 'ATTRIBUTE',
                           p_token1_value    => 'Date');
		  x_msg_tbl(l_tot_msg_count).status       := 'S';
		   END IF;

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                    -- x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

            Else
	             fnd_msg_pub.initialize;

		 -- Issue a warning message if dates are cascaded from header to lines for a fully billed contract.
		      IF(l_disp_warning ='Y') THEN

			OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME_OKS,
				p_msg_name        => 'OKS_HEADER_CASCADE_DATES_WARN');

			x_msg_tbl(l_tot_msg_count).status       := 'W';
		      ELSE

			OKC_API.SET_MESSAGE(
				p_app_name        => G_APP_NAME_OKS,
				p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
				p_token1	         => 'ATTRIBUTE',
				p_token1_value    => 'Date');
				x_msg_tbl(l_tot_msg_count).status       := 'S';

		     END IF;
                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     --x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;

            End If;
	    -- Bug 5191587 --
   Else --lse_id = 46
           fnd_msg_pub.initialize;

	    -- Issue a warning message if dates are cascaded from header to lines for a fully billed contract.
            IF(l_disp_warning ='Y') THEN

		OKC_API.SET_MESSAGE(
			p_app_name        => G_APP_NAME_OKS,
			p_msg_name        => 'OKS_HEADER_CASCADE_DATES_WARN');

	    x_msg_tbl(l_tot_msg_count).status       := 'W';
	    ELSE

		OKC_API.SET_MESSAGE(
			p_app_name        => G_APP_NAME_OKS,
			p_msg_name        => 'OKS_HEADER_CASCADE_SUCCESS',
			p_token1	         => 'ATTRIBUTE',
			p_token1_value    => 'Date');
			x_msg_tbl(l_tot_msg_count).status       := 'S';
	   END IF;
	   l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
           p_encoded   => fnd_api.g_false);
           --x_msg_tbl(l_tot_msg_count).status       := 'S';
           x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
           l_tot_msg_count := l_tot_msg_count + 1;
           l_msg_data := NULL;

   End If;  --lse_id <> 46

   END IF;


IF l_calculate_tax is not null then
   l_lse_id           := l_okc_lines_rec.lse_id;
   l_price_negotiated := l_okc_lines_rec.price_negotiated;

   G_RAIL_REC.amount    := l_price_negotiated;
   IF l_lse_id <> 46 THEN

   --get all sublines and call tax engine and update IRT rule
    -------------------------------------------------------------------
     For sub_line_rec IN cur_sub_line(l_cle_id)
     Loop
       G_RAIL_REC.amount    := sub_line_rec.price_negotiated;
       OKS_TAX_UTIL_PVT.Get_Tax
                    (
	                 p_api_version	    => 1.0,
	                 p_init_msg_list	=> OKC_API.G_TRUE,
	                 p_chr_id           => l_chr_id,
                         p_cle_id           => sub_line_rec.id, --l_cle_id,
                         px_rail_rec        => G_RAIL_REC,
	                 x_msg_count	    => x_msg_count,
	                 x_msg_data		    => x_msg_data,
	                 x_return_status    => l_return_status
                    );

                    If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
		      FOR i in 1..fnd_msg_pub.count_msg
		      Loop
			fnd_msg_pub.get
			(
			  p_msg_index     => i,
			  p_encoded       => 'F',
			  p_data          => l_msg_data,
			  p_msg_index_out => l_msg_index
			);
			x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			l_tot_msg_count := l_tot_msg_count + 1;
			l_msg_data := NULL;
		     End Loop;
                     Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                   End If;

       l_UNIT_SELLING_PRICE       := G_RAIL_REC.UNIT_SELLING_PRICE;
       l_QUANTITY                 := G_RAIL_REC.QUANTITY;
       l_sub_total                := G_RAIL_REC.AMOUNT;
       l_AMOUNT_INCLUDES_TAX_FLAG := G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG;  --Rule_information5
       l_Tax_Code                 := G_RAIL_REC.TAX_CODE;
       l_TAX_RATE                 := G_RAIL_REC.TAX_RATE ;
       l_Tax_Value                := G_RAIL_REC.TAX_VALUE;  --Rule_information4

       IF l_AMOUNT_INCLUDES_TAX_FLAG IS NULL THEN
          l_AMOUNT_INCLUDES_TAX_FLAG := 'N';
       END IF;

       IF l_AMOUNT_INCLUDES_TAX_FLAG = 'Y' THEN
          l_total_amt := 0;
	  l_Tax_Value := 0;
       Else
          l_total := l_sub_total + l_Tax_Value;
          l_total_amt := l_total;
       END IF;

       If sub_line_rec.id  is not null THEN
          OPEN  cur_oks_lines(sub_line_rec.id);
          FETCH cur_oks_lines INTO l_oks_lines_rec;
          IF cur_oks_lines%NOTFOUND then
             CLOSE cur_oks_lines;
             x_return_status := 'E';
             RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
             CLOSE cur_oks_lines;
          END IF;

	  /*added for bug 7387293*/

	  l_kslnv_tbl_in(1).ID                     := l_oks_lines_rec.ID;
          l_kslnv_tbl_in(1).tax_amount             := l_Tax_Value;
          l_kslnv_tbl_in(1).tax_inclusive_yn       := l_AMOUNT_INCLUDES_TAX_FLAG;
          l_kslnv_tbl_in(1).OBJECT_VERSION_NUMBER  := l_oks_lines_rec.OBJECT_VERSION_NUMBER;

	   /*added for bug 7387293*/
	  --Update oks lines

          oks_contract_line_pub.update_line
              (
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_klnv_tbl                     => l_kslnv_tbl_in,
               x_klnv_tbl                     => l_kslnv_tbl_out,
               p_validate_yn                  => 'N'
               );


          If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	     FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;

             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          End If;
         /*
	   IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	   fnd_msg_pub.initialize;
           OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_RECALCULATE_TAX_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Recalculate Tax');

             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
           END IF;
          */

        END IF; --sub_line_rec.id  is not null chk
     End Loop; --sub_line_rec

     --
     -- Bug 4717842 --
     -- Update Lines Level Tax Amount --

     OPEN get_topline_tax_amt_csr(l_cle_id);
     FETCH get_topline_tax_amt_csr INTO l_line_tax_amt;
     CLOSE get_topline_tax_amt_csr;

     OPEN  cur_oks_lines(l_cle_id);
     FETCH cur_oks_lines INTO l_oks_lines_rec;
     close cur_oks_lines;

     l_klnv_tbl_in(1).ID               := l_oks_lines_rec.id;
     l_klnv_tbl_in(1).tax_amount       := l_line_tax_amt.tax_amount;
     l_klnv_tbl_in(1).tax_inclusive_yn := l_oks_lines_rec.tax_inclusive_yn;
     l_klnv_tbl_in(1).OBJECT_VERSION_NUMBER  := l_oks_lines_rec.OBJECT_VERSION_NUMBER;
     oks_contract_line_pub.update_line
              (
               p_api_version           => l_api_version,
               p_init_msg_list         => l_init_msg_list,
               x_return_status         => l_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data,
               p_klnv_tbl              => l_klnv_tbl_in,
               x_klnv_tbl              => l_klnv_tbl_out,
               p_validate_yn           => 'N'
               );
     -- Bug 5227077 --
     If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	 FOR i in 1..fnd_msg_pub.count_msg
	 Loop
	       fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
         Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      End If;

  ELSE   -- this is to check for lse_id = 46
     OKS_TAX_UTIL_PVT.Get_Tax
                    (
	                 p_api_version	    => 1.0,
	                 p_init_msg_list    => OKC_API.G_TRUE,
	                 p_chr_id           => l_chr_id,
                         p_cle_id           => l_cle_id,
                         px_rail_rec        => G_RAIL_REC,
	                 x_msg_count	    => x_msg_count,
	                 x_msg_data	    => x_msg_data,
	                 x_return_status    => l_return_status
	                    );
     -- Bug 5227077 --
     If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	      FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     End If;
     -- Bug 5227077 --
     l_UNIT_SELLING_PRICE       := G_RAIL_REC.UNIT_SELLING_PRICE;
     l_QUANTITY                 := G_RAIL_REC.QUANTITY;
     l_sub_total                := G_RAIL_REC.AMOUNT;
     l_AMOUNT_INCLUDES_TAX_FLAG := G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG;  --Rule_information5
     l_Tax_Code                 := G_RAIL_REC.TAX_CODE;
     l_TAX_RATE                 := G_RAIL_REC.TAX_RATE ;
     l_Tax_Value                := G_RAIL_REC.TAX_VALUE;  --Rule_information4
     l_Return_Status            := l_return_status;

     If l_AMOUNT_INCLUDES_TAX_FLAG = 'Y' THEN
        l_total_amt := 0;
	l_Tax_Value := 0;
     Else
        l_total := l_sub_total + l_Tax_Value;
        l_total_amt := l_total;
     End If;

     l_klnv_tbl_in(1).ID               := l_oks_lines_rec.ID;
     l_klnv_tbl_in(1).tax_amount       := l_Tax_Value;
     l_klnv_tbl_in(1).tax_inclusive_yn := l_AMOUNT_INCLUDES_TAX_FLAG;
     l_klnv_tbl_in(1).OBJECT_VERSION_NUMBER  := l_oks_lines_rec.OBJECT_VERSION_NUMBER;


          oks_contract_line_pub.update_line
              (
               p_api_version           => l_api_version,
               p_init_msg_list         => l_init_msg_list,
               x_return_status         => l_return_status,
               x_msg_count             => l_msg_count,
               x_msg_data              => l_msg_data,
               p_klnv_tbl              => l_klnv_tbl_in,
               x_klnv_tbl              => l_klnv_tbl_out,
               p_validate_yn           => 'N'
               );


    	 If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	     FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
       /*
	  IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
             fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_RECALCULATE_TAX_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Recalculate Tax');

             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;


          END IF;
        */
   END IF;  --lse_id

    -- Update header level tax amount

      OPEN get_hdr_tax_amt_csr(l_chr_id);
      FETCH get_hdr_tax_amt_csr INTO l_hdr_tax_amt;
      CLOSE get_hdr_tax_amt_csr;

      l_khrv_tbl_type_in(1).id                          := l_oks_headers_rec.id;
      l_khrv_tbl_type_in(1).tax_amount                  := l_hdr_tax_amt.tax_amount;
      l_khrv_tbl_type_in(1).object_version_number       := l_oks_headers_rec.object_version_number;

      oks_contract_hdr_pub.update_header(
        p_api_version              => l_api_version,
        p_init_msg_list            => l_init_msg_list,
        x_return_status            => l_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data,
        p_khrv_tbl                 => l_khrv_tbl_type_in,
        x_khrv_tbl                 => l_khrv_tbl_type_out,
        p_validate_yn              => 'N');
      If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	 FOR i in 1..fnd_msg_pub.count_msg
	      Loop
	         fnd_msg_pub.get
		(
		  p_msg_index     => i,
		  p_encoded       => 'F',
		  p_data          => l_msg_data,
		  p_msg_index_out => l_msg_index
		);
		x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	        l_tot_msg_count := l_tot_msg_count + 1;
		l_msg_data := NULL;
	      End Loop;
             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       End If;
      -- Bug 5227077 --


    IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
             fnd_msg_pub.initialize;
             OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_RECALCULATE_TAX_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Recalculate Tax');

             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
             p_encoded   => fnd_api.g_false);
             x_msg_tbl(l_tot_msg_count).status       := 'S';
             x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
             l_tot_msg_count := l_tot_msg_count + 1;
             l_msg_data := NULL;
     END IF;

   -- Update Header Level Tax Amount --
   -- Bug 4717842 --
 END IF;

--Fix for Bug#3635291;
     OKS_BILL_SCH.Cascade_Dates_SLL
        (
         p_top_line_id     =>    l_cle_id,
         x_return_status   =>    l_return_status,
         x_msg_count       =>    l_msg_count,
         x_msg_data        =>    l_msg_data);
         If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then

            FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                         p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

         End If;

--Fix for Bug#3635291;

 exit when i=header_lines_tbl.last;
           i:=header_lines_tbl.next(i);
 END LOOP;

 l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                               p_encoded   => fnd_api.g_false);

/*
 If l_okc_lines_rec.lse_id <> '14' then

    WHILE l_msg_data IS NOT NULL
      LOOP
        IF x_msg_tbl.count=0 THEN
          l_tot_msg_count:=1 ;
        ELSE
          l_tot_msg_count := x_msg_tbl.count + 1;
        END IF;
        x_msg_tbl(l_tot_msg_count).status       := l_return_status;
        x_msg_tbl(l_tot_msg_count).description  := l_msg_data;

	l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_next,
                                   p_encoded   => fnd_api.g_false
                                  );
      END LOOP;
 End If;

*/
End If;
Exception
         When  G_EXCEPTION_HALT_VALIDATION Then
                      x_return_status   :=   l_return_status;
		      x_msg_data        := l_msg_data;
         When  Others Then
                      x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                      x_msg_data := l_msg_data;
END Default_header_to_lines;

----------------------------------------------------------------------------------------------

PROCEDURE Default_lines_to_sublines
                 (lines_sublines_tbl  IN  lines_sublines_tbl_type
                 ,X_return_status     OUT  NOCOPY Varchar2
                 ,x_msg_tbl           IN    OUT NOCOPY attr_msg_tbl_type) IS

Cursor  cur_line_dates(p_cle_id in NUMBER) is
     select start_date , end_date, lse_id
     from okc_k_lines_v
     where id = p_cle_id;
line_dates_rec   cur_line_dates%ROWTYPE;

Cursor cur_okc_lines(p_cle_id in NUMBER) is
  select
         id,
	 line_number,
         line_renewal_type_code
  from okc_k_lines_b
  where id = p_cle_id;
  l_okc_lines_rec   cur_okc_lines%ROWTYPE;

Cursor cur_oks_lines(p_cle_id in NUMBER) is
  select
         id,
         sfwt_flag,
         object_version_number,
         inv_print_flag,
         price_uom,   -- 8/23/05 hkamdar R12 Partial Period
         invoice_text,
	 standard_cov_yn -- Issue# 14 Bug 4566346
  from oks_k_lines_v
  where cle_id = p_cle_id;
  l_oks_lines_rec       cur_oks_lines%ROWTYPE;
  l_oks_sub_lines_rec   cur_oks_lines%ROWTYPE;


Cursor cur_sub_line(p_cle_id in NUMBER) IS
  select id,lse_id
  from okc_k_lines_v
  where cle_id =p_cle_id
  and chr_id is null
  and lse_id in (7,8,9,10,11,13,18,25,35)
  and date_cancelled is null;		--[llc]

  l_sub_line_rec    cur_sub_line%ROWTYPE;

Cursor cur_sub_line_lse(p_subline_id in NUMBER) IS
  select id,
         lse_id,
	 line_number,
	 date_terminated -- new
  from okc_k_lines_v
  where id =p_subline_id;

  l_sub_line_lse_rec    cur_sub_line_lse%ROWTYPE;



i                          NUMBER;
l_chr_id                   NUMBER;
--l_cle_id                   NUMBER;
l_lse_id                   NUMBER;
l_subline_id               NUMBER;
p_subline_id               NUMBER;
l_line_irt                 VARCHAR2(150) ;
l_line_renewal             VARCHAR2(150);
l_line_inv_print           VARCHAR2(150) ;
l_line_dates               VARCHAR2(150) ;
l_line_cov_eff             VARCHAR2(150) ;
l_api_version              Number      := 1.0;
l_init_msg_list            Varchar2(1) := 'F';
l_msg_count                Number;
l_msg_data                 Varchar2(1000);
l_return_status            Varchar2(1) := 'S';
l_tot_msg_count            NUMBER:=0;
l_cle_id_old               NUMBER:=0;

l_can_id                   NUMBER;
p_klnv_rec                 oks_kln_pvt.klnv_rec_type;
l_klnv_rec                 oks_kln_pvt.klnv_rec_type := p_klnv_rec;
p_klnv_rec_in              oks_kln_pvt.klnv_rec_type;
l_klnv_rec_in              oks_kln_pvt.klnv_rec_type := p_klnv_rec_in;

p_klnv_rec_out             oks_kln_pvt.klnv_rec_type;
l_klnv_rec_out             oks_kln_pvt.klnv_rec_type := p_klnv_rec_out;

l_clev_tbl_in              okc_contract_pub.clev_tbl_type;
l_clev_tbl_out             okc_contract_pub.clev_tbl_type;
l_cle_id                   NUMBER;
p_cle_id                   NUMBER;

l_error_tbl                OKC_API.ERROR_TBL_TYPE;
p_klnv_tbl                 oks_kln_pvt.klnv_tbl_type;
l_klnv_tbl                 oks_kln_pvt.klnv_tbl_type := p_klnv_tbl;
x_klnv_tbl                 oks_kln_pvt.klnv_tbl_type;
l_klnv_tbl_in              oks_contract_line_pub.klnv_tbl_type;
l_klnv_tbl_out             oks_contract_line_pub.klnv_tbl_type;
l_msg_index                NUMBER;
l_flag                     BOOLEAN;
l_line_number              VARCHAR2 (150);
l_sub_line_number          VARCHAR2 (150);
l_sub_line_seq_number      VARCHAR2 (310);
x_msg_data	           VARCHAR2(2000);

-- GCHADHA --
-- BUG 4093005 --
l_line_id_tbl              OKS_ATTR_DEFAULTS_PVT.lines_id_tbl_type;
l_id                       NUMBER;
l_count                    NUMBER;
-- END GCHADHA --

l_line_price_uom           VARCHAR2 (150); -- 8/23/05 hkamdar R12 Partial Period


  l_input_details             OKS_QP_PKG.INPUT_DETAILS;
  l_output_details            OKS_QP_PKG.PRICE_DETAILS;
  l_modif_details             QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
  l_pb_details                OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
  l_status_tbl                oks_qp_int_pvt.PRICING_STATUS_TBL;

  l_bill_y_n VARCHAR2(1);
  l_disp_warning VARCHAR2(1) :='N';

PROCEDURE sublines_common_attributes
                 (p_line_irt         IN  VARCHAR2
                 ,p_line_renewal     IN  VARCHAR2
                 ,p_line_inv_print   IN  VARCHAR2
                 ,p_line_dates       IN  VARCHAR2
                 ,p_subline_id       IN  NUMBER
 	         ,p_price_uom        IN VARCHAR2 -- 8/23/05 hkamdar R12 Partial Period
		 ,x_return_status    OUT NOCOPY VARCHAR2
                 ) IS

BEGIN
     l_return_status := 'S';
     OPEN  cur_oks_lines(p_subline_id);
     FETCH cur_oks_lines INTO l_oks_sub_lines_rec;
     CLOSE cur_oks_lines;
     --new
     OPEN  cur_sub_line_lse(p_subline_id);
     FETCH cur_sub_line_lse INTO l_sub_line_lse_rec;
     CLOSE cur_sub_line_lse;
     --new



        IF l_line_irt  is not null then

             l_klnv_tbl_in(1).ID                     := l_oks_sub_lines_rec.id;--l_subline_id;
             l_klnv_tbl_in(1).invoice_text           := l_oks_lines_rec.invoice_text;
             l_klnv_tbl_in(1).object_version_number  := l_oks_sub_lines_rec.object_version_number;

             IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                 OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Invoicing Text');

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;
                      fnd_msg_pub.initialize;

             END IF;

        END IF;
        -------------------------------------------------------------------

        IF  l_line_renewal IS NOT NULL THEN

              l_clev_tbl_in(1).id	                := l_subline_id;
              l_clev_tbl_in(1).line_renewal_type_code   := l_okc_lines_rec.line_renewal_type_code;

              IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                  OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Renewal');

                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;
                      fnd_msg_pub.initialize;



              END IF;
        END IF;

        If  l_line_dates is not null then

        l_sub_line_number     := l_sub_line_lse_rec.line_number;
        l_line_number         := l_okc_lines_rec.line_number;
	l_sub_line_seq_number := (l_line_number || '.' || l_sub_line_number);

        If oks_extwar_util_pvt.check_already_billed(
                                                 p_chr_id => null,
                                                 p_cle_id => l_cle_id,
                                                 p_lse_id => line_dates_rec.lse_id,
                                                 p_end_date => null) Then
              fnd_msg_pub.initialize;
              validate_date

                      (p_api_version    => l_api_version
                      ,p_init_msg_list  => l_init_msg_list
                      ,p_hdr_id         => NULL
                      ,p_top_line_id    => l_cle_id
                      ,p_sub_line_id    => l_subline_id
                      ,x_return_status  => l_return_status
                      ,x_msg_count      => l_msg_count
                      ,x_msg_data       => l_msg_data
                      ,x_flag           => l_flag);


               IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		 FOR i in 1..fnd_msg_pub.count_msg
	         Loop
		   fnd_msg_pub.get
		   (
			p_msg_index     => i,
			p_encoded       => 'F',
			p_data          => l_msg_data,
			p_msg_index_out => l_msg_index
		   );
		  x_msg_tbl(l_tot_msg_count).status       := l_return_status;
		  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
	          l_tot_msg_count := l_tot_msg_count + 1;
		  l_msg_data := NULL;
	        End Loop;
                Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
              Else
                  If l_flag <> TRUE then
	             fnd_msg_pub.initialize;
                     OKC_API.SET_MESSAGE(
                       p_app_name        => 'OKS', --G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_BA_UPDATE_NOT_ALLOWED',
                       p_token1	         => 'Sub Line No ',
                       p_token1_value    => l_sub_line_seq_number);


	             l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'E';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;
		     fnd_msg_pub.initialize;
                     Raise G_EXCEPTION_HALT_VALIDATION;

                  End If;
               End If;
        End If;

--new
	    OPEN cur_line_dates(l_cle_id );
            FETCH cur_line_dates INTO line_dates_rec;
            CLOSE cur_line_dates;


	    l_clev_tbl_in(1).id		         := l_subline_id;
	    l_clev_tbl_in(1).chr_id		         := NULL;
	    l_clev_tbl_in(1).cle_id			 := l_cle_id;
	    l_clev_tbl_in(1).start_date	         := line_dates_rec.start_date;
            l_clev_tbl_in(1).end_date	         := line_dates_rec.end_date;
	    l_clev_tbl_in(1).dnz_chr_id	         := l_chr_id;
             If line_dates_rec.lse_id = '14' Then
                   If l_clev_tbl_in(1).start_date > SYSDATE THen
                      l_clev_tbl_in(1).sts_code  := 'SIGNED';
                   Elsif l_clev_tbl_in(1).start_date <= SYSDATE And l_clev_tbl_in(1).end_date >= SYSDATE  THEN
                      l_clev_tbl_in(1).sts_code  := 'ACTIVE';
                   ELSIF l_clev_tbl_in(1).end_date < SYSDATE Then
                      l_clev_tbl_in(1).sts_code :='EXPIRED';
                   End if;
                End if;

                IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	  -- Issue a warning message if dates are cascaded from lines to sublines for a fully billed contract.
		IF(l_disp_warning ='Y') THEN
			 OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_LINES_CASCADE_DATES_WARN');
		       x_msg_tbl(l_tot_msg_count).status       := 'W';

		ELSE

                    OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Date');
		       x_msg_tbl(l_tot_msg_count).status       := 'S';

		END IF;
                END IF;
----new
                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                    -- x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;
                     fnd_msg_pub.initialize;
----new

        END IF;
   -------------------------------------------------------------------
        IF  l_line_inv_print IS NOT NULL THEN

            l_klnv_tbl_in(1).ID                     := l_oks_sub_lines_rec.id;--l_subline_id;
            l_klnv_tbl_in(1).inv_print_flag         := l_oks_lines_rec.inv_print_flag;
            l_klnv_tbl_in(1).object_version_number  := l_oks_sub_lines_rec.object_version_number;

            IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
                 OKC_API.SET_MESSAGE(
                       p_app_name        => G_APP_NAME_OKS,
                       p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
                       p_token1	         => 'ATTRIBUTE',
                       p_token1_value    => 'Invoicing Print Flag');
            END IF;

----new
                     l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                     p_encoded   => fnd_api.g_false);
                     x_msg_tbl(l_tot_msg_count).status       := 'S';
                     x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                     l_tot_msg_count := l_tot_msg_count + 1;
                     l_msg_data := NULL;
                      fnd_msg_pub.initialize;
----new



        END IF;

   -------------------------------------------------------------------
       -- 8/23/2005 hkamdar R12 Partial Period
	IF l_line_price_uom  is not null THEN
	   If l_sub_line_lse_rec.lse_id IN (7,9,25)
	    AND OKS_AUTH_UTIL_PVT.Is_Line_Eligible(p_api_version => 1.0,
	                                     p_init_msg_list => 'T',
					                     p_contract_hdr_id => l_chr_id,
                					     p_contract_line_id => l_subline_id,
				                	     p_price_list_id => '',
					                     p_intent => 'S',
					                     x_msg_count => l_msg_count,
					                     x_msg_data  => l_msg_data)
         THEN
			 -- Covered Item, Product, Convered product in extended warraties
	      l_klnv_tbl_in(1).ID			:= l_oks_sub_lines_rec.id;--l_subline_id;
	      l_klnv_tbl_in(1).price_uom		:= l_oks_lines_rec.price_uom;
   	      l_klnv_tbl_in(1).object_version_number  := l_oks_sub_lines_rec.object_version_number;

	      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
       		  OKC_API.SET_MESSAGE(
	                            p_app_name        => G_APP_NAME_OKS,
   	                            p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
       	                            p_token1	         => 'ATTRIBUTE',
                                    p_token1_value    => 'Price UOM');

                 l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                 p_encoded   => fnd_api.g_false);
                 x_msg_tbl(l_tot_msg_count).status       := 'S';
                 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                 l_tot_msg_count := l_tot_msg_count + 1;
                 l_msg_data := NULL;
                 fnd_msg_pub.initialize;
	      END IF;
	   Else
	/*	OKC_API.SET_MESSAGE(
	                p_app_name        => G_APP_NAME_OKS,
   	                p_msg_name        => 'OKS_LINE_CASCADE_ERROR',
       	                p_token1	         => 'ATTRIBUTE',
          	        p_token1_value    => 'Price UOM');

                 l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                 p_encoded   => fnd_api.g_false);
		 ----errorout_gsi('Subline_common_attribute UOM msg '||l_msg_data);
                 x_msg_tbl(l_tot_msg_count).status       := 'E';
                 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                 l_tot_msg_count := l_tot_msg_count + 1;
                 l_msg_data := NULL;
                 fnd_msg_pub.initialize; */
		 null;
	   End If;
         END IF;
--new
Exception
         When  G_EXCEPTION_HALT_VALIDATION Then
                      x_return_status   := 'E';
		      x_msg_data        := l_msg_data;
         When  Others Then
                      x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                      x_msg_data := l_msg_data;

--new

END sublines_common_attributes;

Begin
 fnd_msg_pub.initialize;

  IF NOT lines_sublines_tbl.COUNT=0 THEN
     i:=lines_sublines_tbl.FIRST;
     -- GCHADHA --
     -- BUG 4093005 --
     l_id := 0;
     l_count := 0;
     -- END GCHADHA --
         --FOR i IN lines_sublines_tbl.FIRST .. lines_sublines_tbl.LAST
     LOOP
           l_chr_id                :=  lines_sublines_tbl(i).chr_id;
           l_cle_id                :=  lines_sublines_tbl(i).cle_id;
           l_subline_id            :=  lines_sublines_tbl(i).subline_id;
           l_line_irt              :=  lines_sublines_tbl(i).line_irt;
           l_line_renewal          :=  lines_sublines_tbl(i).line_renewal;
           l_line_inv_print        :=  lines_sublines_tbl(i).line_inv_print;
           l_line_dates            :=  lines_sublines_tbl(i).line_dates;
           l_line_cov_eff          :=  lines_sublines_tbl(i).line_cov_eff;
 	       l_line_price_uom        :=  lines_sublines_tbl(i).price_uom; -- 8/23/05 hkamdar R12 Partial Period
-- errorout_vg('Line_Price Uom ' || lines_sublines_tbl(i).price_uom);

	   -- GCHADHA --
           -- BUG 4093005 --
           IF l_id <> l_cle_id THEN
             l_line_id_tbl(l_count).id := l_cle_id;
             l_id := l_cle_id;
             l_count :=l_count + 1;
           END IF;
           -- END GCHADHA --

	   l_klnv_tbl_in.DELETE;
           l_clev_tbl_in.DELETE;

	-- check if the contract has been imported and fully billed at source
	IF(l_chr_id IS NOT NULL) THEN
		select billed_at_source INTO l_bill_y_n FROM okc_k_headers_all_b where id = l_chr_id ;
	END IF;

	IF ((l_bill_y_n IS NOT NULL) AND (l_bill_y_n = 'Y')) THEN
		l_disp_warning :='Y';
	ELSE
		l_disp_warning :='N';
	END IF;



     p_cle_id := l_cle_id;
     OPEN  cur_oks_lines(p_cle_id);
     FETCH cur_oks_lines INTO l_oks_lines_rec;
     CLOSE cur_oks_lines;

     OPEN  cur_okc_lines(p_cle_id);
     FETCH cur_okc_lines INTO l_okc_lines_rec;
     CLOSE cur_okc_lines;
--new
     OPEN  cur_sub_line_lse(l_subline_id);
     FETCH cur_sub_line_lse INTO l_sub_line_lse_rec;
     CLOSE cur_sub_line_lse;
--new

     If l_line_dates is not null then

         IF l_cle_id_old <> l_cle_id AND nvl(l_oks_lines_rec.standard_cov_yn, 'N') <> 'Y' Then
----errorout_gsi('Line date is not null, calling update_coverage_effectivity');
            OPEN cur_line_dates(l_cle_id );
            FETCH cur_line_dates INTO line_dates_rec;
            CLOSE cur_line_dates;
            OKS_COVERAGES_PVT.Update_COVERAGE_Effectivity
                (
                  p_api_version     => l_api_version,
                  p_init_msg_list   => l_init_msg_list,
                  x_return_status   => l_return_status,
                  x_msg_count	    => l_msg_count,
                  x_msg_data        => l_msg_data,
                  p_service_Line_Id => l_cle_id,
                  p_New_Start_Date  => line_dates_rec.start_date,
                  p_New_End_Date    => line_dates_rec.end_date  );

                  If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
		       FOR i in 1..fnd_msg_pub.count_msg
		       Loop
			 fnd_msg_pub.get
			 (
			    p_msg_index     => i,
			    p_encoded       => 'F',
			    p_data          => l_msg_data,
			    p_msg_index_out => l_msg_index
			 );
			 x_msg_tbl(l_tot_msg_count).status       := l_return_status;
			 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
			 l_tot_msg_count := l_tot_msg_count + 1;
			 l_msg_data := NULL;
			End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  End If;

                  IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

	   -- Issue a warning message if dates are cascaded from lines to sublines for a fully billed contract.
		   IF(l_disp_warning ='Y') THEN

			OKC_API.SET_MESSAGE(
                          p_app_name        => G_APP_NAME_OKS,
                          p_msg_name        => 'OKS_LINES_CASCADE_DATES_WARN');

		   ELSE

                      OKC_API.SET_MESSAGE(
                          p_app_name        => G_APP_NAME_OKS,
                          p_msg_name        => 'OKS_LINE_CASCADE_SUCCESS',
                          p_token1	    => 'ATTRIBUTE',
                          p_token1_value    => 'Date');
		  END IF;
                  END IF;
                  l_cle_id_old:=l_cle_id ;
           END IF;

     END IF;

     IF l_subline_id is not null then

-- errorout_vg('Calling subline_common_attributes');

        sublines_common_attributes
                 (p_line_irt         => l_line_irt
                 ,p_line_renewal     => l_line_renewal
                 ,p_line_inv_print   => l_line_inv_print
                 ,p_line_dates       => l_line_dates
                 ,p_subline_id       => l_subline_id
 	         ,p_price_uom => l_line_price_uom  -- 8/23/05 hkamdar R12 Partial Period
		 ,x_return_status    => l_return_status
                 );
	 -- Bug 5227077 --
	 if not(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

             Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	 end if;
	 -- Bug 5227077 --


--errorout_gsi('After sublines_common_attributes status '||l_return_status);
--new
        IF l_line_irt       IS NOT NULL  or
           l_line_inv_print IS NOT NULL  or
	   l_line_price_uom IS NOT NULL THEN -- 8/23/05 hkamdar R12 Partial Period Added new condition

--Update oks lines
-- errorout_vg('Calling oks_contract_line_pub.update_line');
              oks_contract_line_pub.update_line
              (
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_klnv_tbl                     => l_klnv_tbl_in,
               x_klnv_tbl                     => l_klnv_tbl_out,
               p_validate_yn                  => 'N'
               );

-- errorout_vg('After oks_contract_line_pub.update_line status '||l_return_status);
--errorout_gsi('After oks_contract_line_pub.update_line Message '||l_msg_data);

                  If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then

	              FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                     p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  End If;

        END IF;

   -------------------------------------------------------------------
        IF l_line_renewal       IS NOT NULL  OR
           l_line_dates         IS NOT NULL  OR
           l_line_cov_eff       IS NOT NULL  THEN
--errorout_gsi('Calling  local update_line');
           update_line(
	               p_clev_tbl      => l_clev_tbl_in,
        	       x_clev_tbl      => l_clev_tbl_out,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data
                      );

           If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	              FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                     p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

           End If;

        END IF;
--new

     ELSIF l_subline_id is null then
-- errorout_vg('l_subline_id is null');

        OPEN  cur_sub_line(p_cle_id);
        LOOP
        FETCH cur_sub_line INTO l_sub_line_rec;
        l_subline_id := l_sub_line_rec.id;

           EXIT WHEN cur_sub_line%NOTFOUND;

           l_klnv_tbl_in.DELETE;
           l_clev_tbl_in.DELETE;
	  -- GCHADHA --
          -- NCR WARRANTY CASCADE DATE MINOR ENHANCEMENT --
	  -- 5/19/2005 --

	  IF l_sub_line_rec.lse_id = 18
	  THEN

             --new
	     OPEN  cur_sub_line_lse(l_subline_id);
	     FETCH cur_sub_line_lse INTO l_sub_line_lse_rec;
	     CLOSE cur_sub_line_lse;
	    --new
         IF l_sub_line_lse_rec.date_terminated IS NULL
         THEN
-- errorout_vg('Calling subline_common_attributes Second');
              sublines_common_attributes
                 (p_line_irt         => l_line_irt
                 ,p_line_renewal     => l_line_renewal
                 ,p_line_inv_print   => l_line_inv_print
                 ,p_line_dates       => l_line_dates
                 ,p_subline_id       => l_subline_id
		 ,p_price_uom => l_line_price_uom  -- 8/23/05 hkamdar R12 Partial Period
		 ,x_return_status    => l_return_status
                 );
 --- errorout_vg('After sublines_common_attributes second status '||l_return_status);
		FOR i in 1..fnd_msg_pub.count_msg
		 Loop
		  fnd_msg_pub.get
                 (
	            p_msg_index     => i,
                    p_encoded       => 'F',
                    p_data          => l_msg_data,
                    p_msg_index_out => l_msg_index
                   );

                 x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                 l_tot_msg_count := l_tot_msg_count + 1;
                 l_msg_data := NULL;
      	       End Loop;
               IF ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                 Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
               End If;
            END IF ;
          ELSE
-- errorout_vg('Calling subline_common_attributes Third');
               sublines_common_attributes
                 (p_line_irt         => l_line_irt
                 ,p_line_renewal     => l_line_renewal
                 ,p_line_inv_print   => l_line_inv_print
                 ,p_line_dates       => l_line_dates
                 ,p_subline_id       => l_subline_id
		 ,p_price_uom => l_line_price_uom  -- 8/23/05 hkamdar R12 Partial Period
		 ,x_return_status    => l_return_status
                 );
-- errorout_vg('After sublines_common_attributes Third status '||l_return_status);
      	   FOR i in 1..fnd_msg_pub.count_msg
           Loop
                fnd_msg_pub.get
                 (
	            p_msg_index     => i,
                    p_encoded       => 'F',
                    p_data          => l_msg_data,
                    p_msg_index_out => l_msg_index
                   );

                 x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                 x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                 l_tot_msg_count := l_tot_msg_count + 1;
                 l_msg_data := NULL;
      	  End Loop;
          IF ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
              Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          End If;
       END IF;

	   -- END GCAHDHA --
           IF l_line_irt       IS NOT NULL  or
              l_line_inv_print IS NOT NULL  OR
              l_line_price_uom IS NOT NULL THEN -- 8/23/05 hkamdar R12 Partial Period Added new condition


--Update oks lines
--errorout_gsi('Calling oks_contract_line_pub.update_line Second');
      oks_contract_line_pub.update_line
              (
               p_api_version                  => l_api_version,
               p_init_msg_list                => l_init_msg_list,
               x_return_status                => l_return_status,
               x_msg_count                    => l_msg_count,
               x_msg_data                     => l_msg_data,
               p_klnv_tbl                     => l_klnv_tbl_in,
               x_klnv_tbl                     => l_klnv_tbl_out,
               p_validate_yn                  => 'N'
               );

             If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	              FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                     p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

                  End If;

           END IF;

           IF l_line_renewal       IS NOT NULL  OR
              l_line_dates         IS NOT NULL  OR
              l_line_cov_eff       IS NOT NULL  THEN

--errorout_gsi('Calling  local update_line Second');

              update_line(
	               p_clev_tbl      => l_clev_tbl_in,
        	       x_clev_tbl      => l_clev_tbl_out,
                       x_return_status => l_return_status,
                       x_msg_count     => l_msg_count,
                       x_msg_data      => l_msg_data
                      );
                If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	              FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                     p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                End If;

           END IF;
         --    errorout_vg('I -- Before Calling oks_qp_int_pvt.compute_Price lse_id ' || l_sub_line_rec.lse_id );
	  IF l_line_price_uom is NOT NULL and l_sub_line_rec.lse_id in (7,9,25)
	  AND OKS_AUTH_UTIL_PVT.Is_Line_Eligible(p_api_version => 1.0,
	                                     p_init_msg_list => 'T',
					                     p_contract_hdr_id => l_chr_id,
                					     p_contract_line_id => l_subline_id,
				                	     p_price_list_id => '',
					                     p_intent => 'S',
					                     x_msg_count => l_msg_count,
					                     x_msg_data  => l_msg_data)
	 THEN
	  	--  errorout_vg('I -- Calling oks_qp_int_pvt.compute_Price');
		l_input_details.line_id    := l_cle_id;
		l_input_details.subline_id := l_subline_id;
		l_input_details.intent     := 'SP';
	        oks_qp_int_pvt.compute_Price
          		 (
                   p_api_version         => 1.0,
                   p_init_msg_list       => 'T',
                   p_detail_rec          => l_input_details,
                   x_price_details       => l_output_details,
                   x_modifier_details    => l_modif_details,
                   x_price_break_details => l_pb_details,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data
			  );

		   l_status_tbl := oks_qp_int_pvt.get_Pricing_Messages;
		    IF l_status_tbl.Count > 0 Then

		          l_count:= l_status_tbl.FIRST;
			  For i in l_status_tbl.FIRST..l_status_tbl.LAST
			  Loop
				x_msg_tbl(l_count).status       := l_status_tbl(i).Status_Code;
				x_msg_tbl(l_count).description  := l_status_tbl(i).Status_Text;
				EXIT WHEN l_count = l_status_tbl.LAST;
				l_count :=  l_status_tbl.NEXT(l_count);
			  End Loop;
		    END IF;
		    -- Bug 5381082 --
		    If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
			    FOR i in 1..fnd_msg_pub.count_msg
		            Loop
				 fnd_msg_pub.get
				  (
					p_msg_index     => i,
					p_encoded       => 'F',
					p_data          => l_msg_data,
					p_msg_index_out => l_msg_index
				  );
				x_msg_tbl(l_tot_msg_count).status       := l_return_status;
				x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
				l_tot_msg_count := l_tot_msg_count + 1;
				l_msg_data := NULL;
      		           End Loop;
			   Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
		    End If;
	            -- Bug 5381082 --
	  End if;

        END LOOP;
        CLOSE cur_sub_line;
        l_subline_id := l_sub_line_rec.id;

    End If;
  -- Bug 5205136 --
  -- errorout_vg('Before Calling oks_qp_int_pvt.compute_Price lse_id ' || l_sub_line_rec.lse_id );
     IF l_line_price_uom is NOT NULL and (l_sub_line_rec.lse_id in (7,9,25)
					 OR l_sub_line_lse_rec.lse_id in (7,9,25))
     AND OKS_AUTH_UTIL_PVT.Is_Line_Eligible(p_api_version => 1.0,
	                                     p_init_msg_list => 'T',
					                     p_contract_hdr_id => l_chr_id,
                					     p_contract_line_id => l_subline_id,
				                	     p_price_list_id => '',
					                     p_intent => 'S',
					                     x_msg_count => l_msg_count,
					                     x_msg_data  => l_msg_data)
     THEN
  -- Bug 5205136 --
	 --  errorout_vg('Calling oks_qp_int_pvt.compute_Price');
	 l_input_details.line_id    := l_cle_id;
	 l_input_details.subline_id := l_subline_id;
	 l_input_details.intent     := 'SP';
         oks_qp_int_pvt.compute_Price
          		 (
                   p_api_version         => 1.0,
                   p_init_msg_list       => 'T',
                   p_detail_rec          => l_input_details,
                   x_price_details       => l_output_details,
                   x_modifier_details    => l_modif_details,
                   x_price_break_details => l_pb_details,
                   x_return_status       => l_return_status,
                   x_msg_count           => l_msg_count,
                   x_msg_data            => l_msg_data
		  );

         l_status_tbl := oks_qp_int_pvt.get_Pricing_Messages;

	 IF l_status_tbl.Count > 0 Then

		l_count:= l_status_tbl.FIRST;
		For i in l_status_tbl.FIRST..l_status_tbl.LAST
		Loop
			x_msg_tbl(l_count).status       := l_status_tbl(i).Status_Code;
			x_msg_tbl(l_count).description  := l_status_tbl(i).Status_Text;
		EXIT WHEN l_count = l_status_tbl.LAST;
			l_count :=  l_status_tbl.NEXT(l_count);
		End Loop;
	 END IF;
	 -- Bug 5381082 --
         If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	    FOR i in 1..fnd_msg_pub.count_msg
            Loop
                 fnd_msg_pub.get
                     (
	              p_msg_index     => i,
                      p_encoded       => 'F',
                      p_data          => l_msg_data,
                      p_msg_index_out => l_msg_index
                     );
                  x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                  x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                  l_tot_msg_count := l_tot_msg_count + 1;
                  l_msg_data := NULL;
      	   End Loop;
           Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
	-- Bug 5381082 --
     End if;

     exit when i=lines_sublines_tbl.last;
               i:=lines_sublines_tbl.next(i);

     END LOOP;
   -- GCHADHA --
   -- BUG 4093005 --
   -- 05-JAN-2005 --
    IF l_line_id_tbl.COUNT > 0 THEN
      FOR j in l_line_id_tbl.FIRST..l_line_id_tbl.LAST LOOP
         OKS_BILL_SCH.Cascade_Dates_SLL
          (
           p_top_line_id     =>    l_line_id_tbl(j).id,
           x_return_status   =>    l_return_status,
           x_msg_count       =>    l_msg_count,
           x_msg_data        =>    l_msg_data);
 --errorout_gsi('After OKS_BILL_SCH.Cascade_Dates_SLL status '||l_return_status);
         If ( l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
            FOR i in 1..fnd_msg_pub.count_msg
                      Loop
                          fnd_msg_pub.get
                            (
	                     p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => l_msg_data,
                             p_msg_index_out => l_msg_index
                            );

                          x_msg_tbl(l_tot_msg_count).status       := l_return_status;
                          x_msg_tbl(l_tot_msg_count).description  := l_msg_data;
                          l_tot_msg_count := l_tot_msg_count + 1;
                          l_msg_data := NULL;
      	               End Loop;
                       Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

         End If;
       END LOOP;
     END IF;

     -- END GCHADHA --

         l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                                       p_encoded   => fnd_api.g_false);
         WHILE l_msg_data IS NOT NULL
            LOOP
               IF x_msg_tbl.count=0 THEN
                 l_tot_msg_count:=1 ;
               ELSE
                 l_tot_msg_count := x_msg_tbl.count + 1;
               END IF;

                -- store the program results

               x_msg_tbl(l_tot_msg_count).status       := l_return_status;
               x_msg_tbl(l_tot_msg_count).description  := l_msg_data;

               l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_next,
                                             p_encoded   => fnd_api.g_false);
            END LOOP;

  END IF;
--new
  Exception
         When  G_EXCEPTION_HALT_VALIDATION Then
              x_return_status   :=   'E';
		      x_msg_data        := l_msg_data;
         When  Others Then
                      x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                      x_msg_data := l_msg_data;

--new

END Default_lines_to_sublines;


PROCEDURE Rollback_work IS
Begin
  Rollback;
End;
-- Bank Account Consolidation --

-- Added New Procedure Called to delete/ Create
-- Credit Card details
Procedure Delete_credit_Card
 (p_trnx_ext_id IN NUMBER,
  p_line_id  IN NUMBER,
  p_party_id IN NUMBER,
  p_cust_account_id IN NUMBER ,
  x_return_status  OUT NOCOPY VARCHAR2 ,
  x_msg_data OUT NOCOPY VARCHAR2) IS

 l_msg_count                Number;
 l_msg_data                 Varchar2(1000);
 l_return_status            Varchar2(1) := 'S';
 l_payer     IBY_FNDCPT_Common_Pub.PayerContext_rec_type;
 l_response IBY_FNDCPT_COMMON_PUB.Result_rec_type;

 l_api_name                 CONSTANT VARCHAR2(30) := 'Delete_credit_Card';

Begin

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
    END IF;

    l_payer.Payment_Function :='CUSTOMER_PAYMENT';
    l_payer.Party_Id := p_party_id;
    l_payer.cust_account_id := p_cust_account_id;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension.');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.payment_function: ' || l_payer.payment_function);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.party_id: ' || l_payer.party_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.cust_account_id: ' || l_payer.cust_account_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_trnx_ext_id: ' || p_trnx_ext_id);
    END IF;


    IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
           (
            p_api_version      => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_payer            => l_payer,
            --p_payer_equivalency=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD, bug 5439978
            p_payer_equivalency=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL,
            p_entity_id        => p_trnx_ext_id,
            x_response         => l_response
            );

  x_return_status :=l_return_status; --change

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished deleting transaction extension. l_return_status: '|| l_return_status);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| l_msg_data);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| l_msg_count);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
   END IF;


   Exception
   When  Others Then
     x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
     x_msg_data := l_msg_data;

 End Delete_Credit_Card;

Function Create_credit_Card
 (p_line_id IN NUMBER,
  p_party_id IN NUMBER,
  p_org IN NUMBER,
  p_account_site_id IN NUMBER,
  p_cust_account_id IN NUMBER,
  p_trnx_ext_id IN NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_data OUT NOCOPY VARCHAR2) RETURN NUMBER IS


  l_payer     IBY_FNDCPT_Common_Pub.PayerContext_rec_type;
  l_response  IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  l_trxn_attribs IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;




  l_instrument_id            NUMBER;
  l_msg_count                Number;
  l_msg_data                 Varchar2(1000);
  l_return_status            Varchar2(1) := 'S';
  l_entity_id                NUMBER;

  Cursor get_instru_assigned_csr(l_trnx_ext_ID IN NUMBER) IS
  SELECT instr_assignment_id
  FROM IBY_TRXN_EXTENSIONS_V
  WHERE TRXN_EXTENSION_ID = l_trnx_ext_id;

  get_instru_assigned_rec  get_instru_assigned_csr%ROWTYPE;

  l_api_name                 CONSTANT VARCHAR2(30) := 'Create_credit_Card';

Begin

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
    END IF;


    l_payer.payment_function := 'CUSTOMER_PAYMENT';
    l_payer.party_id :=  p_party_id; -- Id of the Lines Level bill to Party
    -- GCHADHA --
    -- 01-SEP-2005 --
    /*
    l_payer.org_type :=  'OPERATING_UNIT';
    l_payer.org_id :=  p_org; -- Organization Id
    l_payer.account_site_id := p_account_site_id; -- Bill to Location --
    */
    -- END GCHADHA --
    l_payer.cust_account_id:=p_cust_account_id; -- Cust Account Id --

    l_trxn_attribs.Originating_Application_Id := 515; --service contracts OKS
    l_trxn_attribs.Order_Id := p_line_id; -- line Id
    -- Bug 4866090 --
    l_trxn_attribs.trxn_ref_number1  := to_char(SYSDATE,'ddmmyyyyhhmmssss'); --to make order id and trx ref 1 unique
    -- Bug 4866090 --

    Open get_instru_assigned_csr(p_trnx_ext_id);
    FETCH get_instru_assigned_csr INTO  get_instru_assigned_rec;
    CLOSE get_instru_assigned_csr;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension.');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.payment_function: ' || l_payer.payment_function);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.party_id: ' || l_payer.party_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payer.cust_account_id: ' || l_payer.cust_account_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_trxn_attribs.Originating_Application_Id: ' || l_trxn_attribs.Originating_Application_Id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_trxn_attribs.Order_Id: ' || l_trxn_attribs.Order_Id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_trxn_attribs.trxn_ref_number1: ' || l_trxn_attribs.trxn_ref_number1);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'get_instru_assigned_rec.instr_assignment_id: ' || get_instru_assigned_rec.instr_assignment_id);
    END IF;


    -- Create Transaction Extension Id
    IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
      (
	  p_api_version => 1.0
         ,p_init_msg_list => FND_API.G_TRUE
         ,p_commit =>  FND_API.G_FALSE
         ,x_return_status => l_return_status
         ,x_msg_count   => l_msg_count
         ,x_msg_data    => l_msg_data
         ,p_payer       => l_payer
         --,p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD -- UPWARD
         ,p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL -- FULL, bug 5439978
         ,p_pmt_channel       => IBY_FNDCPT_SETUP_PUB.G_CHANNEL_CREDIT_CARD -- CREDIT_CARD
         ,p_instr_assignment  => get_instru_assigned_rec.instr_assignment_id
         ,p_trxn_attribs      => l_trxn_attribs
         ,x_entity_id         => l_entity_id -- transaction_extension_id
         ,x_response          => l_response
      );
      x_return_status := l_return_status;


      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished creating transaction extension. l_return_status: '|| l_return_status);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| l_msg_data);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| l_msg_count);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_entity_id: ' || l_entity_id);
      END IF;


  return(l_entity_id);
 Exception
 When  Others Then
   x_return_status   :=   OKC_API.G_RET_STS_UNEXP_ERROR;
   OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
   x_msg_data := l_msg_data;
End Create_Credit_Card;


-- Bank Account Consolidation --
END OKS_ATTR_DEFAULTS_PVT;

/
