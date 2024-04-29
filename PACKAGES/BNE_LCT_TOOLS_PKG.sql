--------------------------------------------------------
--  DDL for Package BNE_LCT_TOOLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_LCT_TOOLS_PKG" AUTHID CURRENT_USER as
/* $Header: bnelcttoolss.pls 120.6 2005/12/07 16:09:38 dagroves noship $ */

function APP_ID_TO_ASN(X_APP_ID IN NUMBER) RETURN FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
function ASN_TO_APP_ID(X_ASN IN VARCHAR2) RETURN FND_APPLICATION.APPLICATION_ID%TYPE;

function GET_APP_ID(X_BNE_KEY IN VARCHAR2)
RETURN NUMBER;
function GET_CODE(X_BNE_KEY IN VARCHAR2)
RETURN VARCHAR2;


function GET_IMPORT_LISTS(X_IMPORT_LIST_APP_ID IN NUMBER,
                          X_IMPORT_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
--  FUNCTION:         GET_ESC_EXTENSIBLE_MENUS_LISTS                          --
--                                                                            --
--  DESCRIPTION:      Retrieve all code values for parameter lists used by    --
--                    the extensible menus functionality.  The Menus codes are--
--                    surrounded by the '#' character to prevent substr probs.--
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  07-Dec-2005  DAGROVES  Created.                                           --
--------------------------------------------------------------------------------
function GET_ESC_EXTENSIBLE_MENUS_LISTS(X_CDPF_LIST_APP_ID IN NUMBER,
                                        X_CDPF_LIST_CODE   IN VARCHAR2)
RETURN VARCHAR2;

end BNE_LCT_TOOLS_PKG;

 

/
