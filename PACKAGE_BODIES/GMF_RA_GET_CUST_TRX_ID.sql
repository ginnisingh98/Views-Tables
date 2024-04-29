--------------------------------------------------------
--  DDL for Package Body GMF_RA_GET_CUST_TRX_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_RA_GET_CUST_TRX_ID" AS
/* $Header: gmfcusrb.pls 115.1 2002/11/11 00:37:09 rseshadr ship $ */
     CURSOR get_cust_trx_id(    startdate date,
                      enddate date,
                      trxtype varchar2) IS
        SELECT cust_trx_type_id
        FROM RA_CUST_TRX_TYPES_ALL
        WHERE TYPE like nvl(trxtype,'%')  AND
            creation_date  BETWEEN
            nvl(startdate,creation_date)  AND
            nvl(enddate,creation_date);
    PROCEDURE ra_get_cust_trx_id(  startdate date,
                        enddate date,
                        trxtype varchar2,
                        custtrxtypeid out NOCOPY number,
                        row_to_fetch in out NOCOPY number,
                        statuscode out NOCOPY number) IS
      BEGIN
        IF NOT get_cust_trx_id%ISOPEN THEN
          OPEN get_cust_trx_id(startdate,enddate,trxtype);
        END IF;
        FETCH  get_cust_trx_id INTO custtrxtypeid;
        IF get_cust_trx_id%NOTFOUND or row_to_fetch = 1 THEN
          CLOSE get_cust_trx_id;
          statuscode := 100;
        END IF;
        EXCEPTION
          WHEN others THEN
            statuscode := SQLCODE;
      END;
END GMF_RA_GET_CUST_TRX_ID;

/
