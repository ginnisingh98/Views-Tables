--------------------------------------------------------
--  DDL for Package GMIPRCNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIPRCNT" AUTHID CURRENT_USER as
-- $Header: gmiprcns.pls 120.0 2005/05/25 15:59:28 appldev noship $

FUNCTION CALCULATE_PERCENT(pfrozen NUMBER, pactual  NUMBER)
RETURN NUMBER;


END GMIPRCNT;

 

/
