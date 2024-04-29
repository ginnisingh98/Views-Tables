--------------------------------------------------------
--  DDL for Package WSH_DATA_PROTECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DATA_PROTECTION" AUTHID CURRENT_USER as
/* $Header: WSHUTDPS.pls 115.7 2004/04/30 16:29:55 wrudge ship $ */

--
--  Procedure:	Get_Disabled_List
--
--  Parameters:	p_entity_type - type of entity: DLVB, DLVY, DLEG, STOP, TRIP
--                p_entity_id - Id for entity
--                p_parent_entity_id - Parent Id for entity:
--                                    DLVY is parent for DLVB and DLEG
--                                    TRIP is parent for STOP
--	                p_entity_status - Status of entity
--                p_entity_planned_state - Planned state of entity
--                p_list_type     - Type of column names to choose
--                                   'WSHFSTRX'  will return STF field names
--                                   unless p_caller is like FTE%
--                x_disabled_list - list of disabled columns
--	                x_return_status - Status of procedure call
--                p_caller        - identify caller; FTE% will get table column names
--
--  Description: This procedure will return a list of disabled columns for
--               update restrictions on the form, unless the first element
--               has the value 'FULL', in which case the list is as below:
--                  'FULL' and list count = 1, means all columns need to
--                       be disabled
--                  'FULL' and list count > 1, means all columns except
--                       the columns that follow are disabled or "entered."
--                  '+column_name' (i.e., column name marked by '+')
--                        means that column_name has "Entered" status,
--                        which is disabled only if the column has a
--                        non-NULL value (i.e., enabled only if NULL).


PROCEDURE Get_Disabled_List(
		p_api_version            IN     NUMBER,
		p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
		x_return_status         OUT NOCOPY      VARCHAR2,
		x_msg_count             OUT NOCOPY      NUMBER,
		x_msg_data              OUT NOCOPY      VARCHAR2,

		p_entity_type    			IN   VARCHAR2,
		p_entity_id					IN   NUMBER,
		p_parent_entity_id 		IN   NUMBER DEFAULT NULL,
      p_list_type					IN   VARCHAR2,
		x_disabled_list    		OUT NOCOPY   wsh_util_core.column_tab_type,
                p_caller                IN   VARCHAR2 DEFAULT NULL
);

END WSH_DATA_PROTECTION;

 

/
