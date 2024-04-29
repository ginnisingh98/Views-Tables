--------------------------------------------------------
--  DDL for Package IBE_MSITE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_GRP" AUTHID CURRENT_USER AS
/* $Header: IBEGMSTS.pls 120.2 2006/06/30 21:14:39 abhandar noship $ */

g_pkg_name   CONSTANT varchar2(30):='IBE_Msite_GRP';
g_api_version CONSTANT number       := 1.0;


TYPE msite_rec_type  IS RECORD (
        msite_id              	number,
        Object_Version_number   number,
        Display_name            varchar2(120),
        Description             varchar2(4000),
        profile_id            	number,
        date_format            	varchar2(30),
        walkin_allowed_code	varchar2(1),
        atp_check_flag		varchar2(1),
        msite_master_flag	varchar2(1),
        msite_root_section_id	number,
        enable_for_store	varchar2(1),
        --new fields for globalisation, added by ssridhar
        resp_access_flag        varchar2(1),
        party_access_code       varchar2(1),
        access_name             varchar2(240),
        start_date_active       date,
        end_date_active         date ,
        url                     varchar2(2000),
        theme_id                number,
        payment_threshold_enable_flag  varchar2(1),
		-- new fields for OWA site integration
		domain_name varchar2(30),
		enable_traffic_filter varchar2(1),
		reporting_status varchar2(1),
		site_type varchar2(10)
	);


TYPE msite_currency_rec_type IS RECORD (
	currency_code		varchar2(15),
	walkin_prc_lst_id   	number,
	registered_prc_lst_id 	number,
	biz_partner_prc_lst_id 	number,
	orderable_limit		number,
	default_flag    	varchar2(1),
    payment_threshold number,
    partner_prc_lst_id 	number);

TYPE msite_language_rec_type is RECORD (
	language_code  varchar2(4),
	default_flag   varchar2(1),
	enable_flag    varchar2(1)
	);

TYPE msite_orgid_rec_type IS RECORD (
	orgid		number,
	default_flag 	varchar2(1)
	);

TYPE msite_delete_rec_type IS RECORD (
	msite_id		number,
	object_version_number 	number
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
	   number INDEX BY BINARY_INTEGER;

PROCEDURE delete_msite(
   p_api_version        IN  	number,
   p_init_msg_list    	IN   	varchar2 	:= FND_API.g_false,
   p_commit             IN  	varchar2  	:= FND_API.g_false,
   x_return_status      OUT NOCOPY varchar2,
   x_msg_count          OUT NOCOPY number,
   x_msg_data           OUT NOCOPY varchar2,
   p_msite_id_tbl       IN 	msite_delete_tbl_type
);

PROCEDURE save_msite(
   p_api_version      	IN  	number,
   p_init_msg_list    	IN   	varchar2 	:= FND_API.g_false,
   p_commit           	IN  	varchar2  	:= FND_API.g_false,
   x_return_status   	OUT NOCOPY 	varchar2,
   x_msg_count        	OUT NOCOPY  	number,
   x_msg_data         	OUT NOCOPY  	varchar2,
   p_msite_rec   	IN OUT NOCOPY 	Msite_REC_TYPE
);

PROCEDURE duplicate_msite(
  p_api_version           IN number,
  p_init_msg_list         IN varchar2 := FND_API.g_false,
  p_commit                IN varchar2  := FND_API.g_false,
  p_default_language_code IN varchar2,
  p_default_currency_code IN varchar2,
  p_walkin_pricing_id     IN number,
  x_minisite_id          OUT NOCOPY number,
  x_version_number       OUT NOCOPY number,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_msite_rec         IN OUT NOCOPY MSITE_REC_TYPE
);

PROCEDURE save_msite_languages(
   p_api_version         IN  	number,
   p_init_msg_list       IN   	varchar2 	:= FND_API.g_false,
   p_commit              IN  	varchar2  	:= FND_API.g_false,
   x_return_status       OUT NOCOPY 	varchar2,
   x_msg_count           OUT NOCOPY  	number,
   x_msg_data            OUT NOCOPY  	varchar2,
   p_msite_id		 IN   	number,
   p_msite_languages_tbl IN MSITE_LANGUAGES_TBL_TYPE
);

PROCEDURE save_msite_currencies(
   p_api_version         IN  	number,
   p_init_msg_list       IN   	varchar2 	:= FND_API.g_false,
   p_commit              IN  	varchar2  	:= FND_API.g_false,
   x_return_status       OUT NOCOPY 	varchar2,
   x_msg_count           OUT NOCOPY  	number,
   x_msg_data            OUT NOCOPY  	varchar2,
   p_msite_id		 IN   	number,
   p_msite_currencies_tbl IN  MSITE_CURRENCIES_TBL_TYPE
);


PROCEDURE get_msite_attribute (
   p_api_version         	IN  	number,
   p_init_msg_list       	IN   	varchar2 	:= FND_API.g_false,
   p_commit              	IN  	varchar2  	:= FND_API.g_false,
   x_return_status       	OUT NOCOPY 	varchar2,
   x_msg_count           	OUT NOCOPY  	number,
   x_msg_data            	OUT NOCOPY  	varchar2,
   p_msite_id		     	IN   	number,
  p_msite_attribute_name     	IN   	varchar2,
   x_msite_attribute_value	OUT NOCOPY 	varchar2);

PROCEDURE save_msite_orgids(
   p_api_version         IN  	number,
   p_init_msg_list       IN   	varchar2 	:= FND_API.g_false,
   p_commit              IN  	varchar2  	:= FND_API.g_false,
   x_return_status       OUT NOCOPY 	varchar2,
   x_msg_count           OUT NOCOPY  	number,
   x_msg_data            OUT NOCOPY  	varchar2,
   p_msite_id		 IN   	number,
   p_msite_orgids_tbl    IN  	MSITE_ORGIDS_TBL_TYPE
);

procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY 	varchar2,
  X_MSITE_ID 			in 	number,
  X_ATTRIBUTE_CATEGORY 		in 	varchar2,
  X_ATTRIBUTE1 			in 	varchar2,
  X_ATTRIBUTE2 			in	varchar2,
  X_ATTRIBUTE3 			in 	varchar2,
  X_ATTRIBUTE4 			in 	varchar2,
  X_ATTRIBUTE5 			in 	varchar2,
  X_ATTRIBUTE6 			in 	varchar2,
  X_ATTRIBUTE7 			in 	varchar2,
  X_ATTRIBUTE8 			in 	varchar2,
  X_ATTRIBUTE9 			in 	varchar2,
  X_ATTRIBUTE11 		in 	varchar2,
  X_ATTRIBUTE10 		in 	varchar2,
  X_ATTRIBUTE12 		in 	varchar2,
  X_ATTRIBUTE13 		in 	varchar2,
  X_ATTRIBUTE14 		in 	varchar2,
  X_ATTRIBUTE15 		in 	varchar2,
  X_OBJECT_VERSION_number	in 	number,
  X_STORE_ID 			in 	number,
  X_START_date_ACTIVE 		in 	date,
  X_END_date_ACTIVE 		in 	date,
  X_DEFAULT_LANGUAGE_CODE 	in 	varchar2,
  X_DEFAULT_CURRENCY_CODE 	in 	varchar2,
  X_DEFAULT_date_FORMAT 	in 	varchar2,
  X_DEFAULT_ORG_ID 		in 	number,
  X_ATP_CHECK_FLAG 		in 	varchar2,
  X_WALKIN_ALLOWED_FLAG 	in 	varchar2,
  X_MSITE_ROOT_SECTION_ID 	in 	number,
  X_PROFILE_ID 			in 	number,
  X_MASTER_MSITE_FLAG 		in 	varchar2,
  X_MSITE_NAME 			in 	varchar2,
  X_MSITE_DESCRIPTION 		in 	varchar2,
  X_CREATION_date 		in 	date,
  X_CREATED_BY 			in 	number,
  X_LAST_UPdate_date 		in 	date,
  X_LAST_UPdateD_BY 		in 	number,
  X_LAST_UPdate_LOGIN 		in 	number ,
  X_RESP_ACCESS_FLAG            in      varchar2 ,
  X_PARTY_ACCESS_CODE           in      varchar2 ,
  X_ACCESS_NAME                 in      varchar2 ,
  X_URL                         in      varchar2 ,
  X_THEME_ID 			in 	number,
  X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
  X_DOMAIN_NAME                 in VARCHAR2  := NULL,
  X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
  X_REPORTING_STATUS            in VARCHAR2  := 'N',
  X_SITE_TYPE                   in VARCHAR2  := 'I'
);

procedure LOCK_ROW (
  X_MSITE_ID 			in 	number,
  X_ATTRIBUTE_CATEGORY 		in 	varchar2,
  X_ATTRIBUTE1 			in 	varchar2,
  X_ATTRIBUTE2 			in	varchar2,
  X_ATTRIBUTE3 			in 	varchar2,
  X_ATTRIBUTE4 			in 	varchar2,
  X_ATTRIBUTE5 			in 	varchar2,
  X_ATTRIBUTE6 			in 	varchar2,
  X_ATTRIBUTE7 			in 	varchar2,
  X_ATTRIBUTE8 			in 	varchar2,
  X_ATTRIBUTE9 			in 	varchar2,
  X_ATTRIBUTE11 		in 	varchar2,
  X_ATTRIBUTE10 		in 	varchar2,
  X_ATTRIBUTE12 		in 	varchar2,
  X_ATTRIBUTE13 		in 	varchar2,
  X_ATTRIBUTE14 		in 	varchar2,
  X_ATTRIBUTE15 		in 	varchar2,
  X_OBJECT_VERSION_number 	in 	number,
  X_STORE_ID 			in 	number,
  X_START_date_ACTIVE 		in 	date,
  X_END_date_ACTIVE 		in 	date,
  X_DEFAULT_LANGUAGE_CODE 	in 	varchar2,
  X_DEFAULT_CURRENCY_CODE 	in 	varchar2,
  X_DEFAULT_date_FORMAT 	in 	varchar2,
  X_DEFAULT_ORG_ID 		in 	number,
  X_ATP_CHECK_FLAG 		in 	varchar2,
  X_WALKIN_ALLOWED_FLAG 	in 	varchar2,
  X_MSITE_ROOT_SECTION_ID 	in 	number,
  X_PROFILE_ID 			in 	number,
  X_MASTER_MSITE_FLAG 		in 	varchar2,
  X_MSITE_NAME 			in 	varchar2,
  X_MSITE_DESCRIPTION 		in 	varchar2 ,
  X_RESP_ACCESS_FLAG            in      varchar2 ,
  X_PARTY_ACCESS_CODE           in      varchar2 ,
  X_ACCESS_NAME                 in      varchar2 ,
  X_URL                         in      varchar2 ,
  X_THEME_ID 			in 	number,
  X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
  X_DOMAIN_NAME                 in VARCHAR2  := NULL,
  X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
  X_REPORTING_STATUS            in VARCHAR2  := 'N',
  X_SITE_TYPE                   in VARCHAR2  := 'I'
);

procedure UPdate_ROW (
  X_MSITE_ID 			in number,
  X_ATTRIBUTE_CATEGORY 		in varchar2,
  X_ATTRIBUTE1 			in varchar2,
  X_ATTRIBUTE2 			in varchar2,
  X_ATTRIBUTE3 			in varchar2,
  X_ATTRIBUTE4 			in varchar2,
  X_ATTRIBUTE5 			in varchar2,
  X_ATTRIBUTE6 			in varchar2,
  X_ATTRIBUTE7 			in varchar2,
  X_ATTRIBUTE8 			in varchar2,
  X_ATTRIBUTE9 			in varchar2,
  X_ATTRIBUTE11 		in varchar2,
  X_ATTRIBUTE10 		in varchar2,
  X_ATTRIBUTE12 		in varchar2,
  X_ATTRIBUTE13 		in varchar2,
  X_ATTRIBUTE14 		in varchar2,
  X_ATTRIBUTE15 		in varchar2,
  X_OBJECT_VERSION_number 	in number,
  X_STORE_ID 			in number,
  X_START_date_ACTIVE 		in date,
  X_END_date_ACTIVE 		in date,
  X_DEFAULT_LANGUAGE_CODE 	in varchar2,
  X_DEFAULT_CURRENCY_CODE 	in varchar2,
  X_DEFAULT_date_FORMAT 	in varchar2,
  X_DEFAULT_ORG_ID 		in number,
  X_ATP_CHECK_FLAG 		in varchar2,
  X_WALKIN_ALLOWED_FLAG 	in varchar2,
  X_MSITE_ROOT_SECTION_ID 	in number,
  X_PROFILE_ID 			in number,
  X_MASTER_MSITE_FLAG 		in varchar2,
  X_MSITE_NAME 			in varchar2,
  X_MSITE_DESCRIPTION 		in varchar2,
  X_LAST_UPdate_date 		in date,
  X_LAST_UPdateD_BY 		in number,
  X_LAST_UPdate_LOGIN 		in number ,
  X_RESP_ACCESS_FLAG            in      varchar2 ,
  X_PARTY_ACCESS_CODE           in      varchar2 ,
  X_ACCESS_NAME                 in      varchar2 ,
  X_URL                         in      varchar2 ,
  X_THEME_ID 			in 	number,
  X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
  X_DOMAIN_NAME                 in VARCHAR2  := NULL,
  X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
  X_REPORTING_STATUS            in VARCHAR2  := 'N',
  X_SITE_TYPE                   in VARCHAR2  := 'I'
);

procedure DELETE_ROW (
  X_MSITE_ID 			in number
);

procedure TRANSLATE_ROW (
  X_MSITE_ID          	in      number,
  X_OWNER               in      varchar2,
  X_MSITE_NAME          in      varchar2,
  X_MSITE_DESCRIPTION   in      varchar2,
  X_LAST_UPDATE_DATE in varchar2,
  X_CUSTOM_MODE  in Varchar2
);

procedure LOAD_ROW (
  X_MSITE_ID 			in number,
  X_OWNER			in varchar2,
  X_ATTRIBUTE_CATEGORY 		in varchar2,
  X_ATTRIBUTE1 			in varchar2,
  X_ATTRIBUTE2 			in varchar2,
  X_ATTRIBUTE3 			in varchar2,
  X_ATTRIBUTE4 			in varchar2,
  X_ATTRIBUTE5 			in varchar2,
  X_ATTRIBUTE6 			in varchar2,
  X_ATTRIBUTE7 			in varchar2,
  X_ATTRIBUTE8 			in varchar2,
  X_ATTRIBUTE9 			in varchar2,
  X_ATTRIBUTE11 		in varchar2,
  X_ATTRIBUTE10 		in varchar2,
  X_ATTRIBUTE12 		in varchar2,
  X_ATTRIBUTE13 		in varchar2,
  X_ATTRIBUTE14 		in varchar2,
  X_ATTRIBUTE15 		in varchar2,
  X_OBJECT_VERSION_number 	in number,
  X_STORE_ID 			in number,
  X_START_date_ACTIVE 		in date,
  X_END_date_ACTIVE 		in date,
  X_DEFAULT_LANGUAGE_CODE 	in varchar2,
  X_DEFAULT_CURRENCY_CODE 	in varchar2,
  X_DEFAULT_date_FORMAT 	in varchar2,
  X_DEFAULT_ORG_ID 		in number,
  X_ATP_CHECK_FLAG 		in varchar2,
  X_WALKIN_ALLOWED_FLAG 	in varchar2,
  X_MSITE_ROOT_SECTION_ID 	in number,
  X_PROFILE_ID 			in number,
  X_MASTER_MSITE_FLAG 		in varchar2,
  X_MSITE_NAME 			in varchar2,
  X_MSITE_DESCRIPTION 		in varchar2 ,
  X_RESP_ACCESS_FLAG            in      varchar2 ,
  X_PARTY_ACCESS_CODE           in      varchar2 ,
  X_ACCESS_NAME                 in      varchar2 ,
  X_URL                         in      varchar2 ,
  X_THEME_ID 			in 	number,
  X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
  X_DOMAIN_NAME                 in VARCHAR2  := NULL,
  X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
  X_REPORTING_STATUS            in VARCHAR2  := 'N',
  X_SITE_TYPE                   in VARCHAR2  := 'I',
  X_LAST_UPDATE_DATE in varchar2,
  X_CUSTOM_MODE  in Varchar2
);

PROCEDURE ADD_LANGUAGE;

PROCEDURE LOAD_SEED_ROW
  (
  					X_MSITE_ID 		     in NUMBER,
  					X_OWNER         	 in VARCHAR2,
  					X_MSITE_NAME		 in VARCHAR2,
  					X_MSITE_DESCRIPTION 	in VARCHAR2,
  					X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  					X_ATTRIBUTE1            in VARCHAR2,
  					X_ATTRIBUTE2            in VARCHAR2,
  					X_ATTRIBUTE3            in VARCHAR2,
  					X_ATTRIBUTE4            in VARCHAR2,
  					X_ATTRIBUTE5            in VARCHAR2,
  					X_ATTRIBUTE6            in VARCHAR2,
  					X_ATTRIBUTE7            in VARCHAR2,
  					X_ATTRIBUTE8            in VARCHAR2,
  					X_ATTRIBUTE9            in VARCHAR2,
  					X_ATTRIBUTE10           in VARCHAR2,
  					X_ATTRIBUTE11           in VARCHAR2,
  					X_ATTRIBUTE12           in VARCHAR2,
  					X_ATTRIBUTE13           in VARCHAR2,
  					X_ATTRIBUTE14           in VARCHAR2,
  					X_ATTRIBUTE15           in VARCHAR2,
  					X_OBJECT_VERSION_NUMBER in NUMBER,
  					X_STORE_ID              in NUMBER,
  					X_START_DATE_ACTIVE 	IN VARCHAR2,--IN DATE,
                                        X_END_DATE_ACTIVE 	IN VARCHAR2,--	IN DATE,
  					X_DEFAULT_LANGUAGE_CODE in VARCHAR2,
  					X_DEFAULT_CURRENCY_CODE in VARCHAR2,
  					X_DEFAULT_DATE_FORMAT   in VARCHAR2,
  					X_DEFAULT_ORG_ID        in NUMBER,
  					X_ATP_CHECK_FLAG        in VARCHAR2,
  					X_WALKIN_ALLOWED_FLAG   in VARCHAR2,
  					X_MSITE_ROOT_SECTION_ID in NUMBER,
  					X_PROFILE_ID            in NUMBER,
  					X_MASTER_MSITE_FLAG     in VARCHAR2,
					X_RESP_ACCESS_FLAG      in VARCHAR2 ,
					X_PARTY_ACCESS_CODE	    in VARCHAR2 ,
					X_ACCESS_NAME    	    in VARCHAR2 ,
					X_URL			        in VARCHAR2 ,
					X_THEME_ID		        in VARCHAR2 ,
               		X_PAYMENT_THRESH_ENABLE_FLAG  in VARCHAR2  := NULL,
		     	    X_DOMAIN_NAME                 in VARCHAR2  := NULL,
			        X_ENABLE_TRAFFIC_FILTER       in VARCHAR2  := 'N',
			        X_REPORTING_STATUS            in VARCHAR2  := 'N',
			        X_SITE_TYPE                   in VARCHAR2  := 'I',
        			X_LAST_UPDATE_DATE		IN VARCHAR2,
                    X_CUSTOM_MODE           IN VARCHAR2,
           			X_UPLOAD_MODE           IN VARCHAR2
  );

END IBE_Msite_GRP;

 

/
