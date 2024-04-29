--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_DETAILS_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_DETAILS_UTILITIES" AUTHID CURRENT_USER as
/* $Header: WSHDDUTS.pls 120.0.12010000.2 2010/02/26 06:59:52 sankarun ship $ */

TYPE porcessed_flag_tbl IS TABLE OF VARCHAR2(1)
  INDEX BY BINARY_INTEGER;



TYPE  delivery_assignment_rec_type IS RECORD (
   delivery_detail_id              wsh_delivery_details.delivery_detail_id%type,
   delivery_id                     wsh_new_deliveries.delivery_id%type);

TYPE delivery_assignment_rec_tbl IS TABLE OF delivery_assignment_rec_type
  INDEX BY BINARY_INTEGER;

PROCEDURE Append_to_Deliveries(
          p_delivery_detail_tbl     IN  WSH_UTIL_CORE.Id_Tab_Type,
          p_append_flag             IN  VARCHAR2 DEFAULT NULL,
          p_group_by_header         IN  VARCHAR2 DEFAULT NULL,
          p_commit                  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_lock_rows               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_check_fte_compatibility IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
          x_appended_det_tbl        OUT NOCOPY WSH_DELIVERY_DETAILS_UTILITIES.delivery_assignment_rec_tbl,
          x_unappended_det_tbl      OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
          x_appended_del_tbl        OUT NOCOPY WSH_UTIL_CORE.Id_Tab_Type,
          x_return_status           OUT NOCOPY VARCHAR2);

-- TPW - Distributed Organization Changes - Start
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Updates_Allowed
--
-- PARAMETERS:
--       p_changed_attributes   => Delivery Details changed attributes
--       p_source_code          => Source Code
--       x_update_allowed       => Update Allowed Flag
--       x_return_status        => Return Status of API (S,E,U)
--
-- COMMENT:
--       API will not allow updates other than Ordered Quantity and Order
--       Quantity UOM, if
--       1) Organization is Distributed Enabled Org (TW2)
--       2) Delivery line corresponding to order line is associated with
--          Shipment batch.
--       Increase in quantity is always allowed
--       For decrease in quantity, there should be delivery line(s) which are
--       not yet assigned to Shipment Batch atleast for quantity being cancelled.
--=============================================================================
--
PROCEDURE Check_Updates_Allowed(
          p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
          p_source_code        IN  VARCHAR2,
          x_update_allowed     OUT NOCOPY  VARCHAR2,
          x_return_status      OUT NOCOPY  VARCHAR2);
-- TPW - Distributed Organization Changes - End


END WSH_DELIVERY_DETAILS_UTILITIES;

/
