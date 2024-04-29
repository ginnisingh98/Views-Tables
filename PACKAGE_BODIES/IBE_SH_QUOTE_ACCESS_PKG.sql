--------------------------------------------------------
--  DDL for Package Body IBE_SH_QUOTE_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SH_QUOTE_ACCESS_PKG" as
/* $Header: IBEVSCSB.pls 115.3 2003/01/30 03:29:33 mannamra ship $ */

G_PKG_NAME  CONSTANT  VARCHAR2(30) := 'IBE_SH_QUOTE_ACCESS_PVT';

PROCEDURE Insert_Row
(
  p_quote_sharee_id            IN NUMBER := FND_API.G_MISS_NUM,
  p_request_id                 IN NUMBER := FND_API.G_MISS_NUM,
  p_program_application_id     IN NUMBER := FND_API.G_MISS_NUM,
  p_program_id                 IN NUMBER := FND_API.G_MISS_NUM,
  p_program_update_date        IN DATE   := FND_API.G_MISS_DATE,
  p_object_version_number      IN NUMBER := FND_API.G_MISS_NUM,
  p_created_by                 IN NUMBER := FND_GLOBAL.USER_ID,
  p_creation_date              IN DATE   := SYSDATE           ,
  p_last_updated_by            IN NUMBER := FND_GLOBAL.USER_ID,
  p_last_update_date           IN DATE   := SYSDATE           ,
  p_last_update_login          IN NUMBER := FND_API.G_MISS_NUM,
  p_quote_header_id            IN NUMBER := FND_API.G_MISS_NUM,
  p_quote_sharee_number		   IN NUMBER := FND_API.G_MISS_NUM,
  p_update_privilege_type_code IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_security_group_id          IN NUMBER := FND_API.G_MISS_NUM,
  p_party_id                   IN NUMBER := FND_API.G_MISS_NUM,
  p_cust_account_id            IN NUMBER := FND_API.G_MISS_NUM,
  p_start_date_active          IN DATE   := SYSDATE           ,
  p_end_date_active            IN DATE   := FND_API.G_MISS_DATE,
  p_recipient_name             IN VARCHAR2 := FND_API.G_MISS_CHAR,
  p_contact_point_id           IN NUMBER := FND_API.G_MISS_NUM
)
IS

BEGIN

  INSERT INTO IBE_SH_QUOTE_ACCESS (
    QUOTE_SHAREE_ID           ,
	REQUEST_ID                ,
	PROGRAM_APPLICATION_ID    ,
	PROGRAM_ID                ,
	PROGRAM_UPDATE_DATE       ,
	OBJECT_VERSION_NUMBER     ,
	CREATED_BY                ,
	CREATION_DATE             ,
	LAST_UPDATED_BY           ,
	LAST_UPDATE_DATE          ,
	LAST_UPDATE_LOGIN         ,
	QUOTE_HEADER_ID           ,
	QUOTE_SHAREE_NUMBER       ,
	UPDATE_PRIVILEGE_TYPE_CODE,
	SECURITY_GROUP_ID         ,
    PARTY_ID                  ,
    CUST_ACCOUNT_ID           ,
    START_DATE_ACTIVE         ,
    END_DATE_ACTIVE           ,
    RECIPIENT_NAME            ,
    CONTACT_POINT_ID

  ) VALUES (

    DECODE(p_quote_sharee_id            ,FND_API.G_MISS_NUM,NULL,p_quote_sharee_id),
    DECODE(p_REQUEST_ID                 ,FND_API.G_MISS_NUM,NULL,p_REQUEST_ID),
    DECODE(p_PROGRAM_APPLICATION_ID     ,FND_API.G_MISS_NUM,NULL,p_PROGRAM_APPLICATION_ID),
    DECODE(p_PROGRAM_ID                 ,FND_API.G_MISS_NUM,NULL,p_PROGRAM_ID),
    DECODE(p_PROGRAM_UPDATE_DATE        ,FND_API.G_MISS_DATE,NULL,p_PROGRAM_UPDATE_DATE),
    DECODE(p_OBJECT_VERSION_NUMBER      ,FND_API.G_MISS_NUM,NULL,p_OBJECT_VERSION_NUMBER),
    DECODE(p_CREATED_BY                 ,FND_API.G_MISS_NUM,NULL,p_CREATED_BY),
    DECODE(p_CREATION_DATE              ,FND_API.G_MISS_DATE,NULL,p_CREATION_DATE),
    DECODE(p_LAST_UPDATED_BY            ,FND_API.G_MISS_NUM,NULL,p_LAST_UPDATED_BY),
    DECODE(p_LAST_UPDATE_DATE           ,FND_API.G_MISS_DATE,NULL,p_LAST_UPDATE_DATE),
    DECODE(p_LAST_UPDATE_LOGIN          ,FND_API.G_MISS_NUM,NULL,p_LAST_UPDATE_LOGIN),
    DECODE(p_QUOTE_HEADER_ID            ,FND_API.G_MISS_NUM,NULL,p_QUOTE_HEADER_ID),
    DECODE(p_QUOTE_SHAREE_NUMBER        ,FND_API.G_MISS_NUM,NULL,p_QUOTE_SHAREE_NUMBER),
    DECODE(p_UPDATE_PRIVILEGE_TYPE_CODE ,FND_API.G_MISS_CHAR,NULL,p_UPDATE_PRIVILEGE_TYPE_CODE),
    DECODE(p_SECURITY_GROUP_ID          ,FND_API.G_MISS_NUM,NULL,p_SECURITY_GROUP_ID),
    DECODE(p_PARTY_ID                   ,FND_API.G_MISS_NUM,NULL,p_PARTY_ID),
    DECODE(p_CUST_ACCOUNT_ID            ,FND_API.G_MISS_NUM,NULL,p_CUST_ACCOUNT_ID),
    DECODE(p_START_DATE_ACTIVE          ,FND_API.G_MISS_DATE,NULL,p_START_DATE_ACTIVE),
    DECODE(p_END_DATE_ACTIVE            ,FND_API.G_MISS_DATE,NULL,p_END_DATE_ACTIVE),
    DECODE(p_RECIPIENT_NAME             ,FND_API.G_MISS_CHAR,NULL,p_RECIPIENT_NAME),
    DECODE(p_CONTACT_POINT_ID           ,FND_API.G_MISS_NUM,NULL,p_CONTACT_POINT_ID)
    );

    /* p_REQUEST_ID                ,
    p_PROGRAM_APPLICATION_ID     ,
    p_PROGRAM_ID                 ,
    p_PROGRAM_UPDATE_DATE        ,
    p_OBJECT_VERSION_NUMBER      ,
    p_CREATED_BY                 ,
    p_CREATION_DATE              ,
    p_LAST_UPDATED_BY            ,
    p_LAST_UPDATE_DATE           ,
    p_LAST_UPDATE_LOGIN          ,
    p_QUOTE_HEADER_ID            ,
    p_QUOTE_SHAREE_NUMBER        ,
    p_UPDATE_PRIVILEGE_TYPE_CODE ,
    p_SECURITY_GROUP_ID          ,
    p_PARTY_ID                   ,
    p_CUST_ACCOUNT_ID            ,
    p_START_DATE_ACTIVE          ,
    p_END_DATE_ACTIVE            ,
    p_RECIPIENT_NAME             ,
    p_CONTACT_POINT_ID
    );*/


END Insert_Row;


PROCEDURE Update_Row
(
p_QUOTE_SHAREE_ID               IN NUMBER    := FND_API.G_MISS_NUM,
p_REQUEST_ID                    IN NUMBER    := FND_API.G_MISS_NUM,
p_PROGRAM_APPLICATION_ID        IN NUMBER    := FND_API.G_MISS_NUM,
p_PROGRAM_ID                    IN NUMBER    := FND_API.G_MISS_NUM,
p_PROGRAM_UPDATE_DATE           IN DATE      := FND_API.G_MISS_DATE,
p_OBJECT_VERSION_NUMBER         IN NUMBER    := FND_API.G_MISS_NUM,
p_CREATED_BY                    IN NUMBER    := FND_API.G_MISS_NUM,
p_CREATION_DATE                 IN DATE      := FND_API.G_MISS_DATE,
p_LAST_UPDATED_BY               IN NUMBER    := FND_GLOBAL.USER_ID,
p_LAST_UPDATE_DATE              IN DATE      := SYSDATE,
p_LAST_UPDATE_LOGIN             IN NUMBER    := FND_API.G_MISS_NUM,
p_QUOTE_HEADER_ID               IN NUMBER    := FND_API.G_MISS_NUM,
p_QUOTE_SHAREE_NUMBER           IN NUMBER    := FND_API.G_MISS_NUM,
p_UPDATE_PRIVILEGE_TYPE_CODE    IN VARCHAR2  := FND_API.G_MISS_CHAR,
p_SECURITY_GROUP_ID             IN NUMBER    := FND_API.G_MISS_NUM,
p_PARTY_ID                      IN NUMBER    := FND_API.G_MISS_NUM,
p_CUST_ACCOUNT_ID               IN NUMBER    := FND_API.G_MISS_NUM,
p_START_DATE_ACTIVE             IN DATE      := FND_API.G_MISS_DATE,
p_END_DATE_ACTIVE               IN DATE      := FND_API.G_MISS_DATE,
p_RECIPIENT_NAME                IN VARCHAR2  := FND_API.G_MISS_CHAR,
p_CONTACT_POINT_ID              IN NUMBER    := FND_API.G_MISS_NUM
)
IS

BEGIN

  UPDATE IBE_SH_QUOTE_ACCESS
  SET
--    QUOTE_SHAREE_ID            = decode(p_QUOTE_SHAREE_ID,FND_API.G_MISS_NUM,QUOTE_SHAREE_ID, p_QUOTE_SHAREE_ID),
    REQUEST_ID                 = decode(p_REQUEST_ID,FND_API.G_MISS_NUM,REQUEST_ID, p_REQUEST_ID),
    PROGRAM_APPLICATION_ID     = decode(p_PROGRAM_APPLICATION_ID,FND_API.G_MISS_NUM,PROGRAM_APPLICATION_ID,
                                       p_PROGRAM_APPLICATION_ID),
    PROGRAM_ID                 = decode(p_PROGRAM_ID,FND_API.G_MISS_NUM,PROGRAM_ID, p_PROGRAM_ID),
    PROGRAM_UPDATE_DATE        = decode(p_PROGRAM_UPDATE_DATE,FND_API.G_MISS_DATE,PROGRAM_UPDATE_DATE,
                                        p_PROGRAM_UPDATE_DATE),
    OBJECT_VERSION_NUMBER      = decode(p_OBJECT_VERSION_NUMBER,FND_API.G_MISS_NUM,OBJECT_VERSION_NUMBER,
                                       p_OBJECT_VERSION_NUMBER),
    CREATED_BY                 = decode(p_CREATED_BY,FND_API.G_MISS_NUM,CREATED_BY, p_CREATED_BY),
    CREATION_DATE              = decode(p_CREATION_DATE,FND_API.G_MISS_DATE,CREATION_DATE, p_CREATION_DATE),
    LAST_UPDATED_BY            = decode(p_LAST_UPDATED_BY,FND_API.G_MISS_NUM,LAST_UPDATED_BY, p_LAST_UPDATED_BY),
    LAST_UPDATE_DATE           = decode(p_LAST_UPDATE_DATE,FND_API.G_MISS_DATE,LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
    LAST_UPDATE_LOGIN          = decode(p_LAST_UPDATE_LOGIN,FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
    QUOTE_HEADER_ID            = decode(p_QUOTE_HEADER_ID,FND_API.G_MISS_NUM,QUOTE_HEADER_ID, p_QUOTE_HEADER_ID),
    QUOTE_SHAREE_NUMBER        = decode(p_QUOTE_SHAREE_NUMBER,FND_API.G_MISS_NUM,QUOTE_SHAREE_NUMBER,
                                       p_QUOTE_SHAREE_NUMBER),
    UPDATE_PRIVILEGE_TYPE_CODE = decode(p_UPDATE_PRIVILEGE_TYPE_CODE,FND_API.G_MISS_CHAR,UPDATE_PRIVILEGE_TYPE_CODE,
                                       p_UPDATE_PRIVILEGE_TYPE_CODE),
    SECURITY_GROUP_ID          = decode(p_SECURITY_GROUP_ID,FND_API.G_MISS_NUM,SECURITY_GROUP_ID, p_SECURITY_GROUP_ID),
    PARTY_ID                   = decode(p_PARTY_ID,FND_API.G_MISS_NUM,PARTY_ID, p_PARTY_ID),
    CUST_ACCOUNT_ID            = decode(p_CUST_ACCOUNT_ID,FND_API.G_MISS_NUM,CUST_ACCOUNT_ID, p_CUST_ACCOUNT_ID),
    START_DATE_ACTIVE          = decode(p_START_DATE_ACTIVE,FND_API.G_MISS_DATE,START_DATE_ACTIVE, p_START_DATE_ACTIVE),
    END_DATE_ACTIVE            = decode(p_END_DATE_ACTIVE,FND_API.G_MISS_DATE,END_DATE_ACTIVE, p_END_DATE_ACTIVE),
    RECIPIENT_NAME             = decode(p_RECIPIENT_NAME,FND_API.G_MISS_CHAR,RECIPIENT_NAME, p_RECIPIENT_NAME),
    CONTACT_POINT_ID           = decode(p_CONTACT_POINT_ID,FND_API.G_MISS_NUM,CONTACT_POINT_ID, p_CONTACT_POINT_ID)

  WHERE
  	/*    quote_header_id = p_quote_header_id
    and party_id        = p_party_id
    and cust_account_id = p_cust_account_id;*/
    quote_sharee_id = p_quote_sharee_id;

  IF (SQL%NOTFOUND) THEN
  	RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

PROCEDURE Delete_Row
(
  p_quote_header_id	IN	NUMBER,
  p_party_id        IN  NUMBER,
  p_cust_account_id IN  NUMBER
)
IS

BEGIN

  DELETE FROM IBE_SH_QUOTE_ACCESS
  WHERE quote_header_id = p_quote_header_id
  and   party_id        = p_party_id
  and   cust_account_id = p_cust_account_id;

  IF (SQL%NOTFOUND) THEN
  	RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;



END IBE_SH_QUOTE_ACCESS_PKG;

/
