--------------------------------------------------------
--  DDL for Package FRM_REPOSITORY_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FRM_REPOSITORY_MAINTENANCE" AUTHID CURRENT_USER AS
/* $Header: frmrepmaintenances.pls 120.0.12010000.3 2010/12/08 09:37:05 rgurusam noship $ */

--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_MENU_ENTRIES                     		      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete menu entries	 		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--  29-Nov-2010  RGURUSAM  Bug 8333050 - Support to overwrite existing reports--
--                         Introduced PL/SQL Procedure DELETE_DOCUMENT_TIMEFRAME
--                         to delete a report of a time frame from document   --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MENU_ENTRIES(P_MENU_ID   IN NUMBER,
        		    P_ENTRY_SEQ   IN NUMBER);


--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_FORM_ENTRIES                     		      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete menu entries	 		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_FORM_ENTRIES(P_FUNC_ID   IN NUMBER);


--------------------------------------------------------------------------------
--  PROCEDURE:        DELETE_MENUFORM_ENTRIES         	                      --
--                                                                            --
--  DESCRIPTION:      Procedure to delete form entries 			      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MENUFORM_ENTRIES(P_DOCUMENT_ID IN NUMBER);


--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_MARKED_ENTRIES                                --
--                                                                            --
--  DESCRIPTION:         Delete all rows marked for delete		      --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  19-APR-2010  DHVENKAT  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_MARKED_ENTRIES(P_USER_ID IN NUMBER);

--------------------------------------------------------------------------------
--  PROCEDURE:           DELETE_DOCUMENT_TIMEFRAME                            --
--                                                                            --
--  DESCRIPTION:         Delete the report for timeframe in the document      --
--                       This procedure is used to replace a report for       --
--                       timeframe in the document when publishing            --
--                       with a report with replace option.                   --
--                       It retains the form functions created, menu entries  --
--                       as they will be used to access the newly created     --
--                       document.                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date         Username  Description                                        --
--  26-NOV-2010  RGURUSAM  CREATED                                            --
--------------------------------------------------------------------------------
PROCEDURE DELETE_DOCUMENT_TIMEFRAME(P_DOCUMENT_ID IN NUMBER, P_TIMEFRAME IN VARCHAR2);

END FRM_REPOSITORY_MAINTENANCE;

/
