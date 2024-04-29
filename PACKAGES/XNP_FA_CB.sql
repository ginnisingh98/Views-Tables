--------------------------------------------------------
--  DDL for Package XNP_FA_CB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_FA_CB" AUTHID CURRENT_USER AS
/* $Header: XNPFACBS.pls 120.2 2006/02/13 07:48:27 dputhiye ship $ */


-- Gets the FE_ID,FEATURE_TYPE for which the provisioning
-- system has responded to. Gets the number range
-- and updates the XNP_SV_SMS_FE_MAPS to the
-- provisioning status returned in the FA_DONE message
-- The correct provisioning operation is derived and
-- the right function is invoked to take it from there
PROCEDURE PROCESS_FA_DONE
 (p_MESSAGE_ID        IN NUMBER
 ,p_PROCESS_REFERENCE IN VARCHAR2
 ,x_ERROR_CODE       OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
 );

-- Updates the FE map status to the provisioning status
-- returned by the FA callback event
PROCEDURE PROVISION_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   );

-- Deletes the FE maps for this number range and feature type
-- If all the FE maps are deleted the SMS entries are also deleted

PROCEDURE DEPROVISION_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   );

-- Updates the FE map status to the provisioning status
-- returned by the FA callback event to either SUCCESS or ERROR
PROCEDURE MODIFY_FE
   (p_STARTING_NUMBER         VARCHAR2
   ,p_ENDING_NUMBER           VARCHAR2
   ,p_FE_ID                   NUMBER
   ,p_FEATURE_TYPE            VARCHAR2
   ,p_PROV_STATUS             VARCHAR2
   ,p_ORDER_ID             IN NUMBER
   ,p_LINEITEM_ID          IN NUMBER
   ,p_WORKITEM_INSTANCE_ID IN NUMBER
   ,p_FA_INSTANCE_ID       IN NUMBER
   ,x_ERROR_CODE          OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
   );

END XNP_FA_CB;


 

/
