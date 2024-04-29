--------------------------------------------------------
--  DDL for Package Body IBE_CFG_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CFG_CONFIG_PVT" AS
/* $Header: IBEVFSCB.pls 120.1.12010000.3 2010/11/30 07:49:14 scnagara ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ibe_cfg_config_pvt';
l_true VARCHAR2(1) := FND_API.G_TRUE;

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
	x_configurable	   OUT NOCOPY 	VARCHAR2,
--	x_icx_sessn_tkt	   OUT NOCOPY	VARCHAR2, -- taken out as we're using a new java api for bug 3137603
	x_db_id		   OUT NOCOPY	VARCHAR2,
	x_servlet_url	   OUT NOCOPY	VARCHAR2,
	x_sysdate	   OUT NOCOPY	VARCHAR2
) is
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Get_Config_Launch_Info';
	l_api_version	CONSTANT NUMBER		:= 1.0;

	l_ui_def_id		NUMBER;
	l_resp_id		NUMBER;
	l_resp_appl_id		NUMBER;
	l_log_enabled   VARCHAR2(1) := 'N';
	l_user_id	NUMBER;
begin
	l_user_id := fnd_global.user_id;
	l_log_enabled := fnd_profile.value_specific(
				name =>'IBE_DEBUG',
				user_id => l_user_id);
	if (l_log_enabled = 'Y') then
		----IBE_Util.Enable_Debug;
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Starting ibe_cfg_config_pvt.Get_Config_Launch_Info ');
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - Key Input: item_id: ' || p_itemid || 'organizationid: ' || p_organization_id);
		END IF;
	end if;

	SAVEPOINT	Get_Config_Launch_Info_Pvt;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;

	-- just something to get working for now

	l_resp_id := fnd_profile.value('RESP_ID');
	l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');

	if (l_log_enabled = 'Y') then
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - responsibility id ' || l_resp_id);
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - calling app id ' || l_resp_appl_id);
		END IF;
		-- call configurator API
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - calling CZ_CF_API.UI_FOR_ITEM');
		END IF;
	end if;
	l_ui_def_id := CZ_CF_API.UI_FOR_ITEM (p_itemid, p_organization_id, SYSDATE,
 					     'DHTML', FND_API.G_MISS_NUM, l_resp_id, l_resp_appl_id);
	if (l_log_enabled = 'Y') then
		----IBE_Util.Enable_Debug;
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - back from CZ_CF_API.UI_FOR_ITEM');
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - l_ui_def_id: ' || to_char(l_ui_def_id));
		END IF;
	end if;

	IF l_ui_def_id IS NULL THEN
		x_configurable := FND_API.G_FALSE;
	ELSE
		x_configurable := FND_API.G_TRUE;
	END IF;

	-- get icx session ticket
--	x_icx_sessn_tkt := CZ_CF_API.ICX_SESSION_TICKET;

	-- get the dbc file name
	x_db_id := FND_WEB_CONFIG.DATABASE_ID;

	-- get the URL for servlet
	x_servlet_url := fnd_profile.value('CZ_UIMGR_URL');

	-- get the SYSDATE
	x_sysdate := to_char(sysdate,'mm-dd-yyyy-hh24-mi-ss');

	if (l_log_enabled = 'Y') then
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
--   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - x_icx_sessn_tkt: ' || x_icx_sessn_tkt);
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - x_db_id        : ' || x_db_id );
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - x_servlet_url  : ' || x_servlet_url);
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info - x_sysdate      : ' || x_sysdate);
		END IF;
	end if;

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(  	p_encoded 		=> FND_API.G_FALSE,
		p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('Done with ibe_cfg_config_pvt.Get_Config_Launch_Info');
	END IF;
	--IBE_Util.Disable_Debug;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info: EXPECTED ERROR EXCEPTION ');
		END IF;
		ROLLBACK TO Get_Config_Launch_Info_Pvt;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info: UNEXPECTED ERROR EXCEPTION ');
		END IF;
		ROLLBACK TO Get_Config_Launch_Info_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
       			p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;
	WHEN OTHERS THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Get_Config_Launch_Info: OTHER EXCEPTION ');
		END IF;
		ROLLBACK TO Get_Config_Launch_Info_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
       			p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;

end Get_Config_Launch_Info;

procedure Add_Config_To_Quote(
	p_api_version	   IN NUMBER,
	p_init_msg_list	   IN VARCHAR2 := FND_API.g_false,
	p_commit	   IN VARCHAR2 := FND_API.g_false,
	p_validation_level IN  	NUMBER	:= FND_API.g_valid_level_full,
	x_return_status	   OUT NOCOPY	VARCHAR2,
	x_msg_count	   OUT NOCOPY	NUMBER,
	x_msg_data	   OUT NOCOPY	VARCHAR2,
	p_quote_hdr_id     IN 	NUMBER := FND_API.g_miss_num,
	p_quote_line_id    IN 	NUMBER := FND_API.g_miss_num,
	p_cfg_hdr_id  	   IN 	NUMBER := FND_API.g_miss_num,
	p_cfg_rev_num  	   IN 	NUMBER := FND_API.g_miss_num,
	p_valid_cfg  	   IN 	VARCHAR2 := 'Y',
	p_complete_cfg     IN 	VARCHAR2 := 'Y',
	p_pricing_request_type	IN 	VARCHAR2 := FND_API.g_miss_char,
	p_header_pricing_event	IN 	VARCHAR2 := FND_API.g_miss_char,
	p_line_pricing_event	IN	VARCHAR2 := FND_API.g_miss_char,
	p_calc_tax		IN	VARCHAR2 := 'Y',
	p_calc_shipping		IN	VARCHAR2 := 'Y',
	p_price_mode		IN	VARCHAR2 := 'ENTIRE_QUOTE'	-- change line logic pricing
) is
	l_count NUMBER;
	p_config_rec aso_quote_pub.qte_line_dtl_rec_type ;
	p_line_rec   aso_quote_pub.qte_line_rec_type ;
	l_api_name	CONSTANT VARCHAR2(30)	:= 'Add_Config_To_Quote';
	l_api_version	CONSTANT NUMBER		:= 1.0;

	l_control_rec		ASO_QUOTE_PUB.Control_Rec_Type;
	l_qte_header_rec   aso_quote_pub.qte_header_rec_type  := aso_quote_pub.g_miss_qte_header_rec; -- bug 8769909, scnagara

	Cursor c_old_cfg_info (p_c_quote_line_id INTEGER)
	IS select CONFIG_HEADER_ID, CONFIG_REVISION_NUM
		from ASO_QUOTE_LINE_DETAILS
		where
			quote_line_id = p_c_quote_line_id;
	l_log_enabled   VARCHAR2(1) := 'N';
	l_user_id	NUMBER;
begin
	--IBE_Util.Enable_Debug;
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('Starting ibe_cfg_config_pvt.Add_Config_To_Quote ');
	END IF;
	SAVEPOINT	Add_Config_To_Quote_Pvt;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API rturn status to success
	x_return_status := FND_API.g_ret_sts_success;

	l_qte_header_rec.quote_header_id := p_quote_hdr_id;  -- bug 8769909, scnagara
	l_qte_header_rec.PRICING_STATUS_INDICATOR := 'C';
	l_qte_header_rec.TAX_STATUS_INDICATOR := 'C';

	l_control_rec.pricing_request_type := p_pricing_request_type;
	l_control_rec.header_pricing_event := p_header_pricing_event;
	l_control_rec.line_pricing_event := p_line_pricing_event;
	l_control_rec.CALCULATE_TAX_FLAG := p_calc_tax;
	l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG := p_calc_shipping;
	l_control_rec.PRICE_MODE := p_price_mode;	-- change line logic pricing

	IF (p_price_mode = 'CHANGE_LINE') THEN		-- change line logic pricing
     		l_qte_header_rec.PRICING_STATUS_INDICATOR := 'I';
		l_qte_header_rec.TAX_STATUS_INDICATOR := 'I';
	END IF;

	p_config_rec.quote_line_id := p_quote_line_id ;
	p_config_rec.complete_configuration_flag := p_complete_cfg;
	p_config_rec.valid_configuration_flag := p_valid_cfg;

	-- Get and pass the previously saved config info from the quote line
	open c_old_cfg_info(p_quote_line_id);
	fetch c_old_cfg_info into p_config_rec.config_header_id, p_config_rec.config_revision_num;
	close c_old_cfg_info;

	l_user_id := fnd_global.user_id;
	l_log_enabled := fnd_profile.value_specific(
				name =>'IBE_DEBUG',
				user_id => l_user_id);
	if (l_log_enabled = 'Y') then
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote - calling ASO_CFG_PUB.Get_config_details ');
   		ibe_util.debug('New Config info:');
   		ibe_util.debug('p_config_hdr_id ' || p_cfg_hdr_id);
   		ibe_util.debug('p_config_rev_nbr ' || p_cfg_rev_num);
   		ibe_util.debug('p_quote_header_id ' || p_quote_hdr_id);
   		ibe_util.debug('p_config_rec.quote_line_id ' || p_quote_line_id);
   		ibe_util.debug('p_config_rec.complete_configuration_flag ' || p_complete_cfg);
   		ibe_util.debug('p_config_rec.valid_configuration_flag ' || p_valid_cfg);
   		ibe_util.debug('Previous Config info (if any):');
   		ibe_util.debug('p_config_rec.config_header_id ' || p_config_rec.config_header_id);
   		ibe_util.debug('p_config_rec.config_revision_num ' || p_config_rec.config_revision_num);
   		ibe_util.debug('Control Rec info:');
   		ibe_util.debug('l_control_rec.pricing_request_type  ' || l_control_rec.pricing_request_type );
   		ibe_util.debug('l_control_rec.header_pricing_event ' || l_control_rec.header_pricing_event);
   		ibe_util.debug('l_control_rec.line_pricing_event  ' || l_control_rec.line_pricing_event);
   		ibe_util.debug('l_control_rec.CALCULATE_TAX_FLAG ' || l_control_rec.CALCULATE_TAX_FLAG);
   		ibe_util.debug('l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG  ' || l_control_rec.CALCULATE_FREIGHT_CHARGE_FLAG );
		ibe_util.debug('l_control_rec.PRICE_MODE  ' || l_control_rec.PRICE_MODE );
		ibe_util.debug('Passing header record to ibe_cfg_config_pvt.Add_Config_To_Quote');
		END IF;
	end if;
	/*   -- bug 8769909, scnagara
	ASO_CFG_PUB.Get_config_details(
		P_Api_Version_Number     => 1.0 ,
		P_Init_Msg_List => FND_API.g_false,
		p_commit	=> FND_API.g_false,
		p_control_rec  	=> l_control_rec,
		p_config_rec        => p_config_rec ,
		p_model_line_rec     => p_line_rec ,
		p_config_hdr_id     => p_cfg_hdr_id ,
		p_config_rev_nbr    => p_cfg_rev_num ,
		p_quote_header_id   => p_quote_hdr_id,
		x_return_status      => x_return_status ,
		x_msg_count          => x_msg_count ,
		x_msg_data           => x_msg_data);
	*/

	ASO_CFG_PUB.get_config_details(		-- bug 8769909, scnagara
		P_Api_Version_Number     => 1.0 ,
		P_Init_Msg_List => FND_API.g_false,
		p_commit	=> FND_API.g_false,
		p_control_rec  	=> l_control_rec,
		p_qte_header_rec    => l_qte_header_rec,
		p_model_line_rec     => p_line_rec ,
		p_config_rec        => p_config_rec ,
		p_config_hdr_id     => p_cfg_hdr_id ,
		p_config_rev_nbr    => p_cfg_rev_num ,
		x_return_status      => x_return_status ,
		x_msg_count          => x_msg_count ,
		x_msg_data           => x_msg_data);
	--IBE_Util.Enable_Debug;
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote - back from ASO_CFG_PUB.Get_config_details ');
	END IF;

	if x_return_status <> FND_API.g_ret_sts_success then
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote - non success status from ASO_CFG_PUB.Get_config_details: ' || x_return_status);
		END IF;
		FND_MESSAGE.SET_NAME('IBE','IBE_PLSQL_API_ERROR');
          	FND_MESSAGE.SET_TOKEN ( '0' , 'Add_Config_To_Quote - ASO_CFG_PUB.Get_config_details' );
             	FND_MESSAGE.SET_TOKEN ( '1' , x_return_status );
		FND_MSG_PUB.Add;
		if x_return_status = FND_API.G_RET_STS_ERROR then
			RAISE FND_API.G_EXC_ERROR;
		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
	end if;


	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(  	p_encoded 		=> FND_API.G_FALSE,
		p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
	--IBE_Util.Disable_Debug;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote: EXPECTED ERROR EXCEPTION ');
		END IF;
		ROLLBACK TO Add_Config_To_Quote_Pvt;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote: UNEXPECTED ERROR EXCEPTION ');
		END IF;
		ROLLBACK TO Add_Config_To_Quote_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
       			p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;
	WHEN OTHERS THEN
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('ibe_cfg_config_pvt.Add_Config_To_Quote: OTHER EXCEPTION ');
		END IF;
		ROLLBACK TO Add_Config_To_Quote_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded 		=> FND_API.G_FALSE,
			p_count         	=>      x_msg_count,
       			p_data          	=>      x_msg_data
    		);
		--IBE_Util.Disable_Debug;

end Add_Config_To_Quote;

end ibe_cfg_config_pvt;

/
