--------------------------------------------------------
--  DDL for Package CSM_LOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_LOBS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmulobs.pls 120.1.12010000.3 2010/05/13 10:05:49 trajasek ship $ */

-- Generated 6/13/2002 8:45:09 PM from APPS@MOBSVC01.US.ORACLE.COM

--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Ravi        06/11/2002
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below
G_FILE_ATTACHMENT BLOB;

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
END CSM_LOBS_PKG; -- Package spec


/
