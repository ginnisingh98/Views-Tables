--------------------------------------------------------
--  DDL for Package Body OKS_QPATTRIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QPATTRIB_PVT" AS
/* $Header: OKSRSQPB.pls 120.0 2005/05/25 18:07:38 appldev noship $ */

--  PROCEDURES /FUNCTIONS
--  QUALIFIER

FUNCTION GET_ACCOUNT_TYPE(p_chr_id IN NUMBER) RETURN QP_ATTR_MAPPING_PUB.T_MULTIRECORD
IS

   l_acc_type_tbl       QP_ATTR_MAPPING_PUB.T_MULTIRECORD;
   l_customer_id        Number;

BEGIN
/*
     Begin
      Select st.cust_account_id into l_customer_id
      From   hz_cust_site_uses_all  su,
             hz_cust_acct_sites_all st,
             okc_k_headers_b        kh
      Where  site_use_id = kh.BILL_TO_SITE_USE_ID     and
             su.cust_acct_site_id = st.cust_acct_site_id and
             kh.id = p_chr_id;
      Exception
      When Others Then
             l_customer_id := Null;
     End;
     Begin
      Select distinct customer_profile_class_id bulk collect into l_acc_type_tbl
      From   ar_customer_profiles
      Where  customer_id = l_customer_id;

      Return l_acc_type_tbl;
      Exception
      When Others Then
       Return l_acc_type_tbl;
     End;
*/
Null;
END GET_ACCOUNT_TYPE;

FUNCTION GET_AGREEMENT_NAME (p_chr_id IN NUMBER) RETURN VARCHAR2
IS
   l_agreement_name Varchar2(250);
BEGIN
   Null;
END GET_AGREEMENT_NAME;

FUNCTION GET_GSA (p_chr_id IN NUMBER) RETURN VARCHAR2
IS
   l_agreement_name Varchar2(250);
BEGIN
   Null;
END GET_GSA;


FUNCTION GET_PARTY_ID (p_chr_id IN NUMBER) RETURN NUMBER IS
 CURSOR l_party_csr Is select object1_id1 from okc_k_party_roles_b where chr_id = p_chr_id and rle_code = 'CUSTOMER';
 l_party_id Number  := Null;
BEGIN

 Open   l_party_csr;
 Fetch  l_party_csr Into l_party_id;
 Close  l_party_csr;
 Return l_party_id;

 Exception
 When Others Then
      Return Null;
END GET_PARTY_ID;


END OKS_QPATTRIB_PVT;

/
