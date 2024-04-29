--------------------------------------------------------
--  DDL for Package Body BIM_MARKET_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_MARKET_SEGMENT_PKG" AS
/* $Header: bimmktb.pls 115.3 2000/02/02 10:08:08 pkm ship  $ */

FUNCTION market_segment_fk(p_customer_id number,
                           p_trx_date    date) RETURN NUMBER AS

CURSOR C_GET_MKTSEG_ID
IS
	SELECT PMKT.MARKET_SEGMENT_ID
	FROM   AMS_PARTY_MARKET_SEGMENTS PMKT
	WHERE
		PMKT.PARTY_ID = p_customer_id
        AND PMKT.MARKET_SEGMENT_FLAG = 'Y';
       -- AND  p_trx_date    >=   PMKT.START_DATE_ACTIVE
       -- AND  p_trx_date    <=   nvl( PMKT.END_DATE_ACTIVE,  SYSDATE ) ;

v_mktseg_id PLS_INTEGER := -999 ;

BEGIN

   IF p_customer_id IS NOT NULL
   THEN
    OPEN   C_GET_MKTSEG_ID;
    FETCH  C_GET_MKTSEG_ID INTO v_mktseg_id;
    CLOSE  C_GET_MKTSEG_ID;
   END IF;

   RETURN v_mktseg_id;

EXCEPTION
    WHEN OTHERS THEN
         IF c_get_mktseg_id%ISOPEN
         THEN
              close c_get_mktseg_id;
         END IF;
         raise;
END;

END BIM_MARKET_SEGMENT_PKG;

/
