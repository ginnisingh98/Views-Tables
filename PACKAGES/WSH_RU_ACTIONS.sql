--------------------------------------------------------
--  DDL for Package WSH_RU_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RU_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: WSHRUACS.pls 120.0 2005/05/26 17:19:36 appldev noship $ */

  TYPE Privileges_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  TYPE Role_Definition_Type IS RECORD (
	ROLE_ID			NUMBER(15),
	NAME			VARCHAR2(30),
	DESCRIPTION		VARCHAR2(240),
	CREATED_BY		NUMBER(15),
	CREATION_DATE		DATE,
	LAST_UPDATED_BY		NUMBER(15),
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATE_LOGIN	NUMBER(15),
	PRIVILEGES		Privileges_Type
  );

  TYPE Custom_message_rec is RECORD
       (customized_activity_mesg_id wsh_customized_activity_msgs.customized_activity_mesg_id %TYPE
       ,role_id                     wsh_customized_activity_msgs.role_id%TYPE
       ,activity_code               wsh_customized_activity_msgs.activity_code%TYPE
       ,validation_code             wsh_customized_activity_msgs.validation_code%TYPE
       ,return_status               wsh_customized_activity_msgs.return_status%TYPE);

  TYPE custom_message_cache_rec is RECORD
       (user_id         number
       ,activity_code   wsh_customized_activity_msgs.activity_code%TYPE
       ,validation_code wsh_customized_activity_msgs.validation_code%TYPE
       ,return_status   wsh_customized_activity_msgs.return_status%TYPE );

  TYPE custom_message_cache_tbl is table of custom_message_cache_rec index by binary_integer;

  PROCEDURE Create_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
	x_rowid			OUT NOCOPY  VARCHAR2,
	x_role_id		OUT NOCOPY  NUMBER,
	x_return_status 	OUT NOCOPY  VARCHAR2);

  PROCEDURE Lock_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
        p_row_id                IN  Varchar2);

  PROCEDURE Update_Role_Definition(
	p_role_def_record	IN  OUT NOCOPY Role_Definition_Type,
	x_return_status 	OUT NOCOPY  VARCHAR2);

  PROCEDURE Delete_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
	x_return_status 	OUT NOCOPY  VARCHAR2);

  PROCEDURE Get_Organization_Privileges(
        p_organization_id       IN  NUMBER,
        x_privileges            OUT NOCOPY  Privileges_Type,
        x_return_status         OUT NOCOPY  VARCHAR2);

  PROCEDURE Entity_Access_In_Organization(
        p_entity_type           IN  VARCHAR2,
        p_organization_id       IN  NUMBER,
        x_access_type           OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2);

  PROCEDURE insert_customized_msgs(
        p_custom_message_rec    IN OUT NOCOPY custom_message_rec
       ,x_error_message         OUT NOCOPY VARCHAR2
       ,x_return_status         OUT NOCOPY VARCHAR2 );

  PROCEDURE update_customized_msgs(
        p_custom_message_rec    IN OUT NOCOPY custom_message_rec
       ,x_error_message         OUT NOCOPY VARCHAR2
       ,x_return_status         OUT NOCOPY VARCHAR2 );

  PROCEDURE delete_customized_msgs(
        p_custom_message_rec    IN OUT NOCOPY custom_message_rec
       ,x_error_message         OUT NOCOPY VARCHAR2
       ,x_return_status         OUT NOCOPY VARCHAR2 );

  FUNCTION get_message_severity (
        p_activity_code         IN VARCHAR2
       ,p_validation_code       IN VARCHAR2) return VARCHAR2;


END WSH_RU_ACTIONS;

 

/
