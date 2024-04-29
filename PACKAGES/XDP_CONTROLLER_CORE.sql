--------------------------------------------------------
--  DDL for Package XDP_CONTROLLER_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_CONTROLLER_CORE" AUTHID CURRENT_USER AS
/* $Header: XDPCCORS.pls 120.1 2005/06/08 23:43:11 appldev  $ */

  e_ControllerWarningException exception;
  e_ControllerErrorException exception;

  pv_StartCustomMessage varchar2(8) 	:= 'STRTADAP';
  pv_VerifyCustomMessage varchar2(8) 	:= 'VRFYADAP';
  pv_TermCustomMessage varchar2(8) 	:= 'TERMADAP';
  pv_SuspCustomMessage varchar2(8) 	:= 'SUSPADAP';
  pv_ResuCustomMessage varchar2(8) 	:= 'RESUADAP';
  pv_ConnCustomMessage varchar2(8) 	:= 'CONNADAP';
  pv_DiscCustomMessage varchar2(8) 	:= 'DISCADAP';
  pv_StopCustomMessage varchar2(8) 	:= 'STOPADAP';
  pv_GenOpCustomMessage varchar2(8) 	:= 'GENOADAP';

  pv_ControllerNotRunningMsg varchar2(40) 	:= 'CONTROLLER_NOT_RUNNING';

-- Verify the Status of a Particular Controller Service Instance ID
-- The CPID of the controller is returned
Procedure VerifyControllerStatus(p_ConcQID in number,
				 p_CPID OUT NOCOPY number,
				 p_ControllerRunning OUT NOCOPY varchar2);

-- Send a Verify Message to the Contoller
-- The Parameters will have the adapter process in CHANNEL_NAME:PROCESS_ID
-- format
Procedure VerifyAdapters (CPID in number,
			  AdapterInfo in varchar2);

-- Send a Start Adapter message to the Controller
Procedure LaunchAdapter (CPID in number,
			 AdapterInfo in varchar2);

-- Send a Terminate Adapter message to the Controller
Procedure TerminateAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Suspend Adapter message to the Controller
Procedure SuspendAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Resume Adapter message to the Controller
Procedure ResumeAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Connect Adapter message to the Controller
Procedure ConnectAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Disconnect Adapter message to the Controller
Procedure DisconnectAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Stop Adapter message to the Controller
Procedure StopAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Send a Generic operation Adapter message to the Controller
Procedure GenericOperationAdapter(CPID in varchar2,
			  AdapterInfo in varchar2);

-- Does processing that is required before Controller stops
-- Added - sacsharm
Procedure Perform_Stop_Processing (p_CPID in varchar2,
			  p_AdapterInfo OUT NOCOPY varchar2);

-- Send Notification to inform that the Controller is not running
Procedure NotifyControllerNotRunning (p_Controllers in VARCHAR2);

-- Does processing that is required before Controller starts
-- Added - sacsharm
Procedure Perform_Start_Processing (p_CPID in varchar2,
			  p_AdapterInfo OUT NOCOPY varchar2);

Procedure Process_Control_Command(p_ChannelName in varchar2,
                                p_Operation in varchar2,
                                p_OpData in varchar2 default null,
                                p_Caller in varchar2 default 'USER',
                                p_Status OUT NOCOPY varchar2,
                                p_ErrorMessage OUT NOCOPY varchar2);
END XDP_CONTROLLER_CORE;

 

/
