--------------------------------------------------------
--  DDL for Package GMF_RA_GET_CUST_TRX_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_RA_GET_CUST_TRX_ID" AUTHID CURRENT_USER AS
/* $Header: gmfcusrs.pls 115.1 2002/11/11 00:37:17 rseshadr ship $ */
    PROCEDURE ra_get_cust_trx_id(  startdate date,
                        enddate date,
                        trxtype varchar2,
                        custtrxtypeid out NOCOPY number,
                        row_to_fetch in out NOCOPY number,
                        statuscode out NOCOPY number);

END GMF_RA_GET_CUST_TRX_ID;

 

/
