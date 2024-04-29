--------------------------------------------------------
--  DDL for Package Body WIP_EAM_GENEALOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_GENEALOGY_PVT" AS
/* $Header: WIPVEGNB.pls 120.8.12010000.2 2008/12/23 10:18:23 smrsharm ship $*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'WIP_EAM_GENEALOGY_PVT';

PROCEDURE create_eam_genealogy(
                        p_api_version               IN  NUMBER,
                        p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
                        p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                        p_subinventory              IN  VARCHAR2 := NULL,
                        p_locator_id                IN  NUMBER   := NULL,
                        p_object_id                 IN  NUMBER   := NULL,
                        p_serial_number             IN  VARCHAR2 := NULL,
                        p_organization_id           IN  NUMBER   := NULL,
                        p_inventory_item_id         IN  NUMBER   := NULL,
                        p_parent_object_id          IN  NUMBER   := NULL,
                        p_parent_serial_number      IN  VARCHAR2 := NULL,
                        p_parent_inventory_item_id  IN  NUMBER   := NULL,
                        p_parent_organization_id    IN  NUMBER   := NULL,
                        p_start_date_active         IN  DATE     := SYSDATE,
                        p_end_date_active           IN  DATE     := NULL,
			p_origin_txn_id                 IN  NUMBER   := NULL,
			p_update_txn_id                 IN  NUMBER   := NULL,
                        p_from_eam                  IN  VARCHAR2 := NULL,
                        x_msg_count                 OUT NOCOPY NUMBER,
                        x_msg_data                  OUT NOCOPY VARCHAR2,
                        x_return_status             OUT NOCOPY VARCHAR2) is

 l_api_name          CONSTANT VARCHAR(30) := 'CREATE_EAM_GENEALOGY';
 l_module            constant varchar2(200) := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;

l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND fnd_log.test(fnd_log.level_unexpected, l_module);
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

/*
 l_log               boolean := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
 l_plog              boolean ; -- := l_log and FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, l_module);
 l_slog              boolean := l_plog and FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, l_module);
*/

 l_errCode           number;
 l_msg_count         number;
 l_msg_data          varchar2(100);
 l_return_status     varchar2(5);
 l_statement         number;
 l_txn_id            number;
 l_update_txn_id     number;
 l_current_status    number;
 l_revision	     varchar2(3);
 l_dist_acct_id      number;
 l_serial_number     varchar2(30);
 l_inventory_item_id number;
 l_parent_inventory_item_id number;
 l_subinventory      varchar2(30);
 l_locator_id        number;
 l_organization_id   number;
 l_parent_organization_id number;
 l_serial_control    number;
 l_api_version       number := 1.0;
 l_parent_object_id  number;
 l_parent_serial_number varchar2(30) := null;
 l_charge_object_id  number;
 l_wms_installed varchar2(10);

 /* R12 Hook for Asset Log #4141712*/
 l_maint_orgid	     number;
 l_event_type	     varchar2(30)	:= 'EAM_SYSTEM_EVENTS';
 l_parent_instance_id number;
 l_instance_id number;
 l_reference	     varchar2(30);
 l_parent_instance_number varchar2(30);


begin
--   l_plog := ( (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) AND l_log );
    savepoint eam_rebuild_genealogy;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN

        FND_MSG_PUB.initialize;

    END IF;

--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;


  if (l_plog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
      'Start of ' || l_module || '('
      || 'p_organization_id='|| p_organization_id || ','
      || 'p_subinventory='|| p_subinventory || ','
      || 'p_locator_id='|| p_locator_id || ','
      || 'p_object_id='|| p_object_id || ','
      || 'p_serial_number='|| p_serial_number ||','
      || 'p_inventory_item_id='|| p_inventory_item_id || ','
      || 'p_parent_object_id='|| p_parent_object_id || ','
      || 'p_parent_serial_number='|| p_parent_serial_number || ','
      || 'p_parent_inventory_item_id='|| p_parent_inventory_item_id ||','
      || 'p_parent_organization_id='|| p_parent_organization_id || ','
      || 'p_start_date_active='|| p_start_date_active || ','
      || 'p_end_date_active='|| p_end_date_active ||','
      || 'p_from_eam='|| p_from_eam || ','
      || 'p_commit='|| p_commit
      || ')');
    end if;

    l_txn_id := p_origin_txn_id;
    l_update_txn_id := p_update_txn_id;

-- return without error if item is not serial controlled when
-- the genealogy is not originating from eam
if (((p_from_eam is null) or (p_from_eam = FND_API.G_FALSE))
	and ((p_object_id is null) and (p_serial_number is null))) then
	select serial_number_control_code into l_serial_control
	from mtl_system_items
	where inventory_item_id = p_inventory_item_id and
	      organization_id = p_organization_id;

	if (l_serial_control = 1) then
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		return;
	end if;
end if;


-- obtain rebuildable information
    if p_object_id is null then

	if p_serial_number is null or p_inventory_item_id is null or p_organization_id is null then
	   -- if serial_number is null, then quit processing
	   FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
        else
           l_serial_number := p_serial_number;
           l_inventory_item_id := p_inventory_item_id;
           select current_organization_id into l_organization_id
           from mtl_serial_numbers
           where serial_number = l_serial_number
  		    and inventory_item_id = l_inventory_item_id;
           -- l_organization_id   := p_organization_id;

        end if;
    else
        if (p_serial_number is null) or (p_inventory_item_id is null) or (p_organization_id is null) then
	    begin
	        select serial_number, inventory_item_id, current_organization_id
                  into l_serial_number, l_inventory_item_id, l_organization_id
                  from mtl_serial_numbers
               	 where gen_object_id = p_object_id;
	    exception
			when others then
		            FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
        		    FND_MSG_PUB.ADD;
        		    RAISE FND_API.G_EXC_ERROR;
	    end;
        else
            l_serial_number := p_serial_number;
            l_inventory_item_id := p_inventory_item_id;
            select current_organization_id into l_organization_id
           from mtl_serial_numbers
               	 where gen_object_id = p_object_id;
            --l_organization_id   := p_organization_id;
        end if;

    end if;

-- obtain parent object id information
    if p_parent_object_id is null then
        if p_parent_serial_number is null or p_parent_inventory_item_id is null or p_parent_organization_id is null then
                -- if there is no parent information, then quit processing
	        FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_INVALID_PARENT_ITEM');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;

    	else
	    begin

		   l_parent_serial_number := p_parent_serial_number;
		   l_parent_inventory_item_id := p_parent_inventory_item_id;

	            select gen_object_id, current_organization_id
              	    into l_parent_object_id, l_parent_organization_id
              	    from mtl_serial_numbers
             	    where serial_number = l_parent_serial_number
               		and inventory_item_id = p_parent_inventory_item_id;
	    exception
			when others then
		            FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_INVALID_PARENT_ITEM');
        		    FND_MSG_PUB.ADD;
        		    RAISE FND_API.G_EXC_ERROR;
	   end;
    	end if;

    else
        l_parent_object_id := p_parent_object_id;
        select current_organization_id,serial_number,inventory_item_id
         into
         l_parent_organization_id,
         l_parent_serial_number,
         l_parent_inventory_item_id
           from mtl_serial_numbers
            where gen_object_id = l_parent_object_id;

    end if;

-- check if there is an open work order against the rebuild item.  If the parent does not correspond to the charge asset in the work order, there is an error.  If the charge asset is null, this is not a problem.

    begin
        select msn.gen_object_id
          into l_charge_object_id
          from wip_discrete_jobs wdj, mtl_serial_numbers msn
         where wdj.rebuild_serial_number = l_serial_number
           and wdj.rebuild_item_id = l_inventory_item_id
           and wdj.organization_id = l_organization_id
           and msn.serial_number = wdj.asset_number
           and msn.inventory_item_id = wdj.asset_group_id
           and msn.current_organization_id = wdj.organization_id
           and wdj.manual_rebuild_flag = 'N'
           and wdj.status_type in (1,3,6);

        if l_charge_object_id <> l_parent_object_id then
            FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_WO_WITH_CHARGE_ASSET');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

    exception
    when others then
        null;
    end;

-- perform genealogy creation

            FND_MSG_PUB.initialize;

            inv_genealogy_pub.insert_genealogy(
                 p_api_version              => l_api_version,
                 p_object_type              => 2,
                 p_parent_object_type       => 2,
                 p_object_number            => l_serial_number,
                 p_inventory_item_id        => l_inventory_item_id,
                 p_org_id                   => l_organization_id,
                 p_parent_object_id         => l_parent_object_id,
                 p_parent_object_number     => l_parent_serial_number,
                 p_parent_inventory_item_id => l_parent_inventory_item_id,
                 p_parent_org_id            => l_parent_organization_id,
                 p_genealogy_origin         => 3,
                 p_genealogy_type           => 5,
                 p_start_date_active        => p_start_date_active,
                 p_end_date_active          => p_end_date_active,
                 p_origin_txn_id            => null,
		     p_update_txn_id            => null,
                 x_return_status            => l_return_status,
                 x_msg_count                => x_msg_count,
                 x_msg_data                 => x_msg_data);

        	if (l_return_status = 'E') then
            	raise FND_API.G_EXC_ERROR;
		elsif (l_return_status = 'U') then
            	raise FND_API.G_EXC_UNEXPECTED_ERROR;
        	end if;

/* R12 Hook for Asset Log #4141712 Begin */

		--Add child Event - 15

		begin

			SELECT cii.instance_id, mp.maint_organization_id,cii.instance_number
		  	INTO l_parent_instance_id , l_maint_orgid,l_parent_instance_number
		  	FROM csi_item_instances cii, mtl_parameters mp
		 	WHERE cii.serial_number = l_parent_serial_number
		   	AND cii.inventory_item_id = l_parent_inventory_item_id
		   	AND cii.last_vld_organization_id = mp.organization_id
		   	AND cii.last_vld_organization_id= l_organization_id ;

			SELECT cii.instance_number, cii.instance_id
		  	INTO l_reference, l_instance_id
		  	FROM csi_item_instances cii
		 	WHERE cii.serial_number = l_serial_number
		   	AND cii.inventory_item_id = l_inventory_item_id
		   	AND cii.last_vld_organization_id = l_organization_id;

			eam_asset_log_pvt.insert_row(
				p_event_date		    =>	p_start_date_active,
				p_event_type		    =>	l_event_type,
				p_event_id		    =>	15,
				p_organization_id	    =>	l_maint_orgid,
				p_instance_id		    =>	l_parent_instance_id,
				p_reference		    =>	l_reference,
				p_ref_id		    =>	l_instance_id,
				p_instance_number	    =>	l_parent_instance_number,
				x_return_status		    =>	l_return_status,
				x_msg_count		    =>	x_msg_count,
				x_msg_data		    =>	x_msg_data
			);

			eam_asset_log_pvt.insert_row(
				p_event_date		    =>	p_start_date_active,
				p_event_type		    =>	l_event_type,
				p_event_id		    =>	14,
				p_organization_id	    =>	l_maint_orgid,
				p_instance_id		    =>	l_instance_id,
				p_reference		    =>	l_parent_instance_number,
				p_ref_id		    =>	l_parent_instance_id,
				p_instance_number	    =>	l_reference,
				x_return_status		    =>	l_return_status,
				x_msg_count		    =>	x_msg_count,
				x_msg_data		    =>	x_msg_data
			);


    		exception
			WHEN NO_DATA_FOUND THEN
				null;
    		end;

/* R12 Hook for Asset Log #4141712 End */


    if p_commit = FND_API.G_TRUE then
            commit;
    end if;

    exception
     WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO eam_rebuild_genealogy;

         x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.Count_And_Get
            (   p_encoded           =>      FND_API.G_FALSE,
                p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

     WHEN OTHERS THEN
        ROLLBACK TO eam_rebuild_genealogy;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
            (   p_encoded           =>      FND_API.G_FALSE,
                p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );

END CREATE_EAM_GENEALOGY;



PROCEDURE update_eam_genealogy(
                        p_api_version         IN  NUMBER,
                        p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                        p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                        p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                        p_object_type         IN  NUMBER,
                        p_object_id           IN  NUMBER   := NULL,
                        p_serial_number       IN  VARCHAR2 := NULL,
                        p_inventory_item_id   IN  NUMBER   := NULL,
                        p_organization_id     IN  NUMBER   := NULL,
                        p_subinventory        IN  VARCHAR2 := NULL,
                        p_locator_id          IN  NUMBER   := NULL,
                        p_genealogy_origin    IN  NUMBER   := NULL,
                        p_genealogy_type      IN  NUMBER   := NULL,
                        p_end_date_active     IN  DATE     := NULL,
                        p_from_eam            IN  VARCHAR2 := NULL,
                        x_return_status       OUT NOCOPY VARCHAR2,
                        x_msg_count           OUT NOCOPY NUMBER,
                        x_msg_data            OUT NOCOPY VARCHAR2) is

 l_api_name          CONSTANT VARCHAR(30) := 'UPDATE_EAM_GENEALOGY';
 l_module            constant varchar2(200) := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;

/*
 l_log               boolean := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
 l_plog              boolean := l_log and FND_LOG.TEST(FND_LOG.LEVEL_PROCEDURE, l_module);
 l_slog              boolean := l_plog and FND_LOG.TEST(FND_LOG.LEVEL_STATEMENT, l_module);
*/

l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level AND fnd_log.test(fnd_log.level_unexpected, l_module);
l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

 l_errCode           number;
 l_msg_count         number;
 l_msg_data          varchar2(100);
 l_return_status     varchar2(5);
 l_statement         number;
 l_txn_id            number := null;
 l_dist_acct_id      number;
 l_api_version       number := 1.0;
 l_serial_number     varchar2(30);
 l_subinventory      varchar2(30);
 l_locator_id        number;
 l_inventory_item_id number;
 l_revision	     varchar2(3);
 l_object_id         number;
 l_organization_id   number;
 l_txn_type          number;
 l_txn_action_id     number;
 l_txn_source_type   number;
 l_wip_entity_id     number;
 l_work_status       number;
 l_original_txn_id   number;
 l_wms_installed varchar2(10);
 l_sub_code number;
 l_dummy number;

 /* R12 Hook for Asset Log #4141712 To get Parent Object Id Begin*/
 l_maint_orgid	    number;
 l_event_type	    varchar2(30)	:= 'EAM_SYSTEM_EVENTS';
 l_parent_instance_id number;
 l_instance_id	    number;
 l_reference	    varchar2(30);
 l_parent_object_id number;
 l_parent_instance_number varchar2(30);
 x_locator_ctrl  NUMBER ;
 x_error_flag    NUMBER ;
 x_error_mssg  VARCHAR2(100);


begin

    savepoint eam_rebuild_genealogy;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                   p_api_version,
                                   l_api_name,
                                   g_pkg_name)
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN

       FND_MSG_PUB.initialize;

    END IF;

--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    if (l_plog) then	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
      'Start of ' || l_module || '('
      || 'p_organization_id='|| p_organization_id || ','
      || 'p_subinventory='|| p_subinventory || ','
      || 'p_locator_id='|| p_locator_id || ','
      || 'p_object_type='|| p_object_type || ','
      || 'p_object_id='|| p_object_id || ','
      || 'p_serial_number='|| p_serial_number ||','
      || 'p_inventory_item_id='|| p_inventory_item_id || ','
      || 'p_end_date_active='|| p_end_date_active ||','
      || 'p_from_eam='|| p_from_eam || ','
      || 'p_commit='|| p_commit
      || ')');
    end if;


-- return without error if serial number is not specified when
-- the genealogy is not originating from eam
    if (((p_from_eam is null) or (p_from_eam = FND_API.G_FALSE))
	and ((p_serial_number is null) and (p_object_id is null))) then
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		return;
    end if;

-- obtain rebuildable information
    if p_object_id is null then

        if p_serial_number is null
           or p_inventory_item_id is null
           or p_organization_id is null then

-- if serial_number is null, then quit processing
	            FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
        	    FND_MSG_PUB.ADD;
        	    RAISE FND_API.G_EXC_ERROR;
        else
            l_serial_number :=  p_serial_number;
            l_inventory_item_id := p_inventory_item_id;
            --l_organization_id := p_organization_id;


            begin
                select gen_object_id,current_organization_id  into l_object_id, l_organization_id
                from mtl_serial_numbers
                where serial_number = l_serial_number
                and inventory_item_id = p_inventory_item_id;

            exception
            when others then
                 FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
            end;
        end if;

    else

        if (p_serial_number is null)
            or (p_inventory_item_id is null)
            or (p_organization_id is null) then

            begin
                select serial_number, inventory_item_id, current_organization_id
                into l_serial_number, l_inventory_item_id, l_organization_id
                from mtl_serial_numbers where
                gen_object_id = p_object_id;

            exception
            when others then
                 FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_ITEM_DOES_NOT_EXIST');
                 FND_MSG_PUB.ADD;
                 RAISE FND_API.G_EXC_ERROR;
            end;

        else
            l_serial_number :=  p_serial_number;
            l_inventory_item_id := p_inventory_item_id;
            --l_organization_id := p_organization_id;
            select current_organization_id into l_organization_id
           from mtl_serial_numbers
               	 where gen_object_id = p_object_id;

        end if;

        l_object_id := p_object_id;

    end if;


-- perform misc inventory transaction if p_from_eam is set to TRUE.
  if FND_API.to_Boolean( p_from_eam ) and (p_subinventory is not null) THEN


        l_subinventory := p_subinventory;

  	IF inv_install.adv_inv_installed(NULL) THEN
		l_wms_installed := 'TRUE';
 	ELSE
		l_wms_installed := 'FALSE';
  	END IF;

	if inv_material_status_grp.is_status_applicable(
			l_wms_installed,
			NULL,
			42,
			NULL,
			NULL,
			l_organization_id,
			l_inventory_item_id,
			l_subinventory,
			NULL,
			NULL,
			NULL,
			'Z') <> 'Y' then
	        FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_INVALID_SUBINVENTORY');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
	end if;

	select restrict_subinventories_code
	into l_sub_code
	from mtl_system_items
	where inventory_item_id = l_inventory_item_id
	and organization_id = l_organization_id;

	if l_sub_code = 1 then

	   l_dummy := 1;

	   begin
		   select 10 into l_dummy from dual
		   where exists
			(select *
	   		from mtl_item_sub_inventories
	   		where inventory_item_id = l_inventory_item_id
       	   		and organization_id = l_organization_id
			and secondary_inventory = l_subinventory);
	    exception
		when others then
		   FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_INVALID_SUBINVENTORY');
        	   FND_MSG_PUB.ADD;
        	   RAISE FND_API.G_EXC_ERROR;
	    end;

	    if l_dummy <> 10 then
	        FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_INVALID_SUBINVENTORY');
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
	    end if;

	end if;


    if p_locator_id is null then
        begin
            select current_locator_id into l_locator_id
            from mtl_serial_numbers
            where serial_number = l_serial_number and
                  inventory_item_id = l_inventory_item_id and
                  current_organization_id = l_organization_id;

        exception
        when others then
            null;
        end;
    else
            l_locator_id := p_locator_id;
    end if;

     Get_LocatorControl_Code(
                      l_organization_id,
                      l_subinventory,
                      l_inventory_item_id,
                      27,
                      x_locator_ctrl,
                      x_error_flag,
                      x_error_mssg);


-- if the locator control is Predefined or Dynamic Entry
if(x_locator_ctrl = 2 or x_locator_ctrl = 3) then
 if(p_locator_id IS NULL) then
   FND_MESSAGE.SET_NAME('EAM', 'EAM_RET_MAT_LOCATOR_NEEDED');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
 end if;
elsif(x_locator_ctrl = 1) then -- If the locator control is NOControl
 if(p_locator_id IS NOT NULL) then
   FND_MESSAGE.SET_NAME('EAM', 'EAM_RET_MAT_LOCATOR_RESTRICTED');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
 end if;
end if; -- end of locator_control checkif



-- genealogy update in future is not allowed
-- This restriction has been put in place because eventhough the date
-- of transaction is future, the status of the item is changed immediately

    if p_end_date_active is not null and p_end_date_active > sysdate then
       FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_REBUILD_FUTURE_TXN');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    else

-- obtain the offset account id from user-defined EAM parameters
            select maintenance_offset_account into l_dist_acct_id
            from wip_eam_parameters
            where organization_id = l_organization_id;

	if l_dist_acct_id is null then
            FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_NO_OFFSET_ACCOUNT');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        end if;

--obtain the revision of the object from MSN
    select revision into l_revision
    from mtl_serial_numbers
    where serial_number = l_serial_number and
    inventory_item_id = l_inventory_item_id and
    current_organization_id = l_organization_id;

-- call the Transaction processing API
-- if API returns success, call the inventory genealogy API
        wip_eam_transactions_pvt.process_eam_txn(
                           p_subinventory               => l_subinventory,
                           p_serial_number              => l_serial_number,
                           p_locator_id                 => l_locator_id,
                           p_organization_id            => l_organization_id,
                           p_inventory_item_id          => l_inventory_item_id,
                           p_dist_acct_id               => l_dist_acct_id,
                           p_transaction_type_id        => 42,
                           p_transaction_quantity       => 1,
                           p_transaction_action_id      => 27,
                           p_transaction_source_type_id => 13,
			   p_revision			=> l_revision,
                           x_errCode                    => l_errCode,
                           x_msg_count                  => x_msg_count,
                           x_msg_data                   => x_msg_data,
                           x_return_status              => l_return_status,
                           x_statement                  => l_statement);

            select last_transaction_id
            into l_txn_id
            from mtl_serial_numbers
            where serial_number = l_serial_number
		and current_organization_id = l_organization_id and
		inventory_item_id = l_inventory_item_id;

	if l_txn_id is null then
           RAISE FND_API.G_EXC_ERROR;
        end if;

    end if;

  end if;


-- perform genealogy update

    if l_return_status = 'S' then

/* R12 Hook for Asset Log #4141712 To get Parent Object Id Begin*/
		SELECT parent_object_id INTO l_parent_object_id
		  FROM mtl_object_genealogy
		 WHERE genealogy_type = 5
		   AND object_id = l_object_id
		   AND end_date_active IS NULL;
/* R12 Hook for Asset Log #4141712 To get Parent Object Id End*/

        FND_MSG_PUB.initialize;

       inv_genealogy_pub.update_genealogy(
                           p_api_version       => l_api_version,
                           p_object_type       => 2,
                           p_object_number     => l_serial_number,
                           p_inventory_item_id => l_inventory_item_id,
                           p_org_id            => l_organization_id,
                           p_genealogy_origin  => 3,
                           p_genealogy_type    => 5,
                           p_end_date_active   => p_end_date_active,
                           p_update_txn_id     => l_txn_id,
                           x_return_status     => l_return_status,
                           x_msg_count         => x_msg_count,
                           x_msg_data          => x_msg_data);

        if (l_return_status = 'E') then
            raise FND_API.G_EXC_ERROR;
	elsif (l_return_status = 'U') then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

/* R12 Hook for Asset Log #4141712 Begin */
	--Remove Parent Instance from Child Instance - 17
	begin
		SELECT cii.instance_id, mp.maint_organization_id
		  INTO l_instance_id , l_maint_orgid
		  FROM csi_item_instances cii, mtl_parameters mp
		 WHERE cii.serial_number = l_serial_number
		   AND cii.inventory_item_id = l_inventory_item_id
		   AND cii.last_vld_organization_id = mp.organization_id
		   AND cii.last_vld_organization_id= l_organization_id ;

                SELECT cii.instance_number ,cii.instance_id
 		  INTO l_reference, l_parent_instance_id
		  FROM csi_item_instances cii, mtl_serial_numbers msn
		 WHERE cii.serial_number = msn.serial_number
		   AND cii.inventory_item_id = msn.inventory_item_id
		   AND cii.last_vld_organization_id = msn.current_organization_id
		   AND msn.gen_object_id= l_parent_object_id ;

		eam_asset_log_pvt.insert_row(
				p_event_date	    => p_end_date_active,
				p_event_type	    => l_event_type,
				p_event_id	    => 17,
				p_organization_id   => l_maint_orgid,
				p_instance_id	    => l_instance_id,
				p_reference	    => l_reference,
				p_ref_id	    => l_parent_instance_id,
				p_instance_number   => l_serial_number,
				x_return_status	    => l_return_status,
				x_msg_count	    => x_msg_count,
				x_msg_data	    => x_msg_data
				);

	    exception
		WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_INSTANCE_ID_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                RETURN;
	end;
	--Remove Child Event  from parent - 16
	begin
		SELECT cii.instance_id, cii.instance_number
		  INTO l_parent_instance_id, l_parent_instance_number
		  FROM csi_item_instances cii, mtl_serial_numbers msn
		 WHERE cii.serial_number = msn.serial_number
		   AND cii.inventory_item_id = msn.inventory_item_id
		   AND msn.gen_object_id = l_parent_object_id;

		 SELECT cii.instance_number
		   INTO l_reference
		   FROM csi_item_instances cii
		  WHERE cii.instance_id = l_instance_id
--		    AND cii.inventory_item_id = l_inventory_item_id
		    AND cii.last_vld_organization_id = l_organization_id;

		eam_asset_log_pvt.insert_row(
				p_event_date		    =>	p_end_date_active,
				p_event_type		    =>	l_event_type,
				p_event_id		    =>	16,
				p_organization_id	    =>	l_maint_orgid,
				p_instance_id		    =>	l_parent_instance_id,
				p_reference		    =>	l_reference,
				p_ref_id		    =>	l_instance_id,
				p_instance_number	    =>	l_parent_instance_number,
				x_return_status		    =>	l_return_status,
				x_msg_count		    =>	x_msg_count,
				x_msg_data		    =>	x_msg_data
				);

	    exception
		WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_INSTANCE_ID_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                RETURN;
	end;
/* R12 Hook for Asset Log #4141712 End */

    else
        raise FND_API.G_EXC_ERROR;
    end if;

    if p_commit = FND_API.G_TRUE then
        commit;
    end if;


    exception
    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO eam_rebuild_genealogy;

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_encoded           =>      FND_API.G_FALSE,
            p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );

     WHEN OTHERS THEN

        ROLLBACK TO eam_rebuild_genealogy;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_encoded           =>      FND_API.G_FALSE,
            p_count             =>      x_msg_count,
            p_data              =>      x_msg_data
        );

end update_eam_genealogy;


Procedure Get_LocatorControl_Code(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER,
                          x_locator_ctrl     OUT NOCOPY NUMBER,
                          x_error_flag       OUT NOCOPY NUMBER, -- returns 0 if no error ,1 if any error .
                          x_error_mssg       OUT NOCOPY VARCHAR2
) IS
x_org_ctrl      NUMBER;
x_sub_ctrl      NUMBER;
x_item_ctrl     NUMBER;
x_neg_flag      NUMBER;
x_restrict_flag NUMBER;
BEGIN

-- initialize the output .
x_error_flag := 0;
x_error_mssg := '';

-- retrive organization level control information
Begin
SELECT
negative_inv_receipt_code,stock_locator_control_code into
x_neg_flag,x_org_ctrl FROM MTL_PARAMETERS
WHERE
organization_id = p_org;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_INVALID_ORGANIZATION';
End;

-- retrive subinventory level control information
Begin
SELECT
locator_type into x_sub_ctrl
FROM MTL_SECONDARY_INVENTORIES
WHERE
organization_id = p_org and
secondary_inventory_name = p_subinv ;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_RET_MAT_INVALID_SUBINV1';
End;


-- retrive Item level control information
Begin

SELECT
location_control_code,restrict_locators_code into
x_item_ctrl,x_restrict_flag
FROM MTL_SYSTEM_ITEMS
WHERE
inventory_item_id = p_item_id and
organization_id = p_org;
Exception
 When no_data_found then
 x_error_flag := 1;
 x_error_mssg := 'EAM_NO_ITEM_FOUND';
End;


 if(x_org_ctrl = 1) then
       x_locator_ctrl := 1;
    elsif(x_org_ctrl = 2) then
       x_locator_ctrl := 2;
    elsif(x_org_ctrl = 3) then
       x_locator_ctrl := 3;
       if(dynamic_entry_not_allowed(x_restrict_flag,
            x_neg_flag,p_action)) then
         x_locator_ctrl := 2;
       end if;
    elsif(x_org_ctrl = 4) then
      if(x_sub_ctrl = 1) then
         x_locator_ctrl := 1;
      elsif(x_sub_ctrl = 2) then
         x_locator_ctrl := 2;
      elsif(x_sub_ctrl = 3) then
         x_locator_ctrl := 3;
         if(dynamic_entry_not_allowed(x_restrict_flag,
              x_neg_flag,p_action)) then
           x_locator_ctrl := 2;
         end if;
      elsif(x_sub_ctrl = 5) then
        if(x_item_ctrl = 1) then
           x_locator_ctrl := 1;
        elsif(x_item_ctrl = 2) then
           x_locator_ctrl := 2;
        elsif(x_item_ctrl = 3) then
           x_locator_ctrl := 3;
           if(dynamic_entry_not_allowed(x_restrict_flag,
                x_neg_flag,p_action)) then
             x_locator_ctrl := 2;
           end if;
        elsif(x_item_ctrl IS NULL) then
           x_locator_ctrl := x_sub_ctrl;
        else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_LOCATOR';
          return ;
        end if;
     else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_SUBINV';
          return ;
      end if;
    else
          x_error_flag := 1;
          x_error_mssg := 'EAM_RET_MAT_INVALID_ORG';
          return ;
    end if;

END Get_LocatorControl_Code; -- end of get_locatorcontrol_code procedure

Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER) return Boolean IS
Begin
if(p_restrict_flag = 2 or p_restrict_flag = null) then
 if(p_neg_flag = 2) then
   if(p_action = 1 or p_action = 2 or p_action = 3 or
      p_action = 21 or  p_action = 30 or  p_action = 32) then
       return TRUE;
   end if;
  else
   return FALSE;
  end if; -- end of neg_flag check
elsif(p_restrict_flag = 1) then
 return TRUE;
end if;
return TRUE;
End Dynamic_Entry_Not_Allowed ;

end WIP_EAM_GENEALOGY_PVT;


/
