--------------------------------------------------------
--  DDL for Package ECX_DTD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_DTD_UTILS" AUTHID CURRENT_USER as
-- $Header: ECXDTDS.pls 120.2 2005/06/30 11:15:17 appldev ship $
procedure ins
	(
	i_root_element	in	varchar2,
	i_filename	in	varchar2,
	i_location	in	varchar2 default null,
	i_payload		in	clob,
	i_retcode		OUT	NOCOPY number,
	i_retmsg		OUT	NOCOPY varchar2
	);

procedure del
	(
	i_root_element	in	varchar2,
	i_filename	in	varchar2,
	i_location	in	varchar2 default null,
	i_retcode		OUT	NOCOPY number,
	i_retmsg		OUT	NOCOPY varchar2
	);

end ecx_dtd_utils;

 

/
