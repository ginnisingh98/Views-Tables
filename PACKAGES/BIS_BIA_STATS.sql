--------------------------------------------------------
--  DDL for Package BIS_BIA_STATS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BIA_STATS" AUTHID CURRENT_USER AS
/*$Header: BISGTSPS.pls 120.0 2005/06/01 16:32 appldev noship $*/

/**
* This is the wrapper around FND_STATS.gather_table_stats
* Object name will be the table name or MV name seeded in RSG,
* while object type is either 'MV' or 'TABLE'
* We will derive the object schema name , then
* call FND_STATS.gather_table_stats to analyze the object
**/
procedure GATHER_TABLE_STATS(errbuf out NOCOPY varchar2,
                             retcode out NOCOPY varchar2,
							 objecttype in varchar2,
                             objectname  in varchar2,
                             percent  in number default null,
                             degree in number default null,
                             partname in varchar2 default null,
                             backup_flag in varchar2 default 'NOBACKUP',
                             granularity  in varchar2 default 'DEFAULT',
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                            );

END BIS_BIA_STATS;


 

/
