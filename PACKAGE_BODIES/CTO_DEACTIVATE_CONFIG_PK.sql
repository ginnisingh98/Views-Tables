--------------------------------------------------------
--  DDL for Package Body CTO_DEACTIVATE_CONFIG_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_DEACTIVATE_CONFIG_PK" as
/* $Header: CTODACTB.pls 120.5.12010000.3 2008/10/30 14:30:48 ntungare ship $*/


/*
 *=========================================================================*
 |                                                                         |
 | Copyright (c) 2001, Oracle Corporation, Redwood Shores, California, USA |
 |                           All rights reserved.                          |
 |                                                                         |
 *=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |            CTO Deactive Confg  package body                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   PL/SQL package body containing the  routine  for deactivating         |
 |   configuration items  which are no loger used.                         |
 |   This code in Release 11i replaces the SQL script BOMCCIPD.sql used    |
 |   in Release 11.                                                        |
 |   In Release 11i the Multi-level/Multi-org functionality has been       |
 |   introduced which was not present in Release 11 and data model has     |
 |   changed (MTL_DEMAND and MTL_DEMAND_INTERFACE tables are not used in   |
 |   Rel-11i )                                                             |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   Input :  Please see the individual function or procedure.             |
 |                                                                         |
 | HISTORY                                                                 |
 |   Date      Author   Comments                                           |
 | --------- -------- ---------------------------------------------------- |
 |  05/25/2001  KKONADA  creation of body      CTO_DEACTIVATE_CONFIG_PK    |
 |  05/30/2001  KKONADA 1.changed the org_id in check_open_demand          |
 |                        to ship_from_org_id                              |
 |                      2.check_common_bom and check common_routing        |
 |                        added the condition for organization_id to pick  |
 |                        up bill_sequnece_id/routing_sequnce_id for an    |
 |                        inventory_item_id                                |
 |                                                                         |
 |  06/14/2001  KKONADA  1. CHANGED THE PROCEDURE CHECK_ITEM_IN_CHILD_ORG  |
 |                        as  previous version had a wrong logic           |
 |                       2.raised exception exceptions in called functions |
 |                       propogate to calling functions.                   |
 |                       3.printing deactivated and undeactived items after|
 |                       the items are actually deactivated, in prevuous   |
 |                       version it was other way around.                  |
 |                                                                         |
 |  09/20/2001  KKONADA  changed the code in procedure                     |
 |                        CHECK_ITEM_IN_CHILD_ORG> Replaced the loop       |
 |                        with a nested query                              |
 |                                                                         |
 |  10/19/2001  KKONADA  where condition 'alternate routing designator is  |
 |                         added to check_common_routing code to filter out|
 |                         any routing_sequnce_id's of alternate routings  |
 |                         which may get collected--fix for bug2063209     |
 |              KKONADA   bugfix 2162892                                   |
 |									   |
 |  04/09/2002  KKONADA   bugfix2308063                                    |
 |                        1.changed the table of scalar to table of records|
 |                        record contains item_id,item name and msg(if any)|
 |                        regarding deactivation.Made the required code    |
 |                        chnages for using table of records at various    |
 |                        The changes are identfied in the code by bugfix# |
 |                                                                         |
 |                        2.Deactivated items were getting inserted        |
 |                        multiple times in mtl_pending_item_status ,every |
 |                        time the deactiavtion program is being run . It  |
 |                        should get inserted only once during teh first   |
 |                        time                                             |
 |                        changed the check_delete_status to pick          |
 |                        up the status code for the LATEST effective date |
 |                        (ie to pick up from the last inserted row)       |
 |                        In patchset-G the status_code was picked from the|
 |                        first row (first effective date).                |
 |                                                                         |
 |                                                                         |
 | 05/16/2002   KKONADA  bug fix#2368862.added a where condition to look   |
 |                       at inventory_item_status_code , in order NOT to   |
 |                       pick up inactive items                            |
 |									   |
 | 05/23/2002   KKONADA	 bug fix#2368862. Added a new procedure            |
 |                       GET_BOM_DELETE_STATUS_CODE and changed CHECK_ITEM |
 |                       IN_CHILD_ORG. Code chnaged to look at the status  |
 |                       of the child org items                            |
 |                                                                         |
 | 05/23/2002   SBHASKAR bugfix 2368862 contd..                            |
 |                       check attribute control for item status and       |
 |                       process accordingly. Refer bug for more details.  |
 |                                                                         |
 |                       bugfix 2214674                                    |
 |                       check onhand for the config item before           |
 |                       deactivating.                                     |
 |                                                                         |
 |                       bugfix 2477125                                    |
 |                       Remove from bom_ato_configurations so that de-    |
 |                       activated items are not used for matching.        |
 |                                                                         |
 | 10/01/2003   KSARKAR  Changes to program for fp-J.                      |
 | 11/19/2003   SBHASKAR bugfix 3275577. Added x_return_status parameter to|
 |                       DEACTIVATE_ITEMS procedure and to the main prog.  |
 |									   |
 | 11/19/2003   KSARKAR  bugfix 3443251. Added exception to handle no data |
 |                       found error when config not in BAC                |
 |
 |
 | 04/06/2004  KKONADA   removed fullstop after BOM , bugfix#3554874
 |
 |
 | 04/07/2004  KKONADA   bugfix 3557190
 |                       modified the query to use index and to delete from
 |                       BCMO only when rows are deleted from BAC
 *=========================================================================*/


/******************************************************************************
 defining a record to hold configuration item details
 config item id, config item name and msg to hold the reason
 for being deactivated or not deactivated
*****************************************************************************/

-- bugfix2308063
TYPE r_cfg_item_details IS RECORD(
     cfg_item_id    mtl_system_items_kfv.inventory_item_id%type,
     cfg_item_name  mtl_system_items_kfv.concatenated_segments%type,
     cfg_orgn_id    number,
     cfg_orgn_code  mtl_parameters.organization_code%type,--5291392
     msg VARCHAR2(200)
     );

--start 5291392
 TYPE r_org_details IS RECORD(
     org_id    mtl_parameters.organization_id%type,
     org_code   mtl_parameters.organization_code%type
     );


 TYPE t_org_details IS TABLE OF r_org_details INDEX BY BINARY_INTEGER;
 tab_org_details t_org_details;
 --end 5291392

/**************************************************************************
  defining a PL/SQL table (of records) type to hold
  deactivated and undeactivated items
**************************************************************************/

-- bugfix2308063
TYPE t_cfg_item_details IS TABLE OF r_cfg_item_details INDEX BY BINARY_INTEGER;


TYPE item_failed_flag_tbl IS TABLE OF varchar2(1) INDEX BY BINARY_INTEGER;
failed_flag 	item_failed_flag_tbl;

Procedure Get_organization_code( p_organization_id IN Number,
                                 p_organization_code out NOCOPY Varchar2
				);

/***********************************************************************
 forward declaration:
 register_result registers the deactiavted and undeactiavted items
 in PL/SQL tables
***********************************************************************/
PROCEDURE REGISTER_RESULT(
                           p_table        IN OUT   NOCOPY t_cfg_item_details,
                           p_cfg_item_id    IN       NUMBER,
                           p_cfg_item_name  IN       VARCHAR2,   --bugfix2308063
                           p_cfg_orgn_id    IN       NUMBER,
                           p_msg VARCHAR2   DEFAULT  NULL
                          );


/********************************************************************
 forward declaration
 check_open_supply  checks if any open supply is present for a
 configuration item
**********************************************************************/
PROCEDURE CHECK_OPEN_SUPPLY(
                              p_inventory_item_id     IN    NUMBER,
                              p_org_id                IN    NUMBER,
                              x_return_status         OUT  NOCOPY VARCHAR2
                            );


/***********************************************************************
 forward declaration
 check_open_demand  checks if there is any open demand present for given
 config item
*************************************************************************/
PROCEDURE CHECK_OPEN_DEMAND(
                              p_inventory_item_id     IN   NUMBER,
                              p_org_id                IN   NUMBER,
                              x_return_status         OUT  NOCOPY VARCHAR2
                           );




/*************************************************************************
 forward declaration
  check_material transaction checks if any material transaction is present
  for a given config item within a given num of days after shipping
***************************************************************************/
PROCEDURE CHECK_MATERIAL_TRANSACTION(
                                       p_inventory_item_id     IN    NUMBER,
                                       p_org_id                IN    NUMBER,
                                       p_num_of_days           IN    NUMBER,
                                       x_return_status         OUT NOCOPY VARCHAR2
                                    );


/*************************************************************************
 forward declaration
  check_active_parent_config checks if the given config item has any
  parent config items which has not been deactivated.
  bugfix 7011607
***************************************************************************/

PROCEDURE CHECK_ACTIVE_PARENT_CONFIG(
                                       p_inventory_item_id     IN    NUMBER,
                                       p_org_id                IN   NUMBER,
                                       x_return_status         OUT  NOCOPY VARCHAR2
                                    );


/**************************************************************************
forward declaration
 This procedure takes in organization id and finds out the parameter
 bom_delete_status_code.
 bom_delete_status_code is the status  which needs to be assigned to the item
 when item becomes inactive
 bugfix 2368862
**************************************************************************/
PROCEDURE GET_BOM_DELETE_STATUS_CODE
          ( p_org_id                IN    NUMBER,
            p_delete_status_code    OUT NOCOPY VARCHAR2,
            x_return_status         OUT NOCOPY VARCHAR2
           );



/*************************************************************************
  forward declaration
  DEACTIVATE_ITEMS deactivates the items by inserting pending flag in
  mtl_pending_item_status and deleting from bom_ato_configuration_items
***************************************************************************/
PROCEDURE  DEACTIVATE_ITEMS(
                                   p_table           IN   t_cfg_item_details,
                                   p_org_id          IN   NUMBER,
                                   p_status_code     IN   VARCHAR2,
                                   p_user_id         IN   NUMBER,
                                   p_login_id        IN   NUMBER,
                                   p_request_id      IN   NUMBER,
                                   p_program_appl_id IN   NUMBER,
                                   p_program_id      IN   NUMBER,
                                   x_return_status   OUT  NOCOPY VARCHAR2
                          );


--
-- Forward Declaration
--

PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0);

PROCEDURE check_attribute_control(
                             p_org_id               IN  NUMBER,
                             x_master_orgn_id       OUT NOCOPY NUMBER,
                             x_attr_control         OUT NOCOPY NUMBER,
                             x_return_status        OUT NOCOPY VARCHAR2
                             );
-- bug 2214674
PROCEDURE check_onhand(
                             p_inventory_item_id     IN     NUMBER,
                             p_org_id                IN     NUMBER,
                             x_return_status         OUT  NOCOPY  VARCHAR2
                      );


/**********************************************************************************
Procedure body:	cto_deactivate_configuration:
   This a stored PL/SQL concurrent program which deactivates configuration based on
   different criteria.

INPUT arguments:
 p_org_id :      organization where deactivation program is run (user entered value)
 p_num_of_days:  number of days  (user entered value)
 p_user_id:      user_id of application (default value)
 p_login_id:     login_id of application (default value)
***********************************************************************************/
PROCEDURE cto_deactivate_configuration
                         (
                                errbuf 	 	OUT  NOCOPY   VARCHAR2,
                         	retcode 	OUT  NOCOPY   VARCHAR2,
                         	p_org_id        IN      NUMBER,
			 	p_master_org_id IN	NUMBER,		-- new fix
			 	p_config_id     IN      NUMBER,		-- new fix
			 	p_dummy	 	IN	NUMBER,		-- new fix
			 	p_model_id      IN      NUMBER,		-- new fix
			 	p_optionitem_id IN      NUMBER,		-- new fix
                         	p_num_of_days   IN      NUMBER,
                         	p_user_id 	IN      NUMBER,
                         	p_login_id      IN      NUMBER,
                         	p_template_id   IN      NUMBER

                        )
IS
       l_org_code 		VARCHAR2(3);
       l_number_of_days 	NUMBER;
       l_org_id  		NUMBER;
       l_request_id 		NUMBER;
       l_program_appl_id 	NUMBER;
       l_program_id 		NUMBER;

       l_stat_num  		NUMBER := 0;
       l_count_sel_items 	NUMBER := 0;
       l_return_status 		VARCHAR2(1);
       l_result_message 	VARCHAR2(100);
       l_order_level		NUMBER;

       x_return_status 		VARCHAR2(1);
       x_attr_control   	NUMBER;
       x_master_orgn_id 	NUMBER;
       x_attr_flag   		VARCHAR2(1);

       --
       -- PL/SQL tables for holding config items
       --
       l_deactivated_items     	t_cfg_item_details;
       l_un_deactivated_items  	t_cfg_item_details;

       loop_counter		NUMBER;
       l_prev_item_id    	NUMBER;
       l_prev_org_id    	NUMBER;
       l_prev_item_name    	MTL_SYSTEM_ITEMS_KFV.concatenated_segments%type;
       l_index 			NUMBER;
       l_del_status 		BOM_PARAMETERS.bom_delete_status_code%type;
       l_selected_inv_item_id 	MTL_SYSTEM_ITEMS_KFV.inventory_item_id%type;

       --bugfix#2162892
       l_selected_inv_item_name MTL_SYSTEM_ITEMS_KFV.concatenated_segments%type;

       --flag to move to next step
       l_next_step_flag 	VARCHAR2(1);


       /***********************************
	New fix declaration
	***********************************/

	gMatchChk	VARCHAR2(3);
	gCusMatchChk    VARCHAR2(3);
	l_Config_Id	NUMBER;
	l_Model_Id	NUMBER;
	l_OptionItem_Id NUMBER;
	l_config_match  VARCHAR2(1);
	l_model_desc	VARCHAR2(50);
	i 		NUMBER := 0;
	l_check_flag 	VARCHAR2(1):= 'N';
	l_chk_cfg	NUMBER := 0;	-- bugfix 3443251

	TYPE MpConfigCurTyp is REF CURSOR ;
	TYPE ChConfigCurTyp is REF CURSOR ;

	mpconfig_cv MpConfigCurTyp;
	chconfig_cv ChConfigCurTyp;

	TYPE tmp_item_rec IS RECORD(
     		cfg_item_id    	mtl_system_items_kfv.inventory_item_id%type,
     		cfg_item_name  	mtl_system_items_kfv.concatenated_segments%type,
     		cfg_orgn_id    	number,
     		msg 		VARCHAR2(1)
     	);

	TYPE tmp_item_tab IS TABLE OF  tmp_item_rec INDEX BY BINARY_INTEGER;

	tmp_item_arr	tmp_item_tab;

	-- begin new variables for bugfix 3275577

	l_item_rec 	INV_ITEM_GRP.Item_rec_type;
	x_item_rec 	INV_ITEM_GRP.Item_rec_type;
	x_err_tbl   	INV_ITEM_GRP.Error_tbl_type;

	-- end new variables for bugfix 3275577

	/*************************************************/



BEGIN

     WriteToLog('Begin Deactivation Configuration Items process with Debug Level: '||gDebugLevel);
     WriteToLog('Parameters passed..');
     WriteToLog('  Organization Id  : '||p_org_id);
     WriteToLog('  Shipped number of days ago : '||p_num_of_days);
     -- new fix
     WriteToLog('  Config Item Id  : '||p_Config_Id);
     WriteToLog('  Base Model Id : '||p_Model_Id);
     WriteToLog('  Option Item Id  : '||p_OptionItem_Id);

     --bug#3975124
     WriteToLog('  Template Id  : '||p_template_id);

     l_org_id         :=  p_org_id ;
     l_number_of_days :=  p_num_of_days ;
     -- new fix
     l_Config_Id      :=  p_Config_Id;
     l_Model_Id       :=  p_Model_Id;
     l_OptionItem_Id  :=  p_OptionItem_Id;

     l_stat_num :=10;

     /* new fix comment

     SELECT FCR.request_id,
            FCR.program_application_id,
            FCR.concurrent_program_id
     INTO   l_request_id,
            l_program_appl_id,
            l_program_id
     FROM   fnd_concurrent_requests FCR,
            fnd_concurrent_programs FCP
     WHERE  FCR.program_application_id =  FCP.application_id
     AND    FCR.concurrent_program_id = FCP.concurrent_program_id
     AND    FCP.concurrent_program_name = 'BOMCCIPD'
     -- AND    FCR.phase_code = 'R'
     -- new fix
     AND    FCR.argument1 = to_char (p_org_id)
     AND    nvl(FCR.argument3,'1') = nvl(to_char (p_config_id),'1')
     AND    nvl(FCR.argument5,'1') = nvl(to_char (p_model_id),'1')
     AND    nvl(FCR.argument6,'1') = nvl(to_char (p_optionitem_id),'1')
     AND    FCR.argument7 = to_char (p_num_of_days)
     AND    FCR.argument8 = to_char (p_user_id)
     AND    FCR.argument9 = to_char (p_login_id);

     */

     l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
     l_program_appl_id := FND_GLOBAL.PROG_APPL_ID;
     l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;


     WriteToLog('request_id      => '||l_request_id, 5);
     WriteToLog('program_appl_id => '||l_program_appl_id, 5);
     WriteToLog('program_id      => '||l_program_id, 5);


     l_stat_num :=20;

     --
     -- getting bom_delete_status_code for given organization
     --

     WriteToLog('Checking the delete status code..',3);
     GET_BOM_DELETE_STATUS_CODE (l_org_id, l_del_status, l_return_status);

     WriteToLog('Status Code = '||l_del_status);

     --
     -- If it returns FALSE, then, you have not setup your parameters correctly.
     --

     if l_return_status = FND_API.G_FALSE then
            fnd_file.put_line(fnd_file.log, 'Action: 1. Set the BOM parameters for the organization.');
            fnd_file.put_line(fnd_file.log, '        2. Set the Inactive Status code in the BOM parameters.');
            errbuf := 'completed with warning';
            retcode := 1; --exits with warning
            return;
     end if;

     l_stat_num :=30;

     WriteToLog('Checking the attribute control ..',3);
     CHECK_ATTRIBUTE_CONTROL (l_org_id, x_master_orgn_id, x_attr_control, x_return_status );

     --
     -- Cache the value of Master Orgn Id and Attribute Control
     --

     gMasterOrgn  := x_master_orgn_id;
     gAttrControl := x_attr_control;

     WriteToLog ('gMasterOrgn = '||gMasterOrgn);
     WriteToLog ('gAttrControl = '||gAttrControl);


     --
     -- If it returns FALSE, then, you are running the process from a child orgn when
     -- the attribute control for item status is set to Master Level.
     --

     IF x_return_status = FND_API.G_FALSE THEN
            fnd_file.put_line(fnd_file.log, 'Attribute control for Item Status is set to Master Level.');
            fnd_file.put_line(fnd_file.log, 'Please run this concurrent program from the master organization.');
	    retcode := 1;	-- exits with warning
	    return;
     END IF;

     -- New fix
     -- Add match chk and custom match chk

     gMatchChk 		:= NVL( FND_PROFILE.Value('BOM:MATCH_CONFIG'), 2 );
     gCusMatchChk 	:= NVL( FND_PROFILE.Value('BOM:CUSTOM_MATCH') , 2 );

	WriteToLog('Config match '||  gMatchChk    , 2 );
	WriteToLog(' Custom match '|| gCusMatchChk , 2 );

     -- start new fix

     If ( gAttrControl = 1 ) OR ( p_Org_Id = gMasterOrgn ) then

	If p_Config_Id is NULL and p_Model_Id is NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case1 : Master Org is passed', 2 );

		OPEN mpconfig_cv FOR
		select  msi.inventory_item_id,
                 	msi.concatenated_segments,
                 	msi.organization_id,
                 	decode(mp.organization_id, mp.master_organization_id, 2, 1) order_level
       		from    mtl_system_items_kfv msi,
                 	mtl_parameters mp
       		where   msi.base_item_id is NOT NULL
       		and     msi.inventory_item_status_code <> l_del_status
       		and     msi.organization_id = mp.organization_id
       		and     mp.master_organization_id = l_Org_Id
		ORDER BY  1, 4;

	elsif p_Config_Id is NOT NULL and p_Model_Id is NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case2 : Master Org and Config is passed', 2 );

		OPEN mpconfig_cv FOR
		select  msi.inventory_item_id,
                 	msi.concatenated_segments,
                 	msi.organization_id,
                 	decode(mp.organization_id, mp.master_organization_id, 2, 1) order_level
       		from    mtl_system_items_kfv msi,
                 	mtl_parameters mp
       		where   msi.inventory_item_status_code <> l_del_status
       		and     msi.organization_id = mp.organization_id
  		and     msi.inventory_item_id = l_Config_Id
       		and     mp.master_organization_id = l_org_id
		ORDER BY  1, 4;

	elsif p_Config_Id is NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case3 : Master Org and Base Model is passed', 2 );

		OPEN mpconfig_cv FOR
		select  msi.inventory_item_id,
                 	msi.concatenated_segments,
                 	msi.organization_id,
                 	decode(mp.organization_id, mp.master_organization_id, 2, 1) order_level
       		from    mtl_system_items_kfv msi,
                 	mtl_parameters mp
       		where   msi.base_item_id = l_Model_Id
		and     msi.inventory_item_status_code <> l_del_status
       		and     msi.organization_id = mp.organization_id
       		and     mp.master_organization_id = l_org_id
		ORDER BY  1, 4;

	elsif p_Config_Id is NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NOT NULL then

	  WriteToLog('Case4 : Master Org,Base Model and Option Item is passed', 2 );
	  --Deactivate all the configs in this org when model's match attr is N.
          -- rkaza. bug 3927712.
          -- querying against config bom instead of model bom
		OPEN mpconfig_cv FOR
		select  msi.inventory_item_id,
                 	msi.concatenated_segments,
                 	msi.organization_id,
                 	decode(mp.organization_id, mp.master_organization_id, 2, 1) order_level
       		from    mtl_system_items_kfv msi,
                 	mtl_parameters mp
       		where   msi.base_item_id = l_Model_Id
		and     msi.inventory_item_status_code <> l_del_status
       		and     msi.organization_id = mp.organization_id
       		and     mp.master_organization_id = l_org_id
		and 	msi.inventory_item_id in (
				          select bom.assembly_item_id
					  from bom_bill_of_materials bom,
					       bom_inventory_components b1,
				       	       bom_inventory_components b2
					  where b1.bill_sequence_id =b2.bill_sequence_id
					  and	b1.component_item_id = l_Model_Id
					  and b2.component_item_id = l_OptionItem_Id
					  and b1.bill_sequence_id = bom.common_bill_sequence_id
					  and bom.organization_id = mp.organization_id )
		ORDER BY  1, 4;



	elsif p_Config_Id is NOT NULL and p_Model_Id is NOT NULL then

	   fnd_file.put_line(fnd_file.log, 'Invalid Combination . Config item and base model cannot be entered together');
	   errbuf := 'completed with warning';
           retcode := 1; --exits with warning
	   return;

	elsif p_Config_Id is NOT NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NOT NULL then

	   fnd_file.put_line(fnd_file.log, 'Invalid Combination . Config item, base model and option item cannot be entered all at the same time');
	   errbuf := 'completed with warning';
           retcode := 1; --exits with warning
	   return;
	end if;

     else

     -- when child org is passed

	If p_Config_Id is NULL and p_Model_Id is NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case5 : Child Org is passed', 2 );

	      if ( gMatchChk = 1 ) OR ( gCusMatchChk = 1 ) then

	         WriteToLog(' Match profile is ON.', 2 );
		 WriteToLog(' Only those configurations that are not used for future matches '||
		            ' will be deactivated in this org ',2);

                 --
                 -- bug 7383631
                 -- Modified the cursor for performance
                 -- ntungare
                 --
		 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv msi
       		 where     organization_id = l_org_id
		 and	   base_item_id is NOT NULL
       		 and       inventory_item_status_code <> l_del_status
		 and	   NOT EXISTS (
		 		select 1
				from bom_ato_configurations
				where config_item_id =  msi.inventory_item_id
                                  and rownum = 1)
       		 ORDER BY  inventory_item_id;

	      else

		 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv
       		 where     organization_id = l_org_id
		 and	   base_item_id is NOT NULL
       		 and       inventory_item_status_code <> l_del_status
       		 ORDER BY  inventory_item_id;

	      end if;

	elsif p_Config_Id is NOT NULL and p_Model_Id is NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case6 : Child Org and Config is passed', 2 );

	      if ( gMatchChk = 1 ) OR ( gCusMatchChk = 1 ) then

	         WriteToLog(' Match profile is ON. ', 2 );

		 -- check if config is in match table

		 -- bugfix 3443251 : Add exception
		 -- handling NO_DATA_FOUND exception and continue if there are
		 -- no rows in bom_ato_configurations.

		 Begin
		  select 1 into l_chk_cfg
		  from bom_ato_configurations
		  where config_item_id = l_config_id;
		 Exception
		  WHEN NO_DATA_FOUND THEN
		    WriteToLog(' This configuration '||l_config_id||' does not exist in match table.', 2);
		    l_chk_cfg := 0;
		 END;



		 -- If config exist in match table
		 -- display error message and disallow deactivation

		 if l_chk_cfg = 1 then

		    fnd_file.put_line(fnd_file.log, ' This configuration '|| l_config_id || ' exists in match table ' || ' and can be used for future match . ' || ' Deactivation is not allowed for this item ');
		    errbuf := 'completed with warning';
            	    retcode := 1; --exits with warning
		    return;

		 end if;

	      end if;

	      -- bugfix 3443251: Add if statement
	      -- continue if l_chk_cfg is 0

	      if l_chk_cfg = 0 then

		-- if match in not ON or config does not exist in match table
		-- deactivate the config.

		 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv
       		 where     organization_id = l_org_id
		 and	   inventory_item_id = l_config_id
       		 and       inventory_item_status_code <> l_del_status
       		 ORDER BY  inventory_item_id;

	      end if;

	elsif p_Config_Id is NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NULL then

	  WriteToLog('Case7 : Child Org and Base Model is passed', 2 );

	    if ( gMatchChk = 1 ) OR ( gCusMatchChk = 1 ) then

	        WriteToLog('Match profile is ON. Checking item level match attribute...', 2 );

		select nvl(config_match,'Y'), concatenated_segments
		into l_config_match, l_model_desc
		from mtl_system_items_kfv
		where inventory_item_id = l_Model_Id
		and   organization_id = l_org_id;

		if l_config_match = 'Y' or l_config_match = 'C' then

		 fnd_file.put_line(fnd_file.log, ' This Model (' || l_model_desc || ') is used for matching and cannot be deactivated in child orgn. Please run it from the master orgn.');
		 errbuf := 'completed with warning';
            	 retcode := 1; --exits with warning
		 return;

		end if;

	    end if;
	    		-- following code will be executed if
			-- site level match is NO.
			-- OR site level is yes but model level match is NO
			-- So deactivate
			-- what happens in case when model's match attr is N but config exists in match tables?
			-- Deactivate all the configs in this org when model's match attr is N.

		 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv
       		 where     organization_id = l_org_id
		 and	   base_item_id = l_Model_Id
       		 and       inventory_item_status_code <> l_del_status
       		 ORDER BY  inventory_item_id;


	elsif p_Config_Id is NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NOT NULL then

	   WriteToLog(' Case8 : Child Org,Base Model and Option Item is passed ', 2 );
	   WriteToLog( ' If Base Model''s match attribute is set , then , '||
	               ' after running this program  Models and configs sourcing rules '||
	               ' will need to be manually  corrected to remove this organization '||
		       ' as a future source for this model ',2);
	   WriteToLog( ' Please refer to deactivation item list for config items ', 2 );

	      if ( gMatchChk = 1 ) OR ( gCusMatchChk = 1 ) then

	         WriteToLog(' Match profile is ON.',2);

                 -- rkaza. bug 3927712.
                 -- querying against config bom instead of model bom

                 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv
       		 where     organization_id = l_org_id
		 and	   base_item_id = l_Model_Id
       		 and       inventory_item_status_code <> l_del_status
		 and 	   option_specific_sourced in (1,2)
		 and	   inventory_item_id in  (
				    select bom.assembly_item_id
		                    from bom_bill_of_materials bom,
				         bom_inventory_components b1,
				         bom_inventory_components b2
			            where b1.bill_sequence_id =b2.bill_sequence_id
				    and	b1.component_item_id = l_Model_Id
				    and b2.component_item_id = l_OptionItem_Id
				    and   b1.bill_sequence_id = bom.common_bill_sequence_id
				    and   bom.organization_id = l_org_id
				     )
       		 ORDER BY  inventory_item_id;

	     else

                 -- rkaza. bug 3927712.
                 -- querying against config bom instead of model bom

		 OPEN chconfig_cv FOR
		 select    inventory_item_id,
   			   concatenated_segments
       		 from      mtl_system_items_kfv
       		 where     organization_id = l_org_id
		 and	   base_item_id = l_Model_Id
       		 and       inventory_item_status_code <> l_del_status
		 and	   inventory_item_id in  (
				    select bom.assembly_item_id
		                    from bom_bill_of_materials bom,
				         bom_inventory_components b1,
				         bom_inventory_components b2
			            where b1.bill_sequence_id =b2.bill_sequence_id
				    and	b1.component_item_id = l_Model_Id
				    and b2.component_item_id = l_OptionItem_Id
				    and   b1.bill_sequence_id = bom.common_bill_sequence_id
				    and   bom.organization_id = l_org_id)
       		 ORDER BY  inventory_item_id;



	     end if;

	elsif p_Config_Id is NOT NULL and p_Model_Id is NOT NULL then

	   fnd_file.put_line(fnd_file.log, 'Invalid Combination . Config item and base model cannot be entered together');
	   errbuf := 'completed with warning';
    	   retcode := 1; --exits with warning
	   return;

	elsif p_Config_Id is NOT NULL and p_Model_Id is NOT NULL and p_OptionItem_Id is NOT NULL then

	   fnd_file.put_line(fnd_file.log, 'Invalid Combination . Config item, base model and option item cannot be entered all at the same time');
	   errbuf := 'completed with warning';
    	   retcode := 1; --exits with warning
	   return;

	end if;

     end if;

     -- new fix ends here

     x_attr_flag := FND_API.G_FALSE;

     loop_counter := 0;

     << beginloop>>

     LOOP

     	      l_stat_num := 35;

	      loop_counter := loop_counter + 1;

     	      If ( gAttrControl = 1 ) OR ( p_Org_Id = gMasterOrgn ) then
		fetch mpconfig_cv into  l_selected_inv_item_id,
					l_selected_inv_item_name,
					l_org_id,
					l_order_level;
	        exit when mpconfig_cv%notfound;
     	      else
                fetch chconfig_cv into    l_selected_inv_item_id,
					  l_selected_inv_item_name;
	        exit when chconfig_cv%notfound;
     	      end if;

              WriteToLog( '----------------------------------------------------------------------',3);
              WriteToLog( 'Processing Inventory Item Id '||l_selected_inv_item_id||' ('||
			   l_selected_inv_item_name||' )' ||' in organization '||l_org_id, 3);
              WriteToLog( '----------------------------------------------------------------------',3);


	      --
	      -- If the attribute control is set to Master Level and if an item fails
	      -- validation in one of the orgs, then, skip processing this item in other orgs.
	      --
     	      If ( gAttrControl = 1 ) OR ( p_Org_Id = gMasterOrgn ) then

	         if (l_prev_item_id = l_selected_inv_item_id and
		    x_attr_flag = FND_API.G_TRUE )
  	         then
                     WriteToLog( 'Skipped processing since this item in another orgn failed validation.', 3);
		     l_result_message := 'Skipped processing since this item in another orgn failed validation';
                     WriteToLog( 'Registering Result for un-deactivated items..',3);

                     REGISTER_RESULT(l_un_deactivated_items,
                                     l_selected_inv_item_id,
                                     l_selected_inv_item_name,
				     l_org_id,
                                     l_result_message);

		     l_prev_item_id   := l_selected_inv_item_id;
		     l_prev_item_name := l_selected_inv_item_name;
		     l_prev_org_id    := l_org_id;

		     --continue with next record..
		     goto beginloop;
	         else
		     x_attr_flag := FND_API.G_FALSE; 	-- Reset the flag for next item
	             failed_flag(l_selected_inv_item_id) := FND_API.G_FALSE;	-- no errors for the selected item yet.
	         end if;
	      end if;


              l_next_step_flag := FND_API.G_FALSE;

              --
              --checks if the item is already inactive or has pending inactive status
              --
              if l_next_step_flag = FND_API.G_FALSE then
                 l_stat_num :=40;
                 WriteToLog( 'Checking delete status ..',3);

                 CHECK_DELETE_STATUS(   l_selected_inv_item_id,
                                        l_org_id,
                                        l_del_status,
                                        x_return_status);


                 --
                 --if item is already inactive
                 --
                 IF x_return_status = FND_API.G_TRUE THEN
                   WriteToLog( 'ERROR: Item already deactivated or has inactive status in pending.',3);
                   l_result_message := 'Item already deactivated or has inactive status in pending.';
                   l_next_step_flag := FND_API.G_TRUE;
                 END IF;

              end if;

	      -- remove CHECK_ITEM_IN_CHILD_ORG

              --
              --checks for common routing
              --

              IF l_next_step_flag = FND_API.G_FALSE THEN
                   l_stat_num :=60;

                   WriteToLog( 'Checking common routing ..',3);
                   CHECK_COMMON_ROUTING(      l_selected_inv_item_id,
                                              l_org_id,
                                              l_del_status,
                                              x_return_status );


                 --
                 --if item has common routing
                 --

                 IF x_return_status = FND_API.G_TRUE THEN
                    WriteToLog('ERROR: Item has a common routing.',3);
                    l_result_message := 'Item has a common routing.';
                    l_next_step_flag := FND_API.G_TRUE;
                 END IF;
              END IF;



	      --
	      --checks for common bom
	      --

              IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num :=70;
                 WriteToLog( 'Checking common BOM ..',3);
                 CHECK_COMMON_BOM(    l_selected_inv_item_id,
                                      l_org_id,
                                      l_del_status,
                                      x_return_status);


                 --
                 --if item has common routing
                 --
                 IF x_return_status = FND_API.G_TRUE THEN
                   -- l_next_step_flag := 'N';
                    l_next_step_flag := FND_API.G_TRUE;
                    WriteToLog('ERROR: Item has a common BOM ',3);
                    l_result_message := 'Item has a common BOM ';
                 END IF;
              END IF;


              --
              --checks for onhand (bug 2214674)
              --

              IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num := 80;

                 WriteToLog( 'Checking onhand ..',3);
                 CHECK_ONHAND(   l_selected_inv_item_id,
                                 l_org_id,
                                 x_return_status);

                 --
                 --if item has onhand
                 --
                 IF x_return_status = FND_API.G_TRUE THEN
                    WriteToLog('ERROR: Item has onhand.',3);
                    l_result_message := 'Item has onhand.';
                    l_next_step_flag := FND_API.G_TRUE;
                 END IF;
              END IF;



              --
              --checks for open supply
              --
              IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num := 80;

                 WriteToLog( 'Checking open supply ..',3);
                 CHECK_OPEN_SUPPLY(   l_selected_inv_item_id,
                                      l_org_id,
                                      x_return_status);


                 --
                 --if item has common supply
                 --
                 IF x_return_status = FND_API.G_TRUE THEN
                    WriteToLog('ERROR: Item has open supply', 3);
                    l_result_message := 'Item has open supply';
                    l_next_step_flag := FND_API.G_TRUE;
                 END IF;
              END IF;



	      --
	      --checks for open demand
	      --
              IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num :=90;

                 WriteToLog( 'Checking open demand ..',3);
                 CHECK_OPEN_DEMAND(   l_selected_inv_item_id,
                                      l_org_id,
                                      x_return_status);

                 --
                 --if item has common demand
                 --
                 IF x_return_status = FND_API.G_TRUE THEN
                    l_next_step_flag := FND_API.G_TRUE;
                    WriteToLog( 'ERROR: Item has open demand', 3);
                    l_result_message := 'Item has open demand';
                 END IF;
             END IF;



 	     --
 	     --checks for material transaction
 	     --
             IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num :=100;

                 WriteToLog( 'Checking material transactions ..',3);
                 CHECK_MATERIAL_TRANSACTION(    l_selected_inv_item_id,
                                                l_org_id,
                                                p_num_of_days,
                                                x_return_status);


                 --
                 --if item has material transactions within given num of days after shipping
                 --
                 IF x_return_status = FND_API.G_TRUE THEN

                    l_next_step_flag := FND_API.G_TRUE;
                    WriteToLog ('ERROR: Item has material transaction within '|| p_num_of_days||
				' days after shipping.', 3);
                    l_result_message := 'Item has material transaction within '|| p_num_of_days||
				' days after shipping.';
                 END IF;
            END IF;

 	     --
         --Begin Bugfix 7011607
         --checks for active parent configs
 	     --
             IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num :=110;

                 WriteToLog( 'Checking active parent ..',3);
                 CHECK_ACTIVE_PARENT_CONFIG(    l_selected_inv_item_id,
                                                l_org_id,
                                                x_return_status);


                 --
                 --if item has an active parent config
                 --
                 IF x_return_status = FND_API.G_TRUE THEN

                    l_next_step_flag := FND_API.G_TRUE;
                    WriteToLog ('ERROR: Item has an active parent config item.', 3);
                    l_result_message := 'Item has an active parent config item.';
                 END IF;
            END IF;

         --End Bugfix 7011607

	     -- begin bugfix 3275577 : Apply Template.
 	     --
 	     -- Apply template
 	     --
             IF l_next_step_flag = FND_API.G_FALSE THEN
                 l_stat_num :=115;

                 WriteToLog( 'Applying Template ..',3);
	         if (p_template_id is not null) then
	    	     l_item_rec.INVENTORY_ITEM_ID := l_selected_inv_item_id;
	    	     l_item_rec.ORGANIZATION_ID   := l_org_id;

	    	     INV_ITEM_GRP.Update_Item
		     (
	       	 	p_Item_rec            => l_item_rec
	     		,  x_Item_rec         => x_item_rec
	     		,  x_return_status    => x_return_status
	     		,  x_Error_tbl        => x_err_tbl
	     		,  p_Template_Id      => p_template_id
	     	     );

	    	     if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
			WriteToLog ('INV_ITEM_GRP.Update_Item returned status '|| x_return_status ||'. Failed to apply template.');
			l_result_message := 'Failed to apply template.';
                        l_next_step_flag := FND_API.G_TRUE;

	    	     end if;
	         end if;

	         -- end bugfix 3275577

            END IF;


	--
	-- If the attribute control is at Master level, should we insert the child orgs
	-- also in mtl_pending_item_status or just master level insertion is fine ?
	-- shailendra agarwal (skagarwa) from BOM team confirmed on Jul 31st that we dont have to
	-- insert the child orgs if attr control is at master level
	--

	-- Printing attrib control and org id

	WriteToLog( 'Attrib control '||x_attr_control||' Org '||p_org_id||' Master Org '||gMasterOrgn ,3);

            IF x_attr_control = 1  THEN
	    --
	    --Master Level
	    --
		if l_next_step_flag = FND_API.G_TRUE then	-- validation failed for the current record

		   retcode := 1; 	-- warning

		   --
		   -- if the current record fails validation, set the failed_flag to TRUE for this item
		   -- and put it in the un-deactivacted items..
		   --

		   failed_flag(l_selected_inv_item_id) := FND_API.G_TRUE;
		   x_attr_flag := FND_API.G_TRUE;


                   WriteToLog( 'Registering Result for un-deactivated items..',3);
                   REGISTER_RESULT(  l_un_deactivated_items,
                                     l_selected_inv_item_id,
                                     l_selected_inv_item_name,
				     l_org_id,
                                     l_result_message);
		end if;

                WriteToLog( 'failed_flag ('||l_selected_inv_item_id||') = '||failed_flag(l_selected_inv_item_id) );

	        -- We dont want to register the result of very first record (=item) since this item may exist in another orgn.
		-- Hence, loop_counter logic.

	        if ( loop_counter > 1 AND l_prev_item_id <> l_selected_inv_item_id) then
                --
                --populate the result
                --
                     l_stat_num :=120;
                     IF failed_flag(l_prev_item_id) = FND_API.G_FALSE THEN

                         WriteToLog( 'Registering Result for deactivated items..', 3);
                         REGISTER_RESULT(l_deactivated_items,
                                         l_prev_item_id,
                                         l_prev_item_name,
				         x_master_orgn_id,
					 null);
                     END IF;
	        end if;

	    -- new code
	    -- This is the case when atrrib control is child level but the program was
    	    -- run from master org.

	    ELSIF ( x_attr_control <> 1 ) and ( p_Org_Id = gMasterOrgn ) THEN

	    	if ( loop_counter = 1 ) then

			-- no previous item
			-- populate temp table with selected item

			i := 1;

			tmp_item_arr(i).cfg_item_id 	:= l_selected_inv_item_id;
			tmp_item_arr(i).cfg_item_name	:= l_selected_inv_item_name;
			tmp_item_arr(i).cfg_orgn_id	:= l_org_id;
			tmp_item_arr(i).msg		:= l_next_step_flag;

			-- Writing to log

        		if tmp_item_arr.count > 0 then

          		   WriteToLog (' Loop counter '||loop_counter,3);
			   Writetolog (' i '|| i ||' Item name '||tmp_item_arr(i).cfg_item_name||
  				       ' Org '|| tmp_item_arr(i).cfg_orgn_id ||
				       ' Flag ' || tmp_item_arr(i).msg,3 );

        		end if;


			i := i + 1;


		elsif ( loop_counter > 1 ) AND ( l_prev_item_id = l_selected_inv_item_id) then

			-- populate temp table with selected item

			tmp_item_arr(i).cfg_item_id 	:= l_selected_inv_item_id;
			tmp_item_arr(i).cfg_item_name	:= l_selected_inv_item_name;
			tmp_item_arr(i).cfg_orgn_id	:= l_org_id;
			tmp_item_arr(i).msg		:= l_next_step_flag;

			-- Writing to log

        		if tmp_item_arr.count > 0 then

          		   WriteToLog (' Loop counter '||loop_counter,3);
			   WriteToLog (' Prev Item Id '||l_prev_item_id,3);
			   Writetolog (' i '|| i ||' Item name '||tmp_item_arr(i).cfg_item_name||
  				       ' Org '|| tmp_item_arr(i).cfg_orgn_id ||
				       ' Flag ' || tmp_item_arr(i).msg,3);

        		end if;

			i := i + 1;

		elsif ( loop_counter > 1 ) AND (l_prev_item_id <> l_selected_inv_item_id) then

			-- perform register result from temp table for previous items
			-- check if l_next_step_flag is TRUE

			if tmp_item_arr.count > 0 then
			   for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
			      loop
			         l_check_flag := tmp_item_arr(x1).msg;
				    if l_check_flag = 'T' then
				    -- item should not be deactivated

		   			retcode := 1; 	-- warning

				    -- Writing to log
					for x2 in tmp_item_arr.FIRST..tmp_item_arr.LAST
					 loop
          		   		   WriteToLog (' Before populating non deactivated list ',3);
			   		   Writetolog (' Item name '||tmp_item_arr(x2).cfg_item_name||
  				       		       ' Org '|| tmp_item_arr(x2).cfg_orgn_id ||
						       ' Flag ' || tmp_item_arr(x2).msg ,3 );
					 end loop;

				    -- Populating non deactivated list

					for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
					   loop
				       		REGISTER_RESULT( l_un_deactivated_items,
                                     				 tmp_item_arr(x1).cfg_item_id ,
                                    				 tmp_item_arr(x1).cfg_item_name ,
				     				 tmp_item_arr(x1).cfg_orgn_id ,
                                     			  	 l_result_message);
					   end loop;	-- end inside loop when flag is TRUE
			 	        exit ;		-- EXIT outside loop as we dont want to deactivate
				     end if;		-- check_flag = 'T'
			       end loop;		-- end outside loop

			   -- execute this when all check_flag = 'F'

			   if l_check_flag = 'F' then
			   -- item should be dactivated

			   -- Writing to log

			    for x2 in tmp_item_arr.FIRST..tmp_item_arr.LAST
				loop
          		   	   WriteToLog (' Before populating deactivated list ',3);
			   	   Writetolog (' Item name '||tmp_item_arr(x2).cfg_item_name||
  					       ' Org '|| tmp_item_arr(x2).cfg_orgn_id ||
				               ' Flag ' || tmp_item_arr(x2).msg ,3 );
				 end loop;

			   -- Populating deactivated list

        		     for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
			        loop
				  REGISTER_RESULT( l_deactivated_items,
                                     		   tmp_item_arr(x1).cfg_item_id ,
                                    		   tmp_item_arr(x1).cfg_item_name ,
				     		   tmp_item_arr(x1).cfg_orgn_id
						 );
			        end loop;		-- end loop when all flag is FALSE
			   end if;			-- check_flag = 'F'

			end if;				-- count

			-- clear temp table and initialize variables;
			i 		:= 0;
			l_check_flag 	:= 'N';

			if tmp_item_arr.count > 0 then
          		   for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
            		      loop
               			tmp_item_arr.DELETE(x1);
            		      end loop;
        		end if;

			-- Populate temp table with new item
			-- Handle last item rows of temp table outside loop

			i := 1;

			tmp_item_arr(i).cfg_item_id 	:= l_selected_inv_item_id;
			tmp_item_arr(i).cfg_item_name	:= l_selected_inv_item_name;
			tmp_item_arr(i).cfg_orgn_id	:= l_org_id;
			tmp_item_arr(i).msg		:= l_next_step_flag;

			-- Writing to log

        		if tmp_item_arr.count > 0 then

          		   WriteToLog (' Loop counter '||loop_counter,3);
			   WriteToLog (' Prev Item Id '||l_prev_item_id,3);
			   Writetolog (' i '|| i ||' Item name '||tmp_item_arr(i).cfg_item_name||
  				       ' Org '|| tmp_item_arr(i).cfg_orgn_id ||
				       ' Flag ' || tmp_item_arr(i).msg , 3);

        		end if;


			i := i + 1;



		end if;

 	    ELSE
	    --
	    -- Organization Level
	    --

                IF l_next_step_flag = FND_API.G_FALSE THEN

                    WriteToLog( 'Registering Result for deactivated items..', 3);
                    REGISTER_RESULT( l_deactivated_items,
                                     l_selected_inv_item_id,
                                     l_selected_inv_item_name,
				     l_org_id);
                ELSE

		    retcode := 1; 	-- warning
                    WriteToLog( 'Registering Result for un-deactivated items..',3);
                    REGISTER_RESULT( l_un_deactivated_items,
                                     l_selected_inv_item_id,
                                     l_selected_inv_item_name,
				     l_org_id,
                                     l_result_message);
                END IF;

            END IF;

  	    l_prev_item_id   := l_selected_inv_item_id;
	    l_prev_item_name := l_selected_inv_item_name;
	    l_prev_org_id    := l_org_id;

     END LOOP;

    --
    -- To process the last record selected (and when there is one and only one record to process),
    -- the following logic will take care.
    -- For orgn level control, this will not be needed since the above logic takes care.
    -- rkaza. bug 3927712. Do not resgister if there are no records.
    -- Adding loop_counter condition to ensure that.
    if x_attr_control = 1 then
       if x_attr_flag = FND_API.G_FALSE and loop_counter > 1 then

          WriteToLog( 'Registering Result for deactivated items..', 3);
          REGISTER_RESULT(l_deactivated_items,
                          l_selected_inv_item_id,
                          l_selected_inv_item_name,
			  x_master_orgn_id);
       end if;
    -- new
    -- This is the case when atrrib control is child level but the program was
    -- run from master org. Here we are handling last item ( which could have
    -- single or multiple rows )
    elsif ( x_attr_control <> 1 ) and ( p_Org_Id = gMasterOrgn ) then

    	-- peform register result of temp table
	if tmp_item_arr.count > 0 then
			   for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
			      loop
			         l_check_flag := tmp_item_arr(x1).msg;
				    if l_check_flag = 'T' then
				    -- item should not be deactivated

				    retcode := 1;

				    -- Writing to log

			    		for x2 in tmp_item_arr.FIRST..tmp_item_arr.LAST
					  loop
          		   	   	    WriteToLog (' Before populating deactivated list ',3);
			   	   	    Writetolog (' Item name '||tmp_item_arr(x2).cfg_item_name||
  					       		' Org '|| tmp_item_arr(x2).cfg_orgn_id ||
				               		' Flag ' || tmp_item_arr(x2).msg ,3 );
				 	  end loop;

				    -- Populating non deactivated list

					for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
					   loop
				       		REGISTER_RESULT( l_un_deactivated_items,
                                     				 tmp_item_arr(x1).cfg_item_id ,
                                    				 tmp_item_arr(x1).cfg_item_name ,
				     				 tmp_item_arr(x1).cfg_orgn_id ,
                                     			  	 l_result_message);
					   end loop;	-- end inside loop when flag is TRUE
			 	        exit ;		-- EXIT outside loop as we dont want to deactivate
				     end if;		-- check_flag = 'T'
			       end loop;		-- end outside loop

			   -- execute this when all check_flag = 'F'

			   if l_check_flag = 'F' then

			   -- item should be deactivated

			   -- Writing to log

			    for x2 in tmp_item_arr.FIRST..tmp_item_arr.LAST
				loop
          		   	   WriteToLog (' Before populating deactivated list ',3);
			   	   Writetolog (' Item name '||tmp_item_arr(x2).cfg_item_name||
  					       ' Org '|| tmp_item_arr(x2).cfg_orgn_id ||
				               ' Flag ' || tmp_item_arr(x2).msg ,3 );
				 end loop;

			   -- Populating deactivated list

			     for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
			        loop
				  REGISTER_RESULT( l_deactivated_items,
                                     		   tmp_item_arr(x1).cfg_item_id ,
                                    		   tmp_item_arr(x1).cfg_item_name ,
				     		   tmp_item_arr(x1).cfg_orgn_id
						 );
			        end loop;		-- end loop when all flag is FALSE
			   end if;			-- check_flag = 'F'

			end if;				-- count

			-- clear temp table and initialize variables;
			i 		:= 0;
			l_check_flag 	:= 'N';

			if tmp_item_arr.count > 0 then
          		   for x1 in tmp_item_arr.FIRST..tmp_item_arr.LAST
            		      loop
               			tmp_item_arr.DELETE(x1);
            		      end loop;
        		end if;


    end if;


     l_stat_num := 140;
      --
      -- Inserting pending status and deleting matched items from bom_ato_configurations
      --

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (l_deactivated_items.count > 0) THEN --bugfix2308063
        WriteToLog('Calling DEACTIVATE_ITEMS to insert records into mtl_pending_status table. ', 5);

        DEACTIVATE_ITEMS( l_deactivated_items,
                          p_org_id,	-- This parameter is not needed now
				        -- but keepin for backward compatibility
                          l_del_status,
                          p_user_id,
                          p_login_id,
                          l_request_id,
                          l_program_appl_id,
                          l_program_id,
			  x_return_status  );

	if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
		WriteToLog ('Error: DEACTIVATE_ITEMS returned with status '|| x_return_status );
		retcode := 1;
	end if;

     END IF;


    WriteToLog( '======================================================================',3);

    IF chconfig_cv%ISOPEN THEN
       IF chconfig_cv%ROWCOUNT = 0 THEN
         fnd_file.put_line(fnd_file.log, 'No configurations present in the org' || p_org_id);
         l_stat_num :=145;
         CLOSE chconfig_cv;
         fnd_file.put_line(fnd_file.log, 'Concurrent program exiting with success');
         RETURN;

       ELSE
         -- bugfix 2308063
         -- added log messages for usability reasons
         WriteToLog('Deactivation is the process of setting the pending status of '||
		    'configuration item to inactive status code');
         WriteToLog('Oracle Inventorys "Update item statuses with pending statuses" '||
	            'needs to be run to implement the pending status');

         WriteToLog('No of  configurations present => '||chconfig_cv%ROWCOUNT);
         WriteToLog('Total number of deactivated items => '||l_deactivated_items.count);
         WriteToLog('Total number of UN deactivated items => '||l_un_deactivated_items.count);
       END IF;


     ELSIF mpconfig_cv%ISOPEN THEN
       IF mpconfig_cv%ROWCOUNT = 0 THEN
         fnd_file.put_line(fnd_file.log, 'No configurations present in the org ' || p_org_id || ' and in its child orgs.');
         l_stat_num :=146;
         CLOSE mpconfig_cv;
         fnd_file.put_line(fnd_file.log, 'Concurrent program exiting with success');
         RETURN;

       ELSE
         -- bugfix 2308063
         -- added log messages for usability reasons
         WriteToLog('Deactivation is the process of setting the pending status of '||
		    'configuration item to inactive status code');
         WriteToLog('Oracle Inventorys "Update item statuses with pending statuses" '||
	            'needs to be run to implement the pending status');

         --WriteToLog('No of  configurations present => '||mpconfig_cv%ROWCOUNT);
         --WriteToLog('Total number of deactivated items => '||l_deactivated_items.count);
         --WriteToLog('Total number of UN deactivated items => '||l_un_deactivated_items.count);
       END IF;
     END IF;

    WriteToLog( '======================================================================',3);


     l_stat_num := 150;

     if chconfig_cv%isopen then
        CLOSE chconfig_cv;

     elsif mpconfig_cv%isopen then
        CLOSE mpconfig_cv;
     end if;




     l_stat_num := 155;

     -- rkaza. bug 4108700. 01/04/2005. Changing oe_debug to fnd_log.
     -- We show the process summary irrespective of dbg profile setting.

     fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log, 'Deactivated items..');
     fnd_file.put_line(fnd_file.log, 'Total number of deactivated items => '|| l_deactivated_items.count);--bugfix2308063

     IF (l_deactivated_items.count > 0) THEN --checks for uninitialized collection --bugfix2308063

        l_index := l_deactivated_items.FIRST;
        LOOP
             fnd_file.put_line(fnd_file.log, l_deactivated_items(l_index).cfg_item_id || '(' || l_deactivated_items(l_index).cfg_item_name || '): ' ||
	                 'Organization: ' || l_deactivated_items(l_index).cfg_orgn_id || '(' || l_deactivated_items(l_index).cfg_orgn_code || '): '    ); --5291392

             EXIT WHEN l_index = l_deactivated_items.LAST;
             l_index := l_deactivated_items.NEXT(l_index);
        END LOOP;
     END IF;

     l_stat_num := 160;
     fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------');
     fnd_file.put_line(fnd_file.log, 'Un-Decativated items..');
     fnd_file.put_line(fnd_file.log, 'Total number of Un-Deactivated items => ' || l_un_deactivated_items.count );--bugfix2308063

      IF (l_un_deactivated_items.count > 0) THEN  --checks for uninitialized collection --bugfix2308063

          l_index := l_un_deactivated_items.FIRST;
          LOOP
             --bugfix2308063
             fnd_file.put_line(fnd_file.log, l_un_deactivated_items(l_index).cfg_item_id || '(' || l_un_deactivated_items(l_index).cfg_item_name ||'):'||
	                   'Organization: '|| l_un_deactivated_items(l_index).cfg_orgn_id || '(' || l_un_deactivated_items(l_index).cfg_orgn_code ||'):'|| --5291392
			   '::' || l_un_deactivated_items(l_index).msg);

             EXIT WHEN l_index = l_un_deactivated_items.LAST;
             l_index := l_un_deactivated_items.NEXT(l_index);
          END LOOP;
      END IF;
     fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------');

     --Bugfix 6241681: Removing the reference of deactivated configs from bom_cto_order_lines

     IF (l_deactivated_items.count > 0) THEN

        fnd_file.put_line(fnd_file.log, 'Removing the reference of deactivated configs from bom_cto_order_lines..');
        l_index := l_deactivated_items.FIRST;
        LOOP
             fnd_file.put_line(fnd_file.log, 'Removing reference of '||l_deactivated_items(l_index).cfg_item_id||'('||
			l_deactivated_items(l_index).cfg_item_name||'): ');
             UPDATE bom_cto_order_lines
             SET config_item_id = null
             WHERE config_item_id = l_deactivated_items(l_index).cfg_item_id;

             EXIT WHEN l_index = l_deactivated_items.LAST;
             l_index := l_deactivated_items.NEXT(l_index);
        END LOOP;
     END IF;
     --Bugfix 6241681: Removing the reference of deactivated configs from bom_cto_order_lines

     errbuf := 'Program completed succesfully';

EXCEPTION
      WHEN OTHERS THEN
         WriteToLog('Error at statement num =>'|| l_stat_num);
         WriteToLog('Error in cto_deactivate_configuration: '||sqlerrm);
         errbuf := 'Completed with error: '||Sqlerrm;
     	 if chconfig_cv%isopen then
            CLOSE chconfig_cv;
         elsif mpconfig_cv%isopen then
            CLOSE mpconfig_cv;
         end if;
         retcode := 2;--completes with error status

END cto_deactivate_configuration;

/*************************************************************************
Procedure 	DEACTIVATE_ITEMS
 this inserts inactive status for all the selected items for deactivation
 argumnents:

p_table 	: items meeting criteria for deactivation
p_org_id 	: organization where deactivation is run
p_status_code  	: bom_delete_status_code from bom_parameters for given org
p_user_id	: default value

***************************************************************************/
PROCEDURE DEACTIVATE_ITEMS(
                             p_table               IN    t_cfg_item_details,
                             p_org_id              IN    NUMBER,		-- mbsk: not actually needed.
                             p_status_code         IN    VARCHAR2,
                             p_user_id             IN    NUMBER,
                             p_login_id            IN    NUMBER,
                             p_request_id          IN    NUMBER,
                             p_program_appl_id     IN    NUMBER,
                             p_program_id          IN    NUMBER,
                             x_return_status       OUT   NOCOPY VARCHAR2)

IS

	l_index 	BINARY_INTEGER; --bugfix2308063

	l_grp_reference_id number;

	l_row_deleted  number;


BEGIN
        WriteToLog('Inside deactivate_items..' ,5);
	x_return_status := FND_API.G_RET_STS_SUCCESS;	-- bugfix 3275577: Initialize the variable.

        l_index := p_table.FIRST;

        WriteToLog('Before loop in deactivate_items. l_index = '||l_index, 5  );--bugfix2308063


        LOOP

           WriteToLog('inserting item id '||p_table(l_index).cfg_item_id ||
		      ' in organization '||p_table(l_index).cfg_orgn_id, 5);


           INSERT INTO mtl_pending_item_status
                      ( inventory_item_id,
                        organization_id,
                        status_code,
                        effective_date,
                        pending_flag,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date)
           VALUES    (  p_table(l_index).cfg_item_id,
                        p_table(l_index).cfg_orgn_id,		--mbsk
                        p_status_code,
                        sysdate,
                        'Y',
                        sysdate,
                        p_user_id,
                        sysdate,
                        p_user_id,
                        p_login_id,
                        p_request_id,
                        p_program_appl_id,
                        p_program_id,
                        sysdate);


	    -- bug 2477125:

	    -- In addition to disabling the bom and routing for deactivated items, we should
            -- also remove the de-activated configurations from the bom_ato_configurations ,
            -- so that these are not used for future matches.

            -- Please note that configurations stored in this tables are org-indepedent
            -- (matched across orgs), so we will use the following criteria for deletion...

	    -- DO NOT delete if
	    --   - run from child orgn since match is org-independent.

	    -- DELETE only if
	    --   - run from master since we would have checked the statuses in the child.
	    --   - attribute control is set to MASTER.
	    --


	    if ( gAttrControl = 1 or p_table(l_index).cfg_orgn_id = gMasterOrgn )
	    then
	       WriteToLog ('Deleting from Bom_Ato_Configurations..',3);

               DELETE FROM bom_ato_configurations
               WHERE  config_item_id = p_table(l_index).cfg_item_id;

	       --bugfix 3557190
	       l_row_deleted :=sql%rowcount;

	       IF l_row_deleted >0 THEN

		BEGIN
	         SELECT group_reference_id
		 INTO   l_grp_reference_id
		 FROM bom_cto_model_orgs
		 WHERE config_item_id = p_table(l_index).cfg_item_id
		 AND rownum = 1;
		EXCEPTION
	        WHEN no_data_found THEN
                   l_grp_reference_id := Null;
		END;

		 -- new fix
		 --used grp_ref_id in where clause instead of cfg-item_id
		 --as grp_ref_id has index on it
                DELETE FROM bom_cto_model_orgs
                WHERE  group_reference_id = l_grp_reference_id;


	       END IF;

               --end bugfix 3557190



	       if sql%found then
	          WriteToLog ('Deleted item_id '||p_table(l_index).cfg_item_id ||' from Bom_Ato_Configurations..',3);
	       end if;
	    end if;

            EXIT WHEN l_index = p_table.LAST;
            l_index := p_table.NEXT(l_index);

        END LOOP;


        If ( gAttrControl = 1 or p_table(l_index).cfg_orgn_id = gMasterOrgn ) then

	 --
	 -- Master Level Control
	 -- OR
	 -- Child level control but ran from Master Orgn
	 -- Update the BOM in all the orgn.. Disable the components
	 --

           UPDATE bom_inventory_components bic
	   SET disable_date = greatest(least(nvl(bic.disable_date,sysdate)),
			            bic.effectivity_date),
               last_update_date = sysdate,
               last_updated_by  =  p_user_id,
               last_update_login = p_login_id,
	       request_id = p_request_id,
	       program_application_id = p_program_appl_id,
	       program_id = p_program_id,
	       program_update_date = sysdate
	   WHERE  bill_sequence_id in (
		select b.bill_sequence_id
		from bom_bill_of_materials b, mtl_pending_item_status m
		where m.status_code = p_status_code
                and m.pending_flag = 'Y'
                and m.request_id = p_request_id
		-- and m.organization_id = b.organization_id		--mbsk: for master level control
		and m.inventory_item_id = b.assembly_item_id);

	   --
	   -- Update the ROUTING. Disable the operation sequences
	   --
           UPDATE bom_operation_sequences bos
	   SET    disable_date = greatest(least(nvl(bos.disable_date,sysdate)),
				    bos.effectivity_date),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_user_id,
               LAST_UPDATE_LOGIN = p_login_id,
	       request_id = p_request_id,
	       program_application_id = p_program_appl_id,
	       program_id = p_program_id,
	       program_update_date = SYSDATE
	   WHERE  routing_sequence_id in(
		select b.routing_sequence_id
		from bom_operational_routings b,mtl_pending_item_status m
		where m.status_code = p_status_code
                and m.pending_flag = 'Y'
                and m.request_id = p_request_id
		-- and b.organization_id = m.organization_id		--mbsk: for mast level control
		and b.assembly_item_id = m.inventory_item_id);

        else
	 --
	 -- Organization Level Control
	 -- Update the BOM in the specific orgn. Disable the components
	 --

           UPDATE bom_inventory_components bic
	   SET disable_date = greatest(least(nvl(bic.disable_date,sysdate)),
			            bic.effectivity_date),
               last_update_date = sysdate,
               last_updated_by  =  p_user_id,
               last_update_login = p_login_id,
	       request_id = p_request_id,
	       program_application_id = p_program_appl_id,
	       program_id = p_program_id,
	       program_update_date = sysdate
	  WHERE  bill_sequence_id in (
		select b.bill_sequence_id
		from bom_bill_of_materials b, mtl_pending_item_status m
		where m.status_code = p_status_code
                and m.pending_flag = 'Y'
                and m.request_id = p_request_id
		and m.organization_id = b.organization_id
		and m.inventory_item_id = b.assembly_item_id);


	  --
	  -- Update the ROUTING. Disable the operation sequences
	  --
          UPDATE bom_operation_sequences bos
	  SET    disable_date = greatest(least(nvl(bos.disable_date,sysdate)),
				    bos.effectivity_date),
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = p_user_id,
               LAST_UPDATE_LOGIN = p_login_id,
	       request_id = p_request_id,
	       program_application_id = p_program_appl_id,
	       program_id = p_program_id,
	       program_update_date = SYSDATE
	  WHERE  routing_sequence_id in(
		select b.routing_sequence_id
		from bom_operational_routings b,mtl_pending_item_status m
		where m.status_code = p_status_code
                and m.pending_flag = 'Y'
                and m.request_id = p_request_id
		and b.organization_id = m.organization_id
		and b.assembly_item_id = m.inventory_item_id);

        end if;



        COMMIT;

        WriteToLog('Exiting deactivate_items.', 5);

EXCEPTION
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; 	-- bugfix 3275577
       WriteToLog('##exiting DEACTIVATE_ITEMS with error##');
       WriteToLog('error in DEACTIVATE_ITEMS : '||sqlerrm);
       RAISE;
END DEACTIVATE_ITEMS;

/*************************************************************************
procedure 	CHECK_DELETE_STATUS
  this checks if the config item selected for deactivation has already been
  deactivated.

  Returns: true (FNDFND_API.G_TRUE), if already deactivated
           false (FND_API.G_FALSE), if not already deactivated

arguments:
 input:
      p_inventory_item_id : config item being checked for deactivation
      p_org_id :           given org id
      p_delete_status_cod : bom_parameters.bom_delete_status_code
      x_return_status     : return variable
************************************************************************/

PROCEDURE CHECK_DELETE_STATUS(
                                p_inventory_item_id    IN NUMBER,
                                p_org_id               IN NUMBER,
                                p_delete_status_code   IN VARCHAR2,
                                x_return_status        OUT NOCOPY VARCHAR2
                             )
IS

l_status_code bom_parameters.bom_delete_status_code%type;
l_org_id     number;  --Bugfix 7011607

BEGIN

     WriteToLog('Entering check_delete_status.. ', 5 );
     WriteToLog('p_inventory_item_id:'||p_inventory_item_id, 5 );
     WriteToLog('p_org_id:'||p_org_id, 5 );

     --Begin Bugfix 7011607
     if gAttrControl = 1 then
         l_org_id := gMasterOrgn;
     else
        l_org_id := p_org_id;
     END if;

     WriteToLog('l_org_id:'||l_org_id, 5 );
    --End Bugfix 7011607


     SELECT status_code INTO l_status_code
     FROM mtl_pending_item_status
     WHERE organization_id = l_org_id        --Bugfix 7011607
     AND inventory_item_id = p_inventory_item_id
     AND EFFECTIVE_DATE                      --bugfix2308063
         = (SELECT max( EFFECTIVE_DATE)      --bugfix2308063
            FROM mtl_pending_item_status
            WHERE organization_id = l_org_id   --Bugfix 7011607
            AND inventory_item_id = p_inventory_item_id);

     WriteToLog('l_status_code:'||l_status_code, 5 );
     WriteToLog('p_delete_status_code:'||p_delete_status_code, 5 );

    IF l_status_code = p_delete_status_code THEN
       x_return_status := FND_API.G_TRUE;
    ELSE
       x_return_status := FND_API.G_FALSE;
    END IF;

    WriteToLog('Exiting check_delete_status with return status '||x_return_status, 5 );
EXCEPTION
   /* (FP 5546965)Bug 5527407: Handle the case when no record exists in mtl_pending_item_status.  */
   WHEN NO_DATA_FOUND THEN
       WriteToLog('Came to no_data_found in CHECK_DELETE_STATUS', 5);

       select inventory_item_status_code
       into   l_status_code
       from   mtl_system_items
       where  inventory_item_id = p_inventory_item_id
       and    organization_id = l_org_id;  --Bugfix 7011607

       WriteToLog('l_status_code1:'||l_status_code, 5 );
       WriteToLog('p_delete_status_code1:'||p_delete_status_code, 5 );

       IF l_status_code = p_delete_status_code THEN
          x_return_status := FND_API.G_TRUE;
       ELSE
          x_return_status := FND_API.G_FALSE;
       END IF;

       WriteToLog('Exiting check_delete_status with return status '||x_return_status, 5 );
   -- end bug 5527407

   WHEN OTHERS THEN
       WriteToLog('## exiting CHECK_DELETE_STATUS with error ## ', 5 );
       WriteToLog('error in CHECK_DELETE_STATUS'||sqlerrm, 5);
       RAISE;
END CHECK_DELETE_STATUS;



PROCEDURE check_attribute_control(
                                   p_org_id               IN  NUMBER,
                                   x_master_orgn_id       OUT NOCOPY NUMBER,
                                   x_attr_control         OUT NOCOPY NUMBER,
                                   x_return_status        OUT NOCOPY VARCHAR2
                                  )
IS

BEGIN

   x_return_status := FND_API.G_FALSE;	-- default

   -- Get the attribute control for item status code
   -- 1 = Master Level
   -- 2 = Organization Level

   select control_level
   into   x_attr_control
   from   mtl_item_attributes
   where  attribute_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

   if x_attr_control = 1 then
      --
      -- check if the orgn where you are running the conc program is the master org. If not, error out.
      -- we don't want user to run this from child org if attribute control is set to master level.
      --

      declare
        l_master_orgn_id  number;
      begin
   	select master_organization_id
	into   l_master_orgn_id
   	from   mtl_parameters
   	where  organization_id = p_org_id;

	x_master_orgn_id := l_master_orgn_id;	-- assigning to OUT parameter.

	if l_master_orgn_id <> p_org_id then
	    return;
	end if;
      end;

 -- new
 -- if attrib control = 2 , then also we need to get back the master org.

   elsif x_attr_control = 2 then

      declare
        l_master_orgn_id  number;
      begin
   	select master_organization_id
	into   l_master_orgn_id
   	from   mtl_parameters
   	where  organization_id = p_org_id;

	x_master_orgn_id := l_master_orgn_id;	-- assigning to OUT parameter.
      end;

   end if;

   x_return_status := FND_API.G_TRUE;

END check_attribute_control;



/***************************************************************************
procedure 	REGISTER_RESULT
 this procedure put the items selected for deactivation in a pl/sql table
 and also put the items which will not be deactivated in a pl/sql table
 with a message saying why the item is not deactivated.
***************************************************************************/

PROCEDURE REGISTER_RESULT(   p_table          IN OUT  NOCOPY t_cfg_item_details,
                             p_cfg_item_id    IN       NUMBER,
                             p_cfg_item_name  IN     VARCHAR2,
                             p_cfg_orgn_id    IN     NUMBER,
                             p_msg            VARCHAR2 DEFAULT  NULL)
IS

l_temp_index BINARY_INTEGER; --bugfix2308063
l_org_code varchar2(3); --5291392

BEGIN
   WriteToLog('Entering register_result for item_id '|| p_cfg_item_id, 5);

   --5291392
   Get_organization_code( p_organization_id=>p_cfg_orgn_id,
                          p_organization_code=>l_org_code
			);

   IF (p_table.count = 0) THEN --bugfix2308063

       p_table(1).cfg_item_id     := p_cfg_item_id;      --bugfix2308063
       p_table(1).cfg_item_name   := p_cfg_item_name;    --bugfix2308063
       p_table(1).cfg_orgn_id     := p_cfg_orgn_id;
       p_table(1).cfg_orgn_code   := l_org_code;        --5291392
       p_table(1).msg             := p_msg;               --bugfix2308063

       WriteToLog('Entered in register_result for index 1: '|| p_table(1).cfg_item_id, 5);

   ELSE
       l_temp_index := p_table.LAST+1;
       p_table(l_temp_index).cfg_item_id     := p_cfg_item_id;
       p_table(l_temp_index).cfg_item_name   := p_cfg_item_name;
       p_table(l_temp_index).cfg_orgn_id     := p_cfg_orgn_id;
       p_table(l_temp_index).cfg_orgn_code   := l_org_code;    --5291392
       p_table(l_temp_index).msg             := p_msg;

       WriteToLog('Entered in register_result item_id '||p_table(l_temp_index).cfg_item_id||
		'- at index  '||l_temp_index, 5);

   END IF;

EXCEPTION
    WHEN OTHERS THEN
        WriteToLog('## exit REGISTER_RESULT with error ##' );
        WriteToLog('ERROR in REGISTER_RESULT'||sqlerrm);
        RAISE;
END REGISTER_RESULT;


/******************************************************************************
procedure :	CHECK_COMMON_ROUTING
 This procedure checks if routing is present for the passed config item.
 If routing is present it checks if the routing has been commoned to some other item.
 If the routing has been commoned to some other item, checks to see if the
 that item has been deactivated.If the item has not been deactivated, it means
 the commoned routing is active.
 If the commoned routing is active procedure returns FND_API.G_TRUE
 else it returns FND_API.G_FALSE

arguments
 p_inventory_item_id  : config_item_id
 p_org_id             : given org_id
 p_delete_status_code : bom_parameters.bom_delete_status_code for given org_id
******************************************************************************/

PROCEDURE CHECK_COMMON_ROUTING(
                               p_inventory_item_id     IN NUMBER,
                               p_org_id                IN NUMBER,
                               p_delete_status_code    IN VARCHAR2,
                               x_return_status         OUT NOCOPY VARCHAR2
                               )
IS

  l_rout_seq_id NUMBER;
  l_com_rout_seq_id NUMBER;
  l_com_asmbly_itm_id NUMBER;
  l_return_status   VARCHAR2(1);

  CURSOR common_rout IS
  SELECT routing_sequence_id,assembly_item_id
  FROM   bom_operational_routings
  WHERE  common_routing_sequence_id = l_rout_seq_id
  and    routing_sequence_id <> l_rout_seq_id;

BEGIN
      WriteToLog('Entering check_common_routing..', 5);
      x_return_status := FND_API.G_FALSE;

      BEGIN
          SELECT routing_sequence_id INTO l_rout_seq_id
          FROM   bom_operational_routings
          WHERE  assembly_item_id = p_inventory_item_id
          AND    organization_id = p_org_id
          AND    alternate_routing_designator is null; --fix for bug2063209
      EXCEPTION
          WHEN no_data_found THEN
              WriteToLog('No routing hence no common routing for =>' ||p_inventory_item_id, 3);
              WriteToLog('Exiting check_common_routing.', 5 );
          RETURN;
      END;

      OPEN  common_rout;
      LOOP
            WriteToLog('In common_rout loop', 5 );
            FETCH common_rout INTO l_com_rout_seq_id,l_com_asmbly_itm_id;

            EXIT WHEN common_rout%NOTFOUND;

            WriteToLog('Assembly Item Id '||l_com_asmbly_itm_id||' commons the routing from item id '||p_inventory_item_id, 3);
            WriteToLog('call to check_delete_status from check_common_routing', 5 );

            CHECK_DELETE_STATUS( l_com_asmbly_itm_id,
                                 p_org_id,
                                 p_delete_status_code,
                                 l_return_status);

            WriteToLog('EXIT call to check_delete_status from check_common_routing', 5 );
            -- l_return_status := l_return_status;

            IF l_return_status = FND_API.G_FALSE THEN
              WriteToLog('CHECK_COMMON_ROUTING: Assembly Item Id '||l_com_asmbly_itm_id ||' is still in active status.',3);
              x_return_status := FND_API.G_TRUE;
              CLOSE  common_rout;
              WriteToLog('Exiting check_common_routing', 5 );
              RETURN;
            END IF;

      END LOOP;

      CLOSE  common_rout;

      WriteToLog('common routing not present or all items commoning it is not active.', 5);
      WriteToLog('Exiting check_common_routing.', 5 );

EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_COMMON_ROUTING with error##' );
         WriteToLog('exception in common routing code'||sqlerrm);
         RAISE;
END CHECK_COMMON_ROUTING;

/*****************************************************************************************
procedure 	CHECK_COMMON_BOM
  This procedure checks if BOM is present for the passed config item.
  If BOM is present it checks if the bom has been commoned to some other
  item.
  If the BOM has been commoned to some other item, checks to see if the
  that item has been deactivated.If the item has not been deactivated, it means
  the commoned BOM is active.

  If the commoned BOM is active procedure returns FND_API.G_TRUE
  else it returns FND_API.G_FALSE

arguments
  p_inventory_item_id  : config_item_id
  p_org_id             : given org_id
  p_delete_status_code : bom_parameters.bom_delete_status_code for given org_id
****************************************************************************************/
PROCEDURE CHECK_COMMON_BOM(
                           p_inventory_item_id     IN NUMBER,
                           p_org_id                IN NUMBER,
                           p_delete_status_code    IN VARCHAR2,
                           x_return_status         OUT NOCOPY VARCHAR2
                          )
IS
  l_del_status                   VARCHAR2(10);
  l_com_org_id                   NUMBER; --org_id of item whose bill is commoned
  l_bill_sequence_id             NUMBER;
  l_com_bill_seq_id              NUMBER;
  l_com_asmbly_itm_id            NUMBER;
  l_return_status                VARCHAR2(1);

  CURSOR   common_bom IS
  SELECT   bill_sequence_id,assembly_item_id,organization_id
  FROM     bom_bill_of_materials
  WHERE    common_bill_sequence_id = l_bill_sequence_id
  AND      bill_sequence_id <> l_bill_sequence_id;

BEGIN
    WriteToLog('Entering check_common_bom ', 5 );
    x_return_status := FND_API.G_FALSE;

    BEGIN
        SELECT   bill_sequence_id INTO l_bill_sequence_id
        FROM     bom_bill_of_materials
        WHERE    assembly_item_id   =  p_inventory_item_id
        AND      organization_id    =  p_org_id
        AND      alternate_bom_designator IS NULL;
    EXCEPTION
        WHEN no_data_found THEN
            WriteToLog('No BOM hence no common BOM for =>' ||p_inventory_item_id, 3);
            WriteToLog('Exiting check_common_bom.', 5 );
        RETURN;
    END;

    OPEN  common_bom;
    LOOP

      FETCH common_bom INTO l_com_bill_seq_id, l_com_asmbly_itm_id, l_com_org_id;
      EXIT WHEN common_bom%NOTFOUND;

      WriteToLog('in loop of check_common_bom', 5 );

      IF l_com_org_id <> p_org_id THEN
          BEGIN
            SELECT bom_delete_status_code INTO l_del_status
            FROM   bom_parameters
            WHERE  organization_id = l_com_org_id;
          EXCEPTION
            WHEN no_data_found THEN
             WriteToLog('Org where BOM is commoned doesnot have bom_del_status', 3);
             x_return_status := FND_API.G_TRUE;
             CLOSE  common_bom;
             WriteToLog('Exiting check_common_bom.', 5 );
             RETURN;
          END;
      END IF;

      IF  l_com_org_id <> p_org_id THEN
         WriteToLog('call to check_delete_status from check_common_bom', 5 );
         CHECK_DELETE_STATUS(
                             l_com_asmbly_itm_id,
                             l_com_org_id,
                             l_del_status,
                             l_return_status );
         WriteToLog('finished call to check_delete_status from check_common_bom', 5 );
      ELSE
         WriteToLog('call to check_delete_status from check_common_bom', 5 );
         CHECK_DELETE_STATUS(  l_com_asmbly_itm_id,
                               p_org_id  ,
                               p_delete_status_code,
                               l_return_status);
         WriteToLog('finished call to check_delete_status from check_common_bom', 5 );
      END IF;

      -- l_return_status := l_return_status;
      IF l_return_status = FND_API.G_FALSE THEN

          WriteToLog('CHECK_COMMON_BOM: Assembly Item Id '||l_com_asmbly_itm_id ||' is still in active status.', 3);
          x_return_status := FND_API.G_TRUE;
          CLOSE  common_bom;
          WriteToLog('Exiting check_common_bom.', 5 );
          RETURN;

      END IF;

      END LOOP;
      CLOSE  common_bom;

      WriteToLog(' common bom not present', 5);
      WriteToLog('Exiting check_common_bom.', 5 );

EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_COMMON_BOM with error##' );
         WriteToLog('exception in common bom code'||sqlerrm);
         RAISE;
END CHECK_COMMON_BOM;


/***********************************************************************************
bugfix 2214674

procedure 	CHECK_ONHAND
 This procedure checks if there is any onhand qty available
 If onhand qty is found it returns FND_API.G_TRUE

arguments
 p_inventory_item_id :config item id
 p_org_id            : given org id
 x_return_status     : FND_API.G_TRUE

**********************************************************************************/
PROCEDURE CHECK_ONHAND(
                             p_inventory_item_id     IN     NUMBER,
                             p_org_id                IN     NUMBER,
                             x_return_status         OUT NOCOPY   VARCHAR2
                      )
IS
      xdummy   number;
BEGIN
      WriteToLog ('In check_onhand..',5);
      x_return_status := FND_API.G_FALSE;

      select transaction_quantity into xdummy
      from  mtl_onhand_quantities
      where inventory_item_id = p_inventory_item_id
      and   organization_id = p_org_id
      and   transaction_quantity > 0;

      raise TOO_MANY_ROWS;	-- single row treated as too many rows

EXCEPTION
      when no_data_found then
	   null; 	-- no onhand. ok to proceed.

      when too_many_rows then
	   x_return_status := FND_API.G_TRUE;
	   WriteToLog ('Onhand Quantity of '||xdummy ||' exists for this item in this organization.', 3);

      when others then
	   x_return_status := FND_API.G_TRUE;
	   WriteToLog ('Others exception in check_onhand :'||sqlerrm);

END;



/***********************************************************************************
procedure 	CHECK_OPEN_SUPPLY
 This procedure checks if there is any open supply existing for given config item from
 a) reservations
 b) discrete jobs
 c) flow jobs
 d) repetitive jobs
 If open supply is found it returns FND_API.G_TRUE

arguments
 p_inventory_item_id :config item id
 p_org_id            : given org id
 x_return_status     : FND_API.G_TRUE

**********************************************************************************/
PROCEDURE CHECK_OPEN_SUPPLY(
                             p_inventory_item_id     IN     NUMBER,
                             p_org_id                IN     NUMBER,
                             x_return_status         OUT NOCOPY   VARCHAR2
                           )
IS
 l_reserved_quantity       NUMBER;
 l_flag                    VARCHAR2(1) := 'N';    --for checking if reservation exists
 l_status_type             NUMBER;
 l_status                  NUMBER;

--cursor to check if any reservations exist
 CURSOR  c_reserv IS
 SELECT  reservation_quantity
 FROM    mtl_reservations
 WHERE   inventory_item_id = p_inventory_item_id
 AND     organization_id = p_org_id
 UNION
 SELECT  reservation_quantity
 FROM    mtl_reservations_interface
 WHERE   inventory_item_id = p_inventory_item_id
 AND     organization_id = p_org_id;

--to check if any open discrete jobs exist
 CURSOR  c_dis_job IS
 SELECT  status_type
 FROM    wip_discrete_jobs
 WHERE   primary_item_id = p_inventory_item_id
 AND     organization_id = p_org_id;

-- to check if any open flow schedules exist
 CURSOR   c_flow_schedules IS
 SELECT   status
 FROM     wip_flow_schedules
 WHERE    primary_item_id = p_inventory_item_id
 AND      organization_id = p_org_id;

-- to check if the config item is manufactured repetitively
-- we don't deactivate repetitive items
 CURSOR   c_repetitive_items IS
 SELECT   primary_item_id
 FROM     wip_repetitive_items
 WHERE    primary_item_id = p_inventory_item_id
 AND      organization_id = p_org_id;

BEGIN
    WriteToLog('Entering check_open_supply..', 5 );

    x_return_status := FND_API.G_FALSE;
    --if not able to satisfy any of below criteria then open supply does not exist

    -- to check for open reservations
    OPEN  c_reserv;
    WriteToLog('in reservation loop', 5);
    LOOP
      FETCH c_reserv INTO l_reserved_quantity;

      EXIT WHEN  c_reserv%NOTFOUND;
      IF l_reserved_quantity > 0 THEN
            x_return_status := FND_API.G_TRUE;
            CLOSE c_reserv;
            WriteToLog('Exiting check_open_supply : reservation present.' , 3);
            RETURN;
      END IF;
    END LOOP;

    CLOSE c_reserv;


 --to check for open work orders in wip_discrete_jobs

   OPEN c_dis_job;

   LOOP
     FETCH c_dis_job INTO l_status_type;
     WriteToLog('in discrete job loop', 5);

     EXIT WHEN c_dis_job%NOTFOUND;
     IF l_status_type <> 12 THEN --checking if work order is open (12 implies closed)
            x_return_status := FND_API.G_TRUE;
            CLOSE c_dis_job;
            WriteToLog('Exiting check_open_supply :discrete job present. ' , 3);
            RETURN;
     END IF;
   END LOOP;

   CLOSE c_dis_job;

-- to check for open flow schedules
   OPEN c_flow_schedules;

   LOOP
     FETCH c_flow_schedules INTO l_status;
     EXIT WHEN c_flow_schedules%NOTFOUND;

     IF  l_status <> 2 THEN --checking if flow is open (2 implies closed)
         x_return_status := FND_API.G_TRUE;
         CLOSE c_flow_schedules;
         WriteToLog('Exiting check_open_supply :flow schedule present. ', 3 );
         RETURN;
     END IF;
   END LOOP;

   CLOSE c_flow_schedules;


-- to check if repetitive items exist
   OPEN c_repetitive_items;

     IF c_repetitive_items%FOUND THEN
         x_return_status := FND_API.G_TRUE;
         CLOSE c_repetitive_items;
         WriteToLog('Exiting check_open_supply :repetitive schedule present.' , 3);
         RETURN;
     END IF;

   CLOSE c_repetitive_items;

   WriteToLog('Exiting check_open_supply.', 5 );
EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_OPEN_SUPPLY with error ##' );
         WriteToLog('exception in check_open_supply'||sqlerrm);
         RAISE;

END CHECK_OPEN_SUPPLY;


/****************************************************************************************
procedure 	CHECK_OPEN_DEMAND
 This checks if there is any open demand (open sales order) for a config item.
 RETURNS FND_API.G_TRUE if there is any open supply present

arguments
 p_inventory_item_id : config item id
 p_org_id            : given org id
*****************************************************************************************/
PROCEDURE CHECK_OPEN_DEMAND(
                   p_inventory_item_id     IN NUMBER,
                   p_org_id                IN NUMBER,
                   x_return_status        OUT NOCOPY VARCHAR2
                  )
IS

l_open_flag VARCHAR2(1);

--cursor to check in open demand present in ML/MO scenario

-- rkaza. bug 3927712. union to bcmo is incorrect and redundant. removing the
-- union. Check if the line you catch in bcso has a config item in its order.
-- In type 1 configs, the previous code was identifying open demand even after
-- delinking the config item from the order, as bcso still contains the record.
-- Type 2/3 configs are always deactivated with the previous code, since
-- rcv_org_id is not populated. So removing rcv_org_id not null in subquery.

--Begin Performance fix 7014363
/*CURSOR    c_bcso IS
SELECT    oel1.open_flag
FROM      oe_order_lines_all oel1, oe_order_lines_all oel2
WHERE     oel1.line_id    IN
             (       SELECT   bcso.line_id
                     FROM     bom_cto_src_orgs bcso
                     WHERE    bcso.config_item_id = p_inventory_item_id
                     AND      bcso.organization_id = p_org_id)
AND oel1.OPEN_FLAG <> 'N'
AND oel1.ato_line_id = oel2.ato_line_id
AND oel2.item_type_code = 'CONFIG';*/

CURSOR    c_bcso IS
  SELECT oel1.open_flag
  FROM oe_order_lines_all oel1,
       oe_order_lines_all oel2
  WHERE oel1.line_id IN
    (  SELECT line_id line_id
       FROM bom_cto_src_orgs_b bcso
       WHERE group_reference_id IS NULL
       AND bcso.config_item_id = p_inventory_item_id
       AND bcso.organization_id = p_org_id
       UNION ALL
       SELECT bcso.line_id line_id
       FROM bom_cto_src_orgs_b bcso,
            bom_cto_model_orgs bcmo
       WHERE bcso.group_reference_id IS NOT NULL
       AND bcso.group_reference_id = bcmo.group_reference_id
       AND bcso.config_item_id = p_inventory_item_id
       AND bcso.organization_id = p_org_id
    )
  AND oel1.open_flag <> 'N'
  AND oel1.ato_line_id = oel2.ato_line_id
  AND oel2.item_type_code = 'CONFIG';
  --End Performance fix 7014363

--this checks for demand of config item when order as an ATO item
CURSOR   c_ato_item IS
SELECT   open_flag
FROM     oe_order_lines_all
WHERE    inventory_item_id = p_inventory_item_id
AND      ship_from_org_id = p_org_id
AND      open_flag <> 'N'
UNION
SELECT   closed_flag
FROM     oe_lines_iface_all
WHERE    inventory_item_id = p_inventory_item_id           --deamnd from or_interface tables (only std items can
AND      ship_from_org_id = p_org_id                       --be ordered from third party tools ie exist in
AND      closed_flag <> 'N';                               --interface table


BEGIN
   WriteToLog('Entering check_open_demand..', 5 );
   x_return_status := FND_API.G_FALSE;

   --check if line is open for config item in bom_cto_src_orgs
   OPEN c_bcso;

   FETCH c_bcso INTO l_open_flag;
   IF c_bcso%FOUND THEN
       x_return_status := FND_API.G_TRUE;
       CLOSE c_bcso ;
       WriteToLog('Exiting check_open_demand' , 5 );
       RETURN;
   END IF;

  CLOSE c_bcso;

-- check  if lines is open for config item (ordered as ato item) in interface table and OE table
   OPEN c_ato_item;

   FETCH c_ato_item INTO l_open_flag;
   IF c_ato_item%FOUND THEN
       x_return_status := FND_API.G_TRUE;
       CLOSE c_ato_item;
       WriteToLog('Exiting check_open_demand.' ,5);
       RETURN;
   END IF;

   CLOSE c_ato_item;

   WriteToLog('Exiting check_open_demand. ' ,5);

EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_OPEN_DEMAND with error ##' );
         WriteToLog('exception in check_open_demand'||sqlerrm);
         RAISE;

END CHECK_OPEN_DEMAND;

/**********************************************************************************************
procedure 	CHECK_MATERIAL_TRANSACTION
 This procedure checks if any material transactions exits within p_num_of_days of item being shipped

arguments:
 p_inventory_item_id   : config item id
 p_org_id              : given org id
 p_num_of_days         : given number of days
*********************************************************************************************/
PROCEDURE CHECK_MATERIAL_TRANSACTION(
                                       p_inventory_item_id     IN    NUMBER,
                                       p_org_id                IN    NUMBER,
                                       p_num_of_days           IN    NUMBER,
                                       x_return_status         OUT NOCOPY    VARCHAR2
                                     )
IS
 l_transaction_date DATE;

 CURSOR   c_material_transaction IS
 SELECT   transaction_date
 FROM     mtl_material_transactions
 WHERE    inventory_item_id = p_inventory_item_id
 AND      organization_id = p_org_id
 AND      transaction_date > (SYSDATE-p_num_of_days);

BEGIN
    OPEN   c_material_transaction;
    WriteToLog('Entering check_material_transaction.. ', 5 );

    FETCH  c_material_transaction INTO l_transaction_date;
    IF c_material_transaction%FOUND THEN
        x_return_status := FND_API.G_TRUE;
        CLOSE c_material_transaction;
        WriteToLog('Exiting check_material_transaction.', 5 );
        RETURN;
    END IF;

   CLOSE c_material_transaction;

   x_return_status := FND_API.G_FALSE;
   WriteToLog('Exiting check_material_transaction.', 5 );

EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_MATERIAL_TRANSACTION with error ##' );
         WriteToLog('Error in CHECK_MATERIAL_TRANSACTION'||sqlerrm);
         RAISE;
END CHECK_MATERIAL_TRANSACTION;

/*****************************************************************************************
Bugfix 7011607

procedure 	CHECK_ACTIVE_PARENT_CONFIG
  This procedure checks if the given config item has any parent config items which
  has not been deactivated.
 RETURNS FND_API.G_TRUE if any active parent config is present

arguments
 p_inventory_item_id : config item id
 p_org_id            : given org id

*******************************************************************************************/

PROCEDURE CHECK_ACTIVE_PARENT_CONFIG(
                                       p_inventory_item_id     IN    NUMBER,
                                       p_org_id                IN   NUMBER,
                                       x_return_status         OUT  NOCOPY VARCHAR2
                                    )
IS

l_del_status        bom_parameters.bom_delete_status_code%type;
l_return_status     VARCHAR2(1);

cursor parent_ato is
    select assembly_item_id
    from   bom_bill_of_materials bom,
           bom_inventory_components bic,
           mtl_system_items msi
    where  bom.common_bill_sequence_id = bic.bill_sequence_id
    and    bic.component_item_id = p_inventory_item_id
    and    bom.organization_id = p_org_id
    and    bom.assembly_item_id = msi.inventory_item_id
    and    bom.organization_id = msi.organization_id
    and    msi.bom_item_type = 4                -- standard bom only
    and    msi.replenish_to_order_flag = 'Y';   -- ato items

BEGIN
    WriteToLog('Entering CHECK_ACTIVE_PARENT_CONFIG for item '||p_inventory_item_id ||' in org '||p_org_id, 5 );

    x_return_status := FND_API.G_FALSE;

    SELECT bom_delete_status_code
    INTO   l_del_status
    FROM   bom_parameters
    WHERE  organization_id = p_org_id;

    WriteToLog('BOM delete status code: '||l_del_status, 5 );

    for assembly_rec in parent_ato
    loop
        WriteToLog('Checking if: '||assembly_rec.assembly_item_id||' is inactive', 5 );

        CHECK_DELETE_STATUS(
                             assembly_rec.assembly_item_id,
                             p_org_id,
                             l_del_status,
                             l_return_status );

        if l_return_status = FND_API.G_FALSE then
           WriteToLog('Parent: '||assembly_rec.assembly_item_id||' is active. Cannot deactivate child '||p_inventory_item_id, 5 );
           x_return_status := FND_API.G_TRUE;
           exit;
        end if;

    end loop;

EXCEPTION
      WHEN others THEN
         WriteToLog('## exiting CHECK_ACTIVE_PARENT_CONFIG with error ##' );
         WriteToLog('Error in CHECK_ACTIVE_PARENT_CONFIG'||sqlerrm);
         RAISE;
END CHECK_ACTIVE_PARENT_CONFIG;

/**************************************************************************************************
procedure 	GET_BOM_DELETE_STATUS_CODE
 This procedure takes in organization id and finds out the parameter bom_delete_status_code.
 bom_delete_status_code is the status  which needs to be assigned to the item when item becomes
 inactive

Logic:
  if bom_delete_status_code is not set for oragnization, return false
  if bom_delete_status_code is set, return success and bom_delete_status_code

Arguments:
            p_org_id                IN    NUMBER,
            p_delete_status_code    OUT VARCHAR2,
            x_return_status         OUT VARCHAR2
 bugfix 2368862
*************************************************************************************************/
PROCEDURE GET_BOM_DELETE_STATUS_CODE
          (
            p_org_id                IN    NUMBER,
            p_delete_status_code    OUT NOCOPY VARCHAR2,
            x_return_status         OUT NOCOPY VARCHAR2

           )
IS

l_del_status bom_parameters.bom_delete_status_code%type;

BEGIN
      x_return_status := FND_API.G_FALSE;--default return value ,bom_delete_status_code is not set

      WriteToLog('Entering get_bom_delete_status_code for org '||p_org_id, 5);

      BEGIN
         SELECT bom_delete_status_code
         INTO   l_del_status
         FROM   bom_parameters
         WHERE  organization_id = p_org_id;
      EXCEPTION
         WHEN no_data_found THEN
	    WriteToLog('BOM Parameters is not set for organization '||p_org_id);
            RETURN;
      END;


     --
     -- if there is a row present but no bom_delete_status for given org
     --

     IF l_del_status IS NULL THEN
         WriteToLog('Inactive Status Code is not populated in bom_parameters');
         RETURN;
     END IF;

     p_delete_status_code := l_del_status;
     x_return_status := FND_API.G_TRUE;

     WriteToLog('Exiting get_bom_delete_status_code.', 5);

EXCEPTION
 WHEN OTHERS THEN
        WriteToLog('## exiting GET_BOM_DELETE_STATUS_CODE with error ##' );
        WriteToLog('ERROR in GET_BOM_DELETE_STATUS_CODE'||sqlerrm);
        RAISE;

END GET_BOM_DELETE_STATUS_CODE;



PROCEDURE WriteToLog (p_message in varchar2 default null,
		      p_level   in number default 0) is
begin
    if gDebugLevel >= p_level then
	oe_debug_pub.add (p_message);
    end if;
end WriteToLog;

--5291392 new api Get_organization_code added
Procedure Get_organization_code( p_organization_id IN Number,
                                 p_organization_code out NOCOPY Varchar2
				) is
begin

   IF tab_org_details.count<>0 THEN
     IF ( tab_org_details.exists(p_organization_id)) THEN
        p_organization_code :=  tab_org_details(p_organization_id).org_code;
        return;
     END IF;
   END IF;

     select organization_code
     INTO p_organization_code
     from mtl_parameters
     where organization_id = p_organization_id;

     tab_org_details(p_organization_id).org_id := p_organization_id;
     tab_org_details(p_organization_id).org_code := p_organization_code;


end Get_organization_code;


END CTO_DEACTIVATE_CONFIG_PK;

/
