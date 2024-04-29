--------------------------------------------------------
--  DDL for Package Body PO_RCVIERR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCVIERR_XMLP_PKG" AS
/* $Header: RCVIERRB.pls 120.2 2008/01/11 11:58:18 dwkrishn noship $ */
  FUNCTION AFTERREPORT(C_1 IN NUMBER
                      ,C_2 IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (C_1 = 0 AND C_2 = 0) THEN
        RETURN (true);
      ELSE
        IF P_PURGE_DATA = 'Y' THEN
          DELETE FROM PO_INTERFACE_ERRORS POI
           WHERE POI.INTERFACE_HEADER_ID in (
             SELECT
               RHI.HEADER_INTERFACE_ID
             FROM
               PO_INTERFACE_ERRORS POI,
               RCV_HEADERS_INTERFACE RHI
             WHERE POI.INTERFACE_HEADER_ID = RHI.HEADER_INTERFACE_ID
               AND ( ( TO_DATE(TO_CHAR(TRUNC(POI.CREATION_DATE)
                            ,'DD-MON-YYYY')
                    ,'DD-MON-YYYY') between TRUNC(NVL(P_START_DATE
                      ,POI.CREATION_DATE))
               AND TRUNC(NVL(P_END_DATE
                      ,SYSDATE))
               AND ( P_START_DATE is not null
             OR P_END_DATE is not null ) )
             OR ( P_START_DATE is null
               AND P_END_DATE is null
               AND RHI.PROCESSING_STATUS_CODE NOT IN ( 'PENDING' ) ) ) );
          DELETE FROM PO_INTERFACE_ERRORS POI
           WHERE POI.INTERFACE_LINE_ID in (
             SELECT
               RTI.INTERFACE_TRANSACTION_ID
             FROM
               PO_INTERFACE_ERRORS POI,
               RCV_TRANSACTIONS_INTERFACE RTI
             WHERE POI.INTERFACE_LINE_ID = RTI.INTERFACE_TRANSACTION_ID
               AND POI.INTERFACE_TYPE = 'RCV-856'
               AND ( ( TRUNC(TO_DATE(TO_CHAR(POI.CREATION_DATE
                                  ,'DD-MON-YYYY')
                          ,'DD-MON-YYYY')) between TRUNC(NVL(P_START_DATE
                      ,POI.CREATION_DATE))
               AND TRUNC(NVL(P_END_DATE
                      ,SYSDATE))
               AND ( P_START_DATE is not null
             OR P_END_DATE is not null ) )
             OR ( P_START_DATE is null
               AND P_END_DATE is null
               AND RTI.PROCESSING_STATUS_CODE NOT IN ( 'PENDING' ) ) ) );
          DELETE FROM PO_INTERFACE_ERRORS POI
           WHERE POI.INTERFACE_TRANSACTION_ID in (
             SELECT
               RTI.INTERFACE_TRANSACTION_ID
             FROM
               PO_INTERFACE_ERRORS POI,
               RCV_TRANSACTIONS_INTERFACE RTI
             WHERE POI.INTERFACE_TRANSACTION_ID = RTI.INTERFACE_TRANSACTION_ID
               AND POI.INTERFACE_TYPE in ( 'RECEIVE' , 'DELIVER' )
               AND ( ( TRUNC(TO_DATE(TO_CHAR(POI.CREATION_DATE
                                  ,'DD-MON-YYYY')
                          ,'DD-MON-YYYY')) between TRUNC(NVL(P_START_DATE
                      ,POI.CREATION_DATE))
               AND TRUNC(NVL(P_END_DATE
                      ,SYSDATE))
               AND ( P_START_DATE is not null
             OR P_END_DATE is not null ) )
             OR ( P_START_DATE is null
               AND P_END_DATE is null
               AND RTI.PROCESSING_STATUS_CODE NOT IN ( 'PENDING' ) ) ) );
        END IF;
        RETURN (TRUE);
      END IF;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    RETURN (TRUE);
  END BEFOREREPORT;

END PO_RCVIERR_XMLP_PKG;


/
