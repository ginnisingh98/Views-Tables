--------------------------------------------------------
--  DDL for Package CSM_STATE_TRANSITION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_STATE_TRANSITION_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmestrs.pls 120.1 2005/07/25 00:26:05 trajasek noship $ */

-- Generated 6/17/2002 10:38:22 AM from APPS@MOBSVC01.US.ORACLE.COM


--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag    05/30/02  Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

procedure Refresh_ACC (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2);
END; -- Package spec

 

/
