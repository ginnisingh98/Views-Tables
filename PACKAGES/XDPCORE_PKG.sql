--------------------------------------------------------
--  DDL for Package XDPCORE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_PKG" AUTHID CURRENT_USER AS
/* $Header: XDPCORPS.pls 120.1 2005/06/15 22:40:31 appldev  $ */



 e_NullValueException		EXCEPTION;

 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);


--  ARE_ALL_SERVICES_IN_PKG_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ARE_ALL_SERVICES_IN_PKG_DONE (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       OUT NOCOPY varchar2);


--  LAUNCH_SERVICE_FOR_PKG_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_SERVICE_FOR_PKG_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  LAUNCH_SERVICE_IN_PACKAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_SERVICE_IN_PACKAGE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_PACKAGE_SERVICE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_PACKAGE_SERVICE (itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       OUT NOCOPY varchar2);


Procedure RESOLVE_IND_DEP_PKGS (itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       OUT NOCOPY varchar2);

Procedure LAUNCH_ALL_IND_SERVICES (itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       OUT NOCOPY varchar2);

Procedure INITIALIZE_DEP_SERVICE_PROCESS (itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       OUT NOCOPY varchar2);


End XDPCORE_PKG;

 

/
