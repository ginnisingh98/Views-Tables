--------------------------------------------------------
--  DDL for Package CS_SR_SECURITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SECURITY_GRP" AUTHID CURRENT_USER AS
/* $Header: csgsecs.pls 115.2 2003/09/25 02:32:27 dejoseph noship $ */

-- Record structure to hold the values of the SR attributes that are used to
-- implement service security
-- For release 11.5.10, only SR Type is used.
TYPE SR_REC_TYPE IS RECORD (
   INCIDENT_ID          NUMBER,
   INCIDENT_TYPE_ID     NUMBER  );

-- Record structure to hold the values of the id and type of the resource. Resource
-- type can be INDIVIDUAL, SUPPLIER, VENDOR, GROUP, TEAM etc.
TYPE RESOURCE_VALIDATE_REC_TYPE IS RECORD  (
   RESOURCE_ID          NUMBER,
   RESOURCE_TYPE        VARCHAR2(90) );

-- Table type of resource records. Given a list of resources, the validate_resource
-- API will return back a set of resources that satisfy the Service Security policies.

TYPE RESOURCE_VALIDATE_TBL_TYPE IS TABLE OF RESOURCE_VALIDATE_REC_TYPE;

-- VALIDATE_USER_RESPONSIBILITY - This API is created for integration with
-- OTM. Given a incident_id, the api queries from the incidents secure view.
-- The secure view validates if the responsibility performing the update has
-- access to the SR or not.
-- This will be invoked from - sr_uwq_integ.validate_security

PROCEDURE VALIDATE_USER_RESPONSIBILITY (
   p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2,
   p_commit                      IN      VARCHAR2,
   p_incident_id                 IN      NUMBER,
   x_resp_access_status          OUT     NOCOPY    VARCHAR2,
   x_return_status               OUT     NOCOPY    VARCHAR2,
   x_msg_count                   OUT     NOCOPY    NUMBER,
   x_msg_data                    OUT     NOCOPY    VARCHAR2 );

-- VALIDATE_RESOURCE - This API is created for integration with JTA assignment
-- manager. Given a service request id and type, and a list of resources, this API
-- returns back a list of resources (from the given list) who have access to
-- the Service Request.

PROCEDURE Validate_Resource (
   p_api_version                IN       NUMBER,
   p_init_msg_list              IN       VARCHAR2,
   p_commit                     IN       VARCHAR2,
   p_sr_rec                     IN       SR_REC_TYPE,
   px_resource_tbl              IN OUT   NOCOPY    RESOURCE_VALIDATE_TBL_TYPE,
   x_return_status              OUT      NOCOPY    VARCHAR2,
   x_msg_count                  OUT      NOCOPY    NUMBER,
   x_msg_data                   OUT      NOCOPY    VARCHAR2 );

END CS_SR_SECURITY_GRP;

 

/
