--------------------------------------------------------
--  DDL for Package IGR_INFTYP_PKG_IT_CRM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_INFTYP_PKG_IT_CRM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH13S.pls 120.0 2005/06/02 04:12:05 appldev noship $ */

  PROCEDURE insert_row(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_deliverable_kit_item_id IN OUT NOCOPY NUMBER,
    x_deliverable_kit_id IN NUMBER,
    x_deliverable_kit_part_id IN NUMBER
  );

  PROCEDURE delete_row(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_deliverable_kit_item_id IN NUMBER
  );

END igr_inftyp_pkg_it_crm_pkg;

 

/
