--------------------------------------------------------
--  DDL for Package POA_SUPPERF_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SUPPERF_INIT_PKG" AUTHID CURRENT_USER AS
/* $Header: POASPINS.pls 115.0 99/07/15 20:04:08 porting shi $: */

   PROCEDURE init_supplier_performance(p_start_date IN DATE, p_end_date IN DATE);


END POA_SUPPERF_INIT_PKG;


 

/
