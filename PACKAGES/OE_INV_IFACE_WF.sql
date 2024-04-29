--------------------------------------------------------
--  DDL for Package OE_INV_IFACE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INV_IFACE_WF" AUTHID CURRENT_USER AS
/* $Header: OEXWIIFS.pls 120.0 2005/06/01 02:57:23 appldev noship $  */

PROCEDURE Inventory_Interface
(   itemtype     IN     VARCHAR2
,   itemkey      IN     VARCHAR2
,   actid        IN     NUMBER
,   funcmode     IN     VARCHAR2
,   resultout    IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

END OE_Inv_Iface_WF;

 

/
