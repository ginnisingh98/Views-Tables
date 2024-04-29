--------------------------------------------------------
--  DDL for Package CSM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_TASKS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmutsks.pls 120.1.12010000.2 2010/04/26 17:57:24 trajasek ship $ */


  /*
   * The function to be called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
   * publication item CSM_TASKS
   */

-- Purpose: Update and Create Tasks changes on Handheld to Enterprise database
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- DBhagat     12th September 2002  Created
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

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );

END CSM_TASKS_PKG; -- Package spec

/
