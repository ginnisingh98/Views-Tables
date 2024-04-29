--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ESTIMATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ESTIMATE_PUB" AS
    /* $Header: csdpestb.pls 120.3 2005/08/02 14:48:23 vparvath noship $ */
    /*#
    * This is the public interface for managing a repair estimate. It allows
    * creation/updation  of repair estimate headers and lines for a repair order.
    * @rep:scope public
    * @rep:product CSD
    * @rep:displayname  Repair Estimate
    * @rep:lifecycle active
    * @rep:category BUSINESS_ENTITY REPAIR_ESTIMATE
    */

    -- ---------------------------------------------------------
    -- Define global variables
    -- ---------------------------------------------------------

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ESTIMATE_PUB';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdpestb.pls';

    /*--------------------------------------------------*/
    /* procedure name: create_estimate_header           */
    /* description   : procedure used to create         */
    /*                 repair estimate headers          */
    /*--------------------------------------------------*/
    /*#
    * Creates a new Repair Estimate header for the given Repair order. The Estimate Header
    * Id is generated if a unique number is not passed. Returns the Estimate Header Id.
    * @param P_Api_Version_Number api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_Estiamte_Hdr_Rec Estimate Header record
    * @param X_Estimate_Hdr_ID Estimate Header id of the created Estiamte Header
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Estimate Header
    */
    PROCEDURE CREATE_ESTIMATE_HEADER(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2,
                                     p_init_msg_list    IN VARCHAR2,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_estimate_hdr_id  OUT NOCOPY NUMBER) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_ESTIMATE_HEADER';
        l_api_version CONSTANT NUMBER := 1.0;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT CREATE_ESTIMATE_HEADER_PUB;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        Csd_Repair_Estimate_Pvt.Create_estimate_header(P_Api_Version      => 1.0,
                                                             P_Init_Msg_List    => p_init_msg_list,
                                                             P_Commit           => Fnd_Api.G_FALSE,
                                                             P_Validation_Level => Fnd_Api.G_VALID_LEVEL_FULL,
                                                             X_Return_Status    => x_return_status,
                                                             X_Msg_Count        => x_msg_count,
                                                             X_Msg_Data         => x_msg_data,
                                                             p_estimate_hdr_rec => p_estimate_hdr_rec,
                                                             x_estimate_hdr_id  => x_estimate_hdr_id);
        --
        -- Check return status from the above procedure call
        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            ROLLBACK TO CREATE_ESTIMATE_HEADER_PUB;
            RETURN;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF Fnd_Api.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN Fnd_Api.g_exc_error THEN
            x_return_status := Fnd_Api.g_ret_sts_error;
            ROLLBACK TO CREATE_ESTIMATE_HEADER_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_header',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.g_exc_unexpected_error THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO CREATE_ESTIMATE_HEADER_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_header',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO CREATE_ESTIMATE_HEADER_PUB;

            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
            THEN
                Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_header',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;
    END CREATE_ESTIMATE_HEADER;

    /*--------------------------------------------------*/
    /* procedure name: update_estimate_header           */
    /* description   : procedure used to update         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/
    /*#
    * Updates a given estimate header record.
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_estimate_hdr_rec estimate header record
    * @param X_object_version_number Object version number of the updated estimate header record.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Estimate Header
    */
    PROCEDURE UPDATE_ESTIMATE_HEADER(p_api_version           IN NUMBER,
                                     p_commit                IN VARCHAR2,
                                     p_init_msg_list         IN VARCHAR2,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec      IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_object_version_number OUT NOCOPY NUMBER) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_ESTIMATE_HEADER';
        l_api_version CONSTANT NUMBER := 1.0;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_ESTIMATE_HEADER_PUB;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        Csd_Repair_Estimate_Pvt.Update_estimate_header(p_api_version           => 1.0,
                                                             p_init_msg_list         => p_init_msg_list,
                                                             p_commit                => Fnd_Api.G_FALSE,
                                                             p_validation_level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                                             x_return_status         => x_return_status,
                                                             x_msg_count             => x_msg_count,
                                                             x_msg_data              => x_msg_data,
                                                             p_estimate_hdr_rec      => p_estimate_hdr_rec,
                                                             x_object_version_number => x_object_version_number);

        --
        -- Check return status from the above procedure call
        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PUB;
            RETURN;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF Fnd_Api.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN Fnd_Api.g_exc_error THEN
            x_return_status := Fnd_Api.g_ret_sts_error;
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_header',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.g_exc_unexpected_error THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_header',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PUB;

            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
            THEN
                Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_header',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;
    END update_estimate_header;

    /*--------------------------------------------------*/
    /* procedure name: create_estimate_line             */
    /* description   : procedure used to create         */
    /*                 repair estimate lines          */
    /*--------------------------------------------------*/
    /*#
    * Creates a new Repair Estimate line for the given Estimate header. The Estimate line
    * Id is generated if a unique number is not passed. Returns the Estimate line Id.
    * @param P_Api_Version_Number api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_Estiamte_Line_Rec Estimate Line record
    * @param X_Estimate_Line_Id Estimate Line id of the created Estiamte Line
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Estimate Line
    */
    PROCEDURE CREATE_ESTIMATE_LINE(p_api_version       IN NUMBER,
                                   p_commit            IN VARCHAR2,
                                   p_init_msg_list     IN VARCHAR2,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_msg_count         OUT NOCOPY NUMBER,
                                   x_msg_data          OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_estimate_line_id  OUT NOCOPY NUMBER)

     IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_ESTIMATE_LINE';
        l_api_version CONSTANT NUMBER := 1.0;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT CREATE_ESTIMATE_LINE_PUB;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        Csd_Repair_Estimate_Pvt.Create_estimate_Line(P_Api_Version       => 1.0,
                                                           P_Init_Msg_List     => p_init_msg_list,
                                                           P_Commit            => Fnd_Api.G_FALSE,
                                                           P_Validation_Level  => Fnd_Api.G_VALID_LEVEL_FULL,
                                                           X_Return_Status     => x_return_status,
                                                           X_Msg_Count         => x_msg_count,
                                                           X_Msg_Data          => x_msg_data,
                                                           p_estimate_line_rec => p_estimate_line_rec,
                                                           x_estimate_line_id  => x_estimate_line_id);
        --
        -- Check return status from the above procedure call
        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            ROLLBACK TO CREATE_ESTIMATE_LINE_PUB;
            RETURN;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF Fnd_Api.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN Fnd_Api.g_exc_error THEN
            x_return_status := Fnd_Api.g_ret_sts_error;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_line',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.g_exc_unexpected_error THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_line',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PUB;

            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
            THEN
                Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.create_estimate_line',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;
    END create_estimate_line;

    /*--------------------------------------------------*/
    /* procedure name: update_estimate_line             */
    /* description   : procedure used to update         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/
    /*#
    * Updates a given estimate Line record.
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param P_estimate_line_rec estimate line record
    * @param X_object_version_number Object version number of the updated estimate line record.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Estimate Line
    */
    PROCEDURE UPDATE_ESTIMATE_LINE(p_api_version           IN NUMBER,
                                   p_init_msg_list         IN VARCHAR2,
                                   p_commit                IN VARCHAR2,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec     IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_object_version_number OUT NOCOPY NUMBER)

     IS

        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_ESTIMATE_LINE';
        l_api_version CONSTANT NUMBER := 1.0;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_ESTIMATE_LINE_PUB;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        --
        -- API body
        --
        Csd_Repair_Estimate_Pvt.Update_estimate_Line(P_Api_Version           => 1.0,
                                                           P_Init_Msg_List         => p_init_msg_list,
                                                           P_Commit                => Fnd_Api.G_FALSE,
                                                           P_Validation_Level      => Fnd_Api.G_VALID_LEVEL_FULL,
                                                           X_Return_Status         => x_return_status,
                                                           X_Msg_Count             => x_msg_count,
                                                           X_Msg_Data              => x_msg_data,
                                                           p_estimate_line_rec     => p_estimate_line_rec,
                                                           x_object_version_number => x_object_version_number);
        --
        -- Check return status from the above procedure call
        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            ROLLBACK TO UPDATE_ESTIMATE_LINE_PUB;
            RETURN;
        END IF;
        --
        -- End of API body.
        --
        -- Standard check for p_commit
        IF Fnd_Api.to_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --
    EXCEPTION
        WHEN Fnd_Api.g_exc_error THEN
            x_return_status := Fnd_Api.g_ret_sts_error;
            ROLLBACK TO UPDATE_ESTIMATE_LINE_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_line',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.g_exc_unexpected_error THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO UPDATE_ESTIMATE_LINE_PUB;
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_line',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            ROLLBACK TO UPDATE_ESTIMATE_LINE_PUB;

            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
            THEN
                Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;

            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pub.update_estimate_line',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;
    END update_estimate_line;

END Csd_Repair_Estimate_Pub;

/
