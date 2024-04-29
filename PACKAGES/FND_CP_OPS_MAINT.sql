--------------------------------------------------------
--  DDL for Package FND_CP_OPS_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_OPS_MAINT" AUTHID CURRENT_USER as
/* $Header: AFCPOPMS.pls 115.4 2002/02/08 19:51:36 nbhambha ship $ */


  --
  -- Name
  --   Expand
  -- Purpose
  --   Called to extend the partitions as new ops instances are added.
  --
  FUNCTION Expand return boolean;

  --
  -- Name
  --   Validate
  -- Purpose
  --   Called to correct issues such as post proc actions being in different
  --   Instance as the parent request.
  -- Arguments
  --   Req_ID		- Request to be repaired (null for all requests).
  -- Note
  --   Will only function on Pending and completed requests.
  --
  FUNCTION Validate(Req_ID in number default null) return boolean;

  --
  -- Name
  --   Migrate
  -- Purpose
  --   Called to migrate a request to a different instance.
  -- Arguments
  --   Req_ID           - Request to be moved.
  --   OPS_ID           - Destination OPS Instance ID.
  -- Note
  --   Will only function on Pending and completed requests.  Calls Validate.
  --
  FUNCTION Migrate(Req_ID in number, OPS_ID in number) return boolean;

  PROCEDURE Register_Instance (
 		INSTANCE_NUMBER IN NUMBER,
 		SERVICE_NAME IN VARCHAR2,
                DESCRIPTION in VARCHAR2);

end FND_CP_OPS_MAINT;

 

/
