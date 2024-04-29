--------------------------------------------------------
--  DDL for Package Body EAM_OP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_OP_UTILITY_PVT" AS
/* $Header: EAMVOPUB.pls 120.7 2006/03/14 20:46:17 pkathoti noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVOPUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_OP_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
--  27-OCT-2004    Girish	      Enhancements Bug 3852846
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_OP_UTILITY_PVT';

        /*********************************************************************
        * Procedure     : Query_Row
        * Parameters IN : wip entity id
        *                 organization Id
        *                 operation_seq_num
        * Parameters OUT NOCOPY: EAM OP column record
        *                 Mesg token Table
        *                 Return Status
        * Purpose       : Procedure will query the database record
        *                 and return with those records.
        ***********************************************************************/

        PROCEDURE Query_Row
        (  p_wip_entity_id       IN  NUMBER
         , p_organization_id     IN  NUMBER
         , p_operation_seq_num   IN  NUMBER
         , x_eam_op_rec          OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_Return_status       OUT NOCOPY VARCHAR2
        )
        IS
                l_eam_op_rec            EAM_PROCESS_WO_PUB.eam_op_rec_type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
                l_dummy                 varchar2(10);
        BEGIN

                SELECT
                         wip_entity_id
                       , organization_id
                       , operation_sequence_id
                       , operation_seq_num
                       , standard_operation_id
                       , department_id
                       , description
                       , minimum_transfer_quantity
                       , count_point_type
                       , backflush_flag
                       , shutdown_type
                       , first_unit_start_date
                       , first_unit_completion_date
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
                       , long_description
                INTO
                         l_eam_op_rec.wip_entity_id
                       , l_eam_op_rec.organization_id
                       , l_eam_op_rec.operation_sequence_id
                       , l_eam_op_rec.operation_seq_num
                       , l_eam_op_rec.standard_operation_id
                       , l_eam_op_rec.department_id
                       , l_eam_op_rec.description
                       , l_eam_op_rec.minimum_transfer_quantity
                       , l_eam_op_rec.count_point_type
                       , l_eam_op_rec.backflush_flag
                       , l_eam_op_rec.shutdown_type
                       , l_eam_op_rec.start_date
                       , l_eam_op_rec.completion_date
                       , l_eam_op_rec.attribute_category
                       , l_eam_op_rec.attribute1
                       , l_eam_op_rec.attribute2
                       , l_eam_op_rec.attribute3
                       , l_eam_op_rec.attribute4
                       , l_eam_op_rec.attribute5
                       , l_eam_op_rec.attribute6
                       , l_eam_op_rec.attribute7
                       , l_eam_op_rec.attribute8
                       , l_eam_op_rec.attribute9
                       , l_eam_op_rec.attribute10
                       , l_eam_op_rec.attribute11
                       , l_eam_op_rec.attribute12
                       , l_eam_op_rec.attribute13
                       , l_eam_op_rec.attribute14
                       , l_eam_op_rec.attribute15
                       , l_eam_op_rec.long_description
                FROM  wip_operations wo
                WHERE wo.wip_entity_id = p_wip_entity_id
                AND   wo.organization_id = p_organization_id
                AND   wo.operation_seq_num = p_operation_seq_num;

                x_return_status  := EAM_PROCESS_WO_PVT.G_RECORD_FOUND;
                x_eam_op_rec     := l_eam_op_rec;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        x_return_status := EAM_PROCESS_WO_PVT.G_RECORD_NOT_FOUND;
                        x_eam_op_rec    := l_eam_op_rec;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        x_eam_op_rec    := l_eam_op_rec;

        END Query_Row;


        /********************************************************************
        * Procedure     : Insert_Row
        * Parameters IN : EAM OP column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an insert into the
        *                 wip_operations table.
        *********************************************************************/

        PROCEDURE Insert_Row
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
		l_count			number;
		l_min_op_seq_num	number;
		l_department_id		number;
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Writing OP rec for ' || p_eam_op_rec.operation_seq_num); END IF;

	-- bug no 3444091
	if p_eam_op_rec.start_date > p_eam_op_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_OP_DT_ERR');
                return;
	end if;

                INSERT INTO WIP_OPERATIONS
                       ( wip_entity_id
                       , operation_seq_num
                       , organization_id
                       , operation_sequence_id
                       , standard_operation_id
                       , department_id
                       , description
                       , scheduled_quantity
                       , quantity_in_queue
                       , quantity_running
                       , quantity_waiting_to_move
                       , quantity_rejected
                       , quantity_scrapped
                       , quantity_completed
                       , first_unit_start_date
                       , first_unit_completion_date
                       , last_unit_start_date
                       , last_unit_completion_date
                       , count_point_type
                       , backflush_flag
                       , minimum_transfer_quantity
                       , shutdown_type
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
                       , long_description
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , last_update_login
                       , request_id
                       , program_application_id
                       , program_id
                       , program_update_date
		       , x_pos
 	               , y_pos)
                VALUES
                       ( p_eam_op_rec.wip_entity_id
                       , p_eam_op_rec.operation_seq_num
                       , p_eam_op_rec.organization_id
                       , p_eam_op_rec.operation_sequence_id
                       , p_eam_op_rec.standard_operation_id
                       , p_eam_op_rec.department_id
                       , p_eam_op_rec.description
                       , 1
                       , 0
                       , 0,0,0,0,0
                       , p_eam_op_rec.start_date
                       , p_eam_op_rec.completion_date
                       , p_eam_op_rec.start_date
                       , p_eam_op_rec.completion_date
                       , p_eam_op_rec.count_point_type
                       , p_eam_op_rec.backflush_flag
                       , p_eam_op_rec.minimum_transfer_quantity
                       , p_eam_op_rec.shutdown_type
                       , p_eam_op_rec.attribute_category
                       , p_eam_op_rec.attribute1
                       , p_eam_op_rec.attribute2
                       , p_eam_op_rec.attribute3
                       , p_eam_op_rec.attribute4
                       , p_eam_op_rec.attribute5
                       , p_eam_op_rec.attribute6
                       , p_eam_op_rec.attribute7
                       , p_eam_op_rec.attribute8
                       , p_eam_op_rec.attribute9
                       , p_eam_op_rec.attribute10
                       , p_eam_op_rec.attribute11
                       , p_eam_op_rec.attribute12
                       , p_eam_op_rec.attribute13
                       , p_eam_op_rec.attribute14
                       , p_eam_op_rec.attribute15
                       , p_eam_op_rec.long_description
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , SYSDATE
                       , FND_GLOBAL.user_id
                       , FND_GLOBAL.login_id
                       , p_eam_op_rec.request_id
                       , p_eam_op_rec.program_application_id
                       , p_eam_op_rec.program_id
                       , SYSDATE
 	               , p_eam_op_rec.x_pos
 	               , p_eam_op_rec.y_pos); --Added for bug#4615678

		       IF p_eam_op_rec.standard_operation_id IS NOT NULL THEN

				FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
				      X_from_entity_name      =>  'BOM_STANDARD_OPERATIONS',
				      X_from_pk1_value        =>  to_char(p_eam_op_rec.standard_operation_id),
				      X_from_pk2_value        =>  '',
				      X_from_pk3_value        =>  '',
				      X_from_pk4_value        =>  '',
				      X_from_pk5_value        =>  '',
				      X_to_entity_name        =>  'EAM_DISCRETE_OPERATIONS',
				      X_to_pk1_value          =>  p_eam_op_rec.wip_entity_id,
				      X_to_pk2_value          =>  p_eam_op_rec.operation_seq_num,
				      X_to_pk3_value          =>  p_eam_op_rec.organization_id,
				      X_to_pk4_value          =>  '',
				      X_to_pk5_value          =>  '',
				      X_created_by            =>  fnd_global.user_id,
				      X_last_update_login     =>  '',
				      X_program_application_id=>  '',
				      X_program_id            =>  '',
				      X_request_id            =>  ''
				    );

				END IF;

	  SELECT count(*) INTO l_count
	    FROM wip_requirement_operations
           WHERE organization_id = p_eam_op_rec.organization_id
	     AND wip_entity_id = p_eam_op_rec.wip_entity_id
	     AND operation_seq_num = 1
	     AND  rownum <=1;

	  IF l_count <> 0 THEN
	    select min(operation_seq_num) into l_min_op_seq_num
	      from wip_operations
	     where organization_id = p_eam_op_rec.organization_id
	       and wip_entity_id = p_eam_op_rec.wip_entity_id ;

		  IF (l_min_op_seq_num is not null) THEN
		     select department_id into l_department_id
		       from wip_operations
		      where organization_id = p_eam_op_rec.organization_id
		        and wip_entity_id = p_eam_op_rec.wip_entity_id
		        and operation_seq_num = l_min_op_seq_num;
		  END IF;


	    update wip_requirement_operations
	       set operation_seq_num = l_min_op_seq_num,
	           department_id = l_department_id
	     where operation_seq_num = 1
	       and organization_id = p_eam_op_rec.organization_id
	       and wip_entity_id = p_eam_op_rec.wip_entity_id ;
	  END IF;

	 SELECT count(*) INTO l_count
	    FROM wip_eam_direct_items
           WHERE organization_id = p_eam_op_rec.organization_id
	     AND wip_entity_id = p_eam_op_rec.wip_entity_id
	     AND operation_seq_num = 1
	     AND  rownum <=1;

	  IF l_count <> 0 THEN
	    select min(operation_seq_num) into l_min_op_seq_num
	      from wip_operations
	     where organization_id = p_eam_op_rec.organization_id
	       and wip_entity_id = p_eam_op_rec.wip_entity_id ;


		  IF (l_min_op_seq_num is not null) THEN
		  begin
		     select department_id into l_department_id
		       from wip_eam_direct_items
		      where organization_id = p_eam_op_rec.organization_id
		        and wip_entity_id = p_eam_op_rec.wip_entity_id
		        and operation_seq_num = l_min_op_seq_num;
		  exception when no_data_found then
			null;
		  end;
		  END IF;

	    update wip_eam_direct_items
	       set operation_seq_num = l_min_op_seq_num,
	           department_id = l_department_id
	     where operation_seq_num = 1
	       and organization_id = p_eam_op_rec.organization_id
	       and wip_entity_id = p_eam_op_rec.wip_entity_id ;
	  END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug ('Creating new operation') ; END IF;

                x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
            WHEN OTHERS THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
                        );

                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        END Insert_Row;

        /********************************************************************
        * Procedure     : Update_Row
        * Parameters IN : EAM OP column record
        * Parameters OUT NOCOPY: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Update on the
        *                 wip_operations table.
        *********************************************************************/

        PROCEDURE Update_Row
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS

	l_old_dept_id NUMBER;
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Updating OP '|| p_eam_op_rec.operation_seq_num); END IF;

        -- bug no 3444091
	if p_eam_op_rec.start_date > p_eam_op_rec.completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_OP_DT_ERR');
                return;
	end if;

	select department_id into l_old_dept_id
	  from wip_operations
 	 WHERE organization_id   = p_eam_op_rec.organization_id
           AND wip_entity_id     = p_eam_op_rec.wip_entity_id
           AND operation_seq_num = p_eam_op_rec.operation_seq_num;


      UPDATE WIP_OPERATIONS
                SET      operation_sequence_id       = p_eam_op_rec.operation_sequence_id
                       , standard_operation_id       = p_eam_op_rec.standard_operation_id
                       , department_id               = p_eam_op_rec.department_id
                       , description                 = p_eam_op_rec.description
                       , first_unit_start_date       = p_eam_op_rec.start_date
                       , first_unit_completion_date  = p_eam_op_rec.completion_date
                       , last_unit_start_date        = p_eam_op_rec.start_date
                       , last_unit_completion_date   = p_eam_op_rec.completion_date
                       , count_point_type            = p_eam_op_rec.count_point_type
                       , backflush_flag              = p_eam_op_rec.backflush_flag
                       , minimum_transfer_quantity   = p_eam_op_rec.minimum_transfer_quantity
                       , shutdown_type               = p_eam_op_rec.shutdown_type
                       , attribute_category          = p_eam_op_rec.attribute_category
                       , attribute1                  = p_eam_op_rec.attribute1
                       , attribute2                  = p_eam_op_rec.attribute2
                       , attribute3                  = p_eam_op_rec.attribute3
                       , attribute4                  = p_eam_op_rec.attribute4
                       , attribute5                  = p_eam_op_rec.attribute5
                       , attribute6                  = p_eam_op_rec.attribute6
                       , attribute7                  = p_eam_op_rec.attribute7
                       , attribute8                  = p_eam_op_rec.attribute8
                       , attribute9                  = p_eam_op_rec.attribute9
                       , attribute10                 = p_eam_op_rec.attribute10
                       , attribute11                 = p_eam_op_rec.attribute11
                       , attribute12                 = p_eam_op_rec.attribute12
                       , attribute13                 = p_eam_op_rec.attribute13
                       , attribute14                 = p_eam_op_rec.attribute14
                       , attribute15                 = p_eam_op_rec.attribute15
                       , long_description            = p_eam_op_rec.long_description
                       , last_update_date            = SYSDATE
                       , last_updated_by             = FND_GLOBAL.user_id
                       , last_update_login           = FND_GLOBAL.login_id
                       , request_id                  = p_eam_op_rec.request_id
                       , program_application_id      = p_eam_op_rec.program_application_id
                       , program_id                  = p_eam_op_rec.program_id
                       , program_update_date         = SYSDATE
		       , x_pos                       = p_eam_op_rec.x_pos      --Added for bug#4615678
 	               , y_pos                       = p_eam_op_rec.y_pos	--Added for bug#4615678
                WHERE    organization_id   = p_eam_op_rec.organization_id
                  AND    wip_entity_id     = p_eam_op_rec.wip_entity_id
                  AND    operation_seq_num = p_eam_op_rec.operation_seq_num;

		-- If Department of operation is updated then correponding departemnt of materials should also get updated
		IF l_old_dept_id <> p_eam_op_rec.department_id THEN
			   UPDATE WIP_REQUIREMENT_OPERATIONS
			   set department_id = p_eam_op_rec.department_id
				WHERE organization_id   = p_eam_op_rec.organization_id
				  AND wip_entity_id     = p_eam_op_rec.wip_entity_id
				  AND operation_seq_num = p_eam_op_rec.operation_seq_num ;

			   UPDATE WIP_EAM_DIRECT_ITEMS
			     SET  Department_id = p_eam_op_rec.department_id
        		   WHERE organization_id   = p_eam_op_rec.organization_id
			     AND wip_entity_id     = p_eam_op_rec.wip_entity_id
			     AND operation_seq_num = p_eam_op_rec.operation_seq_num ;
		END IF;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Update_Row;




        PROCEDURE Delete_Row
        ( p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
        , x_mesg_token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        , x_return_Status      OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Deleting Operation: '|| p_eam_op_rec.operation_seq_num); END IF;

                DELETE FROM WIP_OPERATIONS
                WHERE    wip_entity_id     = p_eam_op_rec.wip_entity_id
                  AND    organization_id   = p_eam_op_rec.organization_id
                  AND    operation_seq_num = p_eam_op_rec.operation_seq_num;

		-- Enhancement Bug 3852846
		UPDATE eam_asset_status_history
		SET enable_flag = 'N'
		    , last_update_date  = SYSDATE
		    , last_updated_by   = FND_GLOBAL.user_id
                    , last_update_login = FND_GLOBAL.login_id
		WHERE wip_entity_id     = p_eam_op_rec.wip_entity_id
                AND   organization_id   = p_eam_op_rec.organization_id
                AND   operation_seq_num = p_eam_op_rec.operation_seq_num
		AND   (enable_flag = 'Y' OR enable_flag IS NULL);

		x_return_status := FND_API.G_RET_STS_SUCCESS;

        END Delete_Row;



        /*********************************************************************
        * Procedure     : Perform_Writes
        * Parameters IN : Operation Record
        * Parameters OUT NOCOPY: Messgae Token Table
        *                 Return Status
        * Purpose       : This is the only procedure that the user will have
        *                 access to when he/she needs to perform any kind of
        *                 writes to the wip_operations.
        *********************************************************************/

        PROCEDURE Perform_Writes
        (  p_eam_op_rec         IN  EAM_PROCESS_WO_PUB.eam_op_rec_type
         , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_return_status      OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
        BEGIN

                IF p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_CREATE
                THEN
                        Insert_Row
                        (  p_eam_op_rec         => p_eam_op_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_UPDATE
                THEN
                        Update_Row
                        (  p_eam_op_rec         => p_eam_op_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
                ELSIF p_eam_op_rec.transaction_type = EAM_PROCESS_WO_PVT.G_OPR_DELETE
                THEN
                        Delete_Row
                        (  p_eam_op_rec         => p_eam_op_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

                END IF;

                x_return_status := l_return_status;
                x_mesg_token_tbl := l_mesg_token_tbl;

        END Perform_Writes;


        FUNCTION NUM_OF_ROW
        ( p_eam_op_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
        , p_wip_entity_id      IN NUMBER
        , p_organization_id    IN NUMBER
        ) RETURN BOOLEAN
        IS

        l_count    NUMBER := 0;

        BEGIN

           begin
               IF p_wip_entity_id is not null
               THEN
                   select count(*)
                   into   l_count
                   from   wip_operations
                   where  wip_entity_id = p_wip_entity_id
                   and    organization_id = p_organization_id
         	   AND  rownum <=1;

               END IF;
           end;

           l_count := l_count + p_eam_op_tbl.COUNT;

             IF (l_count > 0) THEN
                RETURN FALSE;
             ELSE
                RETURN TRUE;
             END IF;

        END NUM_OF_ROW;


END EAM_OP_UTILITY_PVT;

/
