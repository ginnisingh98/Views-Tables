--------------------------------------------------------
--  DDL for Package POA_SAVINGS_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SAVINGS_CON" AUTHID CURRENT_USER AS
/* $Header: poasvp2s.pls 115.5 2003/01/09 23:33:55 rvickrey ship $ */

  PROCEDURE populate_contract (p_start_date IN DATE,
                               p_end_date IN DATE,
                               p_start_time IN DATE,
                               p_batch_no IN NUMBER);

END poa_savings_con;

 

/
