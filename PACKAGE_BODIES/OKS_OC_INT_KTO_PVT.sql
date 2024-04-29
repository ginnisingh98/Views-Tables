--------------------------------------------------------
--  DDL for Package Body OKS_OC_INT_KTO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_OC_INT_KTO_PVT" AS
/* $Header: OKSRKTOB.pls 120.4 2007/12/24 07:25:32 rriyer ship $ */

G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME                   CONSTANT VARCHAR2(200) := 'OKS_OC_INT_KTO_PVT';
G_APP_NAME                   CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_APP_NAME1                  CONSTANT VARCHAR2(3)   := 'OKS';
G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
G_API_TYPE                   CONSTANT VARCHAR2(30)  := '_PROCESS';
G_SCOPE                      CONSTANT VARCHAR2(4)   := '_PVT';

-- other constants

g_okx_parties_v              CONSTANT VARCHAR2(30):= 'OKX_PARTIES_V';
g_rd_price                      CONSTANT VARCHAR2(30)  := 'PRE';
g_rd_shipmtd                    CONSTANT VARCHAR2(30)  := 'SMD';
--
g_qte_source_c                  CONSTANT VARCHAR2(30)  := 'CTRT_COPY';

--
-- global cursors
--
-- cursor for contract header information
--
CURSOR c_chr (p_chr_id NUMBER) IS
SELECT
      object_version_number
     ,authoring_org_id
     ,inv_organization_id
     ,contract_number
     ,contract_number_modifier
     ,currency_code
     ,estimated_amount
     ,date_renewed
     ,scs_code
     ,total_line_list_price
     ,price_list_id
FROM okc_k_headers_b
WHERE id = p_chr_id;

-- 4915691 --
-- Cursor for contract line information
--
CURSOR c_cle(p_cle_id NUMBER) IS SELECT
  object_version_number
FROM okc_k_lines_b
WHERE id = p_cle_id;
-- 4915691 --


CURSOR c_k_header(p_chr_id NUMBER) IS
SELECT
	   kh.ID                     ,
	   kh.SCS_CODE               ,
	   kh.CONTRACT_NUMBER        ,
	   kh.CURRENCY_CODE          ,
	   kh.CONTRACT_NUMBER_MODIFIER,
	   kh.TEMPLATE_YN            ,
	   kh.TEMPLATE_USED          ,
	   kh.CHR_TYPE               ,
	   kh.DATE_TERMINATED        ,
	   kh.DATE_RENEWED           ,
	   kh.START_DATE             ,
	   kh.END_DATE               ,
	   kh.AUTHORING_ORG_ID       ,
	   kh.INV_ORGANIZATION_ID    ,
	   kh.BUY_OR_SELL            ,
	   kh.ISSUE_OR_RECEIVE       ,
	   kh.ESTIMATED_AMOUNT       ,
	   ks.cls_code               ,
	   ks.meaning                ,
	   kst.ste_code
FROM       okc_statuses_b   kst,
           okc_k_headers_b  kh,
           okc_subclasses_v ks
WHERE      kh.id     = p_chr_id
AND        ks.code   = kh.scs_code
AND        kst.code  = kh.sts_code;

--
-- cursor to get customer information
-- header level customers only
-- the customer is the role in the sell contract that is not me
-- this assumption will not hold as more roles get added post 11i
-- IF for a party, this should be party id, not cust account id
--

CURSOR c_cust (b_chr_id NUMBER) IS
SELECT
      cpr.id
     ,cpr.jtot_object1_code
     ,cpr.object1_id1
     ,cpr.object1_id2
     ,cpr.rle_code
FROM okc_k_party_roles_b cpr
    ,okc_role_sources  rsc
WHERE
     rsc.buy_or_sell  = 'S'              -- sell contract
AND  rsc.rle_code     = cpr.rle_code     -- role
AND  rsc.start_date   <= sysdate
AND  NVL(rsc.end_date, sysdate) >= sysdate
AND  cpr.cle_id       IS NULL            -- parties
AND  cpr.dnz_chr_id   = b_chr_id;


TYPE line_info_rec_typ IS RECORD (
   line_id           okc_k_lines_v.id%TYPE
   ,cle_id            okc_k_lines_v.cle_id%TYPE
   ,lse_id            okc_k_lines_v.lse_id%TYPE
   ,line_number       okc_k_lines_v.line_number%TYPE
   ,status_code       okc_statuses_b.ste_code%TYPE
   ,qty               okc_k_items.number_of_items%TYPE
   ,uom_code          okc_k_items.uom_code%TYPE
   ,customer_order_enabled_flag VARCHAR2(1)
   ,item_name         okc_k_lines_v.name%TYPE
   ,priced_item_yn    okc_k_items.priced_item_yn%TYPE
   ,price_unit        okc_k_lines_v.price_unit%TYPE
   ,price_negotiated  okc_k_lines_v.price_negotiated%TYPE
   ,line_list_price   okc_k_lines_v.line_list_price%TYPE
   ,price_list_id      okc_k_lines_v.price_list_id%TYPE
   ,price_list_line_id okc_k_lines_v.price_list_line_id%TYPE
   ,currency_code     okc_k_lines_v.currency_code%TYPE
   ,start_date        okc_k_lines_v.start_date%TYPE
   ,end_date          okc_k_lines_v.end_date%TYPE
   ,k_item_id         okc_k_items.id%TYPE
   ,object_id1        okc_k_items.object1_id1%TYPE
   ,object_id2        okc_k_items.object1_id2%TYPE
   ,line_style        okc_line_styles_b.lse_type%TYPE
   ,line_type         okc_line_styles_b.lty_code%TYPE
   );

TYPE line_info_tab_typ IS TABLE OF line_info_rec_typ INDEX BY BINARY_INTEGER;

TYPE kh_attr_rec_type IS RECORD
  (
    chr_id                          okc_k_headers_b.id%TYPE
   ,CUST_ACCT_ID                    okc_k_headers_b.CUST_ACCT_ID%TYPE
   ,BILL_TO_SITE_USE_ID             okc_k_headers_b.BILL_TO_SITE_USE_ID%TYPE
   ,INV_RULE_ID                     okc_k_headers_b.INV_RULE_ID%TYPE
   ,SHIP_TO_SITE_USE_ID             okc_k_headers_b.SHIP_TO_SITE_USE_ID%TYPE
   ,CONVERSION_TYPE                 okc_k_headers_b.CONVERSION_TYPE%TYPE
   ,CONVERSION_RATE                 okc_k_headers_b.CONVERSION_RATE%TYPE
   ,CONVERSION_RATE_DATE            okc_k_headers_b.CONVERSION_RATE_DATE%TYPE
   ,CONVERSION_EURO_RATE            okc_k_headers_b.CONVERSION_EURO_RATE%TYPE
  );

TYPE kh_attr_tbl_type IS TABLE OF kh_attr_rec_type INDEX BY BINARY_INTEGER;
l_kh_attr_tab              kh_attr_tbl_type;


TYPE kl_attr_rec_type IS RECORD
  (
    CLE_ID                 okc_k_lines_b.cle_id%TYPE
   ,CUST_ACCT_ID           okc_k_lines_b.CUST_ACCT_ID%TYPE
   ,BILL_TO_SITE_USE_ID    okc_k_lines_b.BILL_TO_SITE_USE_ID%TYPE
   ,INV_RULE_ID            okc_k_lines_b.INV_RULE_ID%TYPE
   ,SHIP_TO_SITE_USE_ID    okc_k_lines_b.SHIP_TO_SITE_USE_ID%TYPE
   ,PRICE_LIST_ID          okc_k_lines_b.SHIP_TO_SITE_USE_ID%TYPE
  );

TYPE kl_attr_tbl_type IS TABLE OF kl_attr_rec_type INDEX BY BINARY_INTEGER;
  l_kl_attr_tab              kl_attr_tbl_type;

TYPE bto_sto_rec_typ IS RECORD
  (
  chr_id             okc_k_headers_b.id%TYPE,
  cle_id             okc_k_lines_b.id%TYPE,
  party_site_id      okx_cust_site_uses_v.party_site_id%TYPE,
  cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE,
  party_id           okx_cust_site_uses_v.party_id%TYPE,
  address1           HZ_LOCATIONS.address1%TYPE,
  address2           HZ_LOCATIONS.address2%TYPE,
  address3           HZ_LOCATIONS.address3%TYPE,
  address4           HZ_LOCATIONS.address4%TYPE,
  city               HZ_LOCATIONS.city%TYPE,
  postal_code        HZ_LOCATIONS.postal_code%TYPE,
  state              HZ_LOCATIONS.state%TYPE,
  province           HZ_LOCATIONS.province%TYPE,
  county             HZ_LOCATIONS.county%TYPE,
  country            HZ_LOCATIONS.country%TYPE);

TYPE l_k_bto_sto_data_tab_typ IS TABLE OF bto_sto_rec_typ INDEX BY BINARY_INTEGER;

--
-- Tables to hold bill to and ship to information at the header level
--

l_kh_bto_data_tab l_k_bto_sto_data_tab_typ;
l_kh_sto_data_tab l_k_bto_sto_data_tab_typ;

--
-- Tables to hold bill to and ship to information at the line level
--
l_kl_bto_data_tab l_k_bto_sto_data_tab_typ;
l_kl_sto_data_tab l_k_bto_sto_data_tab_typ;

--
-- global variables
--
l_chr                   c_chr%ROWTYPE;
-- Bug 4915691 --
l_cle           c_cle%ROWTYPE;
-- Bug 4915691 --
l_k_nbr                 VARCHAR2(2000);
l_line_info_tab         line_info_tab_typ;
l_order_type_id         varchar2(240):= nvl(fnd_profile.value('OKS_ORDER_TYPE_ID'), okc_api.g_miss_char);
l_cust                  c_cust%ROWTYPE;
l_customer              c_cust%ROWTYPE;

l_st_cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE;
l_st_party_site_id      okx_cust_site_uses_v.party_site_id%TYPE;
l_st_party_id           okx_cust_site_uses_v.party_id%TYPE;
l_bt_cust_acct_id       okx_cust_site_uses_v.cust_account_id%TYPE;
l_bt_party_site_id      okx_cust_site_uses_v.party_site_id%TYPE;
l_bt_party_id           okx_cust_site_uses_v.party_id%TYPE;

l_exchange_type         okc_conversion_attribs_v.conversion_type%TYPE;
l_exchange_rate         okc_conversion_attribs_v.conversion_rate%TYPE;
l_exchange_date         okc_conversion_attribs_v.conversion_date%TYPE;


--
-- private procedures
--

-------------------------------------------------------------------------------
-- Procedure:           print_error
-- Returns:
-- Purpose:             Print the last error which occured
-- In Parameters:       pos    position on the line to print the message
-- Out Parameters:

PROCEDURE print_error(pos IN NUMBER) IS
x_msg_count NUMBER;
x_msg_data  VARCHAR2(1000);
BEGIN
   IF okc_util.l_trace_flag OR okc_util.l_log_flag THEN
      FND_MSG_PUB.Count_And_Get ( p_count       =>      x_msg_count,
				     p_data          =>         x_msg_data
						  );
      FND_FILE.PUT_LINE( FND_FILE.LOG, '==EXCEPTION=================');
      x_msg_data := fnd_msg_pub.get( p_msg_index => x_msg_count,
				     p_encoded   => 'F'
				   );
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
      FND_FILE.PUT_LINE( FND_FILE.LOG, '============================');
   END IF;
END print_error;

Function is_jtf_source_table(  p_object_code    jtf_objects_b.object_code%type,
                                p_from_table    JTF_OBJECTS_B.from_table%type
                             )

return boolean is
cursor c_get_jtf_source_table(b_object_code varchar2,b_from_table varchar2) is
select 'x' from jtf_objects_b
where object_code = b_object_code
  and from_table like  b_from_table||'%';

l_found varchar2(1);

begin
open c_get_jtf_source_table(p_object_code,p_from_table);
fetch c_get_jtf_source_table into l_found;
If c_get_jtf_source_table%found then
   return true;
else
   return false;
end if;
 close c_get_jtf_source_table;

exception
when others then
if c_get_jtf_source_table%isopen then
      close c_get_jtf_source_table;
      return false;
end if;

end;

----------------------------------------------------------------------
-- Procedure:          build_k_attributes
-- Purpose:            building header and line level rules/attributes
--                     and bill to and ship to information
-- In Parameters:       p_chr_id        the contract id
--                      p_cle_id        line id
--                      p_renew_rec     contract information for renewal
-- Out Parameters:      x_return_status standard return status
--                      x_hdr_attr_tab  header level attributes
--                      x_line_attr_tab line level attributes
--                      x_bto_data_rec  BTO details
--                      x_sto_data_rec  STO details

---------------------------------------------------------------------

PROCEDURE build_k_attributes( p_chr_id 	 IN okc_k_headers_b.ID%TYPE,
			 p_cle_id 	 IN okc_k_lines_v.id%TYPE,
			 x_hdr_attr_tab	 OUT NOCOPY kh_attr_tbl_type,
                         x_line_attr_tab OUT NOCOPY kl_attr_tbl_type,
			 x_bto_data_rec  OUT NOCOPY bto_sto_rec_typ,
			 x_sto_data_rec  OUT NOCOPY bto_sto_rec_typ,
			 x_return_status OUT NOCOPY VARCHAR2 ) IS

--cursor for getting header rules/attribute

CURSOR c_header_attr(p_chr_id in NUMBER) IS
SELECT  ID
       ,CUST_ACCT_ID
       ,BILL_TO_SITE_USE_ID
       ,INV_RULE_ID
       ,SHIP_TO_SITE_USE_ID
       ,CONVERSION_TYPE
       ,CONVERSION_RATE
       ,CONVERSION_RATE_DATE
       ,CONVERSION_EURO_RATE
FROM   OKC_K_HEADERS_B
WHERE id = p_chr_id;

--cursor for getting line rules/attributes

CURSOR c_lines_attr(p_chr_id in NUMBER, p_cle_id in NUMBER) IS
SELECT
        CLE_ID
       ,CUST_ACCT_ID
       ,BILL_TO_SITE_USE_ID
       ,INV_RULE_ID
       ,SHIP_TO_SITE_USE_ID
       ,PRICE_LIST_ID
FROM   OKC_K_LINES_B
WHERE dnz_chr_id = p_chr_id
AND   id = p_cle_id;

-- get party site id for a customer account site id
--

CURSOR c_party_site (b_id1 NUMBER) IS
SELECT
         party_site_id
        ,cust_account_id
        ,party_id
        ,address1
        ,address2
        ,address3
        ,address4
        ,city
        ,state
        ,province
        ,postal_code
        ,county
        ,country
FROM    okx_cust_site_uses_v
WHERE   id1 = b_id1;
--
l_party_site	 c_party_site%ROWTYPE;
e_exit           EXCEPTION;
l_lines          NUMBER;
l_idx            INTEGER;
l_sto_data_rec	 bto_sto_rec_typ;
l_bto_data_rec	 bto_sto_rec_typ;
l_k_attr_tab_h   kh_attr_tbl_type;
l_k_attr_tab_l   kl_attr_tbl_type;

BEGIN

  l_sto_data_rec := NULL;
  l_bto_data_rec := NULL;
  l_k_attr_tab_h.delete;
  l_k_attr_tab_l.delete;

  l_st_party_id      := null;
  l_st_party_site_id := null;
  l_bt_party_id      := null;
  l_bt_party_site_id := null;
  --l_bt_cust_acct_id  := null;

  l_idx := 0;

--retrieving header data

 IF P_CLE_ID IS NULL Then
  FOR header_attr_rec IN c_header_attr(p_chr_id)
  LOOP

    IF header_attr_rec.SHIP_TO_SITE_USE_ID is NOT NULL THEN

         OPEN c_party_site(header_attr_rec.SHIP_TO_SITE_USE_ID);
         FETCH c_party_site INTO l_party_site;

	 IF c_party_site%FOUND THEN

	l_sto_data_rec.chr_id 		:= p_chr_id;
	l_sto_data_rec.party_site_id	:= l_party_site.party_site_id;
        l_sto_data_rec.cust_acct_id 	:= l_party_site.cust_account_id;
        l_sto_data_rec.party_id  	:= l_party_site.party_id;
        l_sto_data_rec.address1  	:= l_party_site.address1;
        l_sto_data_rec.address2  	:= l_party_site.address2;
        l_sto_data_rec.address3  	:= l_party_site.address3;
        l_sto_data_rec.address4  	:= l_party_site.address4;
        l_sto_data_rec.city       	:= l_party_site.city;
        l_sto_data_rec.state      	:= l_party_site.state;
        l_sto_data_rec.province   	:= l_party_site.province;
        l_sto_data_rec.postal_code	:= l_party_site.postal_code;
        l_sto_data_rec.county     	:= l_party_site.county;
        l_sto_data_rec.country    	:= l_party_site.country;
        l_st_party_site_id              := l_party_site.party_site_id;
        l_st_cust_acct_id               := l_party_site.cust_account_id;
        l_st_party_id                   := l_party_site.party_id;



		l_sto_data_rec.cle_id := p_cle_id;
	     END IF;
         CLOSE c_party_site;
    END IF;

    IF header_attr_rec.BILL_TO_SITE_USE_ID is NOT NULL THEN

       OPEN c_party_site(header_attr_rec.BILL_TO_SITE_USE_ID);
       FETCH c_party_site INTO l_party_site;

	 IF c_party_site%FOUND THEN
       l_bto_data_rec.chr_id 	     := p_chr_id;
	   l_bto_data_rec.party_site_id  := l_party_site.party_site_id;
       l_bto_data_rec.cust_acct_id   := l_party_site.cust_account_id;
       l_bto_data_rec.party_id	     := l_party_site.party_id;
       l_bt_party_site_id            := l_party_site.party_site_id;
       l_bt_cust_acct_id             := l_party_site.cust_account_id;
       l_bt_party_id                 := l_party_site.party_id;

		l_bto_data_rec.cle_id 	:= p_cle_id;


	  END IF;

      CLOSE c_party_site;

    END IF;

    l_idx := l_idx + 1;
    l_k_attr_tab_h(l_idx) := header_attr_rec;
  END LOOP;

    x_sto_data_rec := l_sto_data_rec;
    x_bto_data_rec := l_bto_data_rec;
    x_hdr_attr_tab   :=l_k_attr_tab_h;

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

ELSE

--retrieving lines attributes

 FOR lines_attr_rec IN c_lines_attr(p_chr_id, p_cle_id)
  LOOP

     IF lines_attr_rec.SHIP_TO_SITE_USE_ID is NOT NULL THEN

         OPEN c_party_site(lines_attr_rec.SHIP_TO_SITE_USE_ID);
         FETCH c_party_site INTO l_party_site;

	 IF c_party_site%FOUND THEN

        l_sto_data_rec.chr_id 		:= p_chr_id;
	    l_sto_data_rec.party_site_id:= l_party_site.party_site_id;
        l_sto_data_rec.cust_acct_id := l_party_site.cust_account_id;
        l_sto_data_rec.party_id  	:= l_party_site.party_id;
        l_sto_data_rec.address1  	:= l_party_site.address1;
        l_sto_data_rec.address2  	:= l_party_site.address2;
        l_sto_data_rec.address3  	:= l_party_site.address3;
        l_sto_data_rec.address4  	:= l_party_site.address4;
        l_sto_data_rec.city       	:= l_party_site.city;
        l_sto_data_rec.state      	:= l_party_site.state;
        l_sto_data_rec.province   	:= l_party_site.province;
        l_sto_data_rec.postal_code	:= l_party_site.postal_code;
        l_sto_data_rec.county     	:= l_party_site.county;
        l_sto_data_rec.country    	:= l_party_site.country;
        l_st_party_site_id          := l_party_site.party_site_id;
        l_st_cust_acct_id           := l_party_site.cust_account_id;
        l_st_party_id               := l_party_site.party_id;


		l_sto_data_rec.cle_id := p_cle_id;

	 END IF;
         CLOSE c_party_site;
    END IF;

    IF lines_attr_rec.BILL_TO_SITE_USE_ID IS NOT NULL THEN

      -- need to fix bill to, since ASO wants the party site, not customer acct site
    OPEN c_party_site(lines_attr_rec.BILL_TO_SITE_USE_ID);
    FETCH c_party_site INTO l_party_site;

     IF c_party_site%FOUND THEN
	 l_bto_data_rec.chr_id 	      := p_chr_id;
     l_bto_data_rec.party_site_id := l_party_site.party_site_id;
   	 l_bto_data_rec.cust_acct_id  := l_party_site.cust_account_id;
   	 l_bto_data_rec.party_id	  := l_party_site.party_id;
     l_bt_party_site_id           := l_party_site.party_site_id;
     l_bt_cust_acct_id            := l_party_site.cust_account_id;
     l_bt_party_id                := l_party_site.party_id;
	 l_bto_data_rec.cle_id 	      := p_cle_id;


      END IF;

     CLOSE c_party_site;

    END IF;

    l_idx := l_idx + 1;
    --l_k_rule_tab(l_idx) := r_rule;
    l_k_attr_tab_l(l_idx) := lines_attr_rec;
  END LOOP;

    x_sto_data_rec := l_sto_data_rec;
    x_bto_data_rec := l_bto_data_rec;
   -- x_rule_tab	   := l_k_rule_tab;
    x_line_attr_tab   :=l_k_attr_tab_l;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

   END IF;---------p_CLE_ID IS NULL

EXCEPTION
  WHEN e_exit THEN
     IF c_party_site%ISOPEN THEN
        CLOSE c_party_site;
     END IF;



END build_k_attributes;
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Procedure:           validate_k_eligibility
-- Purpose:             Check up on specific conditions to ensure the contract
--                      is elligible for a order creation
-- In Parameters:       p_chr_id        the contract id
--                      p_k_header_rec  contract information
--                      p_renew_rec     contract information for renewal
-- Out Parameters:      x_return_status standard return status
---------------------------------------------------------------------

PROCEDURE validate_k_eligibility(
                 p_chr_id         IN  okc_k_headers_b.ID%TYPE
				 ,p_k_header_rec  IN  c_k_header%ROWTYPE
				 ,x_return_status OUT NOCOPY VARCHAR2
				 ) IS

l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count      NUMBER := 0;
l_msg_data       VARCHAR2(1000);
l_ord_num        NUMBER:= OKC_API.G_MISS_NUM;
e_exit		 EXCEPTION;

BEGIN

-- To Check If this contract has been created from Order.If yes then return an Error

  --l_order_type_id:=nvl(fnd_profile.value('OKS_ORDER_TYPE_ID'), okc_api.g_miss_char);
  IF l_order_type_id = okc_api.g_miss_char THEN
     OKC_API.set_message(p_app_name      => g_app_name,
			 p_msg_name      => 'OKS_K2O_ORDTYP',
			 p_token1        => 'PROFOPT',
			 p_token1_value  => 'OKS:Default Order Type for Subscriptions',
			 p_token2        => 'NUMBER',
			 p_token2_value  => p_k_header_rec.contract_number);
     x_return_status := okc_api.g_ret_sts_error;
	print_error(3);
     RAISE e_exit;
  END IF;

  x_return_status  := OKC_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN e_exit THEN

	OKC_API.set_message(G_APP_NAME,
			   G_UNEXPECTED_ERROR,
			   G_SQLCODE_TOKEN,
			   SQLCODE,
			   G_SQLERRM_TOKEN,
			   SQLERRM);

    	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_k_eligibility;

-------------------------------------------------------------------------------
-- Procedure:           build_k_structures
-- Purpose:             Build several records/tables that hold information to be
--                      used to pass to OC APIs
-- In Parameters:       p_chr_id            the contract id
-- Out Parameters:      x_return_status     standard return status
-----------------------------------------------------------------------------

PROCEDURE build_k_structures (p_chr_id         IN  okc_k_headers_b.ID%TYPE
                              ,p_cle_id        IN okc_k_lines_b.id%TYPE
  	                      ,p_k_header_rec  IN c_k_header%ROWTYPE
	                      ,x_return_status OUT NOCOPY VARCHAR2
	                      ) IS

--cursor for getting line level details

CURSOR c_top_cle(b_chr_id NUMBER,
		b_line_id NUMBER) IS
SELECT
  cle.id          	line_id
  ,cle.cle_id      	cle_id
  ,cle.lse_id		lse_id
  ,cle.line_number 	line_number
  ,sts.ste_code
  ,cim.number_of_items qty
  ,cim.uom_code
  ,'Y'                 customer_order_enabled_flag
  ,cle.name            item_name
  ,cim.priced_item_yn
  ,cle.price_unit
  ,'0' price_negotiated
  ,cle.line_list_price
  ,cle.price_list_id
  ,cle.price_list_line_id
  ,cle.currency_code
  ,cle.start_date
  ,cle.end_date
  ,cim.id cim_id
  ,cim.object1_id1 object1_id1
  ,cim.object1_id2 object1_id2
  ,lse.lse_type         line_style
  ,lse.lty_code         line_type
FROM
	okc_k_lines_v		cle,
	okc_k_items		    cim,
	okc_line_styles_b 	lse,
	okc_statuses_b		sts
WHERE
	cim.cle_id = cle.id
AND	lse.id = cle.lse_id
AND	sts.code = cle.sts_code
AND	cle.dnz_chr_id = b_chr_id
AND	cle.id = b_line_id;

e_exit              exception;
l_idx                binary_integer;
l_svc_duration      NUMBER;
l_svc_period        Varchar2(100);
l_party             NUMBER;
l_lines             NUMBER;
l_item_name         VARCHAR2(150);
l_customer_order_enabled_flag VARCHAR2(1);
r_cle               line_info_rec_typ;
lx_return_status    VARCHAR2(1);
lx_index            NUMBER;
x_msg_count         NUMBER;
x_msg_data          VARCHAR2(1000);
l_customer_account_id NUMBER  := NULL;
l_count		        NUMBER;
l_party_id          NUMBER;
l_inventory_item_id    NUMBER;
l_organization_id       NUMBEr;

lx_kh_attr_tab         kh_attr_tbl_type;
lx_kl_attr_tab         kl_attr_tbl_type;

lx_kh_bto_data_rec      bto_sto_rec_typ;
lx_kh_sto_data_rec      bto_sto_rec_typ;

lx_kl_bto_data_rec      bto_sto_rec_typ;
lx_kl_sto_data_rec      bto_sto_rec_typ;



BEGIN

  l_line_info_tab.delete;

  l_party:=0;

  l_kh_attr_tab.delete   ;
  l_kl_attr_tab.delete   ;

  l_kh_sto_data_tab.delete;
  l_kh_bto_data_tab.delete;

  l_kl_sto_data_tab.delete;
  l_kl_bto_data_tab.delete;

  l_line_info_tab.delete;

  FOR  l_cust IN c_cust(p_chr_id)
  LOOP
     IF is_jtf_source_table(l_cust.jtot_object1_code,g_okx_parties_v)  THEN
           l_party:=l_party+1;
           l_customer:=l_cust;
     END IF;
  END LOOP;


/************ get header level rules************************/


  build_k_attributes(p_chr_id        => p_chr_id,
                     p_cle_id        => NULL,
                     x_hdr_attr_tab  => lx_kh_attr_tab,
                     x_line_attr_tab => lx_kl_attr_tab,
                     x_bto_data_rec  => lx_kh_bto_data_rec,
                     x_sto_data_rec  => lx_kh_sto_data_rec,
                     x_return_status => lx_return_status );

  IF lx_return_status = OKC_API.G_RET_STS_SUCCESS THEN


   IF lx_kh_attr_tab.FIRST IS NOT NULL THEN
          l_kh_attr_tab := lx_kh_attr_tab;
   END IF;

   IF lx_kh_bto_data_rec.chr_id IS NOT NULL THEN
    l_kh_bto_data_tab(l_kh_bto_data_tab.COUNT+1):=lx_kh_bto_data_rec;
   END IF;

   IF lx_kh_sto_data_rec.chr_id IS NOT NULL THEN
    l_kh_sto_data_tab(l_kh_sto_data_tab.COUNT+1):=lx_kh_sto_data_rec;
   END IF;

  ELSE
          raise e_exit;
 END IF;

/**************Get all the top lines in detail****************/


  l_lines := 0;
  l_idx := 0;

    OPEN c_top_cle(p_chr_id, p_cle_id);
    FETCH c_top_cle INTO r_cle;

    IF c_top_cle%NOTFOUND THEN
       OKC_API.set_message(
		      p_app_name      => g_app_name1,
		      p_msg_name      => 'OKS_K2O_LINENOTORDBL5',
		      p_token1        => 'LINE_NUM',
		      p_token1_value  => r_cle.line_number,
		      p_token2        => 'NUMBER',
		      p_token2_value  => l_k_nbr);
       print_error(2);
       RAISE e_exit;
    END IF;

    l_item_name                   :=r_cle.item_name;
    l_customer_order_enabled_flag := r_cle.customer_order_enabled_flag;

    l_lines:=l_lines+1;

    l_idx := l_idx + 1;

    l_line_info_tab(l_idx) := r_cle;
 /*************************************************************/

FND_FILE.PUT_LINE( FND_FILE.LOG,'inventory_item_id ='|| r_cle.object_id1);

/*************************************************************/
 select description into l_item_name
 from okx_system_items_v
 where id1=r_cle.object_id1
 and id2 = r_cle.object_id2;

        l_line_info_tab(l_idx).object_id1:=r_cle.object_id1;
-----   l_line_info_tab(l_idx).object_id2:=l_organization_id ;

      l_line_info_tab(l_idx).item_name := l_item_name;
      l_line_info_tab(l_idx).customer_order_enabled_flag := l_customer_order_enabled_flag;
      l_svc_duration := r_cle.qty;
      l_svc_period   := r_cle.uom_code;

        -- duration is quantity AND period uom for service line
      l_line_info_tab(l_idx).qty      := rtrim(ltrim(l_svc_duration));
      l_line_info_tab(l_idx).uom_code := rtrim(ltrim(l_svc_period));

      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Order Details for Top Line No = '||r_cle.line_number ||' '||'Item Name='||l_item_name);
      FND_FILE.PUT_LINE( FND_FILE.OUTPUT, 'Order Details for Top Line No = '||r_cle.line_number||' '||'Item Name='||l_item_name);


--
--	Check and populate the top lines rules table
--

        build_k_attributes( p_chr_id    => p_chr_id,
                        p_cle_id        => l_line_info_tab(l_idx).line_id,
                        x_hdr_attr_tab 	=> lx_kh_attr_tab,
                        x_line_attr_tab => lx_kl_attr_tab,
                        x_bto_data_rec  => lx_kl_bto_data_rec,
                        x_sto_data_rec  => lx_kl_sto_data_rec,
                        x_return_status => lx_return_status );
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'After top lines build rules return status = '||lx_return_status);

    IF lx_return_status = OKC_API.G_RET_STS_SUCCESS THEN
     IF lx_kl_attr_tab.FIRST IS NOT NULL THEN
	   FOR i IN lx_kl_attr_tab.FIRST..lx_kl_attr_tab.LAST LOOP
        l_kl_attr_tab(l_kl_attr_tab.COUNT+1) := lx_kl_attr_tab(i);
	   END LOOP;
     END IF;


  	 IF lx_kl_bto_data_rec.cle_id IS NOT NULL THEN
        l_kl_bto_data_tab(l_kl_bto_data_tab.COUNT+1) := lx_kl_bto_data_rec;
     END IF;

   	 IF lx_kl_sto_data_rec.cle_id IS NOT NULL THEN
        l_kl_sto_data_tab(l_kl_sto_data_tab.COUNT+1) := lx_kl_sto_data_rec;
     END IF;

    ELSE
          raise e_exit;
    END IF;

     CLOSE c_top_cle;

  IF l_lines = 0 THEN
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO LINES');
    okc_api.set_message(OKC_API.G_APP_NAME,
				    'OKS_K2O_NOLINES',
				    'KNUMBER',
				    l_k_nbr);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);
    RAISE e_exit;
  END IF;
  IF l_idx = 0 THEN
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO ORDERABLE LINES');

    FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO orderable lines');
    okc_api.set_message(OKC_API.G_APP_NAME,
				    'OKS_K2O_NOORDLINES',
				    'KNUMBER',
				    l_k_nbr);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);
    RAISE e_exit;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN e_exit THEN

      IF c_cust%ISOPEN THEN
        CLOSE c_cust;
       END IF;

       IF c_top_cle%ISOPEN THEN
		 CLOSE c_top_cle;
	   END IF;
       WHEN OTHERS THEN

        OKC_API.set_message
         (G_APP_NAME,
         G_UNEXPECTED_ERROR,
         G_SQLCODE_TOKEN,
         SQLCODE,
         G_SQLERRM_TOKEN,
         SQLERRM);

        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END build_k_structures;

-------------------------------------------------------------------------------
-- Procedure:           build_order_hdr
-- Purpose:             Build the order header record to pass to the ASO/OM APIs
-- In Parameters:
-- Out Parameters:
-- In/Out Parameters:   px_qte_hdr_rec - the record to pass to ASO
------------------------------------------------------------------------------

PROCEDURE build_order_hdr
          (px_qte_hdr_rec      IN OUT NOCOPY aso_quote_pub.qte_header_rec_type
	   ,p_contract_id       IN     NUMBER
	   ,px_hd_shipment_tbl  IN OUT NOCOPY aso_quote_pub.shipment_tbl_type
	   ,x_return_status     OUT NOCOPY    VARCHAR2
		   ) IS

      e_exit          exception;                -- used to exit processing
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(1000);


BEGIN

  px_qte_hdr_rec.org_id             := l_chr.authoring_org_id;
  px_qte_hdr_rec.currency_code      := l_chr.currency_code;
  px_qte_hdr_rec.quote_source_code  := g_qte_source_c;
  px_qte_hdr_rec.order_type_id      := l_order_type_id;

  okc_api.set_message(OKC_API.G_APP_NAME, 'OKC_K2Q_KCOPY', 'NUMBER', l_k_nbr);

  FND_MSG_PUB.Count_And_Get (
			 p_count =>      l_msg_count,
			 p_data  =>      l_msg_data);

  px_qte_hdr_rec.quote_name := Substr( fnd_msg_pub.get( p_msg_index =>
   l_msg_count, p_encoded   => 'F'),1,50);

      FND_MSG_PUB.Delete_Msg ( p_msg_index       =>      l_msg_count);


  px_qte_hdr_rec.quote_version               := 1;
  px_qte_hdr_rec.party_id                    := l_cust.object1_id1;
  px_qte_hdr_rec.original_system_reference   := l_k_nbr;


  FND_FILE.PUT_LINE( FND_FILE.LOG, 'After order header salescredit');

IF l_kh_attr_tab.first IS NOT NULL THEN
    FOR i IN l_kh_attr_tab.first..l_kh_attr_tab.last LOOP
      IF l_kh_attr_tab(i).CUST_ACCT_ID IS NOT NULL  THEN

        px_qte_hdr_rec.cust_account_id := l_kh_attr_tab(i).CUST_ACCT_ID;
     /* ELSIF l_kh_attr_tab(i).rule_information_category = g_rd_price THEN

        px_qte_hdr_rec.price_list_id := l_kh_rule_tab(i).object1_id1;*/

      ELSIF l_kh_attr_tab(i).INV_RULE_ID IS NOT NULL  THEN

        px_qte_hdr_rec.invoicing_rule_id := l_kh_attr_tab(i).INV_RULE_ID;

      END IF;
    END LOOP;
  END IF;

IF l_kh_bto_data_tab.FIRST IS NOT NULL THEN
  FOR i IN l_kh_bto_data_tab.FIRST..l_kh_bto_data_tab.LAST LOOP

  px_qte_hdr_rec.invoice_to_party_site_id := l_kh_bto_data_tab(i).party_site_id;
  px_qte_hdr_rec.invoice_to_party_id      := NVL(l_kh_bto_data_tab(i).party_id,l_cust.object1_id1);
  -- Bug 4915691 --
  px_qte_hdr_rec.INVOICE_TO_CUST_ACCOUNT_ID := l_kh_bto_data_tab(i).cust_acct_id;
  px_qte_hdr_rec.cust_account_id            := l_kh_bto_data_tab(i).cust_acct_id;
  -- Bug 4915691 --

 END LOOP;
END IF;

-- Populate the shipment record
--
FND_FILE.PUT_LINE( FND_FILE.LOG, 'before populating order header shipmentrecords = ');
IF l_kh_sto_data_tab.FIRST IS NOT NULL THEN
 FOR i IN l_kh_sto_data_tab.FIRST..l_kh_sto_data_tab.LAST LOOP

  px_hd_shipment_tbl(i).ship_to_party_id := NVL(l_kh_sto_data_tab(i).party_id,l_cust.object1_id1);
  px_hd_shipment_tbl(i).ship_to_party_site_id := l_kh_sto_data_tab(i).party_site_id;
  px_hd_shipment_tbl(i).ship_to_cust_account_id := l_kh_sto_data_tab(i).cust_acct_id;
  px_hd_shipment_tbl(i).ship_to_address1        := l_kh_sto_data_tab(i).address1;
  px_hd_shipment_tbl(i).ship_to_address2        := l_kh_sto_data_tab(i).address2;
  px_hd_shipment_tbl(i).ship_to_address3        := l_kh_sto_data_tab(i).address3;
  px_hd_shipment_tbl(i).ship_to_address4        := l_kh_sto_data_tab(i).address4;
  px_hd_shipment_tbl(i).ship_to_city            := l_kh_sto_data_tab(i).city;
  px_hd_shipment_tbl(i).ship_to_state           := l_kh_sto_data_tab(i).state;
  px_hd_shipment_tbl(i).ship_to_province        := l_kh_sto_data_tab(i).province;
  px_hd_shipment_tbl(i).ship_to_postal_code     := l_kh_sto_data_tab(i).postal_code;
  px_hd_shipment_tbl(i).ship_to_county          := l_kh_sto_data_tab(i).county;
  px_hd_shipment_tbl(i).ship_to_country         := l_kh_sto_data_tab(i).country;

   /* FOR j IN l_kh_rule_tab.FIRST..l_kh_rule_tab.LAST LOOP
      IF l_kh_rule_tab(j).rule_information_category = g_rd_shipmtd THEN
          px_hd_shipment_tbl(i).ship_method_code := l_kh_rule_tab(j).rule_information1;
       END IF;
    END LOOP;
   */
 END LOOP;
END IF;

  --
  -- set exchange information
  --
  px_qte_hdr_rec.exchange_type_code := l_exchange_type;
  px_qte_hdr_rec.exchange_rate      := l_exchange_rate;
  px_qte_hdr_rec.exchange_rate_date := l_exchange_date;

  --
  -- check IF we got customer account, set IF not
  --
  IF px_qte_hdr_rec.cust_account_id IS NULL
   	OR px_qte_hdr_rec.cust_account_id = okc_api.g_miss_num THEN

    px_qte_hdr_rec.cust_account_id := l_bt_cust_acct_id;
    --px_qte_hdr_rec.cust_account_id := 3347;
  END IF;

  OPEN c_chr(p_contract_id);
  FETCH c_chr INTO l_chr;
  IF c_chr%FOUND THEN

     px_qte_hdr_rec.total_list_price      := l_chr.total_line_list_price;
     px_qte_hdr_rec.total_adjusted_amount := l_chr.total_line_list_price - l_chr.estimated_amount;

     px_qte_hdr_rec.price_list_id         := l_chr.price_list_id;

  END IF;
  CLOSE c_chr;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN e_exit THEN
        null;
  WHEN OTHERS THEN
    OKC_API.set_message(
    G_APP_NAME,
    G_UNEXPECTED_ERROR,
    G_SQLCODE_TOKEN,
    SQLCODE,
    G_SQLERRM_TOKEN,
    SQLERRM);

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END build_ORDER_HDR;

-------------------------------------------------------------------------------
-- Procedure:           build_order_line
-- Purpose:             Build the order line record to pass to the ASO/OM APIs
-- In Parameters:
-- Out Parameters:
-- In/Out Parameters:   px_qte_hdr_rec - the record to pass to ASO
------------------------------------------------------------------------------


PROCEDURE build_order_line
  (
   px_qte_line_tbl      IN  OUT NOCOPY aso_quote_pub.qte_line_tbl_type
  ,px_qte_hdr_rec      IN aso_quote_pub.qte_header_rec_type
  ,px_qte_ln_shipment_tbl IN  OUT NOCOPY aso_quote_pub.shipment_tbl_type
  ,px_qte_line_dtl_tbl  IN  OUT NOCOPY aso_quote_pub.qte_line_dtl_tbl_type
  ,px_k2q_line_tbl  IN  OUT NOCOPY okc_oc_int_config_pvt.line_rel_tab_type
  ,x_return_status      OUT  NOCOPY VARCHAR2
    ) IS

   l_ql                 binary_integer;
   i                    binary_integer;
   j                    binary_integer;
   k                    binary_integer;
   l_nb_qte_line_dtl    NUMBER;
   l_cur_tl             NUMBER;
   l_k2q_found	        VARCHAR2(1) := 'N';
   e_exit	        	EXCEPTION;
   l_return_status      VARCHAR2(1);


BEGIN

   l_ql := 0;


  IF l_line_info_tab.first is not NULL THEN

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'in build order lines ');
   FOR i IN l_line_info_tab.first..l_line_info_tab.last LOOP

   l_ql:=l_ql+1;
   px_qte_line_tbl(l_ql).operation_code := g_aso_op_code_create;
   px_qte_line_tbl(l_ql).quote_header_id:= px_qte_hdr_rec.quote_header_id;
   px_qte_line_tbl(l_ql).line_number    := l_ql;


	 --Order Management constraint:
	 --Need to populate p_line_shipment_tbl in addition of p_qte_line_tbl
	 --to create order lines
	 --Order line = (Quote line, Shipment line)
	 --

  px_qte_ln_shipment_tbl(l_ql).qte_line_index  := l_ql;
  px_qte_ln_shipment_tbl(l_ql).quantity        := l_line_info_tab(i).qty;
  px_qte_line_tbl(l_ql).org_id           := l_chr.authoring_org_id;
  px_qte_line_tbl(l_ql).inventory_item_id:= to_number(l_line_info_tab(i).object_id1);
-- px_qte_line_tbl(l_ql).organization_id  := to_number(l_line_info_tab(i).object_id2);
  px_qte_line_tbl(l_ql).organization_id  := l_chr.authoring_org_id;
  px_qte_line_tbl(l_ql).quantity         := l_line_info_tab(i).qty;
  px_qte_line_tbl(l_ql).uom_code         := l_line_info_tab(i).uom_code;
  px_qte_line_tbl(l_ql).start_date_active:= l_line_info_tab(i).end_date + 1;
  px_qte_line_tbl(l_ql).currency_code    := l_line_info_tab(i).currency_code;


-- Obtain the top line rules
 IF l_kl_attr_tab.COUNT > 0 then
  	FOR k IN l_kl_attr_tab.FIRST..l_kl_attr_tab.LAST LOOP

     IF l_kl_attr_tab(k).cle_id = l_line_info_tab(i).line_id THEN

 	  IF l_kl_attr_tab(k).price_list_id IS NOT NULL  THEN
	   px_qte_line_tbl(l_ql).price_list_id := NVL(l_kl_attr_tab(k).price_list_id,px_qte_hdr_rec.price_list_id);
	  ELSIF l_kl_attr_tab(k).inv_rule_id IS NOT NULL THEN

	  px_qte_line_tbl(l_ql).invoicing_rule_id := NVL(l_kl_attr_tab(k).inv_rule_id,px_qte_hdr_rec.invoicing_rule_id);

		  /* ELSIF l_kl_attr_tab(k).rule_information_category = g_rd_shipmtd THEN
	         	px_qte_ln_shipment_tbl(l_ql).ship_method_code := l_kl_rule_tab(k).rule_information1;
             */
  	  END IF;

           px_qte_line_tbl(l_ql).price_list_id := px_qte_hdr_rec.price_list_id;

	   END IF;
	  END LOOP;
  ELSE
  	px_qte_line_tbl(l_ql).price_list_id := px_qte_hdr_rec.price_list_id;
    px_qte_line_tbl(l_ql).invoicing_rule_id := px_qte_hdr_rec.invoicing_rule_id;

  END IF;

--
-- obtain the bill to rule
--
    IF l_kl_bto_data_tab.FIRST IS NOT NULL THEN
	    FOR k IN l_kl_bto_data_tab.FIRST..l_kl_bto_data_tab.LAST LOOP
	      IF l_kl_bto_data_tab(k).cle_id = l_line_info_tab(i).line_id THEN

		    px_qte_line_tbl(l_ql).invoice_to_party_site_id := NVL(l_kl_bto_data_tab(k).party_site_id,px_qte_hdr_rec.invoice_to_party_site_id);
		    px_qte_line_tbl(l_ql).invoice_to_party_id 	:= NVL(l_kl_bto_data_tab(k).party_id,px_qte_hdr_rec.invoice_to_party_id);
		    -- Bug 4915691 --
		    px_qte_line_tbl(l_ql).INVOICE_TO_CUST_ACCOUNT_ID := NVL(l_kl_bto_data_tab(k).cust_acct_id,px_qte_hdr_rec.invoice_to_party_id);
		    -- Bug 4915691 --
	     END IF;
       END LOOP;
     END IF;

FND_FILE.PUT_LINE( FND_FILE.LOG, 'Before order line shipment = ');
--
-- obtain the ship to rule and the operation code
--
  IF l_kl_sto_data_tab.COUNT > 0 THEN
   FOR k IN l_kl_sto_data_tab.FIRST..l_kl_sto_data_tab.LAST LOOP
   IF l_kl_sto_data_tab(k).cle_id = l_line_info_tab(i).line_id THEN

	px_qte_ln_shipment_tbl(l_ql).ship_to_party_site_id := l_kl_sto_data_tab(k).party_site_id;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_cust_account_id := l_kl_sto_data_tab(k).cust_acct_id;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_party_id   := NVL(l_kl_sto_data_tab(k).party_id,l_cust.object1_id1);
  	px_qte_ln_shipment_tbl(l_ql).ship_to_address1   := l_kl_sto_data_tab(k).address1;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_address2   := l_kl_sto_data_tab(k).address2;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_address3   := l_kl_sto_data_tab(k).address3;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_address4   := l_kl_sto_data_tab(k).address4;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_city       := l_kl_sto_data_tab(k).city;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_state      := l_kl_sto_data_tab(k).state;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_province   := l_kl_sto_data_tab(k).province;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_postal_code:= l_kl_sto_data_tab(k).postal_code;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_county     := l_kl_sto_data_tab(k).county;
  	px_qte_ln_shipment_tbl(l_ql).ship_to_country    := l_kl_sto_data_tab(k).country;
	   END IF;
      END LOOP;
     END IF;

   l_cur_tl:=i;


    px_qte_line_tbl(l_ql).line_list_price := 0;
    px_qte_line_tbl(l_ql).line_quote_price := ROUND(l_line_info_tab(l_cur_tl).price_negotiated / l_line_info_tab(l_cur_tl).qty, 2);


/* px_qte_line_tbl(l_ql).price_list_id := l_line_info_tab(l_cur_tl).price_list_id;
px_qte_line_tbl(l_ql).price_list_line_id := l_line_info_tab(l_cur_tl).price_list_line_id;
*/
            --
            -- record relation in the px_k2q_line_tbl PL/SQL table
            --

    px_k2q_line_tbl(l_ql).k_line_id   := l_line_info_tab(l_cur_tl).line_id;
    px_k2q_line_tbl(l_ql).q_line_idx  := l_ql;


   END LOOP;
  END IF;


 IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

 print_error(3);
 RAISE e_exit;

 END IF;


  IF l_ql = 0 THEN
    okc_api.set_message(OKC_API.G_APP_NAME,
				    'OKS_K2O_NOORDLINES2',
				    'NUMBER',
				    l_chr.contract_number);
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(4);

  ELSE
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
  END IF;

  IF px_qte_line_tbl.first IS NOT NULL THEN
    FOR i IN px_qte_line_tbl.first..px_qte_line_tbl.last LOOP

       IF px_qte_line_dtl_tbl.first IS NOT NULL THEN
		l_nb_qte_line_dtl:=0;
	  FOR j IN px_qte_line_dtl_tbl.first..px_qte_line_dtl_tbl.last LOOP
		 IF px_qte_line_dtl_tbl(j).qte_line_index = px_qte_line_tbl(i).line_number THEN
		   l_nb_qte_line_dtl:=l_nb_qte_line_dtl + 1;

		   END IF;
	     END LOOP;
		IF l_nb_qte_line_dtl = 0 THEN
	       FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO Order Detail Lines');
		END IF;
       ELSE
       null;
       END IF;


       IF px_k2q_line_tbl.EXISTS(i) THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Order Item type code    = '||px_k2q_line_tbl(i).q_item_type_code);
       END IF;
       FND_FILE.PUT_LINE( FND_FILE.LOG, '                         ');

    END LOOP;    --  qteline
  ELSE
     FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO Order Lines');
  END IF;
EXCEPTION
  WHEN e_exit THEN
        null;
  WHEN OTHERS THEN
    OKC_API.set_message
     (G_APP_NAME,
     G_UNEXPECTED_ERROR,
     G_SQLCODE_TOKEN,
     SQLCODE,
     G_SQLERRM_TOKEN,
     SQLERRM);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END build_order_line;


--
-- public procedures
--
-------------------------------------------------------------------------------
-- Procedure:       create_order_from_k
-- Version:         1.0
-- Purpose:         Create an order from a contract by populating quote
--                  input records from a contract as the initial
--                  stage.
--                  Create Relationships from ordering contract to order
--                  May also create subject-to relationship from order
--                  to master contract if ordering contract is subject
--                  to a master contract
--                  Calls ASO_ORDER_PUB.CREATE_ORDER to create the order
-- In Parameters:   p_contract_id   Contract for which to create order
-- Out Parameters:  x_order_id      Id of created order
-----------------------------------------------------------------------------
PROCEDURE create_order_from_k(
               p_api_version     IN NUMBER
	      ,p_init_msg_list   IN VARCHAR2 DEFAULT OKC_API.G_FALSE
	      ,x_return_status   OUT NOCOPY VARCHAR2
	      ,x_msg_count       OUT NOCOPY NUMBER
	      ,x_msg_data        OUT NOCOPY VARCHAR2
	      ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
              ,p_default_date    IN DATE  DEFAULT OKC_API.G_MISS_DATE
              ,P_Customer_id     IN NUMBER
              ,P_Grp_id          IN NUMBER
              ,P_org_id          IN  NUMBER
	      ,P_contract_hdr_id_lo in NUMBER
              ,P_contract_hdr_id_hi in NUMBER
	      -- Bug 4915691 --
	      ,P_contract_line_id_lo in NUMBER
              ,P_contract_line_id_hi in NUMBER
              -- Bug 4915691 --
	      ,x_order_id        OUT NOCOPY okx_order_headers_v.id1%TYPE
		)
	      IS

-- Standard api variables


l_api_version           CONSTANT NUMBER := 1;
l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_O_FROM_K';
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(1000);

-- Miscellaneous variables
l_idx                   BINARY_INTEGER;  -- generic table index
l_ord_creation_message  VARCHAR2(1000);
l_aso_api_versiOn       CONSTANT NUMBER := 1;
l_init_msg_count        NUMBER;
k			NUMBER;
l_create_order_flag     VARCHAR2(10);
--
l_k_header_rec          c_k_header%ROWTYPE;
l_chrv_rec              okc_contract_pub.chrv_rec_type;
-- Bug 4915691 --
l_clev_rec              okc_contract_pub.clev_rec_type;

-- Bug 4915691 --
l_k2q_line_rel_tab      okc_oc_int_config_pvt.line_rel_tab_type;  -- keeps track of k line to q line relation

-- Variables for calling create_order
l_qte_header_rec               ASO_QUOTE_PUB.Qte_Header_Rec_Type;
l_Header_Payment_Tbl           ASO_QUOTE_PUB.Payment_Tbl_Type;
l_quote_hd_Price_Adj_Tab       ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
l_quote_hd_price_attr_tab      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_qte_hd_price_adj_rltship_tab ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
l_quote_hd_price_adj_attr_tab  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_quote_hd_shipment_tab        ASO_QUOTE_PUB.shipment_tbl_type;
l_Header_Shipment_Tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_Header_TAX_DETAIL_Tbl        ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type;
l_Header_FREIGHT_CHARGE_Tbl    ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type;
l_quote_line_tab               ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
l_qte_line_dtl_tab             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_Line_Payment_Tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
l_quote_ln_price_adj_tab       ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
l_quote_Ln_Price_Attr_Tab      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_qte_ln_price_adj_rltship_tab ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
l_quote_ln_price_adj_attr_tab  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_quote_ln_Shipment_Tab        ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_Line_TAX_DETAIL_Tbl          ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type;
l_Line_FREIGHT_CHARGE_Tbl      ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type;
l_Line_ATTRIBS_EXT_Tbl         ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
l_Line_Rltship_Tbl             ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
l_line_rltship_tab             ASO_QUOTE_PUB.line_rltship_tbl_type;
x_line_rltship_tab             ASO_QUOTE_PUB.line_rltship_tbl_type;
--
l_Control_Rec                  ASO_ORDER_INT.Control_Rec_Type ;
l_Line_sales_credit_TBL        ASO_ORDER_INT.Sales_credit_tbl_type;
l_Lot_Serial_Tbl               ASO_QUOTE_PUB.Lot_Serial_Tbl_Type;
l_header_attribs_ext_tbl       ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
l_header_quote_party_tbl       ASO_QUOTE_PUB.quote_party_tbl_type;
l_line_quote_party_tbl         ASO_QUOTE_PUB.quote_party_tbl_type;
lx_order_header_rec            ASO_ORDER_INT.Order_Header_Rec_Type;
lx_order_line_tbl              ASO_ORDER_INT.Order_Line_Tbl_type;
l_header_sales_credit_TBL      ASO_ORDER_INT.Sales_credit_tbl_type;
lx_clev_tbl                    okc_cle_pvt.clev_tbl_type;

l_order_hd_sales_credit_tab    ASO_QUOTE_PUB.sales_credit_tbl_type;
l_order_ln_sales_credit_tab    ASO_QUOTE_PUB.sales_credit_tbl_type;

--
l_ord_creation_date            oe_order_headers_all.creation_date%TYPE;
l_ord_num                      oe_order_headers_all.order_number%TYPE;
l_ord_version_number           oe_order_headers_all.version_number%TYPE;
l_ord_expiration_date          oe_order_headers_all.expiration_date%TYPE;
l_kto_found                    varchar2(1);
l_elements_found               varchar2(1):='N';

---cursor for getting the subscription details
 cursor get_header_id(p_contract_id IN NUMBEr) is
  select
  hdr.id,
  hdr.contract_number
  from
  okc_k_headers_b hdr,
  okc_k_party_roles_b pr
  where hdr.id = nvl(p_contract_id ,hdr.id)
   and   hdr.id between nvl(nvl(p_contract_id,p_contract_hdr_id_lo),hdr.id)
   and   nvl(nvl(p_contract_id,p_contract_hdr_id_hi),hdr.id)
   And    pr.chr_id      =  hdr.id
  And    pr.rle_code    = 'SUBSCRIBER'
  And    pr.object1_id1 = nvl(p_customer_id,pr.object1_id1)
  And    Hdr.authoring_org_id = NVL(p_org_id, Hdr.authoring_org_id)
  AND    hdr.sts_code <> 'QA_HOLD'
  And    exists (Select 'x' from OKC_K_GRPINGS  okg
                       Where  okg.included_chr_id = hdr.id
                       And    okg.cgp_parent_id = nvl(p_grp_id,okg.cgp_parent_id) );

/* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
 /* cursor get_elements(p_contract_id IN NUMBEr) is
  select sub.id,
  sub.dnz_chr_id,
  sub.dnz_cle_id,
  sub.start_date,
  sub.end_date,
  sub.om_interface_date
  from   oks_subscr_elements sub ,
         okc_k_lines_b line,
         okc_statuses_b sts
   where sub.dnz_chr_id = nvl(p_contract_id ,sub.dnz_chr_id)
   and   sub.dnz_chr_id between nvl(nvl(p_contract_id,p_contract_hdr_id_lo),sub.dnz_chr_id)
   and   nvl(nvl(p_contract_id,p_contract_hdr_id_hi),sub.dnz_chr_id)
  and sub.order_header_id  is null
  and sub.om_interface_date <= nvl(p_default_date,sysdate)
  and sub.dnz_cle_id = line.id
  and line.lse_id = 46
  and line.sts_code = sts.code
  and sts.ste_code IN('ACTIVE','SIGNED','EXPIRED','TERMINATED')
   -- Bug 4915691 --
  and   line.id between nvl(p_contract_line_id_lo,line.id)
  and   nvl(p_contract_line_id_hi,line.id);
    -- Bug 4915691 -- */
/* Modified by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
 cursor get_elements is
  select sub.id,
  sub.dnz_chr_id,
  sub.dnz_cle_id,
  sub.start_date,
  sub.end_date,
  sub.om_interface_date,
  hdr.contract_number
  from   oks_subscr_elements sub,
         okc_k_headers_b hdr,
         okc_k_party_roles_b pr,
         okc_statuses_b st
   where sub.dnz_chr_id = nvl(p_contract_id ,sub.dnz_chr_id)
--==   and   sub.dnz_chr_id between nvl(nvl(p_contract_id,p_contract_hdr_id_lo),sub.dnz_chr_id)
--==   and   nvl(nvl(p_contract_id,p_contract_hdr_id_hi),sub.dnz_chr_id)
  and hdr.id = sub.dnz_chr_id
  and pr.chr_id = hdr.id
  and pr.rle_code = 'SUBSCRIBER'
  and st.code = hdr.sts_code
  And    pr.object1_id1 = nvl(p_customer_id,pr.object1_id1)
  And    Hdr.authoring_org_id = NVL(p_org_id, Hdr.authoring_org_id)
  And    exists (Select 'x' from OKC_K_GRPINGS  okg
                       Where  okg.included_chr_id = hdr.id
                       And    okg.cgp_parent_id = nvl(p_grp_id,okg.cgp_parent_id) )
  and sub.order_header_id  is null
  and sub.om_interface_date <= nvl(p_default_date,sysdate)
  and st.ste_code in ('ACTIVE','SIGNED')
   -- Bug 4915674 --
  and   sub.dnz_cle_id between nvl(p_contract_line_id_lo,sub.dnz_cle_id)
  and   nvl(p_contract_line_id_hi,sub.dnz_cle_id);
    -- Bug 4915674 --
  /* Modification Ends */

  get_elements_rec  get_elements%rowtype;
  get_header_id_rec get_header_id%rowtype;

BEGIN

        l_quote_line_tab.DELETE;
        l_qte_line_dtl_tab.DELETE;

        l_quote_hd_shipment_tab.DELETE;
        l_quote_ln_shipment_tab.DELETE;

        l_k2q_line_rel_tab.DELETE;
        l_line_rltship_tab.DELETE;
        x_line_rltship_tab.DELETE;

        l_order_hd_sales_credit_tab.DELETE;
        l_order_ln_sales_credit_tab.DELETE;

        l_header_sales_credit_tbl.DELETE;
        l_line_sales_credit_tbl.DELETE;

        l_quote_hd_price_adj_tab.DELETE;
        l_quote_ln_price_adj_tab.DELETE;

        l_quote_hd_price_adj_attr_tab.DELETE;
        l_quote_ln_price_adj_attr_tab.DELETE;

        l_qte_hd_price_adj_rltship_tab.DELETE;
        l_qte_ln_price_adj_rltship_tab.DELETE;

        l_quote_hd_price_attr_tab.DELETE;
        l_quote_ln_price_attr_tab.DELETE;


  l_init_msg_count:=fnd_msg_pub.count_msg;
 --FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Number = '||l_chr.contract_number);
  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************Subscription Contract to Order Creation****************** ');

FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract id = '||p_contract_id);
FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract id lo = '||p_contract_hdr_id_lo);
FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract id high= '||p_contract_hdr_id_hi);
-- Bug 4915691 --
-- FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Lines Details ');
-- FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Line id lo = '||p_contract_line_id_lo);
-- FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Line id high = '||p_contract_line_id_hi);
-- Bug 4915691 --


  --
  -- fetch the contract
 --
 /* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
 /* FOR get_header_id_rec IN get_header_id(p_contract_id)
 LOOP
 FOR get_elements_rec IN get_elements(get_header_id_rec.id) */
 /* Modified by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
 FOR get_elements_rec IN get_elements
  LOOP
   l_elements_found:='Y';

  OPEN c_chr(get_elements_rec.dnz_chr_id);
  FETCH c_chr INTO l_chr;
  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '************************ ');
  FND_FILE.PUT_LINE( FND_FILE.LOG, '************************ ');
  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, 'Contract Number = '||l_chr.contract_number);
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Contract Number = '||l_chr.contract_number);
  IF c_chr%NOTFOUND THEN
    okc_api.set_message(OKC_API.G_APP_NAME,'OKS_K2O_NOKHDR');
    CLOSE c_chr;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    print_error(2);
    CLOSE c_chr;
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE c_chr;

  -- might need this for error messages
  IF l_chr.contract_number_modifier IS NOT NULL THEN
    l_k_nbr := l_chr.contract_number||'-'||l_chr.contract_number_modifier;
  ELSE
    l_k_nbr := l_chr.contract_number;
  END IF;

  -- Bug 4915691 --
  -- lock the contract
  -- - to avoid a concurrent access to the contract for update, renewal...
  -- - to update contract comments
  --

  l_chrv_rec.id :=get_elements_rec.dnz_chr_id;
  l_chrv_rec.object_version_number := l_chr.object_version_number;

  OPEN c_cle(get_elements_rec.dnz_cle_id);
  FETCH c_cle INTO l_cle;
  close c_cle;
  l_clev_rec.id := get_elements_rec.dnz_cle_id;
  l_clev_rec.object_version_number := l_cle.object_version_number;

  /*
  okc_contract_pub.lock_contract_header (
	p_api_version   => 1,
	p_init_msg_list => OKC_API.G_FALSE,
	x_return_status => l_return_status,
	x_msg_count     => l_msg_count,
	x_msg_data      => l_msg_data,
	p_chrv_rec      => l_chrv_rec);

  */
  okc_contract_pub.lock_contract_line (
	p_api_version   => 1,
	p_init_msg_list => OKC_API.G_FALSE,
	x_return_status => l_return_status,
	x_msg_count     => l_msg_count,
	x_msg_data      => l_msg_data,
	p_clev_rec      => l_clev_rec);

  -- Bug 4915691 --

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
     l_return_status = OKC_API.G_RET_STS_ERROR THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			   p_msg_name      => 'OKS_K2O_KLOCKED',
			   p_token1        => 'NUMBER',
			   p_token1_value  => l_k_nbr);
       print_error(2);
  END IF; -- IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;


 /*************** set organization context***************************/
/*
  IF p_contract_id IS NULL THEN
     OKC_API.set_message(p_app_name      => g_app_name,
			 p_msg_name      => 'OKS_K2O_KIDISNULL');
	print_error(2);
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;
*/
  okc_context.set_okc_org_context(p_chr_id => get_elements_rec.dnz_chr_id);
/******************************************************************/

FND_FILE.PUT_LINE( FND_FILE.LOG, 'before header cursor');
  OPEN c_k_header(get_elements_rec.dnz_chr_id);
  FETCH c_k_header INTO l_k_header_rec;
  CLOSE c_k_header;


FND_FILE.PUT_LINE( FND_FILE.LOG, 'before validate_k_eligibility');

   validate_k_eligibility(get_elements_rec.dnz_chr_id,
			         --     p_rel_type,
                          l_k_header_rec,
		                  l_return_status );


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
/******************************************************************/
  --
  -- get the contract information
  --
FND_FILE.PUT_LINE( FND_FILE.LOG, 'before build_k_structures');

  build_k_structures(p_chr_id => get_elements_rec.dnz_chr_id,
                     p_cle_id => get_elements_rec.dnz_cle_id,
                     p_k_header_rec => l_k_header_rec,
	                 x_return_status => l_return_status );

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

/******************************************************************/

  --
  -- populate Order header record
  --
FND_FILE.PUT_LINE( FND_FILE.LOG, 'before build_order_hdr');
  build_order_hdr(px_qte_hdr_rec      => l_qte_header_rec,
		          p_contract_id       => get_elements_rec.dnz_chr_id,
		          px_hd_shipment_tbl  => l_quote_hd_shipment_tab,
		          x_return_status     => l_return_status);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

/******************************************************************/
  --
  -- populate Order lines table, line details
  --

FND_FILE.PUT_LINE( FND_FILE.LOG, 'before build_order_line');
  build_order_line(px_qte_line_tbl        => l_quote_line_tab
		          ,px_qte_hdr_rec         => l_qte_header_rec
		          ,px_qte_ln_shipment_tbl => l_quote_ln_shipment_tab
		          ,px_qte_line_dtl_tbl    => l_qte_line_dtl_tab
		          ,px_k2q_line_tbl        => l_k2q_line_rel_tab
		          ,x_return_status        => l_return_status );


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  l_line_rltship_tab := x_line_rltship_tab;
/******************************************************************/
  --
  -- set control record, need to set additional attributes
  --

  l_control_rec.book_flag := FND_API.G_FALSE;


   fnd_profile.put('UNIQUE:SEQ_NUMBERS','A');
   FND_FILE.PUT_LINE( FND_FILE.LOG, 'before create order');

    ASO_ORDER_INT.Create_order(
          P_Api_Version                   => l_aso_api_version,
          P_Init_Msg_List                 => P_Init_Msg_List,
          p_Control_Rec                   => l_control_rec,
          P_Commit                        => FND_API.G_FALSE,
          p_Qte_Rec                       => l_Qte_Header_Rec,
          p_Header_Payment_Tbl            => l_Header_Payment_Tbl,
          p_Header_Price_Adj_Tbl          => l_quote_hd_price_adj_tab,
          p_Header_Price_Attributes_Tbl   => l_quote_hd_price_attr_tab,
          p_Header_Price_Adj_rltship_Tbl  => l_qte_hd_Price_Adj_rltship_Tab,
          p_Header_Price_Adj_Attr_Tbl     => l_quote_hd_Price_Adj_Attr_Tab,
          p_Header_Shipment_Tbl           => l_quote_hd_Shipment_Tab,
          p_Header_TAX_DETAIL_Tbl         => l_Header_TAX_DETAIL_Tbl,
          p_Header_FREIGHT_CHARGE_Tbl     => l_Header_FREIGHT_CHARGE_Tbl,
          p_Header_sales_credit_TBL       => l_order_hd_sales_credit_tab,
          P_Header_ATTRIBS_EXT_Tbl        => l_header_attribs_ext_tbl,
          P_Header_Quote_Party_Tbl        => l_header_quote_party_tbl,
          p_Qte_Line_Tbl                  => l_quote_line_tab,
          p_Qte_Line_Dtl_Tbl              => l_qte_line_dtl_tab,
          p_Line_Payment_Tbl              => l_Line_Payment_Tbl,
          p_Line_Price_Adj_Tbl            => l_quote_ln_Price_Adj_Tab,
          p_Line_Price_Attributes_Tbl     => l_quote_ln_Price_Attr_Tab,
          p_Line_Price_Adj_rltship_Tbl    => l_qte_ln_Price_Adj_rltship_Tab,
          p_Line_Price_Adj_Attr_Tbl       => l_quote_ln_Price_Adj_Attr_Tab,
          p_Line_Shipment_Tbl             => l_quote_ln_Shipment_Tab,
          p_Line_TAX_DETAIL_Tbl           => l_Line_TAX_DETAIL_Tbl,
          p_Line_FREIGHT_CHARGE_Tbl       => l_Line_FREIGHT_CHARGE_Tbl,
          P_LINE_ATTRIBS_EXT_TBL          => l_Line_ATTRIBS_EXT_Tbl,
          p_Line_Rltship_Tbl              => l_Line_Rltship_Tab,
          P_Line_sales_credit_TBL         => l_order_ln_sales_credit_tab,
          P_Line_Quote_Party_Tbl          => l_line_quote_party_tbl,
          P_Lot_Serial_Tbl                => l_Lot_Serial_Tbl,
          X_Order_Header_Rec              => lx_order_header_rec,
          X_Order_Line_Tbl                => lx_order_line_tbl,
          X_Return_Status                 => l_return_status,
          X_Msg_Count                     => l_msg_count,
          X_Msg_Data                      => l_msg_data);

 IF l_return_status<>'S' Then
   l_create_order_flag:='N';
 END IF;

 FND_FILE.PUT_LINE( FND_FILE.LOG, '****************************************** '); FND_FILE.PUT_LINE( FND_FILE.LOG, '********************Order Number = '||lx_order_header_rec.order_number);
 FND_FILE.PUT_LINE( FND_FILE.LOG,'order create  return status = '||l_return_status);
FND_FILE.PUT_LINE( FND_FILE.LOG, '****************************************** ');

  IF lx_order_line_tbl.first IS NOT NULL THEN
    FOR i IN lx_order_line_tbl.first..lx_order_line_tbl.last LOOP

        update oks_subscr_elements
        set  order_header_id = lx_order_line_tbl(i).order_header_id
        ,order_line_id = lx_order_line_tbl(i).order_line_id
        where id= get_elements_rec.id;

fnd_file.put_line(FND_FILE.LOG, 'Order Header Id = '||lx_order_line_tbl(i).order_header_id);
fnd_file.put_line(FND_FILE.LOG, 'Order Line Id   = '||lx_order_line_tbl(i).order_line_id);
fnd_file.put_line(FND_FILE.LOG, 'Order line status = '||ltrim(rtrim(lx_order_line_tbl(i).status)));

FND_FILE.PUT_LINE( FND_FILE.LOG, 'Before calling OE_ORDER_BOOK_UTIL ');

  OE_Order_Book_Util.Complete_Book_Eligible
                        ( p_api_version_number  => 1.0
                        , p_init_msg_list               => okc_api.g_false
                        , p_header_id                   => lx_order_line_tbl(i).order_header_id
                        , x_return_status               => l_return_status
                        , x_msg_count                   => l_msg_count
                        , x_msg_data                    => l_msg_data);
 IF  l_return_status ='S' THen
FND_FILE.PUT_LINE( FND_FILE.LOG,'Schedule Start Date = '||get_elements_rec.start_date||' '||'Schedule End Date = '||get_elements_rec.end_date);
FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'Schedule Start Date = '||get_elements_rec.start_date||' '||'Schedule End Date = '||get_elements_rec.end_date||' '|| 'OM Interface Date = '||get_elements_rec.om_interface_date);
FND_FILE.PUT_LINE( FND_FILE.LOG, 'Order Number = '||lx_order_header_rec.order_number);
FND_FILE.PUT_LINE( FND_FILE.OUTPUT, 'Order Number = '||lx_order_header_rec.order_number);
    FND_FILE.PUT_LINE( FND_FILE.LOG,'order book return status = '||l_return_status);
  FND_FILE.PUT_LINE( FND_FILE.OUTPUT,'order book return status = '||l_return_status);
FND_FILE.PUT_LINE( FND_FILE.LOG, '****************************************** ');FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************************************** ');
ELSE

    FND_FILE.PUT_LINE( FND_FILE.LOG,'order book return status = '||l_return_status);
FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************************************** ');
FND_FILE.PUT_LINE( FND_FILE.OUTPUT, 'Unable to CREATE and BOOK the order, please check the log files for error details');
FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '***************************************** ');
END IF;
/*
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
*/

    END LOOP ;

  ELSE
	FND_FILE.PUT_LINE( FND_FILE.LOG, 'NO Order Lines');
  END IF;

  --
  -- Contract updating with order information waiting for
  -- a specific notification creation
  --

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
     l_return_status = OKC_API.G_RET_STS_ERROR THEN
        FND_FILE.PUT_LINE( FND_FILE.LOG,l_msg_data);
	l_ord_creation_date:=SYSDATE;
  ELSE

     SELECT creation_date,
		  order_number,
		  version_number,
		  NVL(expiration_date, OKC_API.G_MISS_DATE)
	INTO l_ord_creation_date,
		l_ord_num,
		l_ord_version_number,
		l_ord_expiration_date
	FROM oe_order_headers_all
	WHERE header_id = lx_order_header_rec.order_header_id;

     OKC_API.set_message(p_app_name      => g_app_name,
			 p_msg_name      => 'OKS_K2O_K2OCOMMENTS',
			 p_token1        => 'CRDATE',
			 p_token1_value  => l_ord_creation_date,
			 p_token2        => 'NUMBER',
			 p_token2_value  => l_ord_num,
			 p_token3        => 'VERSION',
			 p_token3_value  => l_ord_version_number,
			 p_token4        => 'EXDATE',
			 p_token4_value  => l_ord_expiration_date,
			 p_token5        => 'TRACEFILE',
			 p_token5_value  => okc_util.l_complete_trace_file_name2
				    );
     FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
     x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	  p_encoded   => 'F');

	l_ord_creation_message := x_msg_data;
     FND_MSG_PUB.Delete_Msg ( p_msg_index       =>      x_msg_count);

  END IF; -- IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    -- RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     --RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
			     ,p_procedure_name => l_api_name
			     ,p_error_text     => 'Encountered error condition'
			     );
    END IF;

    --Error messages for the trace file
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			p_msg_name      => 'OKS_K2O_K2OOUTEMSG',
			p_token1        => 'CRDATE',
			p_token1_value  => l_ord_creation_date,
			p_token2        => 'KNUMBER',
			p_token2_value  => l_chr.contract_number,
			p_token3        => 'KMODIFIER',
			p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
			    );
       FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
        x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	    p_encoded   => 'F');

       l_ord_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

       okc_util.print_output(0, l_ord_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
       IF x_msg_data IS NOT NULL THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
	     FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
		IF okc_util.l_output_flag THEN
	     okc_util.print_output(0, 'Message      : '||x_msg_data);
		okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');


--    IF l_create_order_flag='N' THEN
     EXIT;
 --   END IF;



  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     --RAISE OKC_API.G_EXCEPTION_ERROR;
     --RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
			     ,p_procedure_name => l_api_name
			     ,p_error_text     => 'Encountered error condition'
			     );
    END IF;

    --Error messages for the trace file
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			p_msg_name      => 'OKS_K2O_K2OOUTEMSG',
			p_token1        => 'CRDATE',
			p_token1_value  => l_ord_creation_date,
			p_token2        => 'KNUMBER',
			p_token2_value  => l_chr.contract_number,
			p_token3        => 'KMODIFIER',
			p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
			    );
       FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
        x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	    p_encoded   => 'F');

       l_ord_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

       okc_util.print_output(0, l_ord_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
       IF x_msg_data IS NOT NULL THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
	     FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
		IF okc_util.l_output_flag THEN
	     okc_util.print_output(0, 'Message      : '||x_msg_data);
		okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');


  --  IF l_create_order_flag='N' THEN
     EXIT;
   -- END IF;



  END IF;

  --
  -- capture the order id for the return
  --

  x_order_id := lx_order_header_rec.order_header_id;

  --
  -- we're done
  --

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  -- In the output file (If conc. prog.)
  IF okc_util.l_output_flag THEN
     OKC_API.set_message(p_app_name      => g_app_name,
			 p_msg_name      => 'OKS_K2O_K2OOUTSMSG',
			 p_token1        => 'CRDATE',
			 p_token1_value  => l_ord_creation_date,
			 p_token2        => 'ONUMBER',
			 p_token2_value  => l_ord_num,
			 p_token3        => 'VERSION',
			 p_token3_value  => l_ord_version_number,
			 p_token4        => 'EXDATE',
			 p_token4_value  => l_ord_expiration_date,
			 p_token5        => 'KNUMBER',
			 p_token5_value  => l_chr.contract_number,
			 p_token6        => 'KMODIFIER',
			 p_token6_value  => NVL(l_chr.contract_number_modifier, ' ')
				    );
     FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);

      x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	    p_encoded   => 'F');

	l_ord_creation_message := x_msg_data;
     FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

     okc_util.print_output(0, l_ord_creation_message);
     FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
     FOR k in l_init_msg_count..x_msg_count LOOP
	x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
	IF x_msg_data IS NOT NULL THEN
	   okc_util.print_output(0, 'Message      : '||x_msg_data);
	      okc_util.print_output(0, ' ');
	END IF;
     END LOOP;
  END IF;

  l_contract_number:=l_chr.contract_number;
  l_contract_number_modifier:=l_chr.contract_number_modifier;
  l_order_number:=lx_order_header_rec.order_number;

 END LOOP; -----------get_elements cursor
   IF
     l_elements_found='N' Then
       /* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
       /* fnd_file.put_line(FND_FILE.LOG, 'No subscription elements to be interfaced  for the given Contract number'||'  '||get_header_id_rec.contract_number);
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, 'No subscription elements to be interfaced for the given Contract number'||'  '||get_header_id_rec.contract_number); */

       /* Modified by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
       fnd_file.put_line(FND_FILE.LOG, 'No subscription elements to be interfaced  ');
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, 'No subscription elements to be interfaced ');

   END IF;
 /* Commented by sjanakir for Bug# 5568285 (FP Bug for 5442268) */
 /* END LOOP; -----------get_header_id cursor */
 /* Comment Ends */
/*
   iF
     l_elements_found='N' Then
       fnd_file.put_line(FND_FILE.LOG, 'No subscription elements for the given Contract number');
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, '                            ');
       fnd_file.put_line(FND_FILE.OUTPUT, 'No subscription elements for the given Contract number');

   END IF;
*/
EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    --update_k_comments_err;
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
			     ,p_procedure_name => l_api_name
			     ,p_error_text     => 'Encountered error condition'
			     );
    END IF;

    --Error messages for the trace file
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			p_msg_name      => 'OKS_K2O_K2OOUTEMSG',
			p_token1        => 'CRDATE',
			p_token1_value  => l_ord_creation_date,
			p_token2        => 'KNUMBER',
			p_token2_value  => l_chr.contract_number,
			p_token3        => 'KMODIFIER',
			p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
			    );
       FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
        x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	    p_encoded   => 'F');

       l_ord_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

       okc_util.print_output(0, l_ord_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
       IF x_msg_data IS NOT NULL THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
	     FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
		IF okc_util.l_output_flag THEN
	     okc_util.print_output(0, 'Message      : '||x_msg_data);
		okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
       fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
			     ,p_procedure_name => l_api_name
			     ,p_error_text     => 'Encountered unexpected error'
			     );
    END IF;

    --Error messages for the trace file
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error while creating order:');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Return status: '||x_return_status);
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			p_msg_name      => 'OKS_K2O_K2OOUTEMSG',
			p_token1        => 'CRDATE',
			p_token1_value  => l_ord_creation_date,
			p_token2        => 'KNUMBER',
			p_token2_value  => l_chr.contract_number,
			p_token3        => 'KMODIFIER',
			p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
			    );
       FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
       x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	  p_encoded   => 'F');

       l_ord_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

       okc_util.print_output(0, l_ord_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
       IF x_msg_data IS NOT NULL THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
	     FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
		IF okc_util.l_output_flag THEN
	     okc_util.print_output(0, 'Message      : '||x_msg_data);
		okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;

  WHEN OTHERS THEN
    --update_k_comments_err;
    IF c_k_header%ISOPEN THEN
	     CLOSE c_k_header;
    END IF;

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME
		       ,G_UNEXPECTED_ERROR
		       ,G_SQLCODE_TOKEN
		       ,SQLCODE
		       ,G_SQLERRM_TOKEN
		       ,SQLERRM);

    --Error messages for the trace file
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error while creating order:');
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Return status: '||x_return_status);
    FND_FILE.PUT_LINE( FND_FILE.LOG, '==================================');
    --Error messages for the output file
    IF okc_util.l_output_flag THEN
       OKC_API.set_message(p_app_name      => g_app_name,
			p_msg_name      => 'OKS_K2O_K2OOUTEMSG',
			p_token1        => 'CRDATE',
			p_token1_value  => l_ord_creation_date,
			p_token2        => 'KNUMBER',
			p_token2_value  => l_chr.contract_number,
			p_token3        => 'KMODIFIER',
			p_token3_value  => NVL(l_chr.contract_number_modifier, ' ')
			    );
       FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
       x_msg_data := fnd_msg_pub.get(
		p_msg_index => x_msg_count,
	  p_encoded   => 'F');

       l_ord_creation_message := x_msg_data;
       FND_MSG_PUB.Delete_Msg ( p_msg_index     =>      x_msg_count);

       okc_util.print_output(0, l_ord_creation_message);
    END IF;
    FND_MSG_PUB.Count_And_Get (
		p_count =>      x_msg_count,
		p_data  =>      x_msg_data);
    FOR k in l_init_msg_count..x_msg_count LOOP
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
				      p_encoded   => 'F'
				     );
       IF x_msg_data IS NOT NULL THEN
	  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Message      : '||x_msg_data);
	     FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
		IF okc_util.l_output_flag THEN
	     okc_util.print_output(0, 'Message      : '||x_msg_data);
		okc_util.print_output(0, ' ');
		END IF;
       END IF;
    END LOOP;

END create_order_from_k;


END OKS_OC_INT_KTO_PVT;

/
