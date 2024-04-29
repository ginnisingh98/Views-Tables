--------------------------------------------------------
--  DDL for Package Body ONT_OEXORDTP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXORDTP_XMLP_PKG" AS
/* $Header: OEXORDTPB.pls 120.2 2008/01/04 09:32:40 nchinnam noship $ */

function BEFOREREPORT return boolean
is
begin
DECLARE
BEGIN
BEGIN
/*SRW.USER_EXIT('FND SRWINIT');*/
null;
/* EXCEPTION WHEN USER_EXIT_FAILURE SRW.USER_EXIT_FAILURE THEN */
/*SRW.MESSAGE(1000, 'FAILED IN BEFORE REPORT TRIGGER');*/
null;
END;
DECLARE l_org_name VARCHAR2(100);
BEGIN SELECT sob.name INTO l_org_name FROM gl_sets_of_books sob WHERE sob.set_of_books_id = p_sob_id; rp_org_name := l_org_name;
EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
END;
DECLARE l_report_name VARCHAR2(240);
BEGIN SELECT cp.user_concurrent_program_name INTO l_report_name FROM
FND_CONCURRENT_PROGRAMS_VL cp,
FND_CONCURRENT_REQUESTS cr WHERE cr.request_id = P_CONC_REQUEST_ID AND cp.application_id = cr.program_application_id AND cp.concurrent_program_id = cr.concurrent_program_id ;
RP_Report_Name := l_report_name;
--EXCEPTION WHEN NO_DATA_FOUND THEN RP_REPORT_NAME := 'Transaction Types Listing';
EXCEPTION WHEN NO_DATA_FOUND THEN RP_REPORT_NAME := 'Transaction Types Listing Report';
END;
BEGIN /*srw.user_exit('FND SRWINIT');*/
null;
/*srw.reference(P_STRUCT_NUM );*/
null;
null;
END;
END;
return (TRUE);
end;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    DECLARE
      LP_ORDER_CATEGORY VARCHAR2(80);
    BEGIN
      IF P_TRXN_TYPE_LO IS NOT NULL AND P_TRXN_TYPE_HI IS NOT NULL THEN
        LP_WHERE_CLAUSE := 'tv.name between ''' || P_TRXN_TYPE_LO || '''
                                and ''' || P_TRXN_TYPE_HI || ''' and';
      ELSIF P_TRXN_TYPE_LO IS NULL AND P_TRXN_TYPE_HI IS NOT NULL THEN
        LP_WHERE_CLAUSE := 'tv.name = ''' || P_TRXN_TYPE_HI || ''' and';
      ELSIF P_TRXN_TYPE_LO IS NOT NULL AND P_TRXN_TYPE_HI IS NULL THEN
        LP_WHERE_CLAUSE := 'tv.name = ''' || P_TRXN_TYPE_LO || ''' and';
      ELSE
        IF P_TRXN_TYPE_CODE IS NOT NULL AND P_ORDER_CATEGORY IS NOT NULL THEN
          IF P_TRXN_TYPE_CODE = 'LINE' THEN
            IF P_ORDER_CATEGORY = 'SALES' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''ORDER'') ';
            ELSIF P_ORDER_CATEGORY = 'CREDIT' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''RETURN'') ';
            ELSIF P_ORDER_CATEGORY = 'ALL' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''ORDER'', ''RETURN'') ';
            END IF;
          ELSIF P_TRXN_TYPE_CODE = 'ORDER' THEN
            IF P_ORDER_CATEGORY = 'SALES' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''ORDER'', ''MIXED'') ';
            ELSIF P_ORDER_CATEGORY = 'CREDIT' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''RETURN'', ''MIXED'') ';
            ELSIF P_ORDER_CATEGORY = 'ALL' THEN
              LP_ORDER_CATEGORY := ' and tv.order_category_code in (''ORDER'', ''RETURN'', ''MIXED'') ';
            END IF;
          END IF;
          LP_WHERE_CLAUSE := 'tv.transaction_type_code =''' || P_TRXN_TYPE_CODE || '''' || LP_ORDER_CATEGORY || ' and ';
        ELSIF P_TRXN_TYPE_CODE IS NOT NULL AND P_ORDER_CATEGORY IS NULL THEN
          LP_WHERE_CLAUSE := 'tv.transaction_type_code = ''' || P_TRXN_TYPE_CODE || ''' and ';
        ELSIF P_TRXN_TYPE_CODE IS NULL AND LP_ORDER_CATEGORY IS NOT NULL THEN
          IF P_ORDER_CATEGORY = 'SALES' THEN
            LP_ORDER_CATEGORY := 'and tv.order_category_code in (''ORDER'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'CREDIT' THEN
            LP_ORDER_CATEGORY := 'and tv.order_category_code in (''RETURN'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'ALL' THEN
            LP_ORDER_CATEGORY := 'and tv.order_category_code in (''ORDER'', ''RETURN'', ''MIXED'') ';
          END IF;
          LP_WHERE_CLAUSE := 'tv.order_category_code = ''' || LP_ORDER_CATEGORY || ''' and';
        ELSE
          LP_WHERE_CLAUSE := ' ';
        END IF;
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORG_NAME;
  END RP_ORG_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

END ONT_OEXORDTP_XMLP_PKG;



/
