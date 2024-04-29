--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_CURRENCY" AUTHID CURRENT_USER AS
/* $Header: msddemccs.pls 120.0.12000000.2 2007/09/25 06:15:29 syenamar noship $ */

Procedure process_currency(retcode out nocopy varchar2,
													 p_currency_code in varchar2,
													 p_base_currency_code in varchar2,
													 p_from_date in date,
													 p_to_date in date,
													 l_base_curr in varchar2,
													 g_dblink in varchar2);

procedure collect_currency(errbuf           out nocopy varchar2,
                                            retcode              out nocopy varchar2,
                                            p_instance_id          in  number,
                                            p_from_date  in varchar2 default null,
                                            p_to_date in varchar2 default null,
                                            p_all_currencies       in number,
                                            p_include_currency_list     in varchar2 default null,
                                            p_exclude_currency_list     in varchar2 default null);

END MSD_DEM_COLLECT_CURRENCY;


 

/
