--------------------------------------------------------
--  DDL for Package ECX_XSLT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_XSLT_UTILS" AUTHID CURRENT_USER as
-- $Header: ECXXSLTS.pls 120.2 2005/06/30 11:19:23 appldev ship $

procedure ins
        (
        i_filename      	in      varchar2,
        i_version		in	varchar2	default null,
        i_application_code	in	varchar2,
        i_payload               in      clob,
        i_retcode               OUT     NOCOPY number,
        i_retmsg                OUT     NOCOPY varchar2
        );


procedure del
        (
        i_filename      	in      varchar2,
        i_version		in	varchar2	default null,
        i_application_code	in	varchar2,
        i_retcode               OUT     NOCOPY number,
        i_retmsg                OUT     NOCOPY varchar2
        );

end ecx_xslt_utils;

 

/
