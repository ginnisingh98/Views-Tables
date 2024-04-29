--------------------------------------------------------
--  DDL for Package GHR_MTI_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_MTI_INT" AUTHID CURRENT_USER AS
/* $Header: ghmtiint.pkh 120.0.12010000.1 2008/07/28 10:33:20 appldev ship $ */

	g_package       constant varchar2(33) := '  ghr_mti_int.';
	g_validate		 boolean := FALSE;

	procedure mass_transfer_in(
						p_errbuf 		 		out NOCOPY varchar2,
						p_retcode 		 		out NOCOPY number,
						p_transfer_id			in number,
						p_business_group_id	in number);

end ghr_mti_int;

/
