--------------------------------------------------------
--  DDL for Package WSH_AUTO_MANIFEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_AUTO_MANIFEST" AUTHID CURRENT_USER as
/* $Header: WSHAUMNS.pls 120.1.12010000.3 2009/12/03 14:32:06 anvarshn ship $ */

c_sdebug    CONSTANT NUMBER := wsh_debug_sv.c_level1;
c_debug     CONSTANT NUMBER := wsh_debug_sv.c_level2;

TYPE delivery_msg_rec is RECORD
                (delivery_name   VARCHAR2(30),
                 msg_summary     VARCHAR2(4000),
                 msg_details     VARCHAR2(4000));

TYPE tab_delivery_msg IS TABLE OF delivery_msg_rec INDEX BY BINARY_INTEGER;

--k proj
TYPE t_shipment_rec is RECORD
                (organization_id   NUMBER,
                delivery_id   NUMBER,
                carrier_id   NUMBER,
                customer_id   NUMBER,
                ultimate_dropoff_location_id   NUMBER
                 );



--
-- PROCEDURE:         Submit
-- Purpose:           Submit Automated Carrier Manifesting based on given criteria.
-- Description:       This procedure  is called by Concurrent Program to submit request for Automated
--                    Carrier Manifesting. This works as a wrapper to the main procedure
--                    Process_Auto_Manifest for Automated  Carrier Manifesting.
--
PROCEDURE Submit (
	errbuf	        	OUT NOCOPY      VARCHAR2,
	retcode 		OUT NOCOPY      VARCHAR2,
        --R12.1.1 STANDALONE PROJECT
        -- p_standalone_mode is a parameter defined in concurrent program  and it is
        -- not used anywhere in code.
        p_standalone_mode       IN      VARCHAR2,
        -- K proj
        p_doctype               IN      VARCHAR2,
        p_shipment_type         IN      VARCHAR2,
        p_deploy_mode           IN      VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
        p_set_org               IN      NUMBER,
        p_client_id             IN      NUMBER, -- Modified R12.1.1 LSP PROJECT(rminocha)
        p_organization_id	IN	NUMBER,
        -- K proj
        p_src_header_num_from   IN      VARCHAR2,
        p_src_header_num_to     IN      VARCHAR2,
        --R12.1.1 STANDALONE PROJECT
        p_del_name_from         IN      VARCHAR2,
        p_del_name_to           IN      VARCHAR2,
	p_carrier_id		IN	NUMBER,
	p_customer_id		IN	NUMBER,
	p_customer_ship_to_id	IN	NUMBER,
	p_scheduled_from_date	IN	VARCHAR2,
	p_scheduled_to_date	IN	VARCHAR2,
        p_set_auto_pack         IN      NUMBER,
	p_autopack		IN	VARCHAR2,
        p_log_level             IN      NUMBER);


--
-- PROCEDURE  : Process_Auto_Manifest
-- Description: This is the main procedure for Automated  Carrier Manifesting System,
--              which is called by procedure submit.
--
PROCEDURE Process_Auto_Manifest (
        p_organization_id       IN      NUMBER,
        p_carrier_id            IN      NUMBER,
        p_customer_id           IN      NUMBER,
        p_customer_ship_to_id   IN      NUMBER,
        p_scheduled_from_date   IN      DATE,
        p_scheduled_to_date     IN      DATE,
        p_autopack              IN      VARCHAR2 DEFAULT 'N',
        p_log_level             IN      NUMBER DEFAULT 0,
	x_return_status		OUT NOCOPY 	VARCHAR2,
        p_shipment_type         IN      VARCHAR2,
        p_doctype               IN      VARCHAR2,
        p_src_header_num_from   IN      VARCHAR2,
        p_src_header_num_to     IN      VARCHAR2,
       --R12.1.1 STANDALONE PROJECT
        p_del_name_from         IN      VARCHAR2,
        p_del_name_to           IN      VARCHAR2,
        p_client_id             IN      NUMBER -- Modified R12.1.1 LSP PROJECT
        );

--
-- PROCEDURE  : Lock_Manifest_Delivery
-- Description: This procedure lock the delivery and its assigned lines
--
PROCEDURE Lock_Manifest_Delivery(
  p_delivery_id         IN      NUMBER,
  x_return_status       OUT NOCOPY      VARCHAR2);


--
-- PROCEDURE  : Validate_Scheduled_Ship_Date
-- Description: This procedure check if scheduled_date of lines assign to delivery fall in the range
--              of input scheduled_ship_dates
--
PROCEDURE Validate_Scheduled_Ship_Date(
	p_delivery_id           IN      NUMBER,
        p_scheduled_from_date   IN      DATE,
        p_scheduled_to_date     IN      DATE,
        x_validate		OUT NOCOPY 	VARCHAR2,
	x_return_status		OUT NOCOPY 	VARCHAR2);

FUNCTION set_auto_pack (
       p_doc_type    IN VARCHAR2,
       p_shipment_type IN VARCHAR2
      ) RETURN NUMBER;


END WSH_AUTO_MANIFEST;

/
