--------------------------------------------------------
--  DDL for Package Body EGO_PUB_HIST_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_PUB_HIST_PURGE_PKG" AS
/* $Header: EGOPPHPB.pls 120.0.12010000.6 2009/09/08 08:36:19 cmath noship $ */
--============ Purge_Publish_History API===============
/* This procedure is called by the concurrent program, will be used to delete
   record from status table in order to purge publish history */
PROCEDURE Purge_Publish_History (  err_buff               OUT   NOCOPY  VARCHAR2,
                                   ret_code               OUT   NOCOPY  NUMBER,
                                   p_batch_id             IN            NUMBER ,
                                   p_target_system_code   IN            VARCHAR2,
					                         p_from_date            IN            VARCHAR2 ,
                                   p_to_date              IN            VARCHAR2 ,
  	                               p_status_code          IN            VARCHAR2 ,
                                   p_published_by         IN            NUMBER ,
                                   p_entity_type          IN            VARCHAR2 )

IS

      TYPE l_batch_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE l_status_sys_tab IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
      l_dynamic_sql           VARCHAR2(2000):=NULL;
      l_batch_sql             VARCHAR2(2000):=NULL;
      l_where_clause          VARCHAR2(2000):=NULL;
      l_count_bind_param      NUMBER        := 1;
      l_using_clause          VARCHAR2(500) :=NULL;

      l_from_date  VARCHAR2(1000) := NULL;
      l_to_date  VARCHAR2(1000)   := NULL;

      l_batch_tab               l_batch_table;
      l_batch_tab1              l_batch_table;
      l_batch_tab2              l_batch_table;
      l_batch_tab3              l_batch_table;
      l_status_syss             l_status_sys_tab;
      l_delete_batch_hdr        VARCHAR2(1000):=NULL;
      l_delete_batch_param      VARCHAR2(1000):=NULL;
      l_delete_entity_obj       VARCHAR2(1000):=NULL;
      l_delete_batch_status     VARCHAR2(1000):=NULL;
      l_delete_batch_system     VARCHAR2(1000):=NULL;
      l_delete_batch_system1    VARCHAR2(1000):=NULL;
      l_delete_batch_status1    VARCHAR2(1000):=NULL;
      l_delete_batch_status2    VARCHAR2(1000):=NULL;
      l_delete_batch_status3    VARCHAR2(1000):=NULL;
      l_batch_id                NUMBER        :=NULL ;
      l_pub_dt                  VARCHAR2(100):=NULL;
      l_pub_dt_to               VARCHAR2(100):=NULL;
      l_system_flag               BOOLEAN := false;
      l_status_flag               BOOLEAN := false;
      l_batch_sql1              VARCHAR2(2000):=NULL;
      l_batch_sql2              VARCHAR2(2000):=NULL;
      l_batch_sql3              VARCHAR2(2000):=NULL;
      l_where_clause1           VARCHAR2(2000):=NULL;
      l_where_clause2           VARCHAR2(2000):=NULL;
      l_where_clause3           VARCHAR2(2000):=NULL;
      l_batch_param               BOOLEAN := FALSE;
      l_status_param              BOOLEAN := FALSE;
      l_system_param              BOOLEAN := FALSE;
      l_status_sel_sql            VARCHAR2(1000) := NULL;
      l_system_sel_sql            VARCHAR2(1000) := NULL;
      l_status_sel_count          NUMBER := 0;
      l_system_sel_count          NUMBER := 0;
      l_exec_status               BOOLEAN  := TRUE;
      l_exec_sys                  BOOLEAN  := TRUE;
      l_status_sys_seq            VARCHAR2(1000) := NULL;
      l_sys_frm_status            VARCHAR2(1000) := NULL;

BEGIN

      /* Change into Date format for passed in Date Range*/
      l_from_date := FND_DATE.canonical_to_date(p_from_date);
      l_to_date := FND_DATE.canonical_to_date(p_to_date);

      l_batch_sql               := ' SELECT DISTINCT hdr.Batch_id
                                     FROM  EGO_PUB_BAT_HDR_B hdr, EGO_PUB_BAT_STATUS_B status
                                     WHERE  hdr.batch_id= status.batch_id ';

      l_batch_sql1              := ' select distinct Batch_id from ego_pub_bat_hdr_b where ';
      l_batch_sql2              := ' select distinct BATCH_ID from EGO_PUB_BAT_STATUS_B where ';
      l_batch_sql3              := ' select distinct BATCH_ID from EGO_PUB_BAT_SYSTEMS_B where ';
      l_status_sys_seq          := ' select SYSTEM_CODE from EGO_PUB_BAT_STATUS_B where ' ;

      l_status_sel_sql            := ' select count(*) from EGO_PUB_BAT_STATUS_B where BATCH_ID = :1 ';
      l_system_sel_sql            := ' select count(*) from EGO_PUB_BAT_SYSTEMS_B where BATCH_ID = :1 ';

      l_delete_batch_hdr        := 'Delete FROM ego_pub_bat_hdr_b WHERE batch_id = :1 ';
      l_delete_batch_param      := 'Delete FROM Ego_Pub_Bat_Params_B WHERE type = 1 and type_id  = :1 ';  --Type is 1 for Batch and 2 for System
      l_delete_entity_obj       := 'Delete FROM Ego_Pub_Bat_Ent_Objs_B WHERE batch_id  = :1 ';
      l_delete_batch_status     := 'Delete FROM EGO_PUB_BAT_STATUS_B WHERE batch_id  = :1 ';
      l_delete_batch_status1    := 'Delete FROM EGO_PUB_BAT_STATUS_B WHERE batch_id  = :1 and STATUS_CODE = :2 ';
      l_delete_batch_system     := 'Delete FROM EGO_PUB_BAT_SYSTEMS_B WHERE batch_id  = :1 ';
      l_delete_batch_system1    := 'Delete FROM EGO_PUB_BAT_SYSTEMS_B WHERE batch_id  = :1 and SYSTEM_CODE = :2 ';
      l_delete_batch_status2    := 'Delete FROM EGO_PUB_BAT_STATUS_B WHERE batch_id  = :1 and SYSTEM_CODE = :2 and STATUS_CODE = :3 ';
      l_delete_batch_status3    := 'Delete FROM EGO_PUB_BAT_STATUS_B WHERE batch_id  = :1 and SYSTEM_CODE = :2 ';

       fnd_file.put_line(fnd_file.Log,' Processing data to delete record based on input ');

      /*Case when no Input has been passed, No action will be taken by this API*/
      IF  ( p_batch_id IS NULL AND p_target_system_code IS NULL AND p_from_date IS NULL
                AND p_to_date IS NULL AND p_status_code IS NULL AND p_published_by IS NULL
                AND p_entity_type IS NULL)
      THEN
            -- If all parameters contains null value then send useful message to the log file.
            fnd_file.put_line(fnd_file.Log,'No record has been deleted because all the input parameters contains null value. User have to enter value for atleast one of the input paramters to delete data');
            RETURN;
      END IF;

      /* Validating From date & To Date as both are required */
      IF ( (p_from_date IS NOT NULL  AND p_to_date IS NULL ) OR ( p_from_date IS NULL  AND p_to_date IS NOT NULL )) THEN
         fnd_file.put_line(fnd_file.Log,' Date range is not provided to delete record. ');
         RETURN;
      END IF;


      /*Case when batch_id is passed as input parameter to delete publish history*/
      IF    ( p_batch_id IS NOT NULL ) THEN
              fnd_file.put_line(fnd_file.Log,' Control entrered into Batch ID varification block with : ' || p_batch_id);
              l_where_clause  :=l_where_clause||' AND hdr.batch_id = '||p_batch_id;

              IF l_batch_param THEN
                l_where_clause1  :=l_where_clause1||' AND batch_id = '||p_batch_id;
                l_where_clause2  :=l_where_clause2||' AND batch_id = '||p_batch_id;
                l_where_clause3  :=l_where_clause3||' AND batch_id = '||p_batch_id;
              ELSE
                l_where_clause1  :=l_where_clause1||' batch_id = '||p_batch_id;
                l_where_clause2  :=l_where_clause2||' batch_id = '||p_batch_id;
                l_where_clause3  :=l_where_clause3||' batch_id = '||p_batch_id;
                l_batch_param := TRUE;
                l_status_param := TRUE;
                l_system_param := TRUE;
              END IF;

      END IF;

      /*Case when target_system_code is passed as input parameter to delete publish history*/
      IF ( p_target_system_code IS NOT NULL ) THEN

          fnd_file.put_line(fnd_file.Log,' Control entrered into Target System varification block with : ' || p_target_system_code );
          l_where_clause  :=l_where_clause||' AND status.system_code = '''||p_target_system_code||'''';

          IF l_status_param THEN
             l_where_clause2  :=l_where_clause2 ||' AND system_code = '''||p_target_system_code||'''';
             l_where_clause3  :=l_where_clause3 ||' AND system_code = '''||p_target_system_code||'''';
          ELSE
             l_where_clause2  :=l_where_clause2||' system_code = '''||p_target_system_code||'''';
             l_where_clause3  :=l_where_clause3||' system_code = '''||p_target_system_code||'''';
             l_status_param := TRUE;
             l_system_param := TRUE;
          END IF;

          l_system_flag := TRUE;
      END IF;

     /* Taking the range of dates for purging */
      IF  (p_from_date IS NOT NULL AND p_to_date IS NOT NULL) THEN

           fnd_file.put_line(fnd_file.Log,' Control entrered into Date range varification block from : ' || l_from_date || ' to ' || l_to_date);
           SELECT To_Char(To_Date(l_from_date,'dd-mm-yy hh24:mi:ss'),'dd-mon-yy hh24:mi:ss') INTO l_pub_dt FROM dual;
           SELECT To_Char(To_Date(l_to_date,'dd-mm-yy hh24:mi:ss') ,'dd-mon-yy hh24:mi:ss') INTO l_pub_dt_to FROM dual;
           l_where_clause  :=l_where_clause||' AND hdr.batch_creation_date  >= To_Date( '''||l_pub_dt||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';
           l_where_clause  :=l_where_clause||' AND hdr.batch_creation_date  <= To_Date( '''||l_pub_dt_to||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';

           IF l_batch_param THEN
             l_where_clause1  :=l_where_clause1 ||' AND batch_creation_date  >= To_Date( '''||l_pub_dt||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';
             l_where_clause1  :=l_where_clause1 ||' AND batch_creation_date  <= To_Date( '''||l_pub_dt_to||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';
           ELSE
             l_where_clause1  :=l_where_clause1 ||' batch_creation_date  >= To_Date( '''||l_pub_dt||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';
             l_where_clause1  :=l_where_clause1 ||' batch_creation_date  <= To_Date( '''||l_pub_dt_to||''' ,''dd-mon-yy hh24:mi:ss'''|| ' )';
             l_batch_param := TRUE;
           END IF;

      END IF;

      /*Case when publish status is passed as input parameter to delete publish history*/
      IF   (p_status_code IS NOT NULL) THEN
          fnd_file.put_line(fnd_file.Log,' Control entrered into status varification block with : ' || p_status_code);
          l_where_clause  :=l_where_clause||' AND status.status_code   = '''||p_status_code||'''';

          IF l_status_param THEN
             l_where_clause2  :=l_where_clause2 ||' AND status_code   = '''||p_status_code||'''';
          ELSE
             l_where_clause2  :=l_where_clause2 ||' status_code   = '''||p_status_code||'''';
             l_status_param := TRUE;
          END IF;

          l_status_flag := TRUE;
      END IF;

      /*Case when publisher is passed as input parameter to delete publish history*/
      IF   (p_published_by IS NOT NULL) THEN
           fnd_file.put_line(fnd_file.Log,' Control entrered into Publiched by varification block with : ' || p_published_by);
           l_where_clause  :=l_where_clause||' AND hdr.PUBLISHED_BY   = '||p_published_by;

           IF l_batch_param THEN
             l_where_clause1  :=l_where_clause1 ||' AND PUBLISHED_BY   = '||p_published_by;
           ELSE
             l_where_clause1  :=l_where_clause1 ||' PUBLISHED_BY   = '||p_published_by;
             l_batch_param := TRUE;
           END IF;

      END IF;

      IF (p_entity_type IS NOT NULL ) THEN
           fnd_file.put_line(fnd_file.Log,' Control entrered into Entity type by varification block with : ' || p_entity_type);
           l_where_clause  :=l_where_clause||' AND hdr.batch_type   = '||p_entity_type;

           IF l_batch_param THEN
             l_where_clause1  :=l_where_clause1 ||' AND batch_type   = '||p_entity_type;
           ELSE
             l_where_clause1  :=l_where_clause1 ||' batch_type   = '||p_entity_type;
             l_batch_param := TRUE;
           END IF;

      END IF;

      IF (l_where_clause1 IS NOT NULL) THEN
         l_batch_sql1 := l_batch_sql1 ||l_where_clause1 ;
         fnd_file.put_line(fnd_file.Log,' l_batch_sql1 = '||l_batch_sql1);
         EXECUTE IMMEDIATE l_batch_sql1 BULK COLLECT INTO l_batch_tab1;
      END IF;

      IF (l_where_clause2 IS NOT NULL) THEN
         l_batch_sql2 := l_batch_sql2 ||l_where_clause2 ;
         fnd_file.put_line(fnd_file.Log,' l_batch_sql2 = '||l_batch_sql2);
         EXECUTE IMMEDIATE l_batch_sql2 BULK COLLECT INTO l_batch_tab2;
      END IF;

      IF (l_where_clause3 IS NOT NULL) THEN
          l_batch_sql3 := l_batch_sql3 ||l_where_clause3 ;
          fnd_file.put_line(fnd_file.Log,' l_batch_sql3 = '||l_batch_sql3);
          EXECUTE IMMEDIATE l_batch_sql3 BULK COLLECT INTO l_batch_tab3;
      END IF;

      IF (l_batch_tab3.count >  l_batch_tab2.count ) THEN
          fnd_file.put_line(fnd_file.Log,'getting the batch id from Systems table');
          EXECUTE IMMEDIATE l_batch_sql3 BULK COLLECT INTO l_batch_tab;
      ELSIF ( l_batch_tab3.count = 0 AND l_batch_tab2.count = 0 AND l_batch_tab1.Count <> 0) THEN
          fnd_file.put_line(fnd_file.Log,'getting the batch id from Batch header table');
          EXECUTE IMMEDIATE l_batch_sql1 BULK COLLECT INTO l_batch_tab;
      ELSE
          l_batch_sql   := l_batch_sql||l_where_clause;
          fnd_file.put_line(fnd_file.Log,' l_batch_sql ='||l_batch_sql);
          EXECUTE IMMEDIATE l_batch_sql BULK COLLECT INTO l_batch_tab;
      END IF;

      fnd_file.put_line(fnd_file.Log,' before final execution of deleting the data from the tables' );
      -- Once we get batch_id for passed in parameter, we will delete data from all tables.

       fnd_file.put_line(fnd_file.Log, 'Total Count of batch ID : ' || l_batch_tab.Count);

       IF   l_batch_tab.Count>0 THEN
          FOR i IN l_batch_tab.FIRST..l_batch_tab.LAST
          LOOP
              fnd_file.put_line(fnd_file.Log,' Enetered FOR loop for ' || i || ' time' );
              l_batch_id:=  l_batch_tab(i) ;

              EXECUTE IMMEDIATE ' select count(*) from EGO_PUB_BAT_STATUS_B where BATCH_ID = ' || l_batch_id INTO l_status_sel_count;
              EXECUTE IMMEDIATE ' select count(*) from EGO_PUB_BAT_SYSTEMS_B where BATCH_ID = ' || l_batch_id INTO l_system_sel_count;

              fnd_file.put_line(fnd_file.Log,'ststus table count is ' || l_status_sel_count);
              fnd_file.put_line(fnd_file.Log,'system table count is ' || l_system_sel_count);


              IF (l_where_clause2 IS NOT NULL) THEN
                  fnd_file.put_line(fnd_file.Log,' Getting systems based on given status for deleting systems table');
                  l_where_clause2  := l_where_clause2 ||' AND BATCH_ID = '|| l_batch_id ;
                  l_status_sys_seq := l_status_sys_seq || l_where_clause2;
                  fnd_file.put_line(fnd_file.Log,'l_status_sys_seq = ' || l_status_sys_seq);
                  EXECUTE IMMEDIATE l_status_sys_seq BULK COLLECT INTO l_status_syss ;
                  fnd_file.put_line(fnd_file.Log,'l_status_syss count = ' || l_status_syss.count);

                  IF l_status_syss.Count > 0 THEN
                   FOR j IN l_status_syss.FIRST..l_status_syss.LAST
                   LOOP
                    l_sys_frm_status :=  l_status_syss(j) ;
                    fnd_file.put_line(fnd_file.Log,'deleting system ' || l_sys_frm_status || ' from systems table for the batch id = ' || l_batch_id);
                    EXECUTE IMMEDIATE   l_delete_batch_system1 USING l_batch_id,l_sys_frm_status;
                   END LOOP;
                  END IF;
                END IF;

              IF ( l_status_sel_count >= 1 AND l_status_flag AND l_system_flag)THEN
                fnd_file.put_line(fnd_file.Log,'Given status code and systems. There are other records along with the given input, so deleting only the provided input from status table');
                EXECUTE IMMEDIATE l_delete_batch_status2 USING  l_batch_id, p_target_system_code,p_status_code;
                l_exec_status := FALSE ;
              ELSIF ( l_status_sel_count >= 1 AND l_status_flag) THEN
                fnd_file.put_line(fnd_file.Log,'There are other records along with the given status code, so deleting only the provided input from status table ');
                EXECUTE IMMEDIATE l_delete_batch_status1 USING  l_batch_id, p_status_code;
                l_exec_status := FALSE ;
              ELSIF ( l_status_sel_count >= 1 AND l_system_flag)THEN
                fnd_file.put_line(fnd_file.Log,'There are other records along with the given system code, so deleting only the provided input from status table');
                EXECUTE IMMEDIATE l_delete_batch_status3 USING  l_batch_id, p_target_system_code;
                l_exec_status := FALSE ;
              END IF;

              IF ( l_system_sel_count >= 1 AND l_system_flag) THEN
                fnd_file.put_line(fnd_file.Log,'There are other records along with the given system code, so deleting only the provided input from systems table');
                EXECUTE IMMEDIATE   l_delete_batch_system1 USING l_batch_id,p_target_system_code;
                l_exec_sys := FALSE ;
              END IF;

              IF( l_exec_status AND l_exec_sys) THEN
              fnd_file.put_line(fnd_file.Log,'deleting compltely based on Batch ID as there are no other data in the status and systems table');
                EXECUTE IMMEDIATE   l_delete_batch_hdr  USING l_batch_id;
                EXECUTE IMMEDIATE   l_delete_batch_param  USING l_batch_id;
                EXECUTE IMMEDIATE   l_delete_entity_obj  USING l_batch_id;
                EXECUTE IMMEDIATE   l_delete_batch_status  USING l_batch_id;
                EXECUTE IMMEDIATE   l_delete_batch_system  USING l_batch_id;

             ELSE
                EXECUTE IMMEDIATE ' select count(*) from EGO_PUB_BAT_STATUS_B where BATCH_ID = ' || l_batch_id INTO l_status_sel_count;
                EXECUTE IMMEDIATE ' select count(*) from EGO_PUB_BAT_SYSTEMS_B where BATCH_ID = ' || l_batch_id INTO l_system_sel_count;

                IF ( l_status_sel_count = 0 AND l_system_sel_count = 0 ) THEN
                  EXECUTE IMMEDIATE   l_delete_batch_hdr  USING l_batch_id;
                  EXECUTE IMMEDIATE   l_delete_batch_param  USING l_batch_id;
                  EXECUTE IMMEDIATE   l_delete_entity_obj  USING l_batch_id;
                END IF;
             END IF;

            fnd_file.put_line(fnd_file.Log,'records are deleted based on the given parameters ');
         END LOOP;
       ELSE
         fnd_file.put_line(fnd_file.Log,'No records are deleted  as the count of batch ID is 0');

       END IF;

      --After deletion of publish history sending message to log file

      Return;

EXCEPTION
   WHEN OTHERS THEN
            err_buff:= SQLERRM;
            --Sending message to log file in case of runtime exception occurs.
            fnd_file.put_line(fnd_file.Log,'Records are not deleted due to runtime exception '||SQLERRM);
END Purge_Publish_History;
/* End Purge_Publish_History API*/
END ego_pub_hist_purge_pkg;

/
