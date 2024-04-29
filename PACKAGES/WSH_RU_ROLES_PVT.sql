--------------------------------------------------------
--  DDL for Package WSH_RU_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RU_ROLES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHROTHS.pls 115.2 2002/11/12 01:50:24 nparikh ship $ */

  TYPE Role_Type IS RECORD (
	ROLE_ID			NUMBER(15),
	NAME			VARCHAR2(30),
	DESCRIPTION		VARCHAR2(240),
	CREATED_BY		NUMBER(15),
	CREATION_DATE		DATE,
	LAST_UPDATED_BY		NUMBER(15),
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATE_LOGIN	NUMBER(15)
  );

  PROCEDURE Insert_Row(
	p_role_record	IN  Role_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_role_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Lock_Row(
	p_rowid		IN VARCHAR2,
	p_role_record	IN Role_Type);

  PROCEDURE Update_Row(
	p_rowid		IN  VARCHAR2,
	p_role_record	IN  Role_Type,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Delete_Row(
	p_rowid		IN  VARCHAR2,
	x_return_status OUT NOCOPY  VARCHAR2);

END WSH_RU_ROLES_PVT;

 

/
