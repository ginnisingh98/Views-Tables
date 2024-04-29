--------------------------------------------------------
--  DDL for Package JL_ZZ_AP_EXT_AWT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AP_EXT_AWT_UTIL" AUTHID CURRENT_USER AS
/* $Header: jlzzpwus.pls 115.4 2003/01/17 06:51:30 kpvs ship $ */


/**************************************************************************
 *                                                                        *
 * Name       : debug                                                     *
 * Purpose    : Writes the p_line in a system file                        *
 *                                                                        *
 **************************************************************************/
PROCEDURE  debug(p_line in VARCHAR2 );

/**************************************************************************
 *                                                                        *
 * Name       : Print_Tax_Names                                           *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/
PROCEDURE Print_Tax_Names (P_Tab_Payment_Wh    IN   JL_ZZ_AP_WITHHOLDING_PKG.Tab_Withholding);

/**************************************************************************
 *                                                                        *
 * Name       : Print_tab_all_wh                                          *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_tab_all_wh (P_tab_all_wh  IN JL_ZZ_AP_WITHHOLDING_PKG.Tab_All_Withholding);

/**************************************************************************
 *                                                                        *
 * Name       : Print_tab_amounts                                         *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_tab_amounts (P_tab_Amounts IN JL_AR_AP_WITHHOLDING_PKG.Tab_Amounts);

PROCEDURE initialize;

END   JL_ZZ_AP_EXT_AWT_UTIL;

 

/
