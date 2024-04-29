--------------------------------------------------------
--  DDL for Package PA_CAPITAL_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CAPITAL_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PACACCBS.pls 115.3 2003/08/18 12:51:10 ajdas noship $ */


PROCEDURE CREATE_PERIODIC_EVENTS
   (errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_event_period_name     IN  VARCHAR2,
    p_asset_date_through_arg    IN  VARCHAR2,
    p_ei_date_through_arg       IN  VARCHAR2 DEFAULT NULL,
    p_project_id 	    IN	NUMBER DEFAULT NULL);


PROCEDURE CREATE_EVENT_FOR_PROJECT
	(errbuf                      OUT NOCOPY VARCHAR2,
    retcode                      OUT NOCOPY VARCHAR2,
    p_event_period_name       IN      VARCHAR2,
    p_asset_date_through      IN      DATE,
    p_ei_date_through         IN      DATE,
    p_project_id 	          IN      NUMBER,
    p_event_type              IN      VARCHAR2,
    p_project_number          IN      VARCHAR2,
    p_asset_allocation_method IN      VARCHAR2);


PROCEDURE ATTACH_ASSETS
	(p_project_id 	        IN	    NUMBER,
    p_capital_event_id      IN	    NUMBER,
    p_book_type_code        IN      VARCHAR2 DEFAULT NULL,
    p_asset_name            IN      VARCHAR2 DEFAULT NULL,
    p_asset_category_id     IN      NUMBER DEFAULT NULL,
    p_location_id           IN      NUMBER DEFAULT NULL,
    p_asset_date_from       IN      DATE DEFAULT NULL,
    p_asset_date_to         IN      DATE DEFAULT NULL,
    p_task_number_from      IN      VARCHAR2 DEFAULT NULL,
    p_task_number_to        IN      VARCHAR2 DEFAULT NULL,
    p_ret_target_asset_id   IN      NUMBER DEFAULT NULL,
    x_assets_attached_count    OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2);


PROCEDURE ATTACH_COSTS
	(p_project_id 	        IN	    NUMBER,
    p_capital_event_id      IN	    NUMBER,
    p_task_number_from      IN      VARCHAR2 DEFAULT NULL,
    p_task_number_to        IN      VARCHAR2 DEFAULT NULL,
    p_ei_date_from          IN      DATE DEFAULT NULL,
    p_ei_date_to            IN      DATE DEFAULT NULL,
    p_expenditure_type      IN      VARCHAR2 DEFAULT NULL,
    p_transaction_source    IN      VARCHAR2 DEFAULT NULL,
    x_costs_attached_count     OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2);


END PA_CAPITAL_EVENTS_PVT;

 

/
