--------------------------------------------------------
--  DDL for Package JAI_DRILLDOWN_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_DRILLDOWN_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_drilldown_utils_pkg.pls 120.0.12010000.2 2010/04/15 16:07:32 huhuliu noship $ */


/********************************************************************************************************
 FILENAME      :  jai_drilldown_utils_pkg.pls

 Created By    : Walton

 Created Date  : 15-Apr-2010

 Bug           : 9311844

 Purpose       :  This is the drilldown utility package which contain some common used subprograms.

 Called from   : OFI code

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

 2.        2010/04/15   Xiao Lv
                        Bug No : 9311844
                        Description : The file is changed for ER GL drilldown
                        Fix Details : http://files.oraclecorp.com/content/MySharedFolders/R12.1.3/TDD/TDD_1213_FIN_JAI_GL_Drilldown.doc
                        Doc Impact  : YES
                        Dependencies: YES, refer to Technical Design


***************************************************************************************************************/

--==========================================================================
--  FUNCTION NAME:
--
--    if_accounted                      Public
--
--  DESCRIPTION:
--
--    This function is used to check if accounting entries for OFI transactions
--    was imported into GL journal or not.
--
--  PARAMETERS:
--      In:  pv_view_name            Name of base view
--           pn_transaction_id       Identifier of transaction header
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Walton   created
--==========================================================================
FUNCTION if_accounted (pv_view_name VARCHAR2, pn_transaction_id NUMBER) RETURN BOOLEAN;

--==========================================================================
--  FUNCTION NAME:
--
--    get_transfer_number                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination transfer number.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================

FUNCTION get_transfer_number(pn_transfer_id IN NUMBER
                           , pn_org_id IN NUMBER
                           , pn_balance IN NUMBER) RETURN NUMBER;

--==========================================================================
--  FUNCTION NAME:
--
--    get_des_org_name                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization name.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================
FUNCTION get_des_org_name( pn_transfer_id IN NUMBER
                           , pn_org_id IN NUMBER
                           , pn_balance IN NUMBER) RETURN VARCHAR2;

--==========================================================================
--  FUNCTION NAME:
--
--    get_des_org_type                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization type.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================

FUNCTION get_des_org_type(pn_transfer_id IN NUMBER
                           , pn_org_id IN NUMBER
                           , pn_balance IN NUMBER) RETURN VARCHAR;
--==========================================================================
--  FUNCTION NAME:
--
--    get_des_loc_name                      Public
--
--  DESCRIPTION:
--
--    This function is used to get destination organization location name.
--
--
--  PARAMETERS:
--      In:  pn_transfer_id          Transfer id for Service Tax Distribution
--           pn_org_id               Org id for accounting entries
--           pn_balance              Balance for each accounting entries
--
--
--  DESIGN REFERENCES:
--    FDD_R12_1_3_GL_Drilldowndocx
--
--  CHANGE HISTORY:
--
--           15-Apr-2010   Xiao   created
--==========================================================================
FUNCTION get_des_loc_name(pn_transfer_id IN NUMBER
                           , pn_org_id IN NUMBER
                           , pn_balance IN NUMBER) RETURN VARCHAR;


END JAI_DRILLDOWN_UTILS_PKG;

/
