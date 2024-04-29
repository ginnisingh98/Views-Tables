--------------------------------------------------------
--  DDL for Package MSD_SRP_SSL_RS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SRP_SSL_RS" AUTHID CURRENT_USER as
/* $Header: msdsrprunrss.pls 120.0 2007/11/05 13:55:16 vrepaka noship $ */
procedure run_rs(errbuf             out nocopy varchar2,
                 retcode             out nocopy number,
						 instance number,
								 file_seperator varchar,
								 control_path varchar2,
								 data_path varchar2,
								 file_name varchar2) ;

end msd_srp_ssl_rs;


/
