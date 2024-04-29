--------------------------------------------------------
--  DDL for Package IBE_SH_QUOTE_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SH_QUOTE_ACCESS_PKG" AUTHID CURRENT_USER as
/* $Header: IBEVSCSS.pls 115.3 2003/01/30 03:30:45 mannamra ship $ */

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
);


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
p_LAST_UPDATE_DATE              IN DATE      := SYSDATE           ,
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
);



PROCEDURE Delete_Row
(
  p_quote_header_id	IN	NUMBER,
  p_party_id        IN  NUMBER,
  p_cust_account_id IN  NUMBER
);

END IBE_SH_QUOTE_ACCESS_PKG;

 

/
