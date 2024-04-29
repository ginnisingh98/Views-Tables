--------------------------------------------------------
--  DDL for Package PQP_UK_PS_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UK_PS_FF_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pqukpsfn.pkh 120.1 2005/05/30 00:12:57 rvishwan noship $ */

FUNCTION  date_diff(p_greater_date IN DATE ,
                   p_smaller_date IN DATE ) RETURN NUMBER;

END pqp_uk_ps_ff_functions;

 

/
