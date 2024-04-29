--------------------------------------------------------
--  DDL for Package XDPCORE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_ORDER" AUTHID CURRENT_USER AS
/* $Header: XDPCOROS.pls 120.1 2005/06/15 22:39:30 appldev  $ */



 e_NullValueException		EXCEPTION;




 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);


--  IS_BUNDLE_DETECTED
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure IS_BUNDLE_DETECTED (itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       OUT NOCOPY varchar2);

--  CONTINUE_ORDER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure CONTINUE_ORDER (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_ORDER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_ORDER (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

End XDPCORE_ORDER;

 

/
