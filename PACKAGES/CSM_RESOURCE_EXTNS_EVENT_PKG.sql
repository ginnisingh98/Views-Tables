--------------------------------------------------------
--  DDL for Package CSM_RESOURCE_EXTNS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_RESOURCE_EXTNS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeress.pls 120.2 2006/06/07 13:44:39 saradhak noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Sajesh    7-JUN-2006  Bug 5236469 - Added 2 public APIs
   -- Enter package declarations as shown below

PROCEDURE RESOURCE_EXTNS_ACC_I (p_resource_id IN NUMBER, p_user_id IN NUMBER );

PROCEDURE RESOURCE_EXTNS_ACC_D (p_resource_id IN NUMBER, p_user_id IN NUMBER );

PROCEDURE RESOURCE_EXTNS_ACC_PROCESSOR (p_resource_id IN NUMBER, p_user_id IN NUMBER);

PROCEDURE RS_GROUP_MEMBERS_INS_INIT(p_resource_id IN NUMBER, p_group_id IN NUMBER);

PROCEDURE RS_GROUP_MEMBERS_DEL_INIT(p_resource_id IN NUMBER, p_group_id IN NUMBER);

--Bug 5236469
PROCEDURE RESOURCE_EXTNS_ACC_CLEANUP (p_user_id IN NUMBER);
PROCEDURE PROCESS_NOTIFICATION_SCOPE(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2);

END; -- Package spec



 

/
