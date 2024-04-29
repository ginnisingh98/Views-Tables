--------------------------------------------------------
--  DDL for Package PER_ORG_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: perorgdp.pkh 115.1 2002/10/09 09:03:03 fsheikh noship $ */
-- -------------------------------------------------------------------------
-- --------------------< get_company_valueset_id >--------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION GET_COMPANY_VALUESET_ID
  (P_COMPANY_VALUESET_NAME IN varchar2 )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_company_valueset_id , WNDS);
-- -------------------------------------------------------------------------
-- --------------------< get_costcenter_valueset_id >--------------------------
-- -------------------------------------------------------------------------
-- DESCRIPTION
--   This function returns the
--
FUNCTION GET_COSTCENTER_VALUESET_ID
  (P_COSTCENTER_VALUESET_NAME IN varchar2 )
RETURN BINARY_INTEGER;
PRAGMA RESTRICT_REFERENCES (get_costcenter_valueset_id , WNDS);
END PER_ORG_DATA_PUMP ;

 

/
