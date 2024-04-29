--------------------------------------------------------
--  DDL for Package CTO_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_FLOW_SCHEDULE" AUTHID CURRENT_USER as
/* $Header: CTOFLSCS.pls 120.1 2005/06/06 10:04:02 appldev  $ */
/*----------------------------------------------------------------------------+
|  Copyright (c) 1998 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+-----------------------------------------------------------------------------+
|
| FILE NAME   :
| DESCRIPTION :
|               This file creates a packaged Procedures which create
|               flow schedules  for ATO items/ configured items.
|               To remain a 'noship' file till further decision
|
| HISTORY     : June 30, 1999    Initial Version     Angela Makalintal
|               June 1 , 2005    Added Nocopy Hint   Renga  Kannan
|
|
*============================================================================*/

PROCEDURE cto_fs(p_config_line_id in varchar2,
                 x_return_status         out Nocopy varchar2,
                 x_msg_name              out Nocopy varchar2,
                 x_msg_txt               out Nocopy varchar2
                 );

PROCEDURE cto_create_fs (p_config_line_id        in         varchar2,
			 x_wip_entity_id         out Nocopy number,
                         x_return_status         out Nocopy varchar2,
                         x_msg_count             out Nocopy number,
                         x_msg_data              out Nocopy varchar2,
                         x_msg_name              out Nocopy varchar2
                         );

PROCEDURE cto_schedule_fs (p_config_line_id IN         varchar2,
        		   p_wip_entity_id  IN         NUMBER,
                           x_return_status  OUT Nocopy VARCHAR2,
                           x_msg_count      OUT Nocopy NUMBER,
                           x_msg_data       OUT Nocopy VARCHAR2,
                           x_msg_name       out Nocopy varchar2
                           );

end CTO_FLOW_SCHEDULE;

 

/
