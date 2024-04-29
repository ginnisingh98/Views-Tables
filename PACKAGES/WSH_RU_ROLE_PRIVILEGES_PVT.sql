--------------------------------------------------------
--  DDL for Package WSH_RU_ROLE_PRIVILEGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RU_ROLE_PRIVILEGES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHRPTHS.pls 115.3 2003/09/16 22:47:38 sperera ship $ */

  TYPE Role_Privilege_Type IS RECORD (
	ROLE_PRIVILEGE_ID	NUMBER(15),
	ROLE_ID			NUMBER(15),
	PRIVILEGE_CODE		VARCHAR2(30),
	CREATED_BY		NUMBER(15),
	CREATION_DATE		DATE,
	LAST_UPDATED_BY		NUMBER(15),
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATE_LOGIN	NUMBER(15)
  );

  PROCEDURE Insert_Row(
	p_role_privilege_record	IN  Role_Privilege_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_role_privilege_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Lock_Row(
	p_rowid		IN VARCHAR2,
	p_role_privilege_record	IN Role_Privilege_Type);

  PROCEDURE Update_Row(
	p_rowid		IN  VARCHAR2,
	p_role_privilege_record	IN  Role_Privilege_Type,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Delete_Row(
	p_rowid		IN  VARCHAR2,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Delete_Role_Privileges(
        p_role_id       IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2);



END WSH_RU_ROLE_PRIVILEGES_PVT;

 

/
