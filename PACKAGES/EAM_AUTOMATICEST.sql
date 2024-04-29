--------------------------------------------------------
--  DDL for Package EAM_AUTOMATICEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_AUTOMATICEST" AUTHID CURRENT_USER AS
/* $Header: EAMPARCS.pls 115.3 2002/11/25 06:13:41 rethakur noship $ */

TYPE wip_entity_tbl_type IS TABLE OF wip_discrete_jobs.wip_entity_id%TYPE;

TYPE po_dist_tbl_type IS TABLE OF po_distributions_all.po_distribution_id%TYPE;

PROCEDURE Auto_Reest_of_Cost(
		p_wip_entity_id    IN   NUMBER,
		p_api_name	   IN   VARCHAR2,
		p_req_line_id      IN   NUMBER,
		p_po_dist_id	   IN   NUMBER,
		p_po_line_id       IN   NUMBER,
		p_inv_item_id	   IN   NUMBER,
		p_org_id	   IN   NUMBER,
		p_resource_id	   IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_count        OUT NOCOPY  NUMBER,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);


PROCEDURE  Call_Validate_for_Reestimation(
		p_wip_entity_id    IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);


PROCEDURE  CST_Item_Cost_Change(
		p_inv_item_id      IN   NUMBER,
		p_org_id	   IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);

PROCEDURE  CST_Usage_Rate_Change(
		p_resource_id	   IN   NUMBER,
		p_org_id	   IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);

PROCEDURE  PO_Req_Logic(
		p_req_line_id      IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);


PROCEDURE  PO_Po_Logic(
		p_po_dist_id	   IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);

PROCEDURE  PO_Line_Logic(
		p_po_line_id	   IN   NUMBER,
		x_return_status    OUT NOCOPY  VARCHAR2,
		x_msg_data         OUT NOCOPY  VARCHAR2
		);

end EAM_AutomaticEst;

 

/
