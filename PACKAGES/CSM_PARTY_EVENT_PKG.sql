--------------------------------------------------------
--  DDL for Package CSM_PARTY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PARTY_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeptys.pls 120.1 2005/07/25 00:19:02 trajasek noship $ */

-- Generated 6/13/2002 7:50:32 PM from APPS@MOBSVC01.US.ORACLE.COM

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

PROCEDURE PARTY_ACC_I (p_party_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_flowtype IN VARCHAR2,
                       p_error_msg     OUT NOCOPY    VARCHAR2,
                       x_return_status IN OUT NOCOPY VARCHAR2
                       );

PROCEDURE PARTY_ACC_D (p_party_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_flowtype IN VARCHAR2,
                       p_error_msg     OUT NOCOPY    VARCHAR2,
                       x_return_status IN OUT NOCOPY VARCHAR2
                       );

FUNCTION PARTY_ORG_UPD_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2;

END CSM_PARTY_EVENT_PKG; -- Package spec

 

/
