--------------------------------------------------------
--  DDL for Package ARP_PROCESS_ADJUSTMENT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_ADJUSTMENT1" AUTHID CURRENT_USER AS
/* $Header: ARTEAD1S.pls 115.2 99/10/11 16:15:47 porting sh $ */

FUNCTION is_autoadj_candidate(p_adj_low_amt       IN NUMBER   ,
                              p_adj_high_amt      IN NUMBER   ,
                              p_adj_low_pct       IN NUMBER   ,
                              p_adj_high_pct      IN NUMBER   ,
                              p_type              IN VARCHAR2 ,
                              p_over_apply        IN VARCHAR2 ,
                              p_tax_code_source   IN VARCHAR2 ,
                              p_tax_rate          IN NUMBER   ,
                              p_line_remaining    IN NUMBER   ,
                              p_charges_remaining IN NUMBER   ,
                              p_tax_remaining     IN NUMBER   ,
                              p_line_original     IN NUMBER   ,
                              p_charges_original  IN NUMBER   ,
                              p_tax_original      IN NUMBER   ,
                              p_currency          IN VARCHAR2 ) RETURN VARCHAR2;


END ARP_PROCESS_ADJUSTMENT1;

 

/
