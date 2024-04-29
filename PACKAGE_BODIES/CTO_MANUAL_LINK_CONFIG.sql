--------------------------------------------------------
--  DDL for Package Body CTO_MANUAL_LINK_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_MANUAL_LINK_CONFIG" as
/* $Header: CTOLINKB.pls 120.1.12000000.2 2007/10/10 07:51:40 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOLINKB.pls                                                  |
| DESCRIPTION:                                                                |
|               This file creates a package that contains procedures called   |
                for the Manual Link action from Sales Order Pad.              | |
|                                                                             |
|                                                                             |
| HISTORY     :                                                               |
|               Dec 13, 99  Angela Makalintal   Initial version               |
|               jul 09,2004  Kiran Konada       3755608
|                                               OM api was called with
|                                               'Bom and rtg created' status
|                                               Now calling display_wf_status
|                                               central API to update status
|
=============================================================================*/

/*****************************************************************************
   Function:  link_config
   Parameters:  p_model_line_id   - line id of the top model in
                                    oe_order_lines_all
                p_config_item_id - config id of the selected configuration
                                   item to which the model line will be linked.
                x_error_message   - error message if match function fails
                x_message_name    - name of error message if match
                                    function fails

  Description:  This function is called from the Sales Order Pad to manually
                link a selected configuration item to an ATO model order
                line.

                After linking a configuration item to the model line,
                this link_config function updates the ATO model workflow
                to complete the 'CREATE CONFIG ITEM ELIGIBLE' block
                activity.

                A manual link can only be done if the ATO model order line
                is not linked to a configuration item.
*****************************************************************************/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

TYPE config_bcol_rec IS RECORD
  (
     config_item_id   CTO_MSUTIL_PUB.NUMTAB,
     base_item_id     CTO_MSUTIL_PUB.NUMTAB,
     ship_from_org_id CTO_MSUTIL_PUB.NUMTAB
  );  --Bugfix 6398466

PROCEDURE get_all_configs
    (
         pconfigId IN NUMBER,
         new_config_dtls IN OUT NOCOPY config_bcol_rec,
         pshipOrg IN NUMBER
    );  --Bugfix 6398466

function link_config(
        p_model_line_id         in  number,
        p_config_item_id        in  number,
        x_error_message         out NOCOPY varchar2,
        x_message_name          out NOCOPY varchar2
)
RETURN boolean

IS

	l_stmt_num     		number := 0;
	l_cfm_value    		number;
	l_config_id    		number;
	l_config_line_id 	number;
	l_return_status 	varchar2(1);
	l_x_error_msg_count    	number;
	l_x_error_msg     	varchar2(240);
	l_x_error_msg_name 	varchar2(30);
	l_x_table_name 		varchar2(30);
	l_org_id       		number;
	l_model_id     		number;
	x_message_count		number;
	x_message_data		varchar2(2000);
	l_active_activity 	varchar2(30);
	l_x_bill_seq_id 	number;
	l_status       		integer;
	l_header_id		number;

	PROCESS_ERROR      	exception;

        v_aps_version   number ;

        --New variables introduced as part of Bugfix 6398466
        old_config_dtls config_bcol_rec;
        new_config_dtls config_bcol_rec;

        l_org number;
        l_bom_exists number;
        flag NUMBER := 0;
        bmodel_exists number;

        v_sourcing_rule_exists VARCHAR2(10);
        v_source_type NUMBER;
        v_t_sourcing_info CTO_MSUTIL_PUB.SOURCING_INFO;

        x_exp_error_code NUMBER;
        x_return_status VARCHAR2(30);



BEGIN

        /*---------------------+
         Validate model line.
        +----------------------*/
        l_stmt_num := 100;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_config: ' || 'Inside CTO_MANUAL_LINK_CONFIG.link_config..',2);

		oe_debug_pub.add ('link_config: ' || 'Calling CTO_WORKFLOW.validate_line..',2);
	END IF;

        if (CTO_WORKFLOW.validate_line(p_model_line_id) = FALSE) then

            cto_msg_pub.cto_message('BOM','CTO_LINE_STATUS_NOT_ELIGIBLE');
            x_message_name := 'CTO_LINE_STATUS_NOT_ELIGIBLE';
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('link_config: ' || 'Model Line not valid.',1);
            END IF;
            return FALSE;

        end if;

        l_stmt_num := 105;
        select oel.inventory_item_id, oel.ship_from_org_id
        into   l_model_id, l_org_id
        from   oe_order_lines_all oel
        where  oel.line_id = p_model_line_id;

       /*------------------------------------------+
        Link only if config line does not exist.
        +-----------------------------------------*/
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_config: ' || 'Calling CTO_MATCH_AND_RESERVE.config_line_exists..',2);
	END IF;
        l_stmt_num := 110;
        if (CTO_MATCH_AND_RESERVE.config_line_exists(
				p_model_line_id		=> p_model_line_id,
                                x_config_line_id	=> l_config_line_id,
                                x_config_item_id	=> l_config_id)  = TRUE)
        then

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('link_config: ' || 'Config Line Exists.', 1);
            END IF;
            cto_msg_pub.cto_message('BOM','CTO_CONFIG_ITEM_EXISTS');
            x_message_name := 'CTO_CONFIG_ITEM_EXISTS';
            return FALSE;

        end if;






        v_aps_version := msc_atp_global.get_aps_version  ;

        oe_debug_pub.add('link_config: ' || 'APS version::'|| v_aps_version , 2);






        /*------------------------------------+
        Check Workflow status of model line.
        +-------------------------------------*/
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('link_config: ' || 'Configuration Line does not exist.', 2);
        END IF;
        l_stmt_num := 120;
        CTO_WORKFLOW_API_PK.get_activity_status(
				itemtype	=> 'OEOL',
                                itemkey		=> to_char(p_model_line_id),
                                linetype	=> 'MODEL',
                                activity_name	=> l_active_activity);




        if( v_aps_version <> 10 ) then
            if (l_active_activity = 'NULL') then	-- note: it is character NULL, not regular null

                 /*-----------------------------+
                   Model line workflow status
                   is not eligible for Link.
                 +-----------------------------*/
                 IF PG_DEBUG <> 0 THEN
            	    oe_debug_pub.add
                     ('link_config: ' || 'Model Workflow Status not Eligible for Link.', 1);
                 END IF;

                 cto_msg_pub.cto_message('BOM', 'CTO_INVALID_WORKFLOW_STATUS');
                 x_message_name := 'CTO_INVALID_WORKFLOW_STATUS';
                 return FALSE;

             end if;

             IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('link_config: ' || 'Workflow Status is: ' || l_active_activity, 2);
             END IF;

             -- Link the config item.
             l_stmt_num := 130;
             IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('link_config: ' || 'Config Item: ' || to_char(p_config_item_id),2);
             END IF;



        else


        	oe_debug_pub.add('link_config: ' || '************ workflow need not necessarily be at CREATE_CONFIG_ITEM_ELIGIBLE as APS patchset J is installed '
                                                 || ' and order is scheduled '    ,2);


        end if ;


        l_status := CTO_CONFIG_ITEM_PK.link_item(
				pOrgId		=> l_org_id,
                                pModelId	=> l_model_id,
                                pConfigId	=> p_config_item_id,
                                pLineId		=> p_model_line_id,
                                xMsgCount	=> x_message_count,
                                xMsgData	=> x_message_data);

        IF (l_status <> 1) THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('link_config: ' || 'Failed in link_item function', 1);
            END IF;
            raise PROCESS_ERROR;
        END IF;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('link_config: ' || 'Success in link_item function', 1);
        END IF;




        if( l_active_activity = 'CREATE_CONFIG_ITEM_ELIGIBLE'   ) then



              /*------------------------------+
              Update Model Line's workflow.
              +-------------------------------*/
              IF (CTO_WORKFLOW_API_PK.start_model_workflow(p_model_line_id) = FALSE)
              THEN
                  IF PG_DEBUG <> 0 THEN
            	     oe_debug_pub.add('link_config: ' || 'Failed in call to start_model_workflow',1);
                  END IF;
                  raise PROCESS_ERROR;
              END IF;

	      IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_config: ' || 'Getting config line id.', 2);
	      END IF;




       else


		oe_debug_pub.add ('link_config: ' || 'did not call cto_workflow_api_pk.start_model_workflow as l_active_activity
                                                      is not at CREATE_CONFIG_ITEM_ELIGIBLE.', 2);

        end if ;


       	l_stmt_num := 140;
	select line_id, header_id
	into   l_config_line_id, l_header_id
	from   oe_order_lines_all
	where  ato_line_id = p_model_line_id
	and    item_type_code = 'CONFIG';

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_config: ' || 'Config line id is ' || to_char(l_config_line_id), 2);

		oe_debug_pub.add('link_config: ' || 'header ID: ' || to_char(l_header_id), 2);
	END IF;


	l_stmt_num := 160;
	IF PG_DEBUG <> 0 THEN

                oe_debug_pub.add('link_config: ' || 'Calling display wf status API ',2);
	END IF;


        --bugfix 3755608 changed the call to display_wf_status from OM api
        l_return_status  := CTO_WORKFLOW_API_PK.display_wf_status( p_order_line_id => l_config_line_id );

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('link_config: ' || 'Return from display_wf status'||l_return_status,1);
	END IF;

        --Begin Bugfix 6398466

        l_stmt_num := 170;
        begin

          SELECT  config_item_id,
                  inventory_item_id,
                  ship_from_org_id
          BULK COLLECT INTO old_config_dtls.config_item_id,
                            old_config_dtls.base_item_id,
                            old_config_dtls.ship_from_org_id
          FROM bom_cto_order_lines
          WHERE top_model_line_id = p_model_line_id
          AND config_item_id IS NOT NULL
          AND line_id <> top_model_line_id;

        exception
          when no_data_found then
            null;
        end;

        IF old_config_dtls.config_item_id.Count = 0 THEN

          IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('link_config: ' || 'Delinked config did not have child configs. Updating only the top config.', 1);
	  END IF;

          l_stmt_num := 180;

          UPDATE bom_cto_order_lines
          SET config_item_id = p_config_item_id
          WHERE line_id = p_model_line_id;

        ELSE
          IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('link_config: ' || 'Looking if bom for '|| p_config_item_id || 'exists in shipping org ' || old_config_dtls.ship_from_org_id(1), 1);
          END IF;

          BEGIN
            l_stmt_num := 190;

            SELECT 1
              INTO l_bom_exists
                FROM bom_bill_of_materials bom
                WHERE bom.assembly_item_id = p_config_item_id
                AND bom.organization_id = old_config_dtls.ship_from_org_id(1)
                AND bom.alternate_bom_designator IS NULL;

          EXCEPTION
            WHEN No_Data_Found THEN
              l_bom_exists := 0;
          END;

          IF l_bom_exists = 0 THEN
            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('link_config: ' || 'BOM not found in ship org ' || old_config_dtls.ship_from_org_id(1), 1);
               oe_debug_pub.add('link_config: ' || 'Going to call query sourcing orgs', 1);
            END IF;

            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('link_config: ' || 'Top level model l_model_id= ' || l_model_id, 1);
            END IF;

            l_stmt_num := 200;
            CTO_MSUTIL_PUB.query_sourcing_org_ms(
                                 p_inventory_item_id  => l_model_id
                               , p_organization_id  => old_config_dtls.ship_from_org_id(1)
                               , p_sourcing_rule_exists => v_sourcing_rule_exists
                               , p_source_type => v_source_type
                               , p_t_sourcing_info => v_t_sourcing_info
                               , x_exp_error_code => x_exp_error_code
                               , x_return_status => x_return_status     );

            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               oe_debug_pub.add(' Error in query_sourcing_org_ms.. ', 1);
               raise PROCESS_ERROR;
            END IF;

            l_stmt_num := 210;

            FOR i IN 1..v_t_sourcing_info.sourcing_rule_id.Count LOOP
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('****$$$$ org ' || v_t_sourcing_info.source_organization_id(i)
                                                        ||  '****$$$$ rule  ' || v_t_sourcing_info.sourcing_rule_id(i)
                                                        ||  '****$$$$ type  ' || v_t_sourcing_info.source_type(i)
                                                        ||  '****$$$$ rank ' || v_t_sourcing_info.rank(i)
                                                        ||  '****$$$$ assig id  ' || v_t_sourcing_info.assignment_id(i),1);
              END IF;
            END LOOP;

            FOR i IN 1..v_t_sourcing_info.sourcing_rule_id.Count LOOP
              l_org := v_t_sourcing_info.source_organization_id(i);

              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('link_config: ' || 'Inside for loop****$$$$ org ' || l_org, 1);
                 oe_debug_pub.add('link_config: ' || 'Looking if bom for '|| p_config_item_id || 'exists in org ' || l_org, 1);
              END IF;

              BEGIN

                l_stmt_num := 220;

                SELECT 1
                  INTO flag
                    FROM bom_bill_of_materials bom
                    WHERE bom.assembly_item_id = p_config_item_id
                    AND bom.organization_id = l_org
                    AND bom.alternate_bom_designator IS NULL;

              EXCEPTION
                WHEN No_Data_Found THEN
                  NULL;
              END;

              IF flag = 1 THEN
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('link_config: ' || 'BOM found in org ' || l_org, 1);
                END IF;

                EXIT;

              END IF;  --flag = 1

            END LOOP;  --loop for i

          ELSE
            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('link_config: ' || 'BOM found in ship org ' || old_config_dtls.ship_from_org_id(1), 1);
            END IF;

            flag := 1;
            l_org := old_config_dtls.ship_from_org_id(1);

          END IF;  --l_bom_exists <> 1

          IF flag = 0 THEN   --bom doesn't exist in any orgs in sourcing chain. Updating the top level config
            l_stmt_num := 230;

            UPDATE bom_cto_order_lines
            SET config_item_id = p_config_item_id
            WHERE line_id = p_model_line_id;

            UPDATE bom_cto_order_lines  --Updating the lower level configs to NULL
            SET config_item_id = NULL
            WHERE top_model_line_id = p_model_line_id
            AND config_item_id IS NOT NULL
            AND line_id <> top_model_line_id;

          ELSE
            l_stmt_num := 240;
            get_all_configs(p_config_item_id, new_config_dtls, l_org);

            l_stmt_num := 250;

            IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('link_config: ' || 'Printing values in new_config_dtls',1);
            END IF;

            FOR i IN 1..new_config_dtls.config_item_id.Count LOOP
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('link_config: ' || i||' '||'Config '||new_config_dtls.config_item_id(i)||' Model '||new_config_dtls.base_item_id(i),1);
              END IF;
            END LOOP;

            IF new_config_dtls.config_item_id.Count = 0 THEN
              --New config doesn't have child configs. Updating only the top level config
              l_stmt_num := 260;

              UPDATE bom_cto_order_lines
              SET config_item_id = p_config_item_id
              WHERE line_id = p_model_line_id;

              --Updating lower level configs of original config to NULL
              UPDATE bom_cto_order_lines
              SET config_item_id = NULL
              WHERE top_model_line_id = p_model_line_id
              AND config_item_id IS NOT NULL
              AND line_id <> top_model_line_id;

            ELSE
              FOR i IN 1..old_config_dtls.config_item_id.Count LOOP
                bmodel_exists := 0;
                FOR j IN 1..new_config_dtls.config_item_id.Count LOOP

                  IF old_config_dtls.base_item_id(i) = new_config_dtls.base_item_id(j) THEN
                     IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('link_config: ' || i||'old_config_dtls.base_item_id(i) '||old_config_dtls.base_item_id(i)||j||'new_config_dtls.base_item_id(j) '||new_config_dtls.base_item_id(j), 1);
                        oe_debug_pub.add('link_config: ' ||'Model '||old_config_dtls.base_item_id(i)||' exists in BOM of ' ||new_config_dtls.config_item_id(j), 1);
                     END IF;

                     bmodel_exists := 1;
                     l_stmt_num := 270;

                     --Updating config id corresponding to the model old_config_dtls.base_item_id(i)
                     UPDATE bom_cto_order_lines
                     SET config_item_id = new_config_dtls.config_item_id(j)
                     WHERE ato_line_id = p_model_line_id
                     AND inventory_item_id = new_config_dtls.base_item_id(j);

                     EXIT;

                  END IF;
                END LOOP;  --loop for j

                IF bmodel_exists = 0 THEN  --BOM of new config doesn't have this model
                  l_stmt_num := 280;

                  UPDATE bom_cto_order_lines
                    SET config_item_id = NULL
                    WHERE ato_line_id = p_model_line_id
                    AND inventory_item_id = old_config_dtls.base_item_id(i);
                END IF;
              END LOOP;  --loop for i
            END IF;  --new_config_dtls.config_item_id.Count = 0
          END IF;  --flag = 0
        END IF;  --old_config_dtls.config_item_id.Count = 0

      IF old_config_dtls.config_item_id.Count = 0 OR flag = 0 OR ( flag = 1 AND new_config_dtls.config_item_id.Count = 0 ) THEN
         --In these cases, we have already updated the top level config
         NULL;
      ELSE
          l_stmt_num := 290;

          UPDATE bom_cto_order_lines
          SET config_item_id = p_config_item_id
          WHERE line_id = p_model_line_id;
      END IF;
       --End Bugfix 6398466

        x_message_name := 'SUCCESS';
        return TRUE;

EXCEPTION

       when PROCESS_ERROR then
	   x_message_name := 'CTO_LINK_ERROR' ;
	   cto_msg_pub.cto_message('BOM', x_message_name);
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('link_config: ' || 'CTOLINKB: ' || l_stmt_num || ':' || x_error_message, 1);
           END IF;
           return FALSE;

       when OTHERS then
           x_message_name := 'CTO_LINK_ERROR';
	   cto_msg_pub.cto_message('BOM', x_message_name);
           x_error_message := 'CTOLINKB:link_config : ' || to_char(l_stmt_num) || ':' || substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('link_config: ' || x_error_message, 1);
           END IF;
           return FALSE;
END link_config;



FUNCTION Validate_Link(p_model_line_id         in  number,
        		p_config_item_id        in  number,
        		x_error_message         out NOCOPY varchar2,
        		x_message_name          out NOCOPY varchar2
)
RETURN integer

IS

l_valid	number := 0;

BEGIN

	IF (p_model_line_id is null) OR (p_config_item_id is null) THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Validate_Link: ' || 'Invalid model line or config item',2);
		END IF;
		return(0);
	END IF;


	select distinct 1
	into l_valid
	from oe_order_lines_all oel,	--model line
		mtl_system_items msi	--config item
	where oel.line_id = p_model_line_id
	and oel.inventory_item_id = msi.base_item_id
	and msi.inventory_item_id = p_config_item_id;

	IF l_valid = 1 THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Validate_Link: ' || 'Item to be linked is valid',2);
		END IF;
		return(1);
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Validate_Link: ' || 'Item to be linked is invalid',2);
		END IF;
		x_message_name := 'CTO_LINK_ERROR';
           	x_error_message := 'CTLINKB:validate_link:not a valid link:';
		return(0);
	END IF;

EXCEPTION
	when no_data_found then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Validate_Link: ' || 'Item to be linked is invalid',1);
		END IF;
		x_message_name := 'CTO_LINK_ERROR';
           	x_error_message := 'CTOLINKB:validate_link:ndf: '
                              ||substrb(sqlerrm,1,100);
		return(0);
	when others then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Validate_Link: ' || 'Item to be linked is invalid::others exception',1);
		END IF;
		x_message_name := 'CTO_LINK_ERROR';
           	x_error_message := 'CTOLINKB:validate_link:others: '
                              ||substrb(sqlerrm,1,100);
		return(0);
		return(0);

END Validate_Link;


/*
Bugfix 6398466: Introduced this procedure. This procedure is called recursively and collects all the
child configuration item ids in table cfg_tbl.
*/

PROCEDURE get_all_configs(
  pconfigId IN NUMBER,
  new_config_dtls IN OUT NOCOPY config_bcol_rec,
  pshipOrg IN NUMBER
  ) AS

 l_index NUMBER;

 CURSOR get_configs IS
   SELECT inventory_item_id, base_item_id
      FROM mtl_system_items msi
      WHERE inventory_item_id IN
      ( SELECT component_item_id
          FROM bom_inventory_components bic, bom_bill_of_materials bom
          WHERE bom.assembly_item_id = pconfigId                       --p_config_id
          AND bom.common_bill_sequence_id = bic.bill_sequence_id
          AND bom.alternate_bom_designator IS NULL
          AND bom.organization_id = pshipOrg
      )
      AND auto_created_config_flag = 'Y'
      AND organization_id = pshipOrg;

  BEGIN

    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('Inside get_all_configs', 1);
       oe_debug_pub.add('Value of config id passed: '|| pconfigId, 1);
    END IF;

    OPEN get_configs;

    LOOP
      l_index := new_config_dtls.config_item_id.Count + 1;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('l_index '||l_index, 1);
      END IF;

      FETCH get_configs INTO new_config_dtls.config_item_id(l_index),
                             new_config_dtls.base_item_id(l_index);

      EXIT WHEN get_configs%NOTFOUND;

      get_all_configs(new_config_dtls.config_item_id(l_index), new_config_dtls, pshipOrg);

    END LOOP;

    CLOSE get_configs;

    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('Count '||new_config_dtls.config_item_id.count, 1);
    END IF;

  END get_all_configs;

end CTO_MANUAL_LINK_CONFIG;

/
