--------------------------------------------------------
--  DDL for Package Body EAM_ITEM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ITEM_PVT" AS
/* $Header: EAMPITMB.pls 120.7 2006/06/13 22:42:17 hkarmach noship $ */


G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_ITEM_PVT';

PROCEDURE insert_item
(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE
	, x_return_status		OUT 	NOCOPY VARCHAR2
	, x_msg_count			OUT 	NOCOPY NUMBER
	, x_msg_data	    		OUT 	NOCOPY VARCHAR2
	, x_item_id			OUT	NOCOPY NUMBER
	, p_asset_group		    	IN	VARCHAR2
	, p_segment1			IN	VARCHAR2
	, p_segment2			IN	VARCHAR2
	, p_segment3			IN	VARCHAR2
	, p_segment4			IN	VARCHAR2
	, p_segment5			IN	VARCHAR2
	, p_segment6			IN	VARCHAR2
	, p_segment7			IN	VARCHAR2
	, p_segment8			IN	VARCHAR2
	, p_segment9			IN	VARCHAR2
	, p_segment10			IN	VARCHAR2
	, p_segment11			IN	VARCHAR2
	, p_segment12			IN	VARCHAR2
	, p_segment13			IN	VARCHAR2
	, p_segment14			IN	VARCHAR2
	, p_segment15			IN	VARCHAR2
	, p_segment16			IN	VARCHAR2
	, p_segment17			IN	VARCHAR2
	, p_segment18			IN	VARCHAR2
	, p_segment19			IN	VARCHAR2
	, p_segment20			IN	VARCHAR2
	, P_SOURCE_TMPL_ID		IN	NUMBER
    	, p_template_name       	IN  	VARCHAR2
    	, p_organization_id     	IN  	NUMBER
    	, p_description         	IN  	VARCHAR2
    	, p_serial_generation   	IN  	NUMBER
    	, p_prefix_text         	IN  	VARCHAR2
    	, p_prefix_number       	IN  	VARCHAR2
    	, p_eam_item_type       	IN  	NUMBER
)
IS

	l_create_item_ver		NUMBER := 1.0;
	l_x_return_status		VARCHAR2(1);
	l_x_msg_count			NUMBER;
	l_x_msg_data			VARCHAR2(20000);

	l_asset_group			INV_Item_GRP.Item_Rec_Type;
	l_x_inventory_item_id		NUMBER;
    	l_master_org_id number;

	l_api_name			CONSTANT VARCHAR2(30)	:= 'insert_item';

	l_module           		varchar2(200);
	l_log_level CONSTANT NUMBER := 	fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := 	fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN := 	l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := 	l_pLog AND fnd_log.level_statement >= l_log_level;

-- output variables of inv package
	l_x_curr_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_curr_item_return_status	VARCHAR2(1);
	l_x_curr_item_error_tbl		INV_Item_GRP.Error_Tbl_Type;
	l_x_master_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_master_item_return_status	VARCHAR2(1);
	l_x_master_item_error_tbl	INV_Item_GRP.Error_Tbl_Type;


    	v_row PLS_INTEGER;

BEGIN
        if (l_ulog) then
	   l_module  := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;
	l_asset_group.Description := p_description;
	l_asset_group.SERIAL_NUMBER_CONTROL_CODE := p_serial_generation;
	l_asset_group.AUTO_SERIAL_ALPHA_PREFIX := p_prefix_text;
	l_asset_group.START_AUTO_SERIAL_NUMBER := p_prefix_number;

        IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ITEM_PVT.Insert_item ===================='
		|| 'p_organization_id = ' || p_organization_id
		|| 'p_eam_item_type = ' || p_eam_item_type||
		'Comms_NL_Trackable_Flag: '||l_asset_group.comms_nl_trackable_flag||
		' Inventory_Item_Flag: '||l_asset_group.Inventory_item_flag);
	END IF;

	-- 1.1: Set up Item Number. Use segments if specified.
	IF 	p_segment1 IS NOT NULL OR
		p_segment2 IS NOT NULL OR
		p_segment3 IS NOT NULL OR
		p_segment4 IS NOT NULL OR
		p_segment5 IS NOT NULL OR
		p_segment6 IS NOT NULL OR
		p_segment7 IS NOT NULL OR
		p_segment8 IS NOT NULL OR
		p_segment9 IS NOT NULL OR
		p_segment10 IS NOT NULL OR
		p_segment11 IS NOT NULL OR
		p_segment12 IS NOT NULL OR
		p_segment13 IS NOT NULL OR
		p_segment14 IS NOT NULL OR
		p_segment15 IS NOT NULL OR
		p_segment16 IS NOT NULL OR
		p_segment17 IS NOT NULL OR
		p_segment18 IS NOT NULL OR
		p_segment19 IS NOT NULL OR
		p_segment20 IS NOT NULL
	THEN
		l_asset_group.Segment1 := p_segment1;
		l_asset_group.Segment2 := p_segment2;
		l_asset_group.Segment3 := p_segment3;
		l_asset_group.Segment4 := p_segment4;
		l_asset_group.Segment5 := p_segment5;
		l_asset_group.Segment6 := p_segment6;
		l_asset_group.Segment7 := p_segment7;
		l_asset_group.Segment8 := p_segment8;
		l_asset_group.Segment9 := p_segment9;
		l_asset_group.Segment10 := p_segment10;
		l_asset_group.Segment11 := p_segment11;
		l_asset_group.Segment12 := p_segment12;
		l_asset_group.Segment13 := p_segment13;
		l_asset_group.Segment14 := p_segment14;
		l_asset_group.Segment15 := p_segment15;
		l_asset_group.Segment16 := p_segment16;
		l_asset_group.Segment17 := p_segment17;
		l_asset_group.Segment18 := p_segment18;
		l_asset_group.Segment19 := p_segment19;
		l_asset_group.Segment20 := p_segment20;
	ELSE
		l_asset_group.Item_Number := p_asset_group;
	END IF;

    --derive and assign master org
    select master_organization_id into l_master_org_id
    from mtl_parameters
    where organization_id = p_organization_id;

    l_asset_group.organization_id := l_master_org_id;

    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'l_asset_group.organization_id'||l_asset_group.organization_id);
    END IF;

	-- Set EAM attributes
    l_asset_group.EAM_ITEM_TYPE := p_eam_item_type; -- EAM Asset Activity

    if p_eam_item_type = 1 then
	l_asset_group.COMMS_NL_TRACKABLE_FLAG := 'Y';
    else
	if p_serial_generation = 1 then
		l_asset_group.COMMS_NL_TRACKABLE_FLAG := 'N';
	else
		l_asset_group.COMMS_NL_TRACKABLE_FLAG := 'Y';
	end if;
    end if;


    IF (l_plog) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Calling INV_ITEM_GRP.Create_Item...'||
		'Comms_NL_Trackable_Flag: '||l_asset_group.comms_nl_trackable_flag||
		' Inventory_Item_Flag: '||l_asset_group.Inventory_item_flag);
    END IF;

    INV_ITEM_GRP.Create_Item
    (
        p_Item_rec      =>  l_asset_group,
	p_Template_Id   =>  p_source_tmpl_id,
	p_Template_Name =>  p_template_name,
        x_Item_rec      =>  l_x_master_item_rec,
        x_return_status =>  l_x_master_item_return_status,
        x_Error_tbl     =>  l_x_master_item_error_tbl
    );

    IF (l_plog) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Returned from INV_ITEM_GRP.Create_Item...'||
		'Comms_NL_Trackable_Flag: '||l_x_master_item_rec.comms_nl_trackable_flag||
		' Inventory_Item_Flag: '||l_x_master_item_rec.Inventory_item_flag);
    END IF;

    IF (l_x_master_item_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	IF (l_master_org_id <> p_organization_id) THEN
        	l_asset_group.organization_id := p_organization_id;

    		IF (l_plog) THEN
         		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Calling INV_ITEM_GRP.Create_Item...'||
			'Comms_NL_Trackable_Flag: '||l_asset_group.comms_nl_trackable_flag||
			' Inventory_Item_Flag: '||l_asset_group.Inventory_item_flag);
    		END IF;

        	INV_ITEM_GRP.Create_Item
        	(
            		p_Item_rec      =>  l_asset_group,
            		x_Item_rec      =>  l_x_curr_item_rec,
            		x_return_status =>  l_x_return_status,
            		x_Error_tbl     =>  l_x_curr_item_error_tbl,
            		p_Template_Id   =>  p_source_tmpl_id
        	);

		IF (l_plog) THEN
        		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
			'Returned from INV_ITEM_GRP.Create_Item...'||
			'Comms_NL_Trackable_Flag: '||l_x_curr_item_rec.comms_nl_trackable_flag||
			' Inventory_Item_Flag: '||l_x_curr_item_rec.Inventory_item_flag);
        	END IF;


        	IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			x_return_status := 'S';
        	ELSE

            		v_row := l_x_curr_item_error_tbl.FIRST;
            		LOOP
                		EXIT WHEN v_row IS NULL;

                		FND_MESSAGE.SET_NAME('INV', l_x_curr_item_error_tbl(v_row).message_name);
                		FND_MSG_PUB.ADD;
                		x_msg_data :=  x_msg_data || '    ' ||l_x_curr_item_error_tbl(v_row).unique_id||'  '||l_x_curr_item_error_tbl(v_row).message_text;
                 		v_row := l_x_curr_item_error_tbl.NEXT(v_row);
            		end loop;

            		x_return_status := 'E';
        	END IF;
	END IF;
    ELSE

            v_row := l_x_master_item_error_tbl.FIRST;
            LOOP
                EXIT WHEN v_row IS NULL;

                FND_MESSAGE.SET_NAME('INV', l_x_master_item_error_tbl(v_row).message_name);
                FND_MSG_PUB.ADD;
                x_msg_data := x_msg_data || '    ' ||l_x_master_item_error_tbl(v_row).unique_id||'  '|| l_x_master_item_error_tbl(v_row).message_text;
                 v_row := l_x_master_item_error_tbl.NEXT(v_row);
            end loop;

            x_return_status := 'E';

    END IF;

    IF fnd_api.to_boolean(p_commit) THEN
	commit;
    END IF;

    x_item_id := l_x_curr_item_rec.inventory_item_id;

    IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_ITEM_PVT.Insert_item ====================');
    END IF;
END INSERT_ITEM;

PROCEDURE update_item
(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE
	, x_return_status		OUT NOCOPY VARCHAR2
	, x_msg_count			OUT NOCOPY NUMBER
	, x_msg_data	    		OUT NOCOPY VARCHAR2
    	, p_inventory_item_id     	IN NUMBER
	, P_SOURCE_TMPL_ID		IN	NUMBER
    	, p_template_name       IN  VARCHAR2
    	, p_organization_id             IN NUMBER
    	, p_description         	IN  VARCHAR2
    	, p_serial_generation   	IN  NUMBER
    	, p_prefix_text         	IN  VARCHAR2
    	, p_prefix_number       	IN  VARCHAR2
)

IS

	l_update_item_ver		NUMBER := 1.0;
	l_x_return_status		VARCHAR2(1);
	l_x_msg_count			NUMBER;
	l_x_msg_data			VARCHAR2(20000);
    	l_master_org_id number;

	l_asset_group			INV_Item_GRP.Item_Rec_Type;
	l_x_inventory_item_id		NUMBER;

	l_api_name			CONSTANT VARCHAR2(30)	:= 'Update_item';

	l_module            		varchar2(200);
	l_log_level CONSTANT NUMBER 	:= fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN 	:= fnd_log.level_unexpected >= l_log_level;
	l_pLog CONSTANT BOOLEAN 	:= l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN 	:= l_pLog AND fnd_log.level_statement >= l_log_level;

-- output variables of inv package
	l_x_curr_item_rec		INV_Item_GRP.Item_Rec_Type;
	l_x_curr_item_return_status	VARCHAR2(1);
	l_x_curr_item_error_tbl		INV_Item_GRP.Error_Tbl_Type;
	l_x_master_item_error_tbl	INV_Item_GRP.Error_Tbl_Type;

    v_row PLS_INTEGER;

BEGIN
        if (l_ulog) then
	   l_module  := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

	l_asset_group.Description := p_description;
	l_asset_group.SERIAL_NUMBER_CONTROL_CODE := p_serial_generation;
	l_asset_group.AUTO_SERIAL_ALPHA_PREFIX := p_prefix_text;
	l_asset_group.START_AUTO_SERIAL_NUMBER := p_prefix_number;
	l_asset_group.organization_id := p_organization_id;
	l_asset_group.inventory_item_id := p_inventory_item_id;

       IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ITEM_PVT.Update_item ===================='||
		'Comms_NL_Trackable_Flag: '||l_asset_group.comms_nl_trackable_flag||
		' Inventory_Item_Flag: '||l_asset_group.Inventory_item_flag);

	      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Calling INV_ITEM_GRP.Update_Item...');
       END IF;

   if p_source_tmpl_id is not null or p_template_name is not null then

    	--derive and assign master org
    	select master_organization_id into l_master_org_id
    	from mtl_parameters
    	where organization_id = p_organization_id;

    	l_asset_group.organization_id := l_master_org_id;

    	INV_ITEM_GRP.Update_Item
    	(
        	p_Item_rec      =>  l_asset_group,
		p_Template_Id   =>  p_source_tmpl_id,
		p_Template_Name =>  p_template_name,
        	x_Item_rec      =>  l_x_curr_item_rec,
        	x_return_status =>  l_x_return_status,
        	x_Error_tbl     =>  l_x_curr_item_error_tbl
    	);

        IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            v_row := l_x_master_item_error_tbl.FIRST;
            LOOP
                EXIT WHEN v_row IS NULL;

                FND_MESSAGE.SET_NAME('INV', l_x_master_item_error_tbl(v_row).message_name);
                FND_MSG_PUB.ADD;
                x_msg_data := x_msg_data || '    ' ||l_x_master_item_error_tbl(v_row).unique_id||'  '|| l_x_master_item_error_tbl(v_row).message_text;
                 v_row := l_x_master_item_error_tbl.NEXT(v_row);
            end loop;

            x_return_status := 'E';

        END IF;

   end if;

    l_asset_group.organization_id := p_organization_id;

    	INV_ITEM_GRP.Update_Item
    	(
        	p_Item_rec      =>  l_asset_group,
        	x_Item_rec      =>  l_x_curr_item_rec,
        	x_return_status =>  l_x_return_status,
        	x_Error_tbl     =>  l_x_curr_item_error_tbl
    	);

        IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Returned from INV_ITEM_GRP.Update_Item...'||
		'Comms_NL_Trackable_Flag: '||l_x_curr_item_rec.comms_nl_trackable_flag||
		' Inventory_Item_Flag: '||l_x_curr_item_rec.Inventory_item_flag);
        END IF;

        IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		    x_return_status := 'S';
        ELSE

            v_row := l_x_curr_item_error_tbl.FIRST;
            LOOP
                EXIT WHEN v_row IS NULL;

                FND_MESSAGE.SET_NAME('INV', l_x_curr_item_error_tbl(v_row).message_name);
                FND_MSG_PUB.ADD;
                x_msg_data :=  x_msg_data || '    ' ||l_x_curr_item_error_tbl(v_row).unique_id||'  '||l_x_curr_item_error_tbl(v_row).message_text;
                 v_row := l_x_curr_item_error_tbl.NEXT(v_row);
            end loop;

            x_return_status := 'E';
        END IF;

	IF fnd_api.to_boolean(p_commit) THEN
		commit;
	END IF;

     	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_ITEM_PVT.Update_item ====================');
     	END IF;
END UPDATE_ITEM;

PROCEDURE Lock_Item(
	p_commit	    		IN  	VARCHAR2:= FND_API.G_FALSE		, x_return_status		OUT NOCOPY VARCHAR2
	, x_msg_count			OUT NOCOPY NUMBER
	, x_msg_data	    	OUT NOCOPY VARCHAR2
    , p_inventory_item_id     IN NUMBER
    , p_organization_id     IN NUMBER
)


IS

    l_x_curr_item_error_tbl		INV_Item_GRP.Error_Tbl_Type;
    l_x_return_status VARCHAR2(1);
    l_api_name			CONSTANT VARCHAR2(30)	:= 'Lock_item';

    l_module          varchar2(200);
    l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
    l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
    l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;


  BEGIN

   -- Standard Start of API savepoint
      SAVEPOINT lock_item;
        if (l_ulog) then
	   l_module  := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
	end if;

      IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Entered EAM_ITEM_PVT.Lock_item ===================='
		|| 'p_organization_id = ' || p_organization_id
		|| 'p_inventory_item_id = ' ||p_inventory_item_id);

	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Calling INV_ITEM_GRP.Lock_Item...');
      END IF;

      INV_ITEM_GRP.Lock_Item
      (     p_Item_ID => p_inventory_item_id
        ,   p_Org_ID => p_organization_id
        ,   x_return_status => l_x_return_status
        ,   x_Error_tbl => l_x_curr_item_error_tbl
      );


    x_return_status := l_x_return_status;

     IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Returned from INV_ITEM_GRP.Lock_Item with l_x_return_status '||l_x_return_status);
      END IF;
    if nvl(l_x_return_status, 'S') not in ('E','U') then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
	 IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Commiting Work');
         END IF;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO lock_ITEM;
	  IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Rollback To Lock_Item.....');
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==============INV_ITEM_GRP.Lock_Item :EXPECTED ERROR===================');
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO lock_ITEM;
         IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Rollback To Lock_Item.....');
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==============INV_ITEM_GRP.Lock_Item :UNEXPECTED ERROR===================');
         END IF;
	 x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO lock_ITEM;
	 IF (l_plog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'Rollback To Lock_Item.....');
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==============INV_ITEM_GRP.Lock_Item :OTHER ERROR===================');
         END IF;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, 'LOCK_ITEM');
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

	IF (l_plog) THEN
	        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
		'==================== Exiting EAM_ITEM_PVT.Lock_item ====================');
        END IF;

END LOCK_ITEM;

END EAM_ITEM_PVT;

/
