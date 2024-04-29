--------------------------------------------------------
--  DDL for Package XDPCORE_FA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_FA" AUTHID CURRENT_USER AS
/* $Header: XDPCORFS.pls 120.1 2005/06/15 22:38:00 appldev  $ */


 --global strings..
 g_fp_name varchar2(20) := 'FP_NAME';
 g_xdp_fp_error_threshold varchar2(30) := 'XDP_FP_ERROR_THRESHOLD';
 g_fp_in_error varchar2(20) := 'FP_IN_ERROR';

 e_NullValueException		EXCEPTION;
 e_UnhandledException		EXCEPTION;

 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);

 x_ErrorID number;
 x_ErrCode number;
 x_ErrStr varchar2(800);
 x_MessageList XDP_TYPES.MESSAGE_TOKEN_LIST;



Procedure CreateFAProcess(parentitemtype in varchar2,
                          parentitemkey in varchar2,
                          FAInstanceID in number,
                          WIInstanceID in number,
                          OrderID in number,
                          FaCaller in varchar2 DEFAULT 'EXTERNAL',
                          FaMaster in varchar2,
                          FaItemtype OUT NOCOPY varchar2,
                          FaItemkey OUT NOCOPY varchar2,
                          ErrCode OUT NOCOPY number,
                          ErrStr OUT NOCOPY varchar2);

Procedure CreateFAProcess(parentitemtype in varchar2,
                          parentitemkey in varchar2,
                          FAInstanceID in number,
                          WIInstanceID in number,
                          OrderID in number,
                          LineItemID in number,
                          ResubmissionJobID in number,
                          FaCaller in varchar2 DEFAULT 'EXTERNAL',
                          FaMaster in varchar2,
                          FaItemtype OUT NOCOPY varchar2,
                          FaItemkey OUT NOCOPY varchar2,
                          ErrCode OUT NOCOPY number,
                          ErrStr OUT NOCOPY varchar2);


--  ARE_ALL_FAS_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ARE_ALL_FAS_DONE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);






--  ENQUEUE_FP_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ENQUEUE_FP_QUEUE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  GET_FE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure GET_FE (itemtype        in varchar2,
		itemkey         in varchar2,
		actid           in number,
		funcmode        in varchar2,
		resultout       OUT NOCOPY varchar2);


Procedure OVERRIDE_FE (itemtype        in varchar2,
		itemkey         in varchar2,
		actid           in number,
		funcmode        in varchar2,
		resultout       OUT NOCOPY varchar2);


--  INITIALIZE_FA
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_FA (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  INITIALIZE_FA_LIST
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_FA_LIST (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


Procedure IS_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


-- IS_COD_CHANNEL_AVAILABLE
-- Resultout
--	Yes/No - Yes if a Connect-On-Demand Channel is available
--		 No if No such channel is configured or not available
--		 to be used at this time

Procedure IS_COD_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



-- CONNECT_ON_DEMAND
-- Resultout
--	Success/Failure - Success if the Adapter Connected Successfully
--			  Failure if the Connect Procedure fails

Procedure CONNECT_ON_DEMAND (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

--  LAUNCH_FA_PROVISIONING_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_FA_PROVISIONING_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  LAUNCH_FA_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_FA_PROCESS (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);


--  LAUNCH_FA_PROCESS_SEQ
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_FA_PROCESS_SEQ (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       OUT NOCOPY varchar2);

--  PROVISION_FE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure PROVISION_FE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  RELEASE_FE_CHANNEL
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure RELEASE_FE_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  GET_FA_CALLER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure GET_FA_CALLER (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2);


--  STOP_FA_PROCESSING
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure STOP_FA_PROCESSING (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  WAIT_IN_FP_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure WAIT_IN_FP_QUEUE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  VERIFY_CHANNEL
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure VERIFY_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure RESET_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure RESOLVE_IND_DEP_FAS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure INITIALIZE_DEP_FA_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure LAUNCH_ALL_IND_FAS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure IS_ANY_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure IS_THRESHOLD_EXCEEDED (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure ERROR_DURING_RETRY (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Procedure IS_THRESHOLD_REACHED (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Procedure RESET_SYSTEM_HOLD (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );


Procedure ENQUEUE_FP_HOLD (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Procedure AUTO_RETRY_ENABLED (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2 );



-- Obsoleted with 11.5.6
-- Procedure HandOverChannel (p_ChannelName in varchar2,
--                            p_FeName in varchar2,
--                            p_ErrCode out number,
--                            p_ErrStr out varchar2);

Procedure HandOverChannel (ChannelName in varchar2,
                           FeID in number,
                           ChannelUsageCode in varchar2,
                           Caller in varchar2 default 'FA',
                           ErrCode OUT NOCOPY number,
                           ErrStr OUT NOCOPY varchar2);


Function ConnectOnDemand(
        		p_Channel_Name in varchar2,
        		x_return_code OUT NOCOPY number,
        		x_error_description OUT NOCOPY varchar2) return varchar2;

Procedure SearchAndLockChannel( p_FEID in number,
			 	p_ChannelUsageCode in varchar2,
				p_CODFlag in varchar2,
				p_AdapterStatus in varchar2,
                		x_LockedFlag OUT NOCOPY varchar2,
			 	x_ChannelName OUT NOCOPY varchar2);

Function IsFAAborted(FAInstanceID in number) return boolean;

Function get_display_name( p_FAInstanceID IN NUMBER) return varchar2;

--Function IsChannelAvailable(itemtype in varchar2,
--                            itemkey in varchar2) return varchar2;

End XDPCORE_FA;

 

/
