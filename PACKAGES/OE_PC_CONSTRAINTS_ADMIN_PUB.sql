--------------------------------------------------------
--  DDL for Package OE_PC_CONSTRAINTS_ADMIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_CONSTRAINTS_ADMIN_PUB" AUTHID CURRENT_USER as
/* $Header: OEXPPCAS.pls 120.0 2005/06/01 02:33:05 appldev noship $ */

--  Start of Comments
--  API name    Generate_Constraint_API
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

---------------------------------------
PROCEDURE Generate_Constraint_API
(
   p_api_version_number	       in  number,
   p_application_id            in  number,
   p_entity_short_name         in  varchar2,
   x_script_file_name          out NOCOPY /* file.sql.39 change */ varchar2,
   x_return_status             out NOCOPY /* file.sql.39 change */ varchar2,
   x_msg_count	    	  	 out NOCOPY /* file.sql.39 change */ number,
   x_msg_data	    	    	 out NOCOPY /* file.sql.39 change */ varchar2
);
-----------------------------------------------------


-- FUNCTION Get_Authorized_WF_Roles:
-- Returns the list of WF Roles that are NOT constrained
-- by the conditions for a given constraint (p_constraint_id).

-- NOTE: This does not mean that these roles can perform the
-- constrained operation. There may be other constraints for
-- the same operation on this entity that are applicable to this role.

-----------------------------------------------------
FUNCTION Get_Authorized_WF_Roles
(
  p_constraint_id 		IN NUMBER
, x_return_status 		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
RETURN OE_PC_GLOBALS.Authorized_WF_Roles_TBL;
-----------------------------------------------------

-- PROCEDURE Add_Constraint_Message
-- For a constraint violation on a given object and for a given constraint
-- condition (constraint_id AND group_number), this procedure constructs
-- the message tokens for the name of the attribute, object and the
-- reason. Then adds the message to the OE message stack.
---------------------------------------
PROCEDURE Add_Constraint_Message
(  p_application_id		IN NUMBER
  ,p_database_object_name		IN VARCHAR2
  ,p_column_name		IN VARCHAR2
  ,p_operation			IN VARCHAR2
  ,p_constraint_id		IN NUMBER
  ,p_on_operation_action		IN NUMBER
  ,p_group_number		IN NUMBER
);
-----------------------------------------------------

END Oe_PC_Constraints_Admin_Pub;

 

/
