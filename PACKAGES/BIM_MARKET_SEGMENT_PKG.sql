--------------------------------------------------------
--  DDL for Package BIM_MARKET_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_MARKET_SEGMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: bimmkts.pls 115.2 2000/01/07 16:14:52 pkm ship  $ */

FUNCTION MARKET_SEGMENT_FK(p_customer_id number,
                           p_trx_date    date) RETURN NUMBER;

END BIM_MARKET_SEGMENT_PKG;

 

/
