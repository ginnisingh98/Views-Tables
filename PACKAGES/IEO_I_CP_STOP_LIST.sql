--------------------------------------------------------
--  DDL for Package IEO_I_CP_STOP_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_I_CP_STOP_LIST" AUTHID CURRENT_USER AS
/* $Header: IEOISTPS.pls 120.0 2005/06/02 10:30:42 appldev noship $ */

------------------------------------------------------------------------------------
--  Procedure   : STOP_LIST_INSERT
--  Description : insert date into table IEO_CP_STOP_LIST
--  Parameters  :
--  IN          : p_StopListKey	IN  IEO_CP_STOP_LIST.STOP_LIST_KEY%TYPE		Required
--                      Value of the STOP_LIST_KEY.
--				  p_TelNumber	IN  IEO_CP_STOP_LIST.TELEPHONE_NUMBER%TYPE
--                      Value of the TELEPHONE_NUMBER.
--				  p_CustId	IN  IEO_CP_STOP_LIST.CUSTOMER_ID%TYPE
--                      Value of the CUSTOMER_ID.
--				  p_TimeZone	IN  IEO_CP_STOP_LIST.TIME_ZONE%TYPE
--                      Value of the TIME_ZONE.
--				  p_ExpireDate	IN  IEO_CP_STOP_LIST.STOP_EXPIRES_DATE%TYPE
--                      Value of the STOP_EXPIRES_DATE.
--				  p_Campaign	IN  IEO_CP_STOP_LIST.CAMPAIGN%TYPE
--                      Value of the CAMPAIGN.
--				  p_StopListCode	IN  IEO_CP_STOP_LIST.STOP_LIST_CODE%TYPE
--                      Value of the STOP_LIST_CODE.
--				  p_CreateBy	IN  IEO_CP_STOP_LIST.CREATED_BY%TYPE		Required
--                      Value of the CREATED_BY.
--				  p_CreateDate	IN  IEO_CP_STOP_LIST.CREATION_DATE%TYPE
--                      Value of the CREATION_DATE.
--				  p_LastUpdateBy	IN  IEO_CP_STOP_LIST.LAST_UPDATED_BY%TYPE	Required
--                      Value of the LAST_UPDATED_BY.
--				  p_LastUpdateDate IN  IEO_CP_STOP_LIST.LAST_UPDATE_DATE%TYPE
--                      Value of the LAST_UPDATE_DATE.
--                p_LastUpdateLogin IN IEO_CP_STOP_LIST.LAST_UPDATE_LOGIN%TYPE
--                      Value of the LAST_UPDATE_LOGIN token.
-------------------------------------------------------------------------------------

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
	p_LastUpdateLogin IN IEO_CP_STOP_LIST.LAST_UPDATE_LOGIN%TYPE DEFAULT null);

END IEO_I_CP_STOP_LIST;

 

/
