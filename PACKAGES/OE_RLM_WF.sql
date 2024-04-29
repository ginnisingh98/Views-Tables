--------------------------------------------------------
--  DDL for Package OE_RLM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RLM_WF" AUTHID CURRENT_USER as
/* $Header: OEXWRLMS.pls 120.0 2005/06/01 02:55:16 appldev noship $ */

procedure CHECK_AUTHORIZE_TO_SHIP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2/* file.sql.39 change */
);

END OE_RLM_WF;

 

/
