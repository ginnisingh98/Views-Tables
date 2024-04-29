--------------------------------------------------------
--  DDL for Package CSM_HZ_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_HZ_LOCATION_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuhzls.pls 120.0.12010000.2 2010/04/21 04:27:47 trajasek noship $ */


  /*
   * The function to be called by CSM_HZ_LOCATION_PKG, for upward sync of
   * publication item CSM_HZ_LOCATIONS
   */

-- Purpose: Update HZ location changes on Handheld to Enterprise database
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

Procedure APPLY_HA_CHANGES
          (P_Ha_Payload_Id   In  Number,
           p_Hzl_Name_List   In  Csm_Varchar_List,
           p_Hzl_Value_List  In  Csm_Varchar_List,
           p_Hzps_Name_List  In  Csm_Varchar_List,
           p_HZPS_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type        IN  VARCHAR2,
           X_Return_Status   Out Nocopy Varchar2,
           X_Error_Message   Out Nocopy Varchar2
         );

END CSM_HZ_LOCATION_PKG; -- Package spec

/
