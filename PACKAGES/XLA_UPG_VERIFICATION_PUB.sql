--------------------------------------------------------
--  DDL for Package XLA_UPG_VERIFICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UPG_VERIFICATION_PUB" AUTHID CURRENT_USER AS
-- $Header: xlaugval.pkh 120.0 2006/03/27 07:32:23 ksvenkat noship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaugval.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    XLA_UPG_VERIFICATION_PUB                                                |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA package which contains verification scripts to            |
|    check the AX-SLA Upgrade.                                               |
|                                                                            |
| HISTORY                                                                    |
|    27-Mar-06 Koushik V.S     Created                                       |
+===========================================================================*/

PROCEDURE Validate_Entries (
	  p_upgrading_application_id IN NUMBER,
	  p_application_id IN NUMBER);

PROCEDURE Validate_Application_Entries;

PROCEDURE Validate_Entity_Entries(
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER);

PROCEDURE Validate_Event_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER);

PROCEDURE Validate_Header_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER);

PROCEDURE Validate_Line_Entries (
          p_upgrading_application_id IN NUMBER,
          p_application_id IN NUMBER);

PROCEDURE Validate_Distribution_Entries (
          p_application_id IN NUMBER);

PROCEDURE Populate_Segment_Values (p_application_id IN NUMBER);

END  XLA_UPG_VERIFICATION_PUB;
 

/
