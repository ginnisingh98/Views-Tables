--------------------------------------------------------
--  DDL for Package Body EAM_MATERIAL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MATERIAL_VALIDATE_PVT" AS
/* $Header: EAMVMSCB.pls 120.8.12010000.2 2008/10/06 09:33:18 smrsharm ship $ */


/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVMSCB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_MATERIAL_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  02-FEB-2005    Girish Rajan     Initial Creation
***************************************************************************/

/*******************************************************************
    * Procedure : get_wip_entity_name
    * Returns   : wip_entity_name
    * Parameters IN : Wip Entity Id
    * Purpose   : Local function to get the wip_entity_name corresponding to
    *             the wip_entity_id
    *********************************************************************/

FUNCTION get_wip_entity_name(p_wip_entity_id NUMBER)
RETURN VARCHAR2
IS
	CURSOR wip_entity_name_csr(p_wip_entity_id NUMBER) IS
	SELECT wip_entity_name
	  FROM wip_entities
	 WHERE wip_entity_id = p_wip_entity_id;

	l_wip_entity_name wip_entities.wip_entity_name%TYPE;
BEGIN
	OPEN wip_entity_name_csr(p_wip_entity_id);
	FETCH wip_entity_name_csr INTO l_wip_entity_name;
	CLOSE wip_entity_name_csr;

	RETURN l_wip_entity_name;
END get_wip_entity_name;


/*******************************************************************
    * Procedure : Material_Shortage_CP
    * Returns   : None
    * Parameters IN : Owning Department, Assigned Department, Asset_number,
    *		    : Scheduled Start Date_from, Scheduled Start Date To,
    *		    : Work Order From, Work Order To, Status Type, Horizon, Backlog Horizon,
    *		    : Organization Id, Project, Task
    * Parameters OUT NOCOPY: errbuf to show the erro fired by concurremt program
    *                        retcode = 2 if error
    * Purpose   : For any given work order, this wrapper API will
    *             determine whether there is material shortage
    *             or not and then update that field at the work order
    *             level. API will return whether shortage
    *             exists in p_shortage_exists parameter.
    *********************************************************************/

PROCEDURE Material_Shortage_CP
	( errbuf			OUT NOCOPY VARCHAR2
        , retcode		        OUT NOCOPY VARCHAR2
        , p_owning_department		IN  VARCHAR2
	, p_assigned_department         IN  NUMBER
	, p_asset_number	        IN  VARCHAR2
	, p_scheduled_start_date_from	IN  VARCHAR2
	, p_scheduled_start_date_to	IN  VARCHAR2
	, p_work_order_from		IN  VARCHAR2
	, p_work_order_to		IN  VARCHAR2
	, p_status_type			IN  NUMBER
	, p_horizon			IN  NUMBER
	, p_backlog_horizon		IN  NUMBER
	, p_organization_id		IN  NUMBER
	, p_project			IN  VARCHAR2
	, p_task			IN  VARCHAR2
        )
IS
	TYPE WipIdCurType IS REF CURSOR;

	get_wip_entity_id_csr   WipIdCurType;
	TYPE wip_entity_id_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	wip_entity_id_tbl	wip_entity_id_type;


	   l_api_version	  CONSTANT NUMBER:=1;
	   l_shortage_exists	  VARCHAR2(1);
	   l_return_status	  VARCHAR2(1);
	   l_msg_count		  NUMBER;
	   l_msg_data		  VARCHAR2(2000);
	   l_check_shortage_excep EXCEPTION;
	   l_sql_stmt		  VARCHAR2(2000);
	   l_where_clause	  VARCHAR2(2000);
	   l_rows		  NUMBER := 5000;
	   l_encoding              VARCHAR2(2000);
BEGIN
	l_encoding  := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="'||l_encoding ||'"?>' );
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ROWSET>');
	l_sql_stmt := ' SELECT wdj.wip_entity_id
		        FROM wip_discrete_jobs wdj, eam_work_order_details ewod, csi_item_instances cii
		       WHERE wdj.wip_entity_id = ewod.wip_entity_id
		         AND wdj.maintenance_object_id = cii.instance_id
		         AND wdj.maintenance_object_type = 3
		         AND wdj.organization_id = :p_org_id ';

	IF p_work_order_from IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.wip_entity_id >= '|| p_work_order_from ;
		IF p_work_order_to IS NOT NULL THEN
			l_where_clause := l_where_clause || ' AND wdj.wip_entity_id <= '|| p_work_order_to ;
		ELSE
			l_where_clause :=  ' AND wdj.wip_entity_id = '|| p_work_order_from ;
		END IF;
	END IF;


	IF p_asset_number IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND cii.instance_number = '|| '''' ||p_asset_number ||'''';
	END IF;

	IF p_owning_department IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.owning_department = '|| p_owning_department ;
	END IF;

	IF p_scheduled_start_date_from IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  >= fnd_date.canonical_to_date( '||' '' '||p_scheduled_start_date_from||' '' ) ';
	END IF;

	IF p_scheduled_start_date_to IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  <= fnd_date.canonical_to_date('||' '' '||p_scheduled_start_date_to||' '' ) ';
	END IF;

	IF p_backlog_horizon IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  >=  (sysdate - '|| p_backlog_horizon || ') '  ;
	END IF;

	IF p_horizon IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  <=  (sysdate + '||p_horizon || ') '  ;
	END IF;

	IF p_status_type IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND ewod.user_defined_status_id = ' || p_status_type ;
	END IF;

	IF p_project IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.project_id = ' || p_project ;
	END IF;

	IF p_task IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND wdj.task_id = ' || p_task ;
	END IF;

	IF p_assigned_department IS NOT NULL THEN
		l_where_clause := l_where_clause || ' AND EXISTS (SELECT 1
								    FROM wip_operations wo
								   WHERE wo.wip_entity_id = wdj.wip_entity_id
								     AND wo.department_id = ' || p_assigned_department || ' ) ';
	END IF;

	l_sql_stmt := l_sql_stmt || l_where_clause;


	OPEN get_wip_entity_id_csr FOR l_sql_stmt USING p_organization_id;
	LOOP
		FETCH get_wip_entity_id_csr BULK COLLECT INTO wip_entity_id_tbl LIMIT l_rows;

		IF wip_entity_id_tbl.count > 0 THEN
			FOR i IN wip_entity_id_tbl.first..wip_entity_id_tbl.last
			LOOP
				IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
					fnd_message.set_name('EAM','EAM_PROCESS_WORK_ORDER');
					fnd_message.set_token('WORK_ORDER',get_wip_entity_name( wip_entity_id_tbl(i)),FALSE);
					fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
				END IF;

				eam_material_validate_pub.Check_Shortage
					 (p_api_version => l_api_version
					, x_return_status => l_return_status
					, x_msg_count =>  l_msg_count
					, x_msg_data => l_msg_data
					, p_commit => FND_API.G_TRUE
					, p_wip_entity_id => wip_entity_id_tbl(i)
					, x_shortage_exists => l_shortage_exists
					, p_source_api => 'Concurrent'
					);
				IF l_return_status='E' THEN
					CLOSE get_wip_entity_id_csr;
					RAISE l_check_shortage_excep;
				END IF;
			END LOOP;
		END IF;
		IF l_return_status='E' THEN
			CLOSE get_wip_entity_id_csr;
			RAISE l_check_shortage_excep;
		END IF;
		EXIT WHEN get_wip_entity_id_csr%NOTFOUND;
	END LOOP;
	CLOSE get_wip_entity_id_csr;

	retcode := 0;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</ROWSET>');

EXCEPTION
	WHEN l_check_shortage_excep THEN
		FOR indexCount IN 1 ..l_msg_count
		LOOP
	       	     errbuf := errbuf || FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
		END LOOP;
		retcode := 2;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</ROWSET>');
	WHEN OTHERS THEN
		errbuf := SQLERRM;
		retcode := 2;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</ROWSET>');
END Material_Shortage_CP;

END eam_material_validate_pvt;

/
