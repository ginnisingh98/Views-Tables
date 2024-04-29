--------------------------------------------------------
--  DDL for Package CSM_MAIL_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MAIL_MESSAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmummss.pls 120.1 2005/07/25 01:14:20 trajasek noship $ */

-- Generated 6/13/2002 8:16:45 PM from APPS@MOBSVC01.US.ORACLE.COM

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag      06/10/02  Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );
END CSM_MAIL_MESSAGES_PKG; -- Package spec



 

/
