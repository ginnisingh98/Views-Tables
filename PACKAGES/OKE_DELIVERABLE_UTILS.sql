--------------------------------------------------------
--  DDL for Package OKE_DELIVERABLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DELIVERABLE_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEDUTLS.pls 115.4 2002/10/18 21:04:15 jxtang ship $ */

FUNCTION GET_TERM_VALUE ( x_deliverable_id IN NUMBER, x_term_code IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION GET_PARTY ( x_deliverable_id IN NUMBER, x_role_code IN VARCHAR2 ) RETURN NUMBER;

FUNCTION GET_K_REFERENCE ( P_Deliverable_ID IN NUMBER, P_Source_Code IN VARCHAR2 DEFAULT 'OKE' ) RETURN VARCHAR2;


END;



 

/
