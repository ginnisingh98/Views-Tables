--------------------------------------------------------
--  DDL for Package WSH_ITM_EXPORT_SCREENING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_EXPORT_SCREENING" AUTHID CURRENT_USER AS
/* $Header: WSHITESS.pls 120.1 2005/07/14 04:37:36 shravisa noship $ */


PROCEDURE SCREEN_DELIVERIES (errbuf                         OUT NOCOPY   VARCHAR2,
			 retcode            		OUT NOCOPY   NUMBER,
			 p_organization_id	        IN           NUMBER,
			 p_delivery_from_id       	IN           NUMBER,
			 p_delivery_to_id      		IN           NUMBER,
			 p_ship_method_code             IN           VARCHAR2,
			 p_pickup_date_from             IN           VARCHAR2,
			 p_pickup_date_to               IN           VARCHAR2
			);

--Added for Release 12 by shravisa

PROCEDURE  RAISE_ITM_EVENT(
			p_event_name IN VARCHAR2,
			p_delivery_id IN NUMBER,
			p_organization_id IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2
			);

PROCEDURE  SCREEN_EVENT_DELIVERIES (
			x_return_status                 OUT NOCOPY   VARCHAR2,
			p_organization_id               IN           NUMBER,
			p_delivery_from_id              IN           NUMBER,
			p_delivery_to_id                IN           NUMBER,
			p_event_name                    IN           VARCHAR2,
			p_ship_method_code              IN           VARCHAR2,
			p_pickup_date_from              IN           VARCHAR2,
			p_pickup_date_to                IN           VARCHAR2
			);




END;

 

/
