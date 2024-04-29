--------------------------------------------------------
--  DDL for Package CSM_RESCODE_MAPPING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_RESCODE_MAPPING_EVENT_PKG" 
/* $Header: csmercms.pls 120.0 2005/11/14 09:12:02 trajasek noship $*/
AUTHID CURRENT_USER AS
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

PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);

END CSM_RESCODE_MAPPING_EVENT_PKG; -- Package spec

 

/
