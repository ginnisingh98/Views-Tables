--------------------------------------------------------
--  DDL for Package AP_APPPST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APPPST_PKG" AUTHID CURRENT_USER AS
/* $Header: appstfxs.pls 120.3 2004/10/28 23:29:03 pjena noship $ */
                                                                         --
function Ap_Get_GL_Interface_Amount
                             (EnteredAmount IN NUMBER
                             ,BaseAmount    IN NUMBER
                             ,AccountType   IN VARCHAR2
                             ,ResultColumn  IN VARCHAR2
                             ) return NUMBER;
pragma restrict_references(Ap_Get_GL_Interface_Amount, WNDS, WNPS, RNPS);
                                                                         --
function Ap_apppst_Round_Currency
                         (P_Amount         IN number
                         ,P_Currency_Code  IN varchar2
                         ) return number;
pragma restrict_references(Ap_apppst_Round_Currency, WNDS, WNPS, RNPS);

END AP_APPPST_PKG;

 

/
