--------------------------------------------------------
--  DDL for Package JTF_WF_MESSAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_WF_MESSAGING" AUTHID CURRENT_USER as
/* $Header: JTFWFMGS.pls 120.2 2005/10/25 05:08:54 psanyal ship $ */

----------------------------------------------------------------------------

 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_WF_MESSAGING';


Procedure   GenMsg(	itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   OUT NOCOPY /* file.sql.39 change */ varchar2 );


END jtf_wf_messaging;

 

/
