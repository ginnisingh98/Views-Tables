--------------------------------------------------------
--  DDL for Package CS_INCIDENTLINKS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INCIDENTLINKS_UTIL" AUTHID CURRENT_USER AS
/* $Header: csusrls.pls 115.7 2003/09/17 06:58:53 dejoseph noship $ */

   -- Procedure to validate if the passed in link type id is valid.
   -- Basic sanity validation
   PROCEDURE VALIDATE_LINK_TYPE (
      P_LINK_TYPE_ID            IN           NUMBER := NULL,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Procedure to validate if the passed in subject, object and link type
   -- are valid combination.
   -- Rule : A link instance should have a valid subject type, object type and
   --        link type combination.
   PROCEDURE VALIDATE_LINK_SUB_OBJ_TYPE (
      P_SUBJECT_TYPE            IN           VARCHAR2,
      P_OBJECT_TYPE             IN           VARCHAR2,
      P_LINK_TYPE_ID            IN           NUMBER,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Procedure to validate if the passed in subject and object details are
   -- valid defnitions in their respective schemas. ie. If the subject type
   -- is SR, need to validate if the 'subject_id' is a valid 'incident_id'
   -- in cs_incidents_all_b table.
   -- This procedure can be called with either the subject details or the
   -- object details.
   PROCEDURE VALIDATE_LINK_DETAILS (
      P_SUBJECT_ID              IN           NUMBER    := NULL,
      P_SUBJECT_TYPE            IN           VARCHAR2  := NULL,
      P_OBJECT_ID               IN           NUMBER    := NULL,
      P_OBJECT_TYPE             IN           VARCHAR2  := NULL,
      P_OBJECT_NUMBER           IN           VARCHAR2  := NULL,
      X_SUBJECT_NUMBER          OUT NOCOPY   VARCHAR2,
      X_OBJECT_NUMBER           OUT NOCOPY   VARCHAR2,
      X_SUBJECT_TYPE_NAME       OUT NOCOPY   VARCHAR2,
      X_OBJECT_TYPE_NAME        OUT NOCOPY   VARCHAR2,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Procedure to validate the uniqueness of the link being created.
   -- Rule : Two linked objects cannot have more than one link pair between them.
   -- Note : Object number is an IN parameter, because sometimes the object_id may
   --        be null.
   PROCEDURE VALIDATE_LINK_UNIQUENESS (
      P_SUBJECT_ID              IN           NUMBER,
      P_SUBJECT_TYPE            IN           VARCHAR2,
      P_OBJECT_ID               IN           NUMBER,
      P_OBJECT_TYPE             IN           VARCHAR2,
      P_OBJECT_NUMBER           IN           VARCHAR2,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Procedure to validate if the creation of the link will result in a circular
   -- dependency.
   -- Rule : Prevent creation of circular dependency regardless of link type.
   PROCEDURE VALIDATE_LINK_CIRCULARS (
      P_SUBJECT_ID              IN           NUMBER,
      P_SUBJECT_TYPE            IN           VARCHAR2,
      P_OBJECT_ID               IN           NUMBER,
      P_OBJECT_TYPE             IN           VARCHAR2,
      P_LINK_TYPE_ID            IN           NUMBER,
      P_SUBJECT_NUMBER          IN           VARCHAR2,
      P_OBJECT_NUMBER           IN           VARCHAR2,
      P_SUBJECT_TYPE_NAME       IN           VARCHAR2,
      P_OBJECT_TYPE_NAME        IN           VARCHAR2,
      P_OPERATION_MODE          IN           VARCHAR2 := 'CREATE',
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Procedure to validate that a duplicate link can have exactly only one
   -- original. For eg. if SR1 is duplicate of SR2, SR1 cannot be a duplicate
   -- of SR3 as well. Rather SR3 should be created as a duplicate of SR2.
   -- Rule : A duplicate object must have exactly 1 original.
   PROCEDURE VALIDATE_LINK_DUPLICATES (
      P_SUBJECT_ID              IN           NUMBER,
      P_SUBJECT_TYPE            IN           VARCHAR2,
      P_OBJECT_ID               IN           NUMBER,
      P_OBJECT_TYPE             IN           VARCHAR2,
      P_LINK_TYPE_ID            IN           NUMBER,
      P_SUBJECT_NUMBER          IN           VARCHAR2,
      P_OBJECT_NUMBER           IN           VARCHAR2,
      P_SUBJECT_TYPE_NAME       IN           VARCHAR2,
      P_OBJECT_TYPE_NAME        IN           VARCHAR2,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- Validation procedure to implement Service Security introduced in
   -- R11.5.10
   -- Procedure to validate if the responsibilty creating / updating the link
   -- has access to the subject and/or object if they are service requests.
   -- The query is based on the incidents secure view for which a VPD policy
   -- is defined.
   PROCEDURE VALIDATE_SR_SEC_ACCESS (
      P_INCIDENT_ID       IN           NUMBER,
      X_RETURN_STATUS     OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT         OUT NOCOPY   NUMBER,
      X_MSG_DATA          OUT NOCOPY   VARCHAR2 );

END CS_INCIDENTLINKS_UTIL;

 

/
