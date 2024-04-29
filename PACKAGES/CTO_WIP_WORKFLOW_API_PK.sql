--------------------------------------------------------
--  DDL for Package CTO_WIP_WORKFLOW_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_WIP_WORKFLOW_API_PK" AUTHID CURRENT_USER as
/* $Header: CTOWIPAS.pls 120.1 2005/06/02 13:46:58 appldev  $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWIPAS.pls                                                  |
|                                                                             |
| DESCRIPTION:                                                                |
|               Three APIs are written for WIP support for OE-99 from         |
|               the CTO group.                                                |
|               first_reservation_created - inform the order line workflow    |
|               thaT the first reservation has been created for this sales    |
|               order line.                                                   |
|               last_reservation_deleted - inform the order line workflow that|
|               the last reservation has been deleted for this sales order    |
|               line.                                                         |
|               workflow_build_status - to determine if a particular          |
|               sales order line is at the released phase of the workflow.    |
|                                                                             |
|                                                                             |
| HISTORY     :                                                               |
|               July 22, 99  James Chiu   Initial version                     |
|               12/18/2000   Added by Renga two pkg variables                 |
|                            are added to generate CTO debug messages         |
|                            One CTO_DEBUG Utility procedure is added         |
|               06/01/2005   Renga Kannan
|                            Added NoCopy Hint
=============================================================================*/

/**************************************************************************

   Procedure:   first_wo_reservation_created
   Parameters:	order_line_id		- order_line_id
		x_return_status		- standard API output parameter
		x_msg_count		-           "
		x_msg_data		- 	    "
   Description: This callback is used to inform the order line workflow that
		the first reservation has been created for this sales order
		line.

*****************************************************************************/

PROCEDURE first_wo_reservation_created(
	order_line_id	IN		NUMBER,
	x_return_status	OUT  NOCOPY	VARCHAR2,
	x_msg_count	OUT  NOCOPY	NUMBER,
	x_msg_data	OUT  NOCOPY	VARCHAR2
	);


/**************************************************************************

   Procedure: 	last_wo_reservation_deleted
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the last reservation has been deleted for this sales order
                line.

*****************************************************************************/

PROCEDURE last_wo_reservation_deleted(
	order_line_id   IN             NUMBER,
        x_return_status OUT  NOCOPY    VARCHAR2,
        x_msg_count     OUT  NOCOPY    NUMBER,
        x_msg_data      OUT  NOCOPY    VARCHAR2
        );


/**************************************************************************

   Procedure:   flow_creation
   Parameters:	order_line_id		- order_line_id
		x_return_status		- standard API output parameter
		x_msg_count		-           "
		x_msg_data		- 	    "
   Description: This callback is used to inform the order line workflow that
		the first flow schedule has been created for this sales order
		line.

*****************************************************************************/

PROCEDURE flow_creation(
	order_line_id	IN	   NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2
	);


/**************************************************************************

   Procedure:   flow_deletion
   Parameters:  order_line_id           - order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "
   Description: This callback is used to inform the order line workflow that
                the last flow schedule has been deleted for this sales order
                line.

*****************************************************************************/

PROCEDURE flow_deletion(
	order_line_id   IN         NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2
        );

/**************************************************************************

   Procedure:   query_wf_activity_status
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_label          -           "
                p_activity_name           -           "
                p_activity_status         -
   Description: this procedure is used to query a Workflow activity status

*****************************************************************************/

PROCEDURE query_wf_activity_status(
        p_itemtype        IN         VARCHAR2,
        p_itemkey         IN         VARCHAR2,
        p_activity_label  IN         VARCHAR2,
        p_activity_name   IN         VARCHAR2,
        p_activity_status OUT NOCOPY VARCHAR2
        );



/**************************************************************************

   Function:   	workflow_build_status
   Parameters:  order_line_id           - order_line_id
   Description: to determine if a particular          |
                sales order line is at the released phase of the workflow.
		This function returns TRUE/FALSE.

*****************************************************************************/

FUNCTION workflow_build_status(
	order_line_id	IN 	NUMBER)
return INTEGER;

PRAGMA RESTRICT_REFERENCES (query_wf_activity_status, WNDS);
PRAGMA RESTRICT_REFERENCES (workflow_build_status, WNDS);

-- Added by Renga Kannan on 12/18/2000 added two package varibales which is used by CTO_DEBUG procedure

File_dir         varchar2(200);
File_name        varchar2(200);

-- bugfix 2430063 : added global variable to check for debug level
gDebugLevel	 number :=  to_number(nvl(FND_PROFILE.value('ONT_DEBUG_LEVEL'),0));


/******************************************************************************

       Procedure  : CTO_DEBUG
       Parameters : proc_name      ---   Name of the procedure which is calling this utility
                    Text           ---   Debug message which needs to be written to the log file


       Description :   This utility will write the message into the CTO Debug file


*********************************************************************************/

PROCEDURE   CTO_DEBUG(
                        proc_name   IN   VARCHAR2,
                        text        IN   VARCHAR2);


END CTO_WIP_WORKFLOW_API_PK;

 

/
