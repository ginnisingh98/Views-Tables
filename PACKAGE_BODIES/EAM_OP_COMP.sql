--------------------------------------------------------
--  DDL for Package Body EAM_OP_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_COMP" AS
/* $Header: EAMOCMPB.pls 120.8 2006/09/18 08:33:47 cboppana noship $  */


FUNCTION IS_WORKFLOW_ENABLED
(p_maint_obj_source    IN   NUMBER,
  p_organization_id         IN    NUMBER
) RETURN VARCHAR2
IS
    l_workflow_enabled      VARCHAR2(1);
BEGIN

  BEGIN
              SELECT enable_workflow
	      INTO   l_workflow_enabled
	      FROM EAM_ENABLE_WORKFLOW
	      WHERE MAINTENANCE_OBJECT_SOURCE =p_maint_obj_source;
     EXCEPTION
          WHEN NO_DATA_FOUND   THEN
	      l_workflow_enabled    :=         'N';
   END;

  --IF EAM workorder,check if workflow is enabled for this organization or not
  IF(l_workflow_enabled ='Y'   AND   p_maint_obj_source=1) THEN
       BEGIN
               SELECT eam_wo_workflow_enabled
	       INTO l_workflow_enabled
	       FROM WIP_EAM_PARAMETERS
	       WHERE organization_id =p_organization_id;
       EXCEPTION
               WHEN NO_DATA_FOUND THEN
		       l_workflow_enabled := 'N';
       END;
  END IF;  --check for workflow enabled at org level


     RETURN l_workflow_enabled;

END IS_WORKFLOW_ENABLED;


PROCEDURE op_comp (
	x_err_code	 		OUT NOCOPY 	NUMBER,
	x_err_msg			OUT NOCOPY	VARCHAR2,

	p_wip_entity_id 		IN 	NUMBER,
	p_operation_seq_num 		IN 	NUMBER,
	p_transaction_type 		IN 	NUMBER,
	p_transaction_date		IN	DATE,
	p_actual_start_date		IN	DATE,
	p_actual_end_date		IN	DATE,
	p_actual_duration		IN	NUMBER,
	p_shutdown_start_date		IN	DATE,
	p_shutdown_end_date		IN	DATE,
	p_reconciliation_code		IN	VARCHAR2,
	p_attribute_category		IN	VARCHAR2	:= NULL,
	p_attribute1			IN	VARCHAR2	:= NULL,
	p_attribute2			IN	VARCHAR2	:= NULL,
	p_attribute3			IN	VARCHAR2	:= NULL,
	p_attribute4			IN	VARCHAR2	:= NULL,
	p_attribute5			IN	VARCHAR2	:= NULL,
	p_attribute6			IN	VARCHAR2	:= NULL,
	p_attribute7			IN	VARCHAR2	:= NULL,
	p_attribute8			IN	VARCHAR2	:= NULL,
	p_attribute9			IN	VARCHAR2	:= NULL,
	p_attribute10			IN	VARCHAR2	:= NULL,
	p_attribute11			IN	VARCHAR2	:= NULL,
	p_attribute12			IN	VARCHAR2	:= NULL,
	p_attribute13			IN	VARCHAR2	:= NULL,
	p_attribute14			IN	VARCHAR2	:= NULL,
	p_attribute15			IN	VARCHAR2	:= NULL,
    p_qa_collection_id              IN      NUMBER,
    p_vendor_id             IN  NUMBER      := NULL,
    p_vendor_site_id        IN  NUMBER      := NULL,
	p_vendor_contact_id     IN  NUMBER      := NULL,
	p_reason_id             IN  NUMBER      := NULL,
	p_reference             IN  VARCHAR2    := NULL
) IS

l_op_completed 		VARCHAR2(1);

l_last_update_date	DATE;
l_last_updated_by	NUMBER;
l_last_update_login	NUMBER;
l_organization_id	NUMBER;
l_department_id		NUMBER;
l_asset_number		VARCHAR2(30);
l_asset_group_id	NUMBER;
l_asset_activity_id	NUMBER;
l_max_prior_end_date    DATE;

l_prev_uncomplete	NUMBER			:= 0;
l_prev_completed_after  NUMBER                  := 0;
l_status_id		NUMBER;
l_transaction_id	NUMBER;
l_validate_msg		VARCHAR2(100);
l_job_status        NUMBER ;
l_maint_obj_source     NUMBER;
l_workflow_enabled      VARCHAR2(1);
l_op_completed_event      VARCHAR2(240);
l_workflow_type                   NUMBER;
l_is_last_operation             VARCHAR2(1);
l_parameter_list   wf_parameter_list_t;
 l_event_key VARCHAR2(200);
 l_wf_event_seq NUMBER;
 l_op_sched_end_date            DATE;
 l_wip_entity_name                VARCHAR2(240);

--bug 3572376: pass following parameters to EAM_ASSET_STATUS_HISTORY
l_maintenance_object_type NUMBER := NULL ;
l_maintenance_object_id NUMBER := NULL ;
l_shutdown_type VARCHAR2(30) :=NULL;
CURSOR C IS
    select
	wo.organization_id,
	wo.department_id,
	wdj.asset_number,
	wdj.asset_group_id,
	wdj.primary_item_id ,
	wo.shutdown_type,
        wdj.maintenance_object_type,
        wdj.maintenance_object_id,
	wdj.maintenance_object_source,
	ewod.workflow_type,
	wo.last_unit_completion_date,
	we.wip_entity_name
    from
	wip_operations wo,
	wip_discrete_jobs wdj,
	eam_work_order_details ewod,
	wip_entities we
    where
	wdj.wip_entity_id = p_wip_entity_id AND
	wdj.wip_entity_id = wo.wip_entity_id AND
	wo.operation_seq_num = p_operation_seq_num
	AND wdj.wip_entity_id = ewod.wip_entity_id(+)
	AND wdj.wip_entity_id = we.wip_entity_id;

CURSOR CON IS
    select count(won.prior_operation)
    from wip_operation_networks won
    where
	won.wip_entity_id = p_wip_entity_id and
	won.next_operation = p_operation_seq_num and
    	exists (
		select 1 from wip_operations
		where
		    wip_entity_id = p_wip_entity_id and
		    operation_seq_num = won.prior_operation and
		    nvl(operation_completed,'N') <> 'Y'
    	);
CURSOR CON1 IS
    select count(won.next_operation)
    from wip_operation_networks won
    where
	won.wip_entity_id = p_wip_entity_id and
	won.prior_operation = p_operation_seq_num and
    	exists (
		select 1 from wip_operations
		where
		    wip_entity_id = p_wip_entity_id and
		    operation_seq_num = won.next_operation and
		    operation_completed = 'Y'
    	);


 --added for fix to bug 3543834:
 CURSOR CON3 IS
      select nvl(max(actual_end_date),sysdate-20000)
      from eam_op_completion_txns eoct,wip_operation_networks won
      where eoct.wip_entity_id = p_wip_entity_id
      and eoct.operation_seq_num=won.prior_operation
      and won.wip_entity_id=eoct.wip_entity_id
      and won.next_operation=p_operation_seq_num
      and transaction_type=1
       and transaction_id = (select max(transaction_id)
                          from eam_op_completion_txns
                          where wip_entity_id = p_wip_entity_id
                                and operation_seq_num = eoct.operation_seq_num
                                );



CURSOR CT IS
    select transaction_id from eam_op_completion_txns
    where transaction_id = l_transaction_id;
CURSOR CH IS
    select asset_status_id from eam_asset_status_history
    where asset_status_id = l_status_id;

BEGIN
    x_err_code := 0;
    if (p_transaction_type = 1) then
      l_validate_msg := 'EAM_PREV_OP_NOT_COMPLETED';
    else
      l_validate_msg := 'EAM_NEXT_OP_COMPLETED';
    end if;
    if (p_transaction_type = 1) then
      open CON;
      fetch CON into l_prev_uncomplete;
      if (CON%NOTFOUND) then
        l_prev_uncomplete := 0;
      end if;
      close CON;
    else
      open CON1;
      fetch CON1 into l_prev_uncomplete;
      if (CON1%NOTFOUND) then
        l_prev_uncomplete := 0;
      end if;
      close CON1;
    end if;

    IF (l_prev_uncomplete > 0) THEN
      x_err_code := 1;
      x_err_msg := l_validate_msg;
      fnd_message.set_name(
		'EAM',
		x_err_msg);
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF(p_transaction_type=1) THEN
	--changed code for 3543834:
	open CON3;
	fetch CON3 into l_max_prior_end_date;
	if(p_actual_start_date < l_max_prior_end_date) then
          fnd_message.set_name('EAM','EAM_PRIOR_OP_COMPLETED_AFTER');
	  fnd_message.set_token('MIN_START_DATE',TO_CHAR(l_max_prior_end_date,'dd-MON-yyyy HH24:MI:SS'));
          APP_EXCEPTION.Raise_Exception;
        end if;
	close CON3;
    END IF;

--code added for bug 5476770
	IF(p_shutdown_start_date > sysdate or p_shutdown_end_date > sysdate) THEN
		fnd_message.set_name('EAM','EAM_SHUTDOWN_DATE_IN_FUTURE');
		APP_EXCEPTION.Raise_Exception;
	END IF;
--end of code for bug 5476770


    IF ( p_transaction_type = 1 ) THEN
      l_op_completed := 'Y';
    ELSE
      l_op_completed := 'N';
    END IF;

     /* Fix for Bug 2050412 -- Uncomplete the work ordder before uncompleting an operation */

        IF (p_wip_entity_id is not null) and (l_op_completed = 'N') THEN
         select status_type
         into l_job_status
         from wip_discrete_jobs
         where wip_entity_id = p_wip_entity_id;

         IF (l_job_status = 4 ) THEN
          x_err_code := 1;
          x_err_msg := l_validate_msg;
          fnd_message.set_name(
    		'EAM',
    		'EAM_OP_COMP_WOCOMP_TEST');
	--following line also added as part of bug 5440339
	  fnd_message.set_token('OP_SEQ_NO', p_operation_seq_num);
          APP_EXCEPTION.Raise_Exception;
         END IF;

        END IF;

    /* End of Fix 2050412 */

        l_last_updated_by := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;
    l_last_update_date := sysdate;

    -- update TABLE wip_operations
    UPDATE wip_operations
      SET
        operation_completed 		= l_op_completed,
	quantity_completed		= 1,
        last_updated_by 		= l_last_updated_by,
        last_update_date 		= l_last_update_date,
        last_update_login 		= l_last_update_login
      WHERE
      	wip_entity_id = p_wip_entity_id AND
      	operation_seq_num = p_operation_seq_num;

    IF (SQL%NOTFOUND) THEN
      x_err_code := 1;
      x_err_msg := 'EAM_OP_NOT_FOUND';
      fnd_message.set_name(
		'EAM',
		x_err_msg);
      APP_EXCEPTION.Raise_Exception;
    END IF;

    OPEN C;
    FETCH C into
	l_organization_id,
	l_department_id,
	l_asset_number,
	l_asset_group_id,
	l_asset_activity_id,
	l_shutdown_type,
        l_maintenance_object_type,
        l_maintenance_object_id,
	l_maint_obj_source,
	l_workflow_type,
	l_op_sched_end_date,
	l_wip_entity_name;

    IF (C%NOTFOUND) THEN
      close C;
      x_err_code := 1;
      x_err_msg := 'EAM_OP_NOT_FOUND';
      fnd_message.set_name(
		'EAM',
		x_err_msg);
      APP_EXCEPTION.Raise_Exception;
    END IF;
    close C;

    select eam_op_completion_txns_s.nextval into l_transaction_id from dual;

    -- -insert into TABLE eam_op_completion_txns
    INSERT INTO EAM_OP_COMPLETION_TXNS(
	TRANSACTION_ID,
	TRANSACTION_DATE,
	TRANSACTION_TYPE,
	WIP_ENTITY_ID,
	ORGANIZATION_ID,
	OPERATION_SEQ_NUM,
	ACCT_PERIOD_ID,
	QA_COLLECTION_ID,
	REFERENCE,
	RECONCILIATION_CODE,
	DEPARTMENT_ID,
	---ASSET_GROUP_ID,
	--ASSET_NUMBER,
	ASSET_ACTIVITY_ID,
	ACTUAL_START_DATE,
	ACTUAL_END_DATE,
	ACTUAL_DURATION,
	VENDOR_ID,
	VENDOR_SITE_ID,
	VENDOR_CONTACT_ID,
	REASON_ID,
	TRANSACTION_REFERENCE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15

    ) VALUES (
	l_transaction_id,
	p_transaction_date,
	p_transaction_type,
	p_wip_entity_id,
	l_organization_id,
	p_operation_seq_num,
	NULL,
	p_qa_collection_id,
	NULL,
	p_reconciliation_code,
	l_department_id,
	--l_asset_group_id,
	--l_asset_number,
	l_asset_activity_id,
	decode(p_transaction_type,1,p_actual_start_date,2,null),
	decode(p_transaction_type,1,p_actual_end_date,2,null),
	decode(p_transaction_type,1,p_actual_duration,2,null),
	p_vendor_id,
	p_vendor_site_id,
	p_vendor_contact_id,
	p_reason_id,
	p_reference,
	l_last_updated_by,
	l_last_update_date,
	l_last_updated_by,
	l_last_update_date,
	l_last_update_login,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15
    );

    OPEN CT;
    fetch CT into l_transaction_id;
    IF (CT%NOTFOUND) THEN
      close CT;
      x_err_code := 1;
      x_err_msg := 'EAM_OP_TXN_NOT_FOUND';
      fnd_message.set_name(
		'EAM',
		x_err_msg);
      APP_EXCEPTION.Raise_Exception;
    END IF;
    close CT;

    -- Enhancemnet Bug 3852846
    IF NVL(to_number(l_shutdown_type),1) = 2 THEN
	    UPDATE eam_asset_status_history
	    SET enable_flag = 'N'
   		, last_update_date  = SYSDATE
		, last_updated_by   = FND_GLOBAL.user_id
                , last_update_login = FND_GLOBAL.login_id
	    WHERE organization_id = l_organization_id
	    AND   wip_entity_id = p_wip_entity_id
	    AND	  operation_seq_num = p_operation_seq_num
	    AND   enable_flag = 'Y' OR enable_flag IS NULL;
    END IF;

  -- SHUTDOWN History
  if (p_shutdown_start_date is not null) or
     (p_shutdown_end_date is not null) then

    select eam_asset_status_history_s.nextval into l_status_id from dual;

    INSERT INTO EAM_ASSET_STATUS_HISTORY(
	ASSET_STATUS_ID,
	ASSET_GROUP_ID,
	ASSET_NUMBER,
	ORGANIZATION_ID,
	START_DATE,
	END_DATE,
	WIP_ENTITY_ID,
	OPERATION_SEQ_NUM,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15
	,MAINTENANCE_OBJECT_TYPE
	,MAINTENANCE_OBJECT_ID
	,enable_flag		-- Enhancemnet Bug 3852846

    ) VALUES (
	l_status_id,
	l_asset_group_id,
	l_asset_number,
	l_organization_id,
	p_shutdown_start_date,
	p_shutdown_end_date,
	p_wip_entity_id,
	p_operation_seq_num,
	l_last_updated_by,
	l_last_update_date,
	l_last_updated_by,
	l_last_update_date,
	l_last_update_login,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15
        ,l_maintenance_object_type
	,l_maintenance_object_id
	,'Y'			-- Enhancemnet Bug 3852846
    );

    OPEN CH;
    IF (CH%NOTFOUND) THEN
      CLOSE CH;
      x_err_code := 1;
      x_err_msg := 'EAM_OP_HISTORY_NOT_FOUND';
      fnd_message.set_name(
		'EAM',
		x_err_msg);
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE CH;
   end if; -- history insert

   l_workflow_enabled:= Is_Workflow_Enabled(l_maint_obj_source,l_organization_id);
   l_op_completed_event := 'oracle.apps.eam.workorder.operation.completed';

   IF(l_workflow_enabled='Y' AND (p_transaction_type = 1)
		            AND (Wf_Event.TEST(l_op_completed_event)<>'NONE' )   ) THEN

                                                                                    l_is_last_operation := 'N';
										    select DECODE(count(won.next_operation),0,'Y','N')
										    INTO l_is_last_operation
										    from wip_operation_networks won
										    where won.wip_entity_id =  p_wip_entity_id and
										    won.prior_operation =p_operation_seq_num;

										      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
										      INTO l_wf_event_seq
										      FROM DUAL;

										      l_parameter_list := wf_parameter_list_t();

										    l_event_key := TO_CHAR(l_wf_event_seq);
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Op Completed  event','Building parameter list');
										    -- Add Parameters
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
													    p_value => TO_CHAR(p_wip_entity_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
													    p_value =>l_wip_entity_name,
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
													    p_value => TO_CHAR(l_organization_id),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'ACTUAL_COMPLETION_DATE',
													    p_value => TO_CHAR(p_actual_end_date),
													    p_parameterlist => l_parameter_list);
										   Wf_Event.AddParameterToList(p_name =>'SCHEDULED_COMPLETION_DATE',
													    p_value => TO_CHAR(l_op_sched_end_date),
													    p_parameterlist => l_parameter_list);
										    Wf_Event.AddParameterToList(p_name =>'IS_LAST_OPERATION',
													    p_value => l_is_last_operation,
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
													    p_value => TO_CHAR(l_workflow_type),
													    p_parameterlist => l_parameter_list);
										     Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
													    p_value =>FND_GLOBAL.USER_NAME ,
													    p_parameterlist => l_parameter_list);

										    Wf_Event.Raise(	p_event_name => l_op_completed_event,
													p_event_key => l_event_key,
													p_parameters => l_parameter_list);
										    l_parameter_list.DELETE;
										    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Operation Completed Event','After raising event');

		END IF;   --end of check for raising op complete event


END op_comp;

PROCEDURE get_op_defaults
      (p_wip_entity_id                IN   NUMBER,
       p_tx_type                      IN   NUMBER,
       p_operation_seq_num            IN   NUMBER,
       x_start_date                   out NOCOPY date,
       x_end_date                     out NOCOPY date,
       x_return_status                out NOCOPY varchar2,
       x_msg_data                     out NOCOPY varchar2
       )
IS
   l_api_name constant varchar2(30) := 'get_op_defaults';
   l_max_prior_end_date        DATE;
   l_scheduled_start_date      DATE;
   l_scheduled_end_date        DATE;
begin
    eam_debug.init_err_stack('eam_workorders_jsp.' || l_api_name);

    select first_unit_start_date,last_unit_completion_date
    into l_scheduled_start_date,l_scheduled_end_date
    from wip_operations
    where wip_entity_id=p_wip_entity_id
    and operation_seq_num=p_operation_seq_num;


    if (p_tx_type =  1) then --completion
      x_msg_data := 'Completion: ';


      begin
          --fix for 3543834.changed queries to fetch correct data
      select max(actual_end_date)
      into l_max_prior_end_date
      from eam_op_completion_txns eoct,wip_operation_networks won
      where eoct.wip_entity_id = p_wip_entity_id
      and eoct.operation_seq_num=won.prior_operation
      and won.wip_entity_id=eoct.wip_entity_id
      and won.next_operation=p_operation_seq_num
      and transaction_type=1
       and transaction_id = (select max(transaction_id)
                          from eam_op_completion_txns
                          where wip_entity_id = p_wip_entity_id
                                and operation_seq_num = eoct.operation_seq_num
                                );

      end;
      if((l_max_prior_end_date is not null) and (l_scheduled_start_date <l_max_prior_end_date)) then
         x_start_date := l_max_prior_end_date;
	 x_end_date   := sysdate;
      else
        x_start_date := l_scheduled_start_date;
        x_end_date   := l_scheduled_end_date;
      end if;
    end if; -- of p_tx_type = 1
    if (p_tx_type =  2) then --uncompletion
      x_msg_data :=  'Uncompletion: ';
       x_start_date := l_scheduled_start_date;
        x_end_date   := l_scheduled_end_date;
    end if;

    IF(x_start_date > SYSDATE) THEN
        x_start_date := SYSDATE;
	x_end_date   :=  SYSDATE;
   ELSIF (x_end_date > SYSDATE) THEN
         x_end_date   :=  SYSDATE;
   END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;

  exception
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := x_msg_data || ' UNEXPECTED ERROR: ' || SQLERRM;
      eam_debug.init_err_stack('Exception has occured in ' || l_api_name);
end get_op_defaults;


END eam_op_comp;

/
