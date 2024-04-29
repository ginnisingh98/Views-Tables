--------------------------------------------------------
--  DDL for Package WSH_BOLS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_BOLS_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHBLUTS.pls 120.0.12010000.1 2008/07/29 05:58:30 appldev ship $ */

-- purpose: get the container contents information for master
--          container
-- parameters: p_master_container_id = wsh_delivery_detail_id
--             p_output_mode = 'WEB' or 'REPORT'
--             p_description_mode = 'D', 'F', or 'B'
--             p_organization_id (or warehouse id)
--             x_data_item_classification, for the container
--             x_container_contents, for the container
--             x_hazard_code, for the container
--             x_return_status


PROCEDURE get_master_container_contents
  (p_master_container_id IN NUMBER,
   p_output_mode IN VARCHAR2,
   p_description_mode IN VARCHAR2,
   p_organization_id IN NUMBER,
   x_data_item_classification IN OUT NOCOPY  VARCHAR2,
   x_container_contents IN OUT NOCOPY  VARCHAR2,
   x_hazard_code IN OUT NOCOPY  VARCHAR2,
   x_num_of_packages IN OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2
   );


END WSH_BOLS_UTIL_PKG;

/
