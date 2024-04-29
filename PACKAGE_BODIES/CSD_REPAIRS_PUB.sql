--------------------------------------------------------
--  DDL for Package Body CSD_REPAIRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIRS_PUB" as
    /* $Header: csdpdrab.pls 120.12.12010000.3 2008/12/18 18:45:52 swai ship $ */
    /*#
    * This is the public interface for the Depot Repair API.  It allows
    * execution of various Depot Repair APIs.
    * @rep:scope public
    * @rep:product CSD
    * @rep:displayname Depot Repair APIs
    * @rep:lifecycle active
    * @rep:category BUSINESS_ENTITY CSD_REPAIR_ORDER
    */
    --
    -- Package name     : CSD_REPAIRS_PUB
    -- Purpose          : This package contains the public APIs for creating
    --                    and updating repair orders.
    -- History          :
    -- Version       Date       Name        Description
    -- 115.0         11/17/99   pkdas       Created.
    -- 115.1         12/18/99   pkdas
    -- 115.2         01/04/00   pkdas
    -- 115.3         02/09/00   pkdas       Added p_REPAIR_LINE_ID as IN parameter in the
    --                                      Create_Repairs procedure.
    --                                      Added p_REPAIR_NUMBER as OUT parameter in the
    --                                      Create_Repairs procedure.
    -- 115.4         02/29/00   pkdas       Changed the procedure name
    --                                      Create_Repairs -> Create_Repair_Order
    --                                      Update_Repairs -> Update_Repair_Order
    --                                      Added p_validation_level to Create_Repair_Order and
    --                                      Update_Repair_Order
    --
    -- NOTE             :
    --
    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIRS_PUB';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdpdrab.pls';
    g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
    --
    /*#
    * Create Repair Order
    * @param P_Api_Version_Number api version number
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param p_validation_level validation level, default to full level
    * @param p_repair_line_id repair line id is unique id
    * @param P_REPLN_Rec repiar line record
    * @param p_create_default_logistics flag to create logistics lines, default to N
    * @param X_REPAIR_LINE_ID repair line id of the created repair order
    * @param X_REPAIR_NUMBER repair number of the created repair order which display on Depot UI
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Repair Order
    */
    PROCEDURE Create_Repair_Order(P_Api_Version_Number IN NUMBER,
                                  P_Init_Msg_List      IN VARCHAR2 := FND_API.G_FALSE,
                                  P_Commit             IN VARCHAR2 := FND_API.G_FALSE,
                                  p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                  P_REPAIR_LINE_ID     IN NUMBER := FND_API.G_MISS_NUM,
                                  P_REPLN_Rec          IN CSD_REPAIRS_PUB.REPLN_Rec_Type,
                                  p_create_default_logistics   IN VARCHAR2 := 'N',
                                  X_REPAIR_LINE_ID     OUT NOCOPY NUMBER,
                                  X_REPAIR_NUMBER      OUT NOCOPY VARCHAR2,
                                  X_Return_Status      OUT NOCOPY VARCHAR2,
                                  X_Msg_Count          OUT NOCOPY NUMBER,
                                  X_Msg_Data           OUT NOCOPY VARCHAR2) IS
        --
        l_api_name           CONSTANT VARCHAR2(30) := 'Create_Repair_Order';
        l_api_version_number CONSTANT NUMBER := 1.0;
        --

        -- swai: 12.1.1 bug 7176940 service bulletin check
        l_ro_sc_ids_tbl CSD_RO_BULLETINS_PVT.CSD_RO_SC_IDS_TBL_TYPE;
        l_return_status                 VARCHAR2 (1) ;
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2 (2000);
    BEGIN
        --
        -- Standard Start of API savepoint
        SAVEPOINT CREATE_REPAIR_ORDER_PUB;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        CSD_REPAIRS_PVT.Create_Repair_Order(P_Api_Version_Number => 1.0,
                                            P_Init_Msg_List      => p_init_msg_list,
                                            P_Commit             => p_commit,
                                            P_Validation_Level   => p_validation_level,
                                            P_REPAIR_LINE_ID     => p_REPAIR_LINE_ID,
                                            P_REPLN_Rec          => p_REPLN_Rec,
                                            X_REPAIR_LINE_ID     => x_REPAIR_LINE_ID,
                                            X_REPAIR_NUMBER      => x_REPAIR_NUMBER,
                                            X_Return_Status      => x_return_status,
                                            X_Msg_Count          => x_msg_count,
                                            X_Msg_Data           => x_msg_data);
        --
        -- Check return status from the above procedure call
        IF not (x_return_status = FND_API.G_RET_STS_SUCCESS)
        then
            ROLLBACK TO CREATE_REPAIR_ORDER_PUB;
            return;
        END IF;

        IF (P_CREATE_DEFAULT_LOGISTICS = 'Y') THEN

           CSD_LOGISTICS_PVT.Create_Default_Logistics
           (     p_api_version        =>    P_Api_Version_Number,
                 p_commit             =>    P_Commit,
                 p_init_msg_list      =>    P_Init_Msg_List,
                 p_validation_level   =>    p_validation_level,
                 p_repair_line_id     =>    X_REPAIR_LINE_ID, -- swai: bug 7654143
                 x_return_status      =>    X_Return_Status,
                 x_msg_count          =>    X_Msg_Count,
                 x_msg_data           =>    X_Msg_Data
           );

           IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

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

        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
        --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
        --
        WHEN OTHERS THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
        --
    End Create_Repair_Order;

    PROCEDURE Update_Repair_Order(P_Api_Version_Number IN NUMBER,
                                  P_Init_Msg_List      IN VARCHAR2 := FND_API.G_FALSE,
                                  P_Commit             IN VARCHAR2 := FND_API.G_FALSE,
                                  p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                  p_REPAIR_LINE_ID     IN NUMBER,
                                  P_REPLN_Rec          IN OUT NOCOPY CSD_REPAIRS_PUB.REPLN_Rec_Type,
                                  X_Return_Status      OUT NOCOPY VARCHAR2,
                                  X_Msg_Count          OUT NOCOPY NUMBER,
                                  X_Msg_Data           OUT NOCOPY VARCHAR2) IS
        --
        l_api_name           CONSTANT VARCHAR2(30) := 'Update_Repair_Order';
        l_api_version_number CONSTANT NUMBER := 1.0;
        --
    BEGIN
        --
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_REPAIR_ORDER_PUB;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        CSD_repairs_PVT.Update_Repair_Order(P_Api_Version_Number => 1.0,
                                            P_Init_Msg_List      => p_init_msg_list,
                                            P_Commit             => p_commit,
                                            P_Validation_Level   => p_validation_level,
                                            p_REPAIR_LINE_ID     => p_repair_line_id,
                                            P_REPLN_Rec          => p_REPLN_Rec,
                                            X_Return_Status      => x_return_status,
                                            X_Msg_Count          => x_msg_count,
                                            X_Msg_Data           => x_msg_data);
        --
        -- Check return status from the above procedure call
        IF not (x_return_status = FND_API.G_RET_STS_SUCCESS)
        then
            ROLLBACK TO UPDATE_REPAIR_ORDER_PUB;
            return;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
        --
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
        --
        WHEN OTHERS THEN
            JTF_PLSQL_API.HANDLE_EXCEPTIONS(P_API_NAME        => L_API_NAME,
                                            P_PKG_NAME        => G_PKG_NAME,
                                            P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS,
                                            P_PACKAGE_TYPE    => JTF_PLSQL_API.G_PUB,
                                            X_MSG_COUNT       => X_MSG_COUNT,
                                            X_MSG_DATA        => X_MSG_DATA,
                                            X_RETURN_STATUS   => X_RETURN_STATUS);
            --   RAISE;
    End Update_Repair_Order;
    --
    -- R12 Development Begin
    /*#
    * Update Repair Order Status
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_Repair_status_rec repair status attributes record.
    * @param P_status_upd_control_rec repair status record control flags.
    * @param X_OBJECT_VERSION_NUMBER
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Repair Order Status
    */
    PROCEDURE Update_Ro_Status(P_Api_Version            IN NUMBER,
                               P_Commit                 IN VARCHAR2,
                               P_Init_Msg_List          IN VARCHAR2,
                               X_Return_Status          OUT NOCOPY VARCHAR2,
                               X_Msg_Count              OUT NOCOPY NUMBER,
                               X_Msg_Data               OUT NOCOPY VARCHAR2,
                               P_REPAIR_STATUS_Rec      IN REPAIR_STATUS_REC_TYPE,
                               P_STATUS_UPD_CONTROL_REC IN STATUS_UPD_CONTROL_REC_TYPE,
                               X_OBJECT_VERSION_NUMBER  OUT NOCOPY NUMBER) IS
        --
        l_api_name           CONSTANT VARCHAR2(30) := 'Update_Ro_Status';
        l_api_version_number CONSTANT NUMBER := 1.0;
        --
    BEGIN
        --
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_RO_STATUS_PUB;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        CSD_REPAIRS_PVT.UPDATE_RO_STATUS(P_Api_Version           => p_api_version,
                                         P_Commit                => p_commit,
                                         P_Init_Msg_List         => p_init_msg_list,
                                         P_Validation_Level      => FND_API.G_VALID_LEVEL_FULL,
                                         X_Return_Status         => x_return_status,
                                         X_Msg_Count             => x_msg_count,
                                         X_Msg_Data              => x_msg_data,
                                         P_REPAIR_STATUS_REC     => p_repair_status_rec,
                                         P_STATUS_CONTROL_REC    => p_status_upd_control_rec,
                                         X_OBJECT_VERSION_NUMBER => x_object_Version_number);
        --
        -- Check return status from the above procedure call
        IF not (x_return_status = FND_API.G_RET_STS_SUCCESS)
        then
            ROLLBACK TO UPDATE_RO_STATUS_PUB;
            return;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF FND_API.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO UPDATE_RO_STATUS_PUB;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.CSD_REPAIRS_PUB.Update_ro_status',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_RO_STATUS_PUB;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.CSD_REPAIRS_PUB.Update_ro_status',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            Rollback TO UPDATE_RO_STATUS_PUB;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.CSD_REPAIRS_PUB.Update_ro_status',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;

    End Update_ro_status;
    -- R12 Development End
End CSD_REPAIRS_PUB;

/
