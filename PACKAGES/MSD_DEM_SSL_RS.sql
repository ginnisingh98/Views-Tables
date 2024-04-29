--------------------------------------------------------
--  DDL for Package MSD_DEM_SSL_RS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_SSL_RS" AUTHID CURRENT_USER as
/* $Header: msddemrunrss.pls 120.0.12000000.2 2007/09/24 11:21:37 nallkuma noship $ */

procedure run_rs(errbuf             out nocopy varchar2,
                 retcode             out nocopy number,
								 instance number,
								 auto_run number,
								 file_seperator varchar,
								 control_path varchar2,
								 data_path varchar2,
								 file_name varchar2) ;

end msd_dem_ssl_rs;


 

/
