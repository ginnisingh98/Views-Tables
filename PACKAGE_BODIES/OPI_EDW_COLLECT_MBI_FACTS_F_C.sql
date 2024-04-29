--------------------------------------------------------
--  DDL for Package Body OPI_EDW_COLLECT_MBI_FACTS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_COLLECT_MBI_FACTS_F_C" AS
/* $Header: OPICFCTB.pls 120.1 2005/06/10 14:38:04 appldev  $ */
  PROCEDURE PUSH (Errbuf      in out  nocopy Varchar2,
                Retcode       in out  nocopy Varchar2,
                p_from_date   IN      varchar2,
                p_to_date     IN      varchar2,
                p_fact_name   IN      VARCHAR2,
                p_staging_TABLE IN    VARCHAR2) IS

    l_fact_name       VARCHAR2(30)  :=p_fact_name;
    l_staging_table   VARCHAR2(30)  :=p_staging_table;
    l_exception_msg   VARCHAR2(2000):=Null;
    l_from_date       DATE := NULL;
    l_to_date         DATE := NULL;
  BEGIN
    Errbuf :=NULL;
    Retcode:=0;

    edw_log.put_line(' ');
    edw_log.put_line('call EDW_COLLECTION_UTIL ');
    -- -------------------------------------------
    -- call edw_collection_util.setup
    -- -------------------------------------------
    IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,
                                     l_staging_table,
                                     l_staging_table,
                                     l_exception_msg)) THEN
      errbuf := fnd_message.get;
      Return;
    END IF;
   -- -----------------------------------------------------
   -- figure out the process start/end date
   -- Append 23:59:59 to the to_date incase it's passed
   -- -----------------------------------------------------

   l_from_date  := To_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date    := To_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');

   --  Start of code change for bug fix 2140267.
   -- --------------------------------------------
   -- Taking care of cases where the input from/to
   -- date is NULL.
   -- --------------------------------------------

   l_from_date := nvl(l_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   l_to_date := nvl(l_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   --  End of code change for bug fix 2140267.
    IF l_fact_name = 'OPI_EDW_INV_DAILY_STAT_F'  THEN
      edw_log.put_line(' ');
 --     edw_log.put_line(' Start of Collect Process  Inventory Daily Status ');
/*      OPI_EDW_OPMINV_DAILY_STAT_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date =>to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') , p_to_date => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS') ); */
      IF retcode = '2' THEN
         APP_EXCEPTION.Raise_exception;
      END IF;
      edw_log.put_line(' ');
--      edw_log.put_line(' End of Collect Process  Inventory Daily Status ');
      edw_log.put_line(' ');
      edw_log.put_line(' Start of Collect Discrete Inventory Daily Status ');
      OPI_EDW_INV_DAILY_STAT_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date => to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') ,p_to_date  => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line(' End of Collect Discrete Inventory Daily Status ');
    ELSIF l_fact_name = 'OPI_EDW_COGS_F'  THEN
      edw_log.put_line(' ');
 --     edw_log.put_line(' Start of Collect Process  COGS Fact ');
  /*    OPI_EDW_OPMCOGS_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date =>to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') , p_to_date => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS') ); */
      IF retcode = '2' THEN
         APP_EXCEPTION.Raise_exception;
      END IF;
      edw_log.put_line(' ');
--      edw_log.put_line(' End of Collect COGS Fact');
      edw_log.put_line(' ');
      edw_log.put_line(' Start of Collect Discrete COGS Fact ');
      OPI_EDW_COGS_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date => to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') ,p_to_date  => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line(' End of Collect Discrete COGS Fact ');
    ELSIF l_fact_name = 'OPI_EDW_JOB_RSRC_F'  THEN
      edw_log.put_line(' ');
--      edw_log.put_line(' Start of Collect Process  Job Resource Fact ');
 /*     OPI_EDW_OPM_JOB_RSRC_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date =>to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') , p_to_date => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS') ); */
      IF retcode = '2' THEN
         APP_EXCEPTION.Raise_exception;
      END IF;
      edw_log.put_line(' ');
--      edw_log.put_line(' End of Collect Job Resource Fact');
      edw_log.put_line(' ');
      edw_log.put_line(' Start of Collect Discrete Job Resource Fact ');
      OPI_EDW_OPI_JOB_RSRC_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date => to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') ,p_to_date  => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line(' End of Collect Discrete Job Resource Fact ');
    ELSIF l_fact_name = 'OPI_EDW_JOB_DETAIL_F'  THEN
      edw_log.put_line(' ');
--      edw_log.put_line(' Start of Collect Process  Job Detail Fact ');
/*      OPI_EDW_OPM_JOB_DETAIL_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date =>to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') , p_to_date => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS') ); */
      IF retcode = '2' THEN
         APP_EXCEPTION.Raise_exception;
      END IF;
      edw_log.put_line(' ');
--      edw_log.put_line(' End of Collect Job Detail Fact');
      edw_log.put_line(' ');
      edw_log.put_line(' Start of Collect Discrete Job Detail Fact ');
      OPI_EDW_OPI_JOB_DETAIL_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date => to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') ,p_to_date  => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line(' End of Collect Discrete Job Detail Fact ');
    ELSIF l_fact_name = 'OPI_EDW_RES_UTIL_F'  THEN
      edw_log.put_line(' ');
--      edw_log.put_line(' Start of Collect Process Resource Utilization Fact ');
/*      OPI_EDW_OPM_RES_UTIL_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date =>to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') , p_to_date => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS') ); */
      IF retcode = '2' THEN
         APP_EXCEPTION.Raise_exception;
      END IF;
      edw_log.put_line(' ');
--      edw_log.put_line(' End of Collect Resource Utilization Fact');

      edw_log.put_line(' ');
      edw_log.put_line(' Start of Collect Discrete Resource Utilization Fact ');
      OPI_EDW_OPI_RES_UTIL_F_C.PUSH(Errbuf => Errbuf ,Retcode => Retcode , p_from_date => to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS') ,p_to_date  => to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));
      edw_log.put_line(' ');
      edw_log.put_line(' End of Collect Discrete Resource Utilization Fact ');
    ELSE
      edw_log.put_line(' ');
      edw_log.put_line(' Invalid Concurrent Program registration ');
    END IF;
  END PUSH;
END OPI_EDW_COLLECT_MBI_FACTS_F_C;

/
