--------------------------------------------------------
--  DDL for Package XNP_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_ADAPTER" AUTHID CURRENT_USER AS
/* $Header: XNPADAPS.pls 120.2 2006/02/13 07:37:01 dputhiye ship $ */

TYPE Fe_Data_Rec IS RECORD
(
	attribute_name	VARCHAR2(1024),
	attribute_value VARCHAR2(1024)
) ;

TYPE Fe_Data IS TABLE OF Fe_Data_Rec INDEX BY BINARY_INTEGER ;

--Sends an OPEN command to the specified Adapter
--using -the channel name as the Pipe
--
PROCEDURE open( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Sends a CLOSE command to the specified Adapter
--using the channel name as the Pipe
--
PROCEDURE close( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Sends a SUSPEND command to the specified Adapter
--using the channel name as the Pipe
--
PROCEDURE suspend( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Sends a RESUME command to the specified Adapter
--using the channel name as the Pipe
--
PROCEDURE resume( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Sends a SHUTDOWN command to the specified Adapter
--using the channel name as the Pipe
--
PROCEDURE shutdown( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Closes a FILE  on a specific channel.
--Using * for file name closes all files.
--Not specifying anything closes the default file.
--
PROCEDURE close_file( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

-- New FTP API recommended
-- FTPs a FILE  on a specific channel.
-- Using * for file name FTPs all files.
-- Not specifying anything FTPs the default file.

PROCEDURE ftp( p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2);

-- maintained for backward compatibility
-- FTPs a FILE  on a specific channel.
-- Using * for file name FTPs all files.
-- Not specifying anything FTPs the default file.
--
PROCEDURE ftp( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--API to send an XML message to the adapter
--
PROCEDURE user_control( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_operation IN VARCHAR2
	,p_operation_data IN fe_data
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 );

--Notifies the FMC of adapter errors
--
PROCEDURE notify_fmc
	(p_msg_header IN xnp_message.msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	);

END xnp_adapter ;

 

/
