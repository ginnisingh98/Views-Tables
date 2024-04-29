--------------------------------------------------------
--  DDL for Package OE_SHIPPING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SHIPPING_WF" AUTHID CURRENT_USER as
/* $Header: OEXWSHPS.pls 120.0.12000000.1 2007/01/16 22:14:36 appldev ship $ */

G_FREEZE_II  CONSTANT VARCHAR2(20) := FND_PROFILE.Value('ONT_INCLUDED_ITEM_FREEZE_METHOD');
G_DEV_SKIP   VARCHAR2(1) := 'N';

PROCEDURE Inc_Items_Freeze_Required(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE Start_Shipping(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

END OE_Shipping_WF;

 

/
