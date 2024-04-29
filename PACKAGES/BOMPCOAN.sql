--------------------------------------------------------
--  DDL for Package BOMPCOAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCOAN" AUTHID CURRENT_USER AS
/* $Header: BOMCOANS.pls 120.1.12010000.2 2010/01/23 00:26:39 umajumde ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCOANS.pls                                               |
| DESCRIPTION  :                                                            |
|              This file creates a packaged procedure that performs ECO     |
|              autonumbering.  When passed a user id and an organization    |
|              id, it searches for a valid ECO autonumber prefix and next   |
|              available number, searching in the following order:          |
|                 1 - specific user, specific organization                  |
|                 2 - specific user, across all organizations               |
|                 3 - specific organization, across all users               |
|                 4 - across all users and all organizations                |
| INPUTS       :  P_USER_ID - user id					    |
|                 P_ORGANIZATION_ID - organization id                       |
|                 P_MODE - indicates whether or not to update next          |
|                          available number in the ECO autonumber table     |
|                                                                           |
+==========================================================================*/

--Begin bug fix 9234014
   PROCEDURE Check_Next_AutoNum
    (p_user_id  IN NUMBER
   , p_organization_id  IN NUMBER
   , p_change_notice IN VARCHAR2
   , x_return_status IN OUT NOCOPY VARCHAR2);

 --Eng bug fix 9234014

    PROCEDURE BOM_ECO_AUTONUMBER
   (P_USER_ID 			IN	NUMBER,
    P_ORGANIZATION_ID		IN	NUMBER,
    P_MODE 			IN      NUMBER,
    P_PREFIX			IN OUT NOCOPY  VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2); -- bug fix 9234014

END BOMPCOAN;

/
