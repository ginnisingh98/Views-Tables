--------------------------------------------------------
--  DDL for Package Body CTO_SUBASSEMBLY_SUP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_SUBASSEMBLY_SUP_PK" as
/* $Header: CTOSUBSB.pls 120.17.12010000.3 2010/03/09 12:05:10 pdube ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOSUBSB.pls                                                  |
|                                                                             |
| DESCRIPTION:                                                                |
|               This file creates creates the sub-assembly supply
|               Was created for ML Supply fetaure
|                                                                             |
|
|                                                                             |
| HISTORY     :                                                               |
|               12-DEC-2002   Kiran Konada
|				Intial Cretion
|
|		07-Jan-2003   Kiran Konada
|			      insert paramaeter first_unit_start in wjsi table
|			      when finite scheduler is on.
|			      also,caluclated job_start date for item when finite
|			      scheduler us ON AND top-most item is flow
|			      bugfix#2739590
|
|
|	       20-JAn-2003   Kiran Konada
|			     bugfix 2755695
|			     Create a new mesage for a buy item
|			     a) when top-most item is flow
|				CTO_SUB_LEVEL_BUY_ITEMS
|
                             b) when top-most item is discrete
|				  debug message in AFAS log file
|			     Created a new message when Discrete is under flow
|				CTO_SUB_LEVEL_DISCRETE_REQ
|
|		24-Jan_2003   Kiran Konada
|			     bugfix 2755655 and 2756247
|			     added a outer joing bom_operational routings atbel
|			     if no routing is present, nvl(cfm_routing_flag to -99)
|			     modfied the if conditions to check for
|			     if(cfm_routing_flag = -99 or 2)
|
|		28-JAN-2003  Kiran Konada
|			     bugfix 2765109
|			     When a DIS/BUY sub-item is required at OP SEQ 1 of
|			     a flow parent . It's earliest required date would
|			     be scheduled start date of the first schedule
|
|
|		29-Jan-2003 Kiran Konada
|			    bugfix 2775097
|			    addded the effectivity date whil getting
|			    child configuration items
|
|
|		12-FEB-2003 Kiran Konada
|			    bugfix 2786582
|			    Get-operation_offset_date API requires line_op_Seq_id as input.
|			    bug: operation_Sequence_id was being passed
|			    fix: pass line_op_seq_id
|
|			    operation seq in BOM form belongs to EVENt aasocciated iwth flow
|			    routing.
|			    EVENT is usually associated to either line_operation (and/or) process
|			    If event is not assocaited to any line_opeartion , we wil get the
|			     component required at that particular event at the start of flow
|			    schedle
|
|
|	       01-MAR-2002  Kiran Konada
|			    bugfix 2827357
|			    changed ceil to Floor as wipltesb.pls was using floor. Cto needs to be in sync
|			    with WIP calculations
|
|
|	      01-MAR-2002   Kiran konada
|			    bugifx  2817556
|			    added a attribute 'comment' to record structure in spec CTOSUBSS.pls
|			    added new record and table   r_consolidated_sub_item, t_cons_item_details
|			    Added a new procedure  check_recurring_item
|
|
|
|
|	      05-MAR-2002  Kiran Konada
|			   bugfix 2834244
|			   check for effectivity added
|
|	      21-MAR-2002  Kiran
|			   2858631
|
|
|             13-AUG-2003  Kiran Konada
                           for bug# 3063156
                           propagte bugfix 3042904 to main
|                          Passed project_id and task_id as parameters to populate_req_interface
|
|
|
|
|	      26-AUg-2003  Kiran Konada
|			   changes for DMF-J
|			   becuase of mutiple sources enahcement
|			   sourcetype 66 (invalid sourcing) is not an error any more
|
|
|             03-NOV-2003  Kiran Konada
|
|                          Main propagation bug#3140641
|
|                          Reverting bugfix made on 13-AUG-2003. removing project-id and task_id as
|                          as parametrs to populate req interface
|                          Instead passing P_top_most_line_id as parameter as interface_sourc_line_id
|                          to populate_req_interafce. porject_id and task_id is calculated within pop
|                          ulate req_intreface. This is done to remove dependency on CTOPROCS.pls spec
|                          reverted bugfix 3042904 and provided
			   solution thru fix 3129117
|                          Has functional dependecy on CTOPROCB.pls
|
|
|            02-05-2004    Kiran Konada
|                          Bugfix# 3418102
|                          Project_id and task_id is passed to child cofniguration item supply
|                          only when item attribute end_pegging_flag is set to 'I','X'
|
|            02-03-2005    Kiran Konada
|                          BUG#4153987
|                             FP :11.5.9 - 11.5.10 : of 4134956
|                             With this fix CTO will consider the component yield factor
|
|            06-Jan-2006   Kiran Konada
|			   bugfix#4492875
|	                   Removed the debug statement having sql%rowcount as parameter, which
|			   was immeditaly after sql statement and before if statement using sql%rowcount
|
|                          Reason : if there is a logic dependent on sql%rowcount and debug log statement before
|                           it uses sql%rowcount , then logic may go wrong
|
|
|            20-Feb-2006   Kiran Konada
|			   FP 5011199 base bug 4998922
|                          Look at only primary BOM's
|
|            22-Feb-2006   Kiran Konada
|			   bigfix 4615409
|                          get operation_lead_time percent from bom_operational_routings
|                          NOT from bom_inventory_components
|
|
|            23-Feb-2006   kiran Konada
|			   bugfix 5676839
|			   in FLM routing we should EVENTS onlu ie operation_type = 1
=============================================================================*/










TYPE r_flow_sch_details IS RECORD(
     t_flow_sch_index            number,
     order_line_id		 number, --sales order_line_id
     t_item_details_index        number,
     schedule_number             wip_flow_schedules.schedule_number%type,
     wip_entity_id		 wip_flow_schedules.wip_entity_id%type,
     scheduled_start_date        wip_flow_schedules.scheduled_start_date%type,
     planned_quantity            wip_flow_schedules.planned_quantity%type,
     scheduled_completion_date	 wip_flow_schedules.scheduled_completion_date%type,
     build_sequence		 wip_flow_schedules.build_sequence%type,
     line_id			 wip_flow_schedules.line_id%type,
     line_code			 wip_lines.line_code%type,
     synch_schedule_num          wip_flow_schedules.synch_schedule_num%type,
     SYNCH_OPERATION_SEQ_NUM     wip_flow_schedules.SYNCH_OPERATION_SEQ_NUM%type

     );



TYPE r_consolidated_sub_item IS RECORD(
     item_id number,
     op_seq number,
     -- commented element consolidate_qty number
     consolidate_item_qty number, /* LBM change */
     consolidate_lot_qty number  /* LBM change */

     );

TYPE t_flow_sch_details IS TABLE OF r_flow_sch_details INDEX BY BINARY_INTEGER;





TYPE t_cons_item_details IS TABLE OF r_consolidated_sub_item INDEX BY BINARY_INTEGER;





PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

/*Procedure get_mlsupply_details( p_order_line_id		IN number,
				x_return_status         out  NOCOPY varchar2,
				x_error_message         out  NOCOPY VARCHAR2,
				x_message_name          out  NOCOPY VARCHAR2 ); */
Procedure process_phantoms
          (
	       pitems_table      in out nocopy t_item_details,
	       p_organization_id in number,
	       x_return_status         out  NOCOPY varchar2,
	       x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
	       x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */
          );

PROCEDURE check_recurring_item
 (	p_cons_item_details   in out  NOCOPY t_cons_item_details,
        p_parent_item_id  in number,
	p_organization_id in number,
        p_item_id in number,
        x_min_op_seq_num  out NOCOPY number,
	x_comp_item_qty         out  NOCOPY number,
	x_comp_lot_qty         out  NOCOPY number,  /* LBM project */
        x_oper_lead_time_per  out  NOCOPY number,
        x_recurred_item_flag out NOCOPY number
)
is


v_recurr_flag varchar2(1) := 'N';
   i number :=1 ;

  l_index number;
  l_bill_seq_id number;
  l_stmt_num    number;

BEGIN
      IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add ('Entered check_recurred_item',1);
      END IF;
        x_recurred_item_flag := 1;
	l_stmt_num :=10;
        If (p_cons_item_details.count > 0) THEN--checks for unintialized collection
	    IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('inside the IF after checking for initialized collection',1);
	    END IF;

	  Loop
	       oe_debug_pub.add ('inside the loop aftr chking for intiliazed colelc',1);
	       l_stmt_num:=20;
      	        if   p_cons_item_details(i).item_id = p_item_id THEN
           		x_recurred_item_flag := 3; --recurred item
			oe_debug_pub.add ('check_recureed_item, returning with status 3',1);
                                    RETURN;--to calling program
                 END IF;

                          EXIT WHEN i =p_cons_item_details.LAST;

                             i := p_cons_item_details.NEXT(i);
         END LOOP;

        END IF;

        l_stmt_num:=30;
        IF ( v_recurr_flag = 'N') THEN

             BEGIN

                  -- bugfix 4134956: take component yield factor into account.

                /* LBM Project */
		l_stmt_num :=40;
     	          select SUM( decode( nvl(bic.basis_type,1), 1 , bic.COMPONENT_QUANTITY/bic.component_yield_factor, 0 )) ,
     	          SUM( decode( nvl(bic.basis_type,1), 2 , bic.COMPONENT_QUANTITY/bic.component_yield_factor, 0 )) , 'Y'
                  INTO   x_comp_item_qty , x_comp_lot_qty,  v_recurr_flag
	          FROM BOM_INVENTORY_COMPONENTS bic,
		       bom_bill_of_materials bom
	          WHERE bic.bill_sequence_id = bom.common_bill_sequence_id
                  and   bom.assembly_item_id = p_parent_item_id
                  and   bom.organization_id = p_organization_id
	          AND bic.COMPONENT_ITEM_ID = p_item_id
                  and bic.effectivity_date <= sysdate           --bugfix
		  and nvl(bic.disable_date,sysdate+1) > sysdate --2834244
		  and   bom.ALTERNATE_BOM_DESIGNATOR is null    --bug 4998922
	          GROUP BY bic.COMPONENT_ITEM_ID
	          HAVING COUNT(*) >1;
                /* LBM Project */
            exception
      	    when no_data_found then
             	   x_recurred_item_flag := 1;--single item not recurring
		   oe_debug_pub.add ('check_recureed_item, returning with status 1',1);
                    return;--to calling program
            END;
        END IF;

        l_stmt_num :=60;
        IF (v_recurr_flag =  'Y') THEN

               x_recurred_item_flag := 2 ;--first item recurred
               oe_debug_pub.add ('check_recureed_item, returning with status 2',1);

	       l_stmt_num :=70;
               select min(OPERATION_SEQ_NUM)
               into x_min_op_seq_num
               FROM BOM_INVENTORY_COMPONENTS bic,
		       bom_bill_of_materials bom
               WHERE bic.bill_sequence_id = bom.common_bill_sequence_id
                  and   bom.assembly_item_id = p_parent_item_id
                  and   bom.organization_id = p_organization_id
	          AND bic.COMPONENT_ITEM_ID = p_item_id
                  and bic.effectivity_date <= sysdate           --bugfix
		  and nvl(bic.disable_date,sysdate+1) > sysdate  --2834244
		  and   bom.ALTERNATE_BOM_DESIGNATOR is null;  --bug 4998922

	      l_stmt_num :=75;
	      IF PG_DEBUG <> 0 THEN
	       oe_debug_pub.add ('check_recureed_item, min op seq'|| x_min_op_seq_num,1);
              END IF;

             BEGIN
              l_stmt_num :=80;
              Select nvl(bos_p.OPERATION_LEAD_TIME_PERCENT,0)
              INTO  x_oper_lead_time_per
              FROM BOM_INVENTORY_COMPONENTS bic,
		       bom_bill_of_materials bom,
		       --bugfix 4615409
		       bom_operational_routings bor_p,
		       bom_operation_sequences bos_p
	     WHERE bic.bill_sequence_id = bom.common_bill_sequence_id
                  and   bom.assembly_item_id = p_parent_item_id
                  and   bom.organization_id = p_organization_id
	          AND bic.COMPONENT_ITEM_ID = p_item_id
		  and bic.operation_seq_num = x_min_op_seq_num
                  and bic.effectivity_date <= sysdate           --bugfix
		  and nvl(bic.disable_date,sysdate+1) > sysdate --2834244
		  and   bom.ALTERNATE_BOM_DESIGNATOR is null  --bug 4998922
		  --bugfix4615409
		  and   bor_p.assembly_item_id = bom.assembly_item_id
		  and   bor_p.organization_id  = bom.organization_id
                  and   bor_p.ALTERNATE_ROUTING_DESIGNATOR is null
                  and   bos_p.routing_sequence_id = bor_p.common_routing_sequence_id
                  and   bic.operation_seq_num=bos_p.operation_seq_num
		  and   nvl(bos_p.operation_type,1)=1;--only events for FLM routing 5676839
	     EXCEPTION -- 5622588
	     WHEN no_data_found THEN
	       x_oper_lead_time_per := 0;
	     END;


            IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add ('check_recureed_item, x_oper_lead_time_per'|| x_oper_lead_time_per  ,1);
	    END IF;

	   l_stmt_num :=90;
           If (p_cons_item_details.count > 0) THEN
	          l_stmt_num :=91;
		IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add ('check_recureed_item,count more than 0',1);
		END IF;
                l_index := p_cons_item_details.LAST+1;
                p_cons_item_details(l_index).item_id :=  p_item_id;
                p_cons_item_details(l_index).op_seq :=  x_min_op_seq_num ;
                /* LBM Project */
                p_cons_item_details(l_index).consolidate_item_qty := x_comp_item_qty;
                p_cons_item_details(l_index).consolidate_lot_qty := x_comp_lot_qty;
                /* LBM Project */

	     ELSE
	        l_stmt_num :=92;
		IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add ('check_recureed_item,first item',1);
		END IF;
                p_cons_item_details(1).item_id :=  p_item_id;
                p_cons_item_details(1).op_seq :=  x_min_op_seq_num ;

                -- commented code p_cons_item_details(1).consolidate_qty:= x_comp_item_qty;

                /* LBM Project */
                p_cons_item_details(1).consolidate_item_qty := x_comp_item_qty;
                p_cons_item_details(1).consolidate_lot_qty := x_comp_lot_qty;
                /* LBM Project */

             END IF;
	END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('CTO_SUBASSEMBLY_SUP_PK: ' || 'check_recurring_item::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
      RAISE FND_API.G_EXC_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('CTO_SUBASSEMBLY_SUP_PK: ' || 'check_recurring_item::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('CTO_SUBASSEMBLY_SUP_PK: ' || 'check_recurring_item::other error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END check_recurring_item;

PROCEDURE get_working_day
	   (porgid      in number,
            Pdate       in date,
            pleadtime    in number,
	    pdirection   in varchar2,
            x_ret_date  out NOCOPY date,
	    x_return_status         out  NOCOPY varchar2,
	    x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
	    x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */)

is
  l_new_date date := null;

  l_stmt_num number := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add ('get_working_day: ' || 'Pdate=>' ||to_char(Pdate,'mm/dd/yyyy hh24:mi:ss'),5);
        oe_debug_pub.add ('get_working_day: ' || 'trunc_Pdate=>' ||to_char(TRUNC(Pdate),'mm/dd/yyyy hh24:mi:ss'),5);
	oe_debug_pub.add ('get_working_day: ' || 'pleadtime =>' ||pleadtime ,5);

  END IF;

  IF  (pdirection = 'B') THEN

	l_stmt_num := 10;

	SELECT BCD1.CALENDAR_DATE into l_new_date
	FROM   BOM_CALENDAR_DATES BCD1,
		 BOM_CALENDAR_DATES BCD2,
		 MTL_PARAMETERS MP
	WHERE  MP.ORGANIZATION_ID    = porgid
	AND  BCD1.CALENDAR_CODE    = MP.CALENDAR_CODE
	AND  BCD2.CALENDAR_CODE    = MP.CALENDAR_CODE
	AND  BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
	AND  BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
	AND  BCD2.CALENDAR_DATE    = TRUNC(Pdate)
	AND  BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.PRIOR_SEQ_NUM) - pleadtime;
  ELSIF(pdirection = 'F') THEN
	SELECT BCD1.CALENDAR_DATE into l_new_date
	 FROM   BOM_CALENDAR_DATES BCD1,
	        BOM_CALENDAR_DATES BCD2,
	        MTL_PARAMETERS MP
        WHERE  MP.ORGANIZATION_ID    = porgid
        AND  BCD1.CALENDAR_CODE    = MP.CALENDAR_CODE
        AND  BCD2.CALENDAR_CODE    = MP.CALENDAR_CODE
        AND  BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
        AND  BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
        AND  BCD2.CALENDAR_DATE    = TRUNC(Pdate)
        AND  BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.NEXT_SEQ_NUM) + pleadtime;
  END IF;


   x_ret_date := l_new_date + (Pdate - TRUNC(Pdate));
   IF PG_DEBUG <> 0 THEN
         null;
        oe_debug_pub.add ('get_working_day: ' || 'l_new_date=>' ||to_char(l_new_date,'mm/dd/yyyy hh24:mi:ss'),5);
	oe_debug_pub.add ('get_working_day: ' || 'trunc_Pdate=>' ||to_char(TRUNC(Pdate),'mm/dd/yyyy hh24:mi:ss'),5);
	oe_debug_pub.add ('get_working_day: ' || '  x_ret_date=>' ||to_char(x_ret_date,'mm/dd/yyyy hh24:mi:ss'),5);


  END IF;

EXCEPTION

    when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOSUBSB.get_working_day OTHERS excpn: ' || to_char(l_stmt_num)||':' ||
                                substrb(sqlerrm,1,100);
           IF PG_DEBUG <> 0 THEN

           		oe_debug_pub.add('get_working_day: ' || 'CTOSUBSB.get_working_day OTHERS excpn:  ' || x_error_message,1);

           END IF;

          /* OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'get_working_day'
                        ); */




END get_working_day;




/*
start date is calculated based on fixed and vaiable lead time



*/


Procedure get_start_date( pCompletion_date       in      date,
		pQty                   in      number,
		pitemid       	       in      number,
       		porganization_id       in      number,
		pfixed_leadtime        in      number,
		pvariable_leadtime     in      number,
                x_start_date           out     NOCOPY date,
		 x_return_status         out  NOCOPY varchar2,
		 x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
		x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */)
is

l_return_status  varchar2(1) := null;
l_error_msg  varchar2(1000) := null;
l_msg_name   varchar2(30) := null;

l_total_lead_time number :=0;
l_stmt_num number := 0;



BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS ;



	l_total_lead_time :=  CEIL(  nvl(pfixed_leadtime,0) +( pQty *  nvl(pvariable_leadtime,0) ) );	 --bugfix 2827357

	IF PG_DEBUG <> 0 THEN

           oe_debug_pub.add ('get_start_date: ' || 'pCompletion_date=>' ||to_char(pCompletion_date,'mm/dd/yyyy hh24:mi:ss'),5);
	   oe_debug_pub.add ('get_start_date: ' || 'l_total_lead_time=>' ||l_total_lead_time,5);


        END IF;

        IF ( l_total_lead_time <> 0 ) THEN

	 	l_stmt_num := 20;
		get_working_day
		(
		  porgid	     => porganization_id ,
		  Pdate		     => pCompletion_date ,
	          pleadtime          =>	l_total_lead_time ,
		  pdirection   	     =>'B', --direction in getting working day 'backward
		  x_ret_date  	     =>	x_start_date,
		  x_return_status    =>  l_return_status,
		  x_error_message    =>  l_error_msg,
		  x_message_name     =>  l_msg_name

		 );

		/* if ( l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		       IF PG_DEBUG <> 0 THEN
		       	oe_debug_pub.add ('get_start_date: ' || 'get_start_date: failed after call to get_working_day with status ' || l_return_status ,1);

				oe_debug_pub.add ('get_start_date: ' || 'error message' || l_error_msg ,1);
			END IF;
			RAISE subprogram_exp ;

		 end if;    */

		 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_start_date: ' || 'get_start_date: failed after call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_start_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_start_date: ' || 'get_start_date: failed after call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_start_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_start_date: ' || 'success from get_working_day ' ,1);
				END IF;
		 END IF;


	ELSE
	    x_start_date := pCompletion_date;

	END IF;

	IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add ('get_start_date: ' || 'x_start_date=>' ||to_char(x_start_date,'mm/dd/yyyy hh24:mi:ss'),5);

        END IF;

EXCEPTION


   when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message := 'CTOSUBSB.get_start_date expected  excpn: '|| ':' ||
                                substrb(sqlerrm,1,100) ;


             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('get_start_date: ' || 'CTOSUBSB.get_start_date expected excpn:  ' || x_error_message,1);
             	END IF;



   when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_error_message := 'CTOSUBSB.get_start_date UN expected  excpn: '|| ':' ||
                                substrb(sqlerrm,1,100) ;


             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('get_start_date: ' || 'CTOSUBSB.get_start_date UN expected excpn:  ' || x_error_message,1);
             	END IF;




   when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOSUBSB.get_start_date OTHERS excpn: '|| ':' ||
                                substrb(sqlerrm,1,100) ;


           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('get_start_date: ' || 'CTOSUBSB.get_start_date OTHERS excpn:  ' || x_error_message,1);
           	END IF;


          /* OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'get_working_day'
                        ); */






END get_start_date;




/*

completion date for make items is calculated
*/


Procedure get_completion_date( 	pParent_job_start_date in date,
                                porganization_id       in number,
                                plead_time_offset_percent in number,
				pParent_processing_lead_time in number,
				ppostprocessing_time  in number ,           --valid for buy item only
				pSource_type	      in number,		--buy =3, make =2
				x_child_completion_date out NOCOPY date,
				x_return_status         out  NOCOPY varchar2,
				x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
				x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */)
is
   l_index number;
   l_parent_job_start_date date;

   l_return_status varchar2(10) := null;
   l_error_msg  varchar2(1000) := null;
   l_msg_name   varchar2(30) := null;

   l_total_lead_time number :=0;


    l_zero number :=0;
    l_stmt_num number := 0;


BEGIN

	       x_return_status := FND_API.G_RET_STS_SUCCESS ;

	       IF ( pSource_type = 2) THEN -- make item

	               l_total_lead_time :=  (plead_time_offset_percent/100)*pParent_processing_lead_time;
	       ELSIF ( pSource_type = 3) THEN --buy
                      l_total_lead_time  :=  (  ((plead_time_offset_percent/100)*pParent_processing_lead_time )
						     - ppostprocessing_time -1
						  );

	       END IF;

	     IF  l_total_lead_time>0 THEN

	        l_total_lead_time := ceil(l_total_lead_time);


	        l_stmt_num := 30;
	         get_working_day
		(
		  porgid	     => porganization_id ,
		  Pdate		     => pParent_job_start_date ,
	          pleadtime          =>	l_total_lead_time,
		  pdirection   	     =>	 'F',                 --direction in getting working day 'Forward'
		  x_ret_date  	     =>	 x_child_completion_date,
		  x_return_status    =>  l_return_status,
		  x_error_message    =>  l_error_msg,
		  x_message_name     =>  l_msg_name

		 );

		 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_completion_date: ' || ' failed in call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_completion_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_completion_date: ' || 'get_start_date: failed after call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_completion_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_completion_date: ' || 'success from get_working_day ' ,1);
				END IF;
		 END IF;
	    ELSIF  ( l_total_lead_time < 0 )	THEN
		   l_total_lead_time := FLOOR(l_total_lead_time);
                   l_total_lead_time := abs(l_total_lead_time);--2858631

		   l_stmt_num := 31;
	          get_working_day
		  (
		  porgid	     => porganization_id ,
		  Pdate		     => pParent_job_start_date ,
	          pleadtime          =>	l_total_lead_time,
		  pdirection   	     =>	 'B',                 --direction in getting working day 'Forward'
		  x_ret_date  	     =>	 x_child_completion_date,
		  x_return_status    =>  l_return_status,
		  x_error_message    =>  l_error_msg,
		  x_message_name     =>  l_msg_name

		 );

		 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_completion_date: ' || ' failed in call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_completion_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_ERROR;
		 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_completion_date: ' || 'get_start_date: failed after call to get_working_day with status ' || l_return_status ,1);

					oe_debug_pub.add ('get_completion_date: ' || 'error message' || l_error_msg ,1);
				END IF;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		 ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_completion_date: ' || 'success from get_working_day ' ,1);
				END IF;
		 END IF; --PO return status




	    ELSE
			x_child_completion_date := pParent_job_start_date;

	    END IF;


EXCEPTION

   when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
	      x_error_message := 'CTOSUBSB.get_completion_date expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);



             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('get_completion_date: ' || 'CTOSUBSB.get_completion_date expected excpn:  ' || x_error_message,1);
             	END IF;



   when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_error_message := 'CTOSUBSB.get_completion_date UN expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);



             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('get_completion_date: ' || 'CTOSUBSB.get_completion_date UN expected excpn:  ' || x_error_message,1);
             	END IF;





   when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOSUBSB.get_start_date OTHERS excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);


           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('get_completion_date: ' || 'CTOSUBSB.get_start_date OTHERS excpn:  ' || x_error_message,1);
           	END IF;


          /* OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'get_working_day'
                        ); */






END get_completion_date;



/*
cursor for autocreated config
cursor for ato and confiured items
sourcing rule check



*/


Procedure get_child_configurations
              (
	        pParentItemId     in number,
		pOrganization_id  in      number,
		pLower_Supplytype        in number,   --may need to change after sajnai codes 1= autocreated 2= autocreated and ATo items
		pParent_index       in number,
		pitems_table      in out nocopy t_item_details,
		x_return_status         out  NOCOPY varchar2,
	        x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
	        x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */



              )

is
  lComponent_item_id    number :=0;
  lComponent_quantity   number :=0;


  v_sourcing_rule_exists    VARCHAR2(100);
    v_sourcing_org            NUMBER;
    v_source_type             NUMBER;
    v_transit_lead_time       NUMBER;
    v_exp_error_code          NUMBER;

   -- x_return_status         VARCHAR2(1);

   l_stmt_num number := 0;

  --cursor for configured items
  -- Bug 9402188.Added nvl condition to pick the supply type from msi if not present in bom.pdube
  CURSOR c_config_items IS
  select component_item_id,
         msi.concatenated_segments,
	 component_quantity/bic.component_yield_factor, -- bugfix 4134956: take component_yield_factor into account
	 bic.operation_seq_num,
	 nvl(bor.cfm_routing_flag,-99),    --default to -99 if no routing and treat it as discrete
	 bor.routing_sequence_id,
	 nvl(msi.fixed_lead_time,0),
	 nvl(msi.variable_lead_time,0),
         nvl(msi.full_lead_time,0),
         nvl(msi.postprocessing_lead_time,0),
	 bic.bom_item_type,
	 msi.auto_created_config_flag,
	 bor.line_id,
	 wil.line_code,
	 end_assembly_pegging_flag, --Bugfix# 3418102
         nvl(bic.basis_type,1),            /* LBM Project */
         -- bic.wip_supply_type --4645636
         nvl(bic.wip_supply_type, msi.wip_supply_type) -- Bug 9402188
  from	bom_inventory_components bic,
	bom_bill_of_materials bom,
	mtl_System_items_kfv msi,
	--mtl_system_items msi,
	bom_operational_routings bor,
	wip_lines wil
	--bugfix 4615409
	--bom_operational_routings bor_p,--parent
	--bom_operation_sequences bos_p
 where bic.bill_sequence_id = bom.common_bill_sequence_id
 and   bom.assembly_item_id = pParentItemId
 and   bom.organization_id = pOrganization_id
 and   bic.component_item_id = msi.inventory_item_id
 and   bic.effectivity_date <= sysdate                --bugfix
 and   nvl(bic.disable_date,sysdate+1) > sysdate        --2775097
 and   msi.organization_id = pOrganization_id
 and   bor.assembly_item_id (+)= bic.component_item_id
 and   bor.ALTERNATE_ROUTING_DESIGNATOR(+) is null
 and   bor.organization_id (+) = pOrganization_id
 and   bor.line_id  = wil.line_id(+)
 and   msi.auto_created_config_flag = 'Y'
 and   bom.ALTERNATE_BOM_DESIGNATOR is null;  --bug 4998922



 -- Bug 9402188.Added nvl condition to pick the supply type from msi if not present in bom.pdube
 CURSOR c_config_and_ato_items IS
  select component_item_id,
         msi.concatenated_segments,
	 component_quantity/bic.component_yield_factor, -- bugfix 4134956: take component_yield_factor into account
         bic.operation_seq_num,
	 nvl(bor.cfm_routing_flag,-99),    --default to -99 if no routing and treat it as discrete
	 bor.routing_sequence_id,
	 nvl(msi.fixed_lead_time,0),
	 nvl(msi.variable_lead_time,0),
	 nvl(msi.full_lead_time,0),
	 nvl(msi.postprocessing_lead_time,0),
	 bic.bom_item_type,
	 msi.auto_created_config_flag,
         bor.line_id,
	 wil.line_code,
	 end_assembly_pegging_flag, --Bugfix# 3418102
         nvl(bic.basis_type,1),/* LBM Project */
         -- bic.wip_supply_type  --4645636
         nvl(bic.wip_supply_type, msi.wip_supply_type)  --Bugfix 9402188
  from	bom_inventory_components bic,
	bom_bill_of_materials bom,
	mtl_System_items_kfv msi,
	--mtl_System_items_b msi,
	bom_operational_routings bor,
	wip_lines wil
	--bugfix 4615409
	--bom_operational_routings bor_p,--parent
	--bom_operation_sequences bos_p
 where bic.bill_sequence_id = bom.common_bill_sequence_id
 and   bom.assembly_item_id = pParentItemId
 and   bom.organization_id = pOrganization_id
 and   bic.component_item_id = msi.inventory_item_id
 and   bic.effectivity_date <= sysdate                  --bugfix
 and   nvl(bic.disable_date,sysdate+1) > sysdate            --2775097
 and   msi.organization_id = pOrganization_id
 and   bor.assembly_item_id (+) = bic.component_item_id
 and   bor.ALTERNATE_ROUTING_DESIGNATOR(+) is null
 and   bor.organization_id (+) = pOrganization_id
 and   bor.line_id  = wil.line_id(+)
 and   msi.replenish_to_order_flag = 'Y'
 and   bic.bom_item_type = 4
 and   bom.ALTERNATE_BOM_DESIGNATOR is null;  --bug 4998922


 l_index number;

 l_ret_status		varchar2(1) := null;
 l_error_message  	varchar2(1000) := null;
 l_msg_name             varchar2(30) := null;

  p_cons_item_details t_cons_item_details;

  l_min_op_seq_num number;
  l_comp_item_qty  number;
  l_comp_lot_qty  number;
  l_oper_lead_time_per number;
  l_recurred_item_flag  number;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;

 IF pLower_Supplytype = 2 THEN

    IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add ('get_child_configurations: ' || 'Config children alone' ,1);
	--Bugfix 8913125: Added these messages.
	oe_debug_pub.add ('get_child_configurations: Parent Item:' || pParentItemId, 1);
	oe_debug_pub.add ('get_child_configurations: Org:' || pOrganization_id ,1);
	cto_wip_workflow_api_pk.cto_debug('get_child_configurations: ','Config children alone' );
    END IF;


    OPEN c_config_items;

             l_stmt_num := 40;
	     LOOP
	      l_index := pitems_table.last+1;
	        FETCH c_config_items INTO pitems_table(l_index).item_id,
					  pitems_table(l_index).item_name,
					  pitems_table(l_index).item_quantity,
					-- pitems_table(l_index).operation_lead_time_percent,
					  pitems_table(l_index).operation_seq_num,
		                          pitems_table(l_index).cfm_routing_flag,
					  pitems_table(l_index).routing_sequence_id,
		                          pitems_table(l_index).fixed_lead_time,
		                          pitems_table(l_index).variable_lead_time,
                                          pitems_table(l_index).processing_lead_time,
                                          pitems_table(l_index). postprocessing_lead_time,
					  pitems_table(l_index).bom_item_type,
					  pitems_table(l_index).auto_config_flag,
                                          pitems_table(l_index).line_id,
					  pitems_table(l_index).line_code,
					  pitems_table(l_index).pegging_flag,--Bugfix# 3418102
					  pitems_table(l_index).basis_type,/* LBM Project */
                                          pitems_table(l_index).wip_supply_type; --4645636

		 	  EXIT when c_config_items%notfound;

			   IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || 'item added' || pitems_table(l_index).item_name ,1);

					--Bugfix# 3418102
					oe_debug_pub.add ('get_child_configurations: ' || 'end_peeging_flag for project information' || pitems_table(l_index).pegging_flag ,3);
			   END IF;

                          --	5198966
			  BEGIN
			     select  nvl(bos_p.OPERATION_LEAD_TIME_PERCENT,0)
		             INTO pitems_table(l_index).operation_lead_time_percent
			     from  bom_operational_routings bor_p,--parent
			           bom_operation_sequences bos_p
			     where   bor_p.assembly_item_id = pParentItemId
			     and     bor_p.organization_id  = pOrganization_id
			     and   bor_p.ALTERNATE_ROUTING_DESIGNATOR is null
			     and   bos_p.routing_sequence_id = bor_p.common_routing_sequence_id
			     and   bos_p.operation_seq_num = pitems_table(l_index).operation_seq_num
			     and   nvl(bos_p.operation_type,1)=1; --consider events only for FLM cases.5676839
			  Exception
			     WHEN no_data_found then
				 pitems_table(l_index).operation_lead_time_percent := 0;
			  END;

                           pitems_table(l_index).parent_index := pParent_index;
			   pitems_table(l_index).feeder_run := 'N';


			    l_stmt_num := 50;
			   CTO_UTILITY_PK.QUERY_SOURCING_ORG(
                                          P_inventory_item_id     => pitems_table(l_index).item_id,
                                          P_organization_id       => pOrganization_id,
                                          P_sourcing_rule_exists  => v_sourcing_rule_exists,
                                          P_source_type           => v_source_type,
                                          P_sourcing_org          => v_sourcing_org,
                                          P_transit_lead_time     => v_transit_lead_time,
                                          X_exp_error_code        => v_exp_error_code,
                                          X_return_status         =>x_return_status
                              );

			      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || 'failed after call to CTO_UTILITY_PK.QUERY_SOURCING_ORG with status ' || x_return_status ,1);
				END IF;
				--oe_debug_pub.add ('error message' || l_error_msg ,1);
				RAISE FND_API.G_EXC_ERROR;
			      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || ' failed after call to CTO_UTILITY_PK.QUERY_SOURCING_ORG with status ' || x_return_status ,1);
				END IF;
				--oe_debug_pub.add ('error message' || l_error_msg ,1);
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_child_configurations: ' || 'success from CTO_UTILITY_PK.QUERY_SOURCING_ORG ' ,1);
				END IF;
		             END IF;


                             --by Kiran Konada
			     --removed if block for multiple sources
			     -- rkaza. 05/02/2005. Adding sourcing org also.
		             pitems_table(l_index).source_type  := v_source_type;
		             pitems_table(l_index).sourcing_org  := v_sourcing_org;



			   --call recurring item only
			   --if item is not multiple sources AND
			   --parent is flow AND
			   --if  item is buy or discrete or 100% transfer
			   -- rkaza. 05/02/2005. Adding 100% transfer cases.

			   IF (
			       pitems_table(l_index).source_type <> 66   AND
			       pitems_table(pParent_index).cfm_routing_flag = 1
   			       AND
			       (pitems_table(l_index).source_type = 3
				OR
				pitems_table(l_index).source_type = 1
				OR
				pitems_table(l_index).cfm_routing_flag <> 1
				)
			       ) THEN
		              oe_debug_pub.add ('calling check_recurring_item'  ,1);
			      check_recurring_item
				(	p_cons_item_details  => p_cons_item_details,
					p_parent_item_id     => pitems_table(pParent_index).item_id,
					p_organization_id    => pOrganization_id,
					p_item_id            =>  pitems_table(l_index).item_id,
					x_min_op_seq_num     =>  l_min_op_seq_num ,
					x_comp_item_qty      =>  l_comp_item_qty ,
					x_comp_lot_qty      =>  l_comp_lot_qty ,   /* LBM Project */
					x_oper_lead_time_per  => l_oper_lead_time_per,
					x_recurred_item_flag  => l_recurred_item_flag
				);
			   ELSE
				 --if parent is not flow default recurre_item_flag to 1
					--so that  standard processing takes place
					l_recurred_item_flag := 1;

			   END IF;

			  IF (l_recurred_item_flag = 1) THEN
                                --
				-- begin bugfix 4134956: item_quantity has component_yield_factor taken into account.
				-- Round to 6 decimal places
				--
                                /* LBM Project */
                                if( pitems_table(l_index).basis_type = 1)   /* Item Basis */
                                then
                                pitems_table(l_index).needed_item_qty :=
			            		round (pitems_table(pParent_index).needed_item_qty * pitems_table(l_index).item_quantity, 6);
                                else
                                pitems_table(l_index).needed_item_qty :=
			            		round( pitems_table(l_index).item_quantity, 6);
                                end if;

			        --immediate parent's calculate supply quantity * childs bic component qty
			  END IF;
			  IF (l_recurred_item_flag = 2) THEN
                                --
				-- begin bugfix 4134956: l_comp_item_qty has component_yield_factor taken into account.
				-- Round to 6 decimal places
				--
                                /* LBM change */
                                pitems_table(l_index).needed_item_qty :=
		round( ( ( pitems_table(pParent_index).needed_item_qty * l_comp_item_qty ) + l_comp_lot_qty ) , 6)   ;

				pitems_table(l_index).operation_seq_num :=  l_min_op_seq_num ;
				pitems_table(l_index).operation_lead_time_percent := l_oper_lead_time_per;


			  END IF;

			 IF (l_recurred_item_flag = 3) THEN
				 pitems_table(l_index).needed_item_qty := 0;
				pitems_table(l_index).comment := pitems_table(l_index).comment ||'This items supply has been consolidated';
			 END IF;



			 IF ( pitems_table(l_index).source_type = 2
				and
			        pitems_table(l_index).needed_item_qty > 0
			   ) THEN

				l_stmt_num := 60;
				get_child_configurations
				  ( pParentItemId		=> pitems_table(l_index).item_id,
							  pOrganization_id 	=>	pOrganization_id,
							  pLower_Supplytype	=>	pLower_Supplytype,
							  pParent_index		=> l_index,--passing index# as parentid for children
							  pitems_table  	=> 	pitems_table,
							  x_return_status	=>  l_ret_status,
							  x_error_message  	=>  l_error_message,
							  x_message_name   	=>   l_msg_name

                                     );

		         END IF;   --source type and needed_item_qty


	     END LOOP;
    Close c_config_items;

 ELSIF pLower_Supplytype = 3 THEN


    If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('get_child_configurations: ','Config and ato item children' );
	--Bugfix 8913125: Added these messages.
	oe_debug_pub.add ('get_child_configurations: Config and ato item children', 1);
	oe_debug_pub.add ('get_child_configurations: Parent Item:' || pParentItemId, 1);
	oe_debug_pub.add ('get_child_configurations: Org:' || pOrganization_id ,1);
    End if;

    OPEN c_config_and_ato_items;

	     l_stmt_num := 70;
	     LOOP
	        l_index := pitems_table.last+1;

	        FETCH c_config_and_ato_items INTO pitems_table(l_index).item_id,
					  pitems_table(l_index).item_name,
					  pitems_table(l_index).item_quantity,
					--  pitems_table(l_index).operation_lead_time_percent,
					  pitems_table(l_index).operation_seq_num,
		                          pitems_table(l_index).cfm_routing_flag,
					  pitems_table(l_index).routing_sequence_id,
		                          pitems_table(l_index).fixed_lead_time,
		                          pitems_table(l_index).variable_lead_time,
					  pitems_table(l_index).processing_lead_time,
					  pitems_table(l_index). postprocessing_lead_time,
					  pitems_table(l_index).bom_item_type,
					  pitems_table(l_index).auto_config_flag,
					  pitems_table(l_index).line_id,
					  pitems_table(l_index).line_code,
					  pitems_table(l_index).pegging_flag,
					  pitems_table(l_index).basis_type,  /* LBM Project */
			                  pitems_table(l_index).wip_supply_type; --4645636



		 	  EXIT when c_config_and_ato_items%notfound;
                          IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || 'item added' || pitems_table(l_index).item_name ,1);

					--Bugfix# 3418102
					oe_debug_pub.add ('get_child_configurations: ' || 'end_pegging_flag for project information' || pitems_table(l_index).pegging_flag ,3);
			  END IF;
			  l_stmt_num := 71;

			  --Bugfix 8913125: Added these messages.
			  If PG_DEBUG <> 0 Then
				oe_debug_pub.add ('get_child_configurations:stmt:l_stmt_num' || l_stmt_num);
				oe_debug_pub.add ('get_child_configurations:stmt:l_index:' || l_index);
				oe_debug_pub.add ('get_child_configurations:stmt:item_id:' || pitems_table(l_index).item_id);
				oe_debug_pub.add ('get_child_configurations:stmt:operation_seq_num:' || pitems_table(l_index).operation_seq_num);
				oe_debug_pub.add ('get_child_configurations:stmt:routing_sequence_id:' || pitems_table(l_index).routing_sequence_id);
			  End If;

                          --	5198966
			  BEGIN
			     select  nvl(bos_p.OPERATION_LEAD_TIME_PERCENT,0)
		             INTO pitems_table(l_index).operation_lead_time_percent
			     from  bom_operational_routings bor_p,--parent
			           bom_operation_sequences bos_p
			     where   bor_p.assembly_item_id = pParentItemId
			     and     bor_p.organization_id  = pOrganization_id
			     and   bor_p.ALTERNATE_ROUTING_DESIGNATOR is null
			     and   bos_p.routing_sequence_id = bor_p.common_routing_sequence_id
			     and   bos_p.operation_seq_num = pitems_table(l_index).operation_seq_num
			     and   nvl(bos_p.operation_type,1)=1  --consider events only for FLM cases.5676839
			     --Begin Bugfix 8913125
			     and   implementation_date IS NOT NULL
			     and   effectivity_date <= SYSDATE
			     and   nvl(disable_date, SYSDATE + 1) > SYSDATE;

			     If PG_DEBUG <> 0 Then
				oe_debug_pub.add ('get_child_configurations: oltp:' ||pitems_table(l_index).operation_lead_time_percent,1);
			     End If;
			     --End Bugfix 8913125

			  Exception
			     WHEN no_data_found THEN
				 pitems_table(l_index).operation_lead_time_percent := 0;
			  END;

			  l_stmt_num := 72;

			  pitems_table(l_index).parent_index := pParent_index;
			  pitems_table(l_index).feeder_run := 'N';

			  l_stmt_num := 80;

			  CTO_UTILITY_PK.QUERY_SOURCING_ORG(
                                          P_inventory_item_id     => pitems_table(l_index).item_id,
                                          P_organization_id       => pOrganization_id,
                                          P_sourcing_rule_exists  => v_sourcing_rule_exists,
                                          P_source_type           => v_source_type,
                                          P_sourcing_org          => v_sourcing_org,
                                          P_transit_lead_time     => v_transit_lead_time,
                                          X_exp_error_code        => v_exp_error_code,
                                          X_return_status         =>x_return_status
                              );

			     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || 'failed after call to CTO_UTILITY_PK.QUERY_SOURCING_ORG with status ' || x_return_status ,1);
				END IF;
				--oe_debug_pub.add ('error message' || l_error_msg ,1);
				RAISE FND_API.G_EXC_ERROR;
			      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('get_child_configurations: ' || ' failed after call to CTO_UTILITY_PK.QUERY_SOURCING_ORG with status ' || x_return_status ,1);
				END IF;
				--oe_debug_pub.add ('error message' || l_error_msg ,1);
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			     ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_child_configurations: ' || 'success from CTO_UTILITY_PK.QUERY_SOURCING_ORG ' ,1);
				END IF;
		             END IF;


			      --by Kiran Konada
			     --removed if block for multiple sources
			     -- rkaza. 05/02/2005. Adding sourcing org also.

			     pitems_table(l_index).source_type  := v_source_type;
		             pitems_table(l_index).sourcing_org  := v_sourcing_org;


			   --call recurring item only
			   --if item is not multiple sources AND
			   --parent is flow AND
			   --if item is buy or discrete or 100% transfer
			   -- rkaza. 05/02/2005. Added 100% transfer.

			   IF (
			       pitems_table(l_index).source_type <> 66   AND
			       pitems_table(pParent_index).cfm_routing_flag = 1
   			       AND
			       (pitems_table(l_index).source_type = 3
				OR
			        pitems_table(l_index).source_type = 1
				OR
				pitems_table(l_index).cfm_routing_flag <> 1
				)
			       ) THEN
		              oe_debug_pub.add ('calling check_recurring_item for item '  ,1);
			      check_recurring_item
				(	p_cons_item_details  => p_cons_item_details,
					p_parent_item_id     => pitems_table(pParent_index).item_id,
					p_organization_id    => pOrganization_id,
					p_item_id            =>  pitems_table(l_index).item_id,
					x_min_op_seq_num     =>  l_min_op_seq_num ,
					x_comp_item_qty      =>  l_comp_item_qty ,
					x_comp_lot_qty      =>  l_comp_lot_qty ,   /* LBM Project */
					x_oper_lead_time_per  => l_oper_lead_time_per,
					x_recurred_item_flag  => l_recurred_item_flag
				);
			   ELSE
				 --if parent is not flow default recurre_item_flag to 1
					--so that  standard processing takes place
					l_recurred_item_flag := 1;

			   END IF;

			  IF (l_recurred_item_flag = 1) THEN
                               --
			       -- begin bugfix 4134956: item_quantity has component_yield_factor taken into account.
			       -- Round to 6 decimal places
			       --

                               /* LBM Project */
                                if( pitems_table(l_index).basis_type = 1)   /* Item Basis */
                                then
                                pitems_table(l_index).needed_item_qty :=
                                                round (pitems_table(pParent_index).needed_item_qty * pitems_table(l_index).item_quantity, 6);
                                else
                                pitems_table(l_index).needed_item_qty :=
                                                round( pitems_table(l_index).item_quantity, 6);
                                end if;




				--immediate parent's calculate supply quantity * childs bic component qty

			  END IF;
			  IF (l_recurred_item_flag = 2) THEN
                               --
				-- begin bugfix 4134956: l_comp_item_qty has component_yield_factor taken into account.
				-- Round to 6 decimal places
				--
                                /* LBM Project */
				pitems_table(l_index).needed_item_qty :=
					round( ((pitems_table(pParent_index).needed_item_qty * l_comp_item_qty) + l_comp_lot_qty ) , 6)   ;
        			pitems_table(l_index).operation_seq_num :=  l_min_op_seq_num ;
	                        pitems_table(l_index).operation_lead_time_percent := l_oper_lead_time_per;

			  END IF;

			 IF (l_recurred_item_flag = 3) THEN
				 pitems_table(l_index).needed_item_qty := 0;
				pitems_table(l_index).comment := pitems_table(l_index).comment ||'This items supply has been consolidated';
			 END IF;



			   IF ( pitems_table(l_index).source_type = 2
				and
			        pitems_table(l_index).needed_item_qty > 0
			   ) THEN


			         get_child_configurations
							( pParentItemId		=>pitems_table(pitems_table.last).item_id,
							  pOrganization_id 	=>	pOrganization_id,
							  pLower_Supplytype	=>	pLower_Supplytype,
							  pParent_index		=> 	  l_index,--passing index# as parentid for children
							  pitems_table  	=> 	    pitems_table ,
							  x_return_status	=>  l_ret_status,
							 x_error_message  	=>  l_error_message,
							  x_message_name   	=>   l_msg_name

                                                        );

				  IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('get_child_configurations: ' || 'failed after call to get_child_configurations with status ' || l_ret_status ,1);

						oe_debug_pub.add ('get_child_configurations: ' || 'error message' || l_error_message ,1);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				 ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('get_child_configurations: ' || ' failed after call to get_child_configurations ' || l_ret_status ,1);

						oe_debug_pub.add ('get_child_configurations: ' || 'error message' || l_error_message ,1);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				  ELSE

					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('get_child_configurations: ' || 'success from get_child_configurations ' ,1);
					END IF;
				 END IF;


			   END IF;   --source type and needed_item_qty







	     END LOOP;
    Close c_config_and_ato_items;

  END IF;

 EXCEPTION

    when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
              --Bugfix 8913125
	      x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

              IF PG_DEBUG <> 0 THEN
             	 oe_debug_pub.add('get_child_configurations: ' || 'CTOSUBSB.get_child_configurations expected excpn: ' || x_error_message,1);
              END IF;


    when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             --Bugfix 8913125
	     x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('get_child_configurations: ' || 'CTOSUBSB.get_child_configurations UN expected excpn: ' || x_error_message,1);
             END IF;


   when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           --Bugfix 8913125
	   x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('get_child_configurations: ' || 'CTOSUBSB.get_child_configurations OTHERS excpn: ' || x_error_message,1);
           END IF;


          /* OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'get_working_day'
                        ); */

END get_child_configurations;


 /*

   API to create flow scheudle for sub_assemblies

 */
Procedure create_flow_subassembly
(
  pflow_sch_details in out nocopy t_flow_sch_details,
  pIndex        in number,
  pitems_table  in  t_item_details,
  pShip_org     in number,
  pProject_id   in number,
  pTask_id      in number,
  x_return_status         out  NOCOPY varchar2,
  x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
 x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */

)

IS

  l_flow_schedule_rec       mrp_flow_schedule_pub.flow_schedule_rec_type;
  l_x_flow_schedule_rec     mrp_flow_schedule_pub.flow_schedule_rec_type;
  l_x_flow_schedule_val_rec mrp_flow_schedule_pub.flow_schedule_val_rec_type;
   l_return_status           varchar2(1);
   l_msg_count               number;
   l_msg_data                varchar2(240);

   l_flow_index number := null;

   l_stmt_num number := 0;
   l_x_value varchar2(1);

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_flow_schedule_rec.operation := MRP_GLOBALS.G_OPR_CREATE;
   l_flow_schedule_rec.scheduled_flag := 1;

	 l_flow_schedule_rec.primary_item_id := pitems_table(pIndex).item_id;
	 l_flow_schedule_rec.line_id := pitems_table(pIndex).line_id ;
	 l_flow_schedule_rec.planned_quantity := pitems_table(pIndex).needed_item_qty ; --may need to chnaged the aty either primary uom qty or ordered aty
	 l_flow_schedule_rec.organization_id :=  pShip_org;
	 l_flow_schedule_rec.scheduled_completion_date := pitems_table(pIndex).job_completion_date;

	 --bugfix 3418102
	 IF pitems_table(pIndex).pegging_flag IN ('I','X') THEN --project and task id can be passed to child item
		l_flow_schedule_rec.project_id := pProject_id;
		l_flow_schedule_rec.task_id :=  pTask_id;
         END IF;

        l_stmt_num := 90;
        MRP_Flow_Schedule_PUB.Process_Flow_Schedule(
				 p_api_version_number => 1.0,
				 p_init_msg_list      => FND_API.G_TRUE,
				x_return_status      => l_return_status,
				 x_msg_count          => l_msg_count,
				x_msg_data           => l_msg_data,
				p_flow_schedule_rec => l_flow_schedule_rec,
				x_flow_schedule_rec => l_x_flow_schedule_rec,
				 x_flow_schedule_val_rec => l_x_flow_schedule_val_rec
			);




	        	if (l_return_status = FND_API.G_RET_STS_ERROR) then --flow return status
				 IF PG_DEBUG <> 0 THEN
				 	oe_debug_pub.add('create_flow_subassembly: ' || 'Expected error in Process Flow Schedule with status: ' || l_return_status, 1);
				 END IF;
				raise FND_API.G_EXC_ERROR;

			elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then --flow returns tatus
				 IF PG_DEBUG <> 0 THEN
				 	oe_debug_pub.add('create_flow_subassembly: ' || 'UnExpected error in Process Flow Schedule with status: ' || l_return_status, 1);
				 END IF;
				 raise FND_API.G_EXC_UNEXPECTED_ERROR;

			else --flow return status
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('create_flow_subassembly: ' || 'Success in Process Flow Schedule.');
				END IF;
				if (l_x_flow_schedule_rec.wip_entity_id is not NULL) then
				   l_stmt_num := 100;
				   IF (pflow_sch_details.count = 0 ) THEN
				        l_flow_index := 1;

				   ELSE
				        l_flow_index := pflow_sch_details.last+1;

				   END IF;

					pflow_sch_details(l_flow_index).t_item_details_index		:= pIndex;
				      	pflow_sch_details(l_flow_index).schedule_number			:=  l_x_flow_schedule_rec.schedule_number;
					pflow_sch_details(l_flow_index).wip_entity_id   		:=  l_x_flow_schedule_rec.wip_entity_id;
					pflow_sch_details(l_flow_index).scheduled_start_date		:=  l_x_flow_schedule_rec.scheduled_start_date;
					pflow_sch_details(l_flow_index).planned_quantity		:=  l_x_flow_schedule_rec.planned_quantity;
					pflow_sch_details(l_flow_index).scheduled_completion_date	:=  l_x_flow_schedule_rec.scheduled_completion_date;
					pflow_sch_details(l_flow_index).build_sequence			:=  l_x_flow_schedule_rec.build_sequence;
					pflow_sch_details(l_flow_index).line_id 			:=  l_x_flow_schedule_rec.line_id ;




				   l_stmt_num := 120;
				   INSERT INTO BOM_CTO_MLSUPPLY_FLOW_TEMP
					(	order_line_id,
						item_index,
						schedule_number,
						wip_entity_id,
						scheduled_start_date ,
						planned_quantity ,
						scheduled_completion_date,
						build_sequence,
						line_id
					)
				 VALUES(	pitems_table(pIndex).order_line_id,
						pflow_sch_details(l_flow_index).t_item_details_index,                      --current child item index
						pflow_sch_details(l_flow_index).schedule_number,
						pflow_sch_details(l_flow_index).wip_entity_id,
						pflow_sch_details(l_flow_index).scheduled_start_date,
						pflow_sch_details(l_flow_index).planned_quantity,
						pflow_sch_details(l_flow_index).scheduled_completion_date,
						pflow_sch_details(l_flow_index).build_sequence,
						pflow_sch_details(l_flow_index).line_id
					);



				        IF PG_DEBUG <> 0 Then
                                 cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','after process flow schedule');
				 cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','ietm index'|| pflow_sch_details(1).t_item_details_index);
				 cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','item_id '||l_x_flow_schedule_rec.primary_item_id );
				 cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','scheudle_number'|| pflow_sch_details(1).schedule_number);
				 cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','wipentity id'|| pflow_sch_details(1).wip_entity_id);
				  cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','schedule start date'||pflow_sch_details(1).scheduled_start_date );
				   cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','planned qty'|| pflow_sch_details(1).planned_quantity);
				    cto_wip_workflow_api_pk.cto_debug('create_flow_subassembly','scheudle_completion_date'|| pflow_sch_details(1).scheduled_completion_date);

				End if;





					 IF PG_DEBUG <> 0 THEN
					 	oe_debug_pub.add('create_flow_subassembly: ' || 'alternate_bom_designator : ' ||l_x_flow_schedule_rec.alternate_bom_designator  ,1);

					 	oe_debug_pub.add('create_flow_subassembly: ' || 'alternate_routing_desig ' ||l_x_flow_schedule_rec.alternate_routing_desig ,1);

						oe_debug_pub.add('create_flow_subassembly: ' || 'bom_revision ' ||l_x_flow_schedule_rec.bom_revision,1);

					 	oe_debug_pub.add('create_flow_subassembly: ' || 'bom_revision_date ' ||l_x_flow_schedule_rec.bom_revision_date ,1);

						oe_debug_pub.add('create_flow_subassembly: ' || 'build_sequence ' ||l_x_flow_schedule_rec.build_sequence ,1);

					 	oe_debug_pub.add('create_flow_subassembly: ' || 'class_code' ||l_x_flow_schedule_rec.class_code ,1);

				  	oe_debug_pub.add('create_flow_subassembly: ' || 'completion_locator_id ' ||l_x_flow_schedule_rec.completion_locator_id  ,1);

				 	oe_debug_pub.add('create_flow_subassembly: ' || 'completion_subinventory ' ||l_x_flow_schedule_rec.completion_subinventory ,1);

					 	oe_debug_pub.add('create_flow_subassembly: ' || 'demand_class' ||l_x_flow_schedule_rec.demand_class ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'demand_source_delivery' ||l_x_flow_schedule_rec.demand_source_delivery ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'demand_source_header_id ' ||l_x_flow_schedule_rec.demand_source_header_id ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'line_id' ||l_x_flow_schedule_rec.line_id ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'organization_id ' ||l_x_flow_schedule_rec.organization_id  ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'planned_quantity' ||l_x_flow_schedule_rec.planned_quantity  ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'primary_item_id  ' ||l_x_flow_schedule_rec.primary_item_id ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'project_id ' ||l_x_flow_schedule_rec.project_id ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'quantity_completed ' ||l_x_flow_schedule_rec.quantity_completed ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'scheduled_completion_date ' ||l_x_flow_schedule_rec.scheduled_completion_date ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'scheduled_flag  ' ||l_x_flow_schedule_rec.scheduled_flag ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'scheduled_start_date' ||l_x_flow_schedule_rec.scheduled_start_date ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'task_id  ' ||l_x_flow_schedule_rec.task_id ,1);

				   	oe_debug_pub.add('create_flow_subassembly: ' || 'wip_entity_id ' ||l_x_flow_schedule_rec.wip_entity_id ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'scheduled_by' ||l_x_flow_schedule_rec.scheduled_by,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'operation ' ||l_x_flow_schedule_rec.operation,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'db_flag ' ||l_x_flow_schedule_rec.db_flag ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'quantity_scrapped ' ||l_x_flow_schedule_rec.quantity_scrapped ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'synch_schedule_num' ||l_x_flow_schedule_rec.synch_schedule_num ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'synch_operation_seq_num ' ||l_x_flow_schedule_rec.synch_operation_seq_num ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'roll_forwarded_flag ' ||l_x_flow_schedule_rec.roll_forwarded_flag ,1);

			   	oe_debug_pub.add('create_flow_subassembly: ' || 'current_line_operation  ' ||l_x_flow_schedule_rec.current_line_operation ,1);





			   END IF;



			   end if;
		    end if; --flow return status

EXCEPTION

    when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message := 'CTOSUBSB.create_flow_subassembly expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);


             IF PG_DEBUG <> 0 THEN
             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('create_flow_subassembly: ' || 'CTOSUBSB.create_flow_subassembly expected excpn:  ' || x_error_message,1);
             	END IF;
             END IF;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_error_message := 'CTOSUBSB.create_flow_subassembly UN expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);


             IF PG_DEBUG <> 0 THEN
             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('create_flow_subassembly: ' || 'CTOSUBSB.create_flow_subassembly UN expected excpn:  ' || x_error_message,1);
             	END IF;
             END IF;



   when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOSUBSB.create_flow_subassembly OTHERS excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);

           IF PG_DEBUG <> 0 THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('create_flow_subassembly: ' || 'CTOSUBSB.create_flow_subassembly OTHERS excpn:  ' || x_error_message,1);
           	END IF;
           END IF;




END  create_flow_subassembly;

    /*
Procedure get_mlsupply_details

*/

Procedure get_mlsupply_details(
				x_return_status         out  NOCOPY varchar2,
				x_error_message         out  NOCOPY VARCHAR2,
				x_message_name          out  NOCOPY VARCHAR2 )
is


l_order_line_id number;
l_order_number  number;

l_item_index     number;
l_parent_index   number;
l_item_id        number;
l_item_name      varchar2(40);
l_item_quantity  number;
l_needed_item_qty number;
l_auto_config_flag varchar2(1);
l_job_st_date      date ;
l_job_completion_date date;
l_source_type         number;
l_cfm_routing_flag    number;
l_comments            varchar2(200);

l_sourced varchar2(1);
l_supply_type varchar2(100);
l_config_ato  varchar2(10);


--l_item_index   number;
l_schedule_number varchar2(30);
l_scheduled_start_date  date;
l_scheduled_completion_date  date;
l_synch_schedule_num varchar2(30);
l_run_req_import_flag varchar2(1) := 'N';

CURSOR  c_order_details IS
Select distinct(bcmm.order_line_id),oeh.order_number
from bom_cto_mlsupply_main_temp bcmm,
     oe_order_lines_all oel,
     oe_order_headers_all oeh
where    bcmm.order_line_id = oel.line_id
and	  oel.header_id =  oeh.header_id
order by  oeh.order_number, bcmm.order_line_id;

Cursor c_supply_details is
SELECT item_index,
       parent_index,
       ITEM_ID,
       item_name,
       ITEM_QUANTITY,
       NEEDED_ITEM_QTY,
       AUTO_CONFIG_FLAG,
       JOB_START_DATE,
       JOB_COMPLETION_DATE,
       SOURCE_TYPE,
       CFM_ROUTING_FLAG,
       comments
 FROM  bom_cto_mlsupply_main_temp
 WHERE order_line_id = l_order_line_id
 order by item_index;



 Cursor c_flow_supply IS
 SELECT item_index,
	schedule_number,
	scheduled_start_date,
	scheduled_completion_date,
	synch_schedule_num
 FROM bom_cto_mlsupply_flow_temp
 WHERE order_line_id = l_order_line_id
 order by item_index,scheduled_completion_date,schedule_number;



BEGIN


   OPEN c_order_details;

   LOOP

     FETCH c_order_details INTO l_order_line_id,l_order_number ;


      EXIT when c_order_details%notfound;

       If PG_DEBUG <> 0 Then
       oe_debug_pub.add('   SUPPLY FOR ORDER NUMBER = ' || l_order_number || 'LINE_ID = ' || l_order_line_id ,1);
       oe_debug_pub.add('-----------------------------------------------------------------------------------------',1);

       --CTO DEBUG FILE
       cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details','   SUPPLY FOR ORDER NUMBER = ' || l_order_number || 'LINE_ID = ' || l_order_line_id );
       cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details','-----------------------------------------------------------------------------------------');


       oe_debug_pub.add('INDEX--'||'PARENT_INDEX--'||'ITEM_ID--'||'ITEM_NAME--'||'ITEM_QTY--'||'NEEDED_ITEM_QTY--'||
                       'CONFIG/ATO--'||'JOB_START_DATE--'||'JOB_COMPLETION_DATE--'||'SOURCED--'||'DISCREATE/FLOW/BUY--'||'COMMENTS',1);


       cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details','INDEX--'||'PARENT_INDEX--'||'ITEM_ID--'||'ITEM_NAME--'||'ITEM_QTY--'||'NEEDED_ITEM_QTY--'||
								 'CONFIG/ATO--'||'JOB_START_DATE--'||'JOB_COMPLETION_DATE--'||'SOURCED--'||'DISCREATE/FLOW/BUY--'
								 ||'COMMENTS');
       End if;
       OPEN c_supply_details;

       LOOP

	    FETCH c_supply_details INTO l_item_index,
					l_parent_index,
					l_item_id,
					l_item_name,
					l_item_quantity,
					l_needed_item_qty,
					l_auto_config_flag,
					l_job_st_date,
					l_job_completion_date,
					l_source_type,
					l_cfm_routing_flag,
					l_comments;

		EXIT when c_supply_details%notfound;


	    IF l_auto_config_flag = 'Y' THEN
		l_config_ato := 'CONFIG';
	    ELSE
	        l_config_ato := 'ATO ITEM';
	    END IF;


            -- transfer =1 , 66 = multiple sources
            -- rkaza. 05/02/2005. ireq project.
            -- Need to recommend running req import for 100% transfer cases
            -- also in addition to buy cases. Yet mark them as sourced.

	    IF l_source_type = 1 THEN
              l_sourced := 'Y';
              l_supply_type := '100% Transfer';
              IF l_run_req_import_flag = 'N' THEN
      		 l_run_req_import_flag := 'Y' ;
	      END IF;

	    ELSIF l_source_type = 66 then
	      l_sourced := 'Y';
	      l_supply_type := 'Planning';

	    ELSIF l_source_type = 3 THEN
	      l_sourced := 'N';
	      l_supply_type := 'BUY';
	      IF l_run_req_import_flag = 'N' THEN
		l_run_req_import_flag := 'Y' ;
	      END IF;

	    ELSE
		IF l_cfm_routing_flag = 2  THEN
			l_sourced := 'N';
			l_supply_type := 'Discrete';
		ELSIF l_cfm_routing_flag = -99 THEN
		       l_sourced := 'N';
		       l_supply_type := 'No routing Default to discrete';

		ELSE
			 l_sourced := 'N';
			 l_supply_type := 'FLOW';

		END IF; --cfm flag

	     END IF;--source type

             If PG_DEBUG <> 0 Then
                oe_debug_pub.add(l_item_index||' -- '||l_parent_index||' -- '||l_item_id||' -- '||l_item_name||' -- '||l_item_quantity||' -- '||
		                  l_needed_item_qty||'  -- '||l_config_ato||' -- '||to_char(l_job_st_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||
				  to_char(l_job_completion_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||l_sourced||' --'||l_supply_type||' -- '||l_comments,1);


		cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details',l_item_index||' -- '||l_parent_index||' -- '||l_item_id||' -- '||l_item_name||' -- '||
									  l_item_quantity||' -- '||l_needed_item_qty||'  -- '||l_config_ato||' -- '||
								to_char(l_job_st_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||to_char(l_job_completion_date,'mm/dd/yyyy hh24:mi:ss')||
									  ' -- '||l_sourced||' --'||l_supply_type||' -- '||l_comments );

       End if;
	END LOOP;
	CLOSE c_supply_details;

     OPEN c_flow_supply;
       If PG_DEBUG <> 0 Then
       oe_debug_pub.add('INDEX(from above)--'||'SCHEDULE_NUMBER--'||'SCHEDULE_START_DATE--'||'SCHEDULE_COMPLETION_DATE--'||'PARENT_SCHEDULE_NUM(if flow parent)',1);

       cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details','INDEX(from above)--'||'SCHEDULE_NUMBER--'||'SCHEDULE_START_DATE--'||'SCHEDULE_COMPLETION_DATE--'||'PARENT_SCHEDULE_NUM(if flow parent)');

      End if;
       LOOP
           FETCH c_flow_supply into      l_item_index,
					 l_schedule_number,
					l_scheduled_start_date,
					l_scheduled_completion_date,
					l_synch_schedule_num;

		EXIT when c_flow_supply%notfound;
           If PG_DEBUG <> 0 Then
           oe_debug_pub.add(l_item_index||' -- '||l_schedule_number||' -- '||to_char(l_scheduled_start_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||
				to_char(l_scheduled_completion_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||l_synch_schedule_num,1);


	   cto_wip_workflow_api_pk.cto_debug ('get_mlsupply_details',l_item_index||' -- '||l_schedule_number||' -- '||
	                                       to_char(l_scheduled_start_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||
					       to_char(l_scheduled_completion_date,'mm/dd/yyyy hh24:mi:ss')||' -- '||l_synch_schedule_num );

          End if;

       END LOOP;

       CLOSE c_flow_supply;



 END LOOP;

CLOSE c_order_details;

IF l_run_req_import_flag = 'Y' THEN
   --bugfix 2755695
   oe_debug_pub.add('SUB-ASSEMBLY(S) WITH BUY or TRANSFER SOURCING RULE EXIST(S) , PLEASE RUN REQUISITION IMPORT PROGRAM WITH IMPORT SOURCE => CTO-LOWER LEVEL ',1 );
END IF;




END get_mlsupply_details;



/*
 p_top_assembly_type    1= if called from discrete code
                        2= if called from flow code
insert into wip for child discrete make --but wip mass load called with differnet sequenece
insert into child buy




*/


Procedure create_subassembly_jobs
          (

	       p_mlsupply_parameter     in number,   --org parameter indicating whether auto-created or ( AtOITEM and autocreated) 1= autocreated and 2 =
               p_Top_Assembly_LineId	in number,
	       pSupplyQty		in number,
               p_wip_seq               in   number,
               p_status_type           in  number,
               p_class_code            in  varchar2,
               p_conc_request_id       IN  NUMBER,
               p_conc_program_id       IN  NUMBER,
               p_conc_login_id         IN  NUMBER,
               p_user_id               IN  NUMBER,
               p_appl_conc_program_id  IN  NUMBER,
               x_return_status         out  NOCOPY varchar2,
	       x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
	       x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */
          )
is

  l_finite_scheduler_flag number := null;

  l_parent_start_date DATE ;
  l_child_item_id  NUMBER :=0 ;
  l_child_qty Number :=0;

  l_item_id             mtl_system_items_kfv.inventory_item_id%type;
  l_ship_org            mtl_system_items_kfv.organization_id%type;
  l_schedule_ship_date  date ;
  l_item_name		 mtl_system_items_kfv.concatenated_segments%type;
  l_fixed_lead_time      mtl_system_items_kfv.fixed_lead_time%type;
  l_variable_lead_time   mtl_system_items_kfv.variable_lead_time%type;
  l_processing_lead_time mtl_system_items_kfv.full_lead_time%type;
  l_ordered_uom          varchar2(3) := null;
  l_order_number         number := null;
  l_cfm_routing_flag     number := null;
  l_ordered_quantity     number := null;
  l_routing_sequence_id  number := null;
  l_lead_time		 number := null;
  L_OPERATION_SEQ_ID     number :=  null;
  l_auto_config_flag     varchar2(1);

  l_min_completion_date  date;

  l_child_operation_date date;
  X_CHILD_COMPLETION_DATE date;


  l_project_id number := null;
  l_task_id number := null;
  L_X_RETURN_STATUS varchar2(1) ;
   l_x_msg_count               number;
   l_x_msg_data                varchar2(240);
   l_stmt_num number := 0;

  x_groupID Number;

  l_requestId Number;
  x_retVal varchar2(100);
  x_errMsg varchar2(100);

 x_completion_date  DATE;
 x_parent_job_start_date DATE ;

  --table of records to hold the item details
  l_mlsupply_items t_item_details;

  l_flow_sch_details t_flow_sch_details;




 l_index number;
 flow_index number ;
 errbuf varchar2(10);
   retcode number;
   max_completion_date date;


   l_return_status           varchar2(1);
   l_msg_count               number;
   l_msg_data                varchar2(240);
  -- l_stmt_num                number := 0;

   l_ret_status       varchar2(1);
   l_error_messsage    varchar2(70) := null;
   l_msg_name         varchar2(30) := null;

 v_time1 number;
 v_time2 number;



   CURSOR c_flow_sch IS
   SELECT  wfs.schedule_number,
	  wfs.wip_entity_id,
	  wfs.scheduled_start_date,
	  wfs.planned_quantity,
	  wfs.scheduled_completion_date,
	  wfs.build_sequence,
	  wfs.line_id,
          wil.line_code
   FROM  wip_flow_schedules wfs,
         wip_lines wil
   WHERE demand_source_line = p_Top_Assembly_LineId
   AND   wfs.line_id = wil.line_id;


   l_discrete_under_flow varchar2(1) := 'N'; --will become Y if there is a discrete under top most flow parent
   l_sub_level_buy_item varchar2(1) := 'N';
   l_user_id  number ;
   l_login_id number;
   --l_request_id         := FND_GLOBAL.CONC_REQUEST_ID;
   l_program_id number;

   l_token 	      CTO_MSG_PUB.token_tbl;

   -- rkaza. ireq project. 05/05/2005.
   l_req_input_data       CTO_AUTO_PROCURE_PK.req_interface_input_data;

   l_phantom varchar2(1);
   cnt_wjsi  number;  --Bugfix 8913125

BEGIN

            x_return_status := FND_API.G_RET_STS_SUCCESS ;


           If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('Create_sub_assembly_jobs','Inside create sub-assembly jobs');
	    cto_wip_workflow_api_pk.cto_debug('Create_sub_assembly_jobs','FOR LINE ID '||p_Top_Assembly_LineId );
          End if;

	     l_stmt_num := 140;

	     SELECT oel.inventory_item_id,
		    oel.ship_from_org_id,
		     oel.schedule_ship_date,
		     oel. project_id,
		     oel.task_id,
		     oel.ordered_quantity,
                    mtl.concatenated_segments,
		    mtl.auto_created_config_flag,
	            nvl(mtl.fixed_lead_time,0),
	            nvl(mtl.variable_lead_time,0),
                    nvl(mtl.full_lead_time,0),
		    order_quantity_uom ,
		    oeh.order_number,
		    nvl(bor.cfm_routing_flag,-99),
		    bor.routing_sequence_id
	     INTO	l_item_id,
			l_ship_org,
			l_schedule_ship_date,
			l_project_id,
			l_task_id,
			l_ordered_quantity,
			l_item_name,
			l_auto_config_flag,
			l_fixed_lead_time,
			l_variable_lead_time,
			l_processing_lead_time,
			l_ordered_uom,
			l_order_number,
			l_cfm_routing_flag,
			l_routing_sequence_id
	     FROM  oe_order_lines_all oel,
	           oe_order_headers_all oeh,
	           mtl_system_items_kfv mtl,
		   bom_operational_routings bor
	     WHERE oel.line_id = p_Top_Assembly_LineId
	     AND   oeh.header_id = oel.header_id
	     AND   oel.inventory_item_id =  mtl.inventory_item_id
	     AND   oel.ship_from_org_id = mtl.organization_id
	     AND   bor.assembly_item_id (+)= mtl.inventory_item_id
	     AND   bor.organization_id(+) =  mtl.organization_id
	     AND   bor.alternate_routing_designator(+) is null
	     ;

             IF (l_mlsupply_items.count = 0) THEN  --adding topmoset parent details
		l_mlsupply_items(1).item_id     := p_Top_Assembly_LineId;
		l_mlsupply_items(1).item_id     := l_item_id;
                l_mlsupply_items(1).item_name   := l_item_name;
		IF ( pSupplyQty is null) THEN
			l_mlsupply_items(1).item_quantity :=  l_ordered_quantity;
			l_mlsupply_items(1).needed_item_qty := l_ordered_quantity;  --top most parent needed qty = supply quantity
		ELSE
		  l_mlsupply_items(1).item_quantity :=  pSupplyQty;
		  l_mlsupply_items(1).needed_item_qty := pSupplyQty;  --top most parent needed qty = supply quantity

		END IF;
             --   l_mlsupply_items(1).operation_lead_time_percent := 0;
		l_mlsupply_items(1).cfm_routing_flag := l_cfm_routing_flag;
		l_mlsupply_items(1).routing_sequence_id := l_routing_sequence_id;
		l_mlsupply_items(1).fixed_lead_time := l_fixed_lead_time;
		l_mlsupply_items(1).variable_lead_time := l_variable_lead_time;
                l_mlsupply_items(1).processing_lead_time := l_processing_lead_time;
		l_mlsupply_items(1).job_completion_date := l_schedule_ship_date;

	        If PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('Create_sub_assembly_jobs','Entered top-most item details into table');
                End if;

		IF(l_cfm_routing_flag = 1) THEN --if top most parent = flow


		     l_stmt_num := 160;
		     flow_index := 1;
                     OPEN c_flow_sch;
                     LOOP

					FETCH c_flow_sch INTO l_flow_sch_details(flow_index).schedule_number,
								l_flow_sch_details(flow_index).wip_entity_id,
							 l_flow_sch_details(flow_index).scheduled_start_date,
					  l_flow_sch_details(flow_index).planned_quantity ,
		                          l_flow_sch_details(flow_index).scheduled_completion_date,
		                          l_flow_sch_details(flow_index).build_sequence,
		                          l_flow_sch_details(flow_index).line_id,
					  l_flow_sch_details(flow_index).line_code;


		 			 EXIT when c_flow_sch%notfound;

					 oe_debug_pub.add('create_subassembly_supply'||'top most flow parent schdeule number' || l_flow_sch_details(flow_index).schedule_number);



					 IF (flow_index = 1 ) THEN
                                            l_mlsupply_items(1).flow_start_index := 1;
					    l_mlsupply_items(1).line_id :=  l_flow_sch_details(flow_index).line_id;
					   l_mlsupply_items(1).line_code :=  l_flow_sch_details(flow_index).line_code;
					   l_mlsupply_items(1).feeder_run := 'N';
					 END IF;
					 l_flow_sch_details(flow_index).t_item_details_index := 1;
					 flow_index := l_flow_sch_details.last+1;


		    END LOOP;

		    IF (l_mlsupply_items(1).flow_start_index = 1) THEN  --which means there was a row inserted
                         l_mlsupply_items(1).flow_end_index :=  l_flow_sch_details.last;


			 l_stmt_num := 170;
			 INSERT INTO BOM_CTO_MLSUPPLY_FLOW_TEMP
					(	order_line_id,
						item_index,
						schedule_number,
						wip_entity_id,
						scheduled_start_date ,
						planned_quantity ,
						scheduled_completion_date,
						build_sequence,
						line_id,
						synch_schedule_num,
						SYNCH_OPERATION_SEQ_NUM )
					SELECT
						p_Top_Assembly_LineId,
					        1	,
						schedule_number,
						wip_entity_id,
						scheduled_start_date ,
						planned_quantity ,
						scheduled_completion_date,
						build_sequence,
						line_id,
						synch_schedule_num,
						SYNCH_OPERATION_SEQ_NUM
					FROM wip_flow_schedules
					where demand_source_line = p_Top_Assembly_LineId;

		    END IF;

		    CLOSE c_flow_sch;




		END IF;  --if top most paernt is flow




		 --Insert for top most parent into BOM_CTO_MLSUPPLY_MAIN_TEMP table
		 l_stmt_num := 180;

		INSERT INTO BOM_CTO_MLSUPPLY_MAIN_TEMP
			(	order_line_id,
			        item_index ,
				 item_id,
				item_name,
				AUTO_CONFIG_FLAG,
				item_quantity,
				needed_item_qty ,
				cfm_routing_flag ,
				routing_sequence_id ,
				 fixed_lead_time,
				variable_lead_time ,
				processing_lead_time ,
				job_completion_date,
				line_id,
				line_code,
				flow_start_index,
				flow_end_index
			)
		VALUES	(	p_Top_Assembly_LineId,
				1,                      --as it is first elemnt
				l_item_id,
				l_item_name	,
				l_auto_config_flag,
				l_mlsupply_items(1).item_quantity,
				l_mlsupply_items(1).needed_item_qty ,
				l_cfm_routing_flag ,
				l_routing_sequence_id ,
				l_fixed_lead_time,
				l_variable_lead_time ,
				l_processing_lead_time ,
				l_schedule_ship_date,
				l_mlsupply_items(1).line_id,
				l_mlsupply_items(1).line_code,
				l_mlsupply_items(1).flow_start_index,
				l_mlsupply_items(1).flow_end_index



			)  ;






	     END IF; --top most parent details

	    l_stmt_num := 190;
            If PG_DEBUG <> 0 Then
		cto_wip_workflow_api_pk.cto_debug('Create_sub_assembly_jobs','Before calling get_child_configurations' );
		oe_debug_pub.add ('create_subassembly_jobs: ' || 'Before calling get_child_configurations',1);
            End if;
            get_child_configurations
            (
	        pParentItemId		=>l_mlsupply_items(1).item_id,
		pOrganization_id 	=>l_ship_org,
		pLower_Supplytype	=>p_mlsupply_parameter,  -- lower level supply type
		pParent_index		=>1,--parent index passed as one
                pitems_table  		=>l_mlsupply_items,
		x_return_status	=>  l_ret_status,
		x_error_message  	=>  l_error_messsage,
		x_message_name   	=>   l_msg_name

              );
	      l_stmt_num := 19100;

	      IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to get_child_configurations with status ' || l_return_status ,1);

				oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
			END IF;
			RAISE FND_API.G_EXC_ERROR;
	       ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_child_configurations ' || l_return_status ,1);

				oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
			END IF;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSE
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_child_configurations ' ,1);
			END IF;
	      END IF;
	      l_stmt_num := 19101;

	     IF (l_mlsupply_items.count = 1) THEN
	        x_error_message := 'NO children present at level ' || p_mlsupply_parameter ;
		RETURN;


	     END IF;
	     l_stmt_num := 19102;


	     --getting completion date

	      oe_debug_pub.add('Before starting logic of completion date',1);


	     IF (l_mlsupply_items.count > 0) THEN  --checks for uninitialized collection --bugfix2308063

	         l_index := 2;--completion date is needed from 2nd level discrete item
		 l_stmt_num := 19103;
		LOOP

		   oe_debug_pub.add('Looping for item'||l_mlsupply_items(l_index).item_name,1);
		   l_mlsupply_items(l_index).order_line_id := p_Top_Assembly_LineId;

		   --insert data into MAIN table

		 INSERT INTO BOM_CTO_MLSUPPLY_MAIN_TEMP
			(	order_line_id,
			        item_index ,
				PARENT_INDEX,
				 item_id,
				item_name,
				AUTO_CONFIG_FLAG,
				item_quantity,
				needed_item_qty ,
				cfm_routing_flag ,
				routing_sequence_id ,
				 fixed_lead_time,
				variable_lead_time ,
				processing_lead_time ,
				--job_completion_date,
				line_id,
				line_code,
				flow_start_index,
				flow_end_index,
				source_type,
				comments,
				wip_supply_type,
				OPERATION_SEQ_NUM
			)
		  VALUES	( p_Top_Assembly_LineId,
				l_index,
				l_mlsupply_items(l_index).parent_index,
				l_mlsupply_items(l_index).item_id,
				l_mlsupply_items(l_index).item_name,
				l_mlsupply_items(l_index).auto_config_flag,
				l_mlsupply_items(l_index).item_quantity,
				l_mlsupply_items(l_index).needed_item_qty ,
				l_mlsupply_items(l_index).cfm_routing_flag,
				l_mlsupply_items(l_index).routing_sequence_id ,
				l_mlsupply_items(l_index).fixed_lead_time,
				l_mlsupply_items(l_index).variable_lead_time ,
				l_mlsupply_items(l_index).processing_lead_time ,
				--l_schedule_ship_date,
				l_mlsupply_items(l_index).line_id,
				l_mlsupply_items(l_index).line_code,
				l_mlsupply_items(l_index).flow_start_index,
				l_mlsupply_items(l_index).flow_end_index,
				l_mlsupply_items(l_index).source_type,
				l_mlsupply_items(l_index).comment,
			        l_mlsupply_items(l_index).wip_supply_type, --4645636
				l_mlsupply_items(l_index).operation_seq_num --4645636


			)  ;

	               EXIT WHEN l_index = l_mlsupply_items.LAST;
			l_index := l_mlsupply_items.NEXT(l_index);
		 END LOOP;
	      END IF;

               BEGIN
		select 'Y' INTO l_phantom
		from BOM_CTO_MLSUPPLY_MAIN_TEMP
		where wip_supply_type = 6
		and rownum = 1;
	       Exception
	         when no_data_found then
		   l_phantom := 'N';

	       end;

                 oe_debug_pub.add('Phantom flag'||l_phantom,1);

	       IF l_phantom = 'Y' THEN
                  oe_debug_pub.add('About to call process_phantoms',1);
                 --call process children under phatom
		 process_phantoms
		 (
	           pitems_table=>l_mlsupply_items,
	           p_organization_id =>l_ship_org,
	           x_return_status  => l_ret_status,
	           x_error_message  =>  l_error_messsage,
		   x_message_name   =>   l_msg_name
                  );
	       END IF;

               IF (l_mlsupply_items.count > 0) THEN  --checks for uninitialized collection --bugfix2308063

	         l_index := 2;--completion date is needed from 2nd level discrete item
		LOOP

                   oe_debug_pub.add('Looping again for item'||l_mlsupply_items(l_index).item_name,1);
		   l_mlsupply_items(l_index).order_line_id := p_Top_Assembly_LineId;

		  -- rkaza. ireq project. 05/03/2005.
                  -- Enabling 100% transfer rule supply creation for lower
                  -- level items (source type = 1).

		  IF (	l_mlsupply_items(l_index).source_type in (1,2,3) and
		         l_mlsupply_items(l_index).needed_item_qty >0

			 --4645636 do not cal times for phantom items
                        -- l_mlsupply_items(l_index).wip_supply_type <> 6
			 ) THEN	 --check if item is not sourced

		    IF(	l_mlsupply_items(l_mlsupply_items(l_index).parent_index).cfm_routing_flag =2 OR
		          l_mlsupply_items(l_mlsupply_items(l_index).parent_index).cfm_routing_flag = -99) THEN --parent is discrete
			      --get the value of wip finite scheduler flag if not selected previously
			 IF(l_finite_scheduler_flag is null) THEN

				SELECT nvl(use_finite_scheduler,2)
				INTO l_finite_scheduler_flag
				FROM wip_parameters
				WHERE organization_id =  l_ship_org;

				oe_debug_pub.add ('create_subassembly_jobs: ' || 'l_finite_scheduler_flag is '|| l_finite_scheduler_flag ,1);

			 END IF;--finnite scheduler


		          IF ( l_mlsupply_items(l_index).job_completion_date is null) THEN
				IF (l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date is null) THEN

				        l_stmt_num := 200;
					get_start_date(
				             pCompletion_date =>    l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_completion_date,
				             pQty	      =>   l_mlsupply_items(l_mlsupply_items(l_index).parent_index).needed_item_qty,
                                             pitemid	      =>    l_mlsupply_items(l_mlsupply_items(l_index).parent_index).item_id,
                                             porganization_id =>    l_ship_org,
                                             pfixed_leadtime   =>    l_mlsupply_items(l_mlsupply_items(l_index).parent_index).fixed_lead_time,
					     pvariable_leadtime => l_mlsupply_items(l_mlsupply_items(l_index).parent_index).variable_lead_time,
					      x_start_date     =>  x_parent_job_start_date,
					      x_return_status  => l_ret_status,
					      x_error_message  => l_error_messsage,
					      x_message_name   => l_msg_name
						);


					IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
						IF PG_DEBUG <> 0 THEN
							oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to get_start_date with status ' || l_return_status ,1);

							oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						IF PG_DEBUG <> 0 THEN
							oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_start_date ' || l_return_status ,1);

							oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage,1);
						END IF;
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSE
			 			IF PG_DEBUG <> 0 THEN
			 				oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_start_date ' ,1);
			 			END IF;
					END IF;


					IF ( l_finite_scheduler_flag = 1) THEN
					    IF (x_parent_job_start_date <= SYSDATE) THEN
					       l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date := SYSDATE;

					       --populate start date flag = 1implies insert satrt date in wjsi instead of completion date
					       l_mlsupply_items(l_mlsupply_items(l_index).parent_index).populate_start_date := 1;

					       IF PG_DEBUG <> 0 THEN
			 				oe_debug_pub.add('create_subassembly_jobs: ' || 'actual parent starts date is < sysdate ' ,1);
			 			END IF;

					    ELSE
					      l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date := x_parent_job_start_date;
					      oe_debug_pub.add('create_subassembly_jobs: ' || 'parent_start_date '|| to_char(x_parent_job_start_date,'mm/dd/yy hh24:mi:ss') ,1);

					    END IF;

					ELSE
					  l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date := x_parent_job_start_date;
					  oe_debug_pub.add('create_subassembly_jobs: ' || 'parent_start_date '|| to_char(x_parent_job_start_date,'mm/dd/yy hh:mi:ss') ,1);
					END IF ;




				        --update parent items job start date
					l_stmt_num := 300;
					update bom_cto_mlsupply_main_temp
					set job_start_date =  l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date
					where item_index =  l_mlsupply_items(l_index).parent_index
					and  order_line_id = p_Top_Assembly_LineId ;



				 END IF;


				   IF ( l_mlsupply_items(l_mlsupply_items(l_index).parent_index).populate_start_date is null) THEN
                                     get_completion_date(

							pParent_job_start_date =>	l_mlsupply_items(l_mlsupply_items(l_index).parent_index).job_start_date,
				                        porganization_id       =>     l_ship_org,
					                plead_time_offset_percent =>    l_mlsupply_items(l_index).OPERATION_LEAD_TIME_PERCENT,
						        pParent_processing_lead_time =>    l_mlsupply_items(l_mlsupply_items(l_index).parent_index).processing_lead_time ,
							ppostprocessing_time =>      l_mlsupply_items(l_index).postprocessing_lead_time ,
							pSource_type =>      l_mlsupply_items(l_index).source_type,
						        x_child_completion_date =>    x_completion_date,
							 x_return_status => l_ret_status,
							 x_error_message => l_error_messsage,
							 x_message_name =>  l_msg_name
							);




				       IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
						IF PG_DEBUG <> 0 THEN
							oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to get-completion_date with status ' || l_return_status ,1);

							oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						IF PG_DEBUG <> 0 THEN
							oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_completion_date ' || l_return_status ,1);

							oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
						END IF;
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSE
			 			IF PG_DEBUG <> 0 THEN
			 				oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_completion_date ' ,1);
							 oe_debug_pub.add('create_subassembly_jobs: ' || 'parent_start_date '|| to_char(x_parent_job_start_date,'mm/dd/yy hh:mi:ss') ,1);
			 			END IF;
					END IF;


				       IF ( l_finite_scheduler_flag = 1) THEN
					    IF (x_completion_date <= SYSDATE) THEN    --sysdate check
					       -- rkaza. 05/03/2005. Added
					       -- source type 1 here.
					       IF (l_mlsupply_items(l_index).source_type in (1,3)) THEN --buy and 100% transfer item
					           l_mlsupply_items(l_index).job_completion_date := SYSDATE;

					       ELSE --make(discrete/flow)
					           l_mlsupply_items(l_index).populate_start_date := 1; 	-- to insert wip inetrface with satrt date

						   l_mlsupply_items(l_index).job_completion_date := SYSDATE;
						   l_mlsupply_items(l_index).job_start_date := SYSDATE;
					       END IF; --buy item



					    ELSE   --not sysdate
					     l_mlsupply_items(l_index).job_completion_date :=   x_completion_date;

					     --if flow is top most item AND
					     --if finite scheduler is on we calculate job start date
					     --as we need to insert both first unit start date as well as last unit completion date
					     --bugfix#2739590

						  -- rkaza. 05/05/2005.
						  -- Following block is only
                                                  -- needed for WIP items.
					          IF(l_mlsupply_items(1).cfm_routing_flag = 1) -- top item is flow
					          and l_mlsupply_items(l_index).source_type = 2
						  and l_mlsupply_items(l_index).cfm_routing_flag <> 1 THEN

							get_start_date(
								pCompletion_date =>   l_mlsupply_items(l_index).job_completion_date,
								 pQty	      =>   l_mlsupply_items(l_index).needed_item_qty,
								 pitemid	      =>   l_mlsupply_items(l_index).item_id,
								porganization_id =>    l_ship_org,
								pfixed_leadtime   =>   l_mlsupply_items(l_index).fixed_lead_time,
								pvariable_leadtime => l_mlsupply_items(l_index).variable_lead_time,
								x_start_date     =>  x_parent_job_start_date,
								 x_return_status  => l_ret_status,
								x_error_message  => l_error_messsage,
								 x_message_name   => l_msg_name
								);

							  IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
									IF PG_DEBUG <> 0 THEN
										oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to get_start_date with status ' || l_return_status ,1);

									     oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
									END IF;
									 RAISE FND_API.G_EXC_ERROR;
							  ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
									IF PG_DEBUG <> 0 THEN
										oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_start_date ' || l_return_status ,1);

										oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage,1);
									END IF;
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
							  ELSE
			 						IF PG_DEBUG <> 0 THEN
			 							oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_start_date ' ,1);
			 						END IF;
							  END IF;

							  IF (x_parent_job_start_date <= SYSDATE) THEN
								 l_mlsupply_items(l_index).job_start_date := SYSDATE;

					       			IF PG_DEBUG <> 0 THEN
			 						oe_debug_pub.add('create_subassembly_jobs: ' || 'actual parent starts date is < sysdate ' ,1);
			 					END IF;

							  ELSE
								l_mlsupply_items(l_index).job_start_date := x_parent_job_start_date;
								oe_debug_pub.add('create_subassembly_jobs: ' || 'parent_start_date '|| to_char(x_parent_job_start_date,'mm/dd/yy hh:mi:ss') ,1);

							  END IF;


                                                   END IF; --top most item is flow



					    END IF;  --sysdate check

					ELSE  --infinite scheduler
					  -- rkaza. 05/05/2005. Added IR also.
                                          IF (x_completion_date <= SYSDATE and l_mlsupply_items(l_index).source_type in (1, 3)) THEN
					          l_mlsupply_items(l_index).job_completion_date := SYSDATE; --2858631
					   ELSE
					       l_mlsupply_items(l_index).job_completion_date :=   x_completion_date;
					   END IF;

					END IF ;

					--original code


				ELSE  --parent date is before sysdate
				  -- rkaza. 05/05/2005. Added IR also.
				  IF (l_mlsupply_items(l_index).source_type in (1, 3) ) THEN --buy and IR item
				       --buy item shoiuld always get created either on sysdate or after sysdate

					           l_mlsupply_items(l_index).job_completion_date := SYSDATE;

			          ELSE --make(discrete/flow)
					           l_mlsupply_items(l_index).populate_start_date := 1; 	-- to insert wip inetrface with satrt date

						   l_mlsupply_items(l_index).job_completion_date := SYSDATE;
						   l_mlsupply_items(l_index).job_start_date := SYSDATE;
			          END IF; --buy item

			       END IF; --  end if parent start date is after sysdate

			       update bom_cto_mlsupply_main_temp
			       set job_completion_date = l_mlsupply_items(l_index).job_completion_date,
			           job_start_date = l_mlsupply_items(l_index).job_start_date              -- could be null value
			       where item_index =  l_index
			       and order_line_id = p_Top_Assembly_LineId ;

		      END IF;	--job completion date

		      IF (l_mlsupply_items(l_index).source_type = 2 ) THEN --make
			IF  ( l_mlsupply_items(l_index).cfm_routing_flag =   1  ) THEN   --flow item

			     --flow schedule creation

			      l_stmt_num := 210;
			      If PG_DEBUG <> 0 Then
			      cto_wip_workflow_api_pk.cto_debug ('create_sub_assembly_jobs','calling create flow  schedule for'|| l_mlsupply_items(l_index).item_id);

				oe_debug_pub.add('create_subassembly_jobs: ' || 'calling create flow  schedule for'|| l_mlsupply_items(l_index).item_id);
			     END IF;

                              create_flow_subassembly (
						       	pflow_sch_details  =>	l_flow_sch_details,
			                                pIndex             =>        l_index,
							pitems_table       =>	l_mlsupply_items,
							pShip_org          =>	l_ship_org,
							pProject_id        =>	l_project_id,
							pTask_id           =>	l_task_id,
							x_return_status    =>   l_ret_status,
							x_error_message    =>  l_error_messsage,
							x_message_name     =>  l_msg_name

			                              );

				IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to create_flow_subassembly with status ' || l_return_status ,1);

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				 ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to create_flow_subassembly ' || l_return_status ,1);

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				  ELSE

					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('create_subassembly_jobs: ' || 'success from create_flow_subassembly ' ,1);
					END IF;
				 END IF;


		        END IF; --end flow schedule creation
		      END IF;  --make
		    ELSE  --parent is flow item


			 oe_debug_pub.add (l_mlsupply_items(l_index).item_name || ' parent is a flow item',1);

			 --  if current item is discrete do not call feeder
			 -- if current item is flow call feeder



			 IF(l_mlsupply_items(l_index).cfm_routing_flag =1 ) THEN -- child is flow

			     oe_debug_pub.add('checking if feeder is run',1);
			     IF ( l_mlsupply_items(l_mlsupply_items(l_index).parent_index).feeder_run <> 'Y' ) THEN
				oe_debug_pub.add('calling feeder line api');

				l_stmt_num := 220;
				SELECT max(scheduled_completion_date)
				into max_completion_date
				from BOM_CTO_MLSUPPLY_FLOW_TEMP
				where item_index = l_mlsupply_items(l_index).parent_index
				and  order_line_id = p_Top_Assembly_LineId ;

				oe_debug_pub.add('aparameters for feeder call');
				oe_debug_pub.add('max schcompletion date'||to_char(max_completion_date,'dd/mm/yy hh:mi:ss') );
				oe_debug_pub.add('LIne code :'||l_mlsupply_items(l_mlsupply_items(l_index).parent_index).line_code );

				--creating child supply on feeder line
				l_stmt_num := 230;
				FLM_CREATE_PRODUCT_SYNCH.create_schedules(
									errbuf,
								        retcode,
									l_ship_org,
									l_mlsupply_items(l_mlsupply_items(l_index).parent_index).line_code,
									l_mlsupply_items(l_mlsupply_items(l_index).parent_index).line_code,
									to_char(SYSDATE-1,'YYYY/MM/DD hh:mm:ss'),
									to_char(max_completion_date,'YYYY/MM/DD hh:mm:ss'),                                                      --to_char(SYSDATE+7,'YYYY/MM/DD hh:mm:ss'),
	                                                                 'N');

				oe_debug_pub.add('After calklling feeder line api',1);

				--set parent feeder run flag to 'Y'
				l_mlsupply_items(l_mlsupply_items(l_index).parent_index).feeder_run := 'Y';

			     END IF ;--parent feeder flag

			     l_stmt_num := 240;
			     INSERT INTO BOM_CTO_MLSUPPLY_FLOW_TEMP  (
			               order_line_id,
			               item_index,
					schedule_number,
					wip_entity_id,
					 scheduled_start_date ,
					planned_quantity ,
					scheduled_completion_date,
					build_sequence,
					line_id,
					synch_schedule_num,
					SYNCH_OPERATION_SEQ_NUM )
				SELECT	p_Top_Assembly_LineId,
					l_index,                      --current child item index
					schedule_number,
					wip_entity_id,
					 scheduled_start_date ,
					planned_quantity ,
					scheduled_completion_date,
					build_sequence,
					line_id,
					synch_schedule_num,
					SYNCH_OPERATION_SEQ_NUM
				FROM wip_flow_schedules
				where primary_item_id = l_mlsupply_items(l_index).item_id
				and synch_schedule_num in
				                         ( Select schedule_number
							    from BOM_CTO_MLSUPPLY_FLOW_TEMP
							    where item_index =  l_mlsupply_items(l_index).parent_index
							    and  order_line_id = p_Top_Assembly_LineId
							   );
			 ELSE--child is wip/buy/IR


			     l_stmt_num := 242;

			     --bugfix 2765109
			     BEGIN
			        Select nvl(line_op_seq_id,-99) --bugfix 2786582
				into l_operation_seq_id
				from bom_operation_sequences
				where routing_sequence_id = l_mlsupply_items(l_mlsupply_items(l_index).parent_index).routing_sequence_id
				and operation_seq_num = l_mlsupply_items(l_index).operation_seq_num
				and operation_type =1
				and nvl(EFFECTIVITY_DATE,sysdate+1) <= SYSDATE
				and nvl(disable_date,sysdate+1) > sysdate;

			     EXCEPTION
			      WHEN no_data_found THEN
				l_operation_seq_id := -99;

			     END;

			     IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'operation seq id is' || l_operation_seq_id ,1);


			     END IF;

                             IF l_operation_seq_id = -99 THEN --bugfix 2765109
			         l_stmt_num := 2421;
                                 SELECT min(scheduled_start_date)
			         into l_child_operation_date
				 from BOM_CTO_MLSUPPLY_FLOW_TEMP
				 where item_index = l_mlsupply_items(l_index).parent_index;

				 IF PG_DEBUG <> 0 THEN

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'operation offsetd date is '|| l_child_operation_date,1);

			         END IF;

			     ELSE

			      IF PG_DEBUG <> 0 THEN

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'before entering get_operation offsetd ate' ,1);

			      END IF;

			      l_stmt_num := 241;
				SELECT min(scheduled_completion_date)
				into l_min_completion_date
				from BOM_CTO_MLSUPPLY_FLOW_TEMP
				where item_index = l_mlsupply_items(l_index).parent_index;

				IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'min schedule date' || to_char(l_min_completion_date,'mm/dd/yy hh:mi:ss') ,1);

				END IF;


			      l_stmt_num := 243;
			      l_child_operation_date := MRP_FLOW_SCHEDULE_PUB.get_operation_offset_date
				  ( p_api_version_number => 1.0,
		                    x_return_status      => l_x_return_status,
				    x_msg_count          => l_x_msg_count,
				    x_msg_data           => l_x_msg_data,
				    p_org_id             => l_ship_org,
				    p_assembly_item_id   => l_mlsupply_items(l_mlsupply_items(l_index).parent_index).item_id,
                                    p_routing_sequence_id => l_mlsupply_items(l_mlsupply_items(l_index).parent_index).routing_sequence_id,
				    p_operation_sequence_id => l_operation_seq_id,
				    p_assembly_qty          => 1,             --? what should this quantity be ,ask adrian
				    p_assembly_comp_date => l_min_completion_date ,
				    p_calculate_option    => 1   --implies for the first unit made
				  );


			     END IF;

			    IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'after get_ioperation offset  date with date' || l_child_operation_date ,1);

			    END IF;

			    l_stmt_num := 244;

			     -- rkaza. 05/05/2005. Added IR here.
			     -- Comp date can be set as child op date for IR.
			     -- No lead time considerations for IR.

			     IF (l_mlsupply_items(l_index).source_type in (1, 3) )     THEN -- buy and IR child item

				l_lead_time := CEIL(l_mlsupply_items(l_index).postprocessing_lead_time + 1); --ie postporcoessing+1day

				x_child_completion_date := l_child_operation_date;

				IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'lead time for buy child is ' || l_lead_time ,1);

				END IF;

				if l_mlsupply_items(l_index).source_type = 3 then
				   l_stmt_num := 250;
				   get_working_day
				   (
				    porgid  => l_ship_org,
				    Pdate   =>  l_child_operation_date,
				    pleadtime  =>l_lead_time,
			            pdirection => 'B',                 --direction in getting working day 'backward' for buy item as here it is always backward
				    x_ret_date => x_child_completion_date,
				    x_return_status => l_ret_status,
				    x_error_message => l_error_messsage,
				    x_message_name => l_msg_name
				    );

				end if;

				 IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after get_wroking_day' || l_return_status ,1);

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
					END IF;
					RAISE FND_API.G_EXC_ERROR;
				 ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_working_day' || l_return_status ,1);

						oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
					END IF;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				  ELSE

					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_working_day ' ,1);
					END IF;
				 END IF;

				 IF (x_child_completion_date <= SYSDATE) THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('create_subassembly_jobs: ' || 'buy or IR job comp date is < than sysdate,so default to sysdate' ,1);
						oe_debug_pub.add('create_subassembly_jobs: ' || 'buy or IR job comp date is ' || x_child_completion_date,1);
					END IF;

				   l_mlsupply_items(l_index).job_completion_date := SYSDATE;

                                 ELSE

				 l_mlsupply_items(l_index).job_completion_date := x_child_completion_date;

				  IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add('create_subassembly_jobs: ' || 'buy or IR job comp date is ' || x_child_completion_date,1);
				   END IF;


				 END IF;

				  update bom_cto_mlsupply_main_temp
		  		  set job_completion_date = l_mlsupply_items(l_index).job_completion_date
	        		  where item_index =  l_index
				  and  order_line_id = p_Top_Assembly_LineId;


			     ELSE --discrete child item

			            --get the value of wip finite scheduler flag if not selected previously when uder flow
				IF(l_finite_scheduler_flag is null) THEN

					SELECT nvl(use_finite_scheduler,2)
					INTO l_finite_scheduler_flag
					FROM wip_parameters
					WHERE organization_id =  l_ship_org;

					oe_debug_pub.add ('create_subassembly_jobs: ' || 'l_finite_scheduler_flag is '|| l_finite_scheduler_flag ,1);

		         	 END IF;--finnite scheduler


			      IF (l_finite_scheduler_flag =1) THEN

			        IF( l_child_operation_date <= SYSDATE) THEN --less than sysdate
						   oe_debug_pub.add('create_subassembly_jobs: ' || 'Finite scheduler ON and DISCRETE  job comp date is <SYSDATE., SO DEFAULT TO SYSDTAE',1);
						   oe_debug_pub.add('create_subassembly_jobs: '|| ' DIS job coompl date is l_child_operation_date',1);
						   l_mlsupply_items(l_index).populate_start_date := 1; 	-- to insert wip inetrface with satrt date

						   l_mlsupply_items(l_index).job_completion_date := SYSDATE;
						   l_mlsupply_items(l_index).job_start_date := SYSDATE;

						    update bom_cto_mlsupply_main_temp
						    set job_completion_date = l_mlsupply_items(l_index).job_completion_date,
							job_start_date = l_mlsupply_items(l_index).job_start_date
						    where item_index =  l_index
						    and  order_line_id = p_Top_Assembly_LineId;

				ELSE-- greater sysdate

					l_mlsupply_items(l_index).job_completion_date := l_child_operation_date;
					oe_debug_pub.add('create_subassembly_jobs: ' || 'DISCRETE  job comp date is '|| l_mlsupply_items(l_index).job_completion_date,1);


					--if flow is top most item AND
					--if finite scheduler is on we calculate job start date
					--as we need to insert both first unit start date as well as last unit completion date
					--bugfix#2739590


                                        IF(l_mlsupply_items(1).cfm_routing_flag = 1) THEN --top most item is flow

					       get_start_date(
						    pCompletion_date =>   l_mlsupply_items(l_index).job_completion_date,
						    pQty	      =>   l_mlsupply_items(l_index).needed_item_qty,
						    pitemid	      =>   l_mlsupply_items(l_index).item_id,
						    porganization_id =>    l_ship_org,
						    pfixed_leadtime   =>   l_mlsupply_items(l_index).fixed_lead_time,
						    pvariable_leadtime => l_mlsupply_items(l_index).variable_lead_time,
						    x_start_date     =>  x_parent_job_start_date,
						    x_return_status  => l_ret_status,
						    x_error_message  => l_error_messsage,
						    x_message_name   => l_msg_name
						    );

					       IF l_ret_status = FND_API.G_RET_STS_ERROR THEN
							  IF PG_DEBUG <> 0 THEN
								oe_debug_pub.add ('create_subassembly_jobs: ' || 'failed after call to get_start_date with status ' || l_return_status ,1);

							        oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage ,1);
							  END IF;
							  RAISE FND_API.G_EXC_ERROR;
						ELSIF l_ret_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
							  IF PG_DEBUG <> 0 THEN
								 oe_debug_pub.add ('create_subassembly_jobs: ' || ' failed after call to get_start_date ' || l_return_status ,1);

								  oe_debug_pub.add ('create_subassembly_jobs: ' || 'error message' || l_error_messsage,1);
							   END IF;
							   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					        ELSE
			 				   IF PG_DEBUG <> 0 THEN
			 					 oe_debug_pub.add('create_subassembly_jobs: ' || 'success from get_start_date ' ,1);
			 				   END IF;
					        END IF;

					       IF (x_parent_job_start_date <= SYSDATE) THEN
						       l_mlsupply_items(l_index).job_start_date := SYSDATE;

					       		IF PG_DEBUG <> 0 THEN
			 				   oe_debug_pub.add('create_subassembly_jobs: ' || 'actual parent starts date is < sysdate ' ,1);
			 				END IF;

					       ELSE
							l_mlsupply_items(l_index).job_start_date := x_parent_job_start_date;
							oe_debug_pub.add('create_subassembly_jobs: ' || 'parent_start_date '|| to_char(x_parent_job_start_date,'mm/dd/yy hh:mi:ss') ,1);

					        END IF;


                                          END IF; --top most item is flow

					 update bom_cto_mlsupply_main_temp
		  			 set job_completion_date = l_mlsupply_items(l_index).job_completion_date,
					     job_start_date = l_mlsupply_items(l_index).job_start_date
	        			 where item_index =  l_index
					 and  order_line_id = p_Top_Assembly_LineId;

				END IF;--sysdate checj
			     ELSE--infinite scheduler


					l_mlsupply_items(l_index).job_completion_date := l_child_operation_date;


					oe_debug_pub.add('create_subassembly_jobs: ' || 'DISCRETE  job comp date is '|| l_mlsupply_items(l_index).job_completion_date,1);

					 update bom_cto_mlsupply_main_temp
		  			 set job_completion_date = l_mlsupply_items(l_index).job_completion_date
	        			 where item_index =  l_index
					 and  order_line_id = p_Top_Assembly_LineId;


			     END IF;--finute scheduler check


			     END IF; -- child is buy or IR/discrete


			 END IF; --child is flow or others


		    END IF ; --parent is WIP or flow

		  END IF;  --check for item sourcing

			 EXIT WHEN l_index = l_mlsupply_items.LAST;
			l_index := l_mlsupply_items.NEXT(l_index);
		 END LOOP;

            END IF;



	 --reomve this part at end of UT
              If PG_DEBUG <> 0 Then
	      oe_debug_pub.add ('DEBUG EMSSAEG AFTER COMPLETION DATE CALCULATION',1);

	      cto_wip_workflow_api_pk.cto_debug('Completion date debug messages','after completion date calculations');
              End if;
	      --displaying children
	      IF (l_mlsupply_items.count > 0) THEN  --checks for uninitialized collection --bugfix2308063

	       oe_debug_pub.add ('index --'||'item_name--' || 'item_quantity--'||'needed_item_quantity--'||'OPERATION_LEAD_TIME_PERCENT--'||
				 'operation_seq_num--'|| 'cfm_routing_flag--'||'routing_sequence_id--'||'fixed_lead_time--'||
				 'variable_lead_time--' || 'processing_lead_time--' || 'postprocessing_lead_time--' ||
				 'bom_item_type --' || 'parent_index--'||'job_start_date --'||'job_completion_date --'||
				 'line_id--' || 'line_code--'||'source_type--' || 'feeder_run--' || 'flow_start_index--' ||
				 'flow_end_index '
				 );

	         l_index := 1;--completion date is needed from 2nd level discrete item
		LOOP
		     oe_debug_pub.add ('idx=>'||l_mlsupply_items(l_index).t_item_details_index || '--' ||
		                      'name=>'||l_mlsupply_items(l_index).item_name||'--' ||
			 	       'qty=>'||l_mlsupply_items(l_index).item_quantity||'--'||
			  	       'qty=>'||l_mlsupply_items(l_index).needed_item_qty||'--'||
			  	       'LT%=>'||l_mlsupply_items(l_index).OPERATION_LEAD_TIME_PERCENT||'--'||
			  	       'opseq=>'||l_mlsupply_items(l_index).operation_seq_num||'--'||
			  	       'cfm=>'||l_mlsupply_items(l_index).cfm_routing_flag||'--'||
			  	       'rout=>'||l_mlsupply_items(l_index).routing_sequence_id||'--'||
			  	       'FLT=>'||l_mlsupply_items(l_index).fixed_lead_time||'--'||
			  	       'VLT=>'||l_mlsupply_items(l_index).variable_lead_time||'--' ||
			  	       'PLT=>'||l_mlsupply_items(l_index).processing_lead_time||'--' ||
					'PPLT=>'||l_mlsupply_items(l_index).postprocessing_lead_time||'--' ||
			  	       'BIT=>'||l_mlsupply_items(l_index).bom_item_type||' --' ||
		 	 	       'PIDX=>'||l_mlsupply_items(l_index).parent_index||'--'||
				       'JSTDT=>'||l_mlsupply_items(l_index).job_start_date||' --'||
				       'JCDT=>'||l_mlsupply_items(l_index).job_completion_date||' --'||
				       'FLINE=>'||l_mlsupply_items(l_index).line_id||'--' ||
				       'FLcode=>'||l_mlsupply_items(l_index).line_code||'--'||
				       'Src=>'||l_mlsupply_items(l_index).source_type||'--' ||
				       'Feed=>'||l_mlsupply_items(l_index).feeder_run||'--' ||
				       'FLOW_ST_IDX=>'||l_mlsupply_items(l_index).flow_start_index||'--' ||
				       'FLOW_END_IDX=>'||l_mlsupply_items(l_index).flow_end_index
				 );

                           If PG_DEBUG <> 0 Then
		           cto_wip_workflow_api_pk.cto_debug ('Create_sub_assembly_jobs','idx=>'||l_mlsupply_items(l_index).t_item_details_index || '--' ||
		                      'name=>'||l_mlsupply_items(l_index).item_name||'--' ||
			 	       'qty=>'||l_mlsupply_items(l_index).item_quantity||'--'||
			  	       'qty=>'||l_mlsupply_items(l_index).needed_item_qty||'--'||
			  	       'LT%=>'||l_mlsupply_items(l_index).OPERATION_LEAD_TIME_PERCENT||'--'||
			  	       'opseq=>'||l_mlsupply_items(l_index).operation_seq_num||'--'||
			  	       'cfm=>'||l_mlsupply_items(l_index).cfm_routing_flag||'--'||
			  	       'rout=>'||l_mlsupply_items(l_index).routing_sequence_id||'--'||
			  	       'FLT=>'||l_mlsupply_items(l_index).fixed_lead_time||'--'||
			  	       'VLT=>'||l_mlsupply_items(l_index).variable_lead_time||'--' ||
			  	       'PLT=>'||l_mlsupply_items(l_index).processing_lead_time||'--' ||
					'PPLT=>'||l_mlsupply_items(l_index).postprocessing_lead_time||'--' ||
			  	       'BIT=>'||l_mlsupply_items(l_index).bom_item_type||' --' ||
		 	 	       'PIDX=>'||l_mlsupply_items(l_index).parent_index||'--'||
				       'JSTDT=>'||l_mlsupply_items(l_index).job_start_date||' --'||
				       'JCDT=>'||l_mlsupply_items(l_index).job_completion_date||' --'||
				       'FLINE=>'||l_mlsupply_items(l_index).line_id||'--' ||
				       'FLcode=>'||l_mlsupply_items(l_index).line_code||'--'||
				       'Src=>'||l_mlsupply_items(l_index).source_type||'--' ||
				       'Feed=>'||l_mlsupply_items(l_index).feeder_run||'--' ||
				       'FLOW_ST_IDX=>'||l_mlsupply_items(l_index).flow_start_index||'--' ||
				       'FLOW_END_IDX=>'||l_mlsupply_items(l_index).flow_end_index
				 );


                           End if;





		 EXIT WHEN l_index = l_mlsupply_items.LAST;
			l_index := l_mlsupply_items.NEXT(l_index);
		 END LOOP;

	      END IF;
	        l_index := null;
	      --removw above part at end of UT





--end of calcultating compeltion date




            IF (l_mlsupply_items.count > 0) THEN  --checks for uninitialized collection

	         l_index := l_mlsupply_items.FIRST;
		 LOOP


		       IF PG_DEBUG <> 0 THEN
		       	oe_debug_pub.add('create_subassembly_jobs: ' || l_index||'-- '||
			                     l_mlsupply_items(l_index).parent_index||'-- '||
			                     l_mlsupply_items(l_index).item_id||' -- '||
                                             l_mlsupply_items(l_index).item_name||' -- '||
					     l_mlsupply_items(l_index).job_start_date||' -- '||
                                             l_mlsupply_items(l_index).job_completion_date||' -- '||
                                             l_mlsupply_items(l_index).fixed_lead_time||' -- '||
                                             l_mlsupply_items(l_index).variable_lead_time||' -- '||
                                             l_mlsupply_items(l_index).processing_lead_time,1);
		       END IF;

			 EXIT WHEN l_index = l_mlsupply_items.LAST;
			l_index := l_mlsupply_items.NEXT(l_index);
		 END LOOP;
	     END IF;


	       IF PG_DEBUG <> 0 THEN
	       	oe_debug_pub.add('create_subassembly_jobs: ' || 'before inserting children in wjsi ',1);
	       END IF;

	     --to test submission of wip concurrent program from PL/SQL

           SAVEPOINT REBUILD;
	     l_index := 2;
             LOOP
		   -- rkaza. ireq project. 05/05/2005. Firing
		   -- populate_req_interface for IR also. Passsing source type
                   -- source org as additional parameters.

	           IF (l_mlsupply_items(l_index).source_type in (1, 3) and
		       l_mlsupply_items(l_index).needed_item_qty >0
                       --4645636
		      and l_mlsupply_items(l_index).wip_supply_type <> 6
		        ) then

		        l_stmt_num := 260;

                        If PG_DEBUG <> 0 Then
			cto_wip_workflow_api_pk.cto_debug ('create_sub_assembly_jobs','insert po_interafce'|| l_mlsupply_items(l_index).item_id);
			cto_wip_workflow_api_pk.cto_debug ('create_sub_assembly_jobs','need by date'|| to_char(l_mlsupply_items(l_index).job_completion_date,'mm/dd/yy/ hh:mi:ss'));
			cto_wip_workflow_api_pk.cto_debug ('create_sub_assembly_jobs','need aty'||l_mlsupply_items(l_index).needed_item_qty);
                        End if;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('create_subassembly_jobs: ' || 'insert po_interafce'|| l_mlsupply_items(l_index).item_id);
				oe_debug_pub.add('create_sub_assembly_jobs insert po_interafce'|| l_mlsupply_items(l_index).item_id);
				oe_debug_pub.add('create_sub_assembly_jobs need by date'|| to_char(l_mlsupply_items(l_index).job_completion_date,'mm/dd/yy/ hh:mi:ss'));
				oe_debug_pub.add('create_sub_assembly_jobs  need aty'||l_mlsupply_items(l_index).needed_item_qty);

			END IF;

                        l_req_input_data.source_type := l_mlsupply_items(l_index).source_type;
                        l_req_input_data.sourcing_org := l_mlsupply_items(l_index).sourcing_org;

			cto_auto_procure_pk.populate_req_interface (
			                p_interface_source_code =>'CTO-LOWER LEVEL',
					p_destination_org_id	=>l_ship_org,
					p_org_id		=>null,
					p_created_by            =>p_user_id, -- created_by
					p_need_by_date		=>l_mlsupply_items(l_index).job_completion_date,
					p_order_quantity	=>l_mlsupply_items(l_index).needed_item_qty,
					p_order_uom		=>l_ordered_uom,
					p_item_id		=>l_mlsupply_items(l_index).item_id,
					p_item_revision		=> null, --so_line.item_revision
					 -- reverted bugfix 3042904 and provided
					 --solution thru fix 3129117
					 p_interface_source_line_id=>p_Top_Assembly_LineId,
					 p_unit_price		=> null, -- req-import decides this price
									 --not so_line.unit_selling_price,
					 p_batch_id		=>null,
					 p_order_number		=>l_order_number,
		     			 p_req_interface_input_data => l_req_input_data,
                                         x_return_status	=>x_return_status );

			--change this varname from x_reaturn status to somethinelse
			IF x_return_status = FND_API.G_RET_STS_ERROR THEN  --po return status
				RAISE FND_API.G_EXC_ERROR;
			ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN --po return status
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSE

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('create_subassembly_jobs: ' || 'Req Insert successful for '|| l_mlsupply_items(l_index).item_id ,1);
				END IF;
				IF ( l_sub_level_buy_item = 'N') THEN
				    l_sub_level_buy_item := 'Y';
				END IF;

			END IF; --PO return status

		 ELSIF (l_mlsupply_items(l_index).source_type = 2
		        and l_mlsupply_items(l_index).needed_item_qty >0
			--4645636
			and l_mlsupply_items(l_index).wip_supply_type<>6
			) THEN --make in this org


		    If(l_mlsupply_items(l_index).cfm_routing_flag = 2 OR
		        l_mlsupply_items(l_index).cfm_routing_flag = -99) THEN -- discrete routing

			 IF PG_DEBUG <> 0 THEN
			 	oe_debug_pub.add('create_subassembly_jobs: ' || 'Status passed into lower level supply code is ' ||  p_status_type);
			 END IF;

			  IF(l_mlsupply_items(1).cfm_routing_flag = 2 OR
			     l_mlsupply_items(1).cfm_routing_flag = -99) THEN --top most parent is discrete

			    l_stmt_num := 280;

			    -- Fixed bug 5346922
			    -- Removed the decode for supply type
			   insert into wip_job_schedule_interface
                    		(last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_id,
				program_application_id,
				program_update_date,
				group_id,
				source_code,
				process_phase,
				process_status,
				organization_id,
				load_type,
				status_type,
                     		last_unit_completion_date,
                     		primary_item_id,
                     		wip_supply_type,
                     		class_code,
                     		firm_planned_flag,
				start_quantity,
				bom_revision_date,
				routing_revision_date,
				project_id,
				task_id,
				due_date,
				bom_revision


				)
         		select SYSDATE,
                		p_user_id,
                		SYSDATE,
                		p_user_id,
                		p_conc_login_id,
                		p_conc_request_id,
                		p_conc_program_id,
                		p_appl_conc_program_id,
                		SYSDATE,
                		 p_wip_seq,
                		'WICDOL',
                		WIP_CONSTANTS.ML_VALIDATION,
                		WIP_CONSTANTS.PENDING,       	-- process_status
                		l_ship_org,        		 -- organization id
                		WIP_CONSTANTS.CREATE_JOB,    	--Load_Type
                                nvl(p_status_type, WIP_CONSTANTS.UNRELEASED),  -- Status_Type
                		l_mlsupply_items(l_index).job_completion_date,      	-- Date Completed
                		l_mlsupply_items(l_index).item_id,       	        --Primary_Item_Id
                		WIP_CONSTANTS.BASED_ON_BOM,  				-- Wip_Supply_Type
                		decode(p_class_code, null, null
                	           , p_class_code),					 --Accouting Class
                		2,                     					 --Firm_Planned_Flag
				l_mlsupply_items(l_index).needed_item_qty,
				trunc(greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
                		    'MI')+1/(60*24), 					  --BOM_Revision_Date
				greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
	                                       						   --Routing_Revision_Date
			         --bugfix 3418102
				decode(l_mlsupply_items(l_index).pegging_flag,'I',l_project_id,'X',l_project_id, null),
                                decode(l_mlsupply_items(l_index).pegging_flag,'I',l_task_id,'X',l_task_id, null),
				--end  bugfix 3418102
				l_mlsupply_items(l_index).job_completion_date,
			        BOM_REVISIONS.get_item_revision_fn
	                		( 'ALL',
	                		  'ALL',
	                		  l_ship_org,
					  l_mlsupply_items(l_index).item_id,
					  (trunc (greatest(nvl(cal.calendar_date,SYSDATE),
					  				SYSDATE),'MI')+1/(60*24) )
					)

			from    bom_calendar_dates cal,
		                mtl_parameters     mp,
		                wip_parameters     wp,
		                mtl_system_items   msi
			where   mp.organization_id = l_ship_org
		        and     wp.organization_id = mp.organization_id
		        and     msi.organization_id = l_ship_org
		        and     msi.inventory_item_id = l_mlsupply_items(l_index).item_id  --inventory item id
		        and     cal.calendar_code = mp.calendar_code
		        and     cal.exception_set_id = mp.calendar_exception_set_id
		        and     cal.seq_num =
				 (select greatest(1, (cal2.prior_seq_num -
	                                       (ceil(nvl(msi.fixed_lead_time,0) +
	                                        nvl(msi.variable_lead_time,0) *
					        l_mlsupply_items(l_index).needed_item_qty			--bugfix 2074290: this is in primary uom
						))))
				  from   bom_calendar_dates cal2
				  where  cal2.calendar_code = mp.calendar_code
				  and    cal2.exception_set_id =
	                                 mp.calendar_exception_set_id
				  and    cal2.calendar_date =
	                                 trunc(l_mlsupply_items(l_index).job_completion_date)
				  );

                    	--Bugfix 8913125
			cnt_wjsi := sql%rowcount;

        		if (cnt_wjsi > 0) then  --Bugfix 8913125: Replaced sql%rowcount with cnt_wjsi
        			IF PG_DEBUG <> 0 THEN
        				oe_debug_pub.add('create_subassembly_jobs: ' || 'Number of Rows Inserted in WJSI for children : ' || to_char(cnt_wjsi));

					oe_debug_pub.add('create_subassembly_jobs: ' || 'GROUP ID Inserted in WJSI for children : ' || x_groupID);
				END IF;
            			x_return_status := FND_API.G_RET_STS_SUCCESS;
        		else
            			x_return_status := FND_API.G_RET_STS_ERROR;
            			cto_msg_pub.cto_message('BOM', 'BOM_ATO_PROCESS_ERROR');

        		end if;

		    ELSIF(l_mlsupply_items(1).cfm_routing_flag = 1
		          and l_mlsupply_items(l_index).needed_item_qty >0

			  --4645636
			  and l_mlsupply_items(l_index).wip_supply_type<>6
			) THEN --top most parent is flow

		         IF (l_discrete_under_flow = 'N') THEN
					l_discrete_under_flow := 'Y';

					--intialize var's to be used in isnerting WJSI table
					l_user_id            := FND_GLOBAL.USER_ID;
					l_login_id           := FND_GLOBAL.LOGIN_ID;
					--l_request_id         := FND_GLOBAL.CONC_REQUEST_ID;
					l_program_id         := FND_GLOBAL.CONC_PROGRAM_ID;

					 select wip_job_schedule_interface_s.nextval
					 into   x_groupID
					 from   dual;


		         END IF;

                            -- Fixed bug 5346922
			    -- Removed the decode for supply type
				l_stmt_num := 280;
			    insert into wip_job_schedule_interface
                    		(last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				request_id,
				program_id,
				program_application_id,
				program_update_date,
				group_id,
				source_code,
				process_phase,
				process_status,
				organization_id,
				load_type,
				status_type,
                     		last_unit_completion_date,
                     		primary_item_id,
                     		wip_supply_type,
                     		class_code,
                     		firm_planned_flag,
				start_quantity,
				bom_revision_date,
				routing_revision_date,
				project_id,
				task_id,
				due_date,
				bom_revision,
				scheduling_method,             --inserted ml_manual inorder to stop finite scheduler run
				first_unit_start_date          --enter first unit start date if finite scheduler is turned on bugfix#2739590

				)
         		select SYSDATE,
                		p_user_id,--l_user_id,
                		SYSDATE,
                		p_user_id,--l_user_id,
                		null, --l_login_id,
                		null,
                		null,--35740,
                		null,--706,
                		SYSDATE,
                		x_groupID,
                		'WICDOL',
                		WIP_CONSTANTS.ML_VALIDATION,
                		WIP_CONSTANTS.PENDING,       	-- process_status
                		l_ship_org,        		 -- organization id
                		WIP_CONSTANTS.CREATE_JOB,    	--Load_Type
                                nvl(p_status_type, WIP_CONSTANTS.UNRELEASED),  -- Status_Type
                		l_mlsupply_items(l_index).job_completion_date,      	-- Date Completed
                		l_mlsupply_items(l_index).item_id,       	        --Primary_Item_Id
                		WIP_CONSTANTS.BASED_ON_BOM,  				-- Wip_Supply_Type
                		decode(p_class_code, null, null
                	           , p_class_code),					 --Accouting Class
                		2,                     					 --Firm_Planned_Flag
				l_mlsupply_items(l_index).needed_item_qty,
				trunc(greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
                		    'MI')+1/(60*24), 					  --BOM_Revision_Date
				greatest(nvl(cal.calendar_date,SYSDATE), SYSDATE),
	                                       						   --Routing_Revision_Date
                                --bugfix 3418102
				decode(l_mlsupply_items(l_index).pegging_flag,'I',l_project_id,'X',l_project_id, null),
                                decode(l_mlsupply_items(l_index).pegging_flag,'I',l_task_id,'X',l_task_id, null),
                                --end bugfix 3418102
				   l_mlsupply_items(l_index).job_completion_date,
			        BOM_REVISIONS.get_item_revision_fn
	                		( 'ALL',
	                		  'ALL',
	                		  l_ship_org,
					  l_mlsupply_items(l_index).item_id,
					  (trunc (greatest(nvl(cal.calendar_date,SYSDATE),
					  				SYSDATE),'MI')+1/(60*24) )
					),
				decode(nvl(wp.use_finite_scheduler,2), 1,
                						WIP_CONSTANTS.ML_MANUAL,
                						null),
				decode(nvl(wp.use_finite_scheduler,2), 1,
                						l_mlsupply_items(l_index).job_start_date,
                						null)
				from    bom_calendar_dates cal,
					  mtl_parameters     mp,
					wip_parameters     wp,
					mtl_system_items   msi
					where   mp.organization_id = l_ship_org
				       and     wp.organization_id = mp.organization_id
					and     msi.organization_id = l_ship_org
					and     msi.inventory_item_id = l_mlsupply_items(l_index).item_id  --inventory item id
					and     cal.calendar_code = mp.calendar_code
					and     cal.exception_set_id = mp.calendar_exception_set_id
					and     cal.seq_num =
					(select greatest(1, (cal2.prior_seq_num -
	                                       (ceil(nvl(msi.fixed_lead_time,0) +
	                                        nvl(msi.variable_lead_time,0) *
					        l_mlsupply_items(l_index).needed_item_qty			--bugfix 2074290: this is in primary uom
						))))
					from   bom_calendar_dates cal2
					where  cal2.calendar_code = mp.calendar_code
					and    cal2.exception_set_id =
						mp.calendar_exception_set_id
					and    cal2.calendar_date =
					trunc(l_mlsupply_items(l_index).job_completion_date)
				  );

				  if (SQL%ROWCOUNT > 0) then
        				IF PG_DEBUG <> 0 THEN
        					oe_debug_pub.add('create_subassembly_jobs: ' || 'Number of Rows Inserted in WJSI for children : ' || to_char(SQL%ROWCOUNT));

						oe_debug_pub.add('create_subassembly_jobs: ' || 'GROUP ID Inserted in WJSI for children : ' || x_groupID);
					END IF;

        			  end if;




		    END IF;--end of check for top most parent type




                   END IF; --discrete  routing , flow not checked as flow supply created during completion date calculation

		 -- rkaza. 05/05/2005. Removed IR from here. Do nothing only
		 -- for multiple sources.
	         ELSIF (l_mlsupply_items(l_index).source_type = 66) THEN
		        -- 66 = multiple sources
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('create_subassembly_jobs: ' ||  'item ' ||l_mlsupply_items(l_index).item_id || ' --'||l_mlsupply_items(l_index).item_name||'has multiple sources');
			END IF;

		 END IF; --source_type



		 EXIT WHEN l_index = l_mlsupply_items.LAST;
		l_index := l_mlsupply_items.NEXT(l_index);



	     END LOOP;

	     IF ( l_mlsupply_items(1).cfm_routing_flag  = 2 OR
	           l_mlsupply_items(1).cfm_routing_flag  = -99 ) THEN --top most parent is discrete
                 null;



	     ELSIF ( l_mlsupply_items(1).cfm_routing_flag = 1) THEN   --top most paernt is flow

              --bugfix 2755695
	      IF l_sub_level_buy_item = 'Y' THEN

		      l_token(1).token_name  := 'IMPORT_SOURCE_CODE';
	    	      l_token(1).token_value := 'CTO_LOWER LEVEL';

		       cto_msg_pub.cto_message('BOM', 'CTO_SUB_LEVEL_BUY_ITEMS',l_token);


            	      l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize




	      END IF;--sublevel buy item    bugfix 2755695


	     IF ( l_discrete_under_flow = 'Y') THEN
	         l_stmt_num := 300;



		 l_requestId := fnd_request.submit_request('WIP',
                                              'WICMLP',
                                              null,
                                              null,
                                              false,
                                              to_char(x_groupID),
                                              to_char(WIP_CONSTANTS.ATO),
                                              to_char(WIP_CONSTANTS.NO));



		if(l_requestId = 0) then --conc. req not spawned
			x_retVal := FND_API.G_RET_STS_ERROR;
			 fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
			fnd_message.set_token('ERROR_TEXT', 'WICMLP');
			 x_errMsg := fnd_message.get;
			ROLLBACK TO REBUILD;
		else
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('create_subassembly_jobs: ' || 'REQUEST ID  Inserted in WJSI for children : ' || l_requestId);
				cto_wip_workflow_api_pk.cto_debug ('Requets id is=> ',  l_requestId);

				l_token(1).token_name  := 'REQUEST_ID';
	    			l_token(1).token_value := l_requestId;



				cto_msg_pub.cto_message('BOM', 'CTO_SUB_LEVEL_DISCRETE_REQ',l_token); --bugfix 2755695


            			l_token := CTO_MSG_PUB.G_MISS_TOKEN_TBL;	-- initialize

			END IF;
			commit;
		 end if;

                END IF ; --lauch wip mass load


	    END IF; --top most paernt type

	    get_mlsupply_details( l_return_status,
				  l_error_messsage,
				  l_msg_name  );




EXCEPTION
    when FND_API.G_EXC_ERROR then

             x_return_status := FND_API.G_RET_STS_ERROR;
             --Bugfix 8913125
	     x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_subassembly_jobs: ' || 'CTOSUBSB.create_sub_assembly_jobs expected excpn: ' || x_error_message,1);
             END IF;


    when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             --Bugfix 8913125
	     x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_subassembly_jobs: ' || 'CTOSUBSB.create_sub_assembly_jobs UN expected excpn: ' || x_error_message,1);
             END IF;


   when OTHERS then
             x_return_status := FND_API.G_RET_STS_ERROR;
             --Bugfix 8913125
	     x_error_message := to_char(l_stmt_num)|| ': ' || substrb(sqlerrm,1,50);

             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_subassembly_jobs: ' || 'CTOSUBSB.create_sub_assembly_jobs  OTHERS excpn: ' || x_error_message,1);
             END IF;

END create_subassembly_jobs;

--4645636
Procedure process_phantoms
          (
	       pitems_table      in out nocopy t_item_details,
	       p_organization_id in number,
	       x_return_status         out  NOCOPY varchar2,
	       x_error_message         out  NOCOPY VARCHAR2, --  bytes to hold  msg */
	       x_message_name          out  NOCOPY VARCHAR2  --30 bytes to hold  name */
          )
is

l_index number;
m_index number;
l_phantom_idx number;
l_inherit_phantom_op_seq number;
l_actual_parent_idx number;
l_parent_index number;
x_min_op_seq_num number;
l_cons_item_qty number;
l_last_index number;

l_stmt_num number;

BEGIN
       oe_debug_pub.add('Inside process_phantoms',1);
       --replace phatom's parent idx with its first  non-phatom parent idx in chain
       l_stmt_num :=10;
       l_index := 2;
       Loop
         IF pitems_table(l_index).wip_supply_type = 6 THEN
	    l_phantom_idx := l_index;
	    m_index := 3;
	    --Loop
	    For m_index in 3..pitems_table.last
	    Loop
	       IF pitems_table(m_index).parent_index = l_phantom_idx THEN
	          pitems_table(m_index).actual_parent_idx := pitems_table(m_index).parent_index;
		   --removing phatom from chain
                  pitems_table(m_index).parent_index :=  pitems_table(l_phantom_idx).parent_index;

		  l_stmt_num := 20;
		  update BOM_CTO_MLSUPPLY_MAIN_TEMP
		  set actual_parent_index = pitems_table(m_index).actual_parent_idx,
		      parent_index = pitems_table(m_index).parent_index
		  where ITEM_INDEX = m_index;


	       END IF;

               --EXIT WHEN m_index = pitems_table.LAST;
	       --m_index := m_index+1;

	    END LOOP;
	  END IF;

	  EXIT WHEN l_index = pitems_table.LAST;
          l_index := l_index +1;
       END LOOP;

       l_last_index := pitems_table.count;

       IF PG_DEBUG = 5 THEN
         FOR i IN 1..l_last_index LOOP
		 oe_debug_pub.add('index=>'||i||
		                  'item_id=>'||pitems_table(i).item_id||
	                          'parent_idx=>'||pitems_table(i).parent_index||
			          'actual_parent_idx=>'||pitems_table(i).actual_parent_idx||
			          'wip_supply_type=>'||pitems_table(i).wip_supply_type,5);
          END LOOP;
       END IF;




     --get inherit_op_sequence
     l_stmt_num := 30;
      select INHERIT_PHANTOM_OP_SEQ
      into l_inherit_phantom_op_seq
      from bom_parameters
      where organization_id = p_organization_id;

      l_stmt_num :=40;
      IF l_inherit_phantom_op_seq = 1 THEN
         l_index := 2;
         Loop
          IF pitems_table(l_index).parent_index <> pitems_table(l_index).actual_parent_idx THEN --implies child of phantom

	     l_actual_parent_idx:= pitems_table(l_index).actual_parent_idx;

	     pitems_table(l_index).operation_seq_num := pitems_table(l_actual_parent_idx).operation_seq_num;

             pitems_table(l_index).OPERATION_LEAD_TIME_PERCENT :=  pitems_table(l_actual_parent_idx).OPERATION_LEAD_TIME_PERCENT;

	     l_stmt_num := 50;
	     update BOM_CTO_MLSUPPLY_MAIN_TEMP
             set operation_seq_num = pitems_table(l_index).operation_seq_num,
		 OPERATION_LEAD_TIME_PERCENT = pitems_table(l_index).OPERATION_LEAD_TIME_PERCENT
	     where ITEM_INDEX = l_index;

          END IF;

            EXIT WHEN l_index = pitems_table.LAST;
	    l_index := l_index +1;
	 END LOOP;

      ELSE
         null;
          --(A)--leave op seq as it is

	  --(B)--need to get lead time offset % from parent
	l_index :=3;
	--Loop
	l_stmt_num := 60;
	For l_index in 3..pitems_table.last
	loop
	  --EXIT WHEN l_index = pitems_table.LAST;


          IF pitems_table(l_index).parent_index <> pitems_table(l_index).actual_parent_idx THEN -- implies child of pH
	    l_parent_index := pitems_table(l_index).parent_index;

	    IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('ENTERED IF BLOCK',5);
              oe_debug_pub.add('parent_item_id=>'||pitems_table(l_parent_index).item_id ,5);
	       oe_debug_pub.add('item_id=>'||pitems_table(l_index).item_id ,5);
	        oe_debug_pub.add('operation_seq_num=>'||pitems_table(l_index).operation_seq_num ,5);
	    END IF;

	    BEGIN
	       l_stmt_num := 70;
	       select  nvl(bos_p.OPERATION_LEAD_TIME_PERCENT,0)
	       INTO pitems_table(l_index).operation_lead_time_percent
	       from  bom_operational_routings bor_p,--parent
		     bom_operation_sequences bos_p
	      where   bor_p.assembly_item_id = pitems_table(l_parent_index).item_id
	      and     bor_p.organization_id  = p_organization_id
	      and   bor_p.ALTERNATE_ROUTING_DESIGNATOR is null
	      and   bos_p.routing_sequence_id = bor_p.common_routing_sequence_id
	      and   bos_p.operation_seq_num = pitems_table(l_index).operation_seq_num
	      and   nvl( bos_p.operation_type,1)=1; ---consider event only for flm routing 5676839
	    Exception
	     WHEN no_data_found then
		 pitems_table(l_index).operation_lead_time_percent := 0;
		 oe_debug_pub.add('lead_time=>'||pitems_table(l_index).operation_lead_time_percent,1);

	     END;

	      oe_debug_pub.add('lead_time=>'||pitems_table(l_index).operation_lead_time_percent,1);
	     l_stmt_num := 80;
	     update BOM_CTO_MLSUPPLY_MAIN_TEMP
             set --operation_seq_num = pitems_table(l_index).operation_seq_num,
	         OPERATION_LEAD_TIME_PERCENT = pitems_table(l_index).OPERATION_LEAD_TIME_PERCENT
	     where ITEM_INDEX = l_index;

	  END IF;
	     -- EXIT WHEN l_index = pitems_table.LAST;
	    --  l_index := l_index +1 ;
	END LOOP;


      END IF;


      IF PG_DEBUG = 5 THEN
         FOR i IN 1..l_last_index LOOP
		 oe_debug_pub.add('index=>'||i||
		                  'item_id=>'||pitems_table(i).item_id||
	                          'parent_idx=>'||pitems_table(i).parent_index||
			          'actual_parent_idx=>'||pitems_table(i).actual_parent_idx||
			          'wip_supply_type=>'||pitems_table(i).wip_supply_type||
				  'LT_offset=>'||pitems_table(i).operation_lead_time_percent||
				  'op_seq=>'||pitems_table(i).operation_seq_num,5);
          END LOOP;
       END IF;



        --For MIN_OP_Seq_num calculations
      l_index :=2;
      LOOP
	l_parent_index := pitems_table(l_index).parent_index;

	IF (nvl(pitems_table(l_index).wip_supply_type,1) <> 6 AND
	     pitems_table(l_index).source_type <> 66   AND
	     pitems_table(l_parent_index).cfm_routing_flag = 1 AND
             pitems_table(l_parent_index).needed_item_qty <> 0 AND
	     (pitems_table(l_index).source_type = 3
		OR
	      pitems_table(l_index).source_type = 1
		OR
	      pitems_table(l_index).cfm_routing_flag <> 1
	       )
	     )
        THEN
               IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('ENTERED MIN OP SEQ BLOCK',5);
	       END IF;

                 l_stmt_num := 90;
		 select min(OPERATION_SEQ_NUM),sum(needed_item_qty)
                 into x_min_op_seq_num,l_cons_item_qty
		 FROM BOM_CTO_MLSUPPLY_MAIN_TEMP
		 WHERE parent_index = pitems_table(l_index).parent_index
		 AND   item_id = pitems_table(l_index).item_id;

              IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('item_id=>'||pitems_table(l_index).item_id,5);
		oe_debug_pub.add('x_min_op_seq_num=>'||x_min_op_seq_num,5);
		oe_debug_pub.add('l_cons_item_qty=>'||l_cons_item_qty,5);
                oe_debug_pub.add('parent_index=>'||pitems_table(l_index).parent_index,5);
              END IF;

                l_stmt_num := 100;
		Update bom_cto_mlsupply_main_temp
		 set needed_item_qty = 0
		 where parent_index = pitems_table(l_index).parent_index
		 AND   item_id = pitems_table(l_index).item_id
		 and   Operation_seq_num <> x_min_op_seq_num;


                l_stmt_num := 110;
		 Update bom_cto_mlsupply_main_temp
		 set needed_item_qty = l_cons_item_qty
		 where parent_index = pitems_table(l_index).parent_index
		 AND   item_id = pitems_table(l_index).item_id
                 and    Operation_seq_num = x_min_op_seq_num;




        END IF;
         EXIT WHEN l_index = pitems_table.LAST;
        l_index := l_index+1;
     END LOOP;

     IF PG_DEBUG = 5 THEN
         FOR i IN 1..l_last_index LOOP
		 oe_debug_pub.add('index=>'||i||
		                  'item_id=>'||pitems_table(i).item_id||
	                          'parent_idx=>'||pitems_table(i).parent_index||
			          'actual_parent_idx=>'||pitems_table(i).actual_parent_idx||
			          'wip_supply_type=>'||pitems_table(i).wip_supply_type||
				  'LT_offset=>'||pitems_table(i).operation_lead_time_percent||
				  'op_seq=>'||pitems_table(i).operation_seq_num,5);
          END LOOP;
       END IF;


    EXCEPTION
    when FND_API.G_EXC_ERROR then

              x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message := 'CTOSUBSB.process_phantoms expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);


             IF PG_DEBUG <> 0 THEN
             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('process_phantoms: ' || 'CTOSUBSB.create_flow_subassembly expected excpn:  ' || x_error_message,1);
             	END IF;
             END IF;


   when FND_API.G_EXC_UNEXPECTED_ERROR then
	     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             x_error_message := 'CTOSUBSB.process_phantoms UN expected  excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);


             IF PG_DEBUG <> 0 THEN
             	IF PG_DEBUG <> 0 THEN
             		oe_debug_pub.add('process_phantoms: ' || 'CTOSUBSB.create_flow_subassembly UN expected excpn:  ' || x_error_message,1);
             	END IF;
             END IF;



   when OTHERS then
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_error_message := 'CTOSUBSB.process_phantoms OTHERS excpn: ' || to_char(l_stmt_num)|| ':' ||
                                substrb(sqlerrm,1,100);

           IF PG_DEBUG <> 0 THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('process_phantoms: ' || 'CTOSUBSB.create_flow_subassembly OTHERS excpn:  ' || x_error_message,1);
           	END IF;
           END IF;




END process_phantoms;



end CTO_SUBASSEMBLY_SUP_PK;

/
