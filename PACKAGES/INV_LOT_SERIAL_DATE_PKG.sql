--------------------------------------------------------
--  DDL for Package INV_LOT_SERIAL_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOT_SERIAL_DATE_PKG" AUTHID CURRENT_USER AS
/* $Header: INVLSDTS.pls 120.0 2005/08/12 07:06:07 nsinghi noship $ */

FUNCTION date_rule (p_subscription_guid IN     RAW,
                   p_event             IN OUT NOCOPY wf_event_t) RETURN VARCHAR2 ;

PROCEDURE send_notification (
    p_itemtype      IN VARCHAR2,
    p_itemkey       IN VARCHAR2,
    p_actid         IN NUMBER,
    p_funcmode      IN VARCHAR2,
    p_resultout     OUT NOCOPY VARCHAR2);

PROCEDURE get_message_attrs
(
   command IN VARCHAR2,
   context IN VARCHAR2,
   attr_name IN VARCHAR2,
   attr_type IN VARCHAR2,
   text_value IN OUT NOCOPY VARCHAR2,
   number_value IN OUT NOCOPY NUMBER,
   date_value IN OUT NOCOPY DATE
);

END INV_LOT_SERIAL_DATE_PKG;

 

/
