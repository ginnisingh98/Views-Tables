--------------------------------------------------------
--  DDL for Package Body ASO_TASK_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_TASK_INT" AS
/* $Header: asoitskb.pls 120.4 2006/10/25 20:55:31 pkoka ship $ */

-- Start of Comments
-- Package name     : ASO_TASK_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_TASK_INT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'asoitskb.pls';

/*
 * A quote can have multiple JTF tasks attached to it.  When a
 * new version of quote is created from an existing quote, all the JTF
 * tasks attached to the existing quote should be attached to the new
 * version of quote, too.
 *
 * This procedure is called when a new version of quote is created from an
 * existing quote.
 *
 * param p_old_quote_header_id: quote header ID of the existing quote.
 * param p_new_quote_header_id: quote header ID of the new version.
 * param p_new_quote_name     : quote name of the new version.
 */
PROCEDURE Copy_Tasks
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER,
    p_new_object_id        IN  NUMBER,
    p_old_object_type_code IN  VARCHAR2,
    p_new_object_type_code IN  VARCHAR2,
    p_new_object_name      IN  VARCHAR2,
    p_quote_version_flag   IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)
IS

    L_API_NAME    CONSTANT VARCHAR2(30) := 'Copy_Tasks';
    L_API_VERSION CONSTANT NUMBER       := 1.0;

    l_task_id              NUMBER;
    l_task_reference_id    NUMBER;

    /*
     * This cursor gets information about all the JTF tasks attached
     * to the existing p_object_id for a specific object_type_code.
     */
    CURSOR l_task_csr(p_task_id NUMBER) IS
    SELECT task_id                ,
           task_name              ,
           task_type_id           ,
           description            ,
           task_status_id         ,
           task_priority_id       ,
           owner_type_code        ,
           owner_id               ,
           owner_territory_id     ,
           assigned_by_id         ,
           customer_id            ,
           cust_account_id        ,
           address_id             ,
           planned_start_date     ,
           planned_end_date       ,
           scheduled_start_date   ,
           scheduled_end_date     ,
           actual_start_date      ,
           actual_end_date        ,
           timezone_id            ,
           source_object_type_code,
           source_object_id       ,
           source_object_name     ,
           duration               ,
           duration_uom           ,
           planned_effort         ,
           planned_effort_uom     ,
           actual_effort          ,
           actual_effort_uom      ,
           percentage_complete    ,
           reason_code            ,
           private_flag           ,
           publish_flag           ,
           restrict_closure_flag  ,
           multi_booked_flag      ,
           milestone_flag         ,
           holiday_flag           ,
           billable_flag          ,
           bound_mode_code        ,
           soft_bound_flag        ,
           workflow_process_id    ,
           notification_flag      ,
           notification_period    ,
           notification_period_uom,
           parent_task_id         ,
           alarm_start            ,
           alarm_start_uom        ,
           alarm_on               ,
           alarm_count            ,
           alarm_interval         ,
           alarm_interval_uom     ,
           palm_flag              ,
           wince_flag             ,
           laptop_flag            ,
           device1_flag           ,
           device2_flag           ,
           device3_flag           ,
           costs                  ,
           currency_code          ,
           escalation_level       ,
           attribute1             ,
           attribute2             ,
           attribute3             ,
           attribute4             ,
           attribute5             ,
           attribute6             ,
           attribute7             ,
           attribute8             ,
           attribute9             ,
           attribute10            ,
           attribute11            ,
           attribute12            ,
           attribute13            ,
           attribute14            ,
           attribute15            ,
           attribute_category
      FROM jtf_tasks_vl
     WHERE task_id = p_task_id
       AND deleted_flag ='N';

    /*
     * This cursor gets information about all referenced JTF tasks attached
     * to the existing p_object_id for a specific object_type_code.
     * This cursor is being introduced for bug 5572819 (Made changes such that
     * new reference cursor is the driving cursor in the logic for creation of
     * new version or copy quote).--PKOKA
     */
    CURSOR l_reftask_csr(p_object_id NUMBER, p_object_type_code VARCHAR2) IS
    SELECT task_id
    FROM jtf_task_references_b
     WHERE object_id        = p_object_id
       AND object_type_code = p_object_type_code;

    l_task_rec  l_task_csr%rowtype;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Tasks_int;
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION,
        p_api_version,
        L_API_NAME   ,
        G_PKG_NAME
    )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: Begin Copy_Tasks()', 1, 'Y');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: old_object_id:          ' || p_old_object_id, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: old_object_type_code:   ' || p_old_object_type_code, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: new_object_id:          ' || p_new_object_id, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: new_object_type_code:   ' || p_new_object_type_code, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: new_object_name:        ' || p_new_object_name, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: quote_version_flag:     ' || p_quote_version_flag, 1, 'N');
    END IF;

    -- API body

      FOR l_reftask_rec IN l_reftask_csr(p_old_object_id, p_old_object_type_code) LOOP

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: l_reftask_rec.task_id:     ' || l_reftask_rec.task_id, 1, 'N');
	   END IF;
  /*Changes for Copy Quote Version We shouldn't create new task for a new version of quote */
       IF p_quote_version_flag   = FND_API.G_TRUE THEN
                jtf_task_references_pub.create_references (
                p_api_version         =>        1.0,
                p_init_msg_list       =>       fnd_api.g_false,
                p_commit              =>       fnd_api.g_false,
                p_task_id             =>       l_reftask_rec.task_id,
                p_object_type_code    =>       p_new_object_type_code,
                p_object_name         =>       p_new_object_name,
                p_object_id           =>       p_new_object_id,
                x_return_status       =>       x_return_status,
                x_msg_data            =>       x_msg_data,
                x_msg_count           =>       x_msg_count,
                x_task_reference_id   =>       l_task_reference_id

             );
                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('ASO_TASK_INT: After Copy_Tasks: create_references ref_id' || l_task_reference_id, 1, 'N');
                    END IF;

                   IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;

                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_ERROR;
                     RAISE FND_API.G_EXC_ERROR;
                   END IF;


           ELSE

            open l_task_csr(l_reftask_rec.task_id);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO_TASK_INT: Copy Task for new quote:', 1, 'N');
              END IF;

              fetch l_task_csr into l_task_rec;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('ASO_TASK_INT: Copy Task for new quote: l_task_rec.task_id' || l_task_rec.task_id, 1, 'N');
              END IF;

            close l_task_csr;


        JTF_Tasks_Pub.Create_Task(
            p_api_version             => 1.0                               ,
            p_init_msg_list           => FND_API.G_FALSE                   ,
            p_commit                  => FND_API.G_FALSE                   ,
            x_return_status           => x_return_status                   ,
            x_msg_count               => x_msg_count                       ,
            x_msg_data                => x_msg_data                        ,
            p_task_name               => l_task_rec.task_name              ,
            p_task_type_id            => l_task_rec.task_type_id           ,
            p_description             => l_task_rec.description            ,
            p_task_status_id          => l_task_rec.task_status_id         ,
            p_task_priority_id        => l_task_rec.task_priority_id       ,
            p_owner_type_code         => l_task_rec.owner_type_code        ,
            p_owner_id                => l_task_rec.owner_id               ,
            p_owner_territory_id      => l_task_rec.owner_territory_id     ,
            p_assigned_by_id          => l_task_rec.assigned_by_id         ,
            p_customer_id             => l_task_rec.customer_id            ,
            p_cust_account_id         => l_task_rec.cust_account_id        ,
            p_address_id              => l_task_rec.address_id             ,
            p_planned_start_date      => l_task_rec.planned_start_date     ,
            p_planned_end_date        => l_task_rec.planned_end_date       ,
            p_scheduled_start_date    => l_task_rec.scheduled_start_date   ,
            p_scheduled_end_date      => l_task_rec.scheduled_end_date     ,
            p_actual_start_date       => l_task_rec.actual_start_date      ,
            p_actual_end_date         => l_task_rec.actual_end_date        ,
            p_timezone_id             => l_task_rec.timezone_id            ,
            p_source_object_type_code => p_new_object_type_code            ,
            p_source_object_id        => p_new_object_id                   ,
            p_source_object_name      => p_new_object_name                 ,
            p_duration                => l_task_rec.duration               ,
            p_duration_uom            => l_task_rec.duration_uom           ,
            p_planned_effort          => l_task_rec.planned_effort         ,
            p_planned_effort_uom      => l_task_rec.planned_effort_uom     ,
            p_actual_effort           => l_task_rec.actual_effort          ,
            p_actual_effort_uom       => l_task_rec.actual_effort_uom      ,
            p_percentage_complete     => l_task_rec.percentage_complete    ,
            p_reason_code             => l_task_rec.reason_code            ,
            p_private_flag            => l_task_rec.private_flag           ,
            p_publish_flag            => l_task_rec.publish_flag           ,
            p_restrict_closure_flag   => l_task_rec.restrict_closure_flag  ,
            p_multi_booked_flag       => l_task_rec.multi_booked_flag      ,
            p_milestone_flag          => l_task_rec.milestone_flag         ,
            p_holiday_flag            => l_task_rec.holiday_flag           ,
            p_billable_flag           => l_task_rec.billable_flag          ,
            p_bound_mode_code         => l_task_rec.bound_mode_code        ,
            p_soft_bound_flag         => l_task_rec.soft_bound_flag        ,
            p_workflow_process_id     => l_task_rec.workflow_process_id    ,
            p_notification_flag       => l_task_rec.notification_flag      ,
            p_notification_period     => l_task_rec.notification_period    ,
            p_notification_period_uom => l_task_rec.notification_period_uom,
            p_parent_task_id          => l_task_rec.parent_task_id         ,
            p_alarm_start             => l_task_rec.alarm_start            ,
            p_alarm_start_uom         => l_task_rec.alarm_start_uom        ,
            p_alarm_on                => l_task_rec.alarm_on               ,
            p_alarm_count             => l_task_rec.alarm_count            ,
            p_alarm_interval          => l_task_rec.alarm_interval         ,
            p_alarm_interval_uom      => l_task_rec.alarm_interval_uom     ,
            p_palm_flag               => l_task_rec.palm_flag              ,
            p_wince_flag              => l_task_rec.wince_flag             ,
            p_laptop_flag             => l_task_rec.laptop_flag            ,
            p_device1_flag            => l_task_rec.device1_flag           ,
            p_device2_flag            => l_task_rec.device2_flag           ,
            p_device3_flag            => l_task_rec.device3_flag           ,
            p_costs                   => l_task_rec.costs                  ,
            p_currency_code           => l_task_rec.currency_code          ,
            p_escalation_level        => l_task_rec.escalation_level       ,
            p_attribute1              => l_task_rec.attribute1             ,
            p_attribute2              => l_task_rec.attribute2             ,
            p_attribute3              => l_task_rec.attribute3             ,
            p_attribute4              => l_task_rec.attribute4             ,
            p_attribute5              => l_task_rec.attribute5             ,
            p_attribute6              => l_task_rec.attribute6             ,
            p_attribute7              => l_task_rec.attribute7             ,
            p_attribute8              => l_task_rec.attribute8             ,
            p_attribute9              => l_task_rec.attribute9             ,
            p_attribute10             => l_task_rec.attribute10            ,
            p_attribute11             => l_task_rec.attribute11            ,
            p_attribute12             => l_task_rec.attribute12            ,
            p_attribute13             => l_task_rec.attribute13            ,
            p_attribute14             => l_task_rec.attribute14            ,
            p_attribute15             => l_task_rec.attribute15            ,
            p_attribute_category      => l_task_rec.attribute_category     ,
            x_task_id                 => l_task_id
        );

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: l_task_id:              ' || l_task_id, 1, 'N');
         END IF;
      END IF;
    END LOOP;

    -- End of API body.
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_TASK_INT: Copy_Tasks: End Copy_Tasks()', 1, 'Y');
	END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

END Copy_Tasks;


-- As per the ER 2732010. While creating opportunity to quote in Telesales
-- certain types of tasks should NOT be copied over to the quote.
-- Those task types are to be visible only in telesales.
-- Hence the new Api is needed to accomplish this requirement.
-- The types of task that are copied over to quote from an Opportunity are :
-- 1. Task types that are not linked to any source objects.
-- 2. Task types that are Specifically linked to Quoting.

-- This procedure is called only when creating a quote from an opportunity.

PROCEDURE Copy_Opp_Tasks_To_Qte
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER,
    p_new_object_id        IN  NUMBER,
    p_old_object_type_code IN  VARCHAR2,
    p_new_object_type_code IN  VARCHAR2,
    p_new_object_name      IN  VARCHAR2,
    x_return_status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
)
IS

    L_API_NAME    CONSTANT VARCHAR2(30) := 'Copy_Opp_Tasks_To_Qte';
    L_API_VERSION CONSTANT NUMBER       := 1.0;

    l_task_id              NUMBER;

    /*
     * This cursor gets information about all the JTF tasks attached
     * to the existing p_object_id for a specific object_type_code.
     */
    CURSOR l_task_csr(p_object_id NUMBER, p_object_type_code VARCHAR2) IS
    SELECT task_id                ,
           task_name              ,
           task_type_id           ,
           description            ,
           task_status_id         ,
           task_priority_id       ,
           owner_type_code        ,
           owner_id               ,
           owner_territory_id     ,
           assigned_by_id         ,
           customer_id            ,
           cust_account_id        ,
           address_id             ,
           planned_start_date     ,
           planned_end_date       ,
           scheduled_start_date   ,
           scheduled_end_date     ,
           actual_start_date      ,
           actual_end_date        ,
           timezone_id            ,
           source_object_type_code,
           source_object_id       ,
           source_object_name     ,
           duration               ,
           duration_uom           ,
           planned_effort         ,
           planned_effort_uom     ,
           actual_effort          ,
           actual_effort_uom      ,
           percentage_complete    ,
           reason_code            ,
           private_flag           ,
           publish_flag           ,
           restrict_closure_flag  ,
           multi_booked_flag      ,
           milestone_flag         ,
           holiday_flag           ,
           billable_flag          ,
           bound_mode_code        ,
           soft_bound_flag        ,
           workflow_process_id    ,
           notification_flag      ,
           notification_period    ,
           notification_period_uom,
           parent_task_id         ,
           alarm_start            ,
           alarm_start_uom        ,
           alarm_on               ,
           alarm_count            ,
           alarm_interval         ,
           alarm_interval_uom     ,
           palm_flag              ,
           wince_flag             ,
           laptop_flag            ,
           device1_flag           ,
           device2_flag           ,
           device3_flag           ,
           costs                  ,
           currency_code          ,
           escalation_level       ,
           attribute1             ,
           attribute2             ,
           attribute3             ,
           attribute4             ,
           attribute5             ,
           attribute6             ,
           attribute7             ,
           attribute8             ,
           attribute9             ,
           attribute10            ,
           attribute11            ,
           attribute12            ,
           attribute13            ,
           attribute14            ,
           attribute15            ,
           attribute_category
      FROM jtf_tasks_vl tk
     WHERE tk.source_object_id        = p_object_id
       AND tk.source_object_type_code = p_object_type_code
	  AND tk.deleted_flag ='N'
       AND (EXISTS (SELECT o.object_id
	       	    FROM jtf_object_mappings o
	       	    WHERE  o.object_id = TO_CHAR(tk.task_type_id)
		    AND   o.source_object_code = 'ASO_QUOTE')
            OR    NOT EXISTS ( SELECT om.object_id
		  	       FROM JTF_OBJECT_MAPPINGS om
        		       WHERE om.object_id = TO_CHAR(tk.task_type_id)));

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Copy_Opp_Tasks_To_Qte_int;
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION,
        p_api_version,
        L_API_NAME   ,
        G_PKG_NAME
    )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: Begin Copy_Opp_Tasks_To_Qte()', 1, 'Y');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: old_object_id:          ' || p_old_object_id, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: old_object_type_code:   ' || p_old_object_type_code, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: new_object_id:          ' || p_new_object_id, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: new_object_type_code:   ' || p_new_object_type_code, 1, 'N');
    aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: new_object_name:        ' || p_new_object_name, 1, 'N');
    END IF;

    -- API body

    FOR l_task_rec IN l_task_csr(p_old_object_id, p_old_object_type_code) LOOP

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: l_task_rec.task_id:     ' || l_task_rec.task_id, 1, 'N');
	   END IF;

        JTF_Tasks_Pub.Create_Task(
            p_api_version             => 1.0                               ,
            p_init_msg_list           => FND_API.G_FALSE                   ,
            p_commit                  => FND_API.G_FALSE                   ,
            x_return_status           => x_return_status                   ,
            x_msg_count               => x_msg_count                       ,
            x_msg_data                => x_msg_data                        ,
            p_task_name               => l_task_rec.task_name              ,
            p_task_type_id            => l_task_rec.task_type_id           ,
            p_description             => l_task_rec.description            ,
            p_task_status_id          => l_task_rec.task_status_id         ,
            p_task_priority_id        => l_task_rec.task_priority_id       ,
            p_owner_type_code         => l_task_rec.owner_type_code        ,
            p_owner_id                => l_task_rec.owner_id               ,
            p_owner_territory_id      => l_task_rec.owner_territory_id     ,
            p_assigned_by_id          => l_task_rec.assigned_by_id         ,
            p_customer_id             => l_task_rec.customer_id            ,
            p_cust_account_id         => l_task_rec.cust_account_id        ,
            p_address_id              => l_task_rec.address_id             ,
            p_planned_start_date      => l_task_rec.planned_start_date     ,
            p_planned_end_date        => l_task_rec.planned_end_date       ,
            p_scheduled_start_date    => l_task_rec.scheduled_start_date   ,
            p_scheduled_end_date      => l_task_rec.scheduled_end_date     ,
            p_actual_start_date       => l_task_rec.actual_start_date      ,
            p_actual_end_date         => l_task_rec.actual_end_date        ,
            p_timezone_id             => l_task_rec.timezone_id            ,
            p_source_object_type_code => p_new_object_type_code            ,
            p_source_object_id        => p_new_object_id                   ,
            p_source_object_name      => p_new_object_name                 ,
            p_duration                => l_task_rec.duration               ,
            p_duration_uom            => l_task_rec.duration_uom           ,
            p_planned_effort          => l_task_rec.planned_effort         ,
            p_planned_effort_uom      => l_task_rec.planned_effort_uom     ,
            p_actual_effort           => l_task_rec.actual_effort          ,
            p_actual_effort_uom       => l_task_rec.actual_effort_uom      ,
            p_percentage_complete     => l_task_rec.percentage_complete    ,
            p_reason_code             => l_task_rec.reason_code            ,
            p_private_flag            => l_task_rec.private_flag           ,
            p_publish_flag            => l_task_rec.publish_flag           ,
            p_restrict_closure_flag   => l_task_rec.restrict_closure_flag  ,
            p_multi_booked_flag       => l_task_rec.multi_booked_flag      ,
            p_milestone_flag          => l_task_rec.milestone_flag         ,
            p_holiday_flag            => l_task_rec.holiday_flag           ,
            p_billable_flag           => l_task_rec.billable_flag          ,
            p_bound_mode_code         => l_task_rec.bound_mode_code        ,
            p_soft_bound_flag         => l_task_rec.soft_bound_flag        ,
            p_workflow_process_id     => l_task_rec.workflow_process_id    ,
            p_notification_flag       => l_task_rec.notification_flag      ,
            p_notification_period     => l_task_rec.notification_period    ,
            p_notification_period_uom => l_task_rec.notification_period_uom,
            p_parent_task_id          => l_task_rec.parent_task_id         ,
            p_alarm_start             => l_task_rec.alarm_start            ,
            p_alarm_start_uom         => l_task_rec.alarm_start_uom        ,
            p_alarm_on                => l_task_rec.alarm_on               ,
            p_alarm_count             => l_task_rec.alarm_count            ,
            p_alarm_interval          => l_task_rec.alarm_interval         ,
            p_alarm_interval_uom      => l_task_rec.alarm_interval_uom     ,
            p_palm_flag               => l_task_rec.palm_flag              ,
            p_wince_flag              => l_task_rec.wince_flag             ,
            p_laptop_flag             => l_task_rec.laptop_flag            ,
            p_device1_flag            => l_task_rec.device1_flag           ,
            p_device2_flag            => l_task_rec.device2_flag           ,
            p_device3_flag            => l_task_rec.device3_flag           ,
            p_costs                   => l_task_rec.costs                  ,
            p_currency_code           => l_task_rec.currency_code          ,
            p_escalation_level        => l_task_rec.escalation_level       ,
            p_attribute1              => l_task_rec.attribute1             ,
            p_attribute2              => l_task_rec.attribute2             ,
            p_attribute3              => l_task_rec.attribute3             ,
            p_attribute4              => l_task_rec.attribute4             ,
            p_attribute5              => l_task_rec.attribute5             ,
            p_attribute6              => l_task_rec.attribute6             ,
            p_attribute7              => l_task_rec.attribute7             ,
            p_attribute8              => l_task_rec.attribute8             ,
            p_attribute9              => l_task_rec.attribute9             ,
            p_attribute10             => l_task_rec.attribute10            ,
            p_attribute11             => l_task_rec.attribute11            ,
            p_attribute12             => l_task_rec.attribute12            ,
            p_attribute13             => l_task_rec.attribute13            ,
            p_attribute14             => l_task_rec.attribute14            ,
            p_attribute15             => l_task_rec.attribute15            ,
            p_attribute_category      => l_task_rec.attribute_category     ,
            x_task_id                 => l_task_id
        );

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: l_task_id:              ' || l_task_id, 1, 'N');
         END IF;

    END LOOP;

    -- End of API body.
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('ASO_TASK_INT: Copy_Opp_Tasks_To_Qte: End Copy_Opp_Tasks_To_Qte()', 1, 'Y');
	END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME         => L_API_NAME,
                P_PKG_NAME         => G_PKG_NAME,
                P_EXCEPTION_LEVEL  => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE     => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE          => SQLCODE,
                P_SQLERRM          => SQLERRM,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA         => X_MSG_DATA,
                X_RETURN_STATUS    => X_RETURN_STATUS
            );

END Copy_Opp_Tasks_To_Qte;

END ASO_TASK_INT;

/
