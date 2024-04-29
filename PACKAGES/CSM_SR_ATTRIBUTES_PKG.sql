--------------------------------------------------------
--  DDL for Package CSM_SR_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SR_ATTRIBUTES_PKG" AUTHID CURRENT_USER As
/* $Header: csmusras.pls 120.0.12010000.1 2010/04/21 04:23:24 trajasek noship $ */


  /*
   * The function to be called by HA Procedure, for upward sync of
   * publication item APPLY_SR_LINK_INSERT
   */

-- Purpose: Update SR Links changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_HA_ATTR_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );
PROCEDURE APPLY_HA_LINK_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         );
END CSM_SR_ATTRIBUTES_PKG; -- Package spec

/
