--------------------------------------------------------
--  DDL for Package Body FII_TIME_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_HOOK" as
/*$Header: FIITIMHB.pls 120.0 2002/08/24 05:02:45 appldev noship $ */

function Pre_Dim_Collect return boolean IS
l_cid                    INTEGER;
l_master_instance        VARCHAR2(30);
instance_count           INTEGER;
l_statement              VARCHAR2(10000):=NULL;
l_table                  VARCHAR2(30):=NULL;
rows_processed           VARCHAR2(10):=NULL;
l_count                  INTEGER;
na_count                 INTEGER;
l_max                    DATE;
l_min                    DATE;
l_ep_max                 DATE;
l_ep_min                 DATE;
retcode                  VARCHAR2(2000);
errbuf                   VARCHAR2(2000);
l_join                   VARCHAR2(2000);

begin
  edw_log.put_line('Entering Time Pre Dimension Hook Procedure');
  edw_log.put_line(' ');

-- --------------------------------------------------------------
-- Update calendar day
-- --------------------------------------------------------------
  /* determine if data is pushed from oracle application, if not, return without updating */
  select count(*) into l_count
  from edw_time_cal_day_lstg where ep_cal_period_fk = 'oracle_source' and collection_status='READY';

  if l_count = 0 then
    edw_log.put_line('No data is pushed from oracle application, exit without updating any staging table.');
    return true;
  else
    edw_log.put_line(to_char(l_count)||' records are ready to update.');
    edw_log.put_line(' ');
  end if;

  /* Identify the master instance */
  select instance_code
  into   l_master_instance
  from   edw_system_parameters;
  edw_log.put_line('Master instance is '||l_master_instance||'.');

  /* Identify the instance of the source data */
  select count(distinct instance) into instance_count
  from edw_time_cal_day_lstg
  where ep_cal_period_fk = 'oracle_source' and collection_status='READY' and instance <> l_master_instance;

  /* Check if data pushed from the master instance, if yes, table edw_time_ep_cal_period_lstg
     will be used to populate ep_cal_period_fk, if no, table edw_time_ep_cal_period_ltc will
     be used instead.  This is because the LSTG table may be purged before data is pushed from
     another source. */

  if instance_count=0 then
    l_table:='edw_time_ep_cal_period_lstg';
    l_join:=' and ep.collection_status=''READY'' and ep.instance= '''||l_master_instance||'''';
    select min(start_date), max(end_date)
    into l_ep_min, l_ep_max
    from edw_time_ep_cal_period_lstg;
    edw_log.put_line('Data is collected from the master instance, Enterprise Calendar in the staging table will be used to update the Calendar Day foreign keys.');
    edw_log.put_line(' ');
  else
    l_table:='edw_time_ep_cal_period_ltc';
    l_join:=null;
    select min(start_date), max(end_date)
    into l_ep_min, l_ep_max
    from edw_time_ep_cal_period_ltc;
    edw_log.put_line('Data is not collected from the master instance, Enterprise Calendar in the level table will be used to update the Calendar Day foreign keys.');
    edw_log.put_line(' ');
  end if;

  /* Populate NA_EDW if period is not defined in gl_periods for the given date */
  l_statement:='update EDW_TIME_CAL_DAY_LSTG a set ep_cal_period_fk=nvl(
  (select ep.cal_period_pk from '||l_table||' ep
  where a.calendar_date between ep.start_date and ep.end_date
  and ep.timespan=(select min(ep1.timespan) from '||l_table||' ep1
  where a.calendar_date between ep1.start_date and ep1.end_date)
  and rownum=1'||l_join||'),''NA_EDW'')
  where a.ep_cal_period_fk=''oracle_source'' and a.collection_status=''READY''';

  edw_log.put_line(l_statement);
  edw_log.put_line(' ');

  EXECUTE IMMEDIATE l_statement;

  edw_log.put_line('Finished updating Calendar Day level with correct Enterprise Period.');
  edw_log.put_line(' ');

  select count(*), min(calendar_date), max(calendar_date)
  into na_count, l_min, l_max
  from edw_time_cal_day_lstg where ep_cal_period_fk = 'NA_EDW' and collection_status='READY';

  if na_count > 0 then
    edw_log.put_line('WARNING:The foreign key up the Enterprise Calendar Hierarchy is not updated for '||to_char(na_count)||' records!');
    edw_log.put_line('The records being collected are from '||to_char(l_min, 'dd-Mon-yyyy')||
                     ' to '||to_char(l_max, 'dd-Mon-yyyy'));
    edw_log.put_line('while the enterprise calendar defined in GL is from '||to_char(l_ep_min, 'dd-Mon-yyyy')||
		     ' to '||to_char(l_ep_max, 'dd-Mon-yyyy'));
    edw_log.put_line('Please ensure enterprise calendar periods spans the entire time range in the warehouse.');
  end if;

  commit;
  edw_log.put_line(to_char(l_count-na_count)||' records has been updated with the correct enterprise calendar!');
  return true;

Exception
  when no_data_found then
    -- It's okay if there are no records in staging
    null;
    return true;

  when others then
    rollback;
    retcode := sqlcode;
    errbuf  := sqlerrm;
    edw_log.put_line(retcode||' : '||errbuf);
    return false;

end Pre_Dim_Collect;

END FII_TIME_HOOK;

/
