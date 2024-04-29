--------------------------------------------------------
--  DDL for Package Body CTO_OSS_SOURCE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_OSS_SOURCE_PK" AS
/*$Header: CTOOSSPB.pls 120.3.12010000.9 2011/12/28 10:58:28 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOOSSPB.pls                                                  |
| DESCRIPTION:                                                                |
|               Contains code for Option spefic sourcing processing. This     |
|               Pkg. contains two main functional code areas. One is called   |
|               During ATP to get the OSS orgs list. The other is called      |
|               during Auto create config process.                            |
|               Requisitions.						      |
|               This Package creates the following                            |
|               Procedures                                                    |
|               1. AUTO_CREATE_PUR_REQ_CR                                     |
|               2. POPULATE_REQ_INTERFACE                                     |
|               Functions                                                     |
|               1. GET_RESERVED_QTY                                           |
|               2. GET_NEW_ORDER_QTY                                          |
| HISTORY     :                                                               |
| 25-Aug-2003 : Renga Kannan          Initial version                         |
| 02-Oct-2003 : Renga Kannan          Modified all the code with the          |
|                                     New re-design                           |
| 14-Nov-2003 : Renga Kannan          Fixed all the bugs that are identified  |
|                                     during all the demos.                   |
| 02-MAR-2004 : Sushant Sawant        Fixed Bug 3472654 queries against       |
|                                      bcol_gt should be limited by           |
|				      ato_line_id as same config item         |
|				      could exist on multiple orders.         |
| 09-16-2004    Kiran Konada          bugfix3894241
|                                     used to_number( ) fn on NULL , for
|                                     8i compatability
|
| 09-22-2004    Kiran Konada          bugfix3891572
|                                     10G compatbility issue
|                                     always need to initialize nested table
| 12-02-2004    Renga Kannan          Bug Fix 3896824. added Special validation
|                                     for pre configuration case
| 18-APR-2005   Renga Kannan          Bug Fix 4112373.
|                                     Fixed 100% Sourcing rule creation in
|                                     prune_parent_oss procedure. 100% make at
|                                     rules were not getting created when the model
|                                     has a buy sourcing rule. Nvl caluse was missing
|                                     in the subquery. The bug is fixed.
|
| 26-Apr-2005   Renga Kannan          Fixed bug 4093235
|                                     OSS processing for multi level model with lower level
|                                     matched CIB 3 maodel was giving 'Invalid ship from org'
|                                     message all the time. This is due to code issues
|                                     in prune_parent_oss_config and get_order_sourcing_data
|                                     procedure. Fixed the issue.
|
=============================================================================*/

g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_OSS_SOURCE_PK';


/* This is the Package constant that is used to have indented debug logging */
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);


/* Forward declartion for the procedure.
   This procedure is used during ATP call. This will get the organization
   and vendors from the sourcing rule for OSS ato item.
*/

Procedure get_ato_item_orgs(
                            p_assignment_id  IN  Number,
                            x_return_status  OUT NOCOPY varchar2,
                            x_msg_count      OUT NOCOPY Number,
                            x_msg_data       OUT NOCOPY Varchar2
                           );

/*
   Forward declartion for the procedure.
   This procedure is used during ATP call. This will get the OSS orgs and
   Vendors by processing the configuration for OSS.
*/

Procedure get_configurations_org(
                                 x_return_status  OUT NOCOPY Varchar2,
                                 x_msg_count      OUT NOCOPY Number,
                                 x_msg_data       OUT NOCOPY Varchar2
                                );

/*
   Forward declartion for the procedure.
   This procedure is used during Parent OSS pruning.
   This will get called in the core OSS processing logic.
   This will identify all the parent models for a oss configuration.
*/

Procedure update_parent_oss_line(p_parent_ato_line_id  In  Number,
                                 x_return_status       OUT NOCOPY Varchar2,
				 x_msg_count           OUT NOCOPY Number,
				 x_msg_data            OUT NOCOPY Varchar2
                                );


/*

  Forward declartion for the procedure.
  This is the core API to prune the sourcing rules for the OSS configuration.
  This API will get called during ATP as well as Auto Create config.
  This API will identify all the sourcing rules and prune them according
  to the oss orgs/vendors list provided.

*/

Procedure prune_oss_config(
                           p_model_line_id  IN  Number,
                           p_model_item_id  IN  Number,
			   p_config_item_id IN  Number,
			   p_calling_mode   IN  Varchar2,
                           p_ato_line_id    IN  Number,
			   x_exp_error_code OUT NOCOPY Number,
                           x_return_status  OUT NOCOPY Varchar2,
               	           x_msg_count      OUT NOCOPY Number,
              		   x_msg_data       OUT NOCOPY Varchar2
			  );

/*

  Forward declartion for the procedure.
  This is the core API to prune the Parent of OSS configuration.
  This API will get called during ATP as well as Auto Create config process.
  This API will get the valid orgs by looking at all the OSS child
  and purne the sourcing tree accordingly.

*/

Procedure prune_parent_oss_config(
                                  p_model_line_id  IN  Number,
				  p_model_item_id  IN  Number,
				  p_calling_mode   IN  Varchar2,
                                  p_ato_line_id    IN  Number,
				  x_exp_error_code OUT NOCOPY Number,
	                          x_return_status  OUT NOCOPY Varchar2,
   		                  x_msg_count      OUT NOCOPY Number,
			          x_msg_data       OUT NOCOPY Varchar2
				 );

/*

  Forward declartion for the procedure.
  This API is used during Parent OSS pruning process.
  This is more of a utility API to traverse the source
  tree and update the valid nodes.

*/



Procedure  update_Source_tree(p_line_id       IN Number,
                              p_end_org       IN  Number,
                              x_return_status OUT NOCOPY Varchar2,
                              x_msg_data      OUT NOCOPY varchar2,
                              x_msg_count     OUT NOCOPY Number
                             );

Procedure prune_item_level_rule(p_model_line_id   IN  Number,
                                p_model_item_id   IN  Number,
				x_rule_exists     OUT NOCOPY Varchar2,
				x_return_status   OUT NOCOPY Varchar2,
				x_msg_count       OUT NOCOPY Number,
				x_msg_data        OUT NOCOPY varchar2
			       );

Procedure Find_leaf_node( p_model_line_id   IN  Number,
                          p_source_org_id   IN  Number,
			  p_rcv_org_id      IN  Number,
			  x_return_status   OUT NOCOPY Varchar2,
			  x_msg_data        OUT NOCOPY Varchar2,
			  x_msg_count       OUT NOCOPY Number);


Procedure    Traverse_up_tree(p_model_line_id  IN  Number,
                              p_source_org_id  IN  Number,
		              p_valid_flag     IN  Varchar2,
		              x_return_status  OUT NOCOPY Varchar2,
		              x_msg_count      OUT NOCOPY Varchar2,
		              x_msg_data       OUT NOCOPY Number);





TYPE Number1_arr is TABLE of Number;
TYPE Varchar1_arr is TABLE of Varchar2(1);

TYPE assg_rec is RECORD (assignment_id   Number1_arr := Number1_arr(),
                         line_id         Number1_arr := Number1_arr()
			 );



TYPE parent_ato_rec_type is RECORD  (
		                      line_id	       Number1_arr := number1_arr(),--bugfix3891572
			   	      option_specific  varchar1_arr := varchar1_arr()--bugfix3891572
			            );

TYPE bcol_rec_type is RECORD  (
                               line_id              Number,
		               parent_ato_line_id   Number,
         	   	       ato_line_id          Number,
              		       option_specific      Varchar2(1),
			       perform_match        Varchar2(1)
		              );

--Bugfix 9148706: Indexing by LONG
--TYPE bcol_tbl_type is TABLE OF bcol_rec_type INDEX BY Binary_integer;
TYPE bcol_tbl_type is TABLE OF bcol_rec_type INDEX BY LONG;


Procedure get_sourcing_data(
                            p_ato_line_id     IN  Number,
			    x_return_status   OUT NOCOPY Varchar2,
			    x_msg_data        OUT NOCOPY Varchar2,
			    x_msg_count       OUT NOCOPY Number);

Procedure Process_order_for_oss (P_ato_line_id    IN  Number,
                                 p_calling_mode   IN  Varchar2,
                                 x_return_status  OUT NOCOPY Varchar2,
				 x_msg_data       OUT NOCOPY Varchar2,
				 x_msg_count      OUT NOCOPY Number);

Procedure COPY_TO_BCOL_TEMP(
                            p_ato_line_id   IN  Number,
			    x_return_status OUT NOCOPY Varchar2,
			    x_msg_data      OUT NOCOPY Varchar2,
			    x_msg_count     OUT NOCOPY Number);
Procedure Traverse_sourcing_chain(
                                p_item_id         IN    Number,
                                p_org_id          IN    Number,
                                p_line_id         IN    Number,
                                p_option_specific IN    Varchar,
                                p_ato_line_id     IN    Number, /* Renga Kannan
*/
                                x_assg_list       IN OUT NOCOPY assg_rec,
                                x_return_status   OUT  NOCOPY  Varchar2,
                                x_msg_data        OUT  NOCOPY  Varchar2,
                                x_msg_count       OUT  NOCOPY  Varchar2);


 Procedure Get_order_sourcing_data(
                                p_ato_line_id   IN   Number,
                                x_return_status OUT NOCOPY  Varchar2,
                                x_msg_count     OUT NOCOPY  Number,
                                x_msg_data      OUT NOCOPY  Varchar2);

 -- bug 13362916
 /*
 Procedure Print_source_gt(
                           p_line_id   IN Number);

 Procedure Print_orglist_gt(p_line_id  IN Number);
 */

Procedure Print_source_gt;
Procedure Print_orglist_gt;

TYPE g_assg_list_type is TABLE of Number index by binary_integer;

g_assg_list             g_assg_list_type;
G_bcol_tbl		bcol_tbl_type;
G_parent_rec            parent_ato_rec_type;
G_tbl_index		Number :=1;
G_def_assg_set          Number;

g_pg_level              Number;


--
-- Declaring a Stack data structure to catch circular sourcing
--

Type source_org_stk is Table of number index by Binary_integer;

G_Source_org_stk    Source_org_stk;

--Bugfix 8894392
procedure del_from_msa (p_config_id in number)
is
     pragma autonomous_transaction;
begin

     delete from mrp_sr_assignments
     where assignment_set_id = G_def_assg_set
     and inventory_item_id = p_config_id;

     If PG_DEBUG <> 0 Then
        oe_debug_pub.add('DEL_FROM_MSA: Rows deleted =' || sql%rowcount,5);
     End if;

     commit;
end del_from_msa;
--Bugfix 8894392

/*

  This is procedure is called during Auto Create Config item Process. This will process
  all oss configurations and give the list of orgs where bom should be created.

*/


Procedure Process_Oss_configurations(
                 p_ato_line_id   IN           Number,
                 p_mode          IN           Varchar2 DEFAULT 'ACC',
                 x_return_status OUT   NOCOPY Varchar2,
                 x_msg_count     OUT   NOCOPY Number,
                 x_msg_data      OUT   NOCOPY Varchar) is



   l_perform_match		bom_cto_order_lines.perform_match%type;
   l_reuse_config               bom_cto_order_lines.reuse_config%type;
   l_oss_defined                Varchar2(1);
   i				Number;
   x_exp_error_code             Number;
   l_stmt_num                   Number;
   l_config_creation            Varchar2(1);
   x_oss_exists                 Varchar2(1);
   l_valid_ship_from_org        Varchar2(1);
   l_option_specific            varchar2(1);

   /* This will get all the valid leaf nodes in the pruned tree to construct the
      out variable.
   */


  l_count			number;

  -- Added by Renga Kannan on 11/30/04 for bug 3896824
  -- Added the following variable declaration

  l_ship_from_org_id		oe_order_lines.ship_from_org_id%type;
  l_program_id                  bom_cto_order_lines.program_id%type;
  l_valid_preconfig_org         varchar2(1);

  -- End of change for bug 3896824 on 11/30/04

BEGIN


   oe_debug_pub.add('=========================================================================',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('             START OPTION SPECIFIC SOURCE PROCESSING                     ',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('             START TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('=========================================================================',1);

   g_pg_level := 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_Stmt_num := 10;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGIRATIONS: Insise PROCESS_OSS_CONFIGURATION API',5);
   End if;

   /* Get the default assignment set into a global variable.
      The global variable will be used in all other modules later
   */

   l_stmt_num := 20;
   G_def_assg_set := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

   IF PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Default Assignment set = '
                                            ||to_char(g_def_assg_set),5);
   End if;


   /* If the default assignment set is null, then nothing to process. We will return
   */

   If g_def_assg_set is null Then
      IF PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Default assignment set is null',5);
         oe_debug_pub.add('=========================================================================',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('=========================================================================',1);
      End if;
      return;
   End if;


   /* Check to see if there is any option specific sourcing is defined in setup.
      If option specific sourcing is not defined, nothing to be done
   */
   l_stmt_num := 30;
   Begin
      select 'Y'
      into   l_oss_defined
      from   dual
      where  exists (select 'x'
                    from   bom_cto_oss_components);
   Exception when no_data_found then
      l_oss_defined := 'N';
   end;

   If l_oss_defined = 'N' Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: No Option Specific Soucing setup exists in the system',5);
      return;
   End if;

   /* Check to see if the whole configuration is matched or not.
      If the whole config is matched/Re-used, OSS processing is not
      required to do anything for that configuration.
   */

   /* Impact: Check to see if the item_bom_creation attribute is set to '3'.
              only if the attribute is set to 3, we should not do anything.
	      In case, if the attribute is set to */


   l_stmt_num := 35;
   If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIOS: CAlling mode = '||p_mode,5);
   end if;

   If p_mode = 'UPG' then
      copy_to_bcol_temp(
                     p_ato_line_id    => p_ato_line_id,
                     x_return_status  => x_return_status,
                     x_msg_data       => x_msg_data,
                     x_msg_count      => x_msg_count);
   End if;

   l_stmt_num := 40;

   /* Changed the bom_cto_order_lines reference to bom_cto_order_lines_gt */

   -- Modified by Renga Kannan on 11/30/04 for bug 3896824
   -- fetched two other columns ship_from_org_id and program_id into the variables
   -- l_ship_from_org_id and l_program_id

   Select
          nvl(perform_match,'N'),
          nvl(reuse_config,'N'),
          config_creation,
	  ship_from_org_id,
	  program_id
   into   l_perform_match,
          l_reuse_config,
	  l_config_creation,
	  l_ship_from_org_id,
	  l_program_id
   from   bom_cto_order_lines_gt bcol
   where  line_id = p_ato_line_id;

   -- End of change for bug 3896824 on 11/30/04

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add(lpad(' ',g_pg_level)|| 'PROCESS_OSS_CONFIGURATIONS: l_perform_match:'   || l_perform_match,3);
      oe_debug_pub.add(lpad(' ',g_pg_level)|| 'PROCESS_OSS_CONFIGURATIONS: l_reuse_config:'    || l_reuse_config,3);
      oe_debug_pub.add(lpad(' ',g_pg_level)|| 'PROCESS_OSS_CONFIGURATIONS: l_config_creation:' || l_config_creation,3);
      oe_debug_pub.add(lpad(' ',g_pg_level)|| 'PROCESS_OSS_CONFIGURATIONS: l_ship_from_org_id:'|| l_ship_from_org_id,3);
      oe_debug_pub.add(lpad(' ',g_pg_level)|| 'PROCESS_OSS_CONFIGURATIONS: l_program_id:'      || l_program_id,3);
   END IF;

   if p_mode = 'ACC' then
   -- Added this if as part of Bugfix 8894392. Because of this bypass, table bcos_gt is not populated.
   -- For upgrade part, bcmo is deleted and recreated. Data in these two tables is used to figure out
   -- the orgs where the BOM should get created. If there is no data in bcos_gt, data for BOM
   -- doesn't get pruned for OSS resulting in config BOM getting created in all orgs irrespective of OSS settings.

   l_stmt_num := 41;

   If (l_perform_match = 'Y' or l_reuse_config ='Y') and l_config_creation = 3 Then

      -- Fixed the bug on 02/11/04
      -- If the top most item is matched, we don't need to execute the whole
      -- algorithm, Still we need to validate the ship from org. Adding the validation part here

      Begin

      /* Fixed the following sql to get the from orbitrary org istead of
         going to specific ship from org */

      select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
             option_specific_sourced
      into   l_option_specific
      from   mtl_system_items msi,
             bom_cto_order_lines_gt bcol
      where msi.inventory_item_id = bcol.config_item_id
      and   line_id = p_ato_line_id
      and   rownum =1; /* Bugfix 3472654 */

      if l_option_specific is not null then
      select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
             'Y'
      into   l_valid_ship_from_org
      from   bom_cto_order_lines_gt bcol,
             mtl_system_items msi
      where  line_id = p_ato_line_id
      and    msi.inventory_item_id = bcol.config_item_id
      and    msi.organization_id   = bcol.ship_from_org_id
      and    msi.option_specific_sourced is not null
      and   bcol.ship_from_org_id in
             (select assg.organization_id
	      from   mrp_sr_assignments assg,
	             mrp_sr_receipt_org rcv,
		     mrp_sr_source_org  src
	      where  assg.inventory_item_id = bcol.config_item_id
	      and    assg.sourcing_rule_id = rcv.sourcing_rule_id
	      and    rcv.effective_date <= sysdate
              and    nvl(rcv.disable_date,sysdate+1)>sysdate
              and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
	      union
	      select src.source_organization_id
	      from   mrp_sr_assignments assg,
	             mrp_sr_receipt_org rcv,
		     mrp_sr_source_org  src
	      where  assg.inventory_item_id = bcol.config_item_id
	      and    assg.sourcing_rule_id = rcv.sourcing_rule_id
	      and    rcv.effective_date <= sysdate
              and    nvl(rcv.disable_date,sysdate+1)>sysdate
              and    rcv.SR_RECEIPT_ID = src.sr_receipt_id);
      End if;
      Exception When no_data_found then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Ship from org is not valid',1);
         l_valid_ship_from_org := 'N';
         CTO_MSG_PUB.cto_message('BOM','CTO_OSS_INVALID_SHIP_ORG');
         raise FND_API.G_EXC_ERROR;
      End;

      -- Added by Renga Kannan on 12/02/04 for bug # 3896824
      -- The following validation is added for this bug.
      -- If the top most model is matched for pre configuration case
      -- we need to validate the pre config org is part of the manufacturing
      -- or procuring org. This validation is added here
     If l_option_specific is not null and
        l_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID Then
        Begin
           Select 'x'
           into   l_valid_preconfig_org
           from   bom_cto_order_lines_gt bcol,
                  mtl_system_items msi
           where  line_id = p_ato_line_id
           and    msi.inventory_item_id = bcol.config_item_id
           and    msi.organization_id   = bcol.ship_from_org_id
           and    msi.option_specific_sourced is not null
           and    bcol.ship_from_org_id in
                   (select assg.organization_id org_id
	            from   mrp_sr_assignments assg,
	                   mrp_sr_receipt_org rcv,
		           mrp_sr_source_org  src
	            where  assg.inventory_item_id = bcol.config_item_id
	            and    assg.sourcing_rule_id = rcv.sourcing_rule_id
	            and    rcv.effective_date <= sysdate
                    and    nvl(rcv.disable_date,sysdate+1)>sysdate
                    and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
	            and    src.source_type in (2,3)
	            union
	            select src.source_organization_id org_id
	            from   mrp_sr_assignments assg,
	                   mrp_sr_receipt_org rcv,
		           mrp_sr_source_org  src
	            where  assg.inventory_item_id = bcol.config_item_id
	            and    assg.sourcing_rule_id = rcv.sourcing_rule_id
	            and    rcv.effective_date <= sysdate
                    and    nvl(rcv.disable_date,sysdate+1)>sysdate
                    and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
	            and    src.source_organization_id not in
	                 (Select assg.organization_id
		          from   mrp_sr_assignments assg,
		                 mrp_sr_receipt_org rcv,
			         mrp_sr_source_org  src
		          Where  assg.inventory_item_id = bcol.config_item_id
		          and    assg.sourcing_rule_id   = rcv.sourcing_rule_id
		          and    rcv.effective_date <=sysdate
		          and    nvl(rcv.disable_date,sysdate+1)>sysdate
		          and    rcv.sr_receipt_id = src.sr_receipt_id
		         )
	          );
         if PG_DEBUG <> 0 then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	                    'PROCESS_OSS_CONFIGURATIONS: Preconfiguration org is a valid manufacturing or Procuring org',3);
         End if;
         Exception when no_data_found then
            if PG_DEBUG <> 0 then
	       oe_debug_pub.add(lpad(' ',g_pg_level)||
	                        'PROCESS_OSS_CONFIGURATIONS: Preconfiguration org is not a valid manufacturing or Procuring org',1);
               CTO_MSG_PUB.cto_message('BOM','CTO_OSS_INVALID_PC_ORG');
               raise FND_API.G_EXC_ERROR;
	    End if;
         End;
      End if;

      /* Modified by Renga Kannan on 03/16/2006 for bug #:4368474
         If the top model is matched to a config , which is a oss cofig and
	 the CIB attribute for the config is 3, then The OSS API just returns the
	 call as it does not need to do anything more.

	 But we don't update the bcol date with the oss flag. As we have not updated
	 the oss flag, later part of the program is copying the sourcing rule from model
	 assuming that this is not a oss config. To avoid this issue, we will flag all
	 the matched config with its oss value from mtl_system_items to bcol so that
	 we won't have this issue.

      */

      /* Commenting out this update sql as part of bugfix 8894392(FP:7520529).
      update bom_cto_order_lines_gt bcolgt
      set    option_specific = (select  option_specific_sourced
                                        from    mtl_system_items
					where   inventory_item_id = bcolgt.config_item_id
					and     rownum = 1)
      where config_item_id is not null
      and   ato_line_id = p_ato_line_id;
      */

      -- End of addition by Renga on 12/02/04 for bug 3896824

      IF PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Config item is matched/re-used with attribute 3',5);
	 oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Ending API with Success',5);
         oe_debug_pub.add('=========================================================================',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
         oe_debug_pub.add('                                                                         ',1);
         oe_debug_pub.add('=========================================================================',1);
      End if;

      return;
   end if;
   end if; --if p_mode = 'ACC'  Bugfix 8894392

   delete /*+ INDEX (bom_cto_oss_source_gt BOM_CTO_OSS_SOURCE_GT_N1)  */
   from bom_cto_oss_source_gt
   where ato_line_id = p_ato_line_id;

   delete /*+ INDEX (bom_cto_oss_orgslist_gt BOM_CTO_OSS_ORGSLIST_GT_N1) */
   from bom_cto_oss_orgslist_gt
   where ato_line_id = p_ato_line_id;

   /* Make a call to an API which will process this order for OSS */

   l_stmt_num := 60;
   update_oss_in_bcol(
                    p_ato_line_id   => p_ato_line_id,
  	            x_oss_exists    => x_oss_exists,
		    x_return_status => x_return_status,
		    x_msg_data      => x_msg_data,
		    x_msg_count     => x_msg_count);

   If x_return_status  = FND_API.G_RET_STS_ERROR Then
      IF PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
       End if;
       raise FND_API.G_EXC_ERROR;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
       IF PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
       End if;
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

   -- Moved this update stmt from update_oss_in_bcol to here. Wanted to execute this update only for ACC.
   -- Adding the p_mode condition as part of Bugfix 8894392. Didn't want to disturb the behaviour for ACC
   -- although I don't think this will ever get executed for CIB = 3 and matched configs because of bypass
   -- condition. For UPG, we are doing the complete processing again. So don't need this.
   if p_mode = 'ACC' then
      update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
             bom_cto_order_lines_gt bcol
      set    bcol.option_specific = (select msi.option_specific_sourced
                                     from   mtl_system_items msi
                                     where  msi.inventory_item_id = bcol.config_item_id
		                     and    rownum =1)
      where  bcol.perform_match = 'Y'   /* We need to add config creation condition here */
      and    bcol.config_creation = '3'
      and    bcol.ato_line_id   = p_ato_line_id;

      l_count := sql%rowcount;
   end if;

   IF PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Number of matched configs with attribute settting 3 ='
                                          ||l_count,5);
   End if;

   l_stmt_num := 70;
   If x_oss_exists = 'Y' Then

      l_stmt_num := 80;
      Get_order_sourcing_data(
                                p_ato_line_id   => p_ato_line_id,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);
      If x_return_status  = FND_API.G_RET_STS_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if;


      l_stmt_num := 80;
      Process_order_for_oss(
                         p_ato_line_id   => p_ato_line_id,
			 P_calling_mode  => p_mode,  -- Bugfix 8894392. Need to pass the correct mode.
			 x_return_status => x_return_status,
			 x_msg_count     => x_msg_count,
			 x_msg_data      => x_msg_data);

      If x_return_status  = FND_API.G_RET_STS_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if;



      l_stmt_num := 90;

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Before validating ship from org',5);
      End if;

      /* Renga: Add Validation to ship from org check */

      If p_mode = 'ACC' then
         update bom_cto_order_lines bcol
         set    option_specific = (select /*+ INDEX (bcol_gt BOM_CTO_ORDER_LINES_GT_U1) */
	                                 decode(option_specific,'4','3',option_specific)
                                   from   bom_cto_order_lines_gt bcol_gt
			           where  bcol_gt.line_id = bcol.line_id)
         where  bcol.ato_line_id = p_ato_line_id;
      elsif p_mode = 'UPG' then
         update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_UPG_N4) */ bom_cto_order_lines_upg bcol
         set    option_specific = (select /*+ INDEX (bcol_gt BOM_CTO_ORDER_LINES_GT_U1) */
	                                  decode(option_specific,'4','3',option_specific)
                                   from   bom_cto_order_lines_gt bcol_gt
                                   where  bcol_gt.line_id = bcol.line_id)
         where  bcol.ato_line_id = p_ato_line_id;
      end if;

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: l_program_id:'|| l_program_id, 5);
      END IF;

      IF (l_program_id <> cto_update_configs_pk.bac_program_id) THEN
      -- Bugfix 8894392: If program id = 99, it means that the matched CIB = 3 config
      -- was picked up from bac. This processing failed if a config is present only
      -- on closed SO lines with a shipping org that is now invalid as per new OSS
      -- setting. For example, consider a config C1 that is now present only on closed
      -- SO lines. It has a shipping warehouse as M1. This config will also be present
      -- in bac with organization_id = 207(M1) which is used in UPG processing as ship_from_org_id.
      -- So when users wanted to make this org M1 invalid as per their OSS, the UEC complained
      -- saying ship_from org not valid. So if a config is coming from bac, not performing
      -- this validation check. Secondly, organization_id in bac can be any arbit org where
      -- the config was created sometime in the past. I don't suppose we should rely on
      -- bac's organization_id as ship_from_org_id. We will probably have to think about this later.

	Begin
	  select 'Y'
	  into  /*+ INDEX(bcol BOM_CTO_ORDER_LINES_GT_U1) */
	        l_valid_ship_from_org
          from   bom_cto_order_lines_gt bcol
          where  line_id = p_ato_line_id
	  and (option_specific is null
              or ship_from_org_id in (select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	                              rcv_org_id
                                      from   bom_cto_oss_source_gt oss_src
	    			      where  line_id = p_ato_line_id
				      and    valid_flag = 'Y'
				      union
				      select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
				             source_org_id
                                      from   bom_cto_oss_source_gt oss_src
				      where  line_id = p_ato_line_id
				      and    valid_flag = 'Y'));
	Exception when no_data_found then
          If PG_DEBUG <> 0 Then
	    oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS: Ship from org is not valid',5);
	  end if;
          CTO_MSG_PUB.cto_message('BOM','CTO_OSS_INVALID_SHIP_ORG');
          raise FND_API.G_EXC_ERROR;
	End;

      END IF;  -- IF (l_program_id <> cto_update_configs_pk.bac_program_id) Bugfix 8894392

      -- Added By Renga Kannan on 11/30/04  for bug #3896824
      --
      -- In the preconfig process, preconfiguration is allowed only in the
      -- manufacturing/Procuring org for OSS cases. For OSS config, we allways
      -- create bom only in the manufacturing or procuring orgs. When user trys
      -- pre configure the ato item in the intermediate orgs, CTO should raise an
      -- error stating that this org is not valid for pre configuration
      -- We are adding this validation here and raise the appropriate error.

      -- The way the validation works is as follows. By looking at the pruned sourcing
      -- tree from the temp table, this part of the code identify all the manufacturing/
      -- Procuring org. Then we will verify that the ship from org is part of this orgs
      -- list. If it is not part of the org list derived, then we will register an error

      -- The following sql will derive the list of manufacturing/procuring org
      -- from the pruned sourcing tree

      -- This validation should be performed only for pre configuration cases. This should
      -- not be performed for Upgrade and ACC.


      If l_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID Then
         Begin
            Select 'Y'
            into  l_valid_preconfig_org
            from
            (Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
                    distinct nvl(source_org_id,rcv_org_id)  org_id
             from   bom_cto_oss_source_gt oss_src
             where  line_id = p_ato_line_id
             and    valid_flag in( 'P','Y')
             and    source_type in (2,3)
             union
             select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
                    distinct source_org_id org_id
             from   bom_cto_oss_source_gt oss_src
             where  line_id = p_ato_line_id
             and    valid_flag in ('P','Y')
             and    source_org_id not in (
				select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
				       rcv_org_id
				from   bom_cto_oss_source_gt oss_src
				where  line_id = p_ato_line_id
				and    valid_flag in( 'P','Y')))
	     Where org_id = l_ship_from_org_id
	     and   rownum = 1;
	     if PG_DEBUG<> 0 Then
	        oe_debug_pub.add(lpad(' ',g_pg_level)||
		                      'PROCESS_OSS_CONFIGURATIONS::The Preconfiguration org is valid manufacturing/procuring org',3);
	     end if;

          Exception when no_data_found then
  	     if PG_DEBUG<> 0 Then
	        oe_debug_pub.add(lpad(' ',g_pg_level)||
		                      'PROCESS_OSS_CONFIGURATIONS::The Preconfiguration org is not a valid manufacturing/procuring org',3);
		oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS::Raising Expected error',1);
	     end if;
	     CTO_MSG_PUB.cto_message('BOM','CTO_OSS_INVALID_PC_ORG');
             raise FND_API.G_EXC_ERROR;
	  End;
      End if; /* l_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID */

      -- End of change for bug 3896824 on 11/30/04

   End if; /* x_oss_exists = 'Y' */


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('=========================================================================',1);
      oe_debug_pub.add('                                                                         ',1);
      oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
      oe_debug_pub.add('                                                                         ',1);
      oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
      oe_debug_pub.add('                                                                         ',1);
      oe_debug_pub.add('=========================================================================',1);
   End if;

Exception

    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
       END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
	  g_pg_level := g_pg_level - 3;
          cto_msg_pub.count_and_get(
                                    p_msg_count  => x_msg_count,
                                    p_msg_data   => x_msg_data
                                   );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                    p_msg_count  => x_msg_count,
                                    p_msg_data   => x_msg_data
                                   );
    WHEN OTHERS THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_OSS_CONFIGURATIONS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                    p_msg_count  => x_msg_count,
                                    p_msg_data   => x_msg_data
                                   );

END Process_Oss_configurations;




/*




          *****************************  PRUNE_OSS_CONFIGURATIONS  ***************************************




*/

Procedure prune_oss_config(
                           p_model_line_id  IN  Number,
		           p_model_item_id  IN  Number,
			   p_config_item_id IN  Number,
			   p_calling_mode   IN  Varchar2,
                           p_ato_line_id    IN  Number,
			   x_exp_error_code OUT NOCOPY Number,
                           x_return_status  OUT NOCOPY Varchar2,
	                   x_msg_count      OUT NOCOPY Number,
		           x_msg_data       OUT NOCOPY Varchar2
			  ) is

   l_comp_count		Number :=0;
   l_vendor_count       Number :=0;
   l_org_count          Number :=0;
   l_valid_count        Number :=0;
   l_stmt_num           Number :=0;




Begin

    g_pg_level := g_pg_level + 3;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_exp_error_code := 0;

    delete /*+ INDEX (bom_cto_oss_orgslist_gt BOM_CTO_OSS_ORGSLIST_GT_N1) */
    from bom_cto_oss_orgslist_gt
    where ato_line_id = p_ato_line_id;

    /* The following sql will find out how manny componets in this
       configuration has OSS definition
    */

    If PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Inside PRUNE_OSS_CONFIG API',5);
    End if;


    l_stmt_num := 10;

    select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N3) */
           count(*)
    into   l_comp_count
    from   bom_cto_oss_components ossc,
           bom_cto_order_lines_gt    bcol
    where  ossc.model_item_id      = p_model_item_id
    and    ossc.option_item_id     = bcol.inventory_item_id
    and    bcol.parent_ato_line_id = p_model_line_id
    and    exists (select 'x' from bom_cto_oss_orgs_list ossl
                   where ossl.oss_comp_seq_id = ossc.oss_comp_seq_id);


    If PG_DEBUG <> 0 then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: No of oss components for this model = '||l_comp_count,5);
    End if;

    If l_comp_count > 0 then

        /* We need to find out the intersection orgs from the sourcing setup list.
	   The intersection is found by looking the organization occurance with oss components count.
	   For example if 5 components are part of oss, then all orgs which occur 5 times in the sql
	   will be the commong orgs or intersection orgs.
	*/

	l_stmt_num := 20;

        Insert into bom_cto_oss_orgslist_gt
                  (
                    line_id,          /* Model Line id */
                    inventory_item_id,/* Model item id */
                    organization_id,  /* Organization Id */
                    ato_line_id     /* Ato line id */
                  )

        select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N3) */
               p_model_line_id Line_id,
               p_model_item_id inventory_item_id,
               ossl.organization_id organization_id,
               p_ato_line_id

        from   bom_cto_oss_components ossc,
               bom_cto_oss_orgs_list  ossl,
               bom_cto_order_lines_gt bcol

        where
               ossc.model_item_id       = p_model_item_id
        and    ossc.option_item_id      = bcol.inventory_item_id
        and    bcol.parent_ato_line_id  = p_model_line_id
        and    ossc.oss_comp_seq_id     = ossl.oss_comp_seq_id
	and    ossl.organization_id is not null

        group by organization_id

        having count(*) = l_comp_count;

	l_org_count  := sql%rowcount;

        If PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: After first Insert',5);
	   oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Number of of orgs inserted in temp table ='||l_org_count,5);
	End if;


        /* We need to find out the intersection vendors from the sourcing setup list.
	   The intersection is found by looking the vendor-vendor site occurance with oss components count.
	   For example if 5 components are part of oss, then all vendor-vendor site which occur 5 times in
	   the sql will be the commong orgs or intersection orgs.
	*/

        l_stmt_num := 30;

        Insert into bom_cto_oss_orgslist_gt(
               line_id,
               inventory_item_id,
               vendor_id,
               vendor_site_code,
               ato_line_id )


        select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N3) */
               p_model_line_id line_id,
               p_model_item_id inventory_item_id,
               ossl.vendor_id vendor_id,
               decode(ossl.vendor_site_code,null,'-1',
                      ossl.vendor_site_code) vendor_site_code,
               p_ato_line_id   ato_line_id

        from   bom_cto_oss_components ossc,
               bom_cto_oss_orgs_list ossl,
               bom_cto_order_lines_gt bcol

        where
               bcol.parent_ato_line_id = p_model_line_id
        and    ossc.model_item_id      = p_model_item_id
        and    ossc.option_item_id     = bcol.inventory_item_id
        and    ossc.oss_comp_seq_id    = ossl.oss_comp_seq_id
	and    ossl.vendor_id is not null

        group by vendor_id,
                 decode(vendor_site_code,null,'-1',vendor_site_code)


        having count(*) = l_comp_count;

	l_vendor_count := sql%rowcount;

	If PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: After Second insert..',5);
	   oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Number of Vendors inserted into temp = '||l_vendor_count);
	End if;

        /* If there is no commong orgs, then CTO will raise an error and end the process
	   Renga: Think about the case, where no orgs found but some valid vendors found.
	          is it ok to go ahead in that case? check later
	*/

        /* Impact: Here we need to populate the error code for ATP purpose  */


	l_stmt_num := 40;


	If l_vendor_count = 0 and l_org_count = 0 then

	    If PG_DEBUG <> 0 then
               oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: No Intersection org found ',1);
	       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Model line id = '||p_model_line_id,1);
	    end if;
	    If p_calling_mode in ('ACC', 'UPG') Then  --Bugfix 8894392
	       cto_msg_pub.cto_message('BOM','BOM_CTO_OSS_NO_COMMON_ORGS');
	       raise FND_API.G_EXC_ERROR;
	    Elsif p_calling_mode = 'ATP' Then
	       x_exp_error_code := 350;
	       g_pg_level := g_pg_level - 3;
	       return;
	    End if;

	End if;

        /*

	   Now it is the time to load all the valid model sourcing assignment into memory.
           All the assignment for model-org, for which org is not part of our common org
	   list can be igonored. That means, we will first load all the assignments for which
	   the organization is part of the commong org list.

	   Also, we should load item level and customer level assignments as they don't have
	   any organization.

	   Renga: Here is the most important point, where we may need some decode to get
	          correct rcv_org_id.In some global sourcing rule cases, it will be null.
		  In those cases, we may need to substitue with assignment org id.

	 */

        l_stmt_num := 50;


        /*
	      NOTE: The above sql will get both item and customer level rule. also,
	      get valid item org rules at once.

	      Renga: We may need to tune the above query later.
        */

	/* Identify all the rows which has the source org or vendor as part of the
	   intersection list.
	 */
/*
        for org_rec in org_cur
        Loop
           oe_debug_pub.add('Temp Org id = '||org_rec.organization_id,1);
        End Loop;

        for src_rec in src_cur
        loop
           oe_debug_pub.add('Temp rcv org id = '||src_rec.rcv_org_id,1);
           oe_debug_pub.add('Temp Src org id = '||src_rec.source_org_id,1);
           oe_debug_pub.add('Temp Valid flag = '||src_rec.valid_flag,1);
        end loop;
*/

        l_stmt_num := 60;

	Update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       bom_cto_oss_source_gt oss_src
	set    oss_src.valid_flag = 'Y'
	where oss_src.line_id = p_model_line_id
	and   ((oss_src.source_org_id in
	        (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
		        organization_id
		 from	bom_cto_oss_orgslist_gt oss_lis
		 where  oss_lis.line_id = p_model_line_id)
                 or  (nvl(oss_src.vendor_id,-1),nvl(oss_src.vendor_site_code,-1)) in
	         (select  /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
		         nvl(vendor_id,-99),vendor_site_code
		  from   bom_cto_oss_orgslist_gt oss_lis
		  where    oss_lis.line_id = p_model_line_id)
              )
	      )
	and (oss_src.rcv_org_id is null or
             oss_src.rcv_org_id in (
                                   select  /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
                                          organization_id
	                           from   bom_cto_oss_orgslist_gt oss_lis
				   where  line_id = p_model_line_id)
            );


        If PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Number of valid nodes in the pruned tree ='
	                                        ||sql%rowcount,5);
	End if;



	/* Get all the organizations which are not part of model sourcing tree..
	   And with the planning make buy code 1. That meand make models
	 */


       /* Impact: Don't introdue make at rule for orgs, which exists as part of sourcing rule
          even if it is not valid */
        l_stmt_num := 70;


        insert into bom_cto_oss_source_gt
	              (
		       inventory_item_id,
		       line_id,
		       config_item_id,
		       rcv_org_id,
		       source_org_id,
		       customer_id,
		       ship_to_site_id,
		       vendor_id,
		       vendor_site_code,
		       rank,
		       allocation,
		       reuse_flag,
		       source_type,
		       valid_flag,
		       leaf_node
                      )
         Select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
	        p_model_item_id,
	        p_model_line_id,
		p_config_item_id,
		oss_lis.organization_id,
		oss_lis.organization_id,
		null,
		null,
		null,
		null,
		1,
		100,
                'N',
		2,       /* Make at source type */
		'Y',     /* Valid flag          */
		'Y'      /* Leaf  node          */
         from   bom_cto_oss_orgslist_gt oss_lis,
                mtl_system_items msi
         where  oss_lis.organization_id not in
               (select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	              nvl(rcv_org_id,-1)
                from  bom_cto_oss_source_gt   oss_src
		where oss_src.line_id = p_model_line_id
	        union
	        select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
		       nvl(source_org_id,-1)
	        from   bom_cto_oss_source_gt oss_src
		where  oss_src.line_id = p_model_line_id
                and    valid_flag = 'Y'
	       )
	 and    oss_lis.line_id = p_model_line_id
         and    msi.inventory_item_id = oss_lis.inventory_item_id
         and    msi.organization_id   = oss_lis.organization_id
         and    msi.planning_make_buy_code = 1;

         /* Impact : Valid flag condition should be removed */

         IF PG_DEBUG <> 0 Then
   	     oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Number of 100% rules inserted ='
	                                          ||sql%rowcount);
	  End if;


         /* If no valid sourcs found after pruning, CTO should error out
	 */

         l_stmt_num := 80;

	 Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	        count(*)
	 into   l_valid_count
	 from   bom_cto_oss_source_gt oss_src
	 where  valid_flag = 'Y'
	 and    line_id    = p_model_line_id;

         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Number of valid orgs = '
	                                         ||l_valid_count);
	 End if;

         If l_valid_count = 0 then

	    If PG_DEBUG <> 0 then
	      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Purning model tree results wiht no valid orgs',5);
	    End if;
            If p_calling_mode in ('ACC', 'UPG') Then  --Bugfix 8894392

	       IF PG_DEBUG <> 0 Then
		  oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: About to delete rules for config item:'|| p_config_item_id);
	       End if;

	       del_from_msa(p_config_item_id);  --Bugfix 8894392

	       cto_msg_pub.cto_message('BOM','CTO_OSS_NO_VALID_TREE');
               raise FND_API.G_EXC_ERROR;
	    Elsif p_calling_mode = 'ATP' Then
	       x_exp_error_code := 370;
	       g_pg_level := g_pg_level - 3;
	       return;
	    End if;

	 end if;

        l_stmt_num := 90;

	/* Identify and mark all the leaf nodes in the valid sourcing tree */

	update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       bom_cto_oss_source_gt oss_src
	set    leaf_node = 'Y'
	where  leaf_node is null
	and    line_id    = p_model_line_id
	and    valid_flag = 'Y'
	and    source_org_id not in (
	                             select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
				            rcv_org_id
				     from   bom_cto_oss_source_gt oss_src
				     where  line_id = p_model_line_id
				     and    valid_flag = 'Y');
	/* Renga: Try converting this into a seperate procedure
	          and re-use the code later
        */

        l_stmt_num := 100;
--	Delete from bom_cto_oss_orgslist_gt;
	/* Renga: Is it required to have delete here
	*/

	/* Renga: Things about match and re-use case for parent configs
	*/
        If PG_DEBUG <> 0 Then
   	   oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG: Coming out of PRUNE_OSS_CONFIG API',5);
	End if;


    End if;

    --Bugfix 13362916 Debug changes.
    IF PG_DEBUG <> 0 Then
      Print_source_gt;
      Print_orglist_gt;
    END IF;

    g_pg_level := g_pg_level - 3;

Exception

    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
       END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
	  g_pg_level := g_pg_level - 3;
          cto_msg_pub.count_and_get(
                                    p_msg_count  => x_msg_count,
                                    p_msg_data   => x_msg_data
                                   );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
    WHEN OTHERS THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End prune_oss_config;



/* The following procedure will prune the OSS model sourcing with the list
   of organization specified
 */

Procedure prune_parent_oss_config(
                                  p_model_line_id  IN  Number,
				  p_model_item_id  IN  Number,
				  p_calling_mode   IN  Varchar2,
                                  p_ato_line_id    IN  Number,
				  x_exp_error_code OUT NOCOPY Number,
                                  x_return_status  OUT NOCOPY Varchar2,
                      	          x_msg_count      OUT NOCOPY Number,
                   		  x_msg_data       OUT NOCOPY Varchar2
				 ) is
   l_oss_child_count    Number := 0;
   TYPE Source_org_tbl is Table of Number index by binary_integer;
   TYPE Rcv_org_tbl is Table of Number index by binary_integer;
   l_source_org_tbl     Source_org_tbl;
   l_rcv_org_tbl        rcv_org_tbl;
   l_valid_source_count Number := 0;
   l_item_rule_count    Number := 0;
   l_rule_exists        Varchar2(1);
   l_stmt_num           Number;

   l_option_specific    Varchar2(1);

   --Bugfix 13362916: Adding a new variable
   l_cnt                Number;
Begin

   select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
          option_specific
   into   l_option_specific
   from   bom_cto_order_lines_gt
   where  line_id = p_model_line_id;

   If l_option_specific = '2' then
      update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
           bom_cto_oss_source_gt oss_src
      set  valid_flag = 'N'
      where  line_id = p_model_line_id
      and    valid_flag is null;
      If PG_DEBUG <> 0 then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of records updated in source table = '
                                              ||sql%rowcount,5);
      End if;

      update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
             bom_cto_oss_source_gt oss_src
      set    valid_flag = null
      where  line_id  = p_model_line_id
      and    valid_flag = 'Y';

      If PG_DEBUG <> 0 then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of records updated in source table = '
                                              ||sql%rowcount,5);
      End if;
   end if;

   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 10;
   /* Get the no of child that are oss for this parent model
   */

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Inside PRUNE_PARENT_OSS_CONFIG API',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: p_calling_mode::' || p_calling_mode,5);
   End if;


   select /*+ INDEX(bcol BOM_CTO_ORDER_LINES_GT_N3) */
          count(*)
   into   l_oss_child_count
   from   bom_cto_order_lines_gt bcol
   where  parent_ato_line_id = p_model_line_id
   and    line_id <> p_model_line_id   /* We should igonre the current row */
   and    option_specific    in ('1','2','3')
   --Bugfix 13540153-FP(13360098)
   --and    not exists(select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
   /*                        'x'
		     from  bom_cto_oss_source_gt oss_src
		     where line_id = bcol.line_id
		     and   rcv_org_id is null
		     and   nvl(valid_flag,'N') = 'Y'
                     and   option_specific = '3')*/;

   /*<This is sacred>
   Reason for commenting parts of the above sql:
   Consider a scenarion like:
   model1 (No OSS - OSS flag set to 3 by Update_parent_oss_line)
   .model2 (No OSS - OSS flag set to 3 by Update_parent_oss_line)
   ..model3 (OSS - OSS flag set to 1)

   The above sql would properly prune model2 using OSS of model3 but would skip
   pruning model1 using pruned tree for model2 and model3 combined. This results
   in wrong sourcing results being returned.

   The above commenting is done while inserting into bom_cto_oss_orgslist_gt
   also.
   */

   /* Get the intersection org from all the child oss configurations and
       load it to bom_cto_oss_orgslist_gt table
   */


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of oss child = '
                                           ||l_oss_child_count,5);
   End if;
   l_stmt_num := 20;
   If l_oss_child_count > 0 then

      l_stmt_num := 30;
      delete /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N1) */
      from bom_cto_oss_orgslist_gt oss_lis
      where ato_line_id = p_ato_line_id;
      l_stmt_num := 40;

      insert into bom_cto_oss_orgslist_gt(
                         Inventory_item_id,
			 line_id,
			 organization_id,
                         ato_line_id     )
      select
             p_model_item_id,
             p_model_line_id,
	     organization_id,
             p_ato_line_id
      from   (select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) INDEX (bcol BOM_CTO_ORDER_LINES_GT_N3) */
                      oss_src.line_id line_id,
                      oss_src.rcv_org_id organization_id
              from   bom_cto_oss_source_gt oss_src,
                     bom_cto_order_lines_gt bcol
              where  bcol.parent_ato_line_id = p_model_line_id
              and    bcol.parent_ato_line_id <> bcol.line_id
              and    bcol.option_specific    in ('1','2','3')
              and    oss_src.line_id         = bcol.line_id
              and    oss_src.valid_flag      = 'Y'
              --Bugfix 13540153-FP(13360098): Refer to <This is sacred>.
	      --and    not exists ( Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
              /*                          'x'
                                 from   bom_cto_oss_source_gt oss_src1
                                 where oss_src1.line_id = oss_src.line_id
                                 and   bcol.option_specific = '3'
                                 and   nvl(valid_flag,'N') = 'Y'
                                 and   rcv_org_id is null)*/
              Union
              select  /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) INDEX (bcol BOM_CTO_ORDER_LINES_GT_N3) */
                      oss_src.line_id line_id,
                      oss_src.source_org_id organization_id
              from   bom_cto_oss_source_gt oss_src,
              bom_cto_order_lines_gt bcol
              where  bcol.parent_ato_line_id = p_model_line_id
              and    bcol.parent_ato_line_id <> bcol.line_id
              and    bcol.option_specific    in ('1','2','3')
              and    oss_src.line_id         = bcol.line_id
              and    oss_src.valid_flag      = 'Y'
              --Bugfix 13540153-FP(13360098): Refer to <This is sacred>.
	      --and    not exists ( Select /*+ INDEX (oss_src1 BOM_CTO_OSS_SOURCE_GT_N2) */
              /*                           'x'
                                  from  bom_cto_oss_source_gt oss_src1
                                  where oss_src1.line_id = oss_src.line_id
                                  and   bcol.option_specific = '3'
                                  and   nvl(valid_flag,'N') = 'Y'
                                  and   rcv_org_id is null)*/
	     )

              group by organization_id
              having count(*) = l_oss_child_count;

      --Bugfix 13362916
      l_cnt := sql%rowcount;
   Else
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: No oss child found...Updating in bcol',1);
      END IF;

      update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
             bom_cto_order_lines_gt bcol
      set    option_specific = null
      where  line_id = p_model_line_id;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Rows updated = '||sql%rowcount,1);
      END IF;

      return;
   End if;

   l_stmt_num := 50;
   If PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of intersection orgs = '
                                            ||l_cnt,5);
   End if;

   -- Bug 13362916
   -- If sql%rowcount = 0 then
   If l_cnt = 0 then
      IF PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: No intersection orgs found',5);
      END IF;
      x_exp_error_code := 350;   /* No intersection orgs found */
      g_pg_level := g_pg_level - 3;
      return;
   end if;

   -- Bugfix 13362916
   If PG_DEBUG <> 0 Then
      Print_source_gt;
      Print_orglist_gt;
   End If;

   /* Check to see if there is a item level rule exists for the model
   */
   l_stmt_num := 60;
   Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          count(*)
   into   l_item_rule_count
   from   bom_cto_oss_source_gt oss_src
   where  line_id  = p_model_line_id
   and    customer_id is null
   and    rcv_org_id is null
   and    nvl(valid_flag,'Y') <> 'N';

   /* If there is an item level rule exists then, Item level rule should be
      pruned first
   */


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Item rule count = '||to_char(l_item_rule_count),5);
   end if;

   l_stmt_num := 70;
   If l_item_rule_count > 0 then

       l_stmt_num := 80;
       prune_item_level_rule(p_model_line_id   => p_model_line_id,
                             p_model_item_id   => p_model_item_id,
  		             x_rule_exists     => l_rule_exists,
			     x_return_status   => x_return_status,
			     x_msg_count       => x_msg_count,
			     x_msg_data        => x_msg_data
			    );
      If x_return_status  = FND_API.G_RET_STS_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if;

      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: '
                       ||' Item Rule exists after pruning',1);
    Else
       l_rule_exists := 'N';
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: '
                       ||' No Item Ruleafter pruning',1);

    End if;
   /* After pruing the item level sourcing, If still there are some
      valid nodes, the pruning for other nodes will be different */
   /* Identify all end nodes for the sourcing tree */

   /* Renga: Please modularise the following part of code
             for ease of maintenance
   */

   l_stmt_num := 90;
   If l_rule_exists = 'N' Then
      l_stmt_num := 100;

      Update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
             bom_cto_oss_source_gt oss_src
      set    leaf_node = 'Y'
      where  line_id = p_model_line_id
      and    nvl(valid_flag,'Y')  <> 'N'
      and    (   source_type in (2,3)
            or source_org_id not in
	                    (Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
			            rcv_org_id
			     from   bom_cto_oss_source_gt oss_src
			     where  line_id = p_model_line_id
                             and    nvl(valid_flag,'Y') <> 'N'
			    )
	  );


     /* Identify all the valid end nodes by comapring the source
        org with intersection org list.
        All the buy nodes are any way valid
      */
     l_stmt_num := 110;


     Update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
            bom_cto_oss_source_gt
     set    valid_flag = 'Y'
     where  line_id  = p_model_line_id
     and    leaf_node = 'Y'
     and    nvl(valid_flag,'Y') <> 'N'
     and    (source_type = 3 or
            source_org_id in (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
	                      organization_id
	                      from   bom_cto_oss_orgslist_gt oss_list
			      where  line_id = p_model_line_id
			   )
	 )
     Returning rcv_org_id,source_org_id  Bulk collect into l_source_org_tbl,l_rcv_org_tbl;


     If PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of updated records ='||l_source_org_tbl.count,5);
     End if;

     If l_source_org_tbl.count <> 0 then
        For i in l_source_org_tbl.first..l_source_org_tbl.last
        Loop

          update_Source_tree(p_line_id       => p_model_line_id,
                       p_end_org       => l_source_org_tbl(i),
                       x_return_status => x_return_status,
                       x_msg_data      => x_msg_data,
                       x_msg_count     => x_msg_count);
          If x_return_status  = FND_API.G_RET_STS_ERROR Then
             IF PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
             End if;
             raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
             IF PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
             End if;
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          End if;

        End loop;
     End if;

     /* Mark all the parent lines as valid */

     /* At end all nodes with valid flags are valid nodes for trees  */
        -- Now we should mark all the nodes which is not part of the sourcing tree
        -- Create 100% make at rule based on planning make buy code

     -- Bug Fix 4112373
     -- Added debug print utility call to print the temp table information
     -- This will help in debugging
     If PG_DEBUG <> 0 Then
        print_source_gt;
        print_orglist_gt;
     End if;


   -- Bug Fix 4112373
     -- For the top model after pruning the source tree 100% sourcing rules need to be
     -- created in all the orgs where the top model exists and the lower level model is valid
     -- The following sql will be inserting the 100% rule for the top model
     -- The sub query in this sql will get all the list of orgs in the sourcing chain
     -- for this top model. Since either source org/recv org can be null, we need to have
     -- a nvl caluse for these select columns. Otherwise the not in comparison will not return
     -- any rows.
     -- Added the nvl clause in the subquery returun column

     If PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'PRUNE_PARENT_OSS: Before inserting 100% make at rules',5);
     End if;
     Insert into bom_cto_oss_source_gt
                           (
                            inventory_item_id,
			    line_id,
			    rcv_org_id,
                            source_org_id,
                            customer_id,
			    ship_to_site_id,
			    vendor_id,
			    vendor_site_code,
			    rank,
			    allocation,
			    reuse_flag,
			    source_type,
			    valid_flag,
			    leaf_node
			   )

    select  /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) INDEX(bcol BOM_CTO_ORDER_LINES_GT_U1*/
                              p_model_item_id,
                              p_model_line_id,
                              oss_lis.organization_id,
	                      oss_lis.organization_id,
                              null,
	                      null,
               	              null,
	                      null,
	                      1,
	                      100,
	                      null,
                              2,
	                      'Y',
	                      'Y'
    from   bom_cto_oss_orgslist_gt oss_lis,
           mtl_system_items msi,
  	 bom_cto_order_lines_gt bcol
    where
          bcol.line_id = p_model_line_id
    and   bcol.option_specific = '3'
    and   oss_lis.organization_id not in (
                  select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
		         nvl(source_org_id, -1)
                  from   bom_cto_oss_source_gt oss_src
                  where  valid_flag = 'Y'
                  and    line_id = p_model_line_id
                  union
                  select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
		         nvl(rcv_org_id,-1)
                  from   bom_cto_oss_source_gt oss_src
                  where  valid_flag = 'Y'
                  and    line_id    = p_model_line_id)
    and    oss_lis.line_id            = p_model_line_id
    and    oss_lis.organization_id    = msi.organization_id
    and    msi.inventory_item_id      = bcol.inventory_item_id
    and    msi.planning_make_buy_code = 1;

    /* By this time, we are done with all the valid nodes... */

    /* check to see if there is any valid node after pruning . If there is
       no valid nodes, CTO will fail with error message     */



    select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
           count(*)
    into   l_valid_source_count
    from   bom_cto_oss_source_gt oss_src
    where  line_id = p_model_line_id
    and    valid_flag = 'Y';

    IF PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: Number of valid nodes in the pruned tree ='
                                          ||l_valid_source_count,5);
    End if;

    If l_valid_source_count = 0 then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG: After  pruning there is no valid source node',4);
     End if;
     If p_calling_mode in ('ACC', 'UPG') Then  --Bugfix 8894392
        CTO_MSG_PUB.cto_message('BOM','CTO_OSS_NO_VALID_TREE');
	raise FND_API.G_EXC_ERROR;
     elsif p_calling_mode = 'ATP' Then
        x_exp_error_code := 350;
     End if;
   End if;
 End if;

 -- bug 13362916
 IF PG_DEBUG <> 0 Then
   print_source_gt;
   Print_orglist_gt;
 END IF;

 g_pg_level := g_pg_level - 3;
 Exception

    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
    WHEN OTHERS THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_PARENT_OSS_CONFIG::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End prune_parent_oss_config;



/* This procedure will look at the pruned tree from
   bom_cto_oss_source_gt and create new
   sourcing rules and assignments
 */

Procedure Create_oss_sourcing_rules (
                                      p_ato_line_id   IN  Number,
                                      p_mode          IN  Varchar2 DEFAULT 'ACC',
                                      p_changed_src   IN  Varchar2 DEFAULT null,
                                      x_return_status OUT NOCOPY Varchar2,
   		                      x_msg_count     OUT NOCOPY Number,
			              x_msg_data      OUT NOCOPY Varchar2) is

   Cursor oss_model_lines is
   select line_id,
          inventory_item_id,
	  config_item_id,
	  option_specific,
	  config_creation,
	  perform_match,
	  reuse_config
   from  bom_cto_order_lines
   where ato_line_id = p_Ato_line_id
   and   option_specific in ('1','2','3')
   and   p_mode = 'ACC'
   union
   select line_id,
          inventory_item_id,
          config_item_id,
          option_specific,
          config_creation,
          perform_match,
          reuse_config
   from  bom_cto_order_lines_upg
   where ato_line_id = p_Ato_line_id
   and   option_specific in ('1','2','3')
   and   p_mode = 'UPG'
   and   (p_changed_src = 'Y' or config_creation=3);


   Cursor source_tree_cur(p_line_id number,
                          p_config_item_id number) is
   Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          oss_src.inventory_item_id inventory_item_id,
          oss_src.line_id line_id,
	  oss_src.rcv_org_id rcv_org_id,
	  oss_src.source_org_id source_org_id,
	  oss_src.vendor_id vendor_id,
	  oss_src.vendor_site_code vendor_site_code,
	  oss_src.rank rank,
	  oss_src.allocation allocation,
	  oss_src.reuse_flag reuse_flag,
	  oss_src.valid_flag valid_flag,
	  oss_src.leaf_node leaf_node,
	  oss_src.sr_receipt_id sr_receipt_id,
	  oss_src.sr_source_id sr_source_id,
	  oss_src.config_item_id config_item_id,
	  oss_src.source_type source_type,
          src_asg.assignment_type assignment_type,
          src_asg.assignment_set_id assignment_set_id,
	  src_asg.assignment_id assignment_id,
          src_asg.attribute1 attribute1,
	  src_asg.attribute2 attribute2,
	  src_asg.attribute3 attribute3,
	  src_asg.attribute4 attribute4,
	  src_asg.attribute5 attribute5,
	  src_asg.attribute6 attribute6,
	  src_asg.attribute7 attribute7,
	  src_asg.attribute8 attribute8,
	  src_asg.attribute9 attribute9,
	  src_asg.attribute10 attribute10,
	  src_asg.attribute11 attribute11,
	  src_asg.attribute12 attribute12,
	  src_asg.attribute13 attribute13,
	  src_asg.attribute14 attribute14,
	  src_asg.attribute15 attribute15,
	  src_asg.attribute_category attribute_category,
	  src_asg.category_id category_id,
	  src_asg.category_set_id category_set_id,
	  src_asg.customer_id customer_id,
	  src_asg.organization_id organization_id,
	  src_asg.secondary_inventory secondary_inventory,
	  src_asg.ship_to_site_id ship_to_site_id,
	  src_asg.sourcing_rule_type sourcing_rule_type,
	  src_asg.sourcing_rule_id sourcing_rule_id
   from   bom_cto_oss_source_gt  oss_src,
          mrp_sr_assignments       src_asg
   where  oss_src.line_id   = p_line_id
   and    nvl(oss_src.reuse_flag,'Y') = 'N'
   and    valid_flag   = 'P'
   and    src_asg.assignment_id  = oss_src.assignment_id
   and    nvl(src_asg.organization_id,-1) not in (select nvl(organization_id,-1)
                                          from   mrp_sr_assignments src_asg1
					  where  inventory_item_id = p_config_item_id
                                          and    assignment_set_id = G_def_assg_set)


   order  by oss_src.line_id,
          oss_src.assignment_id,
	  oss_src.sr_receipt_id,
	  oss_src.rank;
   l_cur_line_id   Number:=0;
   l_cur_assg_id   Number;

   --
   -- Bug 13362916
   -- Performance changes
   --
   Cursor oss_make_orgs_cur(p_line_id Number,
                            p_config_item_id Number
                           ) is
   select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          rcv_org_id,
          source_org_id,
          allocation,
          rank,
          config_item_id
   from   bom_cto_oss_source_gt oss_src
   where  line_id    = p_line_id
   and    valid_flag = 'P'
   and    leaf_node  = 'Y'
   and    assignment_id is null
   and    rcv_org_id    IS NULL
   UNION
   select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          rcv_org_id,
          source_org_id,
          allocation,
          rank,
          config_item_id
   from   bom_cto_oss_source_gt oss_src
   WHERE line_id        = p_line_id
   AND valid_flag     = 'P'
   AND leaf_node      = 'Y'
   AND assignment_id IS NULL
   AND RCV_ORG_ID         IS NOT NULL
   AND NOT EXISTS
             (SELECT /*+ INDEX (msa MRP_SR_ASSIGNMENTS_N3) */ 1
              FROM MRP_SR_ASSIGNMENTS msa
               WHERE INVENTORY_ITEM_ID   = p_config_item_id
                 AND ASSIGNMENT_SET_ID   = G_def_assg_set
                 AND ORGANIZATION_ID     = RCV_ORG_ID
                 AND Rownum              = 1
             );

   --
   -- Bug 13362916
   -- Performance changes
   --
   Cursor oss_reused_assg(p_line_id Number,p_config_item_id number) is
   select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          distinct assignment_id
   from   bom_cto_oss_source_gt oss_src
   where  line_id = p_line_id
   and    valid_flag = 'P'
   and    nvl(reuse_flag,'Y') = 'Y'
   and    rcv_org_id         is null
   UNION
   select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
          distinct assignment_id
   FROM BOM_CTO_OSS_SOURCE_GT OSS_SRC
   WHERE LINE_ID           = p_line_id
   and VALID_FLAG          = 'P'
   and NVL(REUSE_FLAG,'Y') = 'Y'
   and RCV_ORG_ID         IS NOT NULL
   and NOT EXISTS
     (SELECT /*+ INDEX (msa MRP_SR_ASSIGNMENTS_N3) */ 1
     FROM MRP_SR_ASSIGNMENTS msa
     WHERE INVENTORY_ITEM_ID = p_config_item_id
     AND ASSIGNMENT_SET_ID   = G_def_assg_set
     AND ORGANIZATION_ID     = RCV_ORG_ID
     AND Rownum              = 1
     );

   l_temp_count  Number;
   l_assignment_set_id   Number;



   TYPE source_tree_rec_typ is RECORD  (
 				       INVENTORY_ITEM_ID  NUMBER,
				       LINE_ID            NUMBER,
				       SOURCE_RULE_ID     NUMBER,
				       RCV_ORG_ID         NUMBER,
				       SOURCE_ORG_ID      NUMBER,
				       CUSTOMER_ID        NUMBER,
				       SHIP_TO_SITE_ID    NUMBER,
				       VENDOR_ID          NUMBER,
				       VENDOR_SITE_CODE   VARCHAR2(30),
				       RANK               NUMBER,
				       ALLOCATION         NUMBER,
				       REUSE_FLAG         VARCHAR2(1),
				       SOURCE_TYPE        NUMBER,
				       VALID_FLAG         VARCHAR2(1),
				       LEAF_NODE          VARCHAR2(1),
				       sr_receipt_id      Number,
				       sr_source_id       Number,
				       assignment_id      Number
				      );

   TYPE source_tree_tbl is TABLE of source_tree_rec_typ index by binary_integer;

   TYPE number_tbl is TABLE of number;
   TYPE varchar150_tbl is TABLE of Varchar2(150);
   TYPE varchar30_tbl  is TABLE of Varchar2(30);
   TYPE Varchar10_tbl  is TABLE of Varchar2(10);
   l_source_tree_tbl    source_tree_tbl;
   l_rank_sum           Number :=0;
   l_rank               Number :=0;
   l_new_rank_seq       Number;
   i                    Number :=1;
   l_old_rank           Number;
   l_curr_rcv_org       Number;
   rcv_count            Number;
   asg_count            Number :=1;
   l_make_at_exists     Varchar2(1);

   l_sourcing_rule_rec        MRP_SOURCING_RULE_PUB.sourcing_rule_rec_type;
   l_sourcing_rule_val_rec    MRP_SOURCING_RULE_PUB.sourcing_rule_val_rec_type;
   l_receiving_org_tbl        MRP_SOURCING_RULE_PUB.receiving_org_tbl_type;
   l_receiving_org_val_tbl    MRP_SOURCING_RULE_PUB.receiving_org_val_tbl_type;
   l_shipping_org_tbl         MRP_SOURCING_RULE_PUB.shipping_org_tbl_type;
   l_shipping_org_val_tbl     MRP_SOURCING_RULE_PUB.shipping_org_val_tbl_type;
   x_sourcing_rule_rec        MRP_SOURCING_RULE_PUB.sourcing_rule_rec_type;
   x_sourcing_rule_val_rec    MRP_SOURCING_RULE_PUB.sourcing_rule_val_rec_type;
   x_receiving_org_tbl        MRP_SOURCING_RULE_PUB.receiving_org_tbl_type;
   x_receiving_org_val_tbl    MRP_SOURCING_RULE_PUB.receiving_org_val_tbl_type;
   x_shipping_org_tbl         MRP_SOURCING_RULE_PUB.shipping_org_tbl_type;
   x_shipping_org_val_tbl     MRP_SOURCING_RULE_PUB.shipping_org_val_tbl_type;


   /* This is for Assignment processing
   */

   lAssignmentRec	      MRP_Src_Assignment_PUB.Assignment_Rec_Type;
   lAssignmentTbl	      MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
   lAssignmentSetRec	      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
   xAssignmentSetRec	      MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
   xAssignmentSetValRec	      MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type;
   xAssignmentTbl	      MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
   xAssignmentValTbl	      MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type;

   /* Declaration for bulk fetch */

   l_index  number;
   l_msg_data   Varchar2(2000);
   l_stmt_num   Number;
   l_vend_site_id Number;

   -- Bugfix 13362916
   TYPE l_sr_receipt_id_cache_typ is table of number index by long;
   l_sr_receipt_id_cache_tbl l_sr_receipt_id_cache_typ;

   SR_RECEIPT_ID_cachedLOC NUMBER := NULL;
Begin

   l_stmt_num := 10;
   g_pg_level := 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Inside Create OSS Sourcing Rule API',5);
   End if;

   l_stmt_num := 15;
   If p_mode = 'UPG' then
     select assignment_set_id
     into   G_def_assg_set
     from   mrp_assignment_sets
     where  assignment_set_name = 'CTO Configuration Updates';
   end if;

   For oss_model_lines_rec in oss_model_lines
   Loop
     l_stmt_num := 20;
     If PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Line id         = '||oss_model_lines_rec.line_id,5);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Config item     = '||oss_model_lines_rec.config_item_id,5);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Option specific = '||oss_model_lines_rec.option_specific,5);

        -- bug 13362916
        print_source_gt;
        Print_orglist_gt;
     End if;

     l_receiving_org_tbl.delete;
     l_receiving_org_val_tbl.delete;

     --Bugfix 13362916
     l_sr_receipt_id_cache_tbl.delete;

     l_shipping_org_tbl.delete;
     l_shipping_org_val_tbl.delete;
     l_new_rank_seq := 0;
     rcv_count      := 1;
     i              := 1;
     l_old_rank     :=null;

     if p_mode = 'ACC' then  -- Bugfix 8894392
       If oss_model_lines_rec.config_creation = '3' and
          (oss_model_lines_rec.perform_match = 'Y' or oss_model_lines_rec.reuse_config = 'Y') Then
	  If PG_DEBUG <> 0 Then
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Config item is matched and item attribute is 3',5);
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: No Need to create new sourcing rules',5);
	  End if;
	  l_stmt_num := 30;
          --Bugfix 13324638
          --exit; /* Start processing next record */
          goto loop_oss_model_lines;
       End if;
     end if;  -- Bugfix 8894392

     -- Reasoning for adding the p_mode condition here:
     -- Consider that the ATO Model has 2 sourcing rules:
     -- Org M1 has Make at rule and Org M2 has make at rule. The OSS says M1 so the rule that should get
     -- created for config is Make at M1. Suppose another SO finds a match to this config. The rule that
     -- should be used is Make at M1. We do not need the complete processing again. Now suppose the OSS is
     -- changed and OSS now says M2. Since the sourcing is changed, we need to create a new Make at M2 rule.
     -- Without this 'if p_mode' condition, the code will bypass creation of the new rule altogether when UEC
     -- is run. When UEC is run, p_mode will be UPG and the code will not exit from here but create the new
     -- rule.

     l_stmt_num := 40;
     If oss_model_lines_rec.config_creation = '3' then

        /* We need to create all the sourcing rules possible for this order lines */
	/* Mark all the nodes with valid flag 'Y' to 'P'. P means rows that needs to be
	   processed
	*/
	l_stmt_num := 50;

        update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       bom_cto_oss_source_gt oss_src
	set    valid_flag = 'P'
	where  line_id = oss_model_lines_rec.line_id
	and    valid_flag = 'Y';

        IF PG_DEBUG <> 0 then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Number of lines updated in bom_cto_oss_source_gt ='
                                                ||sql%rowcount,5);
        End if;

     Else
        /* We need to create sourcing rule only for this order chain */
	/* We need to find the order chain from bcso */

        l_stmt_num := 60;
	update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       bom_cto_oss_source_gt oss_src
	set    valid_flag = 'P'
	where  line_id = oss_model_lines_rec.line_id
	and    valid_flag = 'Y'
	and    rcv_org_id in (select rcv_org_id
	                      from   bom_cto_src_orgs
			      where  line_id = oss_model_lines_rec.line_id
			      and    organization_type is not null);
        IF PG_DEBUG <> 0 then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Number of lines updated in bom_cto_oss_source_gt ='
                                                ||sql%rowcount,5);
        End if;

	update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       bom_cto_oss_source_gt oss_src
	set    valid_flag = 'P'
	where  line_id    = oss_model_lines_rec.line_id
	and    valid_flag = 'Y'
	and    rcv_org_id is null
	and    exists (select rcv_org_id
	               from   bom_cto_src_orgs
		       where  line_id = oss_model_lines_rec.line_id
		       and    organization_type is not null
		       and    rcv_org_id not in (select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
		                                        rcv_org_id
		                                 from   bom_cto_oss_source_gt oss_src
						 where  line_id = oss_model_lines_rec.line_id
						 and    valid_flag = 'P'));

       IF PG_DEBUG <> 0 then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Number of lines updated in bom_cto_oss_source_gt ='
                                                ||sql%rowcount,5);
        End if;
     End if;

     /* Mark all the rows that are not be re-used
     */

     l_stmt_num := 65;
     update /*+ INDEX (oss_src1 BOM_CTO_OSS_SOURCE_GT_N2) */
            bom_cto_oss_source_gt oss_src1
     set    reuse_flag = 'N'
     where  line_id    = oss_model_lines_rec.line_id
     and    valid_flag = 'P'
     and    (oss_src1.assignment_id is null or exists (select/*+ INDEX (oss_src2 BOM_CTO_OSS_SOURCE_GT_N2) */
                                                             'x'
                                                       from bom_cto_oss_source_gt oss_src2
                                                       where oss_src2.line_id = oss_src1.line_id
                                                       and   oss_src2.source_rule_id = oss_src1.source_rule_id
                                                       and   nvl(oss_src2.valid_flag,'N') = 'N'
						      )
            );

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Number of records that are not re-used = '||
                                                sql%rowcount,5);
      End if;

      l_stmt_num := 70;
      l_cur_line_id := 0;
      For source_tree_rec in source_tree_cur(oss_model_lines_rec.line_id,
                                             oss_model_lines_rec.config_item_id)
      Loop
            l_stmt_num := 80;
            if nvl(l_cur_line_id,-1) <> source_tree_rec.line_id then
               l_cur_line_id := source_tree_rec.line_id;
               l_cur_assg_id := null;
            End if;

	    If PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Line id       = '
	                                            ||source_tree_rec.line_id,5);
	       oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Rcv Org Id    = '
						    ||source_tree_rec.rcv_org_id,5);
	       oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Source org id = '
						    ||Source_tree_rec.source_org_id,5);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'Old assignment set id = '||l_cur_assg_id,5);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'New assignment set id = '||source_tree_rec.assignment_id,5);
               --Bugfix 13362916
               oe_debug_pub.add(lpad(' ',g_pg_level)||'SR_RECEIPT_ID = '||source_tree_rec.sr_receipt_id,5);
	    End if;
	    l_stmt_num := 90;
            if nvl(l_cur_assg_id,-1) <> source_tree_rec.assignment_id  then
	       /* Now this is the time to process the sourcing rule creation.
	          we need to call mrp api and create a valid sourcing rule now
	       */

               If l_cur_assg_id is not null then
	          l_stmt_num := 100;
	          MRP_SOURCING_RULE_PUB.PROCESS_SOURCING_RULE(
	                                      p_api_version_number    => 1.0,
					      p_return_values         => FND_API.G_TRUE,
					      p_sourcing_rule_rec     => l_sourcing_rule_rec,
					      p_sourcing_rule_val_rec => l_sourcing_rule_val_rec,
					      p_receiving_org_tbl     => l_receiving_org_tbl,
					      p_receiving_org_val_tbl => l_receiving_org_val_tbl,
					      p_shipping_org_tbl      => l_shipping_org_tbl,
					      p_shipping_org_val_tbl  => l_shipping_org_val_tbl,
					      x_sourcing_rule_rec     => x_sourcing_rule_rec,
					      x_sourcing_rule_val_rec => x_sourcing_rule_val_rec,
					      x_receiving_org_tbl     => x_receiving_org_tbl,
					      x_receiving_org_val_tbl => x_receiving_org_val_tbl,
  				              x_shipping_org_tbl      => x_shipping_org_tbl,
					      x_shipping_org_val_tbl  => x_shipping_org_val_tbl,
					      x_return_status         => x_return_status,
					      x_msg_count             => x_msg_count,
					      x_msg_data              => x_msg_data);

                  FOR l_index IN 1..x_msg_count LOOP
                         l_msg_data := fnd_msg_pub.get(
                         p_msg_index => l_index,
                         p_encoded  => FND_API.G_FALSE);
                         oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: error : '||substr(l_msg_data,1,250));
                  END LOOP;

                  If x_return_status  = FND_API.G_RET_STS_ERROR Then
                     IF PG_DEBUG <> 0 Then
                        oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'CREATE_OSS_SOURCING_RULES: Exepected error occurred in update_oss_in_bcol API',5);
                     End if;
                     raise FND_API.G_EXC_ERROR;
                  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
                     IF PG_DEBUG <> 0 Then
                        oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'CREATE_OSS_SOURCING_RULES: Un Exepected error occurred in update_oss_in_bcol API',5);
                     End if;
                     raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  End if;
                  l_receiving_org_tbl.delete;
                  l_receiving_org_val_tbl.delete;

		  --Bugfix 13362916
                  l_sr_receipt_id_cache_tbl.delete;

                  l_shipping_org_tbl.delete;
                  l_shipping_org_val_tbl.delete;
                  l_stmt_num := 110;
                  lAssignmentTbl(asg_count).sourcing_rule_id    := x_sourcing_rule_rec.sourcing_rule_id;
                  If PG_DEBUG <> 0 Then
                     oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: New Sourcing rule cretaed= '                                                          ||x_sourcing_rule_rec.sourcing_rule_id,5);
                  End if;
	          Asg_count := asg_count + 1;
                  l_old_rank := null;
               End if; /* l_cur_assg_id is not null */

               /* Loading Assignment record for the current assignment */

               l_stmt_num := 120;

               If PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Loading the assignment into assignment record ',5);
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCNIG_RULES: assignment_type = '
                                                       ||source_tree_rec.assignment_type,5);
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: inventory item id = '
                                                       ||oss_model_lines_rec.config_item_id,5);
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: organization id = '
                                                       ||source_tree_rec.organization_id,5);

               End if;

               lAssignmentTbl(asg_count).assignment_set_id   := G_def_assg_set;
	       lAssignmentTbl(asg_count).assignment_type     := source_tree_rec.assignment_type;
	       lAssignmentTbl(asg_count).attribute1          := source_tree_rec.attribute1;
       	       lAssignmentTbl(asg_count).attribute2          := source_tree_rec.attribute2;
	       lAssignmentTbl(asg_count).attribute3          := source_tree_rec.attribute3;
	       lAssignmentTbl(asg_count).attribute4          := source_tree_rec.attribute4;
	       lAssignmentTbl(asg_count).attribute5          := source_tree_rec.attribute5;
	       lAssignmentTbl(asg_count).attribute6          := source_tree_rec.attribute6;
	       lAssignmentTbl(asg_count).attribute7          := source_tree_rec.attribute7;
	       lAssignmentTbl(asg_count).attribute8          := source_tree_rec.attribute8;
	       lAssignmentTbl(asg_count).attribute9          := source_tree_rec.attribute9;
	       lAssignmentTbl(asg_count).attribute10         := source_tree_rec.attribute10;
	       lAssignmentTbl(asg_count).attribute11         := source_tree_rec.attribute11;
	       lAssignmentTbl(asg_count).attribute12         := source_tree_rec.attribute12;
	       lAssignmentTbl(asg_count).attribute13         := source_tree_rec.attribute13;
	       lAssignmentTbl(asg_count).attribute14         := source_tree_rec.attribute14;
	       lAssignmentTbl(asg_count).attribute15         := source_tree_rec.attribute15;
	       lAssignmentTbl(asg_count).attribute_category  := source_tree_rec.attribute_category;
	       lAssignmentTbl(asg_count).category_id         := source_tree_rec.category_id;
	       lAssignmentTbl(asg_count).category_set_id     := source_tree_rec.category_set_id;
	       lAssignmentTbl(asg_count).customer_id         := source_tree_rec.customer_id;
	       lAssignmentTbl(asg_count).inventory_item_id   := oss_model_lines_rec.config_item_id; /* Config item id */
	       lAssignmentTbl(asg_count).organization_id     := source_tree_rec.organization_id;
	       lAssignmentTbl(asg_count).secondary_inventory := source_tree_rec.secondary_inventory;
	       lAssignmentTbl(asg_count).ship_to_site_id     := source_tree_rec.ship_to_site_id;
	       lAssignmentTbl(asg_count).sourcing_rule_type  := source_tree_rec.sourcing_rule_type;
      	       lAssignmentTbl(asg_count).operation           := MRP_Globals.G_OPR_CREATE;



	       l_cur_assg_id := source_tree_rec.assignment_id;
	       l_new_rank_seq := 0;
	       rcv_count      := 1;
               i              := 1;
               l_old_rank     :=null;

	       /* Renga: There is a change to re-use pruned sourcing again here .
	                 We should take care of this later */

   	       /* Delete all the existing data from the record structure.
	          This record structure will be populated with the new sourcing
	          rule information
	       */



	       /* The following sql will populate the data for sourcing
	          rule record type
	       */
	       l_stmt_num := 130;

               l_sourcing_rule_rec := MRP_SOURCING_RULE_PUB.G_MISS_SOURCING_RULE_REC;
	       select attribute1,
	              attribute2,
		      attribute3,
		      attribute4,
		      attribute5,
		      attribute6,
   		      attribute7,
		      attribute8,
		      attribute9,
		      attribute10,
		      attribute11,
		      attribute12,
		      attribute13,
		      attribute14,
		      attribute15,
		      attribute_category,
		      organization_id,
		      planning_active,
		      'CTO*'||bom_Cto_oss_source_rule_s1.nextval,
		      Sourcing_rule_type,
                      MRP_Globals.G_OPR_CREATE,
		      1
		     -- mrp_sourcing_rules_s.nextval
	       Into
	              l_sourcing_rule_rec.attribute1,
	              l_sourcing_rule_rec.attribute2,
		      l_sourcing_rule_rec.attribute3,
		      l_sourcing_rule_rec.attribute4,
		      l_sourcing_rule_rec.attribute5,
		      l_sourcing_rule_rec.attribute6,
   		      l_sourcing_rule_rec.attribute7,
		      l_sourcing_rule_rec.attribute8,
		      l_sourcing_rule_rec.attribute9,
		      l_sourcing_rule_rec.attribute10,
		      l_sourcing_rule_rec.attribute11,
		      l_sourcing_rule_rec.attribute12,
		      l_sourcing_rule_rec.attribute13,
		      l_sourcing_rule_rec.attribute14,
		      l_sourcing_rule_rec.attribute15,
		      l_sourcing_rule_rec.attribute_category,
		      l_sourcing_rule_rec.organization_id,
		      l_sourcing_rule_rec.planning_active,
		      l_sourcing_rule_rec.sourcing_rule_name,
		      l_sourcing_rule_rec.Sourcing_rule_type,
		      l_sourcing_rule_rec.Operation,
		      l_sourcing_rule_rec.status
		    --  l_sourcing_rule_rec.sourcing_rule_id
	       From   mrp_sourcing_rules
	       where  sourcing_rule_id = source_tree_rec.sourcing_rule_id;


               If PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Sourcing Rule name = '||
                                   l_sourcing_rule_rec.sourcing_rule_name,5);
               End if;
	       l_sourcing_rule_rec.operation := 'CREATE';

            End if; /* nvl(l_cur_assg_id,-1) <> source_tree_rec.assignment_id  */

            l_stmt_num := 140;

            If PG_DEBUG <> 0 Then
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Checking l_curr_rcv_org and sr_receipt_id',5);
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: l_curr_rcv_org = '||l_curr_rcv_org,5);
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: source_tree_rec.sr_receipt_id = '|| source_tree_rec.sr_receipt_id,5);
            End if;

            /*
            Bugfix 13362916: Commenting this if condition. Because of this condition, the variable rcv_count was not
            incremented from 1. This variable is subsequently used in populating l_shipping_org_tbl(i).receiving_org_index
            value. The value populated was rcv_count - 1 (=0). This field value is used as index value to access pl/sql
            tables in MRP code. Since the value of index variable was 0, MRP code was failing with error:
            MRP_API_INV_PARENT_INDEX

            Even after removing this if condition, the code was failing. Consider the following scenario:
            BOM structure:
            abmodel1
            .abitem
            .abmodel2
            ..abitem2
            ..abmodel3
            ...abitem3

            Consider a parent sourcing rule like:
            Organization: All Orgs
            Transfer from M1: 30%, Rank 1
            Transfer from M2: 50%, Rank 1
            Transfer from M3: 15%, Rank 1
            Transfer from D1: 5%, Rank 1

            Consider the OSS as M1.

            In this case, the rule tfr from M1 will be created for all 3 config items. A new rule would get created for abmodel1*.
            When the same rule is attempted for abmodel2*, because of the if condition, the collection l_receiving_org_tbl is
            not populated causing a zero index access in l_shipping_org_tbl.

            In second case, consider the OSS as M1 and M2.

            When the if condition was removed, the code was still failing in this scenario because then we were inserting same
            record twice in l_receiving_org_tbl. This is invalid as per MRP and fails with unique constraint violation.
            */

            --If nvl(l_curr_rcv_org,-1) <> source_tree_rec.sr_receipt_id Then
            IF l_sr_receipt_id_cache_tbl.EXISTS(source_tree_rec.sr_receipt_id) = FALSE THEN

               sr_receipt_id_cachedloc := NULL;

               -- l_receiving_org_tbl    :=    MRP_SOURCING_RULE_PUB.G_MISS_RECEIVING_ORG_TBL;
               --  l_receiving_org_val_tbl:=    MRP_SOURCING_RULE_PUB.G_MISS_RECEIVING_ORG_VAL_TBL;
               --  l_shipping_org_tbl     :=    MRP_SOURCING_RULE_PUB.G_MISS_SHIPPING_ORG_TBL;
               --  l_shipping_org_val_tbl :=    MRP_SOURCING_RULE_PUB.G_MISS_SHIPPING_ORG_VAL_TBL;
               --  rcv_count := 1;
	       select attribute1,
	              attribute2,
		      attribute3,
		      attribute4,
		      attribute5,
		      attribute6,
		      attribute7,
		      attribute8,
		      attribute9,
		      attribute10,
		      attribute11,
		      attribute12,
		      attribute13,
		      attribute14,
		      attribute15,
		      attribute_category,
		      disable_date,
                      sysdate,
   		      receipt_organization_id,
		      MRP_Globals.G_OPR_CREATE,
		      l_sourcing_rule_rec.sourcing_rule_id
	       into
                      l_receiving_org_tbl(rcv_count).attribute1,
   	              l_receiving_org_tbl(rcv_count).attribute2,
		      l_receiving_org_tbl(rcv_count).attribute3,
		      l_receiving_org_tbl(rcv_count).attribute4,
		      l_receiving_org_tbl(rcv_count).attribute5,
		      l_receiving_org_tbl(rcv_count).attribute6,
		      l_receiving_org_tbl(rcv_count).attribute7,
		      l_receiving_org_tbl(rcv_count).attribute8,
		      l_receiving_org_tbl(rcv_count).attribute9,
		      l_receiving_org_tbl(rcv_count).attribute10,
		      l_receiving_org_tbl(rcv_count).attribute11,
		      l_receiving_org_tbl(rcv_count).attribute12,
		      l_receiving_org_tbl(rcv_count).attribute13,
		      l_receiving_org_tbl(rcv_count).attribute14,
		      l_receiving_org_tbl(rcv_count).attribute15,
		      l_receiving_org_tbl(rcv_count).attribute_category,
		      l_receiving_org_tbl(rcv_count).disable_date,
		      l_receiving_org_tbl(rcv_count).effective_date,
		      l_receiving_org_tbl(rcv_count).receipt_organization_id,
		      l_receiving_org_tbl(rcv_count).operation,
		      l_receiving_org_tbl(rcv_count).sourcing_rule_id
	       from  mrp_sr_receipt_org
	       where sr_receipt_id = source_tree_rec.sr_receipt_id;

               --Bugfix 13362916
               l_sr_receipt_id_cache_tbl(source_tree_rec.sr_receipt_id) := rcv_count;

  	       rcv_count := rcv_count + 1;
	       l_curr_rcv_org := source_tree_rec.sr_receipt_id;

	    -- End if; /* nvl(l_curr_rcv_org,-1) <> source_tree_rec.sr_receipt_id */
            ELSE
               sr_receipt_id_cachedloc := NULL;
               sr_receipt_id_cachedloc := l_sr_receipt_id_cache_tbl(source_tree_rec.sr_receipt_id);
            END IF; /* !l_sr_receipt_id_cache_tbl.EXISTS(sr_receipt_id) */

            If PG_DEBUG <> 0 Then
 	      oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Old Rank = '||l_old_rank);
	      oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: New Rank = '||source_tree_rec.rank);
	    End if;

            l_stmt_num := 150;

            if nvl(l_old_rank,-1) <> source_tree_rec.rank then

               l_stmt_num := 160;

               select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	              sum(allocation)
	       into   l_rank_sum
	       from   bom_cto_oss_source_gt oss_src
	       where  line_id = source_tree_rec.line_id
	       and    source_rule_id = source_tree_rec.sourcing_rule_id
	       and    rank = source_tree_rec.rank
	       and    valid_flag = 'P';

	       If PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Rule id  = '||source_tree_rec.sourcing_rule_id);
		  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Rank     = '||source_tree_rec.rank);
 		  oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Rank Sum = '||l_rank_sum);
	       End if;

               l_new_rank_seq := l_new_rank_seq + 1;
	       l_old_rank     := source_tree_rec.rank;

	    End if;

            l_stmt_num := 170;

            l_shipping_org_tbl(i).allocation_percent     := source_tree_rec.allocation/l_rank_sum*100;
	    If PG_DEBUG <> 0 Then
  	       oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: New Allocation % = '
                                                    ||l_shipping_org_tbl(i).allocation_percent);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: Vendor id = '
                                                    ||source_tree_rec.vendor_id,5);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULE: source org id = '
                                                    ||source_tree_rec.source_org_id);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING)RULE: Sr Source id ='
                                                    ||source_tree_rec.sr_source_id);
               --Bugfix 13362916
               oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING)RULE: Sr Receipt id ='
			                            ||source_tree_rec.SR_RECEIPT_ID);
	    End if;

	    l_shipping_org_tbl(i).rank                   := l_new_rank_seq;
	    l_shipping_org_tbl(i).source_type            := source_tree_rec.source_type;
	    l_shipping_org_tbl(i).source_organization_id := source_tree_rec.source_org_id;
	    l_shipping_org_tbl(i).vendor_id              := source_tree_rec.vendor_id;

            -- Bug 13362916
 	    IF sr_receipt_id_cachedloc IS NULL THEN
               l_shipping_org_tbl(i).receiving_org_index    := rcv_count - 1;
            ELSE
               l_shipping_org_tbl(i).receiving_org_index := sr_receipt_id_cachedloc;
	    END IF;

	    /* Renga Need to work for vendor site here */


	    l_stmt_num := 180;

	    select  attribute1,
	            attribute2,
		    attribute3,
	   	    attribute4,
		    attribute5,
		    attribute6,
		    attribute7,
		    attribute8,
		    attribute9,
		    attribute10,
		    attribute11,
		    attribute12,
		    attribute13,
		    attribute14,
		    attribute15,
		    attribute_category,
		    secondary_inventory,
		    ship_method,
		    MRP_Globals.G_OPR_CREATE,
		    NVL(sr_receipt_id_cachedloc, rcv_count-1), --Bugfix 13362916
		    vendor_site_id
	     into
	            l_shipping_org_tbl(i).attribute1,
	            l_shipping_org_tbl(i).attribute2,
		    l_shipping_org_tbl(i).attribute3,
		    l_shipping_org_tbl(i).attribute4,
		    l_shipping_org_tbl(i).attribute5,
		    l_shipping_org_tbl(i).attribute6,
		    l_shipping_org_tbl(i).attribute7,
		    l_shipping_org_tbl(i).attribute8,
		    l_shipping_org_tbl(i).attribute9,
		    l_shipping_org_tbl(i).attribute10,
		    l_shipping_org_tbl(i).attribute11,
		    l_shipping_org_tbl(i).attribute12,
		    l_shipping_org_tbl(i).attribute13,
		    l_shipping_org_tbl(i).attribute14,
		    l_shipping_org_tbl(i).attribute15,
		    l_shipping_org_tbl(i).attribute_category,
		    l_shipping_org_tbl(i).secondary_inventory,
		    l_shipping_org_tbl(i).ship_method,
		    l_shipping_org_tbl(i).operation,
		    l_shipping_org_tbl(i).receiving_org_index,
		    l_shipping_org_tbl(i).vendor_site_id
	     from   mrp_sr_source_org
	     where  sr_source_id = source_tree_rec.sr_source_id;

             oe_debug_pub.add('Vendor site id inserted = '||l_shipping_org_tbl(i).vendor_site_id,5);
	     i := i + 1;

             --Bugfix 12917456
             sr_receipt_id_cachedloc := NULL;
      End Loop;




      /* this for the last record which will come out of loop
      */


      l_stmt_num := 190;

      If l_cur_line_id <> 0 then
         -- bug 13362916
         --
         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'Before Calling the MRP API ');
            oe_debug_pub.add(lpad(' ',g_pg_level)||'Printing data of l_sourcing_rule_rec ');
            oe_debug_pub.add(lpad(' ',g_pg_level)||'==============================================');
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Sourcing_Rule_Id :'||l_sourcing_rule_rec.Sourcing_Rule_Id );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute1 :'||l_sourcing_rule_rec.Attribute1 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute10 :'||l_sourcing_rule_rec.Attribute10 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute11 :'||l_sourcing_rule_rec.Attribute11 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute12 :'||l_sourcing_rule_rec.Attribute12 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute13 :'||l_sourcing_rule_rec.Attribute13 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute14 :'||l_sourcing_rule_rec.Attribute14 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute15 :'||l_sourcing_rule_rec.Attribute15 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute2 :'||l_sourcing_rule_rec.Attribute2 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute3 :'||l_sourcing_rule_rec.Attribute3 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute4 :'||l_sourcing_rule_rec.Attribute4 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute5 :'||l_sourcing_rule_rec.Attribute5 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute6 :'||l_sourcing_rule_rec.Attribute6 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute7 :'||l_sourcing_rule_rec.Attribute7 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute8 :'||l_sourcing_rule_rec.Attribute8 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute9 :'||l_sourcing_rule_rec.Attribute9 );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Attribute_Category :'||l_sourcing_rule_rec.Attribute_Category );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Created_By :'||l_sourcing_rule_rec.Created_By );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Creation_Date :'||l_sourcing_rule_rec.Creation_Date );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Description :'||l_sourcing_rule_rec.Description );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Last_Updated_By :'||l_sourcing_rule_rec.Last_Updated_By );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Last_Update_Date :'||l_sourcing_rule_rec.Last_Update_Date );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Last_Update_Login :'||l_sourcing_rule_rec.Last_Update_Login );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Organization_Id :'||l_sourcing_rule_rec.Organization_Id );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Planning_Active :'||l_sourcing_rule_rec.Planning_Active );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Program_Application_Id :'||l_sourcing_rule_rec.Program_Application_Id );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Program_Id :'||l_sourcing_rule_rec.Program_Id );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Program_Update_Date :'||l_sourcing_rule_rec.Program_Update_Date );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Request_Id :'||l_sourcing_rule_rec.Request_Id );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Sourcing_Rule_Name :'||l_sourcing_rule_rec.Sourcing_Rule_Name );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Sourcing_Rule_Type :'||l_sourcing_rule_rec.Sourcing_Rule_Type );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.Status :'||l_sourcing_rule_rec.Status );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.return_status :'||l_sourcing_rule_rec.return_status );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.db_flag :'||l_sourcing_rule_rec.db_flag );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_rec.operation :'||l_sourcing_rule_rec.operation );
            oe_debug_pub.add(lpad(' ',g_pg_level)||'==============================================');

            oe_debug_pub.add(lpad(' ',g_pg_level)||'l_sourcing_rule_val_rec.null_element :'|| l_sourcing_rule_val_rec.null_element);

            oe_debug_pub.add(lpad(' ',g_pg_level)||'Printing data of l_receiving_org_tbl count :'|| l_receiving_org_tbl.count);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'--------------------------------------------------------------------------');

            FOR debug_cntr in 1..l_receiving_org_tbl.count LOOP
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Sr_Receipt_Id :' || l_receiving_org_tbl(debug_cntr).Sr_Receipt_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute1 :' || l_receiving_org_tbl(debug_cntr).Attribute1 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute10 :' || l_receiving_org_tbl(debug_cntr).Attribute10 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute11 :' || l_receiving_org_tbl(debug_cntr).Attribute11 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute12 :' || l_receiving_org_tbl(debug_cntr).Attribute12 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute13 :' || l_receiving_org_tbl(debug_cntr).Attribute13 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute14 :' || l_receiving_org_tbl(debug_cntr).Attribute14 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute15 :' || l_receiving_org_tbl(debug_cntr).Attribute15 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute2 :' || l_receiving_org_tbl(debug_cntr).Attribute2 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute3 :' || l_receiving_org_tbl(debug_cntr).Attribute3 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute4 :' || l_receiving_org_tbl(debug_cntr).Attribute4 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute5 :' || l_receiving_org_tbl(debug_cntr).Attribute5 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute6 :' || l_receiving_org_tbl(debug_cntr).Attribute6 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute7 :' || l_receiving_org_tbl(debug_cntr).Attribute7 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute8 :' || l_receiving_org_tbl(debug_cntr).Attribute8 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute9 :' || l_receiving_org_tbl(debug_cntr).Attribute9 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Attribute_Category :' || l_receiving_org_tbl(debug_cntr).Attribute_Category );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Created_By :' || l_receiving_org_tbl(debug_cntr).Created_By );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Creation_Date :' || l_receiving_org_tbl(debug_cntr).Creation_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Disable_Date :' || l_receiving_org_tbl(debug_cntr).Disable_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Effective_Date :' || l_receiving_org_tbl(debug_cntr).Effective_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Last_Updated_By :' || l_receiving_org_tbl(debug_cntr).Last_Updated_By );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Last_Update_Date :' || l_receiving_org_tbl(debug_cntr).Last_Update_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Last_Update_Login :' || l_receiving_org_tbl(debug_cntr).Last_Update_Login );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Program_Application_Id :' || l_receiving_org_tbl(debug_cntr).Program_Application_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Program_Id :' || l_receiving_org_tbl(debug_cntr).Program_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Program_Update_Date :' || l_receiving_org_tbl(debug_cntr).Program_Update_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Receipt_Organization_Id :' || l_receiving_org_tbl(debug_cntr).Receipt_Organization_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Request_Id :' || l_receiving_org_tbl(debug_cntr).Request_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').Sourcing_Rule_Id :' || l_receiving_org_tbl(debug_cntr).Sourcing_Rule_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').return_status :' || l_receiving_org_tbl(debug_cntr).return_status );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').db_flag :' || l_receiving_org_tbl(debug_cntr).db_flag );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_tbl('||debug_cntr||').operation :' || l_receiving_org_tbl(debug_cntr).operation );
            END LOOP;
            oe_debug_pub.add(lpad(' ',g_pg_level)||'--------------------------------------------------------------------------');

            oe_debug_pub.add(lpad(' ',g_pg_level)||'Printing data of l_receiving_org_val_tbl count :'|| l_receiving_org_val_tbl.count);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

            FOR debug_cntr2 in 1..l_receiving_org_val_tbl.count LOOP
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_receiving_org_val_tbl('||debug_cntr2||').null_element :' || l_receiving_org_val_tbl(debug_cntr2).null_element );
            END LOOP;

            oe_debug_pub.add(lpad(' ',g_pg_level)||'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

            oe_debug_pub.add(lpad(' ',g_pg_level)||'Printing data of l_shipping_org_tbl count :'|| l_shipping_org_tbl.count);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'**********************************************************************************');

            FOR debug_cntr3 in 1..l_shipping_org_tbl.count LOOP
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Sr_Source_Id :' || l_shipping_org_tbl(debug_cntr3).Sr_Source_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Allocation_Percent :' || l_shipping_org_tbl(debug_cntr3).Allocation_Percent );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute1 :' || l_shipping_org_tbl(debug_cntr3).Attribute1 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute10 :' || l_shipping_org_tbl(debug_cntr3).Attribute10 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute11 :' || l_shipping_org_tbl(debug_cntr3).Attribute11 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute12 :' || l_shipping_org_tbl(debug_cntr3).Attribute12 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute13 :' || l_shipping_org_tbl(debug_cntr3).Attribute13 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute14 :' || l_shipping_org_tbl(debug_cntr3).Attribute14 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute15 :' || l_shipping_org_tbl(debug_cntr3).Attribute15 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute2 :' || l_shipping_org_tbl(debug_cntr3).Attribute2 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute3 :' || l_shipping_org_tbl(debug_cntr3).Attribute3 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute4 :' || l_shipping_org_tbl(debug_cntr3).Attribute4 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute5 :' || l_shipping_org_tbl(debug_cntr3).Attribute5 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute6 :' || l_shipping_org_tbl(debug_cntr3).Attribute6 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute7 :' || l_shipping_org_tbl(debug_cntr3).Attribute7 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute8 :' || l_shipping_org_tbl(debug_cntr3).Attribute8 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute9 :' || l_shipping_org_tbl(debug_cntr3).Attribute9 );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Attribute_Category :' || l_shipping_org_tbl(debug_cntr3).Attribute_Category );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Created_By :' || l_shipping_org_tbl(debug_cntr3).Created_By );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Creation_Date :' || l_shipping_org_tbl(debug_cntr3).Creation_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Last_Updated_By :' || l_shipping_org_tbl(debug_cntr3).Last_Updated_By );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Last_Update_Date :' || l_shipping_org_tbl(debug_cntr3).Last_Update_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Last_Update_Login :' || l_shipping_org_tbl(debug_cntr3).Last_Update_Login );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Program_Application_Id :' || l_shipping_org_tbl(debug_cntr3).Program_Application_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Program_Id :' || l_shipping_org_tbl(debug_cntr3).Program_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Program_Update_Date :' || l_shipping_org_tbl(debug_cntr3).Program_Update_Date );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Rank :' || l_shipping_org_tbl(debug_cntr3).Rank );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Request_Id :' || l_shipping_org_tbl(debug_cntr3).Request_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Secondary_Inventory :' || l_shipping_org_tbl(debug_cntr3).Secondary_Inventory );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Ship_Method :' || l_shipping_org_tbl(debug_cntr3).Ship_Method );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Source_Organization_Id :' || l_shipping_org_tbl(debug_cntr3).Source_Organization_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Source_Type :' || l_shipping_org_tbl(debug_cntr3).Source_Type );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Sr_Receipt_Id :' || l_shipping_org_tbl(debug_cntr3).Sr_Receipt_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Vendor_Id :' || l_shipping_org_tbl(debug_cntr3).Vendor_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Vendor_Site_Id :' || l_shipping_org_tbl(debug_cntr3).Vendor_Site_Id );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').return_status :' || l_shipping_org_tbl(debug_cntr3).return_status );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').db_flag :' || l_shipping_org_tbl(debug_cntr3).db_flag );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').operation :' || l_shipping_org_tbl(debug_cntr3).operation );
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_tbl('||debug_cntr3||').Receiving_Org_index :' || l_shipping_org_tbl(debug_cntr3).Receiving_Org_index );
            END LOOP;

            oe_debug_pub.add(lpad(' ',g_pg_level)||'**********************************************************************************');

            oe_debug_pub.add(lpad(' ',g_pg_level)||'Printing data of l_shipping_org_val_tbl count :'|| l_shipping_org_val_tbl.count);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

            FOR debug_cntr4 in 1..l_shipping_org_val_tbl.count LOOP
                oe_debug_pub.add(lpad(' ',g_pg_level)||'l_shipping_org_val_tbl('||debug_cntr4||').null_element :' || l_shipping_org_val_tbl(debug_cntr4).null_element );
            END LOOP;

            oe_debug_pub.add(lpad(' ',g_pg_level)||'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
         END If;

         MRP_SOURCING_RULE_PUB.PROCESS_SOURCING_RULE(
	                                      p_api_version_number    => 1.0,
					      p_return_values         => FND_API.G_TRUE,
					      p_sourcing_rule_rec     => l_sourcing_rule_rec,
					      p_sourcing_rule_val_rec => l_sourcing_rule_val_rec,
					      p_receiving_org_tbl     => l_receiving_org_tbl,
					      p_receiving_org_val_tbl => l_receiving_org_val_tbl,
					      p_shipping_org_tbl      => l_shipping_org_tbl,
					      p_shipping_org_val_tbl  => l_shipping_org_val_tbl,
					      x_sourcing_rule_rec     => x_sourcing_rule_rec,
					      x_sourcing_rule_val_rec => x_sourcing_rule_val_rec,
					      x_receiving_org_tbl     => x_receiving_org_tbl,
					      x_receiving_org_val_tbl => x_receiving_org_val_tbl,
  				              x_shipping_org_tbl      => x_shipping_org_tbl,
					      x_shipping_org_val_tbl  => x_shipping_org_val_tbl,
					      x_return_status         => x_return_status,
					      x_msg_count             => x_msg_count,
					      x_msg_data              => x_msg_data);

         FOR l_index IN 1..x_msg_count LOOP
             l_msg_data := fnd_msg_pub.get(
                      p_msg_index => l_index,
                      p_encoded  => FND_API.G_FALSE);
             oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: error : '||substr(l_msg_data,1,250));
         END LOOP;

         If x_return_status  = FND_API.G_RET_STS_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'CREATE_OSS_SOURCING_RULES: Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'CREATE_OSS_SOURCING_RULES: Un Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         End if;

         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: New sourcing Rule created  = '
                                                 ||x_sourcing_rule_rec.sourcing_rule_id,5);
         End if;

         lAssignmentTbl(asg_count).sourcing_rule_id    := x_sourcing_rule_rec.sourcing_rule_id;
         l_assignment_set_id                           := lAssignmentTbl(asg_count).assignment_set_id;
         Asg_count := asg_count + 1;
         l_receiving_org_tbl.delete;
         l_receiving_org_val_tbl.delete;
         l_shipping_org_tbl.delete;
         l_shipping_org_val_tbl.delete;
         l_new_rank_seq := 0;
         rcv_count      := 1;
         i              := 1;
         l_old_rank     :=null;

      End if;


      /* Now this is the time to generate the assignments which we have created so far */
      /* Now we will create 100% make rule if anytning needs to be created. first we will check
         if we need to create 100% make at rule or not. When we have inserted a row for 100% make at
         we will insert with source_rule_id as null. Check if there is any row exists with that .
      */

      l_stmt_num := 200;

      If PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: '||'Before make orgs loop ',5);
      End if;

      For oss_make_orgs in
oss_make_orgs_cur(oss_model_lines_rec.line_id,oss_model_lines_rec.config_item_id)
      Loop


         oe_debug_pub.add('Inside make at rule loop ',5);
	 l_stmt_num := 210;

         l_sourcing_rule_rec := MRP_SOURCING_RULE_PUB.G_MISS_SOURCING_RULE_REC;
         l_sourcing_rule_rec.organization_id := oss_make_orgs.rcv_org_id;
         l_sourcing_rule_rec.status := 1;
         l_sourcing_rule_rec.planning_active := 1;
         select 'CTO*'||bom_cto_oss_source_rule_s1.nextval
         into    l_sourcing_rule_rec.sourcing_rule_name
         from    dual;

         l_sourcing_rule_rec.Sourcing_rule_type := 1;

/*
         select mrp_sourcing_rules_s.nextval
         into   l_sourcing_rule_rec.sourcing_rule_id
         from dual;
*/

         l_sourcing_rule_rec.operation := MRP_Globals.G_OPR_CREATE;

         l_receiving_org_tbl.delete;


         l_receiving_org_tbl(1).effective_date := sysdate;

         l_receiving_org_tbl(1).receipt_organization_id := oss_make_orgs.rcv_org_id;
       --  l_receiving_org_tbl(1).sourcing_rule_id        := l_sourcing_rule_rec.sourcing_rule_id;
         l_receiving_org_tbl(1).operation               := MRP_Globals.G_OPR_CREATE;


         l_shipping_org_tbl.delete;




         l_shipping_org_tbl(1).allocation_percent     := oss_make_orgs.allocation;
         l_shipping_org_tbl(1).rank                   := oss_make_orgs.rank;
         l_shipping_org_tbl(1).source_organization_id := oss_make_orgs.source_org_id;
         l_shipping_org_tbl(1).Source_type            := 2;
         l_shipping_org_tbl(1).receiving_org_index    := 1;
         l_shipping_org_tbl(1).operation              := MRP_Globals.G_OPR_CREATE;



         l_stmt_num := 220;

         MRP_SOURCING_RULE_PUB.PROCESS_SOURCING_RULE(
	                                      p_api_version_number    => 1.0,
					      p_return_values         => FND_API.G_TRUE,
					      p_commit                => FND_API.G_FALSE,
					      p_sourcing_rule_rec     => l_sourcing_rule_rec,
					      p_sourcing_rule_val_rec => l_sourcing_rule_val_rec,
					      p_receiving_org_tbl     => l_receiving_org_tbl,
					      p_receiving_org_val_tbl => l_receiving_org_val_tbl,
					      p_shipping_org_tbl      => l_shipping_org_tbl,
					      p_shipping_org_val_tbl  => l_shipping_org_val_tbl,
					      x_sourcing_rule_rec     => x_sourcing_rule_rec,
					      x_sourcing_rule_val_rec => x_sourcing_rule_val_rec,
					      x_receiving_org_tbl     => x_receiving_org_tbl,
					      x_receiving_org_val_tbl => x_receiving_org_val_tbl,
  				              x_shipping_org_tbl      => x_shipping_org_tbl,
					      x_shipping_org_val_tbl  => x_shipping_org_val_tbl,
					      x_return_status         => x_return_status,
					      x_msg_count             => x_msg_count,
					      x_msg_data              => x_msg_data);

         If x_return_status  = FND_API.G_RET_STS_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'CREATE_OSS_SOURCING_RULES: Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'CREATE_OSS_SOURCING_RULES: Un Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         End if;


         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Loading the assignment into assignment record ',5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCNIG_RULES: assignment_type = '
                                                 ||'6',5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: inventory item id = '
                                                 ||oss_model_lines_rec.config_item_id,5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: organization id = '
                                                 ||oss_make_orgs.rcv_org_id,5);


         End if;

         lAssignmentTbl(asg_count).assignment_set_id   := G_def_assg_set;
         lAssignmentTbl(asg_count).assignment_type     := 6;
         lAssignmentTbl(asg_count).inventory_item_id   := oss_model_lines_rec.config_item_id;
         lAssignmentTbl(asg_count).organization_id     := oss_make_orgs.rcv_org_id;
         lAssignmentTbl(asg_count).sourcing_rule_type  := 1;
         lAssignmentTbl(asg_count).sourcing_rule_id    := x_sourcing_rule_rec.sourcing_rule_id;
         lAssignmentTbl(asg_count).operation           := MRP_Globals.G_OPR_CREATE;

         asg_count := asg_count + 1;



      End Loop;

      l_stmt_num := 230;


      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: '||'Before reuse org loop ',5);
      End if;

      For oss_reused_assg_rec in
oss_reused_assg(oss_model_lines_rec.line_id,oss_model_lines_rec.config_item_id)
      Loop


         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'Inside Reuse assignments loop',5);
	    oe_debug_pub.add(lpad(' ',g_pg_level)||'Assignment id = '||oss_reused_assg_rec.assignment_id,5);
	 End if;

         l_Stmt_Num := 240;

         --
         -- bug 6617686
         -- The MRP API uses a  ASSIGNMENT_ID = p_Assignment_Id OR
         -- ASSIGNMENT_SET_ID = p_Assignment_Set_Id that leads to
         -- a full table scan on MRP_SR_ASSIGNMENTS and consequent
         -- performance issues. Since CTO does not pass ASSIGNMENT_SET_ID
         -- into the procedure, it is performance effective to directly
         -- query the MRP table
         -- ntungare
         --
         -- lAssignmentRec := MRP_Assignment_Handlers.Query_Row(oss_reused_assg_rec.assignment_id);

         SELECT  ASSIGNMENT_ID
         ,       ASSIGNMENT_SET_ID
         ,       ASSIGNMENT_TYPE
         ,       ATTRIBUTE1
         ,       ATTRIBUTE10
         ,       ATTRIBUTE11
         ,       ATTRIBUTE12
         ,       ATTRIBUTE13
         ,       ATTRIBUTE14
         ,       ATTRIBUTE15
         ,       ATTRIBUTE2
         ,       ATTRIBUTE3
         ,       ATTRIBUTE4
         ,       ATTRIBUTE5
         ,       ATTRIBUTE6
         ,       ATTRIBUTE7
         ,       ATTRIBUTE8
         ,       ATTRIBUTE9
         ,       ATTRIBUTE_CATEGORY
         ,       CATEGORY_ID
         ,       CATEGORY_SET_ID
         ,       CREATED_BY
         ,       CREATION_DATE
         ,       CUSTOMER_ID
         ,       INVENTORY_ITEM_ID
         ,       LAST_UPDATED_BY
         ,       LAST_UPDATE_DATE
         ,       LAST_UPDATE_LOGIN
         ,       ORGANIZATION_ID
         ,       PROGRAM_APPLICATION_ID
         ,       PROGRAM_ID
         ,       PROGRAM_UPDATE_DATE
         ,       REQUEST_ID
         ,       SECONDARY_INVENTORY
         ,       SHIP_TO_SITE_ID
         ,       SOURCING_RULE_ID
         ,       SOURCING_RULE_TYPE
         into    lAssignmentRec.ASSIGNMENT_ID
         ,       lAssignmentRec.ASSIGNMENT_SET_ID
         ,       lAssignmentRec.ASSIGNMENT_TYPE
         ,       lAssignmentRec.ATTRIBUTE1
         ,       lAssignmentRec.ATTRIBUTE10
         ,       lAssignmentRec.ATTRIBUTE11
         ,       lAssignmentRec.ATTRIBUTE12
         ,       lAssignmentRec.ATTRIBUTE13
         ,       lAssignmentRec.ATTRIBUTE14
         ,       lAssignmentRec.ATTRIBUTE15
         ,       lAssignmentRec.ATTRIBUTE2
         ,       lAssignmentRec.ATTRIBUTE3
         ,       lAssignmentRec.ATTRIBUTE4
         ,       lAssignmentRec.ATTRIBUTE5
         ,       lAssignmentRec.ATTRIBUTE6
         ,       lAssignmentRec.ATTRIBUTE7
         ,       lAssignmentRec.ATTRIBUTE8
         ,       lAssignmentRec.ATTRIBUTE9
         ,       lAssignmentRec.ATTRIBUTE_CATEGORY
         ,       lAssignmentRec.CATEGORY_ID
         ,       lAssignmentRec.CATEGORY_SET_ID
         ,       lAssignmentRec.CREATED_BY
         ,       lAssignmentRec.CREATION_DATE
         ,       lAssignmentRec.CUSTOMER_ID
         ,       lAssignmentRec.INVENTORY_ITEM_ID
         ,       lAssignmentRec.LAST_UPDATED_BY
         ,       lAssignmentRec.LAST_UPDATE_DATE
         ,       lAssignmentRec.LAST_UPDATE_LOGIN
         ,       lAssignmentRec.ORGANIZATION_ID
         ,       lAssignmentRec.PROGRAM_APPLICATION_ID
         ,       lAssignmentRec.PROGRAM_ID
         ,       lAssignmentRec.PROGRAM_UPDATE_DATE
         ,       lAssignmentRec.REQUEST_ID
         ,       lAssignmentRec.SECONDARY_INVENTORY
         ,       lAssignmentRec.SHIP_TO_SITE_ID
         ,       lAssignmentRec.SOURCING_RULE_ID
         ,       lAssignmentRec.SOURCING_RULE_TYPE
         FROM    MRP_SR_ASSIGNMENTS
         WHERE   ASSIGNMENT_ID = oss_reused_assg_rec.assignment_id;

         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: Loading the assignment into assignment record ',5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCNIG_RULES: assignment_type = '
                                                 ||lAssignmentRec.Assignment_Type,5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: inventory item id = '
                                                 ||oss_model_lines_rec.config_item_id,5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: organization id = '
                                                 ||lAssignmentRec.Organization_Id,5);
         End if;

         l_Stmt_Num := 245;
         lAssignmentTbl(asg_count).Assignment_Set_Id     := G_def_assg_set;
         lAssignmentTbl(asg_count).Assignment_Type       := lAssignmentRec.Assignment_Type;
         lAssignmentTbl(asg_count).Attribute1            := lAssignmentRec.Attribute1;
         lAssignmentTbl(asg_count).Attribute10           := lAssignmentRec.Attribute10;
         lAssignmentTbl(asg_count).Attribute11           := lAssignmentRec.Attribute11;
         lAssignmentTbl(asg_count).Attribute12           := lAssignmentRec.Attribute12;
         lAssignmentTbl(asg_count).Attribute13           := lAssignmentRec.Attribute13;
         lAssignmentTbl(asg_count).Attribute14           := lAssignmentRec.Attribute14;
         lAssignmentTbl(asg_count).Attribute15           := lAssignmentRec.Attribute15;
         lAssignmentTbl(asg_count).Attribute2            := lAssignmentRec.Attribute2;
         lAssignmentTbl(asg_count).Attribute3            := lAssignmentRec.Attribute3;
         lAssignmentTbl(asg_count).Attribute4            := lAssignmentRec.Attribute4;
         lAssignmentTbl(asg_count).Attribute5            := lAssignmentRec.Attribute5;
         lAssignmentTbl(asg_count).Attribute6            := lAssignmentRec.Attribute6;
         lAssignmentTbl(asg_count).Attribute7            := lAssignmentRec.Attribute7;
         lAssignmentTbl(asg_count).Attribute8            := lAssignmentRec.Attribute8;
         lAssignmentTbl(asg_count).Attribute9            := lAssignmentRec.Attribute9;
         lAssignmentTbl(asg_count).Attribute_Category    := lAssignmentRec.Attribute_Category;
         lAssignmentTbl(asg_count).Category_Id           := lAssignmentRec.Category_Id ;
         lAssignmentTbl(asg_count).Category_Set_Id       := lAssignmentRec.Category_Set_Id;
         lAssignmentTbl(asg_count).Created_By            := lAssignmentRec.Created_By;
         lAssignmentTbl(asg_count).Creation_Date         := lAssignmentRec.Creation_Date;
         lAssignmentTbl(asg_count).Customer_Id           := lAssignmentRec.Customer_Id;
         lAssignmentTbl(asg_count).Inventory_Item_Id     := oss_model_lines_rec.config_item_id;
         lAssignmentTbl(asg_count).Last_Updated_By       := lAssignmentRec.Last_Updated_By;
         lAssignmentTbl(asg_count).Last_Update_Date      := lAssignmentRec.Last_Update_Date;
         lAssignmentTbl(asg_count).Last_Update_Login     := lAssignmentRec.Last_Update_Login;
         lAssignmentTbl(asg_count).Organization_Id       := lAssignmentRec.Organization_Id;
         lAssignmentTbl(asg_count).Program_Application_Id:= lAssignmentRec.Program_Application_Id;
         lAssignmentTbl(asg_count).Program_Id            := lAssignmentRec.Program_Id;
         lAssignmentTbl(asg_count).Program_Update_Date   := lAssignmentRec.Program_Update_Date;
         lAssignmentTbl(asg_count).Request_Id            := lAssignmentRec.Request_Id;
         lAssignmentTbl(asg_count).Secondary_Inventory   := lAssignmentRec.Secondary_Inventory;
         lAssignmentTbl(asg_count).Ship_To_Site_Id       := lAssignmentRec.Ship_To_Site_Id;
         lAssignmentTbl(asg_count).Sourcing_Rule_Id      := lAssignmentRec.Sourcing_Rule_Id;
         lAssignmentTbl(asg_count).Sourcing_Rule_Type    := lAssignmentRec.Sourcing_Rule_Type;
         lAssignmentTbl(asg_count).return_status         := NULL;
         lAssignmentTbl(asg_count).db_flag               := NULL;
         lAssignmentTbl(asg_count).operation             := MRP_Globals.G_OPR_CREATE;

         asg_count := asg_count + 1;


      End Loop; /* oss_reused_assg_rec in oss_reused_assg(oss_model_lines_rec.line_id) */

    --Bugfix 13324638
     <<loop_oss_model_lines>>
     EXIT WHEN oss_model_lines%NOTFOUND;

   End Loop; /*oss_model_lines_rec in oss_model_lines */






   l_stmt_num := 250;

   If pg_debug <> 0 then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: assignment count = '|| lAssignmentTbl.count,5);
   End if;


   If lAssignmentTbl.count <> 0 Then
   MRP_Src_Assignment_PUB.Process_Assignment
		(   p_api_version_number	=> 1.0
		,   x_return_status		=> x_return_status
		,   x_msg_count 		=> x_msg_count
		,   x_msg_data  		=> x_msg_data
		,   p_Assignment_Set_rec 	=> lAssignmentSetRec
		,   p_Assignment_tbl  		=> lAssignmentTbl
		,   x_Assignment_Set_rec  	=> xAssignmentSetRec
		,   x_Assignment_Set_val_rec	=> xAssignmentSetValRec
		,   x_Assignment_tbl   		=> xAssignmentTbl
		,   x_Assignment_val_tbl  	=> xAssignmentValTbl
		);
    FOR l_index IN 1..x_msg_count LOOP
       l_msg_data := fnd_msg_pub.get(
                      p_msg_index => l_index,
                      p_encoded  => FND_API.G_FALSE);
       oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES: error : '||substr(l_msg_data,1,250));
   END LOOP;
   If x_return_status  = FND_API.G_RET_STS_ERROR Then
      IF PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'CREATE_OSS_SOURCING_RULES: Exepected error occurred in update_oss_in_bcol API',5);
      End if;
      raise FND_API.G_EXC_ERROR;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
      IF PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'CREATE_OSS_SOURCING_RULES: Un Exepected error occurred in update_oss_in_bcol API',5);
      End if;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

   End if;

   If p_mode = 'UPG' then

      update mtl_system_items msi
      set    msi.option_specific_sourced = (select bcol.option_specific
                                            from   bom_cto_order_lines_upg bcol
                                            where  bcol.ato_line_id= p_ato_line_id
                                            and    bcol.config_item_id = msi.inventory_item_id
                                           )
         --Bugfix 12917456: Adding a distinct. This sql otherwise returns ORA-01427 error
         --when a top level config has the same child config appearing in its BOM multiple
         --times.
         where  msi.inventory_item_id in (select distinct config_item_id
                                       from   bom_cto_order_lines_upg
                                       where  ato_line_id = p_ato_line_id
                                       and    bom_item_type = 1
                                       and    option_specific in ('1','2','3')
                                      );
  elsif p_mode = 'ACC' Then
      update mtl_system_items msi
      set    msi.option_specific_sourced = (select bcol.option_specific
                                            from   bom_cto_order_lines bcol
                                            where  bcol.ato_line_id=p_ato_line_id
                                            and    bcol.config_item_id =msi.inventory_item_id
                                           )
      where  msi.inventory_item_id in (select config_item_id
                                       from   bom_cto_order_lines
                                       where  ato_line_id = p_ato_line_id
                                       and    bom_item_type = 1
                                       and    option_specific in ('1','2','3')
                                      );

  end if;

 Exception

    WHEN FND_API.G_EXC_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCNIG_RULES::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
    WHEN OTHERS THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_OSS_SOURCING_RULES::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_pg_level := g_pg_level - 3;
       cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End Create_oss_sourcing_rules;



Procedure  update_Source_tree(p_line_id       IN Number,
                              p_end_org       IN  Number,
                              x_return_status OUT NOCOPY Varchar2 ,
                              x_msg_data      OUT NOCOPY Varchar2,
                              x_msg_count     OUT NOCOPY Number
                             ) is

  l_rcv_org_id   Number;
  TYPE org_id_tbl is TABLE of Number index by binary_integer;

  l_org_tbl      org_id_tbl;
  l_stmt_num     Number;


Begin

  l_stmt_num := 10;
  g_pg_level := g_pg_level + 3;

  If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_SOURCE_TREE: Inside Update Source Tree API',5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_SOURCE_TREE: Line id ='||p_line_id,5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_SOURCE_TREE: Org  id ='||p_end_org,5);
  End if;
  If p_line_id is null  and p_end_org is null then
    return;
  end if;
  l_stmt_num := 120;

  update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
         bom_cto_oss_source_gt oss_src
  set    valid_flag = 'Y'
  where  source_org_id = p_end_org
  and    line_id       = p_line_id
  and    nvl(leaf_node,'N') <> 'Y'
  returning rcv_org_id bulk collect into l_org_tbl;

  If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_SOURCE_TREE: Number parent orgs = '||l_org_tbl.count,5);
  End if;

/* Need to work for Cutomer rules... */

  IF l_org_tbl.count <> 0 then
    For i in l_org_tbl.first..l_org_tbl.last
    Loop
       update_source_tree(p_line_id       => p_line_id,
                          p_end_org       => l_org_tbl(i),
                          x_return_status => x_return_status,
                          x_msg_data      => x_msg_data,
                          x_msg_count     => x_msg_count
		         );
       If x_return_status  = FND_API.G_RET_STS_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'UPDATE_SOURCE_TREE: Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'UPDATE_SOURCE_TREE: Un Exepected error occurred in update_oss_in_bcol API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       End if;

    End loop;
  End if;
g_pg_level := g_pg_level - 3;
End update_Source_tree;

/* The following procedure will prune the item level rule for parent oss

   1. For parent oss configurations, If there is an item level rule, we should
      prune the item level rule first.
   2. Pruning the item level rule means, find the all leaf nodes in the item level
      rule and check if the leaf node org is part of the intersection list.
   3. If the leaf node is part of the intersection list, mark that node as valid
      and also mark all the parent nodes as valid. This will make the whole chain as
      valid one.
   4. This should be done for all the leaf nodes in the item level rule.
   5. After pruning the item level rule, check if any thing is marked as valid node.
   6. If nothing found as valid node, then this means the puring resulted in no valid
      item level sourcing chain.
   7. In that case, the reset of the sourcing tree should be pruned with usual logic.
   8. After pruing the item level rule, if we end up having some valid nodes, do the following.
   9. Mark all the leaf nodes as valid which are one of the following.
       a. The source type is buy(3).
       b. It is a leaf node and is a transfer type
       c. It is a leaf node with make at rule and the org is part of the intersection list.
   10. Once the valid leaf nodes are found, mark all its parent sourcing chain as valid
   11. At the end all the valid nodes will form the config sourcing tree.

*/

Procedure prune_item_level_rule(p_model_line_id   IN  Number,
                                p_model_item_id   IN  Number,
				x_rule_exists     OUT NOCOPY Varchar2,
				x_return_status   OUT NOCOPY Varchar2,
				x_msg_count       OUT NOCOPY Number,
				x_msg_data        OUT NOCOPY varchar2
			       ) is

    /* The following cursor will get all the root nodes for item level
       sourcing tree
     */

    Cursor global_orgs_cur  is
    Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
           source_org_id
    from   bom_cto_oss_source_gt oss_src
    where  customer_id is null
    and    rcv_org_id is null
    and    line_id    = p_model_line_id
    and    nvl(valid_flag,'Y') <> 'N';

    l_valid_count      Number;
    TYPE l_source_org_tbl_type is TABLE of Number;
    l_source_org_id    l_source_org_tbl_type;
    l_source_org_tbl   l_source_org_tbl_type;

Begin
    /* For each root item level rule node find the leaf node
       and see if the leaf node is part of intersection org

       Renga: We should implement bulk fetch from cursor and then
              FOR all for select  to improve the performance. Revisit this part
    */

    For global_orgs_rec in global_orgs_cur
    Loop
       Begin
          /* The following sql may not be needed as this will
	     be part of find_leaf_node itself
	   */
          select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	         source_org_id
	  bulk collect into   l_source_org_id
          from   bom_cto_oss_source_gt oss_src
          where  rcv_org_id = global_orgs_rec.source_org_id
          and    line_id    = p_model_line_id
          and    nvl(valid_flag,'Y') <> 'N';

          /* find Leaf node is a recursive procedure to find the leaf node
	  */

          For i in l_source_org_id.first..l_source_org_id.last
          Loop
	  Find_leaf_node(p_model_line_id => p_model_line_id,
	                 p_source_org_id => l_source_org_id(i),
			 p_rcv_org_id    => global_orgs_rec.source_org_id,
			 x_return_status => x_return_status,
			 x_msg_count     => x_msg_count,
			 x_msg_data      => x_msg_data);
          If x_return_status  = FND_API.G_RET_STS_ERROR Then
             IF PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'PRUNE_ITEM_LEVEL_RULE: Exepected error occurred in update_oss_in_bcol API',5);
             End if;
             raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
             IF PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'PRUNE_ITEM_LEVEL_RULE: Un Exepected error occurred in update_oss_in_bcol API',5);
             End if;
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          End if;
          End loop;

       End;

    End Loop;

    Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
           count(*)
    into   l_valid_count
    from   bom_cto_oss_source_gt oss_src
    where  line_id = p_model_line_id
    and    valid_flag ='Y';

    If l_valid_count > 0 then
       x_rule_exists := 'Y';
    else
       x_rule_exists := 'N';
    End if;

    If x_rule_exists = 'Y' then

       /* The following update will find all the
          valid leaf nodes.
          1. This will mark all the buy nodes as valid node.
          2  Mark all the end nodes which are of the type xfer as valid
          3. Mark all the make at nodes for whihc the org is part of intersection
             list as valid nodes.
       */

       Update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
              bom_cto_oss_source_gt oss_src
       set    leaf_node  = 'Y',
              valid_flag = 'Y'
       where
       line_id = p_model_line_id
       and nvl(valid_flag,'Y') <> 'N'
       and
       (source_type = 3
        or (    Source_type = 2
	    and source_org_id in (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
	                          organization_id
	                          from bom_cto_oss_orgslist_gt OSS_LIS
				  where line_id = p_model_line_id)
	    )
	or (    source_type = 1
	    and source_org_id not in
                        (Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
			        nvl(rcv_org_id,-1)
		         from   bom_cto_oss_source_gt oss_src
			 where  line_id = p_model_line_id
                         and    nvl(valid_flag,'Y') <> 'N')
           )
	)
       returning rcv_org_id bulk collect into l_source_org_tbl;


       oe_debug_pub.add(lpad(' ',g_pg_level)||'Prune_item_level_rule Updated
                                               valid leaf nodes = '||l_source_org_tbl.count,1);

       /* For all the above leaf nodes, traverse the tree up
          and update all the parents as valid
       */

       For i in l_source_org_tbl.first..l_source_org_tbl.last
       Loop
           If l_source_org_tbl(i) is not null then
              Traverse_up_tree(p_model_line_id  => p_model_line_id,
                               p_source_org_id  => l_source_org_tbl(i),
  		               p_valid_flag     => 'Y',
		               x_return_status  => x_return_status,
		               x_msg_count      => x_msg_count,
		               x_msg_data       => x_msg_data);
              If x_return_status  = FND_API.G_RET_STS_ERROR Then
                 IF PG_DEBUG <> 0 Then
                    oe_debug_pub.add(lpad(' ',g_pg_level)||
                              'PRUNE_ITEM_LEVEL_RULE: Exepected error occurred in update_oss_in_bcol API',5);
                 End if;
                 raise FND_API.G_EXC_ERROR;
              elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
                 IF PG_DEBUG <> 0 Then
                    oe_debug_pub.add(lpad(' ',g_pg_level)||
                        'PRUNE_ITEM_LEVEL_RULE: Un Exepected error occurred in update_oss_in_bcol API',5);
                 End if;
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
              End if;
           End if;

       End loop;
    Else /* X_rule_exists */
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PRUNE_ITEM_LEVEL_RULE: Updating bcol with option specific = 4',1);

       update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
              bom_cto_order_lines_gt bcol
       set    option_specific = 4
       where  line_id = p_model_line_id;

    End if; /* x_rule_exists = 'Y' */

    /* By this time, we have identified and marked all the valid nodes
       in the tree
    */


End Prune_item_level_rule;


Procedure Find_leaf_node( p_model_line_id   IN  Number,
                          p_source_org_id   IN  Number,
			  p_rcv_org_id      IN  Number,
			  x_return_status   OUT NOCOPY Varchar2,
			  x_msg_data        OUT NOCOPY Varchar2,
			  x_msg_count       OUT NOCOPY Number) is
   --l_source_org_id    Number;
   --l_source_type      Number;

   /*Bugfix 13362916 Changing the table type to refer to a record structure.
   TYPE v_num_type is table of number;

   l_source_org_id  v_num_type;
   l_source_type    v_num_type;
   */

   TYPE source_details_rec IS Record(l_source_org_id NUMBER,
                                     l_source_type   NUMBER);

   TYPE source_details_tab_typ IS TABLE OF source_details_rec INDEX BY BINARY_INTEGER;
   source_details_tab source_details_tab_typ;

   --Bugfix 13540153-FP(13360098)
   l_cnt  number;

Begin
   g_pg_level := nvl(g_pg_level,0)+3;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: Entering Find Leaf Node',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: P_source_org_id = '||p_source_org_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: P_rcv_org_id    = '||p_rcv_org_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: p_model_line_id    = '||p_model_line_id,5);
   End if;

   -- bug 13362916
   -- select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
   --       source_org_id,
   --       source_type
   --bulk collect into
   --       l_source_org_id,
   --       l_source_type
   --from   bom_cto_oss_source_gt oss_src
   --where  rcv_org_id = p_source_org_id
   --and    line_id    = p_model_line_id
   --and    nvl(valid_flag,'Y') <> 'N';

   SELECT /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
      source_org_id,
      source_type
   BULK COLLECT INTO source_details_tab
   FROM   bom_cto_oss_source_gt oss_src
   WHERE  rcv_org_id = p_source_org_id
   AND    line_id    = p_model_line_id
   AND    nvl(valid_flag,'Y') <> 'N';

   IF PG_DEBUG <> 0 Then
      -- bug 13362916
      -- oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: Source Org count = '||l_source_org_id.count,5);
      -- oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: Source Type count   = '||l_source_type.count,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: Source Details Tab count   = '||source_details_tab.count,5);
   End if;


   -- If l_source_type.count <> 0 then
   If source_details_tab.count <> 0 then
      --For i in l_source_type.first..l_source_type.last
      For i in 1..source_details_tab.count
      Loop
         IF PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: source_details_tab.l_source_type   = '||source_details_tab(i).l_source_type,5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'FIND_LEAF_NODE: source_details_tab.l_source_org_id = '||source_details_tab(i).l_source_org_id,5);
         End if;

         -- If l_source_type(i) not in (2,3) then
         If source_details_tab(i).l_source_type not in (2,3) then
            Find_leaf_node(P_model_line_id  => p_model_line_id,
                           p_source_org_id  => source_details_tab(i).l_source_org_id,
                           p_rcv_org_id     => p_source_org_id,
                           x_return_status  => x_return_status,
                           x_msg_data       => x_msg_data,
                           x_msg_count      => x_msg_count);

            If x_return_status  = FND_API.G_RET_STS_ERROR Then
               IF PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||
                                  'FIND_LEAF_NODE: Exepected error occurred in update_oss_in_bcol API',5);
               End if;
               raise FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
               IF PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||
                                  'FIND_LEAF_NODE: Un Exepected error occurred in update_oss_in_bcol API',5);
               End if;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            End if;
         End if;

         /*Bugfix 13540153-FP(13360098): Changing rcv_org_id to source_org_id and adding an nvl.
           1. Changing rcv_org_id to source_org_id: Consider the sourcing data for parent non OSS model as:
           ================PRINTING BOM_CTO_OSS_SOURCE_GT==================
           Line_id --- Item id --- Rcv org --- src org --- customer --- vendor --- vend site --- rank --- alloc% --- src type --- reuse -- valid --- leaf --- sr_receipt_id ---
           -99326 --- 3087074 ---  --- 122 ---  ---  ---  --- 1 --- 40 --- 1 ---  ---  ---  --- 213011
           -99326 --- 3087074 ---  --- 164 ---  ---  ---  --- 1 --- 35 --- 1 ---  ---  ---  --- 213011
           -99326 --- 3087074 ---  --- 304 ---  ---  ---  --- 1 --- 25 --- 1 ---  ---  ---  --- 213011
           -99326 --- 3087074 --- 122 --- 122 ---  ---  ---  --- 1 --- 100 --- 2 ---  ---  ---  --- 212002
           -99326 --- 3087074 --- 164 --- 164 ---  ---  ---  --- 1 --- 100 --- 2 ---  ---  ---  --- 213002
           -99326 --- 3087074 --- 304 --- 122 ---  ---  ---  --- 1 --- 60 --- 1 ---  ---  ---  --- 213004
           -99326 --- 3087074 --- 304 --- 164 ---  ---  ---  --- 1 --- 40 --- 1 ---  ---  ---  --- 213004
           ============== End printing ===============

           Consider the orgs eligible as per OSS on lower level children as:
           ================PRINTING BOM_CTO_ORGSLIST_GT==================
           Line id --- Ato Line Id --- Item Id --- Org id --- vendor --- vend site ---Make Flag
           -99326 --- -99326 --- 3087074 ---  ---  ---  ---
           -99326 --- -99326 --- 3087074 --- 146 ---  ---  ---
           -99326 --- -99326 --- 3087074 --- 164 ---  ---  ---
           -99326 --- -99326 --- 3087074 --- 304 ---  ---  ---
           ============== End printing ===============

           The below update sql was updating the 'rcv_org = 304, src_org = 122' record as valid even though
           org 122 is not valid as per OSS. Furthermore, the idea of this API is to find leaf nodes. These
           leaves would be the source_org values and not rcv_org values.

           2. Reason for adding nvl:
           This was very strange. Without nvl, the record 'rcv_org = 304, src_org = 122' was still being marked
           as valid. Added an nvl to get around this problem.
         */

	 update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
                bom_cto_oss_source_gt oss_src
         set    leaf_node  = 'Y',
                valid_flag = 'Y'
         where  line_id   = p_model_line_id
         and    source_org_id = p_source_org_id
         and    rcv_org_id    = p_rcv_org_id
         and    nvl(valid_flag,'Y') <> 'N'
         --Bugfix 13540153-FP(13360098)
	 --and    rcv_org_id   in (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
	 and    source_org_id   in (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
                                           --Bugfix 13540153-FP(13360098): Adding an nvl.
				           nvl(organization_id, -9999)
                                    from   bom_cto_oss_orgslist_gt oss_lis
                                    where  line_id = p_model_line_id);

         --Bugfix 13540153-FP(13360098)
         l_cnt := sql%rowcount;

	 --If sql%rowcount <> 0 then
	 If l_cnt <> 0 then
            Traverse_up_tree(p_model_line_id  => p_model_line_id,
                             p_source_org_id  => p_rcv_org_id,
                             p_valid_flag     => 'Y',
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data);
            If x_return_status  = FND_API.G_RET_STS_ERROR Then
               IF PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||
                                       'FIND_LEAF_NODE: Exepected error occurred in update_oss_in_bcol API',5);
               End if;
               raise FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
               IF PG_DEBUG <> 0 Then
                  oe_debug_pub.add(lpad(' ',g_pg_level)||
                                'FIND_LEAF_NODE: Un Exepected error occurred in update_oss_in_bcol API',5);
               End if;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            End if;

         End if;/* Sql%rowcount <> 0 then */
      End Loop;
   else
     IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('Inside else.. Find_leaf_node');
     END IF;

     update /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
            bom_cto_oss_source_gt oss_src
     set    leaf_node  = 'Y',
            valid_flag = 'Y'
     where  line_id   = p_model_line_id
     and    source_org_id = p_source_org_id
     and    rcv_org_id    = p_rcv_org_id
     and    nvl(valid_flag,'Y') <> 'N'
     -- Not touching this rcv_org_id value as was done in the if block. The piece of code
     -- is fragile and we would take the issues as and when they come. This sql might be
     -- a potential red flag in the future.
     and    rcv_org_id   in (select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
                                    --Bugfix 13540153-FP(13360098): Adding an nvl.
			            nvl(organization_id, -9999)
                             from   bom_cto_oss_orgslist_gt oss_lis
                             where  line_id = p_model_line_id);

     --Bugfix 13540153-FP(13360098)
     l_cnt := sql%rowcount;

     --If sql%rowcount <> 0 then
     If l_cnt <> 0 then
       Traverse_up_tree(p_model_line_id  => p_model_line_id,
                        p_source_org_id  => p_rcv_org_id,
                        p_valid_flag     => 'Y',
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data);
       If x_return_status  = FND_API.G_RET_STS_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
                                    'FIND_LEAF_NODE: Exepected error occurred in update_oss_in_bcol API',5);
         End if;
         raise FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
                             'FIND_LEAF_NODE: Un Exepected error occurred in update_oss_in_bcol API',5);
         End if;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       End if;

     End if;
   End if; /* l_source_type.count = 0 */
   g_pg_level := g_pg_level - 3;
End Find_leaf_node;


Procedure    Traverse_up_tree(p_model_line_id  IN  Number,
                              p_source_org_id  IN  Number,
		              p_valid_flag     IN  Varchar2,
		              x_return_status  OUT NOCOPY Varchar2,
		              x_msg_count      OUT NOCOPY Varchar2,
		              x_msg_data       OUT NOCOPY Number) is
   TYPE org_id_tbl is TABLE of Number;

   l_org_id_tbl      org_id_tbl;
   l_rcv_org_tbl     org_id_tbl;
   i                 Number;

Begin
   g_pg_level := g_pg_level + 3;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_UP_TREE: Entering Traverse up tree API',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_UP_TREE: Model Line id =
'||p_model_line_id,1);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_UP_TREE: Source Org id =
'||p_source_org_id,1);

   End if;

   update  /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
           bom_cto_oss_source_gt oss_src
   set     valid_flag = 'Y'
   where   line_id = p_model_line_id
   and     source_org_id = p_source_org_id
   and     nvl(valid_flag,'Y') <> 'N'
   and       source_type <> 2  /*Exclude make rules...*/
   returning source_org_id,rcv_org_id bulk collect into l_rcv_org_tbl, l_org_id_tbl;

   If PG_DEBUG <> 0 then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_TREE_UP: Number of parents updated = '||l_org_id_tbl.count,5);
   end if;

   If l_org_id_tbl.count <> 0 Then
      For i in l_org_id_tbl.first..l_org_id_tbl.last
      Loop

         oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_UP_TREE: Rcv org id = '||l_rcv_org_tbl(i),1);
	 oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_UP_TREE: Org id     = '||l_org_id_tbl(i),1);

         If l_rcv_org_tbl(i) <> l_org_id_tbl(i)
	    and l_rcv_org_tbl(i) is not null then


         Traverse_up_tree(p_model_line_id  => p_model_line_id,
                          p_source_org_id  => l_org_id_tbl(i),
	      	          p_valid_flag     => 'Y',
		          x_return_status  => x_return_status,
		          x_msg_count      => x_msg_count,
		          x_msg_data       => x_msg_data);
         if x_return_status  = FND_API.G_RET_STS_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'TRAVERSE_UP_TREE: Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
            IF PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'TRAVERSE_UP_TREE: Un Exepected error occurred in update_oss_in_bcol API',5);
            End if;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         End if;


	 null;

         End if;
      End Loop;
   End if;
   g_pg_level := g_pg_level - 3;
End Traverse_up_tree;

/*



   ********************************* DURING ATP ***************************************

                   The Following part of code is called during ATP

   ************************************************************************************




*/

/*
     This procedure is called from match API during ATP. This will not have
     any input parameter. This looks at the data from bom_cto_order_lines_gt temp table
     and process all the OSS configurations to get the list of valid orgs and
     vendors.
*/

Procedure  Get_OSS_Orgs_list(
               x_oss_orgs_list  OUT  NOCOPY CTO_OSS_SOURCE_PK.oss_orgs_list_rec_type,
               x_return_status  OUT  NOCOPY Varchar2,
               x_msg_data       OUT  NOCOPY Varchar2,
               x_msg_count      OUT  NOCOPY Number) is

  l_temp   number:=0;
  l_stmt_num number    := 0;
Begin

   PG_DEBUG := 5;
   g_pg_level := 1;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 10;

   oe_debug_pub.add('=========================================================================',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('             START OPTION SPECIFIC SOURCE PROCESSING                     ',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('             START TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
   oe_debug_pub.add('                                                                         ',1);
   oe_debug_pub.add('=========================================================================',1);

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Begin GET_OSS_ORGS_LIST API',5);
   End if;

   delete from bom_cto_oss_source_gt ;
   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Number of records delete in source_gt = '
                                           ||sql%rowcount,5);
   end if;

   delete from bom_cto_oss_orgslist_gt;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Number of records delete in source_gt = '
                                           ||sql%rowcount,5);
   end if;

   g_def_assg_set := to_number(
                               FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

  /* Check if there is a default assignment set defined.
     If there is no default assignment set specified,
     OSS is not supported and CTO need not do anything.
  */


  If PG_DEBUG <> 0 then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Default Assignment set id = '
                                          ||g_def_assg_set);
  End if;

  If g_def_assg_set is null then
     If PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: There is no default assignment set Specified',4);
	oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Ending the call',4);
        oe_debug_pub.add('=========================================================================',1);
        oe_debug_pub.add('                                                                         ',1);
        oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
        oe_debug_pub.add('                                                                         ',1);
        oe_debug_pub.add('                                                                         ',1);
        oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
        oe_debug_pub.add('                                                                         ',1);
        oe_debug_pub.add('=========================================================================',1);

     End if;
     return;
  end if;


  /* Check to see if there is some OSS list specified for any model.
     Will check if there is some record exists in bom_cto_oss_components .
     If there is no record, then CTO need not do anything. This means the OSS orgs
     are not specified by user for any model. The following part of the code will
     check this.
  */

  l_stmt_num := 20;

  Declare
    l_check_flag varchar2(1);
  Begin
    Select 'X'
    into   l_check_flag
    from dual
    where exists (select 'x' from bom_cto_oss_components);

    If l_check_flag = 'X' then
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Some OSS Setup Exists',5);
      End if;
    end if;
  Exception when no_data_found then
    If PG_DEBUG <>0 then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: No OSS orgs defied in the system',4);
       oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Ending the call',4);
       oe_debug_pub.add('=========================================================================',1);
       oe_debug_pub.add('                                                                         ',1);
       oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
       oe_debug_pub.add('                                                                         ',1);
       oe_debug_pub.add('                                                                         ',1);
       oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
       oe_debug_pub.add('                                                                         ',1);
       oe_debug_pub.add('=========================================================================',1);

    End if;

    return;
  End;

  /* The following is the procedure to get the organization for all the model configruations
  */

  l_stmt_num := 30;

  get_configurations_org(
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data
		     );

  If x_return_status  = FND_API.G_RET_STS_ERROR Then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in get_configurations_org API',5);
     End if;
     raise FND_API.G_EXC_ERROR;
  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in get_configurations_org API',5);
     End if;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;

  /* The following is the procedure to get the organizations for all the ato items and
     matched configurations.
  */

  l_stmt_num := 40;

  get_ato_item_orgs(
                     p_assignment_id  => g_def_assg_set,
                     x_return_status  => x_return_status,
                     x_msg_count      => x_msg_count,
                     x_msg_data       => x_msg_data
		    );

  If x_return_status  = FND_API.G_RET_STS_ERROR Then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in get_configurations_org API',5);
     End if;
     raise FND_API.G_EXC_ERROR;
  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in get_configurations_org API',5);
     End if;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;



  l_stmt_num := 50;

  select line_id,
	 inventory_item_id,
	 ato_line_id,
	 organization_id,
	 vendor_id,
	 vendor_site_code,
         make_flag
  bulk collect into
         x_oss_orgs_list.line_id,
	 x_oss_orgs_list.inventory_item_id,
	 x_oss_orgs_list.ato_line_id,
	 x_oss_orgs_list.org_id,
	 x_oss_orgs_list.vendor_id,
	 x_oss_orgs_list.vendor_site,
	 x_oss_orgs_list.make_flag
  from   bom_cto_oss_orgslist_gt;


  If PG_DEBUG <> 0 Then
     If x_oss_orgs_list.line_id.count <> 0 Then
        For i in x_oss_orgs_list.line_id.first..x_oss_orgs_list.line_id.last
        Loop
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Line id     = '||x_oss_orgs_list.line_id(i),5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Org id      = '||x_oss_orgs_list.org_id(i),5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Vendor id   = '||x_oss_orgs_list.Vendor_id(i),5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Vendor Site = '||x_oss_orgs_list.vendor_site(i),5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Make Flag   = '||x_oss_orgs_list.make_flag(i),5);
        End loop;
      End if;
  End if;

  If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Number of records insert to output structure ='||sql%rowcount,4);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_ORGS_LIST: Ending the call',4);
  End if;


 oe_debug_pub.add('=========================================================================',1);
 oe_debug_pub.add('                                                                         ',1);
 oe_debug_pub.add('               END OPTION SPECIFIC SOURCE PROCESSING                     ',1);
 oe_debug_pub.add('                                                                         ',1);
 oe_debug_pub.add('                                                                         ',1);
 oe_debug_pub.add('               END TIME STAMP : '||to_char(sysdate,'hh:mi:ss')||'        ',1);
 oe_debug_pub.add('                                                                         ',1);
 oe_debug_pub.add('=========================================================================',1);


Exception

        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'Get_OSS_Orgs_list::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'Get_OSS_Orgs_list::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'Get_OSS_Orgs_list::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

END Get_OSS_Orgs_list;


/* This is the procdure to get the list of oss orgs for non matched configuration
   items
*/


Procedure get_configurations_org(
                      x_return_status  OUT NOCOPY Varchar2,
                      x_msg_count      OUT NOCOPY Number,
                      x_msg_data       OUT NOCOPY Varchar2) is

   Cursor  Oss_top_models is
       Select /*+ INDEX (bcol1 BOM_CTO_ORDER_LINES_GT_N5) */
              distinct bcol1.ato_line_id
       from   bom_cto_order_lines_gt bcol1
       where  exists (select /*+ INDEX (bcol1 BOM_CTO_ORDER_LINES_GT_N3) */
                              'X'
                      from    bom_cto_oss_components ossc,
                              bom_cto_order_lines_gt bcol2
                       where  bcol2.parent_ato_line_id = bcol1.line_id
                       and    ossc.model_item_id   =  bcol1.inventory_item_id
                       and    ossc.option_item_id  =  bcol2.inventory_item_id)
       and     bcol1.bom_item_type = '1'
       and     bcol1.wip_supply_type <> 6;

      /* The following cursor will get all the 'Option Specific sourced' model lines.
      The model config itself can be either oss or any of its child may be oss. This
      will bring all those lines for processing
   */

   Cursor oss_models(p_ato_line_id Number) is
     select /*+ INDEX (bcol1 BOM_CTO_ORDER_LINES_GT_N1) */
            line_id,
            ato_line_id,
            option_specific,
	    inventory_item_id,
	    config_item_id,
	    perform_match,
	    config_creation
     from   bom_cto_order_lines_gt
     where  ato_line_id = p_ato_line_id
     and    option_specific in ('1','2','3')
     order  by plan_level desc;


   L_comp_count     Number := 0;
   l_org_count      Number := 0;
   l_vendor_count   Number := 0;
   x_oss_exists     Varchar2(1);
   x_exp_error_code Number;

   l_stmt_no      Number := 0;

Begin

   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG : Entering Model Process',5);
   End if;

   /* Get the all models which has new config items created and the configuration
      has some oss orgs defined. The cursor definition resolves all the condition.
    */
   l_stmt_no := 10;

   FOR oss_top_model_rec in oss_top_models
   LOOP

      If PG_DEBUG <> 0 then
	 oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: ATO Line id ='
	                                      ||oss_top_model_rec.ato_line_id,5);
         oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: Processing top model line = '
                                              ||oss_top_model_rec.ato_line_id,5);
      End if;


      l_stmt_no := 20;

      update_oss_in_bcol(
                         p_ato_line_id   => oss_top_model_rec.ato_line_id,
			 x_oss_exists    => x_oss_exists,
			 x_return_status => x_return_status,
			 x_msg_data      => x_msg_data,
			 x_msg_count     => x_msg_count);
      If x_return_status  = FND_API.G_RET_STS_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Exepected error occurred in update_oss_in_bcol API',5);
         End if;
         raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
         IF PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||
	          'GET_OSS_ORGS_LIST: Un Exepected error occurred in update_oss_in_bcol API',5);
         End if;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if;


      If X_oss_exists = 'Y' Then

        If PG_DEBUG <> 0 Then
	   oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: This order line has some oss models',5);
	   oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: Start processing OSS Model bottom-up',5);
        End if;

        get_sourcing_data(
                         p_ato_line_id     => oss_top_model_rec.ato_line_id,
	                 x_return_status   => x_return_status,
			 x_msg_data        => x_msg_data,
			 x_msg_count       => x_msg_count);

        If x_return_status  = FND_API.G_RET_STS_ERROR Then

           IF PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||
	                   'GET_OSS_ORGS_LIST: Exepected error occurred in get_sourcing_data API',5);
           End if;
           raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
           IF PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||
	                'GET_OSS_ORGS_LIST: Un Exepected error occurred in get_sourcing_data API',5);
           End if;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if; /* x_return_status  = FND_API.G_RET_STS_ERROR */

        Process_order_for_oss(
                         p_ato_line_id   =>  oss_top_model_rec.ato_line_id,
			 p_calling_mode  =>  'ATP',
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

        If x_return_status  = FND_API.G_RET_STS_ERROR Then
           IF PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||
	                               'GET_CONFIGURATIONS_ORG: Exepected error occurred in update_oss_in_bcol API',5);
           End if;
           raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
           IF PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||
	                         'GET_CONFIGURATIONS_ORG: Un Exepected error occurred in update_oss_in_bcol API',5);
           End if;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;

     Else

        IF PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: This order line does not have any OSS configuration',5);
	End if;
     End if;

   END LOOP;

   delete from bom_cto_oss_orgslist_gt;

   l_stmt_no := 30;
   update bom_cto_oss_source_gt ossgt1
   set   reuse_flag = 'N'
   where  rcv_org_id is not null
   and    valid_flag = 'Y'
   and    not exists (select 'x'
                      from bom_cto_oss_source_gt ossgt2
                      where ossgt1.line_id = ossgt2.line_id
                      and   ossgt2.rcv_org_id = ossgt1.rcv_org_id
                      and   ossgt2.source_type = 2
                      and   ossgt2.valid_flag  = 'Y');


   l_stmt_no := 40;
   update bom_cto_oss_source_gt ossgt1
   set   reuse_flag = 'Y'
   where  rcv_org_id is not null
   and    valid_flag = 'Y'
   and    exists (select/*+ INDEX (ossgt2 BOM_CTO_OSS_SOURCE_GT_N2) */
                          'x'
                      from bom_cto_oss_source_gt ossgt2
                      where ossgt1.line_id = ossgt2.line_id
                      and   ossgt2.rcv_org_id = ossgt1.rcv_org_id
                      and   ossgt2.source_type = 2
                      and   ossgt2.valid_flag  = 'Y');


   l_stmt_no := 50;
   INSERT into bom_cto_oss_orgslist_gt(
         Inventory_item_id,
         line_id,
	 ato_line_id,
         organization_id,
         vendor_id,
         vendor_site_code,
	 make_flag)
   select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
           oss_src.inventory_item_id,
	   oss_src.line_id,
           bcol.ato_line_id,
	   oss_src.rcv_org_id,
	 --  oss_src.vendor_id,
	 --  oss_src.vendor_site_code,
           to_number(null), --3894241
           null,
	   reuse_flag
    from   bom_cto_oss_source_gt oss_src,
           bom_cto_order_lines_gt bcol
    where  bcol.line_id = oss_src.line_id
    and    oss_error_code is null
    and    oss_src.valid_flag  = 'Y'
    and    oss_src.rcv_org_id is not null
    and    nvl(bcol.option_specific,'4') <> '4'
   union
    select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
           oss_src.inventory_item_id,
           oss_src.line_id,
	   bcol.ato_line_id,
	   oss_src.source_org_id,
	  -- oss_src.vendor_id,
	  -- oss_src.vendor_site_code,
           to_number(null), --3894241
           null,
	   null
     from  bom_cto_oss_source_gt oss_src,
           bom_cto_order_lines_gt bcol
     where bcol.line_id = oss_src.line_id
     and   bcol.option_specific is not null
     and   oss_error_code is null
     and   oss_src.valid_flag = 'Y'
     and   oss_src.source_org_id is not null
     and   oss_src.source_org_id not in (select /*+ INDEX (oss_src1 BOM_CTO_OSS_SOURCE_GT_N2) */
                                                rcv_org_id
                                         from   bom_cto_oss_source_gt oss_src1
                                         where  oss_src1.line_id = oss_src.line_id
                                         and    valid_flag = 'Y'
					)
    and    nvl(bcol.option_specific,'4') <> '4'
   union
     select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
           oss_src.inventory_item_id,
           oss_src.line_id,
           bcol.ato_line_id,
           to_number(null),--3894241
           oss_src.vendor_id,
           oss_src.vendor_site_code,
           null
     from  bom_cto_oss_source_gt oss_src,
           bom_cto_order_lines_gt bcol
     where bcol.line_id = oss_src.line_id
     and   bcol.option_specific is not null
     and   oss_error_code is null
     and   oss_src.valid_flag = 'Y'
     and   oss_src.vendor_id is not null
     and    nvl(bcol.option_specific,'4') <> '4';


     g_pg_level := g_pg_level - 3;

     IF PG_DEBUG <> 0 THEN
        Print_source_gt;
        Print_orglist_gt;
     END IF;

Exception

        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: get_configurations_org::exp error::'
			      ||to_char(l_stmt_no)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: get_configurations_org::exp error::'
			      ||to_char(l_stmt_no)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_CONFIGURATIONS_ORG: get_configurations_org::exp error::'
			      ||to_char(l_stmt_no)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End get_configurations_org;


/* This is the procdure to get the list of oss orgs for  matched configuration
   items and ato items.
*/


Procedure get_ato_item_orgs(
                            p_assignment_id  IN  Number,
                            x_return_status  OUT NOCOPY varchar2,
                            x_msg_count      OUT NOCOPY Number,
                            x_msg_data       OUT NOCOPY Varchar2) is
  l_stmt_num    Number := 0;

Begin

  g_pg_level := g_pg_level + 3;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt_num := 10;

  If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ATO_ITEM_ORGS: Assignment set id = '||p_assignment_id);
  End if;

  /* The following sql will insert all the orgs and vendors from sourcing assignments
     and sourcing rules for ato item and matched configuration item
  */

  /* Renga Kannan: Changed ship_from_org_id reference to validation_org.
 *                  Here is the story. ATP team will not pass the ship
 *                  from org in the case of Global ATP. This has been decided
 *                  at the very end of our ST cycle and aggreed to pass null
 *                  value for ship from org in the case of Global ATP.
 *                  Since the ship from org id can be null, OSS code should not
 *                  depend on ship from org id in this API. But, ATP will
 *                  populate validtion org for the order line in all the cases.
 *                  Since we are using ship from org as an orbitrary org fo
 *                  getting option_specific_sourced flag value, We can use
 *                  validation_org instead.
 *                   */




  INSERT into bom_cto_oss_orgslist_gt(
         Inventory_item_id,
         line_id,
	 ato_line_id,
         organization_id,
         vendor_id,
         vendor_site_code)

  select /*+ FULL(bcol) */
         bcol.config_item_id,
         bcol.line_id,
	 bcol.ato_line_id,
         src.source_organization_id,
         src.VENDOR_ID,
         vend.VENDOR_SITE_CODE

  from   mrp_sr_receipt_org rcv,
         mrp_sr_source_org src,
         mrp_sr_assignments assg,
         bom_cto_order_lines_gt bcol,
         mtl_system_items msi,
         ap_supplier_sites_all vend

  where
         bcol.ato_line_id = bcol.line_id
  and    nvl(bcol.wip_supply_type,-1) <> 6
  and    bcol.top_model_line_id is null
  and    msi.inventory_item_id = bcol.config_item_id
  and    msi.organization_id  = bcol.validation_org
  and    msi.option_specific_sourced in('1','2','3')
  and    assg.assignment_set_id = p_assignment_id
  and    assg.customer_id is null
  and    assg.inventory_item_id = msi.inventory_item_id
  and    assg.sourcing_rule_id = rcv.sourcing_rule_id
  and    rcv.effective_date <= sysdate
  and    nvl(rcv.disable_date,sysdate+1)>sysdate
  and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
  and    src.vendor_site_id = vend.vendor_site_id(+)
  and    not exists (select 'X'
                     from   mrp_sr_assignments
		     where  inventory_item_id = bcol.config_item_id
		     and    organization_id is null
		     and    msi.option_specific_sourced = 3)
UNION
  select /*+ FULL(bcol) */
         bcol.config_item_id,
         bcol.line_id,
	 bcol.ato_line_id,
         assg.organization_id,
         to_number(null), --3894241
         null

  from   mrp_sr_assignments assg,
         bom_cto_order_lines_gt bcol,
         mtl_system_items msi

  where
         bcol.ato_line_id             =  bcol.line_id
  and    nvl(bcol.wip_supply_type,-1)<> 6
  and    bcol.top_model_line_id      is null
  and    msi.inventory_item_id        =  bcol.config_item_id
  and    msi.organization_id          =  bcol.validation_org
  and    msi.option_specific_sourced  in ('1','2','3')
  and    assg.assignment_set_id       =  p_assignment_id
  and    assg.customer_id             is null
  and    assg.inventory_item_id       =  msi.inventory_item_id
  and    not exists (select 'X'
                     from   mrp_sr_assignments
		     where  inventory_item_id = bcol.config_item_id
		     and    organization_id is null
		     and    msi.option_specific_sourced = 3)

UNION
  select /*+ FULL(bcol) */
         bcol.config_item_id,
         bcol.line_id,
	 bcol.ato_line_id,
         src.source_organization_id,
         src.VENDOR_ID,
         vend.VENDOR_SITE_CODE

  from   mrp_sr_receipt_org rcv,
         mrp_sr_source_org src,
         mrp_sr_assignments assg,
         bom_cto_order_lines_gt bcol,
         mtl_system_items msi,
         ap_supplier_sites_all vend

  where
         bcol.config_item_id is not null
  and    bcol.top_model_line_id is not null
  and    (bcol.perform_match in ('Y','C') or bcol.reuse_config = 'Y')
  and    bcol.config_creation = '3'
  and    nvl(bcol.wip_supply_type,-1) <> 6
  and    msi.inventory_item_id = bcol.config_item_id
  and    msi.organization_id  = bcol.validation_org
  and    msi.option_specific_sourced in('1','2','3')
  and    assg.assignment_set_id = p_assignment_id
  and    assg.customer_id is null
  and    assg.inventory_item_id = msi.inventory_item_id
  and    assg.sourcing_rule_id = rcv.sourcing_rule_id
  and    rcv.effective_date <= sysdate
  and    nvl(rcv.disable_date,sysdate+1)>sysdate
  and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
  and    src.vendor_site_id = vend.vendor_site_id(+)
  and    not exists (select 'X'
                     from   mrp_sr_assignments
		     where  inventory_item_id = bcol.config_item_id
		     and    organization_id is null
		     and    msi.option_specific_sourced = 3)

UNION
  select /*+ FULL(bcol) */
         bcol.config_item_id,
         bcol.line_id,
	 bcol.ato_line_id,
         assg.organization_id,
         to_number(null),--bugfix3894241
         null

  from   mrp_sr_assignments assg,
         bom_cto_order_lines_gt bcol,
         mtl_system_items msi

  where
         bcol.config_item_id is not null
  and    bcol.top_model_line_id is not null
  and    (bcol.perform_match in ('Y','C') or bcol.reuse_config = 'Y')
  and    bcol.config_creation = '3'
  and    nvl(bcol.wip_supply_type,-1)<> 6
  and    bcol.top_model_line_id      is null
  and    msi.inventory_item_id        =  bcol.config_item_id
  and    msi.organization_id          =  bcol.validation_org
  and    msi.option_specific_sourced  in ('1','2','3')
  and    assg.assignment_set_id       =  p_assignment_id
  and    assg.customer_id             is null
  and    assg.inventory_item_id       =  msi.inventory_item_id
  and    not exists (select 'X'
                     from   mrp_sr_assignments
		     where  inventory_item_id = bcol.config_item_id
		     and    organization_id is null
		     and    msi.option_specific_sourced = 3);


  If PG_DEBUG <> 0 Then
    oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ATO_ITEM_ORGS: Number of records inserted = '||sql%rowcount);
  End if;

  g_pg_level := g_pg_level - 3;

  --Bugfix 13362916
  IF PG_DEBUG <> 0 THEN
     Print_orglist_gt;
  END IF;

Exception

        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ATO_ITEM_ORGS::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ATO_ITEM_ORGS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ATO_ITEM_ORGS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End get_ato_item_orgs;

Procedure update_oss_in_bcol(
                              p_ato_line_id   IN         Number,
			      x_oss_exists    OUT NOCOPY Varchar2,
			      x_return_status OUT NOCOPY Varchar2,
			      x_msg_data      OUT NOCOPY Varchar2,
			      x_msg_count     OUT NOCOPY Number) is

   l_parent_ato_line_id         Number;

   TYPE parent_ato_line_tbl_type    is TABLE of Number INDEX  BY Binary_integer;

   l_parent_ato_line_tbl  parent_ato_line_tbl_type;
   i		          Number:=0;
   l_stmt_num             Number ;
   l_rows_updated         Number ;  --Bugfix 6710393


   /* The following cursor will get all the line from bom_cto_order_lines table.
      This curosr is used for creating bcol cache.
    */

   Cursor bcol_cur is
     select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
            line_id,
            ato_line_id,
	    parent_ato_line_id,
            option_specific,
	    perform_match
     from   bom_cto_order_lines_gt bcol
     where  ato_line_id  = p_ato_line_id;


  Cursor oss_line_cur is
     select  /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
             line_id,
             ato_line_id,
	     parent_ato_line_id,
	     option_specific
     from    bom_cto_order_lines_gt bcol
     where   ato_line_id  = p_ato_line_id
     and     option_specific = '1'
     order  by plan_level desc;

  lCnt number;  -- Bugfix 8894392


Begin

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   g_pg_level := g_pg_level + 3;

   IF PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: In UPDATE_OSS_BCOL API',5);
   End if;
   x_oss_exists :='Y';

   l_stmt_num := 10;

   update /*+ INDEX (bcol1 BOM_CTO_ORDER_LINES_GT_N1) */
          bom_cto_order_lines_gt bcol1
   set    option_specific = '1'
   where
         ato_line_id = p_ato_line_id
   and   exists (select /*+ INDEX (bcol2 BOM_CTO_ORDER_LINES_GT_N3) */
                         'X'
                 from    bom_cto_oss_components ossc,
                         bom_cto_order_lines_gt bcol2,
                         bom_cto_oss_orgs_list ossl
                 where  bcol2.parent_ato_line_id = bcol1.line_id
                 and    ossc.model_item_id   =  bcol1.inventory_item_id
                 and    ossc.option_item_id  =  bcol2.inventory_item_id
                 and    ossl.oss_comp_Seq_id = ossc.oss_comp_seq_id)
   and     nvl(bcol1.wip_supply_type,-1) <> 6 /* Talk to Sushant Sawant */
   and     bcol1.bom_item_type = 1
   returning parent_ato_line_id bulk collect into l_parent_ato_line_tbl;

   --Bugfix 6710393
   --Swaped the positions of if block with oe_debug_pub and sql%rowcount
   --else sql%rowcount will get rowcount of sql executed in oe_debug_pub.add api() api

   l_rows_updated := sql%rowcount;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: Number of OSS configuratinos = '
                                         ||l_rows_updated,5);
   End if;
   If l_rows_updated = 0 then
     IF PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: No OSS configuration exists..',5);
     End if;
     x_oss_exists := 'N';
     g_pg_level   := g_pg_level - 3;
     return;
   End if;

   /* Get the whole bcol data into a local cache. we will traverse in the cache
      instead of going to database. This is a table of records and is sparsed
      by line id
   */

   IF PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: Caching BCOL Data',5);
   End if;

   l_stmt_num := 20;

   FOR bcol_rec in bcol_cur
   Loop

      g_bcol_tbl(bcol_rec.line_id).line_id            := bcol_rec.line_id;
      g_bcol_tbl(bcol_rec.line_id).parent_ato_line_id := bcol_rec.parent_ato_line_id;
      g_bcol_tbl(bcol_rec.line_id).ato_line_id        := bcol_rec.ato_line_id;
      g_bcol_tbl(bcol_rec.line_id).option_specific    := bcol_rec.option_specific;
      g_bcol_tbl(bcol_rec.line_id).perform_match      := bcol_rec.perform_match;

   End Loop;



   /* The following part of the code will mark all the rows that are to be
      processed */

   /* Impact: The following traversal also not required */

      /* For the top model no need to traverse */


   IF PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: Falgging OSS for parents',5);
   End if;

   l_stmt_num := 30;

   For oss_line_rec in oss_line_cur
   Loop
      If oss_line_rec.line_id <> oss_line_rec.ato_line_id then
         update_parent_oss_line(p_parent_ato_line_id => oss_line_rec.parent_ato_line_id,
                                x_return_status      => x_return_status,
	    		        x_msg_count          => x_msg_count,
	 		        x_msg_data           => x_msg_data);

       End if;
   End Loop;


   l_stmt_num := 40;
   If g_parent_rec.line_id.count > 0 then
     FORALL i in g_parent_rec.line_id.first..g_parent_rec.line_id.last
      Update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
             bom_cto_order_lines_gt bcol
      set    option_specific = g_parent_rec.option_specific(i)
      where  line_id = g_parent_rec.line_id(i);
   end if;

   IF PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: Number of parent records updated = '
                                          ||g_parent_rec.line_id.count,5);
   End if;


   /* The following update statement will update all the rows where config item is
      matched and the config the item attribute is set to 3. In these cases, the
      opiton speicific source will be taken from config item. That will replace
      the flag determined earlier.
   */

   l_stmt_num := 50;
   -- Moving this update outside this procedure. Part of Bugfix 8894392.
   -- Reasoning: This sql updates the option_specific flag for matched CIB = 3 configs based on the
   -- value in msi for this config. For UPG, we are doing the processing again, so we don't need this.
   -- Moved this outside because wanted to keep the behaviour same for ACC and we do not have the p_mode
   -- parameter in this procedure.
   --update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
   /*     bom_cto_order_lines_gt bcol
   set    bcol.option_specific = (select msi.option_specific_sourced
                                  from   mtl_system_items msi
 	                          where  msi.inventory_item_id = bcol.config_item_id
			          and    rownum =1)
  where  bcol.perform_match = 'Y'*/   /* We need to add config creation condition here */
  /*and    bcol.config_creation = '3'
  and    bcol.ato_line_id   = p_ato_line_id;

   IF PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL: Number of matched configs with attribute settting 3 ='
                                          ||sql%rowcount,5);
   End if;*/

   l_stmt_num := 60;

   g_parent_rec.line_id.delete;
   g_parent_rec.option_specific.delete;

   g_pg_level := g_pg_level - 3;

Exception
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_OSS_IN_BCOL::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
End update_oss_in_bcol;


/*


   This procedure will find all the parent oss by calling the same
   procedure in a re-cursive way. This way, it will identify all the parents
   for any given oss node.

   ********************   UPDATE_PARENT_OSS_LINE   ***********************



*/


Procedure update_parent_oss_line(p_parent_ato_line_id  In  Number,
                                 x_return_status       OUT NOCOPY Varchar2,
				 x_msg_count           OUT NOCOPY Number,
				 x_msg_data            OUT NOCOPY Varchar2) is

   l_parent_ato_line_id		Number;
   l_stmt_num                   Number;
Begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 10;
    g_pg_level := g_pg_level + 3;

   /* If the parent is already marked, we don't need to mark it again
      and we should go up in the tree . Other wise we will mark the node
      as oss parent and move up*/

   /* The following two statments record the node and its.
      g_parent_rec is a recor of tables and is used for bulk update
      later
   */



   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: Inside UPDATE_PARENT_OSS_LIEN API',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: Line id = '||g_bcol_tbl(p_parent_ato_line_id).line_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: oss = '||g_bcol_tbl(p_parent_ato_line_id).option_specific,5);
   End if;

   l_stmt_num := 20;
   g_parent_rec.line_id.extend(g_tbl_index);
   g_parent_rec.option_specific.extend(g_tbl_index);
   g_parent_rec.line_id(g_tbl_index)                :=  g_bcol_tbl(p_parent_ato_line_id).line_id;


   l_stmt_num := 30;
   If g_bcol_tbl(p_parent_ato_line_id).option_specific = '1' then
     g_parent_rec.option_specific(g_tbl_index)        :=  '2'; /* This indicates the parent is oss also*/
     g_bcol_tbl(p_parent_ato_line_id).option_specific :=  '2';
     g_tbl_index                                      := g_tbl_index + 1;
   else
     g_parent_rec.option_specific(g_tbl_index)        := '3'; /* This is to indicate the parent is not oss
                                                                by itsefl */
     g_bcol_tbl(p_parent_ato_line_id).option_specific := '3';
     g_tbl_index                                      := g_tbl_index + 1;
   end if;


   /* This will get the parent of the current node */

   l_parent_ato_line_id := g_bcol_tbl(p_parent_ato_line_id).parent_ato_line_id;

   If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: l_parent_ato_line_id = '||l_parent_ato_line_id,5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: new line_id = '||g_bcol_tbl(l_parent_ato_line_id).line_id,5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: ato_line_id = '||g_bcol_tbl(l_parent_ato_line_id).ato_line_id,5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE: new oss = '||g_bcol_tbl(l_parent_ato_line_id).option_specific,5);
   END IF;

   /* If the parent of the current node is already processed by some other tree,
      then we need not traverse the tree up. Also, if the current one is the top most
      then also we don't need to traverse up
   */

   l_stmt_num := 40;

   If (g_bcol_tbl(l_parent_ato_line_id).line_id <>
       g_bcol_tbl(l_parent_ato_line_id).ato_line_id) and
       (g_bcol_tbl(l_parent_ato_line_id).option_specific is null) Then

       /* This is the recursive call to traverse up in the tree
       */
       l_stmt_num := 50;
       update_parent_oss_line(p_parent_ato_line_id  => l_parent_ato_line_id,
                              x_return_status       => x_return_status,
			      x_msg_count           => x_msg_count,
			      x_msg_data            => x_msg_data);
   Elsif g_bcol_tbl(l_parent_ato_line_id).line_id = g_bcol_tbl(l_parent_ato_line_id).ato_line_id then

      If g_bcol_tbl(l_parent_ato_line_id).option_specific = '1' then
        g_parent_rec.line_id.extend(g_tbl_index);
        g_parent_rec.option_specific.extend(g_tbl_index);
        g_parent_rec.line_id(g_tbl_index) :=g_bcol_tbl(l_parent_ato_line_id).line_id;
        g_parent_rec.option_specific(g_tbl_index)        :=  '2'; /* This indicates the parent is oss also*/
        g_bcol_tbl(l_parent_ato_line_id).option_specific :=  '2';
        g_tbl_index                                      := g_tbl_index + 1;
      --This flag is set as N while inserting records. The flag should stay as N unless updated
      --by the update sql in update_oss_in_bcol. Added an nvl to keep the old functionality.
      --elsif  g_bcol_tbl(l_parent_ato_line_id).option_specific is null then
      elsif  (nvl(g_bcol_tbl(l_parent_ato_line_id).option_specific, 'N') = 'N') then  --Bugfix 13540153-FP(13360098)
        g_parent_rec.line_id.extend(g_tbl_index);
        g_parent_rec.option_specific.extend(g_tbl_index);
        g_parent_rec.line_id(g_tbl_index) :=g_bcol_tbl(l_parent_ato_line_id).line_id;
        g_parent_rec.option_specific(g_tbl_index)        := '3'; /* This is to indicate the parent is not oss
                                                                by itsefl */
        g_bcol_tbl(l_parent_ato_line_id).option_specific := '3';
        g_tbl_index                                      := g_tbl_index + 1;
      end if;

   End if;

  g_pg_level := g_pg_level  - 3;

Exception
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'UPDATE_PARENT_OSS_LINE::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End Update_parent_oss_line;


Procedure get_sourcing_data(
                            p_ato_line_id         IN  Number,
			    x_return_status   OUT NOCOPY Varchar2,
			    x_msg_data        OUT NOCOPY Varchar2,
			    x_msg_count       OUT NOCOPY Number) is
   l_stmt_num   Number;

begin
   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 10;

   IF PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_SOURCING_DATA: Inside GET_SOURCING_DATA API',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_SOURCING_DATA: Assignment set id ='||g_def_assg_set,5);
   End if;

   Insert into bom_cto_oss_source_gt
                   (
                    Inventory_item_id,
                    Line_id,
		    ato_line_id,
                    config_item_id,
                    Rcv_org_id,
                    Source_org_id,
                    Customer_id,
                    Ship_to_site_id,
                    Vendor_id,
                    Vendor_site_code,
                    rank,
                    Allocation,
                    Source_type,
                    source_rule_id,
                    sr_receipt_id,
                    sr_source_id,
                    assignment_id
                   )

   select           /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
                    bcol.inventory_item_id,
                    bcol.line_id,
		    p_ato_line_id,
                    null,
                    nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
                    assg.customer_id,
                    assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
                    assg.sourcing_rule_id,
                    rcv.sr_receipt_id,
                    src.sr_source_id,
                    assg.assignment_id

   from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
                    mrp_sourcing_rules rule,
                    po_vendor_sites_all vend,
		    bom_cto_order_lines_gt bcol
   where
                    assg.assignment_set_id   = g_def_assg_set
	      and   bcol.ato_line_id         = p_ato_line_id
	      and   bcol.config_item_id      is null
              and   bcol.option_specific     in ('1','2','3')
	      and   assg.inventory_item_id   = bcol.inventory_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
              and   assg.sourcing_rule_id    = rule.sourcing_rule_id
              and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
              and   src.vendor_site_id = vend.vendor_site_id(+);


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_SOURCING_DATA: Number of records inserted in 1st sql ='||sql%rowcount,5);
      -- 13362916
      Print_source_gt;
   End if;
  Insert into bom_cto_oss_source_gt
                   (
                    Inventory_item_id,
                    Line_id,
		    ato_line_id,
                    config_item_id,
                    Rcv_org_id,
                    Source_org_id,
                    Customer_id,
                    Ship_to_site_id,
                    Vendor_id,
                    Vendor_site_code,
                    rank,
                    Allocation,
                    Source_type,
                    source_rule_id,
                    sr_receipt_id,
                    sr_source_id,
                    assignment_id,
		    valid_flag
                   )

   select       /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
                    bcol.inventory_item_id,
                    bcol.line_id,
		    p_ato_line_id,
                    bcol.config_item_id,
                    nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
                    assg.customer_id,
                    assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
                    assg.sourcing_rule_id,
                    rcv.sr_receipt_id,
                    src.sr_source_id,
                    assg.assignment_id,
		    'Y'

   from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
                    mrp_sourcing_rules rule,
                    po_vendor_sites_all vend,
		    bom_cto_order_lines_gt bcol
   where
                    assg.assignment_set_id   = g_def_assg_set
	      and   bcol.ato_line_id         = p_ato_line_id
	      and   bcol.config_creation     = 3
	      and   bcol.option_specific     in ('1','2','3')
	      and   bcol.config_item_id      is not null
	      and   assg.inventory_item_id   = bcol.config_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
              and   assg.sourcing_rule_id    = rule.sourcing_rule_id
              and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
              and   src.vendor_site_id = vend.vendor_site_id(+);
   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_SOURCING_DATA: Number of records inserted in 2nd sql ='||sql%rowcount,5);
      -- Bug 13362916
      Print_source_gt;
   End if;

/*

   If p_config_creation = '3' Then

      Insert into bom_cto_oss_source_gt
	           (
                    Inventory_item_id,
		    Line_id,
		    config_item_id,
		    Rcv_org_id,
		    Source_org_id,
		    Customer_id,
		    Ship_to_site_id,
		    Vendor_id,
		    Vendor_site_code,
                    rank,
		    Allocation,
		    Source_type,
		    source_rule_id,
		    sr_receipt_id,
		    sr_source_id,
		    assignment_id
		   )

      select
	            p_item_id,
	            p_line_id,
	            p_config_item_id,
	            nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
	            assg.customer_id,
	            assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
	            assg.sourcing_rule_id,
	            rcv.sr_receipt_id,
	            src.sr_source_id,
	            assg.assignment_id

      from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
	            mrp_sourcing_rules rule,
	            po_vendor_sites_all vend
      where
	            assg.assignment_set_id   = g_def_assg_set
	      and   assg.inventory_item_id   = p_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
	      and   assg.sourcing_rule_id    = rule.sourcing_rule_id
	      and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
	      and   src.vendor_site_id = vend.vendor_site_id(+);

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_SOURCING_DATA: Number of assignment records inserted = '
	                                      ||sql%rowcount,5);
      End if;

   elsif p_config_creation in ('1','2') then
      null;
   End if;
*/

   g_pg_level := g_pg_level - 3;

End get_sourcing_data;


Procedure Process_order_for_oss (P_ato_line_id    IN  Number,
                                 P_calling_mode   IN  Varchar2,
                                 x_return_status  OUT NOCOPY Varchar2,
				 x_msg_data       OUT NOCOPY Varchar2,
				 x_msg_count      OUT NOCOPY Number) is

  l_stmt_num   Number;


  -- Bug Fix 4093235
  -- Added the condition to the cursor
  -- Cursor oss_models is not (perform_match = 'Y' and config_creation = '3').
  -- This way we will not pickup matched cib 3 model line for pruning process as
  -- the sourcing rule already pruned and the sourcing data is gathered from
  -- config item.

  -- Commenting as part of Bugfix 8894392
     /*cursor oss_models is
     select*/ /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
            /*line_id,
            ato_line_id,
            option_specific,
	    inventory_item_id,
	    config_item_id,
	    perform_match,
	    config_creation
     from   bom_cto_order_lines_gt bcol
     where  ato_line_id = p_ato_line_id
     and    option_specific in ('1','2','3')
     and   not (perform_match = 'Y' and config_creation = '3') -- 4093235
     order  by plan_level desc;*/

     -- Reasoning for adding this new cursor and commenting out the old one:
     -- The old cursor, because of the condition 'and   not (perform_match = 'Y' and config_creation = '3')'
     -- didn't pick up such configs for processing. After bugfix 8894392, we need to process matched CIB = 3
     -- configs also. So forked the cursor based on p_mode. For mode = ACC, the behaviour stays same as old
     -- cursor. For mode = UPG, the the cursor picks up matched CIB = 3 configs for processing.

     -- Adding this cursor as part of Bugfix 8894392
     cursor oss_models is
     select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
            line_id,
            ato_line_id,
            option_specific,
	    inventory_item_id,
	    config_item_id,
	    perform_match,
	    config_creation,
	    plan_level
     from   bom_cto_order_lines_gt bcol
     where  ato_line_id = p_ato_line_id
     and    option_specific in ('1','2','3')
     --Bugfix 11858888: During ATP, if match profile is OFF, the perform_match flag stays
     --null. The cursor doesn't pick up any lines for OSS processing resulting in wrong
     --sourcing data returned to GOP.
        --
        -- bug 13324638
        -- The cursor should not pick the data if the parent is matched and CIB is 3.
        -- The current code is eliminating any child config lines that are matched, which is
        -- incorrect
        --
        -- and   not (nvl(perform_match,'N') = 'Y' and config_creation = '3') -- 4093235
     and NOT EXISTS (SELECT 1 from bom_cto_order_lines_gt bcol2
                         WHERE ato_line_id = p_ato_line_id
                           AND ato_line_id = line_id -- indicating parent
                           AND nvl(perform_match,'N') = 'Y'
                           AND config_creation = '3')
     and   p_calling_mode in ('ACC', 'ATP')  --Bugfix 8894392: Added mode ATP in the cursor
     union
     select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
            line_id,
            ato_line_id,
            option_specific,
	    inventory_item_id,
	    config_item_id,
	    perform_match,
	    config_creation,
	    plan_level
     from   bom_cto_order_lines_gt bcol
     where  ato_line_id = p_ato_line_id
     and    option_specific in ('1','2','3')
     -- and   not (perform_match = 'Y' and config_creation = '3') -- 4093235
     -- Bugfix 8894392. In case of UPG, we need to prune the tree again. Otherwise
     -- the config BOM gets created in several orgs which are not valid as per OSS.
     and   p_calling_mode = 'UPG'
     order  by plan_level desc;

  x_exp_error_code Number :=0;

    --
    -- bug  13324638
    --
    CURSOR bcolgt_debug_cur IS
           SELECT ATO_LINE_ID,
             CONFIG_ITEM_ID,
             INVENTORY_ITEM_ID,
             LINE_ID,
             LINK_TO_LINE_ID,
             PARENT_ATO_LINE_ID,
             PERFORM_MATCH,
             PLAN_LEVEL,
             SHIP_FROM_ORG_ID,
             TOP_MODEL_LINE_ID,
             HEADER_ID,
             OPTION_SPECIFIC,
             REUSE_CONFIG,
             CONFIG_CREATION,
             VALIDATION_ORG
           FROM bom_cto_order_lines_gt;

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_stmt_num := 10;
  g_pg_level := g_pg_level + 3;

  If PG_DEBUG <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Inside PROCESS_ORDER_FOR_OSS API',5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: P_ato_line_id:' || P_ato_line_id,5);
     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: P_calling_mode:'|| P_calling_mode,5);
  End if;
 -- bug 13324638
  If PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: =======================================================',5);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Printing bom_cto_order_lines_gt data ' || P_ato_line_id,5);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: =======================================================',5);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'ATO_LINE_ID, CONFIG_ITEM_ID, INVENTORY_ITEM_ID, LINE_ID, LINK_TO_LINE_ID, '||
                                               'PARENT_ATO_LINE_ID, PERFORM_MATCH, PLAN_LEVEL, SHIP_FROM_ORG_ID, TOP_MODEL_LINE_ID, '||
                                               'HEADER_ID, OPTION_SPECIFIC, REUSE_CONFIG, VALIDATION_ORG',5);

        FOR bcolgtcur in bcolgt_debug_cur LOOP
            oe_debug_pub.add(lpad(' ',g_pg_level)||bcolgtcur.ATO_LINE_ID||','||
                                                   bcolgtcur.CONFIG_ITEM_ID||','||
                                                   bcolgtcur.INVENTORY_ITEM_ID||','||
                                                   bcolgtcur.LINE_ID||','||
                                                   bcolgtcur.LINK_TO_LINE_ID||','||
                                                   bcolgtcur.PARENT_ATO_LINE_ID||','||
                                                   bcolgtcur.PERFORM_MATCH||','||
                                                   bcolgtcur.PLAN_LEVEL||','||
                                                   bcolgtcur.SHIP_FROM_ORG_ID||','||
                                                   bcolgtcur.TOP_MODEL_LINE_ID||','||
                                                   bcolgtcur.HEADER_ID||','||
                                                   bcolgtcur.OPTION_SPECIFIC||','||
                                                   bcolgtcur.REUSE_CONFIG||','||
                                                   bcolgtcur.VALIDATION_ORG,5);
        END LOOP;
        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: =======================================================',5);
  End if;

  l_stmt_num := 20;

  delete /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N1) */
  from bom_cto_oss_orgslist_gt oss_lis
  where ato_line_id = p_ato_line_id;

  For oss_model_rec in oss_models
  Loop

    If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Inside PROCESS_ORDER_FOR_OSS API....',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: OSS process for line id = '
                                           ||oss_model_rec.line_id,5);
    End if;


    /* If the config item is matched and the item creation attribute is
       set to 3, then we can take the sourcing from config item sourcing.
       we don't need to prune the tree.
    */

    l_Stmt_num := 30;


    if oss_model_rec.option_specific in ('1','2') then

       IF PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Calling Prune OSS Config..',5);
       End if;

       l_stmt_num := 70;
       prune_oss_config(
	               p_model_line_id  => oss_model_rec.line_id,
	               p_model_item_id  => oss_model_rec.inventory_item_id,
		       p_config_item_id => oss_model_rec.config_item_id,
		       p_calling_mode   => p_calling_mode,
                       p_ato_line_id    => p_ato_line_id,
		       x_exp_error_code => x_exp_error_code,
	               x_return_status  => x_return_status,
		       x_msg_count      => x_msg_count,
		       x_msg_data       => x_msg_data
			 );

       If x_return_status  = FND_API.G_RET_STS_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	                      'GET_OSS_ORGS_LIST: Exepected error occurred in prune_oss_config API',5);
          End if;
          raise FND_API.G_EXC_ERROR;

       Elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then

          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
	                   'GET_OSS_ORGS_LIST: Un Exepected error occurred in prune_oss_config API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;

       End if; /* x_return_status  = FND_API.G_RET_STS_ERROR */


       If x_exp_error_code <> 0 Then
          l_stmt_num :=80;

	  update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
	         bom_cto_order_lines_gt bcol
	  set    oss_error_code = x_exp_error_code
	  where  line_id = oss_model_rec.line_id;

          If PG_DEBUG <> 0 Then
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Setting current model error code tp 350',5);
	  End if;

	  If oss_model_rec.line_id <> oss_model_rec.ato_line_id then

	     l_stmt_num := 90;

	     update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
	            bom_cto_order_lines_gt bcol
	     Set    oss_error_code = 360
	     where  line_id  = oss_model_rec.ato_line_id;
	     exit;

	     If PG_DEBUG <> 0 Then
	        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: setting parent model error code to 360',5);
	     End if;
	  End if; /* oss_model_rec.line_id <> oss_model_rec.ato_line_id */

       End if; /* x_exp_error_code <> 0 */

       If PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: After prune oss config.',5);
       End if;

    End if; /* oss_model_rec.option_specific in ('1','2') */

    If PG_DEBUG <> 0 Then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Option Specific = '
                                            ||oss_model_rec.option_specific,5);
       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Exp Error Code = '
                                            || x_exp_error_code,5);
    End if;

    l_stmt_num := 100;

    If oss_model_rec.option_specific in ('2','3') and nvl(x_exp_error_code,0) = 0 then

       If PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Before Prune Parent oss config API',5);
       End if;
       l_stmt_num := 110;

       Prune_parent_oss_config(
	                       p_model_line_id  => oss_model_rec.line_id,
	  	               p_model_item_id  => oss_model_rec.inventory_item_id,
			       p_calling_mode   => p_calling_mode,
                               p_ato_line_id    => p_ato_line_id,
			       x_exp_error_code => x_exp_error_code,
	                       x_return_status  => x_return_status,
			       x_msg_count      => x_msg_count,
			       x_msg_data       => x_msg_data
			      );

       If x_return_status  = FND_API.G_RET_STS_ERROR Then
          IF PG_DEBUG <> 0 Then
             oe_debug_pub.add(lpad(' ',g_pg_level)||
                     'PROCESS_ORDER_FOR_OSS: Exepected error occurred in prune_parent_oss_config API',5);
          End if;
          raise FND_API.G_EXC_ERROR;
       elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR Then
          IF PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||
                  'PROCESS_ORDER_FOR_OSS: Un Exepected error occurred in prune_parent_oss_config API',5);
          End if;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       End if; /* x_return_status  = FND_API.G_RET_STS_ERROR */

       If x_exp_error_code <> 0 Then
          l_stmt_num := 120;
	  update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
	         bom_cto_order_lines_gt bcol
	  set    oss_error_code = x_exp_error_code
	  where  line_id = oss_model_rec.line_id;

          If PG_DEBUG <> 0 Then
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: Setting current model error code tp 350',5);
	  End if;

    	  If oss_model_rec.line_id <> oss_model_rec.ato_line_id then
	     l_stmt_num := 130;
	     update /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
	            bom_cto_order_lines_gt bcol
	     set    oss_error_code = 360
	     where  line_id  = oss_model_rec.ato_line_id;
             If PG_DEBUG <> 0 Then
 	        oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS: setting parent model error code to 360',5);
	     End if;
	  end if; /*oss_model_rec.line_id <> oss_model_rec.ato_line_id*/
       End if; /* x_exp_error_code */


    End if; /* oss_model_rec.option_specific in ('2','3') and x_exp_error_code = 0 */

  End Loop;

  g_pg_level := g_pg_level  - 3;

Exception
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_ORDER_FOR_OSS::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End PROCESS_ORDER_FOR_OSS;

Procedure COPY_TO_BCOL_TEMP(
                            p_ato_line_id   IN  Number,
			    x_return_status OUT NOCOPY Varchar2,
			    x_msg_data      OUT NOCOPY Varchar2,
			    x_msg_count     OUT NOCOPY Number) is
   l_stmt_num   Number;
Begin

   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 10;

   If pg_debug <> 0 Then
     oe_debug_pub.add(lpad(' ',g_pg_level)||'COPY_TO_BCOL_TEMP: Inside Copy to Bcol Temp API',5);
   end if;

   delete /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
   from bom_cto_order_lines_gt bcol
   where  ato_line_id = p_ato_line_id;

   INSERT into bom_cto_order_lines_gt(
				      ATO_LINE_ID,
				      BATCH_ID,
				      BOM_ITEM_TYPE,
				      COMPONENT_CODE,
				      COMPONENT_SEQUENCE_ID,
				      CONFIG_ITEM_ID,
				      INVENTORY_ITEM_ID,
				      ITEM_TYPE_CODE,
				      LINE_ID,
				      LINK_TO_LINE_ID,
				      ORDERED_QUANTITY,
				      ORDER_QUANTITY_UOM,
				      PARENT_ATO_LINE_ID,
				      PERFORM_MATCH,
				      PLAN_LEVEL,
				      SCHEDULE_SHIP_DATE,
				      SHIP_FROM_ORG_ID,
				      TOP_MODEL_LINE_ID,
				      WIP_SUPPLY_TYPE,
				      HEADER_ID,
				      OPTION_SPECIFIC,
				      REUSE_CONFIG,
				      QTY_PER_PARENT_MODEL,
				      CONFIG_CREATION,
				      program_id	--Bugfix 8894392
				     )
			Select  /*+ INDEX (bcol_upg BOM_CTO_ORDER_LINES_UPG_N4) */
    				      ATO_LINE_ID,
				      BATCH_ID,
				      BOM_ITEM_TYPE,
				      COMPONENT_CODE,
				      COMPONENT_SEQUENCE_ID,
				      CONFIG_ITEM_ID,
				      INVENTORY_ITEM_ID,
				      ITEM_TYPE_CODE,
				      LINE_ID,
				      LINK_TO_LINE_ID,
				      ORDERED_QUANTITY,
				      ORDER_QUANTITY_UOM,
				      PARENT_ATO_LINE_ID,
				      PERFORM_MATCH,
				      PLAN_LEVEL,
				      SCHEDULE_SHIP_DATE,
				      SHIP_FROM_ORG_ID,
				      TOP_MODEL_LINE_ID,
				      WIP_SUPPLY_TYPE,
				      HEADER_ID,
				      OPTION_SPECIFIC,
				      REUSE_CONFIG,
				      QTY_PER_PARENT_MODEL,
				      CONFIG_CREATION,
				      program_id	--Bugfix 8894392

			from          bom_cto_order_lines_upg bcol_upg
			where         ato_line_id = p_ato_line_id;


   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'COPY_TO_BCOL_TEMP: Number of lines inserted in to temp '
                                           || sql%rowcount,5);
   End if;
   g_pg_level := g_pg_level - 3;
End COPY_TO_BCOL_TEMP;


/*
    This procedure will get the order sourcing data
    by travelling the whole sourcing chain
*/

Procedure Get_order_sourcing_data(
                                p_ato_line_id   IN   Number,
                                x_return_status OUT NOCOPY  Varchar2,
                                x_msg_count     OUT NOCOPY  Number,
                                x_msg_data      OUT NOCOPY  Varchar2) is
   cursor model_lines_cur is
          select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
	         line_id,
                 inventory_item_id,
                 option_specific,
                 parent_ato_line_id,
		 ato_line_id
          from   bom_cto_order_lines_gt bcol
          where  ato_line_id = p_ato_line_id
          and    nvl(wip_supply_type,-1) <> '6'
          and    bom_item_type = '1'
          and    option_specific  in ('1','2','3')
	  and    config_creation <> '3'
          order by plan_level;

  Cursor mfg_orgs_cur(p_line_id Number) is
         select /*+ INDEX (oss_lis BOM_CTO_OSS_ORGSLIST_GT_N2) */
	        organization_id
         from   bom_cto_oss_orgslist_gt oss_lis
         where  line_id = p_line_id;

  x_assg_list assg_rec;
  l_stmt_num   Number;
  l_parent_line_id    Number;
  lCnt number;  -- Bugfix 8894392
Begin

   l_stmt_num := 10;
   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   delete /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N1) */
   from bom_cto_oss_source_gt oss_src where ato_line_id = p_ato_line_id;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCNIG_DATA: Inside GET_ORDER_SOURCING_DATA API',5);
   End if;

   Insert
   into bom_cto_oss_orgslist_gt(
                               line_id,
                               organization_id,
                               ato_line_id
                              )
   select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_U1) */
          -1,
          ship_from_org_id,
          p_ato_line_id
   from   bom_cto_order_lines_gt bcol
   where  line_id = p_ato_line_id;

   l_stmt_num := 20;

   For model_lines_rec in model_lines_cur
   Loop
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCNIG_DATA: Processing model line = '||model_lines_rec.line_id,5);
	 oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCNIG_DATA: Processing model Item = '||model_lines_rec.inventory_item_id,5);
      End if;

      l_stmt_num := 30;

      If model_lines_rec.line_id = model_lines_rec.ato_line_id then
         l_parent_line_id := -1;
      else
         l_parent_line_id := model_lines_rec.parent_ato_line_id;
      End if;
      g_assg_list.delete;
      For mfg_orgs_rec in mfg_orgs_cur(l_parent_line_id)
      Loop
         If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCNIG_DATA: get sourcing chain from org = '||mfg_orgs_rec.organization_id,5);
         End if;
         l_stmt_num := 40;
         Traverse_sourcing_chain(
                                 p_item_id         => model_lines_rec.inventory_item_id,
                                 p_org_id          => mfg_orgs_rec.organization_id,
                                 p_line_id         => model_lines_rec.line_id,
                                 p_option_specific => model_lines_rec.option_specific,
                                 p_ato_line_id     => p_ato_line_id,
                                 x_assg_list       => x_assg_list,
                                 x_return_status   => x_return_status,
                                 x_msg_data        => x_msg_data,
                                 x_msg_count       => x_msg_count);
      End loop;
   End Loop;

   If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCNIG_DATA: after the loop on crsr model_lines_cur',5);
   End if;

   l_stmt_num := 41;
   if x_assg_list.assignment_id.count <> 0 Then
    if PG_DEBUG <> 0 Then
        oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA: Before inserting the assignments into temp table',5);
	oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA: Assignment count = '||x_assg_list.assignment_id.count,1);
     end if;

     l_stmt_num := 50;
     FORALL i in x_assg_list.assignment_id.first..x_assg_list.assignment_id.last
      Insert into bom_cto_oss_source_gt
                   (
                    Inventory_item_id,
                    Line_id,
		    ato_line_id,
                    config_item_id,
                    Rcv_org_id,
                    Source_org_id,
                    Customer_id,
                    Ship_to_site_id,
                    Vendor_id,
                    Vendor_site_code,
                    rank,
                    Allocation,
                    Source_type,
                    source_rule_id,
                    sr_receipt_id,
                    sr_source_id,
                    assignment_id
                   )

             select
                    assg.inventory_item_id,
                    x_assg_list.line_id(i),
		    p_ato_line_id,
                    null,
                    nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
                    assg.customer_id,
                    assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
                    assg.sourcing_rule_id,
                    rcv.sr_receipt_id,
                    src.sr_source_id,
                    assg.assignment_id

      from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
                    mrp_sourcing_rules rule,
                    po_vendor_sites_all vend
      where
                    assg.assignment_set_id   = g_def_assg_set
              and   assg.assignment_id       = x_assg_list.assignment_id(i)
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
              and   assg.sourcing_rule_id    = rule.sourcing_rule_id
              and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
              and   src.vendor_site_id = vend.vendor_site_id(+);
   End if;



   IF PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA: Before inserting Model attribute 3 lines',5);
   End if;

   l_stmt_num := 60;
   Insert into bom_cto_oss_source_gt
                   (
                    Inventory_item_id,
                    Line_id,
		    ato_line_id,
                    config_item_id,
                    Rcv_org_id,
                    Source_org_id,
                    Customer_id,
                    Ship_to_site_id,
                    Vendor_id,
                    Vendor_site_code,
                    rank,
                    Allocation,
                    Source_type,
                    source_rule_id,
                    sr_receipt_id,
                    sr_source_id,
                    assignment_id
                   )

   select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
                    bcol.inventory_item_id,
                    bcol.line_id,
		    p_ato_line_id,
                    null,
                    nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
                    assg.customer_id,
                    assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
                    assg.sourcing_rule_id,
                    rcv.sr_receipt_id,
                    src.sr_source_id,
                    assg.assignment_id

   from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
                    mrp_sourcing_rules rule,
                    po_vendor_sites_all vend,
		    bom_cto_order_lines_gt bcol
   where
                    assg.assignment_set_id   = g_def_assg_set
	      and   bcol.ato_line_id         = p_ato_line_id
	      and   bcol.config_creation     = 3
              and   (nvl(bcol.perform_match,'N') = 'N' or nvl(bcol.reuse_config,'N') = 'N')
	      and   assg.inventory_item_id   = bcol.inventory_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
              and   assg.sourcing_rule_id    = rule.sourcing_rule_id
              and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
              and   src.vendor_site_id = vend.vendor_site_id(+);

   -- Bugfix 8894392
   lCnt := sql%rowcount;
   IF PG_DEBUG <> 0 THEN
     oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA: No. of rows inserted for CIB 3 model:'||lCnt,5);
   END IF;
   -- Bugfix 8894392


  -- Bug Fix 4093235
  -- When we load the sourcing data into the temp table
  -- from matched cib 3 config items, we need to flag all the
  -- legs in the sourcing as valid. The valid_flag column in added
  -- and passed 'Y' value for all rows.

  -- Commenting this sql as part of Bugfix 8894392.
  -- Reasoning: For CIB = 3 and Match/Reuse flag = Y, code will be bypassed from the
  -- validation in process_oss_configurations part for ACC. So this sql is not used in case
  -- the mode is ACC. For UPG, after the code changes, reuse_flag will always be N,
  -- so data will be populated only from the earlier sql.
  -- Secondly, this sql picked up data from config. Since we are pruning the tree again,
  -- we need the data from model and not config.
  /*

  l_stmt_num := 70;
  Insert into bom_cto_oss_source_gt
                   (
                    Inventory_item_id,
                    Line_id,
		    ato_line_id,
                    config_item_id,
                    Rcv_org_id,
                    Source_org_id,
                    Customer_id,
                    Ship_to_site_id,
                    Vendor_id,
                    Vendor_site_code,
                    rank,
                    Allocation,
                    Source_type,
                    source_rule_id,
                    sr_receipt_id,
                    sr_source_id,
                    assignment_id,
		    Valid_flag     /* 4093235 */
                   --)

   --select /*+ INDEX (bcol BOM_CTO_ORDER_LINES_GT_N1) */
     /*             bcol.inventory_item_id,
                    bcol.line_id,
		    p_ato_line_id,
                    bcol.config_item_id,
                    nvl(rcv.receipt_organization_id,assg.organization_id),
                    src.source_organization_id,
                    assg.customer_id,
                    assg.ship_to_site_id,
                    src.VENDOR_ID,
                    vend.VENDOR_SITE_code,
                    src.RANK,
                    src.ALLOCATION_PERCENT,
                    src.SOURCE_TYPE,
                    assg.sourcing_rule_id,
                    rcv.sr_receipt_id,
                    src.sr_source_id,
                    assg.assignment_id,
		    'Y'

   from
                    mrp_sr_receipt_org rcv,
                    mrp_sr_source_org src,
                    mrp_sr_assignments assg,
                    mrp_sourcing_rules rule,
                    po_vendor_sites_all vend,
		    bom_cto_order_lines_gt bcol
   where
                    assg.assignment_set_id   = g_def_assg_set
	      and   bcol.ato_line_id         = p_ato_line_id
	      and   bcol.config_creation     = 3
              and   (nvl(bcol.perform_match,'N') = 'Y' or nvl(bcol.reuse_config,'N') = 'Y')
	      and   assg.inventory_item_id   = bcol.config_item_id
              and   assg.sourcing_rule_id    = rcv.sourcing_rule_id
              and   assg.sourcing_rule_id    = rule.sourcing_rule_id
              and   rule.planning_active     = 1
              and   rcv.effective_date      <= sysdate
              and   nvl(rcv.disable_date,sysdate+1)>sysdate
              and   rcv.SR_RECEIPT_ID        = src.sr_receipt_id
              and   src.vendor_site_id = vend.vendor_site_id(+);*/

   g_pg_level := g_pg_level - 3;

Exception
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );

End Get_order_sourcing_data;

/*
     The following procedure will travell the whole
     sourcing tree for a given org and item
*/

Procedure Traverse_sourcing_chain(
                                p_item_id         IN    Number,
				p_org_id          IN    Number,
                                p_line_id         IN    Number,
                                p_option_specific IN    Varchar,
                                p_ato_line_id     IN    Number,
				x_assg_list       IN OUT NOCOPY assg_rec,
				x_return_status   OUT NOCOPY    Varchar2,
				x_msg_data        OUT NOCOPY   Varchar2,
				x_msg_count       OUT NOCOPY   Varchar2) is

   --Fixed FP bug 5156690
   -- added another filter condition assignment_id is not null
   -- to ignore rules that are not defined as explicit sourcing rules
   cursor src_cur  is
     select
           source_organization_id,
           organization_id,
           sourcing_rule_id,
           nvl(source_type,1) source_type,
	   assignment_type,
	   assignment_id
     from  mrp_sources_v msv
     where msv.assignment_set_id = g_def_assg_set
       and msv.inventory_item_id = p_item_id
       and msv.organization_id = p_org_id
       and nvl(effective_date,sysdate) <= nvl(disable_date, sysdate)
       and nvl(disable_date, sysdate+1) > sysdate
       and assignment_id is not null;
    l_assg_id Number :=0;
    l_stmt_num Number;
Begin
   l_stmt_num := 10;
   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Inside Traverse_Souricng_Chain API',5);
   End if;

   --
   -- Added By Renga Kannan on 11/21/03
   -- implemented an algorithm to catch circular sourcing.
   --

   If G_source_org_stk.exists(p_org_id) then
     if PG_DEBUG <> 0 then
       oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Circular sourcing deducted..',5);
     end if;
     cto_msg_pub.cto_message('BOM','CTO_INVALID_SOURCING');
     raise FND_API.G_EXC_ERROR;
   Else
     -- Push the org to the stack
     G_source_org_stk(p_org_id) := p_org_id;
   End if;

   --
   -- End of adition on 11/21/03
   --


   l_stmt_num := 20;
   For src_rec in src_cur
   Loop
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Assignment Type = '||src_rec.assignment_type,1);
         oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Assignment id   = '||src_rec.assignment_id,1);
         oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Source org id   = '||src_rec.source_organization_id,1);
	 oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Rcv org id      = '||src_rec.organization_id,1);
      End if;
      l_stmt_num := 30;
      If src_rec.assignment_type in (3,6) Then
         If not g_assg_list.exists(src_rec.assignment_id) and p_option_specific is not null Then

            oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Registering the assignment id ',1);
            l_stmt_num := 40;
	    x_assg_list.assignment_id.extend(x_assg_list.assignment_id.count+1);
	    x_assg_list.assignment_id(x_assg_list.assignment_id.last) := src_rec.assignment_id;
            x_assg_list.line_id.extend(x_assg_list.line_id.count+1);
            x_assg_list.line_id(x_assg_list.line_id.last) := p_line_id;
	    g_assg_list(src_rec.assignment_id) := src_rec.assignment_id;
	    oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Line id = '||x_assg_list.line_id(x_assg_list.line_id.last),1);
	    oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: Assg id = '||x_assg_list.assignment_id(x_assg_list.assignment_id.last),1);
         End if;
         l_assg_id := src_rec.assignment_id;
         If src_rec.source_type in (2,3) Then
             l_stmt_num := 50;
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: End org = '||src_rec.organization_id,1);
             insert into bom_cto_oss_orgslist_gt(
                                                 line_id,
                                                 organization_id,
                                                 ato_line_id
                          			)
             values                             (
  					         p_line_id,
                                                 src_rec.organization_id,
                                                 p_ato_line_id
                                                );

         Else
             If PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOOURCING_CHAIN: Before calling traverse sourcing chain recurrsive',5);
             End if;
             l_stmt_num := 60;
             Traverse_sourcing_chain(
                                p_item_id         => p_item_id,
                                p_org_id          => src_rec.source_organization_id,
                                p_line_id         => p_line_id,
                                p_option_specific => p_option_specific,
                                p_ato_line_id     => p_ato_line_id,
                                x_assg_list       => x_assg_list,
                                x_return_status   => x_return_status,
                                x_msg_data        => x_msg_data,
                                x_msg_count       => x_msg_count);

	 End if; /* l_assg_id <> src_rec.assignment_id */

      End if; /* src_rec.assignment_type in (3,6) */
   End Loop;
   If l_assg_id =0 Then
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'TRAVERSE_SOURCING_CHAIN: End of source chain',5);
      End if;

      insert into bom_cto_oss_orgslist_gt(
   				          line_id,
				          organization_id,
                                          ato_line_id
					 )
      values                             (
					  p_line_id,
					  p_org_id,
                                          p_ato_line_id
 					);


   end if;

   g_source_org_stk.delete(p_org_id);

   g_pg_level := g_pg_level - 3;
End Traverse_sourcing_chain;


Procedure query_oss_sourcing_org(
			     p_line_id              IN  NUMBER,
			     p_inventory_item_id    IN  NUMBER,
			     p_organization_id      IN  NUMBER,
			     x_sourcing_rule_exists OUT NOCOPY varchar2,
			     x_source_type          OUT NOCOPY NUMBER,
			     x_t_sourcing_info      OUT NOCOPY CTO_MSUTIL_PUB.SOURCING_INFO,
			     x_exp_error_code       OUT NOCOPY NUMBER,
			     x_return_status        OUT NOCOPY varchar2,
			     x_msg_data	            OUT NOCOPY Varchar2,
			     x_msg_count            OUT NOCOPY Number) is
l_stmt_num            Number;
i		      Number;
l_buy_type            Varchar2(1) := 'N';

Cursor  source_org_rule_cur is
        select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       source_org_id,
	       source_type
	from   bom_cto_oss_source_gt oss_src
	where  line_id = p_line_id
	and    valid_flag = 'Y'
	and    rcv_org_id = p_organization_id;

Cursor  source_item_rule_cur is
        select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
	       source_org_id,
	       source_type
	from   bom_cto_oss_source_gt oss_src
	where  line_id = p_line_id
	and    valid_flag = 'Y'
	and    rcv_org_id is null;

Begin

   l_stmt_num := 10;
   g_pg_level := g_pg_level + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   i := 1;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: Inside Query OSS Sourcing Org API',5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: p_line_id           = '||p_line_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: p_org_id            = '||p_organization_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: p_inventory_item_id = '||p_inventory_item_id,5);
   End if;

   For Source_org_rule_rec in Source_org_rule_cur
   Loop
      If Source_org_rule_rec.source_type = 3 and l_buy_type = 'N' Then
         x_t_sourcing_info.source_organization_id(i) := Source_org_rule_rec.source_org_id;
         x_t_sourcing_info.source_type(i)            := Source_org_rule_rec.source_type;

	 If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing org  = '
	                                         ||x_t_sourcing_info.source_organization_id(i),5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing Type = '
	                                         ||x_t_sourcing_info.source_type(i),5);

	 End if;
	 i := i +1 ;
	 l_buy_type := 'Y';

      elsif source_org_rule_rec.source_type in (1,2) then
         x_t_sourcing_info.source_organization_id(i) := Source_org_rule_rec.source_org_id;
         x_t_sourcing_info.source_type(i)            := Source_org_rule_rec.source_type;
	 If PG_DEBUG <> 0 Then
            oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing org  = '
	                                         ||x_t_sourcing_info.source_organization_id(i),5);
            oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing Type = '
	                                         ||x_t_sourcing_info.source_type(i),5);

	 End if;

	 i := i + 1;
      End if;
   End Loop;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: Number of orgs based on orgs rule ='
                                           ||x_t_sourcing_info.source_organization_id.count,5);
   End if;

   If x_t_sourcing_info.source_organization_id.count = 0 Then

      For Source_item_rule_rec in Source_item_rule_cur
      Loop
         If Source_item_rule_rec.source_type = 3 and l_buy_type = 'N' Then
            x_t_sourcing_info.source_organization_id(i) := Source_item_rule_rec.source_org_id;
            x_t_sourcing_info.source_type(i) := Source_item_rule_rec.source_type;
	    If PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing org  = '
	                                            ||x_t_sourcing_info.source_organization_id(i),5);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing Type = '
	                                            ||x_t_sourcing_info.source_type(i),5);

   	    End if;

	    i := i + 1;
	    l_buy_type := 'Y';
         elsif Source_item_rule_rec.source_type in (1,2) then
            x_t_sourcing_info.source_organization_id(i) := Source_item_rule_rec.source_org_id;
            x_t_sourcing_info.source_type(i) := Source_item_rule_rec.source_type;
	    If PG_DEBUG <> 0 Then
               oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing org  = '
	                                            ||x_t_sourcing_info.source_organization_id(i),5);
               oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: sourcing Type = '
	                                            ||x_t_sourcing_info.source_type(i),5);

	    End if;

	    i := i + 1;
         End if;
      End Loop;

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: Number of orgs based on item rule ='
                                           ||x_t_sourcing_info.source_organization_id.count,5);
      End if;


   End if;

   If x_t_sourcing_info.source_organization_id.count = 0 Then
      x_sourcing_rule_exists := 'N';
      Select planning_make_buy_code
      into   x_source_type
      from   mtl_system_items
      where  inventory_item_id = p_inventory_item_id
      and    organization_id   = p_organization_id;
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: No sourcing rule exists',5);
      End if;
   else
      If PG_DEBUG <> 0 Then
         oe_debug_pub.add(lpad(' ',g_pg_level)||'QUERY_OSS_SOURCING_ORG: Number of sourcin orgs = '
	                                      ||x_t_sourcing_info.source_organization_id.count,5);
      end if;
      x_sourcing_rule_exists := 'Y';
   End if;

   g_pg_level := g_pg_level - 3;
Exception
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)
			      ||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_ORDER_SOURCING_DATA::exp error::'
			      ||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
	    g_pg_level := g_pg_level - 3;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            cto_msg_pub.count_and_get(
                                 p_msg_count  => x_msg_count,
                                 p_msg_data   => x_msg_data
                                );
End query_oss_sourcing_org;


Procedure GET_OSS_BOM_ORGS(
                           p_line_id       IN  Number,
			   x_orgs_list     OUT NOCOPY CTO_OSS_SOURCE_PK.orgs_list,
			   x_return_status OUT NOCOPY Varchar2,
			   x_msg_data      OUT NOCOPY Varchar2,
			   x_msg_count     OUT NOCOPY Number) is
l_stmt_num     Number;
l_count        Number;
l_source_org   number;
l_rcv_org      number;
l_valid_flag   varchar2(1);
l_source_type  varchar2(1);
l_line_id      number;

Begin
   g_pg_level := nvl(g_pg_level,0) + 3;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_stmt_num := 10;

   oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_BOM_ORGS: Begin ',1);

   Select org_id
   bulk collect into x_orgs_list
   from
      (Select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
              distinct nvl(source_org_id,rcv_org_id)  org_id
       from   bom_cto_oss_source_gt oss_src
       where  line_id = p_line_id
       and    valid_flag in( 'P','Y')
       and    source_type in (2,3)
       union
       select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
              distinct source_org_id org_id
       from   bom_cto_oss_source_gt oss_src
       where  line_id = p_line_id
       and    valid_flag in ('P','Y')
       and    source_org_id not in (
				select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
				       rcv_org_id
				from   bom_cto_oss_source_gt oss_src
				where  line_id = p_line_id
				and    valid_flag in( 'P','Y')));
   If PG_DEBUG <> 0 Then
      oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_BOM_ORGS: Number of orgs where bom should be created = '
                                           ||x_orgs_list.count,5);
   End if;

   oe_debug_pub.add(lpad(' ',g_pg_level)||'GET_OSS_BOM_ORGS: End ',1);

End GET_OSS_BOM_ORGS;


-- Bugfix 13362916
Procedure Print_source_gt is
   cursor source_cur is
      select /*+ INDEX (oss_src BOM_CTO_OSS_SOURCE_GT_N2) */
             line_id,
             inventory_item_id,
	     rcv_org_id,
	     source_org_id,
	     customer_id,
	     vendor_id,
	     vendor_site_code,
	     rank,
	     allocation,
	     source_type,
	     reuse_flag,
	     valid_flag,
	     leaf_node,
             SR_RECEIPT_ID -- bug 13362916
      from   bom_cto_oss_source_gt oss_src;
      --where  line_id = p_line_id;

Begin
   oe_debug_pub.add('================PRINTING BOM_CTO_OSS_SOURCE_GT==================',5);
   --oe_debug_pub.add('================   Line id = '||p_line_id||'======================',5);
   oe_debug_pub.add('Line_id --- Item id --- Rcv org --- src org --- customer --- vendor --- vend site --- rank --- alloc% --- src type --- reuse -- valid --- leaf --- sr_receipt_id --- ',5);
   for source_rec in source_cur
   loop
      oe_debug_pub.add(source_rec.line_id|| ' --- '
                       ||source_rec.inventory_item_id||' --- '
                       ||source_rec.rcv_org_id||' --- '||source_rec.source_org_id
		       ||' --- '||source_rec.customer_id||' --- '||source_rec.vendor_id
		       ||' --- '||source_rec.vendor_site_code||' --- '||source_rec.rank
		       ||' --- '||source_rec.allocation||' --- '||source_rec.source_type
		       ||' --- '||source_rec.reuse_flag||' --- '||source_rec.valid_flag
		       ||' --- '||source_rec.leaf_node ||' --- '||source_rec.SR_RECEIPT_ID,5);
   End Loop;

   oe_debug_pub.add('============== End printing ===============',5);
End;

--Bugfix 13362916
Procedure Print_orglist_gt is
Cursor  org_list_cur is
       select line_id,
              ato_line_id,
	      inventory_item_id,
	      organization_id,
	      vendor_id,
	      vendor_site_code,
	      make_flag
	from  bom_cto_oss_orgslist_gt;
	--where line_id = p_line_id;
begin
   oe_debug_pub.add('================PRINTING BOM_CTO_ORGSLIST_GT==================',5);
   --oe_debug_pub.add('================   Line id = '||p_line_id||'======================',5);
   oe_debug_pub.add('Line id --- Ato Line Id --- Item Id --- Org id --- vendor --- vend site ---Make Flag',5);
   for org_list_rec in org_list_cur
   Loop
      oe_debug_pub.add(org_list_rec.line_id||' --- '||org_list_rec.ato_line_id||' --- '||
                       org_list_rec.inventory_item_id||' --- '||org_list_rec.organization_id||' --- '||
		       org_list_rec.vendor_id||' --- '||org_list_rec.vendor_site_code||' --- '||
		       org_list_rec.make_flag,5);
   End Loop;
   oe_debug_pub.add('============== End printing ===============',5);
End;
END CTO_OSS_SOURCE_PK;

/
