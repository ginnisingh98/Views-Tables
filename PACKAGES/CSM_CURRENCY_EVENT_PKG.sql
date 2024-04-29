--------------------------------------------------------
--  DDL for Package CSM_CURRENCY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CURRENCY_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmecurs.pls 120.1 2005/07/22 09:30:17 trajasek noship $ */

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

-- uses acc table
PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END CSM_CURRENCY_EVENT_PKG; -- Package spec

 

/
