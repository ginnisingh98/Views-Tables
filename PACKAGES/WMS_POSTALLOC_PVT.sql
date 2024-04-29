--------------------------------------------------------
--  DDL for Package WMS_POSTALLOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_POSTALLOC_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVPRPS.pls 120.0.12010000.4 2009/05/05 14:01:53 ajunnikr noship $*/

  g_pkg_spec_ver  CONSTANT VARCHAR2(100) := '$Header $';
  g_pkg_name      CONSTANT VARCHAR2(30)  := 'WMS_POSTALLOC_PVT';
  g_caller varchar2(10) := 'N';
  g_pick_group_rule varchar2(10) := 'N';



PROCEDURE assign_operation_plans
( p_batch_id          IN    NUMBER
, x_return_status     OUT   NOCOPY   VARCHAR2
);

PROCEDURE cartonize
( p_org_id                 IN    NUMBER
, p_move_order_header_id   IN    NUMBER
, p_caller                 IN VARCHAR2 DEFAULT 'N'
, x_return_status          OUT   NOCOPY   VARCHAR2
);

PROCEDURE consolidate_tasks
( p_mo_header_id      IN    NUMBER
, x_return_status     OUT   NOCOPY   VARCHAR2
);

PROCEDURE assign_task_types
( p_batch_id          IN    NUMBER
, x_return_status     OUT   NOCOPY   VARCHAR2
);

FUNCTION get_device_id
( p_organization_id   IN NUMBER
, p_subinventory_code IN VARCHAR2
, p_locator_id        IN NUMBER
) RETURN NUMBER;

PROCEDURE insert_device_requests
( p_organization_id   IN    NUMBER
, p_mo_header_id      IN    NUMBER
, x_return_status     OUT   NOCOPY   VARCHAR2
);

PROCEDURE assign_pick_slip_numbers
( p_organization_id   IN           NUMBER
, p_mo_header_id      IN           NUMBER
, p_grouping_rule_id  IN           NUMBER
, x_return_status     OUT  NOCOPY  VARCHAR2
);

PROCEDURE print_labels
( p_batch_id          IN    NUMBER
, x_return_status     OUT   NOCOPY   VARCHAR2
);

END wms_postalloc_pvt;

/
