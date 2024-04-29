--------------------------------------------------------
--  DDL for Package POR_CANCEL_NOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_CANCEL_NOTIF_PVT" AUTHID CURRENT_USER as
/* $Header: PORCNNTS.pls 115.1 2004/05/06 21:52:21 mahmad noship $ */

  FUNCTION Start_WF_Process(reqLineId NUMBER, contractorStatus VARCHAR2) RETURN VARCHAR2;

  PROCEDURE Is_any_supplier_notified(itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funcmode        in varchar2,
                                   resultout       out NOCOPY varchar2);

  PROCEDURE set_notification_attributes(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

  PROCEDURE post_notification_process(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

  PROCEDURE set_supplier(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2);

END por_cancel_notif_pvt;

 

/
