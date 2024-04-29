--------------------------------------------------------
--  DDL for Package OE_CLOSE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CLOSE_WF" AUTHID CURRENT_USER as
/* $Header: OEXWCLOS.pls 120.0 2005/06/01 23:03:15 appldev noship $ */

PROCEDURE Close_Order(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Close_Line(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_Close_WF;

 

/
