--------------------------------------------------------
--  DDL for Package IGI_IAC_REINSTATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_REINSTATE_PKG" AUTHID CURRENT_USER AS
--  $Header: igiiarns.pls 120.5.12000000.2 2007/10/16 14:25:43 sharoy ship $

  FUNCTION Do_Iac_Reinstatement(p_asset_id        NUMBER,
                                p_book_type_code  VARCHAR2,
                                p_retirement_id   NUMBER,
                                p_calling_function VARCHAR2,
                                p_event_id         NUMBER    --R12 uptake
                               )
  RETURN BOOLEAN;

END IGI_IAC_REINSTATE_PKG;

 

/
