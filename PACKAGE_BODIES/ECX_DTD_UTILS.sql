--------------------------------------------------------
--  DDL for Package Body ECX_DTD_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_DTD_UTILS" as
-- $Header: ECXDTDB.pls 120.2 2005/06/30 11:15:15 appldev ship $

procedure ins
	(
	i_root_element	in	varchar2,
	i_filename	in	varchar2,
	i_location	in	varchar2 ,
	i_payload		in	clob,
	i_retcode		OUT	NOCOPY number,
	i_retmsg		OUT	NOCOPY varchar2
	)
is
begin
			delete 	from ecx_dtds
			where 	root_element = i_root_element
			and	( version = i_location or i_location is null )
			and	filename = i_filename;

			insert into ecx_dtds
				(
				dtd_id,
				root_element,
				filename,
				version,
				payload
				)
			values
				(
				ecx_dtd_s.nextval,
				i_root_element,
				i_filename,
				i_location,
				i_payload
				);
i_retcode :=0;
i_retmsg :=' DTD Successfully loaded';
exception
when others then
	i_retcode :=2;
	i_retmsg := SQLERRM||'   DTD cannot be loaded';
end ins;

procedure del
	(
	i_root_element	in	varchar2,
	i_filename	in	varchar2,
	i_location	in	varchar2,
	i_retcode		OUT	NOCOPY number,
	i_retmsg		OUT	NOCOPY varchar2
	)
is
begin
			delete 	from ecx_dtds
			where 	root_element = i_root_element
			and	filename = i_filename
			and	( version = i_location or i_location is null );

i_retcode :=0;
i_retmsg :=' DTD Successfully Deleted';
exception
when others then
	i_retcode :=2;
	i_retmsg := SQLERRM ||'   DTD cannot be deleted';
end del;

end ecx_dtd_utils;

/
