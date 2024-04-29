--------------------------------------------------------
--  DDL for Package RLM_MESSAGE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_MESSAGE_SV" AUTHID CURRENT_USER as
/* $Header: RLMCOMSS.pls 120.2.12000000.2 2007/09/03 13:50:07 sunilku ship $ */
/*===========================================================================
  PACKAGE NAME:		rlm_message_sv

  DESCRIPTION:		Contains the exception handling apis required for
			Oracle Release Management.

  CLIENT/SERVER:	Server

  LIBRARY NAME:		None

  OWNER:		amitra

  PROCEDURE/FUNCTIONS:	app_error
			get_msg_text
			insert_row
			sql_error
                        processing_error
                        get

  GLOBALS:		g_warn
			g_error

===========================================================================*/

g_fatal_error_flag  VARCHAR2(30) := 'N';

TYPE  t_message_rec IS RECORD (
   exception_level VARCHAR2(100),
   message_name VARCHAR2(30000),
   child_message_name VARCHAR2(30),
   error_text VARCHAR2(30000),
   interface_header_id  NUMBER,
   interface_line_id  NUMBER,
   schedule_header_id  NUMBER,
   schedule_line_id  NUMBER ,
   order_header_id  NUMBER,
   order_line_id  NUMBER,
   group_Info     BOOLEAN,
   ship_from_org_id    NUMBER,
   ship_to_address_id  NUMBER,
   customer_item_id    NUMBER,
   inventory_item_id   NUMBER, /* bug 4091219 */
   schedule_line_number NUMBER); --bugfix 6319027

TYPE  t_PurExp_rec IS RECORD (

 ECE_TP_TRANSLATOR_CODE                   VARCHAR2(35),
 SCHEDULE_REFERENCE_NUM                   VARCHAR2(35),
 SCHEDULE_TYPE                            VARCHAR2(30),
 SCHED_GENERATION_DATE                    DATE,
 ORIGIN_TABLE                             VARCHAR2(10) /*2261812*/
);


TYPE  t_exception_rec IS RECORD (
 CUST_NAME_EXT                            VARCHAR2(360),
 --CUST_SHIP_TO_EXT                         VARCHAR2(35),
 --CUST_BILL_TO_EXT                         VARCHAR2(35),
 --CUST_INTERMD_SHIPTO_EXT                  VARCHAR2(35),
 ECE_TP_TRANSLATOR_CODE                   VARCHAR2(35),
 ECE_TP_LOCATION_CODE_EXT                 VARCHAR2(35),
 EDI_CONTROL_NUM_3                        VARCHAR2(15),
 EDI_TEST_INDICATOR                       VARCHAR2(1),
 SCHED_GENERATION_DATE                    DATE,
 SCHEDULE_REFERENCE_NUM                   VARCHAR2(35),
 SCHEDULE_SOURCE                          VARCHAR2(30),
 SCHEDULE_TYPE                            VARCHAR2(30),
 SCHEDULE_PURPOSE                         VARCHAR2(30),
 HORIZON_START_DATE                       DATE,
 HORIZON_END_DATE                         DATE,
 CUST_SHIP_FROM_ORG_EXT                   VARCHAR2(80),
 SCHEDULE_LINE_NUMBER                     NUMBER,
 SCHEDULE_ITEM_NUM                        NUMBER,
 CUSTOMER_ITEM_EXT                        VARCHAR2(50),
 CUST_ITEM_DESCRIPTION                    VARCHAR2(80),
 CUST_UOM_EXT                             VARCHAR2(10),
 INVENTORY_ITEM                           VARCHAR2(50),
 ITEM_DETAIL_TYPE                         VARCHAR2(30),
 ITEM_DETAIL_SUBTYPE                      VARCHAR2(30),
 ITEM_DETAIL_QUANTITY                     NUMBER,
 START_DATE_TIME                          DATE,
 CUST_JOB_NUMBER                          VARCHAR2(50),
 CUST_MODEL_SERIAL_NUM                    VARCHAR2(35),
 CUSTOMER_PROD_SEQ_NUM                    VARCHAR2(35),
 DATE_TYPE_CODE                           VARCHAR2(30),
 QTY_TYPE_CODE                            VARCHAR2(30),
 LINE_NUMBER				  NUMBER,
 REQUEST_DATE				  DATE,
 SCHEDULE_DATE				  DATE,
 CUST_PO_NUMBER				  VARCHAR2(50),
 INDUSTRY_ATTRIBUTE1			  VARCHAR2(150),
 CUST_PRODUCTION_LINE			  VARCHAR2(50),
 CUSTOMER_DOCK_CODE			  VARCHAR2(50),
 SCHEDULE_LINE_ID			  NUMBER
 );


g_info 	   VARCHAR2(2)  := 'I';
g_warn 	   VARCHAR2(2)  := 'W';
g_error    VARCHAR2(2)  := 'E';
g_routine  VARCHAR2(2000) := NULL;
g_location VARCHAR2(3)   := NULL;

-- Constants to be passed in to the app_error
k_error_level  VARCHAR2(10) := 'E';
k_warn_level  VARCHAR2(10) := 'W';
k_info_level  VARCHAR2(10) := 'I';
/*===========================================================================
  PROCEDURE NAME:	app_error

  DESCRIPTION:   	This procedure is called by server side apis to
			process error conditions. It extracts the error
			message, replaces tokens if any and inserts the
			error into the rlm_demand_exceptions table.

  PARAMETERS:		x_ExceptionLevel      IN  VARCHAR2 DEFAULT 'E'
			x_MessageName         IN  VARCHAR2 DEFAULT NULL
			x_ChildMessageName    IN  VARCHAR2 DEFAULT NULL
			x_InterfaceHeaderId   IN  NUMBER   DEFAULT NULL
			x_InterfaceLineId     IN  NUMBER   DEFAULT NULL
			x_ScheduleHeaderId    IN  NUMBER   DEFAULT NULL
			x_ScheduleLineId      IN  NUMBER   DEFAULT NULL
			x_OrderHeaderId       IN  NUMBER   DEFAULT NULL
			x_OrderLineId         IN  NUMBER   DEFAULT NULL
			x_ErrorText           IN  VARCHAR2 DEFAULT NULL
			x_ValidationType      IN  VARCHAR2 DEFAULT NULL
			x_GroupInfo	      IN  BOOLEAN  DEFAULT FALSE

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Abhijit Mitra	Created		8/11/98
                        Mohana Narayan  Modified       10/14/99
===========================================================================*/

PROCEDURE app_error (x_ExceptionLevel      IN  VARCHAR2 DEFAULT 'E',
                     x_MessageName         IN  VARCHAR2 DEFAULT NULL,
                     x_ChildMessageName    IN  VARCHAR2 DEFAULT NULL,
                     x_InterfaceHeaderId   IN  NUMBER DEFAULT NULL,
                     x_InterfaceLineId     IN  NUMBER DEFAULT NULL,
                     x_ScheduleHeaderId    IN  NUMBER DEFAULT NULL,
                     x_ScheduleLineId      IN  NUMBER DEFAULT NULL,
                     x_OrderHeaderId       IN  NUMBER DEFAULT NULL,
                     x_OrderLineId         IN  NUMBER DEFAULT NULL,
                     x_ErrorText           IN  VARCHAR2 DEFAULT NULL,
                     x_ValidationType      IN  VARCHAR2 DEFAULT NULL,
		     x_GroupInfo	   IN  BOOLEAN DEFAULT FALSE,
                     -- bug 4198330
                     x_ShipfromOrgId       IN  NUMBER DEFAULT NULL,
                     x_ShipToAddressId     IN  NUMBER DEFAULT NULL,
                     x_CustomerItemId      IN  NUMBER DEFAULT NULL,
                     x_InventoryItemId     IN  NUMBER DEFAULT NULL,
                     x_token1      IN  VARCHAR2 DEFAULT NULL,
                     x_value1      IN  VARCHAR2 DEFAULT NULL,
                     x_token2      IN  VARCHAR2 DEFAULT NULL,
                     x_value2      IN  VARCHAR2 DEFAULT NULL,
                     x_token3      IN  VARCHAR2 DEFAULT NULL,
                     x_value3      IN  VARCHAR2 DEFAULT NULL,
                     x_token4      IN  VARCHAR2 DEFAULT NULL,
                     x_value4      IN  VARCHAR2 DEFAULT NULL,
                     x_token5      IN  VARCHAR2 DEFAULT NULL,
                     x_value5      IN  VARCHAR2 DEFAULT NULL,
                     x_token6      IN  VARCHAR2 DEFAULT NULL,
                     x_value6      IN  VARCHAR2 DEFAULT NULL,
                     x_token7      IN  VARCHAR2 DEFAULT NULL, -- Bug 4297984
                     x_value7      IN  VARCHAR2 DEFAULT NULL,
                     x_token8      IN  VARCHAR2 DEFAULT NULL,
                     x_value8      IN  VARCHAR2 DEFAULT NULL,
                     x_token9      IN  VARCHAR2 DEFAULT NULL,
                     x_value9      IN  VARCHAR2 DEFAULT NULL,
                     x_token10     IN  VARCHAR2 DEFAULT NULL,
                     x_value10     IN  VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME:	app_purge_error

  DESCRIPTION:   	This procedure is called by Purge Schedule
                        Concurrrent Program to  process error conditions.
                        It extracts the error
			message, replaces tokens if any and inserts the
			error into the rlm_demand_exceptions table.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ajit Sutar 11/15/2000
===========================================================================*/



PROCEDURE app_purge_error (x_ExceptionLevel      IN  VARCHAR2 DEFAULT 'E',
		     x_MessageName         IN  VARCHAR2 DEFAULT NULL,
		     x_ErrorText           IN  VARCHAR2 DEFAULT NULL,
                     x_ChildMessageName    IN  VARCHAR2 DEFAULT NULL,
		     x_InterfaceHeaderId   IN  NUMBER DEFAULT NULL,
		     x_InterfaceLineId	   IN  NUMBER DEFAULT NULL,
		     x_ScheduleHeaderId	   IN  NUMBER DEFAULT NULL,
		     x_ScheduleLineId	   IN  NUMBER DEFAULT NULL,
		     x_OrderHeaderId	   IN  NUMBER DEFAULT NULL,
		     x_OrderLineId	   IN  NUMBER DEFAULT NULL,
                     x_ScheduleLineNum     IN  NUMBER DEFAULT NULL, --bugfix 6319027
		     x_ValidationType      IN  VARCHAR2 DEFAULT NULL,
                     x_token1      IN  VARCHAR2 DEFAULT NULL,
                     x_value1      IN  VARCHAR2 DEFAULT NULL,
                     x_token2      IN  VARCHAR2 DEFAULT NULL,
                     x_value2      IN  VARCHAR2 DEFAULT NULL,
                     x_token3      IN  VARCHAR2 DEFAULT NULL,
                     x_value3      IN  VARCHAR2 DEFAULT NULL,
                     x_token4      IN  VARCHAR2 DEFAULT NULL,
                     x_value4      IN  VARCHAR2 DEFAULT NULL,
                     x_token5      IN  VARCHAR2 DEFAULT NULL,
                     x_value5      IN  VARCHAR2 DEFAULT NULL,
                     x_token6      IN  VARCHAR2 DEFAULT NULL,
                     x_value6      IN  VARCHAR2 DEFAULT NULL,
                     x_token7      IN  VARCHAR2 DEFAULT NULL, -- Bug 4297984
                     x_value7      IN  VARCHAR2 DEFAULT NULL,
                     x_token8      IN  VARCHAR2 DEFAULT NULL,
                     x_value8      IN  VARCHAR2 DEFAULT NULL,
                     x_token9      IN  VARCHAR2 DEFAULT NULL,
                     x_value9      IN  VARCHAR2 DEFAULT NULL,
                     x_token10     IN  VARCHAR2 DEFAULT NULL,
                     x_value10     IN  VARCHAR2 DEFAULT NULL,
           	     x_user_id             IN  NUMBER DEFAULT NULL,
                     x_conc_req_id         IN  NUMBER DEFAULT NULL,
                     x_prog_appl_id        IN  NUMBER DEFAULT NULL,
                     x_conc_program_id     IN  NUMBER DEFAULT NULL,
                     x_PurgeStatus         IN  VARCHAR2 DEFAULT NULL,
                     x_PurgeExp_rec        IN  t_PurExp_rec DEFAULT NULL);





/*===========================================================================
  PROCEDURE NAME:	get_msg_text

  DESCRIPTION:   	This procedure provides the message text after
			performing token substitution. It can process upto
			4 tokens.

  PARAMETERS:		x_message_name  IN      VARCHAR2
			x_text	      IN OUT NOCOPY  VARCHAR2
			x_token1      IN      VARCHAR2 DEFAULT NULL
			x_value1      IN      VARCHAR2 DEFAULT NULL
			x_token2      IN      VARCHAR2 DEFAULT NULL
			x_value2      IN      VARCHAR2 DEFAULT NULL
			x_token3      IN      VARCHAR2 DEFAULT NULL
			x_value3      IN      VARCHAR2 DEFAULT NULL
			x_token4      IN      VARCHAR2 DEFAULT NULL
			x_value4      IN      VARCHAR2 DEFAULT NULL
			x_token5      IN      VARCHAR2 DEFAULT NULL
			x_value5      IN      VARCHAR2 DEFAULT NULL
			x_token6      IN      VARCHAR2 DEFAULT NULL
			x_value6      IN      VARCHAR2 DEFAULT NULL
                        x_token7      IN      VARCHAR2 DEFAULT NULL
                        x_value7      IN      VARCHAR2 DEFAULT NULL
                        x_token8      IN      VARCHAR2 DEFAULT NULL
                        x_value8      IN      VARCHAR2 DEFAULT NULL
                        x_token9      IN      VARCHAR2 DEFAULT NULL
                        x_value9      IN      VARCHAR2 DEFAULT NULL
                        x_token10     IN      VARCHAR2 DEFAULT NULL
                        x_value10     IN      VARCHAR2 DEFAULT NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		9/26/96
===========================================================================*/

PROCEDURE get_msg_text (x_message_name  IN      VARCHAR2,
			x_text	      IN OUT NOCOPY  VARCHAR2,
			x_token1      IN      VARCHAR2 DEFAULT NULL,
			x_value1      IN      VARCHAR2 DEFAULT NULL,
			x_token2      IN      VARCHAR2 DEFAULT NULL,
			x_value2      IN      VARCHAR2 DEFAULT NULL,
			x_token3      IN      VARCHAR2 DEFAULT NULL,
			x_value3      IN      VARCHAR2 DEFAULT NULL,
			x_token4      IN      VARCHAR2 DEFAULT NULL,
			x_value4      IN      VARCHAR2 DEFAULT NULL,
			x_token5      IN      VARCHAR2 DEFAULT NULL,
			x_value5      IN      VARCHAR2 DEFAULT NULL,
			x_token6      IN      VARCHAR2 DEFAULT NULL,
			x_value6      IN      VARCHAR2 DEFAULT NULL,
                        x_token7      IN      VARCHAR2 DEFAULT NULL, -- Bug 4297984
                        x_value7      IN      VARCHAR2 DEFAULT NULL,
                        x_token8      IN      VARCHAR2 DEFAULT NULL,
                        x_value8      IN      VARCHAR2 DEFAULT NULL,
                        x_token9      IN      VARCHAR2 DEFAULT NULL,
                        x_value9      IN      VARCHAR2 DEFAULT NULL,
                        x_token10     IN      VARCHAR2 DEFAULT NULL,
                        x_value10     IN      VARCHAR2 DEFAULT NULL);

/*===========================================================================
  PROCEDURE NAME:	insert_row

  DESCRIPTION:   	Inserts a record into rlm_demand_exceptions
			table.

  PARAMETERS: x_ExceptionLevel  IN  VARCHAR2
           x_MessageName           IN  VARCHAR2 DEFAULT NULL
           x_ErrorText             IN  VARCHAR2 DEFAULT NULL
           x_InterfaceHeaderId  IN  NUMBER DEFAULT NULL
           x_InterfaceLineId    IN  NUMBER DEFAULT NULL
           x_ScheduleHeaderId   IN  NUMBER DEFAULT NULL
           x_ScheduleLineId     IN  NUMBER DEFAULT NULL
           x_Order_Header_Id   IN  NUMBER DEFAULT NULL
           x_Order_Line_Id     IN  NUMBER DEFAULT NULL

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Abhijit Mitra	Created		8/11/98
===========================================================================*/

PROCEDURE insert_row (x_ExceptionLevel  IN  VARCHAR2,
           x_MessageName           IN  VARCHAR2 DEFAULT NULL,
           x_ErrorText             IN  VARCHAR2 DEFAULT NULL,
           x_InterfaceHeaderId   IN  NUMBER DEFAULT NULL,
           x_InterfaceLineId     IN  NUMBER DEFAULT NULL,
           x_ScheduleHeaderId    IN  NUMBER DEFAULT NULL,
           x_ScheduleLineId      IN  NUMBER DEFAULT NULL,
           x_OrderHeaderId       IN  NUMBER DEFAULT NULL,
           x_OrderLineId         IN  NUMBER DEFAULT NULL,
	   x_GroupInfo		 IN  BOOLEAN DEFAULT FALSE,
           x_user_id             IN  NUMBER DEFAULT NULL,
           x_conc_req_id         IN  NUMBER DEFAULT NULL,
           x_prog_appl_id        IN  NUMBER DEFAULT NULL,
           x_conc_program_id     IN  NUMBER DEFAULT NULL,
           x_PurgeStatus         IN VARCHAR2 DEFAULT NULL);


PROCEDURE insert_purge_row (x_ExceptionLevel  IN  VARCHAR2,
           x_MessageName           IN  VARCHAR2 DEFAULT NULL,
           x_ErrorText             IN  VARCHAR2 DEFAULT NULL,
           x_InterfaceHeaderId   IN  NUMBER DEFAULT NULL,
           x_InterfaceLineId     IN  NUMBER DEFAULT NULL,
           x_ScheduleHeaderId    IN  NUMBER DEFAULT NULL,
           x_ScheduleLineId      IN  NUMBER DEFAULT NULL,
           x_OrderHeaderId       IN  NUMBER DEFAULT NULL,
           x_OrderLineId         IN  NUMBER DEFAULT NULL,
           x_ScheduleLineNum     IN  NUMBER DEFAULT NULL, --bugfix 6319027
           x_user_id             IN  NUMBER DEFAULT NULL,
           x_conc_req_id         IN  NUMBER DEFAULT NULL,
           x_prog_appl_id        IN  NUMBER DEFAULT NULL,
           x_conc_program_id     IN  NUMBER DEFAULT NULL,
           x_PurgeStatus        IN  VARCHAR2 DEFAULT NULL,
           x_PurgeExp_rec         IN t_PurExp_rec DEFAULT NULL);


/*===========================================================================

/*===========================================================================
  PROCEDURE NAME:	sql_error

  DESCRIPTION:   	This procedure puts a message on the stack when
                        there is a sql error.  It is useful to trace the error
			to the sql statement causing the exception.


  PARAMETERS:		x_routine  	IN      VARCHAR2
			x_location	IN      VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		9/26/96
===========================================================================*/

PROCEDURE sql_error (x_routine    IN VARCHAR2,
		     x_location   IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	processing_error

  DESCRIPTION:   	This procedure puts a message on the stack when
			there is a fatal processing error. It is useful
                        to trace the error to the procedure/function causing
                        the failure.


  PARAMETERS:		x_routine  	IN      VARCHAR2
			x_location	IN      VARCHAR2

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		9/26/96
===========================================================================*/

PROCEDURE processing_error (x_routine    IN VARCHAR2,
		            x_location   IN VARCHAR2);


/*===========================================================================
  FUNCTION NAME:	get

  DESCRIPTION:          This function retrieves the message from the
                        stack. It should be used only if the message on
                        the stack is required to be passed to another
                        calling procedure which does not have access to
                        the AOL provided message stack.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Ramana Mulpury	Created		9/26/96
===========================================================================*/

FUNCTION get RETURN VARCHAR2;
--
fatal_error_flag VARCHAR2(1);
--
g_info_flag VARCHAR2(1);
--
g_warn_flag VARCHAR2(1);
--
g_error_flag VARCHAR2(1);
--
---------------------------------------------------------------------------
-- DEPENDENCY CHECKS
---------------------------------------------------------------------------
g_message_rec t_message_rec;

TYPE message_tab_type IS TABLE OF g_message_rec%TYPE
                                  INDEX BY BINARY_INTEGER;

g_message_tab message_tab_type;
TYPE dep_rec_type IS RECORD
     (val_name VARCHAR2(30),
      dep_name VARCHAR2(30),
      error_flag VARCHAR2(1));

TYPE dep_tab_type IS TABLE of dep_rec_type INDEX BY BINARY_INTEGER;

-- The g_dependency_table will store the dependency array of all the validations
-- dependencies on which it depends and also the error flag which is
-- stored for the validation. If the validation fails then the error flag will
-- be set to Y so that any further validations with other objects need not be
-- performed

g_dependency_tab dep_tab_type;

PROCEDURE set_Dependent_error( x_name VARCHAR2);
--
PROCEDURE set_fatal_error;
--
PROCEDURE dump_messages;
--
PROCEDURE dump_messages(x_header_id IN NUMBER);
--
PROCEDURE initialize_messages;
--
FUNCTION fatal_error_found
RETURN BOOLEAN;
--
FUNCTION check_dependency(x_name VARCHAR2)
RETURN BOOLEAN ;

PROCEDURE initialize_dependency (x_module VARCHAR2);

PROCEDURE reset_dependency( x_val_name IN VARCHAR2 DEFAULT NULL);

--
g_conc_req_id NUMBER;
--
PROCEDURE populate_req_id;
--
FUNCTION get_conc_req_id
RETURN NUMBER;

-- Bug#: 2771756 : Added the new procedure RemoveMessages.
-- Bug: 4198330 : Added grouping criteria to the removeMessages

PROCEDURE removeMessages (p_header_id IN NUMBER,
                          p_message   IN VARCHAR2,
                          p_message_type IN VARCHAR2,
                          p_ship_from_org_id IN NUMBER DEFAULT NULL,
                          p_ship_to_address_id IN NUMBER DEFAULT NULL,
                          p_customer_item_id IN NUMBER DEFAULT NULL,
                          p_inventory_item_id IN NUMBER DEFAULT NULL);

END RLM_MESSAGE_SV;
 

/
