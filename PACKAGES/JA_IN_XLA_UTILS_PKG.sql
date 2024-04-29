--------------------------------------------------------
--  DDL for Package JA_IN_XLA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_IN_XLA_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: ja_in_xla_utils.pls 120.0.12010000.1 2010/04/08 07:48:24 huhuliu noship $ */


/********************************************************************************************************
 FILENAME      :  ja_in_xla_utils.pls

 Created By    : Walton

 Created Date  : 07-Apr-2010

 Bug           : 9311844

 Purpose       :  Check whether OFI source and category be used or not.

 Called from   : XLACORE.pll

 --------------------------------------------------------------------------------------------------------
 CHANGE HISTORY:
 --------------------------------------------------------------------------------------------------------
 S.No      Date          Author and Details
 --------------------------------------------------------------------------------------------------------
 1.        2010/04/07   Walton Liu
                        Bug No : 9311844
                        Description : The file is changed for ER GL drilldown
                        Fix Details : http://files.oraclecorp.com/content/MySharedFolders/R12.1.3/TDD/TDD_1213_FIN_JAI_GL_Drilldown.doc
                        Doc Impact  : YES
                        Dependencies: YES, refer to Technical Design

***************************************************************************************************************/

--==========================================================================
--  FUNCTION NAME:
--
--    if_OFI_drilldown                      Public
--
--  DESCRIPTION:
--
--    This function is used to Enable/Disable drilldown buttion
--    according OFI journal source and journal categories.
--
--  PARAMETERS:
--      In:  pn_je_source           Identifier of journal source
--           pn_je_category         Identifier of journal category
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_4_GL_Drilldown_V0.4.docx
--
--  CHANGE HISTORY:
--
--           09-Mar-2010   Jia Li   created
--==========================================================================
FUNCTION if_OFI_drilldown (
   pn_je_source           VARCHAR2
 , pn_je_category         VARCHAR2
 ) RETURN BOOLEAN;



END ja_in_xla_utils_pkg;

/
