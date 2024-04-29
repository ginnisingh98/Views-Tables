--------------------------------------------------------
--  DDL for Package FND_CLIENT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CLIENT_INFO" AUTHID CURRENT_USER as
/* $Header: AFCINFOS.pls 120.1.12000000.3 2007/04/17 14:05:14 pdeluna ship $ */


--
-- This package-level pragma means that the initialization section of this
-- package cannot write any DB or package status
--
-- Currently, this package has no initialization section
--

pragma restrict_references (fnd_client_info, WNPS, WNDS);

--
-- Name
--   setup_client_info
-- Purpose
--   Sets up the operating unit context and the Multi-Currency context
--   in the client info area based on the current application,
--   responsibility, user, security group and organization.
--
-- Arguments
--   application_id
--   responsibility_id
--   user_id
--   security_group_id
--   org_id
--
procedure setup_client_info(application_id in number,
                            responsibility_id in number,
                            user_id in number,
                            security_group_id in number,
                            org_id in number);
--
-- Name
--   setup_client_info
-- Purpose
--   Sets up the operating unit context and the Multi-Currency context
--   in the client info area based on the current application,
--   responsibility, user, and security_group.
--   This is an overloaded version for backwards compatibility.
--
-- Arguments
--   application_id
--   responsibility_id
--   user_id
--   security_group_id
--
procedure setup_client_info(application_id in number,
                            responsibility_id in number,
                            user_id in number,
                            security_group_id in number);

--
-- Name
--   set_org_context
-- Purpose
--   Sets up the operating unit context in the client info area
--
-- Arguments
--   context    - org_id for the operating unit; can be up to 10
--                bytes long
--
procedure set_org_context (context in varchar2);

--
-- Name
--   set_currency_context
-- Purpose
--   Sets up the client info area for Multi-Currency reporting
--
-- Arguments
--   context    - context information up to 10 bytes
--
procedure set_currency_context (context in varchar2);

--
-- Name
--   set_security_group_context
-- Purpose
--   Sets up the the security group context in the client info area
--
-- Arguments
--   context    - security_group_id; can be up to 10 bytes long
--
procedure set_security_group_context (context in varchar2);


--
-- Name
--   org_security
-- Purpose
--   Called by oracle server during parsing sql statment
--
-- Arguments
--   obj_schema   - schema of the object
--   obj_name     - name of the object
--
FUNCTION org_security(
  obj_schema          VARCHAR2
, obj_name            VARCHAR2
)
RETURN VARCHAR2;

end fnd_client_info;

 

/
