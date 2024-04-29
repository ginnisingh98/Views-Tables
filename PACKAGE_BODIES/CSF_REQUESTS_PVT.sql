--------------------------------------------------------
--  DDL for Package Body CSF_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_REQUESTS_PVT" AS
  /* $Header: CSFVREQB.pls 120.5.12010000.8 2010/03/24 09:51:00 rkamasam ship $ */
  g_pkg_name CONSTANT VARCHAR2(30) := 'CSF_REQUESTS_PVT';

  PROCEDURE create_scheduler_request(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2
  , p_commit                     IN            VARCHAR2
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_name                       IN            VARCHAR2
  , p_object_id                  IN            NUMBER
  , p_resource_tbl               IN            resource_tbl_type
  , p_status_id                  IN            NUMBER
  , p_route_based_flag           IN            VARCHAR2
  , p_changed_option_start       IN            DATE
  , p_changed_option_end         IN            DATE
  , p_changed_planned_start      IN            DATE
  , p_changed_planned_end        IN            DATE
  , p_disabled_access_hours_flag IN            VARCHAR2
  , p_set_plan_task_confirmed    IN            VARCHAR2
  , p_parent_id                  IN            NUMBER
  , p_spares_mandatory           IN            VARCHAR2
  , p_spares_source              IN            VARCHAR2
  , p_standby_param              IN            VARCHAR2
  , p_resource_preference        IN            VARCHAR2
  , x_request_id                 OUT NOCOPY    NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)    := 'CREATE_SCHEDULER_REQUEST';
    l_api_version CONSTANT NUMBER          := 1.0;

    l_request_task_id NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createschedulerrequest;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    INSERT INTO csf_r_sched_requests(
                 sched_request_id
               , sched_request_name
               , parent_request_id
               , planmode -- this column is obsolete; will be removed
               , route_based_flag
               , target_status_id
               , changed_option_start
               , changed_option_end
               , changed_planned_start
               , changed_planned_end
               , disabled_access_hours_flag
               , customer_conf_rcvd
               , created_by
               , creation_date
               , last_updated_by
               , last_update_date
               , object_version_number
               , consider_standby_shift
               , spares_source
               , spares_mandatory
               , res_preference
               )
         VALUES (
                 csf_r_sched_requests_s1.NEXTVAL
               , p_name
               , p_parent_id
               , -1 -- dummy value for obsolete but mandatory column
               , p_route_based_flag
               , p_status_id
               , p_changed_option_start
               , p_changed_option_end
               , p_changed_planned_start
               , p_changed_planned_end
               , p_disabled_access_hours_flag
               , p_set_plan_task_confirmed
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , 1
               , p_standby_param
               , p_spares_source
               , p_spares_mandatory
               , p_resource_preference
               )
       RETURNING sched_request_id INTO x_request_id;

    -- insert task into the csf_r_request_tasks table
    INSERT INTO csf_r_request_tasks(
                 request_task_id
               , sched_request_id
               , task_id
               , object_version_number
               )
         VALUES (
                 csf_r_request_tasks_s1.NEXTVAL
               , x_request_id
               , p_object_id
               , 1
               )
       RETURNING request_task_id INTO l_request_task_id;

    create_resource_results(
      p_api_version       => 1
    , p_init_msg_list     => fnd_api.g_false
    , p_commit            => fnd_api.g_false
    , x_return_status     => x_return_status
    , x_msg_count         => x_msg_count
    , x_msg_data          => x_msg_data
    , p_request_task_id   => l_request_task_id
    , p_resource_tbl      => p_resource_tbl
    );

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createschedulerrequest;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createschedulerrequest;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createschedulerrequest;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_scheduler_request;

  PROCEDURE create_resource_results(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2          DEFAULT NULL
  , p_commit                     IN            VARCHAR2          DEFAULT NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_request_task_id            IN            VARCHAR2
  , p_resource_tbl               IN            resource_tbl_type
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)    := 'CREATE_RESOURCE_RESULTS';
    l_api_version CONSTANT NUMBER          := 1.0;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createresourceresults;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF p_resource_tbl IS NOT NULL AND p_resource_tbl.COUNT > 0 THEN
      FOR i IN 1 .. p_resource_tbl.LAST LOOP
        INSERT INTO csf_r_resource_results
                    (
                     resource_result_id
                   , request_task_id
                   , resource_id
                   , resource_type
                   , territory_rank
                   , territory_id
                   , preferred_resources_flag
                   , planwin_start
                   , planwin_end
                   , object_version_number
                   , skill_level
                   , resource_source
                    )
             VALUES (
                     csf_r_resource_results_s1.NEXTVAL
                   , p_request_task_id
                   , p_resource_tbl(i).resource_id
                   , p_resource_tbl(i).resource_type
                   , NVL(p_resource_tbl(i).territory_rank, '1')
                   , NVL(p_resource_tbl(i).territory_id, '-1')
                   , p_resource_tbl(i).preferred_resources_flag
                   , NVL(p_resource_tbl(i).planwin_start, SYSDATE)
                   , NVL(p_resource_tbl(i).planwin_end, SYSDATE)
                   , 1
                   , p_resource_tbl(i).skill_level
                   , p_resource_tbl(i).resource_source
                    );
      END LOOP;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createresourceresults;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createresourceresults;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createresourceresults;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_resource_results;

  PROCEDURE create_plan_option(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2
  , p_commit               IN            VARCHAR2
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_request_task_id      IN            NUMBER
  , p_scheduled_start_date IN            DATE
  , p_scheduled_end_date   IN            DATE
  , p_resource_id          IN            NUMBER
  , p_resource_type        IN            VARCHAR2
  , p_cost                 IN            NUMBER
  , p_terr_id              IN            NUMBER
  , p_win_to_promis_id     IN            NUMBER
  , p_spares_cost          IN            NUMBER
  , p_spares_date          IN            DATE
  , p_shift_type           IN            VARCHAR2
  , x_plan_option_id       OUT NOCOPY    NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)         := 'CREATE_PLAN_OPTION';
    l_api_version CONSTANT NUMBER               := 1.0;

    CURSOR c_resource(
      p_request_task_id NUMBER
    , p_resource_id     NUMBER
    , p_resource_type   VARCHAR2
    , p_spares_date     DATE
    , p_spares_cost     NUMBER
    ) IS
      SELECT rr.resource_result_id
           , so.spares_option_id
           , csf_r_plan_options_s1.NEXTVAL plan_option_id
        FROM csf_r_resource_results rr, csf_r_spares_options so
       WHERE rr.request_task_id = p_request_task_id
         AND rr.resource_id = p_resource_id
         AND rr.resource_type = p_resource_type
         AND so.resource_result_id(+) = rr.resource_result_id
         AND so.availability_date(+) = p_spares_date
         AND so.COST(+) = p_spares_cost;

    l_resource_rec c_resource%ROWTYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createplanoption;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status   := fnd_api.g_ret_sts_success;

    OPEN c_resource(p_request_task_id, p_resource_id, p_resource_type, p_spares_date, p_spares_cost);
    FETCH c_resource INTO l_resource_rec;
    IF c_resource%NOTFOUND THEN
      CLOSE c_resource;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_resource;

    IF l_resource_rec.spares_option_id IS NULL THEN
      INSERT INTO csf_r_spares_options
                  (
                   spares_option_id
                 , resource_result_id
                 , availability_date
                 , COST
                 , object_version_number
                  )
           VALUES (
                   csf_r_spares_options_s1.NEXTVAL
                 , l_resource_rec.resource_result_id
                 , p_spares_date
                 , p_spares_cost
                 , 1
                  )
         RETURNING spares_option_id INTO l_resource_rec.spares_option_id;
    END IF;

    INSERT INTO csf_r_plan_options
                (
                 plan_option_id
               , resource_result_id
               , spares_option_id
               , scheduled_start_date
               , scheduled_end_date
               , COST
               , win_to_promis_id
               , object_version_number
               , shift_type
                )
         VALUES (
                 l_resource_rec.plan_option_id
               , l_resource_rec.resource_result_id
               , l_resource_rec.spares_option_id
               , p_scheduled_start_date
               , p_scheduled_end_date
               , p_cost
               , p_win_to_promis_id
               , 1
               , p_shift_type
                );

    -- output plan option id
    x_plan_option_id  := l_resource_rec.plan_option_id;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createplanoption;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createplanoption;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createplanoption;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_plan_option;

  PROCEDURE create_plan_option_task(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2
  , p_commit               IN            VARCHAR2
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_plan_option_id       IN            NUMBER
  , p_task_id              IN            NUMBER
  , p_scheduled_start_date IN            DATE
  , p_scheduled_end_date   IN            DATE
  , p_travel_time          IN            NUMBER
  , p_task_assign_id       IN            NUMBER
  , p_trip_id              IN            NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_PLAN_OPTION_TASK';
    l_api_version CONSTANT NUMBER       := 1.0;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createplanoptiontask;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    INSERT INTO csf_r_plan_option_tasks
                (
                 plan_option_task_id
               , plan_option_id
               , task_id
               , scheduled_start_date
               , scheduled_end_date
               , travel_time
               , task_assignment_id
               , object_capacity_id
               , object_version_number
                )
         VALUES (
                 csf_r_plan_option_tasks_s1.NEXTVAL
               , p_plan_option_id
               , p_task_id
               , p_scheduled_start_date
               , p_scheduled_end_date
               , p_travel_time
               , p_task_assign_id
               , p_trip_id
               , 1
                );

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createplanoptiontask;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createplanoptiontask;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createplanoptiontask;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_plan_option_task;

  PROCEDURE create_message(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2
  , p_commit        IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_request_id    IN            NUMBER
  , p_name          IN            VARCHAR2
  , p_type          IN            VARCHAR2
  , x_message_id    OUT NOCOPY    NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)        := 'CREATE_MESSAGE';
    l_api_version CONSTANT NUMBER              := 1.0;

    CURSOR c_message(p_request_id NUMBER) IS
      SELECT request_task_id
           , csf_r_messages_s1.NEXTVAL message_id
        FROM csf_r_request_tasks
       WHERE sched_request_id = p_request_id
         AND ROWNUM = 1;   -- there should be one task per request

    l_rec                  c_message%ROWTYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createmessage;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    OPEN c_message(p_request_id);
    FETCH c_message INTO l_rec;
    IF c_message%NOTFOUND THEN
      CLOSE c_message;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_message;

    INSERT INTO csf_r_messages
                (
                 message_id
               , request_task_id
               , name
               , type
               , object_version_number
                )
         VALUES (
                 l_rec.message_id
               , l_rec.request_task_id
               , p_name
               , p_type
               , 1
                );

    x_message_id     := l_rec.message_id;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createmessage;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createmessage;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createmessage;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_message;

  PROCEDURE create_message_token(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2
  , p_commit        IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_message_id    IN            NUMBER
  , p_name          IN            VARCHAR2
  , p_value         IN            VARCHAR2
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_MESSAGE_TOKEN';
    l_api_version CONSTANT NUMBER       := 1.0;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createmessagetoken;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    INSERT INTO csf_r_message_tokens
                (
                 message_token_id
               , message_id
               , NAME
               , VALUE
               , object_version_number
                )
         VALUES (
                 csf_r_message_tokens_s1.NEXTVAL
               , p_message_id
               , SUBSTR(p_name, 1, 60)
               , SUBSTR(p_value, 1, 4000)
               , 1
                );

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createmessagetoken;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createmessagetoken;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    --
    WHEN OTHERS THEN
      ROLLBACK TO createmessagetoken;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_message_token;

  PROCEDURE create_plan_options(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2
  , p_commit                   IN            VARCHAR2
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_request_task_id          IN            NUMBER
  , p_scheduled_start_date_tbl IN            jtf_date_table
  , p_scheduled_end_date_tbl   IN            jtf_date_table
  , p_resource_id_tbl          IN            jtf_number_table
  , p_resource_type_tbl        IN            jtf_varchar2_table_100
  , p_cost_tbl                 IN            jtf_number_table
  , p_terr_id_tbl              IN            jtf_number_table
  , p_win_to_promis_id_tbl     IN            jtf_number_table
  , p_spares_cost_tbl          IN            jtf_number_table
  , p_spares_date_tbl          IN            jtf_date_table
  , p_shift_type_tbl           IN            jtf_varchar2_table_100
  , x_plan_option_id_tbl       OUT NOCOPY    jtf_number_table
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)         := 'CREATE_PLAN_OPTIONS';
    l_api_version CONSTANT NUMBER               := 1.0;
    l_shift_type  varchar2(30)                  := null;

    CURSOR c_resource(
      p_request_task_id NUMBER
    , p_resource_id     NUMBER
    , p_resource_type   VARCHAR2
    , p_spares_date     DATE
    , p_spares_cost     NUMBER
    ) IS
      SELECT rr.resource_result_id
           , so.spares_option_id
           , csf_r_plan_options_s1.NEXTVAL plan_option_id
        FROM csf_r_resource_results rr, csf_r_spares_options so
       WHERE rr.request_task_id = p_request_task_id
         AND rr.resource_id = p_resource_id
         AND rr.resource_type = p_resource_type
         AND so.resource_result_id(+) = rr.resource_result_id
         AND so.availability_date(+) = p_spares_date
         AND so.COST(+) = p_spares_cost;

    l_resource_rec c_resource%ROWTYPE;

    j           PLS_INTEGER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT createplanoptions;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status   := fnd_api.g_ret_sts_success;
    x_plan_option_id_tbl  := jtf_number_table();
    IF p_resource_id_tbl IS NOT NULL AND p_resource_id_tbl.COUNT > 0 THEN

      j := p_resource_id_tbl.FIRST;
      WHILE j IS NOT NULL LOOP
        OPEN c_resource(p_request_task_id, p_resource_id_tbl(j), p_resource_type_tbl(j), p_spares_date_tbl(j), p_spares_cost_tbl(j));
        FETCH c_resource INTO l_resource_rec;
        IF c_resource%NOTFOUND THEN
         CLOSE c_resource;
         RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_resource;

        IF l_resource_rec.spares_option_id IS NULL THEN
          INSERT INTO csf_r_spares_options
                  (
                   spares_option_id
                 , resource_result_id
                 , availability_date
                 , COST
                 , object_version_number
                  )
           VALUES (
                   csf_r_spares_options_s1.NEXTVAL
                 , l_resource_rec.resource_result_id
                 , p_spares_date_tbl(j)
                 , p_spares_cost_tbl(j)
                 , 1
                  )
         RETURNING spares_option_id INTO l_resource_rec.spares_option_id;
       END IF;

       IF p_shift_type_tbl IS NOT NULL THEN
         l_shift_type := p_shift_type_tbl(j);
       END IF;

       INSERT INTO csf_r_plan_options
                (
                 plan_option_id
               , resource_result_id
               , spares_option_id
               , scheduled_start_date
               , scheduled_end_date
               , COST
               , win_to_promis_id
               , object_version_number
               , shift_type
                )
         VALUES (
                 l_resource_rec.plan_option_id
               , l_resource_rec.resource_result_id
               , l_resource_rec.spares_option_id
               , p_scheduled_start_date_tbl(j)
               , p_scheduled_end_date_tbl(j)
               , p_cost_tbl(j)
               , p_win_to_promis_id_tbl(j)
               , 1
               , p_shift_type_tbl(j)
                );

        x_plan_option_id_tbl.extend;
        x_plan_option_id_tbl(j) := l_resource_rec.plan_option_id;
        j :=  p_resource_id_tbl.NEXT(j);
      END LOOP;
    END IF;
    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO createplanoptions;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO createplanoptions;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO createplanoptions;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_plan_options;

  PROCEDURE create_multi_trips_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2
  , p_commit             IN              VARCHAR2
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_parent_req_name    IN              VARCHAR2
  , p_child_req_name     IN              VARCHAR2
  , p_trip_tbl           IN              object_tbl_type
  , p_resource_tbl       IN              resource_tbl_type
  , x_sched_request_id   OUT NOCOPY      NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)         := 'CREATE_MULTI_TRIPS_REQUEST';
    l_api_version CONSTANT NUMBER               := 1.0;

    l_index             PLS_INTEGER;
    l_child_request_id  NUMBER;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_opttrips_request;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status   := fnd_api.g_ret_sts_success;

    -- Create the Parent Request
    create_scheduler_request(
      p_api_version       => 1
    , x_return_status     => x_return_status
    , x_msg_data          => x_msg_data
    , x_msg_count         => x_msg_count
    , p_name              => p_parent_req_name
    , p_object_id         => -1
    , x_request_id        => x_sched_request_id
    );
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /**
     * Create the Child Requests.
     *
     * In case the Trips Table is provided (P_TRIP_TBL), then the caller
     * wants the Child Request action to be undertaken individually on
     * each trip. Thus there will be as many child requests created
     * as the number of trips in the P_TRIP_TBL.
     *
     * In case the Resource Table is provided (P_RESOURCE_TBL), then
     * the caller wants the Child Request action to be undertaken as
     * a whole on all the resources. Thus there will be a single
     * request created with all the resource information.
     *
     * This can be generalized in the future by adding another
     * parameter P_INDIVIDUAL_REQUESTS (BOOLEAN) so that the caller
     * can have more control on how the requests are created rather
     * than the API deciding based on the parameters.
     */
    IF p_trip_tbl IS NOT NULL AND p_trip_tbl.COUNT > 0 THEN
      -- In case Trips Table is provided,
      l_index := p_trip_tbl.FIRST;
      WHILE l_index IS NOT NULL LOOP
        create_scheduler_request(
          p_api_version       => 1
        , x_return_status     => x_return_status
        , x_msg_data          => x_msg_data
        , x_msg_count         => x_msg_count
        , p_name              => p_child_req_name
        , p_object_id         => p_trip_tbl(l_index)
        , p_parent_id         => x_sched_request_id
        , x_request_id        => l_child_request_id
        );
        l_index := p_trip_tbl.next(l_index);
      END LOOP;
    ELSIF p_resource_tbl IS NOT NULL AND p_resource_tbl.COUNT > 0 THEN
      create_scheduler_request(
        p_api_version       => 1
      , x_return_status     => x_return_status
      , x_msg_data          => x_msg_data
      , x_msg_count         => x_msg_count
      , p_name              => p_child_req_name
      , p_object_id         => -1
      , p_resource_tbl      => p_resource_tbl
      , p_parent_id         => x_sched_request_id
      , x_request_id        => l_child_request_id
      );
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_opttrips_request;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_opttrips_request;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_opttrips_request;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_multi_trips_request;
END csf_requests_pvt;

/
