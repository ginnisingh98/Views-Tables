--------------------------------------------------------
--  DDL for Package FND_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_USER_PVT" AUTHID CURRENT_USER AS
-- $Header: AFSVWUSS.pls 120.3 2005/09/01 03:39:31 tmorrow ship $

G_PKG_NAME	CONSTANT VARCHAR2(30) := 'FND_USER_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'AFSVWUSB.pls';

/* DESUPPORTED.  DO NOT CALL */
PROCEDURE Create_User
(  p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate                   IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_customer_contact_id	IN	NUMBER   := NULL,
   p_date_format_mask		IN	VARCHAR2 := NULL,
   p_email_address		IN	VARCHAR2 := NULL,
   p_end_date_active		IN	DATE     := NULL,
   p_internal_contact_id	IN	NUMBER   := NULL,
   p_known_as			IN	VARCHAR2 := NULL,
   p_language			IN	VARCHAR2 := 'AMERICAN',   -- ????
   p_last_login_date		IN	DATE	 := NULL,
   p_limit_connects		IN	NUMBER   := NULL,
   p_limit_time			IN	NUMBER   := NULL,
   p_host_port			IN      VARCHAR2,
   p_password			IN	VARCHAR2,
   p_supplier_contact_id	IN	NUMBER   := NULL,
   p_username			IN	VARCHAR2,
   p_created_by			IN	NUMBER,
   p_creation_date		IN	DATE,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER   := NULL,
   p_user_id			OUT NOCOPY	NUMBER
);


/* DESUPPORTED.  DO NOT CALL */
PROCEDURE Update_User
(  p_api_version_number		IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_simulate			IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status		OUT NOCOPY	VARCHAR2,
   p_msg_count			OUT NOCOPY	NUMBER,
   p_msg_data			OUT NOCOPY	VARCHAR2,
   p_user_id			IN	NUMBER,
   p_customer_contact_id	IN	NUMBER   := FND_API.G_MISS_NUM,
   p_date_format_mask		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_numeric_characters         IN     VARCHAR2 := FND_API.G_MISS_CHAR,
   p_territory                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_email_address		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_end_date_active		IN	DATE     := FND_API.G_MISS_DATE,
   p_internal_contact_id	IN	NUMBER   := FND_API.G_MISS_NUM,
   p_known_as			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_language			IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_last_login_date		IN	DATE	 := FND_API.G_MISS_DATE,
   p_limit_connects		IN	NUMBER   := FND_API.G_MISS_NUM,
   p_limit_time			IN	NUMBER   := FND_API.G_MISS_NUM,
   p_host_port			IN     VARCHAR2 := FND_API.G_MISS_CHAR,
   p_old_password		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_new_password		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_supplier_contact_id	IN	NUMBER   := FND_API.G_MISS_NUM,
   p_last_updated_by		IN	NUMBER,
   p_last_update_date		IN	DATE,
   p_last_update_login		IN	NUMBER := NULL
);

END FND_USER_PVT;

 

/
