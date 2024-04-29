--------------------------------------------------------
--  DDL for Package Body MRP_CUSTOM_LINE_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CUSTOM_LINE_SCHEDULE" AS
/* $Header: MRPPCLSB.pls 120.0 2005/05/25 03:35:31 appldev noship $  */

G_PKG_NAME		CONSTANT VARCHAR2(30) := 'MRP_CUSTOM_LINE_SCHEDULE';

PROCEDURE Custom_Schedule (
		p_api_version_number	IN 	NUMBER,
		p_rule_id		IN 	NUMBER,
		p_line_id		IN	NUMBER,
                p_org_id		IN 	NUMBER,
                p_flex_tolerance        IN      NUMBER,/*Added in bug1949098*/
         	p_scheduling_start_date IN 	DATE,
          	p_scheduling_end_date   IN 	DATE,
		x_return_status 	OUT 	NOCOPY	VARCHAR2,
  		x_msg_count  		OUT 	NOCOPY	NUMBER,
                x_msg_data		OUT	NOCOPY	VARCHAR2) IS

  l_api_version_number		CONSTANT NUMBER := 1.0;
  l_api_name			CONSTANT VARCHAR2(30) := 'Custom_Schedule';

BEGIN

  IF NOT FND_API.Compatible_API_Call
	( 	l_api_version_number,
		p_api_version_number,
		l_api_name,
		G_PKG_NAME)
  THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Add code here
  IF (p_rule_id = <first rule id>) THEN
     <first algorithm>
  ELSIF (p_rule_id = <second rule id>) THEN
     <second algorithm>
  ELSE
     <default algorithm>
  END IF;
  */
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Custom_Schedule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Custom_Schedule;

/*
   This API is being called from Line Scheduling Workbench before
   inserting the rows into wip_flow_schedules. It allows the user
   to customize the filtering of the demand to be inserted into
   wip_flow_schedules. This is called before the scheduling engine
   is invoked.
   IN Parameter :
	- p_rule_id     : the scheduling rule id
	- p_line_id     : the production line identifier
	- p_org_id      : the organization id
	- p_demand_type : to identify the demand type.
          2 for sales order, 100 for planned order
 	- p_demand_id   : the identifier for demand.
	  For sales order, p_demand_id = sales order line id in oe_order_lines_all
	  For planned order, p_demand_id = transaction_id in mrp_recommendations
   OUT Parameter :
	- p_valid_demand : the demand will be inserted into wip_flow_schedules
          if the p_valid_demand is TRUE. Otherwise it will be ignored.
*/
PROCEDURE Is_Valid_Demand (
                p_api_version_number    IN      NUMBER,
                p_rule_id               IN      NUMBER,
                p_line_id               IN      NUMBER,
                p_org_id                IN      NUMBER,
                p_demand_type           IN      NUMBER,
                p_demand_id             IN      NUMBER,
                p_valid_demand          OUT     NOCOPY	BOOLEAN,
                x_return_status         OUT     NOCOPY	VARCHAR2,
                x_msg_count             OUT     NOCOPY	NUMBER,
                x_msg_data              OUT     NOCOPY	VARCHAR2) IS

  l_api_version_number		CONSTANT NUMBER := 1.0;
  l_api_name			CONSTANT VARCHAR2(30) := 'Is_Valid_Demand';

BEGIN
  IF NOT FND_API.Compatible_API_Call
	( 	l_api_version_number,
		p_api_version_number,
		l_api_name,
		G_PKG_NAME)
  THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Add code here */
  p_valid_demand := TRUE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Get message count and data

  FND_MSG_PUB.Count_And_Get
  (   p_count                       => x_msg_count
  ,   p_data                        => x_msg_data
  );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Is_Valid_Demand'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Is_Valid_Demand;

END MRP_CUSTOM_LINE_SCHEDULE;

/
