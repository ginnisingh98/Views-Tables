--------------------------------------------------------
--  DDL for Package XDPCORE_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_ERROR" AUTHID CURRENT_USER AS
/* $Header: XDPCORRS.pls 120.2 2006/04/10 23:23:15 dputhiye noship $ */



 e_NullValueException		EXCEPTION;

 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);


--  FE_ERROR_PROCESS_OPTIONS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure FE_ERROR_PROCESS_OPTIONS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2);


--  NOTIFY_OUTSIDE_SYSTEM_OF_ERROR
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure NOTIFY_OUTSIDE_SYSTEM_OF_ERROR (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2);



--  PREPARE_ERROR_MESSAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure PREPARE_ERROR_MESSAGE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       out NOCOPY varchar2);



-- FE_ERR_NTF
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure FE_ERR_NTF (itemtype        in varchar2,
                      itemkey         in varchar2,
                      actid           in number,
                      funcmode        in varchar2,
                      resultout       out NOCOPY varchar2);


Procedure SET_ERROR_CONTEXT (itemtype        in varchar2,
                      itemkey         in varchar2,
                      actid           in number,
                      funcmode        in varchar2,
                      resultout       out NOCOPY varchar2);

Procedure LOG_SESSION_ERROR( p_errory_type in varchar2);

End XDPCORE_ERROR;

 

/
