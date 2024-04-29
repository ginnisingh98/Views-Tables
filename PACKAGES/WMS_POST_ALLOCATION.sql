--------------------------------------------------------
--  DDL for Package WMS_POST_ALLOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_POST_ALLOCATION" AUTHID CURRENT_USER AS
  /* $Header: WMSPRPAS.pls 120.0.12010000.6 2009/08/03 13:06:44 mitgupta noship $ */

 g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_POST_ALLOCATION';


  PROCEDURE process_post_allocation
  ( errbuf                 OUT   NOCOPY   VARCHAR2
  , retcode                OUT   NOCOPY   NUMBER
  , p_pickrel_batch        IN             VARCHAR2
  , p_organization_id      IN             NUMBER
  , p_assign_op_plans      IN             NUMBER    DEFAULT  1
  , p_call_cartonization   IN             NUMBER    DEFAULT  1
  , p_consolidate_tasks    IN             NUMBER    DEFAULT  1
  , p_assign_task_types    IN             NUMBER    DEFAULT  1
  , p_process_device_reqs  IN             NUMBER    DEFAULT  1
  , p_assign_pick_slips    IN             NUMBER    DEFAULT  1
  , p_plan_tasks           IN             NUMBER    DEFAULT  2
  , p_print_labels         IN             NUMBER    DEFAULT  1
  , p_wave_simulation_mode IN             VARCHAR2  DEFAULT  'N'
  );

  PROCEDURE launch
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_auto_pick_confirm    IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , p_wsh_mode             IN    VARCHAR2
  , p_grouping_rule_id     IN    NUMBER
  , p_allow_partial_pick   IN    VARCHAR2
  , p_plan_tasks           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  , x_org_complete         OUT   NOCOPY   VARCHAR2
  );

  PROCEDURE assign_operation_plans
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  );

  PROCEDURE process_sub_request
  ( errbuf              OUT   NOCOPY   VARCHAR2
  , retcode             OUT   NOCOPY   NUMBER
  , p_batch_id          IN    NUMBER
  , p_mode              IN    VARCHAR2
  , p_worker_id         IN    NUMBER
  );

  PROCEDURE assign_task_types
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  );

  PROCEDURE print_labels
  ( p_organization_id      IN    NUMBER
  , p_mo_header_id         IN    NUMBER
  , p_batch_id             IN    NUMBER
  , p_num_workers          IN    NUMBER
  , p_auto_pick_confirm    IN    VARCHAR2
  , p_create_sub_batches   IN    VARCHAR2
  , p_wsh_status           IN    VARCHAR2
  , x_return_status        OUT   NOCOPY   VARCHAR2
  );

END wms_post_allocation;

/
