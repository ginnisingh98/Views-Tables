--------------------------------------------------------
--  DDL for Package Body EAM_MATERIAL_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIAL_REQUEST_PVT" AS
  /* $Header: EAMWEMRB.pls 120.2 2007/12/12 02:28:02 mashah ship $*/
  g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_material_request_pvt';

--author: dgupta
--This procedure allocates material by calling WIP
PROCEDURE allocate(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_validation_level      IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_request_number        OUT NOCOPY    VARCHAR2,
  p_wip_entity_type       IN            NUMBER,
  p_organization_id       IN            NUMBER,
  p_wip_entity_id         IN            NUMBER,
  p_operation_seq_num     IN            NUMBER,
  p_inventory_item_id     IN            NUMBER,
  p_project_id            IN            NUMBER,
  p_task_id               IN            NUMBER,
  p_requested_quantity    IN            NUMBER,
  p_source_subinventory   IN            VARCHAR2,
  p_source_locator        IN            NUMBER,
  p_lot_number            IN            VARCHAR2,
  p_fm_serial             IN            VARCHAR2,
  p_to_serial             IN            VARCHAR2
)  IS

  l_api_name                CONSTANT VARCHAR2(30) := 'allocate';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_full_name               CONSTANT VARCHAR2(100) := g_pkg_name || '.' || l_api_name;
  l_module                  CONSTANT VARCHAR2(60) := 'eam.plsql.'||l_full_name;
  l_msg_data VARCHAR2(2000);
  l_msg VARCHAR2(2000);
  l_return_status VARCHAR2(2000);
  allocate_table  wip_picking_pub.allocate_comp_tbl_t;
  l_pickslip_conc_req_id NUMBER := 0;
  l_current_log_level constant number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
  l_uLog constant BOOLEAN := FND_LOG.LEVEL_UNEXPECTED >= l_current_log_level;
  l_pLog constant BOOLEAN := l_uLog AND FND_LOG.LEVEL_PROCEDURE >= l_current_log_level;
  l_sLog constant BOOLEAN := l_pLog AND FND_LOG.LEVEL_STATEMENT >= l_current_log_level;
  l_partial_qty NUMBER := 0;
  l_project_id number := p_project_id;
  l_task_id number := p_task_id;

BEGIN
	-- Standard Start of API savepoint
  SAVEPOINT	ALLOCATE_EAM;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
    l_api_name,	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
  l_msg_data  := NULL;
  l_return_status := NULL;
  x_msg_data := null;
  x_msg_count := 0;

  --check for invalid parameters
  if (p_requested_quantity = 0) then
    return;
  end if;
  if (p_requested_quantity < 0) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('EAM','EAM_MR_NEGATIVE_REQ_QTY');
    fnd_message.set_token('REQUESTED', to_char(p_requested_quantity) );
    fnd_msg_pub.add;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    return;
  end if;

  if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'Start of ' || l_full_name || '('
    || 'p_commit='|| p_commit ||','
    || 'p_wip_entity_type='|| p_wip_entity_type || ','
    || 'p_organization_id='|| p_organization_id || ','
    || 'p_wip_entity_id='|| p_wip_entity_id || ','
    || 'p_operation_seq_num='|| p_operation_seq_num || ','
    || 'p_inventory_item_id='|| p_inventory_item_id || ','
    || 'p_project_id='|| p_project_id || ','
    || 'p_task_id='|| p_task_id || ','
    || 'p_requested_quantity='|| p_requested_quantity || ','
    || 'p_source_subinventory='|| p_source_subinventory ||','
    || 'p_source_locator='|| p_source_locator ||','
    || 'p_lot_number='|| p_lot_number ||','
    || 'p_fm_serial='|| p_fm_serial ||','
    || 'p_to_serial='|| p_to_serial ||','
    || ')');
  end if;
  -- if project or task info is missing, retrieve it, else carry on
  if ((p_project_id is null) or (p_task_id is null)) then
    select project_id, task_id into l_project_id, l_task_id
    from wip_discrete_jobs
    where wip_entity_id = p_wip_entity_id;
  else
  if (p_project_id = FND_API.G_MISS_NUM) then
    l_project_id := null;
  end if;
  if (p_task_id = FND_API.G_MISS_NUM) then
    l_task_id := null;
  end if;
  end if;
  allocate_table(1).wip_entity_id := p_wip_entity_id;
  allocate_table(1).use_pickset_flag := 'N'; --this flag only used by flow
  allocate_table(1).project_id := l_project_id;
  allocate_table(1).task_id := l_task_id;
  allocate_table(1).operation_seq_num := p_operation_seq_num;
  allocate_table(1).inventory_item_id := p_inventory_item_id;
  allocate_table(1).requested_quantity := p_requested_quantity;
  allocate_table(1).source_subinventory_code := p_source_subinventory;
  allocate_table(1).source_locator_id := p_source_locator;
  allocate_table(1).lot_number := p_lot_number;
  allocate_table(1).start_serial := p_fm_serial;
  allocate_table(1).end_serial := p_to_serial;

  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'Calling wip_picking_pub.allocate_comp');
  end if;
  wip_picking_pub.allocate_comp(p_alloc_comp_tbl => allocate_table,
                     p_cutoff_date => null,
                     p_wip_entity_type => wip_constants.eam,
                     p_organization_id => p_organization_id,
                     x_return_status => l_return_status,
                     x_msg_data => l_msg_data,
                     x_mo_req_number => x_request_number,
                     x_conc_req_id => l_pickslip_conc_req_id);
  if (l_sLog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
    'After Calling wip_picking_pub.allocate_comp');
  end if;
  if (l_sLog) then
    l_msg := 'WIP returned: Request Number:' || x_request_number || ', x_return_status:'
    || l_return_status|| ', x_msg_data:' || l_msg_data ||
    ', x_conc_req_id:' || l_pickslip_conc_req_id;
    l_msg := REPLACE(l_msg, CHR(0), ' ');
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, l_msg);
  end if;
  x_return_status := l_return_status;
  if (l_msg_data is not null) then
    --needed since WIP does not put messages on stack while INV does.
  	FND_MSG_PUB.Count_And_Get(
  	  p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
    if (x_msg_count = 0 ) then --means not on stack, add it.
      fnd_message.set_name('EAM','EAM_GENERIC_ERROR');
      fnd_message.set_token('EAM_ERROR', l_msg_data );
      fnd_msg_pub.add;
    end if;
  end if;

  if (l_return_status = 'P') then
    select sum(quantity_detailed) into l_partial_qty
    from mtl_txn_request_lines
    where header_id = (select header_id from mtl_txn_request_headers
      where request_number = x_request_number
      and organization_id = p_organization_id);
    if (l_partial_qty = 0) then
      fnd_message.set_name('EAM','EAM_MR_NO_MATERIAL_AVAILABLE');
      fnd_msg_pub.add;
    else
      fnd_message.set_name('EAM','EAM_MR_PARTIAL_ALLOCATION');
      fnd_message.set_token('PARTIAL', to_char(l_partial_qty) );
      fnd_message.set_token('REQUESTED', to_char(p_requested_quantity));
      fnd_msg_pub.add;
    end if;
  end if;

  if (x_return_status = FND_API.G_RET_STS_ERROR) then
    if l_msg_data is null then --should not happen, just a safeguard
      fnd_message.set_name('EAM','EAM_MR_ALLOCATION_FAILED');
      fnd_msg_pub.add;
    end if;
    RAISE FND_API.G_EXC_ERROR;
  end if;
	-- End of API body.

	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get(
	  p_count         	=>      x_msg_count,
    p_data          	=>      x_msg_data);
  if (l_pLog) then FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
    'End of ' || l_full_name );
  end if;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO ALLOCATE_EAM;
    IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
	      'Exception Block 1 - Expected Error' );
    END IF;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ALLOCATE_EAM;
	IF ( l_uLog ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module,
	      'Exception Block 2 - Unexpected error' );
	END IF ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
	WHEN OTHERS THEN
		ROLLBACK TO ALLOCATE_EAM;
	IF ( l_uLog ) THEN
	    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module,
	      'Exception Block 3 - Others' );
	END IF ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF 	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(
	    p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
END allocate;

END  EAM_MATERIAL_REQUEST_PVT;

/
