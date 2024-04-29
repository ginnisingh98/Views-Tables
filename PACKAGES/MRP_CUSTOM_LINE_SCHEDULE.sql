--------------------------------------------------------
--  DDL for Package MRP_CUSTOM_LINE_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CUSTOM_LINE_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRPPCLSS.pls 120.2 2006/04/20 16:00:19 yulin noship $  */


PROCEDURE Custom_Schedule (
		p_api_version_number	IN 	NUMBER,
		p_rule_id		IN 	NUMBER,
		p_line_id		IN	NUMBER,
                p_org_id                IN 	NUMBER,
                p_flex_tolerance        IN      NUMBER,/*Added in bug1949098*/
         	p_scheduling_start_date IN 	DATE,
          	p_scheduling_end_date   IN 	DATE,
		x_return_status 	OUT 	NOCOPY	VARCHAR2,
                x_msg_count		OUT	NOCOPY	NUMBER,
  		x_msg_data  		OUT 	NOCOPY	VARCHAR2);

PROCEDURE Is_Valid_Demand (
                p_api_version_number    IN      NUMBER,
                p_rule_id               IN      NUMBER,
                p_line_id               IN      NUMBER,
                p_org_id                IN      NUMBER,
                p_demand_type           IN      NUMBER,
                p_demand_id             IN      NUMBER,
		p_valid_demand		OUT     NOCOPY	BOOLEAN,
                x_return_status         OUT     NOCOPY	VARCHAR2,
                x_msg_count             OUT     NOCOPY	NUMBER,
                x_msg_data              OUT     NOCOPY	VARCHAR2);

END MRP_CUSTOM_LINE_SCHEDULE;

 

/
