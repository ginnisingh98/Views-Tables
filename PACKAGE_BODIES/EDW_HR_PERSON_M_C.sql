--------------------------------------------------------
--  DDL for Package Body EDW_HR_PERSON_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_HR_PERSON_M_C" AS
/* $Header: hrieppsn.pkb 120.1 2005/06/07 05:59:25 anmajumd noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;

 g_instance_code      VARCHAR2(30);  -- Holds source instance

 g_number_of_levels  NUMBER := 15;  -- For Supervisor Hierarchies

/********************************************************************/
/* This procedure dynamically builds a sql statement to insert rows */
/* into the given supervisor hierarchy level table from the given   */
/* level collection view                                            */
/********************************************************************/
Procedure Do_Insert( p_tree_number  IN NUMBER,
                     p_from_level   IN NUMBER,
                     p_to_level     IN NUMBER,
                     p_from_date    IN DATE,
                     p_to_date      IN DATE)
IS

  l_sql_stmt    VARCHAR2(2000); -- Holds SQL Statement to be executed
  l_ret_code    NUMBER;         -- Keeps return code of sql execution

  l_from_view   VARCHAR2(50);  -- Name of the collection view
  l_to_table    VARCHAR2(50);  -- Name of the staging table

  l_pk_column   VARCHAR2(30);  -- Staging table pk column
  l_fk_column   VARCHAR2(30);  -- Staging table fk column
  l_pk_value    VARCHAR2(60);  -- Pk value selected from collection view
  l_fk_value    VARCHAR2(60);  -- Fk value selected from collection view

  l_na_edw_pk  VARCHAR2(30);  -- Primary key for dummy row
  l_na_edw_fk  VARCHAR2(30);  -- Foreign key for dummy row

  l_push_from_level          VARCHAR2(30);  -- Push from level name
  l_push_down_name           VARCHAR2(400); -- Name format for push down level
  l_standard_name            VARCHAR2(400); -- Name format for non push down levels
  l_push_down_name_display   VARCHAR2(400); -- Display Name format for push down level
  l_standard_name_display    VARCHAR2(400); -- Display Name format for non push down levels

  l_temp_date        DATE;         -- Keeps track of execution start time
  l_duration         NUMBER := 0;  -- Execution time
  l_rows_inserted    NUMBER := 0;  -- Number of rows inserted

BEGIN

/* Construct the table, view and level names */
/*********************************************/

  l_from_view := 'EDW_HR_PERM_SPSR1_L' || p_from_level || '_LCV@APPS_TO_APPS';

  l_to_table  := 'EDW_HR_PERM_SPSR1_L' || p_to_level || '_LSTG@EDW_APPS_TO_WH';

  l_push_from_level := 'PERM_SPSR1_L' || p_from_level ;


/* Construct the primary and foreign key names from the staging table */
/**********************************************************************/
  l_pk_column := 'SPRVSR_LVL' || p_to_level || '_PK';

  /* If top level staging table then fk column is ALL */
  IF (p_to_level = g_number_of_levels) THEN
    l_fk_column := 'ALL_FK';
  ELSE
    l_fk_column := 'SPRVSR_LVL' || to_char(p_to_level+1) || '_FK';
  END IF;


/* Construct the primary and foreign key names from the collection view */
/************************************************************************/
/* If straight push, then staging table columns match collection view columns */
  IF (p_from_level = p_to_level) THEN
    l_pk_value := 'lvln.' || l_pk_column;
    l_fk_value := 'NVL(lvln.' || l_fk_column || ',''NA_EDW'')';
/* Otherwise append "-TnLm" tag for push down and get push lookup */
  ELSE
    l_pk_value := 'lvln.SPRVSR_LVL' || p_from_level || '_PK || ''-TL'
                  || p_from_level || '''';

  /* If only pushing down 1 level, then point to pk of level above */
    IF (p_to_level = p_from_level - 1) THEN
      l_fk_value := 'lvln.SPRVSR_LVL' || p_from_level || '_PK';

  /* Otherwise point to pk plus tag of level above */
    ELSE
      l_fk_value := l_pk_value;
    END IF;
  END IF;

/* Construct the primary and foreign key names for the dummy rows */
/******************************************************************/

  l_na_edw_pk := to_char(p_from_level) || '-NA_EDW-' || g_instance_code;

/* If highest level set foreign key to 'ALL' */
  IF (p_from_level = 15) THEN
    l_na_edw_fk := 'ALL';
  ELSE
    l_na_edw_fk :=  to_char(p_from_level+1) || '-NA_EDW-' || g_instance_code;
  END IF;

/******************************************************************************/
/*                 Standard  "Name" column format                             */
/******************************************************************************/
   l_standard_name := 'DECODE(peo.known_as||peo.first_name,NULL,'''',
                              NVL(peo.known_as,peo.first_name)||'' '')
                        ||peo.last_name ||
                       ''(''||NVL(peo.employee_number,
                                  peo.applicant_number)||'')''';
   l_standard_name_display :=
                   'DECODE(peo.known_as||peo.first_name,NULL,'''',
                   NVL(peo.known_as,peo.first_name)||'' '')
                       ||peo.last_name';
/******************************************************************************/
/*                 Push down level "Name" column format                       */
/******************************************************************************/
   l_push_down_name := 'DECODE(peo.known_as||peo.first_name,NULL,'''',
                   NVL(peo.known_as,peo.first_name)||'' '')
                       ||peo.last_name ||
                       ''(''||NVL(peo.employee_number,
                                  peo.applicant_number)'||
                       '||'')-' ||TO_CHAR(16-p_from_level)||'''';
   l_push_down_name_display :=
                   'DECODE(peo.known_as||peo.first_name,NULL,'''',
                   NVL(peo.known_as,peo.first_name)||'' '')
                       ||peo.last_name';
/******************************************************************************/
/* BUILD UP THE SQL STATEMENT                                                 */
/******************************************************************************/

/* Not a push down - straight insert */
/*************************************/
  IF (p_from_level = p_to_level) THEN

    l_sql_stmt :=
'Insert Into ' || l_to_table || '(
 assignment_id,
 collection_status,
 creation_date,
 error_code,
 instance,
 last_update_date,
 name,
 name_display,
 operation_code,
 person_id,
 request_id,
 row_id,
 sprvsr_dp,
 ' || l_pk_column || ',
 ' || l_fk_column || ',
 user_attribute1,
 user_attribute2,
 user_attribute3,
 user_attribute4,
 user_attribute5)
select
 lvln.assignment_id,
 ''READY'',
 sysdate,
 null,
 lvln.INSTANCE,
 sysdate,
 '||l_standard_name||',
 '||l_standard_name_display||',
 to_char(null),
 lvln.person_id,
 to_number(null),
 to_char(null),
 lvln.sprvsr_dp,
 ' || l_pk_value || ',
 ' || l_fk_value || ',
 lvln.user_attribute1,
 lvln.user_attribute2,
 lvln.user_attribute3,
 lvln.user_attribute4,
 lvln.user_attribute5
from ' || l_from_view || ' lvln,
 per_all_people_f peo
where peo.person_id = lvln.person_id
 and SYSDATE between peo.effective_start_date and peo.effective_end_date
UNION ALL
select
 to_number(null),
 ''READY'',
 sysdate,
 null,
 null,
 sysdate,
 null,
 null,
 to_char(null),
 to_number(null),
 to_number(null),
 to_char(null),
 null,
 ''' || l_na_edw_pk || ''',
 ''' || l_na_edw_fk || ''',
 null,
 null,
 null,
 null,
 null
from dual';

/******************************************************************************/
/* Push Down from a higher level                                              */
/******************************************************************************/
  ELSE
    l_sql_stmt := 'Insert Into ' || l_to_table || '(
        assignment_id,
        collection_status,
        creation_date,
        error_code,
        instance,
        last_update_date,
        name,
        name_display,
        operation_code,
        person_id,
        request_id,
        row_id,
        sprvsr_dp,
        ' || l_pk_column || ',
        ' || l_fk_column || ',
        user_attribute1,
        user_attribute2,
        user_attribute3,
        user_attribute4,
        user_attribute5
        )
     select lvln.assignment_id,
        ''READY'',
        sysdate,
        to_char(null),   -- error code
        lvln.INSTANCE,
        sysdate,
        ' || l_push_down_name || ',
        ' || l_push_down_name_display || ',
        to_char(null),   -- operation_code
        lvln.person_id,
        to_number(null), -- request_id
        to_char(null),   -- row_id
        ' || l_push_down_name || ',
        ' || l_pk_value || ',
        ' || l_fk_value || ',
        lvln.user_attribute1,
        lvln.user_attribute2,
        lvln.user_attribute3,
        lvln.user_attribute4,
        lvln.user_attribute5
     from ' || l_from_view || ' lvln,
          per_all_people_f peo
     where lvln.NAME is not null
     and   peo.person_id = lvln.person_id
     and   SYSDATE between peo.effective_start_date and
                           peo.effective_end_date
';

  END IF;

  edw_log.put_line( 'Pushing Supervisor Hierarchy Level ' ||
                    p_from_level || ' to Level ' || p_to_level );

  l_temp_date := SYSDATE;
  -- edw_log.put_line(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt;

  l_rows_inserted := sql%rowcount;

  l_duration := sysdate - l_temp_date;

Commit;

  edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
  ' rows into the ' || l_to_table || ' staging table');

  edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
  edw_log.put_line(' ');

End Do_Insert;


/********************************************************************************/
/* New supervisor hierarchy inserted by HRI                                     */
/********************************************************************************/

Procedure Push_Tree( p_from_date         IN DATE,
                     p_to_date           IN DATE,
                     p_tree              IN NUMBER )
IS
BEGIN

/****************************************************/
/* Collect levels in the following order            */
/*  From view level 1  to table level 1             */
/*  From view level 2  to table level 1             */
/*   - - -          - - -       - - -               */
/*  From view level 15 to table level 1             */
/*  From view level 2  to table level 2             */
/*  From view level 3  to table level 2             */
/*   - - -          - - -       - - -               */
/*  From view level 15 to table level 2             */
/*   - - -          - - -       - - -               */
/*  From view level 14 to table level 14            */
/*  From view level 15 to table level 14            */
/*  From view level 15 to table level 15            */
/****************************************************/

  FOR v_push_to_level IN 1..g_number_of_levels LOOP

    edw_log.put_line('Starting Push_EDW_HR_PERM_SPSR_' || v_push_to_level || '_LSTG');
    edw_log.put_line(' ');

    FOR v_push_from_view IN v_push_to_level..g_number_of_levels LOOP

        Do_Insert( p_tree_number  => p_tree,
                   p_from_level   => v_push_from_view,
                   p_to_level     => v_push_to_level,
                   p_from_date    => p_from_date,
                   p_to_date      => p_to_date );

    END LOOP;

  END LOOP;

END Push_Tree;

/********************************************************************************/

 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_dimension_name   Varchar2(30) :='EDW_HR_PERSON_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

 l_check_sprvsr_id          number:=0;

 cursor cur_check_sprvsr_hrchy is
 select supv_person_id
 from hri_supv_hrchy_summary;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
    Return;
  END IF;

  IF (p_from_date IS NULL) THEN
		EDW_HR_PERSON_M_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
		EDW_COLLECTION_UTIL.g_offset;
  ELSE
	EDW_HR_PERSON_M_C.g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
		EDW_HR_PERSON_M_C.g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
	EDW_HR_PERSON_M_C.g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;


   edw_log.put_line( 'The collection range is from '||
        to_char(EDW_HR_PERSON_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_HR_PERSON_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');


-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

/*************************************************/
/* New changes implemented by HRI                */
/* 10 Levels inserted                            */
/*************************************************/

   edw_log.put_line( 'About to call Supervisor Hierarchy summary table population routine' );
   hri_struct_summary.load_all_sup_hierarchies;

   open cur_check_sprvsr_hrchy;
   fetch cur_check_sprvsr_hrchy into l_check_sprvsr_id;

/* Bug 3440848 - always collect supervisor tree */
/* Moved it outside cursor check */
   if cur_check_sprvsr_hrchy%ISOPEN then
        if cur_check_sprvsr_hrchy%NOTFOUND then
            edw_log.put_line( 'Supervisor hierarchy is empty' );
        else
            edw_log.put_line( 'hri_struct_summary.load_all_sup_hierarchies completed OK.' );
        end if;
    end if;

    edw_log.put_line( ' ' );
    edw_log.put_line( 'About to call Supervisor Tree routine' );
    edw_log.put_line( ' ' );

    EDW_HR_PERSON_M_C.Push_Tree(
       p_from_date         =>  g_push_date_range1,
       p_to_date           =>  g_push_date_range2,
       p_tree              =>  1 );

    edw_log.put_line( ' Supervisor Tree routine completed ok' );
    edw_log.put_line( ' ' );

/*************************************************/

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;

        Push_EDW_HR_PERM_ASSIGN_LSTG(EDW_HR_PERSON_M_C.g_push_date_range1, EDW_HR_PERSON_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Total rows inserted : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2 );
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_HR_PERSON_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_HR_PERSON_M_C.g_exception_msg, g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_HR_PERM_ASSIGN_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;
BEGIN
   edw_log.put_line('Starting Push_EDW_HR_PERM_ASSIGN_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;
   Insert Into
    EDW_HR_PERM_ASSIGN_LSTG@EDW_APPS_TO_WH(
    ASSIGNMENT_PK,
    BUSINESS_GROUP,
    CREATION_DATE,
    END_DATE,
    INSTANCE,
    LAST_UPDATE_DATE,
    NAME,
    NAME_DISPLAY,
    START_DATE,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NATIONAL_IDENTIFIER,
    PERSON_DP,
    PERSON_ID,
    PERSON_NUM,
    PLANNER_CODE,
    PLANNER_FLAG,
    PREVIOUS_LAST_NAME,
    REGION_OF_BIRTH,
    REHIRE_RCMMNDTN,
    RESUME_EXISTS,
    RESUME_UPDATED_DATE,
    SALESREP_ID,
    SALES_REP_FLAG,
    STUDENT_STATUS,
    SYS_GEN_FLAG,
    TITLE,
    TOWN_OF_BIRTH,
    ALL_FK,
    SPRVSR_LVL1_FK,
    BUYER_FLAG,
    COUNTRY_OF_BIRTH,
    CRRSPNDNC_LANGUAGE,
    DATE_EMP_DATA_VRFD,
    DATE_OF_BIRTH,
    DISABILITY_FLAG,
    EFFECTIVE_END_DATE,
    EFFECTIVE_START_DATE,
    EMAIL_ADDRESS,
    FAST_PATH_EMPLOYEE,
    FIRST_NAME,
    FTE_CAPACITY,
    FULL_NAME,
    GENDER,
    GLOBAL_PERSON_ID,
    INTERNAL_LOCATION,
    KNOWN_AS,
    LAST_NAME,
    MAILSTOP,
    MARITAL_STATUS,
    MIDDLE_NAMES,
    NAME_PREFIX,
    NAME_SUFFIX,
    NATIONALITY,
    OPERATION_CODE,
    COLLECTION_STATUS,
/* New for 115.1 */
    EMPLOYEE_FLAG,
    APPLICANT_FLAG)
   select plcv.ASSIGNMENT_PK,
plcv.BUSINESS_GROUP,
plcv.CREATION_DATE,
plcv.END_DATE,
plcv.INSTANCE,
plcv.LAST_UPDATE_DATE,
/***************************************************/
/* The Name string is reformatted here and the     */
/* name attribute from the LCV is ignored.  This   */
/* is to facilitate easy changing of how this      */
/* string is constructed.                          */
/***************************************************/
DECODE(plcv.person_id,NULL,plcv.name,
  DECODE(plcv.known_as||plcv.first_name,NULL,'',
       NVL(plcv.known_as,plcv.first_name)||' ')
        ||plcv.last_name || '('||plcv.person_num||')'
      )                                         NAME,
DECODE(plcv.person_id,NULL,plcv.name,
  DECODE(plcv.known_as||plcv.first_name,NULL,'',
       NVL(plcv.known_as,plcv.first_name)||' ')
        ||plcv.last_name
         )                                      NAME_DISPLAY,
plcv.START_DATE,
plcv.USER_ATTRIBUTE1,
plcv.USER_ATTRIBUTE2,
plcv.USER_ATTRIBUTE3,
plcv.USER_ATTRIBUTE4,
plcv.USER_ATTRIBUTE5,
plcv.NATIONAL_IDENTIFIER,
plcv.PERSON_DP,
plcv.PERSON_ID,
plcv.PERSON_NUM,
plcv.PLANNER_CODE,
plcv.PLANNER_FLAG,
plcv.PREVIOUS_LAST_NAME,
plcv.REGION_OF_BIRTH,
plcv.REHIRE_RCMMNDTN,
plcv.RESUME_EXISTS,
plcv.RESUME_UPDATED_DATE,
plcv.SALESREP_ID,
plcv.SALES_REP_FLAG,
plcv.STUDENT_STATUS,
plcv.SYS_GEN_FLAG,
plcv.TITLE,
plcv.TOWN_OF_BIRTH,
NVL(plcv.ALL_FK, 'NA_EDW'),
plcv.SPRVSR_LVL1_FK,
plcv.BUYER_FLAG,
plcv.COUNTRY_OF_BIRTH,
plcv.CRRSPNDNC_LANGUAGE,
plcv.DATE_EMP_DATA_VRFD,
plcv.DATE_OF_BIRTH,
plcv.DISABILITY_FLAG,
plcv.EFFECTIVE_END_DATE,
plcv.EFFECTIVE_START_DATE,
plcv.EMAIL_ADDRESS,
plcv.FAST_PATH_EMPLOYEE,
plcv.FIRST_NAME,
plcv.FTE_CAPACITY,
plcv.FULL_NAME,
plcv.GENDER,
plcv.GLOBAL_PERSON_ID,
plcv.INTERNAL_LOCATION,
plcv.KNOWN_AS,
plcv.LAST_NAME,
plcv.MAILSTOP,
plcv.MARITAL_STATUS,
plcv.MIDDLE_NAMES,
plcv.NAME_PREFIX,
plcv.NAME_SUFFIX,
plcv.NATIONALITY,
    NULL, -- OPERATION_CODE
    'READY',
plcv.EMPLOYEE_FLAG,
plcv.APPLICANT_FLAG
   from EDW_HR_PERM_ASSIGN_LCV@APPS_TO_APPS plcv
   where plcv.last_update_date between l_date1 and l_date2;
--
   l_rows_inserted := sql%rowcount;
   EDW_HR_PERSON_M_C.g_row_count := EDW_HR_PERSON_M_C.g_row_count + l_rows_inserted ;
   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
' rows into the EDW_HR_PERM_ASSIGN_LSTG staging table');
   edw_log.put_line('Commiting records for EDW_HR_PERM_ASSIGN_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_HR_PERM_ASSIGN_LSTG');
 Exception When others then
   raise;
commit;
END;

BEGIN

SELECT instance_code INTO g_instance_code
FROM edw_local_instance;

End EDW_HR_PERSON_M_C;

/
