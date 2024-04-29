--------------------------------------------------------
--  DDL for Package IBE_CFG_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CFG_CONFIG_PVT" AUTHID CURRENT_USER AS
  /* $Header: IBEVFSCS.pls 120.0.12010000.2 2010/11/30 08:07:34 scnagara ship $ */

procedure Get_Config_Launch_Info(
	p_api_version	   IN 	NUMBER,
	p_init_msg_list	   IN	VARCHAR2 := FND_API.g_false,
	p_commit	   IN	VARCHAR2 := FND_API.g_false,
	p_validation_level IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	   OUT NOCOPY	VARCHAR2,
	x_msg_count	   OUT NOCOPY	NUMBER,
	x_msg_data	   OUT NOCOPY	VARCHAR2,
	p_itemid	   IN	NUMBER,
	p_organization_id  IN	NUMBER,
	x_configurable	OUT NOCOPY VARCHAR2,
--	x_icx_sessn_tkt	OUT NOCOPY VARCHAR2, -- taken out as we're using a new java api for bug 3137603
	x_db_id		OUT NOCOPY VARCHAR2,
	x_servlet_url	OUT NOCOPY VARCHAR2,
	x_sysdate	OUT NOCOPY VARCHAR2
);

procedure Add_Config_To_Quote(
	p_api_version	IN 	NUMBER,
	p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
	p_commit	IN	VARCHAR2 := FND_API.g_false,
	p_validation_level IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2,
	p_quote_hdr_id  IN 	NUMBER := FND_API.g_miss_num,
	p_quote_line_id IN 	NUMBER := FND_API.g_miss_num,
	p_cfg_hdr_id  	IN 	NUMBER := FND_API.g_miss_num,
	p_cfg_rev_num  	IN 	NUMBER := FND_API.g_miss_num,
	p_valid_cfg  	IN 	VARCHAR2 := 'Y',
	p_complete_cfg  IN 	VARCHAR2 := 'Y',
	p_pricing_request_type	IN VARCHAR2 := FND_API.g_miss_char,
	p_header_pricing_event	IN VARCHAR2 := FND_API.g_miss_char,
	p_line_pricing_event	IN VARCHAR2 := FND_API.g_miss_char,
	p_calc_tax		IN VARCHAR2 := 'Y',
	p_calc_shipping		IN VARCHAR2 := 'Y',
	p_price_mode		IN VARCHAR2 := 'ENTIRE_QUOTE'	-- change line logic pricing
);

end ibe_cfg_config_pvt;

/
