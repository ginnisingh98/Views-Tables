--------------------------------------------------------
--  DDL for Package Body WIP_JOB_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOB_DETAILS" as
/* $Header: wipjdldb.pls 120.2 2005/12/16 13:39:31 yulin noship $ */


Procedure Load_All_Details( p_group_id in number,
                            p_parent_header_id in number,
                            p_std_alone in integer,
                            x_err_code out nocopy varchar2,
                            x_err_msg  out nocopy varchar2,
                            x_return_status out nocopy varchar2 ) IS

 Cursor Job_Cur IS
 select distinct wip_entity_id,
         organization_id
  from wip_job_dtls_interface
  where group_id = p_group_id
  and   parent_header_id = p_parent_header_id
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING) ;

 Cursor wdj_cur IS
 select distinct wip_entity_id,
         organization_id
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING) ;

 Cursor Oper_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_OPERATION
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING) ;

 Cursor Res_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_RESOURCE
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING ,WIP_CONSTANTS.WARNING);

 Cursor ResInst_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING ,WIP_CONSTANTS.WARNING);

 Cursor Req_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1 )
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING);

 Cursor Res_Usage_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type in (WIP_JOB_DETAILS.WIP_RES_USAGE,
                     WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING);

 Cursor SubRes_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_SUB_RES
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING ,WIP_CONSTANTS.WARNING);

 Cursor Op_Link_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_OP_LINK
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING ,WIP_CONSTANTS.WARNING);

 Cursor Serials_Cur (p_wip_entity_id number, p_organization_id number) IS
 select distinct wip_entity_id,
             organization_id,
         load_type, substitution_type
  from wip_job_dtls_interface
  where  group_id = p_group_id
  and ((p_std_alone = 0
  and parent_header_id = p_parent_header_id)
  OR  p_std_alone = 1)
  and  wip_entity_id = p_wip_entity_id
  and  organization_id = p_organization_id
  and  load_type = WIP_JOB_DETAILS.WIP_SERIAL
  and   process_phase = WIP_CONSTANTS.ML_VALIDATION
  and   process_status IN (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING);

  x_count number;

  cur_job job_cur%ROWTYPE ;

  l_dummy2 VARCHAR2(1);
  l_logLevel number;

BEGIN

  begin
    x_err_code := NULL;
    x_err_msg  := NULL;
    x_count := 0;
    std_alone := p_std_alone;
    l_logLevel := fnd_log.g_current_runtime_level;

    /** p_group_id can not be null **/
       IF p_group_id IS NULL THEN
           x_err_msg := 'ERROR: You have to specify a group_id to load job details.';
           x_err_code := -999;
           x_return_status := FND_API.G_RET_STS_ERROR;
           return;
       END IF;

       IF p_std_alone = 0 AND p_parent_header_id IS NULL THEN
          x_err_msg := 'ERROR: You have to give a parent header id to specify the job.';
          x_err_code := -999;
          x_return_status := FND_API.G_RET_STS_ERROR;
          return;
        END IF;


        /********************************************************************
        ***** for ALL jobs in the given group that has PENDING status ******
        ********************************************************************/
        /* set process_status = RUNNING and generate new unique interface_id*/
        WIP_JDI_Utils.begin_processing_request(p_group_id,
                                                p_parent_header_id,
                                                x_err_code,
                                                x_err_msg,
                                                x_return_status);

        default_wip_entity_id(p_group_id,
                              p_parent_header_id,
                              x_err_code,
                              x_err_msg,
                              x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           return;

        END IF;

    /* Following if condition is added for Bug#3636378 */
    IF p_std_alone = 1 then
       open wdj_cur ;
    ELSE
       open job_cur ;
    END IF ;

    LOOP
     /* Following if condition is added for Bug#3636378 */
     IF p_std_alone = 1 then
       fetch wdj_cur into cur_job ;
       exit when wdj_cur%NOTFOUND ;

       /* bug 4650624 */
       wip_jsi_utils.current_interface_id := null;
      ELSE
       fetch job_cur into  cur_job ;
       exit when job_cur%NOTFOUND ;

       /* bug 4650624 */
       select interface_id
       into wip_jsi_utils.current_interface_id
       from wip_job_schedule_interface
       where group_id = p_group_id
       and header_id = p_parent_header_id;

     END IF ;

     /*** Validate general info. for this job ***/
        WIP_JOB_DTLS_VALIDATIONS.Jobs(p_group_id,
                                      p_parent_header_id);

        WIP_JOB_DTLS_VALIDATIONS.Job_Status(p_group_id,
                                            p_parent_header_id);

        WIP_JOB_DTLS_VALIDATIONS.Is_Firm(p_group_id,
                                         p_parent_header_id);

         WIP_JOB_DTLS_VALIDATIONS.Load_Sub_Types (p_group_id,
         					  p_parent_header_id,
                                                  cur_job.wip_entity_id,
                                                  cur_job.organization_id);

         WIP_JOB_DTLS_VALIDATIONS.Last_Updated_By(P_Group_Id,
         					  p_parent_header_id,
                                                  cur_job.wip_entity_id,
                                                  cur_job.organization_id);
         WIP_JOB_DTLS_VALIDATIONS.Created_By(P_Group_Id,
         				     p_parent_header_id,
                                             cur_job.wip_entity_id,
                                             cur_job.organization_id);

       FOR l_cur IN OPER_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

         WIP_OPERATION_DEFAULT.Default_Operations
                            (p_group_id,
                             p_parent_header_id,
                             l_cur.wip_entity_id,
                             l_cur.organization_id,
                             l_cur.substitution_type ,
                             x_err_code ,
                             x_err_msg ,
                             x_return_status );

         /* default operation records */

       IF l_cur.substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN

         WIP_OPERATION_VALIDATE.Add_Operation(p_group_id,
                                               p_parent_header_id,
                                               l_cur.wip_entity_id,
                                               l_cur.organization_id,
                                               x_err_code, x_err_msg,
                                               x_return_status);
          /* validate operation records */

        ELSIF l_cur.substitution_type = WIP_JOB_DETAILS.WIP_CHANGE THEN

         WIP_OPERATION_VALIDATE.Change_Operation(p_group_id,
                                                 p_parent_header_id,
                                                 l_cur.wip_entity_id,
                                                 l_cur.organization_id,
                                                 x_err_code, x_err_msg,
                                                 x_return_status);

        END IF;  /* end of operation validation */
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
      				p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


           WIP_JOB_DTLS_SUBSTITUTIONS.ADD_OPERATION
                         (p_group_id,
                          cur_job.wip_entity_id,
                          cur_job.organization_id,
                          x_err_code ,
                          x_err_msg,
                          x_return_status);

            WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_OPERATION
                         (p_group_id,
                          cur_job.wip_entity_id,
                          cur_job.organization_id,
                          x_err_code ,
                          x_err_msg,
                          x_return_status);

         /*************END PROCESSING OPERATIONS********************/

     WIP_JOB_DTLS_VALIDATIONS.OP_Seq_Num ( p_group_id,
                                           p_parent_header_id,
                                          cur_job.wip_entity_id,
                                          cur_job.organization_id);

     FOR l_cur IN RES_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

       IF l_cur.substitution_type = WIP_DELETE THEN
         WIP_RESOURCE_VALIDATIONS.Delete_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_ADD THEN
                       WIP_RESOURCE_VALIDATIONS.Add_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_CHANGE THEN
                       WIP_RESOURCE_VALIDATIONS.Change_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);
       END IF;
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
      				p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


           WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

           WIP_JOB_DTLS_SUBSTITUTIONS.ADD_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);
           WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

     FOR l_cur IN RESINST_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

       IF l_cur.substitution_type = WIP_DELETE THEN
         WIP_RES_INST_VALIDATIONS.Delete_Resource_Instance(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type,
                                        x_err_code,
                                        x_err_msg);
         if (l_logLevel <= wip_constants.trace_logging) then
           IF x_err_code IS NOT NULL THEN
             wip_logger.log(x_err_code, l_dummy2);
             wip_logger.log(x_err_msg, l_dummy2);
           end if;
         end if;

       ELSIF l_cur.substitution_type = WIP_ADD THEN
         WIP_RES_INST_VALIDATIONS.Add_Resource_Instance(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type,
                                        x_err_code,
                                        x_err_msg);
         if (l_logLevel <= wip_constants.trace_logging) then
           IF x_err_code IS NOT NULL THEN
             wip_logger.log(x_err_code, l_dummy2);
             wip_logger.log(x_err_msg, l_dummy2);
           end if;
         end if;

       ELSIF l_cur.substitution_type = WIP_CHANGE THEN
         WIP_RES_INST_VALIDATIONS.Change_Resource_Instance(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type,
                                        x_err_code,
                                        x_err_msg);
         if (l_logLevel <= wip_constants.trace_logging) then
           IF x_err_code IS NOT NULL THEN
             wip_logger.log(x_err_code, l_dummy2);
             wip_logger.log(x_err_msg, l_dummy2);
           end if;
         end if;
       END IF;
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
                                p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


           WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_RESOURCE_INSTANCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        WIP_JOB_DETAILS.WIP_DELETE,
                                        x_err_code,
                                        x_err_msg);

           WIP_JOB_DTLS_SUBSTITUTIONS.ADD_RESOURCE_INSTANCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);
           WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_RESOURCE_INSTANCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
                                p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);

    /****** MATERAIL REQUIREMENTS processing  ******************/
     FOR l_cur IN REQ_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

        IF l_cur.substitution_type = WIP_DELETE THEN

           WIP_REQUIREMENT_VALIDATIONS.Delete_Req(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);
        ELSIF l_cur.substitution_type = WIP_ADD THEN

                       WIP_REQUIREMENT_VALIDATIONS.Add_Req(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);
        ELSIF l_cur.substitution_type = WIP_CHANGE THEN

                       WIP_REQUIREMENT_VALIDATIONS.Change_Req(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

        END IF;           /* End requirement processing */
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
      				p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


         WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_REQUIREMENT(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

         WIP_JOB_DTLS_SUBSTITUTIONS.ADD_REQUIREMENT(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

         WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_REQUIREMENT(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);


  /************** Processing resource usage **********************/
     FOR l_cur IN RES_USAGE_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

        WIP_RES_USAGE_DEFAULT.Default_Resource_Usages
                                     (p_group_id,
                                      p_parent_header_id,
                                      l_cur.wip_entity_id,
                                      l_cur.organization_id,
                                      x_err_code,
                                      x_err_msg,
                                      x_return_status);

        WIP_RES_USAGE_VALIDATE.Validate_Usage(p_group_id,
                                      l_cur.wip_entity_id,
                                      l_cur.organization_id,
                                      x_err_code,
                                      x_err_msg,
                                      x_return_status);

      END LOOP; /* End req_cur loop for validation */

     /**** Error out nocopy the whole job if any validations failed ****/
        WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
        			p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


        WIP_JOB_DTLS_SUBSTITUTIONS.Substitution_Res_Usages
                        (p_group_id,
                         cur_job.wip_entity_id,
                         cur_job.organization_id,
                         x_err_code ,
                         x_err_msg,
                         x_return_status);

     /********* Substitute Resources ********/
     WIP_JOB_DTLS_VALIDATIONS.OP_Seq_Num ( p_group_id,
                                           p_parent_header_id,
                                          cur_job.wip_entity_id,
                                          cur_job.organization_id);

     FOR l_cur IN SUBRES_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

       IF l_cur.substitution_type = WIP_DELETE THEN
         WIP_RESOURCE_VALIDATIONS.Delete_Sub_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_ADD THEN
                       WIP_RESOURCE_VALIDATIONS.Add_Sub_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_CHANGE THEN
                       WIP_RESOURCE_VALIDATIONS.Change_Sub_Resource(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);
       END IF;
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
      WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
      				p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);


           WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_SUB_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

           WIP_JOB_DTLS_SUBSTITUTIONS.ADD_SUB_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);
           WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_SUB_RESOURCE(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

     /** At this point, both resource and sub res changes have been done.
         See if the sum of these changes created any violations of the
         rules regarding sub groups **/
     WIP_RESOURCE_VALIDATIONS.Check_Sub_Groups(p_group_id,
                                               cur_job.organization_id,
                                               cur_job.wip_entity_id);

/****** begin OPERATION LINKS processing  ******************/
     FOR l_cur IN OP_LINK_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP
/*      WIP_JOB_DTLS_VALIDATIONS.OP_Seq_Num ( p_group_id,
                                           p_parent_header_id,
                                          cur_job.wip_entity_id,
                                          cur_job.organization_id);
*/

        IF l_cur.substitution_type = WIP_DELETE THEN

           WIP_OP_LINK_VALIDATIONS.Delete_Op_Link(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type,
                                        x_err_code,
                                        x_err_msg,
                                        x_return_status);

       ELSIF l_cur.substitution_type = WIP_ADD THEN

                       WIP_OP_LINK_VALIDATIONS.Add_Op_Link(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type,
                                        x_err_code,
                                        x_err_msg,
                                        x_return_status);
        END IF;
     END LOOP;

/**** Error out nocopy the whole job if any validations failed ****/
     WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
     				p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);

-- wipjdsts.pls
         WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_OP_LINK(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

         WIP_JOB_DTLS_SUBSTITUTIONS.ADD_OP_LINK(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg);

/****** end of OPERATION LINKS processing  ******************/

     /********* Associate Serial Numbers ********/
     FOR l_cur IN SERIALS_CUR (cur_job.wip_entity_id,
                              cur_job.organization_id) LOOP

       IF l_cur.substitution_type = WIP_DELETE THEN
         WIP_SERIAL_ASSOC_VALIDATIONS.Delete_Serial(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_ADD THEN
                       WIP_SERIAL_ASSOC_VALIDATIONS.Add_Serial(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);

       ELSIF l_cur.substitution_type = WIP_CHANGE THEN
                       WIP_SERIAL_ASSOC_VALIDATIONS.Change_Serial(
                                        p_group_id,
                                        l_cur.wip_entity_id,
                                        l_cur.organization_id,
                                        l_cur.substitution_type);
       END IF;
     END LOOP;

     /**** Error out nocopy the whole job if any validations failed ****/
     WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
                                               p_parent_header_id,
                                               cur_job.wip_entity_id,
                                               cur_job.organization_id);


     WIP_JOB_DTLS_SUBSTITUTIONS.DELETE_SERIAL_ASSOCIATION(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg,
                                        x_return_status);

     WIP_JOB_DTLS_SUBSTITUTIONS.ADD_SERIAL_ASSOCIATION(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg,
                                        x_return_status);
     WIP_JOB_DTLS_SUBSTITUTIONS.CHANGE_SERIAL_ASSOCIATION(
                                        p_group_id,
                                        cur_job.wip_entity_id,
                                        cur_job.organization_id,
                                        x_err_code,
                                        x_err_msg,
                                        x_return_status);

     WIP_JOB_DTLS_SUBSTITUTIONS.VERIFY_OPERATION
                         (p_group_id,
                          cur_job.wip_entity_id,
                          cur_job.organization_id,
                          x_err_code ,
                          x_err_msg,
                          x_return_status);

     /**** Error out the whole job if any validations failed ****/
     WIP_JOB_DTLS_VALIDATIONS.Error_All_If_Any(p_group_id,
                                p_parent_header_id,
                                cur_job.wip_entity_id,
                                cur_job.organization_id);

        SELECT count(*)
            INTO x_count
            from  WIP_JOB_DTLS_INTERFACE
            WHERE group_id = p_group_id
            AND   parent_header_id = p_parent_header_id
            AND   wip_entity_id = cur_job.wip_entity_id
            AND   organization_id = cur_job.organization_id
            AND   process_phase = WIP_CONSTANTS.ML_VALIDATION
            AND   process_status = WIP_CONSTANTS.ERROR ;

         IF x_count <> 0 THEN
           x_err_code := -20239;
           x_err_msg := 'VALIDATION ERROR HAPPENED!';
           x_return_status := FND_API.G_RET_STS_ERROR;

       END IF; /* end processing resource usage*/

       /*************** CLEAN UP ************************/

      IF x_err_code IS NULL THEN

        /* set process_status = COMPLETED */
         UPDATE wip_job_dtls_interface
         SET process_status = WIP_CONSTANTS.COMPLETED
         WHERE group_id = p_group_id
         AND   wip_entity_id = cur_job.wip_entity_id
         AND   (p_parent_header_id IS NULL OR
               (p_parent_header_id IS NOT NULL AND
                parent_header_id = p_parent_header_id))
         AND   organization_id = cur_job.organization_id
         AND   process_phase = WIP_CONSTANTS.ML_VALIDATION
         AND   process_status = WIP_CONSTANTS.RUNNING ;

        /* DELETE THE COMPLETED ROWS FROM INTERFACE TABLE */
         DELETE from wip_job_dtls_interface
         WHERE  group_id = p_group_id
         AND   parent_header_id = p_parent_header_id
         AND   wip_entity_id = cur_job.wip_entity_id
         AND   organization_id = cur_job.organization_id
         AND   process_phase = WIP_CONSTANTS.ML_VALIDATION
         AND   process_status = WIP_CONSTANTS.COMPLETED;

      END IF;

      WIP_JDI_Utils.end_processing_request(cur_job.wip_entity_id,
                                              cur_job.organization_id);

  END LOOP;  /* end job_cursor in given group */

  exception
    when others then
      if x_err_msg is null then
        x_err_msg := 'WIPJDLDB load all details ' || SQLERRM;
        x_err_code := SQLCODE;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF std_alone = 1 THEN
        rollback; /* rollback if there''s any error */
      END IF;
  end;
END Load_All_Details;


procedure default_wip_entity_id(p_group_id number,
                                p_parent_header_id number,
                                x_err_code      out nocopy varchar2,
                                x_err_msg       out nocopy varchar2,
                                x_return_status out nocopy varchar2) IS

  l_wip_entity_id       number;
  l_organization_id     number;
  x_statement           varchar(500);

  cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status = wip_constants.running
         and wjdi.parent_header_id is not null
         and (   wjdi.wip_entity_id is not null
              or wjdi.organization_id is not null);

  l_err_msg VARCHAR2(30);
  l_error_exists boolean := false;
Begin

  if(std_alone = 1) then
    l_err_msg := 'WIP_HEADER_IGNORED';
  else
    l_err_msg := 'WIP_WEI_IGNORED';
  end if;

  for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', l_err_msg);
      fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end loop;
  if(l_error_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.warning
     where group_id = p_group_id
       and parent_header_id = p_parent_header_id
       and process_phase = wip_constants.ml_validation
       and process_status = wip_constants.running
       and wjdi.parent_header_id is not null
       and (   wjdi.wip_entity_id is not null
            or wjdi.organization_id is not null);

  end if;

  begin
     IF p_parent_header_id IS NOT NULL AND
        std_alone = 0 THEN
       select wip_entity_id , organization_id
       into l_wip_entity_id, l_organization_id
       from wip_job_schedule_interface
       where header_id = p_parent_header_id
       and group_id = p_group_id
       and process_status IN (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING);

       Update wip_job_dtls_interface
       Set wip_entity_id = l_wip_entity_id,
           organization_id = l_organization_id
       where group_id = p_group_id
       and parent_header_id = p_parent_header_id
       and process_phase = 2
       and process_status in (2,5);
    END IF;

  exception
        when no_data_found then --could not find the ML row
          fnd_message.set_name('WIP', 'WIP_JOB_DOES_NOT_EXIST');
          fnd_message.set_token('INTERFACE', to_char(wip_jsi_utils.current_interface_id));
          x_err_code := SQLCODE;
          x_err_msg  := substr(fnd_message.get, 1, 500);
          x_return_status := FND_API.G_RET_STS_ERROR;
        when others then
          x_err_code := SQLCODE;
          x_err_msg  := 'WIPJDLDB default wip_entity_id '||SQLERRM;
          x_return_status := FND_API.G_RET_STS_ERROR;
  end;

END default_wip_entity_id;

End WIP_JOB_DETAILS;

/
