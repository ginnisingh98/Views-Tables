--------------------------------------------------------
--  DDL for Package EAM_SRAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SRAPPROVAL_PVT" AUTHID CURRENT_USER AS
/*$Header: EAMVSRAS.pls 120.1 2005/06/21 15:59:20 appldev ship $ */


FUNCTION Service_Request_Created
	(
	p_subscription_guid	in	raw,
	p_event			in out NOCOPY wf_event_t
	) return varchar2;

FUNCTION Service_Request_Updated
	(
	p_subscription_guid	in	raw,
	p_event			in out NOCOPY wf_event_t
	) return varchar2;

Function return_department_id
    (
        p_maintenance_org_id in number, -- OPTIONAL, null can be passed
	p_inventory_item_id in number, -- OPTIONAL, null can be passed
        p_customer_product_id in number -- OPTIONAL, null can be passed
    )    return number;

END EAM_SRAPPROVAL_PVT;



 

/
