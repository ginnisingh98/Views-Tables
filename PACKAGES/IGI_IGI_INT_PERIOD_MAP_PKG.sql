--------------------------------------------------------
--  DDL for Package IGI_IGI_INT_PERIOD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGI_INT_PERIOD_MAP_PKG" AUTHID CURRENT_USER as
-- $Header: igiintas.pls 120.2.12000000.1 2007/09/12 09:37:30 mbremkum ship $
--
  Function CHECK_DUP_PERIOD(X_Period varchar2,
                             X_SOB_ID number,
                             X_Source_Name varchar2) return boolean;

END;

 

/
