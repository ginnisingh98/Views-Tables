--------------------------------------------------------
--  DDL for Package WSH_RU_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_RU_GRANTS_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHGRTHS.pls 115.2 2002/11/12 01:35:37 nparikh ship $ */

  TYPE Grant_Type IS RECORD (
	GRANT_ID		NUMBER(15),
	USER_ID			NUMBER(15),
	ROLE_ID			NUMBER(15),
	ORGANIZATION_ID		NUMBER(15),
	START_DATE		DATE,
	END_DATE		DATE,
	CREATED_BY		NUMBER(15),
	CREATION_DATE		DATE,
	LAST_UPDATED_BY		NUMBER(15),
	LAST_UPDATE_DATE	DATE,
	LAST_UPDATE_LOGIN	NUMBER(15)
  );

  PROCEDURE Insert_Row(
	p_grant_record	IN  Grant_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_grant_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Lock_Row(
	p_rowid		IN VARCHAR2,
	p_grant_record	IN Grant_Type);

  PROCEDURE Update_Row(
	p_rowid		IN  VARCHAR2,
	p_grant_record	IN  Grant_Type,
	x_return_status OUT NOCOPY  VARCHAR2);

  PROCEDURE Delete_Row(
	p_rowid		IN  VARCHAR2,
	x_return_status OUT NOCOPY  VARCHAR2);

END WSH_RU_GRANTS_PVT;

 

/
