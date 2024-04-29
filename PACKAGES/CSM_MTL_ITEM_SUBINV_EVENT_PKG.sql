--------------------------------------------------------
--  DDL for Package CSM_MTL_ITEM_SUBINV_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_ITEM_SUBINV_EVENT_PKG" 
/* $Header: csmemiss.pls 120.1 2005/07/25 00:12:11 trajasek noship $*/
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

END CSM_MTL_ITEM_SUBINV_EVENT_PKG; -- Package spec

 

/
