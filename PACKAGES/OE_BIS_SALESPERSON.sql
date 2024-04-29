--------------------------------------------------------
--  DDL for Package OE_BIS_SALESPERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BIS_SALESPERSON" AUTHID CURRENT_USER AS
--$Header: OEXBISPS.pls 120.0.12000000.2 2008/12/24 12:37:04 kshashan ship $

FUNCTION GET_SALESPERSON_NAME
(
  p_salesrep_id NUMBER
)
RETURN VARCHAR2;

FUNCTION GET_SALESPERSON_NAME -- bug 7620276
(
  p_salesrep_id NUMBER,
  p_org_id      NUMBER
)
RETURN VARCHAR2;

END OE_BIS_SALESPERSON;

 

/
