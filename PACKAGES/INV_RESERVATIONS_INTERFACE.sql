--------------------------------------------------------
--  DDL for Package INV_RESERVATIONS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATIONS_INTERFACE" AUTHID CURRENT_USER as
/* $Header: INVRSV5S.pls 120.0 2005/05/25 06:29:29 appldev noship $ */
/*#
 * This package contains programs to process reservation
 * requests residing in MTL_RESERVATIONS_INTERFACE table.
 * @rep:scope public
 * @rep:product INV
 * @rep:displayname Material Reservation Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY INV_RESERVATION
 */
/*
** ===========================================================================
** Procedure:
**	rsv_interface_manager
**
** Description:
** 	rsv interface manager processes reservations requests in
** background.
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
**	rsv interface manager thru another program, rsv
** batch processor, processes records from MTL_RESERVATIONS_INTERFACE table
** into MTL_RESERVATIONS table, one or more reservation batch id(s) at a time.
** A reservation batch id consists of one or more reservations processing
** requests in MTL_RESERVATIONS_INTERFACE table. Processing includes data
** validation, executions of appropriate reservation APIs, thereby writing
** into MTL_RESERVATIONS table and finally deleting successfuly processed
** records from MTL_RESERVATIONS_INTERFACE table.
**
** Input Parameters:
**	p_api_version_number
**		 parameter to compare API version
**      p_init_msg_lst
**		flag indicating if message list should be initialized
**
**      p_form_mode
**		'Y','y' - called from form;
**              'N','n' - not called from form;
**
** Output Parameters:
**     	x_errbuf
**		mandatory concurrent program parameter
** 	x_retcode
**		mandatory concurrent program parameter
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read and Update.
** ===========================================================================
*/
/*#
 * rsv interface manager processes reservations requests in the background. rsv interface manager through another program, rsv
 * batch processor, processes records from MTL_RESERVATIONS_INTERFACE table into MTL_RESERVATIONS table
 * @param x_errbuf mandatory concurrent program parameter. Contains the error message from the error stack.
 * @param x_retcode mandatory concurrent program parameter. Returns the error code; 0-Success, 1-Warning, 2-Error.
 * @param p_api_version_number  API version number (current version is 1.0)
 * @param p_init_msg_lst Whether initialize the error message list or not. Should be fnd_api.g_false or fnd_api.g_true
 * @param p_form_mode Indicates whether this program is called from the form or not. 'Y' is from the form & 'N is not through the form
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Reservation Interface Manger
 */
PROCEDURE rsv_interface_manager(
  x_errbuf             OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_api_version_number IN  NUMBER   DEFAULT 1.0
, p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_form_mode          IN  VARCHAR2 DEFAULT 'N');

/*
** ===========================================================================
** Procedure:
**	rsv_interface_batch_processor
**
** Description:
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
**	rsv interface batch processor, processes records from
** MTL_RESERVATIONS_INTERFACE table into MTL_RESERVATIONS table, one or more
** reservation batch id(s) at a time. A reservation batch id consists of one
** or more reservations processing requests in MTL_RESERVATIONS_INTERFACE table.
** A reservations request in MTL_RESERVATIONS_INTERFACE table is uniquely
** determined by a reservations interface id.
**	rsv interface batch processor in turn calls another program,
** rsv interface line processor repetitively, passing each time a
** reservations interafce id under the current reservations batch id.
** reservations interface line processor performs the actual reservations
** processing.
** 	rsv interface batch processor deletes successfully processed
** rows from MTL_RESERVATIONS_INTERFACE table.
**
** Input Parameters:
**  	p_api_version_number
**		parameter to compare API version
** 	p_init_msg_lst
**		flag indicating if message list should be initialized
**	p_reservation_batches
**        	reservation batch ids stringed together and separated by
**              delimiter.Eg: 163:716:987:
**      p_process_mode
**		1 = Online 2 = Concurrent 3 = Background
**      p_partial_batch_processing_flag
**		1 - If a line in reservation batch fails, continue
**		2 - If a line in reservation batch fails, exit
**      p_commit_flag
** 		'Y','y'      - Commit
**              not('Y','y') - Do not commit
**
**      p_form_mode
**		'Y','y' - called from form;
**              'N','n' - not called from form;
**
** Output Parameters:
** 	x_return_status
**		return status indicating success, error, unexpected error
** 	x_msg_count
**		number of messages in message list
** 	x_msg_data
**		if the number of messages in message list is 1, contains
**		message text.
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read, Update and Delete.
** ===========================================================================
*/

PROCEDURE rsv_interface_batch_processor (
  p_api_version_number          IN  NUMBER
, p_init_msg_lst                IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_reservation_batches	        IN  VARCHAR2
, p_process_mode		IN  NUMBER   DEFAULT 1
, p_partial_batch_process_flag  IN  NUMBER   DEFAULT 1
, p_commit_flag			IN  VARCHAR2 DEFAULT 'Y'
, p_form_mode                   IN  VARCHAR2 DEFAULT 'N'
, x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2);

/*
** ===========================================================================
** Procedure:
**	rsv_interface_line_processor
**
** Description:
** 	Applications in need of reservations processing such as
** Create Reservations, Update Reservations, Delete Reservations and
** Transfer Reservations can write their specific requests with details such
** as item, organization, demand, supply, inventory controls and quantity
** information into MTL_RESERVATIONS_INTERFACE table.
** 	rsv interface line processor processes the reservations
** request line in MTL_RESERVATIONS_INTERFACE, pointed by a given
** reservations interface id. Processing includes data validation and
** performing the requested reservation function by executing the appropriate
** reservations API.
**
** Input Parameters:
**  	p_api_version_number
**		parameter to compare API version
** 	p_init_msg_lst
**		flag indicating if message list should be initialized
**	p_reservation interface id
**		identifies reservations request line in
**		MTL_RESERVATIONS_INTERFACE table.
**      p_form_mode
**		'Y','y' - called from form;
**              'N','n' - not called from form;
**
** Output Parameters:
**	x_error_code
**		error code
** 	x_error_text
**		error explanation text
** 	x_return_status
**		return status indicating success, error, unexpected error
** 	x_msg_count
**		number of messages in message list
** 	x_msg_data
**		if the number of messages in message list is 1, contains
**		message text
**
** Tables Used:
** 	MTL_RESERVATIONS_INTERFACE for Read and Update.
** ===========================================================================
*/

PROCEDURE rsv_interface_line_processor (
  p_api_version_number        IN  NUMBER
, p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
, p_reservation_interface_id  IN  NUMBER
, p_form_mode                 IN  VARCHAR2 DEFAULT 'N'
, x_error_code		      OUT NOCOPY NUMBER
, x_error_text                OUT NOCOPY VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2);

/*
** ===========================================================================
** Procedure:
**	print_error
**
** Description:
** 	Writes message text in log files.
**
** Input Parameters:
**	p_msg_count
**
** Output Parameters:
**	None
**
** Tables Used:
** 	None
**
** ===========================================================================
*/

PROCEDURE print_error(p_msg_count IN NUMBER);

END INV_RESERVATIONS_INTERFACE;

 

/
