--------------------------------------------------------
--  DDL for Package CSM_SERVICE_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SERVICE_REQUESTS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmusrs.pls 120.1.12010000.2 2010/04/21 04:15:27 trajasek ship $ */

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

/* Conflict Resolution Method for PI level conflict detection. */
FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 ;

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );

END CSM_SERVICE_REQUESTS_PKG;

/
