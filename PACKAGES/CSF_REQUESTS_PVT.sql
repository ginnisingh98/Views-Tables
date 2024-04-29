--------------------------------------------------------
--  DDL for Package CSF_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_REQUESTS_PVT" AUTHID CURRENT_USER AS
  /* $Header: CSFVREQS.pls 120.4.12010000.6 2010/03/19 04:36:52 rkamasam ship $ */

  TYPE resource_tbl_type IS TABLE OF csf_r_resource_results%ROWTYPE;
  TYPE object_tbl_type IS TABLE OF NUMBER;

  PROCEDURE create_scheduler_request(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2          DEFAULT NULL
  , p_commit                     IN            VARCHAR2          DEFAULT NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_name                       IN            VARCHAR2
  , p_object_id                  IN            NUMBER
  , p_resource_tbl               IN            resource_tbl_type DEFAULT NULL
  , p_status_id                  IN            NUMBER            DEFAULT NULL
  , p_route_based_flag           IN            VARCHAR2          DEFAULT 'N'
  , p_changed_option_start       IN            DATE              DEFAULT NULL
  , p_changed_option_end         IN            DATE              DEFAULT NULL
  , p_changed_planned_start      IN            DATE              DEFAULT NULL
  , p_changed_planned_end        IN            DATE              DEFAULT NULL
  , p_disabled_access_hours_flag IN            VARCHAR2          DEFAULT 'N'
  , p_set_plan_task_confirmed    IN            VARCHAR2          DEFAULT 'N'
  , p_parent_id                  IN            NUMBER            DEFAULT NULL
  , p_spares_mandatory           IN            VARCHAR2          DEFAULT NULL
  , p_spares_source              IN            VARCHAR2          DEFAULT NULL
  , p_standby_param              IN            VARCHAR2          DEFAULT NULL
  , p_resource_preference        IN            VARCHAR2          DEFAULT NULL
  , x_request_id                 OUT NOCOPY    NUMBER
  );

  PROCEDURE create_resource_results(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2          DEFAULT NULL
  , p_commit                     IN            VARCHAR2          DEFAULT NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_request_task_id            IN            VARCHAR2
  , p_resource_tbl               IN            resource_tbl_type
  );

  PROCEDURE create_plan_option(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2 DEFAULT NULL
  , p_commit               IN            VARCHAR2 DEFAULT NULL
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
  );

  PROCEDURE create_plan_option_task(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2 DEFAULT NULL
  , p_commit               IN            VARCHAR2 DEFAULT NULL
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
  );

  PROCEDURE create_message(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2 DEFAULT NULL
  , p_commit        IN            VARCHAR2 DEFAULT NULL
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_request_id    IN            NUMBER
  , p_name          IN            VARCHAR2
  , p_type          IN            VARCHAR2
  , x_message_id    OUT NOCOPY    NUMBER
  );

  PROCEDURE create_message_token(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2 DEFAULT NULL
  , p_commit        IN            VARCHAR2 DEFAULT NULL
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , p_message_id    IN            NUMBER
  , p_name          IN            VARCHAR2
  , p_value         IN            VARCHAR2
  );

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
  , p_shift_type_tbl           IN            jtf_varchar2_table_100      DEFAULT NULL
  , x_plan_option_id_tbl       OUT NOCOPY    jtf_number_table
  );

  PROCEDURE create_multi_trips_request(
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2           DEFAULT NULL
  , p_commit             IN              VARCHAR2           DEFAULT NULL
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , p_parent_req_name    IN              VARCHAR2
  , p_child_req_name     IN              VARCHAR2
  , p_trip_tbl           IN              object_tbl_type    DEFAULT NULL
  , p_resource_tbl       IN              resource_tbl_type  DEFAULT NULL
  , x_sched_request_id   OUT NOCOPY      NUMBER
  );

END csf_requests_pvt;

/
