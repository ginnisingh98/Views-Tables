--------------------------------------------------------
--  DDL for Package POA_SAVINGS_NP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SAVINGS_NP" AUTHID CURRENT_USER AS
/* $Header: poasvp3s.pls 115.7 2004/01/22 14:11:58 sdiwakar ship $ */

  PROCEDURE populate_npcontract (p_start_date IN DATE,
                                 p_end_date IN DATE,
                                 p_start_time IN DATE,
                                 p_batch_no IN NUMBER);

  PROCEDURE insert_npcontract (p_po_distribution_id IN NUMBER,
                               p_lowest_price IN NUMBER,
                               p_start_time IN DATE);

  FUNCTION get_currency_conv_rate  (p_from_currency_code po_headers_all.currency_code%type,
                                    p_to_currency_code   VARCHAR2,
                                    p_rate_date          DATE,
                                    p_rate_type          edw_local_system_parameters.rate_type%type)  RETURN NUMBER;
  PRAGMA RESTRICT_REFERENCES (get_currency_conv_rate, WNDS);

END poa_savings_np;

 

/
