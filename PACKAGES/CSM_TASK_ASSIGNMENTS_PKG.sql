--------------------------------------------------------
--  DDL for Package CSM_TASK_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TASK_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmutas.pls 120.1.12010000.2 2010/04/29 16:49:47 trajasek ship $ */


  /*
   * The function to be called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
   * publication item CSM_TASK_ASSIGNMENTS
   */

-- Purpose: Update Task Assignments changes on Handheld to Enterprise database
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- DBhagat     11th September 2002  Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2;

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );

END CSM_TASK_ASSIGNMENTS_PKG; -- Package spec

/
