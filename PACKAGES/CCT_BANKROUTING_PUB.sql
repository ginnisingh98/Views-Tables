--------------------------------------------------------
--  DDL for Package CCT_BANKROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_BANKROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: cctrbnks.pls 120.0 2005/06/02 09:12:53 appldev noship $ */
procedure Get_Group_from_Profitability (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2);

procedure Get_Group_from_Bank_Id (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2);

procedure Get_Group_from_Bank_Branch (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2);

END CCT_BANKROUTING_PUB;

 

/
