--------------------------------------------------------
--  DDL for Package FTE_TRACKING_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TRACKING_WRAPPER" AUTHID CURRENT_USER as
/* $Header: FTETKWRS.pls 120.1 2005/06/01 21:21:13 appldev  $ */

--========================================================================
-- PROCEDURE : Insert_delete_delivery       FTE Tracking wrapper
--
-- COMMENT   : Insert the data from the header interface table to
--             wsh_delivery_leg_activities and wsh_delivery_leg_details.
--             Delete the record from the detail interface table if they are
--             repeated.
--========================================================================

PROCEDURE GET_DELIVERY_OR_CONTAINER(
                           p_transaction_id    IN  NUMBER,
                           x_exception_message OUT NOCOPY VARCHAR2,
                           x_return_status     OUT NOCOPY NUMBER,
                           x_error_token_text  OUT NOCOPY NUMBER);

PROCEDURE GET_DELIVERY_DETAILS(
                           p_transaction_id    IN  NUMBER,
                           p_carrier_id        IN  NUMBER,
                           x_exception_message OUT NOCOPY VARCHAR2,
                           x_return_status     OUT NOCOPY NUMBER,
                           x_error_token_text  OUT NOCOPY NUMBER);

PROCEDURE INSERT_ERROR_STATUS(
                           p_interface_error_id     IN      NUMBER,
                           p_interface_table_name   IN      VARCHAR2,
                           p_interface_id           IN      NUMBER,
                           p_message_code           IN      NUMBER,
                           p_message_name           IN      VARCHAR2,
                           p_error_message          IN      VARCHAR2,
                           p_carrier_id             IN      NUMBER);

PROCEDURE CALL_LAST_DELIVERY_LEG(
				p_delivery_leg_id 	IN NUMBER,
				p_received_date 	IN DATE);


PROCEDURE CALL_LAST_DELIVERY_LEG(
				p_api_version_number    IN NUMBER,
				p_init_msg_list         IN VARCHAR2,
				x_return_status         OUT NOCOPY VARCHAR2,
				x_msg_count             OUT NOCOPY NUMBER,
				x_msg_data              OUT NOCOPY VARCHAR2,
				p_delivery_leg_id 	IN NUMBER,
				p_received_date 	IN DATE);
--MDC Changes for Release 12
PROCEDURE  POPULATE_CHILD_DELIVERY_LEGS
				 (
				 p_init_msg_list          IN   VARCHAR2,
				 p_delivery_leg_id IN NUMBER,
				 p_transaction_id IN NUMBER,
				 p_carrier_id  IN NUMBER,
				 x_return_status     OUT NOCOPY VARCHAR2,
	  			 x_msg_count             OUT NOCOPY NUMBER,
				 x_msg_data              OUT NOCOPY VARCHAR2
				 );

END FTE_TRACKING_WRAPPER;

 

/
