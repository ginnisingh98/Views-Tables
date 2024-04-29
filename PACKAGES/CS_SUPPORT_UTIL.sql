--------------------------------------------------------
--  DDL for Package CS_SUPPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SUPPORT_UTIL" AUTHID CURRENT_USER as
/* $Header: cssuutis.pls 115.6 2001/05/15 15:53:10 pkm ship       $ */
/*
procedure Create_Support_Parties_Link (
	p_support_id	IN 	NUMBER,
	p_party_id 	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2);

procedure Delete_Support_Parties_Link (
	p_support_id	IN 	NUMBER,
	p_party_id	IN	NUMBER,
	X_Return_Status	OUT	VARCHAR2
	);
*/
/*
procedure Create_Support_SR_Link (
	p_support_id	IN 	NUMBER,
	p_incident_id	IN	NUMBER,
	p_product_version IN    VARCHAR2,
	p_platform_version IN   VARCHAR2,
	p_rdbms_version	  IN    VARCHAR2,
	X_Return_Status		OUT	VARCHAR2
);

procedure Delete_Support_SR_Link (
	p_support_id	IN 	NUMBER,
	p_incident_id	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2
);


procedure Create_Support_ID_Level_Link (
	p_support_id	IN 	NUMBER,
	p_level_id 	IN	NUMBER,
	p_start_date		IN	VARCHAR2,
	p_end_date		IN 	VARCHAR2,
	X_support_level_link_id OUT NUMBER,
	X_Return_Status		OUT	VARCHAR2);


procedure Delete_Support_ID_Level_Link (

	p_support_level_link_id	IN    NUMBER,

	X_Return_Status		OUT	VARCHAR2);

procedure Create_Support_Level_Item_Link (
	p_support_level_link_id 	IN 	NUMBER,
	p_item_id 		IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2);

procedure Delete_Support_Level_Item_Link  (
	p_support_level_link_id	 IN	NUMBER,
	p_item_id		IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2);

procedure Delete_All_Level_Item_Link  (
	p_support_leveL_link_id	IN	NUMBER,
	X_Return_Status		OUT	VARCHAR2);
*/
/*
procedure get_current_support_id (
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR,
                     x_support_id              OUT  NUMBER,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

    procedure is_csi_enabled(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit                 IN   VARCHAR := FND_API.G_FALSE,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );
*/

end CS_SUPPORT_UTIL;

 

/
