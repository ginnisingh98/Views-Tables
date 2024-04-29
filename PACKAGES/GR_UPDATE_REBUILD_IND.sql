--------------------------------------------------------
--  DDL for Package GR_UPDATE_REBUILD_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_UPDATE_REBUILD_IND" AUTHID CURRENT_USER AS
/*$Header: GRPRBLDS.pls 115.1 2002/10/29 16:03:43 gkelly noship $*/

/*	Alphanumeric Global Variables */

G_PKG_NAME			CONSTANT VARCHAR2(255) := 'GR_UPDATE_REBUILD_IND';
G_CURRENT_DATE		DATE := sysdate;

/*	Numeric Global Variables */
G_USER_ID			NUMBER;

/*
**		p_update_action determines how the rebuild flag is updated:
**
**		1 - Update all documents for all items
**		2 - Update all Items for a Range of Documents
**		3 - Update all Documents for a Range of Items
**		4 - Update items using a specified document code
**		5 - Update documents using a specified item code
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
				 x_msg_data OUT NOCOPY VARCHAR2);
/*
**	Standard routine to handle error messages
*/
   PROCEDURE Handle_Error_Messages
				(p_called_by_form IN VARCHAR2,
				 p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);

END GR_UPDATE_REBUILD_IND;

 

/
