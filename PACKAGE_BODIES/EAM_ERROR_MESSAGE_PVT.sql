--------------------------------------------------------
--  DDL for Package Body EAM_ERROR_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ERROR_MESSAGE_PVT" AS
/* $Header: EAMVWOEB.pls 120.3 2006/08/10 05:43:10 amourya noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOEB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_ERROR_MESSAGE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_PROCESS_WO_PVT';

        g_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        g_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        g_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        g_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        g_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        g_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        g_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        g_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        g_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

	g_eam_wo_comp_rec            EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type;
	g_eam_wo_quality_tbl         EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
	g_eam_meter_reading_tbl      EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
        g_eam_counter_prop_tbl       EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

	g_eam_wo_comp_rebuild_tbl    EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
	g_eam_wo_comp_mr_read_tbl    EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
	g_eam_op_comp_tbl            EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
	g_eam_request_tbl            EAM_PROCESS_WO_PUB.eam_request_tbl_type;


        G_ERROR_TABLE           EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type;
        G_Msg_Index             NUMBER := 0;
        G_Msg_Count             NUMBER := 0;

        G_BO_IDENTIFIER         VARCHAR2(3) := 'EAM';



    /******************************************************************
    * Procedure : setMaterialRequirements
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
    PROCEDURE setMaterialRequirements
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
        l_idx   NUMBER;
    BEGIN

        IF p_error_scope = G_SCOPE_ALL
        THEN
           FOR l_idx IN (p_entity_index+1)..g_eam_mat_req_tbl.COUNT
           LOOP
               g_eam_mat_req_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  EAM_ERROR_MESSAGE_PVT.Add_Message
                  ( p_mesg_text     => p_other_mesg_text
                  , p_entity_id     => G_MAT_REQ_LEVEL
                  , p_entity_index  => l_idx
                  , p_message_type  => 'E');
               END IF;
            END LOOP;


        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_op_idx <> 0
        THEN

            FOR l_idx IN 1..g_eam_mat_req_tbl.COUNT
            LOOP
                IF NVL(g_eam_mat_req_tbl(l_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM) =
                   NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM)
                THEN

                    g_eam_mat_req_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_MAT_REQ_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');
                END IF;
            END LOOP;  -- MR Children of Op Seq Ends.


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

            FOR l_idx IN (p_entity_index+1)..g_eam_mat_req_tbl.COUNT
            LOOP
                IF NVL(g_eam_mat_req_tbl(l_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM) =
                   NVL(g_eam_mat_req_tbl(p_entity_index).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM)
                THEN

                    g_eam_mat_req_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_MAT_REQ_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');

                END IF;
            END LOOP;

       END IF; -- If error scope Ends

    END setMaterialRequirements ;


    /******************************************************************
    * Procedure : setDirectItems
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

    PROCEDURE setDirectItems
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
        l_idx   NUMBER;
    BEGIN

        IF p_error_scope = G_SCOPE_ALL
        THEN
           FOR l_idx IN (p_entity_index+1)..g_eam_direct_items_tbl.COUNT
           LOOP
               g_eam_direct_items_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  EAM_ERROR_MESSAGE_PVT.Add_Message
                  ( p_mesg_text     => p_other_mesg_text
                  , p_entity_id     => G_DIRECT_ITEMS_LEVEL
                  , p_entity_index  => l_idx
                  , p_message_type  => 'E');
               END IF;
            END LOOP;


        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_op_idx <> 0
        THEN

            FOR l_idx IN 1..g_eam_direct_items_tbl.COUNT
            LOOP
                IF NVL(g_eam_direct_items_tbl(l_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM) =
                   NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM)
                THEN

                    g_eam_direct_items_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_DIRECT_ITEMS_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');
                END IF;
            END LOOP;  -- DI Children of Op Seq Ends.


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

            FOR l_idx IN (p_entity_index+1)..g_eam_direct_items_tbl.COUNT
            LOOP
                IF NVL(g_eam_direct_items_tbl(l_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM) =
                   NVL(g_eam_direct_items_tbl(p_entity_index).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM)
                THEN

                    g_eam_direct_items_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_DIRECT_ITEMS_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');

                END IF;
            END LOOP;

       END IF; -- If error scope Ends

    END setDirectItems;



    /******************************************************************
    * Procedure     : setSubResources
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
    PROCEDURE setSubResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_res_idx            IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
                l_idx   NUMBER;
    BEGIN

         IF p_error_scope = G_SCOPE_ALL
         THEN
             FOR l_idx IN 1..g_eam_sub_res_tbl.COUNT
             LOOP
                 g_eam_sub_res_tbl(l_idx).return_status := p_other_status;

                 IF p_other_mesg_text IS NOT NULL
                 THEN
                       EAM_ERROR_MESSAGE_PVT.Add_Message
                       (  p_mesg_text   => p_other_mesg_text
                        , p_entity_id   => G_SUB_RES_LEVEL
                        , p_entity_index=> l_idx
                        , p_message_type=> 'E');
                 END IF;
             END LOOP;

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_op_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_sub_res_tbl.COUNT
                LOOP
                   IF NVL(g_eam_sub_res_tbl(l_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM) =
                      NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM)

                   THEN
                        g_eam_sub_res_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SUB_RES_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;

                END LOOP;  -- Sub Res Children of Op Seq Ends.

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND p_res_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_sub_res_tbl.COUNT
                LOOP
                    IF NVL(g_eam_sub_res_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_res_tbl(p_res_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_sub_res_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SUB_RES_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
               p_op_idx  = 0 AND
               p_res_idx = 0
         THEN

                FOR l_idx IN 1..g_eam_sub_res_tbl.COUNT
                LOOP
                    IF NVL(g_eam_sub_res_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_sub_res_tbl(p_entity_index).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_sub_res_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SUB_RES_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;


         END IF; -- If Scope = Ends.

    END setSubResources;










    /******************************************************************
    * Procedure     : setResInstances
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
    PROCEDURE setResInstances
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_res_idx            IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
                l_idx   NUMBER;
    BEGIN

         IF p_error_scope = G_SCOPE_ALL
         THEN
             FOR l_idx IN 1..g_eam_res_inst_tbl.COUNT
             LOOP
                 g_eam_res_inst_tbl(l_idx).return_status := p_other_status;

                 IF p_other_mesg_text IS NOT NULL
                 THEN
                       EAM_ERROR_MESSAGE_PVT.Add_Message
                       (  p_mesg_text   => p_other_mesg_text
                        , p_entity_id   => G_RES_INST_LEVEL
                        , p_entity_index=> l_idx
                        , p_message_type=> 'E');
                 END IF;
             END LOOP;

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_op_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_res_inst_tbl.COUNT
                LOOP
                   IF NVL(g_eam_res_inst_tbl(l_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM) =
                      NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM)

                   THEN
                        g_eam_res_inst_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_INST_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;

                END LOOP;  -- Sub Res Children of Op Seq Ends.

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND p_res_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_res_inst_tbl.COUNT
                LOOP
                    IF NVL(g_eam_res_inst_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_res_tbl(p_res_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_res_inst_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_INST_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
               p_op_idx  = 0 AND
               p_res_idx = 0
         THEN

                FOR l_idx IN 1..g_eam_res_inst_tbl.COUNT
                LOOP
                    IF NVL(g_eam_res_inst_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_res_inst_tbl(p_entity_index).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_res_inst_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_INST_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;


         END IF; -- If Scope = Ends.

    END setResInstances;










    /******************************************************************
    * Procedure     : setResUsages
    * Parameters    : Other Message
    *                 Other Status
    *                 Error Scope
    *                 Entity Index
    *                 Resource Usage Index
    * Purpose       : This procedure will set the reference designator
    *                 record status to other status by looking at the
    *                 revised item key or the revised component key or
    *                 else setting all the record status to other status
    ********************************************************************/
    PROCEDURE setResUsages
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_res_idx            IN  NUMBER := 0
     , p_res_usage_idx      IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
                l_idx   NUMBER;
    BEGIN

         IF p_error_scope = G_SCOPE_ALL
         THEN
             FOR l_idx IN 1..g_eam_res_usage_tbl.COUNT
             LOOP
                 g_eam_res_usage_tbl(l_idx).return_status := p_other_status;

                 IF p_other_mesg_text IS NOT NULL
                 THEN
                       EAM_ERROR_MESSAGE_PVT.Add_Message
                       (  p_mesg_text   => p_other_mesg_text
                        , p_entity_id   => G_RES_USAGE_LEVEL
                        , p_entity_index=> l_idx
                        , p_message_type=> 'E');
                 END IF;
             END LOOP;

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_op_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_res_usage_tbl.COUNT
                LOOP
                   IF NVL(g_eam_res_usage_tbl(l_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM) =
                      NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM, FND_API.G_MISS_NUM)

                   THEN
                        g_eam_res_usage_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_USAGE_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;

                END LOOP;  -- Res usage Children of Op Seq Ends.

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND p_res_idx <> 0
         THEN

                FOR l_idx IN 1..g_eam_res_usage_tbl.COUNT
                LOOP
                    IF NVL(g_eam_res_usage_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_res_tbl(p_res_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_res_usage_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_USAGE_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
               p_op_idx  = 0 AND
               p_res_idx = 0
         THEN

                FOR l_idx IN 1..g_eam_res_usage_tbl.COUNT
                LOOP
                    IF NVL(g_eam_res_usage_tbl(l_idx).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM) =
                       NVL(g_eam_res_usage_tbl(p_entity_index).OPERATION_SEQ_NUM,
                           FND_API.G_MISS_NUM)

                    THEN
                        g_eam_res_usage_tbl(l_idx).return_status := p_other_status;
                        EAM_ERROR_MESSAGE_PVT.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RES_USAGE_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E');
                    END IF;
                END LOOP;


         END IF; -- If Scope = Ends.

    END setResUsages;






    /******************************************************************
    * Procedure : setOperationResources
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

    PROCEDURE setOperationResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_op_idx             IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
    )
    IS
        l_idx   NUMBER;
    BEGIN

        IF p_error_scope = G_SCOPE_ALL
        THEN
           FOR l_idx IN (p_entity_index+1)..g_eam_res_tbl.COUNT
           LOOP
               g_eam_res_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  EAM_ERROR_MESSAGE_PVT.Add_Message
                  ( p_mesg_text     => p_other_mesg_text
                  , p_entity_id     => G_RES_LEVEL
                  , p_entity_index  => l_idx
                  , p_message_type  => 'E');
               END IF;
            END LOOP;

            --
            -- Set the Substitute Operation Resources Record Status too
            --
            setSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             );


        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_op_idx <> 0
        THEN


            FOR l_idx IN 1..g_eam_res_tbl.COUNT
            LOOP

                IF NVL(g_eam_res_tbl(l_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM) =
                   NVL(g_eam_op_tbl(p_op_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM)
                THEN

                    g_eam_res_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_RES_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');
                END IF;
            END LOOP;  -- Op Resource Children of Op Seq Ends.

        ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
              p_op_idx = 0
        THEN

        -- This situation will arise when Op Seq is
        -- not part of the business object input data.
        -- Match the operation key information at the entity index
        -- location with rest of the records, all those that are found
        -- will be siblings and should get an error.

            FOR l_idx IN (p_entity_index+1)..g_eam_res_tbl.COUNT
            LOOP
                IF NVL(g_eam_res_tbl(l_idx).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM) =
                   NVL(g_eam_res_tbl(p_entity_index).OPERATION_SEQ_NUM,
                       FND_API.G_MISS_NUM)
                THEN

                    g_eam_res_tbl(l_idx).return_status := p_other_status;
                    EAM_ERROR_MESSAGE_PVT.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_RES_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E');

                END IF;
            END LOOP;

        --
        -- Substitute Operation Resources will also be considered as siblings
        -- of operation resource, they should get an error when
        -- error level is operation resource with scope of Siblings

            setSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             , p_res_idx            => p_entity_index
            );

       END IF; -- If error scope Ends

    END setOperationResources ;


    /*****************************************************************
    * Procedure     : setOperationSequences
    * Parameters IN : Other Message Text
    *                 Other status
    *                 Entity Index
    *                 Error Scope
    *                 Error Status
    *                 Revised Item Index
    * Parameters OUT NOCOPY: None
    * Purpose       : This procedure will set the revised components record
    *                 status to other status and for each errored record
    *                 it will log the other message indicating what caused
    *                 the other records to fail.
    ******************************************************************/
    PROCEDURE setOperationSequences
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_entity_index       IN  NUMBER := 0
     )
    IS
        l_Idx       NUMBER;
    BEGIN


        IF p_error_scope = G_SCOPE_ALL
        THEN

            FOR l_idx IN 1..g_eam_op_tbl.COUNT
            LOOP
            g_eam_op_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  EAM_ERROR_MESSAGE_PVT.Add_Message
                  ( p_mesg_text    => p_other_mesg_text
                  , p_entity_id    => G_OP_LEVEL
                  , p_entity_index => l_Idx
                  , p_message_type => 'E');
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
                     );

        END IF; -- Error Scope Ends

    END setOperationSequences ;


    /*****************************************************************
    * Procedure : setOpNetworks
    * Parameters IN : Other Message Text
    *                 Other status
    *                 Entity Index
    * Parameters OUT NOCOPY: None
    * Purpose   : This procedure will set the Operation Network record
    *             status to other status and for each errored record
    *             it will log the other message indicating what caused
    *             the other records to fail.
    ******************************************************************/
    PROCEDURE setOpNetworks
    (  p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
    )
    IS
        l_CurrentIndex  NUMBER;
    BEGIN

        FOR l_CurrentIndex IN  1..g_eam_op_network_tbl.COUNT
        LOOP
            g_eam_op_network_tbl(l_CurrentIndex).return_status :=
                        p_other_status;
            IF p_other_mesg_text IS NOT NULL
            THEN
                EAM_ERROR_MESSAGE_PVT.Add_Message
                (  p_mesg_text      => p_other_mesg_text
                 , p_entity_id      => G_OP_NETWORK_LEVEL
                 , p_entity_index   => l_CurrentIndex
                 , p_message_type   => 'E');
            END IF;
        END LOOP;

    END setOpNetworks ;




        /****************************************************************
        * Procedure     : Add_Message
        * Paramaters IN : Message Text
        *                 Entity ID
        *                 Entity Index
        * Parameters OUT NOCOPY: None
        * Purpose       : Add_Message will push a message on the message
        *                 stack and will convert the numeric entity id to
        *                 character which will be easier for the user to
        *                 understand. eg. Entity Id = 1 which will be ECO
        *****************************************************************/
        PROCEDURE Add_Message
        (  p_mesg_text          IN  VARCHAR2
         , p_entity_id          IN  NUMBER
         , p_entity_index       IN  NUMBER
         , p_message_type       IN  VARCHAR2)
        IS
                l_Idx                   BINARY_INTEGER;
                l_entity_id_char        VARCHAR2(3);

        BEGIN

                l_Idx := G_ERROR_TABLE.COUNT;

                IF p_entity_id = G_WO_LEVEL
                THEN
                        l_entity_id_char := 'WO';
                ELSIF p_entity_id = G_OP_LEVEL
                THEN
                        l_entity_id_char := 'OP';
                ELSIF p_entity_id = G_OP_NETWORK_LEVEL
                THEN
                        l_entity_id_char := 'ON';
                ELSIF p_entity_id = G_RES_LEVEL
                THEN
                        l_entity_id_char := 'RS';
                ELSIF p_entity_id = G_RES_INST_LEVEL
                THEN
                        l_entity_id_char := 'RI';
                ELSIF p_entity_id = G_SUB_RES_LEVEL
                THEN
                        l_entity_id_char := 'SR';
                ELSIF p_entity_id = G_RES_USAGE_LEVEL
                THEN
                        l_entity_id_char := 'RU';
                ELSIF p_entity_id = G_MAT_REQ_LEVEL
                THEN
                        l_entity_id_char := 'MR';
                END IF;



                G_ERROR_TABLE(l_Idx + 1).message_text := p_mesg_text;
                G_ERROR_TABLE(l_idx + 1).entity_id    := l_entity_id_char;
                G_ERROR_TABLE(l_idx + 1).entity_index := p_entity_index;
                G_ERROR_TABLE(l_idx + 1).message_type := p_message_type;
                G_ERROR_TABLE(l_Idx + 1).bo_identifier:= EAM_ERROR_MESSAGE_PVT.Get_BO_Identifier;

                -- Increment the message counter to keep a tally.

                G_Msg_Count := G_Error_Table.Count;


        END Add_Message;



        /**********************************************************************
        * Procedure     : Add_Error_Token
        * Parameters IN : Message Text (in case of unexpected errors)
        *                 Message Name
        *                 Mesg Token Tbl
        *                 Token Table
        * Parameters OUT: Mesg Token Table
        * Purpose       : This procedure will create a list messages and their
        *                 tokens. When the user passes in a message wtih a
        *                 bunch of token, this procedure will do ahead and
        *                 that message in to the mesg_token_tbl with all those
        *                 token, so that that the log error procedure can
        *                 then seperate the message and its token for generating
        *                 a token substituted and translated message.
        **********************************************************************/

        PROCEDURE Add_Error_Token
        (  p_message_name      IN  VARCHAR2 := NULL
         , p_application_id    IN  VARCHAR2 := 'EAM'
         , p_message_text      IN  VARCHAR2 := NULL
         , x_Mesg_Token_tbl    OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , p_Mesg_Token_Tbl    IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type :=
                                   EAM_ERROR_MESSAGE_PVT.G_MISS_MESG_TOKEN_TBL
         , p_token_tbl         IN  EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type :=
                                   EAM_ERROR_MESSAGE_PVT.G_MISS_TOKEN_TBL
         , p_message_type      IN  VARCHAR2 := 'E'
         )
        IS
                l_Index         NUMBER;
                l_TableCount    NUMBER;
                l_Mesg_Token_Tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type ;
        BEGIN
                ----------------------------------------------------------------
                -- This procedure can be called from the individual entity
                -- validation  procedures to fill up the err_token_tbl that will
                -- be passed to the
                -- Log_Error procedure to create a token substituted and
                -- translated list of messages.
                ----------------------------------------------------------------

                l_Mesg_Token_Tbl := p_Mesg_Token_Tbl;
                l_Index := 0;
                l_TableCount := l_Mesg_token_tbl.COUNT;

              IF p_message_name IS NOT NULL THEN

                IF p_token_tbl.COUNT = 0 AND
                        p_message_name IS NOT NULL
                THEN
                        l_Mesg_token_tbl(l_TableCount + 1).message_name :=
                                        p_message_name;
                        l_Mesg_token_Tbl(l_TableCount + 1).message_type
                                := p_message_type;
                        l_Mesg_token_tbl(l_TableCount + 1).Application_id
                                := SUBSTR(p_message_name, 1, 3);


                ELSIF p_token_tbl.COUNT <> 0 AND
                        p_message_name IS NOT NULL
                THEN
                        FOR l_Index IN 1..p_token_tbl.COUNT LOOP
                                l_TableCount := l_TableCount + 1;
                                l_Mesg_token_tbl(l_TableCount).message_name :=
                                        p_message_name;
                                l_Mesg_token_tbl(l_TableCount).token_name :=
                                        p_token_tbl(l_Index).token_name;
                                l_Mesg_token_tbl(l_TableCount).token_value
                                        := p_token_tbl(l_Index).token_value;
                                l_Mesg_token_tbl(l_TableCount).translate
                                        := p_token_tbl(l_Index).translate;
                                l_Mesg_token_Tbl(l_TableCount).message_type
                                        := p_message_type;
                               l_Mesg_token_tbl(l_TableCount).Application_id
                                := SUBSTR(p_message_name, 1, 3);


                        END LOOP;
		END IF;
                ELSIF p_message_name IS NULL AND
                      p_message_text IS NOT NULL THEN
                        l_Mesg_token_tbl(l_TableCount + 1).message_text :=
                                p_message_text;
                        l_Mesg_token_Tbl(l_TableCount + 1).message_type
                                := p_message_type;
                END IF;



                x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

        END Add_Error_Token;


        /*********************************************************************
        * Procedure     : Translate_And_Insert_Messages
        * Returns       : None
        * Parameters IN : Message Token Table
        * Parameters OUT NOCOPY: None
        * Purpose       : This procedure will parse through the message token
        *                 table and seperate tokens for a message, get the
        *                 translated message, substitute the tokens and insert
        *                 the message in the message table.
        **********************************************************************/
        PROCEDURE Translate_And_Insert_Messages
        (  p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , p_error_level        IN  NUMBER
         , p_entity_index       IN  NUMBER
         , p_application_id     IN  VARCHAR2 := 'EAM'
         )
        IS
                l_message_text  VARCHAR2(2000);
                l_message_name  VARCHAR2(30);
        BEGIN
                l_message_name := NULL;
                FOR l_LoopIndex IN 1..p_mesg_token_tbl.COUNT
                LOOP
                      IF NVL(l_message_name, ' ') <> p_mesg_token_tbl(l_LoopIndex).message_name
                        THEN

			       fnd_message.set_name
                                (  application  => p_mesg_token_tbl(l_LoopIndex).application_id
                                 , name         => p_mesg_token_tbl(l_LoopIndex).message_name
                                 );

				-- add token/tokens to message
                                IF p_mesg_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   (  token     => p_mesg_token_tbl(l_LoopIndex).token_name
                                    , value     => p_mesg_token_tbl(l_LoopIndex).token_value
                                    );
                                END IF; -- Check on token

				l_message_name := p_mesg_token_tbl(l_LoopIndex).message_name;

				-- insert a message when last message or message changes in p_mesg_token_tbl
                                IF l_loopIndex=p_mesg_token_tbl.COUNT OR (l_loopIndex<>p_mesg_token_tbl.COUNT AND l_message_name<>p_mesg_token_tbl(l_loopIndex+1).message_name)
				THEN
					fnd_msg_pub.add;
				END IF; -- Check for last message/ new message

			-- Check for first message/ new message ends

			-- add multiple tokens in a message
                        ELSIF l_message_name = p_mesg_token_tbl(l_LoopIndex).message_name
                        THEN
			       -- add a token to message
                               IF p_mesg_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   (  token     => p_mesg_token_tbl(l_LoopIndex).token_name
                                    , value     => p_mesg_token_tbl(l_LoopIndex).token_value
                                   );
                                END IF ; -- Check on token

				--insert a message when last message or message changes in p_mesg_token_tbl
				IF l_loopIndex=p_mesg_token_tbl.COUNT OR (l_loopIndex<>p_mesg_token_tbl.COUNT AND l_message_name<>p_mesg_token_tbl(l_loopIndex+1).message_name)
				THEN
					fnd_msg_pub.add;
				END IF;	-- Check for last message/ new message

                                l_message_name := p_mesg_token_tbl(l_LoopIndex).message_name;

                        END IF;

                END LOOP;
                -- Mesg Token Tbl Loop Ends.
		-- loop inserts message/messages with a single or multiple token for display on UI

		l_message_name := NULL;

		FOR l_LoopIndex IN 1..p_mesg_token_tbl.COUNT
                LOOP
                       IF NVL(l_message_name, ' ') <> p_mesg_token_tbl(l_LoopIndex).message_name
                        THEN
                               fnd_message.set_name
                                (  application  => p_mesg_token_tbl(l_LoopIndex).application_id
                                 , name         => p_mesg_token_tbl(l_LoopIndex).message_name
                                 );

				-- add token/tokens to message
                                IF p_mesg_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   (  token     => p_mesg_token_tbl(l_LoopIndex).token_name
                                    , value     => p_mesg_token_tbl(l_LoopIndex).token_value
                                    , translate => p_mesg_token_tbl(l_LoopIndex).translate
                                    );
                                END IF; -- Check on token

				l_message_name := p_mesg_token_tbl(l_LoopIndex).message_name;

				-- add a message when last message or message changes in p_mesg_token_tbl
                                IF l_loopIndex=p_mesg_token_tbl.COUNT OR (l_loopIndex<>p_mesg_token_tbl.COUNT AND l_message_name<>p_mesg_token_tbl(l_loopIndex+1).message_name)
				THEN
					l_message_text := fnd_message.get;
					IF (l_message_text IS NOT NULL OR l_message_text <> ' ' OR l_message_text <> '' )
					THEN
					Add_Message
					   (  p_mesg_text          => l_message_text
					    , p_entity_id          => p_error_level
					    , p_entity_index       => p_entity_index
					    , p_message_type       => p_mesg_token_tbl(l_LoopIndex).message_type);
					END IF; -- check for Message Text
				END IF; -- check for last message/ new message

                       ELSIF l_message_name = p_mesg_token_tbl(l_LoopIndex).message_name
                        THEN
			       -- add token/tokens to message
                               IF p_mesg_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   (  token     => p_mesg_token_tbl(l_LoopIndex).token_name
                                    , value     => p_mesg_token_tbl(l_LoopIndex).token_value
                                    , translate => p_mesg_token_tbl(l_LoopIndex).translate
                                   );
                                END IF ; -- Check on token

				-- add a message when last message or message changes in p_mesg_token_tbl
                                IF l_loopIndex=p_mesg_token_tbl.COUNT OR (l_loopIndex<>p_mesg_token_tbl.COUNT AND l_message_name<>p_mesg_token_tbl(l_loopIndex+1).message_name)
				THEN
					l_message_text := fnd_message.get;
					IF (l_message_text IS NOT NULL OR l_message_text <> ' ' OR l_message_text <> '' )
					THEN
					Add_Message
					   (  p_mesg_text          => l_message_text
					    , p_entity_id          => p_error_level
					    , p_entity_index       => p_entity_index
					    , p_message_type       => p_mesg_token_tbl(l_LoopIndex).message_type);
					END IF; -- check for Message Text ends
				END IF;  -- check for last message/ new message

                                l_message_name := p_mesg_token_tbl(l_LoopIndex).message_name;

                        END IF;

			-- Add the unexpected error message which may not have a message name
                        IF p_mesg_token_tbl(l_LoopIndex).message_name IS NULL AND p_mesg_token_tbl(l_LoopIndex).message_text IS NOT NULL
                        THEN
                                Add_Message
                                (  p_mesg_text    => p_mesg_token_tbl(l_LoopIndex).message_text
                                 , p_entity_id    => p_error_level
                                 , p_entity_index => p_entity_index
                                 , p_message_type => p_mesg_token_tbl(l_LoopIndex).message_type
                                 );
                        END IF;

                END LOOP;
		-- Mesg Token Tbl Loop for log ends
		-- This adds message/messages with a single or multiple tokenc to log
        END Translate_And_Insert_Messages;


        /******************************************************************
        * Procedure     : Log_Error
        * Parameters IN : Work Order Record and Rest of the Entity Tables
        *                 Message Token Table
        *                 Other Message Table
        *                 Other Status
        *                 Entity Index
        *                 Error Level
        *                 Error Scope
        *                 Error Status
        * Parameters OUT NOCOPY:  Work Order Record and Rest of the Entity Tables
        * Purpose       : Log Error will take the Message Token Table and
        *                 seperate the message and their tokens, get the
        *                 token substitute messages from the message dictionary
        *                 and put in the error stack.
        *                 Log Error will also make sure that the error
        *                 propogates to the right level's of the business object
        *                 and that the rest of the entities get the appropriate
        *                 status and message.
        ******************************************************************/

        PROCEDURE Log_Error
        (  p_eam_wo_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_rec_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_REC
         , p_eam_op_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_TBL
         , p_eam_op_network_tbl IN  EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_NETWORK_TBL
         , p_eam_res_tbl        IN  EAM_PROCESS_WO_PUB.eam_res_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_TBL
         , p_eam_res_inst_tbl   IN  EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_INST_TBL
         , p_eam_sub_res_tbl    IN  EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_SUB_RES_TBL
         , p_eam_res_usage_tbl  IN  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_RES_USAGE_TBL
         , p_eam_mat_req_tbl    IN  EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_MAT_REQ_TBL
         , p_eam_direct_items_tbl    IN  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
                                :=EAM_PROCESS_WO_PUB.G_MISS_EAM_DIRECT_ITEMS_TBL
         , x_eam_wo_rec         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_rec_type
         , x_eam_op_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_tbl_type
         , x_eam_op_network_tbl OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_network_tbl_type
         , x_eam_res_tbl        OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_tbl_type
         , x_eam_res_inst_tbl   OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type
         , x_eam_sub_res_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type
         , x_eam_res_usage_tbl  OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type
         , x_eam_mat_req_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type
         , x_eam_direct_items_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type
         , p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , p_error_status       IN  VARCHAR2
         , p_error_scope        IN  VARCHAR2 := NULL
         , p_other_message      IN  VARCHAR2 := NULL
         , p_other_mesg_appid   IN  VARCHAR2 := 'EAM'
         , p_other_status       IN  VARCHAR2 := NULL
         , p_other_token_tbl    IN  EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type
                                    := EAM_ERROR_MESSAGE_PVT.G_MISS_TOKEN_TBL
         , p_error_level        IN   NUMBER
         , p_entity_index       IN   NUMBER := 1  -- := NULL
         )
        IS
                l_message_name          VARCHAR2(30);
                l_other_message         VARCHAR2(2000);
                l_message_text          VARCHAR2(2000);
                l_LoopIndex             NUMBER;
                l_Error_Level           NUMBER      := p_Error_Level;
                l_error_scope           VARCHAR2(1) := p_error_scope;
                l_error_status          VARCHAR2(1) := p_error_status;
                l_application_id        VARCHAR2(3);

        BEGIN

                g_eam_wo_rec            := p_eam_wo_rec;
                g_eam_op_tbl            := p_eam_op_tbl;
                g_eam_op_network_tbl    := p_eam_op_network_tbl;
                g_eam_res_tbl           := p_eam_res_tbl;
                g_eam_res_inst_tbl      := p_eam_res_inst_tbl;
                g_eam_sub_res_tbl       := p_eam_sub_res_tbl;
                g_eam_res_usage_tbl     := p_eam_res_usage_tbl;
                g_eam_mat_req_tbl       := p_eam_mat_req_tbl;
                g_eam_direct_items_tbl  := p_eam_direct_items_tbl;

                l_application_id :=  p_other_mesg_appid;

                --
                -- Seperate message and their tokens, get the
                -- token substituted messages and put it in the
                -- Error Table.
          --

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within the Log Error Procedure . . .'); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Scope: ' || l_error_scope); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entity Index: ' || to_char(p_entity_index)); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Level: ' || to_char(p_error_level)); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Status: ' || l_error_status); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Status: ' || p_other_status); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Message: ' || p_other_message); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Business Object: ' || Get_BO_Identifier); END IF;

                EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => p_mesg_token_tbl
                 , p_error_level        => p_error_level
                 , p_entity_index       => p_entity_index
                );
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished logging messages . . . '); END IF;

                --
                -- Get the other message text and token and retrieve the
                -- token substituted message.
              IF p_other_message is not null THEN

                IF p_other_token_tbl.COUNT <> 0
                THEN
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
                        LOOP
                                IF p_other_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   ( token      => p_other_token_tbl(l_LoopIndex).token_name
                                    , value     => p_other_token_tbl(l_LoopIndex).token_value
                                    );
                                END IF;
                        END LOOP;

                        fnd_msg_pub.add;

                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
                        LOOP
                                IF p_other_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   ( token      => p_other_token_tbl(l_LoopIndex).token_name
                                    , value     => p_other_token_tbl(l_LoopIndex).token_value
                                    , translate => p_other_token_tbl(l_LoopIndex).translate
                                    );
                                END IF;
                        END LOOP;

                        l_other_message := fnd_message.get;

                ELSE
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        fnd_msg_pub.add;

                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        l_other_message := fnd_message.get;

                END IF;
                -- Other Token Tbl Count <> 0 Ends
                                Add_Message
                                (  p_mesg_text          => l_other_message
                                 , p_entity_id          => p_error_level
                                 , p_entity_index       => p_entity_index
                                 , p_message_type       => 'E'
                                 );
                                l_other_message := NULL;
              END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished extracting other message . . . '); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Message generated: ' || l_other_message); END IF;

        /*
                --
                -- If the Error Level is Business Object
                -- then set the Error Level = WO
                --

                IF l_error_level = G_BO_LEVEL
                THEN
                        l_error_level := G_WO_LEVEL;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Level is Business Object . . . '); END IF;

                END IF;


                --
                -- If the error_status is UNEXPECTED then set the error scope
                -- to ALL, if WARNING then set the scope to RECORD.
                --

                IF l_error_status = G_STATUS_UNEXPECTED
                THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Status unexpected and scope is All . . .'); END IF;

                        l_error_scope := G_SCOPE_ALL;

                ELSIF l_error_status = G_STATUS_WARNING

                THEN
                        l_error_scope := G_SCOPE_RECORD;
                        l_error_status := FND_API.G_RET_STS_SUCCESS;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Status is warning . . .'); END IF;

                END IF;

                --
                -- If the Error Level is WO Header, then the scope can be
                -- ALL/CHILDREN OR RECORD.
                --

                --
                -- If the Error Level is WO Header.


             IF l_error_level = G_WO_LEVEL
                THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Level is WO Header . . .'); END IF;
                        --
                        -- Set the WO Header record status to p_error_status
                        -- This will also take care of the scope RECORD.
                        --
                        g_eam_wo_rec.return_status := l_error_status;


                        IF l_error_scope = G_SCOPE_ALL OR
                           l_error_scope = G_SCOPE_CHILDREN
                        THEN
                        --
                        -- Set all the operation's
                        -- status, this will then set the
                        -- status of the operation resoources
                        -- and substitute operation resoources

                       setOperationSequences
                        (  p_other_mesg_text => l_other_message
                         , p_other_status    => p_other_status
                         , p_error_scope     => G_SCOPE_ALL
                        );

                        END IF;
                        -- Work Order Header Scope =  ALL or Children Ends


        --
        -- If the Error Level is Operation Networks
        --

        ELSIF l_error_level = G_OP_NETWORK_LEVEL
        THEN
            --
            -- Set the Operatin Network record at the current entity_index
            -- This will take care of scope = RECORD
            --
            g_eam_op_network_tbl(p_entity_index).return_status := l_error_status;

            IF l_error_scope = G_SCOPE_ALL
            THEN
               IF g_eam_op_network_tbl.COUNT <> 0
               THEN
                  --
                  -- Set all the revision record status
                  --
                  setOpNetworks
                  (  p_other_mesg_text => l_other_message
                   , p_other_status    => p_other_status
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
               ) ;

            END IF;

        --
        -- If the Error Level is Operation Sequences
        --
        ELSIF l_error_level = G_OP_LEVEL
        THEN

            --
            -- Set operation sequence record at the entity_index
            -- to error_status
            -- This will take care of Scope = RECORD.
            --
            g_eam_op_tbl(p_entity_index).return_status := l_error_status;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Operation Sequences . . .'); END IF;

            IF l_error_scope = G_SCOPE_SIBLINGS OR
               l_error_scope = G_SCOPE_ALL
            THEN
                 setOperationSequences
                 (  p_other_mesg_text => l_other_message
                  , p_other_status    => p_other_status
                  , p_error_scope     => G_SCOPE_ALL
                  , p_entity_index    => p_entity_index
                 ) ;
            ELSIF l_error_scope = G_SCOPE_CHILDREN
            THEN
                IF g_eam_res_tbl.COUNT <> 0
                THEN
                    setOperationResources
                    (  p_error_scope     => l_error_scope
                     , p_other_status    => p_other_status
                     , p_other_mesg_text => l_other_message
                     , p_op_idx          => p_entity_index
                     );
                END IF;

                IF g_eam_sub_res_tbl.COUNT <> 0
                THEN
                    setSubResources
                    (  p_error_scope     => l_error_scope
                     , p_other_status    => p_other_status
                     , p_other_mesg_text => l_other_message
                     , p_op_idx          => p_entity_index
                    );
                END IF;

                IF g_eam_mat_req_tbl.COUNT <> 0
                THEN
                   setMaterialRequirements
                   (  p_error_scope     => l_error_scope
                    , p_other_status    => p_other_status
                    , p_other_mesg_text => l_other_message
                    , p_op_idx          => p_entity_index
                   ) ;
                END IF ;

                IF g_eam_direct_items_tbl.COUNT <> 0
                THEN
                   setDirectItems
                   (  p_error_scope     => l_error_scope
                    , p_other_status    => p_other_status
                    , p_other_mesg_text => l_other_message
                    , p_op_idx          => p_entity_index
                   ) ;
                END IF ;

            END IF; -- scope = Siblings or All Ends

        --
        -- If the Error Level is Operation Resources
        --

        ELSIF l_error_level = G_RES_LEVEL
        THEN
            --
            -- Set operation resource record status at entity_idx
            -- This will take care of Scope = RECORD.
            --
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Operation Resource . . .'); END IF;

            g_eam_res_tbl(p_entity_index).return_status := l_error_status;
--            IF l_error_scope <> G_SCOPE_RECORD
            IF l_error_scope = G_SCOPE_SIBLINGS OR
               l_error_scope = G_SCOPE_ALL
            THEN
                setOperationResources
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;


            END IF;



        --
        -- If the Error Level is Resource Instances
        --

        ELSIF l_error_level = G_RES_INST_LEVEL
        THEN
             -- Set resource instance record status at entity_idx
             -- This will take care of Scope = RECORD.
             --
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Resource Instances . . .'); END IF;

             g_eam_res_inst_tbl(p_entity_index).return_status := l_error_status;

             IF l_error_scope <> G_SCOPE_RECORD
             THEN
                setResInstances
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;
             END IF ;


        --
        -- If the Error Level is Sub Op Resources
        --

        ELSIF l_error_level = G_SUB_RES_LEVEL
        THEN
             -- Set substitute resource record status at entity_idx
             -- This will take care of Scope = RECORD.
             --
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Substitute Op Resources . . .'); END IF;

             g_eam_sub_res_tbl(p_entity_index).return_status := l_error_status;

             IF l_error_scope <> G_SCOPE_RECORD
             THEN
                setSubResources
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;
             END IF ;




        ELSIF l_error_level = G_RES_USAGE_LEVEL
        THEN
            --
            -- Set resource usage record status at entity_idx
            -- This will take care of Scope = RECORD.
            --
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Resource Usage. . .'); END IF;

            g_eam_res_usage_tbl(p_entity_index).return_status := l_error_status;
--            IF l_error_scope <> G_SCOPE_RECORD
            IF l_error_scope = G_SCOPE_SIBLINGS OR
               l_error_scope = G_SCOPE_ALL
            THEN
                setResUsages
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;
             END IF ;

        --
        -- If the Error Level is Material Requirements
        --



        ELSIF l_error_level = G_MAT_REQ_LEVEL
        THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Material Requirements . . .'); END IF;

             g_eam_mat_req_tbl(p_entity_index).return_status := l_error_status;

             IF l_error_scope <> G_SCOPE_RECORD
             THEN
                setMaterialRequirements
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;
             END IF ;


        --
        -- If the Error Level is Direct Items
        --

        ELSIF l_error_level = G_DIRECT_ITEMS_LEVEL
        THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = DIRECT ITEMS . . .'); END IF;

             g_eam_direct_items_tbl(p_entity_index).return_status := l_error_status;

             IF l_error_scope <> G_SCOPE_RECORD
             THEN
                setDirectItems
                (  p_error_scope     => l_error_scope
                 , p_other_status    => p_other_status
                 , p_other_mesg_text => l_other_message
                 , p_entity_index    => p_entity_index
                ) ;
             END IF ;

        END IF;	*/

        -- Error Level  If Ends.




        --
        -- Copy the changed record/Tables to the out parameters for
        -- returing to the calling program.
        --
        x_eam_wo_rec                   := g_eam_wo_rec;
        x_eam_op_tbl                   := g_eam_op_tbl;
        x_eam_op_network_tbl           := g_eam_op_network_tbl;
        x_eam_res_tbl                  := g_eam_res_tbl;
        x_eam_res_inst_tbl             := g_eam_res_inst_tbl;
        x_eam_sub_res_tbl              := g_eam_sub_res_tbl;
        x_eam_res_usage_tbl            := g_eam_res_usage_tbl;
        x_eam_mat_req_tbl              := g_eam_mat_req_tbl;
        x_eam_direct_items_tbl         := g_eam_direct_items_tbl;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('End of Rtg Log Error.'); END IF;

        END Log_Error;


        /*********************************************************************
        * Procedure     : Initialize
        * Parameters    : None
        * Purpose       : This procedure will initialize the global message
        *                 list and reset the index variables to 0.
        *                 User must initialize the message list before using
        *                 it.
        **********************************************************************/
        PROCEDURE Initialize
        IS
        BEGIN

                G_Error_Table.DELETE;
                G_Msg_Count := 0;
                G_Msg_Index := 0;

                FND_MSG_PUB.Initialize;

        END Initialize;

        /********************************************************************
        * Procedure     : Reset
        * Parameters    : None
        * Purpose       : Reset will reset the message index to the begining
        *                 of the list and the user can start reading the
        *                 messages again.
        *********************************************************************/
        PROCEDURE Reset
        IS
        BEGIN

                g_Msg_Index := 0;

        END Reset;

        /********************************************************************
        * Procedure     : Get_Message_List
        * Parameters    : None
        * Purpose       : This procedure will return the entire message
        *                 table out NOCOPY the user. The returned list will be
        *                 for a particular business object.
        *********************************************************************/
        PROCEDURE Get_Message_List
        ( x_Message_List OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type)
        IS
                l_bo_identifier VARCHAR2(3) := EAM_ERROR_MESSAGE_PVT.Get_BO_Identifier;
                l_msg_count     NUMBER := 1;

        BEGIN
                FOR l_err_idx IN 1..G_ERROR_TABLE.COUNT
                LOOP
                        IF G_Error_Table(l_err_idx).bo_identifier =
                           l_bo_identifier
                        THEN
                                x_message_list(l_msg_count) :=
                                        G_Error_Table(l_err_idx);
                                l_msg_Count := l_msg_count + 1;
                        END IF;
                END LOOP;

        END Get_Message_List;


        /********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
        * Parameters OUT NOCOPY: Error List
        * Purpose       : This procedure will return all the messages for
        *                 a specific Entity.
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id  IN  VARCHAR2
         , x_Message_List OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type
        )
        IS
                l_Idx           NUMBER;
                l_Mesg_List     EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type;
                l_Count         NUMBER := 1;
                l_bo_identifier VARCHAR2(3) := EAM_ERROR_MESSAGE_PVT.Get_BO_Identifier;
        BEGIN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Get Messages for Entity : ' || p_entity_id); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Table Size = ' || to_char(G_Msg_Count)); END IF;

                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_Idx).bo_identifier = l_bo_identifier
                        THEN
                                l_mesg_list(l_count) := G_Error_Table(l_Idx);
                                l_Count := l_Count + 1;
                        END IF;
                END LOOP;
                x_Message_List := l_Mesg_List;

        END Get_Entity_Message;

        /*********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
        *                 Entity Index
        * Parameters OUT NOCOPY: Message Text
        * Purpose       : This procedure will a specific messages for
        *                 an entity and its index
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id          IN  VARCHAR2
         , p_entity_index       IN  NUMBER
         , x_message_text       OUT NOCOPY VARCHAR2
         )
        IS
                l_Idx           NUMBER;
                l_Mesg_List     EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type;
                l_Count         NUMBER;
                l_bo_identifier VARCHAR2(3) := EAM_ERROR_MESSAGE_PVT.Get_BO_Identifier;
        BEGIN
                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).entity_index = p_entity_index
                           AND
                           G_Error_Table(l_idx).bo_identifier = l_bo_identifier
                        THEN
                                x_message_text :=
                                        G_Error_Table(l_idx).message_text;
                        END IF;
                END LOOP;
        END Get_Entity_Message;

        /*********************************************************************
        * Procedure     : Get_Message
        * Parameters    : None
        * Purpose       : This procedure will return the message at the current
        *                 message index and will advance the pointer to the
        *                 next number. If the user tries to retrieve beyond the
        *                 the size of the message list, then the message index
        *                 will be reset to the begining position.
        **********************************************************************/
        PROCEDURE Get_Message
        (  x_message_text        OUT NOCOPY VARCHAR2
         , x_entity_index        OUT NOCOPY NUMBER
         , x_entity_id           OUT NOCOPY VARCHAR2
         , x_message_type        OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN
                IF G_Msg_Index = G_Msg_Count
                THEN
                        G_Msg_Index := 0;
                ELSE
                        G_Msg_Index := G_Msg_Index + 1;
                        x_message_text :=
                                G_Error_Table(g_Msg_Index).message_text;
                        x_entity_id :=
                                G_Error_Table(g_Msg_Index).entity_id;
                        x_entity_index :=
                                G_Error_Table(g_Msg_Index).entity_index;
                        x_message_type :=
                                G_Error_Table(g_Msg_Index).message_type;
                END IF;

        END Get_Message;

        /********************************************************************
        * Procedure     : Delete_Message
        * Parameters IN : Entity Id
        *                 Entity Index
        * Purpose       : This procedure will delete a message for an entity
        *                 record.
        **********************************************************************/
        PROCEDURE Delete_Message
        (  p_entity_id          IN  VARCHAR2
         , p_entity_index       IN  NUMBER
        )
        IS
                l_idx   NUMBER;
        BEGIN
                FOR l_Idx IN 1..G_Msg_Count
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).entity_index = p_entity_index
                        THEN
                               G_Error_Table.Delete(l_idx);
                               G_Msg_Count := G_Msg_Count - 1;
                        END IF;
                END LOOP;
        END Delete_Message;

        /********************************************************************
        * Procedure     : Delete_Message
        * Parameters IN : Entity Id
        * Purpose       : This procedure will delete all messages for an entity
        **********************************************************************/
        PROCEDURE Delete_Message
        (  p_entity_id          IN  VARCHAR2 )
        IS
                l_idx   NUMBER;
        BEGIN
                FOR l_Idx IN 1..G_Msg_Count
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id
                        THEN
                               G_Error_Table.Delete(l_idx);
                               G_Msg_Count := G_Msg_Count - 1;
                        END IF;
                END LOOP;
        END Delete_Message;



        /* This procedure deletes the last message in the message stack
        */
        PROCEDURE Delete_Message
        IS
          l_count NUMBER;
        BEGIN
                G_Msg_Count := G_Error_Table.Count;
                G_Error_Table.delete(G_Msg_Count,G_Msg_Count);
                G_Msg_Count := G_Error_Table.Count;
        END Delete_Message;


        /*********************************************************************
        * Function      : Get_Message_Count
        * Parameters    : None
        * Purpose       : Returns the current number of records in the message
        *                 list
        **********************************************************************/
        FUNCTION Get_Message_Count
        RETURN NUMBER
        IS
        BEGIN
                RETURN G_Msg_Count;
        END Get_Message_Count;

        /*********************************************************************
        * Function      : Dump_Message_List
        * Parameters    : None
        * Purpose       : Will generate a dump of the message list using
        *                 utl_file.
        **********************************************************************/
        PROCEDURE Dump_Message_List
        IS
                l_idx   NUMBER;
        BEGIN
                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Dumping Message List :'); END IF;
                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Number of Messages = '|| G_Error_Table.COUNT); END IF;

                FOR l_idx IN 1..G_Error_Table.COUNT LOOP
                        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entity Id: ' || G_Error_Table(l_idx).entity_id ); END IF;
                        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entity Index: ' || to_char(G_Error_Table(l_idx).entity_index)); END IF;
                        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Message: ' || G_Error_Table(l_idx).message_text); END IF;
                END LOOP;

        END Dump_Message_List;


/*This procedure is used to open the debug session.But if the file could not be opened or input directory is null
  then an error will be returned and the calling procedure will set the debug flag to 'N' and continue.Hence no
  error messages will be shown to user but the log messages will not be written in case of an error*/
        PROCEDURE Open_Debug_Session
        (  p_debug_filename     IN  VARCHAR2
         , p_output_dir         IN  VARCHAR2
         , p_debug_file_mode    IN  VARCHAR2
         , x_return_status      OUT NOCOPY VARCHAR2
         , p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         , x_mesg_Token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
         )
        IS
                l_found NUMBER := 0;
                l_mesg_token_tbl EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type :=
                                p_mesg_token_tbl;
                l_utl_file_dir VARCHAR2(2000);
                l_debug_file_mode VARCHAR2(1) := p_debug_file_mode;
        BEGIN
               IF(p_output_dir IS NULL) THEN
	              EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_Message_name       => NULL
                         , p_message_text       =>
                           ' Debug Session could not be started because the ' ||
                           ' output directory name is invalid. '             ||
                           ' Output directory must be one of the directory ' ||
                           ' value in v$parameter for name = utl_file_dir '  ||
                           ' If unsure leave out the value and the log will '||
                           ' be written to /sqlcom/log '
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_mesg_token_tbl := l_mesg_token_tbl;
                        RETURN;
	       END IF;

		select  value
                  INTO l_utl_file_dir
                  FROM v$parameter
                 WHERE name = 'utl_file_dir';

                 l_found := INSTR(l_utl_file_dir, p_output_dir);

                IF l_found = 0
                THEN
                        EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_Message_name       => NULL
                         , p_message_text       =>
                           ' Debug Session could not be started because the ' ||
                           ' output directory name is invalid. '             ||
                           ' Output directory must be one of the directory ' ||
                           ' value in v$parameter for name = utl_file_dir '  ||
                           ' If unsure leave out the value and the log will '||
                           ' be written to /sqlcom/log '
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_mesg_token_tbl := l_mesg_token_tbl;
                        RETURN;
                END IF;

                if l_debug_file_mode <> 'w' and
                   l_debug_file_mode <> 'W' and
                   l_debug_file_mode <> 'a' and
                   l_debug_file_mode <> 'A' then
                  l_debug_file_mode := 'w';
                end if;

                EAM_ERROR_MESSAGE_PVT.Debug_File := utl_file.fopen(  p_output_dir
                                                           , p_debug_filename
                                                           , p_debug_file_mode);

                x_return_status := FND_API.G_RET_STS_SUCCESS;

                EXCEPTION
                        WHEN UTL_FILE.INVALID_PATH THEN
                                EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                                (  p_message_name       => NULL
                                 , p_message_text       => 'Error opening Debug file . . . ' || sqlerrm
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                        x_mesg_token_tbl := l_mesg_token_tbl;
			x_return_status := FND_API.G_RET_STS_ERROR;
        END Open_Debug_Session;

        PROCEDURE Write_Debug
        (  p_debug_message      IN  VARCHAR2 )
        IS
        BEGIN
                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
                THEN
                    utl_file.put_line(EAM_ERROR_MESSAGE_PVT.Debug_File, p_debug_message);

                END IF;
        END Write_Debug;

        PROCEDURE Close_Debug_Session
        IS
        BEGIN
                IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
                THEN
                  utl_file.fclose(EAM_ERROR_MESSAGE_PVT.Debug_File);
                  -- set debug to NO once debug session is closed
                  EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
        END Close_Debug_Session;


	PROCEDURE Set_BO_Identifier(p_bo_identifier        IN VARCHAR)
	IS
	BEGIN
		G_BO_IDENTIFIER := p_bo_identifier;

	END Set_BO_Identifier;

	FUNCTION  Get_BO_Identifier RETURN VARCHAR2
	IS
	BEGIN
		RETURN G_BO_IDENTIFIER;
	END Get_BO_Identifier;


PROCEDURE Log_Error
        (   p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_COMP_WO_REC
     , p_eam_wo_quality_tbl      IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_QUALITY_TBL
     , p_eam_meter_reading_tbl   IN  EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_METER_READING_TBL
     , p_eam_counter_prop_tbl    IN  EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
				     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_COUNTER_PROP_TBL
     , p_eam_wo_comp_rebuild_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_COMP_REBUILD_TBL
     , p_eam_wo_comp_mr_read_tbl IN  EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_WO_COMP_MR_READ_TBL
     , p_eam_op_comp_tbl         IN  EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
                                     :=EAM_PROCESS_WO_PUB.G_MISS_EAM_OP_COMP_TBL
     , p_eam_request_tbl         IN  EAM_PROCESS_WO_PUB.eam_request_tbl_type
                                    :=EAM_PROCESS_WO_PUB.G_MISS_EAM_REQUEST_TBL

     , x_eam_wo_comp_rec            OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
     , x_eam_wo_quality_tbl         OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
     , x_eam_meter_reading_tbl      OUT NOCOPY EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type
     , x_eam_counter_prop_tbl       OUT NOCOPY EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type
     , x_eam_wo_comp_rebuild_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type
     , x_eam_wo_comp_mr_read_tbl    OUT NOCOPY EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type
     , x_eam_op_comp_tbl            OUT NOCOPY EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type
     , x_eam_request_tbl            OUT NOCOPY EAM_PROCESS_WO_PUB.eam_request_tbl_type

     , p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , p_error_status       IN  VARCHAR2
     , p_error_scope        IN  VARCHAR2 := NULL
     , p_other_message      IN  VARCHAR2 := NULL
     , p_other_mesg_appid   IN  VARCHAR2 := 'EAM'
     , p_other_status       IN  VARCHAR2 := NULL
     , p_other_token_tbl    IN  EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type
                                := EAM_ERROR_MESSAGE_PVT.G_MISS_TOKEN_TBL
     , p_error_level        IN   NUMBER
     , p_entity_index       IN   NUMBER := 1  -- := NULL
         )
        IS
                l_message_name          VARCHAR2(30);
                l_other_message         VARCHAR2(2000);
                l_message_text          VARCHAR2(2000);
                l_LoopIndex             NUMBER;
                l_Error_Level           NUMBER      := p_Error_Level;
                l_error_scope           VARCHAR2(1) := p_error_scope;
                l_error_status          VARCHAR2(1) := p_error_status;
                l_application_id        VARCHAR2(3);

        BEGIN

	g_eam_wo_comp_rec		:= p_eam_wo_comp_rec;
	g_eam_wo_quality_tbl		:= p_eam_wo_quality_tbl;
	g_eam_meter_reading_tbl		:= p_eam_meter_reading_tbl;
	g_eam_counter_prop_tbl		:= p_eam_counter_prop_tbl;
	g_eam_wo_comp_rebuild_tbl	:= p_eam_wo_comp_rebuild_tbl;
	g_eam_wo_comp_mr_read_tbl	:= p_eam_wo_comp_mr_read_tbl;
	g_eam_op_comp_tbl		:= p_eam_op_comp_tbl;
	g_eam_request_tbl		:= p_eam_request_tbl;

        l_application_id :=  p_other_mesg_appid;

         --
         -- Seperate message and their tokens, get the
         -- token substituted messages and put it in the
         -- Error Table.
         --

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within the Log Error Procedure . . .'); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Scope: ' || l_error_scope); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entity Index: ' || to_char(p_entity_index)); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Level: ' || to_char(p_error_level)); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Status: ' || l_error_status); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Status: ' || p_other_status); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Message: ' || p_other_message); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Business Object: ' || Get_BO_Identifier); END IF;

    EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => p_mesg_token_tbl
                 , p_error_level        => p_error_level
                 , p_entity_index       => p_entity_index
                );
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished logging messages . . . '); END IF;

                --
                -- Get the other message text and token and retrieve the
                -- token substituted message.

              IF p_other_message is not null THEN
                IF p_other_token_tbl.COUNT <> 0
                THEN
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
                        LOOP
                                IF p_other_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   ( token      => p_other_token_tbl(l_LoopIndex).token_name
                                    , value     => p_other_token_tbl(l_LoopIndex).token_value
                                    );
                                END IF;
                        END LOOP;

                        fnd_msg_pub.add;

                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );
                        FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
                        LOOP
                                IF p_other_token_tbl(l_LoopIndex).token_name IS NOT NULL
                                THEN
                                   fnd_message.set_token
                                   ( token      => p_other_token_tbl(l_LoopIndex).token_name
                                    , value     => p_other_token_tbl(l_LoopIndex).token_value
                                    , translate => p_other_token_tbl(l_LoopIndex).translate
                                    );
                                END IF;
                        END LOOP;

                        l_other_message := fnd_message.get;

                ELSE
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        fnd_msg_pub.add;

                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        l_other_message := fnd_message.get;

                END IF;
                -- Other Token Tbl Count <> 0 Ends
                                Add_Message
                                (  p_mesg_text          => l_other_message
                                 , p_entity_id          => p_error_level
                                 , p_entity_index       => p_entity_index
                                 , p_message_type       => 'E'
                                 );
                                l_other_message := NULL;
              END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Finished extracting other message . . . '); END IF;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Other Message generated: ' || l_other_message); END IF;

  --
                -- If the Error Level is Business Object
                -- then set the Error Level = WO
                --

                IF l_error_level = G_BO_LEVEL
                THEN
                        l_error_level := G_WO_LEVEL;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Error Level is Business Object . . . '); END IF;

                END IF;


                --
                -- If the error_status is UNEXPECTED then set the error scope
                -- to ALL, if WARNING then set the scope to RECORD.
                --

                IF l_error_status = G_STATUS_UNEXPECTED
                THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Status unexpected and scope is All . . .'); END IF;

                        l_error_scope := G_SCOPE_ALL;

                ELSIF l_error_status = G_STATUS_WARNING

                THEN
                        l_error_scope := G_SCOPE_RECORD;
                        l_error_status := FND_API.G_RET_STS_SUCCESS;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Status is warning . . .'); END IF;

                END IF;

	x_eam_wo_comp_rec          := g_eam_wo_comp_rec       ;
	x_eam_wo_quality_tbl       := g_eam_wo_quality_tbl     ;
	x_eam_meter_reading_tbl    := g_eam_meter_reading_tbl   ;
	x_eam_counter_prop_tbl     := g_eam_counter_prop_tbl    ;
	x_eam_wo_comp_rebuild_tbl  := g_eam_wo_comp_rebuild_tbl ;
	x_eam_wo_comp_mr_read_tbl  := g_eam_wo_comp_mr_read_tbl ;
	x_eam_op_comp_tbl          := g_eam_op_comp_tbl         ;
	x_eam_request_tbl          := g_eam_request_tbl         ;

        END Log_Error;

END EAM_ERROR_MESSAGE_PVT;

/
