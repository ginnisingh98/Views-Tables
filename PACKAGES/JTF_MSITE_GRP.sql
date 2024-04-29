--------------------------------------------------------
--  DDL for Package JTF_MSITE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSITE_GRP" AUTHID CURRENT_USER AS
/* $Header: JTFGMSTS.pls 115.11 2004/07/09 18:50:08 applrt ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='JTF_Msite_GRP';
g_api_version CONSTANT NUMBER       := 1.0;


TYPE msite_rec_type  IS RECORD (
        msite_id              	NUMBER,
        Object_Version_Number   NUMBER,
        Display_name            VARCHAR2(30),
        Description             VARCHAR2(128),
        profile_id            	NUMBER,
        date_format            	VARCHAR2(30),
        walkin_allowed_code	VARCHAR2(1),
        atp_check_flag		VARCHAR2(1),
        msite_master_flag	VARCHAR2(1),
        msite_root_section_id	NUMBER,
        enable_for_store	VARCHAR2(1),
        --new fields for globalisation, added by ssridhar
        resp_access_flag        Varchar2(1),
        party_access_code       Varchar2(1),
        access_name             Varchar2(240),
        start_date_active       Date,
        end_date_active         Date ,
        url                     Varchar2(2000),
        theme_id                Number);


TYPE msite_currency_rec_type IS RECORD (
	currency_code		VARCHAR2(15),
	walkin_prc_lst_id   	NUMBER,
	registered_prc_lst_id 	NUMBER,
	biz_partner_prc_lst_id 	NUMBER,
	orderable_limit		NUMBER,
	default_flag    	VARCHAR2(1));

TYPE msite_language_rec_type is RECORD (
	language_code  VARCHAR2(4),
	default_flag   VARCHAR2(1)
	);

TYPE msite_orgid_rec_type IS RECORD (
	orgid		NUMBER,
	default_flag 	VARCHAR2(1)
	);

TYPE msite_delete_rec_type IS RECORD (
	msite_id		NUMBER,
	object_version_number 	NUMBER
	);


TYPE msite_currencies_tbl_type  IS TABLE OF
	   msite_currency_rec_type INDEX BY BINARY_INTEGER;

TYPE msite_languages_tbl_type  IS TABLE OF
	   msite_language_rec_type INDEX BY BINARY_INTEGER;

TYPE msite_orgids_tbl_type  IS TABLE OF
	   msite_orgid_rec_type INDEX BY BINARY_INTEGER;

TYPE msite_delete_tbl_type  IS TABLE OF
	   msite_delete_rec_type INDEX BY BINARY_INTEGER;

TYPE msite_prtyids_tbl_type  IS TABLE OF
	   NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE delete_msite(
   p_api_version        IN  	NUMBER,
   p_init_msg_list    	IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit             IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status      OUT 	VARCHAR2,
   x_msg_count          OUT  	NUMBER,
   x_msg_data           OUT  	VARCHAR2,
   p_msite_id_tbl       IN 	msite_delete_tbl_type
);

PROCEDURE save_msite(
   p_api_version      	IN  	NUMBER,
   p_init_msg_list    	IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit           	IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status   	OUT 	VARCHAR2,
   x_msg_count        	OUT  	NUMBER,
   x_msg_data         	OUT  	VARCHAR2,
   p_msite_rec   	IN OUT 	Msite_REC_TYPE
);

PROCEDURE save_msite_languages(
   p_api_version         IN  	NUMBER,
   p_init_msg_list       IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit              IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status       OUT 	VARCHAR2,
   x_msg_count           OUT  	NUMBER,
   x_msg_data            OUT  	VARCHAR2,
   p_msite_id		 IN   	NUMBER,
   p_msite_languages_tbl IN MSITE_LANGUAGES_TBL_TYPE
);

PROCEDURE save_msite_currencies(
   p_api_version         IN  	NUMBER,
   p_init_msg_list       IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit              IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status       OUT 	VARCHAR2,
   x_msg_count           OUT  	NUMBER,
   x_msg_data            OUT  	VARCHAR2,
   p_msite_id		 IN   	NUMBER,
   p_msite_currencies_tbl IN  MSITE_CURRENCIES_TBL_TYPE
);


PROCEDURE get_msite_attribute (
   p_api_version         	IN  	NUMBER,
   p_init_msg_list       	IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit              	IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status       	OUT 	VARCHAR2,
   x_msg_count           	OUT  	NUMBER,
   x_msg_data            	OUT  	VARCHAR2,
   p_msite_id		     	IN   	NUMBER,
  p_msite_attribute_name     	IN   	VARCHAR2,
   x_msite_attribute_value	OUT 	VARCHAR2);

PROCEDURE save_msite_orgids(
   p_api_version         IN  	NUMBER,
   p_init_msg_list       IN   	VARCHAR2 	:= FND_API.g_false,
   p_commit              IN  	VARCHAR2  	:= FND_API.g_false,
   x_return_status       OUT 	VARCHAR2,
   x_msg_count           OUT  	NUMBER,
   x_msg_data            OUT  	VARCHAR2,
   p_msite_id		 IN   	NUMBER,
   p_msite_orgids_tbl    IN  	MSITE_ORGIDS_TBL_TYPE
);

procedure INSERT_ROW (
  X_ROWID 			in out 	VARCHAR2,
  X_MSITE_ID 			in 	NUMBER,
  X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2,
  X_ATTRIBUTE1 			in 	VARCHAR2,
  X_ATTRIBUTE2 			in	VARCHAR2,
  X_ATTRIBUTE3 			in 	VARCHAR2,
  X_ATTRIBUTE4 			in 	VARCHAR2,
  X_ATTRIBUTE5 			in 	VARCHAR2,
  X_ATTRIBUTE6 			in 	VARCHAR2,
  X_ATTRIBUTE7 			in 	VARCHAR2,
  X_ATTRIBUTE8 			in 	VARCHAR2,
  X_ATTRIBUTE9 			in 	VARCHAR2,
  X_ATTRIBUTE11 		in 	VARCHAR2,
  X_ATTRIBUTE10 		in 	VARCHAR2,
  X_ATTRIBUTE12 		in 	VARCHAR2,
  X_ATTRIBUTE13 		in 	VARCHAR2,
  X_ATTRIBUTE14 		in 	VARCHAR2,
  X_ATTRIBUTE15 		in 	VARCHAR2,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OBJECT_VERSION_NUMBER	in 	NUMBER,
  X_STORE_ID 			in 	NUMBER,
  X_START_DATE_ACTIVE 		in 	DATE,
  X_END_DATE_ACTIVE 		in 	DATE,
  X_DEFAULT_LANGUAGE_CODE 	in 	VARCHAR2,
  X_DEFAULT_CURRENCY_CODE 	in 	VARCHAR2,
  X_DEFAULT_DATE_FORMAT 	in 	VARCHAR2,
  X_DEFAULT_ORG_ID 		in 	NUMBER,
  X_ATP_CHECK_FLAG 		in 	VARCHAR2,
  X_WALKIN_ALLOWED_FLAG 	in 	VARCHAR2,
  X_MSITE_ROOT_SECTION_ID 	in 	NUMBER,
  X_PROFILE_ID 			in 	NUMBER,
  X_MASTER_MSITE_FLAG 		in 	VARCHAR2,
  X_MSITE_NAME 			in 	VARCHAR2,
  X_MSITE_DESCRIPTION 		in 	VARCHAR2,
  X_CREATION_DATE 		in 	DATE,
  X_CREATED_BY 			in 	NUMBER,
  X_LAST_UPDATE_DATE 		in 	DATE,
  X_LAST_UPDATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_LOGIN 		in 	NUMBER ,
  X_RESP_ACCESS_FLAG            in      VARCHAR2 ,
  X_PARTY_ACCESS_CODE           in      VARCHAR2 ,
  X_ACCESS_NAME                 in      VARCHAR2 ,
  X_URL                         in      VARCHAR2 ,
  X_THEME_ID 			in 	NUMBER );

procedure LOCK_ROW (
  X_MSITE_ID 			in 	NUMBER,
  X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2,
  X_ATTRIBUTE1 			in 	VARCHAR2,
  X_ATTRIBUTE2 			in	VARCHAR2,
  X_ATTRIBUTE3 			in 	VARCHAR2,
  X_ATTRIBUTE4 			in 	VARCHAR2,
  X_ATTRIBUTE5 			in 	VARCHAR2,
  X_ATTRIBUTE6 			in 	VARCHAR2,
  X_ATTRIBUTE7 			in 	VARCHAR2,
  X_ATTRIBUTE8 			in 	VARCHAR2,
  X_ATTRIBUTE9 			in 	VARCHAR2,
  X_ATTRIBUTE11 		in 	VARCHAR2,
  X_ATTRIBUTE10 		in 	VARCHAR2,
  X_ATTRIBUTE12 		in 	VARCHAR2,
  X_ATTRIBUTE13 		in 	VARCHAR2,
  X_ATTRIBUTE14 		in 	VARCHAR2,
  X_ATTRIBUTE15 		in 	VARCHAR2,
  X_SECURITY_GROUP_ID 		in 	NUMBER,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_STORE_ID 			in 	NUMBER,
  X_START_DATE_ACTIVE 		in 	DATE,
  X_END_DATE_ACTIVE 		in 	DATE,
  X_DEFAULT_LANGUAGE_CODE 	in 	VARCHAR2,
  X_DEFAULT_CURRENCY_CODE 	in 	VARCHAR2,
  X_DEFAULT_DATE_FORMAT 	in 	VARCHAR2,
  X_DEFAULT_ORG_ID 		in 	NUMBER,
  X_ATP_CHECK_FLAG 		in 	VARCHAR2,
  X_WALKIN_ALLOWED_FLAG 	in 	VARCHAR2,
  X_MSITE_ROOT_SECTION_ID 	in 	NUMBER,
  X_PROFILE_ID 			in 	NUMBER,
  X_MASTER_MSITE_FLAG 		in 	VARCHAR2,
  X_MSITE_NAME 			in 	VARCHAR2,
  X_MSITE_DESCRIPTION 		in 	VARCHAR2 ,
  X_RESP_ACCESS_FLAG            in      VARCHAR2 ,
  X_PARTY_ACCESS_CODE           in      VARCHAR2 ,
  X_ACCESS_NAME                 in      VARCHAR2 ,
  X_URL                         in      VARCHAR2 ,
  X_THEME_ID 			in 	NUMBER
);

procedure UPDATE_ROW (
  X_MSITE_ID 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_SECURITY_GROUP_ID 		in NUMBER,
  X_OBJECT_VERSION_NUMBER 	in NUMBER,
  X_STORE_ID 			in NUMBER,
  X_START_DATE_ACTIVE 		in DATE,
  X_END_DATE_ACTIVE 		in DATE,
  X_DEFAULT_LANGUAGE_CODE 	in VARCHAR2,
  X_DEFAULT_CURRENCY_CODE 	in VARCHAR2,
  X_DEFAULT_DATE_FORMAT 	in VARCHAR2,
  X_DEFAULT_ORG_ID 		in NUMBER,
  X_ATP_CHECK_FLAG 		in VARCHAR2,
  X_WALKIN_ALLOWED_FLAG 	in VARCHAR2,
  X_MSITE_ROOT_SECTION_ID 	in NUMBER,
  X_PROFILE_ID 			in NUMBER,
  X_MASTER_MSITE_FLAG 		in VARCHAR2,
  X_MSITE_NAME 			in VARCHAR2,
  X_MSITE_DESCRIPTION 		in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER ,
  X_RESP_ACCESS_FLAG            in      VARCHAR2 ,
  X_PARTY_ACCESS_CODE           in      VARCHAR2 ,
  X_ACCESS_NAME                 in      VARCHAR2 ,
  X_URL                         in      VARCHAR2 ,
  X_THEME_ID 			in 	NUMBER
);

procedure DELETE_ROW (
  X_MSITE_ID 			in NUMBER
);

procedure TRANSLATE_ROW (
  X_MSITE_ID          	in      NUMBER,
  X_OWNER               in      VARCHAR2,
  X_MSITE_NAME          in      VARCHAR2,
  X_MSITE_DESCRIPTION   in      VARCHAR2
);

procedure LOAD_ROW (
  X_MSITE_ID 			in NUMBER,
  X_OWNER			in VARCHAR2,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_SECURITY_GROUP_ID 		in NUMBER,
  X_OBJECT_VERSION_NUMBER 	in NUMBER,
  X_STORE_ID 			in NUMBER,
  X_START_DATE_ACTIVE 		in DATE,
  X_END_DATE_ACTIVE 		in DATE,
  X_DEFAULT_LANGUAGE_CODE 	in VARCHAR2,
  X_DEFAULT_CURRENCY_CODE 	in VARCHAR2,
  X_DEFAULT_DATE_FORMAT 	in VARCHAR2,
  X_DEFAULT_ORG_ID 		in NUMBER,
  X_ATP_CHECK_FLAG 		in VARCHAR2,
  X_WALKIN_ALLOWED_FLAG 	in VARCHAR2,
  X_MSITE_ROOT_SECTION_ID 	in NUMBER,
  X_PROFILE_ID 			in NUMBER,
  X_MASTER_MSITE_FLAG 		in VARCHAR2,
  X_MSITE_NAME 			in VARCHAR2,
  X_MSITE_DESCRIPTION 		in VARCHAR2 ,
  X_RESP_ACCESS_FLAG            in      VARCHAR2 ,
  X_PARTY_ACCESS_CODE           in      VARCHAR2 ,
  X_ACCESS_NAME                 in      VARCHAR2 ,
  X_URL                         in      VARCHAR2 ,
  X_THEME_ID 			in 	NUMBER);

PROCEDURE ADD_LANGUAGE;

END JTF_Msite_GRP;

 

/
