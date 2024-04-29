--------------------------------------------------------
--  DDL for Package POA_SAVINGS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SAVINGS_MAIN" AUTHID CURRENT_USER AS
/* $Header: poasvp1s.pls 115.4 2003/01/09 23:31:24 rvickrey ship $ */

  PROCEDURE populate_savings(p_start_date IN DATE, p_end_date IN DATE,
                             p_populate_inc IN BOOLEAN := TRUE);


END poa_savings_main;

 

/
