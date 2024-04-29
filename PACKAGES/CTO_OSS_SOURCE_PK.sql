--------------------------------------------------------
--  DDL for Package CTO_OSS_SOURCE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_OSS_SOURCE_PK" AUTHID CURRENT_USER AS
/*$Header: CTOOSSPS.pls 115.8 2004/03/03 01:01:25 rekannan noship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOOSSPS.pls                                                  |
| DESCRIPTION:                                                                |
|               Contains all pkgs procedure definition for                    |
|               Option specific sourcing module. This file will also          |
|               contains all the ncessary pkg. variable declaration and       |
|               pl/sql records definition.				      |
| HISTORY     :                                                               |
| 25-Aug-2003 : Renga  Kannan  Initial version                                |
=============================================================================*/


/* General package name constant declaration */

g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_OSS_SOURCE_PK';



/* This is the record type used to send the list of orgs where bom should be created,
   during Auto create config item process
*/

TYPE bom_list_tab_rec is RECORD  (
                                    Line_id              Number,
                                    Inventory_item_id   Number,
                                    Org_id               Number);
TYPE Orgs_list is Table of Number;

TYPE bom_org_list_tab is TABLE Of bom_list_tab_rec index by binary_integer;


/* The following procedure will be called during Auto create config
   process. This will have one input parameter, which is top ato line id.
   This will return the list of orgs where bom should be created for each
   OSS config as record structrue
 */

Procedure Process_Oss_configurations(
                 p_ato_line_id      IN                 Number,
                 p_mode             IN                 Varchar2 DEFAULT 'ACC',
                 x_return_status    OUT      NOCOPY    Varchar2,
                 x_msg_count        OUT      NOCOPY    Number,
                 x_msg_data         OUT      NOCOPY    Varchar);

TYPE number_arr IS TABLE OF Number index by binary_integer;
TYPE Char30_arr IS TABLE of Varchar2(30) index by binary_integer;
TYPE Char1_arr  IS TABLE of Varchar2(1);

/*
TYPE OSS_ORGS_LIST_REC_TYPE is RECORD (
                 Line_id             Number_arr := number_arr(),
                 Inventory_item_id   Number_arr := Number_arr(),
                 Org_id              Number_arr := Number_arr(),
                 Vendor_id           Number_arr := Number_arr(),
                 Vendor_site         Char30_arr := Char30_arr());
*/
TYPE OSS_ORGS_LIST_REC_TYPE is RECORD (
                 Line_id             Number_arr ,
		 ato_line_id         Number_arr,
                 Inventory_item_id   Number_arr ,
                 Org_id              Number_arr ,
                 Vendor_id           Number_arr ,
                 Vendor_site         Char30_arr ,
		 Make_flag           Char1_arr);

/* This is the procedure that is called during ATP. Match api will
   call this procedure.
 */
Procedure  Get_OSS_Orgs_list(
                x_oss_orgs_list OUT  NOCOPY  CTO_OSS_SOURCE_PK.oss_orgs_list_rec_type,
                x_return_status OUT  NOCOPY  Varchar2,
                x_msg_data      OUT  NOCOPY  Varchar2,
                x_msg_count     OUT  NOCOPY  Number);


Procedure update_oss_in_bcol(
                              p_ato_line_id   IN         Number,
			      x_oss_exists    OUT NOCOPY Varchar2,
			      x_return_status OUT NOCOPY Varchar2,
			      x_msg_data      OUT NOCOPY Varchar2,
			      x_msg_count     OUT NOCOPY Number) ;



/* This procedure will be called during populate_src_orgs. This API will get the
   sourcing orgs for OSS models
*/

PROCEDURE query_oss_sourcing_org(
			     p_line_id              IN  NUMBER,
			     p_inventory_item_id    IN  NUMBER,
			     p_organization_id      IN  NUMBER,
			     x_sourcing_rule_exists OUT NOCOPY varchar2,
			     x_source_type          OUT NOCOPY NUMBER,
			     x_t_sourcing_info      OUT NOCOPY CTO_MSUTIL_PUB.SOURCING_INFO,
			     x_exp_error_code       OUT NOCOPY NUMBER,
			     x_return_status        OUT NOCOPY varchar2,
			     x_msg_data	            OUT NOCOPY Varchar2,
			     x_msg_count            OUT NOCOPY Number);

Procedure Create_oss_sourcing_rules(
                                      p_ato_line_id   IN  Number,
                                      p_mode          IN  Varchar2 DEFAULT 'ACC',
                                      p_changed_src   IN  Varchar2 DEFAULT null,
                                      x_return_status OUT NOCOPY Varchar2,
   		                      x_msg_count     OUT NOCOPY Number,
			              x_msg_data      OUT NOCOPY Varchar2
				     );

Procedure get_oss_bom_orgs(
                           p_line_id        IN  Number,
			   x_orgs_list      OUT NOCOPY CTO_OSS_SOURCE_PK.orgs_list,
			   x_return_status  OUT NOCOPY Varchar2,
			   x_msg_data       OUT NOCOPY Varchar2,
			   x_msg_count      OUT NOCOPY Number);


END CTO_OSS_SOURCE_PK;

 

/
