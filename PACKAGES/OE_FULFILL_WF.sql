--------------------------------------------------------
--  DDL for Package OE_FULFILL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FULFILL_WF" AUTHID CURRENT_USER as
/* $Header: OEXWFULS.pls 120.0 2005/06/01 00:57:46 appldev noship $ */

PROCEDURE Check_Wait_To_Fulfill_Line
(itemtype          IN          VARCHAR2
,itemkey           IN          VARCHAR2
,actid             IN          NUMBER
,funcmode          IN          VARCHAR2
,resultout         IN OUT NOCOPY /* file.sql.39 change */      VARCHAR2
);

PROCEDURE Complete_Fulfill_Eligible_Line
(p_line_id         IN          NUMBER
,x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE Start_Fulfillment(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

END OE_Fulfill_WF;

 

/
