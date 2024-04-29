--------------------------------------------------------
--  DDL for Package OKL_INSURANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INSURANCE_WF" AUTHID CURRENT_USER AS
/* $Header: OKLRIWFS.pls 120.1 2005/07/18 06:21:18 asawanka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  procedure Initialize ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);

   procedure Check_Insurance ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout 	out nocopy  varchar2);

    procedure  Create_Third_Party_Task(itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2) ;

    procedure send_message ( itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode	in varchar2,
				resultout	out nocopy varchar2	);

END OKL_INSURANCE_WF;

 

/
