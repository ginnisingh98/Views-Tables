--------------------------------------------------------
--  DDL for Package IBU_HOME_PAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_HOME_PAGE_PVT" 
/* $Header: ibuhvhps.pls 120.0 2005/10/06 09:42:49 ktma noship $ */
	AUTHID CURRENT_USER as
      -- ---------------------------------------------------------
      -- Declare Global Variables
      -- --------------------------------------------------
      G_ADMIN_PROFILE_NAME CONSTANT VARCHAR2(30) := 'IBU_A_PROFILE00';
      G_MANDATORY_LAYOUT_DATA_NAME CONSTANT VARCHAR2(30) := 'IBU_MANDATORY_LAYOUT';
      G_USER_LAYOUT_DATA_NAME CONSTANT VARCHAR2(30) := 'IBU_USER_LAYOUT';
	 G_LAYOUT_DATA_TYPE CONSTANT VARCHAR2(30) := 'IBU_LAYOUT';

      -- ---------------------------------------------------------
      -- Declare Data Types
      -- --------------------------------------------------
      TYPE     IBU_STR_ARR IS VARRAY(20) OF VARCHAR2(80);

      TYPE Bin_Data_Type IS RECORD (
          bin_id         NUMBER         := 0,
          package_name   VARCHAR2(300)  := null,
          mandatory_flag VARCHAR2(1)    := null,
          disabled_flag  VARCHAR2(1)    := null,
          MES_cat_ID     NUMBER         := null,
          row_number         NUMBER         := -1
      );


      TYPE Account_Data_Type IS RECORD (
		account_id     NUMBER       := null,
		account_number VARCHAR2(30) := null
      );
	 TYPE Account_List_Type is table of Account_Data_Type;

      type Filter_Data_Type IS RECORD (
           name  VARCHAR2(60) := '',
           value VARCHAR2(240) := ''
      );
      type Filter_Data_List_Type is table of Filter_Data_Type;

      -- ---------------------------------------------------------
      -- Common Context Info APIs
      -- --------------------------------------------------
	 function is_rollout_enabled return VARCHAR;
	 function is_country_contract_enabled return VARCHAR;

      function get_user_id return NUMBER;
      function get_user_name return VARCHAR2;
      function get_app_id return NUMBER;
      function get_resp_id return NUMBER;
      function get_customer_id return NUMBER;
      function get_employee_id return NUMBER;
      function get_company_id return NUMBER;
      function get_company_name return VARCHAR2;
      function get_account_id return NUMBER;
      function get_lang_code return VARCHAR2;
      function get_date_format return VARCHAR2;

      function get_resp_id_from_user(p_user_id IN NUMBER) return NUMBER;
      function get_customer_id_from_user(p_user_id IN NUMBER) return NUMBER;
      function get_employee_id_from_user(p_user_id IN NUMBER) return NUMBER;
      function get_party_type_from_user(p_user_id IN NUMBER, x_party_id OUT NOCOPY NUMBER) return VARCHAR2;
      function get_company_id_from_user(p_user_id IN NUMBER) return NUMBER;
      function get_company_name_from_user(p_user_id IN NUMBER) return VARCHAR2;
      function get_account_id_from_user(p_user_id IN NUMBER) return NUMBER;
      function get_accounts_from_user(p_user_id IN NUMBER) return Account_List_Type;
      function get_date_format_from_user(p_user_id IN NUMBER) return VARCHAR2;
      function get_long_language_from_user(p_user_id IN NUMBER) return VARCHAR2;


      -- ---------------------------------------------------------
      -- Unit functions for homepage
      -- --------------------------------------------------
	 function get_close_bin_url(p_bin_id IN NUMBER,
						   p_cookie_url IN VARCHAR2)
	   return VARCHAR2;

	 function get_edit_bin_url(p_bin_id IN NUMBER,
						  p_jsp_file_name IN VARCHAR2,
						  p_filter_string IN VARCHAR2,
						  p_cookie_url IN VARCHAR2)
	   return VARCHAR2;

      function get_bin_header_html(p_bin_name IN VARCHAR2,
							p_bin_link_url IN VARCHAR2,
							p_edit_url IN VARCHAR2,
							p_close_url IN VARCHAR2)
	   return VARCHAR2;

	 procedure get_bin_info(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count        OUT  NOCOPY NUMBER,
                     x_msg_data         OUT  NOCOPY VARCHAR2,
                     p_bin_id 		IN NUMBER,
                     x_bin_info 	     OUT NOCOPY Bin_Data_Type);

      function get_formatted_date(p_date in DATE, p_format in VARCHAR2)
        return VARCHAR2;

      procedure get_ak_region_items(p_region_code IN VARCHAR2,
                                    p_prompts OUT NOCOPY IBU_STR_ARR);
      function get_ak_bin_prompt(p_region_item_name IN VARCHAR2)
	   return VARCHAR2;

      procedure get_ak_region_items_from_user(p_user_id IN NUMBER,
							 p_region_code IN VARCHAR2,
                                    p_prompts OUT NOCOPY IBU_STR_ARR);

      procedure get_filter_list(p_api_version     IN   NUMBER,
                     p_init_msg_list         IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     p_user_id            IN   NUMBER,
                     p_bin_id        In   NUMBER,
                     x_return_status          OUT NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
                     x_filter_list OUT NOCOPY Filter_Data_List_Type,
                     x_filter_string OUT NOCOPY VARCHAR2);

      procedure get_perz_data_attrib(
				 p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit       IN VARCHAR          := FND_API.G_FALSE,
                     x_return_status          OUT  NOCOPY VARCHAR2,
                     x_msg_count         OUT  NOCOPY NUMBER,
                     x_msg_data          OUT  NOCOPY VARCHAR2,
				 p_user_id IN NUMBER := 0,
			      p_prof_name IN VARCHAR2 := NULL,
				 p_pd_id   IN NUMBER,
			      p_pd_name IN VARCHAR2,
				 p_pd_type IN VARCHAR2,
				 p_one_attrib IN VARCHAR2  := FND_API.G_TRUE,
				 p_pd_attrib_name IN VARCHAR2 := NULL,
                     x_pd_attrib_value OUT NOCOPY VARCHAR2,
				 x_pd_attrib_tbl OUT NOCOPY JTF_PERZ_DATA_PUB.DATA_ATTRIB_TBL_TYPE
				);
end IBU_HOME_PAGE_PVT;

 

/
