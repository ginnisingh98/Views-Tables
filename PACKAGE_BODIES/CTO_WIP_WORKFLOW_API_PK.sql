--------------------------------------------------------
--  DDL for Package Body CTO_WIP_WORKFLOW_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WIP_WORKFLOW_API_PK" as
/* $Header: CTOWIPAB.pls 120.2.12010000.2 2010/07/21 07:59:57 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPAB.pls                                                  |
|                                                                             |
| DESCRIPTION:                                                                |
|               APIs are written for WIP and Flow support for OE-99 from      |
|               the CTO group.                                                |
|               first_reservation_created - inform the order line workflow    |
|               thaT the first reservation has been created for this sales    |
|               order line.                                                   |
|               last_reservation_deleted - inform the order line workflow that|
|               the last reservation has been deleted for this sales order    |
|               line.                                                         |
|               workflow_build_status - to determine if a particular          |
|               sales order line is at the released phase of the workflow.    |
|                                                                             |
|                                                                             |
| HISTORY     :                                                               |
|               July 22, 99  James Chiu   Initial version                     |
|               12/18/2000   Renga Kannan                                     |
|                            Added one utility procedure CTO_DEBUG which      |
|                            will write the CTO debug messages                |
|                                                                             |
|               01/11/2001   Renga Kannan                                     |
|                            The exception handling in CTO_DEBUG is added     |
|                            so that the cto_debug will not fail in the case  |
|                            of invalid directry specified. This fix is part  |
|                            of bug # 1577006                                 |
|              08/16/2001    Kiran Konada, fix for bug#1874380                |
|                            to support ATO item under a PTO                  |
|                             item_type_code for an ato item under PTO        |
|			     is 'OPTION' and top_model_line_id will NOT be    |
|                             null, UNLIKE an ato item order, where           |
|			     item_type_code = 'Standard' and                  |
|                             top_model_lined_id is null                      |
|                             This fix has actually been provided in          |
|                              branched code 115.15.115.3                     |
|                                                                             |
|               06/01/2005   Renga Kannan
|                            Added NoCopy Hint				      |
=============================================================================*/



G_PKG_NAME               CONSTANT  VARCHAR2(30) := 'CTO_WIP_WORKFLOW_API_PK';
G_ITEM_TYPE_NAME         CONSTANT  VARCHAR2(30) := 'OEOL';


/******************************************************************************

  Procedure  : CTO_DEBUG
  Parameters : proc_name      ---   Name of the procedure which is calling this utility
               Text           ---   Debug message which needs to be written to the log file


  Description :   This utility will write the message into the CTO Debug file
		  in ctoDDHH24MISS.dbg format.



*********************************************************************************/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE   CTO_DEBUG(
                        proc_name   IN   VARCHAR2,
                        text        IN   VARCHAR2) is
fname   utl_file.file_type;

BEGIN

 -- bugfix 2430063 : Only if OM:Debug Level is set to 5 or more, cto* debug
 --                  will be generated.


 if ( gDebugLevel < 5 ) then
	return;
 end if;


 if CTO_WIP_WORKFLOW_API_PK.file_dir is null then

  /* -- begin bugfix 3511114: use v$parameter2 instead.
 *
 *    select ltrim(rtrim(substr(value, instr(value,',',-1,1)+1)))
 *       into   file_dir
 *          from   v$parameter
 *             where  name= 'utl_file_dir';
 *
 *                -- end bugfix 3511114
 *                   */

 -- begin bugfix 3511114: use v$parameter2 instead.

   select ltrim(rtrim(value))
   into   file_dir
   from   (select value from v$parameter2
           where name='utl_file_dir'
           order by rownum desc)
   where rownum <2;

 -- end bugfix 3511114

 end if;

 if CTO_WIP_WORKFLOW_API_PK.file_name is null then
   file_name := 'cto_'||to_char(sysdate,'ddhh24miss')||'.dbg';
 end if;

 fname := utl_file.fopen(CTO_WIP_WORKFLOW_API_PK.file_dir,CTO_WIP_WORKFLOW_API_PK.file_name,'a');
 utl_file.put_line(fname,proc_name||'::'||text);
 utl_file.fflush(fname);
 utl_file.fclose(fname);


EXCEPTION
 when OTHERS then
  -- The exception handling is added by renga Kannan on 01/11/2001
  -- We don't want to stop other functinality becauseo of CTO_DEBUG erros.
  -- The example cases are if the customer sets the utl_file_dir value as * or .
  -- We need not create the debug message and need not faile too.
   null;

END CTO_DEBUG;


/**************************************************************************

   Procedure:   first_wo_reservation_created
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the first reservation has been created for this sales order
                line.

*****************************************************************************/



PROCEDURE first_wo_reservation_created(
        order_line_id   IN             NUMBER,
        x_return_status OUT  NOCOPY    VARCHAR2,
        x_msg_count     OUT  NOCOPY    NUMBER,
        x_msg_data      OUT  NOCOPY    VARCHAR2)

IS

  l_api_name CONSTANT 		varchar2(40)   := 'first_wo_reservation_created';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	varchar2(8);
  return_value 			integer;


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select item_type_code, ato_line_id
    into  v_item_type_code, v_ato_line_id
    from oe_order_lines_all
    where line_id = order_line_id;

    --Adding INCLUDED item type code for SUN ER#9793792
    --if ((upper(v_item_type_code) = 'STANDARD' OR upper(v_item_type_code) = 'OPTION')  --fix for bug#1874380
    IF (  (UPPER(v_item_type_code) = 'STANDARD'
        OR UPPER(v_item_type_code) = 'OPTION'
        OR UPPER(v_item_type_code) = 'INCLUDED'
	  )
        AND v_ato_line_id          = order_line_id
       )
        OR UPPER(v_item_type_code) = 'CONFIG'
    THEN

    --
    --  an ATO item line or CONFIG line
    --  check if the line status is CREATE_SUPPLY_ORDER_ELIGIBLE or
    --                              SHIP_LINE
    --

      query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
						   'CREATE_SUPPLY_ORDER_ELIGIBLE',
						   'CREATE_SUPPLY_ORDER_ELIGIBLE',
						   v_activity_status_code);

      if  upper(v_activity_status_code) = 'NOTIFIED' then
	   wf_engine.CompleteActivityInternalName(G_ITEM_TYPE_NAME,
                                        TO_CHAR(order_line_id),
	                                'CREATE_SUPPLY_ORDER_ELIGIBLE',
	                                'RESERVED');

      else
	  query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
								   'SHIP_LINE', 'SHIP_LINE', v_activity_status_code);
          if  upper(v_activity_status_code) <> 'NOTIFIED' then
		    cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
            	    raise FND_API.G_EXC_ERROR;
	  end if;
      end if;

        -- display proper status to OM form
	-- Added By Renga Kannan on 12/18/00 to get the debug messages

      CTO_DEBUG('FIRST_WO_RESERVATION_CREATED',
                'Calling Display_wf_status procedure for order_line_id='||to_char(order_line_id));

      return_value := CTO_WORKFLOW_API_PK.display_wf_status(order_line_id);

      CTO_DEBUG('FIRST_WO_RESERVATION_CREATED',
                'Return value from display_wf_status = '||to_char(return_value));

      if return_value <> 1 then
	     cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
             raise FND_API.G_EXC_ERROR;
      end if;

    end if;


EXCEPTION

  when FND_API.G_EXC_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('first_wo_reservation_created: ' || 'first_wo_reservation_created raised expected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('first_wo_reservation_created: ' || 'first_wo_reservation_created raised unexpected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

  when others then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('first_wo_reservation_created: ' || 'first_wo_reservation_created others exception: '||sqlerrm,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );



END first_wo_reservation_created;


/**************************************************************************

   Procedure:   last_wo_reservation_deleted
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the last reservation has been deleted for this sales order
                line.

*****************************************************************************/

PROCEDURE last_wo_reservation_deleted(
        order_line_id   IN          NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data      OUT NOCOPY  VARCHAR2
        )
IS



  l_api_name CONSTANT 		VARCHAR2(40)   := 'last_wo_reservation_deleted';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	VARCHAR2(8);
  v_counter 			INTEGER;
  v_counter2 			INTEGER;
  return_value 			INTEGER;
  l_source_document_type_id  	NUMBER;		--bugfix 1799874


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select item_type_code, ato_line_id
    into  v_item_type_code, v_ato_line_id
    from oe_order_lines_all
    where line_id = order_line_id;

    --bugfix 1799874 start
    l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => order_line_id );
    --bugfix 1799874 end

    --Adding INCLUDED item type code for SUN ER#9793792
    --if(((upper(v_item_type_code) = 'STANDARD') OR (upper(v_item_type_code) = 'OPTION'))
    if((   (upper(v_item_type_code) = 'STANDARD')
        OR (upper(v_item_type_code) = 'OPTION')
	OR (upper(v_item_type_code) = 'INCLUDED')
       )
        and v_ato_line_id = order_line_id )   -- fix for bug# 1874380
        or upper(v_item_type_code) = 'CONFIG'
    then

	--  an ATO item line or CONFIG line
	--  check if the line status is SHIP_LINE

	  query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
							   'SHIP_LINE',
							   'SHIP_LINE', v_activity_status_code);
      	  if  upper(v_activity_status_code) = 'NOTIFIED' then

		v_counter := 0;

		select count(*) into v_counter
		from mtl_reservations
		--where demand_source_type_id = 2
                where demand_source_type_id  =
                                   decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
					   inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
		and   demand_source_line_id = order_line_id
		and   primary_reservation_quantity > 0;

 		-- bugfix 1799874 : as per adrian suherman, we need not worry about internal SO for wip_flow_schedules.


        	v_counter2 := 0;

                /*****************************************************************
                 * The following Sql has changed by Renga Kannan to fix the sql
                 * for performance. The count(*) logic is replaced with the
                 * current logic to get better performance
                 * ***************************************************************/
                Begin
                   select 1
                   into   v_counter2
                   from   dual
                   where exists(select 'x'
                                from   wip_flow_schedules
                                where  demand_source_type = 2
                                and    demand_source_line = to_char(order_line_id));  --Bugfix 6330114
                Exception when no_data_found then
                   v_counter2 := 0;
                End;


        	/* no reservation at all */
        	if v_counter = 0 and v_counter2 = 0 then
          		wf_engine.CompleteActivityInternalName(G_ITEM_TYPE_NAME,
                                                 TO_CHAR(order_line_id),
	                                         'SHIP_LINE',
	                                         'UNRESERVE');
        	end if;

	  else
		    cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
		    raise FND_API.G_EXC_ERROR;
          end if;

      	  -- display proper status to OM form

      	  CTO_DEBUG('LAST_WO_RESERVATION_DELETED',
                 'Calling Display_wf_status procedure for order_line_id='||to_char(order_line_id));


          return_value := CTO_WORKFLOW_API_PK.display_wf_status(order_line_id);

          CTO_DEBUG('LAST_WO_RESERVATION',
                'Return value from display_wf_status  = '||to_char(order_line_id));

	  if return_value <> 1 then
	     	cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
		raise FND_API.G_EXC_ERROR;
	  end if;

    end if;


EXCEPTION

  when FND_API.G_EXC_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('last_wo_reservation_deleted: ' || 'last_wo_reservation_deleted raised expected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );


  when FND_API.G_EXC_UNEXPECTED_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('last_wo_reservation_deleted: ' || 'last_wo_reservation_deleted raised unexpected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

  when others then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('last_wo_reservation_deleted: ' || 'last_wo_reservation_deleted raised others exception: '||sqlerrm,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );


END last_wo_reservation_deleted;



/**************************************************************************

   Procedure:   flow_creation
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the first flow schedule has been created for this sales order
                line.

*****************************************************************************/


PROCEDURE flow_creation(
        order_line_id   IN          NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data      OUT NOCOPY  VARCHAR2)

IS

  l_api_name CONSTANT 		VARCHAR2(40)   := 'flow_creation';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	VARCHAR2(8);
  return_value 			INTEGER;


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select item_type_code, ato_line_id
    into  v_item_type_code, v_ato_line_id
    from oe_order_lines_all
    where line_id = order_line_id;

    --Adding INCLUDED item type code for SUN ER#9793792
    --if (((upper(v_item_type_code) = 'STANDARD') OR (upper(v_item_type_code) = 'OPTION'))
    if ((   (upper(v_item_type_code) = 'STANDARD')
         OR (upper(v_item_type_code) = 'OPTION')
	 OR (upper(v_item_type_code) = 'INCLUDED')
	)
       and v_ato_line_id = order_line_id)  -- fix for bug #1874380
       or upper(v_item_type_code) = 'CONFIG' then

	--  an ATO item line or CONFIG line
	--  check if the line status is CREATE_SUPPLY_ORDER_ELIGIBLE or
	--                              SHIP_LINE

	query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
							   'CREATE_SUPPLY_ORDER_ELIGIBLE',
							   'CREATE_SUPPLY_ORDER_ELIGIBLE', v_activity_status_code);
      	if  upper(v_activity_status_code) = 'NOTIFIED' then
        	wf_engine.CompleteActivityInternalName(G_ITEM_TYPE_NAME,
                                        TO_CHAR(order_line_id),
	                                'CREATE_SUPPLY_ORDER_ELIGIBLE',
	                                'RESERVED');

	else
		query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
								   'SHIP_LINE', 'SHIP_LINE', v_activity_status_code);
          	if  upper(v_activity_status_code) <> 'NOTIFIED' then
		    cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
		    raise FND_API.G_EXC_ERROR;
		end if;
        end if;

        -- display proper status to OM form

        CTO_DEBUG('FLOW_CREATION',
               ' display_wf_status procedure is called with order_line_id  = '||to_char(order_line_id));

        return_value := CTO_WORKFLOW_API_PK.display_wf_status(order_line_id);

        CTO_DEBUG('FLOW_CREATION',
               ' The return value from display_wf_status  = '||to_char(return_value));

	if return_value <> 1 then
	     cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
             raise FND_API.G_EXC_ERROR;
	end if;

    end if;


EXCEPTION

  when FND_API.G_EXC_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_creation: ' || 'flow_creation raised expected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );


  when FND_API.G_EXC_UNEXPECTED_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_creation: ' || 'flow_creation raised unexpected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

  when others then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_creation: ' || 'flow_creation raised others exception: '||sqlerrm,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );


END flow_creation;


/**************************************************************************

   Procedure:   flow_deletion
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the last flow schedule has been deleted for this sales order
                line.

*****************************************************************************/

PROCEDURE flow_deletion(
        order_line_id   IN         NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2
        )
IS



  l_api_name CONSTANT 		VARCHAR2(40)   := 'flow_deletion';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	VARCHAR2(8);
  v_counter 			INTEGER;
  v_counter2 			INTEGER;
  return_value 			INTEGER;
  l_source_document_type_id  	NUMBER;		--bugfix 1799874


BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select item_type_code, ato_line_id
    into  v_item_type_code, v_ato_line_id
    from oe_order_lines_all
    where line_id = order_line_id;

    --bugfix 1799874 start
    l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => order_line_id );
    --bugfix 1799874 end

    --Adding INCLUDED item type code for SUN ER#9793792
    --if (((upper(v_item_type_code) = 'STANDARD') OR (upper(v_item_type_code) = 'OPTION'))
    if ((   (upper(v_item_type_code) = 'STANDARD')
         OR (upper(v_item_type_code) = 'OPTION')
	 OR (upper(v_item_type_code) = 'INCLUDED')
	)
       and v_ato_line_id = order_line_id )        -- fix for bug#1874380
       or upper(v_item_type_code) = 'CONFIG'
    then

	--  an ATO item line or CONFIG line
	--  check if the line status is SHIP_LINE

	  query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(order_line_id),
							   'SHIP_LINE',
							   'SHIP_LINE', v_activity_status_code);
      	  if  upper(v_activity_status_code) = 'NOTIFIED' then

		v_counter := 0;
		select count(*) into v_counter
		from mtl_reservations
		-- where demand_source_type_id = 2
                where demand_source_type_id  =
                                   decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
					   inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
		and   demand_source_line_id = order_line_id
		and   primary_reservation_quantity > 0;

 		-- bugfix 1799874 : as per adrian suherman, we need not worry about internal SO for wip_flow_schedules.

		v_counter2 := 0;

                -- bug 3840900. rkaza. 08/18/2004. select count(*) logic
                -- is replaced with the current logic to get better performance

                Begin
                   select 1
                   into   v_counter2
                   from   dual
                   where exists(select 'x'
                                from   wip_flow_schedules
                                where  demand_source_type = 2
                                and    demand_source_line = to_char(order_line_id));  --Bugfix 6330114
                Exception when no_data_found then
                   v_counter2 := 0;
                End;

        	/* no flow schedule and reservation at all */
        	if v_counter = 0 and v_counter2 = 0 then
          		wf_engine.CompleteActivityInternalName(G_ITEM_TYPE_NAME,
                                                 TO_CHAR(order_line_id),
	                                         'SHIP_LINE',
	                                         'UNRESERVE');
        	end if;

	  else
		    cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
		    raise FND_API.G_EXC_ERROR;
          end if;

      	  -- display proper status to OM form

          CTO_DEBUG('FLOW_DELETION',
                ' display_wf_status is called with order_line_id =   '||to_char(order_line_id));

          return_value := CTO_WORKFLOW_API_PK.display_wf_status(order_line_id);

          CTO_DEBUG('FLOW_DELETION',
                ' Display_wf_status return value = '||to_char(return_value));

          if return_value <> 1 then
         	cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
         	raise FND_API.G_EXC_ERROR;
      	  end if;

     end if;


EXCEPTION

  when FND_API.G_EXC_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_deletion: ' || 'flow_deletion raised expected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );


  when FND_API.G_EXC_UNEXPECTED_ERROR then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_deletion: ' || 'flow_deletion raised expected error.',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

  when others then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_deletion: ' || 'flow_deletion raised others exception:'||sqlerrm,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    CTO_MSG_PUB.Count_And_Get(
      p_msg_count => x_msg_count,
      p_msg_data  => x_msg_data
    );

END flow_deletion;




/**************************************************************************

   Procedure:   query_wf_activity_status
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_label          -           "
                p_activity_name           -           "
                p_activity_status         -
   Description: this procedure is used to query a Workflow activity status

*****************************************************************************/

PROCEDURE query_wf_activity_status(
        p_itemtype        IN         VARCHAR2,
        p_itemkey         IN         VARCHAR2,
        p_activity_label  IN         VARCHAR2,
        p_activity_name   IN         VARCHAR2,
        p_activity_status OUT NOCOPY VARCHAR2 )

IS


BEGIN

    select activity_status
    into   p_activity_status
    from   wf_item_activity_statuses was
    where  was.item_type      = p_itemtype
    and    was.item_key       = p_itemkey
    and    was.process_activity in
	(SELECT wpa.instance_id
	FROM  wf_process_activities wpa
	 WHERE wpa.activity_name = p_activity_name);

EXCEPTION

  when others then
    p_activity_status := 'NULL';

END query_wf_activity_status;

/**************************************************************************

   Function:    workflow_build_status
   Parameters:  order_line_id           - order_line_id
   Description: This API will be called by WIP to determine if a particular
                sales order line is at the released phase of the workflow.
                This function returns TRUE/FALSE.

*****************************************************************************/

FUNCTION workflow_build_status(
        order_line_id   IN      NUMBER)
return INTEGER is

  v_activity_status_code_1 	VARCHAR2(8);
  v_activity_status_code_2      VARCHAR2(8);

BEGIN

  query_wf_activity_status('OEOL', TO_CHAR(order_line_id), 'SHIP_LINE',
                           'SHIP_LINE', v_activity_status_code_1);

  query_wf_activity_status('OEOL', TO_CHAR(order_line_id),
                           'CREATE_SUPPLY_ORDER_ELIGIBLE',
                           'CREATE_SUPPLY_ORDER_ELIGIBLE',
                           v_activity_status_code_2);

  if upper(v_activity_status_code_1) = 'ACTIVE' or
     upper(v_activity_status_code_1) = 'NOTIFIED'or
     upper(v_activity_status_code_2) = 'ACTIVE' or
     upper(v_activity_status_code_2) = 'NOTIFIED'or
     upper(v_activity_status_code_2) = 'COMPLETE'
  then
	return (1);
  else
	return (2);
  end if;


EXCEPTION

  when others then
    return (2);

END workflow_build_status;

END CTO_WIP_WORKFLOW_API_PK;

/
