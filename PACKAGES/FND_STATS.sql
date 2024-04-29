--------------------------------------------------------
--  DDL for Package FND_STATS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_STATS" AUTHID CURRENT_USER as
/* $Header: AFSTATSS.pls 120.7.12010000.15 2012/12/13 10:29:14 msaleem ship $ */


AUTO_SAMPLE_SIZE NUMBER :=0;         --


-- table having fewer blocks than this thold will be serialized
SMALL_TAB_FOR_PAR_THOLD  NUMBER := 500;

-- table having fewer blocks than this thold will be gathered at 100%
SMALL_TAB_FOR_EST_THOLD  NUMBER := 500;

-- index having fewer blocks than this thold will be serialized
SMALL_IND_FOR_PAR_THOLD  NUMBER := 500;

-- index having fewer blocks than this thold will be gathered at 100%
SMALL_IND_FOR_EST_THOLD  NUMBER := 500;

TYPE Error_Out IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

procedure CREATE_STAT_TABLE ;

procedure ENABLE_SCHEMA_MONITORING(schemaname in varchar2 default 'ALL');

procedure DISABLE_SCHEMA_MONITORING(schemaname in varchar2 default 'ALL');

/* Undocumented and for INTERNAL use only */
procedure CREATE_STAT_TABLE( schemaname in varchar2,
                              tabname    in varchar2,
                              tblspcname in varchar2 default null);

procedure TRANSFER_STATS(   errbuf OUT NOCOPY  varchar2,
                            retcode OUT NOCOPY  varchar2,
                            action  in varchar2,
                            schemaname in varchar2,
                            tabname in varchar2,
                            stattab in varchar2 default 'FND_STATTAB',
                            statid   in varchar2
                           ) ;

procedure BACKUP_SCHEMA_STATS( schemaname in varchar2,
                               statid  in varchar2 default null);

procedure BACKUP_TABLE_STATS( schemaname in varchar2,
                              tabname in varchar2,
                              statid   in varchar2 default 'BACKUP',
                              partname in varchar2 default null,
                              cascade  in boolean default true
                              )  ;

procedure BACKUP_TABLE_STATS(   errbuf OUT NOCOPY  varchar2,
                                retcode OUT NOCOPY  varchar2,
                                schemaname in varchar2,
                                tabname in varchar2,
                                statid   in varchar2 default 'BACKUP',
                                partname in varchar2 default null,
                                cascade  in boolean default true
                             ) ;

procedure RESTORE_SCHEMA_STATS( schemaname in varchar2,
                                statid     in varchar2 default null);

procedure RESTORE_TABLE_STATS(ownname in varchar2,
                              tabname  in varchar2,
                              statid   in varchar2 default null,
                              partname in varchar2 default null,
                              cascade  in boolean default true
                              );

procedure RESTORE_TABLE_STATS(  errbuf OUT NOCOPY  varchar2,
                                retcode OUT NOCOPY  varchar2,
                                ownname in varchar2,
                                tabname  in varchar2,
                                statid   in varchar2 default null,
                                partname in varchar2 default null,
                                cascade  in boolean default true
                                );

/* Undocumented and for INTERNAL use only */
procedure RESTORE_INDEX_STATS(ownname in varchar2,
                              indname  in varchar2,
                              statid   in varchar2 default null,
                              partname in varchar2 default null);

procedure RESTORE_COLUMN_STATS(ownname in varchar2,
                              tabname  in varchar2,
                              colname  in varchar2,
                              partname in varchar2 default null,
                              statid   in varchar2 default null);

/* This restores the column stats for all cols specified in FND_HISTOGRAM_COLS */
procedure RESTORE_COLUMN_STATS(statid in varchar2 default null) ;

/* This procedure is created so that it can be called from SQL prompt
   This is exactly same except it doesn't have the output parameter */
procedure GATHER_SCHEMA_STATISTICS(schemaname in varchar2,
		-- changes done for bug 11835452
                              estimate_percent in number default null , -- default 10,
                              degree in number default null,
                              internal_flag in varchar2 default 'NOBACKUP',
                              request_id in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              options in varchar2 default 'GATHER',
                              modpercent in number default 10,
                              invalidate    in varchar2 default 'Y'
                              );

procedure GATHER_SCHEMA_STATS(schemaname in varchar2,
		-- changes done for bug 11835452
                              estimate_percent in number default null, -- default 10,
                              degree in number default null,
                              internal_flag in varchar2 default 'NOBACKUP',
                              --Errors        OUT NOCOPY  Error_Out, -- commented to handle the error collection
                              request_id in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              options in varchar2 default 'GATHER',
                              modpercent in number default 10,
                              invalidate    in varchar2 default 'Y'
                              );





procedure GATHER_SCHEMA_STATS_SQLPLUS(schemaname in varchar2,
		-- changes done for bug 11835452
                              estimate_percent in number default null, -- default 10,
                              degree in number default null,
                              internal_flag in varchar2 default 'NOBACKUP',
                              Errors        OUT NOCOPY  Error_Out, -- commented to handle the error collection
                              request_id in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              options in varchar2 default 'GATHER',
                              modpercent in number default 10,
                              invalidate    in varchar2 default 'Y'
                              );

procedure GATHER_SCHEMA_STATS(errbuf OUT NOCOPY  varchar2,
                              retcode OUT NOCOPY  varchar2,
                              schemaname in varchar2,
		-- changes done for bug 11835452
                              estimate_percent in number default null, -- default 10,
                              degree in number default null,
                              internal_flag in varchar2 default 'NOBACKUP',
                              request_id in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              options in varchar2 default 'GATHER',
                              modpercent in number default 10,
                              invalidate    in varchar2 default 'Y'
                              );

procedure GATHER_INDEX_STATS(ownname in varchar2,
                             indname  in varchar2,
                             percent  in number default null,
			     degree in number default null,
                             partname in varchar2 default null,
                             backup_flag  in varchar2 default 'NOBACKUP',
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                             );

procedure GATHER_TABLE_STATS(ownname in varchar2,
                             tabname  in varchar2,
                             percent  in number default null,
                             degree in number default null,
                             partname in varchar2 default null,
                             backup_flag in varchar2 default 'NOBACKUP',
                             cascade  in boolean default true,
                             granularity  in varchar2 default 'DEFAULT',
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                            );

procedure GATHER_TABLE_STATS(errbuf OUT NOCOPY  varchar2,
                             retcode OUT NOCOPY  varchar2,
                             ownname in varchar2,
                             tabname  in varchar2,
                             percent  in number default null,
                             degree in number default null,
                             partname in varchar2 default null,
                             backup_flag in varchar2 default 'NOBACKUP',
                             granularity  in varchar2 default 'DEFAULT',
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                             );

procedure GATHER_COLUMN_STATS(appl_id in number default null,
                              percent in number default null,
                              degree in number default null,
                              backup_flag in varchar2 default 'NOBACKUP',
                              --Errors OUT NOCOPY  Error_Out,--commented to handle the error collection
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                             );

procedure GATHER_ALL_COLUMN_STATS(ownname in varchar2,
                              percent in number default null,
                              degree in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                              );

procedure GATHER_ALL_COLUMN_STATS(errbuf OUT NOCOPY  varchar2,
                              retcode OUT NOCOPY  varchar2,
                              ownname in varchar2,
                              percent in number default null,
                              degree in number default null,
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                              );

procedure GATHER_COLUMN_STATS(ownname in varchar2,
                              tabname  in varchar2,
                              colname  in varchar2,
                              percent in number default null,
                              degree in number default null,
                              hsize   in number default 254,
                              backup_flag in varchar2 default 'NOBACKUP',
                              partname in varchar2 default null,
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                             );

procedure GATHER_COLUMN_STATS(errbuf OUT NOCOPY  varchar2,
                              retcode OUT NOCOPY  varchar2,
                              ownname in varchar2,
                              tabname  in varchar2,
                              colname  in varchar2,
                              percent  in number  default null,
                              degree in number default null,
                              hsize   in number default 254,
                              backup_flag in varchar2 default 'NOBACKUP',
                              partname in varchar2 default null,
                              hmode in varchar2 default 'LASTRUN',
                              invalidate    in varchar2 default 'Y'
                             );

/* Purges all records of the FND_STATS_HIST that fall between from_req_id and to_req_id */
procedure  PURGE_STAT_HISTORY(from_req_id in number,
                      to_req_id  in number
                                ) ;

/* Purges all records of the FND_STATS_HIST that fall between from_req_id and to_req_id */
procedure  PURGE_STAT_HISTORY(purge_from_date in varchar2 ,
                      purge_to_date  in varchar2
                                ) ;
procedure PURGE_STAT_HISTORY(errbuf OUT NOCOPY  varchar2,
                             retcode OUT NOCOPY  varchar2,
                             purge_mode in varchar2 ,
                             from_value in varchar2 ,
                             to_value in varchar2 );


/* Undocumented and for INTERNAL use only */
procedure SET_TABLE_STATS(ownname in varchar2,
                          tabname in varchar2,
                          numrows  in number,
                          numblks  in number,
                          avgrlen  in number,
                          partname in varchar2 default null);


/* Undocumented and for INTERNAL use only */
procedure SET_INDEX_STATS(ownname in varchar2,
                          indname in varchar2,
                          numrows  in number,
                          numlblks  in number,
                          numdist  in number,
                          avglblk  in number,
                          avgdblk  in number,
                          clstfct  in number,
                          indlevel in number,
                          partname in varchar2 default null);

procedure  LOAD_XCLUD_STATS(schemaname in varchar2);

/* This one is for a particular INTERFACE TABLE  */
procedure  LOAD_XCLUD_STATS(schemaname in varchar2,
                            tablename  in varchar2);

/* This is for loading exclusion list into fnd_exclude_table_stats */
procedure LOAD_XCLUD_TAB(action in varchar2,
                          appl_id in number,
                          tabname in varchar2);

/* This is for internal/support purpose only. For loading/deleting SEED database */
/* procedure DELETE_XCLUD_IND( appl_id in number,
                          tabname in varchar2,
                          indname in varchar2,
                          partname  in varchar2 default null);
*/
/* This is for internal purpose only. For loading into SEED database */
procedure LOAD_HISTOGRAM_COLS(action in varchar2,
                          appl_id in number,
                          tabname in varchar2,
                          colname in varchar2,
                          partname in varchar2 default null,
                          hsize  in number default 254,
                          commit_flag in varchar2 default 'Y' );

/* This is for internal purpose only. This is for seeding Materialized View columns For loading into SEED database */
procedure LOAD_HISTOGRAM_COLS_MV(action in varchar2,
                          ownername in varchar2,
                          tabname in varchar2,
                          colname in varchar2,
                          partname in varchar2 default null,
                          hsize  in number default 254,
                          commit_flag in varchar2 default 'Y');
/* This is to check if the leading cols of non-unique indexes of
   a list of input table_names needs histograms */
procedure CHECK_HISTOGRAM_COLS(tablelist        in varchar2,
                               factor           in integer default 75,
                               percent          in number default 10,
                               degree           in number default null);

/* This is to create histograms on all leading cols of non-unique indexes of all the
   tables in a given schema */
procedure ANALYZE_ALL_COLUMNS(ownname       in varchar2,
                              percent       in number default null,
                              hsize         in number default 254,
                              hmode in varchar2 default 'LASTRUN');
/* conc. job version of ANALYZE_ALL_COLUMNS */
procedure ANALYZE_ALL_COLUMNS(errbuf OUT NOCOPY  varchar2,
                              retcode OUT NOCOPY  varchar2,
                              ownname       in varchar2,
                              percent  in number default null,
                              hsize              in number default 254,
                              hmode in varchar2 default 'LASTRUN');
/* This is for internal purpose only. For loading 11G extension stats into SEED database */
procedure LOAD_EXTNSTATS_COLS(action in varchar2,
                            appl_id in number,
			    owner in varchar2,
                          tabname in varchar2,
                          colname1 in varchar2,
                          colname2 in varchar2,
                          colname3 in varchar2 default null,
                          colname4 in varchar2 default null,
                          partname in varchar2 default null,
                          hsize  in number default 254,
                          commit_flag in varchar2 default 'Y' );

/* Used for updating the FND_STATS_HIST with autonomous_transaction */
procedure  UPDATE_HIST(schemaname varchar2,
                                 objectname in varchar2,
                                 objecttype in varchar2,
                                 partname   in varchar2,
                                 columntablename   in varchar2,
                                 degree  in number,
                                 upd_ins_flag in varchar2,
                                 percent in number default null
                                ) ;
/* This procedure checks tables, indexes and histograms to see if statistics exist or are stale */
procedure verify_stats(schemaname  varchar2 default null,
		       tableList   varchar2 default null,
		       days_old    number   default null,
                       column_stat boolean default false);
end FND_STATS;

/
