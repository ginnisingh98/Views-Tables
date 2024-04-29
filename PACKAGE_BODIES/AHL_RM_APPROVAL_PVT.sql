--------------------------------------------------------
--  DDL for Package Body AHL_RM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_RM_APPROVAL_PVT" AS
/* $Header: AHLVROAB.pls 120.1.12010000.3 2009/11/25 13:01:58 bachandr ship $ */
G_PKG_NAME      VARCHAR2(30):='AHL_RM_APPROVAL_PVT';
G_OBJECT_TYPE   VARCHAR2(30):='RM_NTF';
G_PM_INSTALL    VARCHAR2(30):=ahl_util_pkg.is_pm_installed;

-- Local Api
G_DEBUG 		 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;
PROCEDURE NOTIFY_TERMINATION
(
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_object_type               IN         VARCHAR2,
 p_prim_object_type          IN         VARCHAR2,
 p_activity_id               IN         NUMBER
 )
AS
	CURSOR  CursorNotify
	IS
	SELECT  A.APPROVAL_RULE_ID,
		A.APPROVAL_OBJECT_CODE,
		A.STATUS_CODE,
		B.APPROVER_NAME,
		B.APPROVER_SEQUENCE
	FROM AHL_APPROVAL_RULES_Vl A,AHL_APPROVERS_V B
	WHERE A.APPROVAL_RULE_ID=B.APPROVAL_RULE_ID
	AND A.STATUS_CODE='ACTIVE'
        AND A.APPROVAL_OBJECT_CODE=p_object_type
        ORDER BY  B.APPROVER_SEQUENCE;

        l_rec   CursorNotify%rowtype;

        CURSOR CurRoute
        is
        SELECT C.*,D.VISIT_NUMBER
        FROM AHL_ROUTES_APP_V A,AHL_MR_ROUTES B,AHL_VISIT_TASKS_B C,AHL_VISITS_VL D
        WHERE A.ROUTE_ID=p_activity_id
        AND   A.ROUTE_ID=B.ROUTE_ID
        AND   B.MR_ROUTE_ID=C.MR_ROUTE_ID
        AND   C.VISIT_ID=D.VISIT_ID
        AND   D.STATUS_CODE<>'CLOSED';


        CURSOR CurRouteDet
        is
        SELECT *
        FROM  AHL_ROUTES_VL
        WHERE ROUTE_ID=p_activity_id;

        l_route_Rec       CurRouteDet%rowtype;


        CURSOR CurOper
        is
        SELECT C.*,D.VISIT_NUMBER
        FROM AHL_ROUTES_APP_V A,AHL_MR_ROUTES B,AHL_VISIT_TASKS_B C,AHL_VISITS_VL D,AHL_ROUTE_OPERATIONS E
        WHERE A.ROUTE_ID=B.ROUTE_ID
        AND   A.ROUTE_ID=E.ROUTE_ID
        AND   B.MR_ROUTE_ID=C.MR_ROUTE_ID
        AND   C.VISIT_ID=D.VISIT_ID
        AND   E.OPERATION_ID=p_activity_id
        AND   D.STATUS_CODE<>'CLOSED';

        CURSOR CurOperDet
        is
        SELECT *
        FROM  AHL_OPERATIONS_B_KFV
        WHERE OPERATION_ID=p_activity_id;

        l_oper_Rec       CurOperDet%rowtype;

        CURSOR  CurFullname(C_USERNAME VARCHAR2)
        IS
        SELECT * FROM  AHL_JTF_RS_EMP_V
        WHERE USER_NAME=C_USERNAME;

        l_item_type                 VARCHAR2(30) := 'AHLGAPP';
        l_message_name              VARCHAR2(200) := 'GEN_STDLN_MESG';
        l_subject                   VARCHAR2(3000);
        l_body                      VARCHAR2(3000) := NULL;
        l_send_to_role_name         VARCHAR2(30):= NULL;
        l_send_to_res_id            NUMBER:= NULL;
        l_notif_id                  NUMBER;
        l_notif_id1                 NUMBER;
        l_return_status             VARCHAR2(1);
        l_role_name                 VARCHAR2(100);
        l_display_role_name         VARCHAR2(240);
        l_object_notes              VARCHAR2(400);
        l_counter                   NUMBER:=0;
BEGIN
        SAVEPOINT  NOTIFY_TERMINATION;

        IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Enter Notifications','+RM_NOTIFY+');
	END IF;

        IF p_prim_object_type='RM'
        THEN
                OPEN  CurRouteDet;
                FETCH CurRouteDet INTO l_route_rec;
                CLOSE CurRouteDet;

                FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROUTE_TERMINATE_NTF_SUB');
                FND_MESSAGE.set_token('ROUTE',l_route_Rec.ROUTE_NO,false);
                FND_MESSAGE.set_token('REVISION',l_route_Rec.REVISION_NUMBER, false);
                l_subject:=fnd_message.get;

                FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROUTE_TERM_NTF_CONTENT');
                l_body:=l_subject||'-'||fnd_message.get;


                FOR l_visit_rec in  CurRoute
                LOOP
                    l_body:=l_subject;
                    l_body:=l_body||'-'||l_visit_rec.visit_number||','||l_visit_rec.visit_task_number;
                    l_counter:=l_counter+1;
                end loop;

                if l_counter>0
                then

                        FOR XREC IN CursorNotify
                        LOOP

                        l_role_name:=xrec.approver_name;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        l_notif_id := WF_NOTIFICATION.Send
                           (  role => l_role_name
                            , msg_type => l_item_type
                            , msg_name => l_message_name
                           );

                          WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_SUBJECT',
                                       l_subject);

                           WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_BODY',
                                       l_body);

                           WF_NOTIFICATION.SetAttrText(l_notif_id,
                                       'GEN_MSG_SEND_TO',
                                       l_role_name);

                           WF_NOTIFICATION.Denormalize_Notification(l_notif_id);
                        end loop;
                 end if;
        else
                OPEN  CurOperDet;
                FETCH CurOperDet INTO l_Oper_rec;
                CLOSE CurOperDet;


                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_TERMINATE_NTF_SUB');
                FND_MESSAGE.set_token('SEGMENT_COMB',l_oper_rec.concatenated_segments,false);
                FND_MESSAGE.set_token('REVISION',l_oper_Rec.REVISION_NUMBER, false);
                l_subject:=fnd_message.get;

                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_TERM_NTF_CONTENT');
                l_body:=l_subject||'-'||fnd_message.get;



                FOR l_visit_rec in  CurOper
                LOOP
                    l_body:=l_subject;
                    l_body:=l_body||'-'||l_visit_rec.visit_number||','||l_visit_rec.visit_task_number;
                    l_counter:=l_counter+1;
                END LOOP;
                IF l_counter>0
                THEN
                        FOR XREC IN CursorNotify
                        LOOP

                        l_role_name:=xrec.approver_name;

                        l_return_status := FND_API.G_RET_STS_SUCCESS;

                        l_notif_id := WF_NOTIFICATION.Send
                           (  role => l_role_name
                            , msg_type => l_item_type
                            , msg_name => l_message_name
                           );

                           WF_NOTIFICATION.SetAttrText(  l_notif_id
                                            , 'GEN_MSG_SUBJECT'
                                               , l_subject
                                              );
                           WF_NOTIFICATION.SetAttrText(  l_notif_id
                                       , 'GEN_MSG_BODY'
                                       , l_body
                                      );
                           WF_NOTIFICATION.SetAttrText(  l_notif_id
                                       , 'GEN_MSG_SEND_TO'
                                       , l_role_name
                                      );
                           WF_NOTIFICATION.Denormalize_Notification(l_notif_id);
                 end loop;
                END IF;
        end if;


EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO NOTIFY_TERMINATION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO NOTIFY_TERMINATION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO NOTIFY_TERMINATION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  'NOTIFY_TERMINATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

PROCEDURE INITIATE_OPER_APPROVAL
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_operation_id       IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprvl_type               IN         VARCHAR2)
 AS
 l_counter    NUMBER:=0;
 l_status     VARCHAR2(30);
 l_object           VARCHAR2(30):='OPER';
 l_approval_type    VARCHAR2(100):='CONCEPT';
 l_active           VARCHAR2(50) := 'N';
 l_process_name     VARCHAR2(50);
 l_item_type        VARCHAR2(50);
 l_return_status    VARCHAR2(50);
 l_msg_count        NUMBER;
 l_msg_data         VARCHAR2(2000);
 l_activity_id      NUMBER:=p_source_OPERATION_id;
 l_Status           VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_object_Version_number  NUMBER:=nvl(p_object_Version_number,0);

 l_upd_status    VARCHAR2(50);
 l_rev_status    VARCHAR2(50);
 --bachandr Enigma Phase I changes -- start

 l_enig_op_id    VARCHAR2(80);
 --bachandr Enigma Phase I changes -- end

 -- Contains value for approval workflow setup.
 l_OPER_APPR_ENABLED VARCHAR2(10);


 CURSOR get_oper_Det(c_operation_id NUMBER)
 Is
 Select revision_status_code,
	revision_number,
	start_date_active,
	end_date_active,
	concatenated_segments
 From   ahl_operations_b_KFV
 Where  operation_id = c_operation_id;

 l_oper_rec   get_oper_Det%rowtype;

 CURSOR get_oper_Det2(c_operation_id NUMBER)
 Is
 Select revision_status_code,
	revision_number,
	start_date_active,
	end_date_active,
	concatenated_segments
 From   ahl_operations_b_kfv
 Where  operation_id = c_operation_id;

 -- Bug # 8639648 -- start
 -- Fetches all active routes which has time span greater than
 -- operation duration.
 CURSOR get_asso_active_routes(c_oper_id IN NUMBER, c_op_duration IN NUMBER)
 IS
 SELECT rou.route_id
 FROM   AHL_ROUTES_APP_V rou     ,
        ahl_route_operations arop,
        ahl_operations_b oper
 WHERE  (
            TRUNC(rou.start_date_active)                                 >= TRUNC(oper.start_date_active)
            AND
            TRUNC(NVL(oper.end_date_active, rou.start_date_active + 1))   > TRUNC(rou.start_date_active)
        )
        AND    TRUNC( NVL( rou.end_date_active , SYSDATE             + 1 )) > TRUNC( SYSDATE )
        AND    rou.time_span                                                < c_op_duration
        AND    rou.route_id                                                 = arop.route_id
        AND    oper.operation_id                                            = arop.operation_id
        AND    arop.operation_id                                            = c_oper_id
        AND    rownum                                                       < 2;

 l_route_id  NUMBER;

 -- cursor for deriving operation duration.
 CURSOR get_op_max_duration( c_operation_id NUMBER )
 IS
 SELECT NVL(SUM(RES_DURATION),0)
 FROM   ( SELECT  MAX( duration ) RES_DURATION
        FROM     AHL_RT_OPER_RESOURCES
        WHERE    association_type_code = 'OPERATION'
        AND      scheduled_type_id     = 1
        AND      object_id             = c_operation_id
        GROUP BY schedule_seq
       );

 l_op_duration NUMBER;

 -- Bug # 8639648 -- end

 l_oper_rec1   get_oper_Det2%rowtype;
 l_msg         VARCHAR2(30);
 l_start_date  DATE;
BEGIN
       SAVEPOINT  INITIATE_OPER_APPROVAL;

    -- Check if API is called in debug mode. If yes, enable debug.

       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Enter Initiate OPERATION Approval..','+HEADERS+');
       END IF;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   --  Initialize API return status to success

       x_return_status :=FND_API.G_RET_STS_SUCCESS;

   -- Get approval process setup.
   IF (G_PM_INSTALL = 'Y') THEN
     l_OPER_APPR_ENABLED  := nvl(FND_PROFILE.VALUE('AHL_RM_OPERATION_APPRV_ENABLED'), 'N');
   ELSE
     l_OPER_APPR_ENABLED  := nvl(FND_PROFILE.VALUE('AHL_RM_OPERATION_APPRV_ENABLED'), 'Y');
   END IF;

   -- Bug # 8639648 -- start
   OPEN get_op_max_duration(p_source_operation_id);
   FETCH get_op_max_duration INTO l_op_duration;
   CLOSE get_op_max_duration;

   OPEN get_asso_active_routes(p_source_operation_id, l_op_duration);
   FETCH get_asso_active_routes INTO l_route_id;
   CLOSE get_asso_active_routes;

   IF l_route_id IS NOT NULL
   THEN
	   FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_DUR_GT_ROU');
	   FND_MESSAGE.set_token('DURATION',l_op_duration);
	   FND_MSG_PUB.ADD;
   END IF;
   -- Bug # 8639648 -- end

-- Start work Flow Process
        IF l_OPER_APPR_ENABLED = 'Y'
        THEN
        ahl_utility_pvt.get_wf_process_name(
                                    p_object     =>l_object,
									x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);
        END IF ;
        IF p_object_Version_number is null or p_object_Version_number=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OBJ_VERSION_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_source_operation_id is null or p_source_operation_id=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OBJECT_ID_NULL');
                FND_MSG_PUB.ADD;
        ELSE
                OPEN get_oper_Det(p_source_operation_id);
                FETCH get_oper_Det INTO l_oper_Rec;
                CLOSE get_oper_Det;

                IF p_apprvl_type = 'APPROVE'
                THEN
                        IF l_oper_rec.revision_status_code='DRAFT' or
                           l_oper_rec.revision_status_code='APPROVAL_REJECTED'
                        THEN
                                l_upd_status := 'APPROVAL_PENDING';
                        ELSE
                                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_STAT_NOT_DRFT');
                		FND_MESSAGE.set_token('FIELD',l_oper_rec.concatenated_Segments,false);
                                FND_MSG_PUB.ADD;
                        END IF;

                          AHL_RM_ROUTE_UTIL.Validate_rt_oper_start_date
                          (
                          p_object_id             =>p_source_operation_id,
                          p_association_type      =>'OPERATION',
                          p_start_date            =>l_oper_rec.start_date_active,
                          x_start_date            =>l_start_date,
                          x_msg_data              =>l_msg,
                          x_return_status         =>l_return_Status
                          );

                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                                FND_MESSAGE.SET_NAME('AHL',l_msg);
                                FND_MESSAGE.set_token('FIELD',l_start_Date);
                                FND_MSG_PUB.ADD;
          			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug( 'AHL_rm_util.Validate_rt_oper_start_date','+OPER+');
				END IF;
                         ELSIF TRUNC(l_oper_rec.START_DATE_ACTIVE)<TRUNC(SYSDATE)
                         THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_RM_INVALID_ST_DATE');
                                FND_MESSAGE.set_token('FIELD',TRUNC(sysdate));
                                FND_MSG_PUB.ADD;
                         END IF;
                ELSIF p_apprvl_type = 'TERMINATE'
                THEN
			--bachandr Enigma Phase I changes -- start
		        Select ENIGMA_OP_ID into l_enig_op_id
		        From   ahl_operations_b
		        Where  operation_id = p_source_operation_id;

                        IF ( l_enig_op_id is not null)
                        THEN
                        --if the operation is from enigma do not allow termination.
                            FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_ENIG_TERM');
                            FND_MSG_PUB.ADD;

                        END IF;
                        --bachandr Enigma Phase I changes -- end

                        IF(
			   l_oper_rec.revision_status_code = 'TERMINATED'
			  )
                        THEN
                        -- if the operation is terminated
                        	FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_INV_TERMT');
                        	FND_MSG_PUB.ADD;

                        ELSIF
                        (
			   ( l_oper_rec.END_DATE_ACTIVE IS NOT NULL OR
			   l_oper_rec.END_DATE_ACTIVE<>FND_API.G_MISS_DATE )
			   AND
			   l_oper_rec.revision_status_code = 'COMPLETE'
  			)
  			THEN
                        -- if the operation is coplete and end dated.
                            FND_MESSAGE.SET_NAME('AHL','AHL_RM_OPER_INACTIVE');
			    FND_MSG_PUB.ADD;
                        ELSE
                        -- for all other cases throw all errors;
                        IF l_oper_rec.revision_status_code='COMPLETE'  or
		           l_oper_rec.revision_status_code='APPROVAL_TERMINATED'
                        THEN
                                l_upd_status := 'TERMINATION_PENDING';

                                SELECT COUNT(*) into l_counter
                                FROM  AHL_OPERATIONS_B_KFV
                                WHERE CONCATENATED_SEGMENTS=l_oper_Rec.CONCATENATED_SEGMENTS
                                AND   REVISION_NUMBER=l_oper_Rec.revision_number+1;

                                IF l_counter>0
                                THEN
                                        FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_C_TERM');
                                        FND_MSG_PUB.ADD;
                                END IF;
                        ELSE
                                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OP_STAT_NOT_COMP');
                		FND_MESSAGE.set_token('FIELD',l_oper_rec.concatenated_Segments,false);
                                FND_MSG_PUB.ADD;
				END IF;
                        END IF;
                END IF;

        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF  l_ACTIVE='Y'
        THEN
               Update  AHL_OPERATIONS_B
               Set REVISION_STATUS_CODE=l_upd_status,
               OBJECT_VERSION_number=OBJECT_VERSION_number+1
               Where OPERATION_ID=p_source_operation_id
               and OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF;

               Update  AHL_OPERATIONS_TL
               Set APPROVER_NOTE=null
               Where OPERATION_ID=p_source_operation_id;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF;

                        AHL_GENERIC_APRV_PVT.START_WF_PROCESS(
                                     P_OBJECT                =>l_object,
                                     P_ACTIVITY_ID           =>l_activity_id,
                                     P_APPROVAL_TYPE         =>'CONCEPT',
                                     P_OBJECT_VERSION_NUMBER =>l_object_version_number+1,
                                     P_ORIG_STATUS_CODE      =>'ACTIVE',
                                     P_NEW_STATUS_CODE       =>'APPROVED',
                                     P_REJECT_STATUS_CODE    =>'REJECTED',
                                     P_REQUESTER_USERID      =>fnd_global.user_id,
                                     P_NOTES_FROM_REQUESTER  =>NULL,
                                     P_WORKFLOWPROCESS       =>'AHL_GEN_APPROVAL',
                                     P_ITEM_TYPE             =>'AHLGAPP');

        ELSE
               UPDATE  AHL_OPERATIONS_B
               SET REVISION_STATUS_CODE=l_upd_status,
               OBJECT_VERSION_number=OBJECT_VERSION_number+1
               WHERE OPERATION_ID=p_source_OPERATION_id
               and OBJECT_VERSION_NUMBER=p_object_Version_number;


               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF;
               COMPLETE_OPER_REVISION
                        (
                          p_api_version               =>p_api_version,
                          p_init_msg_list             =>p_init_msg_list,
                          p_commit                    =>FND_API.G_FALSE,
                          p_validation_level          =>p_validation_level ,
                          p_default                   =>p_default ,
                          p_module_type               =>p_module_type,
                          x_return_status             =>l_return_status,
                          x_msg_count                 =>x_msg_count ,
                          x_msg_data                  =>x_msg_data  ,
                          p_appr_status               =>'APPROVED',
                          p_operation_id              =>p_source_operation_id,
                          p_object_version_number     =>l_object_version_number+1,
                          p_approver_note             =>null
                         );

                        IF G_DEBUG='Y'
                        THEN
                          	AHL_DEBUG_PUB.debug( 'After CompleteOperRevision');
                        END IF;
    END IF ;


        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_OPER_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_OPER_APPROVAL;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_OPER_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  G_PKG_NAME,
                            p_procedure_name  =>  'INITIATE_OPER_APPROVAL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END;

PROCEDURE INITIATE_ROUTE_APPROVAL
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_source_route_id           IN         NUMBER,
 p_object_Version_number     IN         NUMBER,
 p_apprvl_type               IN         VARCHAR2
 )
 AS
 CURSOR get_route_det(c_route_id NUMBER)
 IS
 SELECT *
 FROM  AHL_ROUTES_APP_V
 WHERE  route_id = c_route_id;
 l_route_rec                    get_route_det%rowtype;
 l_msg                          VARCHAR2(30);
 l_start_date                   DATE;
 l_counter                      NUMBER:=0;
 l_status                       VARCHAR2(30);
 l_object                       VARCHAR2(30):='RM';
 l_approval_type                VARCHAR2(100):='CONCEPT';
 l_active                       VARCHAR2(50) := 'N';
 l_process_name                 VARCHAR2(50);
 l_item_type                    VARCHAR2(50);
 l_return_status                VARCHAR2(50);
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);
 l_activity_id                  NUMBER:=p_source_route_id;
 l_Status                       VARCHAR2(1);
 l_init_msg_list                VARCHAR2(10):=FND_API.G_TRUE;
 l_object_Version_number        NUMBER:=nvl(p_object_Version_number,0);
 l_upd_status                   VARCHAR2(50);
 l_rev_status                   VARCHAR2(50);
 l_new_status                   VARCHAR2(50);

 l_ROUTE_APPR_ENABLED           VARCHAR2(30);
 --bachandr Enigma Phase I changes -- start
 l_enigma_doc_id                VARCHAR2(30);
 --bachandr Enigma Phase I changes -- end

BEGIN
       SAVEPOINT  INITIATE_ROUTE_APPROVAL;

    -- Check if API is called in debug mode. If yes, enable debug.

       IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
		  AHL_DEBUG_PUB.debug( 'Enter Initiate Route Approval','+ROUTES+');
		  AHL_DEBUG_PUB.debug( 'p_approval_type'||p_apprvl_type,'+ROUTES+');
       END IF;

   -- Standard call to check for call compatibility.

      IF FND_API.to_boolean(l_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

   -- Initialize API return status to success

      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Set default for CMRO and PM modes.
   IF (G_PM_INSTALL = 'Y') THEN
     l_ROUTE_APPR_ENABLED := nvl(FND_PROFILE.VALUE('AHL_RM_ROUTE_APPRV_ENABLED'),'N');
   ELSE
     l_ROUTE_APPR_ENABLED := nvl(FND_PROFILE.VALUE('AHL_RM_ROUTE_APPRV_ENABLED'),'Y');
   END IF;


--Before calling   ahl_utility_pvt.get_wf_process_name()
-- Validate Application Usage
  AHL_RM_ROUTE_UTIL .validate_ApplnUsage
  (
     p_object_id              => p_source_route_id,
     p_association_type       => 'ROUTE',
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data
  );

-- If any severe error occurs, then, abort API.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
                -- added code : prithwi : 29.9.2003
                OPEN  get_route_det(p_source_route_id);
                FETCH get_route_det INTO l_route_rec;
                CLOSE get_route_det;

   -- Start work Flow Process
   IF l_ROUTE_APPR_ENABLED = 'Y'
   THEN
      ahl_utility_pvt.get_wf_process_name(
                                    p_object       =>l_object,
									p_application_usg_code => l_route_rec.application_usg_code,
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);
   END IF ;

        IF p_object_Version_number is null or p_object_Version_number=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OBJ_VERSION_NULL');
                FND_MSG_PUB.ADD;
        END IF;

        IF p_source_route_id is null or p_source_route_id=FND_API.G_MISS_NUM
        THEN
                FND_MESSAGE.SET_NAME('AHL','AHL_RM_OBJECT_ID_NULL');
                FND_MSG_PUB.ADD;
        ELSE
                OPEN  get_route_det(p_source_route_id);
                FETCH get_route_det INTO l_route_rec;
                CLOSE get_route_det;
                IF p_apprvl_type = 'APPROVE'
                THEN
                          AHL_RM_ROUTE_UTIL.Validate_rt_oper_start_date
                          (
                          p_object_id             =>p_source_route_id,
                          p_association_type      =>'ROUTE',
                          p_start_date            =>l_route_rec.start_date_active,
                          x_start_date            =>l_start_date,
                          x_msg_data              =>l_msg,
                          x_return_status         =>l_return_Status
                          );

                         IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                         THEN
                                FND_MESSAGE.SET_NAME('AHL',l_msg);
                                FND_MESSAGE.set_token('FIELD',l_start_Date);
                                FND_MSG_PUB.ADD;
          			IF G_DEBUG='Y' THEN
		  		AHL_DEBUG_PUB.debug('AHL_rm_util.Validate_rt_oper_start_date','+ROUTE+');
				END IF;
                         ELSIF TRUNC(l_route_rec.START_DATE_ACTIVE)<TRUNC(SYSDATE)
                         THEN
                                FND_MESSAGE.SET_NAME('AHL','AHL_RM_INVALID_ST_DATE');
                                FND_MESSAGE.set_token('FIELD',TRUNC(sysdate));
                                FND_MSG_PUB.ADD;
                         END IF;

			IF l_route_rec.revision_Status_code = 'DRAFT' or
                           l_route_rec.revision_Status_code='APPROVAL_REJECTED'
                        THEN
                               l_upd_status := 'APPROVAL_PENDING';
                        ELSE
                               FND_MESSAGE.SET_NAME('AHL','AHL_RM_RO_STAT_NOT_DRFT');
                               FND_MESSAGE.set_token('FIELD',l_route_rec.route_no);
                               FND_MSG_PUB.ADD;
                        END IF;

                        --bachandr Enigma Phase I changes -- start
			-- When the workflow type is approve , check if time span is entered as it is mandatory for
			-- approval flow. If not throw an error.
			IF l_route_rec.time_span is null or l_route_rec.time_span =FND_API.G_MISS_NUM
			THEN
				FND_MESSAGE.SET_NAME('AHL','AHL_RM_TIME_SPAN_NULL');
				FND_MSG_PUB.ADD;
			END IF;
			--bachandr Enigma Phase I changes -- end

                ELSIF p_apprvl_type = 'TERMINATE'
                THEN

                        --bachandr Enigma Phase I changes -- start
                        Select ENIGMA_DOC_ID into l_enigma_doc_id
                        From   ahl_routes_b
                        Where  route_id = p_source_route_id;

                        IF ( l_enigma_doc_id is not null)
                        THEN
                            --if the route is from enigma do not allow termination.
                            FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROUTE_ENIG_TERM');
                            FND_MSG_PUB.ADD;
                        END IF;
                        --bachandr Enigma Phase I changes -- end

                        IF (
                           (l_route_rec.END_DATE_ACTIVE IS NOT NULL OR
                            l_route_rec.END_DATE_ACTIVE<>FND_API.G_MISS_DATE
                           )
                           AND
                            l_route_rec.revision_status_code = 'TERMINATED'
                           )
                        THEN
                        -- if the Route is TERMINATED
                               FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROUTE_INV_TERMT');
                               FND_MSG_PUB.ADD;
                        ELSIF
                        (
			   (l_route_rec.END_DATE_ACTIVE IS NOT NULL OR
			    l_route_rec.END_DATE_ACTIVE<>FND_API.G_MISS_DATE
			   )
			   AND
			    l_route_rec.revision_status_code = 'COMPLETE'
                        )
                        THEN
                        -- if the Route is COMPLETE and End Dated.
			    FND_MESSAGE.SET_NAME('AHL','AHL_RM_ROUTE_INACTIVE');
			    FND_MSG_PUB.ADD;
                        ELSE
-- for all other cases throw all errors


                        /*SELECT COUNT(*) into l_counter
                               FROM  AHL_ROUTE_MR_V
                               WHERE ROUTE_ID=l_route_Rec.ROUTE_ID
                               AND  trunc(nvl(AHL_ROUTE_MR_V.EFFECTIVE_TO,SYSDATE))>=trunc(SYSDATE);*/

--AMSRINIV : Bug 4913294. Tuned above commented query.
                        SELECT COUNT(*) into l_counter
                               from ahl_mr_routes a, ahl_mr_headers_b b
                              where
                                 a.route_id = l_route_rec.route_id and
                                 a.mr_header_id = b.mr_header_id and
                                 b.application_usg_code = rtrim(ltrim(fnd_profile.value('AHL_APPLN_USAGE'))) and
                                 trunc(nvl(b.effective_to,sysdate)) >= trunc(sysdate);
                                IF l_counter>0
                                THEN
                                        FND_MESSAGE.SET_NAME('AHL','AHL_RM_MR_C_TERM');
                                        FND_MSG_PUB.ADD;
                                END IF;

                        IF l_route_rec.revision_status_code ='COMPLETE'  or
 			   l_route_rec.revision_Status_code='APPROVAL_TERMINATED'
                        THEN
                               SELECT COUNT(*) into l_counter
				       FROM  AHL_ROUTES_APP_V
                               WHERE UPPER(TRIM(ROUTE_NO))=UPPER(TRIM(l_route_Rec.route_no))
                               AND   REVISION_NUMBER=l_route_Rec.revision_number+1;

                                IF l_counter>0
                                THEN
                                        FND_MESSAGE.SET_NAME('AHL','AHL_RM_RT_C_TERM');
                                        FND_MSG_PUB.ADD;
                                END IF;

                               l_upd_status := 'TERMINATION_PENDING';
                        ELSE
                               FND_MESSAGE.SET_NAME('AHL','AHL_RM_RO_STAT_NOT_COMP');
                               FND_MESSAGE.set_token('FIELD',l_route_rec.route_no);
                               FND_MSG_PUB.ADD;
				END IF;
                        END IF;
                 END IF;
        END IF;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF  l_ACTIVE='Y'
        THEN
               UPDATE  AHL_ROUTES_B
               SET REVISION_STATUS_CODE=l_upd_status,
               OBJECT_VERSION_number=OBJECT_VERSION_number+1
               WHERE ROUTE_ID=p_source_route_id
               and OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF ;

               UPDATE AHL_ROUTES_TL
               SET APPROVER_NOTE=null
               WHERE ROUTE_ID=p_source_route_id;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;
               END IF ;


                        AHL_GENERIC_APRV_PVT.START_WF_PROCESS(
                                     P_OBJECT                =>l_object,
                                     P_ACTIVITY_ID           =>l_activity_id,
                                     P_APPROVAL_TYPE         =>'CONCEPT',
									 P_APPLICATION_USG_CODE  =>l_route_rec.application_usg_code,
                                     P_OBJECT_VERSION_NUMBER =>l_object_version_number+1,
                                     P_ORIG_STATUS_CODE      =>'ACTIVE',
                                     P_NEW_STATUS_CODE       =>'APPROVED',
                                     P_REJECT_STATUS_CODE    =>'REJECTED',
                                     P_REQUESTER_USERID      =>fnd_global.user_id,
                                     P_NOTES_FROM_REQUESTER  =>NULL,
--                                     P_WORKFLOWPROCESS       =>'AHL_GEN_APPROVAL',
                                     P_WORKFLOWPROCESS       =>l_process_name,
                                     P_ITEM_TYPE             =>'AHLGAPP');

        ELSE
               UPDATE  AHL_ROUTES_B
               SET REVISION_STATUS_CODE=l_upd_status,
               OBJECT_VERSION_number=OBJECT_VERSION_number+1
               WHERE ROUTE_ID=p_source_route_id
               and OBJECT_VERSION_NUMBER=p_object_Version_number;

               IF sql%rowcount=0
               THEN
                        FND_MESSAGE.SET_NAME('AHL','AHL_COM_RECORD_CHANGED');
                        FND_MSG_PUB.ADD;

               END IF;

                        COMPLETE_ROUTE_REVISION
                        (
                          p_api_version               =>p_api_version,
                          p_init_msg_list             =>p_init_msg_list,
                          p_commit                    =>FND_API.G_FALSE,
                          p_validation_level          =>p_validation_level ,
                          p_default                   =>p_default ,
                          p_module_type               =>p_module_type,
                          x_return_status             =>l_return_status,
                          x_msg_count                 =>x_msg_count ,
                          x_msg_data                  =>x_msg_data  ,
                          p_appr_status               =>'APPROVED',
                          p_route_id                  =>p_source_route_id,
                          p_object_version_number     =>l_object_version_number+1,
                          p_approver_note             =>null
                         );
                        IF G_DEBUG='Y'
                        THEN
                          	AHL_DEBUG_PUB.debug( 'After CompleteRouteRevision');
                        END IF;
        END IF ;

        l_msg_count := FND_MSG_PUB.count_msg;

        IF l_msg_count > 0
        THEN
              X_msg_count := l_msg_count;
              X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF FND_API.TO_BOOLEAN(p_commit) THEN
            COMMIT;
        END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO INITIATE_ROUTE_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO INITIATE_ROUTE_APPROVAL;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO INITIATE_ROUTE_APPROVAL;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_RM_ROUTE_PUB',
                            p_procedure_name  =>  'INITIATE_ROUTE_APPROVAL',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
END INITIATE_ROUTE_APPROVAL;

PROCEDURE COMPLETE_ROUTE_REVISION
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_route_id                  IN         NUMBER,
 p_object_version_number     IN         NUMBER,
 p_approver_note             IN         VARCHAR2   := null
  )
 AS

 CURSOR GetRouteDet(C_ROUTE_ID NUMBER)
 IS
 SELECT ROUTE_ID,ROUTE_NO,REVISION_NUMBER,START_DATE_ACTIVE,END_DATE_ACTIVE
 FROM AHL_ROUTES_APP_V
 WHERE ROUTE_ID=C_ROUTE_ID;

 CURSOR GetPrevRouteDet(C_REVISION_NUMBER NUMBER,C_ROUTE_NO  VARCHAR2)
 IS
 SELECT ROUTE_ID,ROUTE_NO,REVISION_NUMBER,START_DATE_ACTIVE,END_DATE_ACTIVE
 FROM AHL_ROUTES_APP_V
 WHERE UPPER(TRIM(ROUTE_NO))=UPPER(TRIM(C_ROUTE_NO))
 AND   REVISION_NUMBER=C_REVISION_NUMBER-1;

 l_route_rec             GetRouteDet%rowtype;
 l_prev_route_rec        GetPrevRouteDet%rowtype;
 l_status                VARCHAR2(30);
 l_mr_status             VARCHAR2(30);
 l_check_flag            VARCHAR2(1):='N';
 l_check_flag2           VARCHAR2(1):='N';
 l_check_flag3           VARCHAR2(1):='Y';
 l_api_name     CONSTANT VARCHAR2(30) := 'COMPLETE_ROUTE_REVISION';
 l_api_version  CONSTANT NUMBER       := 1.0;
 l_num_rec               NUMBER;
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_init_msg_list         VARCHAR2(10):=FND_API.G_TRUE;
 l_fr_date               DATE:=SYSDATE;
 l_to_Date               DATE:=SYSDATE;
 l_commit                VARCHAR2(10):=FND_API.G_TRUE;
 l_curr_status           VARCHAR2(30);


 l_object                       VARCHAR2(30):='RM';
 l_approval_type                VARCHAR2(100):='CONCEPT';
 l_active                       VARCHAR2(50);
 l_process_name                 VARCHAR2(50);
 l_item_type                    VARCHAR2(50);

-- Routes
CURSOR CurGetRoutedet(C_ROUTE_ID NUMBER)
IS
SELECT * from AHL_MR_ROUTES
WHERE ROUTE_ID=C_ROUTE_ID;
l_mr_route_rec  CurGetRoutedet%rowtype;

l_new_mr_ROUTE_ID       NUMBER:=0;
l_new_mr_ROUTE_SEQ_ID   NUMBER:=0;
l_old_mr_route_id       NUMBER:=0;
l_seq_mr_route_id       NUMBER:=0;
l_seq_rel_mr_route_id   NUMBER:=0;
-- Route Sequences
CURSOR CurGetRouteSeqDet(C_MR_ROUTE_ID NUMBER)
iS
SELECT   * FROM  AHL_MR_ROUTE_SEQUENCES
WHERE (MR_ROUTE_ID=C_MR_ROUTE_ID OR RELATED_MR_ROUTE_ID=C_MR_ROUTE_ID);

l_mr_route_seq_rec  CurGetRouteSeqDet%rowtype;
l_rowid             VARCHAR2(30);
BEGIN

     SAVEPOINT  COMPLETE_ROUTE_REVISION;

     	IF G_DEBUG='Y' THEN
		  AHL_DEBUG_PUB.enable_debug;
	END IF;

     SELECT REVISION_STATUS_CODE INTO l_curr_status
     FROM AHL_ROUTES_APP_V WHERE ROUTE_ID=p_route_id;


     IF p_appr_status='APPROVED'
     THEN
                l_status:='COMPLETE';
     ELSE
        IF l_curr_status='APPROVAL_PENDING'
        THEN
                l_status:='APPROVAL_REJECTED';
        ELSE
                l_status:='COMPLETE';
        END IF;
        l_check_flag3:='N';
     END IF;

     IF p_route_id is not null or p_route_id<>fnd_api.g_miss_num
     THEN
             IF G_DEBUG='Y'
             THEN
                AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:p_route_id'||p_route_id);
             END IF;
             OPEN  GetRouteDet(p_route_id);

             FETCH GetRouteDet INTO  l_route_rec;

             IF GetRouteDet%NOTFOUND
             THEN
                l_check_flag:='N';
             ELSE
                l_check_flag:='Y';
                IF trunc(l_route_rec.Start_date_active) >trunc(sysdate)
                THEN
                   l_fr_date:=l_route_rec.start_date_active;
                   l_to_date:=l_route_rec.start_date_active;
                ELSE
                   l_fr_date:=sysdate;
                   l_to_date:=sysdate;
                END IF;
             END IF;

             CLOSE GetRouteDet;
             IF l_check_flag='Y' and p_appr_status='REJECTED'
             Then
                     UPDATE AHL_ROUTES_B
                            SET REVISION_STATUS_CODE=l_status,
                                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE ROUTE_ID=P_ROUTE_ID;

                     UPDATE AHL_ROUTES_TL
                            SET APPROVER_NOTE=p_approver_note
                                WHERE ROUTE_ID=P_ROUTE_ID;
             Elsif l_check_flag='Y' and  l_curr_status='TERMINATION_PENDING' and
		   p_appr_status='APPROVED'
             Then
                     UPDATE AHL_ROUTES_B
                            SET REVISION_STATUS_CODE='TERMINATED',
                               -- START_DATE_ACTIVE=l_fr_date,
                                END_DATE_ACTIVE=l_to_date,
                                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE ROUTE_ID=P_ROUTE_ID;

                     -- Do not call for Preventive Maintenance application Mode.
                     IF (G_PM_INSTALL <> 'Y') THEN
                        ahl_utility_pvt.get_wf_process_name(
                                    p_object       =>'RM_NTF',
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);

                        IF (l_active = 'Y') THEN
                                NOTIFY_TERMINATION
                                (
                                 x_return_status             =>l_return_status,
                                 x_msg_count                 =>l_msg_count,
                                 x_msg_data                  =>l_msg_data,
                                 p_object_type               =>G_OBJECT_TYPE,
                                 p_prim_object_type          =>'RM',
                                 p_activity_id               =>p_ROUTE_ID
                                 );
                        END IF;
                     END IF;
             Elsif l_check_flag='Y' and l_route_rec.revision_number=1 and
		   l_curr_status='APPROVAL_PENDING' AND  p_appr_status='APPROVED'
             THEN
                     UPDATE AHL_ROUTES_B
                            SET REVISION_STATUS_CODE=l_status,
                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE ROUTE_ID=P_ROUTE_ID;

                     l_check_flag:='Y';

                     l_check_flag2:='Y';
             IF G_DEBUG='Y'
             THEN
                AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:p_route_id'||p_route_id);
                AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:l_status'||l_status);
                AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:l_route_rec.revision_number'||l_route_rec.revision_number);
             END IF;
             Elsif l_check_flag='Y' and l_route_rec.revision_number>1  and
		   l_curr_status='APPROVAL_PENDING' AND  p_appr_status='APPROVED'
             THEN
                     IF G_DEBUG='Y'
                     THEN
                        AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:p_route_id'||p_route_id);
                        AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:l_status'||l_status);
                        AHL_DEBUG_PUB.debug( 'Inside CompleteRouteRevision:l_route_rec.revision_number'||l_route_rec.revision_number);
                     END IF;
                     OPEN GetPrevRouteDet(l_route_rec.revision_number,l_route_rec.route_no);

                     FETCH GetPrevRouteDet INTO  l_prev_route_rec;

                     IF GetPrevRouteDet%NOTFOUND
                     THEN
                         l_check_flag2:='N';
                     ELSE
                        l_check_flag2:='Y';
                     END IF;

                     CLOSE GetPrevRouteDet;

                     IF l_check_flag2='Y'
                     THEN

                        UPDATE AHL_ROUTES_B
                                    SET REVISION_STATUS_CODE= l_status,
                                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
                                    START_DATE_ACTIVE=l_fr_date
                        WHERE ROUTE_ID=P_ROUTE_ID;

                        IF l_check_flag3='Y'
                        THEN
                                UPDATE AHL_ROUTES_B
                                            SET REVISION_STATUS_CODE= l_status,
                                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
                                            END_DATE_ACTIVE=l_to_date
                                WHERE ROUTE_ID=l_prev_route_rec.ROUTE_ID;

                                IF l_check_flag2='Y'
                                THEN

                                open  CurGetRoutedet(l_prev_route_rec.ROUTE_ID);
                                --open  CurGetRoutedet(P_ROUTE_ID);
                                loop
                                fetch CurGetRoutedet into l_mr_route_rec;
                                IF CurGetRoutedet%FOUND
                                THEN

                                        SELECT  AHL_MR_ROUTES_S.NEXTVAL
                                                INTO l_new_mr_ROUTE_ID
                                                FROM DUAL;

                                        l_old_mr_route_id:=l_mr_route_Rec.mr_route_id;

                   		AHL_MR_ROUTES_PKG.INSERT_ROW (
--                   		X_ROWID                               =>L_ROWID,
                   		X_MR_ROUTE_ID                         =>l_new_mr_ROUTE_ID,
                      		X_MR_HEADER_ID                        =>l_mr_route_Rec.mr_header_id,
                      		X_ROUTE_ID                            =>P_ROUTE_ID,
                      		X_STAGE				      =>l_mr_route_Rec.STAGE,
                   		X_ATTRIBUTE_CATEGORY                  =>l_mr_route_Rec.ATTRIBUTE_CATEGORY,
                   		X_ATTRIBUTE1                          =>l_mr_route_Rec.ATTRIBUTE1,
                   		X_ATTRIBUTE2                          =>l_mr_route_Rec.ATTRIBUTE2,
                   		X_ATTRIBUTE3                          =>l_mr_route_Rec.ATTRIBUTE3,
                   		X_ATTRIBUTE4                          =>l_mr_route_Rec.ATTRIBUTE4,
                   		X_ATTRIBUTE5                          =>l_mr_route_Rec.ATTRIBUTE5,
                   		X_ATTRIBUTE6                          =>l_mr_route_Rec.ATTRIBUTE6,
                   		X_ATTRIBUTE7                          =>l_mr_route_Rec.ATTRIBUTE7,
                   		X_ATTRIBUTE8                          =>l_mr_route_Rec.ATTRIBUTE8,
                   		X_ATTRIBUTE9                          =>l_mr_route_Rec.ATTRIBUTE9,
                   		X_ATTRIBUTE10                         =>l_mr_route_Rec.ATTRIBUTE10,
                   		X_ATTRIBUTE11                         =>l_mr_route_Rec.ATTRIBUTE11,
                   		X_ATTRIBUTE12                         =>l_mr_route_Rec.ATTRIBUTE12,
                   		X_ATTRIBUTE13                         =>l_mr_route_Rec.ATTRIBUTE13,
                   		X_ATTRIBUTE14                         =>l_mr_route_Rec.ATTRIBUTE14,
                   		X_ATTRIBUTE15                         =>l_mr_route_Rec.ATTRIBUTE15,
                      		X_OBJECT_VERSION_NUMBER               =>1,
                   		X_CREATION_DATE                       =>sysdate,
                   		X_CREATED_BY                          =>fnd_global.user_id,
                   		X_LAST_UPDATE_DATE                    =>sysdate,
                   		X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                   		X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                                OPEN CurGetRouteSeqDet(l_old_mr_ROUTE_ID);
                                LOOP
                                FETCH CurGetRouteSeqDet INTO l_mr_route_seq_rec;
                                IF CurGetRouteSeqDet%FOUND
                                THEN
                                SELECT  AHL_MR_ROUTE_SEQUENCES_S .NEXTVAL
					INTO l_new_mr_ROUTE_SEQ_ID FROM DUAL;
                                IF l_mr_route_seq_rec.mr_route_id=l_old_mr_route_id
                                THEN
                                        l_seq_rel_mr_route_id:=l_mr_route_seq_rec.related_mr_route_id;
                                        l_seq_mr_route_id:=l_new_mr_ROUTE_ID;

                                ELSIF l_mr_route_seq_rec.related_mr_route_id=l_old_mr_route_id
                                THEN
                                        l_seq_mr_route_id:=l_mr_route_seq_rec.mr_route_id;
                                        l_seq_rel_mr_route_id:=l_new_mr_ROUTE_ID;
                                END IF;
                                AHL_MR_ROUTE_SEQUENCES_PKG.INSERT_ROW (
                                X_MR_ROUTE_SEQUENCE_ID                =>l_new_mr_route_seq_id,
                                X_RELATED_MR_ROUTE_ID                 =>l_seq_rel_mr_route_id,
                                X_SEQUENCE_CODE                       =>l_mr_route_seq_rec.SEQUENCE_CODE,
                                X_MR_ROUTE_ID                         =>l_seq_mr_route_id,
                                X_OBJECT_VERSION_NUMBER               =>1,
                                X_ATTRIBUTE_CATEGORY             =>l_mr_route_seq_rec.ATTRIBUTE_CATEGORY,
                                X_ATTRIBUTE1                          =>l_mr_route_seq_rec.ATTRIBUTE1,
                                X_ATTRIBUTE2                          =>l_mr_route_seq_rec.ATTRIBUTE2,
                                X_ATTRIBUTE3                          =>l_mr_route_seq_rec.ATTRIBUTE3,
                                X_ATTRIBUTE4                          =>l_mr_route_seq_rec.ATTRIBUTE4,
                                X_ATTRIBUTE5                          =>l_mr_route_seq_rec.ATTRIBUTE5,
                                X_ATTRIBUTE6                          =>l_mr_route_seq_rec.ATTRIBUTE6,
                                X_ATTRIBUTE7                          =>l_mr_route_seq_rec.ATTRIBUTE7,
                                X_ATTRIBUTE8                          =>l_mr_route_seq_rec.ATTRIBUTE8,
                                X_ATTRIBUTE9                          =>l_mr_route_seq_rec.ATTRIBUTE9,
                                X_ATTRIBUTE10                         =>l_mr_route_seq_rec.ATTRIBUTE10,
                                X_ATTRIBUTE11                         =>l_mr_route_seq_rec.ATTRIBUTE11,
                                X_ATTRIBUTE12                         =>l_mr_route_seq_rec.ATTRIBUTE12,
                                X_ATTRIBUTE13                         =>l_mr_route_seq_rec.ATTRIBUTE13,
                                X_ATTRIBUTE14                         =>l_mr_route_seq_rec.ATTRIBUTE14,
                                X_ATTRIBUTE15                         =>l_mr_route_seq_rec.ATTRIBUTE15,
                                X_CREATION_DATE                       =>sysdate,
                                X_CREATED_BY                          =>fnd_global.user_id,
                                X_LAST_UPDATE_DATE                    =>sysdate,
                                X_LAST_UPDATED_BY                     =>fnd_global.user_id,
                                X_LAST_UPDATE_LOGIN                   =>fnd_global.user_id);
                                ELSE
                                     EXIT WHEN CurGetRouteSeqDet%NOTFOUND;
                                END IF;
                                END LOOP;
                                CLOSE CurGetRouteSeqDet;

                                        ELSE
                                                EXIT WHEN CurGetRoutedet%NOTFOUND;
                                        END IF;

                                        END LOOP;

                                        END IF;
                                        close CurGetRoutedet;

                               -- Do not call for Preventive Maintenance application Mode.
                               IF (G_PM_INSTALL <> 'Y') THEN
                                 ahl_utility_pvt.get_wf_process_name(
                                    p_object       =>'RM_NTF',
                                    x_active       =>l_active,
                                    x_process_name =>l_process_name ,
                                    x_item_type    =>l_item_type,
                                    x_return_status=>l_return_status,
                                    x_msg_count    =>l_msg_count,
                                    x_msg_data     =>l_msg_data);

                                 IF (l_active = 'Y') THEN

                                    NOTIFY_TERMINATION
                                      (
                                       x_return_status             =>l_return_status,
                                       x_msg_count                 =>l_msg_count,
                                       x_msg_data                  =>l_msg_data,
                                       p_object_type               =>G_OBJECT_TYPE,
                                       p_prim_object_type          =>'RM',
                                       p_activity_id               =>l_prev_route_rec.ROUTE_ID
                                       );
                                 END IF;
                               END IF;

                        else
                                UPDATE AHL_ROUTES_B
                                            SET REVISION_STATUS_CODE= l_status,
                                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
                                            END_DATE_ACTIVE=l_to_date
                                WHERE ROUTE_ID=l_prev_route_rec.ROUTE_ID;
                        END IF;
                     END IF;
             END IF;

      END IF;

      IF l_msg_count > 0
      THEN
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

	IF G_DEBUG='Y' THEN
		AHL_DEBUG_PUB.debug( 'Before commit Complete_route_revision Status----->'||p_appr_status,'+DEBUG_RELATIONS+');
	END IF;

      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT;
      END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COMPLETE_ROUTE_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COMPLETE_MR_REVISION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO COMPLETE_MR_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>'COMPLETE_ROUTE_REVISION',
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;

PROCEDURE COMPLETE_OPER_REVISION
 (
 p_api_version               IN         NUMBER:=  1.0,
 p_init_msg_list             IN         VARCHAR2,
 p_commit                    IN         VARCHAR2,
 p_validation_level          IN         NUMBER,
 p_default                   IN         VARCHAR2   := FND_API.G_FALSE,
 p_module_type               IN         VARCHAR2,
 x_return_status                OUT NOCOPY     VARCHAR2,
 x_msg_count                    OUT NOCOPY     NUMBER,
 x_msg_data                     OUT NOCOPY     VARCHAR2,
 p_appr_status               IN         VARCHAR2,
 p_operation_id              IN         NUMBER,
 p_object_version_number     IN         NUMBER,
 p_approver_note             IN         VARCHAR2   := null
  )
 AS
 CURSOR GetOperationDet(C_OPERATION_ID NUMBER)
 IS
 SELECT OPERATION_ID,
	CONCATENATED_SEGMENTS,
	REVISION_NUMBER,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE
 FROM AHL_OPERATIONS_B_KFV
 WHERE OPERATION_ID=C_OPERATION_ID;

 CURSOR GetPrevOperDet(C_REVISION_NUMBER NUMBER,C_CONCATENATED_SEGMENTS  VARCHAR2)
 IS
 SELECT OPERATION_ID,
	CONCATENATED_SEGMENTS,
	REVISION_NUMBER,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE
 FROM AHL_OPERATIONS_B_KFV
 WHERE CONCATENATED_SEGMENTS=C_CONCATENATED_SEGMENTS
 AND REVISION_NUMBER=C_REVISION_NUMBER-1;

 l_oper_rec                             GetOperationDet%rowtype;
 l_prev_oper_rec                        GetPrevOperDet%rowtype;
 l_status                               VARCHAR2(30);
 l_curr_status                          VARCHAR2(30);
 l_curr_atus                            VARCHAR2(30);
 l_check_flag                           VARCHAR2(1):='N';
 l_check_flag2                          VARCHAR2(1):='N';
 l_check_flag3                          VARCHAR2(1):='Y';
 l_api_name                    CONSTANT VARCHAR2(30) := 'COMPLETE_MR_REVISION';
 l_api_version                 CONSTANT NUMBER       := 1.0;
 l_num_rec                              NUMBER;
 l_msg_count                            NUMBER;
 l_msg_data                             VARCHAR2(2000);
 l_return_status                        VARCHAR2(1);
 l_init_msg_list                        VARCHAR2(10):=FND_API.G_TRUE;
 l_fr_date                              DATE:=SYSDATE;
 l_to_Date                              DATE:=SYSDATE;
 l_commit                               VARCHAR2(10):=FND_API.G_TRUE;
 l_active                               VARCHAR2(50);
 l_process_name                         VARCHAR2(50);
 l_item_type                            VARCHAR2(50);

BEGIN
     SAVEPOINT  COMPLETE_OPER_REVISION;

     	IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.enable_debug;
	  AHL_DEBUG_PUB.debug( 'Complete_mr_revision Status----->'||p_appr_status,'+DEBUG_RELATIONS+');
	END IF;

     SELECT REVISION_STATUS_CODE INTO l_curr_status
     FROM AHL_OPERATIONS_B_KFV WHERE OPERATION_ID=p_operation_id;

     IF p_appr_status='APPROVED'
     THEN
                l_status:='COMPLETE';
     ELSE
        IF l_curr_status='APPROVAL_PENDING'
        THEN
                l_status:='APPROVAL_REJECTED';
        ELSE
                l_status:='COMPLETE';
        END IF;
        l_check_flag3:='N';
     END IF;

     	IF G_DEBUG='Y' THEN
	AHL_DEBUG_PUB.debug( 'Complete_operation_revision Status2----->'||L_status,'+DEBUG_REVISION+');
	AHL_DEBUG_PUB.debug( 'Complete_mr_revision Status2----->'||L_status,'+DEBUG_REVISION+');
	END IF;

     IF p_operation_id is not null or p_operation_id<>fnd_api.g_miss_num
     THEN
             OPEN  GetOperationDet(p_operation_id);
             FETCH GetOperationDet INTO  l_oper_rec;

             IF    GetOperationDet%NOTFOUND
             THEN
                 l_check_flag:='N';
             ELSE
                l_check_flag:='Y';
                IF trunc(l_oper_rec.start_date_active) >trunc(sysdate)
                THEN
                   l_fr_date:=l_oper_rec.start_date_active;
                   l_to_date:=l_oper_rec.Start_date_active;
                ELSE
                   l_fr_date:=sysdate;
                   l_to_date:=sysdate;
                END IF;
             END IF;

             CLOSE GetOperationDet;
             IF l_check_flag='Y' and  p_appr_status='REJECTED'
             THEN
                     UPDATE AHL_OPERATIONS_B
                            SET REVISION_STATUS_CODE=l_status,
                                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE OPERATION_ID=P_OPERATION_ID;
                     UPDATE AHL_OPERATIONS_TL
                            SET APPROVER_NOTE=p_approver_note
                                WHERE OPERATION_ID=P_OPERATION_ID;
             ELSIF l_check_flag='Y' and  l_curr_status='TERMINATION_PENDING'
		   and  p_appr_status='APPROVED'
             THEN
                     UPDATE AHL_OPERATIONS_B
                            SET REVISION_STATUS_CODE='TERMINATED',
                               -- START_DATE_ACTIVE=l_fr_date,
                                END_DATE_ACTIVE=l_to_date,
                                OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE OPERATION_ID=P_OPERATION_ID;

                     -- Bypass notifications in Preventive Application mode.
                     IF (G_PM_INSTALL <> 'Y') THEN
                       ahl_utility_pvt.get_wf_process_name(
                                      p_object       =>'RM_NTF',
                                      x_active       =>l_active,
                                      x_process_name =>l_process_name ,
                                      x_item_type    =>l_item_type,
                                      x_return_status=>l_return_status,
                                      x_msg_count    =>l_msg_count,
                                      x_msg_data     =>l_msg_data);

                       IF (l_active = 'Y') THEN
                                  NOTIFY_TERMINATION
                                  (
                                   x_return_status             =>l_return_status,
                                   x_msg_count                 =>l_msg_count,
                                   x_msg_data                  =>l_msg_data,
                                   p_object_type               =>G_OBJECT_TYPE,
                                   p_prim_object_type          =>'OPER',
                                   p_activity_id               =>p_operation_id
                                   );
                       END IF;
                     END IF;

             ELSIF l_check_flag='Y' and l_oper_rec.revision_number=1
		   and  l_curr_status='APPROVAL_PENDING' and  p_appr_status='APPROVED'
             THEN
                     UPDATE AHL_OPERATIONS_B
                            SET REVISION_STATUS_CODE=l_status,
                            OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1
                     WHERE OPERATION_ID=P_OPERATION_ID;

                     l_check_flag:='Y';

                     l_check_flag2:='Y';

             ELSIF l_check_flag='Y' and
		   l_oper_rec.revision_number>1 and
	 	   p_appr_status='APPROVED'
             THEN
                     OPEN  GetPrevOperDet(l_oper_rec.revision_number,l_oper_rec.CONCATENATED_SEGMENTS);
                     FETCH GetPrevOperDet INTO  l_prev_oper_rec;
                     IF    GetPrevOperDet%NOTFOUND
                     THEN
                         l_check_flag2:='N';
                     ELSE
                        l_check_flag2:='Y';
                     END IF;

                     CLOSE GetPrevOperDet;

                     IF l_check_flag2='Y'
                     THEN
                        UPDATE AHL_OPERATIONS_B
                                    SET REVISION_STATUS_CODE=l_status,
                                    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
                                    START_DATE_ACTIVE=l_fr_date
                        WHERE OPERATION_ID=P_OPERATION_ID;
                        IF l_check_flag3='Y'
                        THEN
                                UPDATE AHL_OPERATIONS_B
                                            SET REVISION_STATUS_CODE=l_status,
                                            OBJECT_VERSION_NUMBER=OBJECT_VERSION_NUMBER+1,
                                            END_DATE_ACTIVE=l_to_date
                                WHERE OPERATION_ID=l_prev_oper_rec.OPERATION_ID;

                                -- Bypass notifications in preventive Maintenance mode.
                                IF (G_PM_INSTALL <> 'Y') THEN
                                  ahl_utility_pvt.get_wf_process_name(
                                     p_object       =>'RM_NTF',
                                     x_active       =>l_active,
                                     x_process_name =>l_process_name ,
                                     x_item_type    =>l_item_type,
                                     x_return_status=>l_return_status,
                                     x_msg_count    =>l_msg_count,
                                     x_msg_data     =>l_msg_data);

                                  IF (l_active = 'Y') THEN
                                     NOTIFY_TERMINATION
                                     (
                                      x_return_status             =>l_return_status,
                                      x_msg_count                 =>l_msg_count,
                                      x_msg_data                  =>l_msg_data,
                                      p_object_type               =>G_OBJECT_TYPE,
                                      p_prim_object_type          =>'OPER',
                                      p_activity_id               =>p_operation_id
                                      );
                                  END IF;
                                END IF;
                        END IF;
                     END IF;
             END IF;
      ELSE
            IF G_DEBUG='Y' THEN
		 AHL_DEBUG_PUB.debug( 'INVALID P_MR_HEADER_ID','+COMPLETE_OPERATION_REVISION+');
                 ROLLBACK;
            END IF;
      END IF;

      IF l_msg_count > 0
      THEN
            X_msg_count := l_msg_count;
            X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RAISE FND_API.G_EXC_ERROR;
      END IF;

	IF G_DEBUG='Y' THEN
	  AHL_DEBUG_PUB.debug( 'Before commit Complete_mr_revision Status----->'||p_appr_status,'+DEBUG_RELATIONS+');
	END IF;

      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT;
      END IF;
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO COMPLETE_OPER_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

 WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO COMPLETE_OPER_REVISION;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
 WHEN OTHERS THEN
    ROLLBACK TO COMPLETE_OPER_REVISION;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>G_PKG_NAME,
                            p_procedure_name  =>'COMPLETE_OPER_REVISION',
                            p_error_text      =>SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded =>FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);

END;



END AHL_RM_APPROVAL_PVT;

/
