--------------------------------------------------------
--  DDL for Package Body MSC_CL_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_FUNCTION" AS -- body
/* $Header: MSCCLFNB.pls 120.1 2005/10/20 01:42:49 abhikuma noship $ */

NULL_DBLINK                  CONSTANT VARCHAR2(1):= ' ';

PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
        null;
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

FUNCTION GET_ALL_ORGS ( p_org_group IN VARCHAR2,
   			p_instance_id IN NUMBER)
RETURN VARCHAR2 AS

        TYPE mastcurtyp IS REF CURSOR;
        c mastcurtyp;

        lv_sql_stmt   VARCHAR2(1000) := null;
	lv_in_org_str VARCHAR2(1000) := null;
	lc_ins_org    VARCHAR2(10)   :=null;
BEGIN

	   SELECT DECODE( M2A_DBLINK,
                        NULL, NULL_DBLINK,
                        '@'||M2A_DBLINK)
           INTO v_dblink
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= p_instance_id;


	lv_sql_stmt := 'select mp.organization_code org_code '
	               ||' from msc_instance_orgs ins , mtl_parameters'||v_dblink||'  mp '
	               ||' where ins.organization_id=mp.organization_id '
	               ||' and ins.enabled_flag=1 '
	               ||' and ins.org_group = :p_org_group '
	               ||' and ins.sr_instance_id = :p_instance_id ';


	OPEN c FOR lv_sql_stmt using p_org_group,p_instance_id;

	   LOOP

	     FETCH c into lc_ins_org;
	       EXIT WHEN c%NOTFOUND;

	       IF c%rowcount = 1 THEN
                 lv_in_org_str:= lc_ins_org;
               ELSE
                 lv_in_org_str := lv_in_org_str||','||lc_ins_org;
               END IF;

           END LOOP;

        CLOSE c;


    RETURN lv_in_org_str ;

END;


PROCEDURE  UPDATE_DATE_COLUMNS(ERRBUF               OUT NOCOPY VARCHAR2,
                              RETCODE              OUT NOCOPY NUMBER,
                              pINSTANCE_ID         IN  NUMBER,
                              pNUM_OF_DAYS         IN  NUMBER)
IS

lv_sql_tmp_stmt varchar2(4000);

Cursor c1(lv_msc_schema varchar2) is
SELECT flv.attribute2 table_name, atc.COLUMN_NAME column_name
         FROM all_tab_columns atc , fnd_lookup_values flv
      WHERE
	     flv.lookup_type='MSC_ODS_TABLE'
		 and flv.enabled_flag = 'Y' AND  flv.view_application_id = 700
         and flv.attribute11 is null   and flv.attribute12 is null
	     and upper(atc.TABLE_NAME) = flv.attribute2
        AND atc.OWNER = lv_msc_schema
        AND atc.DATA_TYPE = 'DATE'
        and flv.language=userenv('lang');

Cursor c2(lv_msc_schema varchar2) is
SELECT flv.attribute2 table_name, atc.COLUMN_NAME column_name
         FROM all_tab_columns atc , fnd_lookup_values flv
      WHERE
	     flv.lookup_type='MSC_ODS_TABLE'
		 and flv.enabled_flag = 'Y' AND  flv.view_application_id = 700
         and flv.attribute11='Y'   and flv.attribute12 is null
	     and upper(atc.TABLE_NAME) = flv.attribute2
        AND atc.OWNER = lv_msc_schema
        AND atc.DATA_TYPE = 'DATE'
        and flv.language=userenv('lang');


Cursor c3(lv_msc_schema varchar2) is
SELECT flv.attribute2 table_name, atc.COLUMN_NAME column_name
         FROM all_tab_columns atc , fnd_lookup_values flv
      WHERE
	     flv.lookup_type='MSC_ODS_TABLE'
		 and flv.enabled_flag = 'Y' AND  flv.view_application_id = 700
         and flv.attribute11='Y'   and flv.attribute12='Y'
	     and upper(atc.TABLE_NAME) = flv.attribute2
        AND atc.OWNER = lv_msc_schema
        AND atc.DATA_TYPE = 'DATE'
        and flv.language=userenv('lang');

lv_table_name varchar2(100);
lv_retval boolean;
lv_dummy1 varchar2(32);
lv_dummy2 varchar2(32);
lv_msc_schema varchar2(32);
lv_prod_short_name varchar2(32);

BEGIN
  lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(724);
  lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2,lv_msc_schema);
   lv_sql_tmp_stmt := null;
   lv_table_name   := null ;
 	FOR c_rec IN c1(lv_msc_schema) LOOP
	 IF lv_table_name is null or lv_table_name <> c_rec.table_name then
	    IF  lv_table_name is not null then
		     EXECUTE IMMEDIATE
               ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
              ||' SET  ' || lv_sql_tmp_stmt;
	 			 LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
          commit;
				 lv_sql_tmp_stmt := null;
			end if ;
	 		lv_table_name := c_rec.table_name;
	  END IF ;
	  IF lv_sql_tmp_stmt IS NULL THEN
        lv_sql_tmp_stmt := ' ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     ELSE
        lv_sql_tmp_stmt := lv_sql_tmp_stmt || ' , ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     END IF;
  END LOOP;
     EXECUTE IMMEDIATE
     ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
              ||' SET  ' || lv_sql_tmp_stmt;
    LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
    commit;

   lv_sql_tmp_stmt := null;
   lv_table_name   := null ;

 	FOR c_rec IN c2(lv_msc_schema) LOOP
	 IF lv_table_name is null or lv_table_name <> c_rec.table_name then
	    IF  lv_table_name is not null then
		     EXECUTE IMMEDIATE
               ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
              ||' SET  ' || lv_sql_tmp_stmt
              ||' WHERE SR_INSTANCE_ID = :pINSTANCE_ID '
       	USING pINSTANCE_ID;
	 			 LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
          commit;
				 lv_sql_tmp_stmt := null;
			end if ;
	 		lv_table_name := c_rec.table_name;
	  END IF ;

	  IF lv_sql_tmp_stmt IS NULL THEN
        lv_sql_tmp_stmt := ' ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     ELSE
        lv_sql_tmp_stmt := lv_sql_tmp_stmt || ' , ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     END IF;
  END LOOP;
    EXECUTE IMMEDIATE
		    ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
		    ||' SET  ' || lv_sql_tmp_stmt
		    ||' WHERE SR_INSTANCE_ID = :pINSTANCE_ID '
    USING pINSTANCE_ID;
   LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
          commit;


   lv_sql_tmp_stmt := null;
   lv_table_name   := null ;

 	FOR c_rec IN c3(lv_msc_schema) LOOP
	 IF lv_table_name is null or lv_table_name <> c_rec.table_name then
	    IF  lv_table_name is not null then
		      EXECUTE IMMEDIATE
               ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
              ||' SET  ' || lv_sql_tmp_stmt
              ||' WHERE SR_INSTANCE_ID = :pINSTANCE_ID '
              ||' AND PLAN_ID = -1 '
         	USING pINSTANCE_ID;
	 			 LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
          commit;
				 lv_sql_tmp_stmt := null;
			end if ;
	 		lv_table_name := c_rec.table_name;
	  END IF ;

	  IF lv_sql_tmp_stmt IS NULL THEN
        lv_sql_tmp_stmt := ' ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     ELSE
        lv_sql_tmp_stmt := lv_sql_tmp_stmt || ' , ' || c_rec.column_name || ' = '||c_rec.column_name || ' + ' || pNUM_OF_DAYS;
     END IF;
  END LOOP;
    EXECUTE IMMEDIATE
               ' UPDATE /*+ PARALLEL('|| lv_table_name || ') */ ' || lv_table_name
              ||' SET  ' || lv_sql_tmp_stmt
              ||' WHERE SR_INSTANCE_ID = :pINSTANCE_ID '
              ||' AND PLAN_ID = -1 '
     USING pINSTANCE_ID;
   LOG_MESSAGE('Table Updated :   ' || lv_table_name || ' row updated : '|| SQL%ROWCOUNT );
          commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    LOG_MESSAGE('An error has occurred when updating the Date columns.');
    LOG_MESSAGE(SQLERRM);
    RETCODE := G_ERROR;

END UPDATE_DATE_COLUMNS;


END MSC_CL_FUNCTION;

/
