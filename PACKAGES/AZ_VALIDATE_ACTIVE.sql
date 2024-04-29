--------------------------------------------------------
--  DDL for Package AZ_VALIDATE_ACTIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_VALIDATE_ACTIVE" AUTHID CURRENT_USER AS
/* $Header: azvalidateactvs.pls 120.0 2006/02/06 22:34:30 gagupta noship $ */

  -- Author  : GAGUPTA
  -- Created : 1/10/2006 7:16:46 PM
  -- Purpose : update the added 'active' column for az_requests

  PROCEDURE validate_active;
  PROCEDURE activate_apis;
  FUNCTION validate_active_request(p_job_name     IN VARCHAR2,
                                   p_request_type IN VARCHAR2,
                                   p_user_id      IN NUMBER)
    RETURN VARCHAR2;

END az_validate_active;

 

/
