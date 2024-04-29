--------------------------------------------------------
--  DDL for Package Body GMP_FORM_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_FORM_EFF_PKG" as
/* $Header: GMPDLEFB.pls 115.6 2003/03/21 16:52:29 sgidugu noship $ */

/* Put Global variables , type decalrations here  */


/*=========================================================================
| PROCEDURE NAME                                                           |
|    delete_eff_rows                                                       |
|                                                                          |
| TYPE                                                                     |
|    public                                                                |
|                                                                          |
| DESCRIPTION                                                              |
| Input Parameters                                                         |
|    p_validate - Indicate whether to evaluate if the rows to be deleted   |
|                 are under use in any plan in aps or not                  |
| Output Parameters                                                        |
|    errbuf - Standard Conc prgm parameter                                 |
|    retcode - Standard Conc prgm parameter                                |
| HISTORY                                                                  |
|        18-nov-2002 Abhay Satpute Created                                 |
|                                                                          |
 ==========================================================================*/

PROCEDURE delete_eff_rows( errbuf       OUT NOCOPY VARCHAR2,
                           retcode      OUT NOCOPY NUMBER,
                           p_validate   IN NUMBER) IS
l_date_cnt               INTEGER := 0 ;
at_msc_dblink            VARCHAR2(32) ;
l_instance_id            NUMBER ;
cur_date                 DATE ;

Cursor cur_creation_dates IS
 SELECT distinct creation_date
 FROM gmp_form_eff
 ORDER BY creation_date DESC ;
 /* order by desc so that data for last extract is NOT deleted */

BEGIN

IF p_validate = 1 THEN
 SELECT a2m_dblink, instance_id
 INTO at_msc_dblink , l_instance_id
 FROM mrp_ap_apps_instances ;
END IF ;

IF at_msc_dblink is NOT NULL THEN
 at_msc_dblink := '@'||at_msc_dblink ;
END IF ;

OPEN cur_creation_dates ;
LOOP
   FETCH cur_creation_dates INTO cur_date ;
   EXIT WHEN cur_creation_dates%NOTFOUND ;
   -- Give a message if there are No rows to delete
   IF trunc(cur_date) = trunc(sysdate)
   THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Cannot delete rows for the Current Date  -->  '||cur_date);
   END IF;
   IF l_date_cnt >= 1 THEN
     -- let the same vars be updated by child proc
     delete_data(errbuf, retcode ,cur_date,p_validate, at_msc_dblink , l_instance_id) ;
   END IF ;
   l_date_cnt := l_date_cnt + 1 ;
   /* simply loops through without deleting the data for first record
      By doing this way, we are NOT deleting the latest record even if
      Validation is given 'No'
   */
END LOOP;

CLOSE cur_creation_dates ;
 retcode := 0 ;

EXCEPTION
   WHEN Others Then
      errbuf := sqlcode ||' - '||sqlerrm;
      retcode := -1 ;

END delete_eff_rows;


/*=========================================================================
| PROCEDURE NAME                                                           |
|    delete_data                                                           |
|                                                                          |
| TYPE                                                                     |
|    Private                                                               |
|                                                                          |
| DESCRIPTION                                                              |
| Input Parameters                                                         |
|    p_cur_date - creation date for which rows are being deleted           |
|    p_validate - whether to evaluate use of these rows in aps plans       |
|    p_dblink   - passed in from calling proc to be used to make qry       |
|    p_instance_id - used in qry to determine rows of the same instance    |
|                                                                          |
| Output Parameters                                                        |
|                                                                          |
| HISTORY                                                                  |
|        18-nov-2002 Abhay Satpute Created                                 |
|                                                                          |
 ==========================================================================*/
PROCEDURE delete_data ( errbuf       OUT NOCOPY VARCHAR2,
                       retcode      OUT NOCOPY NUMBER,
                       p_cur_date  IN DATE ,
                       p_validate  IN NUMBER ,
                       p_dblink    IN VARCHAR2,
                       p_instance_id IN NUMBER )IS

rows_deleted             NUMBER := 1 ;
total_rows_deleted       NUMBER := 0 ;
eff_in_use               INTEGER := 0 ;
statement1               VARCHAR2(2000) ;
statement2               VARCHAR2(2000) ;
statement3               VARCHAR2(2000) ;
v_plan_name              VARCHAR2(10);
v_plan_id                 NUMBER(10);
v_eff_id                 NUMBER(10);
excp_eff_in_use          EXCEPTION ;

TYPE ref_cursor_typ IS REF CURSOR;
cur_in_use ref_cursor_typ ;
Cur_plan_name ref_cursor_typ ;
Cur_plan_name2 ref_cursor_typ ;

BEGIN

IF p_validate = 1 THEN    /* Validate = 'Yes' */
   statement1 :=  'SELECT 1 '
              || ' FROM dual '
              || ' WHERE EXISTS (SELECT 1 from '
              || ' msc_process_effectivity'||p_dblink||' mpe ,gmp_form_eff ge'
              || ' where (ge.aps_fmeff_id*2 + 1) = mpe.bill_sequence_id '
              || ' and mpe.sr_instance_id =  :p_instance_id '
              || ' and mpe.plan_id =  -1 '
              || ' and trunc(ge.creation_date) = :p_cur_date  )' ;

   OPEN cur_in_use FOR statement1 USING p_instance_id, trunc(p_cur_date) ;
   FETCH cur_in_use INTO eff_in_use ;
   CLOSE cur_in_use ;

   IF nvl(eff_in_use,0) = 1 THEN
--
   statement2 :=   ' SELECT distinct mp.compile_designator '
                  || ' from '
                  || ' msc_process_effectivity'||p_dblink||' mpe , '
                  || ' msc_plans'||p_dblink||' mp , '
                  || ' gmp_form_eff ge'
                  || ' where mpe.plan_id = mp.plan_id '
                  || ' and mpe.plan_id <> -1 '
                  || ' and (ge.aps_fmeff_id*2 + 1) = mpe.bill_sequence_id '
                  || ' and mpe.sr_instance_id =  :p_instance_id '
                  || ' and trunc(ge.creation_date) = :p_cur_date  ' ;

        OPEN Cur_plan_name FOR statement2 USING p_instance_id,trunc(p_cur_date);
        LOOP
           FETCH Cur_plan_name INTO v_plan_name;
           EXIT WHEN Cur_plan_name%NOTFOUND;
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows Exist in gmp_form_eff table, cannot delete effectivities for the following Plans -->  '||v_plan_name);
        END LOOP;
        CLOSE Cur_plan_name ;

      RAISE excp_eff_in_use ;

   END IF ; /* End if for eff_in_use check */
--
ELSIF p_validate = 2
THEN
        statement3 :=   ' SELECT distinct mp.compile_designator '
                  || ' from '
                  || ' msc_process_effectivity'||p_dblink||' mpe , '
                  || ' msc_plans'||p_dblink||' mp , '
                  || ' gmp_form_eff ge'
                  || ' where mpe.plan_id = mp.plan_id '
                  || ' and mpe.plan_id <> -1 '
                  || ' and (ge.aps_fmeff_id*2 + 1) = mpe.bill_sequence_id '
                  || ' and mpe.sr_instance_id =  :p_instance_id '
                  || ' and trunc(ge.creation_date) = :p_cur_date  ' ;

        OPEN Cur_plan_name2 FOR statement3 USING p_instance_id,trunc(p_cur_date);
        LOOP
           FETCH Cur_plan_name2 INTO v_plan_name;
           EXIT WHEN Cur_plan_name2%NOTFOUND;
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Effectivities for the following Plans have been deleted -->  '||v_plan_name);
        END LOOP;
        CLOSE Cur_plan_name2 ;

END IF ; /* End if for Validate Flag check */

WHILE (rows_deleted >0 )
LOOP
 Delete from gmp_form_eff
 where creation_date = p_cur_date
 and rownum < 501 ;

 rows_deleted := SQL%ROWCOUNT ;
 total_rows_deleted := total_rows_deleted + rows_deleted  ;

 commit ;
 -- We can put further optimize on this
  IF rows_deleted < 500 THEN
    EXIT ;
  END IF ;
END LOOP;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of rows Successfully deleted from collection run on '||to_char(p_cur_date,'DD-MON-YYYY HH24:MI:SS')||'= '||total_rows_deleted);

EXCEPTION
    WHEN excp_eff_in_use THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG,'Rows Exist in gmp_form_eff table '||v_plan_name||'-'||p_cur_date);
      NULL ;
    WHEN others THEN
      errbuf := sqlcode ||' - '||sqlerrm;
      retcode := -2 ;
END delete_data;

END gmp_form_eff_pkg;


/
