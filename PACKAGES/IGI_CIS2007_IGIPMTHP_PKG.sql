--------------------------------------------------------
--  DDL for Package IGI_CIS2007_IGIPMTHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_IGIPMTHP_PKG" AUTHID CURRENT_USER AS
 -- $Header: IGIPMTHS.pls 120.0.12000000.2 2007/07/16 12:36:36 vensubra noship $
  -- Public type declarations
  PROCEDURE pr_audit_update(p_in_header_id IN NUMBER,
                            p_in_completion_code IN VARCHAR2);

end IGI_CIS2007_IGIPMTHP_PKG;

 

/
