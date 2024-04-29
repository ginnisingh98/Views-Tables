--------------------------------------------------------
--  DDL for Package XDP_ADAPTER_CORE_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER_CORE_PIPE" AUTHID CURRENT_USER AS
/* $Header: XDPACOPS.pls 120.2 2005/07/07 02:23:08 appldev ship $ */

e_SendPipedMsgException exception;
e_ReceivePipedMsgException exception;

pv_AckTimeout number := 60;

-- Construct a Unique Channel Name. The Channel Name can have a max size of 30
-- Characters.
Function GetUniqueChannelName (p_Name in varchar2) return varchar2;

-- Construct the Channel Name for the Application Thread of the Adapter
Function ConstructChannelName ( p_ChannelType in varchar2,
				p_ChannelName in varchar2) return varchar2;

-- Clean up the Channel before using it.
-- Clean up the Return Channel too
Procedure CleanupPipe(p_ChannelName in varchar2,
		      p_CleanReturn in varchar2 default 'Y');

-- Send a Message via pipes
Procedure SendPipedMessage(p_ChannelName in varchar2,
			    p_Message in varchar2);

-- Wait on a Pipe to receive a message. The specified timeout is used
-- to block on the pipe
Procedure ReceivePipedMessage(	p_ChannelName in varchar2,
				p_Timeout in number,
				p_ErrorCode OUT NOCOPY number,
				p_Message OUT NOCOPY varchar2);

-- Get the return channel name given a Channel Name
-- The return channel is used by the adapters to communicate back.
Function GetReturnChannelName(p_ChannelName in varchar2) return varchar2;


END XDP_ADAPTER_CORE_PIPE;

 

/
