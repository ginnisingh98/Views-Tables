--------------------------------------------------------
--  DDL for Package FRM_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FRM_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: frmsecs.pls 120.0.12010000.2 2010/02/25 12:24:30 rgurusam noship $ */

--------------------------------------------------------------------------------
--  PACKAGE:      FRM_SECURITY_PKG                                            --
--                                                                            --
--  DESCRIPTION:                                                              --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  16-FEB-2010  RGURUSAM  Created.                                           --
--------------------------------------------------------------------------------


FUNCTION IS_MENU_ACCESSIBLE
                 (P_USER_ID     IN NUMBER,
                  P_MENU_ID     IN NUMBER,
                  P_MENU_TYPE   IN VARCHAR2) RETURN VARCHAR2;


FUNCTION IS_MENU_OWNER
                 (P_USER_ID     IN NUMBER,
                  P_MENU_ID     IN NUMBER,
                  P_MENU_TYPE   IN VARCHAR2) RETURN VARCHAR2;

FUNCTION IS_VALID_MENU_ID
                 (P_MENU_ID     IN NUMBER,
                  P_MENU_TYPE   IN VARCHAR2) RETURN BOOLEAN;

FUNCTION IS_VALID_USER_ID
                 (P_USER_ID     IN NUMBER) RETURN BOOLEAN;

END FRM_SECURITY_PKG;

/
