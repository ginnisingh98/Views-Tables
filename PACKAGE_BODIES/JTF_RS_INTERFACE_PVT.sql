--------------------------------------------------------
--  DDL for Package Body JTF_RS_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_INTERFACE_PVT" AS
/* $Header: jtfrsvxb.pls 120.0.12010000.11 2009/09/29 09:38:51 rgokavar noship $ */
  /*****************************************************************************************
   This package body defines the procedures for importing Resources and Sales Rep.
   Its main procedures are as following:
   Import Resource
   Import Salesreps
   This package validates the input parameters to these procedures and then
   Calls corresponding  private procedures from jtf_rs_resource_pub to do business
   validations and to do actual create and update into tables.
   ******************************************************************************************/



  /* Package variables. */

    G_PKG_NAME         CONSTANT VARCHAR2(30) := 'JTF_RS_INTERFACE_PVT';


    l_miss_char            VARCHAR2(1) := FND_API.G_MISS_CHAR;
    l_miss_num             NUMBER      := FND_API.G_MISS_NUM;
    l_miss_date            DATE        := FND_API.G_MISS_DATE;

    l_null_char            VARCHAR2(1) := FND_API.G_NULL_CHAR;
    l_null_num             NUMBER      := FND_API.G_NULL_NUM;
    l_null_date            DATE        := FND_API.G_NULL_DATE;
    l_trans_message              VARCHAR2(250);
 /**
 * PROCEDURE debug
 *
 * DESCRIPTION
 *     Put debug message.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_message                      Message you want to put in log.
 *     p_prefix                       Prefix of the message. Default value is
 *                                    DEBUG.
 *     p_msg_level                    Message Level.Default value is 1 and the value should be between
 *                                    1 and 6 corresponding to FND_LOG's
 *                                    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
 *                                    LEVEL_ERROR      CONSTANT NUMBER  := 5;
 *                                    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
 *                                    LEVEL_EVENT      CONSTANT NUMBER  := 3;
 *                                    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
 *                                    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
 *     p_module_prefix                Module prefix to store package name,form name.Default value is
 *                                    HZ_Package.
 *     p_module                       Module to store Procedure Name. Default value is HZ_Module.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 * 12th Aug 2009   Sudhir Gokavarapu Bug8786536-During Build compilation error
 *                                   Commented CONTINUE statement, which is new feature in 11g
 *                                   and build was in 10g. IF loop added accordingly.
 * 25th Sep 2009   Sudhir Gokavarapu Bug8945146 Before calling Public APIs to update resource
 *                                   verification of Input dates are done by calling
 *                                   JTF_RESOURCE_UTL.validate_input_dates API.
 *
 */

  PROCEDURE debug (
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module_prefix                         IN     VARCHAR2 DEFAULT 'JTF_RS_Package',
    p_module                                IN     VARCHAR2 DEFAULT 'JTF_RS_Module'
) IS

    l_message                               VARCHAR2(4000);
    l_module                                VARCHAR2(255);

BEGIN

    l_module  :=SUBSTRB('jtf.rs.plsql.'||p_module_prefix||'.'||p_module,1,255);

    IF p_prefix IS NOT NULL THEN
      l_message :=SUBSTRB(p_prefix||'-'||p_message,1,4000);
    ELSE
      l_message :=SUBSTRB(p_message,1,4000);
    END IF;

  if( p_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(p_msg_level,l_module,l_message);
  end if;

END debug;

/**
 * PROCEDURE do_create_resource
 *
 * DESCRIPTION
 *     Create Resource.
 *
 * Private PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */


  PROCEDURE do_create_resource
  (p_batch_id                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS


    --Cursor to get Resource records for Create operation.
    CURSOR c_resource_int (p_batch_id  IN  NUMBER)
    IS
    SELECT
    interface_id,          start_date_active,   end_date_active,        compensation_currency_code,
    commissionable_flag,   hold_reason_code,    hold_payment,           resource_name,
    source_id,             address_id,          contact_id,             managing_employee_id,
    time_zone,             cost_per_hr,         primary_language,       secondary_language,
    support_site_id,       ies_agent_login,     server_group_id,        interaction_center_name,
    assigned_to_group_id,  cost_center,         charge_to_cost_center,  comp_service_team_id,
    user_id,               transaction_number,  user_name,              attribute_category,
    attribute1,            attribute2,          attribute3,             attribute4,
    attribute5,            attribute6,          attribute7,             attribute8,
    attribute9,            attribute10,         attribute11,            attribute12,
    attribute13,           attribute14,         attribute15,            category
    FROM
    jtf_rs_resource_extns_int
    WHERE
    batch_id  = p_batch_id AND
    category  = 'OTHER'    AND
    operation = 'CREATE'   AND
    operation_status IS    NULL
    ORDER BY interface_id;

    l_commit_count        NUMBER ;

    /*=================Variables for Resource Import========================*/
   l_api_name                  VARCHAR2(30);
   l_init_msg_list             VARCHAR2(1);
   l_commit                    VARCHAR2(1);
   l_interface_id              JTF_RS_RESOURCE_EXTNS_INT.INTERFACE_ID%TYPE;
   l_source_id                 JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE;
   l_address_id                JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE;
   l_contact_id                JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE;
   l_managing_emp_id           JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE;
   l_start_date_active         JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE;
   l_end_date_active           JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE;
   l_time_zone                 JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE;
   l_cost_per_hr               JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE;
   l_primary_language          JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE;
   l_secondary_language        JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE;
   l_support_site_id           JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE;
   l_ies_agent_login           JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE;
   l_server_group_id           JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE;
   l_interaction_center_name   VARCHAR2(256);
   l_assigned_to_group_id      JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE;
   l_cost_center               JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE;
   l_charge_to_cost_center     JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE;
   l_comp_currency_code        JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE;
   l_commissionable_flag       JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE;
   l_hold_reason_code          JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE;
   l_hold_payment              JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE;
   l_comp_service_team_id      JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE;
   l_user_id                   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
   l_transaction_number        JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE;
   x_resource_id               JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   x_resource_number           JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;
   l_resource_name             JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE;
   l_user_name                 JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
   l_attribute1                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE;
   l_attribute2                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE;
   l_attribute3                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE;
   l_attribute4                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE;
   l_attribute5                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE;
   l_attribute6                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE;
   l_attribute7                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE;
   l_attribute8                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE;
   l_attribute9                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE;
   l_attribute10               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE;
   l_attribute11               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE;
   l_attribute12               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE;
   l_attribute13               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE;
   l_attribute14               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE;
   l_attribute15               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE;
   l_attribute_category        JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE;
   l_resource_id               JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   l_resource_number           JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;
   l_source_name               JTF_RS_RESOURCE_EXTNS.source_name%TYPE;
   l_category                  JTF_RS_RESOURCE_EXTNS.category%TYPE;
   l_debug_prefix              VARCHAR2(30) := '';
   l_batch_id                  NUMBER;

   l_return_status             VARCHAR2(1);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(4000);
   l_msg_data1                 VARCHAR2(4000);
   l_api_version               CONSTANT NUMBER := 1.0;
   l_status_error              CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_error;
   l_status_success            CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_success;
  BEGIN

    SAVEPOINT do_create_resource;

    l_api_name            := 'DO_CREATE_RESOURCE';

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
               debug(p_message=>'do_create_resource (+)',
                     p_prefix =>l_debug_prefix,
                     p_msg_level=>fnd_log.level_statement);
    END IF;

    -- initialize variables
    x_return_status := fnd_api.g_ret_sts_success;
    l_init_msg_list := fnd_api.g_true;
    l_commit        := fnd_api.g_false;
    l_commit_count  := 0;
    l_batch_id      := p_batch_id;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Batch Id : '||l_batch_id,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Validating Start date active ',
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    --validate Start Date Active value.
    -- Get translated value for 'Start Date Active cannot be null'
    l_trans_message := fnd_message.get_string('JTF','JTF_RS_START_DATE_NULL');

    UPDATE jtf_rs_resource_extns_int
    SET    OPERATION_STATUS  = l_status_error,
           OPERATION_MESSAGE = l_trans_message,
           OPERATION_PROCESS_DATE = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              category  = 'OTHER'       AND
              operation = 'CREATE'      AND
              operation_status  IS NULL AND
              start_date_active IS NULL    ;

    -- Get the number of rows updated
    l_commit_count := SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Records having Start date null in CREATE mode:'||
        to_char(l_commit_count),
        p_prefix =>l_debug_prefix,
        p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Validating Resource Name ',
          p_prefix =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
    END IF;

    --validate Resource Name value.
    --Get traslated Resource Name to set prompts.
        l_trans_message := fnd_message.get_string('JTF','JTF_RS_ISET_RESOURCE_NAME');

    -- Get translated value for 'Resource Name cannot be null'
        fnd_message.set_name('JTF', 'JTF_RS_NOT_NULL');
        fnd_message.set_token('PROMPTS', l_trans_message);
        fnd_msg_pub.add;

    l_trans_message := FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE);

    UPDATE jtf_rs_resource_extns_int
    SET  OPERATION_STATUS  = l_status_error,
         OPERATION_MESSAGE = l_trans_message,
         OPERATION_PROCESS_DATE = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              CATEGORY  = 'OTHER'       AND
              operation = 'CREATE'      AND
              operation_status  IS NULL AND
              resource_name     IS NULL    ;

    -- Get the number of rows updated
    l_commit_count := l_commit_count + SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Records having Resource Name NULL in CREATE mode:'||
            to_char(SQL%ROWCOUNT),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
     END IF;

    -- Open cursor for remaining records after Not Null value validation.
    OPEN c_resource_int(p_batch_id);
    LOOP
       FETCH c_resource_int INTO
         l_interface_id,          l_start_date_active,    l_end_date_active,        l_comp_currency_code,
         l_commissionable_flag,   l_hold_reason_code,     l_hold_payment,           l_resource_name,
         l_source_id,             l_address_id,           l_contact_id,             l_managing_emp_id,
         l_time_zone,             l_cost_per_hr,          l_primary_language,       l_secondary_language,
         l_support_site_id,       l_ies_agent_login,      l_server_group_id,        l_interaction_center_name,
         l_assigned_to_group_id,  l_cost_center,          l_charge_to_cost_center,  l_comp_service_team_id,
         l_user_id,               l_transaction_number,   l_user_name,              l_attribute_category,
         l_attribute1,            l_attribute2,           l_attribute3,             l_attribute4,
         l_attribute5,            l_attribute6,           l_attribute7,             l_attribute8,
         l_attribute9,            l_attribute10,          l_attribute11,            l_attribute12,
         l_attribute13,           l_attribute14,          l_attribute15,            l_category;

       EXIT WHEN c_resource_int%NOTFOUND ;

       BEGIN
         SAVEPOINT do_create_resource_loop;
           -- Debug info.
         IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
             debug(p_message=>'Before Create Resource call for Interface ID :'
                               ||l_interface_id,
                   p_prefix =>l_debug_prefix,
                   p_msg_level=>fnd_log.level_statement);
         END IF;

         --Call the Public procedure to Create Resource.
         JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
                    p_api_version              =>   l_api_version,
                    p_init_msg_list            =>   l_init_msg_list,
                    p_commit                   =>   l_commit,
                    p_category                 =>   l_category,
                    p_source_id                =>   l_source_id,
                    p_address_id               =>   l_address_id,
                    p_contact_id               =>   l_contact_id,
                    p_managing_emp_id          =>   l_managing_emp_id,
                    p_start_date_active        =>   l_start_date_active,
                    p_end_date_active          =>   l_end_date_active,
                    p_transaction_number       =>   l_transaction_number,
                    p_user_id                  =>   l_user_id,
                    p_time_zone                =>   l_time_zone,
                    p_primary_language         =>   l_primary_language,
                    p_secondary_language       =>   l_secondary_language,
                    p_source_name              =>   l_source_name,
                    p_resource_name            =>   l_resource_name,
                    p_user_name                =>   l_user_name,
                    p_attribute_category       =>   l_attribute_category,
                    p_attribute1               =>   l_attribute1,
                    p_attribute2               =>   l_attribute2,
                    p_attribute3               =>   l_attribute3,
                    p_attribute4               =>   l_attribute4,
                    p_attribute5               =>   l_attribute5,
                    p_attribute6               =>   l_attribute6,
                    p_attribute7               =>   l_attribute7,
                    p_attribute8               =>   l_attribute8,
                    p_attribute9               =>   l_attribute9,
                    p_attribute10              =>   l_attribute10,
                    p_attribute11              =>   l_attribute11,
                    p_attribute12              =>   l_attribute12,
                    p_attribute13              =>   l_attribute13,
                    p_attribute14              =>   l_attribute14,
                    p_attribute15              =>   l_attribute15,
                    p_cost_center              =>   l_cost_center,
                    p_charge_to_cost_center    =>   l_charge_to_cost_center,
                    p_comp_service_team_id     =>   l_comp_service_team_id,
                    p_server_group_id          =>   l_server_group_id,
                    p_interaction_center_name  =>   l_interaction_center_name,
                    p_assigned_to_group_id     =>   l_assigned_to_group_id,
                    p_support_site_id          =>   l_support_site_id,
                    p_ies_agent_login          =>   l_ies_agent_login,
                    p_cost_per_hr              =>   l_cost_per_hr,
                    p_comp_currency_code       =>   l_comp_currency_code,
                    p_commissionable_flag      =>   l_commissionable_flag,
                    p_hold_reason_code         =>   l_hold_reason_code,
                    p_hold_payment             =>   l_hold_payment,
                    x_return_status            =>   l_return_status,
                    x_msg_count                =>   l_msg_count,
                    x_msg_data                 =>   l_msg_data,
                    x_resource_id              =>   x_resource_id,
                    x_resource_number          =>   x_resource_number
                  );

        -- Debug info.
                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                    debug(p_message=>'After Create Reource call Return Status : '
                                     ||l_return_status,
                          p_prefix =>l_debug_prefix,
                          p_msg_level=>fnd_log.level_statement);
                END IF;

                    -- Message data reading logic
                    IF (l_return_status <> l_status_success
                        AND l_msg_count > 0)
                    THEN
                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                               l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded    => 'F')||', ';
                          END LOOP;


                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                           -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                      END IF;
        ---- End of Message data reading logic

        --When return status is success then update Resource Id to Intf Table.
        IF l_return_status = l_status_success THEN
            UPDATE jtf_rs_resource_extns_int
            SET  operation_status       = l_status_success,
                 operation_process_date = SYSDATE,
                 resource_id            = x_resource_id
            WHERE interface_id = l_interface_id;
        ELSE
        -- When return status is NOT success,update Error details to Intf Table.
            UPDATE jtf_rs_resource_extns_int
            SET  operation_status  = l_return_status,
                 operation_message = l_msg_data1,
                 operation_process_date = SYSDATE
            WHERE interface_id = l_interface_id;
        END IF;

       l_commit_count := l_commit_count + 1;

       EXCEPTION
       WHEN OTHERS THEN

         -- When any other unexpected error then try to capture it
         l_msg_data1 := SQLERRM;
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Unexpected Error in Create Resource loop at'
                             ||' Batch Id :'||l_batch_id
                             ||' Interface Id :'||l_interface_id,
                  p_prefix =>l_debug_prefix,
                  p_msg_level=>fnd_log.level_statement);
          END IF;

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Error is : '||l_msg_data1,
                              p_prefix =>l_debug_prefix,
                              p_msg_level=>fnd_log.level_statement);
          END IF;

          ROLLBACK TO do_create_resource_loop;

          UPDATE jtf_rs_resource_extns_int
          SET  operation_status  = l_return_status,
               operation_message = l_msg_data1,
               operation_process_date = SYSDATE
          WHERE interface_id = l_interface_id;

          l_commit_count := l_commit_count + 1;

       END;   -- End of BEGIN BLOCK for EACH record in LOOP

       -- commit should be outside individual record processing block
        IF MOD(l_commit_count,1000) = 0 THEN -- Commit after every 1000 records.
           COMMIT;
         l_commit_count := 0 ; -- reset the counter
        END IF;

    END LOOP;  --End of Cursor loop.
    CLOSE c_resource_int;

    COMMIT;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message  =>' do_create_resource (-)',
              p_prefix   =>l_debug_prefix,
              p_msg_level=>fnd_log.level_statement);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
       debug(p_message=>'Unexpected Error at do_create_resource procedure:'
                         ||SQLERRM,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;

    -- if commit is there after 1000 recs and in update stmt, savepoint will
    -- not be established.
    -- ROLLBACK TO do_create_resource;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
  END do_create_resource;

  /**
 * PROCEDURE do_update_resource
 *
 * DESCRIPTION
 *     Create Resource.
 *
 * Private PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */

  PROCEDURE do_update_resource
  (P_BATCH_ID                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS

    l_api_version               CONSTANT NUMBER := 1.0;
    l_status_error              CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_error;
    l_status_success            CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_success;
--    l_miss_char            VARCHAR2(1) := FND_API.G_MISS_CHAR;
--    l_miss_num             NUMBER      := FND_API.G_MISS_NUM;
--    l_miss_date            DATE     ;--   := FND_API.G_MISS_DATE;

--    l_null_char            VARCHAR2(1) := FND_API.G_NULL_CHAR;
--    l_null_num             NUMBER      := FND_API.G_NULL_NUM;
--    l_null_date            DATE        := FND_API.G_NULL_DATE;
     l_other_value          BOOLEAN;
     l_start_date_active_char   VARCHAR2(20);

    --Cursor to get Resource records for Create mode.
    --If User wants to set to NULL from Not Null then provide FND_API.G_NULL_xxx
    --When it match with FND_API.G_NULL_xxx then will provide NULL to public API.
    --When it is NULL then will provide FND_API.G_MISS_xxx to public API to retain existing value.
    CURSOR c_resource_int (p_batch_id  IN  NUMBER)
    IS
    SELECT
    interface_id,
    DECODE(start_date_active,NULL,l_miss_date,l_null_date,NULL,start_date_active) start_date_active,
    DECODE(end_date_active  ,NULL,l_miss_date,l_null_date,NULL,end_date_active) end_date_active,
    DECODE(compensation_currency_code,l_null_char,NULL,NULL,l_miss_char,compensation_currency_code) compensation_currency_code,
    DECODE(commissionable_flag,l_null_char,NULL,NULL,l_miss_char,commissionable_flag) commissionable_flag,
    DECODE(hold_reason_code,l_null_char,NULL,NULL,l_miss_char,hold_reason_code) hold_reason_code,
    DECODE(hold_payment,l_null_char,NULL,NULL,l_miss_char,hold_payment) hold_payment,
    DECODE(resource_name,l_null_char,NULL,NULL,l_miss_char,resource_name) resource_name,
    DECODE(address_id,L_NULL_NUM,NULL,NULL,l_miss_num,address_id) address_id,
    DECODE(contact_id,L_NULL_NUM,NULL,NULL,l_miss_num,contact_id) contact_id,
    DECODE(managing_employee_id,L_NULL_NUM,NULL,NULL,l_miss_num,managing_employee_id) managing_employee_id,
    DECODE(time_zone,L_NULL_NUM,NULL,NULL,l_miss_num,time_zone) time_zone,
    DECODE(cost_per_hr,L_NULL_NUM,NULL,NULL,l_miss_num,cost_per_hr) cost_per_hr,
    DECODE(primary_language,l_null_char,NULL,NULL,l_miss_char,primary_language) primary_language,
    DECODE(secondary_language,l_null_char,NULL,NULL,l_miss_char,secondary_language) secondary_language,
    DECODE(support_site_id,L_NULL_NUM,NULL,NULL,l_miss_num,support_site_id) support_site_id,
    DECODE(ies_agent_login,l_null_char,NULL,NULL,l_miss_char,ies_agent_login) ies_agent_login,
    DECODE(server_group_id,L_NULL_NUM,NULL,NULL,l_miss_num,server_group_id) server_group_id,
    DECODE(assigned_to_group_id,L_NULL_NUM,NULL,NULL,l_miss_num,assigned_to_group_id) assigned_to_group_id,
    DECODE(cost_center,l_null_char,NULL,NULL,l_miss_char,cost_center) cost_center,
    DECODE(charge_to_cost_center,l_null_char,NULL,NULL,l_miss_char,charge_to_cost_center) charge_to_cost_center,
    DECODE(comp_service_team_id,L_NULL_NUM,NULL,NULL,l_miss_num,comp_service_team_id) comp_service_team_id,
    DECODE(user_id,L_NULL_NUM,NULL,NULL,l_miss_num,user_id) user_id,
    DECODE(user_name,l_null_char,NULL,NULL,l_miss_char,user_name) user_name,
    DECODE(attribute_category,l_null_char,NULL,NULL,l_miss_char,attribute_category) attribute_category,
    DECODE(attribute1,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute1,
    DECODE(attribute2,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute2,
    DECODE(attribute3,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute3,
    DECODE(attribute4,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute4,
    DECODE(attribute5,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute5,
    DECODE(attribute6,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute6,
    DECODE(attribute7,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute7,
    DECODE(attribute8,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute8,
    DECODE(attribute9,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute9,
    DECODE(attribute10,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute10,
    DECODE(attribute11,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute11,
    DECODE(attribute12,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute12,
    DECODE(attribute13,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute13,
    DECODE(attribute14,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute14,
    DECODE(attribute15,l_null_char,NULL,NULL,l_miss_char,attribute1) attribute15,
    resource_id,
    DECODE(start_date_active,to_char(l_null_date,'dd/mm/yyyy hh24:mi:ss'),NULL,NULL,to_char(l_miss_date,'dd/mm/yyyy hh24:mi:ss'),to_char(start_date_active,'dd/mm/yyyy hh24:mi:ss')) start_date_active_char
    --Character converted date To compare with l_miss_date.
    FROM
    jtf_rs_resource_extns_int
    WHERE
    batch_id  = p_batch_id AND
    category  = 'OTHER'    AND
    operation = 'UPDATE'   AND
    operation_status IS    NULL
    ORDER BY interface_id;


   l_category                  JTF_RS_RESOURCE_EXTNS.CATEGORY%TYPE;
   l_object_version_number     JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE;
   l_end_date_active_db        JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE;
   l_start_date_active_db      JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE;

   x_object_version_num_res    NUMBER;
   l_commit_count              NUMBER;

    /*=================Variables for Resource Import========================*/
   l_api_name                  VARCHAR2(30);
   l_init_msg_list             VARCHAR2(1);
   l_commit                    VARCHAR2(1);
   l_interface_id              JTF_RS_RESOURCE_EXTNS_INT.INTERFACE_ID%TYPE;
   l_source_id                 JTF_RS_RESOURCE_EXTNS.SOURCE_ID%TYPE;
   l_address_id                JTF_RS_RESOURCE_EXTNS.ADDRESS_ID%TYPE;
   l_contact_id                JTF_RS_RESOURCE_EXTNS.CONTACT_ID%TYPE;
   l_managing_emp_id           JTF_RS_RESOURCE_EXTNS.MANAGING_EMPLOYEE_ID%TYPE;
   l_start_date_active         JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE;
   l_end_date_active           JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE;
   l_time_zone                 JTF_RS_RESOURCE_EXTNS.TIME_ZONE%TYPE;
   l_cost_per_hr               JTF_RS_RESOURCE_EXTNS.COST_PER_HR%TYPE;
   l_primary_language          JTF_RS_RESOURCE_EXTNS.PRIMARY_LANGUAGE%TYPE;
   l_secondary_language        JTF_RS_RESOURCE_EXTNS.SECONDARY_LANGUAGE%TYPE;
   l_support_site_id           JTF_RS_RESOURCE_EXTNS.SUPPORT_SITE_ID%TYPE;
   l_ies_agent_login           JTF_RS_RESOURCE_EXTNS.IES_AGENT_LOGIN%TYPE;
   l_server_group_id           JTF_RS_RESOURCE_EXTNS.SERVER_GROUP_ID%TYPE;
   l_interaction_center_name   VARCHAR2(256);
   l_assigned_to_group_id      JTF_RS_RESOURCE_EXTNS.ASSIGNED_TO_GROUP_ID%TYPE;
   l_cost_center               JTF_RS_RESOURCE_EXTNS.COST_CENTER%TYPE;
   l_charge_to_cost_center     JTF_RS_RESOURCE_EXTNS.CHARGE_TO_COST_CENTER%TYPE;
   l_comp_currency_code        JTF_RS_RESOURCE_EXTNS.COMPENSATION_CURRENCY_CODE%TYPE;
   l_commissionable_flag       JTF_RS_RESOURCE_EXTNS.COMMISSIONABLE_FLAG%TYPE;
   l_hold_reason_code          JTF_RS_RESOURCE_EXTNS.HOLD_REASON_CODE%TYPE;
   l_hold_payment              JTF_RS_RESOURCE_EXTNS.HOLD_PAYMENT%TYPE;
   l_comp_service_team_id      JTF_RS_RESOURCE_EXTNS.COMP_SERVICE_TEAM_ID%TYPE;
   l_user_id                   JTF_RS_RESOURCE_EXTNS.USER_ID%TYPE;
   l_transaction_number        JTF_RS_RESOURCE_EXTNS.TRANSACTION_NUMBER%TYPE;
   x_resource_id               JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   x_resource_number           JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;
   l_resource_name             JTF_RS_RESOURCE_EXTNS_TL.RESOURCE_NAME%TYPE;
   l_user_name                 JTF_RS_RESOURCE_EXTNS.USER_NAME%TYPE;
   l_attribute1                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE1%TYPE;
   l_attribute2                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE2%TYPE;
   l_attribute3                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE3%TYPE;
   l_attribute4                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE4%TYPE;
   l_attribute5                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE5%TYPE;
   l_attribute6                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE6%TYPE;
   l_attribute7                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE7%TYPE;
   l_attribute8                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE8%TYPE;
   l_attribute9                JTF_RS_RESOURCE_EXTNS.ATTRIBUTE9%TYPE;
   l_attribute10               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE10%TYPE;
   l_attribute11               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE11%TYPE;
   l_attribute12               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE12%TYPE;
   l_attribute13               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE13%TYPE;
   l_attribute14               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE14%TYPE;
   l_attribute15               JTF_RS_RESOURCE_EXTNS.ATTRIBUTE15%TYPE;
   l_attribute_category        JTF_RS_RESOURCE_EXTNS.ATTRIBUTE_CATEGORY%TYPE;
   l_resource_id               JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
   l_resource_number           JTF_RS_RESOURCE_EXTNS.RESOURCE_NUMBER%TYPE;
   l_source_name               JTF_RS_RESOURCE_EXTNS.source_name%TYPE;
   l_category                  JTF_RS_RESOURCE_EXTNS.category%TYPE;
   l_debug_prefix              VARCHAR2(30) := 'RS_UPD:';
   l_batch_id                  NUMBER;

   l_return_status             VARCHAR2(1);
   l_msg_count                 NUMBER;
   l_msg_data                  VARCHAR2(4000);
   l_msg_data1                 VARCHAR2(4000);

  BEGIN

   SAVEPOINT do_update_resource;
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>' do_update_resource (+)',
              p_prefix =>l_debug_prefix,
              p_msg_level=>fnd_log.level_statement);
    END IF;

    -- initialize variables
    l_api_name      := 'DO_UPDATE_RESOURCE';
    l_miss_date     := FND_API.G_MISS_DATE;
    x_return_status := fnd_api.g_ret_sts_success;
    l_init_msg_list := fnd_api.g_true;
    l_commit        := fnd_api.g_false;
    l_commit_count  := 0;
    l_batch_id      := p_batch_id;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Batch Id : '||l_batch_id,
                                      p_prefix =>l_debug_prefix,
                                      p_msg_level=>fnd_log.level_statement);
    END IF;


    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Validating Resource Id ',
              p_prefix =>l_debug_prefix,
              p_msg_level=>fnd_log.level_statement);
    END IF;

   --Validate if Resource Id value is NULL.
    -- Get translated value for 'Resource Id cannot be null in Update mode.'

    l_trans_message := fnd_message.get_string('JTF','JTF_RS_RESOURCE_ID_NULL');

    UPDATE jtf_rs_resource_extns_int
    SET  operation_status  = l_status_error,
         operation_message = l_trans_message,
         operation_process_date = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              operation = 'UPDATE'      AND
              operation_status  IS NULL AND
              resource_id       IS NULL    ;

    -- Get the number of rows updated
    l_commit_count := SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Resource Id cannot be null in UPDATE mode:'||
            to_char(l_commit_count),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
     END IF;

    --If Resource Id value is there then Validate is it valid or not.
    -- Get translated value for 'Resource Id is not valid'

    l_trans_message := fnd_message.get_string('JTF','JTF_RS_RES_ID_INVALID');

    UPDATE jtf_rs_resource_extns_int rs_int
    SET  operation_status  = l_status_error,
         operation_message = l_trans_message,
         operation_process_date = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              operation = 'UPDATE'      AND
              operation_status  IS NULL AND
              resource_id       IS NOT NULL
    AND NOT EXISTS
           (SELECT 1 FROM jtf_rs_resource_extns rs
            WHERE  rs.resource_id = rs_int.resource_id);

    -- Get the number of rows updated
    l_commit_count := l_commit_count + SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Resource Id is not valid:'||
            to_char(SQL%ROWCOUNT),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
     END IF;

    -- As per ciurrent scope only resource of CATEGORY OTHER is supported
    -- by Resource manager interface
    --If Resource Id is valid then check if it is belong to OTHER category.

    -- Get translated value for 'Resource Id is not of OTHER category.'
        fnd_message.set_name('JTF', 'JTF_RS_INVALID_RES_ID_CAT');
        fnd_message.set_token('P_CATEGORY','OTHER');
        fnd_msg_pub.add;

    l_trans_message := FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE);

    UPDATE jtf_rs_resource_extns_int rs_int
    SET  operation_status  = l_status_error,
         operation_message = l_trans_message,
         operation_process_date = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              operation = 'UPDATE'      AND
              operation_status  IS NULL AND
              resource_id       IS NOT NULL
    AND NOT EXISTS
           (SELECT 1 FROM jtf_rs_resource_extns rs
            WHERE  rs.resource_id = rs_int.resource_id
            AND    rs.category    = 'OTHER' );

    -- Get the number of rows updated
    l_commit_count := l_commit_count + SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Resource Id is not of OTHER category.'||
            to_char(SQL%ROWCOUNT),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
     END IF;


    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Validating - Resource Name cannot be updated to null ',
              p_prefix =>l_debug_prefix,
              p_msg_level=>fnd_log.level_statement);
    END IF;

   --Validate if Resource Id value is NULL.
    --'Resource Name should not be updated to NULL.'
    --Get traslated Resource Name to set prompts.

        l_trans_message := fnd_message.get_string('JTF','JTF_RS_ISET_RESOURCE_NAME');

    -- Get translated value for 'Resource Name cannot be null'
        fnd_message.set_name('JTF', 'JTF_RS_NOT_NULL');
        fnd_message.set_token('PROMPTS', l_trans_message);
        fnd_msg_pub.add;

    l_trans_message := FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE);

    UPDATE jtf_rs_resource_extns_int
    SET  operation_status  = l_status_error,
         operation_message = l_trans_message,
         operation_process_date = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              operation = 'UPDATE'      AND
              operation_status  IS NULL AND
              resource_name   = l_null_char;

    -- Get the number of rows updated
    l_commit_count := SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Resource Name should not be updated to NULL:'||
            to_char(l_commit_count),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
    END IF;

 -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Validating - Active Start Date cannot be updated to null ',
              p_prefix =>l_debug_prefix,
              p_msg_level=>fnd_log.level_statement);
    END IF;

   --Validate if Resource Id value is NULL.
    -- Get translated value for 'Start Date Active cannot be null'
    l_trans_message := fnd_message.get_string('JTF','JTF_RS_START_DATE_NULL');

   --'Active Start Date should not be updated to NULL.'
    UPDATE jtf_rs_resource_extns_int
    SET  operation_status  = l_status_error,
         operation_message = l_trans_message,
         operation_process_date = SYSDATE
    WHERE     batch_id  = p_batch_id    AND
              operation = 'UPDATE'      AND
              operation_status  IS NULL AND
              start_date_active   = l_null_date;

    -- Get the number of rows updated
    l_commit_count := SQL%ROWCOUNT ;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
      DEBUG(p_message=>'Active Start Date should not be updated to NULL:'||
            to_char(l_commit_count),
            p_prefix =>l_debug_prefix,
            p_msg_level=>fnd_log.level_statement);
    END IF;

    IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
      COMMIT;
      l_commit_count := 0 ; -- reset the counter
    END IF;

   OPEN c_resource_int(p_batch_id);
   LOOP
     FETCH c_resource_int
     INTO
     l_interface_id,          l_start_date_active,    l_end_date_active,        l_comp_currency_code,
     l_commissionable_flag,   l_hold_reason_code,     l_hold_payment,           l_resource_name,
                              l_address_id,           l_contact_id,             l_managing_emp_id,
     l_time_zone,             l_cost_per_hr,          l_primary_language,       l_secondary_language,
     l_support_site_id,       l_ies_agent_login,      l_server_group_id,
     l_assigned_to_group_id,  l_cost_center,          l_charge_to_cost_center,  l_comp_service_team_id,
     l_user_id,                                       l_user_name,              l_attribute_category,
     l_attribute1,            l_attribute2,           l_attribute3,             l_attribute4,
     l_attribute5,            l_attribute6,           l_attribute7,             l_attribute8,
     l_attribute9,            l_attribute10,          l_attribute11,            l_attribute12,
     l_attribute13,           l_attribute14,          l_attribute15,
     l_resource_id,           l_start_date_active_char;
     EXIT WHEN c_resource_int%NOTFOUND ;

     BEGIN
       SAVEPOINT do_update_resource_loop;

       -- Debug info.
       IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          debug(p_message=>'Update Resource mode Interface Id :'||
                              l_interface_id ||' Resource Id :'||l_resource_id ,
                p_prefix =>l_debug_prefix,
                p_msg_level=>fnd_log.level_statement);
        END IF;

        --Get Object Version Number and End Date Active.
        SELECT object_version_number,end_date_active,start_date_active
        INTO   l_object_version_number,l_end_date_active_db,l_start_date_active_db
        FROM   jtf_rs_resource_extns
        WHERE  resource_id = l_resource_id;

        -- If Start Date Active is NULL then we are getting l_miss_date into l_start_date.
        -- While validating Input dates l_miss_date is always greater than equal to
        -- any value in l_end_date_active and system will throw error.
        -- To validate actual values we are assigning Actual value of START_DATE_ACTIVE in
        -- JTF_RS_RESOURCE_EXTN table to l_start_date_active.
        IF l_start_date_active_char = to_char(l_miss_date,'dd/mm/yyyy hh24:mi:ss') THEN
             l_start_date_active := l_start_date_active_db;
        END IF;

        -- If end_date_active contains value then
        -- if resource was active or had end date greater than end date passed in the interface table,
        -- we have to end date resource and related child entities
        -- like resource role, group member role, salesrep etc.
        -- To accomplish this
        -- If there is any additional attribute other than end date to be updated,
        -- first call JTF_RS_RESOURCE_PUB.update_resource procedure without end date,
        -- then call jtf_rs_resource_utl_pub.end_date_employee procedure for end dating.


        IF (
           ((l_end_date_active IS NOT NULL AND l_end_date_active <> l_miss_date)
           OR ( to_date(to_char(l_end_date_active,'DD-MM-RRRR hh24:mi:ss'),'DD-MM-RRRR hh24:mi:ss')
                 < l_end_date_active_db ))
           AND
           fnd_profile.value('JTF_RS_INTF_END_DATE_CHILD') <> 'N'
           )
        THEN
           -- Debug info.
           IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              debug(p_message=>'End date active is having value. '||
                               'l_end_date_active:'||TO_CHAR(l_end_date_active,'dd-MM-RRRR hh24:mi:ss')||
                               'l_end_date_active_db:'||TO_CHAR(l_end_date_active_db,'dd-MM-RRRR hh24:mi:ss'),
                    p_prefix =>l_debug_prefix,
                    p_msg_level=>fnd_log.level_statement);
           END IF;
                   JTF_RESOURCE_UTL.validate_input_dates
                    (p_start_date_active    => l_start_date_active,
                     p_end_date_active      => l_end_date_active,
                     x_return_status        => l_return_status
                    );
                       -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'After Validating Date values Return Status : '||l_return_status,
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                  IF l_return_status <> l_status_success THEN
                  -- l_start_date_active cannot be null so if this API returns error status means
                  -- only chance of JTF_RS_ERR_STDT_GREATER_EDDT

                       l_trans_message := fnd_message.get_string('JTF','JTF_RS_ERR_STDT_GREATER_EDDT');

                       --'Date values should be valid'
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status  = l_return_status,
                                 operation_message = l_trans_message,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;

                            -- When return status is NOT success then update Error details to Interface Table.
                                -- Debug info.
                                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                                    debug(p_message=>'Error in Update Resource loop at Resource Id,Batch Id, Interface Id : '||l_resource_id||'   '||l_batch_id||'  '||l_interface_id,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                                END IF;
                                -- Debug info.
                                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                                    debug(p_message=>'Message:'||l_trans_message,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                                END IF;
                  END IF;

         IF  l_return_status = l_status_success THEN



          -- Check if there is any additional attribute other than end date to be updated.
          -- As we already converted Null to MISS_xxx, here we are comparing with MISS_xxx.
          -- Start date is converted to character and verifying with l_miss_date.
          -- If it is not converted then it is taking default date format (Ex : Year YY format).
          IF l_start_date_active_char <> to_char(l_miss_date,'dd/mm/yyyy hh24:mi:ss') OR
             l_comp_currency_code <> l_miss_char OR
             l_commissionable_flag <> l_miss_char OR       l_hold_reason_code <> l_miss_char OR
             l_hold_payment <> l_miss_char OR              l_resource_name <> l_miss_char OR
             l_address_id <> l_miss_num OR                 l_contact_id <> l_miss_num OR
             l_managing_emp_id <> l_miss_num OR            l_time_zone <> l_miss_num OR
             l_cost_per_hr <> l_miss_num OR                l_primary_language <> l_miss_char OR
             l_secondary_language <> l_miss_char OR        l_support_site_id <> l_miss_num OR
             l_ies_agent_login <> l_miss_char OR           l_server_group_id <> l_miss_num OR
             l_assigned_to_group_id <> l_miss_num OR       l_cost_center <> l_miss_char OR
             l_charge_to_cost_center <> l_miss_char OR     l_comp_service_team_id <> l_miss_num OR
             l_user_id <> l_miss_num OR                    l_user_name <> l_miss_char OR
             l_attribute_category <> l_miss_char OR        l_attribute1 <> l_miss_char OR
             l_attribute2 <> l_miss_char OR                l_attribute3 <> l_miss_char OR
             l_attribute4 <> l_miss_char OR                l_attribute5 <> l_miss_char OR
             l_attribute6 <> l_miss_char OR                l_attribute7 <> l_miss_char OR
             l_attribute8 <> l_miss_char OR                l_attribute9 <> l_miss_char OR
             l_attribute10 <> l_miss_char OR               l_attribute11 <> l_miss_char OR
             l_attribute12 <> l_miss_char OR               l_attribute13 <> l_miss_char OR
             l_attribute14 <> l_miss_char OR               l_attribute15 <> l_miss_char
          THEN
               l_other_value := TRUE; -- Other_value flag set to True.
                   -- Debug info.
                   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      debug(p_message=>'l_other_value set to TRUE',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                   END IF;

          ELSE
          -- Other_value flag set to False. No value other than end date to be updated.
               l_other_value := FALSE;
                   -- Debug info.
                   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      debug(p_message=>'l_other_value set to FALSE',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                   END IF;

          END IF;

              IF NOT l_other_value THEN

                   -- Debug info.
                   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      debug(p_message=>'No value other than end date to be updated. ',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                   END IF;

                  -- Other_value flag value is False. No value other than end date to be updated.
                  -- Call only end_date_employee and move to next record.
                  jtf_rs_resource_utl_pub.end_date_employee(
                                p_api_version              =>   l_api_version,
                                p_init_msg_list            =>   l_init_msg_list,
                                p_commit                   =>   l_commit,
                                p_resource_id              =>   l_resource_id,
                                p_end_date_active          =>   l_end_date_active,
                                X_OBJECT_VER_NUMBER        =>   x_object_version_num_res,
                                x_return_status            =>   l_return_status,
                                x_msg_count                =>   l_msg_count,
                                x_msg_data                 =>   l_msg_data  );

                        -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'After end_date_employee call Return Status : '||l_return_status,
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                        ---- Message data reading logic
                        IF (l_return_status <> l_status_success
                            AND l_msg_count > 0)
                        THEN
                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                             l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                          END LOOP;

                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                          -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                        END IF;
                        ---- End of Message data reading logic

                        --When return status is success then update Status to Interface Table.
                        IF l_return_status = l_status_success THEN
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status       = l_status_success,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        ELSE-- When return status is NOT success then update Error details to Interface Table.
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status  = l_return_status,
                                 operation_message = l_msg_data1,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        END IF;

              ELSE -- having other than end date to be updated
             -- Other_value flag value is True.
             -- Call update_resource with end_date_active value and then
             -- call end_date_employee before moving to next record.
                   -- Debug info.
                   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                      debug(p_message=>'Having other than end date to be updated. ',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                   END IF;
                  jtf_rs_resource_pub.update_resource(
                                p_api_version              =>   l_api_version,
                                p_init_msg_list            =>   l_init_msg_list,
                                p_commit                   =>   l_commit,
                                p_address_id               =>   l_address_id,
                                p_managing_emp_id          =>   l_managing_emp_id,
                                p_start_date_active        =>   l_start_date_active,
                                p_user_id                  =>   l_user_id,
                                p_time_zone                =>   l_time_zone,
                                p_primary_language         =>   l_primary_language,
                                p_secondary_language       =>   l_secondary_language,
                                x_return_status            =>   l_return_status,
                                x_msg_count                =>   l_msg_count,
                                x_msg_data                 =>   l_msg_data,
                                p_resource_id              =>   l_resource_id,
                                p_resource_number          =>   x_resource_number,
                                p_source_name              =>   l_source_name,
                                p_resource_name            =>   l_RESOURCE_NAME,
                                p_user_name                =>   l_user_name,
                                p_object_version_num       =>   l_object_version_number,
                                p_attribute_category       =>   l_attribute_category,
                                p_attribute1               =>   l_attribute1,
                                p_attribute2               =>   l_attribute2,
                                p_attribute3               =>   l_attribute3,
                                p_attribute4               =>   l_attribute4,
                                p_attribute5               =>   l_attribute5,
                                p_attribute6               =>   l_attribute6,
                                p_attribute7               =>   l_attribute7,
                                p_attribute8               =>   l_attribute8,
                                p_attribute9               =>   l_attribute9,
                                p_attribute10              =>   l_attribute10,
                                p_attribute11              =>   l_attribute11,
                                p_attribute12              =>   l_attribute12,
                                p_attribute13              =>   l_attribute13,
                                p_attribute14              =>   l_attribute14,
                                p_attribute15              =>   l_attribute15,
                                p_cost_center              =>   l_cost_center,
                                p_charge_to_cost_center    =>   l_charge_to_cost_center,
                                p_comp_service_team_id     =>   l_comp_service_team_id,
                                p_server_group_id          =>   l_server_group_id,
                                p_assigned_to_group_id     =>   l_assigned_to_group_id,
                                p_support_site_id          =>   l_support_site_id,
                                p_ies_agent_login          =>   l_ies_agent_login,
                                p_cost_per_hr              =>   l_cost_per_hr,
                                p_comp_currency_code       =>   l_comp_currency_code,
                                p_commissionable_flag      =>   l_commissionable_flag,
                                p_hold_reason_code         =>   l_hold_reason_code,
                                p_hold_payment             =>   l_hold_payment
                   );
                        -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'After Update Resource (without end date) call Return Status : '||l_return_status,
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                        ---- Message data reading logic
                        IF (l_return_status <> l_status_success
                            AND l_msg_count > 0)
                        THEN

                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                              l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                          END LOOP;

                          -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                        END IF;
                        ---- End of Message data reading logic


                        --When return status is success then update Status to Interface Table.
                        IF l_return_status = l_status_success THEN
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status       = l_status_success,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        ELSE-- When return status is NOT success then update Error details to Interface Table.
                                -- Debug info.
                                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                                    debug(p_message=>'Error in Update Resource loop at Resource Id,Batch Id, Interface Id : '||l_resource_id||'   '||l_batch_id||'  '||l_interface_id,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
                                END IF;
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status  = l_return_status,
                                 operation_message = l_msg_data1,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
--                        CONTINUE;
                        END IF;
                  --Bug#8786536
                  --Commented CONTINUE statement in above loop and added IF loop accordingly.
                  --If update_resource without end_date value returns success
                  --then only proceed further with end_date_employee call for current record.
                  IF  l_return_status = l_status_success THEN
                        -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Before calling end_date_employee and after Update Resource (without end date) call.',
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                        jtf_rs_resource_utl_pub.end_date_employee(
                                p_api_version              =>   1.0,
                                p_init_msg_list            =>   l_init_msg_list,
                                p_commit                   =>   l_commit,
                                p_resource_id              =>   l_resource_id,
                                p_end_date_active          =>   l_end_date_active,
                                X_OBJECT_VER_NUMBER        =>   x_object_version_num_res,
                                x_return_status            =>   l_return_status,
                                x_msg_count                =>   l_msg_count,
                                x_msg_data                 =>   l_msg_data  );

                        -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'After end_date_employee call Return Status : '||l_return_status,
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                        ---- Message data reading logic
                        IF (l_return_status <> l_status_success
                            AND l_msg_count > 0)
                        THEN
                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                           l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                          END LOOP;

                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                          -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                        END IF;
                        ---- End of Message data reading logic


                        --When return status is success then update Status to Interface Table.
                        IF l_return_status = l_status_success THEN
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status       = l_status_success,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        ELSE-- When return status is NOT success then update Error details to Interface Table.
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status  = l_return_status,
                                 operation_message = l_msg_data1,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        END IF;
                  END IF;
              END IF; --l_other_value
           END IF; -- Date value validation
          ELSE   --end_date_active check, Normal call

          --Call the Public procedure to Update Resource.
                   JTF_RS_RESOURCE_PUB.UPDATE_RESOURCE(
                                p_api_version              =>   1.0,
                                p_init_msg_list            =>   l_init_msg_list,
                                p_commit                   =>   l_commit,
                                p_address_id               =>   l_address_id,
                                p_managing_emp_id          =>   l_managing_emp_id,
                                p_start_date_active        =>   l_start_date_active,
                                p_end_date_active          =>   l_end_date_active,
                                p_user_id                  =>   l_user_id,
                                p_time_zone                =>   l_time_zone,
                                p_primary_language         =>   l_primary_language,
                                p_secondary_language       =>   l_secondary_language,
                                x_return_status            =>   l_return_status,
                                x_msg_count                =>   l_msg_count,
                                x_msg_data                 =>   l_msg_data,
                                p_resource_id              =>   l_resource_id,
                                p_resource_number          =>   x_resource_number,
                                p_source_name              =>   l_source_name,
                                p_resource_name            =>   l_RESOURCE_NAME,
                                p_user_name                =>   l_user_name,
                                p_object_version_num       =>   l_object_version_number,
                                p_attribute_category       =>   l_attribute_category,
                                p_attribute1               =>   l_attribute1,
                                p_attribute2               =>   l_attribute2,
                                p_attribute3               =>   l_attribute3,
                                p_attribute4               =>   l_attribute4,
                                p_attribute5               =>   l_attribute5,
                                p_attribute6               =>   l_attribute6,
                                p_attribute7               =>   l_attribute7,
                                p_attribute8               =>   l_attribute8,
                                p_attribute9               =>   l_attribute9,
                                p_attribute10              =>   l_attribute10,
                                p_attribute11              =>   l_attribute11,
                                p_attribute12              =>   l_attribute12,
                                p_attribute13              =>   l_attribute13,
                                p_attribute14              =>   l_attribute14,
                                p_attribute15              =>   l_attribute15,
                                p_cost_center              =>   l_cost_center,
                                p_charge_to_cost_center    =>   l_charge_to_cost_center,
                                p_comp_service_team_id     =>   l_comp_service_team_id,
                                p_server_group_id          =>   l_server_group_id,
                                p_assigned_to_group_id     =>   l_assigned_to_group_id,
                                p_support_site_id          =>   l_support_site_id,
                                p_ies_agent_login          =>   l_ies_agent_login,
                                p_cost_per_hr              =>   l_cost_per_hr,
                                p_comp_currency_code       =>   l_comp_currency_code,
                                p_commissionable_flag      =>   l_commissionable_flag,
                                p_hold_reason_code         =>   l_hold_reason_code,
                                p_hold_payment             =>   l_hold_payment
              );
                       -- Debug info.
                        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'After Update Resource call Return Status : '||l_return_status,
                                                          p_prefix =>l_debug_prefix,
                                                          p_msg_level=>fnd_log.level_statement);
                        END IF;

                        ---- Message data reading logic
                        IF (l_return_status <> l_status_success
                            AND l_msg_count > 0)
                        THEN
                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                           l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                          END LOOP;

                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                          -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                        END IF;
                        ---- End of Message data reading logic

                        --When return status is success then update Status to Interface Table.
                        IF l_return_status = l_status_success THEN
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status       = l_status_success,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;
                        ELSE-- When return status is NOT success then update Error details to Interface Table.
                            UPDATE jtf_rs_resource_extns_int
                            SET  operation_status  = l_return_status,
                                 operation_message = l_msg_data1,
                                 operation_process_date = SYSDATE
                            WHERE interface_id = l_interface_id;

                        END IF;
        END IF;   --end_date_active check

       l_commit_count := l_commit_count + 1;

   EXCEPTION
   WHEN OTHERS THEN

         -- When any other unexpected error then try to capture it
         l_msg_data1 := SQLERRM;
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
              debug(p_message=>'Unexpected Error in Update Resource loop at'
                             ||' Batch Id :'||l_batch_id
                             ||' Interface Id :'||l_interface_id,
                  p_prefix =>l_debug_prefix,
                  p_msg_level=>fnd_log.level_statement);
            END IF;

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Error is : '||l_msg_data1,
                              p_prefix =>l_debug_prefix,
                              p_msg_level=>fnd_log.level_statement);
          END IF;

          ROLLBACK TO do_create_resource_loop;

          UPDATE jtf_rs_resource_extns_int
          SET  operation_status  = l_return_status,
               operation_message = l_msg_data1,
               operation_process_date = SYSDATE
          WHERE interface_id = l_interface_id;

          l_commit_count := l_commit_count + 1;

       END;   -- End of BEGIN BLOCK for EACH record in LOOP

     -- commit should be outside individual record processing block
     IF MOD(l_commit_count,1000) = 0 THEN -- Commit after every 1000 records.
        COMMIT;
        l_commit_count := 0 ; -- reset the counter
      END IF;

   END LOOP;
   CLOSE c_resource_int;

     COMMIT;
    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>' do_update_resource (-)',
                                      p_prefix =>l_debug_prefix,
                                      p_msg_level=>fnd_log.level_statement);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_resource;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_resource;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
    WHEN OTHERS THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Unexpected Error at do_update_resource procedure '||SQLERRM,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;
      ROLLBACK TO do_update_resource;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);
  END;

/**
 * PROCEDURE do_create_salesrep
 *
 * DESCRIPTION
 *     Create SalesRep.
 *
 * Private PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */
   PROCEDURE do_create_salesrep
  (p_batch_id                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS


      --Cursor to get Salesrep records for Create mode.
        CURSOR c_salesrep_int (p_batch_id  IN  NUMBER)
        IS
        SELECT
        interface_id,                salesrep_id,
        resource_id,                 sales_credit_type_id,      status,
        start_date_active,           end_date_active,           salesrep_number,
        org_id,                      email_address,             gl_id_rev,
        gl_id_freight,               gl_id_rec,                 set_of_books_id,
        sales_tax_geocode,           sales_tax_inside_city_limits
        FROM
        jtf_rs_salesreps_int
        WHERE
        batch_id  = p_batch_id AND
        operation = 'CREATE'   AND
        operation_status IS    NULL
        ORDER BY interface_id;

        l_salesrep_id                       JTF_RS_SALESREPS.salesrep_id%TYPE;
        l_sales_credit_type_id              JTF_RS_SALESREPS.sales_credit_type_id%TYPE;
        l_status                            JTF_RS_SALESREPS.status%TYPE;
        l_salesrep_number                   JTF_RS_SALESREPS.salesrep_number%TYPE;
        l_org_id                            JTF_RS_SALESREPS.org_id%TYPE;
        l_email_address                     JTF_RS_SALESREPS.email_address%TYPE;
        l_gl_id_rev                         JTF_RS_SALESREPS.gl_id_rev%TYPE;
        l_gl_id_freight                     JTF_RS_SALESREPS.gl_id_freight%TYPE;
        l_gl_id_rec                         JTF_RS_SALESREPS.gl_id_rec%TYPE;
        l_set_of_books_id                   JTF_RS_SALESREPS.set_of_books_id%TYPE;
        l_sales_tax_geocode                 JTF_RS_SALESREPS.sales_tax_geocode%TYPE;
        l_sales_tax_inside_city_limits      JTF_RS_SALESREPS.sales_tax_inside_city_limits%TYPE;
        x_salesrep_id                       JTF_RS_SALESREPS.salesrep_id%TYPE;
        l_start_date_active                 DATE;--JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE;
        l_end_date_active                   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE;
        l_interface_id                      JTF_RS_RESOURCE_EXTNS_INT.INTERFACE_ID%TYPE;
        l_resource_id                       JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
        l_commit_count                      NUMBER ;
        l_api_name                          VARCHAR2(30);
        l_init_msg_list                     VARCHAR2(1);
        l_commit                            VARCHAR2(1);
        l_api_version                       CONSTANT NUMBER := 1.0;
        l_status_error                      CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_error;
        l_status_success                    CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_success;
        l_debug_prefix                      VARCHAR2(30) := 'RS_UPD:';
        l_batch_id                          NUMBER;
        l_return_status                     VARCHAR2(1);
        l_msg_count                         NUMBER;
        l_msg_data                          VARCHAR2(4000);
        l_msg_data1                         VARCHAR2(4000);
  BEGIN

        SAVEPOINT do_create_salesrep;

          l_api_name            := 'DO_CREATE_SALESREP';
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'do_create_salesrep (+)',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;

        -- initialize variables
        x_return_status := fnd_api.g_ret_sts_success;
        l_init_msg_list := fnd_api.g_true;
        l_commit        := fnd_api.g_false;
        l_commit_count  := 0;
        l_batch_id := p_batch_id;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Batch Id : '||l_batch_id,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;



        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Validating Resource Id ',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;

            --validate Resource Id value.
        --Getting Translated 'Resource Id cannot be null'.
        l_trans_message := fnd_message.get_string('JTF','JTF_RS_RESOURCE_ID_NULL');

        UPDATE jtf_rs_salesreps_int
        SET  OPERATION_STATUS  = l_status_error,
             OPERATION_MESSAGE = l_trans_message,
             OPERATION_PROCESS_DATE = SYSDATE
        WHERE     batch_id  = p_batch_id    AND
                  operation = 'CREATE'      AND
                  operation_status  IS NULL AND
                  resource_id       IS NULL    ;

       -- Get the number of rows updated
        l_commit_count := SQL%ROWCOUNT ;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          DEBUG(p_message=>'Records having Resource Id null in CREATE mode:'||
                to_char(l_commit_count),
                p_prefix =>l_debug_prefix,
                p_msg_level=>fnd_log.level_statement);
        END IF;

        IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
          COMMIT;
          l_commit_count := 0 ; -- reset the counter
         END IF;
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Validating Salesperson number  ',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;


        --validate Sales Number value.
        --Getting Translated 'Salesperson number is required to setup a salesperson.'.
        l_trans_message := fnd_message.get_string('JTF','JTF_RS_SALESREP_NUMBER_NULL');

            UPDATE jtf_rs_salesreps_int
            SET  OPERATION_STATUS  = l_status_error,
                 OPERATION_MESSAGE = l_trans_message,
                 OPERATION_PROCESS_DATE = SYSDATE
            WHERE     batch_id  = p_batch_id    AND
                      operation = 'CREATE'      AND
                      operation_status  IS NULL AND
                      salesrep_number   IS NULL    ;

       -- Get the number of rows updated
        l_commit_count := SQL%ROWCOUNT ;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
          DEBUG(p_message=>'Records having Sales Person Number null in CREATE mode:'||
                to_char(l_commit_count),
                p_prefix =>l_debug_prefix,
                p_msg_level=>fnd_log.level_statement);
        END IF;

        IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
          COMMIT;
          l_commit_count := 0 ; -- reset the counter
        END IF;

           -- Open cursor for remaining records after Not Null value validation.
           OPEN c_salesrep_int(p_batch_id);
           LOOP
             FETCH c_salesrep_int  INTO
             l_interface_id,                l_salesrep_id,
             l_resource_id,                 l_sales_credit_type_id,      l_status,
             l_start_date_active,           l_end_date_active,           l_salesrep_number,
             l_org_id,                      l_email_address,             l_gl_id_rev,
             l_gl_id_freight,               l_gl_id_rec,                 l_set_of_books_id,
             l_sales_tax_geocode,           l_sales_tax_inside_city_limits;
           EXIT WHEN c_salesrep_int%NOTFOUND ;

           BEGIN
             SAVEPOINT do_create_salesrep_loop;

                -- Debug info.
                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                    debug(p_message=>'Before Create Salesrep call for Interface ID : '||l_interface_id,
                                                  p_prefix =>l_debug_prefix,
                                                  p_msg_level=>fnd_log.level_statement);
                END IF;

                    --Call the Public procedure to Create Salesrep.
                    JTF_RS_SALESREPS_PUB.create_salesrep
                                  (p_api_version                     =>   1.0,
                                   p_init_msg_list                   =>   l_init_msg_list,
                                   p_commit                          =>   l_commit,
                                   p_resource_id                     =>   l_resource_id,
                                   p_sales_credit_type_id            =>   l_sales_credit_type_id,
                                   p_status                          =>   l_status,
                                   p_start_date_active               =>   l_start_date_active,
                                   p_end_date_active                 =>   l_end_date_active,
                                   p_salesrep_number                 =>   l_salesrep_number,
                                   p_org_id                          =>   l_org_id,
                                   p_email_address                   =>   l_email_address,
                                   p_gl_id_rev                       =>   l_gl_id_rev,
                                   p_gl_id_freight                   =>   l_gl_id_freight,
                                   p_gl_id_rec                       =>   l_gl_id_rec,
                                   p_set_of_books_id                 =>   l_set_of_books_id,
                                   p_sales_tax_geocode               =>   l_sales_tax_geocode,
                                   p_sales_tax_inside_city_limits    =>   l_sales_tax_inside_city_limits,
                                   x_return_status                   =>   l_return_status,
                                   x_msg_count                       =>   l_msg_count,
                                   x_msg_data                        =>   l_msg_data,
                                   x_salesrep_id                     =>   x_salesrep_id
                                  );

                -- Debug info.
                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                    debug(p_message=>'After Create Salesrep call Return Status : '||l_return_status,
                                                  p_prefix =>l_debug_prefix,
                                                  p_msg_level=>fnd_log.level_statement);
                END IF;

                    -- Message data reading logic
                    IF (l_return_status <> l_status_success AND l_msg_count > 0)
                    THEN
                          l_msg_data1 := '';
                          FOR i IN 1..l_msg_count LOOP
                               l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                          END LOOP;

                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                           -- Debug info.
                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                          END IF;
                      END IF;
        ---- End of Message data reading logic


                IF l_return_status = l_status_success THEN
                    UPDATE jtf_rs_salesreps_int
                    SET  operation_status       = l_status_success,
                         operation_process_date = SYSDATE,
                         salesrep_id            = x_salesrep_id
                    WHERE interface_id = l_interface_id;
                ELSE
                    UPDATE jtf_rs_salesreps_int
                    SET  operation_status  = l_return_status,
                         operation_message = l_msg_data1,
                         operation_process_date = SYSDATE
                    WHERE interface_id = l_interface_id;

                END IF;

               l_commit_count := l_commit_count + 1;
               IF MOD(l_commit_count,1000) = 0 THEN
                   COMMIT;
               END IF;

       EXCEPTION
       WHEN OTHERS THEN
         -- When any other unexpected error then try to capture it
         l_msg_data1 := SQLERRM;
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Unexpected Error in Create Salesrep loop at '||
                                  'Batch Id ' ||l_batch_id||' Interface Id : '||l_interface_id,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Error is : '||l_msg_data1,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;

          ROLLBACK TO do_create_salesrep_loop;

          UPDATE jtf_rs_salesreps_int
          SET  operation_status  = l_return_status,
               operation_message = l_msg_data1,
               operation_process_date = SYSDATE
          WHERE interface_id = l_interface_id;

          l_commit_count := l_commit_count + 1;

       END;   -- End of BEGIN BLOCK for EACH record in LOOP

       -- commit should be outside individual record processing block
        IF MOD(l_commit_count,1000) = 0 THEN -- Commit after every 1000 records.
           COMMIT;
         l_commit_count := 0 ; -- reset the counter
        END IF;

       END LOOP;
       CLOSE c_salesrep_int;

       COMMIT;

        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>' do_create_salesrep (-)',
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        -- Debug info.
        IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Unexpected Error at do_create_salesrep procedure '||SQLERRM,
                                          p_prefix =>l_debug_prefix,
                                          p_msg_level=>fnd_log.level_statement);
        END IF;
    -- if commit is there after 1000 recs and in update stmt, savepoint will
    -- not be established.
    -- ROLLBACK TO do_create_salesrep;
          fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
          fnd_message.set_token('P_SQLCODE',SQLCODE);
          fnd_message.set_token('P_SQLERRM',SQLERRM);
          fnd_message.set_token('P_API_NAME', l_api_name);
          FND_MSG_PUB.add;
          x_return_status := fnd_api.g_ret_sts_unexp_error;
          FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                     p_data => x_msg_data);

  END do_create_salesrep;

/**
 * PROCEDURE do_update_salesrep
 *
 * DESCRIPTION
 *     Create Salesrep.
 *
 * Private PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */

   PROCEDURE do_update_salesrep
  (p_batch_id                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  ) IS
       --Cursor to get Salesrep records for Update mode.
        CURSOR c_salesrep_int (p_batch_id  IN  NUMBER)
        IS
        SELECT
        interface_id,salesrep_id,resource_id,
        DECODE(sales_credit_type_id,l_null_num,NULL,NULL,l_miss_num,sales_credit_type_id) sales_credit_type_id,
        DECODE(status,l_null_char,NULL,NULL,l_miss_char,status) status,
        DECODE(start_date_active,NULL,l_miss_date,l_null_date,NULL,start_date_active) start_date_active,
        DECODE(end_date_active  ,NULL,l_miss_date,l_null_date,NULL,end_date_active) end_date_active,
        DECODE(salesrep_number,l_null_char,NULL,NULL,l_miss_char,salesrep_number) salesrep_number,
        DECODE(org_id,l_null_num,NULL,NULL,l_miss_num,org_id) org_id,
        DECODE(email_address,l_null_char,NULL,NULL,l_miss_char,email_address) email_address,
        DECODE(gl_id_rev,l_null_num,NULL,NULL,l_miss_num,gl_id_rev) gl_id_rev,
        DECODE(gl_id_freight,l_null_num,NULL,NULL,l_miss_num,gl_id_freight) gl_id_freight,
        DECODE(gl_id_rec,l_null_num,NULL,NULL,l_miss_num,gl_id_rec) gl_id_rec,
        DECODE(set_of_books_id,l_null_num,NULL,NULL,l_miss_num,set_of_books_id) set_of_books_id,
        DECODE( sales_tax_geocode,l_null_char,NULL,NULL,l_miss_char, sales_tax_geocode) sales_tax_geocode,
        DECODE(sales_tax_inside_city_limits,l_null_char,NULL,NULL,l_miss_char,sales_tax_inside_city_limits) sales_tax_inside_city_limits
        FROM
        jtf_rs_salesreps_int
        WHERE
        batch_id  = p_batch_id AND
        operation = 'UPDATE'   AND
        operation_status IS    NULL
        ORDER BY interface_id;

        l_salesrep_id                       JTF_RS_SALESREPS.salesrep_id%TYPE;
        l_sales_credit_type_id              JTF_RS_SALESREPS.sales_credit_type_id%TYPE;
        l_status                            JTF_RS_SALESREPS.status%TYPE;
        l_salesrep_number                   JTF_RS_SALESREPS.salesrep_number%TYPE;
        l_org_id                            JTF_RS_SALESREPS.org_id%TYPE;
        l_email_address                     JTF_RS_SALESREPS.email_address%TYPE;
        l_gl_id_rev                         JTF_RS_SALESREPS.gl_id_rev%TYPE;
        l_gl_id_freight                     JTF_RS_SALESREPS.gl_id_freight%TYPE;
        l_gl_id_rec                         JTF_RS_SALESREPS.gl_id_rec%TYPE;
        l_set_of_books_id                   JTF_RS_SALESREPS.set_of_books_id%TYPE;
        l_sales_tax_geocode                 JTF_RS_SALESREPS.sales_tax_geocode%TYPE;
        l_sales_tax_inside_city_limits      JTF_RS_SALESREPS.sales_tax_inside_city_limits%TYPE;
        l_object_version_number             JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE;
        l_start_date_active                 JTF_RS_RESOURCE_EXTNS.START_DATE_ACTIVE%TYPE;
        l_end_date_active                   JTF_RS_RESOURCE_EXTNS.END_DATE_ACTIVE%TYPE;
         l_interface_id                     JTF_RS_RESOURCE_EXTNS_INT.INTERFACE_ID%TYPE;
        l_resource_id                       JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE;
        l_commit_count                      NUMBER ;
        l_api_name                          VARCHAR2(30);
        l_init_msg_list                     VARCHAR2(1);
        l_commit                            VARCHAR2(1);
        l_api_version                       CONSTANT NUMBER := 1.0;
        l_status_error                      CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_error;
        l_status_success                    CONSTANT VARCHAR2(10) := fnd_api.g_ret_sts_success;
        l_debug_prefix                      VARCHAR2(30) := 'RS_UPD:';
        l_batch_id                          NUMBER;
        l_return_status                     VARCHAR2(1);
        l_msg_count                         NUMBER;
        l_msg_data                          VARCHAR2(4000);
        l_msg_data1                         VARCHAR2(4000);
   BEGIN

            SAVEPOINT do_update_salesrep;

            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                debug(p_message=>'do_update_salesrep (+)',
                                              p_prefix =>l_debug_prefix,
                                              p_msg_level=>fnd_log.level_statement);
            END IF;
    -- initialize variables
    l_miss_date     := FND_API.G_MISS_DATE;
    l_init_msg_list := fnd_api.g_true;
    l_commit        := fnd_api.g_false;
    l_commit_count  := 0;
    l_batch_id      := p_batch_id;
    l_api_name            := 'DO_UPDATE_SALESREP';
    x_return_status := fnd_api.g_ret_sts_success;
    l_batch_id := p_batch_id;

            -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                debug(p_message=>'Batch Id : '||l_batch_id,
                                              p_prefix =>l_debug_prefix,
                                              p_msg_level=>fnd_log.level_statement);
            END IF;

                -- Debug info.
            IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                debug(p_message=>'Validating SalesRep Id ',
                                              p_prefix =>l_debug_prefix,
                                              p_msg_level=>fnd_log.level_statement);
            END IF;

            --validate SalesRep Id value.
        --Getting Translated 'Salesrep Id cannot be null.'.

        l_trans_message := fnd_message.get_string('JTF','JTF_RS_SALESREP_ID_NULL');

                UPDATE jtf_rs_salesreps_int
                SET  OPERATION_STATUS  = l_status_error,
                     OPERATION_MESSAGE = l_trans_message,
                     OPERATION_PROCESS_DATE = SYSDATE
                WHERE     batch_id  = p_batch_id    AND
                          operation = 'UPDATE'      AND
                          operation_status  IS NULL AND
                          salesrep_id       IS NULL    ;

                -- Get the number of rows updated
                l_commit_count := SQL%ROWCOUNT ;

                -- Debug info.
                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  DEBUG(p_message=>'Records having Salesrep Id null in Update mode:'||
                        to_char(l_commit_count),
                        p_prefix =>l_debug_prefix,
                        p_msg_level=>fnd_log.level_statement);
                END IF;

                IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
                  COMMIT;
                  l_commit_count := 0 ; -- reset the counter
                END IF;

              --validate SalesRep Id value.
                --Getting Translated 'Salesperson Id is Invalid'.
                fnd_message.set_name('JTF', 'JTF_RS_INVALID_SALESREP_ID');
                fnd_message.set_token('P_SALESREP_ID','');
                fnd_msg_pub.add;

                l_trans_message := FND_MSG_PUB.Get( p_encoded => FND_API.G_FALSE);

                UPDATE jtf_rs_salesreps_int a
                SET  OPERATION_STATUS  = l_status_error,
                     OPERATION_MESSAGE = l_trans_message,
                     OPERATION_PROCESS_DATE = SYSDATE
                WHERE     batch_id  = p_batch_id    AND
                          operation = 'UPDATE'      AND
                          operation_status  IS NULL AND
                NOT EXISTS (SELECT 1 FROM  jtf_rs_salesreps B
                            WHERE  A.salesrep_id = B.salesrep_id);

                -- Get the number of rows updated
                l_commit_count := SQL%ROWCOUNT ;

                -- Debug info.
                IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                  DEBUG(p_message=>'Records having Invalid Salesrep Id in Update mode:'||
                        to_char(l_commit_count),
                        p_prefix =>l_debug_prefix,
                        p_msg_level=>fnd_log.level_statement);
                END IF;

                IF l_commit_count >= 1000  THEN -- Commit if more than 1000 records.
                  COMMIT;
                  l_commit_count := 0 ; -- reset the counter
                END IF;

              l_commit_count := 1;--Initial Count

               -- Open cursor for remaining records after Not Null value validation.
               OPEN c_salesrep_int(p_batch_id);
               LOOP
                 FETCH c_salesrep_int
                 INTO
                 l_interface_id,                l_salesrep_id,
                 l_resource_id,                 l_sales_credit_type_id,      l_status,
                 l_start_date_active,           l_end_date_active,           l_salesrep_number,
                 l_org_id,                      l_email_address,             l_gl_id_rev,
                 l_gl_id_freight,               l_gl_id_rec,                 l_set_of_books_id,
                 l_sales_tax_geocode,           l_sales_tax_inside_city_limits;

                   EXIT WHEN c_salesrep_int%NOTFOUND ;
                 BEGIN
                 SAVEPOINT do_update_salesrep_loop;

                   SELECT object_version_number,org_id
                   INTO l_object_version_number,l_org_id
                   FROM JTF_RS_SALESREPS
                   WHERE salesrep_id = l_salesrep_id;

                    -- Debug info.
                    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                        debug(p_message=>'Before Update Salesrep call for Interface ID : '
                                             ||l_interface_id||' SalesRep Id : '||l_salesrep_id,
                                                  p_prefix =>l_debug_prefix,
                                                  p_msg_level=>fnd_log.level_statement);
                    END IF;

                     --Call the Public procedure to Update Salesrep.
                    JTF_RS_SALESREPS_PUB.update_salesrep
                                  (p_api_version                     =>   1.0,
                                   p_init_msg_list                   =>   l_init_msg_list,
                                   p_commit                          =>   l_commit,
                                   p_sales_credit_type_id            =>   l_sales_credit_type_id,
                                   p_status                          =>   l_status,
                                   p_start_date_active               =>   l_start_date_active,
                                   p_end_date_active                 =>   l_end_date_active,
                                   p_salesrep_number                 =>   l_salesrep_number,
                                   p_org_id                          =>   l_org_id,
                                   p_email_address                   =>   l_email_address,
                                   p_gl_id_rev                       =>   l_gl_id_rev,
                                   p_gl_id_freight                   =>   l_gl_id_freight,
                                   p_gl_id_rec                       =>   l_gl_id_rec,
                                   p_set_of_books_id                 =>   l_set_of_books_id,
                                   p_sales_tax_geocode               =>   l_sales_tax_geocode,
                                   p_sales_tax_inside_city_limits    =>   l_sales_tax_inside_city_limits,
                                   x_return_status                   =>   l_return_status,
                                   x_msg_count                       =>   l_msg_count,
                                   x_msg_data                        =>   l_msg_data,
                                   p_salesrep_id                     =>   l_salesrep_id,
                                   p_object_version_number           =>   l_object_version_number
                                  );


                    -- Debug info.
                    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                        debug(p_message=>'After Update Salesrep call Return Status : '||l_return_status,
                                                  p_prefix =>l_debug_prefix,
                                                  p_msg_level=>fnd_log.level_statement);
                    END IF;

                    -- Message data reading logic
                    IF (l_return_status <> l_status_success AND l_msg_count > 0)
                    THEN
                          l_msg_data1 := '';
                      FOR i IN 1..l_msg_count LOOP
                               l_msg_data1 := l_msg_data1||fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F')||', ';
                      END LOOP;

                          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message Count:'||l_msg_count,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                      END IF;
                       -- Debug info.
                      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
                            debug(p_message=>'Message:'||l_msg_data1,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
                      END IF;
                      END IF;
                      ---- End of Message data reading logic

                   IF l_return_status = l_status_success THEN
                        UPDATE jtf_rs_salesreps_int
                        SET  operation_status       = l_status_success,
                             operation_process_date = SYSDATE
                        WHERE interface_id = l_interface_id;
                    ELSE
                        UPDATE jtf_rs_salesreps_int
                        SET  operation_status  = l_return_status,
                             operation_message = l_msg_data1,
                             operation_process_date = SYSDATE
                        WHERE interface_id = l_interface_id;

                    END IF;

           l_commit_count := l_commit_count + 1;

   EXCEPTION
   WHEN OTHERS THEN

         -- When any other unexpected error then try to capture it
         l_msg_data1 := SQLERRM;
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Debug info.
          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           debug(p_message=>'Unexpected Error in Update Salesrep loop at'
                             ||' Batch Id :'||l_batch_id
                             ||' Interface Id :'||l_interface_id,
                  p_prefix =>l_debug_prefix,
                  p_msg_level=>fnd_log.level_statement);
          END IF;

          IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
            debug(p_message=>'Error is : '||l_msg_data1,
                              p_prefix =>l_debug_prefix,
                              p_msg_level=>fnd_log.level_statement);
          END IF;

          ROLLBACK TO do_update_salesrep_loop;

      UPDATE jtf_rs_salesreps_int
        SET  operation_status  = l_return_status,
             operation_message = l_msg_data1,
             operation_process_date = SYSDATE
        WHERE interface_id = l_interface_id;

          l_commit_count := l_commit_count + 1;

       END;   -- End of BEGIN BLOCK for EACH record in LOOP

       -- commit should be outside individual record processing block
       IF MOD(l_commit_count,1000) = 0 THEN -- Commit after every 1000 records.
         COMMIT;
         l_commit_count := 0 ; -- reset the counter
       END IF;

    END LOOP;  --End of Cursor loop.
    CLOSE c_salesrep_int;

    COMMIT;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
    debug(p_message  =>' do_create_salesrep (-)',
          p_prefix   =>l_debug_prefix,
          p_msg_level=>fnd_log.level_statement);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Debug info.
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=>'Unexpected Error at do_update_salesrep procedure:'
                         ||SQLERRM,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;

    -- if commit is there after 1000 recs and in update stmt, savepoint will
    -- not be established.
    -- ROLLBACK TO do_create_resource;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

  END do_update_salesrep;

/**
 * PROCEDURE import_resource
 *
 * DESCRIPTION
 *     Create Resource.
 *
 * Public PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *   OUT:
 *     x_return_status                Get Status.
 *     x_msg_count                    Get count of loaded messages.
 *     x_msg_data                     Get info of loaded messages.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */

  PROCEDURE import_resource
  (P_BATCH_ID                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
   ) IS

   l_api_name         CONSTANT VARCHAR2(30) := 'IMPORT_RESOURCE';
   l_debug_prefix     CONSTANT VARCHAR2(30) := 'RS_IMP:';

  BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   --Call Create Resource and then Update Resource along with Batch Id
   /* Call Create Resource */
   do_create_resource(p_batch_id       => p_batch_id,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data
                     );

    -- Debug Info
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Create Resource API Return Values:'||
                        ' p_batch_id :'||p_batch_id||
                        ' x_return_status :'||x_return_status||
                        ' x_msg_count :'||x_msg_count||
                        ' x_msg_data :'||x_msg_data,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
    END IF;

    IF (X_RETURN_STATUS = fnd_api.g_ret_sts_success) THEN
      /* Call Update Resource */
      do_update_resource(p_batch_id       => p_batch_id,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data
                       );

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Update Resource API Return Values:'||
                        ' p_batch_id :'||p_batch_id||
                        ' x_return_status :'||x_return_status||
                        ' x_msg_count :'||x_msg_count||
                        ' x_msg_data :'||x_msg_data,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Create Resource API Failed. Update Resource not executed.',
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF ;

  EXCEPTION WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

    IF fnd_log.LEVEL_UNEXPECTED >=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Import Resource API raised EXCEPTION:'||
                        ' p_batch_id :'||p_batch_id||
                        ' Error :'||SQLERRM,
                         p_prefix => l_debug_prefix,
                         p_msg_level=> fnd_log.LEVEL_UNEXPECTED);
    END IF;

  END import_resource;
/**
 * PROCEDURE import_salesreps
 *
 * DESCRIPTION
 *     Create Resource.
 *
 * Public PROCEDURES/FUNCTIONS
 *
 * ARGUMENTS
 *   IN:
 *     p_batch_id                     Batch Id to process records.
 *   OUT:
 *     x_return_status                Get Status.
 *     x_msg_count                    Get count of loaded messages.
 *     x_msg_data                     Get info of loaded messages.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 * 10-June-2009     Sudhir Gokavarapu   Created.
 *
 */

  PROCEDURE import_salesreps
  (P_BATCH_ID                IN  NUMBER,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
   ) IS
   l_api_name         CONSTANT VARCHAR2(30) := 'IMPORT_SALESREP';
   l_debug_prefix     CONSTANT VARCHAR2(30) := 'SR_IMP:';

  BEGIN


   x_return_status := fnd_api.g_ret_sts_success;

   --Call Create Salesrep and then Update Salesrep along with Batch Id
   /* Call Create Salesrep */
   do_create_salesrep(p_batch_id       => p_batch_id,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data
                     );

    -- Debug Info
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Create Salesrep API Return Values:'||
                        ' p_batch_id :'||p_batch_id||
                        ' x_return_status :'||x_return_status||
                        ' x_msg_count :'||x_msg_count||
                        ' x_msg_data :'||x_msg_data,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
    END IF;

    IF (X_RETURN_STATUS = fnd_api.g_ret_sts_success) THEN
      /* Call Update Salesrep */
      do_update_salesrep(p_batch_id       => p_batch_id,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data
                       );

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Update Salesrep API Return Values:'||
                        ' p_batch_id :'||p_batch_id||
                        ' x_return_status :'||x_return_status||
                        ' x_msg_count :'||x_msg_count||
                        ' x_msg_data :'||x_msg_data,
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;
    ELSE
      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Create Salesrep API Failed. Update Salesrep not executed.',
                         p_prefix =>l_debug_prefix,
                         p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF ;

  EXCEPTION WHEN OTHERS THEN
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data => x_msg_data);

    IF fnd_log.LEVEL_UNEXPECTED >=fnd_log.g_current_runtime_level THEN
        debug(p_message=> 'Import Salesrep API raised EXCEPTION:'||
                        ' p_batch_id :'||p_batch_id||
                        ' Error :'||SQLERRM,
                         p_prefix => l_debug_prefix,
                         p_msg_level=> fnd_log.LEVEL_UNEXPECTED);
    END IF;


END import_salesreps;


END jtf_rs_interface_pvt;

/
