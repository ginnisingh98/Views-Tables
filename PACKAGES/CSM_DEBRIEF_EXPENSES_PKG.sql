--------------------------------------------------------
--  DDL for Package CSM_DEBRIEF_EXPENSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DEBRIEF_EXPENSES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmudbes.pls 120.1 2005/07/25 01:11:26 trajasek noship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag      06/09/02  Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );
END CSM_DEBRIEF_EXPENSES_PKG; -- Package spec



-- End of DDL Script for Package APPS.CSM_DEBRIEF_EXPENSES_PKG




 

/
