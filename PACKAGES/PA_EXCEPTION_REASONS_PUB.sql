--------------------------------------------------------
--  DDL for Package PA_EXCEPTION_REASONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXCEPTION_REASONS_PUB" AUTHID CURRENT_USER AS
/*$Header: PAXEXPRS.pls 115.0 99/07/16 15:24:09 porting ship $*/

FUNCTION get_exception_text
     (x_exception_type		IN	VARCHAR2,
      x_exception_code		IN	VARCHAR2,
      x_exception_reason	IN	VARCHAR2,
      x_return_type		IN	VARCHAR2) return varchar2;
PRAGMA RESTRICT_REFERENCES (get_exception_text, WNDS, WNPS);

END PA_EXCEPTION_REASONS_PUB;

 

/
