--------------------------------------------------------
--  DDL for Package Body EAM_WOREP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WOREP_PUB" AS
/* $Header: EAMPWORB.pls 120.4.12010000.6 2010/06/17 09:58:52 somitra ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPWORB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WOREP_PUB
--
--  NOTES
--
--  HISTORY
--
--  20-MARCH-2006    Smriti Sharma     Initial Creation
***************************************************************************/
G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_WOREP_PUB';
PROCEDURE Work_Order_CP
        ( errbuf                        OUT NOCOPY VARCHAR2
        , retcode                       OUT NOCOPY VARCHAR2
	, p_work_order_from             IN  VARCHAR2
        , p_work_order_to               IN  VARCHAR2
	, p_scheduled_start_date_from   IN  VARCHAR2
        , p_scheduled_start_date_to     IN  VARCHAR2
	, p_asset_area_from             IN  VARCHAR2
	, p_asset_area_to               IN  VARCHAR2
        , p_asset_number                IN  VARCHAR2
	, p_status_type                 IN  NUMBER
        , p_assigned_department         IN  NUMBER
       	, p_organization_id             IN  NUMBER
        , p_operation                   IN  NUMBER
        , p_resource                    IN  NUMBER
        , p_material                    IN  NUMBER
        , p_direct_item                 IN  NUMBER
    	, p_work_request                IN  NUMBER
        , p_meter                       IN  NUMBER
        , p_quality_plan                IN  NUMBER
	, p_mandatory                   IN  NUMBER
	, p_attachment                  IN  NUMBER
	, p_asset_bom                   IN  NUMBER
	, p_permit                      IN  NUMBER --added bug 9812863
        )
IS
        TYPE WipIdCurType IS REF CURSOR;

        get_wip_entity_id_csr   WipIdCurType;
        --TYPE wip_entity_id_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        --wip_entity_id_tbl        wip_entity_id_type;
          wip_entity_id_tbl        system.eam_wipid_tab_type;

       l_api_version          CONSTANT NUMBER:=1;
       l_shortage_exists       VARCHAR2(1);
       l_return_status         VARCHAR2(1);
       l_msg_count             NUMBER;
       l_msg_data              VARCHAR2(2000);
       l_sql_stmt              VARCHAR2(2000);
       l_where_clause          VARCHAR2(2000):=null;
       l_where_clause1          VARCHAR2(2000):=null;
       l_rows                  NUMBER := 5000;
	   l_quality_plan          NUMBER :=0;
	   l_short_attachment      NUMBER :=0;
	   l_long_attachment       NUMBER :=0;
	   l_file_attachment       NUMBER :=0;
	   l_operation             NUMBER;
	   l_material              NUMBER;
	   l_resource              NUMBER;
	   l_direct_item           NUMBER;
	   l_work_request          NUMBER;
	   l_meter                 NUMBER;
	   l_asset_bom             NUMBER;
     l_safety_permit           NUMBER ; -- for  safety permit
	   l_xmldoc                CLOB:=null ;
	   l_length                NUMBER ;
	   l_encoding              VARCHAR2(2000);
	   l_offset		   NUMBER;
	   l_char		   VARCHAR2(2);
BEGIN

        l_sql_stmt := ' SELECT wdj.wip_entity_id
                        FROM wip_discrete_jobs wdj, eam_work_order_details ewod, csi_item_instances cii,wip_entities we,eam_org_maint_defaults eomd,
			mtl_eam_locations mel
                        WHERE wdj.wip_entity_id = ewod.wip_entity_id
                        AND decode(wdj.maintenance_object_type,3, wdj.maintenance_object_id,NULL) = cii.instance_id(+)
                        AND wdj.wip_entity_id = we.wip_entity_id
			AND wdj.organization_id=we.organization_id
			AND wdj.organization_id = :p_org_id
		        AND eomd.object_id(+) = cii.instance_id
			AND eomd.object_type(+)=50
			AND eomd.organization_id(+)=:p_org_id
			AND mel.location_id(+)=eomd.area_id';

        IF p_work_order_from IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND we.wip_entity_name >= '''|| p_work_order_from || '''';
                IF p_work_order_to IS NOT NULL THEN
                        l_where_clause := l_where_clause || ' AND we.wip_entity_name <= '''|| p_work_order_to|| '''';
                ELSE
                        l_where_clause :=  ' AND we.wip_entity_name = '''|| p_work_order_from || '''';
                END IF;
        END IF;


        IF p_asset_number IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND cii.instance_number = '|| '''' ||p_asset_number ||'''';
        END IF;

        IF p_scheduled_start_date_from IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  >= fnd_date.canonical_to_date( '||' '' '||p_scheduled_start_date_from||' '' ) ';
        END IF;

        IF p_scheduled_start_date_to IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND wdj.scheduled_start_date  <= fnd_date.canonical_to_date('||' '' '||p_scheduled_start_date_to||' '' ) ';
        END IF;



        IF p_status_type IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND ewod.user_defined_status_id = ' || p_status_type ;
        END IF;


        IF p_assigned_department IS NOT NULL THEN
                l_where_clause := l_where_clause || ' AND EXISTS (SELECT 1
                                                                    FROM wip_operations wo
                                                                   WHERE wo.wip_entity_id = wdj.wip_entity_id
								     AND wo.organization_id=wdj.organization_id
                                                                     AND wo.department_id = ' || p_assigned_department || ' ) ';
        END IF;

	if p_asset_area_from is not null then
	        l_where_clause1 :=  ' AND mel.location_id >= '|| p_asset_area_from ;
                IF p_asset_area_to IS NOT NULL THEN
                        l_where_clause1 := l_where_clause1 || ' AND mel.location_id <='|| p_asset_area_to;
                ELSE
                        l_where_clause1 :=  ' AND mel.location_id = '|| p_asset_area_from;
                END IF;

	end if;


	if p_quality_plan =1 then
	  if p_mandatory=1 then
	    l_quality_plan:=1;
          else
	    l_quality_plan:=2;
          end if;
	end if;

	if p_attachment=1 then
	l_short_attachment :=1;
	l_long_attachment :=1;
        l_file_attachment :=1;
	end if;

	 if p_operation=1 then
	  l_operation:=1;
	 else
	  l_operation:=0;
	 end if;

	 if p_material=1 then
	  l_material:=1;
	 else
	  l_material:=0;
	 end if;

	 if p_resource=1 then
	  l_resource:=1;
	 else
	  l_resource:=0;
	 end if;

	 if p_direct_item=1 then
	  l_direct_item:=1;
	 else
	  l_direct_item:=0;
	 end if;

	 if p_work_request=1 then
	  l_work_request:=1;
	 else
	  l_work_request:=0;
	 end if;

	 if p_meter=1 then
	  l_meter:=1;
	 else
	  l_meter:=0;
	 end if;

	 if p_asset_bom=1 then
	  l_asset_bom := 1;
	 else
	  l_asset_bom :=0;
	 end if;

	 --added bug 9812863
	 if p_permit =1 then
	    l_safety_permit:=1;
          else
	    l_safety_permit:=0;
     end if;


	l_sql_stmt := l_sql_stmt || l_where_clause || l_where_clause1;

        OPEN get_wip_entity_id_csr FOR l_sql_stmt USING p_organization_id,p_organization_id;
        FETCH get_wip_entity_id_csr BULK COLLECT INTO wip_entity_id_tbl LIMIT l_rows;
	CLOSE get_wip_entity_id_csr;
        if wip_entity_id_tbl.count <> 0 then
    	  l_xmldoc := EAM_WorkOrderRep_PVT.getWoReportXML(wip_entity_id_tbl,l_operation,l_material,l_resource,l_direct_item,l_short_attachment,l_long_attachment ,
          l_file_attachment,l_work_request ,l_meter ,l_quality_plan,l_asset_bom,l_safety_permit);
	end if;
        l_encoding  := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<?xml version="1.0" encoding="'||l_encoding ||'"?>' );
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ROWSET>');
        l_length := nvl(DBMS_LOB.getlength(l_xmldoc), 0);
	l_offset := 1;

	WHILE (l_offset <= l_length)
	LOOP
	l_char := dbms_lob.substr(l_xmldoc,1,l_offset);

	IF (l_char = to_char(10))
	THEN
        fnd_file.new_line(fnd_file.output, 1);
	ELSE
        fnd_file.put(fnd_file.output, l_char);
	END IF;

	l_offset := l_offset + 1;
        END LOOP;

        fnd_file.new_line(fnd_file.output, 1);

    	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</ROWSET>');

        retcode := 0;
EXCEPTION

        WHEN OTHERS THEN
                errbuf := SQLERRM;
                retcode := 2;
END Work_Order_CP;

END EAM_WOREP_PUB;


/
