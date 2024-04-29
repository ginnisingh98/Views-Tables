--------------------------------------------------------
--  DDL for Package Body EAM_JOBCLOSE_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_JOBCLOSE_PRIV" AS
/* $Header: EAMJCLPB.pls 120.2.12010000.3 2010/01/25 09:17:54 vchidura ship $ */


PROCEDURE RAISE_WORKFLOW_STATUS_CHANGED
(p_wip_entity_id					 IN   NUMBER,
  p_wip_entity_name				 IN   VARCHAR2,
  p_organization_id				 IN    NUMBER,
  p_new_status					 IN    NUMBER,
  p_old_system_status			IN   NUMBER,
  p_old_wo_status				IN   NUMBER,
  p_workflow_type                                 IN    NUMBER,
  x_return_status                                   OUT   NOCOPY VARCHAR2
  )
  IS
	 l_status_changed_event VARCHAR2(240);
	 l_event_name VARCHAR2(240);
	l_parameter_list   wf_parameter_list_t;
	 l_event_key VARCHAR2(200);
	 l_wf_event_seq NUMBER;
	 l_estimation_status NUMBER;
	 l_cost_estimate NUMBER;
	 l_return_status    VARCHAR2(1);
	 l_err_text      VARCHAR2(2000);
	 l_msg_count     NUMBER;

  BEGIN

        l_status_changed_event := 'oracle.apps.eam.workorder.status.changed';

            IF   (WF_EVENT.TEST(l_status_changed_event) <> 'NONE'  --if status change event enabled
                          ) THEN
                                                                                      SELECT EAM_WORKFLOW_EVENT_S.NEXTVAL
                                                                                      INTO l_wf_event_seq
                                                                                      FROM DUAL;

                                                                                      l_parameter_list := wf_parameter_list_t();
                                                                                      l_event_name := l_status_changed_event;

                                                                                    l_event_key := TO_CHAR(l_wf_event_seq);
                                                                                    WF_CORE.CONTEXT('Enterprise Asset Management...','Work Order Status change event','Building parameter list');
                                                                                    -- Add Parameters
                                                                                    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_ID',
                                                                                                            p_value => TO_CHAR(p_wip_entity_id),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Event.AddParameterToList(p_name =>'WIP_ENTITY_NAME',
                                                                                                            p_value =>p_wip_entity_name,
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Event.AddParameterToList(p_name =>'ORGANIZATION_ID',
                                                                                                            p_value => TO_CHAR(p_organization_id),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Event.AddParameterToList(p_name =>'NEW_SYSTEM_STATUS',
                                                                                                            p_value => TO_CHAR(p_new_status),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Event.AddParameterToList(p_name =>'NEW_WO_STATUS',
                                                                                                            p_value => TO_CHAR(p_new_status),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                   Wf_Event.AddParameterToList(p_name =>'OLD_SYSTEM_STATUS',
                                                                                                            p_value => TO_CHAR(p_old_system_status),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Event.AddParameterToList(p_name =>'OLD_WO_STATUS',
                                                                                                            p_value => TO_CHAR(p_old_wo_status),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                      Wf_Event.AddParameterToList(p_name =>'WORKFLOW_TYPE',
                                                                                                            p_value => TO_CHAR(p_workflow_type),
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                      Wf_Event.AddParameterToList(p_name =>'REQUESTOR',
                                                                                                            p_value =>FND_GLOBAL.USER_NAME ,
                                                                                                            p_parameterlist => l_parameter_list);
                                                                                    Wf_Core.Context('Enterprise Asset Management...','Work Order Staus Changed Event','Raising event');

                                                                                    Wf_Event.Raise(        p_event_name => l_event_name,
                                                                                                        p_event_key => l_event_key,
                                                                                                        p_parameters => l_parameter_list);
                                                                                    l_parameter_list.DELETE;
                                                                                     WF_CORE.CONTEXT('Enterprise Asset Management..','Work Order Status Changed Event','After raising event');
                        END IF;   --end of check for status change event


  END RAISE_WORKFLOW_STATUS_CHANGED;


/**************************************************************************
*   PROCEDURE TO WAIT FOR CONC. PROGRAM.
*   IT WILL RETURN ONLY AFTER THE CONC. PROGRAM COMPLETES
/**************************************************************************/

  PROCEDURE WAIT_CONC_PROGRAM(p_request_id in number,
                           errbuf       out NOCOPY varchar2,
                           retcode      out NOCOPY number) is
    l_call_status      boolean;
    l_phase            varchar2(80);
    l_status           varchar2(80);
    l_dev_phase        varchar2(80);
    l_dev_status       varchar2(80);
    l_message          varchar2(240);

    l_counter          number := 0;
  BEGIN
    LOOP
      l_call_status:= FND_CONCURRENT.WAIT_FOR_REQUEST
                    ( p_request_id,
                      10,
                      -1,
                      l_phase,
                      l_status,
                      l_dev_phase,
                      l_dev_status,
                      l_message);
      exit when l_call_status=false;

      if (l_dev_phase='COMPLETE') then
        if (l_dev_status = 'NORMAL') then
          retcode := -1;
        elsif (l_dev_status = 'WARNING') then
          retcode := 1;
        else
          retcode := 2;
        end if;
        errbuf := l_message;
        return;
      end if;

      l_counter := l_counter + 1;
      exit when l_counter >= 2;

    end loop;

    retcode := 2;
    return ;
END WAIT_CONC_PROGRAM;



/* Wrapper function which will be called by the concurrent manager */
procedure EAM_CLOSE_MGR
(
      ERRBUF               OUT NOCOPY VARCHAR2 ,
      RETCODE              OUT NOCOPY VARCHAR2 ,
      p_organization_id     IN  NUMBER    ,
      p_class_type          IN  VARCHAR2  ,
      p_from_class          IN  VARCHAR2  ,
      p_to_class            IN  VARCHAR2  ,
      p_from_job            IN  VARCHAR2  ,
      p_to_job              IN  VARCHAR2  ,
      p_from_release_date   IN  VARCHAR2  ,
      p_to_release_date     IN  VARCHAR2  ,
      p_from_start_date     IN  VARCHAR2  ,
      p_to_start_date       IN  VARCHAR2  ,
      p_from_completion_date IN VARCHAR2  ,
      p_to_completion_date  IN  VARCHAR2  ,
      p_status              IN  VARCHAR2  ,
      p_group_id            IN  NUMBER  ,
      p_select_jobs         IN  NUMBER  ,
      p_exclude_reserved_jobs IN  VARCHAR2  ,
      p_uncompleted_jobs    IN VARCHAR2,
      p_exclude_pending_txn_jobs IN  VARCHAR2  ,
      p_report_type         IN  VARCHAR2 ,
      p_act_close_date      IN  VARCHAR2
)
IS
  l_returnstatus         VARCHAR2(1) ;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_warning               NUMBER;
  l_req_id                  NUMBER;
  l_user_id               NUMBER;
  l_resp_id               NUMBER;
   l_resp_appl_id       NUMBER;

  TYPE WORKORDER_REC IS RECORD
     (wip_entity_id				NUMBER,
       organization_id                     NUMBER,
       wip_entity_name			VARCHAR2(240),
       old_system_status              NUMBER,
       old_wo_status                       NUMBER,
       workflow_type                        NUMBER
       );

TYPE   WORKORDER_TAB is TABLE OF workorder_rec
      INDEX BY BINARY_INTEGER;
  l_workorder_tbl         WORKORDER_TAB;
  l_wo_count            NUMBER;
  l_new_status_type        NUMBER;
  l_return_status                VARCHAR2(1);

  CURSOR workorders
IS
   SELECT wdj.wip_entity_id, we.wip_entity_name,
        wdj.status_type,wdj.organization_id,ewod.user_defined_status_id,ewod.workflow_type
   FROM wip_discrete_jobs wdj, wip_dj_close_temp wdct,eam_work_order_details ewod,wip_entities we
   WHERE wdct.group_id = p_group_id
   and wdct.wip_entity_id = wdj.wip_entity_id
   and wdct.organization_id  = wdj.organization_id
   and wdj.wip_entity_id = ewod.wip_entity_id
   and wdj.organization_id   = ewod.organization_id
   and wdj.wip_entity_id = we.wip_entity_id
   and wdj.organization_id   = we.organization_id;

BEGIN

  RETCODE := 0 ; -- success
                                               ----Commenting code as this is now being called from WIP. See bug 6718091
					      /* l_wo_count   :=  0;
					       FOR l_workorders_rec IN workorders LOOP
													     l_wo_count      :=           l_wo_count +1;
													     l_workorder_tbl(l_wo_count).wip_entity_id   :=  l_workorders_rec.wip_entity_id;
													     l_workorder_tbl(l_wo_count).wip_entity_name   :=  l_workorders_rec.wip_entity_name;
													     l_workorder_tbl(l_wo_count).organization_id   :=  l_workorders_rec.organization_id;
													     l_workorder_tbl(l_wo_count).old_system_status   :=  l_workorders_rec.status_type;
													     l_workorder_tbl(l_wo_count).old_wo_status   :=  l_workorders_rec.user_defined_status_id;
													     l_workorder_tbl(l_wo_count).workflow_type   :=  l_workorders_rec.workflow_type;

													   RAISE_WORKFLOW_STATUS_CHANGED
														(p_wip_entity_id			=>   l_workorder_tbl(l_wo_count).wip_entity_id,
														  p_wip_entity_name		=>   l_workorder_tbl(l_wo_count).wip_entity_name,
														  p_organization_id		=>   l_workorder_tbl(l_wo_count).organization_id,
														  p_new_status			=>     14,
														  p_old_system_status	=>   l_workorder_tbl(l_wo_count).old_system_status,
														  p_old_wo_status		=>   l_workorder_tbl(l_wo_count).old_wo_status,
														  p_workflow_type                 =>   l_workorder_tbl(l_wo_count).workflow_type,
														  x_return_status                  =>    l_return_status
														  );

														IF (NVL(l_return_status,'S') <> 'S') THEN
														      RETCODE := 2;
														      errbuf := SQLERRM;
														      RETURN;
														  END IF;

														  EAM_TEXT_UTIL.PROCESS_WO_EVENT
														     (
															  p_event					=> 'UPDATE',
															  p_wip_entity_id				 =>l_workorder_tbl(l_wo_count).wip_entity_id,
															  p_organization_id			=>l_workorder_tbl(l_wo_count).organization_id,
															  p_last_update_date			=> SYSDATE,
															  p_last_updated_by			=> FND_GLOBAL.user_id,
															  p_last_update_login			 =>FND_GLOBAL.login_id
														     );


						END LOOP;

                                                 COMMIT;*/

--Launch concurrent program to close work orders

                                                        l_user_id       := fnd_global.user_id;
                                                        l_resp_id      :=  fnd_global.resp_id;
														  l_resp_appl_id  := fnd_global.resp_appl_id;

                                                        IF (l_user_id IS NOT NULL AND l_resp_id IS NOT NULL) THEN
                                                                 FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id,l_resp_appl_id,0);
                                                          END IF;

							  fnd_file.put_line(FND_FILE.LOG,'Before invoking WIP conc. program');

                                                          l_req_id := fnd_request.submit_request('WIP', 'WICDCL', NULL,
															NULL,
															FALSE,
															p_organization_id,'','','','','','','','','',
															'','','',to_char(p_group_id),'2','','','',p_report_type,'',
															chr(0),'','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','',
															'','','','','','','','','','');


                                                           COMMIT ;
							  fnd_file.put_line(FND_FILE.LOG,'After invoking WIP conc. program..request_id.'||l_req_id);

							  IF (l_req_id = 0) THEN
							      RETCODE := 2;
							      errbuf := SQLERRM;
							      RETURN;
							  END IF;

					WAIT_CONC_PROGRAM(l_req_id,ERRBUF,RETCODE);

					  FND_FILE.PUT_LINE(FND_FILE.LOG,'WIP Close concurrent program  : '||retcode);

                                           ----Commenting code as this is now being called from WIP. See bug 6718091

					/*  FOR i IN l_workorder_tbl.FIRST..l_workorder_tbl.LAST     LOOP
								     BEGIN
											SELECT status_type
											INTO l_new_status_type
											FROM WIP_DISCRETE_JOBS
											WHERE wip_entity_id   = l_workorder_tbl(i).wip_entity_id
											AND  organization_id = l_workorder_tbl(i).organization_id;

											IF(l_new_status_type <> 14) THEN

																				UPDATE EAM_WORK_ORDER_DETAILS
																				SET USER_DEFINED_STATUS_ID = l_new_status_type,
																					 last_update_date                       =   SYSDATE,
																					  last_updated_by                       =  FND_GLOBAL.user_id,
																					  last_update_login                    =  FND_GLOBAL.login_id
																				WHERE wip_entity_id   = l_workorder_tbl(i).wip_entity_id
																				AND  organization_id = l_workorder_tbl(i).organization_id;



       						                                                                                                             COMMIT;


																				RAISE_WORKFLOW_STATUS_CHANGED
																							(p_wip_entity_id			=>   l_workorder_tbl(i).wip_entity_id,
																							  p_wip_entity_name		=>   l_workorder_tbl(i).wip_entity_name,
																							  p_organization_id		=>   l_workorder_tbl(i).organization_id,
																							  p_new_status			=>     l_new_status_type,
																							  p_old_system_status	=>   14,
																							  p_old_wo_status		=>   14,
																							  p_workflow_type                 =>   l_workorder_tbl(i).workflow_type,
																							  x_return_status                  =>    l_return_status
																							  );

																							IF (NVL(l_return_status,'S') <> 'S') THEN
																								FND_FILE.PUT_LINE(FND_FILE.LOG,'Raising of workflow has failed with an error');
																							  END IF;

																				 EAM_TEXT_UTIL.PROCESS_WO_EVENT
																							     (
																								  p_event					=> 'UPDATE',
																								  p_wip_entity_id				 =>l_workorder_tbl(i).wip_entity_id,
																								  p_organization_id			=>l_workorder_tbl(i).organization_id,
																								  p_last_update_date			=> SYSDATE,
																								  p_last_updated_by			=> FND_GLOBAL.user_id,
																								  p_last_update_login			 =>FND_GLOBAL.login_id
																							     );
												   END IF;     --end of check for status changed

								     EXCEPTION
								          WHEN NO_DATA_FOUND THEN
									             NULL;
								     END;
						END LOOP;

						COMMIT;*/

					  if (RETCODE <> -1 ) then
					      FND_FILE.PUT_LINE(FND_FILE.LOG,'Wip close concurrent program has errored or has a warning');
					      errbuf := fnd_message.get;
					      RETURN;
					   ELSE
					         retcode:= 0;
					  end if;


EXCEPTION
  WHEN others THEN
     retcode := 2; -- error
     errbuf := SQLERRM;

END EAM_CLOSE_MGR ;



PROCEDURE EAM_CLOSE_WO
(
   p_submission_date          IN    DATE,
   p_organization_id               IN    NUMBER,
   p_group_id                           IN    NUMBER,
   p_select_jobs                      IN    NUMBER,
   p_report_type                       IN     VARCHAR2,
   x_request_id                        OUT NOCOPY    NUMBER
   )
 IS
 BEGIN

       x_request_id := fnd_request.submit_request('EAM', 'EAMCDCL', '',
	to_char(p_submission_date, 'YYYY/MM/DD HH24:MI'),
	FALSE,
	to_char(p_organization_id),'','','','','','','','','',
        '','','',to_char(p_group_id),to_char(p_select_jobs),'','','',p_report_type,'',
	chr(0),'','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','',
	'','','','','','','','','','');

 END EAM_CLOSE_WO;

END EAM_JOBCLOSE_PRIV ;

/
