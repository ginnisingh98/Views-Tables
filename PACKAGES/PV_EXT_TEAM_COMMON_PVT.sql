--------------------------------------------------------
--  DDL for Package PV_EXT_TEAM_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_EXT_TEAM_COMMON_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvcoms.pls 120.0 2005/05/27 15:46:50 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_EXT_TEAM_COMMON_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvcoms.pls';


/*============================================================================
-- Start of comments
--  API name  : chk_oppty_approver
--  Type      : Function.
--  Function  : This function return the value 'Y' or 'N' based on the
--              findings that the given user is a Opportunity Approver
--              or not.
--
--
--
--
--
--
--
--  Pre-reqs  :
--  Parameters  :
--  IN    :
--        p_user_name  In   VARCHAR2
--
--  OUT   :
--
--  Version : Current version   1.0
--
--  Notes   : Note text
--
-- End of comments
============================================================================*/
FUNCTION chk_oppty_approver(p_user_name IN VARCHAR2 )
RETURN VARCHAR2 ;

END PV_EXT_TEAM_COMMON_PVT;

 

/
