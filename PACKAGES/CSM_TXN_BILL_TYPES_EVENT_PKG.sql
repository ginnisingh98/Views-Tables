--------------------------------------------------------
--  DDL for Package CSM_TXN_BILL_TYPES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TXN_BILL_TYPES_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmetbts.pls 120.1 2005/07/25 00:27:02 trajasek noship $ */

-- Generated 6/17/2002 10:50:55 AM from APPS@MOBSVC01.US.ORACLE.COM

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

procedure Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
