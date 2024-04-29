--------------------------------------------------------
--  DDL for Package XDPCORE_ORU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_ORU" AUTHID CURRENT_USER AS
/* $Header: XDPCORUS.pls 120.1 2005/06/15 22:41:30 appldev  $ */



 e_NullValueException		EXCEPTION;

 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);



--  LAUNCH_RESUBMISSION_FAS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_RESUBMISSION_FAS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_ORU_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_ORU_PROCESS (itemtype        in varchar2,
                                  itemkey         in varchar2,
                                  actid           in number,
                                  funcmode        in varchar2,
                                  resultout       OUT NOCOPY varchar2);


--  SET_ORU_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_ORU_STATUS (itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       OUT NOCOPY varchar2);


End XDPCORE_ORU;

 

/
