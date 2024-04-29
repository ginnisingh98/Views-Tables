--------------------------------------------------------
--  DDL for Package CSM_INVENTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_INVENTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuinvs.pls 120.1 2005/07/25 01:13:27 trajasek noship $ */
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

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

END CSM_INVENTORY_PKG; -- Package spec

 

/
