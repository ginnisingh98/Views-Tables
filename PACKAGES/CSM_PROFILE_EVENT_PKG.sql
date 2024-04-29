--------------------------------------------------------
--  DDL for Package CSM_PROFILE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PROFILE_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeprfs.pls 120.1.12010000.1 2008/07/28 16:14:31 appldev ship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

PROCEDURE refresh_user_acc(p_user_id IN NUMBER);

FUNCTION IS_MFS_PROFILE(p_profile_option_name IN VARCHAR2) RETURN BOOLEAN;

END CSM_PROFILE_EVENT_PKG; -- Package spec


/
