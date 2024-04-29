--------------------------------------------------------
--  DDL for Package INV_UI_PROJECT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_PROJECT_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVUIPRS.pls 120.2.12010000.1 2008/07/24 01:50:33 appldev ship $ */

TYPE t_genref IS REF CURSOR;
--
--      Name: GET_PROJECTS
--
--      Input parameters:
--       p_restrict_projects
--
--      Output parameters:
--       x_projects      returns LOV rows as reference cursor
--
--      Functions: This API is to return all valid projects
--

PROCEDURE GET_PROJECTS(
                       x_projects          OUT NOCOPY /* file.sql.39 change */ t_genref,
                       p_restrict_projects IN  VARCHAR
                      );

PROCEDURE GET_RCV_PROJECTS(
			    X_PROJECTS 	 OUT NOCOPY /* file.sql.39 change */ t_genref,
			    document_type        IN  VARCHAR2,
			    p_po_header_id       IN  NUMBER,
			    p_po_line_id         IN  NUMBER,
			    p_order_header_id    IN  NUMBER,
			    p_req_header_id      IN  NUMBER,
			    p_shipment_header_id IN  NUMBER,
			    p_project_number     IN  VARCHAR2,
			    p_item_id            IN  NUMBER DEFAULT NULL,
			    p_lpn_id             IN  NUMBER DEFAULT NULL,
			    p_po_release_id      IN  NUMBER DEFAULT NULL,--BUG 4201013
			    p_is_deliver         IN  VARCHAR2 DEFAULT 'F' --bug6785303
			   );

PROCEDURE GET_CC_PROJECTS (
				x_projects	   OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_organization_id  IN  NUMBER,
				p_cycle_count_id   IN  NUMBER,
				p_unscheduled_flag IN NUMBER,
				p_project_number   IN  VARCHAR2
			  );

PROCEDURE GET_PHY_PROJECTS (
                                x_projects      OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_organization_id IN  NUMBER,
                                p_dynamic_entry_flag     IN   NUMBER,
                                p_physical_inventory_id  IN   NUMBER,
                                p_project_number         IN   varchar2
                             ) ;
PROCEDURE GET_MO_PROJECTS(
                       x_projects          OUT NOCOPY /* file.sql.39 change */ t_genref,
                       p_restrict_projects IN  VARCHAR2,
		       p_organization_id   IN  NUMBER,
		       p_mo_header_id      IN  NUMBER
                      );
END INV_UI_PROJECT_LOVS;

/
