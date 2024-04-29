--------------------------------------------------------
--  DDL for Package OE_OEOL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_OEOL_SCH" AUTHID CURRENT_USER as
/* $Header: OEXWSCHS.pls 120.0.12000000.1 2007/01/16 22:14:32 appldev ship $ */

Procedure Schedule_Line(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

Procedure Branch_on_source_type(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE Release_to_purchasing(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE Is_Line_Scheduled(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE Is_Line_Firmed(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

PROCEDURE Firm_demand(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2);/* file.sql.39 change */

end oe_oeol_sch;

 

/
