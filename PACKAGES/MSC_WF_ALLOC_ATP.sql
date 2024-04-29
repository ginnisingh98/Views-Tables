--------------------------------------------------------
--  DDL for Package MSC_WF_ALLOC_ATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WF_ALLOC_ATP" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCWFATS.pls 120.1 2005/08/25 05:16:41 anbansal noship $ */


   --  ================= Procedures ====================

        --ATP Debug Workflow
        PROCEDURE DEBUG_WF(
                    p_session_id        IN      NUMBER,
                    p_login_user        IN      VARCHAR2,
                    p_session_loc_des   IN      VARCHAR2,
                    p_trace_loc_des     IN      VARCHAR2,
                    p_spid_des          IN      NUMBER);

        PROCEDURE start_mscalloc_wf(
                p_itemkey               IN      VARCHAR2,
                p_inventory_item_id     IN      NUMBER,
                p_inventory_item_name   IN      VARCHAR2,
                p_plan_id               IN      NUMBER,
                p_organization_id       IN      NUMBER,
                p_organization_code     IN      VARCHAR2,
                p_instance_id           IN      NUMBER,
                p_demand_class          IN      VARCHAR2,
                p_requested_qty         IN      NUMBER,
                p_request_date          IN      DATE,
                p_request_date_qty      IN      NUMBER,
                p_available_qty         IN      NUMBER,
                p_available_date        IN      DATE,
                p_stolen_qty            IN      NUMBER,
                p_customer_id           IN      NUMBER,
                p_customer_site_id      IN      NUMBER,
                p_order_number          IN      NUMBER);

	PROCEDURE Within_Allocation(
		itemtype  in 	varchar2,
		itemkey   in 	varchar2,
		actid     in 	number,
		funcmode  in 	varchar2,
		resultout out 	NoCopy varchar2);

        PROCEDURE Qty_Stolen(
                itemtype  in    varchar2,
                itemkey   in    varchar2,
                actid     in    number,
                funcmode  in    varchar2,
                resultout out   NoCopy varchar2);

        PROCEDURE ATP_Satisfy(
                itemtype  in    varchar2,
                itemkey   in    varchar2,
                actid     in    number,
                funcmode  in    varchar2,
                resultout out   NoCopy varchar2);


        PROCEDURE start_mscatp_wf(
                p_itemkey               IN      VARCHAR2,
                p_inventory_item_id     IN      NUMBER,
                p_inventory_item_name   IN      VARCHAR2,
                p_plan_id               IN      NUMBER,
                p_organization_id       IN      NUMBER,
                p_organization_code     IN      VARCHAR2,
                p_instance_id           IN      NUMBER,
                p_demand_class          IN      VARCHAR2,
                p_requested_qty         IN      NUMBER,
                p_request_date          IN      DATE,
                p_request_date_qty      IN      NUMBER,
                p_available_qty         IN      NUMBER,
                p_available_date        IN      DATE,
                p_customer_id           IN      NUMBER,
                p_customer_site_id      IN      NUMBER,
                p_order_number          IN      NUMBER,
                p_line_number           IN      NUMBER);


END MSC_WF_ALLOC_ATP;
 

/
