--------------------------------------------------------
--  DDL for Package Body CTO_MATCH_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_MATCH_CONFIG" as
/* $Header: CTOMCFGB.pls 120.6.12010000.2 2008/08/14 11:33:11 ntungare ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOMCFGB.pls                                                  |
| DESCRIPTION:                                                                |
|               This file creates packaged functions that check for matching  |
|               configurations and insert unique configurations into          |
|               BOM_ATO_CONFIGURATIONS.                                       |
|                                                                             |
|               check_config_match - checks BOM_ATO_CONFIGURATIONS for        |
|               configurations that match the ordered configuration.  It      |
|               is called from the Match Configuration Workflow activity      |
|               and from the Create Configuration batch process.              |
|                                                                             |
|               can_configurations - inserts unique configurations into       |
|               BOM_ATO_CONFIGURATIONS.  It is called from the Create         |
|               Configuration batch process and the Create Configuration      |
|               Item and BOM workflow activity.                               |
|                                                                             |
| To Do:        Handle Errors.  Need to discuss with Usha and Girish what     |
|               error information to include in Notification.                 |
|                                                                             |
| HISTORY     :                                                               |
|               May 10, 99  Angela Makalintal   Initial version		      |
|									      |
| 2/23/01       SBHASKAR   	Bugfix 1553467				      |

|
|
|
|
| 2/31/03       SSAWANT         BugFix 2789771                                |
|                               A fundamental bug for matching was fixed.     |
|                               This happens due to the new                   |
|                               Multiple Instantiation                        |
|                               feature for all levels of ATO Models          |
|                               introduced in current DMF, CZ 11.5.9          |
|                                                                             |
|                                                                             |
|                                                                             |
| 7/02/03       KSARKAR         Bugfix 2986192                                |
|
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items
|
|09/05/03     Kiran Konada    chnages for patchset-J
|
|
|||09-10-2003   Kiran Konada
|
|			       bugfix  3070429,3124169
|                              pragtion bugfix #3143556
|
|
|                              After a call to create item ,  a new call is added to
|                              CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
|
|                              NOTE: CTO_ENI_WRAPPER is maintained in bom Source control and
|                              is owned by ENI team. This is done as part of bugfix 3070429
|
|                              Always the main code contains stubbed version and branch has the
|                              a call to file maintained in ENI product top
|
|                              Branch is always shipped with  ENI
|
|                              The above approach was taken as CTO could not directly make a
|                              call to a ENI file. ENI is present from 11.5.4 onwards and
|                              CTO bugfixes can be shipped to all customers since base release
|                              (11.5.2)
|
|                              The error messages if any from CTO_CALL_TO_ENI  are ignored
|                              decision:Usha Arora,Krishna Bhagvatula,Anuradha subramnian<Kiran Koanda)
|                              As CTO should not error out in its process becuase of failure in inserting
|                              in DBI atbles used for intelligence
|
|
|  11-05-2003  Kiran Konada
|                          added following line in evaluate and pop match procedure
|                          to look at custom profile
|
|                          l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');
|
|  01-20-2003  Kiran Konada bugfix 3381658
|
|
|
|  02/23/2003  Kiran Konada bugfix 3259017
|                      added no copy chnages for new procedures added
|                      as part of 11.5.10
|
|
|  03/04/2004  Kiran Konada bugfix 3443204
|              Preventing canning for pre-configured item
|              which has relenish_to_order_lflag set to 'N'
|
|
| 03/26/2004   Kiran Konada 3530054
|              Added a nvl for wip_supply_type
|              wip_supply_type is populated as null value during ACC
|
|
|               Modified   :    13-APR-2004     Sushant Sawant
|                                               Fixed Bug 3533192
|                                               Similar configurations under different models should result in same config item
|04/26/2004    Kiran Konada 3503764
|              re-use shhould not happen for a ware-house change
|
|05/03/2004    Kiran Konada 3503764
|              reuse sql for  3503764 needs to comapre th ware house change
|              only for models
|              Hence added additional where conditions
|              bom_item_type=1 and wip_supply_type<>6
|
|05/17/2004    Kiran Konada 3555026
|
|                          --null value in config_orgs should be treated as
|                            based on sourcing
|                          --When ATP passes null in ship_from_org_id, we should
|                            NOT default to any other organization
|                            AS that org could be a ware house on SO pad
|                            during intial scheduling and hence bcol could have
|                            the data AND would create a problem in re-use,
|                            as configitem is reused if ware house is same
|                            before and after re-scheduling
|                          --To get match attribute using validation_org as
|                            ship_from_org_id can be null
|
|07/07/2004   Kiran Konada bugfix 3745659
|             added delete before insert into BCOL_GT
|
|
+=============================================================================*/

/****************************************************************************
   Procedure:   Match_and_create_all_items
   Parameters:  p_model_line_id   - line id of the top model in
                                      oe_order_lines_all
                x_return_status   - return status
                x_msg_count
                x_msg_data

   Description:  This function looks for a configuration in
                 bom_ato_configurations that matches the ordered
                 configuration in oe_order_lines_all.

*****************************************************************************/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);
--PG_DEBUG Number := 5;

TYPE reuse_rec_type is RECORD  (
                 line_id              Number,
		 parent_ato_line_id   Number,
		 reuse_config         VARCHAR2(1));

TYPE reuse_tbl_rec_type is TABLE OF reuse_rec_type INDEX BY Binary_integer;

TYPE Number1_arr_tbl_type is TABLE of Number INDEX BY Binary_integer;

g_reuse_tbl		reuse_tbl_rec_type;
g_model_line_tbl        Number1_arr_tbl_type;


procedure match_and_create_all_items(
        pModelLineId       in  number, -- ato line id
        xReturnStatus         out NOCOPY varchar2,
        xMsgCount             out NOCOPY number,
        xMsgData              out NOCOPY varchar2
        )

IS

       l_x_error_msg    varchar2(100);
       l_x_msg_name     varchar2(30);
       l_x_table_name	varchar2(30);
       lStatus          number;
       lXConfigId       number;
       lPerformMatch    varchar2(1);
       lStmtNum         number := 0;
       lFlowCalc        number := 1;
       l_custom_match_profile	varchar2(10);

       cursor c_model_lines is
       --select perform_match, line_id, parent_ato_line_id, inventory_item_id
       select line_id, parent_ato_line_id, inventory_item_id
       from   bom_cto_order_lines
       where  bom_item_type = 1
       --and    top_model_line_id = pModelLineId -- top model
       and    ato_line_id = pModelLineId
       and    nvl(wip_supply_type,0) <> 6
       and    config_item_id is null -- do we need this in case on-line match
       and    ato_line_id is not null -- could be a PTO
       order by plan_level desc;

        --start bugfix  3070429,3124169
       l_eni_star_record    CTO_ENI_WRAPPER.STAR_REC_TYPE;
       eni_return_status VARCHAR2(1);

        --end bugfix  3070429,3124169

BEGIN

       gUserId  := nvl(Fnd_Global.USER_ID, -1) ;
       gLoginId := nvl(Fnd_Global.LOGIN_ID, -1);

       xReturnStatus := FND_API.G_RET_STS_SUCCESS;


       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('match_and_create_all_items: ' || 'In Match_and_Create_all_Items for ato_line_id '
                        || to_char(pModelLineId), 1);
       END IF;

	l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('match_and_create_all_items: ' || 'CUSTOM_MATCH: ' || l_custom_match_profile, 1);
        END IF;

       /*-----------------------------------------------------+
         This is the loop that traverses bom_cto_order_lines
         to match each configured assembly.  If an assembly
         does not have a match, a new item is created.  If
         it does have a match, we make create that item
         in all the sourcing organizations if it does not exist.
       +-----------------------------------------------------*/
       for lNextRec in c_model_lines loop

           lXConfigId := NULL;

           select perform_match
           into   lPerformMatch
           from   bom_cto_order_lines
           where  line_id = lNextRec.line_id;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('match_and_create_all_items: ' || 'Match_and_create_all_items: Processing line_id '
                            || to_char(lNextRec.line_id) ||
                            ' with perform_match value ' ||
                            lPerformMatch, 1);
           END IF;

           if (lPerformMatch = 'N') then

               lStmtNum := 100;

               lStatus := CTO_CONFIG_ITEM_PK.create_item(
                                      pModelId	=> lNextRec.inventory_item_id, -- Model
                                      PLineId	=> lNextRec.line_id,
                                      pConfigId	=> lXConfigId,
                                      xMsgCount	=> xMsgCount,
                                      xMsgData	=> xMsgData
                                      );

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('match_and_create_all_items: ' ||
                 'Returned from create_item in stmt num 100 with status ' ||
                 to_char(lStatus), 1);
               END IF;

               if (lStatus = 0) then

                   raise fnd_api.g_exc_error;

                elsif lStatus =1 then
	                 --start bugfix  3070429,3124169

                        l_eni_star_record.inventory_item_id := lXConfigId;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'conifg item id passed to ENI=>'||
				                   l_eni_star_record.inventory_item_id , 5);
			END IF;

			--follwoing API is maintained by PLM,DBI team present in Bom source control
			CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
			        (p_api_version  => 1.0,
				 p_star_record  => l_eni_star_record,
				 x_return_status =>eni_return_status,
                                 x_msg_count	 => xMsgCount,
                                 x_msg_data	 => xMsgData);


			 --return status passed as 'S' and not as FND_API.XXXXX
			 --CTO has decided not to fail for error messages but just log messages
			 --refer bug 3124169 for more info
			 IF  eni_return_status = 'S' THEN
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items:' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 5);
			     END IF;
			 ELSE
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 1);
			        oe_debug_pub.add('match_and_create_all_items: ' || 'IGNORING ABOVE ERROR', 1);
			     END IF;

			 END IF;

		       --end bugfix  3070429,3124169

               end if;

               lStmtNum := 110;
               lStatus := can_configurations(
                                          lNextRec.line_id,
                                          0,
                                          0,
                                          0,
                                          gUserId,
                                          gLoginId,
                                          l_x_error_msg,
                                          l_x_msg_name);

               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('match_and_create_all_items: ' ||
                  'Returned from canning in stmt num 110 with status '
                  || to_char(lStatus), 1);
               END IF;

               if (lStatus = 1) then

                   begin

                      update bom_cto_order_lines
                      set    perform_match = 'N'
                      where  line_id = lNextRec.parent_ato_line_id
                      and    perform_match = 'Y';
			-- if the update fails, its not an error

                   end;

               else

                    raise fnd_api.g_exc_error;

                end if; -- end lStatus = 1

           else

                lStmtNum := 120;
		IF l_custom_match_profile = 2 THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Standard Match.', 1);
			END IF;
                	lStatus := check_config_match(
                                        lNextRec.line_id,
                                        lXConfigId,
                                        l_x_error_msg,
                                        l_x_msg_name);

                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('match_and_create_all_items: ' || 'Returned from check_config_match with status '
                                 || to_char(lStatus), 1);
                	END IF;

			if lStatus <> 1 then
			    raise fnd_api.g_exc_error;
			end if;
		ELSE
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Custom Match.', 1);
			END IF;
                	lStatus := CTO_CUSTOM_MATCH_PK.find_matching_config(
                                          pModelLineId		=> lNextRec.line_id,
                                          xMatchedItemId	=> lXConfigId,
                                          xErrorMessage		=> l_x_error_msg,
                                          xMessageName		=> l_x_msg_name,
                                          xTableName		=> l_x_table_name);

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Returned from find_matching_config with status '
                                 || to_char(lStatus), 1);
			END IF;

			if lStatus <> 1 then
			    raise fnd_api.g_exc_error;
			end if;

		END IF;

                if (lStatus = 1 and lXConfigId is null) then

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' || 'No match for line ' ||
                                     to_char(lNextRec.line_id), 1);
                    END IF;

                    lStmtNum :=  130;

                    lStatus := CTO_CONFIG_ITEM_PK.create_item(
                                      pModelId		=> lNextRec.inventory_item_id, -- Model
                                      pLineId		=> lNextRec.line_id,
                                      pConfigId		=> lXConfigId,
                                      xMsgCount		=> xMsgCount,
                                      xMsgData		=> xMsgData);

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' ||
                      'Returned from create_item in stmt num 130 with status '
                      || to_char(lStatus), 1);
                    END IF;

                    if (lStatus <> 1) then

                        raise fnd_api.g_exc_error;

		    else
		       	     --start bugfix  3070429,3124169

                        l_eni_star_record.inventory_item_id := lXConfigId;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'conifg item id passed to ENI=>'||
				                   l_eni_star_record.inventory_item_id , 5);
			END IF;

                        --follwoing API is maintained by PLM,DBI team present in Bom source control
			CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
			        (p_api_version  => 1.0,
				 p_star_record  => l_eni_star_record,
				 x_return_status =>eni_return_status,
                                 x_msg_count	 => xMsgCount,
                                 x_msg_data	 => xMsgData);


			 --return status passed as 'S' and not as FND_API.XXXXX
			 --CTO has decided not to fail for error messages but just log messages
			 --refer bug 3124169 for more info
			 IF  eni_return_status = 'S' THEN
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items:' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 5);
			     END IF;
			 ELSE
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 1);
			        oe_debug_pub.add('match_and_create_all_items: ' || 'IGNORING ABOVE ERROR', 1);
			     END IF;

			 END IF;

		       --end bugfix  3070429,3124169


                    end if;

                    lStmtNum := 140;
                    lStatus := can_configurations(
                                          lNextRec.line_id,
                                          0,
                                          0,
                                          0,
                                          gUserId,
                                          gLoginId,
                                          l_x_error_msg,
                                          l_x_msg_name);

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' ||
                    'Returned from canning in stmt num 140 with status '
                      || to_char(lStatus), 1);
                    END IF;

                    if (lStatus <> 1) then

                        raise fnd_api.g_exc_error;
                    end if;

                    begin

                       update bom_cto_order_lines
                       set    perform_match = 'N'
                       where  line_id = lNextRec.parent_ato_line_id
                       and    perform_match = 'Y';
			-- if the update fails, its not an error

                     end;

                elsif (lStatus = 1 and lXConfigId is not null) then

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' || 'Match found for line ' ||
                                     to_char(lNextRec.line_id) ||
                                     ' with config item ' ||
                                     to_char(lXConfigId), 1);
                    END IF;

		    /*bugfix 2986192 */
                     gMatch := 1;
                     IF PG_DEBUG <> 0 THEN
                     	oe_debug_pub.add('Value of gMatch ' ||gMatch,1);
		     END IF;

                    lStmtNum := 150;
                    lStatus := CTO_CONFIG_ITEM_PK.create_item(
                                      pModelId		=> lNextRec.inventory_item_id, -- Model
                                      pLineId		=> lNextRec.line_id,
                                      pConfigId		=> lXConfigId,
                                      xMsgCount		=> xMsgCount,
                                      xMsgData		=> xMsgData);

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' ||
                     'Returned from create_item in stmt num 150 with status '
                             || to_char(lStatus), 1);
                    END IF;

                    if (lStatus = 0) then

                        raise fnd_api.g_exc_error;

                    else
		        --start bugfix  3070429,3124169

                        l_eni_star_record.inventory_item_id := lXConfigId;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'conifg item id passed to ENI=>'||
				                   l_eni_star_record.inventory_item_id , 5);
			END IF;

                        --follwoing API is maintained by PLM,DBI team present in Bom source control
			CTO_ENI_WRAPPER.CTO_CALL_TO_ENI
			        (p_api_version  => 1.0,
				 p_star_record  => l_eni_star_record,
				 x_return_status =>eni_return_status,
                                 x_msg_count	 => xMsgCount,
                                 x_msg_data	 => xMsgData);


			 --return status passed as 'S' and not as FND_API.XXXXX
			 --CTO has decided not to fail for error messages but just log messages
			 --refer bug 3124169 for more info
			 IF  eni_return_status = 'S' THEN
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items:' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 5);
			     END IF;
			 ELSE
			     IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'ENI_CONFIG_ITEMS_PKG.Create_config_items returned=>'
                                                     ||eni_return_status, 1);
			        oe_debug_pub.add('match_and_create_all_items: ' || 'IGNORING ABOVE ERROR', 1);
			     END IF;

			 END IF;

		       --end bugfix  3070429,3124169

                    end if;

                else

                    raise fnd_api.g_exc_error;

                end if; -- end lStatus = 1 and lXConfigID is not null

           end if; -- end lNextRec.Perform_match

           lStmtNum := 160;
           update bom_cto_order_lines
           set    config_item_id = lXConfigId
           where  line_id = lNextRec.line_id;

       end loop;

       --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );

EXCEPTION

   WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('match_and_create_all_items: ' || 'Exception in stmt num: ' || to_char(lStmtNum), 1);
        END IF;
        xReturnStatus := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => xMsgCount
           , p_msg_data  => xMsgData
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('match_and_create_all_items: ' || ' Unexpected Exception in stmt num: ' || to_char(lStmtNum), 1);
        END IF;
        xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
            );

   WHEN OTHERS then
        oe_debug_pub.add('errmsg'||sqlerrm);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('match_and_create_all_items: ' || 'Others Exception in stmt num: ' || to_char(lStmtNum), 1);
        END IF;
        xReturnStatus := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count  => xMsgCount
           , p_msg_data   => xMsgData
             );

END match_and_create_all_items;


/*****************************************************************************
   Function:  check_config_match
   Parameters:  pModelLineId   - line id of the top model in oe_order_lines_all
                x_match_config_id - config id of the matching configuration
                                  from bom_ato_configurations
                x_error_message   - error message if match function fails
                x_message_name    - name of error message if match
                                    function fails

   Description:  This function looks for a configuration in
                 bom_ato_configurations that matches the ordered
                 configuration in oe_order_lines_all.

   Bugfix 1553467  : If an ATO model is part of a PTO model (see fig below),
                     then, the link_to_line_id of ATO model will be the line_id of
		     the PTO model. Since the PTO options are not inserted in
		     bom_cto_order_lines, the condition
			"and    colp.line_id = nvl(col1.link_to_line_id, col1.line_id)"
		     will fail.
		     Removed "colp" from the FROM clause and added a new condition after
		     commenting the old. Search on 1553467.
   PTO-MODEL-1
   ... ATO-MODEL-1
   ......ATO-OPTCLASS-1
   .........OPTION-1
   .........OPTION-2
   ......OPTION-3

   08-AUG-2003	   Kiran Konada
		   chnaged the code to use BCOL_TEMP instead of BCOL for patchser J



*****************************************************************************/


function check_config_match(
	p_model_line_id    in	number,
	x_config_match_id  out NOCOPY 	number,
        x_error_message    out NOCOPY     VARCHAR2,  /* 70 bytes to hold  msg */
        x_message_name     out NOCOPY    VARCHAR2 /* 30 bytes to hold  name */
	)
RETURN integer

IS

l_stmt_num     number;
l_cfm_value    number;

PARAMETER_ERROR    EXCEPTION;

/* (FP 	4895615) 4526218: Added the following variables*/
l_start_time        date;
diff                number;
l_component_sum     number;
l_component_count   number;
l_base_model_id     number;


BEGIN

         /**************************************************************
        *  Check BOM_ATO_CONFIGURATIONS for a configuration that matches the
        *  ordered configuration in oe_order_lines_all.
        ****************************************************************/


        oe_debug_pub.add('entered Check_config_match=>' );

        l_stmt_num := 0;
        if (p_model_line_id is NULL) then
	   raise PARAMETER_ERROR;
        end if;

         /*******************************************************************
        As part of (FP	4895615)
	base bug 4526218 doesnot work for multi-level match.SO,corrected the fix
	in FP. Correction is the usage of decode function. Abhimanyu, will obsolete
	the bug 4526218 and create a new patch for it.

	Bug4526218 begin: performance issue- Broke the match sql into two parts.
        The first sql shall insert into bom_ato_configs_temp the "approximate"
        matching configurations. For "approximate" match, it must have the same
        count of components and the sum of component item ids must be equal.

        The second sql shall work on the filtered set of probable match candidate
        configs to determine if there is any extra component in the order or in
        the config or whether the config has been deactivated in some orgs.
        ********************************************************************/

	 l_start_time := sysdate;

        IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add ('check_config_match :: start time : '||to_char(l_start_time, 'MM-DD-YYYY HH24:MI:SS'));
        END IF;

        l_stmt_num := 100;
        delete bom_ato_configs_temp;

        l_stmt_num := 110;
       select count(*), sum( nvl( decode(line_id, p_model_line_id, inventory_item_id, config_item_id),
                                    inventory_item_id
                                 )
                            )
        into   l_component_count, l_component_sum
        from   bom_cto_order_lines_gt
        where  parent_ato_line_id = p_model_line_id
        or     line_id = p_model_line_id;



        l_stmt_num := 120;
        select  inventory_item_id
        into    l_base_model_id
        from    bom_cto_order_lines_gt
        where   line_id = p_model_line_id;

        IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('l_component_count = '||l_component_count ||' l_component_sum = '||l_component_sum);
            oe_debug_pub.add(' l_base_model_id = '||l_base_model_id||' p_model_line_id = '||p_model_line_id);
        END IF;

        l_stmt_num := 130;
        --
        -- bug 7203643
        -- modified the SQL query to make use of the Exists clause
        -- instead of the IN operator
        -- ntungare
        --
        /*
        insert into bom_ato_configs_temp(
                config_item_id,
                organization_id,
                base_model_id,
                component_item_id,
                component_code,
                component_quantity)
        select  bac1.config_item_id,
                bac1.organization_id,
                bac1.base_model_id,
                bac1.component_item_id,
                bac1.component_code,
                bac1.component_quantity
        from    bom_ato_configurations bac1
        where   bac1.config_item_id in (
                                        select config_item_id
                                        from   BOM_ATO_CONFIGURATIONS bac3
                                        where  bac3.base_model_id = l_base_model_id
                                        group by bac3.config_item_id
                                        having count(*) = l_component_count
                                        and    sum(component_item_id) = l_component_sum
                                       )
        and     bac1.component_item_id = bac1.base_model_id;  --6086540: load just 1 record per config item
        */

        insert into bom_ato_configs_temp(
                config_item_id,
                organization_id,
                base_model_id,
                component_item_id,
                component_code,
                component_quantity)
        select  /*+ INDEX(BAC1 BOM_ATO_CONFIGURATIONS_N1)*/
                bac1.config_item_id,
                bac1.organization_id,
                bac1.base_model_id,
                bac1.component_item_id,
                bac1.component_code,
                bac1.component_quantity
        from    bom_ato_configurations bac1
        where   bac1.component_item_id = bac1.base_model_id
            and bac1.base_model_id     = l_base_model_id
            and EXISTS (SELECT 1
                         from  BOM_ATO_CONFIGURATIONS bac3
                        where  bac3.base_model_id  = l_base_model_id
                          and  bac1.config_item_id = bac3.config_item_id
                          and  bac1.base_model_id  = bac3.base_model_id
                        group by bac3.config_item_id
                        having count(*) = l_component_count
                        and    sum(component_item_id) = l_component_sum);


        IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add ('Rows inserted into gtt :'||sql%rowcount);
            oe_debug_pub.add ('check_config_match :: after bom_ato_configs_temp insert time : '||to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS'));
        END IF;

        l_stmt_num := 140;

	-- If the config item is INACTIVE in even one orgn, we will not consider that configuration for matching.

        select /*+ ordered */ bac1.config_item_id   -- 6086540: added the ordered hint
        into   x_config_match_id
        from   bom_cto_order_lines_gt  col1, /* model */
               bom_ato_configs_temp bact1,   --6086540: use the GTT for filtering based on approx match
               bom_ato_configurations bac1   --6086540: matching will be done in main table
        where  col1.line_id = p_model_line_id
        and    bac1.base_model_id  = col1.inventory_item_id
        and    bact1.base_model_id = col1.inventory_item_id
        and    bac1.component_item_id = col1.inventory_item_id
        and    bac1.config_item_id = bact1.config_item_id
	and not exists (
		select 'Config Item is not active in atleast one orgn'
		from   mtl_system_items msi,
		       bom_parameters bp
		where  msi.organization_id = bp.organization_id
		and    msi.inventory_item_id = bac1.config_item_id
		and    msi.inventory_item_status_code = nvl(bp.bom_delete_status_code,'NULL')
		)
        and    not exists
               (select 'Extra Options in Order'
                from   bom_cto_order_lines_gt col5
                where  (col5.parent_ato_line_id = col1.line_id
                     or col5.line_id = col1.line_id)  -- to pick up top model
                and    col5.ordered_quantity  > 0
                and    nvl(decode(col5.line_id, col1.line_id, col5.inventory_item_id,
                                                              col5.config_item_id),
                           col5.inventory_item_id) not in
                       (select  bac2.component_item_id
                       from   bom_ato_configurations bac2     -- 6086540
                       where  bac2.config_item_id    = bac1.config_item_id
                       and    bac2.component_item_id =
                            decode(col5.config_item_id, NULL,
                                   col5.inventory_item_id, decode(col5.line_id, col1.line_id,
                                                           col5.inventory_item_id, col5.config_item_id))
                       and    bac2.component_code    =
                                   substrb(col5.component_code,
                                           instrb(col5.component_code||'-',
                                                  '-'||to_char(col1.inventory_item_id)||'-')+1)
                       and    bac2.component_quantity =
                                  Round( nvl(col5.ordered_quantity,0)/ nvl(col1.ordered_quantity,0) , 7 )  /* Decimal-Qty Support for Option Items */
                       )
              )
        and not exists  /* Added due to Multiple Instantiation */
             ( select 'Extra Options in Config' from bom_ato_configurations bac9    -- 6086540
                where bac9.config_item_id =  bac1.config_item_id  /* v_config_item_id */
                  and ( bac9.component_item_id , bac9.component_quantity )
               not in
                    ( select decode( col1.line_id , col9.line_id, col9.inventory_item_id ,
                             nvl( col9.config_item_id, col9.inventory_item_id )),
                             Round( nvl( col9.ordered_quantity, 0)/nvl( col1.ordered_quantity, 0 ), 7 ) /* Decimal-Qty Support for Option Items */
                        from bom_cto_order_lines_gt col9
                       where col9.parent_ato_line_id = col1.line_id or col9.line_id = col1.line_id
                    )
             )
        and   rownum = 1;

        if (x_config_match_id is not NULL) then
          IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('matched item=>'|| x_config_match_id,5);
	  END IF;

           --Begin bugfix 7203643
           declare

             record_locked         EXCEPTION;
             pragma exception_init (record_locked, -54);
             --l_dummy 		   VARCHAR2(2);

             CURSOR config_rows IS
              SELECT last_referenced_date
              FROM   bom_ato_configurations
              WHERE  config_item_id = x_config_match_id
              FOR UPDATE NOWAIT;

           begin
             l_stmt_num := 110;

             OPEN config_rows;
             CLOSE config_rows;

             IF PG_DEBUG <> 0 THEN
		  OE_DEBUG_PUB.add ('check_config_match: ' || 'Locked rows.');
             END IF;

             l_stmt_num := 120;

             update bom_ato_configurations
             set    last_referenced_date = SYSDATE
             where  config_item_id = x_config_match_id;

           exception
             when record_locked then
	        IF PG_DEBUG <> 0 THEN
		  OE_DEBUG_PUB.add ('check_config_match: ' || 'Could not lock for config id '|| x_config_match_id ||' for update.');
	          OE_DEBUG_PUB.add ('check_config_match: ' || 'This config is being processed by another process. Not updating last_referenced_date.');
                END IF;
           end;
           --End bugfix 7203643
        end if;

        --start (FP 4895615 )4526218
	diff := (sysdate - l_start_time)*24*60*60;

        IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add ('check_config_match :: end time : '||to_char(sysdate, 'MM-DD-YYYY HH24:MI:SS'));
            oe_debug_pub.add('Time taken : '||diff);
        END IF;
       --end (FP 4895615)4526218

        return 1;

EXCEPTION
	when PARAMETER_ERROR THEN
           IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('check_config_match raised PARAMETER_ERROR',1);
           END IF;

           x_error_message := 'CTO_MATCH_CONFIG.check_config_match' ||
                         'Verify Parameters';
           x_message_name := 'CTO_MATCH_ERROR';
           cto_msg_pub.cto_message('BOM','CTO_MATCH_ERROR');
           return 0;


        when NO_DATA_FOUND then

	   IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add ('check_config_match :No data found',1);
	      oe_debug_pub.add ('check_config_match :returning 1,success',1);
           END IF;
           return 1;

	when OTHERS THEN

           IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('check_config_match raised OTHERS exception:'||sqlerrm);
           END IF;
	   x_error_message := 'CTO_MATCH_CONFIG.check_config_match' ||
                               to_char(l_stmt_num) || ':' ||
                               substrb(sqlerrm,1,150);
	   x_message_name := 'CTO_MATCH_ERROR';
           cto_msg_pub.cto_message('BOM','CTO_MATCH_ERROR');
           return 0;
END;



/*****************************************************************************
   Function:  can_configurations
   Parameters:  p_model_line_id   - line id of the model in oe_order_lines_all
                                     whose
                                  configuration will be inserted
                prg_appid       - program application id
                prg_id          - program id
                req_id          - job id
                user_id         - id of user running process
                login_id        - login id
                x_error_message   - error message if match function fails
                x_message_name    - name of error msg if match function fails

   Description:  This function inserts the configuration (model and components)
                 into BOM_ATO_CONFIGURATIONS for use when matching a
                 configuration via the Match functionality.

                 It is called from the Create Item and BOM batch process.

   Bugfix 1553467  : If an ATO model is part of a PTO model (see fig below),
                     then, the link_to_line_id of ATO model will be the line_id of
		     the PTO model. Since the PTO options are not inserted in
		     bom_cto_order_lines, the condition
        		"and    bcolParent.line_id = NVL(bcolModel.link_to_line_id, bcolModel.line_id); "
		     will fail.

		     Removed "bcolParent" from the FROM clause and added a new condition after
		     commenting the old. Search on 1553467.
   PTO-MODEL-1
   ... ATO-MODEL-1
   ......ATO-OPTCLASS-1
   .........OPTION-1
   .........OPTION-2
   ......OPTION-3
*****************************************************************************/
function can_configurations(
        p_model_line_id in number,
        prg_appid     in number,
        prg_id        in number,
        req_id        in number,
        user_id       in number,
        login_id      in number,
        error_msg     out NOCOPY varchar2,
        msg_name      out NOCOPY varchar2
        )
return integer

IS
        l_stmt_num number;

        PARAMETER_ERROR exception;
        INSERT_ERROR    exception;

	l_ato_flag VARCHAR2(1);
	l_cfg_item_id NUMBER;

BEGIN
        l_stmt_num := 0;
        if (p_model_line_id is NULL) then
           raise PARAMETER_ERROR;
        end if;




 --start bugfix 3443204
 --For a pre-configured item , the replenish_to_order_flag
 --can be 'N'. We should not can such items
 --Checking the flag irrespective of organization as
 --we expect the setup for an pre-configured item to be
 --same across all orgs
        l_stmt_num := 10;
        BEGIN
		SELECT 'Y'
		INTO l_ato_flag
		FROM bom_cto_order_lines bcol,
			mtl_system_items msi
		WHERE bcol.line_id = p_model_line_id
		AND   bcol.config_item_id = msi.inventory_item_id
		AND msi.replenish_to_order_flag = 'Y'
		AND rownum =1;
	EXCEPTION
	WHEN no_data_found THEN
              l_ato_flag := 'N';
	END ;
--bugfix 3443204

    IF l_ato_flag = 'Y' THEN --if clause added for 3443204




        /******************************************************************
         Insert into BOM_ATO_CONFIGURATIONS the model configuration from
         oe_order_lines_all.
        ******************************************************************/
        l_stmt_num := 100;
        insert into BOM_ATO_CONFIGURATIONS(
               config_item_id,
               organization_id,
               base_model_id,
               component_item_id,
               component_code,
               component_quantity,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               last_referenced_date,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
       select  bcolModel.config_item_id,
               bcolModel.ship_from_org_id,
               bcolModel.inventory_item_id,
               nvl(decode(bcolOptions.line_id, bcolModel.line_id, bcolOptions.inventory_item_id,
                                                                  bcolOptions.config_item_id),
                   bcolOptions.inventory_item_id),
               -- bugfix 1553467 begin
               substrb(bcolOptions.component_code,
                       instrb(bcolOptions.component_code||'-',
                              '-'||to_char(bcolModel.inventory_item_id)||'-')+1),
               -- bugfix 1553467 end

	       /* -- bugfix 1553467 comment begin
               decode(bcolModel.link_to_line_id, NULL,
                      bcolOptions.component_code,
                      substr(bcolOptions.component_code,
                      lengthb(bcolParent.component_code)+2)),
	        -- bugfix 1553467 comment end
	       */
               Round( (bcolOptions.ordered_quantity / bcolModel.ordered_quantity), 7 ) ,
-- qty represents ordered - canclld
/* Decimal-Qty Support for Option Items */
               SYSDATE,
               user_id,
               SYSDATE,
               user_id,
               login_id,
               SYSDATE,
               req_id,
               prg_appid,
               prg_id,
               SYSDATE
       from
	       -- bugfix 1553467: bom_cto_order_lines bcolParent,      /* Parent of Model, if any */
               bom_cto_order_lines bcolModel,       /* Model */
               bom_cto_order_lines bcolOptions      /* Options */
        where  bcolModel.line_id = p_model_line_id
        and    (bcolOptions.parent_ato_line_id = bcolModel.line_id or
                bcolOptions.line_id = bcolModel.line_id);
        --and    bcolOptions.ordered_quantity >
        --       NVL(bcolOptions.cancelled_quantity, 0)
	/*
	-- bugfix 1553467 : comment begin
        and    bcolParent.line_id = NVL(bcolModel.link_to_line_id,
                                            bcolModel.line_id);
	-- bugfix 1553467 : comment end
	*/


        if (SQL%ROWCOUNT > 0) then
            return 1;
        else
            raise INSERT_ERROR;
        end if;

   ELSE --flag is N

      IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('can_configurations: ' || 'Not canning the configuration AS', 3);
		oe_debug_pub.add('Assemble_to_order_flag is set to N ', 3);



      END IF;
      return 1;

   END IF; --3443204

EXCEPTION

        when PARAMETER_ERROR then
 --           IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || 'Failed in can_configurations 1. ', 1);
--            END IF;
            error_msg := 'CTO_MATCH_CONFIG.can_configurations' ||
                          to_char(l_stmt_num) || ':' ||
                         'Verify Parameters';
            msg_name := 'CTO_MATCH_ERROR';
--            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || error_msg, 1);
--            END IF;
            cto_msg_pub.cto_message('BOM','CTO_MATCH_ERROR');
            return 0;

        when INSERT_ERROR then
--            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || 'Failed in can_configurations 2. ', 1);
--            END IF;
            error_msg := 'CTO_MATCH_CONFIG.can_configurations' ||
                         'Insert Error';
	    msg_name := 'CTO_MATCH_ERROR';
--            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || error_msg, 1);
--            END IF;
            cto_msg_pub.cto_message('BOM','CTO_MATCH_ERROR');
            return 0;

        when OTHERS then
	    oe_debug_pub.add('errmsg'||sqlerrm);
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || 'Failed in can_configurations 3. ', 1);
            END IF;
            error_msg := 'CTO_MATCH_CONFIG.can_configurations' ||
                          to_char(l_stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('can_configurations: ' || error_msg, 1);
            END IF;
	    msg_name := 'CTO_MATCH_ERROR';
            cto_msg_pub.cto_message('BOM','CTO_MATCH_ERROR');
            return 0;


END; /* end can_configurations */


/*-----------------------
This procedure calculates the parent_ato_line_id


----------------------------*/

PROCEDURE populate_parent_ato(
  P_Source      in varchar2,
  P_tab_of_rec  in out NOCOPY CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count	   OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2

);



/*--------------------------
trans_tab_of_rec converts rec of tables
structure into table of records

----------------------------*/

PROCEDURE xfer_tab_to_rec(
                p_match_rec_of_tab IN	       CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
                x_tab_of_rec       OUT  NOCOPY CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
		x_return_status    OUT	NOCOPY       VARCHAR2,
		x_msg_count	   OUT	NOCOPY       NUMBER,
		x_msg_data         OUT	NOCOPY       VARCHAR2

                )
IS

i NUMBER := 0 ;
j integer ;

l_count number ;
lStmtNum NUMBER;


BEGIN


    IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('ENTERED xfer_tab_to_rec',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    lStmtNum :=10;
    l_count := p_match_rec_of_tab.LINE_ID.count;


     IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('count in table=>'|| l_count,5);
     END IF;




    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('no of records in table=>'|| l_count,5);--level 5
    END IF;
    i := 1;

    lStmtNum:= 20;
    While i is not null
    LOOP
         j				 := p_match_rec_of_tab.LINE_ID(i);

         x_tab_of_rec(j).l_index	 := i;


         x_tab_of_rec(j).LINE_ID	 := p_match_rec_of_tab.LINE_ID(i);


         x_tab_of_rec(j).ATO_LINE_ID     := p_match_rec_of_tab.ATO_LINE_ID(i);
         x_tab_of_rec(j).TOP_MODEL_LINE_ID:= p_match_rec_of_tab.TOP_MODEL_LINE_ID(i);
	 x_tab_of_rec(j).LINK_TO_LINE_ID := p_match_rec_of_tab.LINK_TO_LINE_ID(i);
         x_tab_of_rec(j).BOM_ITEM_TYPE   := p_match_rec_of_tab.BOM_ITEM_TYPE(i);
         x_tab_of_rec(j).wip_supply_type := p_match_rec_of_tab.WIP_SUPPLY_TYPE(i);

	 lStmtNum:=30;
	 i := p_match_rec_of_tab.LINE_ID.NEXT(i);
  	 --EXIT when i = l_count;

    END LOOP;


    l_count := x_tab_of_rec.count;


    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('count in record structure=>'|| l_count,5);
    END IF;





EXCEPTION
WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_tab_to_rec: ' || 'Exception in stmt num: '
		|| to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
       IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('xfer_tab_to_rec: ' || ' Unexpected Exception in stmt num: '
	                       || to_char(lStmtNum), 1);

       END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then

      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_tab_to_rec: ' || 'Others Exception in stmt num: '
		                  || to_char(lStmtNum), 1);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        oe_debug_pub.add('error mse'||sqlerrm);
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );



END xfer_tab_to_rec;

PROCEDURE xfer_rec_to_tab(
                p_tab_of_rec       IN		 CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
		p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
		x_return_status    OUT	NOCOPY	VARCHAR2,
		x_msg_count	   OUT	NOCOPY	NUMBER,
		x_msg_data         OUT	NOCOPY	VARCHAR2

                )

IS

i number := 0  ;
j number  ;


l_last_idx number;
lStmtNum NUMBER;
l_count number;



BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

       lStmtNum := 10;
       l_last_idx :=   p_tab_of_rec.last;
       j := p_tab_of_rec.first;
       l_count := p_tab_of_rec.count;

       IF PG_DEBUG <> 0 THEN

         oe_debug_pub.add('Last index in p_tab_of_rec strcuture=>'||l_last_idx,5);
         oe_debug_pub.add('first index in p_tab_of_rec strcuture=>'||j,5);
         oe_debug_pub.add('no of recs in p_tab_of_rec strcuture=>'||l_count,3);

       END IF;





      -- p_match_rec_of_tab.plan_level.extend(l_count);
      -- p_match_rec_of_tab.parent_ato_line_id.extend(l_count);
      -- p_match_rec_of_tab.gop_parent_ato_line_id.extend(l_count);


      --print only fi debug = 5

      IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('index '||' line_id '||' plan_level'
                          || 'parent_ato '||'gop_parent',5);
      END IF;

      lStmtNum :=30;
      WHILE(j <= l_last_idx)
      LOOP

	i := p_tab_of_rec(j).l_index;


	p_match_rec_of_tab.plan_level(i)		:= p_tab_of_rec(j).plan_level;

	p_match_rec_of_tab.parent_ato_line_id(i)	:= p_tab_of_rec(j).parent_ato_line_id;
	p_match_rec_of_tab.gop_parent_ato_line_id(i)	:= p_tab_of_rec(j).gop_parent_ato_line_id;

	--print only fi debug = 5

	IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(i||'=>'||p_match_rec_of_tab.line_id(i)||'=>' ||
	                     p_match_rec_of_tab.plan_level(i)||'=>'||
			     p_match_rec_of_tab.parent_ato_line_id(i)||'=>'||
			     p_match_rec_of_tab.gop_parent_ato_line_id(i),5);
        END IF;

        lStmtNum :=40;

	j := p_tab_of_rec.next(j);
       END LOOP;




EXCEPTION

  WHEN fnd_api.g_exc_error THEN
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_rec_to_tab: ' || 'Exception in stmt num: '
		                   || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_rec_to_tab: ' || ' Unexpected Exception in stmt num: ' ||
		                   to_char(lStmtNum), 1);
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_rec_to_tab: ' || 'Others Exception in stmt num: ' ||
		                     to_char(lStmtNum), 1);
		oe_debug_pub.add('errmessage' || sqlerrm,1);
       END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );



END xfer_rec_to_tab;




PROCEDURE populate_parent_ato(
 P_Source		in Varchar2,
 P_tab_of_rec  in out NOCOPY CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
 x_return_status    OUT NOCOPY		VARCHAR2,
 x_msg_count	   OUT NOCOPY		NUMBER,
 x_msg_data         OUT NOCOPY		VARCHAR2
)
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 v_prev_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i number;
 l_last_idx number;
 lStmtNum   number;
 BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Entered populate_parent_ato',5);
    END IF;

    v_step := 'Step C1' ;

    lStmtNum:=10;
    l_last_idx := P_tab_of_rec.last;

    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('last index'|| l_last_idx,5);
    END IF;


    i := P_tab_of_rec.FIRST;

    IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('first index'|| i,5);
    END IF;

    lStmtNum:=20;
    LOOP
       IF( P_tab_of_rec.exists(i)  ) THEN
          v_src_point := i ;


           IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add('populate_parent_ato: ' || 'present index=>'
	                        || v_src_point,5);
	       oe_debug_pub.add('populate_parent_ato: ' || 'ato line => '
	                        ||P_tab_of_rec(v_src_point).ato_line_id,5);
	       oe_debug_pub.add('populate_parent_ato: ' || 'top line => '
	                        ||P_tab_of_rec(v_src_point).top_model_line_id,5);

           END IF;

          lStmtNum:=30;
	  IF(P_tab_of_rec(v_src_point).ato_line_id is not null
		and
	       --filters out any individual embedded ato lines
	      P_tab_of_rec(v_src_point).top_model_line_id is not null) THEN

             IF PG_DEBUG <> 0 THEN
          	    oe_debug_pub.add('populate_parent_ato: ' ||  ' processing '
		    || to_char( v_src_point ) , 4 );
             END IF;

		/*
			** resolve parent ato line id for item.
		*/

	      v_step := 'Step C2' ;
	      lStmtNum:=40;
              WHILE( P_tab_of_rec.exists(v_src_point) )
              LOOP
		v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
		IF( P_tab_of_rec(v_src_point).line_id =
			P_tab_of_rec(v_src_point).ato_line_id )
		THEN

		      IF PG_DEBUG <> 0 THEN
          	         oe_debug_pub.add('populate_parent_ato: ' ||  'top_most ato parent '
		                           || to_char( v_src_point ),5);
                       END IF;
			exit ;
		END IF ;

		 /* store each unresolved item in its heirarchy */
		v_prev_src_point := v_src_point ;
		v_src_point := P_tab_of_rec(v_src_point).link_to_line_id ;



		IF( v_src_point is null  ) THEN
			 v_src_point := v_prev_src_point ;
			exit ;
		END IF ;

		IF(  P_tab_of_rec(v_src_point).ato_line_id is null  ) THEN
			v_src_point := v_prev_src_point ;
			/* break IF pto is on top of top level ato or
			  the current lineid is top level phantom ato
			v_src_point := null ;
			*/
			 exit ;
		END IF ;

		IF( P_tab_of_rec(v_src_point).bom_item_type = '1' AND
		    P_tab_of_rec(v_src_point).ato_line_id is not null AND
		    nvl( P_tab_of_rec(v_src_point).wip_supply_type , 0 ) <> '6' ) THEN
			 exit ;
                  /* break if non phantom ato parent found */
		END IF ;
              END LOOP ;

              j := v_raw_line_id.count ; /* total number of items to be resolved */

	      v_step := 'Step C3' ;
	      lStmtNum:=50;
              WHILE( j >= 1 )
	      LOOP
		P_tab_of_rec(v_raw_line_id(j)).parent_ato_line_id := v_src_point ;


		IF PG_DEBUG <> 0 THEN
          	   oe_debug_pub.add('populate_parent_ato: ' || v_raw_line_id(j)||
		                     ' parent '||v_src_point,5 );
                END IF;

		j := j -1 ;
	      END LOOP ;

		/* remove all elements as they have been resolved */
	      v_raw_line_id.delete ;

           END IF ; /* check whether ato_line_id is not null */

       END IF ;

       EXIT when i = l_last_idx;
       lStmtNum:=50;
       i := P_tab_of_rec.next(i);


      IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('populate_parent_ato: ' || 'next index=>'|| i,5);
       END IF;


    END LOOP ; --end of first while




   IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('--parent_ato_line_id--',5);
	  oe_debug_pub.add(' Line_id '||' => '||' parent_ato_line_id ',5);

	  i := P_tab_of_rec.first;
          WHILE i is not null
          LOOP
            oe_debug_pub.add(i||' => '||P_tab_of_rec(i).parent_ato_line_id,5);
             i := P_tab_of_rec.NEXT(i);
          END LOOP;

   END IF;



    --calculation of parent_ato_line_id for Gop (ATP) purpose
    --phatom models are treated as non-phantom during this calculation
     i := 0;
     l_last_idx := 0;
    lStmtNum:=70;
    IF P_Source = 'GOP' THEN
       v_step := 'Step C1' ;

       l_last_idx := P_tab_of_rec.last;
       i := P_tab_of_rec.FIRST;

       lStmtNum:=80;
       LOOP
       IF( P_tab_of_rec.exists(i)  ) THEN
          v_src_point := i ;

	  IF(P_tab_of_rec(v_src_point).ato_line_id is not null
		and
	       --filters out any individual embedded ato lines
	      P_tab_of_rec(v_src_point).top_model_line_id is not null) THEN

            IF PG_DEBUG <> 0 THEN
          	    oe_debug_pub.add('populate_parent_ato: ' ||  ' processing '
		    || to_char( v_src_point ) , 4 );
             END IF;
		/*
			** resolve parent ato line id for item.
		*/

	      v_step := 'Step C2' ;
	      lStmtNum:=90;
              WHILE( P_tab_of_rec.exists(v_src_point) )
              LOOP
		v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
		IF( P_tab_of_rec(v_src_point).line_id =
			P_tab_of_rec(v_src_point).ato_line_id )
		THEN
			exit ;
		END IF ;

		 /* store each unresolved item in its heirarchy */
		v_prev_src_point := v_src_point ;
		v_src_point := P_tab_of_rec(v_src_point).link_to_line_id ;



		IF( v_src_point is null  ) THEN
			 v_src_point := v_prev_src_point ;
			exit ;
		END IF ;

		IF(  P_tab_of_rec(v_src_point).ato_line_id is null  ) THEN
			v_src_point := v_prev_src_point ;
			/* break IF pto is on top of top level ato or
			  the current lineid is top level phantom ato
			v_src_point := null ;
			*/
			 exit ;
		END IF ;

		IF( P_tab_of_rec(v_src_point).bom_item_type = '1' AND
		    P_tab_of_rec(v_src_point).ato_line_id is not null
		    --wip_supplY-Type is ignored
		    ) THEN
			 exit ;
                  /* break if non phantom ato parent found */
		END IF ;
              END LOOP ;

              j := v_raw_line_id.count ; /* total number of items to be resolved */

	      v_step := 'Step C3' ;
	      lStmtNum:=90;
              WHILE( j >= 1 )
	      LOOP
		P_tab_of_rec(v_raw_line_id(j)).gop_parent_ato_line_id := v_src_point ;
		j := j -1 ;
	      END LOOP ;

		/* remove all elements as they have been resolved */
	      v_raw_line_id.delete ;

           END IF ; /* check whether ato_line_id is not null */

         END IF ;

	 EXIT when i = l_last_idx;

	 lStmtNum:=100;
         i := P_tab_of_rec.next(i);

       END LOOP ; --end of first while



    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('--gop parent_ato_line_id--',5);
	oe_debug_pub.add(' Line_id '||' => '||' gop parent_ato_line_id ',5);
	i := P_tab_of_rec.first;
	WHILE i is not null
	LOOP
		oe_debug_pub.add(i||' => '||P_tab_of_rec(i).gop_parent_ato_line_id,5);
		i := P_tab_of_rec.NEXT(i);
	END LOOP;
    END IF;--p debug

  END IF; --P_Source = GOP

EXCEPTION
 WHEN others THEN

   IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('populate_parent_ato: ' || 'Others Exception in stmt num: '
		                 || to_char(lStmtNum), 1);
	oe_debug_pub.add('errmsg'||sqlerrm,5);
    END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );


 END populate_parent_ato ;




 PROCEDURE populate_plan_level
 ( P_tab_of_rec  in out NOCOPY CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count	   OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2)
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i             number := 0 ;
 lStmtNum      number;

 begin

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add('Entered populate_plan_level',5);
     END IF;

       /*
    ** Strategy: Resolve plan_level for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */

        v_step := 'Step B1' ;
    lStmtNum :=10;
    i := P_tab_of_rec.first ;

    lStmtNum :=20;
    while i is not null
    loop

       if( P_tab_of_rec.exists(i)  ) then
           v_src_point := i ;

         --to filter out ATO items ordered individually
         IF P_tab_of_rec(v_src_point).top_model_line_id is not null THEN


		/*
		** resolve plan level for item only if not yet resolved
		*/
		lStmtNum :=30;
		while( P_tab_of_rec(v_src_point).plan_level is null )
		loop
                        IF (P_tab_of_rec(v_src_point).line_id = P_tab_of_rec(v_src_point).ato_line_id) THEN
                           P_tab_of_rec(v_src_point).plan_level := 0;
			   EXIT;

			END IF;

			v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
			/* store each unresolved item in its heirarchy */

			v_src_point := P_tab_of_rec(v_src_point).link_to_line_id ;

		end loop ;

		v_step := 'Step B2' ;

		j := v_raw_line_id.count ; /* total number of items to be resolved */

		lStmtNum :=40;
		while( j >= 1 )
		loop

			P_tab_of_rec(v_raw_line_id(j)).plan_level := P_tab_of_rec(v_src_point).plan_level + 1;

			v_src_point := v_raw_line_id(j) ;

			j := j -1 ;
		end loop ;

		v_raw_line_id.delete ; /* remove all elements as they have been resolved */

	   END IF; --top model line id check

       end if ;


       lStmtNum :=50;
       i := P_tab_of_rec.next(i) ;  /* added for bug 1728383 for performance */


    end loop ;



    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('--plan level--',5);
	oe_debug_pub.add(' Line_id '||' => '||' plan_level ',5);
	i := P_tab_of_rec.first;
	WHILE i is not null
	LOOP
		oe_debug_pub.add(i||' => '||P_tab_of_rec(i).plan_level,5);
		i := P_tab_of_rec.NEXT(i);
	END LOOP;

     END IF;

EXCEPTION
WHEN others THEN

   IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_plan_level : ' || 'Others Exception in stmt num: '
		|| to_char(lStmtNum), 1);
		oe_debug_pub.add('errmsg'||sqlerrm,5);
    END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );


 end populate_plan_level ;




 PROCEDURE perform_match
 (
   p_ato_line_id  in number,
  -- p_custom_match_profile  in VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count	      OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS

    cursor c_model_lines is
       select line_id, parent_ato_line_id, inventory_item_id
       from   bom_cto_order_lines_gt
       where  bom_item_type = '1'
       and    ato_line_id = p_ato_line_id
       and    nvl(wip_supply_type,0) <> 6
       and    ato_line_id is not null -- could be a PTO
       and    config_item_id is null --becos item could have been re-used
       and    perform_match in ('Y','C')
       order by plan_level desc, inventory_item_id asc;
       /*  bugfix 4227993: added item_id in the order by, so that 2 processes always process the
			   sub-models in the same sequence. This should avoid deadlock issues while
			   acquiring user-locks.
       */


    lStatus          number;
    lXConfigId       number;
    lPerformMatch    varchar2(1);
    l_x_error_msg    varchar2(100);
    l_x_msg_name     varchar2(30);
    l_x_table_name   varchar2(30);
    lStmtNum         number;
    l_lock_status    number;    -- bugfix 4227993
    --
    -- bug 7203643
    -- changed the hash value variable type to varchar2
    -- ntungare
    --
    --l_hash_value     number;    -- bugfix 4227993
    l_hash_value     varchar2(2000);

v_total_count number ;

  BEGIN


	/*IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add('Entered perform_match for =>'|| p_ato_line_id
	                     ||'custm prof=>'||p_custom_match_profile,1);
	END IF;*/
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

        lStmtNum:=10;
        for lNextRec in c_model_lines loop

           lXConfigId := NULL;
           lStmtNum :=20;
           select perform_match
           into   lPerformMatch
           from   bom_cto_order_lines_gt
           where  line_id = lNextRec.line_id;




	   IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add(' perform_match flag =>'||lPerformMatch
	                        ||'for line_id =>'||lNextRec.line_id,5
	                        );
	   END IF;

           if (lPerformMatch = 'U') then

                      lStmtNum:=30;
                      update bom_cto_order_lines_gt
                      set    perform_match = 'U'
                      where  line_id = lNextRec.parent_ato_line_id
                      and    perform_match in ('Y','C');
			-- if the update fails, its not an error

           else

                lStmtNum := 120;
    		--
    		-- Begin Bugfix 4227993
    		-- Acquire user-lock by calling lock_for_match so that the process does not end up
		-- creating new configs if a non-commited match exists.
		-- Incase lock is not acquired, wait indefinitely. We could error out but we decided
    		-- to wait so that user does not have to resubmit the process again.
    		--
                IF( lPerformMatch in (  'Y' , 'C' )) then

                /*FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling cto_utility_pk.lock_for_match: start time: ' ||
                                                to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));*/
                IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Calling cto_utility_pk.lock_for_match: start time: ' || to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'), 1);
                END IF; --Bugfix 6452747

		CTO_UTILITY_PK.lock_for_match(
					x_return_status	=> x_return_status,
        				xMsgCount       => x_msg_count,
        				xMsgData        => x_msg_data,
					x_lock_status	=> l_lock_status,
    		                        x_hash_value	=> l_hash_value,
					p_line_id	=> lNextRec.line_id );

                /*FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calling cto_utility_pk.lock_for_match: end time: ' ||
                                                to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'));*/
                IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add('Calling cto_utility_pk.lock_for_match: end time: ' || to_char(sysdate , 'MM/DD/YYYY HH24:MI:SS'), 1);
                END IF;  --Bugfix 6452747

		if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
   		     oe_debug_pub.add('match_and_create_all_items: '|| 'get_user_lock returned error');
		     raise fnd_api.g_exc_unexpected_error;
		end if;

   		--check for error cases
		if ( l_lock_status  <> 0 ) THEN
      			if (l_lock_status = 1) then -- timeout
   				oe_debug_pub.add('l_lock_status = 1: TIMEOUT ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_TIMEOUT');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 2) then -- deadlock
   				oe_debug_pub.add('l_lock_status = 2: DEADLOCK ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_DEADLOCK');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 3) then -- parameter error
   				oe_debug_pub.add('l_lock_status = 3: PARAMETER ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_PARAM_ERROR');
   				raise fnd_api.g_exc_unexpected_error;

      			elsif (l_lock_status = 4) then -- already locked.
   				oe_debug_pub.add('l_lock_status = 4: ALREADY LOCKED  ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_ALREADY_LOCKED');
   				-- we shall not raise an error if we are already holding the lock.

      			else -- internal error - not fault of user
   				oe_debug_pub.add('l_lock_status = '||l_lock_status||': INTERNAL ERROR ');
      				cto_msg_pub.cto_message('BOM','CTO_LOCK_ERROR');
   				raise fnd_api.g_exc_unexpected_error;
      			end if;
		else
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Successfully obtained lock for match.');
			END IF;

		end if;
                END IF;
    		--
    		-- End Bugfix 4227993
    		--

		IF lPerformMatch  = 'Y' THEN

			lStmtNum:=40;
                	lStatus := CTO_MATCH_CONFIG.check_config_match(
                                        lNextRec.line_id,
                                        lXConfigId,
                                        l_x_error_msg,
                                        l_x_msg_name);



			if lStatus <> 1 then
			    raise fnd_api.g_exc_error;
			end if;
		ELSIF lPerformMatch = 'C' THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('match_and_create_all_items: ' || 'Custom Match.', 1);
			END IF;

			lStmtNum:=50;
                	lStatus := CTO_CUSTOM_MATCH_PK.find_matching_config(
                                          pModelLineId		=> lNextRec.line_id,
                                          xMatchedItemId	=> lXConfigId,
                                          xErrorMessage		=> l_x_error_msg,
                                          xMessageName		=> l_x_msg_name,
                                          xTableName		=> l_x_table_name);


			if lStatus <> 1 then
			    raise fnd_api.g_exc_error;
			end if;

		END IF;

                if (lStatus = 1 and lXConfigId is null) then


                      lStmtNum:=60;
		      update bom_cto_order_lines_gt
                      set    perform_match = 'U'
                      where  line_id = lNextRec.line_id
                      and    perform_match in ('Y','C');
			-- if the update fails, its not an error

        	oe_debug_pub.add('perform_match: ' || 'updated to U : ' || to_char(lNextRec.Line_Id), 1);

        	oe_debug_pub.add('perform_match: ' || 'rowcount  : ' || to_char(sql%rowcount), 1);

		       lStmtNum:=70;
                       update bom_cto_order_lines_gt
                       set    perform_match = 'U'
                       where  line_id = lNextRec.parent_ato_line_id
                       and    perform_match in ( 'Y','C');
			-- if the update fails, its not an error

        	oe_debug_pub.add('perform_match: ' || 'updated to U : ' || to_char(lNextRec.parent_ato_Line_Id), 1);

        	oe_debug_pub.add('perform_match: ' || 'rowcount  : ' || to_char(sql%rowcount), 1);

                elsif (lStatus = 1 and lXConfigId is not null) then


                     lStmtNum:=80;
		     update bom_cto_order_lines_gt
		     set    config_item_id = lXConfigId
                     where  line_id = lNextRec.line_id;

		    --
		    -- begin bugfix 4227993
		    -- Release the lock if match found rather than wait for commit/rollback.
		    --

                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('match_and_create_all_items: ' || 'Match found for line ' ||
                                     to_char(lNextRec.line_id) ||
                                     ' with config item ' ||
                                     to_char(lXConfigId), 1);
                    END IF;

		    CTO_UTILITY_PK.release_lock(
			x_return_status	=> x_return_status,
        		x_Msg_Count     => x_Msg_Count,
        		x_Msg_Data      => x_msg_data,
   			p_hash_value	=> l_hash_value);

		    if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
   		       oe_debug_pub.add('match_and_create_all_items: '|| 'get_user_lock returned error');
		       raise fnd_api.g_exc_unexpected_error;
		    end if;

		    --
		    -- end bugfix 4227993
		    --


                else

                    raise fnd_api.g_exc_error;

                end if; -- end lStatus = 1 and lXConfigID is not null

           end if; -- else perform_match = 'U'

           lStmtNum := 160;


       end loop;




                 /* Fix for bug 3533192 */

                 update bom_cto_order_lines_gt
                    set perform_match = 'Y'
                  where ato_line_id = p_ato_line_id
                    and inventory_item_id in
                           ( select inventory_item_id
                               from bom_cto_order_lines_gt
                              where ato_line_id = p_ato_line_id
                                and bom_item_type = '1'
                                and wip_supply_type <> 6
                                and perform_match = 'U'
                              group by inventory_item_id
                             having count(*) > 1
                           );




        	oe_debug_pub.add('perform_match: ' || 'Updated possible similar models to Y : '
		                 || to_char(sql%rowcount), 1);







EXCEPTION
  WHEN fnd_api.g_exc_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('perform_match: ' || 'Exception in stmt num: '
		                 || to_char(lStmtNum), 1);
      END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('perform_match: ' || ' Unexpected Exception in stmt num: '
		                        || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then

       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('perform_match: ' || 'Others Exception in stmt num: '
		                 || to_char(lStmtNum), 1);
	        oe_debug_pub.add('errmsg'||sqlerrm,1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );


END perform_match;

PROCEDURE flag_reuse_config(
	p_model_line_id IN number,
        x_return_status OUT NOCOPY varchar2

	)
IS

l_model_line_id number;
lStmtNum        number :=10;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;


  g_reuse_tbl(p_model_line_id).reuse_config := 'N';

  g_model_line_tbl(g_model_line_tbl.count+1):= p_model_line_id;

   l_model_line_id := g_reuse_tbl(p_model_line_id).parent_ato_line_id;

    --as this model might have a reuse flag =N
    --becuase of another child model /becuase of its own componenet
    --and also it atkes care of condition where top most ato
    --line is reached
    IF  g_reuse_tbl(l_model_line_id).reuse_config= 'Y' THEN

	   flag_reuse_config(p_model_line_id =>l_model_line_id,
	                     x_return_status =>x_return_status
			     );
	   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE fnd_api.g_exc_unexpected_error;
	   END IF;

    END IF;




EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('flag_reuse_config: ' || ' Unexpected Exception in stmt num: '
		            || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        /*--  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );*/

   WHEN OTHERS then

       IF PG_DEBUG <> 0 THEN

        	oe_debug_pub.add('flag_reuse_config: ' || 'Others Exception in stmt num: '
		              || to_char(lStmtNum), 1);
	        oe_debug_pub.add('error='||sqlerrm,1);

       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




END flag_reuse_config;


  PROCEDURE CTO_REUSE_CONFIGURATION(
		p_ato_line_id	   IN  number default null,
		x_config_change    OUT NOCOPY varchar2,
		x_return_status	   OUT NOCOPY varchar2,
		x_msg_count	   OUT NOCOPY number,
		x_msg_data	   OUT NOCOPY varchar2

		 )
IS

 Type number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;

 l_parent_ato_line_tbl  number_tbl_type;
 l_ato_line_tbl		number_tbl_type;
 l_unprocessed_parents	number_tbl_type;



 i number;
 l_parent_ato_last_index number;
 l_ato_last_index number;

 lStmtNum	  number;

 CURSOR c_single_ato is
 SELECT line_id,
        parent_ato_line_id,
        reuse_config
 FROM bom_cto_order_lines_gt
 --added nvl, bugfix 3530054
 WHERE nvl(wip_supply_type,1) <>6  --non phantom ato models
 AND bom_item_type = '1' --used inverted commas to use index N5
 AND ato_line_id = p_ato_line_id;


 CURSOR c_bulk is
 SELECT line_id,
        parent_ato_line_id,
        reuse_config
 FROM bom_cto_order_lines_gt
 ----added nvl, bugfix 3530054
 WHERE nvl(wip_supply_type,1) <>6  --non phantom
 AND bom_item_type = '1' ;  --'1' for using idx_N5    --ato models

 CURSOR c_gt_intial_pic is
 SELECT
        line_id,
	parent_ato_line_id,
	ato_line_id,
	wip_supply_type,
	bom_item_type,
	qty_per_parent_model,
	reuse_config
 FROM   bom_cto_order_lines_gt
 WHERE  ato_line_id = p_ato_line_id;

 CURSOR c_debug is
 SELECT
        line_id,
	reuse_config,
	config_item_id,
	qty_per_parent_model,
        config_creation,
	ship_from_org_id,
	validation_org
 FROM   bom_cto_order_lines_gt
 WHERE  reuse_config is not null;




--temporary structures use for debug
l_temp_line_id			number_tbl_type;
l_qty_per_parent_model		number_tbl_type;
l_bcol_ato_line_tbl             number_tbl_type;




BEGIN


    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('ENTERED reuse configuration',5);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    lStmtNum:=10;
    IF p_ato_line_id IS NOT NULL THEN


	 IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('reuse for ato line=>'||p_ato_line_id,1);
	 END IF;

	lStmtNum := 20;



	UPDATE bom_cto_order_lines_gt
	SET    reuse_config = 'Y'
	WHERE ato_line_id = p_ato_line_id
	AND   bom_item_type = '1' --'1' uses idx_n5        --identifies non-phantom
	--need a nvl as for top most ato model there is no value
	AND nvl(WIP_SUPPLY_TYPE,1) <> 6;      --model lines

	lStmtNum:=30;
        l_ato_line_tbl(1) := p_ato_line_id;

	--debug select
    IF PG_DEBUG = 5 THEN
	SELECT line_id,
	       qty_per_parent_model
	BULK COLLECT INTO
           l_temp_line_id,
	   l_qty_per_parent_model
	FROM bom_cto_order_lines_gt
	WHERE  ato_line_id = p_ato_line_id;

	oe_debug_pub.add('LINE_ID >>QTY_PER_PARENT_MODEL',5);

	FOR i in l_temp_line_id.first..l_temp_line_id.last LOOP

		oe_debug_pub.add(l_temp_line_id(i)||'>>'||l_qty_per_parent_model(i),5);

	END LOOP;

        oe_debug_pub.add('Picture of bcol_gt before reuse process',5);

        FOR kiran_rec in c_gt_intial_pic
	LOOP
            oe_debug_pub.add('LINE_ID=>'||kiran_rec.line_id,5);
	    oe_debug_pub.add('parent_LINE_ID=>'||kiran_rec.parent_ato_line_id,5);
	    oe_debug_pub.add('ato_LINE_ID=>'||kiran_rec.ato_line_id,5);
	    oe_debug_pub.add('WS=>'||kiran_rec.wip_supply_type,5);
	    oe_debug_pub.add('BIT=>'||kiran_rec.bom_item_type,5);
	    oe_debug_pub.add('QPM=>'||kiran_rec.qty_per_parent_model,5);
	    oe_debug_pub.add('reuse=>'||kiran_rec.reuse_config,5);

	END LOOP;



      END IF;
        --debug end

    ELSE --bulk call


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('reuse configuration BULK call',1);
	END IF;


        lStmtNum := 40;
  	UPDATE bom_cto_order_lines_gt
	SET    reuse_config = 'Y'
	WHERE  bom_item_type = '1' --used idx_n5         --identifies non-phantom
	AND nvl(WIP_SUPPLY_TYPE,1) <> 6;

	--had to use a slect clause
	--returning into cluase doesnot supoort distinct
	lStmtNum:=50;
	SELECT distinct(ato_line_id)
	BULK COLLECT INTO l_ato_line_tbl
	FROM bom_cto_order_lines_gt
	WHERE top_model_line_id is not null;
    END IF;

    l_ato_last_index := l_ato_line_tbl.count;



    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('IF count>1, re-use called for more than 1 order line',5);
	oe_debug_pub.add('l_ato_line_tbl.count=>'||l_ato_line_tbl.count,5);
    END IF;


 IF  l_ato_line_tbl.count > 0 THEN

   BEGIN

      -- rkaza. 12/06/2005. bug 4520992. Fp'ed bug 4493512.
      -- Added hint as per Perf team so that bcolgt drives the query
      SELECT /*+ leading(BCGT) use_nl(BCGT BCOL) */ distinct(bcol.ato_line_id)
      BULK COLLECT INTO l_bcol_ato_line_tbl
      FROM bom_cto_order_lines bcol,
           bom_cto_order_lines_gt bcgt
      WHERE bcgt.line_id = bcol.line_id
      AND   bcol.qty_per_parent_model is null;

   EXCEPTION
    WHEN others then
       null;

   END;

   IF l_bcol_ato_line_tbl.count > 0 THEN

      IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Updating bcol (permanent table) with qty per parent model',5);

      END IF;

      FORALL j IN 1..l_bcol_ato_line_tbl.last
	    UPDATE bom_cto_order_lines child
	    SET    qty_per_parent_model =
	                  --used round to be consistent with can_configuration code
	 	 ( SELECT  ROUND(child.ordered_quantity/parent.ordered_quantity,7)
		   FROM   bom_cto_order_lines parent
		   WHERE  child.parent_ato_line_id= parent.line_id
		  )
	    --to filter out ato item order lines
	    WHERE top_model_line_id is not null
	    AND   ato_line_id = l_bcol_ato_line_tbl(j) ;

    END IF; -- l_bcol_ato_line_tbl.count > 0


     --bugfix 3503764
      --need config_creation as part of fix 3503764
      --in core reuse sql
      UPDATE bom_cto_order_lines_gt bcol_gt
      SET    config_creation =
	                  --used round to be consistent with can_configuration code
			( SELECT  nvl(mtl.config_orgs,1)--3555026
			FROM   mtl_system_items mtl
			WHERE  mtl.inventory_item_id = bcol_gt.inventory_item_id
			AND    mtl.organization_id   = bcol_gt.validation_org--3555026
			)
      --to filter out ato item order lines
      WHERE top_model_line_id is not null
      AND   bom_item_type= '1'
      --nvl as for top most model there wst is not populated
      AND   nvl(wip_supply_type,1) <> 6;


        lStmtNum := 60;
    FORALL i in 1..l_ato_last_index
	UPDATE bom_cto_order_lines_gt bcolt
	SET bcolt.reuse_config = 'N'
	WHERE
	 line_id in (

	             --bugfix start 3503764
		      --if ware house is different then reuse = N
		     (SELECT bcol_gt1.line_id
		      FROM  bom_cto_order_lines_gt bcol_gt1,
		            bom_cto_order_lines bcol
		      WHERE bcol.line_id = l_ato_line_tbl(i)
		      AND   bcol_gt1.config_creation in (1,2)
		      AND   bcol_gt1.ato_line_id = l_ato_line_tbl(i)
		      AND   bcol_gt1.ship_from_org_id <> bcol.ship_from_org_id
		      AND   bcol_gt1.bom_item_type = '1'
		      AND   nvl(bcol_gt1.wip_supply_type,1) <> 6
		      )
		      --end bugfix 3503764

	            UNION
	            ( Select parent_ato_line_id
		    from bom_cto_order_lines_gt bcolt1
		    Where (bcolt1.line_id,
			   bcolt1.qty_per_parent_model,
			   bcolt1.inventory_item_id)
			         not in ( Select line_id,
						qty_per_parent_model,
						inventory_item_id
					 from bom_cto_order_lines
				         where ato_line_id = l_ato_line_tbl(i) )
				    --filters out pure ato item lines
		     AND bcolt1.top_model_line_id is not null
		     AND bcolt1.ato_line_id = l_ato_line_tbl(i)
		    )
		    -- bugfix 3381658 start
		    UNION
		    (Select parent_ato_line_id
		    from bom_cto_order_lines bcol2
		    Where (bcol2.line_id,
			   bcol2.qty_per_parent_model,
			   bcol2.inventory_item_id)
			         not in ( Select bcolgt.line_id,
						 bcolgt.qty_per_parent_model,
						 bcolgt.inventory_item_id
					 from bom_cto_order_lines_gt bcolgt
				         where ato_line_id = l_ato_line_tbl(i) )
				    --filters out pure ato item lines
		     AND bcol2.top_model_line_id is not null
		     AND bcol2.ato_line_id = l_ato_line_tbl(i)
                    )
		    --end  bugfix 3381658
		    )
       RETURNING  parent_ato_line_id BULK COLLECT INTO l_parent_ato_line_tbl;



       lStmtNum:= 70;
       IF l_parent_ato_line_tbl.EXISTS(1) THEN



	    IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('Some UN-reusable parent ato lines have been identified',5);
              FOR p_ato_idx in l_parent_ato_line_tbl.first..l_parent_ato_line_tbl.last
	      LOOP
                oe_debug_pub.add('kiran'||l_parent_ato_line_tbl(p_ato_idx),5);
              END LOOP;
            END IF;




          l_parent_ato_last_index :=  l_parent_ato_line_tbl.LAST;

	  lStmtNum:= 80;
	  IF p_ato_line_id IS NOT NULL THEN
	        lStmtNum:=90;
		FOR bcol_rec in c_single_ato
		Loop

			g_reuse_tbl(bcol_rec.line_id).line_id            := bcol_rec.line_id;
			g_reuse_tbl(bcol_rec.line_id).parent_ato_line_id := bcol_rec.parent_ato_line_id;
			g_reuse_tbl(bcol_rec.line_id).reuse_config       := bcol_rec.reuse_config;

			IF PG_DEBUG <> 0 THEN
                          oe_debug_pub.add('LINE_ID=>'||g_reuse_tbl(bcol_rec.line_id).line_id,5);
			  oe_debug_pub.add('PARENT_ATO_LINE_ID=>'||g_reuse_tbl(bcol_rec.line_id).parent_ato_line_id,5);
			  oe_debug_pub.add('REUSE_CONFIG_from_GT=>'||g_reuse_tbl(bcol_rec.line_id).reuse_config,5);

			END IF;

		End Loop;

	  ELSE --bulk call
	        lStmtNum:=91;
	        FOR bcol_rec in c_bulk
		Loop

			g_reuse_tbl(bcol_rec.line_id).line_id            := bcol_rec.line_id;
			g_reuse_tbl(bcol_rec.line_id).parent_ato_line_id := bcol_rec.parent_ato_line_id;
			g_reuse_tbl(bcol_rec.line_id).reuse_config       := bcol_rec.reuse_config;

		End Loop;



	  END IF;--check for bulk call



	  lStmtNum:= 100;
	  FOR i IN l_parent_ato_line_tbl.FIRST..l_parent_ato_line_tbl.LAST LOOP



	     --previous update might have put reuse_config to N
	     --so following if condition
	     --OR previous element might have updated reuse to N
	    IF g_reuse_tbl(l_parent_ato_line_tbl(i)).reuse_config= 'Y' THEN

                IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('calling flag_reuse_config for model_line_id=>'
		                       ||l_parent_ato_line_tbl(i),5);
	        END IF;

	       	lStmtNum:= 110;
	        flag_reuse_config(p_model_line_id =>l_parent_ato_line_tbl(i),
		                  x_return_status =>x_return_status
			         );
		 IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
		    RAISE fnd_api.g_exc_unexpected_error;
		 END IF;

	     END IF;--re-use = Y
	   END LOOP;

	  lStmtNum:= 120;

	  IF g_model_line_tbl.EXISTS(1) THEN

		IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('updating reuse_flag to N for following model lines =>',5);
	        END IF;

                FOR i IN g_model_line_tbl.FIRST..g_model_line_tbl.LAST LOOP
		  IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add(g_model_line_tbl(i),5);
	          END IF;

		END LOOP;

		FORALL i in g_model_line_tbl.FIRST..g_model_line_tbl.LAST
			UPDATE bom_cto_order_lines_gt
			SET reuse_config = 'N'
			WHERE line_id = g_model_line_tbl(i);
	  END IF;--g_model_line exists

	ELSE


	    -- IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add('All parent ato lines are re-usable',5);--5 level
           --  END IF;
	END IF;	--   l_parent_ato_line_tbl.EXISTS(1)

  lStmtNum:=130;
  IF p_ato_line_id IS NOT NULL THEN

	 --deleted, as the procedure gets called again
	--for another ATO model line during ACC
	g_reuse_tbl.DELETE;
	g_model_line_tbl.DELETE;

	--check if this needs to be a performance query
	lStmtNum := 140;

        --as per perf std ahmed almori
	--If the global temporary table is referenced in a sub-query in a
	--SQL statement which accesses other tables.
	--In such cases, the join order may not be optimal due to the lack
	--of stats on the temp table, hence hints should be used to ensure the optimal join order.

	UPDATE /*+ INDEX (bcolt BOM_CTO_ORDER_LINES_GT_N5) */bom_cto_order_lines_gt bcolt
	SET bcolt.config_item_id =
	      (SELECT bcol.config_item_id
	       FROM bom_cto_order_lines bcol
	       WHERE bcolt.line_id = bcol.line_id
	       )
	 WHERE  bcolt.bom_item_type = '1'--used idx_n5
	 AND   nvl(bcolt.WIP_SUPPLY_TYPE,1) <>6
	 AND   bcolt.reuse_config = 'Y'
	 AND   bcolt.ato_line_id = p_ato_line_id ;
  ELSE --bulk call
        --check if this needs to be a performance query
	lStmtNum:=150;
	--as per perf std ahmed almori
	--If the global temporary table is referenced in a sub-query in a
	--SQL statement which accesses other tables.
	--In such cases, the join order may not be optimal due to the lack
	--of stats on the temp table, hence hints should be used to ensure the optimal join order.

	UPDATE /*+ INDEX (bcolt BOM_CTO_ORDER_LINES_GT_N5) */bom_cto_order_lines_gt bcolt
	SET bcolt.config_item_id =
	      (SELECT bcol.config_item_id
	       FROM bom_cto_order_lines bcol
	       WHERE bcolt.line_id = bcol.line_id
	       )
	 WHERE bcolt.bom_item_type = '1' --used inverted commas, so that index is used
	 AND   nvl(bcolt.WIP_SUPPLY_TYPE,1) <>6
	 AND   bcolt.reuse_config = 'Y';


  END IF;

END IF;--if l_ato_line_tbl.count is > 0)

IF PG_DEBUG = 5 THEN
  Oe_debug_pub.add('LINE_ID--'||'reuse_config--'||
                   'CONFIG_ITEM_ID--' ||'qty_per_parent_model--'
		   ||'CIB--'||'ship_from_org--'||'validation_org');
	FOR debug_rec in c_debug
	LOOP
	    oe_debug_pub.add(debug_rec.line_id||'--'||debug_rec.reuse_config||'--'||
	                     debug_rec.config_item_id||'--'||debug_rec.qty_per_parent_model||'--'||
                             debug_rec.config_creation||'--'||debug_rec.ship_from_org_id||'--'||
                             debug_rec.validation_org
			     ,5);
	END LOOP;
END IF;


EXCEPTION

  WHEN fnd_api.g_exc_error THEN
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('CTO_REUSE_CONFIGURATION: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('CTO_REUSE_CONFIGURATION: ' || ' Unexpected Exception in stmt num: '
		                     || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then


       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('CTO_REUSE_CONFIGURATION: ' || 'Others Exception in stmt num: '
		                     || to_char(lStmtNum), 1);
		oe_debug_pub.add('errmsg =>'||sqlerrm,1);
     END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );



END  CTO_REUSE_CONFIGURATION ;









PROCEDURE prepare_bcol_temp_data(
                p_source           IN VARCHAR2,
		p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
		x_return_status    OUT	NOCOPY	VARCHAR2,
		x_msg_count	   OUT	NOCOPY	NUMBER,
		x_msg_data         OUT	NOCOPY	VARCHAR2
	       )
IS
  l_last_index number;

 l_row_count number;

  l_tab_of_rec   CTO_Configured_Item_GRP.TEMP_TAB_OF_REC_TYPE;
  --l_return_status VARCHAR2(1);
 -- l_msg_count     number;
 -- l_msg_data      varchar2(;
   lStmtNum NUMBER;

BEGIN

	   	x_return_status := FND_API.G_RET_STS_SUCCESS;

                lStmtNum:=10;
        	l_last_index := p_match_rec_of_tab.line_id.count;



                lStmtNum:=20;
		UPDATE bom_cto_order_lines_gt bcol
		SET (bcol.wip_supply_type,
		     bcol.bom_item_type )=
			(SELECT wip_supply_type,
			        bom_item_type
			 FROM bom_inventory_components bic
			 WHERE bcol.component_sequence_id = bic.component_sequence_id
			 )
		where bcol.ato_line_id <>bcol.line_id;


	       oe_debug_pub.add('rowcount after update from bic=>'||sql%rowcount,5);


		--rowcount after insert of bom_item_type and wip_supply_type is l_rowcount;

		--getting bom_item_type and wip_supply_type into cto_match_rec_type
	        lStmtNum:=30;
		SELECT bom_item_type,
			wip_supply_type
		BULK COLLECT INTO
			p_match_rec_of_tab.bom_item_type,
			p_match_rec_of_tab.wip_supply_type
		FROM   bom_cto_order_lines_gt;

		oe_debug_pub.add('rowcount after select for BIT,WST=>'||sql%rowcount,5);

		--rowcount of bom_itemtype,wip_supply_typ after select l_rowcount;
                lStmtNum:=40;
		xfer_tab_to_rec(
			p_match_rec_of_tab,
			l_tab_of_rec,
			x_return_status,
			x_msg_count,
			x_msg_data
                          );

	      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	         oe_debug_pub.add('SUCCESS after xfer_tab_to_rec',5);

		 --add retrun status and error mesages to these
		 lStmtNum:=50;
	 	 populate_parent_ato(
			     P_Source => p_source,
			     P_tab_of_rec => l_tab_of_rec,
			     x_return_status  => x_return_status,
			     x_msg_count	 => x_msg_count,
			     x_msg_data       => x_msg_data );

	      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('status after after xfer_tab_to_rec=>'
		                         || FND_API.G_RET_STS_ERROR,5);
                   RAISE fnd_api.g_exc_error;
	      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           oe_debug_pub.add('status after after xfer_tab_to_rec=>'
		                         || FND_API.G_RET_STS_UNEXP_ERROR,5);
                   RAISE fnd_api.g_exc_unexpected_error;
	      END IF;



      	      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	         oe_debug_pub.add('SUCCESS after populate_parent_ato=>');
                        lStmtNum:=60;
			populate_plan_level( P_tab_of_rec => l_tab_of_rec,
					x_return_status  => x_return_status,
					x_msg_count	 => x_msg_count,
					x_msg_data       => x_msg_data );
	      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('status after after populate_parent_ato=>'
		                         || FND_API.G_RET_STS_ERROR);
                   RAISE fnd_api.g_exc_error;
	      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           oe_debug_pub.add('status after after populate_parent_ato=>'
		                         || FND_API.G_RET_STS_UNEXP_ERROR );
                   RAISE fnd_api.g_exc_unexpected_error;
	      END IF;



	     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	         oe_debug_pub.add('SUCCESS after populate_plan_level=>');

              	lStmtNum:=70;
		xfer_rec_to_tab(
			p_tab_of_rec => l_tab_of_rec ,
			p_match_rec_of_tab => p_match_rec_of_tab,
			x_return_status  => x_return_status,
			x_msg_count	 => x_msg_count,
			x_msg_data       => x_msg_data
                                );

	     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('status after after populate_plan_level=>'
		                         || FND_API.G_RET_STS_ERROR);
                   RAISE fnd_api.g_exc_error;
	     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           oe_debug_pub.add('status after after populate_plan_level=>'
		                         || FND_API.G_RET_STS_UNEXP_ERROR );
                   RAISE fnd_api.g_exc_unexpected_error;
	     END IF;


	     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	         oe_debug_pub.add('SUCCESS after xfer_rec_to_tabl=>');

                lStmtNum:=80;
		--update the remaining columns into bcol_temp

		FORALL i IN 1..l_last_index
			UPDATE bom_cto_order_lines_gt
			SET        PARENT_ATO_LINE_ID      = p_match_rec_of_tab.PARENT_ATO_LINE_ID(i),
				   GOP_PARENT_ATO_LINE_ID  = p_match_rec_of_tab.GOP_PARENT_ATO_LINE_ID(i),
				   PLAN_LEVEL              = p_match_rec_of_tab.PLAN_LEVEL (i)
			WHERE  line_id = p_match_rec_of_tab.LINE_ID(i);

	     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	           oe_debug_pub.add('status after after xfer_rec_to_tab=>'
		                         || FND_API.G_RET_STS_ERROR);
                   RAISE fnd_api.g_exc_error;
	     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	           oe_debug_pub.add('status after after xfer_rec_to_tab=>'
		                         || FND_API.G_RET_STS_UNEXP_ERROR );
                   RAISE fnd_api.g_exc_unexpected_error;
	     END IF;


EXCEPTION
    WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add(' prepare_bcol_temp_data: ' || 'Exception in stmt num: '
		                   || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add(' prepare_bcol_temp_data: ' || ' Unexpected Exception in stmt num: '
		                     || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
        oe_debug_pub.add('errmsg'||sqlerrm);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add(' prepare_bcol_temp_data: ' || 'Others Exception in stmt num: ' ||
		                    to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );



END prepare_bcol_temp_data;

/*----------------------
Checks if Ato model is present
in the data

------------------------*/
PROCEDURE Insert_into_bcol_gt(
                p_match_rec_of_tab IN OUT NOCOPY CTO_Configured_Item_GRP.CTO_MATCH_REC_TYPE,
		x_return_status    OUT	NOCOPY	VARCHAR2,
		x_msg_count	   OUT	NOCOPY	NUMBER,
		x_msg_data         OUT	NOCOPY	VARCHAR2
	       )
IS

l_last_index number;
lStmtNum     number;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      lStmtNum:=10;
      l_last_index := p_match_rec_of_tab.line_id.count;
      IF PG_DEBUG <> 0 THEN

	oe_debug_pub.add('Last index ='||l_last_index,3);
	oe_debug_pub.add('first index ='||p_match_rec_of_tab.line_id.first,3);
      END IF;

      -- rkaza. 11/30/2005. bug 4712706. This procedure is called during match
      -- and reserve flow. Each transaction processes a bunch of top ato models
      -- for match that are present in the pl/sql table. Here we insert these
      -- ato models and their components into bcol gt from pl/sql table. The
      -- rows remain within a session. So the next transaction still sees the
      -- old rows and this is causing the bug down the line. In CTOGCFGB ->
      -- match_configured_item procedure, we do a bulk collect finally from
      -- bcolgt into the pl/sql table. But since bcol gt has more rows than
      -- the pl/sql table, incorrect configs are matched to models.
      -- So executing a complete delete here from bcol gt.

      delete from bom_cto_order_lines_gt;

      IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add('insert into bcol_gt',5);
      END IF;


      lStmtNum:=20;
      FORALL i in 1..l_last_index
         INSERT INTO bom_cto_order_lines_gt
	      (
	      ATO_LINE_ID,
	      BOM_ITEM_TYPE,
	      COMPONENT_CODE,
	      COMPONENT_SEQUENCE_ID,
	      INVENTORY_ITEM_ID,
	      LINE_ID,
	      LINK_TO_LINE_ID,
	      ORDERED_QUANTITY,
	      ORDER_QUANTITY_UOM,
	      PARENT_ATO_LINE_ID,
	      PLAN_LEVEL,
	      TOP_MODEL_LINE_ID,
	      WIP_SUPPLY_TYPE,
	      SHIP_FROM_ORG_ID,
	      VALIDATION_ORG --3503764
	      )
	 VALUES
	      (
	       p_match_rec_of_tab.ato_line_id(i),
		--added -1 to be consistent  with CTOGOPIB insert
		-- -1 is used in where cluase in downstream procedure
		-- prepare_bcol_temp
	       nvl(p_match_rec_of_tab.bom_item_type(i),-1),
	       p_match_rec_of_tab.component_code(i),
	       p_match_rec_of_tab.component_sequence_id(i),
	       p_match_rec_of_tab.inventory_item_id(i),
	       p_match_rec_of_tab.line_id(i),
	       p_match_rec_of_tab.link_to_line_id(i),
	       p_match_rec_of_tab.ordered_quantity(i),
	       p_match_rec_of_tab.order_quantity_uom(i),
	       p_match_rec_of_tab.parent_ato_line_id(i),
	       p_match_rec_of_tab.plan_level(i),
	       p_match_rec_of_tab.top_model_line_id(i),
	         --added -1 to be consistent  with CTOGOPIB insert
		 -- -1 is used in where cluase in downstream procedure
		 -- prepare_bcol_temp
	       nvl(p_match_rec_of_tab.wip_supply_type(i),-1),
	       nvl(p_match_rec_of_tab.ship_from_org_id(i),-99),--3555026

	       p_match_rec_of_tab.validation_org(i)--3503764
	      );


	IF PG_DEBUG <> 0 THEN
	 oe_debug_pub.add('Sql%row count ='||sql%rowcount,5);
	END IF;



EXCEPTION
   WHEN fnd_api.g_exc_error THEN
     IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Insert_into_bcol_gt: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
      END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
      IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Insert_into_bcol_gt: ' || ' Unexpected Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
	oe_debug_pub.add('errmsg'||sqlerrm);
        IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('error='||sqlerrm);
        	oe_debug_pub.add('Insert_into_bcol_gt: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
    END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );





END   Insert_into_bcol_gt;


-- This procedure will get the Match_attribute from mtl_system_items_b
-- Will process those flags.
--Eg:
-- Model levels	  Match_ttribute	perform_match
--                (from Item form)      (calculated)
-- M1                 Y                  N
--  ---M2             N                  N
--      ----M3        Y                  Y
-- If match flag is not passed it will be treated as 'Y'
--only non-phantom models need to be passed

PROCEDURE Evaluate_N_Pop_Match_Flag
(
  p_match_flag_tab        IN	     MATCH_FLAG_TBL_TYPE,
  x_sparse_tab            OUT  NOCOPY MATCH_FLAG_TBL_TYPE,
  x_return_status	  OUT  NOCOPY     VARCHAR2,
  x_msg_count		  OUT  NOCOPY     NUMBER,
  x_msg_data		  OUT  NOCOPY     VARCHAR2

)
IS

l_count number;
lStmtNum number;


 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;

i number;
j number;
k number;
l_sparse_index   number;
v_src_point	 number;
v_prev_src_point number;
l_custom_match_profile  varchar2(10);

l_profile_value   VARCHAR2(1) := 'Y'; --standard match as this API is
                                     --called when BOM: Match to Existing Configuration
				     --is YEs


BEGIN
       IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Evaluate_N_Pop_Match_Flag:'||'BEGIN Evaluate_N_Pop_Match_Flag',5);
       END IF;

        lStmtNum := 9;
	l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Evaluate_N_Pop_Match_Flag:'||'custome matc value=>'||l_custom_match_profile,5);
        END IF;

        --if custom match is also YES then
	--we should use 'C' instead of 'Y'
	IF l_custom_match_profile = 1 THEN

	   IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Evaluate_N_Pop_Match_Flag:'||'setting l_profile vale to C',5);
           END IF;
           l_profile_value := 'C';

	END IF;

        lStmtNum := 10;

        l_count := p_match_flag_tab.count;

        oe_debug_pub.add('Evaluate_N_Pop_Match_Flag:'||'Converting into sparse record structure indexed by line_id',5);

        lStmtNum := 20;
	i := p_match_flag_tab.first ;

	lStmtNum := 30;
	WHILE i is not null --sparse while
	LOOP
	  l_sparse_index := p_match_flag_tab(i).line_id;

	  x_sparse_tab(l_sparse_index).line_id		  := p_match_flag_tab(i).line_id;
          x_sparse_tab(l_sparse_index).parent_ato_line_id := p_match_flag_tab(i).parent_ato_line_id;
	  x_sparse_tab(l_sparse_index).ato_line_id	  := p_match_flag_tab(i).ato_line_id;

	  oe_debug_pub.add('Evaluate_N_Pop_Match_Flag:'||'original amtch flag=>'|| p_match_flag_tab(i).match_flag);

          x_sparse_tab(l_sparse_index).match_flag         := nvl(p_match_flag_tab(i).match_flag,l_profile_value);

          i := p_match_flag_tab.next(i);
	END LOOP; --end of sparse while loop

	--evaluating match flag
	lStmtNum := 40;
        j := x_sparse_tab.first;

	lStmtNum := 50;
	WHILE j is not null --while loop B
        LOOP
 	   IF( x_sparse_tab.exists(j)) THEN
	     v_src_point := j ;

	     IF x_sparse_tab(v_src_point).ato_line_id <> v_src_point THEN --check for ato model line
	       IF x_sparse_tab(v_src_point).match_flag = 'N' THEN --check match =N

		lStmtNum := 60;
		WHILE(x_sparse_tab.exists(v_src_point) ) --while loop  C
		LOOP

		      IF x_sparse_tab(x_sparse_tab(v_src_point).parent_ato_line_id).match_flag
		            = 'Y' THEN --check match =Y

			 v_prev_src_point := v_src_point ;
                         v_src_point := x_sparse_tab(v_src_point).parent_ato_line_id;
			 v_raw_line_id(v_raw_line_id.count + 1) := v_src_point  ;

			 IF x_sparse_tab(v_src_point).ato_line_id = v_src_point THEN
                           exit;
			 END IF;
	              ELSE
                         exit;

		      END IF;--check match = Y


                END LOOP;--while loop C

                lStmtNum := 70;
	        k := v_raw_line_id.count ; /* total number of items to be resolved */


                lStmtNum := 80;
		WHILE( k >= 1 ) --while loop D
		LOOP
			x_sparse_tab(v_raw_line_id(k)).match_flag := 'N' ;
			k := k -1 ;

		END LOOP ;--while loop D

		v_raw_line_id.delete ; /* remove all elements as they have been resolved */

               END IF; --check match =N

	      END IF;--check for ato model line

            END IF;

            lStmtNum := 90;
            j := x_sparse_tab.next(j) ;  /* added for bug 1728383 for performance */


          END  LOOP ;--while loop B


	  --debug statement
       IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('LINE_ID  =>'||' MATCH_FLAG');

              lStmtNum := 100;
	      j := x_sparse_tab.first;

	      lStmtNum := 110;
              WHILE j is not null --while loop C
              LOOP

	        oe_debug_pub.add(x_sparse_tab(j).line_id ||' => '||x_sparse_tab(j).match_flag, 5);

                j := x_sparse_tab.next(j) ;
	      END LOOP;
       END IF;--PG_DEBUG





EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Evaluate_N_Pop_Match_Flag: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Evaluate_N_Pop_Match_Flag: ' || ' Unexpected Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
	oe_debug_pub.add('errmsg'||sqlerrm);
       IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('error='||sqlerrm);
        	oe_debug_pub.add('Evaluate_N_Pop_Match_Flag: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
END Evaluate_N_Pop_Match_Flag;



--This will transfer sparse record to record of tables
PROCEDURE xfer_match_flag_to_rec_of_tab
(

  p_sparse_tab            IN	      MATCH_FLAG_TBL_TYPE,
  x_match_flag_rec        OUT  NOCOPY      Match_flag_rec_of_tab,
  x_return_status	  OUT  NOCOPY     VARCHAR2,
  x_msg_count		  OUT  NOCOPY	     NUMBER,
  x_msg_data		  OUT  NOCOPY	     VARCHAR2

)
IS
 i binary_integer := 1;
 j number;
 lStmtNum number;


BEGIN

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('BEGIN xfer_match_flag_to_rec_of_tab: ', 5);
        END IF;

    lStmtNum :=10;
    j:= p_sparse_tab.first;

    lStmtNum :=20;
    WHILE(j is not null)
    LOOP
       x_match_flag_rec.line_id(i) := p_sparse_tab(j).line_id;
       x_match_flag_rec.match_flag(i) := p_sparse_tab(j).match_flag;

       i := i+1;
       j := p_sparse_tab.next(j);

    END LOOP;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_match_flag_to_rec_of_tab: ' || 'Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('xfer_match_flag_to_rec_of_tab: ' || ' Unexpected Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then
	oe_debug_pub.add('errmsg'||sqlerrm);
      IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('error='||sqlerrm);
        	oe_debug_pub.add('xfer_match_flag_to_rec_of_tab: ' || 'Others Exception in stmt num: '
		                    || to_char(lStmtNum), 1);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );

END xfer_match_flag_to_rec_of_tab;


PROCEDURE Update_BCOLGT_with_match_flag
(
  x_return_status	  OUT	NOCOPY     VARCHAR2,
  x_msg_count		  OUT	NOCOPY     NUMBER,
  x_msg_data		  OUT	NOCOPY    VARCHAR2

)
IS


l_match_flag_tab	 CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE;
x_sparse_match_tab       CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE;
l_match_flag_rec_of_tab  CTO_MATCH_CONFIG.Match_flag_rec_of_tab;

lStmtNum number;
i        number;
j        number;

CURSOR c_models_match_flag
 IS
    SELECT line_id,
           parent_ato_line_id,
	   ato_line_id,
	   perform_match
    FROM   bom_cto_order_lines_gt
    WHERE  bom_item_type = '1' -- put in inverted commas to use hint
    AND    nvl(wip_supply_type,1)<> 6;




BEGIN

      IF PG_DEBUG <> 0 THEN
	 oe_debug_pub.add('ENTERED Update_BCOLGT_with_match_flag', 5);
      END IF;

      --added for re-arch
      --get match flag for all non-pahtom ato models
      lStmtNum :=10;

      --as per perf std ahmed almori
      --If the global temporary table is referenced in a sub-query in a
      --SQL statement which accesses other tables.
      --In such cases, the join order may not be optimal due to the lack
      --of stats on the temp table, hence hints should be used to ensure the optimal join order.

      UPDATE /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N5) */ bom_cto_order_lines_gt bcol
      SET bcol.perform_match=
			(SELECT config_match
			 FROM mtl_system_items_b mtl
			 WHERE mtl.inventory_item_id = bcol.inventory_item_id

			 AND   mtl.organization_id   = bcol.validation_org --reuse_revert
			                                                   --3555026

			)
      WHERE bcol.bom_item_type    = '1'-- used inverted commas to use index
      AND   nvl(bcol.wip_supply_type,1) <> 6;

      IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('Update_BCOLGT_with_match_flag:'||'Sql%row count ='||sql%rowcount,3);
      END IF;


      --prepare a record structure for input paremeter to
      --procedure evaluate_n_pop_match
      j := 1;

      lStmtNum := 20;
      FOR models_match_rec in c_models_match_flag
      LOOP
         l_match_flag_tab(j).line_id	        :=  models_match_rec.line_id;
	 l_match_flag_tab(j).parent_ato_line_id :=  models_match_rec.parent_ato_line_id;
	 l_match_flag_tab(j).ato_line_id	:=  models_match_rec.ato_line_id;
	 l_match_flag_tab(j).match_flag         :=  models_match_rec.perform_match;

	 j := j+1 ;
      END LOOP;

      --call evaluate_n_pop_match_flag proceure
      -- to process the match flag
      lStmtNum := 30;
      Evaluate_N_Pop_Match_Flag
      (
	 p_match_flag_tab => l_match_flag_tab,
	 x_sparse_tab     => x_sparse_match_tab,
	 x_return_status  => x_return_status,
	 x_msg_count	  => X_msg_count,
	 x_msg_data       => X_msg_data

       );


       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		   --level1
	--  IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Update_BCOLGT_with_match_flag:'||
			                    'success after Evaluate_N_Pop_Match_Flag', 1);
	--  END IF;

       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	         RAISE fnd_api.g_exc_error;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	         RAISE fnd_api.g_exc_unexpected_error;
       END IF;

     lStmtNum := 40;
     CTO_MATCH_CONFIG.xfer_match_flag_to_rec_of_tab
     (
	p_sparse_tab      => x_sparse_match_tab,
	x_match_flag_rec  => l_match_flag_rec_of_tab,
	x_return_status   => x_return_status,
	x_msg_count	  => X_msg_count,
	x_msg_data        => X_msg_data
     );


     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		   --level1
	  IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Update_BCOLGT_with_match_flag:'||'success after xfer_match_flag_to_rec_of_tab', 1);
	  END IF;

     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	         RAISE fnd_api.g_exc_error;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     lStmtNum := 50;
     FORALL i IN 1..l_match_flag_rec_of_tab.line_id.count
	UPDATE bom_cto_order_lines_gt
	SET perform_match = l_match_flag_rec_of_tab.match_flag(i)
	WHERE line_id = l_match_flag_rec_of_tab.line_id (i);


     IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('Update_BCOLGT_with_match_flag:'||'Sql%row count ='||sql%rowcount,3);
     END IF;

EXCEPTION
     WHEN fnd_api.g_exc_error THEN
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Update_BCOLGT_with_match_flag ' || 'Exception in stmt num: '
		                       || to_char(lStmtNum), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN fnd_api.g_exc_unexpected_error THEN
       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Update_BCOLGT_with_match_flag ' || ' Unexpected Exception in stmt num: '
		                   || to_char(lStmtNum), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
   WHEN OTHERS then

        IF PG_DEBUG <> 0 THEN

        	oe_debug_pub.add('Update_BCOLGT_with_match_flag' || 'Others Exception in stmt num: '
		              || to_char(lStmtNum), 1);
	         oe_debug_pub.add('error '||sqlerrm,1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );

END;



end CTO_MATCH_CONFIG;

/
