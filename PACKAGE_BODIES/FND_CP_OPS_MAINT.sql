--------------------------------------------------------
--  DDL for Package Body FND_CP_OPS_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_OPS_MAINT" as
/* $Header: AFCPOPMB.pls 115.7 2004/02/06 23:00:21 pferguso noship $ */


  --
  -- Name
  --   Expand
  -- Purpose
  --   Called to extend the partitions as new ops instances are added.
  --
  FUNCTION Expand return boolean is

  begin
   return true;
  end;


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
  FUNCTION Validate(Req_ID in number default null) return boolean is

  begin
   return true;
  end;


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
  FUNCTION Migrate(Req_ID in number, OPS_ID in number) return boolean is

  begin
    return true;
  end;

 PROCEDURE Register_Instance (
                INSTANCE_NUMBER IN NUMBER,
                SERVICE_NAME IN VARCHAR2,
                DESCRIPTION in VARCHAR2) is

begin
  null;
end;


end FND_CP_OPS_MAINT;

/
