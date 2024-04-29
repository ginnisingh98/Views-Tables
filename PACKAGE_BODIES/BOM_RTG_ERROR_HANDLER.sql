--------------------------------------------------------
--  DDL for Package Body BOM_RTG_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_ERROR_HANDLER" AS
/* $Header: BOMROEHB.pls 120.1 2005/12/01 03:02:50 dikrishn noship $ */
/*************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMROEHB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Rtg_Error_Handler
--
--  NOTES   This package is created to make the RTG Business Object
--          independent of Bom Business Object.
--          Log_Error for Routing Bo procedure have been moved here from
--          Error_Handler package. This Log_Error procedure calls
--          Error Handler's functions.
--
--  HISTORY
--
--  14-DEC-00   Masanori Kimizuka      Initial Creation
--
--
*************************************************************************/

    /*******************************************************
    -- Routing BO records
    ********************************************************/
    g_rtg_header_rec         Bom_Rtg_Pub.Rtg_Header_Rec_Type ;
    g_rtg_revision_tbl       Bom_Rtg_Pub.Rtg_Revision_Tbl_Type ;
    g_operation_tbl          Bom_Rtg_Pub.Operation_Tbl_Type ;
    g_op_resource_tbl        Bom_Rtg_Pub.Op_Resource_Tbl_Type ;
    g_sub_resource_tbl       Bom_Rtg_Pub.Sub_Resource_Tbl_Type ;
    g_op_network_tbl         Bom_Rtg_Pub.Op_Network_Tbl_Type ;

       /* BOM BO RECORDS added for add_message procedure */
    g_bom_header_rec         Bom_Bo_Pub.Bom_Head_Rec_Type := Bom_Bo_Pub.G_MISS_BOM_HEADER_REC;
    g_bom_revision_tbl       Bom_Bo_Pub.Bom_Revision_Tbl_Type := Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL;
    g_bom_component_tbl      Bom_Bo_pub.Bom_Comps_Tbl_Type := Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
    g_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type := Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL;
    g_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type := Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
    g_bom_comp_ops_tbl       Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type := Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL;
        /* BOM BO RECORDS added for add_message procedure */

    G_ERROR_TABLE           Error_Handler.Error_Tbl_Type;
    G_Msg_Index             NUMBER := 0;
    G_Msg_Count             NUMBER := 0;


    /******************************************************************
    * Procedure     : setSubResources (Unexposed)
    * Parameters    : Other Message
    *                 Other Status
    *                 Error Scope
    *                 Entity Index
    *                 Operation Index
    *                 Operation Resource Index
    * Purpose       : This procedure will set the reference designator
    *                 record status to other status by looking at the
    *                 revised item key or the revised component key or
    *                 else setting all the record status to other status
    ********************************************************************/
    /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.
       Passed this p_other_mesg_name to p_mesg_name parameter in the calls to Add_message procedure.*/
    PROCEDURE setSubResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER
     , p_res_idx            IN  NUMBER
     , p_entity_index       IN  NUMBER
     , p_other_mesg_name    IN  VARCHAR2 := NULL
    )
    IS

                l_idx   NUMBER;
    BEGIN
         IF p_error_scope = G_SCOPE_ALL
         THEN
             FOR l_idx IN 1..g_sub_resource_tbl.COUNT
             LOOP
                 g_sub_resource_tbl(l_idx).return_status := p_other_status;

                 IF p_other_mesg_text IS NOT NULL
                 THEN
                       Error_Handler.Add_Message
                       (  p_mesg_text   => p_other_mesg_text
                        , p_entity_id   => G_SR_LEVEL
                        , p_entity_index=> l_idx
			, p_row_identifier => g_sub_resource_tbl(l_idx).row_identifier
                        , p_message_type=> 'E'
                        , p_mesg_name   => p_other_mesg_name
                        , p_bom_header_rec =>  g_bom_header_rec
                        , p_bom_revision_tbl =>  g_bom_revision_tbl
			, p_bom_component_tbl => g_bom_component_tbl
			, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
			, p_bom_sub_component_tbl => g_bom_sub_component_tbl
			, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
			);
                 END IF;
             END LOOP;

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_op_idx <> 0
         THEN

                FOR l_idx IN 1..g_sub_resource_tbl.COUNT
                LOOP
                   IF NVL(g_sub_resource_tbl(l_idx).operation_sequence_number,
                          FND_API.G_MISS_NUM) =
                      NVL(g_operation_tbl(p_op_idx).operation_sequence_number,
                          FND_API.G_MISS_NUM)
                   AND
                      NVL(g_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                      NVL(g_operation_tbl(p_op_idx).start_effective_date, SYSDATE)
                   AND
                      NVL(g_sub_resource_tbl(l_idx).operation_type, FND_API.G_MISS_NUM) =
                      NVL(g_operation_tbl(p_op_idx).operation_type, FND_API.G_MISS_NUM)
                   THEN

                        g_sub_resource_tbl(l_idx).return_status := p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
			 , p_row_identifier	=> g_sub_resource_tbl(l_idx).row_identifier
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
			, p_bom_header_rec =>  g_bom_header_rec
			, p_bom_revision_tbl =>  g_bom_revision_tbl
			, p_bom_component_tbl => g_bom_component_tbl
			, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
			, p_bom_sub_component_tbl => g_bom_sub_component_tbl
			, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
			);
                    END IF;
                END LOOP;  -- Sub Res Children of Op Seq Ends.

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND p_res_idx <> 0
         THEN

                FOR l_idx IN 1..g_sub_resource_tbl.COUNT
                LOOP
                    IF NVL(g_sub_resource_tbl(l_idx).operation_sequence_number,
                           FND_API.G_MISS_NUM) =
                       NVL(g_op_resource_tbl(p_res_idx).operation_sequence_number,
                           FND_API.G_MISS_NUM)
                    AND
                       NVL(g_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                       NVL(g_op_resource_tbl(p_res_idx).op_start_effective_date,
                            SYSDATE)
                    AND
                       NVL(g_sub_resource_tbl(l_idx).operation_type, FND_API.G_MISS_NUM) =
                       NVL(g_op_resource_tbl(p_res_idx).operation_type,
                           FND_API.G_MISS_NUM)
                    THEN
                        g_sub_resource_tbl(l_idx).return_status := p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
			 , p_row_identifier	=> g_sub_resource_tbl(l_idx).row_identifier
                         , p_message_type       => 'E'
                         , p_mesg_name   	=> p_other_mesg_name
			 , p_bom_header_rec =>  g_bom_header_rec
			, p_bom_revision_tbl =>  g_bom_revision_tbl
			, p_bom_component_tbl => g_bom_component_tbl
			, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
			, p_bom_sub_component_tbl => g_bom_sub_component_tbl
			, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
			);
                    END IF;
                END LOOP;

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
               p_op_idx  = 0 AND
               p_res_idx = 0
         THEN


                FOR l_idx IN 1..g_sub_resource_tbl.COUNT
                LOOP
                    IF NVL(g_sub_resource_tbl(l_idx).operation_sequence_number,
                           FND_API.G_MISS_NUM) =
                       NVL(g_sub_resource_tbl(p_entity_index).operation_sequence_number,
                           FND_API.G_MISS_NUM)
                    AND
                       NVL(g_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                       NVL(g_sub_resource_tbl(p_entity_index).op_start_effective_date,
                            SYSDATE)
                    AND
                       NVL(g_sub_resource_tbl(l_idx).operation_type, FND_API.G_MISS_NUM) =
                       NVL(g_sub_resource_tbl(p_entity_index).operation_type,
                           FND_API.G_MISS_NUM)
                    THEN
                        g_sub_resource_tbl(l_idx).return_status := p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
			 , p_row_identifier	=> g_sub_resource_tbl(l_idx).row_identifier
                         , p_message_type       => 'E'
                         , p_mesg_name   	=> p_other_mesg_name
			, p_bom_header_rec =>  g_bom_header_rec
			, p_bom_revision_tbl =>  g_bom_revision_tbl
			, p_bom_component_tbl => g_bom_component_tbl
			, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
			, p_bom_sub_component_tbl => g_bom_sub_component_tbl
			, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
			);
                    END IF;
                END LOOP;


         END IF; -- If Scope = Ends.

    END setSubResources;


    /******************************************************************
    * Procedure : setOperationResources (Unexposed)
    * Parameters    : Other Message
    *                 Other Status
    *                 Error Scope
    *                 Entity Index
    *                 Operation Index
    * Purpose   : This procedure will set the operation resource
    *             record status to other status by looking at the
    *             operation sequence key or else setting all the record
    *             status to other status
    ********************************************************************/
    /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.
       Passed this p_other_mesg_name to Add_message, setSubResources procedures calls.*/
    PROCEDURE setOperationResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER
     , p_entity_index       IN  NUMBER
     , p_other_mesg_name    IN  VARCHAR2 := NULL
    )
    IS
        l_idx   NUMBER;
    BEGIN

        IF p_error_scope = G_SCOPE_ALL
        THEN
           FOR l_idx IN (p_entity_index+1)..g_op_resource_tbl.COUNT
           LOOP
               g_op_resource_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  Error_Handler.Add_Message
                  ( p_mesg_text     => p_other_mesg_text
                  , p_entity_id     => G_RES_LEVEL
                  , p_entity_index  => l_idx
		  , p_row_identifier => g_op_resource_tbl(l_idx).row_identifier
                  , p_message_type  => 'E'
                  , p_mesg_name     => p_other_mesg_name
		, p_bom_header_rec =>  g_bom_header_rec
		, p_bom_revision_tbl =>  g_bom_revision_tbl
		, p_bom_component_tbl => g_bom_component_tbl
		, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
		, p_bom_sub_component_tbl => g_bom_sub_component_tbl
		, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
		);
               END IF;
            END LOOP;

            --
            -- Set the Substitute Operation Resources Record Status too
            --
            setSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             , p_op_idx             => 0
             , p_res_idx            => 0
             , p_entity_index       => 0
             , p_other_mesg_name    => p_other_mesg_name
             );


        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_op_idx <> 0
        THEN


            FOR l_idx IN 1..g_op_resource_tbl.COUNT
            LOOP
                IF NVL(g_op_resource_tbl(l_idx).operation_sequence_number,
                       FND_API.G_MISS_NUM) =
                   NVL(g_operation_tbl(p_op_idx).operation_sequence_number,
                       FND_API.G_MISS_NUM)
                AND
                   NVL(g_op_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                   NVL(g_operation_tbl(p_op_idx).start_effective_date, SYSDATE)
                AND
                   NVL(g_op_resource_tbl(l_idx).operation_type, FND_API.G_MISS_NUM) =
                   NVL(g_operation_tbl(p_op_idx).operation_type, FND_API.G_MISS_NUM)
                THEN

                    g_op_resource_tbl(l_idx).return_status := p_other_status;
                    Error_Handler.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_RES_LEVEL
                     , p_entity_index   => l_idx
		     , p_row_identifier => g_op_resource_tbl(l_idx).row_identifier
                     , p_message_type   => 'E'
                     , p_mesg_name      => p_other_mesg_name
			, p_bom_header_rec =>  g_bom_header_rec
			, p_bom_revision_tbl =>  g_bom_revision_tbl
			, p_bom_component_tbl => g_bom_component_tbl
			, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
			, p_bom_sub_component_tbl => g_bom_sub_component_tbl
			, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
			);
                END IF;
            END LOOP;  -- Op Resource Children of Op Seq Ends.


        ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
              p_op_idx = 0
        THEN
        --
        -- This situation will arise when Op Seq is
        -- not part of the business object input data.
        -- Match the operation key information at the entity index
        -- location with rest of the records, all those that are found
        -- will be siblings and should get an error.
        --

            FOR l_idx IN (p_entity_index+1)..g_op_resource_tbl.COUNT
            LOOP
                IF NVL(g_op_resource_tbl(l_idx).operation_sequence_number,
                       FND_API.G_MISS_NUM) =
                   NVL(g_op_resource_tbl(p_entity_index).operation_sequence_number,
                       FND_API.G_MISS_NUM)
                AND
                   NVL(g_op_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                   NVL(g_op_resource_tbl(p_entity_index).op_start_effective_date, SYSDATE)
                AND
                   NVL(g_op_resource_tbl(l_idx).operation_type,
                       FND_API.G_MISS_NUM) =
                   NVL(g_op_resource_tbl(p_entity_index).operation_type,
                       FND_API.G_MISS_NUM)
                THEN

                    g_op_resource_tbl(l_idx).return_status := p_other_status;
                    Error_Handler.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_RES_LEVEL
                     , p_entity_index   => l_idx
		     , p_row_identifier => g_op_resource_tbl(l_idx).row_identifier
                     , p_message_type   => 'E'
                     , p_mesg_name      => p_other_mesg_name
		, p_bom_header_rec =>  g_bom_header_rec
		, p_bom_revision_tbl =>  g_bom_revision_tbl
		, p_bom_component_tbl => g_bom_component_tbl
		, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
		, p_bom_sub_component_tbl => g_bom_sub_component_tbl
		, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
		);

                END IF;
            END LOOP;

        --
        -- Substitute Operation Resources will also be considered as siblings
        -- of operation resource, they should get an error when
        -- error level is operation resource with scope of Siblings
                --
            setSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             , p_res_idx            => p_entity_index
             , p_op_idx             => 0
             , p_entity_index       => 0
             , p_other_mesg_name    => p_other_mesg_name
            );
       END IF; -- If error scope Ends

    END setOperationResources ;


    /*****************************************************************
    * Procedure     : setOperationSequences (Unexposed)
    * Parameters IN : Other Message Text
    *                 Other status
    *                 Entity Index
    *                 Error Scope
    *                 Error Status
    *                 Revised Item Index
    * Parameters OUT: None
    * Purpose       : This procedure will set the revised components record
    *                 status to other status and for each errored record
    *                 it will log the other message indicating what caused
    *                 the other records to fail.
    ******************************************************************/
    /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.
       Passed this p_other_mesg_name to Add_message, setOperationResources procedure calls.*/
    PROCEDURE setOperationSequences
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_entity_index       IN  NUMBER
     , p_other_mesg_name    IN  VARCHAR2 := NULL
     )
    IS
        l_Idx       NUMBER;
    BEGIN

        IF p_error_scope = G_SCOPE_ALL
        THEN

            FOR l_idx IN 1..g_operation_tbl.COUNT
            LOOP
            g_operation_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  Error_Handler.Add_Message
                  ( p_mesg_text    => p_other_mesg_text
                  , p_entity_id    => G_OP_LEVEL
                  , p_entity_index => l_Idx
		  , p_row_identifier => g_operation_tbl(l_idx).row_identifier
                  , p_message_type => 'E'
                  , p_mesg_name    => p_other_mesg_name
		, p_bom_header_rec =>  g_bom_header_rec
		, p_bom_revision_tbl =>  g_bom_revision_tbl
		, p_bom_component_tbl => g_bom_component_tbl
		, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
		, p_bom_sub_component_tbl => g_bom_sub_component_tbl
		, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
		);
               END IF;

            END LOOP;

            --
            -- Set the operation resource and substitute
            -- operation resource record status too.
            --
            setOperationResources
                    (  p_other_status    => p_other_status
                     , p_error_scope     => p_error_scope
                     , p_other_mesg_text => p_other_mesg_text
                     , p_op_idx          => 0
                     , p_entity_index    => 0
                     , p_other_mesg_name    => p_other_mesg_name
                     );

        END IF; -- Error Scope Ends

    END setOperationSequences ;


    /*****************************************************************
    * Procedure : setOpNetworks (unexposed)
    * Parameters IN : Other Message Text
    *                 Other status
    *                 Entity Index
    * Parameters OUT: None
    * Purpose   : This procedure will set the Operation Network record
    *             status to other status and for each errored record
    *             it will log the other message indicating what caused
    *             the other records to fail.
    ******************************************************************/
    /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.
       Passed this p_other_mesg_name to Add_message procedure call.*/
    PROCEDURE setOpNetworks
    (  p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_other_mesg_name    IN  VARCHAR2 := NULL
    )
    IS
        l_CurrentIndex  NUMBER;
    BEGIN

        FOR l_CurrentIndex IN  1..g_op_network_tbl.COUNT
        LOOP
            g_op_network_tbl(l_CurrentIndex).return_status :=
                        p_other_status;
            IF p_other_mesg_text IS NOT NULL
            THEN
                Error_Handler.Add_Message
                (  p_mesg_text      => p_other_mesg_text
                 , p_entity_id      => G_NWK_LEVEL
                 , p_entity_index   => l_CurrentIndex
		 , p_row_identifier => g_op_network_tbl(l_CurrentIndex).row_identifier
                 , p_message_type   => 'E'
                 , p_mesg_name      => p_other_mesg_name
		, p_bom_header_rec =>  g_bom_header_rec
		, p_bom_revision_tbl =>  g_bom_revision_tbl
		, p_bom_component_tbl => g_bom_component_tbl
		, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
		, p_bom_sub_component_tbl => g_bom_sub_component_tbl
		, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
		);
            END IF;
        END LOOP;

    END setOpNetworks ;


    /*****************************************************************
    * Procedure : setRtgRevisions (unexposed)
    * Parameters IN : Other Message Text
    *                 Other status
    *                 Entity Index
    * Parameters OUT: None
    * Purpose   : This procedure will set the Routing Revisions record
    *             status to other status and for each errored record
    *             it will log the other message indicating what caused
    *             the other records to fail.
    ******************************************************************/
    /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.
       Passed this p_other_mesg_name to Add_message procedure call.*/
    PROCEDURE setRtgRevisions
    (  p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_other_mesg_name    IN  VARCHAR2 := NULL
    )
    IS
        l_CurrentIndex  NUMBER;
    BEGIN

        FOR l_CurrentIndex IN  1..g_rtg_revision_tbl.COUNT
        LOOP
            g_rtg_revision_tbl(l_CurrentIndex).return_status :=
                        p_other_status;
            IF p_other_mesg_text IS NOT NULL
            THEN

                Error_Handler.Add_Message
                (  p_mesg_text      => p_other_mesg_text
                 , p_entity_id      => G_REV_LEVEL
                 , p_entity_index   => l_CurrentIndex
		 , p_row_identifier => g_rtg_revision_tbl(l_CurrentIndex).row_identifier
                 , p_message_type   => 'E'
                 , p_mesg_name      => p_other_mesg_name
		, p_bom_header_rec =>  g_bom_header_rec
		, p_bom_revision_tbl =>  g_bom_revision_tbl
		, p_bom_component_tbl => g_bom_component_tbl
		, p_bom_ref_Designator_tbl => g_bom_ref_designator_tbl
		, p_bom_sub_component_tbl => g_bom_sub_component_tbl
		, p_bom_comp_ops_tbl => g_bom_comp_ops_tbl
		);
            END IF;
        END LOOP;

    END setRtgRevisions;



    /******************************************************************
    * Procedure : Log_Error
    * Parameters IN : Routing Header Record and Rest of the Entity Tables
    *                 Message Token Table
    *                 Other Message Table
    *                 Other Status
    *                 Entity Index
    *                 Error Level
    *                 Error Scope
    *                 Error Status
    * Parameters OUT:  Routing Header Record and Rest of the Entity Tables
    * Purpose   : Log Error will take the Message Token Table and
    *             seperate the message and their tokens, get the
    *             token substitute messages from the message dictionary
    *             and put in the error stack.
    *             Log Error will also make sure that the error
    *             propogates to the right level's of the business object
    *             and that the rest of the entities get the appropriate
    *             status and message.
    ******************************************************************/
     PROCEDURE Log_Error
     ( p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
     , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
     , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
     , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
     , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
     , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
     , p_Mesg_Token_tbl          IN  Error_Handler.Mesg_Token_Tbl_Type
     , p_error_status            IN  VARCHAR2
     , p_error_scope             IN  VARCHAR2
     , p_other_message           IN  VARCHAR2
     , p_other_mesg_appid        IN  VARCHAR2
     , p_other_status            IN  VARCHAR2
     , p_other_token_tbl         IN  Error_Handler.Token_Tbl_Type
     , p_error_level             IN  NUMBER
     , p_entity_index            IN  NUMBER
     , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
     , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
     , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
     , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
     , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
     , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
     )

    IS
        l_message_name      VARCHAR2(30);
        l_other_message     VARCHAR2(2000);
        l_message_text      VARCHAR2(2000);
        l_LoopIndex         NUMBER;
        l_Error_Level       NUMBER      := p_Error_Level;
        l_error_scope       VARCHAR2(1) := p_error_scope;
        l_error_status      VARCHAR2(1) := p_error_status;
        l_application_id    VARCHAR2(3);
        l_row_identifier    NUMBER;
    BEGIN
       g_rtg_header_rec         := p_rtg_header_rec ;
       g_rtg_revision_tbl       := p_rtg_revision_tbl ;
       g_operation_tbl          := p_operation_tbl ;
       g_op_resource_tbl        := p_op_resource_tbl ;
       g_sub_resource_tbl       := p_sub_resource_tbl ;
       g_op_network_tbl         := p_op_network_tbl ;

       l_application_id :=  p_other_mesg_appid;


        /*************************************************
        --
        -- Seperate message and their tokens, get the
        -- token substituted messages and put it in the
        -- Error Table.
        --
        **************************************************/


IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within the Rtg Log Error Procedure . . .'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope: ' || l_error_scope); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Index: ' || to_char(p_entity_index)); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level: ' || to_char(p_error_level)); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Status: ' || l_error_status); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Status: ' || p_other_status); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Message: ' || p_other_message); END IF;

      IF p_error_level = G_BO_LEVEL OR p_error_level = G_RTG_LEVEL THEN
         l_row_identifier := p_rtg_header_rec.row_identifier;
      ELSIF p_error_level = G_REV_LEVEL THEN
         l_row_identifier := p_rtg_revision_tbl(p_entity_index).row_identifier;
      ELSIF p_error_level = G_OP_LEVEL THEN
         l_row_identifier := p_operation_tbl(p_entity_index).row_identifier;
      ELSIF p_error_level = G_RES_LEVEL THEN
         l_row_identifier := p_op_resource_tbl(p_entity_index).row_identifier;
      ELSIF p_error_level = G_SR_LEVEL THEN
         l_row_identifier := p_sub_resource_tbl(p_entity_index).row_identifier;
      ELSIF  p_error_level = G_NWK_LEVEL THEN
         l_row_identifier := p_op_network_tbl(p_entity_index).row_identifier;
      END IF;
        Error_Handler.Translate_And_Insert_Messages
        (  p_mesg_token_Tbl => p_mesg_token_tbl
         , p_error_level    => p_error_level
         , p_entity_index   => p_entity_index
         , p_row_identifier => l_row_identifier
        );

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished logging messages . . . '); END IF;

        /**********************************************************
        --
        -- Get the other message text and token and retrieve the
        -- token substituted message.
        --
        ***********************************************************/

        IF p_other_token_tbl.COUNT <> 0
        THEN
            FND_MESSAGE.SET_NAME
            (  application  => l_application_id
             , name         => p_other_message
             );

            FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
            LOOP
                IF p_other_token_tbl(l_LoopIndex).token_name IS
                   NOT NULL
                THEN
                   FND_MESSAGE.SET_TOKEN
                   ( token  => p_other_token_tbl(l_LoopIndex).token_name
                    , value => p_other_token_tbl(l_LoopIndex).token_value
                    , translate   => p_other_token_tbl(l_LoopIndex).translate
                   );
                END IF;
            END LOOP;

            l_other_message := FND_MESSAGE.GET;

        ELSE
            FND_MESSAGE.SET_NAME
            (  application  => l_application_id
             , name         => p_other_message
             );

            l_other_message := FND_MESSAGE.GET;

        END IF; -- Other Token Tbl Count <> 0 Ends

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished extracting other message . . . '); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Message generated: ' || l_other_message); END IF;


        /**********************************************************
        --
        -- If the Error Level is Business Object
        -- then set the Error Level = RTG
        --
        ************************************************************/
        IF l_error_level = G_BO_LEVEL
        THEN
            l_error_level := G_RTG_LEVEL;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level is Business Object . . . '); END IF;

        END IF;
        /**********************************************************
        --
        -- If the error_status is UNEXPECTED then set the error scope
        -- to ALL, if WARNING then set the scope to RECORD.
        --
        ************************************************************/
        IF l_error_status = G_STATUS_UNEXPECTED
        THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Status unexpected and scope is All . . .'); END IF;

            l_error_scope := G_SCOPE_ALL;
        ELSIF l_error_status = G_STATUS_WARNING
        THEN
            l_error_scope := G_SCOPE_RECORD;
            l_error_status := FND_API.G_RET_STS_SUCCESS;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Status is warning . . .'); END IF;

        END IF;

        --
        -- If the Error Level is Routing Header, then the scope can be
        -- ALL/CHILDREN OR RECORD.
        --
        /*************************************************************
        --
        -- If the Error Level is Routing Header.
        --
        *************************************************************/
        IF l_error_level = G_RTG_LEVEL
        THEN
        /* Fix for bug 4661753 - added p_other_message to the calls to Add_message, setSubResources, setOperationResources,
	        setOperationSequences, setOpNetworks, setRtgRevisions procedures below.
 	        Note that p_other_message contains message_name (can be null) whereas l_other_message contains message_text.*/

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level is Routing Header . . .'); END IF;

            --
            -- Set the Routing Header record status to p_error_status
            -- This will also take care of the scope RECORD.
            --
            g_rtg_header_rec.return_status := l_error_status;

            IF p_other_message IS NOT NULL AND
               p_error_level IN (G_BO_LEVEL, G_RTG_LEVEL)
            THEN
                Error_Handler.Add_Message
                (  p_mesg_text      => l_other_message
                 , p_entity_id      => p_error_level
                 , p_entity_index   => p_entity_index
		 , p_row_identifier => g_rtg_header_rec.row_identifier
                 , p_message_type   => 'E'
                 , p_mesg_name      => p_other_message
                );
                l_other_message := NULL;
            END IF;


            IF l_error_scope = G_SCOPE_ALL OR
               l_error_scope = G_SCOPE_CHILDREN
            THEN
                --
                -- Set all the operation's
                -- status, this will then set the
                -- status of the operation resoources
                -- and substitute operation resoources

                --
                setOperationSequences
                (  p_other_mesg_text => l_other_message
                 , p_other_status    => p_other_status
                 , p_error_scope     => G_SCOPE_ALL
                 , p_entity_index    =>0
                 , p_other_mesg_name => p_other_message
                );

            END IF; -- Routing Header Scope =  ALL or Children Ends


        /********************************************
        --
        -- If the Error Level is Routing Revision
        --
        *********************************************/
        ELSIF l_error_level = G_REV_LEVEL
        THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level is Routing Revision. . .'); END IF;
            --
            -- Set the Routing Revision record at the current entity_index
            -- This will take care of scope = RECORD
            --
            g_rtg_revision_tbl(p_entity_index).return_status := l_error_status;


            IF l_error_scope = G_SCOPE_ALL
            THEN
               IF g_rtg_revision_tbl.COUNT <> 0
               THEN
                  --
                  -- Set all the revision record status
                  --
                  setRtgRevisions
                  (  p_other_mesg_text => l_other_message
                   , p_other_status    => p_other_status
                   , p_other_mesg_name => p_other_message
                  );

               END IF;

               --
               -- Set all the operation's
               -- status, this will then set the
               -- status of the operation resources
               -- and substitute operation resources
               --
               setOperationSequences
               (  p_other_mesg_text => l_other_message
                , p_other_status    => p_other_status
                , p_error_scope     => l_error_scope
                , p_entity_index    => 0
                , p_other_mesg_name => p_other_message
               ) ;

            END IF;


        /********************************************
        --
        -- If the Error Level is Operation Networks
        --
        *********************************************/
        ELSIF l_error_level = G_NWK_LEVEL
        THEN
            --
            -- Set the Operatin Network record at the current entity_index
            -- This will take care of scope = RECORD
            --
            g_op_network_tbl(p_entity_index).return_status := l_error_status;

            IF l_error_scope = G_SCOPE_ALL
            THEN
               IF g_op_network_tbl.COUNT <> 0
               THEN
                  --
                  -- Set all the revision record status
                  --
		  setOpNetworks
                  (  p_other_mesg_text => l_other_message
                   , p_other_status    => p_other_status
                   , p_other_mesg_name => p_other_message
                  );
               END IF;

               --
               -- Set all the operation's
               -- status, this will then set the
               -- status of the operation resources
               -- and substitute operation resources
               --
               setOperationSequences
               (  p_other_mesg_text => l_other_message
                , p_other_status    => p_other_status
                , p_error_scope     => l_error_scope
                , p_entity_index    => 0
                , p_other_mesg_name => p_other_message
               ) ;

            END IF;

        /********************************************
        --
        -- If the Error Level is Operation Sequences
        --
        *********************************************/
        ELSIF l_error_level = G_OP_LEVEL
        THEN

            --
            -- Set operation sequence record at the entity_index
            -- to error_status
            -- This will take care of Scope = RECORD.
            --
            g_operation_tbl(p_entity_index).return_status := l_error_status;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Operation Sequences . . .'); END IF;

            IF l_error_scope = G_SCOPE_SIBLINGS OR
               l_error_scope = G_SCOPE_ALL
            THEN
                 setOperationSequences
                 (  p_other_mesg_text => l_other_message
                  , p_other_status    => p_other_status
                  , p_error_scope     => G_SCOPE_ALL
                  , p_entity_index    => p_entity_index
                  , p_other_mesg_name => p_other_message
                 ) ;
            ELSIF l_error_scope = G_SCOPE_CHILDREN
            THEN
                IF g_op_resource_tbl.COUNT <> 0
                THEN
                    setOperationResources
                    (  p_error_scope     => l_error_scope
                     , p_other_status    => p_other_status
                     , p_other_mesg_text => l_other_message
                     , p_op_idx          => p_entity_index
                     , p_entity_index    => 0
                     , p_other_mesg_name => p_other_message
                     );
                END IF;

                IF g_sub_resource_tbl.COUNT <> 0
                THEN
                    setSubResources
                    (  p_error_scope     => l_error_scope
                     , p_other_status    => p_other_status
                     , p_other_mesg_text => l_other_message
                     , p_op_idx          => p_entity_index
                     , p_res_idx            => 0
                     , p_entity_index       => 0
                     , p_other_mesg_name    => p_other_message
                    );
                END IF;
            END IF; -- scope = Siblings or All Ends

        /***********************************************
        --
        -- If the Error Level is Operation Resources
        --
        ************************************************/
        ELSIF l_error_level = G_RES_LEVEL
        THEN
            --
            -- Set operation resource record status at entity_idx
            -- This will take care of Scope = RECORD.
            --
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Operation Resource . . .'); END IF;

            g_op_resource_tbl(p_entity_index).return_status := l_error_status;
            IF l_error_scope <> G_SCOPE_RECORD
            THEN
                setOperationResources
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                 , p_op_idx          => 0
                 , p_other_mesg_name => p_other_message
                ) ;
            END IF;
        /***********************************************
        --
        -- If the Error Level is Sub Op Resources
        --
        ************************************************/
        ELSIF l_error_level = G_SR_LEVEL
        THEN
             -- Set substitute resource record status at entity_idx
             -- This will take care of Scope = RECORD.
             --
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Substitute Op Resources . . .'); END IF;

             g_sub_resource_tbl(p_entity_index).return_status := l_error_status;

             IF l_error_scope <> G_SCOPE_RECORD
             THEN
                setSubResources
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                 , p_op_idx             => 0
                 , p_res_idx            => 0
                 , p_other_mesg_name    => p_other_message
                ) ;
             END IF ;

        END IF; -- Error Level  If Ends.

        --
        -- Copy the changed record/Tables to the out parameters for
        -- returing to the calling program.
        --
        x_rtg_header_rec         := g_rtg_header_rec ;
        x_rtg_revision_tbl       := g_rtg_revision_tbl ;
        x_operation_tbl          := g_operation_tbl ;
        x_op_resource_tbl        := g_op_resource_tbl ;
        x_sub_resource_tbl       := g_sub_resource_tbl ;
        x_op_network_tbl         := g_op_network_tbl ;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('End of Rtg Log Error.'); END IF;


    END Log_Error;

END Bom_Rtg_Error_Handler;

/
