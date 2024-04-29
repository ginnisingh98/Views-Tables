--------------------------------------------------------
--  DDL for Package HXC_WF_ERROR_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_WF_ERROR_HELPER" AUTHID CURRENT_USER as
/* $Header: hxcwferrhelper.pkh 120.0 2006/06/19 19:28:49 jdupont noship $ */

procedure prepare_error(
	 			itemtype     IN varchar2,
                                itemkey      IN varchar2,
                                actid        IN number,
                                funcmode     IN varchar2,
                                result       IN OUT NOCOPY varchar2);

END HXC_WF_ERROR_HELPER;

 

/
