--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ESTIMATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ESTIMATE_PVT" AS
    /* $Header: csdvestb.pls 120.13.12010000.3 2010/03/17 21:07:55 swai ship $ */

    -- ---------------------------------------------------------
    -- Define global variables
    -- ---------------------------------------------------------

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ESTIMATE_PVT';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvestb.pls';
    g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;
    ----Begin change for 3931317, wrpper aPI forward port

    C_EST_STATUS_ACCEPTED CONSTANT VARCHAR2(30) := 'ACCEPTED';
    C_EST_STATUS_REJECTED CONSTANT VARCHAR2(30) := 'REJECTED';
    C_EST_STATUS_NEW      CONSTANT VARCHAR2(30) := 'NEW';
    C_REP_STATUS_APPROVED CONSTANT VARCHAR2(30) := 'A';
    C_REP_STATUS_REJECTED CONSTANT VARCHAR2(30) := 'R';
    G_DEBUG_LEVEL         CONSTANT NUMBER := TO_NUMBER(NVL(Fnd_Profile.value('CSD_DEBUG_LEVEL'),
                                                           '0'));
    ----End change for 3931317, wrpper aPI forward port


    /*--------------------------------------------------*/
    /* swai: 12.1 Service costing (bug 6960295)         */
    /* procedure name: process_estimate_lines           */
    /* description   : procedure used to create/update  */
    /*                 delete charge lines. This        */
    /*                 procedure allows the overriding  */
    /*                 of the create/update/delete cost */
    /*                 flag introduced in the Charges   */
    /*                 API for 12.1 release             */
    /*--------------------------------------------------*/

    PROCEDURE PROCESS_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     p_action           IN VARCHAR2,
                                     p_cs_cost_flag     IN VARCHAR2 := 'Y',
                                     x_Charges_Rec      IN OUT NOCOPY Cs_Charge_Details_Pub.Charges_Rec_Type,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'PROCESS_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(100);
        l_msg_index             NUMBER;
        l_estimate_detail_id    NUMBER;
        x_object_version_number NUMBER;
        x_line_number           NUMBER;
        x_cost_id               NUMBER; -- swai: 12.1 Service costing uptake bug 6960295

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT process_estimate_lines;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('p_action =' || p_action);
        END IF;

        -- Based on the action, call the respective charges public api to
        -- to create/update/delete the charge lines.
        IF p_action = 'CREATE'
        THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Creating the charge lines ');
            END IF;

            Cs_Charge_Details_Pub.Create_Charge_Details(p_api_version           => p_api_version,
                                                        p_init_msg_list         => p_init_msg_list,
                                                        p_commit                => p_commit,
                                                        p_validation_level      => p_validation_level,
                                                        p_transaction_control   => Fnd_Api.G_TRUE,
                                                        p_Charges_Rec           => x_charges_rec,
                                                        p_create_cost_detail    => p_cs_cost_flag,  -- swai: 12.1 service costing uptake bug 6960295
                                                        x_object_version_number => x_object_version_number,
                                                        x_estimate_detail_id    => l_estimate_detail_id,
                                                        x_line_number           => x_line_number,
                                                        x_return_status         => x_return_status,
                                                        x_msg_count             => x_msg_count,
                                                        x_msg_data              => x_msg_data,
                                                        x_cost_id               => x_cost_id);  -- swai: 12.1 service costing uptake bug 6960295

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Create_Charge_Details failed ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            x_charges_rec.estimate_detail_id := l_estimate_detail_id;

        ELSIF p_action = 'UPDATE'
        THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('l_Charges_Rec.estimate_detail_id =' ||
                                        x_Charges_Rec.estimate_detail_id);
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Updating the charge lines ');
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Estimate Detail Id = ' ||
                                        x_Charges_Rec.estimate_detail_id);
                Csd_Gen_Utility_Pvt.ADD('x_Charges_Rec.business_process_id=' ||
                                        x_Charges_Rec.business_process_id);
            END IF;

            IF ((NVL(x_Charges_Rec.business_process_id, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM) AND
               x_Charges_Rec.estimate_detail_id IS NOT NULL)
            THEN
                BEGIN
                    SELECT business_process_id
                      INTO x_Charges_Rec.business_process_id
                      FROM cs_estimate_details
                     WHERE estimate_detail_id =
                           x_Charges_Rec.estimate_detail_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('No Business business_process_id');
                        END IF;
                        RAISE Fnd_Api.G_EXC_ERROR;
                    WHEN TOO_MANY_ROWS THEN
                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('Too many business_process_id');
                        END IF;
                        RAISE Fnd_Api.G_EXC_ERROR;
                END;
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('x_Charges_Rec.business_process_id=' ||
                                        x_Charges_Rec.business_process_id);
            END IF;

            Cs_Charge_Details_Pub.Update_Charge_Details(p_api_version           => p_api_version,
                                                        p_init_msg_list         => p_init_msg_list,
                                                        p_commit                => p_commit,
                                                        p_validation_level      => p_validation_level,
                                                        p_transaction_control   => Fnd_Api.G_TRUE,
                                                        p_Charges_Rec           => x_Charges_Rec,
                                                        p_update_cost_detail    => p_cs_cost_flag,  -- swai: 12.1 service costing uptake bug 6960295
                                                        x_object_version_number => x_object_version_number,
                                                        x_return_status         => x_return_status,
                                                        x_msg_count             => x_msg_count,
                                                        x_msg_data              => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('update_charge_details failed');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSIF p_action = 'DELETE'
        THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('l_estimate_detail_id =' ||
                                        l_estimate_detail_id);
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Deleting the charge lines ');
            END IF;

            l_estimate_detail_id := x_charges_rec.estimate_detail_id;

            Cs_Charge_Details_Pub.Delete_Charge_Details(p_api_version         => p_api_version,
                                                        p_init_msg_list       => p_init_msg_list,
                                                        p_commit              => p_commit,
                                                        p_validation_level    => p_validation_level,
                                                        p_transaction_control => Fnd_Api.G_TRUE,
                                                        p_estimate_detail_id  => l_estimate_detail_id,
                                                        p_delete_cost_detail  => p_cs_cost_flag,  -- swai: 12.1 service costing uptake bug 6960295
                                                        x_return_status       => x_return_status,
                                                        x_msg_count           => x_msg_count,
                                                        x_msg_data            => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Delete_Charge_Details failed ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSE
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Invalid action is passed ');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_INVALID_ACTION');
            Fnd_Message.SET_TOKEN('ACTION', p_action);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;

        END IF;

        -- Api body ends here
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO process_estimate_lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END process_estimate_lines;

    /*--------------------------------------------------*/
    /* procedure name: update_ro_group_estimate         */
    /* description   : procedure used to update         */
    /*                 repair group for estimate changes*/
    /*--------------------------------------------------*/
    PROCEDURE UPDATE_RO_GROUP_ESTIMATE(p_api_version           IN NUMBER,
                                       p_commit                IN VARCHAR2 := Fnd_Api.g_false,
                                       p_init_msg_list         IN VARCHAR2 := Fnd_Api.g_false,
                                       p_validation_level      IN NUMBER := Fnd_Api.g_valid_level_full,
                                       p_repair_line_id        IN NUMBER,
                                       x_object_version_number OUT NOCOPY NUMBER,
                                       x_return_status         OUT NOCOPY VARCHAR2,
                                       x_msg_count             OUT NOCOPY NUMBER,
                                       x_msg_data              OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_RO_GROUP_ESTIMATE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_index       NUMBER;
        l_return_status   VARCHAR2(10);
        l_msg_count       NUMBER;
        l_msg_data        VARCHAR2(2000);
        l_group_quantity  NUMBER;
        l_group_ovn       NUMBER;
        l_repair_group_id NUMBER;
        l_count           NUMBER;
        l_tot_approved    NUMBER;
        l_tot_no_approval NUMBER;
        l_tot_rejected    NUMBER;
        l_rep_group_rec   Csd_Repair_Groups_Pvt.REPAIR_ORDER_GROUP_REC;

    BEGIN

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Inside UPDATE_RO_GROUP_ESTIMATE Procedure p_repair_line_id =' ||
                                    p_repair_line_id);
        END IF;

        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_RO_GROUP_ESTIMATE;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_repair_line_id,
                                          p_param_name  => 'REPAIR_LINE_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair line id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => p_repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT grp.repair_group_id,
                   grp.group_quantity,
                   grp.object_version_number
              INTO l_repair_group_id, l_group_quantity, l_group_ovn
              FROM CSD_REPAIR_ORDER_GROUPS grp
             WHERE EXISTS
             (SELECT 'x'
                      FROM CSD_REPAIRS rep
                     WHERE rep.repair_group_id = grp.repair_group_id
                       AND rep.repair_line_id = p_repair_line_id);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
                -- FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_GRP_UPD_NO_DATA');
            -- FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
            -- FND_MSG_PUB.ADD;
            -- RAISE FND_API.G_EXC_ERROR;
            WHEN OTHERS THEN
                NULL;
                -- FND_MESSAGE.SET_NAME('CSD','CSD_API_RO_GRP_UPD_OTHERS');
            -- FND_MESSAGE.SET_TOKEN('REPAIR_LINE_ID',p_repair_line_id);
            -- FND_MSG_PUB.ADD;
            -- RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_repair_group_id IS NOT NULL)
        THEN

            l_count           := 0;
            l_tot_approved    := 0;
            l_tot_rejected    := 0;
            l_tot_no_approval := 0;

            BEGIN
                SELECT COUNT(*)
                  INTO l_tot_approved
                  FROM CSD_REPAIRS
                 WHERE repair_group_id = l_repair_group_id
                   AND approval_status = 'A'
                   AND approval_required_flag = 'Y';
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD(' OTHERS l_tot_approved =' ||
                                                l_tot_approved);
                    END IF;

            END;

            BEGIN
                SELECT COUNT(*)
                  INTO l_tot_rejected
                  FROM CSD_REPAIRS
                 WHERE repair_group_id = l_repair_group_id
                   AND approval_status = 'R'
                   AND approval_required_flag = 'Y';
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD(' OTHERS l_tot_rejected =' ||
                                                l_tot_rejected);
                    END IF;

            END;

            BEGIN
                SELECT COUNT(*)
                  INTO l_tot_no_approval
                  FROM CSD_REPAIRS
                 WHERE repair_group_id = l_repair_group_id
                   AND approval_required_flag = 'N';
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD(' OTHERS l_tot_no_approval =' ||
                                                l_tot_no_approval);
                    END IF;

            END;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('l_tot_approved =' ||
                                        l_tot_approved);
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('l_tot_rejected =' ||
                                        l_tot_rejected);
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('l_tot_no_approval =' ||
                                        l_tot_no_approval);
            END IF;

            -- total of approved/rejected repairs with approval required = Y and approval required = N
            -- Assumption no approval are not allowed to be rejected
            l_count                               := NVL(l_tot_approved, 0) +
                                                     NVL(l_tot_rejected, 0) +
                                                     NVL(l_tot_no_approval,
                                                         0);
            l_rep_group_rec.repair_group_id       := l_repair_group_id;
            l_rep_group_rec.object_version_number := l_group_ovn;

            -- check if all group qty have been approved/rejected
            IF (NVL(l_group_quantity, 0) = NVL(l_tot_no_approval, 0))
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('EST_NOT_REQD ');
                END IF;

                l_rep_group_rec.group_approval_status := 'EST_NOT_REQD';
                l_rep_group_rec.approved_quantity     := NVL(l_tot_no_approval,
                                                             0);
            ELSIF (l_group_quantity > l_count)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('PARTIAL_APPRD ');
                END IF;

                l_rep_group_rec.group_approval_status := 'PARTIAL_APPRD';
                l_rep_group_rec.approved_quantity     := NVL(l_tot_approved,
                                                             0) +
                                                         NVL(l_tot_no_approval,
                                                             0);
            ELSIF (l_group_quantity =
                  NVL(l_tot_approved, 0) + NVL(l_tot_no_approval, 0))
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('APPROVED ');
                END IF;

                l_rep_group_rec.group_approval_status := 'APPROVED';
                l_rep_group_rec.approved_quantity     := NVL(l_tot_approved,
                                                             0) +
                                                         NVL(l_tot_no_approval,
                                                             0);
            ELSIF (l_group_quantity = NVL(l_tot_rejected, 0))
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('REJECTED ');
                END IF;

                l_rep_group_rec.group_approval_status := 'REJECTED';
                l_rep_group_rec.approved_quantity     := 0;
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('CSD_REPAIR_ESTIMATE_PVT.UPDATE_RO_GROUP_ESTIMATE Update Group RO call');
            END IF;

            Csd_Repair_Groups_Pvt.UPDATE_REPAIR_GROUPS(p_api_version            => 1.0,
                                                       p_commit                 => 'F',
                                                       p_init_msg_list          => 'T',
                                                       p_validation_level       => Fnd_Api.g_valid_level_full,
                                                       x_repair_order_group_rec => l_rep_group_rec,
                                                       x_return_status          => l_return_status,
                                                       x_msg_count              => l_msg_count,
                                                       x_msg_data               => l_msg_data);

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('CSD_REPAIR_ESTIMATE_PVT.UPDATE_RO_GROUP_ESTIMATE UPDATE_REPAIR_GROUPS :' ||
                                        x_return_status);
            END IF;

            IF l_return_status <> 'S'
            THEN
                x_return_status := Fnd_Api.G_RET_STS_ERROR;
                Fnd_Message.SET_NAME('CSD', 'CSD_API_RO_GROUP_EST_FAIL');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            ELSIF l_return_status = 'S'
            THEN
                x_object_version_number := l_rep_group_rec.object_version_number;
            END IF;

            -- Api body ends here

            -- Standard check of p_commit.
            IF Fnd_Api.To_Boolean(p_commit)
            THEN
                COMMIT WORK;
            END IF;

            -- Standard call to get message count and IF count is  get message info.
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        END IF;

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO UPDATE_RO_GROUP_ESTIMATE;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_RO_GROUP_ESTIMATE;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_RO_GROUP_ESTIMATE;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END UPDATE_RO_GROUP_ESTIMATE;

    /*--------------------------------------------------*/
    /* procedure name: create_repair_estimate           */
    /* description   : procedure used to create         */
    /*                 repair estimate headers          */
    /*--------------------------------------------------*/

    PROCEDURE CREATE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     x_estimate_rec     IN OUT NOCOPY REPAIR_ESTIMATE_REC,
                                     x_estimate_id      OUT NOCOPY NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_REPAIR_ESTIMATE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(100);
        l_msg_index         NUMBER;
        l_dummy             VARCHAR2(1);
        l_incident_id       NUMBER := NULL;
        l_est_count         NUMBER := 0;
        l_est_status_code   VARCHAR2(30);
        l_api_return_status VARCHAR2(3);
        l_group_obj_ver_num NUMBER;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_repair_estimate;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- Dump the in parameters in the log file
        -- if the debug level > 5
        -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--        IF (g_debug > 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_estimate_rec(p_estimate_rec => x_estimate_rec);
--        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter');
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_rec.repair_line_id,
                                          p_param_name  => 'REPAIR_LINE_ID',
                                          p_api_name    => l_api_name);

        -- swai 11.5.10
        -- remove validation since these are not required anymore
        /*
         -- Check the required parameter
         CSD_PROCESS_UTIL.Check_Reqd_Param
         ( p_param_value    => x_estimate_rec.work_summary,
           p_param_name     => 'WORK_SUMMARY',
           p_api_name       => l_api_name);

         -- Check the required parameter
         CSD_PROCESS_UTIL.Check_Reqd_Param
         ( p_param_value    => x_estimate_rec.lead_time,
           p_param_name     => 'LEAD_TIME',
           p_api_name       => l_api_name);

         -- Check the required parameter
         CSD_PROCESS_UTIL.Check_Reqd_Param
         ( p_param_value    => x_estimate_rec.lead_time_uom,
           p_param_name     => 'LEAD_TIME_UOM',
           p_api_name       => l_api_name);
        */

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_rec.estimate_status,
                                          p_param_name  => 'ESTIMATE_STATUS',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair line id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => x_estimate_rec.repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check if there is only one estimate per repair order');
        END IF;

        BEGIN
            SELECT COUNT(*)
              INTO l_est_count
              FROM CSD_REPAIR_ESTIMATE
             WHERE repair_line_id = x_estimate_rec.repair_line_id;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        IF l_est_count > 0
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Estimate already exists for the repair line Id: ' ||
                                        x_estimate_rec.repair_line_id);
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_API_ESTIMATE_EXISTS');
            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                  x_estimate_rec.repair_line_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate the estimate status');
        END IF;

        BEGIN
            SELECT lookup_code
              INTO l_est_status_code
              FROM fnd_lookups
             WHERE lookup_type = 'CSD_ESTIMATE_STATUS'
               AND lookup_code = x_estimate_rec.estimate_status;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_STATUS_MISSING');
                Fnd_Message.SET_TOKEN('ESTIMATE_STATUS',
                                      x_estimate_rec.estimate_status);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;
        /*
               IF l_est_status_code in ('ACCEPTED','REJECTED') then

                IF x_estimate_rec.estimate_reason_code is null then

                 FND_MESSAGE.SET_NAME('CSD','CSD_EST_REASON_CODE__MISSING');
                   FND_MESSAGE.SET_TOKEN('REPAIR_ESTIMATE_ID',x_estimate_rec.repair_estimate_id);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;

                END IF;

              END IF;
        */

        -- Assigning object version number
        x_estimate_rec.object_version_number := 1;

        Csd_Repair_Estimate_Pkg.Insert_Row(px_REPAIR_ESTIMATE_ID   => x_estimate_rec.repair_estimate_id,
                                           p_REPAIR_LINE_ID        => x_estimate_rec.repair_line_id,
                                           p_ESTIMATE_STATUS       => x_estimate_rec.estimate_status,
                                           p_ESTIMATE_DATE         => x_estimate_rec.estimate_date,
                                           p_WORK_SUMMARY          => x_estimate_rec.work_summary,
                                           p_PO_NUMBER             => x_estimate_rec.po_number,
                                           p_LEAD_TIME             => x_estimate_rec.lead_time,
                                           p_LEAD_TIME_UOM         => x_estimate_rec.lead_time_uom,
                                           p_ESTIMATE_FREEZE_FLAG  => x_estimate_rec.estimate_freeze_flag,
                                           p_ESTIMATE_REASON_CODE  => x_estimate_rec.estimate_reason_code,
                                           p_NOT_TO_EXCEED         => x_estimate_rec.not_to_exceed,
                                           p_LAST_UPDATE_DATE      => SYSDATE,
                                           p_CREATION_DATE         => SYSDATE,
                                           p_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
                                           p_CREATED_BY            => Fnd_Global.USER_ID,
                                           p_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
                                           p_ATTRIBUTE1            => x_estimate_rec.ATTRIBUTE1,
                                           p_ATTRIBUTE2            => x_estimate_rec.ATTRIBUTE2,
                                           p_ATTRIBUTE3            => x_estimate_rec.ATTRIBUTE3,
                                           p_ATTRIBUTE4            => x_estimate_rec.ATTRIBUTE4,
                                           p_ATTRIBUTE5            => x_estimate_rec.ATTRIBUTE5,
                                           p_ATTRIBUTE6            => x_estimate_rec.ATTRIBUTE6,
                                           p_ATTRIBUTE7            => x_estimate_rec.ATTRIBUTE7,
                                           p_ATTRIBUTE8            => x_estimate_rec.ATTRIBUTE8,
                                           p_ATTRIBUTE9            => x_estimate_rec.ATTRIBUTE9,
                                           p_ATTRIBUTE10           => x_estimate_rec.ATTRIBUTE10,
                                           p_ATTRIBUTE11           => x_estimate_rec.ATTRIBUTE11,
                                           p_ATTRIBUTE12           => x_estimate_rec.ATTRIBUTE12,
                                           p_ATTRIBUTE13           => x_estimate_rec.ATTRIBUTE13,
                                           p_ATTRIBUTE14           => x_estimate_rec.ATTRIBUTE14,
                                           p_ATTRIBUTE15           => x_estimate_rec.ATTRIBUTE15,
                                           p_CONTEXT               => x_estimate_rec.CONTEXT,
                                           p_OBJECT_VERSION_NUMBER => 1);

        -- Api body ends here

        -- travi 052002 code
        -- Call to update group estimate status and approved quantity
        IF (x_estimate_rec.estimate_status IN ('ACCEPTED', 'REJECTED'))
        THEN

            UPDATE_RO_GROUP_ESTIMATE(p_api_version           => 1.0,
                                     p_commit                => Fnd_Api.g_false,
                                     p_init_msg_list         => Fnd_Api.g_true,
                                     p_validation_level      => Fnd_Api.g_valid_level_full,
                                     p_repair_line_id        => x_estimate_rec.repair_line_id,
                                     x_object_version_number => l_group_obj_ver_num,
                                     x_return_status         => l_api_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data);

            IF (l_api_return_status <> 'S')
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO create_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_repair_estimate;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_repair_estimate;

    /*--------------------------------------------------*/
    /* procedure name: update_repair_estimate           */
    /* description   : procedure used to update         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE UPDATE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     x_estimate_rec     IN OUT NOCOPY REPAIR_ESTIMATE_REC,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_REPAIR_ESTIMATE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(100);
        l_msg_index         NUMBER;
        l_upd_estimate_flag VARCHAR2(1) := '';
        l_approval_status   VARCHAR2(1);
        l_estimate_id       NUMBER;
        l_obj_ver_num       NUMBER;
        l_est_status_code   VARCHAR2(30);
        l_api_return_status VARCHAR2(3);
        l_group_obj_ver_num NUMBER;

        CURSOR repair_estimate(p_est_id IN NUMBER) IS
            SELECT a.repair_estimate_id,
                   a.object_version_number,
                   b.approval_status
              FROM CSD_REPAIR_ESTIMATE a, CSD_REPAIRS b
             WHERE a.repair_line_id = b.repair_line_id
               AND a.repair_estimate_id = p_est_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT update_repair_estimate;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- Dump the in parameters in the log file
        -- if the debug level > 5
        --If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--        IF (g_debug > 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_estimate_rec(p_estimate_rec => x_estimate_rec);
--        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter: Repair Estimate Id');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Repair Estimate Id =' ||
                                    x_estimate_rec.repair_estimate_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_rec.repair_estimate_id,
                                          p_param_name  => 'REPAIR_ESTIMATE_ID',
                                          p_api_name    => l_api_name);

        IF NVL(x_estimate_rec.repair_estimate_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN

            OPEN repair_estimate(x_estimate_rec.repair_estimate_id);
            FETCH repair_estimate
                INTO l_estimate_id, l_obj_ver_num, l_approval_status;

            IF repair_estimate%NOTFOUND
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_ESTIMATE_MISSING');
                Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', l_estimate_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF repair_estimate%ISOPEN
            THEN
                CLOSE repair_estimate;
            END IF;

        END IF;

        IF NVL(x_estimate_rec.object_version_number, Fnd_Api.G_MISS_NUM) <>
           l_obj_ver_num
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('object version number does not match');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_OBJ_VER_MISMATCH');
            Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', l_estimate_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate the estimate status');
        END IF;

        BEGIN
            SELECT lookup_code
              INTO l_est_status_code
              FROM fnd_lookups
             WHERE lookup_type = 'CSD_ESTIMATE_STATUS'
               AND lookup_code = x_estimate_rec.estimate_status;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_STATUS_MISSING');
                Fnd_Message.SET_TOKEN('ESTIMATE_STATUS',
                                      x_estimate_rec.estimate_status);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;
        /*
               IF l_est_status_code in ('ACCEPTED','REJECTED') then

                IF x_estimate_rec.estimate_reason_code is null then

                 FND_MESSAGE.SET_NAME('CSD','CSD_EST_REASON_CODE__MISSING');
                   FND_MESSAGE.SET_TOKEN('REPAIR_ESTIMATE_ID',x_estimate_rec.repair_estimate_id);
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;

                END IF;
              END IF;
        */

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_approval_status =' ||
                                    l_approval_status);
        END IF;

        -- Estimate lines are allowed to update only
        -- if it is not frozen

        -- IF NVL(l_approval_status,'Z') <> 'A' THEN

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Calling CSD_REPAIR_ESTIMATE_PKG.Update_Row');
        END IF;

        Csd_Repair_Estimate_Pkg.Update_Row(p_REPAIR_ESTIMATE_ID    => x_estimate_rec.repair_estimate_id,
                                           p_REPAIR_LINE_ID        => x_estimate_rec.repair_line_id,
                                           p_ESTIMATE_STATUS       => x_estimate_rec.estimate_status,
                                           p_ESTIMATE_DATE         => x_estimate_rec.estimate_date,
                                           p_WORK_SUMMARY          => x_estimate_rec.work_summary,
                                           p_PO_NUMBER             => x_estimate_rec.po_number,
                                           p_LEAD_TIME             => x_estimate_rec.lead_time,
                                           p_LEAD_TIME_UOM         => x_estimate_rec.lead_time_uom,
                                           p_ESTIMATE_FREEZE_FLAG  => x_estimate_rec.estimate_freeze_flag,
                                           p_ESTIMATE_REASON_CODE  => x_estimate_rec.estimate_reason_code,
                                           p_NOT_TO_EXCEED         => x_estimate_rec.not_to_exceed,
                                           p_LAST_UPDATE_DATE      => SYSDATE,
                                           p_CREATION_DATE         => SYSDATE,
                                           p_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
                                           p_CREATED_BY            => Fnd_Global.USER_ID,
                                           p_LAST_UPDATE_LOGIN     => Fnd_Global.LOGIN_ID,
                                           p_ATTRIBUTE1            => x_estimate_rec.ATTRIBUTE1,
                                           p_ATTRIBUTE2            => x_estimate_rec.ATTRIBUTE2,
                                           p_ATTRIBUTE3            => x_estimate_rec.ATTRIBUTE3,
                                           p_ATTRIBUTE4            => x_estimate_rec.ATTRIBUTE4,
                                           p_ATTRIBUTE5            => x_estimate_rec.ATTRIBUTE5,
                                           p_ATTRIBUTE6            => x_estimate_rec.ATTRIBUTE6,
                                           p_ATTRIBUTE7            => x_estimate_rec.ATTRIBUTE7,
                                           p_ATTRIBUTE8            => x_estimate_rec.ATTRIBUTE8,
                                           p_ATTRIBUTE9            => x_estimate_rec.ATTRIBUTE9,
                                           p_ATTRIBUTE10           => x_estimate_rec.ATTRIBUTE10,
                                           p_ATTRIBUTE11           => x_estimate_rec.ATTRIBUTE11,
                                           p_ATTRIBUTE12           => x_estimate_rec.ATTRIBUTE12,
                                           p_ATTRIBUTE13           => x_estimate_rec.ATTRIBUTE13,
                                           p_ATTRIBUTE14           => x_estimate_rec.ATTRIBUTE14,
                                           p_ATTRIBUTE15           => x_estimate_rec.ATTRIBUTE15,
                                           p_CONTEXT               => x_estimate_rec.CONTEXT,
                                           p_OBJECT_VERSION_NUMBER => l_obj_ver_num + 1);

        x_estimate_rec.object_version_number := l_obj_ver_num + 1;

        -- END IF; -- end of update estimate

        -- Api body ends here
        -- travi 052002 code
        -- Call to update group estimate status and approved quantity
        IF (x_estimate_rec.estimate_status IN ('ACCEPTED', 'REJECTED'))
        THEN

            UPDATE_RO_GROUP_ESTIMATE(p_api_version           => 1.0,
                                     p_commit                => Fnd_Api.g_false,
                                     p_init_msg_list         => Fnd_Api.g_true,
                                     p_validation_level      => Fnd_Api.g_valid_level_full,
                                     p_repair_line_id        => x_estimate_rec.repair_line_id,
                                     x_object_version_number => l_group_obj_ver_num,
                                     x_return_status         => l_api_return_status,
                                     x_msg_count             => x_msg_count,
                                     x_msg_data              => x_msg_data);

            IF (l_api_return_status <> 'S')
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO update_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_estimate;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_repair_estimate;

    /*--------------------------------------------------*/
    /* procedure name: delete_repair_estimate           */
    /* description   : procedure used to delete         */
    /*                 repair estimate header           */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE DELETE_REPAIR_ESTIMATE(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                     p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                     p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                     p_estimate_id      IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_REPAIR_ESTIMATE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(100);
        l_msg_index          NUMBER;
        l_Charges_Rec        Cs_Charge_Details_Pub.charges_rec_type;
        x_estimate_detail_id NUMBER;
        l_est_detail_id      NUMBER;
        l_delete_allow       VARCHAR2(1);
        l_approval_status    VARCHAR2(1);
        l_est_line_count     NUMBER;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT delete_repair_estimate;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter: Estimate Id ');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Repair Estimate Id  =' ||
                                    p_estimate_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_id,
                                          p_param_name  => 'REPAIR_ESTIMATE_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair estimate id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_estimate_id(p_estimate_id => p_estimate_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT b.approval_status
              INTO l_approval_status
              FROM CSD_REPAIR_ESTIMATE a, CSD_REPAIRS b
             WHERE a.repair_line_id = b.repair_line_id
               AND a.repair_estimate_id = p_estimate_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Estimate ID missing');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_API_ESTIMATE_MISSING');
                Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', p_estimate_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        BEGIN
            SELECT COUNT(*)
              INTO l_est_line_count
              FROM CSD_REPAIR_ESTIMATE_LINES
             WHERE repair_estimate_id = p_estimate_id;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;

        IF l_est_line_count > 0
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Estimate Lines exists for this estimate');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_ESTIMATE_LINE_EXISTS');
            Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', p_estimate_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF NVL(l_approval_status, 'Z') <> 'A'
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call CSD_REPAIR_ESTIMATE_PKG.Delete_Row');
            END IF;

            Csd_Repair_Estimate_Pkg.Delete_Row(p_REPAIR_ESTIMATE_ID => p_estimate_id);
        ELSE
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_DELETE_NOT_ALLOWED');
            Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_ID', p_estimate_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Api body ends here
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO delete_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_repair_estimate;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END delete_repair_estimate;

    /*--------------------------------------------------*/
    /* procedure name: lock_repair_estimate             */
    /* description   : procedure used to create         */
    /*                 repair estimate headers          */
    /*--------------------------------------------------*/

    PROCEDURE lock_repair_estimate(p_api_version      IN NUMBER,
                                   p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                   p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                   p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                   p_estimate_rec     IN REPAIR_ESTIMATE_REC,
                                   x_return_status    OUT NOCOPY VARCHAR2,
                                   x_msg_count        OUT NOCOPY NUMBER,
                                   x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_REPAIR_ESTIMATE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count NUMBER;
        l_msg_data  VARCHAR2(100);
        l_msg_index NUMBER;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT lock_repair_estimate;

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

        Csd_Repair_Estimate_Pkg.Lock_Row(p_REPAIR_ESTIMATE_ID    => p_estimate_rec.repair_estimate_id,
                                         p_OBJECT_VERSION_NUMBER => p_estimate_rec.OBJECT_VERSION_NUMBER);

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO lock_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO lock_repair_estimate;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO lock_repair_estimate;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END lock_repair_estimate;

    /*--------------------------------------------------*/
    /* procedure name: create_repair_estimate_lines     */
    /* description   : procedure used to create         */
    /*                 repair estimate lines            */
    /*--------------------------------------------------*/

    PROCEDURE CREATE_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                           p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                           x_estimate_line_rec IN OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
                                           x_estimate_line_id  OUT NOCOPY NUMBER,
                                           x_return_status     OUT NOCOPY VARCHAR2,
                                           x_msg_count         OUT NOCOPY NUMBER,
                                           x_msg_data          OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_REPAIR_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count           NUMBER;
        l_msg_data            VARCHAR2(100);
        l_msg_index           NUMBER;
        l_serial_flag         BOOLEAN := FALSE;
        l_dummy               VARCHAR2(1);
        l_Charges_Rec         Cs_Charge_Details_Pub.Charges_Rec_Type;
        x_estimate_detail_id  NUMBER := NULL;
        l_incident_id         NUMBER := NULL;
        l_reference_number    VARCHAR2(30) := '';
        l_contract_number     VARCHAR2(120) := '';
        l_bus_process_id      NUMBER := NULL;
        l_repair_type_ref     VARCHAR2(3) := '';
        l_line_type_id        NUMBER := NULL;
        l_txn_billing_type_id NUMBER := NULL;
        l_party_id            NUMBER := NULL;
        l_account_id          NUMBER := NULL;
        l_order_header_id     NUMBER := NULL;
        l_release_status      VARCHAR2(10) := '';
        l_curr_code           VARCHAR2(10) := '';
        l_line_category_code  VARCHAR2(30) := '';
        l_ship_from_org_id    NUMBER := NULL;
        l_order_line_id       NUMBER := NULL;
        -- passing in from form
        -- l_coverage_id            NUMBER := NULL;
        -- l_coverage_name          VARCHAR2(30) := '';
        -- l_txn_group_id           NUMBER := NULL;
        --
        l_unit_selling_price NUMBER := NULL;
        l_item_cost          NUMBER := NULL;

        CURSOR order_rec(p_incident_id IN NUMBER) IS
            SELECT customer_id, account_id
              FROM cs_incidents_all_b
             WHERE incident_id = p_incident_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_repair_estimate_lines;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- Dump the in parameters in the log file
        -- if the debug level > 5
        -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--        IF (g_debug > 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_estimate_line_rec(p_estimate_line_rec => x_estimate_line_rec);
--        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Repair Line ID =' ||
                                    x_estimate_line_rec.repair_line_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('txn_billing_type_id =' ||
                                    x_estimate_line_rec.txn_billing_type_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.repair_line_id,
                                          p_param_name  => 'REPAIR_LINE_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.txn_billing_type_id,
                                          p_param_name  => 'TXN_BILLING_TYPE_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.inventory_item_id,
                                          p_param_name  => 'INVENTORY_ITEM_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.unit_of_measure_code,
                                          p_param_name  => 'UNIT_OF_MEASURE_CODE',
                                          p_api_name    => l_api_name);

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.estimate_quantity,
                                          p_param_name  => 'ESTIMATE_QUANTITY',
                                          p_api_name    => l_api_name);

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.price_list_id,
                                          p_param_name  => 'PRICE_LIST_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair estimate id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_estimate_id(p_estimate_id => x_estimate_line_rec.repair_estimate_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair line id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => x_estimate_line_rec.repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Get the service request
        BEGIN
            SELECT incident_id
              INTO l_incident_id
              FROM CSD_REPAIRS
             WHERE repair_line_id = x_estimate_line_rec.repair_line_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      x_estimate_line_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_incident_id  =' || l_incident_id);
        END IF;

        -- Get the business process id
        -- Forward port bug fix# 2756313
        --      l_bus_process_id := CSD_PROCESS_UTIL.GET_BUS_PROCESS(l_incident_id);

        l_bus_process_id := Csd_Process_Util.GET_BUS_PROCESS(x_estimate_line_rec.repair_line_id);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_bus_process_id =' ||
                                    l_bus_process_id);
        END IF;

        IF l_bus_process_id < 0
        THEN
            IF NVL(x_estimate_line_rec.business_process_id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN
                l_bus_process_id := x_estimate_line_rec.business_process_id;
            ELSE
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Business process does not exist ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        /* contract information passed from form
        IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.ADD('Getting the Coverage and txn Group Id');
        END IF;

        IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.ADD('contract_line_id ='||x_estimate_line_rec.contract_id);
        END IF;


              IF NVL(x_estimate_line_rec.contract_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

                Begin
                 SELECT cov.actual_coverage_id ,
                        cov.coverage_name,
                        ent.txn_group_id
                 INTO   l_coverage_id,
                        l_coverage_name,
                        l_txn_group_id
                 FROM   oks_ent_coverages_v cov,
                        oks_ent_txn_groups_v ent
                 WHERE  cov.contract_number = x_estimate_line_rec.contract_number -- travi change
                  AND   cov.actual_coverage_id = ent.coverage_id
                  AND   ent.business_process_id = l_bus_process_id;

        -- travi comment
        --         WHERE  cov.contract_line_id = x_estimate_line_rec.contract_id

                Exception
                 When no_data_found then
                  FND_MESSAGE.SET_NAME('CSD','CSD_API_CONTRACT_MISSING');
                  FND_MESSAGE.SET_TOKEN('CONTRACT_LINE_ID',x_estimate_line_rec.contract_id);
                  FND_MSG_PUB.ADD;
        IF (g_debug > 0 ) THEN
                  csd_gen_utility_pvt.ADD('Contract Line Id missing');
        END IF;

                  RAISE FND_API.G_EXC_ERROR;
                End;

                 x_estimate_line_rec.coverage_id := l_coverage_id;
                 x_estimate_line_rec.coverage_txn_group_id := l_txn_group_id;

        IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD('l_coverage_id  ='||l_coverage_id);
        END IF;

        IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD('l_txn_group_id ='||l_txn_group_id);
        END IF;


              End If;
        */

        IF l_incident_id IS NOT NULL
        THEN
            OPEN order_rec(l_incident_id);
            FETCH order_rec
                INTO l_party_id, l_account_id;

            IF order_rec%NOTFOUND OR l_party_id IS NULL
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_PARTY_MISSING');
                Fnd_Message.SET_TOKEN('INCIDENT_ID', l_incident_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF order_rec%ISOPEN
            THEN
                CLOSE order_rec;
            END IF;

        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_party_id   =' || l_party_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_account_id =' || l_account_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('x_estimate_line_rec.txn_billing_type_id =' ||
                                    x_estimate_line_rec.txn_billing_type_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('x_estimate_line_rec.organization_id     =' ||
                                    x_estimate_line_rec.organization_id);
        END IF;

        -- Derive the txn_billing type and line category code
        -- from the transaction type
        Csd_Process_Util.GET_LINE_TYPE(p_txn_billing_type_id => x_estimate_line_rec.txn_billing_type_id,
                                       -- Following line commented (and substituted) for the bug 3337344.
                                       -- p_org_id              => x_estimate_line_rec.organization_id,
                                       -- Organization_id passed could really be Service Validation Org, whereas
                                       -- it should really be Operating Unit. CSD_PROCESS_UTIL.get_org_id procedure
                                       -- ensures that the OU is passed.
                                       p_org_id             => Csd_Process_Util.get_org_id(x_estimate_line_rec.incident_id),
                                       x_line_type_id       => l_line_type_id,
                                       x_line_category_code => l_line_category_code,
                                       x_return_status      => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_line_type_id        =' ||
                                    l_line_type_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_line_category_code  =' ||
                                    l_line_category_code);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('x_estimate_line_rec.price_list_id =' ||
                                    x_estimate_line_rec.price_list_id);
        END IF;

        -- If line_type_id Or line_category_code is null
        -- then raise error
        IF l_line_type_id IS NULL OR l_line_category_code IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_LINE_TYPE_MISSING');
            Fnd_Message.SET_TOKEN('TXN_BILLING_TYPE_ID',
                                  x_estimate_line_rec.txn_billing_type_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Get the currency code
        IF NVL(x_estimate_line_rec.price_list_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            BEGIN
                SELECT currency_code
                  INTO l_curr_code
                  FROM oe_price_lists
                 WHERE price_list_id = x_estimate_line_rec.price_list_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_API_INV_PRICE_LIST_ID');
                    Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                          x_estimate_line_rec.price_list_id);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_curr_code     =' || l_curr_code);
        END IF;

        -- If l_curr_code is null then raise error
        IF l_curr_code IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_CURR_CODE');
            Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                  x_estimate_line_rec.price_list_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        --
        -- Commented for bug# 2857134 (forward port bugfix from 11.5.8)
        --
        --       IF NVL(x_estimate_line_rec.item_cost,FND_API.G_MISS_NUM)= FND_API.G_MISS_NUM THEN
        --IF (g_debug > 0 ) THEN
        --         csd_gen_utility_pvt.ADD('Get item cost' );
        --END IF;
        --
        --
        --        BEGIN
        --           select decode(item_cost,0 ,null,item_cost)
        --           into l_item_cost
        --           from cst_item_costs
        --           where inventory_item_id = x_estimate_line_rec.inventory_item_id
        --           and  organization_id   = cs_std.get_item_valdn_orgzn_id
        --           and  cost_type_id = 1;
        --
        --           x_estimate_line_rec.item_cost               := l_item_cost ;
        --
        --         EXCEPTION
        --          WHEN NO_DATA_FOUND THEN
        --IF (g_debug > 0 ) THEN
        --          csd_gen_utility_pvt.ADD('Could not get item cost' );
        --END IF;
        --
        --           FND_MESSAGE.SET_NAME('CSD','CSD_ITEM_COST_MISSING');
        --           FND_MSG_PUB.ADD;
        --           RAISE FND_API.G_EXC_ERROR;
        --        END;
        --      END IF;
        --
        --

        -- assigning values for the charge record
        x_estimate_line_rec.incident_id         := l_incident_id;
        x_estimate_line_rec.business_process_id := l_bus_process_id;
        x_estimate_line_rec.line_type_id        := l_line_type_id;
        x_estimate_line_rec.currency_code       := l_curr_code;
        x_estimate_line_rec.line_category_code  := l_line_category_code;

        -- travi new code
        --x_estimate_line_rec.charge_line_type        := ;
        --x_estimate_line_rec.apply_contract_discount := ;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Convert estimate line rec to charges rec');
        END IF;

        -- always create estimate lines with interface to OE flag as 'N'
        x_estimate_line_rec.interface_to_om_flag := 'N';

        -- Convert the estimate record to
        -- charge record
        Csd_Process_Util.CONVERT_EST_TO_CHG_REC(p_estimate_line_rec => x_estimate_line_rec,
                                                x_charges_rec       => l_Charges_Rec,
                                                x_return_status     => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Call process_estimate_lines to create charge lines ');
        END IF;

        process_estimate_lines(p_api_version      => 1.0,
                               p_commit           => Fnd_Api.g_false,
                               p_init_msg_list    => Fnd_Api.g_false, -- swai 11.5.10, set to g_false
                               p_validation_level => Fnd_Api.g_valid_level_full,
                               p_action           => 'CREATE',
                               x_Charges_Rec      => l_Charges_Rec,
                               x_return_status    => x_return_status,
                               x_msg_count        => x_msg_count,
                               x_msg_data         => x_msg_data);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('NEW ESTIMATE DETAIL ID =' ||
                                    l_Charges_Rec.estimate_detail_id);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Call csd_repair_estimate_lines_pkg.insert_row to create repair estimate lines ');
        END IF;

        -- travi forward port Bug # 2789754 fix added override_charge_flag
        Csd_Repair_Estimate_Lines_Pkg.Insert_Row(px_REPAIR_ESTIMATE_LINE_ID  => x_estimate_line_rec.repair_estimate_line_id,
                                                 p_REPAIR_ESTIMATE_ID        => x_estimate_line_rec.repair_estimate_id,
                                                 p_ESTIMATE_DETAIL_ID        => l_Charges_Rec.estimate_detail_id,
                                                 p_LAST_UPDATE_DATE          => SYSDATE,
                                                 p_CREATION_DATE             => SYSDATE,
                                                 p_LAST_UPDATED_BY           => Fnd_Global.USER_ID,
                                                 p_CREATED_BY                => Fnd_Global.USER_ID,
                                                 p_LAST_UPDATE_LOGIN         => Fnd_Global.LOGIN_ID,
                                                 p_ITEM_COST                 => x_estimate_line_rec.item_cost,
                                                 p_RESOURCE_ID               => x_estimate_line_rec.resource_id,
                                                 p_OVERRIDE_CHARGE_FLAG      => x_estimate_line_rec.override_charge_flag,
                                                 p_JUSTIFICATION_NOTES       => x_estimate_line_rec.justification_notes,
                                                 p_ATTRIBUTE1                => x_estimate_line_rec.ATTRIBUTE1,
                                                 p_ATTRIBUTE2                => x_estimate_line_rec.ATTRIBUTE2,
                                                 p_ATTRIBUTE3                => x_estimate_line_rec.ATTRIBUTE3,
                                                 p_ATTRIBUTE4                => x_estimate_line_rec.ATTRIBUTE4,
                                                 p_ATTRIBUTE5                => x_estimate_line_rec.ATTRIBUTE5,
                                                 p_ATTRIBUTE6                => x_estimate_line_rec.ATTRIBUTE6,
                                                 p_ATTRIBUTE7                => x_estimate_line_rec.ATTRIBUTE7,
                                                 p_ATTRIBUTE8                => x_estimate_line_rec.ATTRIBUTE8,
                                                 p_ATTRIBUTE9                => x_estimate_line_rec.ATTRIBUTE9,
                                                 p_ATTRIBUTE10               => x_estimate_line_rec.ATTRIBUTE10,
                                                 p_ATTRIBUTE11               => x_estimate_line_rec.ATTRIBUTE11,
                                                 p_ATTRIBUTE12               => x_estimate_line_rec.ATTRIBUTE12,
                                                 p_ATTRIBUTE13               => x_estimate_line_rec.ATTRIBUTE13,
                                                 p_ATTRIBUTE14               => x_estimate_line_rec.ATTRIBUTE14,
                                                 p_ATTRIBUTE15               => x_estimate_line_rec.ATTRIBUTE15,
                                                 p_CONTEXT                   => x_estimate_line_rec.CONTEXT,
                                                 p_OBJECT_VERSION_NUMBER     => 1,
                                                 p_EST_LINE_SOURCE_TYPE_CODE => x_estimate_line_rec.EST_LINE_SOURCE_TYPE_CODE,
                                                 p_EST_LINE_SOURCE_ID1       => x_estimate_line_rec.EST_LINE_SOURCE_ID1,
                                                 p_EST_LINE_SOURCE_ID2       => x_estimate_line_rec.EST_LINE_SOURCE_ID2,
                                                 p_RO_SERVICE_CODE_ID        => x_estimate_line_rec.RO_SERVICE_CODE_ID);

        x_estimate_line_rec.object_version_number := 1;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO create_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_repair_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_repair_estimate_lines;

    /*--------------------------------------------------*/
    /* procedure name: update_repair_estimate_lines     */
    /* description   : procedure used to update         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE UPDATE_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                           p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                           x_estimate_line_rec IN OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC,
                                           x_return_status     OUT NOCOPY VARCHAR2,
                                           x_msg_count         OUT NOCOPY NUMBER,
                                           x_msg_data          OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_REPAIR_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(100);
        l_msg_index          NUMBER;
        l_upd_charge_flag    VARCHAR2(1) := '';
        l_dummy              VARCHAR2(1);
        l_Charges_Rec        Cs_Charge_Details_Pub.charges_rec_type;
        x_estimate_detail_id NUMBER := NULL;
        l_incident_id        NUMBER := NULL;
        l_party_id           NUMBER := NULL;
        l_account_id         NUMBER := NULL;
        l_order_header_id    NUMBER := NULL;
        l_curr_code          VARCHAR2(10) := '';
        l_picking_rule_id    NUMBER := NULL;
        l_est_detail_id      NUMBER := NULL;
        l_repair_line_id     NUMBER := NULL;
        l_booked_flag        VARCHAR2(1) := '';
        l_allow_ship         VARCHAR2(1) := '';
        l_obj_ver_num        NUMBER := NULL;
        l_ship_from_org_id   NUMBER := NULL;
        l_order_line_id      NUMBER := NULL;
        l_coverage_id        NUMBER := NULL;
        -- Bugfix 3617932, vkjain.
        -- Increasing the column length to 150
        -- l_coverage_name          VARCHAR2(150) := '';
        l_txn_group_id       NUMBER := NULL;
        l_bus_process_id     NUMBER := NULL;
        l_unit_selling_price NUMBER := NULL;
        l_serial_flag        BOOLEAN := FALSE;

        CURSOR estimate_line(p_est_line_id IN NUMBER) IS
            SELECT estimate_detail_id, object_version_number
              FROM CSD_REPAIR_ESTIMATE_LINES
             WHERE repair_estimate_line_id = p_est_line_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT update_repair_estimate_lines;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- Dump the in parameters in the log file
        -- if the debug level > 5
        -- If fnd_profile.value('CSD_DEBUG_LEVEL') > 5 then
--        IF (g_debug > 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_estimate_line_rec(p_estimate_line_rec => x_estimate_line_rec);
--        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter: Repair Estimate Line id');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Repair Estimate Line Id =' ||
                                    x_estimate_line_rec.repair_estimate_line_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_estimate_line_rec.repair_estimate_line_id,
                                          p_param_name  => 'ESTIMATE_LINE_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate Estimate Line Id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_estimate_line_id(p_estimate_line_id => x_estimate_line_rec.repair_estimate_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF NVL(x_estimate_line_rec.repair_estimate_line_id,
               Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
        THEN

            OPEN estimate_line(x_estimate_line_rec.repair_estimate_line_id);
            FETCH estimate_line
                INTO l_est_detail_id, l_obj_ver_num;
            CLOSE estimate_line;
        END IF;

        IF NVL(x_estimate_line_rec.object_version_number,
               Fnd_Api.G_MISS_NUM) <> l_obj_ver_num
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('object version number does not match');
            END IF;

            Fnd_Message.SET_NAME('CSD', 'CSD_OBJ_VER_MISMATCH');
            Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_LINE_ID',
                                  x_estimate_line_rec.repair_estimate_line_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF NVL(x_estimate_line_rec.estimate_detail_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            IF x_estimate_line_rec.estimate_detail_id <> l_est_detail_id
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('The estimate detail id cannot to changed');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        ELSE
            x_estimate_line_rec.estimate_detail_id := l_est_detail_id;
        END IF;

        IF NVL(x_estimate_line_rec.repair_line_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            IF x_estimate_line_rec.repair_line_id <> l_repair_line_id
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('The repair line id cannot to changed');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        ELSE
            x_estimate_line_rec.repair_line_id := l_repair_line_id;
        END IF;

        BEGIN
            SELECT business_process_id
              INTO l_bus_process_id
              FROM cs_estimate_details
             WHERE estimate_detail_id = l_est_detail_id
               AND order_header_id IS NULL;
            l_upd_charge_flag := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_upd_charge_flag := 'N';
        END;

        /* contract information passed from form
              IF NVL(x_estimate_line_rec.contract_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('Getting the Coverage and txn Group Id');
        END IF;

        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('contract_line_id ='||x_estimate_line_rec.contract_id);
        END IF;

        IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.ADD('l_bus_process_id ='||l_bus_process_id);
        END IF;


                Begin
                 SELECT cov.actual_coverage_id ,
                        -- cov.coverage_name, -- Commented for bugfix 3617932
                        ent.txn_group_id
                 into   l_coverage_id,
                        -- l_coverage_name, -- Commented for bugfix 3617932
                        l_txn_group_id
                 FROM   oks_ent_coverages_v cov,
                        oks_ent_txn_groups_v ent
                 WHERE cov.contract_number = x_estimate_line_rec.contract_number -- takwong, fixed bug#2510068
               -- cov.contract_line_id = x_estimate_line_rec.contract_id
                  AND    cov.actual_coverage_id = ent.coverage_id
                  AND    ent.business_process_id = l_bus_process_id;
                Exception
                 When no_data_found then
                  FND_MESSAGE.SET_NAME('CSD','CSD_API_CONTRACT_MISSING');
                  FND_MESSAGE.SET_TOKEN('CONTRACT_LINE_ID',x_estimate_line_rec.contract_id);
                  FND_MSG_PUB.ADD;
        IF (g_debug > 0 ) THEN
                  csd_gen_utility_pvt.ADD('Contract Line Id missing');
        END IF;

                  RAISE FND_API.G_EXC_ERROR;
                End;

                 x_estimate_line_rec.coverage_id := l_coverage_id;
                 x_estimate_line_rec.coverage_txn_group_id := l_txn_group_id;
        IF (g_debug > 0 ) THEN
                 csd_gen_utility_pvt.ADD('l_coverage_id  ='||l_coverage_id);
        END IF;

        IF (g_debug > 0 ) THEN
                 csd_gen_utility_pvt.ADD('l_txn_group_id ='||l_txn_group_id);
        END IF;


              End If;
        */

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_upd_charge_flag =' ||
                                    l_upd_charge_flag);
        END IF;

        IF x_estimate_line_rec.item_cost = 0
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('item cost is zero');
            END IF;

            x_estimate_line_rec.item_cost := NULL;
        END IF;

        -- Charge lines are allowed to update only
        -- if it is not interfaced to OM

        IF l_upd_charge_flag = 'Y'
        THEN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Convert estimate to charges rec');
            END IF;

            Csd_Process_Util.CONVERT_EST_TO_CHG_REC(p_estimate_line_rec => x_estimate_line_rec,
                                                    x_charges_rec       => l_Charges_Rec,
                                                    x_return_status     => x_return_status);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('csd_process_util.convert_to_chg_rec failed');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            l_Charges_Rec.estimate_detail_id := l_est_detail_id;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call process_estimate_lines to update charge lines ');
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Estimate Detail Id = ' ||
                                        l_Charges_Rec.estimate_detail_id);
            END IF;

            process_estimate_lines(p_api_version      => 1.0,
                                   p_commit           => Fnd_Api.g_false,
                                   p_init_msg_list    => Fnd_Api.g_true,
                                   p_validation_level => Fnd_Api.g_valid_level_full,
                                   p_action           => 'UPDATE',
                                   x_Charges_Rec      => l_Charges_Rec,
                                   x_return_status    => x_return_status,
                                   x_msg_count        => x_msg_count,
                                   x_msg_data         => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('process_estimate_lines failed ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END IF; -- end of update charge line

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Call csd_repair_estimate_line_pkg.update_row to update the repair estimate');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('x_estimate_line_rec.repair_estimate_line_id =' ||
                                    x_estimate_line_rec.repair_estimate_line_id);
        END IF;

        -- travi forward port Bug # 2789754 fix added override_charge_flag
        Csd_Repair_Estimate_Lines_Pkg.Update_Row(p_REPAIR_ESTIMATE_LINE_ID   => x_estimate_line_rec.repair_estimate_line_id,
                                                 p_REPAIR_ESTIMATE_ID        => x_estimate_line_rec.repair_estimate_id,
                                                 p_ESTIMATE_DETAIL_ID        => x_estimate_line_rec.estimate_detail_id,
                                                 p_LAST_UPDATE_DATE          => SYSDATE,
                                                 p_CREATION_DATE             => SYSDATE,
                                                 p_LAST_UPDATED_BY           => Fnd_Global.USER_ID,
                                                 p_CREATED_BY                => Fnd_Global.USER_ID,
                                                 p_LAST_UPDATE_LOGIN         => Fnd_Global.USER_ID,
                                                 p_ITEM_COST                 => x_estimate_line_rec.item_cost,
                                                 p_RESOURCE_ID               => x_estimate_line_rec.resource_id,
                                                 p_OVERRIDE_CHARGE_FLAG      => x_estimate_line_rec.override_charge_flag,
                                                 p_JUSTIFICATION_NOTES       => x_estimate_line_rec.justification_notes,
                                                 p_ATTRIBUTE1                => x_estimate_line_rec.ATTRIBUTE1,
                                                 p_ATTRIBUTE2                => x_estimate_line_rec.ATTRIBUTE2,
                                                 p_ATTRIBUTE3                => x_estimate_line_rec.ATTRIBUTE3,
                                                 p_ATTRIBUTE4                => x_estimate_line_rec.ATTRIBUTE4,
                                                 p_ATTRIBUTE5                => x_estimate_line_rec.ATTRIBUTE5,
                                                 p_ATTRIBUTE6                => x_estimate_line_rec.ATTRIBUTE6,
                                                 p_ATTRIBUTE7                => x_estimate_line_rec.ATTRIBUTE7,
                                                 p_ATTRIBUTE8                => x_estimate_line_rec.ATTRIBUTE8,
                                                 p_ATTRIBUTE9                => x_estimate_line_rec.ATTRIBUTE9,
                                                 p_ATTRIBUTE10               => x_estimate_line_rec.ATTRIBUTE10,
                                                 p_ATTRIBUTE11               => x_estimate_line_rec.ATTRIBUTE11,
                                                 p_ATTRIBUTE12               => x_estimate_line_rec.ATTRIBUTE12,
                                                 p_ATTRIBUTE13               => x_estimate_line_rec.ATTRIBUTE13,
                                                 p_ATTRIBUTE14               => x_estimate_line_rec.ATTRIBUTE14,
                                                 p_ATTRIBUTE15               => x_estimate_line_rec.ATTRIBUTE15,
                                                 p_CONTEXT                   => x_estimate_line_rec.CONTEXT,
                                                 p_OBJECT_VERSION_NUMBER     => l_obj_ver_num + 1,
                                                 p_EST_LINE_SOURCE_TYPE_CODE => x_estimate_line_rec.EST_LINE_SOURCE_TYPE_CODE,
                                                 p_EST_LINE_SOURCE_ID1       => x_estimate_line_rec.EST_LINE_SOURCE_ID1,
                                                 p_EST_LINE_SOURCE_ID2       => x_estimate_line_rec.EST_LINE_SOURCE_ID2,
                                                 p_RO_SERVICE_CODE_ID        => x_estimate_line_rec.RO_SERVICE_CODE_ID);

        x_estimate_line_rec.object_version_number := l_obj_ver_num + 1;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO update_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_repair_estimate_lines;

    /*--------------------------------------------------*/
    /* procedure name: delete_repair_estimate_lines     */
    /* description   : procedure used to delete         */
    /*                 repair estimate lines            */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE DELETE_REPAIR_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                           p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                           p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                           p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                           p_estimate_line_id IN NUMBER,
                                           x_return_status    OUT NOCOPY VARCHAR2,
                                           x_msg_count        OUT NOCOPY NUMBER,
                                           x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_REPAIR_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(100);
        l_msg_index          NUMBER;
        l_Charges_Rec        Cs_Charge_Details_Pub.charges_rec_type;
        x_estimate_detail_id NUMBER;
        l_est_detail_id      NUMBER;
        l_delete_allow       VARCHAR2(1);

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT delete_repair_estimate_lines;

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

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter: Estimate Line Id ');
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Repair Estimate Line Id  =' ||
                                    p_estimate_line_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_line_id,
                                          p_param_name  => 'REPAIR_ESTIMATE_LINE_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair estimate line id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_estimate_line_id(p_estimate_line_id => p_estimate_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('check if rocord is allowed to delete');
        END IF;

        -- The estimate line is allowed to delete
        -- only if it is not interfaced
        BEGIN
            SELECT a.estimate_detail_id
              INTO l_est_detail_id
              FROM CSD_REPAIR_ESTIMATE_LINES a, cs_estimate_details b
             WHERE a.estimate_detail_id = b.estimate_detail_id
               AND a.repair_estimate_line_id = p_estimate_line_id
               AND b.order_header_id IS NULL;
            l_delete_allow := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_delete_allow := 'N';
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Estimate Line is interfaced,so it cannot be deleted');
                END IF;

                Fnd_Message.SET_NAME('CSD', 'CSD_API_DELETE_NOT_ALLOWED');
                Fnd_Message.SET_TOKEN('REPAIR_ESTIMATE_LINE_ID',
                                      p_estimate_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_delete_allow     =' ||
                                    l_delete_allow);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Estimate Detail Id =' ||
                                    l_est_detail_id);
        END IF;

        IF l_delete_allow = 'Y'
        THEN

            l_Charges_Rec.estimate_detail_id := l_est_detail_id;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call process_estimate_lines to delete');
            END IF;

            process_estimate_lines(p_api_version      => 1.0,
                                   p_commit           => Fnd_Api.g_false,
                                   p_init_msg_list    => Fnd_Api.g_true,
                                   p_validation_level => Fnd_Api.g_valid_level_full,
                                   p_action           => 'DELETE',
                                   x_Charges_Rec      => l_Charges_Rec,
                                   x_return_status    => x_return_status,
                                   x_msg_count        => x_msg_count,
                                   x_msg_data         => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call csd_product_transactions_pkg.Delete_Row');
            END IF;

            Csd_Repair_Estimate_Lines_Pkg.Delete_Row(p_REPAIR_ESTIMATE_LINE_ID => p_estimate_line_id);

        END IF; --end of delete

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO delete_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_repair_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END delete_repair_estimate_lines;

    /*--------------------------------------------------*/
    /* procedure name: lock_repair_estimate_lines       */
    /* description   : procedure used to create         */
    /*                 repair estimate lines            */
    /*--------------------------------------------------*/

    PROCEDURE LOCK_REPAIR_ESTIMATE_LINES(p_api_version       IN NUMBER,
                                         p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                         p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_false,
                                         p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                         p_estimate_line_rec IN REPAIR_ESTIMATE_LINE_REC,
                                         x_return_status     OUT NOCOPY VARCHAR2,
                                         x_msg_count         OUT NOCOPY NUMBER,
                                         x_msg_data          OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_REPAIR_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count NUMBER;
        l_msg_data  VARCHAR2(100);
        l_msg_index NUMBER;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT lock_repair_estimate_lines;

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

        Csd_Repair_Estimate_Lines_Pkg.Lock_Row(p_REPAIR_ESTIMATE_LINE_ID => p_estimate_line_rec.repair_estimate_line_id,
                                               p_OBJECT_VERSION_NUMBER   => p_estimate_line_rec.object_version_number);

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO lock_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO lock_repair_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO lock_repair_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END lock_repair_estimate_lines;

    PROCEDURE REPAIR_ESTIMATE_PRINT(p_api_version      IN NUMBER,
                                    p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                    p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                    p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                    p_repair_line_id   IN NUMBER,
                                    x_request_id       OUT NOCOPY NUMBER,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'REPAIR_ESTIMATE_PRINT';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(200);
        l_msg_index      NUMBER;
        l_est_count      NUMBER := 0;
        l_request_id     NUMBER := 0;  -- valase :6499519
        l_submit_Status  BOOLEAN;
        l_printer_name   VARCHAR2(80);
        l_print_required VARCHAR2(10);
        -- valase: 6499519  below
        l_layout_status  BOOLEAN;
        l_print_mode     VARCHAR2(30);
        l_xdo_conc_name  VARCHAR(30);
        l_template_code  VARCHAR(80);
        l_language       VARCHAR(2);
        l_territory      VARCHAR(2);
        CURSOR get_default_template_name(p_xdo_conc_name IN VARCHAR) IS
            SELECT template_code
              FROM fnd_concurrent_programs
             WHERE concurrent_program_name = p_xdo_conc_name; -- case sensitive
		                                                    -- user must input con code with exactly as defined
        CURSOR get_lang_terr IS
            SELECT lower(iso_language), iso_territory
              FROM fnd_languages
             WHERE language_code = userenv('LANG');
        -- valase:6499519 , above
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT estimate_print;
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
        -- start of the concurrent submission
        l_printer_name := Fnd_Profile.value('CSD_PRINTER_NAME');
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_printer_name =' || l_printer_name);
        END IF;
        -- Check if the printer setup is required
        -- l_print_required := fnd_profile.value('CSD_EST_PRINTER_REQ');
        -- For bugfix 3398079. vkjain.
        -- The profile name was misspelt.
        l_print_required := Fnd_Profile.value('CSD_PRINTER_REQ');
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_print_required =' ||
                                    l_print_required);
        END IF;
        -- Check for the printer setup
        IF l_printer_name IS NOT NULL
        THEN
            l_submit_status := Fnd_Request.set_print_options(printer        => l_printer_name,
                                                             style          => 'PORTRAIT',
                                                             copies         => 1,
                                                             save_output    => TRUE,
                                                             print_together => 'N');
            IF l_submit_status
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Set Print Option successfull');
                END IF;
            ELSE
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Set Print Option Failed');
                END IF;
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_PRINT_OPTION_ERROR');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
                Fnd_Msg_Pub.ADD;
            END IF;
        ELSIF (l_print_required = 'Y')
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_NOPRINTER_SETUP');
            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
            Fnd_Msg_Pub.ADD;
        END IF;
        -- valase:6499519, rfieldma: 6532016  below
        -- get print mode
        l_print_mode := FND_PROFILE.value('CSD_ESTRT_PRINT_MODE');

        IF (l_print_mode is not null and l_print_mode <> 'ORAPT' ) THEN -- one of the XDO output types
            --get concurrent name
            l_xdo_conc_name :=FND_PROFILE.value('CSD_CUST_ESTRT_CON_NAME');
            IF l_xdo_conc_name is null THEN
                l_xdo_conc_name := 'CSDERT';
            END IF;
            -- get default template code
            OPEN get_default_template_name(l_xdo_conc_name);
            FETCH get_default_template_name
             INTO l_template_code;
            CLOSE get_default_template_name;
            -- no default tempalte defined, raise error
            IF (l_template_code is null) THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_XDO_ESTRT_NO_TEMPLATE');
                Fnd_Message.SET_TOKEN('PROF_NAME', csd_repairs_util.get_user_profile_option_name('CSD_CUST_ESTRT_CON_NAME'));
                x_request_id := l_request_id;
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            -- get current session language and territory
            OPEN get_lang_terr;
            FETCH get_lang_terr
             INTO l_language, l_territory;
            CLOSE get_lang_terr;

            -- XML publisher report
            -- set layout
            l_layout_status := Fnd_Request.add_layout('CSD', --template_appl_name
                                                       l_template_code, --'CSD_XDOESTRT_RTF', --template_code
                                                       l_language, --'en', 'ja',  --template_language
                                                       l_territory, --'US', 'JP' --template_territory
                                                       l_print_mode --output_format
                                                     );
            -- Submit the Concurrent Program
            l_request_id := Fnd_Request.submit_request('CSD',
                                                        l_xdo_conc_name,
                                                       'Depot Repair Estimate Report',
                                                        NULL,
                                                        FALSE,
                                                        p_repair_line_id);
        ELSE -- not defined or ORAPT (oracle reports)
             -- print in Oracle report format
             -- Submit the Concurrent Program
            l_request_id := Fnd_Request.submit_request('CSD',
                                                       'CSDESTRT',
                                                       'Depot Repair Estimate Report',
                                                        NULL,
                                                        FALSE,
                                                        p_repair_line_id);
        END IF;
        -- valase:6499519  above
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Concurrent request Id =' ||
                                    TO_CHAR(l_request_id));
        END IF;
        IF (l_request_id <> 0)
        THEN
            COMMIT;
        END IF;
        x_request_id := l_request_id;
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO estimate_print;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO estimate_print;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO estimate_print;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END REPAIR_ESTIMATE_PRINT;

    PROCEDURE SUBMIT_REPAIR_ESTIMATE_LINES(p_api_version      IN NUMBER,
                                           p_commit           IN VARCHAR2,
                                           p_init_msg_list    IN VARCHAR2,
                                           p_validation_level IN NUMBER,
                                           p_repair_line_id   IN NUMBER,
                                           x_return_status    OUT NOCOPY VARCHAR2,
                                           x_msg_count        OUT NOCOPY NUMBER,
                                           x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'SUBMIT_REPAIR_ESTIMATE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_estimate_detail_id  NUMBER;
        l_order_header_id     NUMBER;
        l_msg_count           NUMBER;
        l_msg_data            VARCHAR2(200);
        l_msg_index           NUMBER;
        l_incident_id         NUMBER := NULL;
        l_party_id            NUMBER := NULL;
        l_order_category_code VARCHAR2(30);
        l_account_id          NUMBER := NULL;
        l_add_to_same_order   BOOLEAN := TRUE;
        l_last_est_detail_id  NUMBER := NULL;
        l_order_number        VARCHAR2(30) := '';
        l_org_src_ref         VARCHAR2(30) := '';
        l_org_src_header_id   NUMBER;
        l_orig_po_num         VARCHAR2(50);

        l_est_line_rec Cs_Charge_Details_Pub.Charges_Rec_Type;

        CURSOR ESTIMATE(p_rep_line_id IN NUMBER) IS
            SELECT ced.estimate_detail_id, ced.purchase_order_num
              FROM CSD_REPAIR_ESTIMATE       cre,
                   CSD_REPAIR_ESTIMATE_LINES crel,
                   cs_estimate_details       ced
             WHERE cre.repair_line_id = p_rep_line_id
               AND cre.repair_estimate_id = crel.repair_estimate_id
               AND crel.estimate_detail_id = ced.estimate_detail_id
               AND ced.order_header_id IS NULL
               AND ced.interface_to_oe_flag = 'N';

    BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT submit_estimate_lines;

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

        BEGIN
            SELECT original_source_header_id, original_source_reference
              INTO l_org_src_header_id, l_org_src_ref
              FROM CSD_REPAIRS
             WHERE repair_line_id = p_repair_line_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF l_org_src_ref = 'RMA'
        THEN

            BEGIN
                SELECT header_id
                  INTO l_order_header_id
                  FROM oe_order_headers_all ooh, oe_order_types_v oot
                 WHERE ooh.order_type_id = oot.order_type_id
                   AND ooh.header_id = l_org_src_header_id
                   AND oot.order_category_code IN ('MIXED', 'ORDER');
                l_add_to_same_order := TRUE;
            EXCEPTION
                WHEN OTHERS THEN
                    l_add_to_same_order := FALSE;
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('in others exception ');
                    END IF;
            END;

        ELSE

            -- Take any sales order of order type either Mixed or order
            -- and add to the sales order
            BEGIN
                SELECT MAX(ced.order_header_id)
                  INTO l_order_header_id
                  FROM CSD_PRODUCT_TRANSACTIONS cpt,
                       cs_estimate_details      ced,
                       oe_order_headers_all     ooh,
                       oe_order_types_v         oot
                 WHERE ooh.order_type_id = oot.order_type_id
                   AND ooh.header_id = ced.order_header_id
                   AND oot.order_category_code IN ('MIXED', 'ORDER')
                   AND cpt.estimate_detail_id = ced.estimate_detail_id
                   AND cpt.repair_line_id = p_repair_line_id
                   AND ced.order_header_id IS NOT NULL
                   AND ced.interface_to_oe_flag = 'Y';
            EXCEPTION
                WHEN OTHERS THEN
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('in others exception ');
                    END IF;
            END;

            IF l_order_header_id = 0
            THEN
                l_add_to_same_order := FALSE;
            ELSE
                l_add_to_same_order := TRUE;
            END IF;

        END IF;

        -- updating the estimate with the interface_to_oe_flag
        FOR est IN estimate(p_repair_line_id)
        LOOP

            l_est_line_rec.estimate_detail_id   := est.estimate_detail_id;
            l_est_line_rec.interface_to_oe_flag := 'Y';
            l_last_est_detail_id                := est.estimate_detail_id;

            IF l_add_to_same_order
            THEN
                l_est_line_rec.add_to_order_flag := 'Y';
                IF l_org_src_ref = 'RMA'
                THEN
                    l_est_line_rec.order_header_id := l_org_src_header_id;
                ELSE
                    l_est_line_rec.order_header_id := l_order_header_id;
                END IF;
                --
                --  Fix for forward port bug # 2826897
                --
                IF est.purchase_order_num IS NOT NULL
                THEN
                    BEGIN
                        SELECT ced.purchase_order_num
                          INTO l_orig_po_num
                          FROM CSD_PRODUCT_TRANSACTIONS cpt,
                               cs_estimate_details      ced
                         WHERE cpt.estimate_detail_id =
                               ced.estimate_detail_id
                           AND cpt.repair_line_id = p_repair_line_id
                           AND ced.order_header_id =
                               l_est_line_rec.order_header_id
                           AND ced.purchase_order_num =
                               est.purchase_order_num;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_est_line_rec.add_to_order_flag := 'F';
                            l_est_line_rec.order_header_id   := Fnd_Api.G_MISS_NUM;
                        WHEN TOO_MANY_ROWS THEN
                            NULL;
                    END;
                END IF;
            ELSE
                l_est_line_rec.add_to_order_flag := 'F';
                l_est_line_rec.order_header_id   := Fnd_Api.G_MISS_NUM;
            END IF;
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Updating estimate lines  with add to order flag for estimate_detail_id = ' ||
                                        est.estimate_detail_id);
            END IF;

            Csd_Process_Pvt.PROCESS_CHARGE_LINES(p_api_version        => 1.0,
                                                 p_commit             => Fnd_Api.g_false,
                                                 p_init_msg_list      => Fnd_Api.g_true,
                                                 p_validation_level   => Fnd_Api.g_valid_level_full,
                                                 p_action             => 'UPDATE',
                                                 p_Charges_Rec        => l_est_line_rec,
                                                 x_estimate_detail_id => l_estimate_detail_id,
                                                 x_return_status      => x_return_status,
                                                 x_msg_count          => x_msg_count,
                                                 x_msg_data           => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        END LOOP;

        BEGIN
            SELECT cia.incident_id, cia.customer_id, cia.account_id
              INTO l_incident_id, l_party_id, l_account_id
              FROM cs_incidents_all_b cia, CSD_REPAIRS cr
             WHERE cia.incident_id = cr.incident_id
               AND cr.repair_line_id = p_repair_line_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Creating the Sales Order');
            Csd_Gen_Utility_Pvt.ADD('l_incident_id    =' || l_incident_id);
            Csd_Gen_Utility_Pvt.ADD('l_party_id       =' || l_party_id);
            Csd_Gen_Utility_Pvt.ADD('l_account_id     =' || l_account_id);
        END IF;

        Cs_Charge_Create_Order_Pub.Submit_Order(p_api_version      => 1.0,
                                                p_init_msg_list    => 'T',
                                                p_commit           => 'F',
                                                p_validation_level => Fnd_Api.g_valid_level_full,
                                                p_incident_id      => l_incident_id,
                                                p_party_id         => l_party_id,
                                                p_account_id       => l_account_id,
                                                p_book_order_flag  => 'N',
                                                x_return_status    => x_return_status,
                                                x_msg_count        => x_msg_count,
                                                x_msg_data         => x_msg_data);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        BEGIN
            SELECT oe.order_number
              INTO l_order_number
              FROM oe_order_headers_all oe, cs_estimate_details ced
             WHERE oe.header_id = ced.order_header_id
               AND ced.estimate_detail_id = l_last_est_detail_id;
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_ORDER_NUMBER');
            Fnd_Message.SET_TOKEN('ORDER_NUMBER', l_order_number);
            Fnd_Msg_Pub.ADD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_NOT_INTERFACED');
                Fnd_Msg_Pub.ADD;
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Estimate not interfaced to OM ');
                END IF;
        END;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO submit_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO submit_estimate_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO submit_estimate_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END SUBMIT_REPAIR_ESTIMATE_LINES;

    --
    -- swai 11.5.10
    -- new apis
    --
    /*--------------------------------------------------*/
    /* procedure name: get_total_estimated_charge       */
    /* description   : given a repair line id, returns  */
    /*                 the total charge (includes any   */
    /*                 contract calculations)  If no    */
    /*                 estimate lines for the repair    */
    /*                 line, return null.               */
    /*--------------------------------------------------*/

    PROCEDURE get_total_estimated_charge(p_repair_line_id   IN NUMBER,
                                         x_estimated_charge OUT NOCOPY NUMBER,
                                         x_return_status    OUT NOCOPY VARCHAR2) IS
        lc_debug_level CONSTANT NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
        lc_stat_level  CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
        lc_proc_level  CONSTANT NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        lc_event_level CONSTANT NUMBER := Fnd_Log.LEVEL_EVENT;
        lc_excep_level CONSTANT NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        lc_error_level CONSTANT NUMBER := Fnd_Log.LEVEL_ERROR;
        lc_unexp_level CONSTANT NUMBER := Fnd_Log.LEVEL_UNEXPECTED;
        lc_mod_name    CONSTANT VARCHAR2(100) := 'csd.plsql.csd_repair_estimate_pvt.get_total_estimated_charge';
    BEGIN
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.BEGIN',
                           'Entered get_total_estimated_charge');
        END IF;

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        SELECT SUM(NVL(charge, 0))
          INTO x_estimated_charge
          FROM csd_repair_estimate_lines_v
         WHERE repair_line_id = p_repair_line_id
           AND billing_type IN ('M', 'L', 'E');

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || 'out_parameter',
                           'x_estimated_charge: ' || x_estimated_charge);
        END IF;
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.END',
                           'Leaving get_total_estimated_charge');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status    := Fnd_Api.G_RET_STS_ERROR;
            x_estimated_charge := NULL;
        WHEN OTHERS THEN
            x_return_status    := Fnd_Api.G_RET_STS_ERROR;
            x_estimated_charge := NULL;
    END; -- PROCEDURE get_total_estimated_charge

    /*--------------------------------------------------*/
    /* procedure name: Autocreate_Estimate_Lines        */
    /* description   : The main procedure that is       */
    /*                 triggered by the click of the    */
    /*                 button on the `Estimates' tab.   */
    /*                 Creates all the estimate lines   */
    /*                 for TASK or BOM.                 */
    /*                                                  */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Depot Repair UI                    */
    /*--------------------------------------------------*/

    PROCEDURE Autocreate_Estimate_Lines(p_api_version         IN NUMBER,
                                        p_commit              IN VARCHAR2,
                                        p_init_msg_list       IN VARCHAR2,
                                        p_validation_level    IN NUMBER,
                                        x_return_status       OUT NOCOPY VARCHAR2,
                                        x_msg_count           OUT NOCOPY NUMBER,
                                        x_msg_data            OUT NOCOPY VARCHAR2,
                                        p_repair_line_id      IN NUMBER,
                                        p_estimate_id         IN NUMBER, -- required
                                        p_repair_type_id      IN NUMBER, -- required
                                        p_business_process_id IN NUMBER, -- required
                                        p_currency_code       IN VARCHAR2, -- required
                                        p_incident_id         IN NUMBER, -- required
                                        p_repair_mode         IN VARCHAR2, -- required
                                        p_inventory_item_id   IN NUMBER, -- required
                                        p_organization_id     IN NUMBER, -- required
                                        x_warning_flag        OUT NOCOPY VARCHAR2) IS
        -- CONSTANTS --
        lc_debug_level CONSTANT NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
        lc_stat_level  CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
        lc_proc_level  CONSTANT NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        lc_event_level CONSTANT NUMBER := Fnd_Log.LEVEL_EVENT;
        lc_excep_level CONSTANT NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        lc_error_level CONSTANT NUMBER := Fnd_Log.LEVEL_ERROR;
        lc_unexp_level CONSTANT NUMBER := Fnd_Log.LEVEL_UNEXPECTED;
        lc_mod_name    CONSTANT VARCHAR2(100) := 'csd.plsql.csd_repair_estimate_pvt.autocreate_estimate_lines';
        lc_api_name    CONSTANT VARCHAR2(30) := 'Autocreate_Estimate_Lines';
        lc_api_version CONSTANT NUMBER := 1.0;

        -- VARIABLES --
        l_default_contract_line_id NUMBER := NULL;
        l_default_price_list_id    NUMBER := NULL;
        l_num_service_codes        NUMBER := 0;
        l_contract_validated       BOOLEAN;
        l_est_lines_tbl            CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_TBL;
        l_return_status            VARCHAR2(1);
        l_msg_count                NUMBER;
        l_msg_data                 VARCHAR2(200);
        l_estimate_line_id         NUMBER;
        l_ro_sc_rec_type           Csd_Ro_Service_Codes_Pvt.RO_SERVICE_CODE_REC_TYPE;
        l_obj_ver_number           NUMBER;
        l_prev_ro_sc_id            NUMBER;
        l_item_name                VARCHAR2(40);
        l_warning_flag             VARCHAR2(1) := Fnd_Api.G_FALSE;

        -- EXCEPTIONS --
        CSD_EST_SC_NO_APPL EXCEPTION; -- no service codes to apply
        CSD_EST_DEF_PL EXCEPTION; -- no default price list
        CSD_EST_INAPPL_MODE EXCEPTION; -- cannot apply service code for repair mode

        -- CURSORS --
        CURSOR c_ro_sc_obj_version(p_ro_service_code_id NUMBER) IS
            SELECT object_version_number
              FROM CSD_RO_SERVICE_CODES
             WHERE ro_service_code_id = p_ro_service_code_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Autocreate_Estimate_Lines;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(lc_api_version,
                                           p_api_version,
                                           lc_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.BEGIN',
                           'Entered Autocreate_Estimate_Lines');
        END IF;

        -- log parameters
        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_api_version: ' || p_api_version);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_commit: ' || p_commit);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_init_msg_list: ' || p_init_msg_list);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_validation_level: ' || p_validation_level);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_line_id: ' || p_repair_line_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_estimate_id: ' || p_estimate_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_type_id: ' || p_repair_type_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_business_process_id: ' ||
                           p_business_process_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_currency_code: ' || p_currency_code);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_incident_id: ' || p_incident_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_mode: ' || p_repair_mode);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_inventory_item_id: ' || p_inventory_item_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_organization_id: ' || p_organization_id);
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        --
        -- Begin API Body
        --

        -- initialize the warning flag
        x_warning_flag := Fnd_Api.G_FALSE;

        -- Check the required parameters
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Checking required parameters');
        END IF;

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_repair_line_id,
                                          p_param_name  => 'REPAIR_LINE_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_estimate_id,
                                          p_param_name  => 'ESTIMATE_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_repair_type_id,
                                          p_param_name  => 'REPAIR_TYPE_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_business_process_id,
                                          p_param_name  => 'BUSINESS_PROCESS_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_currency_code,
                                          p_param_name  => 'CURRENCY_CODE',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_incident_id,
                                          p_param_name  => 'INCIDENT_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_repair_mode,
                                          p_param_name  => 'REPAIR_MODE',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_inventory_item_id,
                                          p_param_name  => 'INVENTORY_ITEM_ID',
                                          p_api_name    => lc_api_name);

        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_organization_id,
                                          p_param_name  => 'ORGANIZATION_ID',
                                          p_api_name    => lc_api_name);

        -- Check number of service codes to get mle lines for
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Counting the number of service codes to apply');
        END IF;
        BEGIN
            SELECT COUNT(*)
              INTO l_num_service_codes
              FROM CSD_RO_SERVICE_CODES
             WHERE repair_line_id = p_repair_line_id
               AND NVL(applicable_flag, 'N') = 'Y'
               AND NVL(applied_to_est_flag, 'N') = 'N';
            -- Commented for bugfix 3473869.vkjain.
            -- and nvl(applied_to_work_flag, 'N') = 'N';
        EXCEPTION
            WHEN OTHERS THEN
                l_num_service_codes := 0;
        END;

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name,
                           'l_num_service_codes: ' || l_num_service_codes);
        END IF;

        -- if no applicable service codes, see if we need to
        -- raise an error
        IF (l_num_service_codes <= 0)
        THEN
            -- bug fix 3388891
            -- only give an error if it is wip or if
            -- in task mode profile option is not set to get tasks from soln
            IF (p_repair_mode = 'WIP') OR
               (NVL(Fnd_Profile.value('CSD_USE_TASK_FROM_SOLN'), 'N') = 'N')
            THEN
                RAISE CSD_EST_SC_NO_APPL;
            END IF;
        END IF;

        -- Get default Contract.
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Calling CSD_CHARGE_LINE_UTIL.Get_DefaultContract');
        END IF;

        l_default_contract_line_id := Csd_Charge_Line_Util.Get_DefaultContract(p_repair_line_id);

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            -- log results from previous call
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Returned from CSD_CHARGE_LINE_UTIL.Get_DefaultContract');
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'l_default_contract_line_id = ' ||
                           l_default_contract_line_id);
            -- log the next call
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'calling CSD_CHARGE_LINE_UTIL.Get_RO_PriceList');
        END IF;

        l_default_price_list_id := Csd_Charge_Line_Util.Get_RO_PriceList(p_repair_line_id);
        IF l_default_price_list_id IS NULL
        THEN
            RAISE CSD_EST_DEF_PL;
        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            -- log results from previous call
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Returned from CSD_CHARGE_LINE_UTIL.Get_RO_PriceList');
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'l_default_price_list_id = ' ||
                           l_default_price_list_id);
            -- log the next call
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Calling CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
        END IF;

        -- initialize local return status before calling procedures
        l_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- purge any existing messages before processing
        -- Module ACT (source entity ESTIMATE).
        Csd_Gen_Errmsgs_Pvt.purge_entity_msgs(p_api_version             => 1.0,
                                              p_commit                  => Fnd_Api.G_TRUE,
                                              p_init_msg_list           => Fnd_Api.G_FALSE,
                                              p_validation_level        => Fnd_Api.G_VALID_LEVEL_FULL,
                                              p_module_code             => 'EST',
                                              p_source_entity_id1       => p_repair_line_id,
                                              p_source_entity_type_code => NULL,
                                              p_source_entity_id2       => NULL,
                                              x_return_status           => l_return_status,
                                              x_msg_count               => l_msg_count,
                                              x_msg_data                => l_msg_data);
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Returned from CSD_GEN_ERRMSGS_PVT.purge_entity_msgs');
        END IF;
        IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Now, get info for estimate lines into l_est_lines_tbl
        IF p_repair_mode = 'TASK'
        THEN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Calling CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_Task');
            END IF;
            Get_Estimates_From_Task(p_api_version         => 1.0,
                                    p_commit              => p_commit,
                                    p_init_msg_list       => Fnd_Api.G_FALSE,
                                    p_validation_level    => p_validation_level,
                                    x_return_status       => l_return_status,
                                    x_msg_count           => l_msg_count,
                                    x_msg_data            => l_msg_data,
                                    p_repair_line_id      => p_repair_line_id,
                                    p_estimate_id         => p_estimate_id,
                                    p_repair_type_id      => p_repair_type_id,
                                    p_business_process_id => p_business_process_id,
                                    p_currency_code       => p_currency_code,
                                    p_incident_id         => p_incident_id,
                                    p_repair_mode         => p_repair_mode,
                                    p_inventory_item_id   => p_inventory_item_id,
                                    p_organization_id     => p_organization_id,
                                    p_price_list_id       => l_default_price_list_id,
                                    p_contract_line_id    => l_default_contract_line_id,
                                    x_est_lines_tbl       => l_est_lines_tbl,
                                    x_warning_flag        => l_warning_flag);
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Returned from CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_Task');
            END IF;
        ELSIF p_repair_mode = 'WIP'
        THEN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Calling CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_BOM');
            END IF;
            Get_Estimates_From_BOM(p_api_version         => 1.0,
                                   p_commit              => p_commit,
                                   p_init_msg_list       => Fnd_Api.G_FALSE,
                                   p_validation_level    => p_validation_level,
                                   x_return_status       => l_return_status,
                                   x_msg_count           => l_msg_count,
                                   x_msg_data            => l_msg_data,
                                   p_repair_line_id      => p_repair_line_id,
                                   p_estimate_id         => p_estimate_id,
                                   p_repair_type_id      => p_repair_type_id,
                                   p_business_process_id => p_business_process_id,
                                   p_currency_code       => p_currency_code,
                                   p_incident_id         => p_incident_id,
                                   p_repair_mode         => p_repair_mode,
                                   p_inventory_item_id   => p_inventory_item_id,
                                   p_organization_id     => p_organization_id,
                                   p_price_list_id       => l_default_price_list_id,
                                   p_contract_line_id    => l_default_contract_line_id,
                                   x_est_lines_tbl       => l_est_lines_tbl,
                                   x_warning_flag        => l_warning_flag);
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Returned from CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_BOM');
            END IF;
        ELSE
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Unknown Repair Mode: ' || p_repair_mode);
            END IF;
            RAISE CSD_EST_INAPPL_MODE;
        END IF;

        -- Loop through the estimates table of records and insert into Estimate lines and Charge lines.
        IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        ELSE
            -- if any warnings were raised already, then save them
            -- before attempting to create estimate lines
            IF (l_warning_flag = Fnd_Api.G_TRUE)
            THEN
                x_warning_flag := l_warning_flag;
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Calling CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Number of messages in stack: ' ||
                                   Fnd_Msg_Pub.count_msg);
                END IF;
                Csd_Gen_Errmsgs_Pvt.Save_Fnd_Msgs(p_api_version             => 1.0,
                                                  p_commit                  => Fnd_Api.G_FALSE,
                                                  p_init_msg_list           => Fnd_Api.G_FALSE,
                                                  p_validation_level        => 0,
                                                  p_module_code             => 'EST',
                                                  p_source_entity_id1       => p_repair_line_id,
                                                  p_source_entity_type_code => 'ESTIMATE',
                                                  p_source_entity_id2       => p_estimate_id,
                                                  x_return_status           => l_return_status,
                                                  x_msg_count               => l_msg_count,
                                                  x_msg_data                => l_msg_data);
                IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Returned from CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Number of messages in stack: ' ||
                                   Fnd_Msg_Pub.count_msg);
                END IF;
            END IF;

            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Creating repair estimate lines');
            END IF;
            FOR i IN 1 .. l_est_lines_tbl.COUNT
            LOOP
                BEGIN
                    IF (Fnd_Log.Level_Statement >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                       lc_mod_name,
                                       'Calling create_repair_estimate_lines for line ' || i);
                    END IF;
                    create_repair_estimate_lines(p_api_version       => 1.0,
                                                 p_commit            => Fnd_Api.G_FALSE,
                                                 p_init_msg_list     => Fnd_Api.G_FALSE,
                                                 p_validation_level  => 0,
                                                 x_estimate_line_rec => l_est_lines_tbl(i),
                                                 x_estimate_line_id  => l_estimate_line_id, -- throw away
                                                 x_return_status     => l_return_status,
                                                 x_msg_count         => l_msg_count,
                                                 x_msg_data          => l_msg_data);
                EXCEPTION
                    WHEN Fnd_Api.G_EXC_ERROR THEN
                        l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    WHEN OTHERS THEN
                        l_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                END;

                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'x_estimate_line_rec = ' ||
                                   TO_CHAR(l_est_lines_tbl(i)
                                           .repair_estimate_line_id));
                    -- FND_LOG.STRING(Fnd_Log.Level_Procedure, lc_mod_name,
                    --               'x_return_status = '||l_return_status);
                END IF;

                -- If SC have been applied to create estimate lines successfully,
                -- make sure to update CSD_RO_SERVICE_CODES table with the value `Y' for the
                -- column that indicates `applied to estimates'.
                IF (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    -- if previous ro_sc_id is same as current, no need to update
                    -- ro_service_code id, since it should have been done already
                    IF (NVL(l_prev_ro_sc_id, -999) <>
                       NVL(l_est_lines_tbl(i).RO_SERVICE_CODE_ID, -999)) AND
                       (l_est_lines_tbl(i).RO_SERVICE_CODE_ID IS NOT NULL)
                    THEN

                        IF (Fnd_Log.Level_Statement >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'l_prev_ro_sc_id = ' ||
                                           TO_CHAR(l_prev_ro_sc_id));
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'l_est_lines_tbl(i).RO_SERVICE_CODE_ID = ' ||
                                           TO_CHAR(l_est_lines_tbl(i)
                                                   .RO_SERVICE_CODE_ID));
                        END IF;

                        l_ro_sc_rec_type.ro_service_code_id  := l_est_lines_tbl(i)
                                                               .RO_SERVICE_CODE_ID;
                        l_ro_sc_rec_type.applied_to_est_flag := 'Y';
                        OPEN c_ro_sc_obj_version(l_est_lines_tbl(i)
                                                 .RO_SERVICE_CODE_ID);
                        FETCH c_ro_sc_obj_version
                            INTO l_ro_sc_rec_type.object_version_number;
                        CLOSE c_ro_sc_obj_version;

                        IF (Fnd_Log.Level_Procedure >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                           lc_mod_name,
                                           'Calling CSD_RO_SERVICE_CODES_PVT.Update_RO_Service_Code');
                        END IF;
                        Csd_Ro_Service_Codes_Pvt.Update_RO_Service_Code(p_api_version         => 1.0,
                                                                        p_commit              => Fnd_Api.G_FALSE,
                                                                        p_init_msg_list       => Fnd_Api.G_FALSE,
                                                                        p_validation_level    => 0,
                                                                        p_ro_service_code_rec => l_ro_sc_rec_type,
                                                                        x_obj_ver_number      => l_obj_ver_number,
                                                                        x_return_status       => l_return_status,
                                                                        x_msg_count           => l_msg_count,
                                                                        x_msg_data            => l_msg_data);

                        IF (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                        THEN
                            l_prev_ro_sc_id := l_est_lines_tbl(i)
                                              .RO_SERVICE_CODE_ID;
                        ELSE
                            -- not able to update csd_ro_service_codes table to set as applied to est
                            x_warning_flag := Fnd_Api.G_TRUE;
                            IF (Fnd_Log.Level_Statement >=
                               Fnd_Log.G_Current_Runtime_Level)
                            THEN
                                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                               lc_mod_name,
                                               'Adding message CSD_EST_SC_APPLIED_ERR to FND_MSG stack');
                            END IF;
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_EST_SC_APPLIED_ERR');
                            Fnd_Msg_Pub.ADD;
                            IF (Fnd_Log.Level_Procedure >=
                               Fnd_Log.G_Current_Runtime_Level)
                            THEN
                                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                               lc_mod_name,
                                               'Calling CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                               lc_mod_name,
                                               'Number of messages in stack: ' ||
                                               Fnd_Msg_Pub.count_msg);
                            END IF;
                            Csd_Gen_Errmsgs_Pvt.Save_Fnd_Msgs(p_api_version             => 1.0,
                                                              p_commit                  => Fnd_Api.G_FALSE,
                                                              p_init_msg_list           => Fnd_Api.G_FALSE,
                                                              p_validation_level        => 0,
                                                              p_module_code             => 'EST',
                                                              p_source_entity_id1       => p_repair_line_id,
                                                              p_source_entity_type_code => l_est_lines_tbl(i)
                                                                                          .est_line_source_type_code,
                                                              p_source_entity_id2       => l_est_lines_tbl(i)
                                                                                          .est_line_source_id1,
                                                              x_return_status           => l_return_status,
                                                              x_msg_count               => l_msg_count,
                                                              x_msg_data                => l_msg_data);
                            IF NOT
                                (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                            THEN
                                RAISE Fnd_Api.G_EXC_ERROR;
                            END IF;
                            IF (Fnd_Log.Level_Procedure >=
                               Fnd_Log.G_Current_Runtime_Level)
                            THEN
                                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                               lc_mod_name,
                                               'Returned from CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                               lc_mod_name,
                                               'Number of messages in stack: ' ||
                                               Fnd_Msg_Pub.count_msg);
                            END IF;
                        END IF;
                    END IF;
                ELSE
                    -- not able to create repair estimate line from record in table
                    -- log a warning and save the error messages.
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Unable to create repair estimate line for index ' || i);
                    END IF;

                    x_warning_flag := Fnd_Api.G_TRUE;
                    BEGIN
                        SELECT concatenated_segments
                          INTO l_item_name
                          FROM mtl_system_items_kfv
                         WHERE inventory_item_id = l_est_lines_tbl(i)
                        .inventory_item_id
                           AND organization_id = l_est_lines_tbl(i)
                        .organization_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_item_name := TO_CHAR(l_est_lines_tbl(i)
                                                   .inventory_item_id);
                        WHEN OTHERS THEN
                            l_item_name := TO_CHAR(l_est_lines_tbl(i)
                                                   .inventory_item_id);
                    END;

                    IF (Fnd_Log.Level_Statement >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                       lc_mod_name,
                                       'Adding message CSD_EST_LINE_CREATED_ERR to FND_MSG stack');
                    END IF;
                    Fnd_Message.SET_NAME('CSD', 'CSD_EST_LINE_CREATED_ERR');
                    Fnd_Message.SET_TOKEN('ITEM', l_item_name);
                    Fnd_Msg_Pub.ADD;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Calling CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Number of messages in stack: ' ||
                                       Fnd_Msg_Pub.count_msg);
                    END IF;
                    Csd_Gen_Errmsgs_Pvt.Save_Fnd_Msgs(p_api_version             => 1.0,
                                                      p_commit                  => Fnd_Api.G_FALSE,
                                                      p_init_msg_list           => Fnd_Api.G_FALSE,
                                                      p_validation_level        => 0,
                                                      p_module_code             => 'EST',
                                                      p_source_entity_id1       => p_repair_line_id,
                                                      p_source_entity_type_code => l_est_lines_tbl(i)
                                                                                  .est_line_source_type_code,
                                                      p_source_entity_id2       => l_est_lines_tbl(i)
                                                                                  .est_line_source_id1,
                                                      x_return_status           => l_return_status,
                                                      x_msg_count               => l_msg_count,
                                                      x_msg_data                => l_msg_data);
                    IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                    THEN
                        RAISE Fnd_Api.G_EXC_ERROR;
                    END IF;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Returned from CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Number of messages in stack: ' ||
                                       Fnd_Msg_Pub.count_msg);
                    END IF;
                END IF;
            END LOOP;

        END IF;
        --
        -- End API Body
        --

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.out_parameter',
                           'x_warning_flag: ' || x_warning_flag);
        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.END',
                           'Leaving Autocreate_Estimate_Lines');
        END IF;

    EXCEPTION
        WHEN CSD_EST_SC_NO_APPL THEN
            ROLLBACK TO Autocreate_Estimate_Lines;
            -- No service codes found to apply
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            x_warning_flag  := Fnd_Api.G_FALSE;

            -- save message in fnd stack
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Adding message CSD_EST_SC_NO_APPL to FND_MSG stack');
            END IF;
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_SC_NO_APPL');
            Fnd_Msg_Pub.ADD;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'No service codes found to apply');
            END IF;
        WHEN CSD_EST_DEF_PL THEN
            -- Unable to determine default pricelist
            ROLLBACK TO Autocreate_Estimate_Lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            x_warning_flag  := Fnd_Api.G_FALSE;

            -- save message in fnd stack
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Adding message CSD_EST_NO_DEF_PL to FND_MSG stack');
            END IF;
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_NO_DEF_PL');
            Fnd_Msg_Pub.ADD;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'Unable to determine default pricelist');
            END IF;

        WHEN CSD_EST_INAPPL_MODE THEN
            -- cannot apply service code for repair mode
            ROLLBACK TO Autocreate_Estimate_Lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            x_warning_flag  := Fnd_Api.G_FALSE;

            -- save message in fnd stack
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Adding message CSD_EST_INAPPL_MODE to FND_MSG stack');
            END IF;
            DECLARE
                l_repair_mode_name VARCHAR2(80) := '';
            BEGIN
                SELECT meaning
                  INTO l_repair_mode_name
                  FROM fnd_lookups
                 WHERE lookup_type = 'CSD_REPAIR_MODE'
                   AND lookup_code = p_repair_mode;
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_INAPPL_MODE');
                Fnd_Message.SET_TOKEN('MODE', l_repair_mode_name);
                Fnd_Msg_Pub.ADD;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_repair_mode_name := p_repair_mode;
            END;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'Cannot apply service code for repair mode');
            END IF;
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Autocreate_Estimate_Lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;

            /*
            -- TO DO: Add seeded err message
            -- save message in fnd stack
            if (Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) then
                FND_LOG.STRING(Fnd_Log.Level_Statement, lc_mod_name,
                               'Adding message err_name to FND_MSG stack');
            end if;
            FND_MESSAGE.SET_NAME('CSD','err_name');
            FND_MESSAGE.SET_TOKEN('toke_name', 'token_value');
            FND_MSG_PUB.ADD;
            */
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Autocreate_Estimate_Lines;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            ROLLBACK TO Autocreate_Estimate_Lines;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                -- create a seeded message
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'SQL Message[' || SQLERRM || ']');
            END IF;

    END Autocreate_Estimate_Lines;

    /*--------------------------------------------------*/
    /* procedure name: Get_Estimates_From_Task          */
    /* description   : Fetches ML lines for the tasks   */
    /*                 associated via Service Codes and */
    /*                 (optionally) Solution.           */
    /*                                                  */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Autocreate_Estimate_Lines          */
    /*--------------------------------------------------*/
    PROCEDURE Get_Estimates_From_Task(p_api_version         IN NUMBER,
                                      p_commit              IN VARCHAR2,
                                      p_init_msg_list       IN VARCHAR2,
                                      p_validation_level    IN NUMBER,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2,
                                      p_repair_line_id      IN NUMBER,
                                      p_estimate_id         IN NUMBER,
                                      p_repair_type_id      IN NUMBER,
                                      p_business_process_id IN NUMBER,
                                      p_currency_code       IN VARCHAR2,
                                      p_incident_id         IN NUMBER,
                                      p_repair_mode         IN VARCHAR2,
                                      p_inventory_item_id   IN NUMBER,
                                      p_organization_id     IN NUMBER,
                                      p_price_list_id       IN NUMBER,
                                      p_contract_line_id    IN NUMBER,
                                      x_est_lines_tbl       OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_TBL,
                                      x_warning_flag        OUT NOCOPY VARCHAR2) IS
        -- CONSTANTS --
        lc_debug_level CONSTANT NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
        lc_stat_level  CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
        lc_proc_level  CONSTANT NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        lc_event_level CONSTANT NUMBER := Fnd_Log.LEVEL_EVENT;
        lc_excep_level CONSTANT NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        lc_error_level CONSTANT NUMBER := Fnd_Log.LEVEL_ERROR;
        lc_unexp_level CONSTANT NUMBER := Fnd_Log.LEVEL_UNEXPECTED;
        lc_mod_name    CONSTANT VARCHAR2(100) := 'csd.plsql.csd_repair_estimate_pvt.get_estimates_from_task';
        lc_api_name    CONSTANT VARCHAR2(30) := 'Get_Estimates_From_Task';
        lc_api_version CONSTANT NUMBER := 1.0;

        -- VARIABLES --
        l_use_tasks_from_sol      VARCHAR(1);
        l_labor_inventory_item_id NUMBER;
        l_materials_from_sc_tbl   MLE_LINES_TBL_TYPE;
        l_labor_from_sc_tbl       MLE_LINES_TBL_TYPE;
        l_materials_from_sol_tbl  MLE_LINES_TBL_TYPE;
        l_labor_from_sol_tbl      MLE_LINES_TBL_TYPE;
        l_task_threshold          NUMBER;
        l_warning_flag            VARCHAR2(1);
        l_return_status           VARCHAR2(1);
        l_msg_count               NUMBER;
        l_msg_data                VARCHAR2(2000);

        -- bugfix 3543135, vkjain.
        l_No_Eligible_Lines BOOLEAN := TRUE;

        -- EXCEPTIONS --
        CSD_EST_NO_AUTOGEN EXCEPTION;

        -- CURSORS --

        /* bugfix 3468680. vkjain
           The selling price should be derived via API call instead of
           selecting from the query.
           The cursors are replaced by new ones.
           Following changes are made to the existing cursors -
           -- Cursors do not accept p_price_list_id as IN parameter anymore.
           -- They do not select the list_price from the QP view.
           -- The reference to QP view is removed from the FROM part of statements.
           -- All joins for the QP view commented in the WHERE clause.
           -- The selling price is derived in the Convert_to_est_lines procedure
              by calling CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE API.

          -- Cursor gets:
          -- Information to create material lines from task groups attached to
          -- srvice codes linked to the repair line id.
          cursor c_material_lines_from_sc (p_repair_line_id NUMBER,
                                          p_price_list_id  NUMBER) is
            SELECT b.inventory_item_id,
                   b.primary_uom_code uom,
                   b.manual_quantity manual_qty,
                   ceil(b.rollup_quantity_used/b.rollup_times_used) rollup_qty,
                   a.actual_times_used times_used,
                   c.list_price selling_price,
                   d.concatenated_segments item_name,
                   d.comms_nl_trackable_flag,
                   f.txn_billing_type_id,
                   'SERVICE_CODE' est_line_source_type_code,
                   ROSC.Service_code_id est_line_source_id1,
                   null est_line_source_id2,
                   ROSC.RO_Service_code_id
            FROM CSD_RO_SERVICE_CODES ROSC,
                 CSD_SERVICE_CODES_VL SC,
                 CSD_SC_WORK_ENTITIES WRK,
                 CSP_PRODUCT_TASKS a,
                 CSP_TASK_PARTS  b,
                 QP_PRICE_LIST_LINES_V c,
                 MTL_SYSTEM_ITEMS_KFV d,
                 CSD_REPAIR_TYPES_SAR e,
                 CS_TXN_BILLING_TYPES f,
                 JTF_TASK_TEMPLATES_VL g
            WHERE ROSC.repair_line_id = p_repair_line_id
                and ROSC.applicable_flag = 'Y'
                -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
                and ROSC.applied_to_est_flag = 'N'
                and WRK.Service_code_id = ROSC.Service_code_id
                and WRK.work_entity_type_code = 'TASK'
                and SC.Service_code_Id = ROSC.Service_code_id
                and nvl(SC.active_from, SYSDATE) <= SYSDATE
                and nvl(SC.active_to, SYSDATE) >= SYSDATE
                and g.task_group_id = WRK.work_entity_id1
                and a.task_template_id = g.task_template_id
                and a.product_id = p_inventory_item_id
                and b.product_task_id = a.product_task_id
                and (b.manual_quantity IS NOT NULL OR
                     b.rollup_quantity_used IS NOT NULL)
                and b.substitute_item IS NULL
                and c.price_list_id(+) = p_price_list_id
                and c.inventory_item_id(+) = b.inventory_item_id
                and c.unit_code(+) = b.primary_uom_code
                and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
                and d.inventory_item_id = b.inventory_item_id
                and d.organization_id = p_organization_id
                and e.repair_type_id = p_repair_type_id
                and f.txn_billing_type_id = e.txn_billing_type_id(+)
                and f.billing_type = d.material_billable_flag(+)
                and d.material_billable_flag IS NOT NULL;

          -- Cursor gets:
          -- Information to create labor lines from task groups attached to
          -- service codes linked to the repair line id.
          cursor c_labor_lines_from_sc (p_repair_line_id NUMBER,
                                        p_price_list_id  NUMBER,
                                        p_labor_inventory_item_id NUMBER) is
                SELECT p_labor_inventory_item_id inventory_item_id,
                       b.planned_effort_uom uom,
                       b.planned_effort quantity,
                       c.list_price selling_price,
                       d.concatenated_segments item_name,
                       d.comms_nl_trackable_flag,
                       f.txn_billing_type_id,
                       'SERVICE_CODE' est_line_source_type_code,
                       ROSC.Service_code_id est_line_source_id1,
                       null est_line_source_id2,
                       ROSC.RO_Service_code_id
                FROM CSD_RO_SERVICE_CODES ROSC,
                     CSD_SERVICE_CODES_VL SC,
                     CSD_SC_WORK_ENTITIES WRK,
                     JTF_TASK_TEMPLATES_B  b,
                     QP_PRICE_LIST_LINES_V c,
                     MTL_SYSTEM_ITEMS_KFV d,
                     CSD_REPAIR_TYPES_SAR e,
                     CS_TXN_BILLING_TYPES f,
                     JTF_TASK_TEMPLATES_VL g
                WHERE ROSC.repair_line_id = p_repair_line_id
                    and ROSC.applicable_flag = 'Y'
                    -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
                    and ROSC.applied_to_est_flag = 'N'
                    and WRK.Service_code_id = ROSC.Service_code_id
                    and WRK.work_entity_type_code = 'TASK'
                    and SC.Service_code_Id = ROSC.Service_code_id
                    and nvl(SC.active_from, SYSDATE) <= SYSDATE
                    and nvl(SC.active_to, SYSDATE) >= SYSDATE
                    and g.task_group_id = WRK.work_entity_id1
                    and b.task_template_id = g.task_template_id
                    and b.planned_effort is NOT NULL
                    and b.planned_effort_uom is NOT NULL
                    and c.price_list_id(+) = p_price_list_id
                    and c.inventory_item_id(+) = p_labor_inventory_item_id
                    and c.unit_code(+) = b.planned_effort_uom
                    and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                    and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
                    and d.inventory_item_id = p_labor_inventory_item_id
                    and d.organization_id = p_organization_id
                    and e.repair_type_id = p_repair_type_id
                    and f.txn_billing_type_id = e.txn_billing_type_id(+)
                    and f.billing_type = d.material_billable_flag(+)
                    and d.material_billable_flag IS NOT NULL;


          -- Cursor gets:
          -- Information to create material lines from task groups attached to
          -- solutions linked to the repair line id.
          cursor c_material_lines_from_sol (p_repair_line_id NUMBER,
                                        p_price_list_id  NUMBER,
                                        p_inventory_item_id NUMBER,
                                        p_organization_id NUMBER,
                                        p_repair_type_id NUMBER) is
                SELECT b.inventory_item_id,
                       b.primary_uom_code uom,
                       b.manual_quantity manual_qty,
                       ceil(b.rollup_quantity_used/b.rollup_times_used) rollup_qty,
                       a.actual_times_used times_used,
                       c.list_price selling_price,
                       d.concatenated_segments item_name,
                       d.comms_nl_trackable_flag,
                       f.txn_billing_type_id,
                       'SOLUTION' est_line_source_type_code,
                       SetLinkRO.set_id est_line_source_id1,
                       null est_line_source_id2,
                       null ro_service_code_id
                FROM
                     cs_kb_set_links SetLinkTG, --link to task group
                     cs_kb_set_links SetLinkRO, -- link to repair order
                     cs_kb_sets_vl KBSets,
                     jtf_task_temp_groups_vl JtfTaskTempGroupEO,
                     csp_product_tasks a,
                     csp_task_parts  b,
                     qp_price_list_lines_v c,
                     mtl_system_items_kfv d,
                     csd_repair_types_sar e,
                     cs_txn_billing_types f,
                     jtf_task_templates_vl g
                WHERE
                        g.task_group_id = JtfTaskTempGroupEO.task_template_group_id
                    and a.task_template_id = g.task_template_id
                    and a.product_id = p_inventory_item_id
                    and b.product_task_id = a.product_task_id
                    and (b.manual_quantity IS NOT NULL OR
                         b.rollup_quantity_used IS NOT NULL)
                    and b.substitute_item IS NULL
                    and c.price_list_id(+) = p_price_list_id
                    and c.inventory_item_id(+) = b.inventory_item_id
                    and c.unit_code(+) = b.primary_uom_code
                    and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                    and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
                    and d.inventory_item_id = b.inventory_item_id
                    and d.material_billable_flag IS NOT NULL
                    and d.organization_id = p_organization_id
                    and e.repair_type_id = p_repair_type_id
                    and f.txn_billing_type_id = e.txn_billing_type_id(+)
                    and f.billing_type = d.material_billable_flag(+)
                    and SetLinkRO.other_id = p_repair_line_id
                    and SetLinkRO.object_code = 'DR'
                    and SetLinkRO.link_type = 'S'
                    and SetLinkTG.set_id = SetLinkRO.set_id
                    and SetLinkTG.other_id = JtfTaskTempGroupEO.task_template_group_id
                    and SetLinkTG.object_code = 'CS_KB_TASK_TEMPLATE_GRP'
                    and JtfTaskTempGroupEO.application_id = 512  -- depot repair task groups only
                    and KBSets.set_id = SetLinkTG.set_id
                    and KBSets.status = 'PUB'               -- only published solutions
                    and not exists                          -- not already brought in
                        ( select 'x'
                          from  csd_repair_estimate_lines_v csd
                          where csd.repair_line_id = SetLinkRO.other_id
                            and csd.est_line_source_type_code = 'SOLUTION'
                            and csd.est_line_source_id1 = KBSets.set_id);

          -- Cursor gets:
          -- Information to create labor lines from task groups attached to
          -- solutions linked to the repair line id.
          cursor c_labor_lines_from_sol (p_repair_line_id NUMBER,
                                        p_price_list_id  NUMBER,
                                        p_labor_inventory_item_id NUMBER,
                                        p_organization_id NUMBER,
                                        p_repair_type_id NUMBER) is
                SELECT p_labor_inventory_item_id inventory_item_id,
                       b.planned_effort_uom uom,
                       b.planned_effort quantity,
                       c.list_price selling_price,
                       d.concatenated_segments item_name,
                       d.comms_nl_trackable_flag,
                       f.txn_billing_type_id,
                       'SOLUTION' est_line_source_type_code,
                       SetLinkRO.set_id est_line_source_id1,
                       null est_line_source_id2,
                       null ro_service_code_id
                FROM
                     cs_kb_set_links SetLinkTG, --link to task group
                     cs_kb_set_links SetLinkRO, -- link to repair order
                     cs_kb_sets_vl KBSets,
                     jtf_task_temp_groups_vl JtfTaskTempGroupEO,
                     jtf_task_templates_b  b,
                     qp_price_list_lines_v c,
                     mtl_system_items_kfv d,
                     csd_repair_types_sar e,
                     cs_txn_billing_types f,
                     jtf_task_templates_vl g
                WHERE
                        SetLinkRO.other_id = p_repair_line_id
                    and SetLinkRO.object_code = 'DR'
                    and SetLinkRO.link_type = 'S'
                    and SetLinkTG.set_id = SetLinkRO.set_id
                    and SetLinkTG.other_id = JtfTaskTempGroupEO.task_template_group_id
                    and SetLinkTG.object_code = 'CS_KB_TASK_TEMPLATE_GRP'
                    and g.task_group_id = JtfTaskTempGroupEO.task_template_group_id
                    and b.task_template_id = g.task_template_id
                    and b.planned_effort is NOT NULL
                    and b.planned_effort_uom is NOT NULL
                    and c.price_list_id(+) = p_price_list_id
                    and c.inventory_item_id(+) = p_labor_inventory_item_id
                    and c.unit_code(+) = b.planned_effort_uom
                    and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                    and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
                    and d.inventory_item_id = p_labor_inventory_item_id
                    and d.organization_id = p_organization_id
                    and e.repair_type_id = p_repair_type_id
                    and f.txn_billing_type_id = e.txn_billing_type_id(+)
                    and f.billing_type = d.material_billable_flag(+)
                    and d.material_billable_flag IS NOT NULL
                    and JtfTaskTempGroupEO.application_id = 512  -- depot repair task groups only
                    and KBSets.set_id = SetLinkTG.set_id
                    and KBSets.status = 'PUB'               -- only published solutions
                    and not exists                          -- not already brought in
                        ( select 'x'
                          from  csd_repair_estimate_lines_v csd
                          where csd.repair_line_id = SetLinkRO.other_id
                            and csd.est_line_source_type_code = 'SOLUTION'
                            and csd.est_line_source_id1 = KBSets.set_id);
        */

        -- Cursor gets:
        -- Information to create material lines from task groups attached to
        -- srvice codes linked to the repair line id.
        CURSOR c_material_lines_from_sc(p_repair_line_id NUMBER) IS
        -- p_price_list_id  NUMBER) is , bug 3468680, vkjain
            SELECT b.inventory_item_id,
                   b.primary_uom_code uom,
                   b.manual_quantity manual_qty,
                   CEIL(b.rollup_quantity_used / b.rollup_times_used) rollup_qty,
                   a.actual_times_used times_used,
                   -- c.list_price selling_price,
                   d.concatenated_segments item_name,
                   d.comms_nl_trackable_flag,
                   f.txn_billing_type_id,
                   'SERVICE_CODE' est_line_source_type_code,
                   ROSC.Service_code_id est_line_source_id1,
                   NULL est_line_source_id2,
                   ROSC.RO_Service_code_id
              FROM CSD_RO_SERVICE_CODES ROSC,
                   CSD_SERVICE_CODES_VL SC,
                   CSD_SC_WORK_ENTITIES WRK,
                   CSP_PRODUCT_TASKS    a,
                   CSP_TASK_PARTS       b,
                   -- QP_PRICE_LIST_LINES_V c,
                   MTL_SYSTEM_ITEMS_KFV  d,
                   CSD_REPAIR_TYPES_SAR  e,
                   CS_TXN_BILLING_TYPES  f,
                   JTF_TASK_TEMPLATES_VL g
             WHERE ROSC.repair_line_id = p_repair_line_id
               AND ROSC.applicable_flag = 'Y'
                  -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               AND ROSC.applied_to_est_flag = 'N'
               AND WRK.Service_code_id = ROSC.Service_code_id
               AND WRK.work_entity_type_code = 'TASK'
               AND SC.Service_code_Id = ROSC.Service_code_id
               AND NVL(SC.active_from, SYSDATE) <= SYSDATE
               AND NVL(SC.active_to, SYSDATE) >= SYSDATE
               AND g.task_group_id = WRK.work_entity_id1
               AND a.task_template_id = g.task_template_id
               AND a.product_id = p_inventory_item_id
               AND b.product_task_id = a.product_task_id
               AND (b.manual_quantity IS NOT NULL OR
                   b.rollup_quantity_used IS NOT NULL)
               AND b.substitute_item IS NULL
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and c.price_list_id(+) = p_price_list_id
                  -- and c.inventory_item_id(+) = b.inventory_item_id
                  -- and c.unit_code(+) = b.primary_uom_code
                  -- and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               AND d.inventory_item_id = b.inventory_item_id
               AND d.organization_id = p_organization_id
               AND e.repair_type_id = p_repair_type_id
               AND f.txn_billing_type_id = e.txn_billing_type_id(+)
               AND f.billing_type = d.material_billable_flag(+)
               AND d.material_billable_flag IS NOT NULL;

        -- Cursor gets:
        -- Information to create labor lines from task groups attached to
        -- service codes linked to the repair line id.
        CURSOR c_labor_lines_from_sc(p_repair_line_id NUMBER,
        -- p_price_list_id  NUMBER, bug 3468680, vkjain
        p_labor_inventory_item_id NUMBER) IS
            SELECT p_labor_inventory_item_id inventory_item_id,
                   b.planned_effort_uom      uom,
                   b.planned_effort          quantity,
                   -- c.list_price selling_price,
                   d.concatenated_segments item_name,
                   d.comms_nl_trackable_flag,
                   f.txn_billing_type_id,
                   'SERVICE_CODE' est_line_source_type_code,
                   ROSC.Service_code_id est_line_source_id1,
                   NULL est_line_source_id2,
                   ROSC.RO_Service_code_id
              FROM CSD_RO_SERVICE_CODES ROSC,
                   CSD_SERVICE_CODES_VL SC,
                   CSD_SC_WORK_ENTITIES WRK,
                   JTF_TASK_TEMPLATES_B b,
                   -- QP_PRICE_LIST_LINES_V c,
                   MTL_SYSTEM_ITEMS_KFV  d,
                   CSD_REPAIR_TYPES_SAR  e,
                   CS_TXN_BILLING_TYPES  f,
                   JTF_TASK_TEMPLATES_VL g
             WHERE ROSC.repair_line_id = p_repair_line_id
               AND ROSC.applicable_flag = 'Y'
                  -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               AND ROSC.applied_to_est_flag = 'N'
               AND WRK.Service_code_id = ROSC.Service_code_id
               AND WRK.work_entity_type_code = 'TASK'
               AND SC.Service_code_Id = ROSC.Service_code_id
               AND NVL(SC.active_from, SYSDATE) <= SYSDATE
               AND NVL(SC.active_to, SYSDATE) >= SYSDATE
               AND g.task_group_id = WRK.work_entity_id1
               AND b.task_template_id = g.task_template_id
               AND b.planned_effort IS NOT NULL
               AND b.planned_effort_uom IS NOT NULL
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and c.price_list_id(+) = p_price_list_id
                  -- and c.inventory_item_id(+) = p_labor_inventory_item_id
                  -- and c.unit_code(+) = b.planned_effort_uom
                  -- and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               AND d.inventory_item_id = p_labor_inventory_item_id
               AND d.organization_id = p_organization_id
               AND e.repair_type_id = p_repair_type_id
               AND f.txn_billing_type_id = e.txn_billing_type_id(+)
               AND f.billing_type = d.material_billable_flag(+)
               AND d.material_billable_flag IS NOT NULL;

        -- Cursor gets:
        -- Information to create material lines from task groups attached to
        -- solutions linked to the repair line id.
        CURSOR c_material_lines_from_sol(p_repair_line_id NUMBER,
        -- p_price_list_id  NUMBER, bug 3468680, vkjain
        p_inventory_item_id NUMBER, p_organization_id NUMBER, p_repair_type_id NUMBER) IS
            SELECT b.inventory_item_id,
                   b.primary_uom_code uom,
                   b.manual_quantity manual_qty,
                   CEIL(b.rollup_quantity_used / b.rollup_times_used) rollup_qty,
                   a.actual_times_used times_used,
                   -- c.list_price selling_price,
                   d.concatenated_segments item_name,
                   d.comms_nl_trackable_flag,
                   f.txn_billing_type_id,
                   'SOLUTION' est_line_source_type_code,
                   SetLinkRO.set_id est_line_source_id1,
                   NULL est_line_source_id2,
                   NULL ro_service_code_id
              FROM cs_kb_set_links         SetLinkTG, --link to task group
                   cs_kb_set_links         SetLinkRO, -- link to repair order
                   cs_kb_sets_vl           KBSets,
                   jtf_task_temp_groups_vl JtfTaskTempGroupEO,
                   csp_product_tasks       a,
                   csp_task_parts          b,
                   -- qp_price_list_lines_v c,
                   mtl_system_items_kfv  d,
                   CSD_REPAIR_TYPES_SAR  e,
                   cs_txn_billing_types  f,
                   jtf_task_templates_vl g
             WHERE g.task_group_id =
                   JtfTaskTempGroupEO.task_template_group_id
               AND a.task_template_id = g.task_template_id
               AND a.product_id = p_inventory_item_id
               AND b.product_task_id = a.product_task_id
               AND (b.manual_quantity IS NOT NULL OR
                   b.rollup_quantity_used IS NOT NULL)
               AND b.substitute_item IS NULL
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and c.price_list_id(+) = p_price_list_id
                  -- and c.inventory_item_id(+) = b.inventory_item_id
                  -- and c.unit_code(+) = b.primary_uom_code
                  -- and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               AND d.inventory_item_id = b.inventory_item_id
               AND d.material_billable_flag IS NOT NULL
               AND d.organization_id = p_organization_id
               AND e.repair_type_id = p_repair_type_id
               AND f.txn_billing_type_id = e.txn_billing_type_id(+)
               AND f.billing_type = d.material_billable_flag(+)
               AND SetLinkRO.other_id = p_repair_line_id
               AND SetLinkRO.object_code = 'DR'
               AND SetLinkRO.link_type = 'S'
               AND SetLinkTG.set_id = SetLinkRO.set_id
               AND SetLinkTG.other_id =
                   JtfTaskTempGroupEO.task_template_group_id
               AND SetLinkTG.object_code = 'CS_KB_TASK_TEMPLATE_GRP'
               AND JtfTaskTempGroupEO.application_id = 512 -- depot repair task groups only
               AND KBSets.set_id = SetLinkTG.set_id
               AND KBSets.status = 'PUB' -- only published solutions
               AND NOT EXISTS -- not already brought in
             (SELECT 'x'
                      FROM csd_repair_estimate_lines_v csd
                     WHERE csd.repair_line_id = SetLinkRO.other_id
                       AND csd.est_line_source_type_code = 'SOLUTION'
                       AND csd.est_line_source_id1 = KBSets.set_id);

        -- Cursor gets:
        -- Information to create labor lines from task groups attached to
        -- solutions linked to the repair line id.
        CURSOR c_labor_lines_from_sol(p_repair_line_id NUMBER,
        -- p_price_list_id  NUMBER, bug 3468680, vkjain
        p_labor_inventory_item_id NUMBER, p_organization_id NUMBER, p_repair_type_id NUMBER) IS
            SELECT p_labor_inventory_item_id inventory_item_id,
                   b.planned_effort_uom      uom,
                   b.planned_effort          quantity,
                   -- c.list_price selling_price,
                   d.concatenated_segments item_name,
                   d.comms_nl_trackable_flag,
                   f.txn_billing_type_id,
                   'SOLUTION' est_line_source_type_code,
                   SetLinkRO.set_id est_line_source_id1,
                   NULL est_line_source_id2,
                   NULL ro_service_code_id
              FROM cs_kb_set_links         SetLinkTG, --link to task group
                   cs_kb_set_links         SetLinkRO, -- link to repair order
                   cs_kb_sets_vl           KBSets,
                   jtf_task_temp_groups_vl JtfTaskTempGroupEO,
                   jtf_task_templates_b    b,
                   -- qp_price_list_lines_v c,
                   mtl_system_items_kfv  d,
                   CSD_REPAIR_TYPES_SAR  e,
                   cs_txn_billing_types  f,
                   jtf_task_templates_vl g
             WHERE SetLinkRO.other_id = p_repair_line_id
               AND SetLinkRO.object_code = 'DR'
               AND SetLinkRO.link_type = 'S'
               AND SetLinkTG.set_id = SetLinkRO.set_id
               AND SetLinkTG.other_id =
                   JtfTaskTempGroupEO.task_template_group_id
               AND SetLinkTG.object_code = 'CS_KB_TASK_TEMPLATE_GRP'
               AND g.task_group_id =
                   JtfTaskTempGroupEO.task_template_group_id
               AND b.task_template_id = g.task_template_id
               AND b.planned_effort IS NOT NULL
               AND b.planned_effort_uom IS NOT NULL
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and c.price_list_id(+) = p_price_list_id
                  -- and c.inventory_item_id(+) = p_labor_inventory_item_id
                  -- and c.unit_code(+) = b.planned_effort_uom
                  -- and nvl(c.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(c.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               AND d.inventory_item_id = p_labor_inventory_item_id
               AND d.organization_id = p_organization_id
               AND e.repair_type_id = p_repair_type_id
               AND f.txn_billing_type_id = e.txn_billing_type_id(+)
               AND f.billing_type = d.material_billable_flag(+)
               AND d.material_billable_flag IS NOT NULL
               AND JtfTaskTempGroupEO.application_id = 512 -- depot repair task groups only
               AND KBSets.set_id = SetLinkTG.set_id
               AND KBSets.status = 'PUB' -- only published solutions
               AND NOT EXISTS -- not already brought in
             (SELECT 'x'
                      FROM csd_repair_estimate_lines_v csd
                     WHERE csd.repair_line_id = SetLinkRO.other_id
                       AND csd.est_line_source_type_code = 'SOLUTION'
                       AND csd.est_line_source_id1 = KBSets.set_id);

        -- Cursor gets:
        -- Tasks template groups associated with solutions for a repair line
        -- where the task template groups do not have any task templates
        -- defined for the repair line's product
        CURSOR c_sol_tasks_no_prod(p_repair_line_id NUMBER) IS
            SELECT KBSets.set_id                             solution_id, -- solution id
                   JtfTaskTempGroupEO.task_template_group_id task_group_id, -- task template group id
                   JtfTaskTempGroupEO.template_group_name    task_group_name -- task template group name
              FROM cs_kb_set_links         SetLinkTG, --link to task group
                   cs_kb_set_links         SetLinkRO, -- link to repair order
                   cs_kb_sets_vl           KBSets,
                   jtf_task_temp_groups_vl JtfTaskTempGroupEO,
                   CSD_REPAIRS             repairs
             WHERE SetLinkRO.other_id = p_repair_line_id
               AND SetLinkRO.object_code = 'DR'
               AND SetLinkRO.link_type = 'S'
               AND SetLinkTG.set_id = SetLinkRO.set_id
               AND SetLinkTG.other_id =
                   JtfTaskTempGroupEO.task_template_group_id
               AND SetLinkTG.object_code = 'CS_KB_TASK_TEMPLATE_GRP'
               AND JtfTaskTempGroupEO.application_id = 512 -- depot repair task groups only
               AND KBSets.set_id = SetLinkTG.set_id
               AND KBSets.status = 'PUB' -- only published solutions
               AND repairs.repair_line_id = SetLinkRO.other_id
               AND NOT EXISTS -- not already brought in
             (SELECT 'x'
                      FROM csd_repair_estimate_lines_v csd
                     WHERE csd.repair_line_id = SetLinkRO.other_id
                       AND csd.est_line_source_type_code = 'SOLUTION'
                       AND csd.est_line_source_id1 = KBSets.set_id)
               AND NOT EXISTS -- no template for this product
             (SELECT 'x'
                      FROM csp_product_tasks       x,
                           jtf_task_templates_vl   y,
                           jtf_task_temp_groups_vl z
                     WHERE x.product_id = repairs.inventory_item_id
                       AND x.task_template_id = y.task_template_id
                       AND y.task_group_id = SetLinkTG.other_id);

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Get_Estimates_From_Task;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(lc_api_version,
                                           p_api_version,
                                           lc_api_name,
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

        -- initialize the warning flag
        x_warning_flag := Fnd_Api.G_FALSE;

        --
        -- Begin API Body
        --
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.BEGIN',
                           'Entering CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_Task');
        END IF;
        -- log parameters
        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_api_version: ' || p_api_version);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_commit: ' || p_commit);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_init_msg_list: ' || p_init_msg_list);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_validation_level: ' || p_validation_level);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_line_id: ' || p_repair_line_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_estimate_id: ' || p_estimate_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_type_id: ' || p_repair_type_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_business_process_id: ' ||
                           p_business_process_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_currency_code: ' || p_currency_code);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_incident_id: ' || p_incident_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_mode: ' || p_repair_mode);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_inventory_item_id: ' || p_inventory_item_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_organization_id: ' || p_organization_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_price_list_id: ' || p_price_list_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_contract_line_id: ' || p_contract_line_id);
        END IF;

        -- get labor inventory item from profile option
        l_labor_inventory_item_id := Fnd_Profile.value('CSD_DEFAULT_EST_LABOR');

        -- get use tasks from solution profile option
        l_use_tasks_from_sol := NVL(Fnd_Profile.value('CSD_USE_TASK_FROM_SOLN'),
                                    'N');

        -- get threshold for tasks - to be used when determining manual vs rollup qty
        l_task_threshold := TO_NUMBER(NVL(Fnd_Profile.value('CSP_PROD_TASK_HIST_RULE'),
                                          '0'));

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name,
                           'l_labor_inventory_item_id = ' ||
                           l_labor_inventory_item_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name,
                           'l_use_tasks_from_sol = ' ||
                           l_use_tasks_from_sol);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name,
                           'l_task_threshold = ' || l_task_threshold);
        END IF;

        --
        -- (1) Material lines from Service Codes
        --
        DECLARE
            l_count NUMBER := 0;
        BEGIN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Getting task material lines from service codes');
            END IF;
            -- bugfix 3468680, vkjain
            -- FOR r1 in c_material_lines_from_sc (p_repair_line_id, p_price_list_id)
            FOR r1 IN c_material_lines_from_sc(p_repair_line_id)
            LOOP
                IF (r1.manual_qty IS NOT NULL) OR
                   (l_task_threshold <= r1.times_used)
                THEN
                    l_count := l_count + 1;
                    IF (r1.manual_qty IS NOT NULL)
                    THEN
                        l_materials_from_sc_tbl(l_count).quantity := r1.manual_qty;
                    ELSE
                        -- if (l_task_threshold <= r1.times_used)
                        l_materials_from_sc_tbl(l_count).quantity := r1.rollup_qty;
                    END IF;
                    l_materials_from_sc_tbl(l_count).inventory_item_id := r1.inventory_item_id;
                    l_materials_from_sc_tbl(l_count).uom := r1.uom;
                    -- Bugfix 3468680, vkjain
                    -- l_materials_from_sc_tbl(l_count).selling_price := r1.selling_price;
                    l_materials_from_sc_tbl(l_count).item_name := r1.item_name;
                    l_materials_from_sc_tbl(l_count).comms_nl_trackable_flag := r1.comms_nl_trackable_flag;
                    l_materials_from_sc_tbl(l_count).txn_billing_type_id := r1.txn_billing_type_id;
                    l_materials_from_sc_tbl(l_count).est_line_source_type_code := r1.est_line_source_type_code;
                    l_materials_from_sc_tbl(l_count).est_line_source_id1 := r1.est_line_source_id1;
                    l_materials_from_sc_tbl(l_count).est_line_source_id2 := r1.est_line_source_id2;
                    l_materials_from_sc_tbl(l_count).ro_service_code_id := r1.ro_service_code_id;
                END IF;
            END LOOP;
        END;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'material line count = ' ||
                           l_materials_from_sc_tbl.COUNT);
        END IF;
        IF (l_materials_from_sc_tbl.COUNT > 0)
        THEN
            -- bugfix 3543135, vkjain.
            l_No_Eligible_Lines := FALSE;

            Convert_To_Est_Lines(p_api_version         => 1.0,
                                 p_commit              => Fnd_Api.G_FALSE,
                                 p_init_msg_list       => Fnd_Api.G_FALSE,
                                 p_validation_level    => p_validation_level,
                                 x_return_status       => x_return_status,
                                 x_msg_count           => x_msg_count,
                                 x_msg_data            => x_msg_data,
                                 p_repair_line_id      => p_repair_line_id,
                                 p_estimate_id         => p_estimate_id,
                                 p_repair_type_id      => p_repair_type_id,
                                 p_business_process_id => p_business_process_id,
                                 p_currency_code       => p_currency_code,
                                 p_incident_id         => p_incident_id,
                                 p_organization_id     => p_organization_id,
                                 p_price_list_id       => p_price_list_id,
                                 p_contract_line_id    => p_contract_line_id,
                                 p_MLE_lines_tbl       => l_materials_from_sc_tbl,
                                 x_est_lines_tbl       => x_est_lines_tbl,
                                 x_warning_flag        => l_warning_flag);
            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                x_warning_flag := Fnd_Api.G_TRUE;
            END IF;
            IF l_warning_flag <> Fnd_Api.G_FALSE
            THEN
                x_warning_flag := l_warning_flag;
            END IF;
        END IF;

        --
        -- (2) Labor lines from Service Codes
        --
        IF (l_labor_inventory_item_id IS NOT NULL)
        THEN
            DECLARE
                l_count NUMBER := 0;
            BEGIN
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting task labor lines from service codes');
                END IF;
                -- bugfix 3468680, vkjain
                -- FOR r1 in c_labor_lines_from_sc (p_repair_line_id, p_price_list_id, l_labor_inventory_item_id)
                FOR r1 IN c_labor_lines_from_sc(p_repair_line_id,
                                                l_labor_inventory_item_id)
                LOOP
                    l_count := l_count + 1;
                    l_labor_from_sc_tbl(l_count).inventory_item_id := r1.inventory_item_id;
                    l_labor_from_sc_tbl(l_count).uom := r1.uom;
                    l_labor_from_sc_tbl(l_count).quantity := r1.quantity;
                    -- Bugfix 3468680, vkjain
                    -- l_labor_from_sc_tbl(l_count).selling_price := r1.selling_price;
                    l_labor_from_sc_tbl(l_count).item_name := r1.item_name;
                    l_labor_from_sc_tbl(l_count).comms_nl_trackable_flag := r1.comms_nl_trackable_flag;
                    l_labor_from_sc_tbl(l_count).txn_billing_type_id := r1.txn_billing_type_id;
                    l_labor_from_sc_tbl(l_count).est_line_source_type_code := r1.est_line_source_type_code;
                    l_labor_from_sc_tbl(l_count).est_line_source_id1 := r1.est_line_source_id1;
                    l_labor_from_sc_tbl(l_count).est_line_source_id2 := r1.est_line_source_id2;
                    l_labor_from_sc_tbl(l_count).ro_service_code_id := r1.ro_service_code_id;
                END LOOP;
            END;

            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'labor line count = ' ||
                               l_labor_from_sc_tbl.COUNT);
            END IF;
            IF (l_labor_from_sc_tbl.COUNT > 0)
            THEN
                -- bugfix 3543135, vkjain.
                l_No_Eligible_Lines := FALSE;

                Convert_To_Est_Lines(p_api_version         => 1.0,
                                     p_commit              => Fnd_Api.G_FALSE,
                                     p_init_msg_list       => Fnd_Api.G_FALSE,
                                     p_validation_level    => p_validation_level,
                                     x_return_status       => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data,
                                     p_repair_line_id      => p_repair_line_id,
                                     p_estimate_id         => p_estimate_id,
                                     p_repair_type_id      => p_repair_type_id,
                                     p_business_process_id => p_business_process_id,
                                     p_currency_code       => p_currency_code,
                                     p_incident_id         => p_incident_id,
                                     p_organization_id     => p_organization_id,
                                     p_price_list_id       => p_price_list_id,
                                     p_contract_line_id    => p_contract_line_id,
                                     p_MLE_lines_tbl       => l_labor_from_sc_tbl,
                                     x_est_lines_tbl       => x_est_lines_tbl,
                                     x_warning_flag        => l_warning_flag);
                IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    x_warning_flag := Fnd_Api.G_TRUE;
                END IF;
                IF l_warning_flag <> Fnd_Api.G_FALSE
                THEN
                    x_warning_flag := l_warning_flag;
                END IF;
            END IF;
        END IF;

        --
        -- Use tasks associated with solutions
        --
        IF (l_use_tasks_from_sol = 'Y')
        THEN
            --
            -- Before getting any material lines from Solutions, check to
            -- see if there are any task groups with no task templates for the
            -- repair line's product.  Log a warning for each task group.
            --
            DECLARE
                l_return_status VARCHAR2(1);
                l_msg_count     NUMBER;
                l_msg_data      VARCHAR2(2000);
            BEGIN
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting all solution tasks with no product template');
                END IF;
                FOR r1 IN c_sol_tasks_no_prod(p_repair_line_id)
                LOOP
                    x_warning_flag := Fnd_Api.G_TRUE;
                    IF (Fnd_Log.Level_Statement >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                       lc_mod_name,
                                       'Adding message CSD_EST_SOL_TASK_NO_PROD to FND_MSG stack');
                        Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                       lc_mod_name,
                                       'no task template for task group id ' ||
                                       r1.task_group_id);
                    END IF;
                    Fnd_Message.SET_NAME('CSD', 'CSD_EST_SOL_TASK_NO_PROD');
                    Fnd_Message.SET_TOKEN('GROUP_ID', r1.task_group_id);
                    Fnd_Message.SET_TOKEN('GROUP_NAME', r1.task_group_name);
                    Fnd_Msg_Pub.ADD;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Calling CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Number of messages in stack: ' ||
                                       Fnd_Msg_Pub.count_msg);
                    END IF;
                    Csd_Gen_Errmsgs_Pvt.Save_Fnd_Msgs(p_api_version             => 1.0,
                                                      p_commit                  => Fnd_Api.G_FALSE,
                                                      p_init_msg_list           => Fnd_Api.G_FALSE,
                                                      p_validation_level        => 0,
                                                      p_module_code             => 'EST',
                                                      p_source_entity_id1       => p_repair_line_id,
                                                      p_source_entity_type_code => 'SOLUTION',
                                                      p_source_entity_id2       => r1.solution_id,
                                                      x_return_status           => l_return_status,
                                                      x_msg_count               => l_msg_count,
                                                      x_msg_data                => l_msg_data);
                    IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                    THEN
                        RAISE Fnd_Api.G_EXC_ERROR;
                    END IF;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Returned from CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Number of messages in stack: ' ||
                                       Fnd_Msg_Pub.count_msg);
                    END IF;
                END LOOP;
            END;

            --
            -- (3) Material lines from Solutions
            --
            DECLARE
                l_count NUMBER := 0;
            BEGIN
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting task material lines from solutions');
                END IF;
                FOR r1 IN c_material_lines_from_sol(p_repair_line_id,
                                                    -- p_price_list_id, bugfix 3468680, vkjain
                                                    p_inventory_item_id,
                                                    p_organization_id,
                                                    p_repair_type_id)
                LOOP
                    IF (r1.manual_qty IS NOT NULL) OR
                       (l_task_threshold <= r1.times_used)
                    THEN
                        l_count := l_count + 1;
                        IF (r1.manual_qty IS NOT NULL)
                        THEN
                            l_materials_from_sol_tbl(l_count).quantity := r1.manual_qty;
                        ELSE
                            -- if (l_task_threshold <= r1.times_used)
                            l_materials_from_sol_tbl(l_count).quantity := r1.rollup_qty;
                        END IF;
                        l_materials_from_sol_tbl(l_count).inventory_item_id := r1.inventory_item_id;
                        l_materials_from_sol_tbl(l_count).uom := r1.uom;
                        -- Bugfix 3468680, vkjain
                        -- l_materials_from_sol_tbl(l_count).selling_price := r1.selling_price;
                        l_materials_from_sol_tbl(l_count).item_name := r1.item_name;
                        l_materials_from_sol_tbl(l_count).comms_nl_trackable_flag := r1.comms_nl_trackable_flag;
                        l_materials_from_sol_tbl(l_count).txn_billing_type_id := r1.txn_billing_type_id;
                        l_materials_from_sol_tbl(l_count).est_line_source_type_code := r1.est_line_source_type_code;
                        l_materials_from_sol_tbl(l_count).est_line_source_id1 := r1.est_line_source_id1;
                        l_materials_from_sol_tbl(l_count).est_line_source_id2 := r1.est_line_source_id2;
                        l_materials_from_sol_tbl(l_count).ro_service_code_id := r1.ro_service_code_id;
                    END IF;
                END LOOP;
            END;

            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'material line count = ' ||
                               l_materials_from_sol_tbl.COUNT);
            END IF;
            IF (l_materials_from_sol_tbl.COUNT > 0)
            THEN
                -- bugfix 3543135, vkjain.
                l_No_Eligible_Lines := FALSE;

                Convert_To_Est_Lines(p_api_version         => 1.0,
                                     p_commit              => Fnd_Api.G_FALSE,
                                     p_init_msg_list       => Fnd_Api.G_FALSE,
                                     p_validation_level    => p_validation_level,
                                     x_return_status       => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data,
                                     p_repair_line_id      => p_repair_line_id,
                                     p_estimate_id         => p_estimate_id,
                                     p_repair_type_id      => p_repair_type_id,
                                     p_business_process_id => p_business_process_id,
                                     p_currency_code       => p_currency_code,
                                     p_incident_id         => p_incident_id,
                                     p_organization_id     => p_organization_id,
                                     p_price_list_id       => p_price_list_id,
                                     p_contract_line_id    => p_contract_line_id,
                                     p_MLE_lines_tbl       => l_materials_from_sol_tbl,
                                     x_est_lines_tbl       => x_est_lines_tbl,
                                     x_warning_flag        => l_warning_flag);
                IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    x_warning_flag := Fnd_Api.G_TRUE;
                END IF;
                IF l_warning_flag <> Fnd_Api.G_FALSE
                THEN
                    x_warning_flag := l_warning_flag;
                END IF;
            END IF;
        END IF;

        --
        -- (4) Labor lines from Solutions
        --
        IF (l_use_tasks_from_sol = 'Y') AND
           (l_labor_inventory_item_id IS NOT NULL)
        THEN
            DECLARE
                l_count NUMBER := 0;
            BEGIN
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting task labor lines from solutions');
                END IF;
                FOR r1 IN c_labor_lines_from_sol(p_repair_line_id,
                                                 -- p_price_list_id, bugfix 3468680, vkjain
                                                 l_labor_inventory_item_id,
                                                 p_organization_id,
                                                 p_repair_type_id)
                LOOP
                    l_count := l_count + 1;
                    l_labor_from_sol_tbl(l_count).inventory_item_id := r1.inventory_item_id;
                    l_labor_from_sol_tbl(l_count).uom := r1.uom;
                    l_labor_from_sol_tbl(l_count).quantity := r1.quantity;
                    -- Bugfix 3468680, vkjain
                    -- l_labor_from_sol_tbl(l_count).selling_price := r1.selling_price;
                    l_labor_from_sol_tbl(l_count).item_name := r1.item_name;
                    l_labor_from_sol_tbl(l_count).comms_nl_trackable_flag := r1.comms_nl_trackable_flag;
                    l_labor_from_sol_tbl(l_count).txn_billing_type_id := r1.txn_billing_type_id;
                    l_labor_from_sol_tbl(l_count).est_line_source_type_code := r1.est_line_source_type_code;
                    l_labor_from_sol_tbl(l_count).est_line_source_id1 := r1.est_line_source_id1;
                    l_labor_from_sol_tbl(l_count).est_line_source_id2 := r1.est_line_source_id2;
                    l_labor_from_sol_tbl(l_count).ro_service_code_id := r1.ro_service_code_id;
                END LOOP;
            END;

            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'labor line count = ' ||
                               l_labor_from_sol_tbl.COUNT);
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Calling Convert_To_Est_Lines');
            END IF;
            IF (l_labor_from_sol_tbl.COUNT > 0)
            THEN
                -- bugfix 3543135, vkjain.
                l_No_Eligible_Lines := FALSE;

                Convert_To_Est_Lines(p_api_version         => 1.0,
                                     p_commit              => Fnd_Api.G_FALSE,
                                     p_init_msg_list       => Fnd_Api.G_FALSE,
                                     p_validation_level    => p_validation_level,
                                     x_return_status       => x_return_status,
                                     x_msg_count           => x_msg_count,
                                     x_msg_data            => x_msg_data,
                                     p_repair_line_id      => p_repair_line_id,
                                     p_estimate_id         => p_estimate_id,
                                     p_repair_type_id      => p_repair_type_id,
                                     p_business_process_id => p_business_process_id,
                                     p_currency_code       => p_currency_code,
                                     p_incident_id         => p_incident_id,
                                     p_organization_id     => p_organization_id,
                                     p_price_list_id       => p_price_list_id,
                                     p_contract_line_id    => p_contract_line_id,
                                     p_MLE_lines_tbl       => l_labor_from_sol_tbl,
                                     x_est_lines_tbl       => x_est_lines_tbl,
                                     x_warning_flag        => l_warning_flag);
                IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    x_warning_flag := Fnd_Api.G_TRUE;
                END IF;
                IF l_warning_flag <> Fnd_Api.G_FALSE
                THEN
                    x_warning_flag := l_warning_flag;
                END IF;
            END IF;
        END IF;

        -- bugfix 3543135, vkjain.
        -- IF (x_est_lines_tbl.count <= 0) THEN
        IF (l_No_Eligible_Lines)
        THEN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'no estimate lines available to autogenerate from tasks');
            END IF;
            RAISE CSD_EST_NO_AUTOGEN;
        END IF;

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.out_parameter',
                           'x_warning_flag: ' || x_warning_flag);
        END IF;
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.END',
                           'Leaving CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_Task');
        END IF;
        --
        -- End API Body
        --

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN CSD_EST_NO_AUTOGEN THEN
            x_warning_flag := Fnd_Api.G_TRUE;

            -- save message in fnd stack
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Adding message CSD_EST_NO_AUTOGEN to FND_MSG stack');
            END IF;
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_NO_AUTOGEN');
            Fnd_Msg_Pub.ADD;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'No estimate lines autogenerated');
            END IF;

        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Get_Estimates_From_Task;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;

            /*
            -- TO DO: Add seeded err message
            -- save message in fnd stack
            if (Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) then
                FND_LOG.STRING(Fnd_Log.Level_Statement, lc_mod_name,
                               'Adding message ERR_NAME to FND_MSG stack');
            end if;
            FND_MESSAGE.SET_NAME('CSD','err_name');
            FND_MESSAGE.SET_TOKEN('toke_name', 'token_value');
            FND_MSG_PUB.ADD;
            */
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Get_Estimates_From_Task;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO Get_Estimates_From_Task;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                -- create a seeded message
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'SQL Message[' || SQLERRM || ']');
            END IF;
    END Get_Estimates_From_Task;

    /*--------------------------------------------------*/
    /* procedure name: Get_Estimates_From_BOM           */
    /* description   : Fetches ML lines for the         */
    /*                 BOM/Route references associated  */
    /*                 via Service Codes.               */
    /*                                                  */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Autocreate_Estimate_Lines          */
    /*--------------------------------------------------*/
    PROCEDURE Get_Estimates_From_BOM(p_api_version         IN NUMBER,
                                     p_commit              IN VARCHAR2,
                                     p_init_msg_list       IN VARCHAR2,
                                     p_validation_level    IN NUMBER,
                                     x_return_status       OUT NOCOPY VARCHAR2,
                                     x_msg_count           OUT NOCOPY NUMBER,
                                     x_msg_data            OUT NOCOPY VARCHAR2,
                                     p_repair_line_id      IN NUMBER,
                                     p_estimate_id         IN NUMBER,
                                     p_repair_type_id      IN NUMBER,
                                     p_business_process_id IN NUMBER,
                                     p_currency_code       IN VARCHAR2,
                                     p_incident_id         IN NUMBER,
                                     p_repair_mode         IN VARCHAR2,
                                     p_inventory_item_id   IN NUMBER,
                                     p_organization_id     IN NUMBER,
                                     p_price_list_id       IN NUMBER,
                                     p_contract_line_id    IN NUMBER,
                                     x_est_lines_tbl       OUT NOCOPY CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_TBL,
                                     x_warning_flag        OUT NOCOPY VARCHAR2) IS

        -- CONSTANTS --
        lc_debug_level CONSTANT NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
        lc_stat_level  CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
        lc_proc_level  CONSTANT NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        lc_event_level CONSTANT NUMBER := Fnd_Log.LEVEL_EVENT;
        lc_excep_level CONSTANT NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        lc_error_level CONSTANT NUMBER := Fnd_Log.LEVEL_ERROR;
        lc_unexp_level CONSTANT NUMBER := Fnd_Log.LEVEL_UNEXPECTED;
        lc_mod_name    CONSTANT VARCHAR2(100) := 'csd.plsql.csd_repair_estimate_pvt.get_estimates_from_bom';
        lc_api_name    CONSTANT VARCHAR2(30) := 'Get_Estimates_From_BOM';
        lc_api_version CONSTANT NUMBER := 1.0;

        -- VARIABLES --
        l_material_lines_tbl MLE_LINES_TBL_TYPE;
        l_labor_lines_tbl    MLE_LINES_TBL_TYPE;
        l_warning_flag       VARCHAR2(1);

        -- bugfix 3543135, vkjain.
        l_No_Eligible_Lines BOOLEAN := TRUE;

        -- EXCEPTIONS --
        CSD_EST_NO_AUTOGEN EXCEPTION;

        -- CURSORS --

        /* bugfix 3468680. vkjain
          The selling price should be derived via API call instead of
          selecting from the query.
          The cursors are replaced by new ones.
          Following changes are made to the existing cursors -
          -- Cursors do not accept p_price_list_id as IN parameter anymore.
          -- They do not select the list_price from the QP view.
          -- The reference to QP view is removed from the FROM part of statements.
          -- All joins for the QP view commented in the WHERE clause.
          -- The selling price is derived in the Convert_to_est_lines procedure
             by calling CSD_PROCESS_UTIL.GET_CHARGE_SELLING_PRICE API.

        cursor c_material_lines_from_bom (p_repair_line_id NUMBER,
                                          p_repair_type_id NUMBER,
                                          p_price_list_id  NUMBER) is
           SELECT BOM.component_item_id       INVENTORY_ITEM_ID,
                  BOM.primary_uom_code        UOM,
                  BOM.component_quantity      QUANTITY,
                  PRICE.list_price            SELLING_PRICE,
                  MTL.concatenated_segments   ITEM_NAME,
                  MTL.comms_nl_trackable_flag COMMS_NL_TRACKABLE_FLAG,
                  SAR.txn_billing_type_id     TXN_BILLING_TYPE_ID,
                  'SERVICE_CODE'              EST_LINE_SOURCE_TYPE_CODE,
                  ROSC.Service_Code_id        EST_LINE_SOURCE_ID1,
                  null                        EST_LINE_SOURCE_ID2,
                  ROSC.RO_Service_Code_id     RO_SERVICE_CODE_ID
           FROM CSD_RO_SERVICE_CODES       ROSC,
                CSD_SERVICE_CODES_VL       SC,
                CSD_SC_WORK_ENTITIES       WRK,
                BOM_INVENTORY_COMPONENTS_V BOM,
                QP_PRICE_LIST_LINES_V      PRICE,
                MTL_SYSTEM_ITEMS_KFV       MTL,
                CSD_REPAIR_TYPES_SAR       RTSAR,
                CS_TXN_BILLING_TYPES       SAR
           WHERE ROSC.repair_line_id = p_repair_line_id
               and ROSC.applicable_flag = 'Y'
               -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               and ROSC.applied_to_est_flag = 'N'
               and WRK.Service_code_id = ROSC.Service_code_id
               and WRK.work_entity_type_code = 'BOM'
               and SC.Service_code_Id = ROSC.Service_code_id
               and nvl(SC.active_from, SYSDATE) <= SYSDATE
               and nvl(SC.active_to, SYSDATE) >= SYSDATE
               and WRK.work_entity_id3 = cs_std.get_item_valdn_orgzn_id
               -- and WRK.work_entity_id1 IS NOT NULL
               and BOM.bill_sequence_id = WRK.work_entity_id1
               and nvl(BOM.effectivity_date , SYSDATE) <= SYSDATE -- swai bug 3323274
               and nvl(BOM.disable_date , SYSDATE) >= SYSDATE     -- swai bug 3323274
               and PRICE.price_list_id(+) = p_price_list_id
               and PRICE.inventory_item_id(+) = BOM.component_item_id
               and PRICE.unit_code(+) = BOM.primary_uom_code
               and nvl(PRICE.start_date_active, SYSDATE) <= SYSDATE  -- swai added
               and nvl(PRICE.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               and MTL.inventory_item_id = BOM.component_item_id
               and MTL.organization_id = WRK.work_entity_id3
               and RTSAR.repair_type_id = p_repair_type_id
               and SAR.txn_billing_type_id = RTSAR.txn_billing_type_id(+)
               and SAR.billing_type = MTL.material_billable_flag(+)
               and MTL.material_billable_flag IS NOT NULL;

         cursor c_labor_lines_from_bom (p_repair_line_id NUMBER,
                                        p_repair_type_id NUMBER,
                                        p_price_list_id  NUMBER) is
           SELECT
                  RES.billable_item_id        INVENTORY_ITEM_ID,
                  RES.unit_of_measure         UOM,
                  -- OPRES.assigned_units        QUANTITY, -- Replaced by following line to fix 3365436. vkjain.
                  OPRES.usage_rate_or_amount  QUANTITY,
                  PRICE.list_price            SELLING_PRICE,
                  MTL.concatenated_segments   ITEM_NAME,
                  MTL.comms_nl_trackable_flag COMMS_NL_TRACKABLE_FLAG,
                  SAR.txn_billing_type_id     TXN_BILLING_TYPE_ID,
                  'SERVICE_CODE'              EST_LINE_SOURCE_TYPE_CODE,
                  ROSC.Service_Code_id        EST_LINE_SOURCE_ID1,
                  null                        EST_LINE_SOURCE_ID2,
                  ROSC.RO_Service_Code_id     RO_SERVICE_CODE_ID,
                RES.resource_id             RESOURCE_ID -- vkjain. 3449978
           FROM CSD_RO_SERVICE_CODES    ROSC,
                CSD_SC_WORK_ENTITIES    WRK,
                CSD_SERVICE_CODES_VL    SC,
                BOM_OPERATION_SEQUENCES OPSEQ,
                BOM_OPERATION_RESOURCES OPRES,
                QP_PRICE_LIST_LINES_V   PRICE,
                MTL_SYSTEM_ITEMS_KFV    MTL,
                CSD_REPAIR_TYPES_SAR    RTSAR,
                CS_TXN_BILLING_TYPES    SAR,
                BOM_RESOURCES           RES
           WHERE ROSC.repair_line_id = p_repair_line_id
               and ROSC.applicable_flag = 'Y'
               -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               and ROSC.applied_to_est_flag = 'N'
               and WRK.Service_code_id = ROSC.Service_code_id
               and WRK.work_entity_type_code = 'BOM'
               and SC.Service_code_Id = ROSC.Service_code_id
               and nvl(SC.active_from, SYSDATE) <= SYSDATE
               and nvl(SC.active_to, SYSDATE) >= SYSDATE
               and WRK.work_entity_id3 = cs_std.get_item_valdn_orgzn_id
               -- and WRK.work_entity_id2 IS NOT NULL
               and OPSEQ.ROUTING_SEQUENCE_ID = WRK.work_entity_id2
               and nvl(OPSEQ.effectivity_date , SYSDATE) <= SYSDATE -- swai bug 3323274
               and nvl(OPSEQ.disable_date , SYSDATE) >= SYSDATE     -- swai bug 3323274
               and OPRES.OPERATION_SEQUENCE_ID = OPSEQ.OPERATION_SEQUENCE_ID
               and RES.RESOURCE_ID = OPRES.RESOURCE_ID
               and PRICE.price_list_id(+) = p_price_list_id
               and nvl(PRICE.start_date_active, SYSDATE) <= SYSDATE  -- swai added
               and nvl(PRICE.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               and PRICE.inventory_item_id(+) = RES.billable_item_id
               and PRICE.unit_code(+) = RES.unit_of_measure
               and MTL.inventory_item_id = RES.billable_item_id
               and MTL.organization_id = WRK.work_entity_id3
               and MTL.material_billable_flag IS NOT NULL
               and RTSAR.repair_type_id = p_repair_type_id
               and SAR.txn_billing_type_id = RTSAR.txn_billing_type_id(+)
               and SAR.billing_type = MTL.material_billable_flag(+);
              */

        CURSOR c_material_lines_from_bom(p_repair_line_id NUMBER, p_repair_type_id NUMBER) IS
        -- p_price_list_id  NUMBER) is, bug 3468680, vkjain
            SELECT BOM.component_item_id  INVENTORY_ITEM_ID,
                   BOM.primary_uom_code   UOM,
                   BOM.component_quantity QUANTITY,
                   -- PRICE.list_price            SELLING_PRICE,
                   MTL.concatenated_segments ITEM_NAME,
                   MTL.comms_nl_trackable_flag COMMS_NL_TRACKABLE_FLAG,
                   SAR.txn_billing_type_id TXN_BILLING_TYPE_ID,
                   'SERVICE_CODE' EST_LINE_SOURCE_TYPE_CODE,
                   ROSC.Service_Code_id EST_LINE_SOURCE_ID1,
                   NULL EST_LINE_SOURCE_ID2,
                   ROSC.RO_Service_Code_id RO_SERVICE_CODE_ID
              FROM CSD_RO_SERVICE_CODES       ROSC,
                   CSD_SERVICE_CODES_VL       SC,
                   CSD_SC_WORK_ENTITIES       WRK,
                   BOM_INVENTORY_COMPONENTS_V BOM,
                   -- QP_PRICE_LIST_LINES_V      PRICE,
                   MTL_SYSTEM_ITEMS_KFV MTL,
                   CSD_REPAIR_TYPES_SAR RTSAR,
                   CS_TXN_BILLING_TYPES SAR
             WHERE ROSC.repair_line_id = p_repair_line_id
               AND ROSC.applicable_flag = 'Y'
                  -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               AND ROSC.applied_to_est_flag = 'N'
               AND WRK.Service_code_id = ROSC.Service_code_id
               AND WRK.work_entity_type_code = 'BOM'
               AND SC.Service_code_Id = ROSC.Service_code_id
               AND NVL(SC.active_from, SYSDATE) <= SYSDATE
               AND NVL(SC.active_to, SYSDATE) >= SYSDATE
               AND WRK.work_entity_id3 = Cs_Std.get_item_valdn_orgzn_id
                  -- and WRK.work_entity_id1 IS NOT NULL
               AND BOM.bill_sequence_id = WRK.work_entity_id1
               AND NVL(BOM.effectivity_date, SYSDATE) <= SYSDATE -- swai bug 3323274
               AND NVL(BOM.disable_date, SYSDATE) >= SYSDATE -- swai bug 3323274
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and PRICE.price_list_id(+) = p_price_list_id
                  -- and PRICE.inventory_item_id(+) = BOM.component_item_id
                  -- and PRICE.unit_code(+) = BOM.primary_uom_code
                  -- and nvl(PRICE.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(PRICE.end_date_active, SYSDATE) >= SYSDATE    -- swai added
               AND MTL.inventory_item_id = BOM.component_item_id
               AND MTL.organization_id = WRK.work_entity_id3
               AND RTSAR.repair_type_id = p_repair_type_id
               AND SAR.txn_billing_type_id = RTSAR.txn_billing_type_id(+)
               AND SAR.billing_type = MTL.material_billable_flag(+)
               AND MTL.material_billable_flag IS NOT NULL;

        CURSOR c_labor_lines_from_bom(p_repair_line_id NUMBER, p_repair_type_id NUMBER) IS
        -- p_price_list_id  NUMBER) is -- bug 3468680, vkjain
            SELECT RES.billable_item_id INVENTORY_ITEM_ID,
                   RES.unit_of_measure  UOM,
                   -- OPRES.assigned_units        QUANTITY, -- Replaced by following line to fix 3365436. vkjain.
                   OPRES.usage_rate_or_amount QUANTITY,
                   -- PRICE.list_price            SELLING_PRICE,
                   MTL.concatenated_segments ITEM_NAME,
                   MTL.comms_nl_trackable_flag COMMS_NL_TRACKABLE_FLAG,
                   SAR.txn_billing_type_id TXN_BILLING_TYPE_ID,
                   'SERVICE_CODE' EST_LINE_SOURCE_TYPE_CODE,
                   ROSC.Service_Code_id EST_LINE_SOURCE_ID1,
                   NULL EST_LINE_SOURCE_ID2,
                   ROSC.RO_Service_Code_id RO_SERVICE_CODE_ID,
                   RES.resource_id RESOURCE_ID -- vkjain. 3449978
              FROM CSD_RO_SERVICE_CODES    ROSC,
                   CSD_SC_WORK_ENTITIES    WRK,
                   CSD_SERVICE_CODES_VL    SC,
                   BOM_OPERATION_SEQUENCES OPSEQ,
                   BOM_OPERATION_RESOURCES OPRES,
                   -- QP_PRICE_LIST_LINES_V   PRICE,
                   MTL_SYSTEM_ITEMS_KFV MTL,
                   CSD_REPAIR_TYPES_SAR RTSAR,
                   CS_TXN_BILLING_TYPES SAR,
                   BOM_RESOURCES        RES
             WHERE ROSC.repair_line_id = p_repair_line_id
               AND ROSC.applicable_flag = 'Y'
                  -- and ROSC.applied_to_work_flag = 'N' -- bugfix 3473869.vkjain.
               AND ROSC.applied_to_est_flag = 'N'
               AND WRK.Service_code_id = ROSC.Service_code_id
               AND WRK.work_entity_type_code = 'BOM'
               AND SC.Service_code_Id = ROSC.Service_code_id
               AND NVL(SC.active_from, SYSDATE) <= SYSDATE
               AND NVL(SC.active_to, SYSDATE) >= SYSDATE
               AND WRK.work_entity_id3 = Cs_Std.get_item_valdn_orgzn_id
                  -- and WRK.work_entity_id2 IS NOT NULL
               AND OPSEQ.ROUTING_SEQUENCE_ID = WRK.work_entity_id2
               AND NVL(OPSEQ.effectivity_date, SYSDATE) <= SYSDATE -- swai bug 3323274
               AND NVL(OPSEQ.disable_date, SYSDATE) >= SYSDATE -- swai bug 3323274
               AND OPRES.OPERATION_SEQUENCE_ID =
                   OPSEQ.OPERATION_SEQUENCE_ID
               AND RES.RESOURCE_ID = OPRES.RESOURCE_ID
                  -- Following lines commented by vkjain, bugfix 3468680
                  -- and PRICE.price_list_id(+) = p_price_list_id
                  -- and nvl(PRICE.start_date_active, SYSDATE) <= SYSDATE  -- swai added
                  -- and nvl(PRICE.end_date_active, SYSDATE) >= SYSDATE    -- swai added
                  -- and PRICE.inventory_item_id(+) = RES.billable_item_id
                  -- and PRICE.unit_code(+) = RES.unit_of_measure
               AND MTL.inventory_item_id = RES.billable_item_id
               AND MTL.organization_id = WRK.work_entity_id3
               AND MTL.material_billable_flag IS NOT NULL
               AND RTSAR.repair_type_id = p_repair_type_id
               AND SAR.txn_billing_type_id = RTSAR.txn_billing_type_id(+)
               AND SAR.billing_type = MTL.material_billable_flag(+);

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Get_Estimates_From_BOM;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(lc_api_version,
                                           p_api_version,
                                           lc_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.BEGIN',
                           'Entering CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_BOM');
        END IF;
        -- log parameters
        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_api_version: ' || p_api_version);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_commit: ' || p_commit);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_init_msg_list: ' || p_init_msg_list);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_validation_level: ' || p_validation_level);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_line_id: ' || p_repair_line_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_estimate_id: ' || p_estimate_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_type_id: ' || p_repair_type_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_business_process_id: ' ||
                           p_business_process_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_currency_code: ' || p_currency_code);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_incident_id: ' || p_incident_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_mode: ' || p_repair_mode);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_inventory_item_id: ' || p_inventory_item_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_organization_id: ' || p_organization_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_price_list_id: ' || p_price_list_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_contract_line_id: ' || p_contract_line_id);
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- initialize the warning flag
        x_warning_flag := Fnd_Api.G_FALSE;

        --
        -- Begin API Body
        --

        --
        -- Get Material Lines from BOM
        --
        DECLARE
            l_count NUMBER := 0;
        BEGIN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Getting BOM material lines from service codes');
            END IF;
            -- Bugfix 3468680, vkjain
            -- FOR r1 in c_material_lines_from_bom (p_repair_line_id, p_repair_type_id, p_price_list_id)
            FOR r1 IN c_material_lines_from_bom(p_repair_line_id,
                                                p_repair_type_id)
            LOOP
                l_count := l_count + 1;
                l_material_lines_tbl(l_count).inventory_item_id := r1.inventory_item_id;
                l_material_lines_tbl(l_count).uom := r1.uom;
                l_material_lines_tbl(l_count).quantity := r1.quantity;
                -- Bugfix 3468680, vkjain
                -- l_material_lines_tbl(l_count).selling_price := r1.selling_price;
                l_material_lines_tbl(l_count).item_name := r1.item_name;
                l_material_lines_tbl(l_count).comms_nl_trackable_flag := r1.comms_nl_trackable_flag;
                l_material_lines_tbl(l_count).txn_billing_type_id := r1.txn_billing_type_id;
                l_material_lines_tbl(l_count).est_line_source_type_code := r1.est_line_source_type_code;
                l_material_lines_tbl(l_count).est_line_source_id1 := r1.est_line_source_id1;
                l_material_lines_tbl(l_count).est_line_source_id2 := r1.est_line_source_id2;
                l_material_lines_tbl(l_count).ro_service_code_id := r1.ro_service_code_id;
            END LOOP;
        END;

        -- bugfix 3543135, vkjain.
        IF (l_material_lines_tbl.COUNT > 0)
        THEN
            l_No_Eligible_Lines := FALSE;
        END IF;

--        IF (g_debug >= 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_mle_lines_tbl_type(l_material_lines_tbl);
--        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'material line count = ' ||
                           l_material_lines_tbl.COUNT);
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Calling Convert_To_Est_Lines');
        END IF;

        Convert_To_Est_Lines(p_api_version         => 1.0,
                             p_commit              => Fnd_Api.G_FALSE,
                             p_init_msg_list       => Fnd_Api.G_FALSE,
                             p_validation_level    => p_validation_level,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_repair_line_id      => p_repair_line_id,
                             p_estimate_id         => p_estimate_id,
                             p_repair_type_id      => p_repair_type_id,
                             p_business_process_id => p_business_process_id,
                             p_currency_code       => p_currency_code,
                             p_incident_id         => p_incident_id,
                             p_organization_id     => p_organization_id,
                             p_price_list_id       => p_price_list_id,
                             p_contract_line_id    => p_contract_line_id,
                             p_MLE_lines_tbl       => l_material_lines_tbl,
                             x_est_lines_tbl       => x_est_lines_tbl,
                             x_warning_flag        => l_warning_flag);

--        IF (g_debug >= 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_repair_estimate_line_tbl(x_est_lines_tbl);
--        END IF;

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF l_warning_flag <> Fnd_Api.G_FALSE
        THEN
            x_warning_flag := l_warning_flag;
        END IF;
        --
        -- Get Labor Lines from BOM
        --
        DECLARE
            l_count NUMBER := 0;
        BEGIN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Getting BOM labor lines from service codes');
            END IF;
            -- bugfix 3468680, vkjain
            -- FOR r2 in c_labor_lines_from_bom (p_repair_line_id, p_repair_type_id, p_price_list_id)
            FOR r2 IN c_labor_lines_from_bom(p_repair_line_id,
                                             p_repair_type_id)
            LOOP
                l_count := l_count + 1;
                l_labor_lines_tbl(l_count).inventory_item_id := r2.inventory_item_id;
                l_labor_lines_tbl(l_count).uom := r2.uom;
                l_labor_lines_tbl(l_count).quantity := r2.quantity;
                -- Bugfix 3468680, vkjain
                -- l_labor_lines_tbl(l_count).selling_price := r2.selling_price;
                l_labor_lines_tbl(l_count).item_name := r2.item_name;
                l_labor_lines_tbl(l_count).comms_nl_trackable_flag := r2.comms_nl_trackable_flag;
                l_labor_lines_tbl(l_count).txn_billing_type_id := r2.txn_billing_type_id;
                l_labor_lines_tbl(l_count).est_line_source_type_code := r2.est_line_source_type_code;
                l_labor_lines_tbl(l_count).est_line_source_id1 := r2.est_line_source_id1;
                l_labor_lines_tbl(l_count).est_line_source_id2 := r2.est_line_source_id2;
                l_labor_lines_tbl(l_count).ro_service_code_id := r2.ro_service_code_id;
                -- vkjain. Bugfix 3449978.
                l_labor_lines_tbl(l_count).resource_id := r2.resource_id;
            END LOOP;
        END;

        -- bugfix 3543135, vkjain.
        IF (l_labor_lines_tbl.COUNT > 0)
        THEN
            l_No_Eligible_Lines := FALSE;
        END IF;

--        IF (g_debug >= 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_mle_lines_tbl_type(l_labor_lines_tbl);
--        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'labor line count = ' || l_labor_lines_tbl.COUNT);
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name,
                           'Calling Convert_To_Est_Lines');
        END IF;
        Convert_To_Est_Lines(p_api_version         => 1.0,
                             p_commit              => Fnd_Api.G_FALSE,
                             p_init_msg_list       => Fnd_Api.G_FALSE,
                             p_validation_level    => p_validation_level,
                             x_return_status       => x_return_status,
                             x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data,
                             p_repair_line_id      => p_repair_line_id,
                             p_estimate_id         => p_estimate_id,
                             p_repair_type_id      => p_repair_type_id,
                             p_business_process_id => p_business_process_id,
                             p_currency_code       => p_currency_code,
                             p_incident_id         => p_incident_id,
                             p_organization_id     => p_organization_id,
                             p_price_list_id       => p_price_list_id,
                             p_contract_line_id    => p_contract_line_id,
                             p_MLE_lines_tbl       => l_labor_lines_tbl,
                             x_est_lines_tbl       => x_est_lines_tbl,
                             x_warning_flag        => l_warning_flag);

--        IF (g_debug >= 5)
--        THEN
--            Csd_Gen_Utility_Pvt.dump_repair_estimate_line_tbl(x_est_lines_tbl);
--        END IF;

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
        IF l_warning_flag <> Fnd_Api.G_FALSE
        THEN
            x_warning_flag := l_warning_flag;
        END IF;

        -- bugfix 3543135, vkjain.
        -- IF (NVL(x_est_lines_tbl.count, 0) <= 0) THEN
        IF (l_No_Eligible_Lines)
        THEN
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'no estimate lines available to autogenerate from BOM');
            END IF;
            RAISE CSD_EST_NO_AUTOGEN;
        END IF;

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.out_parameter',
                           'x_warning_flag: ' || x_warning_flag);
        END IF;
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.END',
                           'Leaving CSD_REPAIR_ESTIMATE_PVT.Get_Estimates_From_BOM');
        END IF;

        --
        -- End API Body
        --

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN CSD_EST_NO_AUTOGEN THEN
            x_warning_flag := Fnd_Api.G_TRUE;

            -- save message in fnd stack
            IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Statement,
                               lc_mod_name,
                               'Adding message CSD_EST_NO_AUTOGEN to FND_MSG stack');
            END IF;
            Fnd_Message.SET_NAME('CSD', 'CSD_EST_NO_AUTOGEN');
            Fnd_Msg_Pub.ADD;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'No estimate lines autogenerated');
            END IF;
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Get_Estimates_From_BOM;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;

            /*
            -- TO DO: Add seeded err message
            -- save message in fnd stack
                if (Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) then
                    FND_LOG.STRING(Fnd_Log.Level_Statement, lc_mod_name,
                                   'Adding message err_name to FND_MSG stack');
                end if;
            FND_MESSAGE.SET_NAME('CSD','err_name');
            FND_MESSAGE.SET_TOKEN('toke_name', 'token_value');
            FND_MSG_PUB.ADD;
            */
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Get_Estimates_From_BOM;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO Get_Estimates_From_BOM;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                -- create a seeded message
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'SQL Message[' || SQLERRM || ']');
            END IF;
    END Get_Estimates_From_BOM;

    /*--------------------------------------------------*/
    /* procedure name: Convert_To_Est_Lines             */
    /* description   : The procedure to manipulate      */
    /*                 different structures. It converts*/
    /*                 data from MLE_LINES_REC_TYPE to  */
    /*                 REPAIR_ESTIMATE_LINE_REC. It also*/
    /*                 sets the item cost and logs      */
    /*                 warnings.                        */
    /*                                                  */
    /* x_warning_flag : FND_API.G_TRUE if any non-fatal */
    /*                  errors occured. FND_API.G_FALSE */
    /*                  if everything was successful.   */
    /*                  Note that this value could be   */
    /*                  G_TRUE even if x_return_status  */
    /*                  is G_RET_STS_SUCCESS            */
    /* called from:  Get_Estimates_From_BOM             */
    /*               Get_Estimates_From_Task            */
    /*--------------------------------------------------*/
    PROCEDURE Convert_To_Est_Lines(p_api_version         IN NUMBER,
                                   p_commit              IN VARCHAR2,
                                   p_init_msg_list       IN VARCHAR2,
                                   p_validation_level    IN NUMBER,
                                   x_return_status       OUT NOCOPY VARCHAR2,
                                   x_msg_count           OUT NOCOPY NUMBER,
                                   x_msg_data            OUT NOCOPY VARCHAR2,
                                   p_repair_line_id      IN NUMBER,
                                   p_estimate_id         IN NUMBER,
                                   p_repair_type_id      IN NUMBER,
                                   p_business_process_id IN NUMBER,
                                   p_currency_code       IN VARCHAR2,
                                   p_incident_id         IN NUMBER,
                                   p_organization_id     IN NUMBER,
                                   p_price_list_id       IN NUMBER,
                                   p_contract_line_id    IN NUMBER,
                                   p_MLE_lines_tbl       IN MLE_LINES_TBL_TYPE,
                                   x_est_lines_tbl       IN OUT NOCOPY REPAIR_ESTIMATE_LINE_TBL,
                                   x_warning_flag        OUT NOCOPY VARCHAR2) IS
        -- CONSTANTS --
        lc_debug_level CONSTANT NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;
        lc_stat_level  CONSTANT NUMBER := Fnd_Log.LEVEL_STATEMENT;
        lc_proc_level  CONSTANT NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        lc_event_level CONSTANT NUMBER := Fnd_Log.LEVEL_EVENT;
        lc_excep_level CONSTANT NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        lc_error_level CONSTANT NUMBER := Fnd_Log.LEVEL_ERROR;
        lc_unexp_level CONSTANT NUMBER := Fnd_Log.LEVEL_UNEXPECTED;
        lc_mod_name    CONSTANT VARCHAR2(100) := 'csd.plsql.csd_repair_estimate_pvt.convert_to_est_lines';
        lc_api_name    CONSTANT VARCHAR2(30) := 'Convert_To_Est_Lines';
        lc_api_version CONSTANT NUMBER := 1.0;

        -- VARIABLES --
        l_error           BOOLEAN;
        l_numRows         NUMBER;
        l_curRow          NUMBER;
        l_price_list_name VARCHAR2(240);
        l_num_subtypes    NUMBER;
        l_ext_price       NUMBER;
        l_selling_price   NUMBER;
        l_no_charge_flag  VARCHAR2(1);

        l_return_status VARCHAR2(1);
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);

        -- Pricing attributes
        l_pricing_rec Csd_Process_Util.pricing_attr_rec;
		--bug#3875036
		l_account_id						NUMBER        := NULL;

        -- cursors --
        /* -- no longer validating this due to performance
         cursor count_csi_txn_subtypes (p_txn_billing_type_id NUMBER) is
            -- number of txn subtypes for a given txn billing type
            SELECT count(*)
            FROM   csi_txn_sub_types ib,
                   cs_txn_billing_types cs
            WHERE  ib.cs_transaction_type_id = cs.transaction_type_id
                   and cs.txn_billing_type_id = p_txn_billing_type_id;
        */

        CURSOR c_transaction_type(p_txn_billing_type_id NUMBER) IS
            SELECT cs.transaction_type_id
              FROM cs_txn_billing_types cs
             WHERE cs.txn_billing_type_id = p_txn_billing_type_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT Convert_To_Est_Lines;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(lc_api_version,
                                           p_api_version,
                                           lc_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.BEGIN',
                           'Entering CSD_REPAIR_ESTIMATE_PVT.Convert_To_Est_Lines');
        END IF;
        -- log parameters
        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_api_version: ' || p_api_version);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_commit: ' || p_commit);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_init_msg_list: ' || p_init_msg_list);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_validation_level: ' || p_validation_level);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_line_id: ' || p_repair_line_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_estimate_id: ' || p_estimate_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_repair_type_id: ' || p_repair_type_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_business_process_id: ' ||
                           p_business_process_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_currency_code: ' || p_currency_code);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_incident_id: ' || p_incident_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_organization_id: ' || p_organization_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_price_list_id: ' || p_price_list_id);
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.parameter_logging',
                           'p_contract_line_id: ' || p_contract_line_id);
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- initialize the warning flag
        x_warning_flag := Fnd_Api.G_FALSE;

	/* bug#3875036 */
		l_account_id := CSD_CHARGE_LINE_UTIL.Get_SR_AccountId(p_repair_line_id);

        --
        -- Begin API Body
        --
        l_numRows := p_MLE_lines_tbl.COUNT;
        FOR i IN 1 .. l_numRows
        LOOP
            l_error := FALSE;
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Processing MLE line ' || i);
            END IF;

            -- Initialize the selling price variable.
            -- bugfix 3468680, vkjain.
            l_selling_price := NULL;

            -- get the selling price of the item
            -- if no selling price, then we cannot determine charge, so
            -- log a warning.
            BEGIN
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Calling CSD_PROCESS_UTIL.get_charge_selling_price');
                END IF;

                Csd_Process_Util.GET_CHARGE_SELLING_PRICE(p_inventory_item_id    => p_MLE_lines_tbl(i)
                                                                                   .inventory_item_id,
                                                          p_price_list_header_id => p_price_list_id,
                                                          p_unit_of_measure_code => p_MLE_lines_tbl(i).uom,
                                                          p_currency_code        => p_currency_code,
                                                          p_quantity_required    => p_MLE_lines_tbl(i).quantity,
														  p_account_id			  => l_account_id,  /* bug#3875036 */
														  p_org_id => p_organization_id, -- added for R12
                                                          p_pricing_rec          => l_pricing_rec,
                                                          x_selling_price        => l_selling_price,
                                                          x_return_status        => l_return_status,
                                                          x_msg_count            => l_msg_count,
                                                          x_msg_data             => l_msg_data);
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Returned from CSD_PROCESS_UTIL.get_charge_selling_price');
                END IF;
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'l_selling_price = ' || l_selling_price);
                END IF;
            EXCEPTION
                WHEN Fnd_Api.G_EXC_ERROR THEN
                    l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Exception FND_API.G_EXC_ERROR occurred in CSD_PROCESS_UTIL.get_charge_selling_price');
                    END IF;
                WHEN OTHERS THEN
                    l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Exception OTHERS occurred in CSD_PROCESS_UTIL.get_charge_selling_price');
                    END IF;
            END;

            IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) OR
               (l_selling_price IS NULL)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message CSD_EST_NOPRICE_ITEM_UOM to FND_MSG stack');
                END IF;
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_NOPRICE_ITEM_UOM');
                BEGIN
                    SELECT name
                      INTO l_price_list_name
                      FROM qp_list_headers_tl
                     WHERE list_header_id = p_price_list_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_price_list_name := p_price_list_id;
                        IF (Fnd_Log.Level_Procedure >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                           lc_mod_name,
                                           'Exception NO_DATA_FOUND occurred while querying for price list name');
                        END IF;
                    WHEN OTHERS THEN
                        l_price_list_name := p_price_list_id;
                        IF (Fnd_Log.Level_Procedure >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                           lc_mod_name,
                                           'Exception OTHERS occurred while querying for price list name');
                        END IF;
                END;
                Fnd_Message.SET_TOKEN('ITEM', p_MLE_lines_tbl(i).item_name);
                Fnd_Message.SET_TOKEN('PRICELIST', l_price_list_name);
                Fnd_Message.SET_TOKEN('UOM', p_MLE_lines_tbl(i).uom);
                Fnd_Msg_Pub.ADD;
                l_error := TRUE;
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Unable to get price for item-uom combination in pricelist ' ||
                                   p_price_list_id);
                END IF;
            END IF;

            -- check txn billing type
            IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                               lc_mod_name,
                               'Checking for required txn billing type id');
            END IF;
            IF (p_MLE_lines_tbl(i).txn_billing_type_id IS NULL)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message CSD_EST_NO_ITEM_SAR to FND_MSG stack');
                END IF;
                Fnd_Message.SET_NAME('CSD', 'CSD_EST_NO_ITEM_SAR');
                Fnd_Message.SET_TOKEN('ITEM', p_MLE_lines_tbl(i).item_name);
                Fnd_Msg_Pub.ADD;
                l_error := TRUE;
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Error - txn_billing_type_id is null');
                ELSE
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Txn billing type id is available');
                    END IF;
                END IF;

            END IF;

            IF (l_error = FALSE)
            THEN
                l_curRow := x_est_lines_tbl.COUNT + 1;

                -- default no_charge if it is set up in charges
                -- this is probably a rare case
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting no charge flag to determine extended price');
                END IF;
                l_no_charge_flag := Csd_Process_Util.Get_No_Chg_Flag(p_MLE_lines_tbl(i)
                                                                     .txn_billing_type_id);
                IF (NVL(l_no_charge_flag, 'N') = 'Y')
                THEN
                    l_ext_price := 0;
                ELSE
                    -- l_ext_price := nvl(p_MLE_lines_tbl(i).quantity, 0) * nvl(p_MLE_lines_tbl(i).selling_price,0);
                    -- bugfix 3468680 vkjain. Using the price from the Pricing Engine API.
                    l_ext_price := NVL(p_MLE_lines_tbl(i).quantity, 0) *
                                   l_selling_price;
                END IF;
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'l_no_charge_flag = ' ||
                                   l_no_charge_flag);
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'l_ext_price = ' || l_ext_price);
                END IF;

                --
                -- Derive after waranty cost
                -- note: this portion of code is very similar to
                -- ESTIMATE_UTILS.copy_unitprice_nochg_values in CSDREPLN.pld
                -- consider modularizing code for this
                --
                IF (p_contract_line_id IS NOT NULL) AND
                   (p_business_process_id IS NOT NULL) AND
                   (NVL(l_no_charge_flag, 'N') = 'N')
                THEN
                    BEGIN
                        IF (Fnd_Log.Level_Procedure >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                           lc_mod_name,
                                           'Calling CSD_CHARGE_LINE_UTIL.Get_CoverageInfo');
                        END IF;
                        Csd_Charge_Line_Util.Get_CoverageInfo(p_contract_line_id      => p_contract_line_id,
                                                              p_business_process_id   => p_business_process_id,
                                                              x_return_status         => x_return_status,
                                                              x_msg_count             => x_msg_count,
                                                              x_msg_data              => x_msg_data,
                                                              x_contract_id           => x_est_lines_tbl(l_curRow)
                                                                                        .contract_id,
                                                              x_contract_number       => x_est_lines_tbl(l_curRow)
                                                                                        .contract_number,
                                                              x_coverage_id           => x_est_lines_tbl(l_curRow)
                                                                                        .coverage_id,
                                                              x_coverage_txn_group_id => x_est_lines_tbl(l_curRow)
                                                                                        .coverage_txn_group_id);
                        IF (Fnd_Log.Level_Statement >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'x_contract_id = ' ||
                                            x_est_lines_tbl(l_curRow)
                                           .contract_id);
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'x_contract_number = ' ||
                                            x_est_lines_tbl(l_curRow)
                                           .contract_number);
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'x_coverage_id = ' ||
                                            x_est_lines_tbl(l_curRow)
                                           .coverage_id);
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'x_coverage_txn_group_id = ' ||
                                            x_est_lines_tbl(l_curRow)
                                           .coverage_txn_group_id);
                        END IF;

                    EXCEPTION
                        WHEN Fnd_Api.G_EXC_ERROR THEN
                            l_return_status := Fnd_Api.G_RET_STS_ERROR;
                        WHEN OTHERS THEN
                            l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    END;

                    IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
                    THEN
                        l_error := TRUE;
                    END IF;

                    BEGIN
                        IF (Fnd_Log.Level_Procedure >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                           lc_mod_name,
                                           'Calling CSD_CHARGE_LINE_UTIL.get_discountedprice');
                        END IF;
                        Csd_Charge_Line_Util.GET_DISCOUNTEDPRICE(p_api_version         => 1.0,
                                                                 p_init_msg_list       => Fnd_Api.G_FALSE,
                                                                 p_contract_line_id    => p_contract_line_id,
                                                                 p_repair_type_id      => p_repair_type_id,
                                                                 p_txn_billing_type_id => p_MLE_lines_tbl(i)
                                                                                         .txn_billing_type_id,
                                                                 p_coverage_txn_grp_id => x_est_lines_tbl(l_curRow)
                                                                                         .coverage_txn_group_id,
                                                                 p_extended_price      => l_ext_price,
                                                                 p_no_charge_flag      => l_no_charge_flag,
                                                                 x_discounted_price    => x_est_lines_tbl(l_curRow)
                                                                                         .after_warranty_cost,
                                                                 x_return_status       => l_return_status,
                                                                 x_msg_count           => l_msg_count,
                                                                 x_msg_data            => l_msg_data);
                        IF (Fnd_Log.Level_Statement >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'x_discounted_price = ' ||
                                            x_est_lines_tbl(l_curRow)
                                           .after_warranty_cost);
                        END IF;
                    EXCEPTION
                        WHEN Fnd_Api.G_EXC_ERROR THEN
                            l_return_status := Fnd_Api.G_RET_STS_ERROR;
                        WHEN OTHERS THEN
                            l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    END;
                    IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
                    THEN
                        IF (Fnd_Log.Level_Statement >=
                           Fnd_Log.G_Current_Runtime_Level)
                        THEN
                            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                           lc_mod_name,
                                           'Adding message CSD_EST_ESTIMATED_CHARGE_ERR to FND_MSG stack');
                        END IF;
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_EST_ESTIMATED_CHARGE_ERR');
                        Fnd_Message.SET_TOKEN('CONTRACT_NUMBER',
                                              x_est_lines_tbl(l_curRow)
                                              .contract_number);
                        Fnd_Msg_Pub.ADD;
                        l_error := TRUE;
                    END IF;
                    -- Bugfix 3843770, vkjain.
                    -- The contract discount field is not being populated for AutoCreate
                    -- estimate lines.
                    x_est_lines_tbl(l_curRow).contract_discount_amount := l_ext_price -
                                                                          NVL(x_est_lines_tbl(l_curRow)
                                                                              .after_warranty_cost,
                                                                              0);
                ELSE
                    -- p_contract_line_id is null or p_business_process_id is null
                    x_est_lines_tbl(l_curRow).after_warranty_cost := l_ext_price;
                END IF; -- end derive after warranty cost

                -- Added by vkjain. 3449978.
                x_est_lines_tbl(l_curRow).resource_id := p_MLE_lines_tbl(i)
                                                        .resource_id;

                BEGIN
                    IF (Fnd_Log.Level_Procedure >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                       lc_mod_name,
                                       'Calling CSD_COST_ANALYSIS_PVT.arcs in forms/US/CSDREPLN.fmb
				   ItemCost');
                    END IF;

                    -- Bugfix 3449978. vkjain.
                    -- We attempt to get the resource_id for labor lines.
                    -- The Get_InvItemCost procedure is replaced by
                    -- Get_ResItemCost. The Get_ResItemCost procedure
                    -- gets the reosurce cost if it exists and otherwise
                    -- gets the item cost.
                    -- CSD_COST_ANALYSIS_PVT.Get_InvItemCost(
                    Csd_Cost_Analysis_Pvt.Get_ResItemCost(
                                                          -- p_api_version           =>     1.0,
                                                          -- p_commit                =>     fnd_api.g_false,
                                                          -- p_init_msg_list         =>     fnd_api.g_false,
                                                          -- p_validation_level      =>     fnd_api.g_valid_level_full,
                                                          x_return_status     => l_return_status,
                                                          x_msg_count         => l_msg_count,
                                                          x_msg_data          => l_msg_data,
                                                          p_inventory_item_id => p_MLE_lines_tbl(i)
                                                                                .inventory_item_id,
                                                          p_organization_id   => p_organization_id,
                                                          p_bom_resource_id   => p_MLE_lines_tbl(i)
                                                                                .resource_id,
                                                          p_charge_date       => SYSDATE,
                                                          p_currency_code     => p_currency_code,
                                                          p_chg_line_uom_code => p_MLE_lines_tbl(i).uom, --sangigup 3356020
                                                          x_item_cost         => x_est_lines_tbl(l_curRow)
                                                                                .item_cost);
                    IF (Fnd_Log.Level_Statement >=
                       Fnd_Log.G_Current_Runtime_Level)
                    THEN
                        Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                       lc_mod_name,
                                       'x_item_cost = ' ||
                                       x_est_lines_tbl(l_curRow).item_cost);
                    END IF;
                EXCEPTION
                    WHEN Fnd_Api.G_EXC_ERROR THEN
                        l_return_status := Fnd_Api.G_RET_STS_ERROR;
                    WHEN OTHERS THEN
                        l_return_status := Fnd_Api.G_RET_STS_ERROR;
                END;

                IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    x_est_lines_tbl(l_curRow).item_cost := NULL;
                    --
                    -- TO DO: give warning message that cost could not be determined?
                    -- x_warning_flag  := FND_API.G_TRUE;
                    -- x_return_status := FND_API.G_RET_STS_ERROR;
                    --    if (Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) then
                    --        FND_LOG.STRING(Fnd_Log.Level_Statement, lc_mod_name,
                    --                       'Adding message CSD_EST_ESTIMATED_CHARGE_ERR to FND_MSG stack');
                    --    end if;
                    -- FND_MESSAGE.SET_NAME('CSD','CSD_EST_ESTIMATED_CHARGE_ERR');
                    -- FND_MESSAGE.SET_TOKEN('CONTRACT_NUMBER',x_est_lines_tbl(l_curRow).contract_number);
                    -- FND_MSG_PUB.ADD;
                    -- l_error := TRUE;
                END IF;

                -- set transaction type (Material, labor, expense)
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Getting transaction type id');
                END IF;
                OPEN c_transaction_type(p_MLE_lines_tbl(i)
                                        .txn_billing_type_id);
                FETCH c_transaction_type
                    INTO x_est_lines_tbl(l_curRow) .transaction_type_id;
                CLOSE c_transaction_type;

                -- values from individual params
                x_est_lines_tbl(l_curRow).repair_estimate_id := p_estimate_id; -- required param
                x_est_lines_tbl(l_curRow).repair_line_id := p_repair_line_id; -- required param
                x_est_lines_tbl(l_curRow).incident_id := p_incident_id; -- derived value, do we need this?
                x_est_lines_tbl(l_curRow).business_process_id := p_business_process_id; -- optional value?, used if derived value not available
                x_est_lines_tbl(l_curRow).currency_code := p_currency_code; -- derived value, do we need this?
                x_est_lines_tbl(l_curRow).organization_id := p_organization_id; -- required param
                x_est_lines_tbl(l_curRow).price_list_id := p_price_list_id; -- required param

                -- values from MLE_LINES
                x_est_lines_tbl(l_curRow).txn_billing_type_id := p_MLE_lines_tbl(i)
                                                                .txn_billing_type_id; -- required param
                x_est_lines_tbl(l_curRow).inventory_item_id := p_MLE_lines_tbl(i)
                                                              .inventory_item_id; -- required param
                x_est_lines_tbl(l_curRow).unit_of_measure_code := p_MLE_lines_tbl(i).uom; -- required param
                x_est_lines_tbl(l_curRow).estimate_quantity := p_MLE_lines_tbl(i)
                                                              .quantity; -- required param
                -- x_est_lines_tbl(l_curRow).selling_price        := p_MLE_lines_tbl(i).selling_price;
                -- bugfix 3468680, vkjain.
                -- Setting the selling price that is from the Pricing Engine.
                x_est_lines_tbl(l_curRow).selling_price := l_selling_price;
                x_est_lines_tbl(l_curRow).est_line_source_type_code := p_MLE_lines_tbl(i)
                                                                      .est_line_source_type_code;
                x_est_lines_tbl(l_curRow).est_line_source_id1 := p_MLE_lines_tbl(i)
                                                                .est_line_source_id1;
                x_est_lines_tbl(l_curRow).est_line_source_id2 := p_MLE_lines_tbl(i)
                                                                .est_line_source_id2;
                x_est_lines_tbl(l_curRow).ro_service_code_id := p_MLE_lines_tbl(i)
                                                               .ro_service_code_id;
                -- bug#7212629, subhat.
                -- the contract line id information is not passed to
                -- charges API, but the contract id is passed.
                -- we need to pass contract line id, if not
                -- CSD_CHARGE_LINE_UTIL.GET_DISCOUNTEDPRICE will fail in CSDESTIM.pld.

                x_est_lines_tbl(l_curRow).contract_line_id := p_contract_line_id;
                --end bug#7212629, subhat.

                -- null items
                x_est_lines_tbl(l_curRow).reference_number := NULL;
                x_est_lines_tbl(l_curRow).order_number := NULL;
                x_est_lines_tbl(l_curRow).source_number := NULL;
                x_est_lines_tbl(l_curRow).original_source_number := NULL;
                x_est_lines_tbl(l_curRow).original_system_reference := NULL;
                x_est_lines_tbl(l_curRow).lot_number := NULL;
                x_est_lines_tbl(l_curRow).instance_id := NULL;
                x_est_lines_tbl(l_curRow).instance_number := NULL;
                x_est_lines_tbl(l_curRow).coverage_bill_rate_id := NULL;
                x_est_lines_tbl(l_curRow).sub_inventory := NULL;
                x_est_lines_tbl(l_curRow).return_reason := NULL;
                x_est_lines_tbl(l_curRow).last_update_date := NULL;
                x_est_lines_tbl(l_curRow).last_updated_by := NULL;
                x_est_lines_tbl(l_curRow).created_by := NULL;
                x_est_lines_tbl(l_curRow).last_update_login := NULL;
                x_est_lines_tbl(l_curRow).security_group_id := NULL;

                -- non-null items
                x_est_lines_tbl(l_curRow).return_by_date := SYSDATE;
                x_est_lines_tbl(l_curRow).creation_date := SYSDATE;
                x_est_lines_tbl(l_curRow).original_source_code := 'DR'; -- check for constants
                x_est_lines_tbl(l_curRow).source_code := 'DR';
                x_est_lines_tbl(l_curRow).charge_line_type := 'ESTIMATE'; -- check for constants to use
                x_est_lines_tbl(l_curRow).no_charge_flag := l_no_charge_flag;
                x_est_lines_tbl(l_curRow).override_charge_flag := NVL(l_no_charge_flag,
                                                                      'N'); -- charge is only overridden if no charge
                x_est_lines_tbl(l_curRow).interface_to_om_flag := 'N';

                -- TO DO: get default po number from repair estimate
                -- x_est_lines_tbl(l_curRow).purchase_order_num        := name_in('repair_estimate_line_det.po_number');

            END IF; -- end if l_error = FALSE.

            -- Note: Do NOT elsif this statement with the above "if (l_error = FALSE)",
            -- since the above section could potentially set l_error=TRUE as well.
            IF (l_error = TRUE)
            THEN
                x_warning_flag := Fnd_Api.G_TRUE;
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Calling CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Number of messages in stack: ' ||
                                   Fnd_Msg_Pub.count_msg);
                END IF;
                Csd_Gen_Errmsgs_Pvt.Save_Fnd_Msgs(p_api_version             => 1.0,
                                                  p_commit                  => Fnd_Api.G_FALSE,
                                                  p_init_msg_list           => Fnd_Api.G_FALSE,
                                                  p_validation_level        => 0,
                                                  p_module_code             => 'EST',
                                                  p_source_entity_id1       => p_repair_line_id,
                                                  p_source_entity_type_code => p_MLE_lines_tbl(i)
                                                                              .est_line_source_type_code,
                                                  p_source_entity_id2       => p_MLE_lines_tbl(i)
                                                                              .est_line_source_id1,
                                                  x_return_status           => l_return_status,
                                                  x_msg_count               => l_msg_count,
                                                  x_msg_data                => l_msg_data);
                IF NOT (l_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                THEN
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
                IF (Fnd_Log.Level_Procedure >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Returned from CSD_GEN_ERRMSGS_PVT.Save_Fnd_Msgs');
                    Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                                   lc_mod_name,
                                   'Number of messages in stack: ' ||
                                   Fnd_Msg_Pub.count_msg);
                END IF;
            END IF;
        END LOOP;

        IF (Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Statement,
                           lc_mod_name || '.out_parameter',
                           'x_warning_flag: ' || x_warning_flag);
        END IF;
        IF (Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level)
        THEN
            Fnd_Log.STRING(Fnd_Log.Level_Procedure,
                           lc_mod_name || '.END',
                           'Leaving CSD_REPAIR_ESTIMATE_PVT.Convert_To_Est_Lines');
        END IF;

        --
        -- End API Body
        --

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Convert_To_Est_Lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;

            /*
            -- TO DO: Add seeded err message
            -- save message in fnd stack
            if (Fnd_Log.Level_Statement>= Fnd_Log.G_Current_Runtime_Level) then
                FND_LOG.STRING(Fnd_Log.Level_Statement, lc_mod_name,
                               'Adding message err_name to FND_MSG stack');
            end if;
            FND_MESSAGE.SET_NAME('CSD','err_name');
            FND_MESSAGE.SET_TOKEN('toke_name', 'token_value');
            FND_MSG_PUB.ADD;
            */
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Convert_To_Est_Lines;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            ROLLBACK TO Convert_To_Est_Lines;
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;

            -- save message in fnd stack
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                IF (Fnd_Log.Level_Statement >=
                   Fnd_Log.G_Current_Runtime_Level)
                THEN
                    Fnd_Log.STRING(Fnd_Log.Level_Statement,
                                   lc_mod_name,
                                   'Adding message using FND_MSG_PUB.Add_Exc_Msg to FND_MSG stack');
                END IF;
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, lc_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

            -- save message in debug log
            IF (Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level)
            THEN
                -- create a seeded message
                Fnd_Log.STRING(Fnd_Log.Level_Exception,
                               lc_mod_name,
                               'SQL Message[' || SQLERRM || ']');
            END IF;
    END Convert_To_Est_Lines;
    --
    -- end swai 11.5.10
    --
    ----Begin change for 3931317, wrpper aPI forward port
    PROCEDURE debug(msg VARCHAR2) IS
    BEGIN
        IF (G_DEBUG_LEVEL >= 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD(msg);
            --DBMS_OUTPUT.PUT_LINE(msg);
        END IF;
    END DEBUG;

    /*----------------------------------------------------------------------------*/
    /* procedure name: CREATE_ESTIMATE_HEADER                                     */
    /* description   : Wrapper procedure used to create estimate header           */
    /*   Updates repair order estimate approved flag and creates Depot estimate   */
    /*   header record with information like, summary, lead time etc              */
    /*----------------------------------------------------------------------------*/

    PROCEDURE CREATE_ESTIMATE_HEADER(p_api_version      IN NUMBER,
                                     p_init_msg_list    IN VARCHAR2,
                                     p_commit           IN VARCHAR2,
                                     p_validation_level IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_estimate_hdr_id      OUT NOCOPY NUMBER ) IS
        l_incident_id     NUMBER;
        l_tmp_count       NUMBER;
        l_repln_obj_Ver   NUMBER;
        l_repln_quantity  NUMBER;
        l_approval_Status VARCHAR2(30);
        l_return_status   VARCHAR2(30);
        l_msg_count       NUMBER;
        l_msg_Data        VARCHAR2(2000);
        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_ESTIMATE_HEADER';
        l_api_version CONSTANT NUMBER := 1.0;

        l_estimate_hdr_rec Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC;
        l_est_hdr_pvt_rec     Csd_Repair_Estimate_Pvt.REPAIR_ESTIMATE_REC;
    BEGIN

        IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level)
        THEN
            Fnd_Log.STRING(Fnd_Log.level_procedure,
                           'csd.plsql.csd_repair_Estimate_pvt.create_estimate_header.begin',
                           'Entering create_estimate_header');
        END IF;
        -- Standard Start of API savepoint
        SAVEPOINT CREATE_ESTIMATE_HEADER_PVT;

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

        debug('Start of estiamte hdr creation for repair lineid[=' ||
              p_estimate_hdr_rec.repair_line_id || ']');

        l_estimate_hdr_rec := p_estimate_hdr_rec;

        csd_estimate_utils_pvt.validate_est_hdr_rec(p_estimate_hdr_rec => l_estimate_hdr_rec,
                                                p_validation_level => p_validation_level);

        csd_estimate_utils_pvt.default_est_hdr_rec(l_estimate_hdr_rec);

        csd_estimate_utils_pvt.validate_defaulted_est_hdr(l_estimate_hdr_rec,
                                                      p_validation_level);

        --If the estiamte_status is accepted or rejected then update the
        -- repair order status.
        IF (l_estimate_hdr_rec.estimate_status = C_EST_STATUS_ACCEPTED)
        THEN
            l_approval_Status := C_REP_STATUS_APPROVED;
        ELSIF (l_estimate_hdr_rec.estimate_status = C_EST_STATUS_REJECTED)
        THEN
            l_approval_Status := C_REP_STATUS_REJECTED;
        END IF;

        IF (l_estimate_hdr_rec.estimate_status = C_EST_STATUS_ACCEPTED OR
           l_estimate_hdr_rec.estimate_status = C_EST_STATUS_REJECTED)
        THEN

            debug('status is accepted or rejected');

            IF (l_estimate_hdr_rec.estimate_reason_code IS NOT NULL AND NOT
                Csd_Estimate_Utils_Pvt.VALIDATE_REASON(l_estimate_hdr_rec.estimate_reason_code,
                                                                                                                l_estimate_hdr_rec.estimate_status))
            THEN
                debug('Invalid estimate_reason_code[' ||
                      l_estimate_hdr_rec.estimate_reason_code || ']');
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            Csd_Repairs_Grp.UPDATE_APPROVAL_STATUS(p_repair_line_id        => l_estimate_hdr_rec.repair_line_id,
                                                   p_new_approval_status   => l_approval_Status,
                                                   p_old_approval_status   => NULL,
                                                   p_quantity              => l_estimate_hdr_rec.repair_line_quantity,
                                                   p_org_contact_id        => NULL,
                                                   p_reason                => '',
                                                   p_object_version_number => l_estimate_hdr_rec.ro_object_version_number,
                                                   x_return_status         => l_return_status,
                                                   x_msg_count             => l_msg_count,
                                                   x_msg_data              => l_msg_data);
            debug('Updated ro status');
            IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                debug('Updated ro status failed, x_msg_data[' ||
                      l_msg_data || ']');
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSE
            l_estimate_hdr_rec.estimate_reason_code := NULL;
        END IF;
        debug('creating estimate header');

        csd_estimate_utils_pvt.COPY_TO_EST_HDR_REC(l_estimate_hdr_rec,
                                               l_est_hdr_pvt_rec);
        Csd_Repair_Estimate_Pvt.create_repair_estimate(p_api_version      => 1.0,
                                                       p_commit           => Fnd_Api.G_FALSE,
                                                       p_init_msg_list    => Fnd_Api.G_FALSE,
                                                       p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                                       x_estimate_rec     => l_est_hdr_pvt_rec,
                                                       x_estimate_id      => x_estimate_hdr_id,
                                                       x_return_status    => l_return_status,
                                                       x_msg_count        => l_msg_count,
                                                       x_msg_data         => l_msg_data);

        debug('after creating the estimate header');

        IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            debug('create estiamte header failed, x_msg_data[' ||
                  l_msg_data || ']');
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        IF (Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level)
        THEN
            Fnd_Log.STRING(Fnd_Log.level_procedure,
                           'csd.plsql.csd_repair_Estimate_pvt.create_estimate_header.end',
                           'Leaving create_estimate_header');
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO create_estimate_header_pvt;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_header',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_estimate_header_pvt;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_header',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_estimate_header_pvt;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_header',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;

    END CREATE_ESTIMATE_HEADER;

    /*----------------------------------------------------------------------------*/
    /* procedure name: CREATE_ESTIMATE_LINE                                       */
    /* description   : private procedure used to create estimate line             */
    /*   Creates Depot estimate line record and submits                           */
    /*   based on some validations.                                               */
    /*----------------------------------------------------------------------------*/

    PROCEDURE CREATE_ESTIMATE_LINE(p_api_version       IN NUMBER,
                                   p_init_msg_list     IN VARCHAR2,
                                   p_commit            IN VARCHAR2,
							p_validation_level  IN NUMBER,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_msg_count         OUT NOCOPY NUMBER,
                                   x_msg_data          OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_estimate_line_id  OUT NOCOPY NUMBER) IS

        l_tmp_count      NUMBER;
        l_repair_type_id NUMBER;
        l_uom_Code       VARCHAR2(3);
        l_return_status  VARCHAR2(30);
        l_msg_count      NUMBER;
        l_msg_Data       VARCHAR2(2000);
        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_ESTIMATE_LINE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_no_charge_flag   VARCHAR2(10);
        l_contract_line_id NUMBER;

        l_est_pvt_line_rec   CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_LINE_REC;
        l_estimate_line_rec Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC;

    BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT CREATE_ESTIMATE_LINE_PVT;

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

        debug('Start of estimate line creation for estimate id[=' ||
              p_estimate_line_rec.repair_estimate_id || ']');

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           'csd.plsql.csd_repair_estimate_pvt.create_estimate_line.begin',
                           'Entering create_estimate_line');
        END IF;

        l_estimate_line_rec := p_estimate_line_rec;

        csd_estimate_utils_pvt.validate_est_LINE_rec(l_estimate_line_rec,
                                                 p_validation_level);

        csd_estimate_utils_pvt.default_est_line_rec(l_estimate_line_rec);

        csd_estimate_utils_pvt.validate_defaulted_est_line(l_estimate_line_rec,
                                                       p_validation_level);

--        csd_estimate_utils_pvt.copy_to_est_pvt_line_rec(l_estimate_line_rec,
--                                                    l_est_pvt_line_rec);

        debug('Calling create estimate_lines...');

        create_repair_estimate_lines(p_api_version       => 1.0,
                                     p_commit            => Fnd_Api.G_FALSE,
                                     p_init_msg_list     => Fnd_Api.G_FALSE,
                                     p_validation_level  => Fnd_Api.G_VALID_LEVEL_FULL,
                                     x_estimate_line_rec => l_est_pvt_line_rec,
                                     x_estimate_line_id  => x_estimate_line_id,
                                     x_return_status     => l_return_status,
                                     x_msg_count         => l_msg_count,
                                     x_msg_data          => l_msg_data);

        IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            debug('create estimate_lines failed..');
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           'csd.plsql.csd_repair_estimate_pvt.create_estimate_line.end',
                           'leaving create_estimate_line');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_line',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_line',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO CREATE_ESTIMATE_LINE_PVT;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.create_estimate_line',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;

    END CREATE_ESTIMATE_LINE;

    /*----------------------------------------------------------------------------*/
    /* procedure name: UPDATE_ESTIMATE_HEADER                                     */
    /* description   : procedure used to update estimate header                  */
    /*   Updates repair order estimate approved flag and creates Depot estimate   */
    /*   header record with information like, summary, lead time etc              */
    /*  Change History  : Created 24-June-2005 by Vijay                          */
    /*----------------------------------------------------------------------------*/
    PROCEDURE UPDATE_ESTIMATE_HEADER(p_api_version           IN NUMBER,
                                     p_init_msg_list         IN VARCHAR2,
                                     p_commit                IN VARCHAR2,
							  p_validation_level      IN NUMBER,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2,
                                     p_estimate_hdr_rec      IN Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC,
                                     x_object_version_number OUT NOCOPY NUMBER) IS

        l_return_status VARCHAR2(30);
        l_approval_Status VARCHAR2(30);
        l_msg_count     NUMBER;
        l_msg_Data      VARCHAR2(2000);
        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_ESTIMATE_HEADER';
        l_api_version CONSTANT NUMBER := 1.0;

        l_est_pvt_hdr_Rec CSD_REPAIR_ESTIMATE_PVT.REPAIR_ESTIMATE_REC;
        l_estimate_hdr_rec Csd_Repair_Estimate_Pub.ESTIMATE_HDR_REC;

        l_est_status_changed BOOLEAN;
	   l_est_hdr_id         NUMBER;

        CURSOR CUR_EST_HDR(p_estimate_header_id NUMBER) IS
            SELECT REPAIR_ESTIMATE_ID,
                   REPAIR_LINE_ID,
                   ESTIMATE_STATUS,
                   ESTIMATE_DATE,
                   WORK_SUMMARY,
                   PO_NUMBER,
                   LEAD_TIME,
                   LEAD_TIME_UOM,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATED_BY,
                   LAST_UPDATE_DATE,
                   LAST_UPDATE_LOGIN,
                   CONTEXT,
                   ATTRIBUTE1,
                   ATTRIBUTE2,
                   ATTRIBUTE3,
                   ATTRIBUTE4,
                   ATTRIBUTE5,
                   ATTRIBUTE6,
                   ATTRIBUTE7,
                   ATTRIBUTE8,
                   ATTRIBUTE9,
                   ATTRIBUTE10,
                   ATTRIBUTE11,
                   ATTRIBUTE12,
                   ATTRIBUTE13,
                   ATTRIBUTE14,
                   ATTRIBUTE15,
                   OBJECT_VERSION_NUMBER,
                   ESTIMATE_REASON_CODE,
                   NOT_TO_EXCEED -- swai: bug 9462789 allow update of NTE value
              FROM CSD_REPAIR_ESTIMATE
             WHERE REPAIR_ESTIMATE_ID = p_estimate_header_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT UPDATE_ESTIMATE_HEADER_PVT;

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

        debug('Start of update estimate header for estimate id[=' ||
              p_estimate_hdr_rec.repair_estimate_id || ']');

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           'csd.plsql.csd_repair_estimate_pvt.update_estimate_header.begin',
                           'Entering update_estimate_header');
        END IF;


        l_estimate_hdr_rec := p_estimate_hdr_rec;

        OPEN CUR_EST_HDR(p_estimate_hdr_rec.repair_estimate_id);
        FETCH CUR_EST_HDR
            INTO l_est_pvt_hdr_Rec.repair_estimate_id,
		  l_est_pvt_hdr_Rec.repair_line_id,
		  l_est_pvt_hdr_Rec.estimate_status,
		  l_est_pvt_hdr_Rec.estimate_date,
		  l_est_pvt_hdr_Rec.work_summary,
		  l_est_pvt_hdr_Rec.po_number,
		  l_est_pvt_hdr_Rec.lead_time,
		  l_est_pvt_hdr_Rec.lead_time_uom,
		  l_est_pvt_hdr_Rec.creation_date,
		  l_est_pvt_hdr_Rec.created_by,
		  l_est_pvt_hdr_Rec.last_updated_by,
		  l_est_pvt_hdr_Rec.last_update_date,
		  l_est_pvt_hdr_Rec.last_update_login,
		  l_est_pvt_hdr_Rec.context,
		  l_est_pvt_hdr_Rec.attribute1,
		  l_est_pvt_hdr_Rec.attribute2,
		  l_est_pvt_hdr_Rec.attribute3,
		  l_est_pvt_hdr_Rec.attribute4,
		  l_est_pvt_hdr_Rec.attribute5,
		  l_est_pvt_hdr_Rec.attribute6,
		  l_est_pvt_hdr_Rec.attribute7,
		  l_est_pvt_hdr_Rec.attribute8,
		  l_est_pvt_hdr_Rec.attribute9,
		  l_est_pvt_hdr_Rec.attribute10,
		  l_est_pvt_hdr_Rec.attribute11,
		  l_est_pvt_hdr_Rec.attribute12,
		  l_est_pvt_hdr_Rec.attribute13,
		  l_est_pvt_hdr_Rec.attribute14,
		  l_est_pvt_hdr_Rec.attribute15,
		  l_est_pvt_hdr_Rec.object_version_number,
		  l_est_pvt_hdr_Rec.estimate_reason_code,
          l_est_pvt_hdr_Rec.not_to_exceed;  -- swai: bug 9462789

        IF (CUR_EST_HDR%NOTFOUND)
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_INV_ESTIMATE_HEADER');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (l_est_pvt_hdr_Rec.repair_line_id <>
           p_Estimate_hdr_Rec.repair_line_id)
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_INV_ESTIMATE_INPUT');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
    CLOSE CUR_EST_HDR;

        l_est_status_changed := FALSE;
        IF (p_Estimate_hdr_Rec.estimate_status IS NOT NULL AND
           p_Estimate_hdr_Rec.estimate_status <>
           l_est_pvt_hdr_Rec.estimate_status)
        THEN
            l_est_status_changed := TRUE;
        END IF;

        IF (l_est_status_changed AND
           p_estimate_hdr_rec.estimate_status = C_EST_STATUS_ACCEPTED OR
           p_estimate_hdr_rec.estimate_status = C_EST_STATUS_REJECTED)
        THEN

            debug('status is accepted or rejected');

            IF (l_est_pvt_hdr_rec.estimate_reason_code IS NOT NULL AND NOT
                csd_estimate_utils_pvt.VALIDATE_REASON(l_estimate_hdr_rec.estimate_reason_code,
                                                                                                                l_estimate_hdr_rec.estimate_status))
            THEN
                debug('Invalid estimate_reason_code[' ||
                      l_estimate_hdr_rec.estimate_reason_code || ']');
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            Csd_Repairs_Grp.UPDATE_APPROVAL_STATUS(p_repair_line_id        => l_estimate_hdr_rec.repair_line_id,
                                                   p_new_approval_status   => l_approval_Status,
                                                   p_old_approval_status   => NULL,
                                                   p_quantity              => l_estimate_hdr_rec.repair_line_quantity,
                                                   p_org_contact_id        => NULL,
                                                   p_reason                => '',
                                                   p_object_version_number => l_estimate_hdr_rec.ro_object_version_number,
                                                   x_return_status         => l_return_status,
                                                   x_msg_count             => l_msg_count,
                                                   x_msg_data              => l_msg_data);
            debug('Updated ro status');
            IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                debug('Updated ro status failed, x_msg_data[' ||
                      l_msg_data || ']');
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSE
            l_estimate_hdr_rec.estimate_reason_code := NULL;
        END IF;

        csd_estimate_utils_pvt.COPY_TO_EST_HDR_REC_UPD(l_estimate_hdr_rec,
                                                   l_est_pvt_hdr_rec);

        Csd_Repair_Estimate_Pvt.update_repair_estimate(p_api_version      => 1.0,
                                                       p_commit           => Fnd_Api.G_FALSE,
                                                       p_init_msg_list    => Fnd_Api.G_FALSE,
                                                       p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                                                       x_estimate_rec     => l_est_pvt_hdr_rec,
                                                       x_return_status    => l_return_status,
                                                       x_msg_count        => l_msg_count,
                                                       x_msg_data         => l_msg_data);

        debug('after creating the estimate header');
        x_object_version_number := l_estimate_hdr_rec.object_version_number;

        IF (l_return_status <> Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            debug('update estiamte header failed, x_msg_data[' ||
                  l_msg_data || ']');
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
        THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           'csd.plsql.csd_repair_estimate_pvt.update_estimate_header.end',
                           'leaving update_estimate_header');
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_error,
                               'csd.plsql.csd_repair_estimate_pvt.update_estimate_header',
                               'EXC_ERROR[' || x_msg_data || ']');
            END IF;

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_ESTIMATE_HEADER_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.update_estimate_header',
                               'EXC_UNEXP_ERROR[' || x_msg_data || ']');
            END IF;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            Rollback TO UPDATE_ESTIMATE_HEADER_PVT;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
            IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
            THEN
                Fnd_Log.STRING(Fnd_Log.level_exception,
                               'csd.plsql.csd_repair_estimate_pvt.update_estimate_header',
                               'SQL MEssage[' || SQLERRM || ']');
            END IF;

    END UPDATE_ESTIMATE_HEADER;

    /*----------------------------------------------------------------------------*/
    /* procedure name: UPDATE_ESTIMATE_LINE                                       */
    /* description   :  procedure used to update  estimate line                  */
    /*   Updates Depot estimate line record and submits                           */
    /*   based on some validations.                                               */
    /*  Change History  : Created 24-June-2005 by Vijay                           */
    /*----------------------------------------------------------------------------*/

    PROCEDURE UPDATE_ESTIMATE_LINE(p_api_version           IN NUMBER,
                                   p_init_msg_list         IN VARCHAR2,
                                   p_commit                IN VARCHAR2,
                                   p_validation_level      IN NUMBER,
                                   x_return_status         OUT NOCOPY VARCHAR2,
                                   x_msg_count             OUT NOCOPY NUMBER,
                                   x_msg_data              OUT NOCOPY VARCHAR2,
                                   p_estimate_line_rec     IN Csd_Repair_Estimate_Pub.ESTIMATE_LINE_REC,
                                   x_object_version_number OUT NOCOPY NUMBER) IS
    BEGIN
        NULL;
    END UPDATE_ESTIMATE_LINE;

END Csd_Repair_Estimate_Pvt;

/
