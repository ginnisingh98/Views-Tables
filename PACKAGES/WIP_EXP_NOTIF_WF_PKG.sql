--------------------------------------------------------
--  DDL for Package WIP_EXP_NOTIF_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EXP_NOTIF_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: wipvexps.pls 120.0 2005/06/29 06:45:25 amgarg noship $ */



PROCEDURE INVOKE_NOTIFICATION(p_exception_id  IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2);

procedure CHECK_EXCEPTION_TYPE   ( itemtype        in  varchar2,
                                  itemkey         in  varchar2,
                                  actid           in number,
                                  funcmode        in  varchar2,
                                  result          out nocopy varchar2);

END WIP_EXP_NOTIF_WF_PKG;


 

/
