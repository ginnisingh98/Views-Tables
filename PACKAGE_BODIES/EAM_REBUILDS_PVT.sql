--------------------------------------------------------
--  DDL for Package Body EAM_REBUILDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REBUILDS_PVT" AS
  /* $Header: EAMWERBB.pls 120.2.12000000.2 2007/03/30 14:17:10 sdandapa ship $*/
  g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_rebuilds_pvt';

PROCEDURE validate_rebuild(
  p_init_msg_list         IN            VARCHAR2,
  p_validate_mode         IN            NUMBER,
  p_organization_id       IN            NUMBER,
  p_wip_entity_id         IN            NUMBER,
  p_rebuild_item_id       IN OUT NOCOPY NUMBER,
  p_rebuild_item_name     IN            VARCHAR2,
  p_rebuild_serial_number IN            VARCHAR2,
  p_rebuild_activity_id   IN OUT NOCOPY NUMBER,
  p_rebuild_activity_name IN            VARCHAR2,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
)  IS
l_dummy_num               number        := null;
l_dummy_char              varchar2(2000) := null;
l_current_status          number := null;
l_object_id               number := null;
l_parent_object_id        number := null;
l_serial_control_code     number := null;
l_cur_organization_id     number := null;
l_module         constant varchar2(200) := 'eam.plsql.'||g_pkg_name
                          ||'.validate_rebuild';
l_log                     boolean := false;

BEGIN
  SAVEPOINT VALIDATE_REBUILD;
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

  l_log := (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
  if (l_log) then -- true only if logging enabled, avoids costly function call
    l_log := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
  end if;
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_module || '('
    || 'p_organization_id='|| p_organization_id || ','
    || 'p_wip_entity_id='|| p_wip_entity_id || ','
    || 'p_rebuild_item_id='|| p_rebuild_item_id || ','
    || 'p_rebuild_item_name='|| p_rebuild_item_name || ','
    || 'p_rebuild_serial_number='|| p_rebuild_serial_number ||','
    || 'p_rebuild_activity_id='|| p_rebuild_activity_id ||','
    || 'p_rebuild_activity_name='|| p_rebuild_activity_name
    || ')');
  end if;


  x_return_status := FND_API.G_RET_STS_ERROR;
  x_msg_count := 0;
  if (p_organization_id is null) then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    return;
  end if;

  --validate rebuild item
  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'Validating Rebuild Item...');
  end if;
  begin
  if (p_rebuild_item_id is not null) then
    select inventory_item_id, serial_number_control_code
    into l_dummy_num, l_serial_control_code
    from mtl_system_items_b msi, mtl_parameters mp
    where msi.inventory_item_id = p_rebuild_item_id
    and msi.organization_id = mp.organization_id
	and mp.maint_organization_id = p_organization_id
    and eam_item_type = 3
    and rownum = 1;
  elsif (p_rebuild_item_name is not null) then
    select inventory_item_id, serial_number_control_code
    into p_rebuild_item_id, l_serial_control_code
    from mtl_system_items_b_kfv msi, mtl_parameters mp
    where msi.concatenated_segments = p_rebuild_item_name
    and msi.organization_id = mp.organization_id
	and mp.maint_organization_id = p_organization_id
    and eam_item_type = 3
    and rownum = 1;
  else
    fnd_message.set_name('EAM', 'EAM_REBUILD_ITEM_EXCEPTION');
    fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
    return;  --no use in continuing further with validations
  end if;
  exception
  when no_data_found then
    fnd_message.set_name('EAM', 'EAM_INVALID_REBUILD_ITEM');
    fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
	  return;
  end;

  if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Finished Validating Rebuild Item Id ' || p_rebuild_item_id);
  end if;

  --validate rebuild serial
  if ((l_serial_control_code> 1) and p_rebuild_serial_number is not null) then
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Now Validating Rebuild Serial...' || p_rebuild_item_id);
    end if;
    if ((p_wip_entity_id is null) and (p_validate_mode <> VALIDATE_ISSUE)) then
      -- wip entity id is required for checking the hierarchy
      return;
    end if;
    begin
    select serial_number, current_status, gen_object_id, current_organization_id
      into l_dummy_char, l_current_status, l_object_id, l_cur_organization_id
      from mtl_serial_numbers msn, mtl_parameters mp
      where inventory_item_id = p_rebuild_item_id
      and current_organization_id = mp.organization_id
	  and mp.maint_organization_id = p_organization_id
      and serial_number = p_rebuild_serial_number;
    --current_status: 1= predefined, 3= in stores, 4=out of stores, 5=in transit
    if (l_current_status <> 1) then
      if ((l_current_status <> 3) and (l_current_status <> 4))then
        raise no_data_found; --current statuses outside of 1,3,4 not allowed
      end if;
      if ((l_current_status = 4) and (p_validate_mode = VALIDATE_ISSUE))then
        raise no_data_found; --current status 4 is not ok for issue transaction
      end if;
      --current status 3 is ok for all transactions as per Suresh
      --now rebuild has to be immediate child of parent work order's object
      --only if transaction is not issue.
      if (p_validate_mode <> VALIDATE_ISSUE) then


        select msn.gen_object_id into l_parent_object_id
        from wip_discrete_jobs wdj, mtl_serial_numbers msn, csi_item_instances cii
        where wdj.wip_entity_id = p_wip_entity_id
		and wdj.maintenance_object_id = cii.instance_id
		and wdj.maintenance_object_type = 3
		and cii.serial_number = msn.serial_number
		and cii.inventory_item_id = msn.inventory_item_id
		and cii.last_vld_organization_id = msn.current_organization_id;

        select object_id into l_dummy_num
        from mtl_object_genealogy
        where object_id = l_object_id
        and parent_object_id = l_parent_object_id
	and start_date_active <= sysdate
	and (end_date_active is null or end_date_active >= sysdate);
      end if;
    end if;
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Finished Validating Rebuild Serial');
    end if;
  exception
  when no_data_found then
    if (p_validate_mode = VALIDATE_ISSUE) then
      fnd_message.set_name('EAM', 'EAM_INVALID_RBLD_SERIAL_ISSUE');
    elsif (p_validate_mode = VALIDATE_REMOVE) then
      fnd_message.set_name('EAM', 'EAM_INVALID_RBLD_SERIAL_REMOVE');
    else
      fnd_message.set_name('EAM', 'EAM_INVALID_RBLD_SERIAL');
    end if;
    fnd_message.set_token('SERIAL', p_rebuild_serial_number);
    fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
	  return;
  end;
  end if;


  --validate rebuild activity
  if ((p_rebuild_activity_id is not null) or
  (p_rebuild_activity_name is not null)) then
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Now Validating Rebuild Activity...');
    end if;
    -- serial mandatory if specifying activity for serialized rebuild
    if ((p_rebuild_serial_number is null) and (l_serial_control_code > 1)) then
      fnd_message.set_name('EAM', 'EAM_NO_SERIAL_FOR_ACTIVITY');
      fnd_msg_pub.add;
  	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  	  return;
  	end if;

  	begin
    if (p_rebuild_activity_id is not null) then
      select inventory_item_id into l_dummy_num
      from mtl_system_items_b_kfv
      where inventory_item_id = p_rebuild_activity_id
      and organization_id = p_organization_id
      and eam_item_type = 2;
    elsif (p_rebuild_activity_name is not null) then
      select inventory_item_id into p_rebuild_activity_id
      from mtl_system_items_b_kfv
      where concatenated_segments = p_rebuild_activity_name
      and organization_id = p_organization_id
      and eam_item_type = 2;
      if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
        'Rebuild Activity Id is ' || p_rebuild_activity_id);
      end if;
    if (l_serial_control_code > 1) then

      select meaa.activity_association_id into l_dummy_num
        from mtl_eam_asset_activities meaa,  eam_org_maint_defaults eomd, csi_item_instances cii
        where ( meaa.end_date_active is null or meaa.end_date_active > sysdate)
        and (meaa.start_date_active is null or meaa.start_date_active < sysdate)
        and meaa.asset_activity_id = p_rebuild_activity_id
        and nvl(meaa.tmpl_flag, 'N') = 'N'
        and eomd.organization_id = p_organization_id
		and eomd.object_type = 60
		and eomd.object_id = meaa.activity_association_id
        and cii.inventory_item_id = p_rebuild_item_id
        and cii.serial_number = p_rebuild_serial_number
		and meaa.maintenance_object_type = 3
		and meaa.maintenance_object_id = cii.instance_id;
      else
        select meaa.activity_association_id into l_dummy_num
        from mtl_eam_asset_activities meaa, eam_org_maint_defaults eomd
        where ( meaa.end_date_active is null or meaa.end_date_active > sysdate)
        and (meaa.start_date_active is null or meaa.start_date_active < sysdate)
        and meaa.asset_activity_id = p_rebuild_activity_id
        and meaa.maintenance_object_type = 2
		and  meaa.maintenance_object_id = p_rebuild_item_id
        and eomd.organization_id = p_organization_id
		and eomd.object_type = 40
		and eomd.object_id = meaa.activity_association_id;
      end if;
    end if;
    if (l_log and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
      'Finished Validating Rebuild Activity');
    end if;
    exception
    when no_data_found then
      fnd_message.set_name('EAM', 'EAM_INVALID_ACTIVITY');
      fnd_msg_pub.add;
  	  FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  	  return;
    end;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
	FND_MSG_PUB.Count_And_Get('T', x_msg_count, x_msg_data);
  if (l_log and (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, 'End of ' || l_module);
  end if;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    ROLLBACK to VALIDATE_REBUILD;
END  validate_rebuild;

END  EAM_REBUILDS_PVT;

/
