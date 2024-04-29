--------------------------------------------------------
--  DDL for Package CSM_BUS_PROCESS_TXNS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_BUS_PROCESS_TXNS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmebpts.pls 120.1 2005/07/22 08:38:54 trajasek noship $ */

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag    05/29/02  created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


procedure Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
