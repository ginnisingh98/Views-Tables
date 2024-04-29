--------------------------------------------------------
--  DDL for Package CSM_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmunots.pls 120.1.12010000.2 2010/04/21 04:17:31 trajasek ship $ */

-- Generated 6/13/2002 8:18:22 PM from APPS@MOBSVC01.US.ORACLE.COM

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag      06/12/02  Created
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below


  PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

 PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );

END CSM_NOTES_PKG; -- Package spec


/
