--------------------------------------------------------
--  DDL for Package Body EAM_WO_NETWORK_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_NETWORK_VALIDATE_PVT" AS
/* $Header: EAMVWNVB.pls 120.4.12010000.3 2009/01/27 00:20:30 mashah ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNVB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_NETWORK_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_NETWORK_VALIDATE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;


    /*******************************************************************
    * Procedure	: Validate_Structure
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: The purpose of this procedure is to check the structural
    *             validation errors within a work order network. It checks
    *             for parent child as well as completion dependency
    *             constraints.
    *********************************************************************/
    PROCEDURE Validate_Structure
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_exception_logging             IN      VARCHAR2 := 'N',

	p_validate_status		IN      VARCHAR2 := 'N',
	p_output_errors			IN      VARCHAR2 := 'N',

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2,
        x_wo_relationship_exc_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
        )


    IS
	l_api_name			CONSTANT VARCHAR2(30)	:= 'Validate_Structure';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_top_level_object_id       NUMBER;
    l_top_level_object_type_id  NUMBER;
    l_released_rowcount         NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

    l_exception_msg             VARCHAR2(1000);
    l_wo_relationship_exc_tbl   EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;

    CURSOR  exception_writer_cur(topLvlObj NUMBER, topLvlObjType NUMBER, l_relationship_type NUMBER,l_status_check NUMBER) IS
    SELECT  WSR.SCHED_RELATIONSHIP_ID,
            WE1.WIP_ENTITY_NAME             AS PARENT_JOB,
            WE2.WIP_ENTITY_NAME             AS CHILD_JOB,
            WDJ1.SCHEDULED_START_DATE       AS PARENT_START_DATE,
            WDJ1.SCHEDULED_COMPLETION_DATE  AS PARENT_COMPLETION_DATE,
            WDJ2.SCHEDULED_START_DATE       AS CHILD_START_DATE,
            WDJ2.SCHEDULED_COMPLETION_DATE  AS CHILD_COMPLETION_DATE
    FROM    WIP_SCHED_RELATIONSHIPS WSR,
            WIP_ENTITIES WE1,
            WIP_ENTITIES WE2,
            WIP_DISCRETE_JOBS WDJ1,
            WIP_DISCRETE_JOBS WDJ2
    WHERE   WSR.RELATIONSHIP_STATUS = 3
    AND     WSR.RELATIONSHIP_TYPE = l_relationship_type
    AND     WSR.PARENT_OBJECT_TYPE_ID = 1
    AND     WSR.CHILD_OBJECT_TYPE_ID = 1
    AND     WE1.WIP_ENTITY_ID = WSR.PARENT_OBJECT_ID
    AND     WE2.WIP_ENTITY_ID   = WSR.CHILD_OBJECT_ID
    AND     WDJ1.WIP_ENTITY_ID = WE1.WIP_ENTITY_ID
    AND     WDJ2.WIP_ENTITY_ID = WE2.WIP_ENTITY_ID
    AND     WSR.TOP_LEVEL_OBJECT_ID = topLvlObj
    AND     WSR.TOP_LEVEL_OBJECT_TYPE_ID = topLvlObjType
    AND	    WDJ2.STATUS_TYPE = nvl(l_status_check,WDJ2.STATUS_TYPE);

   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_VALIDATE_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_work_object_type_id       := p_work_object_type_id;
    l_work_object_id            := p_work_object_id;
    l_top_level_object_id       := NULL;
    l_top_level_object_type_id  := NULL;

    /* Obtain TOP Parent Object Information  */

    BEGIN
        l_stmt_num := 20;


        SELECT  WSR.TOP_LEVEL_OBJECT_ID,
                WSR.TOP_LEVEL_OBJECT_TYPE_ID
        INTO    l_top_level_object_id,
                l_top_level_object_type_id
        FROM    WIP_SCHED_RELATIONSHIPS WSR
        WHERE   WSR.CHILD_OBJECT_ID         = l_work_object_id
        AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
        AND     WSR.RELATIONSHIP_TYPE       = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                l_top_level_object_id       := l_work_object_id;
                l_top_level_object_type_id  := l_work_object_type_id;
                --dbms_output.put_line ('TOP = '||l_top_level_object_id);
        WHEN OTHERS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;



    /* Reset Status Flag for the entire structure */
    l_stmt_num := 30;

    -- for fix 7943516

    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 1
    WHERE   WSR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     WSR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id
    AND     WSR.CHILD_OBJECT_ID         = l_work_object_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id;

   /*UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 1
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID  = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID       = l_top_level_object_id;*/

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 1
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID  = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID       = l_top_level_object_id
    AND     EWR.CHILD_OBJECT_ID         = l_work_object_id
    AND     EWR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id;

    -- for fix 7943516



    /* *****************************************************************************
       Check Completion Dependancy between work orders for this structure
       ************************************************************************** */
    l_stmt_num := 40;

    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 3
    WHERE   WSR.SCHED_RELATIONSHIP_ID IN
                (
                SELECT  WSR1.SCHED_RELATIONSHIP_ID
                FROM    WIP_SCHED_RELATIONSHIPS  WSR1,
                        WIP_DISCRETE_JOBS       WDJ1,
                        WIP_DISCRETE_JOBS       WDJ2
                WHERE   WSR1.PARENT_OBJECT_TYPE_ID  = 1
                AND     WSR1.CHILD_OBJECT_TYPE_ID   = 1
                AND     WDJ1.WIP_ENTITY_ID          = WSR1.PARENT_OBJECT_ID
                AND     WDJ2.WIP_ENTITY_ID          = WSR1.CHILD_OBJECT_ID
                AND     WDJ1.SCHEDULED_COMPLETION_DATE   > WDJ2.SCHEDULED_START_DATE
                AND     WSR1.TOP_LEVEL_OBJECT_ID        = l_top_level_object_id
                AND     WSR1.TOP_LEVEL_OBJECT_TYPE_ID   = l_top_level_object_type_id
                AND     WSR1.RELATIONSHIP_TYPE      = 2
                );

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 3
    WHERE   EWR.WO_RELATIONSHIP_ID IN
                (
                SELECT  EWR1.WO_RELATIONSHIP_ID
                FROM    EAM_WO_RELATIONSHIPS  EWR1,
                        WIP_DISCRETE_JOBS       WDJ1,
                        WIP_DISCRETE_JOBS       WDJ2
                WHERE   EWR1.PARENT_OBJECT_TYPE_ID  = 1
                AND     EWR1.CHILD_OBJECT_TYPE_ID   = 1
                AND     WDJ1.WIP_ENTITY_ID          = EWR1.PARENT_OBJECT_ID
                AND     WDJ2.WIP_ENTITY_ID          = EWR1.CHILD_OBJECT_ID
                AND     WDJ1.SCHEDULED_COMPLETION_DATE   > WDJ2.SCHEDULED_START_DATE
                AND     EWR1.TOP_LEVEL_OBJECT_ID        = l_top_level_object_id
                AND     EWR1.TOP_LEVEL_OBJECT_TYPE_ID   = l_top_level_object_type_id
                AND     EWR1.PARENT_RELATIONSHIP_TYPE      = 2
                );

     /* *****************************************************************************
       Check Completion Dependancy between released work orders for this structure
       and Raise ERROR Condition. Stop further processing and RETURN
       Statuses are: 3- Released, 4 - Complete, 5- Complete No Charge
       6 - On Hold, 7- Cancelled, 12 - Closed, 14- Pending Close, 15 - Failed Close
       ************************************************************************** */

  IF (SQL%ROWCOUNT > 0) THEN

    l_released_rowcount := 0;
    l_stmt_num := 50;


    SELECT  COUNT(WSR.SCHED_RELATIONSHIP_ID)
    INTO    l_released_rowcount
    FROM    WIP_SCHED_RELATIONSHIPS  WSR,
            WIP_DISCRETE_JOBS       WDJ
    WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
    AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
    AND     WDJ.WIP_ENTITY_ID          = WSR.CHILD_OBJECT_ID
    AND     WDJ.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
    AND     WSR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id
    AND     WSR.TOP_LEVEL_OBJECT_TYPE_ID    = l_top_level_object_type_id
    AND     WSR.RELATIONSHIP_TYPE           = 2
    AND     WSR.RELATIONSHIP_STATUS         = 3;
    -- No Need to Check parent status as Parent will always be released if child is released


     IF (l_released_rowcount > 0 ) THEN
        -- Error between two released work orders
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
   END IF;


/* Call Parent Child Constraint Checks */
    l_return_status := NULL;

    l_stmt_num := 60;
    EAM_WO_NETWORK_VALIDATE_PVT.Check_Constrained_Children
        (
        p_api_version                   => 1.0,
        p_parent_object_id              => l_top_level_object_id,
        p_parent_object_type_id         => l_top_level_object_type_id,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        --x_Mesg_Token_Tbl                => l_Mesg_Token_Tbl
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END IF;


  IF p_validate_status = 'N' THEN
	--fix for 3433757
	validate_status(p_work_object_id  =>  p_work_object_id,
                   p_work_object_type_id  =>  p_work_object_type_id,
                   x_return_status     => l_return_status
                   );

	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
	END IF;
  ELSE
	-- Added for Detailed Scheduling
	Validate_Network_Status(p_work_object_id          => l_top_level_object_id,
                                p_work_object_type_id     => l_top_level_object_type_id,
		                p_wo_relationship_exc_tbl => l_wo_relationship_exc_tbl
		   );
	 IF (l_wo_relationship_exc_tbl.count >0 ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

        l_stmt_num := 70;

	IF p_output_errors = 'Y' THEN

		FND_MESSAGE.CLEAR;

		FOR type_1 IN exception_writer_cur(l_top_level_object_id, l_top_level_object_type_id, 1,3)
		LOOP
		    l_stmt_num := 80;

		    FND_MESSAGE.SET_NAME('EAM','EAM_TYPE_1_NETWORK_ERROR');
		    FND_MESSAGE.SET_TOKEN('PARENT_JOB',type_1.parent_job);
		    FND_MESSAGE.SET_TOKEN('PARENT_START_DATE',TO_CHAR(type_1.parent_start_date, 'DD-MON-YYYY HH24:MM:SS'));
		    FND_MESSAGE.SET_TOKEN('PARENT_COMPLETION_DATE',TO_CHAR(type_1.parent_completion_date, 'DD-MON-YYYY HH24:MM:SS'));
		    FND_MESSAGE.SET_TOKEN('CHILD_JOB',type_1.child_job);
		    FND_MESSAGE.SET_TOKEN('CHILD_START_DATE',TO_CHAR(type_1.child_start_date, 'DD-MON-YYYY HH24:MM:SS'));
		    FND_MESSAGE.SET_TOKEN('CHILD_COMPLETION_DATE',TO_CHAR(type_1.child_completion_date, 'DD-MON-YYYY HH24:MM:SS'));            l_exception_msg := FND_MESSAGE.GET;

		  IF type_1.parent_job IS NOT NULL THEN

		     IF l_wo_relationship_exc_tbl.COUNT = 0 THEN
				l_wo_relationship_exc_tbl(1) :=l_exception_msg;
			     ELSE
				l_wo_relationship_exc_tbl(l_wo_relationship_exc_tbl.LAST+1) :=l_exception_msg;
		     END IF;
		    l_exception_msg := NULL;
		    FND_MESSAGE.CLEAR;

		  END IF;

		END LOOP;

		FOR type_2 IN exception_writer_cur(l_top_level_object_id, l_top_level_object_type_id, 2,3)
		LOOP
		  IF type_2.parent_job IS NOT NULL THEN

		    l_stmt_num := 90;

		    FND_MESSAGE.SET_NAME('EAM','EAM_TYPE_2_NETWORK_ERROR');
		    FND_MESSAGE.SET_TOKEN('PARENT_JOB',type_2.parent_job);
		    FND_MESSAGE.SET_TOKEN('PARENT_COMPLETION_DATE',TO_CHAR(type_2.parent_completion_date, 'DD-MON-YYYY HH24:MM:SS'));
		    FND_MESSAGE.SET_TOKEN('CHILD_JOB',type_2.child_job);
		    FND_MESSAGE.SET_TOKEN('CHILD_START_DATE',TO_CHAR(type_2.child_start_date, 'DD-MON-YYYY HH24:MM:SS'));
		    l_exception_msg := FND_MESSAGE.GET;

		    IF l_wo_relationship_exc_tbl.COUNT =0 Then
				l_wo_relationship_exc_tbl(1) :=l_exception_msg;
			     ELSE
				l_wo_relationship_exc_tbl(l_wo_relationship_exc_tbl.LAST+1) :=l_exception_msg;
		     END if;

		    l_exception_msg := NULL;
		    FND_MESSAGE.CLEAR;

		  END IF;
		END LOOP;
	END IF; -- END IF for p_output_errors = 'Y'
     END IF;  -- End for IF p_validate_status = 'N'

--Bug3868292: Replaced top_level_object_id with l_top_level_object_id.

    IF (UPPER(p_exception_logging) <> 'N' ) THEN

    -- Purge the WIP_SCHEDULING_EXCEPTIONS table of error messages
    -- from previous runs of Validate_Structure
    delete from wip_scheduling_exceptions
      where exception_type = 2
      and sched_relationship_id in
        (select sched_relationship_id from
         wip_sched_relationships
         start with parent_object_id = l_top_level_object_id
         connect by parent_object_id = prior child_object_id);

        l_stmt_num := 100;

        FND_MESSAGE.CLEAR;

        FOR type_1 IN exception_writer_cur(l_top_level_object_id, l_top_level_object_type_id, 1,to_number(null))
        LOOP
            l_stmt_num := 110;

            FND_MESSAGE.SET_NAME('EAM','EAM_TYPE_1_NETWORK_ERROR');
            FND_MESSAGE.SET_TOKEN('PARENT_JOB',type_1.parent_job);
            FND_MESSAGE.SET_TOKEN('PARENT_START_DATE',TO_CHAR(type_1.parent_start_date, 'DD-MON-YYYY HH24:MM:SS'));
            FND_MESSAGE.SET_TOKEN('PARENT_COMPLETION_DATE',TO_CHAR(type_1.parent_completion_date, 'DD-MON-YYYY HH24:MM:SS'));
            FND_MESSAGE.SET_TOKEN('CHILD_JOB',type_1.child_job);
            FND_MESSAGE.SET_TOKEN('CHILD_START_DATE',TO_CHAR(type_1.child_start_date, 'DD-MON-YYYY HH24:MM:SS'));
            FND_MESSAGE.SET_TOKEN('CHILD_COMPLETION_DATE',TO_CHAR(type_1.child_completion_date, 'DD-MON-YYYY HH24:MM:SS'));            l_exception_msg := FND_MESSAGE.GET;


          if type_1.parent_job is not null then

            BEGIN

            INSERT INTO WIP_SCHEDULING_EXCEPTIONS
            (
            wip_entity_id,
            organization_id,
            mesg_sequence,
            scheduling_source,
            scheduling_source_id,
            message_text,
            message_type,
            marked_flag,
            reported_date,
            last_update_date,
            creation_date,
            created_by,
            last_update_login,
            last_updated_by,
            operation_seq_num,
            resource_seq_num,
            resource_id,
            inventory_item_id,
            instance_id,
            serial_number,
            sched_relationship_id,
            exception_type
            )
            VALUES
            (
            NULL, --wip_entity_id,
            NULL, --organization_id,
            1, --mesg_sequence,
            NULL, --scheduling_source,
            NULL,--scheduling_source_id,
            l_exception_msg, --message_text,
            NULL, --message_type,
            NULL, --marked_flag,
            SYSDATE, --reported_date,
            SYSDATE, --last_update_date,
            SYSDATE, --creation_date,
            -1, --created_by,
            -1, --last_update_login,
            -1, --last_updated_by,
            NULL, --operation_seq_num,
            NULL, --resource_seq_num,
            NULL, --resource_id,
            NULL, --inventory_item_id,
            NULL, --instance_id,
            NULL, --serial_number,
            type_1.sched_relationship_id,
            2 -- exception_type
            );
            EXCEPTION
                WHEN OTHERS THEN
               		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
    	    		);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;

            l_exception_msg := NULL;
            FND_MESSAGE.CLEAR;

          end if;

        END LOOP;

        FOR type_2 IN exception_writer_cur(l_top_level_object_id, l_top_level_object_type_id, 2,to_number(null))
        LOOP
          if type_2.parent_job is not null then

            l_stmt_num := 120;

            FND_MESSAGE.SET_NAME('EAM','EAM_TYPE_2_NETWORK_ERROR');
            FND_MESSAGE.SET_TOKEN('PARENT_JOB',type_2.parent_job);
            FND_MESSAGE.SET_TOKEN('PARENT_COMPLETION_DATE',TO_CHAR(type_2.parent_completion_date, 'DD-MON-YYYY HH24:MM:SS'));
            FND_MESSAGE.SET_TOKEN('CHILD_JOB',type_2.child_job);
            FND_MESSAGE.SET_TOKEN('CHILD_START_DATE',TO_CHAR(type_2.child_start_date, 'DD-MON-YYYY HH24:MM:SS'));
            l_exception_msg := FND_MESSAGE.GET;


            BEGIN
            INSERT INTO WIP_SCHEDULING_EXCEPTIONS
            (
            wip_entity_id,
            organization_id,
            mesg_sequence,
            scheduling_source,
            scheduling_source_id,
            message_text,
            message_type,
            marked_flag,
            reported_date,
            last_update_date,
            creation_date,
            created_by,
            last_update_login,
            last_updated_by,
            operation_seq_num,
            resource_seq_num,
            resource_id,
            inventory_item_id,
            instance_id,
            serial_number,
            sched_relationship_id,
            exception_type
            )
            VALUES
            (
            NULL, --wip_entity_id,
            NULL, --organization_id,
            1, --mesg_sequence,
            NULL, --scheduling_source,
            NULL,--scheduling_source_id,
            l_exception_msg, --message_text,
            NULL, --message_type,
            NULL, --marked_flag,
            SYSDATE, --reported_date,
            SYSDATE, --last_update_date,
            SYSDATE, --creation_date,
            -1, --created_by,
            -1, --last_update_login,
            -1, --last_updated_by,
            NULL, --operation_seq_num,
            NULL, --resource_seq_num,
            NULL, --resource_id,
            NULL, --inventory_item_id,
            NULL, --instance_id,
            NULL, --serial_number,
            type_2.sched_relationship_id,
            2 -- exception_type
            );


            EXCEPTION
                WHEN OTHERS THEN
               		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
    	    		);
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END;

            l_exception_msg := NULL;
            FND_MESSAGE.CLEAR;

          end if;
        END LOOP;

    END IF;


    /* Status Flag for the successful Rows */
    l_stmt_num := 130;

     --fix for 7943516

    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 2
    WHERE   WSR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     WSR.TOP_LEVEL_OBJECT_ID      = l_top_level_object_id
    AND     WSR.CHILD_OBJECT_ID         = l_work_object_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
    AND     WSR.RELATIONSHIP_STATUS     <> 3;


    /*UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 2
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID      = l_top_level_object_id
    AND     EWR.RELATIONSHIP_STATUS     <> 3;*/

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 2
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID      = l_top_level_object_id
    AND     EWR.CHILD_OBJECT_ID         = l_work_object_id
    AND     EWR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
    AND     EWR.RELATIONSHIP_STATUS     <> 3;

     --fix for 7943516

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	x_msg_count := FND_MSG_PUB.Count_Msg;
	x_wo_relationship_exc_tbl := l_wo_relationship_exc_tbl;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);

    /* Reset Status Flag for the entire structure */
    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 0
    WHERE   WSR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     WSR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id;

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 0
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

    /* Reset Status Flag for the entire structure */
    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 0
    WHERE   WSR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     WSR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id;

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 0
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID         = l_top_level_object_id;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

    /* Reset Status Flag for the entire structure */
    UPDATE  WIP_SCHED_RELATIONSHIPS WSR
    SET     WSR.RELATIONSHIP_STATUS = 0
    WHERE   WSR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     WSR.TOP_LEVEL_OBJECT_ID      = l_top_level_object_id;

    UPDATE  EAM_WO_RELATIONSHIPS EWR
    SET     EWR.RELATIONSHIP_STATUS = 0
    WHERE   EWR.TOP_LEVEL_OBJECT_TYPE_ID = l_top_level_object_type_id
    AND     EWR.TOP_LEVEL_OBJECT_ID      = l_top_level_object_id;

    END Validate_Structure;



    /*******************************************************************
    * Procedure	: Check_Constrained_Children
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This procedure is called to validate that all immediate
    *             children a constraining parent falls within the timespan
    *             of the parent work order. The procedure is called
    *             recurssively to process multilevel structures
    *********************************************************************/


    PROCEDURE Check_Constrained_Children
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_parent_object_id                IN      NUMBER,
        p_parent_object_type_id           IN      NUMBER,


        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        )

    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Check_Constrained_Children';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_parent_object_id          NUMBER;
    l_parent_object_type_id     NUMBER;
    l_released_rowcount         NUMBER;


    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

   CURSOR constrained_children_cur (l_p_object NUMBER, l_p_object_type NUMBER) IS
    SELECT  WSR.CHILD_OBJECT_ID,
            WSR.CHILD_OBJECT_TYPE_ID
    FROM    WIP_SCHED_RELATIONSHIPS WSR
    WHERE   WSR.PARENT_OBJECT_ID        = l_p_object
    AND     WSR.PARENT_OBJECT_TYPE_ID   = l_p_object_type
    AND     WSR.RELATIONSHIP_TYPE       = 1;


   BEGIN
	-- Standard Start of API savepoint

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_parent_object_type_id       := p_parent_object_type_id;
    l_parent_object_id            := p_parent_object_id;


    /* Open Cursor for the current parent */

    FOR child IN constrained_children_cur (l_parent_object_id, l_parent_object_type_id)
    LOOP

        l_stmt_num := 20;
                 --Code in the following conditional block is for replacing original update statements with performance issue
 	         --Fix for bug 7660880
 	IF (child.child_object_type_id = 1 AND l_parent_object_type_id = 1) THEN
        UPDATE  WIP_SCHED_RELATIONSHIPS WSR
        SET     WSR.RELATIONSHIP_STATUS = 3
        WHERE  WSR.CHILD_OBJECT_TYPE_ID   = child.child_object_type_id
        AND    WSR.CHILD_OBJECT_ID        = child.child_object_id
        AND    WSR.PARENT_OBJECT_TYPE_ID  = l_parent_object_type_id
        AND    WSR.PARENT_OBJECT_ID       = l_parent_object_id
        AND    WSR.RELATIONSHIP_TYPE      = 1
        AND    EXISTS (SELECT *
                          FROM   WIP_DISCRETE_JOBS WDJ1,
				 WIP_DISCRETE_JOBS WDJ2
                          WHERE  WDJ1.WIP_ENTITY_ID = l_parent_object_id
                          AND  WDJ2.WIP_ENTITY_ID          = child.child_object_id
                          AND (WDJ2.SCHEDULED_START_DATE  < WDJ1.SCHEDULED_START_DATE
                            OR
                               WDJ2.SCHEDULED_COMPLETION_DATE > WDJ1.SCHEDULED_COMPLETION_DATE)
		            AND NOT (WDJ2.STATUS_TYPE = 7
			    OR
			     (WDJ2.STATUS_TYPE IN (12,14,15) AND WDJ2.DATE_COMPLETED IS NULL)));


        UPDATE  EAM_WO_RELATIONSHIPS EWR
        SET     EWR.RELATIONSHIP_STATUS = 3
        WHERE   EWR.CHILD_OBJECT_TYPE_ID     = child.child_object_type_id
	AND     EWR.CHILD_OBJECT_ID          = child.child_object_id
	AND     EWR.PARENT_OBJECT_TYPE_ID    = l_parent_object_type_id
	AND     EWR.PARENT_OBJECT_ID         = l_parent_object_id
	AND     EWR.PARENT_RELATIONSHIP_TYPE = 1
	AND     EXISTS (SELECT *
 	                           FROM   WIP_DISCRETE_JOBS WDJ1,
					  WIP_DISCRETE_JOBS WDJ2
				   WHERE  WDJ1.WIP_ENTITY_ID = l_parent_object_id
				   AND     WDJ2.WIP_ENTITY_ID = child.child_object_id
	                           AND     (WDJ2.SCHEDULED_START_DATE  < WDJ1.SCHEDULED_START_DATE
                            OR
                            WDJ2.SCHEDULED_COMPLETION_DATE > WDJ1.SCHEDULED_COMPLETION_DATE)
		         AND NOT (WDJ2.STATUS_TYPE = 7
			   OR
			             (WDJ2.STATUS_TYPE IN (12,14,15) AND WDJ2.DATE_COMPLETED IS NULL)));
	END IF;



     /* *****************************************************************************
       Check Parent Child Constraints between released work orders for this structure
       and Raise ERROR Condition. Stop further processing and RETURN
       Statuses are: 3- Released, 4 - Complete, 5- Complete No Charge
       6 - On Hold,  12 - Closed, 14- Pending Close, 15 - Failed Close
       ************************************************************************** */

    IF (SQL%ROWCOUNT > 0) THEN
    l_stmt_num := 30;
    l_released_rowcount := 0;


    SELECT  COUNT(SCHED_RELATIONSHIP_ID)
    INTO    l_released_rowcount
    FROM    WIP_SCHED_RELATIONSHIPS  WSR,
            WIP_DISCRETE_JOBS       WDJ
    WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
    AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
    AND     WSR.PARENT_OBJECT_ID         = l_parent_object_id
    AND     WSR.PARENT_OBJECT_TYPE_ID    = l_parent_object_type_id
    AND     WSR.RELATIONSHIP_TYPE           = 1
    AND     WSR.RELATIONSHIP_STATUS         = 3
    AND     WDJ.WIP_ENTITY_ID          = WSR.CHILD_OBJECT_ID
    AND     WDJ.STATUS_TYPE            IN (3,4,5,6,7,12,14,15);
    -- No Need to Check parent status as Parent will always be released if child is released

    --dbms_output.put_line ('Released Count ='||l_released_rowcount);


    IF (l_released_rowcount > 0 ) THEN
        -- Error between two released work orders
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    END IF;

    /* Recursive Call to the validation API */
    l_stmt_num := 40;
    EAM_WO_NETWORK_VALIDATE_PVT.Check_Constrained_Children
        (
        p_api_version                   => 1.0,
        p_parent_object_id              => child.child_object_id,
        p_parent_object_type_id         => child.child_object_type_id,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END IF;


    END LOOP;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

        RETURN;
    END Check_Constrained_Children;


--fix for 3433757.added procedure validate_status to validate the statuses of parent and child
---------------------------------------------------------------------------------------------
-- Valid statuses for parent and child are
--               Parent                       Child
-------------------------------------------------------------------------
--              Draft                         Draft,cancelled,on-hold
--              Unreleased                    Draft,Unreleased,cancelled,on-hold
--              Released,On-hold              Draft,Unreleased,Released,On-hold,Cancelled,Complete,comp-no-chrg,closed,pend-close,failed close
--              Cancelled                     Cancelled,Closed,pend-close,failed close
--              Complete,Comp-no-charg,closed,  Complete,comp-no-chrg,closed ,Cancelled,pend-close,failed close
--               pend-close,failed close
---------------------------------------------------------------------------------------------
PROCEDURE Validate_Status
       (
          p_work_object_id                IN      NUMBER,
          p_work_object_type_id           IN      NUMBER,
          x_return_status                 OUT NOCOPY  VARCHAR2
       )
       IS
          l_parent_status  NUMBER;
          l_parent_count   NUMBER := 0;
          l_wo_status      NUMBER;
          l_invalid_child NUMBER:=0;
          --Added variables l_pending_flag,l_user_defined_status for Bug #5350181.
          l_pending_flag VARCHAR2(1);
          l_user_defined_status NUMBER;

       BEGIN
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          --Bug #5350181 :Changed the query to capture pending flag and user defined status

	   SELECT wdj.status_type,ewod.user_defined_status_id,ewod.pending_flag
           INTO l_wo_status,l_user_defined_status,l_pending_flag
           FROM wip_discrete_jobs wdj,eam_work_order_details_v ewod
           WHERE wdj.wip_entity_id=p_work_object_id
           and ewod.wip_entity_id=wdj.wip_entity_id;

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('workorder status'||l_wo_status); END IF;

       BEGIN
               SELECT wdj.status_type
               INTO l_parent_status
               FROM  wip_discrete_jobs wdj,wip_sched_relationships wsr
               WHERE wsr.child_object_id =p_work_object_id
               and wsr.child_object_type_id = p_work_object_type_id
               and wsr.relationship_type = 1
               and wdj.wip_entity_id = wsr.parent_object_id;



IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('inside parent status validation :parent status'||l_parent_status); END IF;

               IF(  ((l_parent_status=17) and (l_wo_status NOT IN (17,7,6)))
                  OR ((l_parent_status=1) and (l_wo_status NOT IN (17,7,1,6)))
                  OR ((l_parent_status IN (3,6)) and (l_wo_status NOT IN (3,6,17,7,1,12,14,15,4,5)))
                  OR ((l_parent_status=7) and (l_wo_status NOT IN (7,12,14,15)))
                  OR ((l_parent_status IN (4,5,12,14,15)) and (l_wo_status NOT IN (4,5,12,14,15,7)))
                  -- Bug #5350181: A child work order can't be sent for release approval when is parent is not in released status.
                  OR ((l_parent_status NOT IN (3,6))and (l_user_defined_status IN(3) and l_pending_flag='Y'))
                  ) THEN
                  x_return_status:=FND_API.G_RET_STS_ERROR;
              END IF;
IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('after parent status validation :'||x_return_status); END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             null;
     END;

           l_invalid_child  := 0;

           IF(l_wo_status=17) THEN
              SELECT COUNT(*)
              INTO l_invalid_child
              FROM wip_discrete_jobs wdj,wip_sched_relationships wsr
              WHERE wsr.parent_object_id=p_work_object_id
              AND wsr.parent_object_type_id= p_work_object_type_id
              AND wsr.child_object_type_id=p_work_object_type_id
              AND wsr.child_object_id=wdj.wip_entity_id
              AND wsr.relationship_type = 1
              AND wdj.status_type NOT IN (17,7,6);
           ELSIF(l_wo_status=1) THEN
              SELECT COUNT(*)
              INTO l_invalid_child
              FROM wip_discrete_jobs wdj,wip_sched_relationships wsr
              WHERE wsr.parent_object_id=p_work_object_id
              AND wsr.parent_object_type_id= p_work_object_type_id
              AND wsr.child_object_type_id=p_work_object_type_id
              AND wsr.child_object_id=wdj.wip_entity_id
              AND wsr.relationship_type = 1
              AND wdj.status_type NOT IN (17,7,1,6);
           ELSIF(l_wo_status IN (3,6)) THEN
              SELECT COUNT(*)
              INTO l_invalid_child
              FROM wip_discrete_jobs wdj,wip_sched_relationships wsr
              WHERE wsr.parent_object_id=p_work_object_id
              AND wsr.parent_object_type_id= p_work_object_type_id
              AND wsr.child_object_type_id=p_work_object_type_id
              AND wsr.child_object_id=wdj.wip_entity_id
              AND wsr.relationship_type = 1
              AND wdj.status_type NOT IN (3,6,17,7,1,12,14,15,4,5);
           ELSIF(l_wo_status=7) THEN
              SELECT COUNT(*)
              INTO l_invalid_child
              FROM wip_discrete_jobs wdj,wip_sched_relationships wsr
              WHERE wsr.parent_object_id=p_work_object_id
              AND wsr.parent_object_type_id= p_work_object_type_id
              AND wsr.child_object_type_id=p_work_object_type_id
              AND wsr.child_object_id=wdj.wip_entity_id
              AND wsr.relationship_type = 1
              AND wdj.status_type NOT IN (7,12,14,15);
           ELSIF(l_wo_status IN (4,5,12,14,15)) THEN
              SELECT COUNT(*)
              INTO l_invalid_child
              FROM wip_discrete_jobs wdj,wip_sched_relationships wsr
              WHERE wsr.parent_object_id=p_work_object_id
              AND wsr.parent_object_type_id= p_work_object_type_id
              AND wsr.child_object_type_id=p_work_object_type_id
              AND wsr.child_object_id=wdj.wip_entity_id
              AND wsr.relationship_type = 1
              AND wdj.status_type NOT IN (4,5,12,14,15,7);
           END IF;

          IF(l_invalid_child<>0) THEN
              x_return_status:=FND_API.G_RET_STS_ERROR;
          END IF;

IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('after child status validation :'||x_return_status); END IF;
       END Validate_Status;

     -- Added for Detailed Scheduling.Validates the status of entire hierarchy
     PROCEDURE Validate_Network_Status
       (
          p_work_object_id                IN      NUMBER,
          p_work_object_type_id           IN      NUMBER,
	  p_wo_relationship_exc_tbl       IN OUT NOCOPY EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
       )
       IS
       	  l_wo_status           NUMBER;
	  l_wo_status_meaning	VARCHAR2(80);
	  l_exception_msg       VARCHAR2(1000);
	  x_return_status	VARCHAR2(1);

	  TYPE wip_entity_id_tbl_type     is TABLE OF number INDEX BY BINARY_INTEGER;
          TYPE workorder_status_tbl_type  is TABLE OF varchar2(1000) INDEX BY BINARY_INTEGER;

	  l_WipEntityId_tbl	     wip_entity_id_tbl_type;
	  l_workorder_status_tbl     workorder_status_tbl_type;

	   CURSOR constrained_children_cur (l_p_object NUMBER, l_p_object_type NUMBER) IS
	    SELECT  WSR.CHILD_OBJECT_ID,
		    WSR.CHILD_OBJECT_TYPE_ID
		    FROM    WIP_SCHED_RELATIONSHIPS WSR
		    WHERE   WSR.PARENT_OBJECT_ID        = l_p_object
		    AND     WSR.PARENT_OBJECT_TYPE_ID   = l_p_object_type
		    AND     WSR.RELATIONSHIP_TYPE       = 1;

	      CURSOR get_status(p_work_object_id NUMBER) IS
              SELECT work_order_status
		FROM eam_work_order_details ewod,eam_wo_statuses_v ewsv
		WHERE ewod.wip_entity_id = p_work_object_id
		  AND ewod.user_defined_status_id = ewsv.status_id;
       BEGIN

  	    x_return_status := FND_API.G_RET_STS_SUCCESS;

	    OPEN get_status(p_work_object_id);
	    FETCH get_status INTO l_wo_status_meaning ;
	    CLOSE get_status;

	    l_WipEntityId_tbl.delete;
	    l_workorder_status_tbl.delete;

	   IF(l_wo_status=17) THEN
	      SELECT wsr.child_object_id,lk.meaning BULK COLLECT INTO
	      l_WipEntityId_tbl,l_workorder_status_tbl
	      FROM wip_discrete_jobs wdj,wip_sched_relationships wsr,mfg_lookups lk
	      WHERE wsr.parent_object_id=p_work_object_id
	      AND wsr.parent_object_type_id= p_work_object_type_id
	      AND wsr.child_object_type_id=p_work_object_type_id
	      AND wsr.child_object_id=wdj.wip_entity_id
	      AND wsr.relationship_type = 1
	      AND wdj.status_type NOT IN (17,7,6)
	      AND lk.lookup_type = 'WIP_JOB_STATUS'
	      AND lk.lookup_code = wdj.status_type;
	   ELSIF(l_wo_status=1) THEN
	    SELECT wsr.child_object_id,lk.meaning  BULK COLLECT INTO
	      l_WipEntityId_tbl,l_workorder_status_tbl
	      FROM wip_discrete_jobs wdj,wip_sched_relationships wsr,mfg_lookups lk
	      WHERE wsr.parent_object_id=p_work_object_id
	      AND wsr.parent_object_type_id= p_work_object_type_id
	      AND wsr.child_object_type_id=p_work_object_type_id
	      AND wsr.child_object_id=wdj.wip_entity_id
	      AND wsr.relationship_type = 1
	      AND wdj.status_type NOT IN (17,7,1,6)
	      AND lk.lookup_type = 'WIP_JOB_STATUS'
	      AND lk.lookup_code = wdj.status_type;
	   ELSIF(l_wo_status IN (3,6)) THEN
	      SELECT wsr.child_object_id,lk.meaning  BULK COLLECT INTO
	      l_WipEntityId_tbl,l_workorder_status_tbl
	      FROM wip_discrete_jobs wdj,wip_sched_relationships wsr,mfg_lookups lk
	      WHERE wsr.parent_object_id=p_work_object_id
	      AND wsr.parent_object_type_id= p_work_object_type_id
	      AND wsr.child_object_type_id=p_work_object_type_id
	      AND wsr.child_object_id=wdj.wip_entity_id
	      AND wsr.relationship_type = 1
	      AND wdj.status_type NOT IN (3,6,17,7,1,12,14,15,4,5)
      	      AND lk.lookup_type = 'WIP_JOB_STATUS'
	      AND lk.lookup_code = wdj.status_type;
	   ELSIF(l_wo_status=7) THEN
	       SELECT wsr.child_object_id,lk.meaning  BULK COLLECT INTO
	      l_WipEntityId_tbl,l_workorder_status_tbl
	      FROM wip_discrete_jobs wdj,wip_sched_relationships wsr,mfg_lookups lk
	      WHERE wsr.parent_object_id=p_work_object_id
	      AND wsr.parent_object_type_id= p_work_object_type_id
	      AND wsr.child_object_type_id=p_work_object_type_id
	      AND wsr.child_object_id=wdj.wip_entity_id
	      AND wsr.relationship_type = 1
	      AND wdj.status_type NOT IN (7,12,14,15)
      	      AND lk.lookup_type = 'WIP_JOB_STATUS'
	      AND lk.lookup_code = wdj.status_type;
	   ELSIF(l_wo_status IN (4,5,12,14,15)) THEN
	     SELECT wsr.child_object_id,lk.meaning  BULK COLLECT INTO
	      l_WipEntityId_tbl,l_workorder_status_tbl
	      FROM wip_discrete_jobs wdj,wip_sched_relationships wsr,mfg_lookups lk
	      WHERE wsr.parent_object_id=p_work_object_id
	      AND wsr.parent_object_type_id= p_work_object_type_id
	      AND wsr.child_object_type_id=p_work_object_type_id
	      AND wsr.child_object_id=wdj.wip_entity_id
	      AND wsr.relationship_type = 1
	      AND wdj.status_type NOT IN (4,5,12,14,15,7)
      	      AND lk.lookup_type = 'WIP_JOB_STATUS'
	      AND lk.lookup_code = wdj.status_type;
	   END IF;

	IF l_WipEntityId_tbl.COUNT > 0 THEN
		FOR tbl_counter IN l_WipEntityId_tbl.FIRST..l_WipEntityId_tbl.LAST LOOP
		    FND_MESSAGE.SET_NAME('EAM','EAM_WO_REL_STATUS_ERROR');
		    FND_MESSAGE.SET_TOKEN('PARENT_JOB',p_work_object_id);
		    FND_MESSAGE.SET_TOKEN('PARENT_STATUS',l_wo_status_meaning);
		    FND_MESSAGE.SET_TOKEN('CHILD_JOB',l_WipEntityId_tbl(tbl_counter));
		    FND_MESSAGE.SET_TOKEN('CHILD_STATUS',l_workorder_status_tbl(tbl_counter));
		    l_exception_msg := FND_MESSAGE.GET;

		    IF p_wo_relationship_exc_tbl.COUNT =0 Then
				p_wo_relationship_exc_tbl(1) :=l_exception_msg;
			     ELSE
				p_wo_relationship_exc_tbl(p_wo_relationship_exc_tbl.LAST+1) :=l_exception_msg;
		     END if;
		END LOOP;
	END IF;

	  FOR child IN constrained_children_cur(p_work_object_id, p_work_object_type_id)
	    LOOP
		 EAM_WO_NETWORK_VALIDATE_PVT.Validate_Network_Status
		          (p_work_object_id  =>   child.child_object_id,
			   p_work_object_type_id  =>  child.child_object_type_id,
			   p_wo_relationship_exc_tbl  => p_wo_relationship_exc_tbl
			  );
	    END LOOP;

	   IF EAM_PROCESS_WO_PVT.GET_DEBUG = 'Y' THEN
		IF p_wo_relationship_exc_tbl.count >0 THEN
			x_return_status:=FND_API.G_RET_STS_ERROR;
		END IF;
		EAM_ERROR_MESSAGE_PVT.Write_Debug('after Validate_Network_Status status validation :'||x_return_status);
	   END IF;

       END Validate_Network_Status;


END EAM_WO_NETWORK_VALIDATE_PVT;

/
