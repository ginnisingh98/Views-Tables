--------------------------------------------------------
--  DDL for Package Body WSM_RESERVATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_RESERVATIONS_GRP" as
/* $Header: WSMGRSVB.pls 120.2 2005/09/27 10:38:16 mprathap noship $ */

/* Package name  */
g_pkg_name 	       VARCHAR2(20) := 'WSM_RESERVATIONS_GRP';

/*logging variables*/

g_log_level_unexpected 	NUMBER := FND_LOG.LEVEL_UNEXPECTED ;
g_log_level_error       number := FND_LOG.LEVEL_ERROR      ;
g_log_level_exception   number := FND_LOG.LEVEL_EXCEPTION  ;
g_log_level_event       number := FND_LOG.LEVEL_EVENT      ;
g_log_level_procedure   number := FND_LOG.LEVEL_PROCEDURE  ;
g_log_level_statement   number := FND_LOG.LEVEL_STATEMENT  ;

g_msg_lvl_unexp_error 	NUMBER := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR    ;
g_msg_lvl_error 	NUMBER := FND_MSG_PUB.G_MSG_LVL_ERROR          ;
g_msg_lvl_success 	NUMBER := FND_MSG_PUB.G_MSG_LVL_SUCCESS        ;
g_msg_lvl_debug_high 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH     ;
g_msg_lvl_debug_medium 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM   ;
g_msg_lvl_debug_low 	NUMBER := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW      ;

g_ret_success	    varchar2(1)    := FND_API.G_RET_STS_SUCCESS;
g_ret_error	    varchar2(1)    := FND_API.G_RET_STS_ERROR;
g_ret_unexpected    varchar2(1)    := FND_API.G_RET_STS_UNEXP_ERROR;

PROCEDURE get_available_supply_demand (
		x_return_status            	OUT    	NOCOPY VARCHAR2                  ,
		x_msg_count                	OUT    	NOCOPY NUMBER                    ,
		x_msg_data                 	OUT    	NOCOPY VARCHAR2                  ,
		x_available_quantity		OUT     NOCOPY NUMBER                    ,
		x_source_uom_code		OUT	NOCOPY VARCHAR2			 ,
		x_source_primary_uom_code	OUT	NOCOPY VARCHAR2 		 ,
		p_organization_id		IN 	NUMBER default null              ,
		p_item_id			IN 	NUMBER default null              ,
		p_revision			IN 	VARCHAR2 default null            ,
		p_lot_number			IN	VARCHAR2 default null            ,
		p_subinventory_code		IN	VARCHAR2 default null            ,
		p_locator_id			IN 	NUMBER default null              ,
		p_supply_demand_code		IN	NUMBER                           ,
		p_supply_demand_type_id		IN	NUMBER                           ,
		p_supply_demand_header_id	IN	NUMBER                           ,
		p_supply_demand_line_id		IN	NUMBER                           ,
		p_supply_demand_line_detail	IN	NUMBER               		 ,
		p_lpn_id			IN	NUMBER                 		 ,
		p_project_id			IN	NUMBER default null              ,
		p_task_id			IN	NUMBER default null              ,
		p_api_version_number     	IN     	NUMBER default 1.0               ,
		p_init_msg_lst             	IN      VARCHAR2 DEFAULT fnd_api.g_false
		)

IS
     /* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name	      VARCHAR2(30) := 'get_available_supply_demand';

     /* Module name for logging */
     l_module    VARCHAR2(100) := 'wsm.plsql.WSM_RESERVATIONS_GRP.get_available_supply_demand';

     /* local variable for debug purpose */
     l_stmt_num 	NUMBER := 0;
     l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
     l_log_level	number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
     l_item_id wip_discrete_jobs.primary_item_id%TYPE; --bug 4633035

BEGIN

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 l_stmt_num := 10;
	 /* Initialize   message list if p_init_msg_list is set to TRUE. */
	 IF FND_API.to_Boolean( p_init_msg_lst ) THEN
		FND_MSG_PUB.initialize;
		/* Message list enabled....-- EVENT */
        	--logging
	end if;

	l_stmt_num := 20;
	/* Check for the API compatibilty */
	IF NOT FND_API.Compatible_API_Call( l_api_version,
    					p_api_version_number,
					g_pkg_name,
					l_api_name
					)
	THEN
	  --logging here...
	  /* Incompatible versions...*/
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_stmt_num := 30;
	 SELECT WDJ.NET_QUANTITY,WDJ.PRIMARY_ITEM_ID
	 INTO x_available_quantity,l_item_id
	 FROM WIP_DISCRETE_JOBS WDJ
	 WHERE WDJ.WIP_ENTITY_ID = p_supply_demand_header_id;

	l_stmt_num := 40;
	 select primary_uom_code
	 into x_source_primary_uom_code
	 from mtl_system_items
	 where inventory_item_id=l_item_id --p_item_id
	 and organization_id=p_organization_id;

	 x_source_uom_code := x_source_primary_uom_code;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	when no_data_found then
		x_return_status := fnd_api.g_ret_sts_error;
		x_msg_data := 'No job with the given wip_entity_id found';
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := G_RET_ERROR ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := G_RET_UNEXPECTED ;
		x_msg_data := SUBSTR('WSM_RESERVATIONS_GRP.validate_supply_demand: Unexpected error: '||SQLERRM, 1, 500);

 	WHEN OTHERS THEN
		/* handle it... */
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_msg_data := SUBSTR('WSM_RESERVATIONS_GRP.get_available_supply_demand: Unexpexted error: '||SQLERRM, 1, 500);

END;

PROCEDURE validate_supply_demand (
		x_return_status            	OUT    	NOCOPY VARCHAR2
		, x_msg_count                	OUT    	NOCOPY NUMBER
		, x_msg_data                 	OUT    	NOCOPY VARCHAR2
		, x_valid_status		OUT     NOCOPY VARCHAR2
		, p_organization_id		IN	NUMBER
		, p_item_id			IN	NUMBER
		, p_supply_demand_code		IN	NUMBER
		, p_supply_demand_type_id	IN	NUMBER
		, p_supply_demand_header_id	IN	NUMBER
		, p_supply_demand_line_id	IN	NUMBER
		, p_supply_demand_line_detail	IN	NUMBER
		, p_demand_ship_date		IN	DATE
		, p_expected_receipt_date	IN	DATE
		, p_api_version_number     	IN     	NUMBER default 1.0
		, p_init_msg_lst             	IN      VARCHAR2 DEFAULT fnd_api.g_false
		)
IS

l_scheduled_completion_date DATE;
l_net_qty NUMBER;
l_status_type NUMBER;

/* API version stored locally */
     l_api_version    NUMBER := 1.0;
     l_api_name	      VARCHAR2(30) := 'validate_supply_demand';

     /* Module name for logging */
     l_module    VARCHAR2(100) := 'wsm.plsql.WSM_RESERVATIONS_GRP.validate_supply_demand';

     /* local variable for debug purpose */
     l_stmt_num 	NUMBER := 0;
     l_msg_tokens       WSM_Log_PVT.token_rec_tbl;
     l_log_level	number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

BEGIN

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 l_stmt_num := 10;
	 /* Initialize   message list if p_init_msg_list is set to TRUE. */
	 IF FND_API.to_Boolean( p_init_msg_lst ) THEN
		FND_MSG_PUB.initialize;
		/* Message list enabled....-- EVENT */
        	--logging
	end if;

	l_stmt_num := 20;
	/* Check for the API compatibilty */
	IF NOT FND_API.Compatible_API_Call( l_api_version,
    					p_api_version_number,
					g_pkg_name,
					l_api_name
					)
	THEN
	  --logging here...
	  /* Incompatible versions...*/
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_stmt_num := 30;
	 	select
		wdj.scheduled_completion_date,
		wdj.net_quantity,
		wdj.status_type
		into
		l_scheduled_completion_date,
		l_net_qty,
		l_status_type
		from wip_entities we,
		wip_discrete_jobs wdj
		where wdj.wip_entity_id = p_supply_demand_header_id
		and we.wip_entity_id = wdj.wip_entity_id
		and wdj.job_type in (1,3)
		and we.entity_type = 5;

		If l_status_type not in (1,3,6) then
			x_valid_status := 'N';
			--Return error; job not in released/unreleased/on-hold status
			/*event log*/
			IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then
			 	l_msg_tokens.delete;
				WSM_log_PVT.logMessage(p_module_name	    => l_module			,
						       p_msg_name  	    => 'WSM_INVALID_JOB',
						       p_msg_appl_name	    => 'WSM'			,
						       p_msg_tokens	    => l_msg_tokens		,
						       p_stmt_num	    => l_stmt_num		,
						       p_fnd_msg_level      => G_MSG_LVL_ERROR    	,
						       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
						       p_run_log_level      => l_log_level
						      );
			 END IF;
		elsif p_demand_ship_date < l_scheduled_completion_date then
			x_valid_status := 'N';
			--Return error; the qty wont be available before the need-by date
			IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then
			 	l_msg_tokens.delete;
				WSM_log_PVT.logMessage(p_module_name	    => l_module			,
						       p_msg_name  	    => 'WSM_COMPL_LATE',
						       p_msg_appl_name	    => 'WSM'			,
						       p_msg_tokens	    => l_msg_tokens		,
						       p_stmt_num	    => l_stmt_num		,
						       p_fnd_msg_level      => G_MSG_LVL_ERROR    	,
						       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
						       p_run_log_level      => l_log_level
						      );
			 END IF;
		elsif l_net_qty <= 0 then
			x_valid_status := 'N';
			--Return error; the qty available is less than zero.
			IF g_log_level_event >= l_log_level OR FND_MSG_PUB.check_msg_level(G_MSG_LVL_SUCCESS) then
			 	l_msg_tokens.delete;
				WSM_log_PVT.logMessage(p_module_name	    => l_module			,
						       p_msg_name  	    => 'WSM_NET_QTY_ZERO',
						       p_msg_appl_name	    => 'WSM'			,
						       p_msg_tokens	    => l_msg_tokens		,
						       p_stmt_num	    => l_stmt_num		,
						       p_fnd_msg_level      => G_MSG_LVL_ERROR    	,
						       p_fnd_log_level      => G_LOG_LEVEL_ERROR        ,
						       p_run_log_level      => l_log_level
						      );
			 END IF;
		end if;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_return_status := G_RET_ERROR;

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := G_RET_ERROR ;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := G_RET_UNEXPECTED ;
		x_msg_data := SUBSTR('WSM_RESERVATIONS_GRP.validate_supply_demand: Unexpected error: '||SQLERRM, 1, 500);
	WHEN OTHERS THEN
		/* handle it... */
		x_return_status := G_RET_UNEXPECTED ;
		x_msg_data := SUBSTR('WSM_RESERVATIONS_GRP.validate_supply_demand: Unexpected error: '||SQLERRM, 1, 500);
END;

end WSM_RESERVATIONS_GRP;

/
