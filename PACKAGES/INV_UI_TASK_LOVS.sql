--------------------------------------------------------
--  DDL for Package INV_UI_TASK_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_TASK_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVUITAS.pls 120.2 2008/02/15 10:37:58 mporecha ship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_SUB_LOV_RCV
--
--      Input parameters:
--       p_project_id     which restricts LOV SQL to specified project
--       p_restrict_tasks
--
--      Output parameters:
--       x_tasks      returns LOV rows as reference cursor
--
--

   PROCEDURE GET_TASKS(
                       x_tasks          OUT NOCOPY /* file.sql.39 change */ t_genref,
                       p_restrict_tasks IN  VARCHAR,
                       p_project_id     IN  VARCHAR
                      );

  PROCEDURE GET_MO_TASKS(
                      x_tasks           OUT NOCOPY /* file.sql.39 change */ t_genref,
                      p_restrict_tasks  IN  VARCHAR2,
		      p_project_id      IN  NUMBER,
		      p_organization_id IN  NUMBER,
                      p_mo_header_id    IN  NUMBER
                     );

  PROCEDURE GET_CC_TASKS (
				x_tasks           OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_restrict_tasks  IN  VARCHAR2,
				p_project_id      IN  NUMBER,
				p_organization_id IN  NUMBER,
				p_cycle_count_id  IN  NUMBER,
				p_unscheduled_flag IN NUMBER
			);

	PROCEDURE GET_PHY_TASKS (
                                x_tasks           OUT NOCOPY /* file.sql.39 change */ t_genref,
                                p_restrict_tasks  IN  VARCHAR2,
                                p_project_id      IN  NUMBER,
                                p_organization_id IN  NUMBER,
                                p_dynamic_entry_flag     IN   NUMBER,
                                p_physical_inventory_id  IN   NUMBER
                          );
	PROCEDURE GET_RCV_TASKS(
                           X_TASKS              OUT NOCOPY /* file.sql.39 change */ t_genref,
                           p_document_type      IN VARCHAR2,
                           p_po_header_id       IN NUMBER,
                           p_po_line_id         IN NUMBER,
                           p_oe_header_id       IN NUMBER,
                           p_req_header_id      IN NUMBER,
                           p_shipment_id        IN NUMBER,
                           p_project_id         IN NUMBER,
                           p_task_number        IN VARCHAR2,
                           p_item_id            IN NUMBER DEFAULT NULL,
                           p_lpn_id             IN NUMBER DEFAULT NULL, -- ASN
                           p_po_release_id      IN NUMBER DEFAULT NULL,
                           p_is_deliver         IN VARCHAR2 DEFAULT 'F' --bug 6785303
                          );

END INV_UI_TASK_LOVS;

/
