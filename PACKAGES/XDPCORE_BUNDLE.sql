--------------------------------------------------------
--  DDL for Package XDPCORE_BUNDLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_BUNDLE" AUTHID CURRENT_USER AS
/* $Header: XDPCORBS.pls 120.1 2005/06/15 22:12:29 appldev  $ */



 e_NullValueException		EXCEPTION;




 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);


--  ARE_ALL_BUNDLES_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ARE_ALL_BUNDLES_DONE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_BUNDLE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_BUNDLE (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);


--  LAUNCH_BUNDLE_PROCESSES
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_BUNDLE_PROCESSES (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  LAUNCH_BUNDLE_PROCESS_SEQ
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_BUNDLE_PROCESS_SEQ (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  LAUNCH_LINE_FOR_BUNDLE_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_LINE_FOR_BUNDLE_PROCESS (itemtype        in varchar2,
                                          itemkey         in varchar2,
                                          actid           in number,
                                          funcmode        in varchar2,
                                          resultout       OUT NOCOPY varchar2);


Procedure RESOLVE_IND_DEP_BUNDLES (itemtype        in varchar2,
                                          itemkey         in varchar2,
                                          actid           in number,
                                          funcmode        in varchar2,
                                          resultout       OUT NOCOPY varchar2);

Procedure LAUNCH_ALL_IND_BUNDLES (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

Procedure INITIALIZE_DEP_BUNDLE_PROCESS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);



Procedure LAUNCH_BUNDLE_PROCESS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);


Procedure RESOLVE_IND_DEP_LINES_FOR_BUN (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

End XDPCORE_BUNDLE;

 

/
