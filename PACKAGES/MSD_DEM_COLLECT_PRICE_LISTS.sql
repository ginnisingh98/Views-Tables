--------------------------------------------------------
--  DDL for Package MSD_DEM_COLLECT_PRICE_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DEM_COLLECT_PRICE_LISTS" AUTHID CURRENT_USER AS
/* $Header: msddemprlcls.pls 120.1.12000000.2 2007/09/24 11:07:11 nallkuma noship $ */

procedure collect_price_lists(errbuf              out nocopy varchar2,
														  retcode             out nocopy number,
                              p_instance_id        in   number,
                              p_start_date  			 in varchar2,
                              p_end_date           in varchar2,
                              p_include_all        in   number,
                              p_include_prl_list   in varchar2,
                              p_exclude_prl_list   in varchar2);

procedure delete_price_lists(errbuf              out nocopy varchar2,
														 retcode             out nocopy number,
														 p_list              in  varchar2);

END MSD_DEM_COLLECT_PRICE_LISTS;


 

/
