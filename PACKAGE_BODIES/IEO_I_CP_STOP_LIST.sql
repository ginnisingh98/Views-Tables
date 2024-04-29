--------------------------------------------------------
--  DDL for Package Body IEO_I_CP_STOP_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_I_CP_STOP_LIST" AS
/* $Header: IEOISTPB.pls 120.0 2005/06/02 10:45:29 appldev noship $ */

------------------------------------------------------------------------------
--  Procedure   : STOP_LIST_INSERT
------------------------------------------------------------------------------

PROCEDURE STOP_LIST_INSERT(
	p_StopListKey	IN  IEO_CP_STOP_LIST.CP_STOP_LIST_KEY%TYPE,
	p_TelNumber	IN  IEO_CP_STOP_LIST.TELEPHONE_NUMBER%TYPE DEFAULT null,
	p_CustId	IN  IEO_CP_STOP_LIST.CUSTOMER_ID%TYPE DEFAULT null,
	p_TimeZone	IN  IEO_CP_STOP_LIST.TIME_ZONE%TYPE DEFAULT null,
	p_ExpireDate	IN  IEO_CP_STOP_LIST.STOP_EXPIRES_DATE%TYPE DEFAULT null,
	p_Campaign	IN  IEO_CP_STOP_LIST.CAMPAIGN%TYPE DEFAULT null,
	p_StopListCode	IN  IEO_CP_STOP_LIST.STOP_LIST_CODE%TYPE DEFAULT null,
	p_CreateBy	IN  IEO_CP_STOP_LIST.CREATED_BY%TYPE,
	p_CreateDate	IN  IEO_CP_STOP_LIST.CREATION_DATE%TYPE DEFAULT sysdate,
	p_LastUpdateBy	IN  IEO_CP_STOP_LIST.LAST_UPDATED_BY%TYPE,
	p_LastUpdateDate IN  IEO_CP_STOP_LIST.LAST_UPDATE_DATE%TYPE DEFAULT sysdate,
	p_LastUpdateLogin IN IEO_CP_STOP_LIST.LAST_UPDATE_LOGIN%TYPE DEFAULT null)
	AS
BEGIN
	-- insert a new row in table
	INSERT INTO IEO_CP_STOP_LIST(CP_STOP_LIST_KEY,TELEPHONE_NUMBER,CUSTOMER_ID,TIME_ZONE,STOP_EXPIRES_DATE,
	CAMPAIGN,STOP_LIST_CODE,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN) VALUES(p_StopListKey,p_TelNumber,p_CustId,p_TimeZone,
	p_ExpireDate,p_Campaign,p_StopListCode,p_CreateBy,p_CreateDate,p_LastUpdateBy,
	p_LastUpdateDate,p_LastUpdateLogin);

END STOP_LIST_INSERT;
END IEO_I_CP_STOP_LIST;

/
