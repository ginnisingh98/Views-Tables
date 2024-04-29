--------------------------------------------------------
--  DDL for Package OE_REPRICE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_REPRICE_WF" AUTHID CURRENT_USER as
/* $Header: OEXWREPS.pls 120.0 2005/06/01 03:07:59 appldev noship $ */

PROCEDURE Start_Repricing(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

PROCEDURE Start_Repricing_Holds(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_Reprice_WF;

 

/
