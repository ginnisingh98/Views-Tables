--------------------------------------------------------
--  DDL for Package Body WIP_EAM_PROCESS_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EAM_PROCESS_WO_PUB" AS
/* $Header: WIPPWOPB.pls 120.1 2005/06/29 03:52:35 mmaduska noship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30):='WIP_EAM_PROCESS_WO_PUB';







PROCEDURE Update_Firm_Planned_Flag
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2,
    p_wip_entity_id             IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_firm_planned_flag         IN  NUMBER
) IS

        l_eam_wo_rec               eam_process_wo_pub.eam_wo_rec_type;
        l_eam_op_tbl               EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_eam_op_network_tbl       EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl              EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_eam_res_inst_tbl         EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_eam_sub_res_tbl          EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_eam_res_usage_tbl        EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_eam_mat_req_tbl          EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_eam_di_tbl               EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        l_out_eam_wo_rec           eam_process_wo_pub.eam_wo_rec_type;
        l_out_eam_op_tbl           EAM_PROCESS_WO_PUB.eam_op_tbl_type;
        l_out_eam_op_network_tbl   EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_out_eam_res_tbl          EAM_PROCESS_WO_PUB.eam_res_tbl_type;
        l_out_eam_res_inst_tbl     EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
        l_out_eam_sub_res_tbl      EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
        l_out_eam_res_usage_tbl    EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
        l_out_eam_mat_req_tbl      EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
        l_out_eam_di_tbl           EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;

        l_return_status            VARCHAR2(1);
        l_msg_count                NUMBER;
        l_error_message            VARCHAR2(512);

        l_api_version              NUMBER;
        l_init_msg_list            VARCHAR2(10);
        l_init                     BOOLEAN;
        l_commit                   VARCHAR2(10);
        l_validation_level         NUMBER;

BEGIN

    l_api_version                   := p_api_version;
    l_init_msg_list                 := p_init_msg_list;
    l_commit                        := p_commit;
    l_validation_level              := p_validation_level;

    l_eam_wo_rec := null;
    l_eam_wo_rec.wip_entity_id := p_wip_entity_id;
    l_eam_wo_rec.organization_id := p_organization_id;
    l_eam_wo_rec.firm_planned_flag := p_firm_planned_flag;
    l_eam_wo_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;

    l_init := FALSE;
    if nvl(l_init_msg_list,'T') = 'Y' then
      l_init := TRUE;
    end if;


        eam_process_wo_pub.PROCESS_WO
        (  p_bo_identifier           => 'EAM'
         , p_api_version_number      => l_api_version
         , p_init_msg_list           => l_init
         , p_commit                  => l_commit
         , p_eam_wo_rec              => l_eam_wo_rec
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_di_tbl
         , x_eam_wo_rec              => l_out_eam_wo_rec
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_direct_items_tbl    => l_out_eam_di_tbl
         , x_return_status           => l_return_status
         , x_msg_count               => l_msg_count
         , p_debug                   => 'N'
         , p_output_dir              => NULL
         , p_debug_filename          => 'EAM_WO_DEBUG.log'
         , p_debug_file_mode         => 'w'
         );


         x_return_status := l_return_status;
         x_msg_count     := l_msg_count;

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
         ( p_count  => x_msg_count,
           p_data   => x_msg_data
         );

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;
          l_error_message := substrb(sqlerrm,1,512);
          x_msg_data      := l_error_message;

END Update_Firm_Planned_Flag;




PROCEDURE Move_WO
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_offset_days                   IN      NUMBER := 1,  -- 1 Day Default
        p_offset_direction              IN      NUMBER  := 1, -- Forward
        p_start_date                    IN      DATE    := null,
        p_completion_date               IN      DATE    := null,
        p_schedule_method               IN      NUMBER  := 1, -- Forward Scheduling

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )
IS

        l_api_version                   NUMBER;
        l_init_msg_list                 VARCHAR2(10);
        l_commit                        VARCHAR2(10);
        l_validation_level              NUMBER;

        l_work_object_id                NUMBER;
        l_work_object_type_id           NUMBER;
        l_offset_days                   NUMBER;
        l_offset_direction              NUMBER;
        l_start_date                    DATE;
        l_completion_date               DATE;
        l_schedule_method               NUMBER;

        l_return_status                 VARCHAR2(10);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(512);
        l_error_message                 VARCHAR2(512);

BEGIN

        l_api_version                   := p_api_version;
        l_init_msg_list                 := p_init_msg_list;
        l_commit                        := p_commit;
        l_validation_level              := p_validation_level;

        l_work_object_id                := p_work_object_id;
        l_work_object_type_id           := p_work_object_type_id;
        l_offset_days                   := p_offset_days;
        l_offset_direction              := p_offset_direction;
        l_start_date                    := p_start_date;
        l_completion_date               := p_completion_date;
        l_schedule_method               := p_schedule_method;

        EAM_WO_NETWORK_UTIL_PVT.Move_WO
        (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        p_commit                        => l_commit,
        p_validation_level              => l_validation_level,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,
        p_offset_days                   => l_offset_days,
        p_offset_direction              => l_offset_direction,
        p_start_date                    => l_start_date,
        p_completion_date               => l_completion_date,
        p_schedule_method               => l_schedule_method,

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

        x_return_status                 := l_return_status;
        x_msg_count                     := l_msg_count;
        x_msg_data                      := l_msg_data;

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;
          l_error_message := substrb(sqlerrm,1,512);
          x_msg_data      := l_error_message;

END;





    PROCEDURE Validate_Structure
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_exception_logging             IN      VARCHAR2 := 'N',

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        --x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type

        )
     IS

        l_api_version                   NUMBER;
        l_init_msg_list                 VARCHAR2(10);
        l_commit                        VARCHAR2(10);
        l_validation_level              NUMBER;

        l_work_object_id                NUMBER;
        l_work_object_type_id           NUMBER;
        l_exception_logging             VARCHAR2(10);

        l_return_status                 VARCHAR2(10);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(512);
        l_error_message                 VARCHAR2(512);
	l_wo_relationship_exc_tbl	EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;

     BEGIN

        l_api_version                   := p_api_version;
        l_init_msg_list                 := p_init_msg_list;
        l_commit                        := p_commit;
        l_validation_level              := p_validation_level;

        l_work_object_id                := p_work_object_id;
        l_work_object_type_id           := p_work_object_type_id;
        l_exception_logging             := p_exception_logging;

        EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
        (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        p_commit                        => l_commit,
        p_validation_level              => l_validation_level,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,
        p_exception_logging             => l_exception_logging,

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
	x_wo_relationship_exc_tbl	=> l_wo_relationship_exc_tbl

        --x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );

        x_return_status                 := l_return_status;
        x_msg_count                     := l_msg_count;
        x_msg_data                      := l_msg_data;

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;
          l_error_message := substrb(sqlerrm,1,512);
          x_msg_data      := l_error_message;

     END;




    PROCEDURE Snap_Right
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )
     IS

        l_api_version                   NUMBER;
        l_init_msg_list                 VARCHAR2(10);
        l_commit                        VARCHAR2(10);
        l_validation_level              NUMBER;

        l_work_object_id                NUMBER;
        l_work_object_type_id           NUMBER;

        l_return_status                 VARCHAR2(10);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(512);
        l_error_message                 VARCHAR2(512);

     BEGIN

        l_api_version                   := p_api_version;
        l_init_msg_list                 := p_init_msg_list;
        l_commit                        := p_commit;
        l_validation_level              := p_validation_level;

        l_work_object_id                := p_work_object_id;
        l_work_object_type_id           := p_work_object_type_id;

        EAM_WO_NETWORK_DEFAULT_PVT.Snap_Right
        (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        p_commit                        => l_commit,
        p_validation_level              => l_validation_level,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

        x_return_status                 := l_return_status;
        x_msg_count                     := l_msg_count;
        x_msg_data                      := l_msg_data;

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;
          l_error_message := substrb(sqlerrm,1,512);
          x_msg_data      := l_error_message;

     END;




PROCEDURE Snap_Left
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )
IS

        l_api_version                   NUMBER;
        l_init_msg_list                 VARCHAR2(10);
        l_commit                        VARCHAR2(10);
        l_validation_level              NUMBER;

        l_work_object_id                NUMBER;
        l_work_object_type_id           NUMBER;

        l_return_status                 VARCHAR2(10);
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(512);
        l_error_message                 VARCHAR2(512);

BEGIN

        l_api_version                   := p_api_version;
        l_init_msg_list                 := p_init_msg_list;
        l_commit                        := p_commit;
        l_validation_level              := p_validation_level;

        l_work_object_id                := p_work_object_id;
        l_work_object_type_id           := p_work_object_type_id;

        EAM_WO_NETWORK_DEFAULT_PVT.Snap_Left
        (
        p_api_version                   => l_api_version,
        p_init_msg_list                 => l_init_msg_list,
        p_commit                        => l_commit,
        p_validation_level              => l_validation_level,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data

        );

        x_return_status                 := l_return_status;
        x_msg_count                     := l_msg_count;
        x_msg_data                      := l_msg_data;

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status := fnd_api.g_ret_sts_error;
          l_error_message := substrb(sqlerrm,1,512);
          x_msg_data      := l_error_message;

END;




END WIP_EAM_PROCESS_WO_PUB;

/
