--------------------------------------------------------
--  DDL for Package Body OKS_OKSCOBKS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_OKSCOBKS_XMLP_PKG" AS
/* $Header: OKSCOBKSB.pls 120.2 2007/12/25 07:56:23 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   apf boolean;
  BEGIN
    apf := AFTERPFORM;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    X_SALESREP VARCHAR2(800);
    X_ORG VARCHAR2(800);
    X_VALUE VARCHAR2(800);
    L_DEFAULT_ORDER_BY VARCHAR2(800);
    L_DEFAULT_ORDER_BY1 VARCHAR2(800);
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'srw_init')*/NULL;
    END;
    /*SRW.MESSAGE(15
               ,'After srw_init')*/NULL;
    IF P_ORG IS NULL AND FND_PROFILE.VALUE('OKC_VIEW_K_BY_ORG') = 'Y' THEN
      P_ORG := FND_PROFILE.VALUE('ORG_ID');
    END IF;
    IF P_ORG IS NOT NULL THEN
      X_ORG := ' and org.organization_id = :p_org';
      P_ORG_WHERE := X_ORG;
    END IF;
    IF P_SALESREP IS NOT NULL THEN
      P_SALESREP_CHAR := TO_CHAR(P_SALESREP);
      X_SALESREP := ' and contact.object1_id1 =  :p_salesrep_char';
      P_SALESREP_WHERE := X_SALESREP;
    END IF;
    IF P_VALUE IS NOT NULL THEN
      X_VALUE := ' and okc_hdr.estimated_amount > :p_value';
      P_VALUE_WHERE := X_VALUE;
    END IF;
    P_APPROVED_DATE_WHERE := ' ';
    IF P_DATE_FROM IS NOT NULL THEN
      P_APPROVED_DATE_WHERE := P_APPROVED_DATE_WHERE || ' and okc_hdr.date_approved  >= :p_date_from';
    END IF;
    IF P_DATE_TO IS NOT NULL THEN
      P_APPROVED_DATE_WHERE := P_APPROVED_DATE_WHERE || ' and okc_hdr.date_approved  <= ( (TRUNC(:p_date_to)+1) - (1/(24*60*60)) )';
    END IF;
    P_START_DATE_WHERE := ' ';
    IF P_START_DATE_FROM IS NOT NULL THEN
      P_START_DATE_WHERE := P_START_DATE_WHERE || ' and okc_hdr.start_date  >= :p_start_date_from';
    END IF;
    IF P_START_DATE_TO IS NOT NULL THEN
      P_START_DATE_WHERE := P_START_DATE_WHERE || ' and okc_hdr.start_date  <= ( (TRUNC(:p_start_date_to)+1) - (1/(24*60*60)) )';
    END IF;
    IF P_CONTRACT_GROUP IS NOT NULL THEN
      P_CONTRACT_GROUP_FROM := ' ,  ( select INCLUDED_CHR_ID
                                                                  from okc_k_grpings
                                                                  start with INCLUDED_CHR_ID IN
                                                                         ( select /*+ cardinality (b,1) */ id
                                                                           from okc_k_headers_b b
                                                                           where start_date between :P_START_DATE_FROM and :P_START_DATE_TO
                                                                           and scs_code in ( ''SERVICE'' , ''WARRANTY'' ) )
                                                                and CGP_PARENT_ID = :p_contract_group
                                                                connect by CGP_PARENT_ID = PRIOR INCLUDED_CGP_ID ) cgrp ';
      P_CONTRACT_GROUP_WHERE := ' and okc_hdr.ID = cgrp.included_chr_id ';
    END IF;
    L_DEFAULT_ORDER_BY := ' ORDER BY salesrep.name, okc_hdr.currency_code';
    L_DEFAULT_ORDER_BY1 := ' ORDER BY bill_txn.trx_number,bill_txn.trx_date, trx_amount';
    IF P_ORDER_BY = 'CUSTOMER NAME' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', hzp.party_name';
    ELSIF P_ORDER_BY = 'DATE APPROVED' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', okc_hdr.date_approved';
    ELSIF P_ORDER_BY = 'SERVICE CONTRACT' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', okc_hdr.contract_number,okc_hdr.contract_number_modifier';
    ELSIF P_ORDER_BY = 'MODIFIER' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', okc_hdr.contract_number_modifier';
    ELSIF P_ORDER_BY = 'CONTRACT VALUE' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', okc_hdr.estimated_amount';
    ELSIF P_ORDER_BY = 'START DATE' THEN
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ', okc_hdr.start_date';
    ELSIF P_ORDER_BY = 'INVOICE NUMBER' THEN
      P_ORDER_BY_ORDER1 := ' ORDER BY bill_txn.trx_number';
    ELSIF P_ORDER_BY = 'INVOICE DATE' THEN
      P_ORDER_BY_ORDER1 := ' ORDER BY bill_txn.trx_date';
    ELSIF P_ORDER_BY = 'INVOICE VALUE' THEN
      P_ORDER_BY_ORDER1 := 'ORDER BY trx_amount';
    ELSE
      P_ORDER_BY_ORDER := L_DEFAULT_ORDER_BY || ',hzp.party_name,okc_hdr.contract_number,okc_hdr.contract_number_modifier,' || 'okc_hdr.start_date,okc_hdr.date_approved,okc_hdr.estimated_amount ';
      P_ORDER_BY_ORDER1 := L_DEFAULT_ORDER_BY1;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'srw_exit')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

END OKS_OKSCOBKS_XMLP_PKG;


/
