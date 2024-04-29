--------------------------------------------------------
--  DDL for Package Body EAM_WO_COMP_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_COMP_VALIDATE_PVT" AS
/* $Header: EAMVWCVB.pls 120.10 2006/11/14 22:59:37 brmanesh noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWCVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_COMP_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/
PROCEDURE Check_Required
   (
	p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status         OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
    )
   IS
      l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
      l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
      l_shutdown_type	      VARCHAR2(30);
      l_wip_entity_name	      VARCHAR2(240);
      l_status_type	      NUMBER;
   BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Check Required'); END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	  SELECT wip_entity_name
	    INTO l_wip_entity_name
            FROM wip_entities
           WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Actual start date'); END IF;

	   SELECT status_type,shutdown_type
	     INTO l_status_type,l_shutdown_type
             FROM wip_discrete_jobs
            WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

              IF p_eam_wo_comp_rec.actual_start_date IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  l_wip_entity_name;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ACT_STDATE_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
  	            return;
		END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Actual end date'); END IF;
		IF p_eam_wo_comp_rec.actual_end_date IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  l_wip_entity_name;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ACT_ENDDATE_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
  	            return;
		END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check Actual duration '); END IF;
		IF p_eam_wo_comp_rec.actual_duration IS NULL
		THEN
		    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		    l_token_tbl(1).token_value :=  l_wip_entity_name;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		    (  p_message_name	=> 'EAM_WCMP_ACT_DUR_REQ'
		     , p_token_tbl	=> l_Token_tbl
		     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
		     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
		     );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;
		    x_mesg_token_tbl	  := l_mesg_token_tbl ;
		    x_return_status	  := FND_API.G_RET_STS_ERROR;
  	            return;
		END IF;

		IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE
		THEN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check shutdown type '); END IF;
			IF l_shutdown_type = 2 THEN -- Bug #5165813. Only Required shutdown_type needs to be validate
			  IF p_eam_wo_comp_rec.shutdown_start_date IS NULL  OR p_eam_wo_comp_rec.shutdown_end_date IS NULL THEN

			    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  l_wip_entity_name;

			    l_out_mesg_token_tbl  := l_mesg_token_tbl;
			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WCMPL_SHUTDOWN_DATE_MISS'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );
			    l_mesg_token_tbl      := l_out_mesg_token_tbl;
			    x_mesg_token_tbl	  := l_mesg_token_tbl ;
			    x_return_status	  := FND_API.G_RET_STS_ERROR;
			    return;
			END IF;
		      END IF;
		END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check status type '); END IF;
	       IF (p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE AND l_status_type <> 3 )
		    OR
		   (
		       (  p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UNCOMPLETE)
		      AND
		       (  l_status_type not in (4 ,5))
		    )
		    THEN
			    l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			    l_token_tbl(1).token_value :=  l_wip_entity_name;
			    l_out_mesg_token_tbl       := l_mesg_token_tbl;

			    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
			    (  p_message_name	=> 'EAM_WO_COMP_WRONG_STATUS'
			     , p_token_tbl	=> l_Token_tbl
			     , p_Mesg_Token_Tbl	=> l_Mesg_Token_Tbl
			     , x_Mesg_Token_Tbl	=> l_out_Mesg_Token_Tbl
			     );
			    l_mesg_token_tbl      := l_out_mesg_token_tbl;
			    x_mesg_token_tbl	  := l_mesg_token_tbl ;
			    x_return_status       := FND_API.G_RET_STS_ERROR;
			    return;
		END IF;
END Check_Required;










PROCEDURE Check_Attributes
   (
	  p_eam_wo_comp_rec     IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_eam_wo_comp_rec     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
	, x_return_status       OUT NOCOPY  VARCHAR2
       	, x_mesg_token_tbl      OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
   )
IS
	l_err_text              VARCHAR2(2000) := NULL;
	l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_out_Mesg_Token_Tbl    EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
	network_child_job_var   VARCHAR2(2):='0';
	sibling_parent_job_var  VARCHAR2(2):='0';
	l_reconciliation_code   VARCHAR2(30);
	l_manual_rebuild_flag   VARCHAR2(1);
	l_parent_wip_entity_id  NUMBER;
	l_parent_status_type    NUMBER;
	l_wip_entity_name       VARCHAR2(240);
        l_min_open_period       DATE;
	l_max_compl_op_date     DATE;
        l_min_compl_op_date     DATE;
	l_locator_id		NUMBER;
	l_completion_info	NUMBER;
	l_lot_ctrl_code		NUMBER;
	l_lot_number		VARCHAR2(80);
	l_rebuild_serial_number VARCHAR2(30);
	l_serial_status		NUMBER;
	l_valid                 NUMBER := 0;
	child_job_var           VARCHAR2(2):='0';

	p_subinv_ctrl		NUMBER;
	l_subinv		VARCHAR2(80);
	l_error_flag		NUMBER;
	l_error_mssg		VARCHAR2(250);
	l_locator_ctrl		NUMBER ; -- Holds the Locator Control information
	l_org_id		NUMBER;
	l_maintenance_object_type	NUMBER;
	l_count			NUMBER;
	l_serial_number		VARCHAR2(30);

	G_EXC_RET_MAT_INVALID_SUBINV	EXCEPTION;
	G_EXC_NOT_ENOUGH_VALUES		EXCEPTION;
	G_EXC_RET_MAT_INVALID_LOCATOR	EXCEPTION;
	G_EXC_RET_MAT_LOCATOR_NEEDED	EXCEPTION;
	G_EXC_RET_MAT_LOCATOR_RESTRIC	EXCEPTION;
	G_EXC_NO_LOT_NUMBER		EXCEPTION;
	G_EXC_LOT_NEEDED		EXCEPTION;
	G_EXC_LOT_NOT_NEEDED		EXCEPTION;
	G_EXC_LOCATOR_DEFAULT		EXCEPTION;
	l_inventory_item_id		NUMBER;

	CURSOR cur_work_order_details IS
	SELECT  cii.inventory_item_id
	  FROM  wip_discrete_jobs wdj,csi_item_instances cii
	 WHERE  wdj.wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
	   AND  wdj.maintenance_object_type = 3
	   AND  wdj.maintenance_object_id = cii.instance_id
	 UNION
        SELECT  wdj.maintenance_object_id
	  FROM  wip_discrete_jobs wdj
	 WHERE  wdj.wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
	   AND  wdj.maintenance_object_type = 2;

  BEGIN

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Check_Attributes'); END IF;

        x_return_status   := FND_API.G_RET_STS_SUCCESS;
	x_eam_wo_comp_rec := p_eam_wo_comp_rec;
	l_org_id	  := p_eam_wo_comp_rec.organization_id;

	  SELECT wip_entity_name
	    INTO l_wip_entity_name
            FROM WIP_ENTITIES
           WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

	   SELECT maintenance_object_type
	     INTO l_maintenance_object_type
	     FROM wip_discrete_jobs
	    WHERE wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

	    OPEN cur_work_order_details;
	    FETCH cur_work_order_details into l_inventory_item_id;
	    CLOSE cur_work_order_details;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check shutdown start and end date'); END IF;

	   begin

		IF p_eam_wo_comp_rec.actual_start_date > p_eam_wo_comp_rec.actual_end_date THEN
		    raise fnd_api.g_exc_unexpected_error;
		END IF;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

	   exception
	    when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
	      l_token_tbl(1).token_value :=  l_wip_entity_name;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name       => 'EAM_WC_SHUTDOWN_STAF_END'
	       , p_token_tbl          => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;
	   end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check transaction date and open period'); END IF;
	   begin

		 SELECT NVL(MIN(period_start_date), sysdate+2)
		   INTO l_min_open_period
		   FROM org_acct_periods
		  WHERE organization_id = l_org_id
		    AND open_flag = 'Y';
		    /* Fix for bug no: 2695696    */
			 /*Fix for bug 3235163*/
		   --Previously the check was for actual_end date.It has been changed to p_transaction_date

			  IF (p_eam_wo_comp_rec.transaction_date < l_min_open_period) THEN
				raise fnd_api.g_exc_unexpected_error;
			  END IF;
			  x_return_status := FND_API.G_RET_STS_SUCCESS;
	   exception
	    when others then

	      l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
	      l_token_tbl(1).token_value :=  l_wip_entity_name;

	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name       => 'EAM_TRANSACTION_DATE_INVALID'
	       , p_token_tbl          => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;

	   end;


	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check shutdown start and end date'); END IF;
	    begin
		IF p_eam_wo_comp_rec.shutdown_start_date > p_eam_wo_comp_rec.shutdown_end_date  THEN
		    raise fnd_api.g_exc_unexpected_error;
		END IF;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

	    exception
		    when others then

		      l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		      l_token_tbl(1).token_value :=  l_wip_entity_name;

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_WC_SHUTDOWN_DATE_BAD'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
	    end;



	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check completion date'); END IF;
	   begin
	      if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  then
	      begin

	       /* Fix for Bug 2100416 */
	      select nvl(max(actual_end_date), sysdate - 200000)
	      into l_max_compl_op_date
	      from eam_op_completion_txns eoct
	      where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
	      --fix for 3543834.added  where clause so that the last completion date will be fetched if the operation is complete
	      and transaction_type=1
	      and transaction_id = (select max(transaction_id)
				  from eam_op_completion_txns
				  where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
					and operation_seq_num = eoct.operation_seq_num
					);
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Allowing for completed operations'); END IF;
	      /* Fix for bug no:2730242 */
	      select nvl(min(actual_start_date), sysdate + 200000)
	      into l_min_compl_op_date
	      from eam_op_completion_txns eoct
	      where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
	      --fix for 3543834.added  where clause so that the last completion date will be fetched if the operation is complete
	      and transaction_type=1
	      and transaction_id = (select max(transaction_id)
				    from eam_op_completion_txns
				    where wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
					  and operation_seq_num = eoct.operation_seq_num
					 );

		-- mmaduska added for bug 3273898
		 -- mmaduska added and condition to solve the date time truncation problem

	      -- changed conditions for 3543834 so that actual_start_date and actual_end_date will be validated
	       if (
		  ((p_eam_wo_comp_rec.actual_end_date < l_max_compl_op_date) AND (l_max_compl_op_date - p_eam_wo_comp_rec.actual_end_date >  (0.000011575 * 60 ))) OR
		  ((p_eam_wo_comp_rec.actual_start_date > l_min_compl_op_date) AND (p_eam_wo_comp_rec.actual_start_date -  l_min_compl_op_date >  (0.000011575 * 60 )))
		  )then
		  raise fnd_api.g_exc_unexpected_error;

	      end if;

	      -- if p_actual_start_date is close to l_min_compl_op_date by a min or p_actual_end_date is close to l_max_compl_op_date
			if (p_eam_wo_comp_rec.actual_end_date < l_max_compl_op_date) then
			    x_eam_wo_comp_rec.actual_end_date := l_max_compl_op_date;
			else
			   x_eam_wo_comp_rec.actual_end_date := p_eam_wo_comp_rec.actual_end_date;
			end if;

			if(p_eam_wo_comp_rec.actual_start_date > l_min_compl_op_date) then
			    x_eam_wo_comp_rec.actual_start_date := l_min_compl_op_date;
			else
			    x_eam_wo_comp_rec.actual_start_date := p_eam_wo_comp_rec.actual_start_date;
			end if;
	   exception
	   when others then

	      l_token_tbl(1).token_name  := 'MIN_OP_DATE';
	      l_token_tbl(1).token_value :=  TO_CHAR(l_min_compl_op_date,'dd-MON-yyyy HH24:MI:SS');

	      l_token_tbl(2).token_name  := 'MAX_OP_DATE';
	      l_token_tbl(2).token_value :=  TO_CHAR(l_max_compl_op_date,'dd-MON-yyyy HH24:MI:SS');


	      l_out_mesg_token_tbl  := l_mesg_token_tbl;
	      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
	      (  p_message_name       => 'EAM_WO_COMPL_DATES_INVALID'
	       , p_token_tbl          => l_token_tbl
	       , p_mesg_token_tbl     => l_mesg_token_tbl
	       , x_mesg_token_tbl     => l_out_mesg_token_tbl
	      );
	      l_mesg_token_tbl      := l_out_mesg_token_tbl;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_mesg_token_tbl := l_mesg_token_tbl ;
	      return;

	      end;
	     end if;
	   end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check duration'); END IF;
	   begin
	      if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  then

		     begin
			IF p_eam_wo_comp_rec.actual_duration < 0  THEN
			    raise fnd_api.g_exc_unexpected_error;
		       END IF;

		    x_return_status := FND_API.G_RET_STS_SUCCESS;

		  exception
		    when others then

		      l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		      l_token_tbl(1).token_value :=  l_wip_entity_name;

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name       => 'EAM_WC_NEGATIVE_DURATION'
		       , p_token_tbl          => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
		  end;
	      end if;
	   end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check actual end date in future'); END IF;
	   begin
		if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  then
		    begin

		       IF p_eam_wo_comp_rec.actual_end_date > sysdate  THEN
			    raise fnd_api.g_exc_unexpected_error;
		       END IF;

		       x_return_status := FND_API.G_RET_STS_SUCCESS;
		   exception
		    when others then

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_END_LATER_THAN_TODAY'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
		  end;
		end if;
	   end;


	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check subinventory and lot information '); END IF;
	   begin
	    if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  and
	       p_eam_wo_comp_rec.completion_subinventory IS NOT NULL
	       then

		begin
			l_completion_info := 0;

			IF l_maintenance_object_type = 2 THEN
				SELECT count(*) into l_count
				  FROM wip_discrete_jobs wdj,
				       mtl_system_items_b msib
				 WHERE wdj.organization_id = msib.organization_id
				   AND wdj.maintenance_object_id = msib.inventory_item_id
				   AND wdj.organization_id = p_eam_wo_comp_rec.organization_id
				   AND wdj.wip_entity_id   = p_eam_wo_comp_rec.wip_entity_id ;

				   IF l_count >0 THEN
					l_completion_info := 1;
				   END IF;

			 END IF;
			 IF l_maintenance_object_type = 3 THEN

				SELECT count(*) into l_count
				  FROM wip_discrete_jobs wdj,
				       csi_item_instances cii
				 WHERE wdj.organization_id = cii.last_vld_organization_id
				   AND wdj.maintenance_object_id = cii.instance_id
				   AND wdj.organization_id = p_eam_wo_comp_rec.organization_id
				   AND wdj.wip_entity_id   = p_eam_wo_comp_rec.wip_entity_id ;


				   IF l_count > 0 THEN

					   SELECT  cii.serial_number ,
						   msn.current_status
					    INTO   l_serial_number ,
						   l_serial_status
					     FROM  wip_discrete_jobs wdj,
						   csi_item_instances cii,
						   mtl_serial_numbers msn
					    WHERE  wdj.wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
					      AND  wdj.maintenance_object_type = 3
					      AND  wdj.maintenance_object_id = cii.instance_id
					      AND  cii.serial_number = msn.serial_number
					      AND  cii.inventory_item_id = msn.inventory_item_id;

					     IF l_serial_status = 4 THEN
						 l_completion_info := 1;
					     END IF;


				   END IF;

			END IF;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check subinventory'); END IF;

			IF l_completion_info = 1 THEN
			   SELECT lot_control_code into l_lot_ctrl_code
			     FROM mtl_system_items_b
			    WHERE inventory_item_id = l_inventory_item_id
			      AND organization_id = l_org_id ;

			      IF p_eam_wo_comp_rec.completion_subinventory IS NOT NULL THEN
					Begin
					select restrict_subinventories_code
					  into p_subinv_ctrl
					  from mtl_system_items_kfv
					 where organization_id = l_org_id
					   and inventory_item_id = l_inventory_item_id;

					  if(p_subinv_ctrl is null or p_subinv_ctrl <> 1) then
						 select secondary_inventory_name into l_subinv
						 from mtl_secondary_inventories
						 where
						 secondary_inventory_name = p_eam_wo_comp_rec.completion_subinventory
						 and organization_id = l_org_id
						 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
						 and Asset_inventory = 2;
					 elsif(p_subinv_ctrl = 1) then
						 select secondary_inventory_name into l_subinv
						 from mtl_secondary_inventories
						 where
						 secondary_inventory_name = p_eam_wo_comp_rec.completion_subinventory
						 and organization_id = l_org_id
						 and nvl(disable_date,trunc(sysdate)+1)>trunc(sysdate)
						 and Asset_inventory = 2
						 and EXISTS (select secondary_inventory from mtl_item_sub_inventories
											   where secondary_inventory = secondary_inventory_name
											   and  inventory_item_id = l_inventory_item_id
											   and organization_id = l_org_id);
					  end if;
					 exception
					  when no_data_found then
						  raise G_EXC_RET_MAT_INVALID_SUBINV;
				end;
			      ELSE
					-- raise G_EXC_NOT_ENOUGH_VALUES;
					null;
			      END IF;
			 END IF;  -- end of l_completion_info = 1

			 l_locator_id := p_eam_wo_comp_rec.completion_locator_id;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check locator control code'); END IF;
	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_MTL_TXN_PROCESS.Get_LocatorControl_Code'); END IF;
			/* Check for Locator Control which could be defined
			   at 3 level Organization,Subinventory,Item .
			*/
			EAM_MTL_TXN_PROCESS.Get_LocatorControl_Code(
								  l_org_id,
								  p_eam_wo_comp_rec.completion_subinventory,
								  l_inventory_item_id,
								  27,
								  l_locator_ctrl,
								  l_error_flag,
								  l_error_mssg);

			if(l_error_flag <> 0) then
			   raise G_EXC_LOCATOR_DEFAULT;
			end if;

			-- if the locator control is Predefined or Dynamic Entry
			if(l_locator_ctrl = 2 or l_locator_ctrl = 3) then
			 if(l_locator_id IS NULL) then
				raise G_EXC_RET_MAT_LOCATOR_NEEDED;
			 end if;
			elsif(l_locator_ctrl = 1) then -- If the locator control is NOControl
			 if(l_locator_id IS NOT NULL) then
				raise G_EXC_RET_MAT_LOCATOR_RESTRIC;
			 end if;
			end if; -- end of locator_control checkif

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check lot entry '); END IF;

			/* CHECK for lot entry    */
			if(l_lot_ctrl_code = 2) then
			    if(p_eam_wo_comp_rec.lot_number is not null)then
				begin
				 select
				    lot_number into l_lot_number
				    from
				    mtl_lot_numbers
				   where
				    inventory_item_id = l_inventory_item_id
					and organization_id = l_org_id;
				exception
				when NO_DATA_FOUND then
				   raise G_EXC_NO_LOT_NUMBER;
				end;
			    else
				raise G_EXC_LOT_NEEDED;
			    end if;
			else
			   if(p_eam_wo_comp_rec.lot_number is not null) then
				 raise G_EXC_LOT_NOT_NEEDED;
			   end if;
			end if; -- end of lot entry check

		exception
			WHEN G_EXC_RET_MAT_INVALID_SUBINV THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_RET_MAT_INVALID_SUBINV'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;

			WHEN G_EXC_NOT_ENOUGH_VALUES THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_NOT_ENOUGH_VALUES'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;

			WHEN G_EXC_LOCATOR_DEFAULT THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_LOCATOR_DEFAULT_ERR'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
			WHEN G_EXC_RET_MAT_LOCATOR_NEEDED THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_RET_MAT_LOCATOR_NEEDED'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
			WHEN G_EXC_RET_MAT_LOCATOR_RESTRIC THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_RET_MAT_LOCATOR_RESTRICTED'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
			WHEN G_EXC_NO_LOT_NUMBER THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_NO_LOT_NUMBER'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
			WHEN G_EXC_LOT_NEEDED THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_LOT_NEEDED'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
			WHEN G_EXC_LOT_NOT_NEEDED THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_LOT_NOT_NEEDED'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
		end;

	    end if;
	 end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check whether child job is complete'); END IF;
	 begin
	  if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE then
	  begin
	-- Replaced the above cursor loop and cursor with the following query.
	   -- for bug #2414513.
	      SELECT '1'
		INTO child_job_var
		FROM dual
	       WHERE EXISTS (SELECT '1'
			       FROM wip_discrete_jobs wdj, wip_entities we
			      WHERE wdj.wip_entity_id =  we.wip_entity_id
				AND wdj.parent_wip_entity_id = p_eam_wo_comp_rec.wip_entity_id
				AND wdj.manual_rebuild_flag = 'Y'
				AND wdj.status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
				WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED));

	      if (child_job_var = '1') then
		     raise fnd_api.g_exc_unexpected_error;
	      end if;
	    exception
	     WHEN NO_DATA_FOUND THEN
		    null;
	     WHEN OTHERS THEN
		      l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
		      l_token_tbl(1).token_value :=  l_wip_entity_name;

		      l_out_mesg_token_tbl  := l_mesg_token_tbl;
		      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_CHILD_JOB_NOT_COMPLETE'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		      );
		      l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_return_status := FND_API.G_RET_STS_ERROR;
		      x_mesg_token_tbl := l_mesg_token_tbl ;
		      return;
	    end;
	    end if;
	  end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check reconciliation code'); END IF;
	  begin
		if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE and
		   p_eam_wo_comp_rec.reconciliation_code is not null then

		    begin
		       SELECT mlu.lookup_code
			 INTO l_reconciliation_code
			 FROM mfg_lookups mlu
			WHERE mlu.lookup_type = 'WIP_EAM_RECONCILIATION_CODE'
			  AND mlu.lookup_code = p_eam_wo_comp_rec.reconciliation_code;

		    EXCEPTION WHEN OTHERS THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_WC_RECONCILIATION_CODE_INV'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
		    end;
		end if;
	    end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check whether WO network child is complete ...'); END IF;
	    begin
		if p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE  then
		begin
			 SELECT '1'
			   INTO network_child_job_var
			   FROM dual
			  WHERE EXISTS ( SELECT '1'
					   FROM wip_discrete_jobs
					  WHERE wip_entity_id IN
					  (
					 SELECT DISTINCT  child_object_id
					   FROM eam_wo_relationships
					  WHERE parent_relationship_type =1
						START WITH parent_object_id =    p_eam_wo_comp_rec.wip_entity_id AND parent_relationship_type = 1
						CONNECT BY  parent_object_id  = prior child_object_id   AND parent_relationship_type = 1
					 )
				       AND status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
					WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED, WIP_CONSTANTS.CANCELLED )

				     );

			  if (network_child_job_var = '1') then  --In the network Work Order has Uncompleted Child Work Orders
				raise fnd_api.g_exc_unexpected_error;
			  end if;

		exception
		WHEN NO_DATA_FOUND THEN
			null;
		WHEN OTHERS THEN
				l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
				l_token_tbl(1).token_value :=  l_wip_entity_name;

				l_out_mesg_token_tbl  := l_mesg_token_tbl;
				EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_NETWRK_CHILD_JOB_NOT_COMP'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
				l_mesg_token_tbl      := l_out_mesg_token_tbl;

				x_return_status := FND_API.G_RET_STS_ERROR;
				x_mesg_token_tbl := l_mesg_token_tbl ;
				return;
		    end;
		end if;
	    end;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check whether WO network sibling is complete ...'); END IF;
	    begin
	       IF p_eam_wo_comp_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_COMPLETE THEN
		begin
		 SELECT '1'
		    INTO sibling_parent_job_var
		    FROM dual
		 WHERE EXISTS (SELECT '1'
				   FROM wip_discrete_jobs
				 WHERE wip_entity_id IN
				 (
				 SELECT DISTINCT  parent_object_id
					FROM eam_wo_relationships
				  WHERE parent_relationship_type =2 and
					child_object_id  =    p_eam_wo_comp_rec.wip_entity_id
				 )
			       AND status_type NOT IN (WIP_CONSTANTS.COMP_CHRG,
				WIP_CONSTANTS.COMP_NOCHRG,WIP_CONSTANTS.CLOSED)
			     );

		 IF (sibling_parent_job_var = '1') THEN
		      raise fnd_api.g_exc_unexpected_error;
		 END IF;
	    exception
		WHEN NO_DATA_FOUND THEN
			null;
		WHEN OTHERS THEN
			l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_token_tbl(1).token_value :=  l_wip_entity_name;

			l_out_mesg_token_tbl  := l_mesg_token_tbl;
			EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_NETWRK_SIB_JOB_NOT_COM'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
			l_mesg_token_tbl      := l_out_mesg_token_tbl;

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_mesg_token_tbl := l_mesg_token_tbl ;
			return;
	       end;
	      end if;
	    end ;

	IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check whether parent rebuild job is complete if manual rebuild WO  ...'); END IF;
	    begin
		SELECT	manual_rebuild_flag,
			parent_wip_entity_id
		  INTO  l_manual_rebuild_flag,
			l_parent_wip_entity_id
		  FROM	WIP_DISCRETE_JOBS
		 WHERE	wip_entity_id = p_eam_wo_comp_rec.wip_entity_id;

		 IF l_manual_rebuild_flag = 'Y' and l_parent_wip_entity_id IS NOT NULL THEN
			SELECT status_type
			  INTO l_parent_status_type
			  FROM WIP_DISCRETE_JOBS
			 WHERE wip_entity_id = l_parent_wip_entity_id;

			  IF(l_parent_status_type = WIP_CONSTANTS.COMP_CHRG) THEN
				 raise fnd_api.g_exc_unexpected_error;
			  END IF;

		 END IF;
	    exception
	      WHEN OTHERS THEN
			l_token_tbl(1).token_name  := 'WIP_ENTITY_NAME';
			l_token_tbl(1).token_value :=  l_wip_entity_name;

			l_out_mesg_token_tbl  := l_mesg_token_tbl;
			EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name  => 'EAM_PARENT_JOB_COMPLETED'
				, p_token_tbl     => l_token_tbl
				, p_mesg_token_tbl     => l_mesg_token_tbl
				, x_mesg_token_tbl     => l_out_mesg_token_tbl
				);
			l_mesg_token_tbl      := l_out_mesg_token_tbl;

			x_return_status := FND_API.G_RET_STS_ERROR;
			x_mesg_token_tbl := l_mesg_token_tbl ;
			return;
	    end;

END Check_Attributes;






PROCEDURE Check_Attributes_b4_Defaulting
        (  p_eam_wo_comp_rec              IN EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
         , x_Mesg_Token_Tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
    )
    IS
    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
    g_dummy         NUMBER;

    BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Work Order Completeion processing Check_Attributes_b4_Defaulting'); END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

--  organization_id
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Check organization_id'); END IF;

  declare
    l_disable_date date;
  begin

    select 1
      into g_dummy
      from mtl_parameters mp
     where mp.organization_id = p_eam_wo_comp_rec.organization_id;

    select nvl(hou.date_to,sysdate+1)
      into l_disable_date
      from hr_organization_units hou
      where organization_id =  p_eam_wo_comp_rec.organization_id;

    if(l_disable_date < sysdate) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_comp_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORGANIZATION_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

--  organization_id (EAM enabled)

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Validating organization_id (EAM enabled) . . . '); END IF;

  begin

    select 1
      into g_dummy
      from wip_eam_parameters wep, mtl_parameters mp
     where wep.organization_id = mp.organization_id
       and mp.eam_enabled_flag = 'Y'
       and wep.organization_id = p_eam_wo_comp_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then

      l_token_tbl(1).token_name  := 'Organization Id';
      l_token_tbl(1).token_value :=  p_eam_wo_comp_rec.organization_id;

      l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WO_ORG_EAM_ENABLED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_mesg_token_tbl := l_mesg_token_tbl ;
      return;

  end;

END Check_Attributes_b4_Defaulting;


END EAM_WO_COMP_VALIDATE_PVT;

/
