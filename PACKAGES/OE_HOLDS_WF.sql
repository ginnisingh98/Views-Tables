--------------------------------------------------------
--  DDL for Package OE_HOLDS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HOLDS_WF" AUTHID CURRENT_USER as
/* $Header: OEXWHLDS.pls 120.0 2005/06/01 01:05:51 appldev noship $ */

procedure Apply_Holds(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

procedure Check_Holds(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

procedure Release_Holds(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_Holds_WF;

 

/
