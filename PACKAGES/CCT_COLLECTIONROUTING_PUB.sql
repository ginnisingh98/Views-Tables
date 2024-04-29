--------------------------------------------------------
--  DDL for Package CCT_COLLECTIONROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_COLLECTIONROUTING_PUB" AUTHID CURRENT_USER as
/* $Header: cctrcols.pls 120.0 2005/06/02 09:47:31 appldev noship $ */

procedure isCustomerOverdue (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy  varchar2);

procedure getCollectors (
     itemtype       in varchar2
     , itemkey      in varchar2
     , actid        in number
     , funmode      in varchar2
     , resultout    in out nocopy varchar2);

END CCT_COLLECTIONROUTING_PUB;

 

/
