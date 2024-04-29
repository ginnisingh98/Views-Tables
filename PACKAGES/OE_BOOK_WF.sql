--------------------------------------------------------
--  DDL for Package OE_BOOK_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BOOK_WF" AUTHID CURRENT_USER as
/* $Header: OEXWBOKS.pls 120.0 2005/06/01 02:37:44 appldev noship $ */

PROCEDURE Book_Order(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_Book_WF;

 

/
