--------------------------------------------------------
--  DDL for Package Body GR_UPDATE_REBUILD_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_UPDATE_REBUILD_IND" AS
/*$Header: GRPRBLDB.pls 120.1 2005/09/06 14:36:36 pbamb noship $*/

/*
** PROCEDURE :
** Update_Rebuild_Flag
**
** DESCRIPTION:
**   	This procedure takes the entry from p_update_action, as defined below
**	and for all occurrences of the update code in documents, marks the
**      item document combination for rebuild.
**
**      The first step is to re-explode all items where required and then,
**      based on the update action, read the tables and ultimately mark the
**      relevant item document combination for rebuild.
**
**	NOTE: If the item has a production formula specified, the program will
**            call the OPM_410_MSDS_Formula routine. This is done because the
**            11i explosion performs and app_exception if the return status is
**            not 'S' for successful. This works fine if the 11i routine is
**            called from a form, but destroys this procedure!
**
** PARAMETERS:
**              errbuf             - Error Buffer for the Concurrent program
**              retcode            - Return Status code for concurrent Program
**              p_commit           - Commit Flag
**              p_init_msg_list    - Initialisation of the Message List
**              p_validation_level - Level of Validation
**              p_api_version      - Version of the API
**              p_called_by_form   - The procedure is called by Form or not
**		p_update_action    - To determine which criteria to consider for
**                                   the rebuild flag to be updated
**
**		1 - Update all documents for all items
**		2 - Update range of documents for all item
**		3 - Update Specific documents for all item
**		4 - Update all items using a specified document code
**		5 - Update Specific items for all documents
**
**		p_update_code      - Item/Document code to control the update.
**		p_update_code1     - Item/Document code to control the update.
**		x_return_status    - Return Status for the procedure
**		x_msg_count        - Message count for the Procedure
**		x_msg_data         - Message data for the Procedure
**
** SYNOPSIS:
** Update_Rebuild_Flag(errbuf, retcode, FALSE, 'T', 'T', 99, TO_CHAR(1.0), 'T',
**                     p_update_action, p_update_code, p_update_code1,
**                     x_return_status, x_msg_count, x_msg_data);
**
** HISTORY:
** 12-JUN-2001 Mercy Thomas  BUG 1766048 Added this procedure to update
**                                       the rebuild Indicator
** 11-Feb-2003 GK Bug 2190522 Made changes to the section update action = 4
**	and also I am only checking for items exploding for all
**	other update actions except 4.
*/

PROCEDURE Update_Rebuild_Flag
				(errbuf OUT NOCOPY VARCHAR2,
                                 retcode OUT NOCOPY VARCHAR2,
                                 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_called_by_form IN VARCHAR2,
				 p_update_action IN NUMBER,
				 p_update_code IN VARCHAR2,
				 p_update_code1 IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Update_Rebuild_Flag;

/*
** PROCEDURE :
** Handle_Error_Messages
**
** DESCRIPTION:
**		This procedure is called from the EXCEPTION handlers
**		in other procedures. It is passed the message code,
**		token name and token value.
**
**		The procedure will then process the error message into
**		the message stack and then return to the calling routine.
**		The procedure assumes all messages used are in the
**		application id 'GR'.
**
** PARAMETERS:
**              p_called_by_form   - The procedure is called from a Form or not
**              p_message_code     - Message Code
**              p_token_name       - Name of the Token
**		p_token_value      - Token Value
**		x_msg_count        - Message count for the Procedure
**		x_msg_data         - Message data for the Procedure
**		x_return_status    - Return Status for the procedure
**
** SYNOPSIS:
** Handle_Error_Messages('T', p_message_code, p_token_name, p_token_value,
**                       x_msg_count, x_msg_data, x_return_status);
**
** HISTORY:
** 12-JUN-2001 Mercy Thomas  BUG 1766048 Added this procedure to update
**                                       the rebuild Indicator
**
**
*/

PROCEDURE Handle_Error_Messages
				(p_called_by_form IN VARCHAR2,
				 p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Handle_Error_Messages;


/*
**  The procedure checks to see if the item code is used
**  in another item, either as an ingredient or as an intermediate.
**
**  The next stage is to check for and update any generic items.
*/

PROCEDURE Get_Item_Usage
                   (p_commit IN VARCHAR2,
				    p_called_by_form IN VARCHAR2,
					p_item_code IN VARCHAR2,
					p_document_code IN VARCHAR2,
				    x_msg_data OUT NOCOPY VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END Get_Item_Usage;

END GR_UPDATE_REBUILD_IND;

/
