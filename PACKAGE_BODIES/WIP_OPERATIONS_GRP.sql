--------------------------------------------------------
--  DDL for Package Body WIP_OPERATIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATIONS_GRP" AS
/* $Header: wipopgpb.pls 115.6 2004/06/17 13:49:50 mraman noship $ */

procedure WIP_PERCENTAGE_COMPLETE
  (   p_api_version         IN	NUMBER,
      p_init_msg_list       IN	VARCHAR2 := FND_API.G_FALSE	,
      p_wip_entity_id       IN 	NUMBER,
      x_Percentage_complete OUT	NOCOPY NUMBER,
      x_scheduled_hours     OUT	NOCOPY NUMBER,
      x_return_status       OUT	NOCOPY VARCHAR2,
      x_msg_data            OUT	NOCOPY VARCHAR2,
      x_msg_count     	    OUT NOCOPY NUMBER
  )
  IS
    l_total_complete NUMBER  :=0;
    l_scheduled_hours NUMBER; -- Total Scheduled Hours
    l_hrVal Number ;
    l_uomClass VARCHAR2(10);
    l_usage Number ;
    l_progress Number ;
    l_op_seq_num number ;
    l_hrUOM VARCHAR2(3):= fnd_profile.value('BOM:HOUR_UOM_CODE');--hour UOM

/* Cursor to pick up all the resource usages which are based on time*/
CURSOR Cresource IS
SELECT operation_seq_num,sum(inv_convert.inv_um_convert(0,
                                        NULL,
                                wor.scheduled_units * assigned_units,
                                        wor.UOM_CODE,
					l_hrUom,
                                        NULL,
                                        NULL ))
FROM    wip_operation_resources_v wor
WHERE   wor.wip_entity_id = p_wip_entity_id
AND     wor.UOM_CODE  in (SELECT UOM_CODE
                            FROM mtl_units_of_measure
                            WHERE UOM_CLASS = l_uomclass)
GROUP BY wor.operation_seq_num ;

/* Cursor to get the progress percentage for an operation seq number */
CURSOR Cprogress(l_op_seq_num number) IS
SELECT progress_percentage
FROM   wip_operations
WHERE  operation_seq_num = l_op_seq_num
AND    wip_entity_id = p_wip_entity_id ;


BEGIN

    SELECT conversion_rate, uom_class
      INTO l_hrVal, l_uomClass
      FROM mtl_uom_conversions
     WHERE uom_code = l_hrUOM
       AND nvl(disable_date, sysdate + 1) > sysdate
       AND inventory_item_id = 0;

       OPEN CResource ;
	LOOP
 	  FETCH CResource INTO l_op_seq_num , l_usage ;
	  EXIT WHEN Cresource%NOTFOUND ;
  	  OPEN Cprogress(l_op_seq_num);
 	  FETCH Cprogress INTO l_progress ;
          l_total_complete := l_total_complete + NVL(l_progress,0) *
                                                 NVL(l_usage,0) ;
 	  CLOSE Cprogress;
	END loop;
        CLOSE CResource ;


  SELECT
     sum(inv_convert.inv_um_convert( 0 ,
                                      NULL ,
                                      wor.scheduled_units * assigned_units,
                                      wor.UOM_CODE,
                            	      l_hrUOM,
                           	      NULL,
                               	      NULL  ))
  INTO    l_scheduled_hours
  FROM    wip_operation_resources_v wor
  WHERE   wor.wip_entity_id = p_wip_entity_id
  AND  	wor.UOM_CODE  in (SELECT UOM_CODE
                          FROM mtl_units_of_measure
                          WHERE UOM_CLASS  = l_uomclass);

  x_percentage_complete := l_total_complete / l_scheduled_hours;

  x_scheduled_hours := l_scheduled_hours ;

-- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
    (   p_count             =>      x_msg_count,
	p_data              =>      x_msg_data
    );


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	fnd_message.set_name('WIP', 'NO_DATA_AVAILABLE');
	FND_MSG_PUB.Add;
	FND_MSG_PUB.Count_And_Get
	(   p_count             =>      x_msg_count,
	    p_data              =>      x_msg_data
	);

    WHEN ZERO_DIVIDE THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	fnd_message.set_name('WIP', 'WIP_NO_SCHEDULED_HRS');
	FND_MSG_PUB.Add;
	FND_MSG_PUB.Count_And_Get
	(   p_count             =>      x_msg_count,
	    p_data              =>      x_msg_data
	);
	x_scheduled_hours := 0;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level
	  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	   FND_MSG_PUB.Add_Exc_Msg
	    (       'WIP_OPERATIONS_GRP',
		    'WIP_PERCENTAGE_COMPLETE'
	    );
	END IF;
	  FND_MSG_PUB.Count_And_Get
            (   p_count             =>      x_msg_count,
                p_data              =>      x_msg_data
            );


  END WIP_PERCENTAGE_COMPLETE;


END WIP_OPERATIONS_GRP;

/
