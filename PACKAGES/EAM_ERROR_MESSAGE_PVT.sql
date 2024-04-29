--------------------------------------------------------
--  DDL for Package EAM_ERROR_MESSAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ERROR_MESSAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWOES.pls 120.1 2005/05/30 10:30:06 appldev  $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOES.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_ERROR_MESSAGE_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

--  Global constant holding the package name

    G_PKG_NAME          CONSTANT VARCHAR2(30)   := 'EAM_ERROR_MESSAGE_PVT';

    G_BO_LEVEL          CONSTANT NUMBER         := 0;

    G_WO_LEVEL          CONSTANT NUMBER         := 1;
    G_OP_LEVEL          CONSTANT NUMBER         := 2;
    G_OP_NETWORK_LEVEL  CONSTANT NUMBER         := 3;
    G_RES_LEVEL         CONSTANT NUMBER         := 4;
    G_RES_INST_LEVEL    CONSTANT NUMBER         := 5;
    G_SUB_RES_LEVEL     CONSTANT NUMBER         := 6;
    G_RES_USAGE_LEVEL   CONSTANT NUMBER         := 7;
    G_MAT_REQ_LEVEL     CONSTANT NUMBER         := 8;
    G_DIRECT_ITEMS_LEVEL     CONSTANT NUMBER    := 9;

   G_WO_COMP_LEVEL		CONSTANT NUMBER     := 10;
   G_WO_QUALITY_LEVEL		CONSTANT NUMBER     := 11;
   G_METER_READING_LEVEL	CONSTANT NUMBER     := 12;
   G_WO_COMP_REBUILD_LEVEL	CONSTANT NUMBER     := 13;
   G_WO_COMP_MR_READ_LEVEL	CONSTANT NUMBER     := 14;
   G_OP_COMP_LEVEL		CONSTANT NUMBER     := 15;
   G_REQUEST_TBL_LEVEL		CONSTANT NUMBER     := 16;



    G_STATUS_WARNING    CONSTANT VARCHAR2(1)    := 'W';
    G_STATUS_UNEXPECTED CONSTANT VARCHAR2(1)    := 'U';
    G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';
    G_STATUS_FATAL      CONSTANT VARCHAR2(1)    := 'F';
    G_STATUS_NOT_PICKED CONSTANT VARCHAR2(1)    := 'N';

    G_SCOPE_ALL         CONSTANT VARCHAR2(1)    := 'A';
    G_SCOPE_RECORD      CONSTANT VARCHAR2(1)    := 'R';
    G_SCOPE_SIBLINGS    CONSTANT VARCHAR2(1)    := 'S';
    G_SCOPE_CHILDREN    CONSTANT VARCHAR2(1)    := 'C';

    Debug_File      UTL_FILE.FILE_TYPE;

    --  Error record type
    TYPE Error_Rec_Type IS RECORD
    (   organization_id               NUMBER
    ,   entity_id                     VARCHAR2(3)
    ,   message_text                  VARCHAR2(2000)
    ,   entity_index                  NUMBER
    ,   message_type                  VARCHAR2(1)
    ,   bo_identifier                 VARCHAR2(3) := 'EAM'
    );

    TYPE Error_Tbl_Type IS TABLE OF Error_Rec_Type
            INDEX BY BINARY_INTEGER;

    TYPE Mesg_Token_Rec_Type IS RECORD
    (  message_name                   VARCHAR2(30)   := NULL
     , application_id                 VARCHAR2(3)    := NULL
     , message_text                   VARCHAR2(2000) := NULL
     , token_name                     VARCHAR2(30)   := NULL
     , token_value                    VARCHAR2(100)  := NULL
     , translate                      BOOLEAN        := FALSE
     , message_type                   VARCHAR2(1)    := NULL
     );

    TYPE Mesg_Token_Tbl_Type IS TABLE OF Mesg_Token_Rec_Type
            INDEX BY BINARY_INTEGER;

    TYPE Token_Rec_Type IS RECORD
    (  token_value                    VARCHAR2(100) := NULL
    ,  token_name                     VARCHAR2(30)  := NULL
    ,  translate                      BOOLEAN       := FALSE
     );

    TYPE Token_Tbl_Type IS TABLE OF Token_Rec_Type
            INDEX BY BINARY_INTEGER;

    G_MISS_TOKEN_TBL             Token_Tbl_Type;
    G_MISS_MESG_TOKEN_TBL        Mesg_Token_Tbl_Type;


    PROCEDURE Add_Message
    (  p_mesg_text          IN  VARCHAR2
     , p_entity_id          IN  NUMBER
     , p_entity_index       IN  NUMBER
     , p_message_type       IN  VARCHAR2
     );

    PROCEDURE Translate_And_Insert_Messages
    (  p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , p_error_level        IN  NUMBER
     , p_entity_index       IN  NUMBER
     , p_application_id     IN  VARCHAR2 := 'EAM'
     );

    PROCEDURE Add_Error_Token
    (  p_message_name       IN  VARCHAR2 := NULL
     , p_application_id     IN  VARCHAR2 := 'EAM'
     , p_message_text       IN  VARCHAR2 := NULL
     , x_Mesg_Token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , p_Mesg_Token_Tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type := EAM_ERROR_MESSAGE_PVT.G_MISS_MESG_TOKEN_TBL
     , p_token_tbl          IN  EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type := EAM_ERROR_MESSAGE_PVT.G_MISS_TOKEN_TBL
     , p_message_type       IN  VARCHAR2 := 'E'
     );

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
     );



    PROCEDURE Initialize;

    PROCEDURE Reset;

    PROCEDURE Get_Message_List
    ( x_message_list        OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type);

    PROCEDURE Get_Entity_Message
    (  p_entity_id          IN  VARCHAR2
     , x_message_list       OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Error_Tbl_Type
     );

    PROCEDURE Get_Entity_Message
    (  p_entity_id          IN  VARCHAR2
     , p_entity_index       IN  NUMBER
     , x_message_text       OUT NOCOPY VARCHAR2
     );

    PROCEDURE Delete_Message
    (  p_entity_id          IN  VARCHAR2
     , p_entity_index       IN  NUMBER
     );

    PROCEDURE Delete_Message
    (  p_entity_id          IN  VARCHAR2
     );

    PROCEDURE Delete_Message;

    PROCEDURE Get_Message
    (  x_message_text       OUT NOCOPY VARCHAR2
     , x_entity_index       OUT NOCOPY NUMBER
     , x_entity_id          OUT NOCOPY VARCHAR2
     , x_message_type       OUT NOCOPY VARCHAR2
     );

    FUNCTION Get_Message_Count RETURN NUMBER;

    PROCEDURE Dump_Message_List;

    PROCEDURE Open_Debug_Session
    (  p_debug_filename     IN  VARCHAR2
     , p_output_dir         IN  VARCHAR2
     , p_debug_file_mode    IN  VARCHAR2
     , x_return_status      OUT NOCOPY VARCHAR2
     , p_mesg_token_tbl     IN  EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     , x_mesg_token_tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
     );

    PROCEDURE Close_Debug_Session;

    PROCEDURE Write_Debug
    (  p_debug_message      IN  VARCHAR2
     );

     PROCEDURE Set_BO_Identifier(p_bo_identifier IN VARCHAR);

     FUNCTION  Get_BO_Identifier RETURN VARCHAR2;


 PROCEDURE Log_Error
    (  p_eam_wo_comp_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_comp_rec_type
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
     );

END EAM_ERROR_MESSAGE_PVT;

 

/
