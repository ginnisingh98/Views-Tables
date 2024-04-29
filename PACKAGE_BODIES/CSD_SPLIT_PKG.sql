--------------------------------------------------------
--  DDL for Package Body CSD_SPLIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_SPLIT_PKG" as
/* $Header: csdspltb.pls 120.11.12010000.3 2008/11/06 07:34:15 subhat ship $ */
-- Start of Comments
-- Package name     : CSD_SPLIT_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_SPLIT_PKG';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'csdspltb.pls';

PROCEDURE Split_Repair_Order (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_split_option              IN              NUMBER,
    p_copy_attachment           IN              VARCHAR2,
    p_attachment_counts         IN              NUMBER,
    p_new_quantity              IN              NUMBER,
    p_repair_type_id            IN              NUMBER
)

IS
    l_api_name                  CONSTANT  VARCHAR2(30) := 'Split_Repair_Order' ;
    l_api_name_full             CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
    l_api_version               CONSTANT  NUMBER       := 1.0 ;
    l_rep_line_rec              CSD_REPAIRS_PUB.REPLN_REC_TYPE;
    l_original_rep_line_rec     CSD_REPAIRS_PUB.REPLN_REC_TYPE;
    l_total_original_quantity   NUMBER;
    l_org_new_quantity          NUMBER;
    l_repair_history_Rec        CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type;
    l_repair_history_id         NUMBER;
    l_repair_type_name          VARCHAR2(30);
    x_repair_line_id            NUMBER;
    l_original_repair_number    NUMBER;
    l_original_repair_type_id   NUMBER;

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

    -- swai: 12.1.1 bug 7176940 service bulletin check
    l_ro_sc_ids_tbl CSD_RO_BULLETINS_PVT.CSD_RO_SC_IDS_TBL_TYPE;
    l_return_status                 VARCHAR2 (1) ;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2 (2000);

    CURSOR c_repair_type_name(p_original_repair_line_id IN NUMBER) IS
    SELECT crtv.name
    from csd_repair_types_vl crtv, csd_repairs cr
    where cr.repair_line_id = p_original_repair_line_id and crtv.repair_type_id = cr.repair_type_id;

Begin

    IF(l_procedure_level >= l_debug_level) THEN
        FND_LOG.STRING(l_procedure_level,
                       'CSD.PLSQL.CSD_SPLIT_PKG.Split_Repair_Order',
                       'Entered Split_Repair_Order API');
    END IF;

    IF(l_statement_level >= l_debug_level) THEN
        FND_LOG.STRING(l_statement_level,
                       'CSD.PLSQL.CSD_SPLIT_PKG.Split_Repair_Order',
                       'Enabling the Split_Repair_Order savepoint');
    END IF;

    --  Standard Start of API Savepoint
    SAVEPOINT   CSD_SPLIT_PKG ;

    --  Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure


    Build_Repln_Record(
        p_repair_line_id    => p_original_repair_line_id,
        x_Repln_Rec         => l_rep_line_rec,
        x_return_status     => x_return_status
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF(l_statement_level >= l_debug_level) THEN
            FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Build_Repln_Record','failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_total_original_quantity := l_rep_line_rec.quantity;
    l_org_new_quantity := l_total_original_quantity - p_new_quantity;
    l_original_repair_number := l_rep_line_rec.repair_number;
    l_original_repair_type_id := l_rep_line_rec.repair_type_id;

    if (p_split_option = 1) then
        --Update the current RO quantity. call update_repair_order
        if (l_org_new_quantity = 0) then
            CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
                (
                 p_QUANTITY      => l_org_new_quantity,
                 p_STATUS        => 'C',
                 p_object_version_number => l_rep_line_rec.object_version_number,
                 x_repln_rec    => l_original_rep_line_rec
            );
        else
            CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
                (
                 p_QUANTITY      => l_org_new_quantity,
                 p_object_version_number => l_rep_line_rec.object_version_number,
                 x_repln_rec    => l_original_rep_line_rec
            );
        end if;

        CSD_REPAIRS_PVT.Update_Repair_Order
            (p_API_version_number => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            p_commit => FND_API.G_FALSE,
            p_validation_level => null,
            p_repair_line_id => p_original_repair_line_id,
            p_Repln_Rec => l_original_rep_line_rec,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIRS_PVT.Update_Repair_Order','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_rep_line_rec.repair_number := null;
        l_rep_line_rec.object_version_number := FND_API.G_MISS_NUM;
        l_rep_line_rec.quantity := p_new_quantity;
        l_rep_line_rec.repair_type_id := p_repair_type_id;

        Create_New_Repair_Order (
            p_api_version               => 1.0,
            p_init_msg_list             => p_init_msg_list,
            p_commit                    => FND_API.G_FALSE,
            p_validation_level          => null,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            x_repair_line_id            => x_repair_line_id,
            p_copy_attachment           => p_copy_attachment,
            p_original_repair_line_id   => p_original_repair_line_id,
            p_rep_line_rec              => l_rep_line_rec
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Create_New_Repair_Order','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_repair_history_Rec.repair_line_id := p_original_repair_line_id;
        l_repair_history_Rec.EVENT_CODE := 'SLT';
        l_repair_history_Rec.EVENT_DATE := sysdate;
        l_repair_history_Rec.paramn1    := l_total_original_quantity;

        CSD_REPAIR_HISTORY_PVT.Create_repair_history(
           P_Api_Version_Number    => p_api_version,
           P_Init_Msg_List         => p_init_msg_list,
           P_Commit                => FND_API.G_FALSE,
           p_validation_level      => p_validation_level,
           P_REPH_REC              => l_repair_history_Rec,
           X_REPAIR_HISTORY_ID     => l_repair_history_id,
           X_Return_Status         => x_return_status,
           X_Msg_Count             => x_msg_count,
           X_Msg_Data              => x_msg_data
           );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIR_HISTORY_PVT.Create_repair_history','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_repair_history_Rec.repair_line_id := x_repair_line_id;
        l_repair_history_Rec.EVENT_CODE := 'SLT';
        l_repair_history_Rec.EVENT_DATE := sysdate;
        l_repair_history_Rec.paramn1    := l_total_original_quantity;
        l_repair_history_Rec.paramc1    := l_original_repair_number;

        If (p_copy_attachment = 'Y') and (p_attachment_counts > 0) THEN
            l_repair_history_Rec.paramc2    := 'Y';
        elsif (p_attachment_counts > 0) THEN
            l_repair_history_Rec.paramc2    := 'N';
        end if;
        -- if previous repair type id is not the same as the new repair type id, display following info to activity tab.
        If (l_original_repair_type_id <> p_repair_type_id) then
            OPEN c_repair_type_name(p_original_repair_line_id);
            FETCH c_repair_type_name INTO
                l_repair_type_name;
            IF c_repair_type_name%isopen then
              CLOSE c_repair_type_name;
            END IF;
            l_repair_history_Rec.paramc3    := l_repair_type_name;
            l_repair_history_Rec.paramn2    := l_original_repair_type_id;
        end if;

        CSD_REPAIR_HISTORY_PVT.Create_repair_history(
           P_Api_Version_Number    => p_api_version,
           P_Init_Msg_List         => p_init_msg_list,
           P_Commit                => FND_API.G_FALSE,
           p_validation_level      => p_validation_level,
           P_REPH_REC              => l_repair_history_Rec,
           X_REPAIR_HISTORY_ID     => l_repair_history_id,
           X_Return_Status         => x_return_status,
           X_Msg_Count             => x_msg_count,
           X_Msg_Data              => x_msg_data
           );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIR_HISTORY_PVT.Create_repair_history','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
        IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
            CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
               p_api_version_number         => 1.0,
               p_init_msg_list              => Fnd_Api.G_FALSE,
               p_commit                     => Fnd_Api.G_FALSE,
               p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
               p_repair_line_id             => x_repair_line_id,
               px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data
            );
            -- ignore return status for now.
        END IF;

    elsif (p_split_option = 2) then

        if (l_total_original_quantity <= 1) then
        --need to display message.
            return;
        end if;

        --Update the current RO quantity.
        CSD_REPAIRS_UTIL.Convert_to_Repln_Rec_Type
            (
             p_QUANTITY      => 1,
             p_object_version_number => l_rep_line_rec.object_version_number,
             x_repln_rec    => l_original_rep_line_rec
        );

        CSD_REPAIRS_PVT.Update_Repair_Order
            (p_API_version_number => 1.0,
            p_init_msg_list => FND_API.G_TRUE,
            p_commit => FND_API.G_FALSE,
            p_validation_level => null,
            p_repair_line_id => p_original_repair_line_id,
            p_Repln_Rec => l_original_rep_line_rec,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIRS_PVT.Update_Repair_Order','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_rep_line_rec.repair_number := null;
        l_rep_line_rec.object_version_number := FND_API.G_MISS_NUM;
        for i in 1..(l_total_original_quantity-1) loop
            l_rep_line_rec.quantity := 1;

            Create_New_Repair_Order (
                p_api_version               => 1.0,
                p_init_msg_list             => p_init_msg_list,
                p_commit                    => FND_API.G_FALSE,
                p_validation_level          => null,
                x_return_status             => x_return_status,
                x_msg_count                 => x_msg_count,
                x_msg_data                  => x_msg_data,
                x_repair_line_id            => x_repair_line_id,
                p_copy_attachment           => p_copy_attachment,
                p_original_repair_line_id   => p_original_repair_line_id,
                p_rep_line_rec              => l_rep_line_rec
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF(l_statement_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Create_New_Repair_Order','failed');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_repair_history_Rec.repair_line_id := x_repair_line_id;
            l_repair_history_Rec.EVENT_CODE := 'SLT';
            l_repair_history_Rec.EVENT_DATE := sysdate;
            l_repair_history_Rec.paramn1    := l_total_original_quantity;
            If (p_attachment_counts > 0) THEN
                l_repair_history_Rec.paramc2    := 'Y';
            end if;
            l_repair_history_Rec.paramc1    := l_original_repair_number;
            CSD_REPAIR_HISTORY_PVT.Create_repair_history(
               P_Api_Version_Number    => p_api_version,
               P_Init_Msg_List         => p_init_msg_list,
               P_Commit                => FND_API.G_FALSE,
               p_validation_level      => p_validation_level,
               P_REPH_REC              => l_repair_history_Rec,
               X_REPAIR_HISTORY_ID     => l_repair_history_id,
               X_Return_Status         => x_return_status,
               X_Msg_Count             => x_msg_count,
               X_Msg_Data              => x_msg_data
               );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF(l_statement_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIR_HISTORY_PVT.Create_repair_history','failed');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;


        end loop;

        l_repair_history_Rec.repair_line_id := p_original_repair_line_id;
        l_repair_history_Rec.EVENT_CODE := 'SLT';
        l_repair_history_Rec.EVENT_DATE := sysdate;
        l_repair_history_Rec.paramn1    := l_total_original_quantity;
        l_repair_history_Rec.paramc2    := null;
        l_repair_history_Rec.paramc1    := null;

        CSD_REPAIR_HISTORY_PVT.Create_repair_history(
           P_Api_Version_Number    => p_api_version,
           P_Init_Msg_List         => p_init_msg_list,
           P_Commit                => FND_API.G_FALSE,
           p_validation_level      => p_validation_level,
           P_REPH_REC              => l_repair_history_Rec,
           X_REPAIR_HISTORY_ID     => l_repair_history_id,
           X_Return_Status         => x_return_status,
           X_Msg_Count             => x_msg_count,
           X_Msg_Data              => x_msg_data
           );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIR_HISTORY_PVT.Create_repair_history','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- swai: 12.1.1 bug 7176940 - check service bulletins after RO creation
        IF (nvl(fnd_profile.value('CSD_AUTO_CHECK_BULLETINS'),'N') = 'Y') THEN
            CSD_RO_BULLETINS_PVT.LINK_BULLETINS_TO_RO(
               p_api_version_number         => 1.0,
               p_init_msg_list              => Fnd_Api.G_FALSE,
               p_commit                     => Fnd_Api.G_FALSE,
               p_validation_level           => Fnd_Api.G_VALID_LEVEL_FULL,
               p_repair_line_id             => x_repair_line_id,
               px_ro_sc_ids_tbl             => l_ro_sc_ids_tbl,
               x_return_status              => l_return_status,
               x_msg_count                  => l_msg_count,
               x_msg_data                   => l_msg_data
            );
            -- ignore return status for now.
        END IF;
    end if;

    -- End of API body
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Split_Repair_Order',
                   'EXC_ERROR ['||x_msg_data||']');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Split_Repair_Order',
                   'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Split_Repair_Order',
                   'SQL Message ['||sqlerrm||']');
        END IF;

End Split_Repair_Order;

PROCEDURE Build_Repln_Record (
    p_repair_line_id    IN              NUMBER,
    x_Repln_Rec         OUT     NOCOPY  CSD_REPAIRS_PUB.Repln_Rec_Type,
    x_return_status     OUT     NOCOPY  VARCHAR2
)
IS

CURSOR c_repair_line_dtls(p_repair_line_id IN NUMBER) IS
SELECT
     repair_number
    ,incident_id
    ,inventory_item_id
    ,customer_product_id
    ,unit_of_measure
    ,repair_type_id
    ,resource_id
    ,instance_id
    ,project_id
    ,task_id
    ,unit_number
    ,contract_line_id
    ,quantity
    ,status
    ,approval_required_flag
    ,date_closed
    ,quantity_in_wip
    ,approval_status
    ,quantity_rcvd
    ,quantity_shipped
    ,serial_number
    ,promise_date
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,security_group_id
    ,order_line_id
    ,original_source_reference
    ,status_reason_code
    ,auto_process_rma
    ,repair_mode
    ,item_revision
    ,repair_group_id
    ,ro_txn_status
    ,currency_code
    ,default_po_num
    ,original_source_header_id
    ,original_source_line_id
    ,price_list_header_id
    ,problem_description -- swai: bug 4666344
    ,ro_priority_code    -- swai: R12
    ,resolve_by_date     -- rfieldma: 5355051
    ,object_version_number
    ,attribute16 --bug#7497907, 12.1 FP, subhat
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,attribute21
    ,attribute22
    ,attribute23
    ,attribute24
    ,attribute25
    ,attribute26
    ,attribute27
    ,attribute28
    ,attribute29
    ,attribute30
FROM csd_repairs
where repair_line_id = p_repair_line_id;

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

begin

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF(l_statement_level >= l_debug_level) THEN
        FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Build_Repln_Record','At the Begin in Build_Repln_Record');
    END IF;

    IF NVL(p_repair_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

        OPEN  c_repair_line_dtls(p_repair_line_id);
        FETCH c_repair_line_dtls INTO
             x_Repln_Rec.REPAIR_NUMBER
            ,x_Repln_Rec.INCIDENT_ID
            ,x_Repln_Rec.INVENTORY_ITEM_ID
            ,x_Repln_Rec.CUSTOMER_PRODUCT_ID
            ,x_Repln_Rec.UNIT_OF_MEASURE
            ,x_Repln_Rec.REPAIR_TYPE_ID
            ,x_Repln_Rec.RESOURCE_ID
            ,x_Repln_Rec.INSTANCE_ID
            ,x_Repln_Rec.PROJECT_ID
            ,x_Repln_Rec.TASK_ID
            ,x_Repln_Rec.UNIT_NUMBER
            ,x_Repln_Rec.CONTRACT_LINE_ID
            ,x_Repln_Rec.QUANTITY
            ,x_Repln_Rec.STATUS
            ,x_Repln_Rec.APPROVAL_REQUIRED_FLAG
            ,x_Repln_Rec.DATE_CLOSED
            ,x_Repln_Rec.QUANTITY_IN_WIP
            ,x_Repln_Rec.APPROVAL_STATUS
            ,x_Repln_Rec.QUANTITY_RCVD
            ,x_Repln_Rec.QUANTITY_SHIPPED
            ,x_Repln_Rec.SERIAL_NUMBER
            ,x_Repln_Rec.PROMISE_DATE
            ,x_Repln_Rec.ATTRIBUTE_CATEGORY
            ,x_Repln_Rec.ATTRIBUTE1
            ,x_Repln_Rec.ATTRIBUTE2
            ,x_Repln_Rec.ATTRIBUTE3
            ,x_Repln_Rec.ATTRIBUTE4
            ,x_Repln_Rec.ATTRIBUTE5
            ,x_Repln_Rec.ATTRIBUTE6
            ,x_Repln_Rec.ATTRIBUTE7
            ,x_Repln_Rec.ATTRIBUTE8
            ,x_Repln_Rec.ATTRIBUTE9
            ,x_Repln_Rec.ATTRIBUTE10
            ,x_Repln_Rec.ATTRIBUTE11
            ,x_Repln_Rec.ATTRIBUTE12
            ,x_Repln_Rec.ATTRIBUTE13
            ,x_Repln_Rec.ATTRIBUTE14
            ,x_Repln_Rec.ATTRIBUTE15
            ,x_Repln_Rec.REPAIR_GROUP_ID
            ,x_Repln_Rec.ORDER_LINE_ID
            ,x_Repln_Rec.ORIGINAL_SOURCE_REFERENCE
            ,x_Repln_Rec.STATUS_REASON_CODE
            ,x_Repln_Rec.AUTO_PROCESS_RMA
            ,x_Repln_Rec.REPAIR_MODE
            ,x_Repln_Rec.ITEM_REVISION
            ,x_Repln_Rec.REPAIR_GROUP_ID
            ,x_Repln_Rec.RO_TXN_STATUS
            ,x_Repln_Rec.CURRENCY_CODE
            ,x_Repln_Rec.DEFAULT_PO_NUM
            ,x_Repln_Rec.ORIGINAL_SOURCE_HEADER_ID
            ,x_Repln_Rec.ORIGINAL_SOURCE_LINE_ID
            ,x_Repln_Rec.PRICE_LIST_HEADER_ID
            ,x_Repln_Rec.PROBLEM_DESCRIPTION     -- swai: bug 4666344
            ,x_Repln_Rec.RO_PRIORITY_CODE        -- swai: R12
		        ,x_Repln_Rec.RESOLVE_BY_DATE         -- rfieldma: 5355051
            ,x_Repln_Rec.OBJECT_VERSION_NUMBER
            ,x_Repln_Rec.ATTRIBUTE16 --bug#7497907, 12.1 FP, subhat
            ,x_Repln_Rec.ATTRIBUTE17
            ,x_Repln_Rec.ATTRIBUTE18
            ,x_Repln_Rec.ATTRIBUTE19
            ,x_Repln_Rec.ATTRIBUTE20
            ,x_Repln_Rec.ATTRIBUTE21
            ,x_Repln_Rec.ATTRIBUTE22
            ,x_Repln_Rec.ATTRIBUTE23
            ,x_Repln_Rec.ATTRIBUTE24
            ,x_Repln_Rec.ATTRIBUTE25
            ,x_Repln_Rec.ATTRIBUTE26
            ,x_Repln_Rec.ATTRIBUTE27
            ,x_Repln_Rec.ATTRIBUTE28
            ,x_Repln_Rec.ATTRIBUTE29
            ,x_Repln_Rec.ATTRIBUTE30
            ;

        IF c_repair_line_dtls%notfound then
          FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
          FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF c_repair_line_dtls%isopen then
          CLOSE c_repair_line_dtls;
        END IF;

    END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO CSD_SPLIT_PKG;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO CSD_SPLIT_PKG;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        WHEN OTHERS THEN
            ROLLBACK TO CSD_SPLIT_PKG;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
End Build_Repln_Record;


PROCEDURE Build_Product_TXN_Record (
    p_product_txn_id    IN              NUMBER,
    x_product_txn_Rec   OUT     NOCOPY  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
    x_return_status     OUT     NOCOPY  VARCHAR2
)
IS

CURSOR c_product_txn_line_dtls(p_product_txn_id IN NUMBER) IS
SELECT
     estimate_detail_id
    ,action_type
    ,action_code
    ,interface_to_om_flag
    ,book_sales_order_flag
    ,release_sales_order_flag
    ,ship_sales_order_flag
    ,sub_inventory
    ,lot_number
    ,context
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,prod_txn_status
    ,prod_txn_code
    --,shipped_serial_number This column is not used in 11.5.10
    ,object_version_number
    ,req_header_id
    ,req_line_id
    ,order_header_id
    ,order_line_id
    ,quantity_received
    ,quantity_shipped
    ,source_serial_number
    ,source_instance_id
    ,non_source_serial_number
    ,non_source_instance_id
    ,locator_id
    ,sub_inventory_rcvd
    ,lot_number_rcvd
    ,picking_rule_id         -- Add for R12 pickrule id change.Vijay.
    ,project_id
    ,task_id
    ,unit_number
    ,internal_po_header_id  -- swai: bug 6148019
FROM csd_product_transactions
where product_transaction_id = p_product_txn_id;

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

begin

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NVL(p_product_txn_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
        OPEN  c_product_txn_line_dtls(p_product_txn_id);
        FETCH c_product_txn_line_dtls INTO
            x_product_txn_Rec.estimate_detail_id
            ,x_product_txn_Rec.action_type
            ,x_product_txn_Rec.action_code
            ,x_product_txn_Rec.interface_to_om_flag
            ,x_product_txn_Rec.book_sales_order_flag
            ,x_product_txn_Rec.release_sales_order_flag
            ,x_product_txn_Rec.ship_sales_order_flag
            ,x_product_txn_Rec.sub_inventory
            ,x_product_txn_Rec.lot_number
            ,x_product_txn_Rec.context
            ,x_product_txn_Rec.attribute1
            ,x_product_txn_Rec.attribute2
            ,x_product_txn_Rec.attribute3
            ,x_product_txn_Rec.attribute4
            ,x_product_txn_Rec.attribute5
            ,x_product_txn_Rec.attribute6
            ,x_product_txn_Rec.attribute7
            ,x_product_txn_Rec.attribute8
            ,x_product_txn_Rec.attribute9
            ,x_product_txn_Rec.attribute10
            ,x_product_txn_Rec.attribute11
            ,x_product_txn_Rec.attribute12
            ,x_product_txn_Rec.attribute13
            ,x_product_txn_Rec.attribute14
            ,x_product_txn_Rec.attribute15
            ,x_product_txn_Rec.prod_txn_status
            ,x_product_txn_Rec.prod_txn_code
            -- ,x_product_txn_Rec.shipped_serial_number this column is not used in 11.5.10
            ,x_product_txn_Rec.object_version_number
            ,x_product_txn_Rec.req_header_id
            ,x_product_txn_Rec.req_line_id
            ,x_product_txn_Rec.order_header_id
            ,x_product_txn_Rec.order_line_id
            ,x_product_txn_Rec.prd_txn_qty_received
            ,x_product_txn_Rec.prd_txn_qty_shipped
            ,x_product_txn_Rec.source_serial_number
            ,x_product_txn_Rec.source_instance_id
            ,x_product_txn_Rec.non_source_serial_number
            ,x_product_txn_Rec.non_source_instance_id
            ,x_product_txn_Rec.locator_id
            ,x_product_txn_Rec.sub_inventory_rcvd
            ,x_product_txn_Rec.lot_number_rcvd
            ,x_product_txn_Rec.picking_rule_id  -- Add for R12 pickrule id change.Vijay.
            ,x_product_txn_Rec.project_id
            ,x_product_txn_Rec.task_id
            ,x_product_txn_Rec.unit_number
            ,x_product_txn_Rec.internal_po_header_id  -- swai: bug 6148019
            ;

        IF c_product_txn_line_dtls%notfound then
          FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
          FND_MESSAGE.SET_TOKEN('p_product_txn_id',p_product_txn_id);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF c_product_txn_line_dtls%isopen then
          CLOSE c_product_txn_line_dtls;
        END IF;

    END IF;

-- Standard call to get message count and if count is 1, get message info.
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
End Build_Product_TXN_Record;


PROCEDURE Set_Error_Message (
    p_msg_code          IN              VARCHAR2,
    x_return_status     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2
)

IS

begin
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( fnd_api.g_true ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (p_msg_code is not null) ThEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CSD',p_msg_code);
        FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

End Set_Error_Message;


PROCEDURE Is_Split_Repair_Order_Allow (
    p_repair_line_id    IN      NUMBER,
    x_return_status     OUT     NOCOPY  VARCHAR2,
    x_msg_count         OUT     NOCOPY  NUMBER,
    x_msg_data          OUT     NOCOPY  VARCHAR2
)

IS
    l_api_name                      CONSTANT  VARCHAR2(30) := 'Is_Split_Repair_Order_Allow' ;
    l_repair_quantity               NUMBER;
    l_number_product_txn_lines      NUMBER;
    l_total_quantity_rcvd           NUMBER;
    l_total_quantity_in_wip         NUMBER;
    l_repair_mode                   VARCHAR2(10);
    l_repair_type_ref               VARCHAR2(10);
    l_wip_job_count                 NUMBER;

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

    CURSOR c_rma_product_txn_line_info(p_repair_line_id IN NUMBER) IS
    SELECT cptv.action_type, cptv.interface_to_om_flag, cptv.repair_quantity, cptv.quantity_in_wip, cptv.quantity_rcvd, cptv.status,
           cptv.serial_number_control_code, crtv.repair_type_ref, msiv.comms_nl_trackable_flag, crtv.repair_mode
    FROM csd_product_txns_v cptv, csd_repair_types_vl crtv, mtl_system_items_vl msiv
    WHERE repair_line_id = p_repair_line_id and crtv.repair_type_id = cptv.repair_type_id and action_type = 'RMA'
    and  msiv.inventory_item_id = cptv.inventory_item_id and msiv.organization_id = cs_std.get_item_valdn_orgzn_id;


    CURSOR c_ship_product_txn_line_info(p_repair_line_id IN NUMBER) IS
    SELECT interface_to_om_flag
    FROM csd_product_txns_v
    WHERE repair_line_id = p_repair_line_id and action_type = 'SHIP';

    CURSOR c_repair_type_ref(p_repair_line_id IN NUMBER) IS
    SELECT crtv.repair_type_ref
    FROM csd_repairs_v crv, csd_repair_types_vl crtv
    WHERE repair_line_id = p_repair_line_id and crv.repair_type_id = crtv.repair_type_id;

    CURSOR c_wip_job(p_repair_line_id IN NUMBER) IS
    SELECT count(*)
    FROM csd_repair_job_xref
    WHERE repair_line_id = p_repair_line_id;



begin
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_number_product_txn_lines := 0;
    l_total_quantity_rcvd := 0;
    l_total_quantity_in_wip := 0;
    l_repair_mode := null;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( fnd_api.g_true ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (p_repair_line_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_WITHOUT_RO_NUM');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        return;
    END IF;
--taklam
--    return;

    OPEN c_repair_type_ref(p_repair_line_id);
    FETCH c_repair_type_ref INTO l_repair_type_ref;
    IF c_repair_type_ref%isopen then
      CLOSE c_repair_type_ref;
    END IF;

    IF l_repair_type_ref not in ('SR', 'RR') then
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_INCORRECT_REF');
       FND_MSG_PUB.ADD;
       if (x_return_status <>  FND_API.G_RET_STS_SUCCESS) then
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
            return;
       end if;
    END IF;

    OPEN c_wip_job(p_repair_line_id);
    FETCH c_wip_job INTO l_wip_job_count;
    IF c_wip_job%isopen then
      CLOSE c_wip_job;
    END IF;

    FOR P in c_rma_product_txn_line_info(p_repair_line_id)
    loop
        l_number_product_txn_lines := l_number_product_txn_lines + 1;
        l_repair_mode := P.repair_mode;
        l_repair_quantity := P.repair_quantity;
        l_total_quantity_rcvd := l_total_quantity_rcvd + P.quantity_rcvd;
        l_total_quantity_in_wip := l_total_quantity_in_wip + P.quantity_in_wip;
        if P.status <> 'O' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_WRONG_STATUS');
            FND_MSG_PUB.ADD;
        elsif P.serial_number_control_code <> 1 then
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_PROD_SERIALIZED');
            FND_MSG_PUB.ADD;
        elsif P.repair_type_ref not in ('SR', 'RR') then
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_INCORRECT_REF');
            FND_MSG_PUB.ADD;
        elsif P.comms_nl_trackable_flag = 'Y' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_PROD_IB_TRBLE');
            FND_MSG_PUB.ADD;
        end if;
        if (x_return_status <>  FND_API.G_RET_STS_SUCCESS) then
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
            return;
        end if;
    end loop;

    IF c_rma_product_txn_line_info%isopen then
      CLOSE c_rma_product_txn_line_info;
    END IF;

    if (l_number_product_txn_lines < 1) then
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_NO_LOGISTIC_LINE');
        FND_MSG_PUB.ADD;
    elsif (l_repair_quantity > l_total_quantity_rcvd) then
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_ALL_QTYS_NOT_REC');
        FND_MSG_PUB.ADD;
    elsif ((l_repair_quantity > l_total_quantity_in_wip) and (l_repair_mode = 'WIP') and (l_wip_job_count > 0)) then
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_JOB_INCOMPLETED');
        FND_MSG_PUB.ADD;
    end if;

    if (x_return_status <>  FND_API.G_RET_STS_SUCCESS) then
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        return;
    end if;

    FOR S in c_ship_product_txn_line_info(p_repair_line_id)
    loop
        if S.interface_to_om_flag = 'Y' then
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('CSD','CSD_NOT_SPLIT_LINE_INTERFACED');
            FND_MSG_PUB.ADD;
        end if;
    end loop;
    IF c_ship_product_txn_line_info%isopen then
      CLOSE c_ship_product_txn_line_info;
    END IF;

    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Is_Split_Repair_Order_Allow',
                   'EXC_ERROR ['||x_msg_data||']');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Is_Split_Repair_Order_Allow',
                   'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Is_Split_Repair_Order_Allow',
                   'SQL Message ['||sqlerrm||']');
        END IF;

End Is_Split_Repair_Order_Allow;


PROCEDURE Create_New_Repair_Order (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    x_repair_line_id            OUT     NOCOPY  NUMBER,
    p_copy_attachment           IN              VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_rep_line_rec              IN              CSD_REPAIRS_PUB.REPLN_REC_TYPE
) IS

    l_api_name                  CONSTANT  VARCHAR2(30) := 'Create_New_Repair_Order' ;
    l_original_product_txn_rec  CSD_PROCESS_PVT.PRODUCT_TXN_REC;
    l_repair_line_id            NUMBER;
    l_repair_number             NUMBER;
    x_ship_prod_txn_tbl         CSD_PROCESS_PVT.PRODUCT_TXN_TBL;

    CURSOR c_rma_product_txns_id(p_original_repair_line_id IN NUMBER) IS
        SELECT product_transaction_id
        FROM csd_product_txns_v
        WHERE repair_line_id = p_original_repair_line_id and ACTION_TYPE = 'RMA';

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

Begin


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure

    CSD_REPAIRS_PVT.Create_Repair_Order
        (p_API_version_number => 1.0,
        p_init_msg_list => p_init_msg_list,
        p_commit => p_commit,
        p_validation_level => null,
        p_repair_line_id => null,
        p_Repln_Rec => p_rep_line_rec,
        x_repair_line_id => l_repair_line_id,
        x_repair_number => l_repair_number,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF(l_statement_level >= l_debug_level) THEN
            FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIRS_PVT.Create_Repair_Order','failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_repair_line_id := l_repair_line_id;

    FOR P in c_rma_product_txns_id(p_original_repair_line_id)

    loop

        Build_Product_TXN_Record (
            p_product_txn_id    =>  P.product_transaction_id,
            x_product_txn_Rec   =>  l_original_product_txn_rec,
            x_return_status     =>  x_return_status
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Build_Product_TXN_Record','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_original_product_txn_rec.PRODUCT_TRANSACTION_ID := FND_API.G_MISS_NUM;
        CSD_PRODUCT_TRANSACTIONS_PKG.INSERT_ROW
        (   px_PRODUCT_TRANSACTION_ID   => l_original_product_txn_rec.PRODUCT_TRANSACTION_ID,
            p_REPAIR_LINE_ID            => l_repair_line_id,
            p_ESTIMATE_DETAIL_ID        => l_original_product_txn_rec.estimate_detail_id,
            p_ACTION_TYPE               => l_original_product_txn_rec.ACTION_TYPE,
            p_ACTION_CODE               => l_original_product_txn_rec.ACTION_CODE,
            p_LOT_NUMBER                => l_original_product_txn_rec.LOT_NUMBER,
            p_SUB_INVENTORY             => l_original_product_txn_rec.SUB_INVENTORY,
            p_INTERFACE_TO_OM_FLAG      => l_original_product_txn_rec.INTERFACE_TO_OM_FLAG,
            p_BOOK_SALES_ORDER_FLAG     => l_original_product_txn_rec.BOOK_SALES_ORDER_FLAG,
            p_RELEASE_SALES_ORDER_FLAG  => l_original_product_txn_rec.RELEASE_SALES_ORDER_FLAG,
            p_SHIP_SALES_ORDER_FLAG     => l_original_product_txn_rec.SHIP_SALES_ORDER_FLAG ,
            p_PROD_TXN_STATUS           => l_original_product_txn_rec.PROD_TXN_STATUS,
            p_PROD_TXN_CODE             => l_original_product_txn_rec.PROD_TXN_CODE,
            p_LAST_UPDATE_DATE          => SYSDATE,
            p_CREATION_DATE             => SYSDATE,
            p_LAST_UPDATED_BY           => FND_GLOBAL.USER_ID,
            p_CREATED_BY                => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_LOGIN         => FND_GLOBAL.USER_ID,
            p_ATTRIBUTE1                => l_original_product_txn_rec.ATTRIBUTE1,
            p_ATTRIBUTE2                => l_original_product_txn_rec.ATTRIBUTE2,
            p_ATTRIBUTE3                => l_original_product_txn_rec.ATTRIBUTE3,
            p_ATTRIBUTE4                => l_original_product_txn_rec.ATTRIBUTE4,
            p_ATTRIBUTE5                => l_original_product_txn_rec.ATTRIBUTE5,
            p_ATTRIBUTE6                => l_original_product_txn_rec.ATTRIBUTE6,
            p_ATTRIBUTE7                => l_original_product_txn_rec.ATTRIBUTE7,
            p_ATTRIBUTE8                => l_original_product_txn_rec.ATTRIBUTE8,
            p_ATTRIBUTE9                => l_original_product_txn_rec.ATTRIBUTE9,
            p_ATTRIBUTE10               => l_original_product_txn_rec.ATTRIBUTE10,
            p_ATTRIBUTE11               => l_original_product_txn_rec.ATTRIBUTE11,
            p_ATTRIBUTE12               => l_original_product_txn_rec.ATTRIBUTE12,
            p_ATTRIBUTE13               => l_original_product_txn_rec.ATTRIBUTE13,
            p_ATTRIBUTE14               => l_original_product_txn_rec.ATTRIBUTE14,
            p_ATTRIBUTE15               => l_original_product_txn_rec.ATTRIBUTE15,
            p_CONTEXT                   => l_original_product_txn_rec.CONTEXT    ,
            p_OBJECT_VERSION_NUMBER     => 1,
       --   p_SHIPPED_SERIAL_NUMBER     => l_original_product_txn_rec.SHIPPED_SERIAL_NUMBER
            p_Req_Header_Id             => l_original_product_txn_rec.Req_Header_Id,
            p_Req_Line_Id               => l_original_product_txn_rec.Req_Line_Id,
            p_Order_Header_Id           => l_original_product_txn_rec.Order_Header_Id,
            p_Order_Line_Id             => l_original_product_txn_rec.Order_Line_Id,
            p_Prd_txn_Qty_Received      => l_original_product_txn_rec.Prd_Txn_Qty_Received,
            p_Prd_Txn_Qty_Shipped       => l_original_product_txn_rec.Prd_Txn_Qty_Shipped,
            p_Source_Serial_Number      => l_original_product_txn_rec.Source_Serial_Number,
            p_Source_Instance_Id        => l_original_product_txn_rec.Source_Instance_Id,
            p_Non_Source_Serial_Number  => l_original_product_txn_rec.Non_Source_Serial_Number,
            p_Non_Source_Instance_Id    => l_original_product_txn_rec.Non_Source_Instance_Id,
            p_Locator_Id                => l_original_product_txn_rec.Locator_Id,
            p_Sub_Inventory_Rcvd        => l_original_product_txn_rec.Sub_Inventory_Rcvd,
            p_Lot_Number_Rcvd           => l_original_product_txn_rec.Lot_Number_Rcvd,
            p_picking_rule_id           => l_original_product_txn_rec.picking_rule_id,  -- Add for R12 pickrule id change.Vijay.
            p_project_id                => l_original_product_txn_rec.project_id,
            p_task_id                   => l_original_product_txn_rec.task_id,
            p_unit_number               => l_original_product_txn_rec.unit_number,
            p_internal_po_header_id     => l_original_product_txn_rec.internal_po_header_id -- swai: bug 6148019
        );
    end loop;

    IF c_rma_product_txns_id%isopen then
      CLOSE c_rma_product_txns_id;
    END IF;


    Build_Ship_Prod_Txn_Tbl
    ( p_repair_line_id     => l_repair_line_id,
      x_prod_txn_tbl       => x_ship_prod_txn_tbl,
      x_return_status      => x_return_status );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF(l_statement_level >= l_debug_level) THEN
            FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Build_Ship_Prod_Txn_Tbl','failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF x_ship_prod_txn_tbl.COUNT > 0 THEN
        FOR i IN x_ship_prod_txn_tbl.first..x_ship_prod_txn_tbl.last
        LOOP

            CSD_PROCESS_PVT.CREATE_PRODUCT_TXN
                (p_api_version           =>  1.0 ,
                p_commit                =>  fnd_api.g_false,
                p_init_msg_list         =>  'F',
                p_validation_level      =>  fnd_api.g_valid_level_full,
                x_product_txn_rec       =>  x_ship_prod_txn_tbl(i),
                x_return_status         =>  x_return_status,
                x_msg_count             =>  x_msg_count,
                x_msg_data              =>  x_msg_data  );

            IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                IF(l_statement_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_PROCESS_UTIL.CREATE_PRODUCT_TXN','failed');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END LOOP;
    END IF;

    Copy_Repair_History (
        p_api_version               =>  1.0,
        p_init_msg_list             =>  p_init_msg_list,
        p_commit                    =>  p_commit,
        p_validation_level          =>  p_validation_level,
        x_return_status             =>  x_return_status,
        x_msg_count                 =>  x_msg_count,
        x_msg_data                  =>  x_msg_data,
        p_original_repair_line_id   =>  p_original_repair_line_id,
        p_new_repair_line_id        =>  l_repair_line_id);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF(l_statement_level >= l_debug_level) THEN
            FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Copy_Repair_History','failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    Copy_JTF_Notes (
        p_api_version               =>  1.0,
        p_init_msg_list             =>  p_init_msg_list,
        p_commit                    =>  p_commit,
        p_validation_level          =>  p_validation_level,
        x_return_status             =>  x_return_status,
        x_msg_count                 =>  x_msg_count,
        x_msg_data                  =>  x_msg_data,
        p_original_repair_line_id   =>  p_original_repair_line_id,
        p_new_repair_line_id        =>  l_repair_line_id);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF(l_statement_level >= l_debug_level) THEN
            FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Copy_JTF_Notes','failed');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

        If (p_copy_attachment = 'Y') THEN
            CSD_REPAIRS_PVT.Copy_Attachments
             ( p_api_version       =>   1.0,
               p_commit            =>   p_commit,
               p_init_msg_list     =>   p_init_msg_list,
               p_validation_level  =>   p_validation_level,
               p_original_ro_id    =>   p_original_repair_line_id,
               p_new_ro_id         =>   l_repair_line_id,
               x_return_status     =>   x_return_status,
               x_msg_count         =>   x_msg_count,
               x_msg_data          =>   x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                IF(l_statement_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIRS_PVT.Copy_Attachments','failed');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END if;

    -- End of API body
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Create_New_Repair_Order',
                   'EXC_ERROR ['||x_msg_data||']');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Create_New_Repair_Order',
                   'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Create_New_Repair_Order',
                   'SQL Message ['||sqlerrm||']');
        END IF;

End Create_New_Repair_Order;


PROCEDURE Copy_Repair_History (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_new_repair_line_id        IN              NUMBER
) IS


    l_api_name                  CONSTANT  VARCHAR2(30) := 'Copy_Repair_History' ;
    l_repair_history_rec        CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type;
    l_repair_history_id         NUMBER;
    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

    CURSOR c_repair_history_id (p_original_repair_line_id IN NUMBER) IS
        SELECT repair_history_id
        FROM CSD_REPAIR_HISTORY
        WHERE repair_line_id = p_original_repair_line_id;

Begin


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure


    FOR C in c_repair_history_id(p_original_repair_line_id)
    loop

        Build_Repair_History_Record (
            p_original_repair_history_id    =>  C.repair_history_id,
            x_repair_history_Rec            =>  l_repair_history_rec,
            x_return_status                 =>  x_return_status
            );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_SPLIT_PKG.Build_Repair_History_Record','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


        l_repair_history_rec.repair_line_id := p_new_repair_line_id;

        CSD_REPAIR_HISTORY_PVT.Create_repair_history(
           P_Api_Version_Number    => p_api_version,
           P_Init_Msg_List         => p_init_msg_list,
           P_Commit                => p_commit,
           p_validation_level      => p_validation_level,
           P_reph_rec              => l_repair_history_rec,
           X_REPAIR_HISTORY_ID     => l_repair_history_id,
           X_Return_Status         => x_return_status,
           X_Msg_Count             => x_msg_count,
           X_Msg_Data              => x_msg_data
           );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.CSD_REPAIR_HISTORY_PVT.Create_repair_history','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end loop;
    IF c_repair_history_id%isopen then
      CLOSE c_repair_history_id;
    END IF;


    -- End of API body
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_Repair_History',
                   'EXC_ERROR ['||x_msg_data||']');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_Repair_History',
                   'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_Repair_History',
                   'SQL Message ['||sqlerrm||']');
        END IF;

End Copy_Repair_History;


PROCEDURE Build_Repair_History_Record (
    p_original_repair_history_id    IN              NUMBER,
    x_repair_history_Rec            OUT     NOCOPY  CSD_REPAIR_HISTORY_PVT.REPH_Rec_Type,
    x_return_status                 OUT     NOCOPY  VARCHAR2
) IS

CURSOR c_repair_history_record(p_original_repair_history_id IN NUMBER) IS
    SELECT request_id, program_id, program_application_id, program_update_date, event_code, event_date, quantity
    ,paramn1, paramn2, paramn3, paramn4, paramn5, paramn6, paramn7, paramn8, paramn9, paramn10
    , paramc1, paramc2, paramc3, paramc4, paramc5, paramc6, paramc7, paramc8, paramc9, paramc10
    , paramd1, paramd2, paramd3, paramd4, paramd5, paramd6, paramd7, paramd8, paramd9, paramd10
    , attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5, attribute6
    , attribute7, attribute8, attribute9, attribute10, attribute11, attribute12, attribute13, attribute14, attribute15
    FROM csd_repair_history
    WHERE repair_history_id = p_original_repair_history_id;

    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

begin

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_repair_history_record(p_original_repair_history_id);
    FETCH c_repair_history_record INTO
        x_repair_history_Rec.request_id, x_repair_history_Rec.program_id, x_repair_history_Rec.program_application_id,
        x_repair_history_Rec.program_update_date, x_repair_history_Rec.event_code, x_repair_history_Rec.event_date,
        x_repair_history_Rec.quantity,x_repair_history_Rec.paramn1, x_repair_history_Rec.paramn2, x_repair_history_Rec.paramn3,
        x_repair_history_Rec.paramn4, x_repair_history_Rec.paramn5, x_repair_history_Rec.paramn6, x_repair_history_Rec.paramn7,
        x_repair_history_Rec.paramn8, x_repair_history_Rec.paramn9, x_repair_history_Rec.paramn10, x_repair_history_Rec.paramc1,
        x_repair_history_Rec.paramc2, x_repair_history_Rec.paramc3, x_repair_history_Rec.paramc4, x_repair_history_Rec.paramc5,
        x_repair_history_Rec.paramc6, x_repair_history_Rec.paramc7, x_repair_history_Rec.paramc8, x_repair_history_Rec.paramc9,
        x_repair_history_Rec.paramc10, x_repair_history_Rec.paramd1, x_repair_history_Rec.paramd2, x_repair_history_Rec.paramd3,
        x_repair_history_Rec.paramd4, x_repair_history_Rec.paramd5, x_repair_history_Rec.paramd6, x_repair_history_Rec.paramd7,
        x_repair_history_Rec.paramd8, x_repair_history_Rec.paramd9, x_repair_history_Rec.paramd10, x_repair_history_Rec.attribute_category,
        x_repair_history_Rec.attribute1, x_repair_history_Rec.attribute2, x_repair_history_Rec.attribute3, x_repair_history_Rec.attribute4,
        x_repair_history_Rec.attribute5, x_repair_history_Rec.attribute6, x_repair_history_Rec.attribute7, x_repair_history_Rec.attribute8,
        x_repair_history_Rec.attribute9, x_repair_history_Rec.attribute10, x_repair_history_Rec.attribute11, x_repair_history_Rec.attribute12,
        x_repair_history_Rec.attribute13, x_repair_history_Rec.attribute14, x_repair_history_Rec.attribute15;

    IF c_repair_history_record%notfound then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
      FND_MESSAGE.SET_TOKEN('p_original_repair_history_id',p_original_repair_history_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF c_repair_history_record%isopen then
        CLOSE c_repair_history_record;
    END IF;

    x_repair_history_Rec.CREATED_BY := FND_GLOBAL.USER_ID;
    x_repair_history_Rec.CREATION_DATE := sysdate;
    x_repair_history_Rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    x_repair_history_Rec.LAST_UPDATE_DATE := sysdate;
    x_repair_history_Rec.LAST_UPDATE_LOGIN := FND_GLOBAL.USER_ID;

END Build_Repair_History_Record;


PROCEDURE Copy_JTF_Notes (
    p_api_version               IN              NUMBER,
    p_init_msg_list             IN              VARCHAR2,
    p_commit                    IN              VARCHAR2,
    p_validation_level          IN              NUMBER,
    x_return_status             OUT     NOCOPY  VARCHAR2,
    x_msg_count                 OUT     NOCOPY  NUMBER,
    x_msg_data                  OUT     NOCOPY  VARCHAR2,
    p_original_repair_line_id   IN              NUMBER,
    p_new_repair_line_id        IN              NUMBER
) IS

    l_api_name                  CONSTANT  VARCHAR2(30) := 'Copy_JTF_Notes' ;
    l_jtf_note_contexts_tab     JTF_NOTES_PUB.jtf_note_contexts_tbl_type;
    l_jtf_note_id               NUMBER;
    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;


CURSOR c_jtf_note_id (p_original_repair_line_id IN NUMBER) IS
    SELECT notes, note_status, note_type, entered_by, entered_date, creation_date, created_by,
    last_update_date, last_updated_by, last_update_login,
    ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
    ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
    ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, CONTEXT
    FROM jtf_notes_vl
    WHERE source_object_id = p_original_repair_line_id and source_object_code = 'DR';

Begin


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure

    FOR C in c_jtf_note_id(p_original_repair_line_id)
    loop

        JTF_NOTES_PUB.create_note
          ( p_api_version           => 1.0
          , p_init_msg_list         => 'F'
          , p_commit                => p_commit
          , p_validation_level      => 0
          , x_return_status         => x_return_status
          , x_msg_count             => x_msg_count
          , x_msg_data              => x_msg_data
          , p_source_object_code    => 'DR'
          , p_source_object_id      => p_new_repair_line_id
          , p_notes                 => C.notes
          , p_note_status           => C.note_status
          , p_note_type             => C.note_type
          , p_entered_by            => C.entered_by
          , p_entered_date          => C.entered_date
          , x_jtf_note_id           => l_jtf_note_id
          , p_creation_date         => C.creation_date
          , p_created_by            => C.created_by
          , p_last_update_date      => C.last_update_date
          , p_last_updated_by       => C.last_updated_by
          , p_last_update_login     => C.last_update_login
          , p_attribute1            => C.ATTRIBUTE1
          , p_attribute2            => C.ATTRIBUTE2
          , p_attribute3            => C.ATTRIBUTE3
          , p_attribute4            => C.ATTRIBUTE4
          , p_attribute5            => C.ATTRIBUTE5
          , p_attribute6            => C.ATTRIBUTE6
          , p_attribute7            => C.ATTRIBUTE7
          , p_attribute8            => C.ATTRIBUTE8
          , p_attribute9            => C.ATTRIBUTE9
          , p_attribute10           => C.ATTRIBUTE10
          , p_attribute11           => C.ATTRIBUTE11
          , p_attribute12           => C.ATTRIBUTE12
          , p_attribute13           => C.ATTRIBUTE13
          , p_attribute14           => C.ATTRIBUTE14
          , p_attribute15           => C.ATTRIBUTE15
          , p_context               => C.CONTEXT
          , p_jtf_note_contexts_tab => l_jtf_note_contexts_tab
          );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF(l_statement_level >= l_debug_level) THEN
                FND_LOG.STRING(l_statement_level,'CSD.PLSQL.JTF_NOTES_PUB.create_note','failed');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end loop;
    IF c_jtf_note_id%isopen then
      CLOSE c_jtf_note_id;
    END IF;


    -- End of API body
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_JTF_Notes',
                   'EXC_ERROR ['||x_msg_data||']');
        END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_JTF_Notes',
                   'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CSD_SPLIT_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
        IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                   'CSD.PLSQL.CSD_SPLIT_PKG.Copy_JTF_Notes',
                   'SQL Message ['||sqlerrm||']');
        END IF;
End Copy_JTF_Notes;


PROCEDURE build_ship_prod_txn_tbl
( p_repair_line_id      IN     NUMBER,
  x_prod_txn_tbl        OUT     NOCOPY CSD_PROCESS_PVT.PRODUCT_TXN_TBL,
  x_return_status       OUT     NOCOPY VARCHAR2
) IS

    l_repair_type_ref          VARCHAR2(3) := '';
    l_auto_process_rma         VARCHAR2(1) := '';
    l_inv_item_id              NUMBER  := NULL;
    l_inv_revision             VARCHAR2(3)  := '';
    l_contract_id              NUMBER  := NULL;
    l_unit_of_measure          VARCHAR2(30) := '';
    l_quantity                 NUMBER  := NULL;
    l_serial_number            VARCHAR2(30) := '';
    l_instance_id              NUMBER  := NULL;
    l_price_list_id            NUMBER  := NULL;
    l_return_reason            VARCHAR2(30) := '';
    l_org_id                   NUMBER  := NULL;
    l_incident_id              NUMBER  := NULL;
    l_inv_org_id            NUMBER := NULL;
    l_revision                 VARCHAR2(30) := '';
    l_bus_process_id           NUMBER  := NULL;
    l_price_list_header_id     NUMBER  := NULL;
    l_cps_txn_billing_type_id  NUMBER := NULL;
    l_cpr_txn_billing_type_id  NUMBER := NULL;
    l_ls_txn_billing_type_id   NUMBER := NULL;
    l_lr_txn_billing_type_id   NUMBER := NULL;
    l_debug_level       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_procedure_level   NUMBER := FND_LOG.LEVEL_PROCEDURE;
    l_statement_level   NUMBER := FND_LOG.LEVEL_STATEMENT;
    l_event_level       NUMBER := FND_LOG.LEVEL_EVENT;

   l_po_number                 VARCHAR2(50);  -- swai bug fix 4535829
   l_project_id              NUMBER := null;
   l_task_id                 NUMBER := null;
   l_unit_number             VARCHAR2(30) :='';

    CURSOR repair_line_dtls(p_rep_line_id IN NUMBER) IS
    SELECT
        crt.repair_type_ref,
        cr.auto_process_rma,
        cr.inventory_item_id,
        cr.item_revision,
        cr.contract_line_id,
        cr.unit_of_measure,
        cr.quantity,
        cr.customer_product_id,
        cr.serial_number,
        crt.cps_txn_billing_type_id ,
        crt.cpr_txn_billing_type_id ,
        crt.ls_txn_billing_type_id  ,
        crt.lr_txn_billing_type_id  ,
        crt.price_list_header_id    ,
        crt.business_process_id,
        cr.incident_id,
        cr.default_po_num,
        cr.inventory_org_id,
        cr.project_id,
        cr.task_id,
        cr.unit_number
    FROM csd_repairs cr,
        csd_repair_types_vl crt
    WHERE cr.repair_type_id = crt.repair_type_id
    and   cr.repair_line_id = p_rep_line_id;

    CURSOR get_revision(p_inv_item_id IN NUMBER,
                  p_org_id      IN NUMBER) IS
    SELECT
        revision
    FROM mtl_item_revisions
    WHERE inventory_item_id  = p_inv_item_id
        and  organization_id    = p_org_id;

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

--taklam
--    return;

    -- Initialize the table
    x_prod_txn_tbl.delete;


    OPEN  repair_line_dtls(p_repair_line_id);

    FETCH repair_line_dtls INTO
       l_repair_type_ref,
       l_auto_process_rma,
       l_inv_item_id,
       l_inv_revision,
       l_contract_id,
       l_unit_of_measure,
       l_quantity,
       l_instance_id,
       l_serial_number,
       l_cps_txn_billing_type_id,
       l_cpr_txn_billing_type_id,
       l_ls_txn_billing_type_id,
       l_lr_txn_billing_type_id,
       l_price_list_header_id,
       l_bus_process_id,
       l_incident_id,
       l_po_number,  -- swai bug fix 4535829
	    l_inv_org_id, -- inv_org_change vijay, 3/20/06
       l_project_id,
       l_task_id,
       l_unit_number;

    IF repair_line_dtls%notfound then
      FND_MESSAGE.SET_NAME('CSD','CSD_API_INV_REP_LINE_ID');
      FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF repair_line_dtls%isopen then
      CLOSE repair_line_dtls;
    END IF;

    -- Get the price_list
    l_price_list_id := NVL(l_price_list_header_id,FND_PROFILE.value('CS_CHARGE_DEFAULT_PRICE_LIST'));

    -- Get the return reason
    l_return_reason := FND_PROFILE.value('CSD_DEF_RMA_RETURN_REASON');

    l_org_id := csd_process_util.get_org_id(l_incident_id);
--    l_inv_org_id := csd_process_util.get_inv_org_id;
    l_revision := l_inv_revision;

    IF l_repair_type_ref = 'RR' THEN
        -- Shipping customer product txn line
        x_prod_txn_tbl(1).repair_line_id              := p_repair_line_id  ;
        x_prod_txn_tbl(1).txn_billing_type_id         := l_cps_txn_billing_type_id;
        x_prod_txn_tbl(1).action_code                 := 'CUST_PROD';
        x_prod_txn_tbl(1).source_instance_id          := l_instance_id;
        x_prod_txn_tbl(1).source_serial_number        :=  l_serial_number;
        x_prod_txn_tbl(1).action_type                 := 'SHIP'           ;
        x_prod_txn_tbl(1).organization_id             := l_org_id          ;
        x_prod_txn_tbl(1).business_process_id         := l_bus_process_id ;
        x_prod_txn_tbl(1).inventory_item_id           := l_inv_item_id     ;
        x_prod_txn_tbl(1).unit_of_measure_code        := l_unit_of_measure ;
        x_prod_txn_tbl(1).quantity                    := l_quantity        ;
        x_prod_txn_tbl(1).lot_number                  := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(1).price_list_id               := l_price_list_id   ;
--        x_prod_txn_tbl(1).contract_id                 := l_contract_id     ;
        x_prod_txn_tbl(1).sub_inventory               := FND_API.G_MISS_CHAR;
        x_prod_txn_tbl(1).no_charge_flag              := csd_process_util.get_no_chg_flag(l_cps_txn_billing_type_id);
        x_prod_txn_tbl(1).interface_to_om_flag        := 'N'               ;
        x_prod_txn_tbl(1).book_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(1).release_sales_order_flag    := 'N'               ;
        x_prod_txn_tbl(1).ship_sales_order_flag       := 'N'               ;
        x_prod_txn_tbl(1).process_txn_flag            := 'N'               ;
        x_prod_txn_tbl(1).revision                    := l_revision       ;
        x_prod_txn_tbl(1).last_update_date            := sysdate          ;
        x_prod_txn_tbl(1).creation_date               := sysdate          ;
        x_prod_txn_tbl(1).last_updated_by             := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(1).created_by                  := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(1).last_update_login           := FND_GLOBAL.USER_ID;
        x_prod_txn_tbl(1).prod_txn_status             := 'ENTERED';
        x_prod_txn_tbl(1).prod_txn_code               := 'POST';
        x_prod_txn_tbl(1).project_id                  := l_project_id;
        x_prod_txn_tbl(1).task_id                     := l_task_id;
        x_prod_txn_tbl(1).unit_number                 := l_unit_number;
        x_prod_txn_tbl(1).inventory_org_id            := l_inv_org_id;
        x_prod_txn_tbl(1).po_number                   := l_po_number; -- swai bug fix 4535829

    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END build_ship_prod_txn_tbl;


End CSD_SPLIT_PKG;


/
