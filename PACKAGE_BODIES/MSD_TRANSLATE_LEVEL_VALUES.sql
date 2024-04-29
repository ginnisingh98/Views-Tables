--------------------------------------------------------
--  DDL for Package Body MSD_TRANSLATE_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_TRANSLATE_LEVEL_VALUES" AS
/* $Header: msdtlvlb.pls 120.2 2006/07/12 05:42:11 sjagathe noship $ */

/* Debug */
C_DEBUG               Constant varchar2(1) := 'Y';



/* Private API */
procedure log_debug( pBUFF  in varchar2)
 is
 begin

         if C_MSC_DEBUG = 'Y' then
            fnd_file.put_line( fnd_file.log, pBUFF);
         else
            null;
            --dbms_output.put_line( pBUFF);
         end if;

 end log_debug;

 PROCEDURE LOG_MESSAGE( pBUFF           IN  VARCHAR2)
 IS
 BEGIN

            FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

 END LOG_MESSAGE;

Procedure ins( a in varchar2) is
Begin
/*  Debugging Code
  insert into msd_test values ('VM' || to_char(sysdate, 'hh24:mi') || ' ' || a);
  commit;
*/
null;
End;



PROCEDURE CREATE_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_source_table              IN  VARCHAR2,
                        p_dest_table                IN  VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER,
                        p_delete_flag               IN  VARCHAR2);

PROCEDURE DELETED_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
                        p_seq_num                   IN  NUMBER);

PROCEDURE  UPDATE_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
                        p_seq_num                   IN  NUMBER);



PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER);


PROCEDURE  PROCESS_LEVEL_ASSOCIATION(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER);


PROCEDURE  PROCESS_TOP_LEVEL_VALUES (
                       errbuf              		OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_instance_id       		IN  VARCHAR2,
			p_parent_level_id   		IN  NUMBER,
			p_parent_value_column		IN  VARCHAR2,
			p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2);



PROCEDURE CREATE_DELETED_LEVEL_ASSOCI(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER);

PROCEDURE CREATE_DELETED_LEVEL_VALUES(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER );

/* Populates the Working and Non-working days for
 * each specific Organization. This is called for
 * the Organization level only.
 *
 *
 */

PROCEDURE POP_ORG_CAL_ASSOCIATIONS (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_source_table                  IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_instance_id                   IN  NUMBER);


/* Populates the relationships between levels and organizations.
 */

PROCEDURE POP_ORG_LVL_ASSOCIATIONS (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_lvl_id                        IN  NUMBER,
                        p_source_table                  IN  VARCHAR2,
                        p_org_relationship_view         IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_instance_id                   IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2);

/* Stores the maximum refresh number for level values collections
 */

PROCEDURE POP_MAX_SEQ_NUM (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_seq_num                       IN  NUMBER);



Procedure show_line(p_sql in    varchar2);


Procedure debug_line(p_sql in    varchar2);



/* Public API */
procedure translate_level_parent_values(
                        errbuf              		OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_instance_id       		IN  NUMBER,
			p_level_id	    		IN  NUMBER,
			p_level_value_column 		IN  VARCHAR2,
			p_level_value_pk_column 	IN  VARCHAR2,
                        p_level_value_desc_column       IN  VARCHAR2,
			p_parent_level_id   		IN  NUMBER,
			p_parent_value_column		IN  VARCHAR2,
			p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
                        p_update_lvl_table              IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER ) IS
                        --,p_launched_from                 IN  NUMBER ) IS     --jarorad

v_instance_id    varchar2(40);
v_retcode        number;
v_sql_stmt       varchar2(4000);
v_sql_stmt1      varchar2(1000) :=to_char(NULL);        --jarorad

v_sql_stmt3      varchar2(2000);                         --jarorad
v_sql_stmt4      varchar2(2000);                        --jarorad

v_count1          number :=0;                            --jarorad
v_count2          number :=0;                            --jarorad
v_dest_ass_table    varchar2(240) ;
v_sr_ass_table    varchar2(240) ;
v_parent_lvl_type varchar2(3);
v_lvl_type	varchar2(1);
v_dim_code	varchar2(3);
v_org_view      varchar2(30);
v_up	number;
x_dblink VARCHAR2(128);

v_table_name   varchar2(100);

Begin

log_debug('In procedure TRANSLATE_LEVEL_PARENT_VALUE');
debug_line('In translate_level_parent_value');

v_up := p_update_lvl_table;
ins('In Translate' || p_level_id || ' ' || p_parent_level_id);
debug_line('In Translate   LEVEL_ID   :' || p_level_id || '  PARENT_LEVEL_ID   :' || p_parent_level_id);

   retcode :=0;

   Savepoint Before_Delete ;

   /* Beginning of IF 1 */
   IF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE) THEN

         v_dest_ass_table := MSD_COMMON_UTILITIES.LEVEL_ASSOC_FACT_TABLE ;
         v_sr_ass_table := MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE ;

         /* First time to process this level_id */
         IF (p_update_lvl_table = 1) THEN
             /* Insert deleted level values into deleted_level_value table and delete it
                from the fact level value table */
             /* For Incremental Level Value Collection, p_delete_flag = 'N'
                So, we don't delete existing level values */
             IF (p_delete_flag = 'Y') THEN
                 CREATE_DELETED_LEVEL_VALUES( errbuf,
                                              retcode,
                                              p_instance_id,
                                              p_level_id,
                                              p_seq_num);
             END IF;

             /* Process row by row from staging level values table */
             PROCESS_LEVEL_VALUE_PER_ROW( errbuf,
                                          retcode,
                                          p_instance_id,
			                  p_level_id,
                                          p_seq_num);
         END IF;

         /* Insert deleted level associations into deleted level association table
            and delete it from the existing fact level associations table */
         /* For Incremental Level Value Collection, p_delete_flag = 'N'
                So, we don't delete existing level values */
         IF (p_delete_flag = 'Y') THEN
             CREATE_DELETED_LEVEL_ASSOCI(       errbuf,
                                                retcode,
                                                p_instance_id,
                                                p_level_id,
                                                p_parent_level_id,
                                                p_seq_num);
         END IF;

         /* Process from staging level associations table */
         PROCESS_LEVEL_ASSOCIATION(
                                    errbuf,
                                    retcode,
                                    p_instance_id,
			            p_level_id,
                                    p_parent_level_id,
                                    p_seq_num);

   /* ELSE for IF 1.  COLLECTION */
   ELSIF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) THEN

     log_debug(' Entering Collect Level values Condition');

         v_dest_ass_table := MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE;

         /* Delete Staging Table only if delete flag = Yes */
         IF (p_delete_flag = 'Y') THEN
              /* First time to process this level_id */
              IF (p_update_lvl_table = 1) THEN
                   DELETE FROM msd_st_level_values
                   WHERE instance = p_instance_id AND level_id = p_level_id;
              END IF;

              DELETE FROM msd_st_level_associations
              WHERE instance = p_instance_id AND
                    level_id = p_level_id AND parent_level_id = p_parent_level_id;
         END IF;


   /* Logic to figure out if the source view contains the relevant columns required for
      Sales and Operation Planning */

         /* Get the x_dblink from p_instance_id */
             msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);

         /* Check for errors in getting the db link */

            if (retcode = -1) then

                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;

            end if;

         select substr(p_source_table,1,decode(instr(p_source_table,'@')-1,-1,length(p_source_table),instr(p_source_table,'@')-1))
         INTO v_table_name from dual;


         BEGIN
         v_count1 :=0;

         v_sql_stmt3 :=   ' select count(*) '
                        ||' from sys.all_tab_columns'|| x_dblink ||
                        ' where table_name = '''||v_table_name||''' and column_name = ''SYSTEM_ATTRIBUTE1'' ';

         log_debug('statement before exec :'||v_sql_stmt3);

         EXECUTE IMMEDIATE v_sql_stmt3 INTO v_count1;


         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                   v_count1 := 0;
            WHEN OTHERS THEN
                  v_count1 := 0;
         END;


         BEGIN
         v_count2 :=0;


         v_sql_stmt4 :=   ' select count(*) '
                        ||' from sys.all_tab_columns'|| x_dblink ||
                        ' where table_name = '''||v_table_name||''' and column_name = ''DP_ENABLED_FLAG'' ';

         log_debug('statement before exec :'||v_sql_stmt4);

         EXECUTE IMMEDIATE v_sql_stmt4 INTO v_count2;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                    v_count2 := 0;
             WHEN OTHERS THEN
                    v_count2 := 0;
         END;





         log_debug('Source table Name :'||p_source_table);
         log_debug('value of v_count1  :'||v_count1);
         log_debug('value of v_count2  :'||v_count2);

/*
         --What should happen if TPClass(GEO), TPZone(GEO) and PF(PRD) hierarchies are customized?

          -- Do we need to make this code generic?
          -- Use code which based on the column existence(dp_enabled_flag etc) in the p_source_table
          -- and then attach this extra statement.

         IF (  ((p_level_id = 1) AND (p_parent_level_id = 3))           --jarorad
            OR
               ((p_level_id = 11) AND (p_parent_level_id = 15))
            OR
               ((p_level_id = 15) AND (p_parent_level_id = 16))
            OR
               ((p_level_id = 16) AND (p_parent_level_id = 30))
            OR
               ((p_level_id = 11) AND (p_parent_level_id = 41))
            OR
               ((p_level_id = 41) AND (p_parent_level_id = 42))
            OR
               ((p_level_id = 42) AND (p_parent_level_id = 30))

            ) THEN

               v_sql_stmt1 :=    ' system_attribute1, ' ||            --jarorad
                                 'system_attribute2, ' ||
                                 'dp_enabled_flag, ';

         END IF;                                                      --jarorad
*/


       IF v_count1 > 0 THEN
          log_debug('setting the v_sql_stmt1');

          v_sql_stmt1 :=    ' system_attribute1, ' ||            --jarorad
                                 'system_attribute2, ' ;

        END IF;

       IF v_count2 > 0 THEN
          log_debug('changing the v_sql_stmt1');

          v_sql_stmt1 :=    v_sql_stmt1||' dp_enabled_flag, ';

        END IF;

       log_debug('The final value for v_sql_stmt1 is   :'||v_sql_stmt1);


         /* Insert Level Values into staging table */
	 v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || p_dest_table || ' ( ' ||
                        'instance, ' ||
                        'level_id, ' ||
                        'level_value, ' ||
                        'sr_level_pk, ' ||
                        'level_value_desc, ' ||
                        'attribute1, ' ||
                        'attribute2, ' ||
                        'attribute3, ' ||
                        'attribute4, ' ||
                        'attribute5, ' ||
                         v_sql_stmt1   ||            --jarorad
                        'last_update_date, ' ||
                        'last_updated_by, ' ||
                        'creation_date, ' ||
                        'created_by ) ' ||
                        'select  ''' ||
                         p_instance_id ||''', ' ||
                         p_level_id || ', ' ||
                         p_level_value_column||', ' ||
                         p_level_value_pk_column||', ' ||
                         p_level_value_desc_column||', ' ||
                        'attribute1, ' ||
                        'attribute2, ' ||
                        'attribute3, ' ||
                        'attribute4, ' ||
                        'attribute5, ' ||
                        v_sql_stmt1 ||                   --jarorad
                        'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ', ' ||
                        'sysdate, ' ||
                        FND_GLOBAL.USER_ID || ' ' ||
                        'from ' ||
                        p_source_table ;

                        /* Following filter causes a performance hit. We'll colect duplicates
                           into staging. At the end these will be deleted by delete_duplicate in the
                           collection program

                        if (p_update_lvl_table = 0) then
			    v_sql_stmt := v_sql_stmt ||
			    ' where ' || p_level_value_pk_column || ' not in ' ||
                            '(select sr_level_pk from ' || p_dest_table ||
			    ' where instance = ' || p_instance_id ||
			    '   and level_id = ' || p_level_id || ')';
                        end if;
                        */

         ins(v_sql_stmt);
         debug_line(v_sql_stmt);
         EXECUTE IMMEDIATE v_sql_stmt;

         /* Insert Level Associations into  staging table */
         v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || v_dest_ass_table || ' ( ' ||
                                'instance, ' ||
                                'level_id, ' ||
                                'sr_level_pk, ' ||
                                'parent_level_id, ' ||
                                'sr_parent_level_pk, ' ||
                                'last_update_date, ' ||
                                'last_updated_by, ' ||
                                'creation_date, ' ||
                                'created_by ) ' ||
                                'select  ''' ||
                                p_instance_id ||''', ' ||
                                p_level_id || ', ' ||
                                p_level_value_pk_column||', ' ||
                                p_parent_level_id || ', ' ||
                                p_parent_value_pk_column ||', ' ||
                                'sysdate, ' ||
                                FND_GLOBAL.USER_ID || ', ' ||
                                'sysdate, ' ||
                                FND_GLOBAL.USER_ID || ' ' ||
                                'from ' ||
                                p_source_table ;

            ins(v_sql_stmt);
            debug_line(v_sql_stmt);
            EXECUTE IMMEDIATE v_sql_stmt;

     log_debug(' Entering Collect Level values Condition');

   END IF;  /* End of IF 1 */

    /* Get the Parent Level Type */
   begin
         select level_type_code into v_parent_lvl_type
         from   msd_levels
         where  level_id = p_parent_level_id
         and plan_type is null;                              --vinekuma
   exception
         when NO_DATA_FOUND then
            null;
         WHEN others THEN
	   fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	   errbuf := substr(SQLERRM,1,150);
   end ;



   /* dbms_output.put_line('Parent Level : ' || p_parent_level_id ) ;
        dbms_output.put_line('Parent Level Type : ' || v_parent_lvl_type ) ; */

   /* Process parent level value only if it is TOP level value*/
   IF (v_parent_lvl_type = '1' AND p_update_lvl_table = 1) THEN


       PROCESS_TOP_LEVEL_VALUES (
                        errbuf,
                        retcode,
                        p_source_table,
                        p_dest_table,
                        p_instance_id,
			p_parent_level_id,
			p_parent_value_column,
			p_parent_value_pk_column,
                        p_parent_value_desc_column,
                        p_seq_num,
                        p_delete_flag);


   END IF;


   /* this piece of code copies item_list_price data if necessary - i.e.
      if p_update_lvl_table is set to 1 (i.e. the level_id had not been
      processed before) and level_id is the lowest level or intermediate level
      in the product dimension */

   IF (p_update_lvl_table = 1) THEN  /* IF 1 */

        select level_type_code, dimension_code, org_relationship_view
        into v_lvl_type, v_dim_code, v_org_view
        from msd_levels
        where level_id = p_level_id
        and plan_type is null;                                     --vinekuma

        IF (p_level_id = 1 OR p_level_id = 3) THEN  /* IF 2 */

           CREATE_ITEM_LIST_PRICE(
                        errbuf,
                        retcode,
                        p_source_table,
                        p_dest_table,
                        p_instance_id,
			p_level_id,
                        p_seq_num,
                        p_delete_flag);


        END IF;  /* End of (v_lvl_type = '2' AND v_dim_code = 'PRD')   IF 2*/

   END IF;   /* End of p_update_lvl_table = 1   IF 1*/

   IF (p_update_lvl_table = 1 AND p_level_id = 7) THEN

    pop_org_cal_associations (
                        errbuf,
			retcode,
                        p_source_table,
                        p_dest_table,
                        p_instance_id
                              );
   END IF;

   IF (p_update_lvl_table = 1 AND p_level_id in (1,18,11)) THEN

    pop_org_lvl_associations (
                        errbuf,
			retcode,
                        p_level_id,
                        p_source_table,
                        v_org_view,
                        p_dest_table,
                        p_instance_id,
                        p_delete_flag);
   END IF;


   POP_MAX_SEQ_NUM (    errbuf, retcode, p_seq_num );

   COMMIT;

   log_debug('Exiting procedure TRANSLATE_LEVEL_PARENT_VALUE');

exception
     when others then
                --write to log an back out
                errbuf := substr(SQLERRM,1,150);
                retcode := 1 ; --warning
                ins('ERROR ' || v_sql_stmt);
                debug_line('ERROR ' || v_sql_stmt);
                ins('ERROR ' || errbuf);
                debug_line('ERROR ' || errbuf);
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                fnd_file.put_line(fnd_file.log, 'The offending sql is:');
                fnd_file.put_line(fnd_file.log, v_sql_stmt);
                rollback;
                -- rollback to Savepoint Before_Delete ;

End translate_level_parent_values ;



/***********************************************************

PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW

***********************************************************/
PROCEDURE  PROCESS_LEVEL_VALUE_PER_ROW(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS

/* New Level values will be inserted into fact table
   and will get deleted from the staging */
CURSOR c_insert IS
select sr_level_pk
from msd_st_level_values
where instance = p_instance_id and level_id = p_level_id
MINUS
select sr_level_pk
from msd_level_values
where instance = p_instance_id and level_id = p_level_id;

/* Cursor to find modified level values */
/* This cursor needs to be opend only after
   new level values are deleted from the staging table
*/
CURSOR c_update IS
(select sr_level_pk, level_value,
attribute1, attribute2, attribute3,
attribute4, attribute5,
level_value_desc,system_attribute1,system_attribute2,  --jarorad
dp_enabled_flag                                               --jarorad
from msd_st_level_values
where instance = p_instance_id and level_id = p_level_id
MINUS
select sr_level_pk, level_value,
attribute1, attribute2, attribute3,
attribute4, attribute5,
level_value_desc,system_attribute1,system_attribute2,  --jarorad
dp_enabled_flag                                               --jarorad
from msd_level_values
where instance = p_instance_id and level_id = p_level_id);



TYPE sr_level_pk_tab     IS TABLE OF msd_st_level_values.sr_level_pk%TYPE;
TYPE level_val_tab       IS TABLE OF msd_st_level_values.level_value%TYPE;
TYPE level_attribute_tab IS TABLE OF msd_st_level_values.attribute1%TYPE;

TYPE system_attribute1_tab IS TABLE OF msd_st_level_values.system_attribute1%TYPE;            --jarorad
TYPE system_attribute2_tab IS TABLE OF msd_st_level_values.system_attribute2%TYPE;  --jarorad
TYPE dp_enabled_flag_tab IS TABLE OF msd_st_level_values.dp_enabled_flag%TYPE;                  --jarorad

a_sr_level_pk    sr_level_pk_tab;
a_level_value    level_val_tab;
a_attribute1     level_attribute_tab;
a_attribute2     level_attribute_tab;
a_attribute3     level_attribute_tab;
a_attribute4     level_attribute_tab;
a_attribute5     level_attribute_tab;
a_level_value_desc  level_attribute_tab;
a_system_attribute1        system_attribute1_tab;       --jarorad
a_system_attribute2   system_attribute2_tab;  --jarorad
a_dp_enabled_flag           dp_enabled_flag_tab;          --jarorad

BEGIN

   OPEN  c_insert;
   FETCH c_insert BULK COLLECT INTO a_sr_level_pk;
   CLOSE c_insert;

   IF (a_sr_level_pk.exists(1)) THEN
      /* First Delete fetched rows from staging, and then
         Insert them into Fact Table.
      */
      FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
        DELETE FROM msd_st_level_values
        WHERE instance = p_instance_id and
              level_id = p_level_id and
              sr_level_pk = a_sr_level_pk(i)
        RETURNING level_value, attribute1,
                  attribute2, attribute3, attribute4,
                  attribute5, level_value_desc,
                  system_attribute1,system_attribute2, --jarorad
                  dp_enabled_flag                             --jarorad
        BULK COLLECT INTO a_level_value, a_attribute1,
                          a_attribute2, a_attribute3,
                          a_attribute4, a_attribute5,
                          a_level_value_desc,a_system_attribute1,     --jarorad
                          a_system_attribute2,a_dp_enabled_flag; --jarorad

      /* Insert new rows into fact table */
      FORALL j IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
         INSERT INTO msd_level_values(
                                     instance, level_id, level_value,
                                     sr_level_pk, level_pk, level_value_desc,
                                     action_code, created_by_refresh_num,  last_refresh_num,
                                     last_update_date, last_updated_by,
                                     creation_date, created_by,
                                     last_update_login, attribute1, attribute2,
                                     attribute3, attribute4, attribute5,
                                     system_attribute1,system_attribute2,   --jarorad
                                     dp_enabled_flag)                              --jarorad
         VALUES(    p_instance_id, p_level_id, a_level_value(j),
                    a_sr_level_pk(j), MSD_COMMON_UTILITIES.get_level_pk(),
                    a_level_value_desc(j),
                   'I', p_seq_num, p_seq_num,
                    sysdate, FND_GLOBAL.USER_ID,
                    sysdate, FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID, a_attribute1(j), a_attribute2(j),
                    a_attribute3(j), a_attribute4(j), a_attribute5(j),
                    a_system_attribute1(j), a_system_attribute2(j),   --jarorad
                    a_dp_enabled_flag(j) );                                  --jarorad
   END IF;


  /* Fetch updated rows from staging */
   OPEN  c_update;
   FETCH c_update BULK COLLECT INTO a_sr_level_pk, a_level_value, a_attribute1,
                                    a_attribute2, a_attribute3,
                                    a_attribute4, a_attribute5, a_level_value_desc,
                                    a_system_attribute1,a_system_attribute2,  --jarorad
                                    a_dp_enabled_flag;                               --jarorad
   CLOSE c_update;

   IF (a_sr_level_pk.exists(1)) THEN
    FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
      UPDATE msd_level_values
         SET level_value = a_level_value(i),
             attribute1 = a_attribute1(i),
             attribute2 = a_attribute2(i),
             attribute3 = a_attribute3(i),
             attribute4 = a_attribute4(i),
             attribute5 = a_attribute5(i),
             level_value_desc = a_level_value_desc(i),
             system_attribute1 = a_system_attribute1(i),               --jarorad
             system_attribute2 = a_system_attribute2(i),     --jarorad
             dp_enabled_flag = a_dp_enabled_flag(i),                     --jarorad
             action_code = 'U',
             last_refresh_num = p_seq_num,
             last_update_date = sysdate
         WHERE instance = p_instance_id and
               level_id = p_level_id and
               sr_level_pk = a_sr_level_pk(i);
   END IF;



EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END PROCESS_LEVEL_VALUE_PER_ROW;



/***********************************************************

PROCEDURE  CREATE_DELETED_LEVEL_VALUES

***********************************************************/

PROCEDURE CREATE_DELETED_LEVEL_VALUES(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS

CURSOR c_delete IS
(select sr_level_pk
from msd_level_values
where instance = p_instance_id and level_id = p_level_id
MINUS
select sr_level_pk
from msd_st_level_values
where instance = p_instance_id and level_id = p_level_id);

TYPE sr_level_pk_tab is table of msd_level_values.sr_level_pk%TYPE;
TYPE level_pk_tab is table of msd_level_values.level_pk%TYPE;
TYPE crn_tab is table of msd_level_values.created_by_refresh_num%TYPE;

a_sr_level_pk    SR_LEVEL_PK_TAB;
a_level_pk       LEVEL_PK_TAB;
a_crn            CRN_TAB;


BEGIN

   OPEN c_delete;
   FETCH c_delete BULK COLLECT INTO a_sr_level_pk;
   CLOSE c_delete;

   IF (a_sr_level_pk.exists(1)) THEN
      FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
         DELETE FROM msd_level_values
         WHERE instance = p_instance_id and
               level_id = p_level_id and
               sr_level_pk = a_sr_level_pk(i)
         RETURNING level_pk, created_by_refresh_num
         BULK COLLECT INTO a_level_pk, a_crn;

      FORALL j IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
         INSERT INTO msd_deleted_level_values(instance, level_id,
                                  sr_level_pk, level_pk,
                                  created_by_refresh_num, last_refresh_num,
                                  creation_date, created_by, last_update_date,
                                  last_updated_by, last_update_login)
         VALUES(p_instance_id, p_level_id,
                a_sr_level_pk(j), a_level_pk(j),
                a_crn(j) , p_seq_num,
                sysdate, FND_GLOBAL.USER_ID, sysdate,
                FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID);

      /* VM - To be implemented
         1. We should mark data deleted from msd_cs_Data for deleted level
values
         2. We should delete level associations for level values being deleted.
       */
   END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END CREATE_DELETED_LEVEL_VALUES;



/***********************************************************

PROCEDURE  PROCESS_LEVEL_ASSOCIATION

***********************************************************/
PROCEDURE  PROCESS_LEVEL_ASSOCIATION(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS

/* This cursur will select only new level associations */
CURSOR c_new_rows IS
(select sr_level_pk
from msd_st_level_associations
where instance = p_instance_id and level_id = p_level_id and
parent_level_id = p_parent_level_id
MINUS
select sr_level_pk
from msd_level_associations
where instance = p_instance_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id);


/* Cursor for updated level association */
/* This cursor need to be opened only after
   new associations are deleted from the staging table */
CURSOR c_update_rows IS
(select sr_level_pk, sr_parent_level_pk
from msd_st_level_associations
where instance = p_instance_id and level_id = p_level_id and
parent_level_id = p_parent_level_id
MINUS
select sr_level_pk, sr_parent_level_pk
from msd_level_associations
where instance = p_instance_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id);



TYPE sr_level_pk_tab is table of msd_level_associations.sr_level_pk%TYPE;
TYPE sr_parent_level_pk_tab is table of msd_level_associations.sr_parent_level_pk%TYPE;

a_sr_level_pk          SR_LEVEL_PK_TAB;
a_sr_parent_level_pk   SR_PARENT_LEVEL_PK_TAB;

l_count     NUMBER := 0;

BEGIN
     OPEN  c_new_rows;
     FETCH c_new_rows BULK COLLECT INTO a_sr_level_pk;
     CLOSE c_new_rows;

     /* For new level association */
     IF (a_sr_level_pk.exists(1)) THEN
        /* First Delete fetched rows(new level associations) from staging,
           and then Insert them into Fact Table.
        */
        FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
           DELETE FROM msd_st_level_associations
           WHERE instance = p_instance_id and
                 level_id = p_level_id and
                 sr_level_pk = a_sr_level_pk(i) and
                 parent_level_id = p_parent_level_id
           RETURNING sr_parent_level_pk
           BULK COLLECT INTO a_sr_parent_level_pk;

        /* Insert new rows into fact table */
        IF (a_sr_parent_level_pk.exists(1)) THEN
           FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
              INSERT INTO msd_level_associations(
                          instance, level_id, sr_level_pk,
                          parent_level_id, sr_parent_level_pk,
                          last_update_date, last_updated_by,
                          creation_date, created_by, last_update_login,
                          created_by_refresh_num, last_refresh_num, action_code)
              VALUES(p_instance_id, p_level_id, a_sr_level_pk(i),
                     p_parent_level_id, a_sr_parent_level_pk(i),
                     sysdate, FND_GLOBAL.USER_ID,
                     sysdate,FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
                     p_seq_num, p_seq_num, 'I');
        END IF;
     END IF;  /* End of New Association */

     OPEN  c_update_rows;
     FETCH c_update_rows BULK COLLECT INTO a_sr_level_pk, a_sr_parent_level_pk;
     CLOSE c_update_rows;

     /* For updated level association */
     IF (a_sr_level_pk.exists(1) and a_sr_parent_level_pk.exists(1)) THEN
        FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
            UPDATE msd_level_associations
            SET
               sr_parent_level_pk = a_sr_parent_level_pk(i),
               action_code = 'U',
               last_refresh_num = p_seq_num,
               last_update_date = sysdate
            WHERE instance = p_instance_id and
                  level_id = p_level_id and
                  sr_level_pk = a_sr_level_pk(i) and
                  parent_level_id = p_parent_level_id;
     END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END PROCESS_LEVEL_ASSOCIATION;



/***********************************************************

PROCEDURE  CREATE_DELETED_LEVEL_ASSOCI

***********************************************************/

PROCEDURE CREATE_DELETED_LEVEL_ASSOCI(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_parent_level_id           IN  NUMBER,
                        p_seq_num                   IN  NUMBER) IS


CURSOR c_delete IS
(select sr_level_pk, sr_parent_level_pk
from msd_level_associations
where instance = p_instance_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id
MINUS
select sr_level_pk, sr_parent_level_pk
from msd_st_level_associations
where instance = p_instance_id and level_id = p_level_id and
      parent_level_id = p_parent_level_id);

TYPE sr_level_pk_tab is table of msd_level_associations.sr_level_pk%TYPE;
TYPE sr_parent_level_pk_tab is table of msd_level_associations.sr_parent_level_pk%TYPE;

a_sr_level_pk          SR_LEVEL_PK_TAB;
a_sr_parent_level_pk   SR_PARENT_LEVEL_PK_TAB;

BEGIN

   OPEN c_delete;
   FETCH c_delete BULK COLLECT INTO a_sr_level_pk, a_sr_parent_level_pk;
   CLOSE c_delete;

   IF (a_sr_level_pk.exists(1)) THEN
       FORALL i IN a_sr_level_pk.FIRST..a_sr_level_pk.LAST
         DELETE FROM msd_level_associations
         WHERE instance = p_instance_id and
               level_id = p_level_id and
               sr_level_pk = a_sr_level_pk(i) and
               parent_level_id = p_parent_level_id and
               sr_parent_level_pk = a_sr_parent_level_pk(i);
   END IF;

EXCEPTION
     when others then
               errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END CREATE_DELETED_LEVEL_ASSOCI;


/***********************************************************

PROCEDURE  PROCESS_TOP_LEVEL_VALUES

***********************************************************/
PROCEDURE  PROCESS_TOP_LEVEL_VALUES (
                       errbuf              		OUT NOCOPY VARCHAR2,
                        retcode             		OUT NOCOPY VARCHAR2,
                        p_source_table      		IN  VARCHAR2,
                        p_dest_table        		IN  VARCHAR2,
                        p_instance_id       		IN  VARCHAR2,
			p_parent_level_id   		IN  NUMBER,
			p_parent_value_column		IN  VARCHAR2,
			p_parent_value_pk_column	IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2) IS


v_sql_stmt       varchar2(4000);

BEGIN


        /* dbms_output.put_line('Parent Level : ' || p_parent_level_id ) ; */

        /* Note that we will not be able to get the attributes 1 - 5 for the
	Top level as we will not have a separate view for the top level */

        /* For PULL */
        IF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE) THEN
             /* Find deleted top level values, if any */
             /* Top Level Values can be modified, but should not be deleted.
                comment out this part
             IF (p_delete_flag = 'Y') THEN
                 CREATE_DELETED_LEVEL_VALUES( errbuf,
                                              retcode,
                                              p_instance_id,
                                              p_parent_level_id,
                                              p_seq_num);
             END IF;
             */

             /* Update or insert new top level values */
             PROCESS_LEVEL_VALUE_PER_ROW( errbuf,
                                          retcode,
                                          p_instance_id,
			                  p_parent_level_id,
                                          p_seq_num);
        ELSE
             /* Collect into Staging table*/

                delete from msd_st_level_values
                where instance = p_instance_id
                      and level_id = p_parent_level_id ;

             v_sql_stmt :=  'insert  /*+ ALL_ROWS */ into ' || p_dest_table || ' ( ' ||
                       'instance, ' ||
                       'level_value, ' ||
                       'sr_level_pk, ' ||
                       'level_id, ' ||
                       'level_value_desc, ' ||
                       'last_update_date, ' ||
                       'last_updated_by, ' ||
                       'creation_date, ' ||
                       'created_by ) ' ||
                       'SELECT ''' ||
                        p_instance_id ||''', ' ||
                        p_parent_value_column || ', ' ||
                        p_parent_value_pk_column ||', '  ||
                        p_parent_level_id || ', ' ||
                       'parent_desc_alias' ||', ' ||
                       'sysdate, ' || FND_GLOBAL.USER_ID || ', ' ||
                       'sysdate, ' || FND_GLOBAL.USER_ID || ' ' ||
                       'FROM ' ||
                       '(select distinct ' || p_parent_value_column || ', ' ||
                       p_parent_value_pk_column || ', ' ||
                       p_parent_level_id || ', '||
                       p_parent_value_desc_column || ' parent_desc_alias ' || ' from ' ||
                       p_source_table || ') src ';

             ins(v_sql_stmt);
             debug_line(v_sql_stmt);
             EXECUTE IMMEDIATE v_sql_stmt;

        END IF;



EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END PROCESS_TOP_LEVEL_VALUES;




/***********************************************************

PROCEDURE  CREATE_ITEM_LIST_PRICE

***********************************************************/

PROCEDURE CREATE_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_source_table              IN  VARCHAR2,
                        p_dest_table                IN  VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
			p_level_id	            IN  NUMBER,
                        p_seq_num                   IN  NUMBER,
                        p_delete_flag               IN  VARCHAR2) IS


x_dblink        VARCHAR2(128);
v_sql_stmt       varchar2(4000);


BEGIN

   IF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE) THEN
                 /* pulling data */
          IF (p_delete_flag = 'Y' and p_level_id = 1) THEN
                 DELETED_ITEM_LIST_PRICE(  errbuf,
                                           retcode,
                                           p_instance_id,
                                           p_seq_num);
          END IF;
          UPDATE_ITEM_LIST_PRICE(   errbuf,
                                    retcode,
                                    p_instance_id,
                                    p_seq_num);

          delete from msd_st_item_list_price
          where instance = p_instance_id;


   ELSIF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

        /* Collection */
         IF (p_level_id = 1) THEN
            delete from msd_st_item_list_price
	    where instance = p_instance_id;
         END IF;

         msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);
         if (retcode = -1) then
             retcode :=-1;
             return;
         end if;

         v_sql_stmt:= ' insert into msd_st_item_list_price ( '||
                                       'instance, '||
                                       'item, '||
                                       'sr_item_pk, '||
                                       'list_price, '||
                                       'avg_discount, '||
                                       'base_uom, '||
                                       'item_type_id, ' ||
                                       'forecast_type_id, ' ||
                                       'creation_date, '||
                                       'created_by, '||
                                       'last_update_date, '||
                                       'last_updated_by, '||
                                       'last_update_login) '||
                                       'SELECT ''' || p_instance_id || ''','||
                                       'item,'||
                                       'sr_item_pk, '||
                                       'list_price, '||
                                       'avg_discount, '||
                                       'base_uom, ' ||
                                       'item_type_id, ' ||
                                       'forecast_type_id, ' ||
        	                       'sysdate, ' ||
                                       FND_GLOBAL.USER_ID || ', ' ||
                                       'sysdate, ' ||
                                       FND_GLOBAL.USER_ID || ', ' ||
                                       FND_GLOBAL.USER_ID || ' ' ||
                                      'FROM ' ||
                                      ' msd_sr_item_list_price_v' || x_dblink  ||
		                      ' where sr_item_pk in (select to_number(decode(ltrim(sr_level_pk, ''.0123456789''),' ||
                                      ' null, sr_level_pk, null)) ' ||
		                      ' from msd_st_level_values ' ||
		                      ' where level_id = ' || p_level_id || ')' ;

         ins(v_sql_stmt);
         debug_line(v_sql_stmt);
         EXECUTE IMMEDIATE v_sql_stmt;

   END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END CREATE_ITEM_LIST_PRICE;


/***********************************************************

PROCEDURE  DELETED_ITEM_LIST_PRICE

***********************************************************/

PROCEDURE DELETED_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
                        p_seq_num                   IN  NUMBER) IS

CURSOR c_delete IS
(select sr_item_pk
from msd_item_list_price
where instance = p_instance_id
MINUS
select sr_item_pk
from msd_st_item_list_price
where instance = p_instance_id);

TYPE sr_item_pk_tab is table of msd_item_list_price.sr_item_pk%TYPE;

a_sr_item_pk    SR_ITEM_PK_TAB;


BEGIN

   OPEN c_delete;
   FETCH c_delete BULK COLLECT INTO a_sr_item_pk;
   CLOSE c_delete;

   IF (a_sr_item_pk.exists(1)) THEN
      FORALL i IN a_sr_item_pk.FIRST..a_sr_item_pk.LAST
         DELETE FROM msd_item_list_price
         WHERE sr_item_pk = a_sr_item_pk(i) and instance = p_instance_id;
/*
      FORALL j IN a_sr_item_pk.FIRST..a_sr_item_pk.LAST
         INSERT INTO msd_deleted_item_list_price(instance,  sr_item_pk, created_by_refresh_num,
                                  creation_date, created_by, last_update_date,
                                  last_updated_by, last_update_login)
         VALUES(p_instance_id, a_sr_item_pk(j), p_seq_num,
                sysdate, FND_GLOBAL.USER_ID, sysdate,
                FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID);
*/
   END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));



END DELETED_ITEM_LIST_PRICE;



/***********************************************************

PROCEDURE  UPDATE_ITEM_LIST_PRICE

***********************************************************/
PROCEDURE  UPDATE_ITEM_LIST_PRICE(
                        errbuf                      OUT NOCOPY VARCHAR2,
                        retcode                     OUT NOCOPY VARCHAR2,
                        p_instance_id               IN  VARCHAR2,
                        p_seq_num                   IN  NUMBER) IS


CURSOR c_st_rows IS
select item, list_price, avg_discount, base_uom,
sr_item_pk, item_type_id, forecast_type_id
from  msd_st_item_list_price
where instance = p_instance_id;


CURSOR c_fact_rows (p_item_pk VARCHAR2) IS
select sr_item_pk, item, list_price, avg_discount, base_uom,
item_type_id, forecast_type_id
from msd_item_list_price
where instance = p_instance_id and sr_item_pk = p_item_pk;

l_item                VARCHAR2(240);
l_list_price          NUMBER;
l_avg_discount        NUMBER;
l_base_uom            VARCHAR2(40);
l_item_pk             VARCHAR2(240);
l_item_type_id        NUMBER;
l_forecast_type_id    NUMBER;


BEGIN

     FOR rec_st_rows IN c_st_rows LOOP

         OPEN    c_fact_rows( rec_st_rows.sr_item_pk);
         FETCH   c_fact_rows
         INTO    l_item_pk, l_item, l_list_price,
                 l_avg_discount, l_base_uom, l_item_type_id,
                 l_forecast_type_id;
         CLOSE   c_fact_rows;

         /* If this row doesn't exist in fact table then insert */
         IF (l_item_pk is null) THEN

            INSERT INTO msd_item_list_price( instance, item, list_price,
                                             avg_discount, base_uom,
                                             sr_item_pk, item_type_id, forecast_type_id,
                                             action_code, created_by_refresh_num, last_refresh_num,
                                             last_update_date, last_updated_by,
                                             creation_date, created_by,
                                             last_update_login)
            VALUES( p_instance_id, rec_st_rows.item,  rec_st_rows.list_price,
                    rec_st_rows.avg_discount,  rec_st_rows.base_uom,
                    rec_st_rows.sr_item_pk,  rec_st_rows.item_type_id,
                    rec_st_rows.forecast_type_id,
                   'I', p_seq_num, p_seq_num,
                    sysdate, FND_GLOBAL.USER_ID,
                    sysdate, FND_GLOBAL.USER_ID,
                    FND_GLOBAL.LOGIN_ID);

         ELSE

            /* If this row exists in the fact then check row has been
               updated row or not. */
            IF ( (nvl(rec_st_rows.item, 'NULL') <> nvl(l_item, 'NULL')) OR
                 (nvl(rec_st_rows.list_price,-9999) <> nvl(l_list_price, -9999)) OR
                 (nvl(rec_st_rows.avg_discount,-9999) <> nvl(l_avg_discount,-9999)) OR
                 (nvl(rec_st_rows.base_uom,'NULL') <> nvl(l_base_uom,'NULL') ) OR
                 (nvl(rec_st_rows.item_type_id,-9999) <> nvl(l_item_type_id,-9999)) OR
                 (nvl(rec_st_rows.forecast_type_id,-9999) <> nvl(l_forecast_type_id,-9999)) ) THEN
               /* If this row has been modified */

               UPDATE msd_item_list_price
               SET item = rec_st_rows.item,
                   list_price =  rec_st_rows.list_price,
                   avg_discount =  rec_st_rows.avg_discount,
                   base_uom =  rec_st_rows.base_uom,
                   item_type_id =  rec_st_rows.item_type_id,
                   forecast_type_id =  rec_st_rows.forecast_type_id,
                   action_code = 'U',
                   last_refresh_num = p_seq_num,
                   last_update_date = sysdate
               WHERE instance = p_instance_id and
                     sr_item_pk = rec_st_rows.sr_item_pk;
            END IF;
         END IF;  /* End of IF (l_item_pk is null) */

       l_item_pk := null;
       l_item := null;
       l_list_price := null;
       l_avg_discount := null;
       l_base_uom := null;
       l_item_type_id := null;
       l_forecast_type_id := null;
     END LOOP; /* End of For LOOP */



EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END UPDATE_ITEM_LIST_PRICE;





/*----------------------------------------------------------------
  This procedure will clean up the MSD_DELETED_LEVEL_VALUES table,
  MSD_DELETED_LEVEL_ASSOCIATIONS, MSD_DELETED_ITEM_LIST_PRICE table

-----------------------------------------------------------------*/

PROCEDURE CLEAN_DELETED_LEVEL_VALUES(errbuf              OUT NOCOPY VARCHAR2,
                                    retcode             OUT NOCOPY VARCHAR2) IS

l_least_refresh_num   NUMBER := 0;

BEGIN

   /* Find the least refresh number for existing demand plan */
   SELECT nvl(min(dp_build_refresh_num), 0) INTO l_least_refresh_num
   FROM msd_demand_plans;

   if l_least_refresh_num <> 0 then
     DELETE FROM msd_deleted_level_values
     WHERE LAST_REFRESH_NUM <= l_least_refresh_num;
   end if;

/*   DELETE FROM msd_deleted_level_associations
   WHERE CREATED_BY_REFRESH_NUM < l_least_refresh_num;

   DELETE FROM msd_deleted_item_list_price
   WHERE CREATED_BY_REFRESH_NUM < l_least_refresh_num;
*/



EXCEPTION
	when others then
	   fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
	   errbuf := substr(SQLERRM,1,150);
	   retcode := -1;

END CLEAN_DELETED_LEVEL_VALUES;



/** Added for Multiple Time Hierarchies.
  * This will populate associations between
  * enabled orgs in source with manufacturing calendars.
  **/

PROCEDURE POP_ORG_CAL_ASSOCIATIONS (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_source_table                  IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_instance_id                   IN  NUMBER)    IS

/* The Type Id for Manufacturing Calendar */
p_man_cal_type VARCHAR2(240) := MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR;

/* Destination table to insert into */
v_dest_table VARCHAR2(1000);

/* The Insert-Select Sql Statement */
v_stmt     VARCHAR2(2000);

/* The link to the source database */
x_dblink   VARCHAR2(2000);

BEGIN

  if (p_source_table <> MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then
    /* Get the x_dblink from p_instance_id */
    msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);

    /* Check for errors in getting the db link */

    if (retcode = -1) then

      retcode :=-1;
      errbuf := 'Error while getting db_link';
      return;

    end if;
  end if;


  /* Refresh the existing Org Calendar relationships for this instance */

  if (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

    delete from msd_st_org_calendars
    where instance = p_instance_id;

    v_dest_table := 'MSD_ST_ORG_CALENDARS';

  else

    delete from msd_org_calendars
    where instance = p_instance_id;

    v_dest_table := 'MSD_ORG_CALENDARS';

  end if;

  /** Insert Data **/

  if (p_source_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

     insert into msd_org_calendars
        (INSTANCE,
         SR_ORG_PK,
         CALENDAR_TYPE,
         CALENDAR_CODE,
	 CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY)
      select
         a.instance,
         a.sr_org_pk,
         a.calendar_type,
         a.calendar_code,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
      from
      (select distinct
              instance,
              sr_org_pk,
              calendar_type,
              calendar_code
         from msd_st_org_calendars
      where instance = p_instance_id) a;

     delete from msd_st_org_calendars where instance = p_instance_id;


  else

     v_stmt :=  'insert into ' || v_dest_table ||
                ' (   INSTANCE, SR_ORG_PK, CALENDAR_TYPE, CALENDAR_CODE,   ' ||
   	        ' CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY) ' ||
                ' select ' ||
                         p_instance_id          || ', ' ||
                        ' mod.organization_id'   || ', ' ||
                   '''' ||  p_man_cal_type || '''' || ', ' ||
                        ' mod.calendar_code'     || ', ' ||
                       ' sysdate'               || ', ' ||
                          fnd_global.user_id     || ', ' ||
                       ' sysdate'               || ', ' ||
                          fnd_global.user_id     || '  ' ||
                     '  From MSD_ORGANIZATION_DEFINITIONS' || x_dblink || ' MOD';
     v_stmt := v_stmt || ' where exists (select 1 from msd_app_instance_orgs' || x_dblink || ' maio where MOD.organization_id = MAIO.organization_id)';

      execute immediate v_stmt;

  end if;


  EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(v_stmt, 1,  100));
                fnd_file.put_line(fnd_file.log, substr(v_stmt,100, 200));
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));

end;


PROCEDURE POP_ORG_LVL_ASSOCIATIONS (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_lvl_id                        IN  NUMBER,
                        p_source_table                  IN  VARCHAR2,
                        p_org_relationship_view         IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_instance_id                   IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2) IS

/* Destination table to insert into */
v_dest_table VARCHAR2(1000);

/* The Insert-Select Sql Statement */
v_stmt     VARCHAR2(2000);

/* The link to the source database */
x_dblink   VARCHAR2(2000);

cursor c_delete is
select instance,
       level_id,
       sr_level_pk,
       org_level_id,
       org_sr_level_pk
from   msd_st_level_org_asscns
where  instance = p_instance_id
       and level_id = p_lvl_id;



BEGIN

  if (p_source_table <> MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

    /* Get the x_dblink from p_instance_id */
    msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);

    /* Check for errors in getting the db link */

    if (retcode = -1) then

      retcode :=-1;
      errbuf := 'Error while getting db_link';
      return;

    end if;
  end if;


  /* Refresh the existing Org Calendar relationships for this instance */

  if (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

    delete from msd_st_level_org_asscns
    where instance = p_instance_id
    and level_id = p_lvl_id;

    v_dest_table := 'MSD_ST_LEVEL_ORG_ASSCNS';
  /* Bug # 3745624. Delete all level org asscns only when Complete Refresh = 'y' else delete only those values which
   exist in msd_st_level_org_asscns */
  elsif (p_delete_flag = 'Y') then

    delete from msd_level_org_asscns
    where instance = p_instance_id
    and level_id = p_lvl_id;

    v_dest_table := 'MSD_LEVEL_ORG_ASSCNS';

  elsif (p_delete_flag = 'N') then

    for c_delete_cur in c_delete loop

      delete from msd_level_org_asscns
      where instance = p_instance_id
      and level_id = p_lvl_id
      and sr_level_pk = c_delete_cur.sr_level_pk
      and org_level_id = c_delete_cur.org_level_id
      and org_sr_level_pk = c_delete_cur.org_sr_level_pk;

    end loop;

    v_dest_table := 'MSD_LEVEL_ORG_ASSCNS';

  end if;

  /** Insert Data **/

  if (p_source_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) then

     insert into msd_level_org_asscns
        ( INSTANCE,
          LEVEL_ID,
          SR_LEVEL_PK,
          ORG_LEVEL_ID,
          ORG_SR_LEVEL_PK,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY
        )
      select
         a.instance,
         a.level_id,
         a.sr_level_pk,
         a.org_level_id,
         a.org_sr_level_pk,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
      from
      (select distinct
              instance,
              level_id,
              sr_level_pk,
              org_level_id,
              org_sr_level_pk
         from msd_st_level_org_asscns
      where instance = p_instance_id
      and level_id = p_lvl_id) a;

     delete from msd_st_level_org_asscns
     where instance = p_instance_id
     and level_id = p_lvl_id;

  else

     v_stmt :=  'insert into ' || v_dest_table ||
                ' (   INSTANCE, LEVEL_ID, SR_LEVEL_PK, ORG_LEVEL_ID, ORG_SR_LEVEL_PK, ' ||
   	        ' CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY) ' ||
                ' select ' ||
                         p_instance_id          || ', ' ||
                         p_lvl_id   || ', ' ||
                          ' src.level_value_pk ' || ', ' ||
                        ' src.org_level_id '     || ', ' ||
                        ' src.org_level_value_pk '     || ', ' ||
                       ' sysdate '               || ', ' ||
                          fnd_global.user_id     || ', ' ||
                       ' sysdate '               || ', ' ||
                          fnd_global.user_id     || '  ' ||
                     '  From ' ||  p_org_relationship_view  || x_dblink || ' src';

      execute immediate v_stmt;

  end if;


  EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(v_stmt, 1,  100));
                fnd_file.put_line(fnd_file.log, substr(v_stmt,100, 200));
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));

end;


/* Stores the maximum refresh number for level values collections
 */

PROCEDURE POP_MAX_SEQ_NUM (
                        errbuf 				OUT NOCOPY VARCHAR2,
			retcode 			OUT NOCOPY VARCHAR2,
                        p_seq_num                       IN  NUMBER) IS

x_temp number;

BEGIN

     SELECT REFRESH_NUM INTO x_temp
       FROM MSD_DP_PARAMETERS_DS
      WHERE DEMAND_PLAN_ID = -1;

     UPDATE MSD_DP_PARAMETERS_DS
     SET REFRESH_NUM = p_seq_num
     WHERE DEMAND_PLAN_ID = -1;

EXCEPTION WHEN NO_DATA_FOUND THEN

     INSERT INTO MSD_DP_PARAMETERS_DS
     (  DEMAND_PLAN_ID,
        DATA_TYPE,
        PARAMETER_TYPE,
        PARAMETER_NAME,
        REFRESH_NUM,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY
     )  VALUES
     (
        -1,
         'LEVEL_VALUES',
         null,
         null,
         p_seq_num,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
     );

END;






/*------------------------------------------------------------------
   This program is no longer needed, but is kept around for possible
   future use.
--------------------------------------------------------------------*/
procedure revert_level_values(p_level_id number, p_instance varchar2) is
 v_sql varchar2(2000);
begin
  -- this is dynamic sql because the pl/sql refuses to accept this
  -- query as valid.
  v_sql := 'update msd_level_values lv '||
           'set level_pk = nvl((select level_pk '||
           'from msd_backup_level_values bak '||
           'where bak.level_id = ' || p_level_id ||
           ' and bak.instance = '''|| p_instance ||
           ''' and bak.sr_level_pk = lv.sr_level_pk), level_pk) '||
           'where lv.instance = ''' || p_instance ||
           ''' and lv.level_id = ' || p_level_id;

  execute immediate v_sql;

end revert_level_values;

/* For Debugging purpose */
Procedure show_line(p_sql in    varchar2) is
    i   number:=1;
Begin
    while i<= length(p_sql)
    loop
 --     dbms_output.put_line (substr(p_sql, i, 255));
        fnd_file.put_line(fnd_file.log,substr(p_sql, i, 255));
	null;
        i := i+255;
    end loop;
End;

Procedure debug_line(p_sql in    varchar2)is
Begin
    if c_debug = 'Y' then
        show_line(p_sql);
    end if;
End;

END ;

/
