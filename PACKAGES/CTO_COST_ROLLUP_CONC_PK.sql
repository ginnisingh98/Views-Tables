--------------------------------------------------------
--  DDL for Package CTO_COST_ROLLUP_CONC_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_COST_ROLLUP_CONC_PK" AUTHID CURRENT_USER as
/* $Header: CTOCRCNS.pls 115.0 2003/11/12 04:11:40 ksarkar noship $*/


/*
 *=========================================================================*
 |                                                                         |
 | Copyright (c) 2001, Oracle Corporation, Redwood Shores, California, USA |
 |                           All rights reserved.                          |
 |                                                                         |
 *=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |            CTO Cost rollup   package specification                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   PL/SQL package body containing the  routine  for cost rollup          |
 |   of configuration items.                          			   |
 |   For different combination of parameters passed , code gets the parent |
 |   config item and its child and insert them into cst_sc_lists	   |
 |									   |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   Input :  	Config Item 		: Select this config item          |
 |		Base Model Item 	: All configs for this base model  |
 |		Item Created Days Ago   : All configs created in last "n"  |
 |					  days.				   |
 |		Organization		: Calculate cost for all configs in|
 |					  this org.			   |
 | HISTORY                                                                 |
 |   Date      Author   Comments                                           |
 | --------- -------- ---------------------------------------------------- |
 |  10/27/2003  KSARKAR  creation of package   CTO_COST_ROLLUP_CONC_PK     |
 |                                                                         |
 *=========================================================================*/

	-- global variable
	gDebugLevel     NUMBER :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));

       --
       -- PL/SQL tables for holding config items
       --
        TYPE r_cfg_item IS RECORD(
     	cfg_item_id    		mtl_system_items.inventory_item_id%type,
     	cfg_org_id    		number
     	);

	TYPE r_cfg_item_cum IS RECORD(
     	cfg_item_id    		mtl_system_items.inventory_item_id%type
     	);

        TYPE t_cfg_item     IS TABLE OF r_cfg_item     INDEX BY BINARY_INTEGER;
	TYPE t_cfg_item_cum IS TABLE OF r_cfg_item_cum INDEX BY BINARY_INTEGER;

        cfg_item_arr     		t_cfg_item;
	cfg_item_arr_cum     		t_cfg_item_cum;



/**********************************************************************************
Procedure spec:	CTO_COST_ROLLUP_CONC_PK :
   This a stored PL/SQL concurrent program that rolls up config item cost based on
   different criteria.

INPUT arguments:
 p_config_id 	: Configuration Item.
 p_model_id  	: Configs with this base Model Item.
 p_num_of_days	: Configs created in the last "n" days.
 p_org_id	: Organization Id
 p_upgrade	: If this is for upgrade
 p_calc_costrollup : If costrollup is needed with upgrade
***********************************************************************************/
PROCEDURE cto_cost_rollup
                         (
                                errbuf 	 		OUT     NOCOPY VARCHAR2,
                         	retcode 		OUT     NOCOPY VARCHAR2,
                         	p_org_id        	IN      NUMBER,
				p_dummy			IN	NUMBER,
				p_config_item_id     	IN      NUMBER,
				p_dummy2		IN	NUMBER,
				p_model_id      	IN      NUMBER,
				p_num_of_days   	IN      NUMBER,
				p_upgrade		IN	VARCHAR2,
				p_calc_costrollup	IN	VARCHAR2

                        );
END CTO_COST_ROLLUP_CONC_PK;


 

/
