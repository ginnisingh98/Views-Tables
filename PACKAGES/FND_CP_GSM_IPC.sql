--------------------------------------------------------
--  DDL for Package FND_CP_GSM_IPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_GSM_IPC" AUTHID CURRENT_USER AS
/* $Header: AFCPSMIS.pls 120.2 2005/08/19 14:39:43 susghosh ship $ */


--=========================================================================--
/* ICM Functions */
--=========================================================================--

/*--------------------------------------------------------------------------
procedure Unsubscribe -unsub from AQ.  Null -> unsub all
-----------------------------------------------------------------------------*/

procedure Unsubscribe(cpid in number default null);


--=========================================================================--
/* Cartridge Functions */
--=========================================================================--

/*--------------------------------------------------------------------------
procedure Init_Cartridge
-----------------------------------------------------------------------------*/

procedure Init_Cartridge;

/*--------------------------------------------------------------------------
procedure Shutdown_Cartridge
-----------------------------------------------------------------------------*/

procedure Shutdown_Cartridge;

/*--------------------------------------------------------------------------
procedure Cartridge_Init_Service
-----------------------------------------------------------------------------*/

procedure Cartridge_Init_Service(cpid in Number,
                        Params in Varchar2,
                        Debug_Level in Varchar2);

/*--------------------------------------------------------------------------
        Procedure Send_Message:

        Handle = CPID
        Message -> Stop, Suspend, Resume, Verify, Initialize
        Parameters - Currently only used to send parameters with Verify
        Debug_Level = One character Debug Level
-----------------------------------------------------------------------------*/


Procedure Send_Message (Handle in Number,
                        Message in Varchar2,
                        Parameters in Varchar2,
                        Debug_Level in Varchar2);

/*--------------------------------------------------------------------------
Function Get_Status:

Reads off of -CPID,  Consumes/Ignores All but last message on AQ
Leaves last message on AQ.
        Handle = CPID
-----------------------------------------------------------------------------*/

Function Get_Status (Handle in Number) Return Varchar2;

--=========================================================================--
/* Routines called Externally */
--=========================================================================--


/*--------------------------------------------------------------------------
        Procedure Send_Custom_Message:

        Handle = CPID
        Type - 8 characters for identifying format
        Message - Currently only used to send parameters with Verify
-----------------------------------------------------------------------------*/


Procedure Send_Custom_Message (Handle in Number,
                        Type in varchar2,
                        Mesg in Varchar2);


--=========================================================================--
/* Routines called by Service */
--=========================================================================--

/*--------------------------------------------------------------------------
        Procedure Init_Service:

        Init_Service:
        Handle = CPID
        Parameters = Initial Parameter String
        Debug_Level = One character Debug Level
-----------------------------------------------------------------------------*/

Procedure Init_Service (Handle in Number,
                        Parameters out NOCOPY Varchar2,
                        Debug_Level out NOCOPY Varchar2);


/*--------------------------------------------------------------------------
        Procedure Get_Message:

        Handle = CPID
        Message -> Stop, Suspend, Resume, Verify, Custom:<type>, Initialize (Internal)
        Parameters - used to send parameters with Verify as well as Custom messages.
        Debug_Level - One character Debug Level - Not valid with Custom Messages
        Blocking_Flag = Y/N do we wait?
        Consume_Flag = Y/N do we consume message?
        More_Flag = Y/N more messages on AQ?
        Message_Wait_Timeout = Timeout to use when waiting on AQ for msg.
                Used for both blocking and non blocking calls. Null= nowait
        Blocking_Sleep_Time = Only meaningful if blocking_flag = 'Y'.  How
                many secs to sleep between looking for messages.

    Notes:
        All messages types (returned in parameter Message) can be matched to the functions
	MSG_Stop, MSG_Suspend, MSG_Resume, MSG_Verify, and MSG_Custom.  However in the case
	of Custom, the returned value will be Custom:<type> where type is an 8 character or
	less tag of the developers choice. (for example Custom:INV_ALERT), so only the first
	6 charactes of the parameter Message should be compared to MSG_Custom, or else the
	tag should be appended to MSG_Custom before comparison.  For example:

		if (Message = MSG_Custom || ':' || 'INV_ALERT') then ....

	An additional concern regarding the Custom message, is that the Debug_Level is
	always null...the service should not interpret this as a command to change the
	Debug level to the value Null.


-----------------------------------------------------------------------------*/

Procedure Get_Message ( Handle in Number,
                        Message out NOCOPY Varchar2,
                        Parameters out NOCOPY Varchar2,
                        Debug_Level out NOCOPY Varchar2,
                        Blocking_Flag in Varchar2,
                        Consume_Flag in Varchar2,
                        Success_Flag out NOCOPY Varchar2,
                        More_Flag out NOCOPY Varchar2,
                        Message_Wait_Timeout in number default Null,
                        Blocking_Sleep_Time in number default 30);


/* Messages */

Function MSG_Stop return varchar2;
Function MSG_Suspend return varchar2;
Function MSG_Resume return varchar2;
Function MSG_Verify return varchar2;
Function MSG_Custom return varchar2;

/*--------------------------------------------------------------------------
        Procedure Update_Status:

        Handle = CPID
        Status is one of: Running, Stopped, Suspended,
                                        Uninitialized (for FND Use only)
-----------------------------------------------------------------------------*/


Procedure Update_Status ( Handle in Number, Status in Varchar2);

/*--------------------------------------------------------------------------
        Procedure Update_Status_and_info:

        Handle = CPID
        Status is one of: Running, Stopped, Suspended,
                                        Uninitialized (for FND Use only)
	Info is varchar2(2000) for service developers use.
-----------------------------------------------------------------------------*/


Procedure Update_Status_and_Info ( Handle in Number, Status in Varchar2, Info in Varchar2);

/* Statuses */

Function Status_Running return varchar2;
Function Status_Stopped return varchar2;
Function Status_Suspended return varchar2;

END fnd_cp_gsm_ipc;

 

/
