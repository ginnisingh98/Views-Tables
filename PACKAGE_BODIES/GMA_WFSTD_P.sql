--------------------------------------------------------
--  DDL for Package Body GMA_WFSTD_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_WFSTD_P" AS
/* $Header: GMAWFSTB.pls 115.7 2002/11/01 21:19:22 appldev ship $ */
 /*  Procedure to get the role. Input parameters are
  Wokflow type, Process type and Activity_type */
   PROCEDURE get_role(

      p_wf_item_type     IN varchar2,
      p_process_name     IN varchar2,
      p_activity_name    IN varchar2,
      p_datastring       IN VARCHAR2,
      P_role             OUT NOCOPY VARCHAR2
                ) IS

   l_column_name1   GMA_ACTDATA_WF.COLUMN_NAME1%TYPE DEFAULT NULL;
   l_column_value1  GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   l_column_name2   GMA_ACTDATA_WF.COLUMN_NAME2%TYPE DEFAULT NULL;
   l_column_value2  GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   l_column_name3   GMA_ACTDATA_WF.COLUMN_NAME3%TYPE DEFAULT NULL;
   l_column_value3  GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   l_column_name4   GMA_ACTDATA_WF.COLUMN_NAME4%TYPE DEFAULT NULL;
   l_column_value4  GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   l_column_name5   GMA_ACTDATA_WF.COLUMN_NAME5%TYPE DEFAULT NULL;
   l_column_value5  GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   l_column_name6   GMA_ACTDATA_WF.COLUMN_NAME6%TYPE DEFAULT NULL;
   l_column_value6  GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   l_column_name7   GMA_ACTDATA_WF.COLUMN_NAME7%TYPE DEFAULT NULL;
   l_column_value7  GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   l_column_name8   GMA_ACTDATA_WF.COLUMN_NAME8%TYPE DEFAULT NULL;
   l_column_value8  GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   l_column_name9   GMA_ACTDATA_WF.COLUMN_NAME9%TYPE DEFAULT NULL;
   l_column_value9  GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   l_column_name10  GMA_ACTDATA_WF.COLUMN_NAME10%TYPE DEFAULT NULL;
   l_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;

  /* Temperory Place holders in intermediate search */
   Temp_column_value1 GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   Temp_column_value2 GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   Temp_column_value3 GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   Temp_column_value4 GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   Temp_column_value5 GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   Temp_column_value6 GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   Temp_column_value7 GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   Temp_column_value8 GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   Temp_column_value9 GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   Temp_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;


   /* To count number of Columns */
   l_column_count     NUMBER;

   /* To count the number of parameters passed */
   l_parameter_count  NUMBER;

   /* To Count the number of searches for where clause loop */
   l_search_count NUMBER;
   /* To get the default delimiter */
   l_delimiter varchar2(10);

   /* To get the temperory column name for the cursor */

   l_temp_col_name GMA_ACTDATA_WF.COLUMN_NAME1%TYPE;
   l_temp_col_value GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE;


   l_col_name_value VARCHAR2(100);

   l_activity_id NUMBER;

   l_parsing_sql VARCHAR2(4000);

   l_where_clause VARCHAR2(4000);

   l_loop_counter NUMBER;

/* To check the fetched rows */

   l_fetched_rows BOOLEAN;

/* Variables for Dynamic SQL */

   l_dbms_cur                integer;
   l_Rows_processed          integer;

/* Temperory string Holder */
   l_datastring VARCHAR2(4000);

/* Cursor to get the column hierarchy for a given activity */

   CURSOR Cur_Actcol_wf(X_activity_id NUMBER) IS
          SELECT COLUMN_NAME
          FROM   gma_actcol_wf_b
          WHERE  activity_id = X_activity_id
          ORDER BY Column_hierarchy;

/* Cursot to fetch a role for the given attributes  */

   CURSOR Cur_find_role(X_activity_id NUMBER,
                        X_column_name1  VARCHAR2,
                        X_column_value1 VARCHAR2,
                        X_column_name2 VARCHAR2,
                        X_column_value2 VARCHAR2,
                        X_column_name3 VARCHAR2,
                        X_column_value3 VARCHAR2,
                        X_column_name4 VARCHAR2,
                        X_column_value4 VARCHAR2,
                        X_column_name5 VARCHAR2,
                        X_column_value5 VARCHAR2,
                        X_column_name6 VARCHAR2,
                        X_column_value6 VARCHAR2,
                        X_column_name7 VARCHAR2,
                        X_column_value7 VARCHAR2,
                        X_column_name8 VARCHAR2,
                        X_column_value8 VARCHAR2,
                        X_column_name9 VARCHAR2,
                        X_column_value9 VARCHAR2,
                        X_column_name10 VARCHAR2,
                        X_column_value10 VARCHAR2) IS
             SELECT role
             FROM   gma_actdata_wf
             WHERE  activity_id    = X_activity_id AND
                    nvl(column_name1,0)    = nvl(X_column_name1,0)   AND
                    nvl(column_value1,0)   = nvl(X_column_value1,0)  AND
                    nvl(column_name2,0)    = nvl(X_column_name2,0)   AND
                    nvl(column_value2,0)   = nvl(X_column_value2,0)  AND
                    nvl(column_name3,0)    = nvl(X_column_name3,0)   AND
                    nvl(column_value3,0)   = nvl(X_column_value3,0)  AND
                    nvl(column_name4,0)    = nvl(X_column_name4,0)   AND
                    nvl(column_value4,0)   = nvl(X_column_value4,0)  AND
                    nvl(column_name5,0)    = nvl(X_column_name5,0)   AND
                    nvl(column_value5,0)   = nvl(X_column_value5,0)  AND
                    nvl(column_name6,0)    = nvl(X_column_name6,0)   AND
                    nvl(column_value6,0)   = nvl(X_column_value6,0)  AND
                    nvl(column_name7,0)    = nvl(X_column_name7,0)   AND
                    nvl(column_value7,0)   = nvl(X_column_value7,0)  AND
                    nvl(column_name8,0)    = nvl(X_column_name8,0)   AND
                    nvl(column_value8,0)   = nvl(X_column_value8,0)  AND
                    nvl(column_name9,0)    = nvl(X_column_name9,0)   AND
                    nvl(column_value9,0)   = nvl(X_column_value9,0)  AND
                    nvl(column_name10,0)   = nvl(X_column_name10,0)  AND
                    nvl(column_value10,0)  = nvl(X_column_value10,0);

   BEGIN
        p_role:='NOROLE';
        IF (FND_PROFILE.DEFINED ('SY$WF_DELIMITER')) THEN
        	  l_delimiter := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
        ELSE
             p_role:= 'ERROR';
        END IF;

        IF l_delimiter is NULL THEN
            p_role:= 'ERROR';
        END IF;

        SELECT activity_id into l_activity_id
        FROM   gma_actdef_wf
        WHERE  wf_item_type  = p_wf_item_type AND
               process_name  = p_process_name AND
               activity_name = p_activity_name;

        /* Initializing the column count */
        l_column_count := 0;
        /* Populating the column name according to the hierarchy */
           OPEN Cur_Actcol_wf(l_activity_id);
           LOOP
              Fetch Cur_Actcol_wf into  l_temp_col_name;
              IF Cur_Actcol_WF%FOUND THEN
                	     l_column_count := l_column_count + 1;
                       IF    l_column_count = 1 THEN
                             l_column_name1:=l_temp_col_name;
	                 ELSIF l_column_count = 2 THEN
                             l_column_name2:=l_temp_col_name;
	                 ELSIF l_column_count = 3 THEN
                             l_column_name3:=l_temp_col_name;
	                 ELSIF l_column_count = 4 THEN
                             l_column_name4:=l_temp_col_name;
	                 ELSIF l_column_count = 5 THEN
                             l_column_name5:=l_temp_col_name;
	                 ELSIF l_column_count = 6 THEN
                             l_column_name6:=l_temp_col_name;
	                 ELSIF l_column_count = 7 THEN
                             l_column_name7:=l_temp_col_name;
	                 ELSIF l_column_count = 8 THEN
                             l_column_name8:=l_temp_col_name;
	                 ELSIF l_column_count = 9 THEN
                             l_column_name9:=l_temp_col_name;
	                 ELSIF l_column_count = 10 THEN
                             l_column_name10:=l_temp_col_name;
	                 END IF;
               ELSE
                       EXIT;
               END IF;
           END LOOP;
           CLOSE Cur_Actcol_wf;

   /* Initializing parameter count  */
          l_parameter_count := 0;

   /* Setting Column Count to Where clause search count */
          l_search_count:=l_column_count;

          l_datastring:=p_datastring;
      /* Start processing the String */

       LOOP
          IF l_datastring IS NOT NULL THEN
             l_parameter_count:=l_parameter_count+1;
            IF (instr(l_datastring,l_delimiter,1,1) <> 0) THEN
                        l_col_name_value := substr(l_datastring,1,instr(l_datastring,l_delimiter,1,1)-1);
                        l_datastring :=substr(l_datastring,instr(l_datastring,l_delimiter,1,1)+1);
            ELSE
                       l_col_name_value:=l_datastring;
                       l_datastring:=NULL;
            END IF;

                  /* Checking for the column name and assigning the Value to the column */
                     l_temp_col_name := substr(l_col_name_value,1,instr(l_col_name_value,'=',1,1)-1);
                     l_temp_col_value:= substr(l_col_name_value,instr(l_col_name_value,'=',1,1)+1);
                  /* Assign the column value accordingly */

                     IF l_temp_col_name = l_column_name1 THEN
                        l_column_value1:=l_temp_col_value;
                        temp_column_value1:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name2 THEN
                        l_column_value2:=l_temp_col_value;
                        temp_column_value2:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name3 THEN
                        l_column_value3:=l_temp_col_value;
                        temp_column_value3:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name4 THEN
                        l_column_value4:=l_temp_col_value;
                        temp_column_value4:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name5 THEN
                        l_column_value5:=l_temp_col_value;
                        temp_column_value5:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name6 THEN
                        l_column_value6:=l_temp_col_value;
                        temp_column_value6:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name7 THEN
                        l_column_value7:=l_temp_col_value;
                        temp_column_value7:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name8 THEN
                        l_column_value8:=l_temp_col_value;
                        temp_column_value8:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name9 THEN
                        l_column_value9:=l_temp_col_value;
                        temp_column_value9:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name10 THEN
                        l_column_value10:=l_temp_col_value;
                        temp_column_value10:=l_temp_col_value;
                     END IF;

          ELSE
                     EXIT;
          END IF;
       END LOOP;
              /* Check for the passed parameters */
                IF l_column_count <> l_parameter_count THEN
                    p_role := 'ERROR';
                 END IF;



          /* Fetch the details using cursor Using Bottom Up Approach */
        LOOP
              IF l_search_count > 0 THEN
                 OPEN Cur_find_role(l_activity_id ,
                                    l_column_name1,l_column_value1,
                                    l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3,
                                    l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5,
                                    l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7,
                                    l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9,
                                    l_column_name10,l_column_value10);
                  FETCH cur_find_role into p_role;
                  IF cur_find_role%FOUND THEN
                     CLOSE Cur_find_role;
                     EXIT;
                  ELSE
                  /* Make the last column value in hierarchy NULL */
                                   IF    l_search_count = 10 THEN
             		                 l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                   END IF;
       		                   l_search_count:=l_search_count-1;
                                   CLOSE Cur_find_role;
                  END IF;
              ELSE
                  EXIT;
              END IF;
     END LOOP;



     IF p_role = 'NOROLE' THEN
          /* Re assigning the column values */
          l_column_value1 :=temp_column_value1;
          l_column_value2 :=temp_column_value2;
          l_column_value3 :=temp_column_value3;
          l_column_value4 :=temp_column_value4;
          l_column_value5 :=temp_column_value5;
          l_column_value6 :=temp_column_value6;
          l_column_value7 :=temp_column_value7;
          l_column_value8 :=temp_column_value8;
          l_column_value9 :=temp_column_value9;
          l_column_value10:=temp_column_value10;

          /* Initilizing the Search count to start from first column in hierarchy */
          l_search_count:=1;

          /* Fetch the details using cursor Using Top Down Approach */

         LOOP
              IF l_search_count <= 10 THEN

                                     IF    l_search_count = 10 THEN
             		                   l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                     END IF;

                 OPEN Cur_find_role(l_activity_id ,
                                    l_column_name1,l_column_value1, l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3, l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5, l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7, l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9, l_column_name10,l_column_value10);
                  FETCH cur_find_role into p_role;
                  IF cur_find_role%FOUND THEN
                     CLOSE Cur_find_role;
                     EXIT;
                  ELSE
                  /* Make the NEXT column value in hierarchy NULL */
       		     l_search_count:=l_search_count+1;
                     CLOSE Cur_find_role;
                  END IF;
              ELSE
                  EXIT;
              END IF;
         END LOOP;
      END IF;
   EXCEPTION
                WHEN no_data_found THEN
                p_role:='ERROR';

   END get_role;

   FUNCTION check_process_approval_req(p_wf_item_type  VARCHAR2,
                                       p_Process_name  VARCHAR2,
                                       p_datastring    VARCHAR2) RETURN VARCHAR2 IS
   l_column_name1   GMA_ACTDATA_WF.COLUMN_NAME1%TYPE DEFAULT NULL;
   l_column_value1  GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   l_column_name2   GMA_ACTDATA_WF.COLUMN_NAME2%TYPE DEFAULT NULL;
   l_column_value2  GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   l_column_name3   GMA_ACTDATA_WF.COLUMN_NAME3%TYPE DEFAULT NULL;
   l_column_value3  GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   l_column_name4   GMA_ACTDATA_WF.COLUMN_NAME4%TYPE DEFAULT NULL;
   l_column_value4  GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   l_column_name5   GMA_ACTDATA_WF.COLUMN_NAME5%TYPE DEFAULT NULL;
   l_column_value5  GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   l_column_name6   GMA_ACTDATA_WF.COLUMN_NAME6%TYPE DEFAULT NULL;
   l_column_value6  GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   l_column_name7   GMA_ACTDATA_WF.COLUMN_NAME7%TYPE DEFAULT NULL;
   l_column_value7  GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   l_column_name8   GMA_ACTDATA_WF.COLUMN_NAME8%TYPE DEFAULT NULL;
   l_column_value8  GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   l_column_name9   GMA_ACTDATA_WF.COLUMN_NAME9%TYPE DEFAULT NULL;
   l_column_value9  GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   l_column_name10  GMA_ACTDATA_WF.COLUMN_NAME10%TYPE DEFAULT NULL;
   l_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;

  /* Temperory Place holders in intermediate search */
   Temp_column_value1 GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   Temp_column_value2 GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   Temp_column_value3 GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   Temp_column_value4 GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   Temp_column_value5 GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   Temp_column_value6 GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   Temp_column_value7 GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   Temp_column_value8 GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   Temp_column_value9 GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   Temp_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;


   /* To count number of Columns */
   l_column_count     NUMBER;

   /* To count the number of parameters passed */
   l_parameter_count  NUMBER;

   /* To Count the number of searches for where clause loop */
   l_search_count NUMBER;
   /* To get the default delimiter */
   l_delimiter varchar2(10);

   /* To get the temperory column name for the cursor */

   l_temp_col_name GMA_ACTDATA_WF.COLUMN_NAME1%TYPE;
   l_temp_col_value GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE;


   l_col_name_value VARCHAR2(100);

   l_activity_id NUMBER;

   l_parsing_sql VARCHAR2(4000);

   l_where_clause VARCHAR2(4000);

   l_loop_counter NUMBER;

/* To check the fetched rows */

   l_fetched_rows BOOLEAN;

/* Variables for Dynamic SQL */

   l_dbms_cur                integer;
   l_Rows_processed          integer;

/* Temperory string Holder */
   l_datastring VARCHAR2(4000);

/* Cursor to get the column hierarchy for a given activity */

   CURSOR Cur_Actcol_wf(X_wf_item_type VARCHAR2,
                        X_process_name VARCHAR2) IS
          SELECT COLUMN_NAME
          FROM   gma_proccol_wf_b
          WHERE  wf_item_type = X_wf_item_type
            AND  process_name = X_process_name
          ORDER BY Column_hierarchy;

/* Cursot to fetch a role for the given attributes  */

   CURSOR Cur_appr_req(X_wf_item_type VARCHAR2,
                        X_process_name VARCHAR2,
                        X_column_name1  VARCHAR2,
                        X_column_value1 VARCHAR2,
                        X_column_name2 VARCHAR2,
                        X_column_value2 VARCHAR2,
                        X_column_name3 VARCHAR2,
                        X_column_value3 VARCHAR2,
                        X_column_name4 VARCHAR2,
                        X_column_value4 VARCHAR2,
                        X_column_name5 VARCHAR2,
                        X_column_value5 VARCHAR2,
                        X_column_name6 VARCHAR2,
                        X_column_value6 VARCHAR2,
                        X_column_name7 VARCHAR2,
                        X_column_value7 VARCHAR2,
                        X_column_name8 VARCHAR2,
                        X_column_value8 VARCHAR2,
                        X_column_name9 VARCHAR2,
                        X_column_value9 VARCHAR2,
                        X_column_name10 VARCHAR2,
                        X_column_value10 VARCHAR2) IS
             SELECT ENABLE_FLAG
             FROM   gma_procdata_wf
             WHERE  wf_item_type           = X_wf_item_type          AND
                    process_name           = X_process_name          AND
                    nvl(column_name1,0)    = nvl(X_column_name1,0)   AND
                    nvl(column_value1,0)   = nvl(X_column_value1,0)  AND
                    nvl(column_name2,0)    = nvl(X_column_name2,0)   AND
                    nvl(column_value2,0)   = nvl(X_column_value2,0)  AND
                    nvl(column_name3,0)    = nvl(X_column_name3,0)   AND
                    nvl(column_value3,0)   = nvl(X_column_value3,0)  AND
                    nvl(column_name4,0)    = nvl(X_column_name4,0)   AND
                    nvl(column_value4,0)   = nvl(X_column_value4,0)  AND
                    nvl(column_name5,0)    = nvl(X_column_name5,0)   AND
                    nvl(column_value5,0)   = nvl(X_column_value5,0)  AND
                    nvl(column_name6,0)    = nvl(X_column_name6,0)   AND
                    nvl(column_value6,0)   = nvl(X_column_value6,0)  AND
                    nvl(column_name7,0)    = nvl(X_column_name7,0)   AND
                    nvl(column_value7,0)   = nvl(X_column_value7,0)  AND
                    nvl(column_name8,0)    = nvl(X_column_name8,0)   AND
                    nvl(column_value8,0)   = nvl(X_column_value8,0)  AND
                    nvl(column_name9,0)    = nvl(X_column_name9,0)   AND
                    nvl(column_value9,0)   = nvl(X_column_value9,0)  AND
                    nvl(column_name10,0)   = nvl(X_column_name10,0)  AND
                    nvl(column_value10,0)  = nvl(X_column_value10,0);
    l_enable_flag  gma_procdata_wf.enable_flag%type;
   BEGIN
        l_enable_flag  :='Z';
        IF (FND_PROFILE.DEFINED ('SY$WF_DELIMITER')) THEN
        	  l_delimiter := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
        ELSE
             l_enable_flag  := 'E';
             RETURN l_enable_flag ;
        END IF;

        IF l_delimiter is NULL THEN
            l_enable_flag  := 'E';
             RETURN l_enable_flag ;
        END IF;

        /* Initializing the column count */
        l_column_count := 0;
        /* Populating the column name according to the hierarchy */
           OPEN Cur_Actcol_wf(p_wf_item_type,p_process_name);
           LOOP
              Fetch Cur_Actcol_wf into  l_temp_col_name;
              IF Cur_Actcol_WF%FOUND THEN
                	     l_column_count := l_column_count + 1;
                       IF    l_column_count = 1 THEN
                             l_column_name1:=l_temp_col_name;
	                 ELSIF l_column_count = 2 THEN
                             l_column_name2:=l_temp_col_name;
	                 ELSIF l_column_count = 3 THEN
                             l_column_name3:=l_temp_col_name;
	                 ELSIF l_column_count = 4 THEN
                             l_column_name4:=l_temp_col_name;
	                 ELSIF l_column_count = 5 THEN
                             l_column_name5:=l_temp_col_name;
	                 ELSIF l_column_count = 6 THEN
                             l_column_name6:=l_temp_col_name;
	                 ELSIF l_column_count = 7 THEN
                             l_column_name7:=l_temp_col_name;
	                 ELSIF l_column_count = 8 THEN
                             l_column_name8:=l_temp_col_name;
	                 ELSIF l_column_count = 9 THEN
                             l_column_name9:=l_temp_col_name;
	                 ELSIF l_column_count = 10 THEN
                             l_column_name10:=l_temp_col_name;
	                 END IF;
               ELSE
                       EXIT;
               END IF;
           END LOOP;
           CLOSE Cur_Actcol_wf;

   /* Initializing parameter count  */
          l_parameter_count := 0;

   /* Setting Column Count to Where clause search count */
          l_search_count:=l_column_count;

          l_datastring:=p_datastring;
      /* Start processing the String */

       LOOP
          IF l_datastring IS NOT NULL THEN
             l_parameter_count:=l_parameter_count+1;
            IF (instr(l_datastring,l_delimiter,1,1) <> 0) THEN
                        l_col_name_value := substr(l_datastring,1,instr(l_datastring,l_delimiter,1,1)-1);
                        l_datastring :=substr(l_datastring,instr(l_datastring,l_delimiter,1,1)+1);
            ELSE
                       l_col_name_value:=l_datastring;
                       l_datastring:=NULL;
            END IF;

                  /* Checking for the column name and assigning the Value to the column */
                     l_temp_col_name := substr(l_col_name_value,1,instr(l_col_name_value,'=',1,1)-1);
                     l_temp_col_value:= substr(l_col_name_value,instr(l_col_name_value,'=',1,1)+1);
                  /* Assign the column value accordingly */

                     IF l_temp_col_name = l_column_name1 THEN
                        l_column_value1:=l_temp_col_value;
                        temp_column_value1:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name2 THEN
                        l_column_value2:=l_temp_col_value;
                        temp_column_value2:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name3 THEN
                        l_column_value3:=l_temp_col_value;
                        temp_column_value3:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name4 THEN
                        l_column_value4:=l_temp_col_value;
                        temp_column_value4:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name5 THEN
                        l_column_value5:=l_temp_col_value;
                        temp_column_value5:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name6 THEN
                        l_column_value6:=l_temp_col_value;
                        temp_column_value6:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name7 THEN
                        l_column_value7:=l_temp_col_value;
                        temp_column_value7:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name8 THEN
                        l_column_value8:=l_temp_col_value;
                        temp_column_value8:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name9 THEN
                        l_column_value9:=l_temp_col_value;
                        temp_column_value9:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name10 THEN
                        l_column_value10:=l_temp_col_value;
                        temp_column_value10:=l_temp_col_value;
                     END IF;

          ELSE
                     EXIT;
          END IF;
       END LOOP;
              /* Check for the passed parameters */
                IF l_column_count <> l_parameter_count THEN
                   l_enable_flag := 'E';
                     RETURN l_enable_flag ;
                 END IF;



          /* Fetch the details using cursor Using Bottom Up Approach */
        LOOP
              IF l_search_count > 0 THEN
                 OPEN Cur_appr_req( p_wf_item_type,p_process_name,
                                    l_column_name1,l_column_value1,
                                    l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3,
                                    l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5,
                                    l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7,
                                    l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9,
                                    l_column_name10,l_column_value10);
                  FETCH cur_appr_req into l_enable_flag;
                  IF cur_appr_req%FOUND THEN
                     CLOSE Cur_appr_req;
                     EXIT;
                  ELSE
                  /* Make the last column value in hierarchy NULL */
                                   IF    l_search_count = 10 THEN
             		                 l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                   END IF;
       		                   l_search_count:=l_search_count-1;
                     CLOSE Cur_appr_req;
                  END IF;
              ELSE
                  EXIT;
              END IF;
     END LOOP;



     IF l_enable_flag not in ('Y','N') THEN
          /* Re assigning the column values */
          l_column_value1 :=temp_column_value1;
          l_column_value2 :=temp_column_value2;
          l_column_value3 :=temp_column_value3;
          l_column_value4 :=temp_column_value4;
          l_column_value5 :=temp_column_value5;
          l_column_value6 :=temp_column_value6;
          l_column_value7 :=temp_column_value7;
          l_column_value8 :=temp_column_value8;
          l_column_value9 :=temp_column_value9;
          l_column_value10:=temp_column_value10;

          /* Initilizing the Search count to start from first column in hierarchy */
          l_search_count:=1;

          /* Fetch the details using cursor Using Top Down Approach */

         LOOP
              IF l_search_count <= 10 THEN

                                     IF    l_search_count = 10 THEN
             		                   l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                     END IF;

                 OPEN Cur_appr_req(p_wf_item_type,p_process_name,
                                    l_column_name1,l_column_value1, l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3, l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5, l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7, l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9, l_column_name10,l_column_value10);
                  FETCH cur_appr_req into l_enable_flag;
                  IF cur_appr_req%FOUND THEN
                     CLOSE Cur_appr_req;
                     EXIT;
                  ELSE
                  /* Make the NEXT column value in hierarchy NULL */
       		     l_search_count:=l_search_count+1;
                     CLOSE Cur_appr_req;
                  END IF;
              ELSE
                  EXIT;
              END IF;
         END LOOP;
      END IF;
      RETURN l_enable_flag ;
   EXCEPTION
                WHEN no_data_found THEN
                RETURN l_enable_flag ;
    end check_process_approval_req;

   FUNCTION check_activity_approval_req(p_wf_item_type  VARCHAR2,
                                        p_Process_name  VARCHAR2,
                                        p_activity_name    IN varchar2,
                                        p_datastring    VARCHAR2) RETURN VARCHAR2 IS
   l_column_name1   GMA_ACTDATA_WF.COLUMN_NAME1%TYPE DEFAULT NULL;
   l_column_value1  GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   l_column_name2   GMA_ACTDATA_WF.COLUMN_NAME2%TYPE DEFAULT NULL;
   l_column_value2  GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   l_column_name3   GMA_ACTDATA_WF.COLUMN_NAME3%TYPE DEFAULT NULL;
   l_column_value3  GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   l_column_name4   GMA_ACTDATA_WF.COLUMN_NAME4%TYPE DEFAULT NULL;
   l_column_value4  GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   l_column_name5   GMA_ACTDATA_WF.COLUMN_NAME5%TYPE DEFAULT NULL;
   l_column_value5  GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   l_column_name6   GMA_ACTDATA_WF.COLUMN_NAME6%TYPE DEFAULT NULL;
   l_column_value6  GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   l_column_name7   GMA_ACTDATA_WF.COLUMN_NAME7%TYPE DEFAULT NULL;
   l_column_value7  GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   l_column_name8   GMA_ACTDATA_WF.COLUMN_NAME8%TYPE DEFAULT NULL;
   l_column_value8  GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   l_column_name9   GMA_ACTDATA_WF.COLUMN_NAME9%TYPE DEFAULT NULL;
   l_column_value9  GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   l_column_name10  GMA_ACTDATA_WF.COLUMN_NAME10%TYPE DEFAULT NULL;
   l_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;

  /* Temperory Place holders in intermediate search */
   Temp_column_value1 GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
   Temp_column_value2 GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
   Temp_column_value3 GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
   Temp_column_value4 GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
   Temp_column_value5 GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
   Temp_column_value6 GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
   Temp_column_value7 GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
   Temp_column_value8 GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
   Temp_column_value9 GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
   Temp_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;


   /* To count number of Columns */
   l_column_count     NUMBER;

   /* To count the number of parameters passed */
   l_parameter_count  NUMBER;

   /* To Count the number of searches for where clause loop */
   l_search_count NUMBER;
   /* To get the default delimiter */
   l_delimiter varchar2(10);

   /* To get the temperory column name for the cursor */

   l_temp_col_name GMA_ACTDATA_WF.COLUMN_NAME1%TYPE;
   l_temp_col_value GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE;


   l_col_name_value VARCHAR2(100);

   l_activity_id NUMBER;

   l_parsing_sql VARCHAR2(4000);

   l_where_clause VARCHAR2(4000);

   l_loop_counter NUMBER;

/* To check the fetched rows */

   l_fetched_rows BOOLEAN;

/* Variables for Dynamic SQL */

   l_dbms_cur                integer;
   l_Rows_processed          integer;

/* Temperory string Holder */
   l_datastring VARCHAR2(4000);

/* Cursor to get the column hierarchy for a given activity */

   CURSOR Cur_Actcol_wf(X_activity_id NUMBER) IS
          SELECT COLUMN_NAME
          FROM   gma_actcol_wf_b
          WHERE  activity_id = X_activity_id
          ORDER BY Column_hierarchy;

/* Cursot to fetch a role for the given attributes  */

   CURSOR Cur_find_role(X_activity_id NUMBER,
                        X_column_name1  VARCHAR2,
                        X_column_value1 VARCHAR2,
                        X_column_name2 VARCHAR2,
                        X_column_value2 VARCHAR2,
                        X_column_name3 VARCHAR2,
                        X_column_value3 VARCHAR2,
                        X_column_name4 VARCHAR2,
                        X_column_value4 VARCHAR2,
                        X_column_name5 VARCHAR2,
                        X_column_value5 VARCHAR2,
                        X_column_name6 VARCHAR2,
                        X_column_value6 VARCHAR2,
                        X_column_name7 VARCHAR2,
                        X_column_value7 VARCHAR2,
                        X_column_name8 VARCHAR2,
                        X_column_value8 VARCHAR2,
                        X_column_name9 VARCHAR2,
                        X_column_value9 VARCHAR2,
                        X_column_name10 VARCHAR2,
                        X_column_value10 VARCHAR2) IS
             SELECT ENABLE_FLAG
             FROM   gma_actdata_wf
             WHERE  activity_id    = X_activity_id AND
                    nvl(column_name1,0)    = nvl(X_column_name1,0)   AND
                    nvl(column_value1,0)   = nvl(X_column_value1,0)  AND
                    nvl(column_name2,0)    = nvl(X_column_name2,0)   AND
                    nvl(column_value2,0)   = nvl(X_column_value2,0)  AND
                    nvl(column_name3,0)    = nvl(X_column_name3,0)   AND
                    nvl(column_value3,0)   = nvl(X_column_value3,0)  AND
                    nvl(column_name4,0)    = nvl(X_column_name4,0)   AND
                    nvl(column_value4,0)   = nvl(X_column_value4,0)  AND
                    nvl(column_name5,0)    = nvl(X_column_name5,0)   AND
                    nvl(column_value5,0)   = nvl(X_column_value5,0)  AND
                    nvl(column_name6,0)    = nvl(X_column_name6,0)   AND
                    nvl(column_value6,0)   = nvl(X_column_value6,0)  AND
                    nvl(column_name7,0)    = nvl(X_column_name7,0)   AND
                    nvl(column_value7,0)   = nvl(X_column_value7,0)  AND
                    nvl(column_name8,0)    = nvl(X_column_name8,0)   AND
                    nvl(column_value8,0)   = nvl(X_column_value8,0)  AND
                    nvl(column_name9,0)    = nvl(X_column_name9,0)   AND
                    nvl(column_value9,0)   = nvl(X_column_value9,0)  AND
                    nvl(column_name10,0)   = nvl(X_column_name10,0)  AND
                    nvl(column_value10,0)  = nvl(X_column_value10,0);
    l_enable_flag  gma_procdata_wf.enable_flag%type;
   BEGIN
        l_enable_flag :='Y';
        IF (FND_PROFILE.DEFINED ('SY$WF_DELIMITER')) THEN
        	  l_delimiter := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
        ELSE
             l_enable_flag := 'E';
        END IF;

        IF l_delimiter is NULL THEN
            l_enable_flag := 'E';
        END IF;

        SELECT activity_id into l_activity_id
        FROM   gma_actdef_wf
        WHERE  wf_item_type  = p_wf_item_type AND
               process_name  = p_process_name AND
               activity_name = p_activity_name;

        /* Initializing the column count */
        l_column_count := 0;
        /* Populating the column name according to the hierarchy */
           OPEN Cur_Actcol_wf(l_activity_id);
           LOOP
              Fetch Cur_Actcol_wf into  l_temp_col_name;
              IF Cur_Actcol_WF%FOUND THEN
                	     l_column_count := l_column_count + 1;
                       IF    l_column_count = 1 THEN
                             l_column_name1:=l_temp_col_name;
	                 ELSIF l_column_count = 2 THEN
                             l_column_name2:=l_temp_col_name;
	                 ELSIF l_column_count = 3 THEN
                             l_column_name3:=l_temp_col_name;
	                 ELSIF l_column_count = 4 THEN
                             l_column_name4:=l_temp_col_name;
	                 ELSIF l_column_count = 5 THEN
                             l_column_name5:=l_temp_col_name;
	                 ELSIF l_column_count = 6 THEN
                             l_column_name6:=l_temp_col_name;
	                 ELSIF l_column_count = 7 THEN
                             l_column_name7:=l_temp_col_name;
	                 ELSIF l_column_count = 8 THEN
                             l_column_name8:=l_temp_col_name;
	                 ELSIF l_column_count = 9 THEN
                             l_column_name9:=l_temp_col_name;
	                 ELSIF l_column_count = 10 THEN
                             l_column_name10:=l_temp_col_name;
	                 END IF;
               ELSE
                       EXIT;
               END IF;
           END LOOP;
           CLOSE Cur_Actcol_wf;

   /* Initializing parameter count  */
          l_parameter_count := 0;

   /* Setting Column Count to Where clause search count */
          l_search_count:=l_column_count;

          l_datastring:=p_datastring;
      /* Start processing the String */

       LOOP
          IF l_datastring IS NOT NULL THEN
             l_parameter_count:=l_parameter_count+1;
            IF (instr(l_datastring,l_delimiter,1,1) <> 0) THEN
                        l_col_name_value := substr(l_datastring,1,instr(l_datastring,l_delimiter,1,1)-1);
                        l_datastring :=substr(l_datastring,instr(l_datastring,l_delimiter,1,1)+1);
            ELSE
                       l_col_name_value:=l_datastring;
                       l_datastring:=NULL;
            END IF;

                  /* Checking for the column name and assigning the Value to the column */
                     l_temp_col_name := substr(l_col_name_value,1,instr(l_col_name_value,'=',1,1)-1);
                     l_temp_col_value:= substr(l_col_name_value,instr(l_col_name_value,'=',1,1)+1);
                  /* Assign the column value accordingly */

                     IF l_temp_col_name = l_column_name1 THEN
                        l_column_value1:=l_temp_col_value;
                        temp_column_value1:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name2 THEN
                        l_column_value2:=l_temp_col_value;
                        temp_column_value2:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name3 THEN
                        l_column_value3:=l_temp_col_value;
                        temp_column_value3:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name4 THEN
                        l_column_value4:=l_temp_col_value;
                        temp_column_value4:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name5 THEN
                        l_column_value5:=l_temp_col_value;
                        temp_column_value5:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name6 THEN
                        l_column_value6:=l_temp_col_value;
                        temp_column_value6:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name7 THEN
                        l_column_value7:=l_temp_col_value;
                        temp_column_value7:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name8 THEN
                        l_column_value8:=l_temp_col_value;
                        temp_column_value8:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name9 THEN
                        l_column_value9:=l_temp_col_value;
                        temp_column_value9:=l_temp_col_value;
                     ELSIF l_temp_col_name = l_column_name10 THEN
                        l_column_value10:=l_temp_col_value;
                        temp_column_value10:=l_temp_col_value;
                     END IF;

          ELSE
                     EXIT;
          END IF;
       END LOOP;
              /* Check for the passed parameters */
                IF l_column_count <> l_parameter_count THEN
                    l_enable_flag  := 'E';
                 END IF;



          /* Fetch the details using cursor Using Bottom Up Approach */
        LOOP
              IF l_search_count > 0 THEN
                 OPEN Cur_find_role(l_activity_id ,
                                    l_column_name1,l_column_value1,
                                    l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3,
                                    l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5,
                                    l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7,
                                    l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9,
                                    l_column_name10,l_column_value10);
                  FETCH cur_find_role into l_enable_flag ;
                  IF cur_find_role%FOUND THEN
                     CLOSE Cur_find_role;
                     EXIT;
                  ELSE
                  /* Make the last column value in hierarchy NULL */
                                   IF    l_search_count = 10 THEN
             		                 l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                   END IF;
       		                   l_search_count:=l_search_count-1;
                                   CLOSE Cur_find_role;
                  END IF;
              ELSE
                  EXIT;
              END IF;
     END LOOP;



     IF l_enable_flag  = 'E' THEN
          /* Re assigning the column values */
          l_column_value1 :=temp_column_value1;
          l_column_value2 :=temp_column_value2;
          l_column_value3 :=temp_column_value3;
          l_column_value4 :=temp_column_value4;
          l_column_value5 :=temp_column_value5;
          l_column_value6 :=temp_column_value6;
          l_column_value7 :=temp_column_value7;
          l_column_value8 :=temp_column_value8;
          l_column_value9 :=temp_column_value9;
          l_column_value10:=temp_column_value10;

          /* Initilizing the Search count to start from first column in hierarchy */
          l_search_count:=1;

          /* Fetch the details using cursor Using Top Down Approach */

         LOOP
              IF l_search_count <= 10 THEN

                                     IF    l_search_count = 10 THEN
             		                   l_column_value10:=NULL;
	   	            	     ELSIF l_search_count = 9 THEN
                                           l_column_value9:=NULL;
                                     ELSIF l_search_count = 8 THEN
                                           l_column_value8:=NULL;
	   	             	     ELSIF l_search_count = 7 THEN
                                           l_column_value7:=NULL;
                                     ELSIF l_search_count = 6 THEN
                                           l_column_value6:=NULL;
	   	            	     ELSIF l_search_count = 5 THEN
                                           l_column_value5:=NULL;
                                     ELSIF l_search_count = 4 THEN
                                           l_column_value4:=NULL;
	   	            	     ELSIF l_search_count = 3 THEN
                                           l_column_value3:=NULL;
                                     ELSIF l_search_count = 2 THEN
                                           l_column_value2:=NULL;
                                     ELSIF l_search_count = 1 THEN
                                           l_column_value1:=NULL;
                                     END IF;

                 OPEN Cur_find_role(l_activity_id ,
                                    l_column_name1,l_column_value1, l_column_name2,l_column_value2,
                                    l_column_name3,l_column_value3, l_column_name4,l_column_value4,
                                    l_column_name5,l_column_value5, l_column_name6,l_column_value6,
                                    l_column_name7,l_column_value7, l_column_name8,l_column_value8,
                                    l_column_name9,l_column_value9, l_column_name10,l_column_value10);
                  FETCH cur_find_role into l_enable_flag ;
                  IF cur_find_role%FOUND THEN
                     CLOSE Cur_find_role;
                     EXIT;
                  ELSE
                  /* Make the NEXT column value in hierarchy NULL */
       		     l_search_count:=l_search_count+1;
                     CLOSE Cur_find_role;
                  END IF;
              ELSE
                  EXIT;
              END IF;
         END LOOP;
      END IF;
      RETURN l_enable_flag;
   EXCEPTION
      WHEN no_data_found THEN
                l_enable_flag :='E';
                RETURN l_enable_flag;
   end check_activity_approval_req;
/******************************************************************************************/
   FUNCTION check_process_enabled(p_wf_item_type  VARCHAR2,
                                  p_Process_name  VARCHAR2) RETURN BOOLEAN IS
      l_enable_flag       GMA_PROCDEF_WF.enable_flag%TYPE;
   BEGIN
     SELECT enable_flag INTO l_enable_flag
     FROM  GMA_PROCDEF_WF
     WHERE wf_item_type = p_wf_item_type   AND
           process_name = p_process_name;
     IF l_enable_flag = 'Y' THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
   END  check_process_enabled;
/***************************************************************************************/
/*********************************************************************************/

  PROCEDURE WF_GET_CONTORL_PARAMS(P_WF_ITEM_TYPE  IN VARCHAR2,
                                  P_PROCESS_NAME  IN VARCHAR2,
                                  P_ACTIVITY_NAME IN VARCHAR2,
                                  P_TABLE_NAME    IN VARCHAR2,
                                  P_WHERE_CLAUSE  IN VARCHAR2,
                                  P_DATASTRING   OUT NOCOPY VARCHAR2,
                                  P_WFSTRING     OUT NOCOPY VARCHAR2)  IS
  l_sql_stmt       VARCHAR2(4000);
  l_where_position Integer;
  l_key_Table      Integer;
  l_column_name1   GMA_ACTDATA_WF.COLUMN_NAME1%TYPE DEFAULT NULL;
  l_column_value1  GMA_ACTDATA_WF.COLUMN_VALUE1%TYPE DEFAULT NULL;
  l_column_name2   GMA_ACTDATA_WF.COLUMN_NAME2%TYPE DEFAULT NULL;
  l_column_value2  GMA_ACTDATA_WF.COLUMN_VALUE2%TYPE DEFAULT NULL;
  l_column_name3   GMA_ACTDATA_WF.COLUMN_NAME3%TYPE DEFAULT NULL;
  l_column_value3  GMA_ACTDATA_WF.COLUMN_VALUE3%TYPE DEFAULT NULL;
  l_column_name4   GMA_ACTDATA_WF.COLUMN_NAME4%TYPE DEFAULT NULL;
  l_column_value4  GMA_ACTDATA_WF.COLUMN_VALUE4%TYPE DEFAULT NULL;
  l_column_name5   GMA_ACTDATA_WF.COLUMN_NAME5%TYPE DEFAULT NULL;
  l_column_value5  GMA_ACTDATA_WF.COLUMN_VALUE5%TYPE DEFAULT NULL;
  l_column_name6   GMA_ACTDATA_WF.COLUMN_NAME6%TYPE DEFAULT NULL;
  l_column_value6  GMA_ACTDATA_WF.COLUMN_VALUE6%TYPE DEFAULT NULL;
  l_column_name7   GMA_ACTDATA_WF.COLUMN_NAME7%TYPE DEFAULT NULL;
  l_column_value7  GMA_ACTDATA_WF.COLUMN_VALUE7%TYPE DEFAULT NULL;
  l_column_name8   GMA_ACTDATA_WF.COLUMN_NAME8%TYPE DEFAULT NULL;
  l_column_value8  GMA_ACTDATA_WF.COLUMN_VALUE8%TYPE DEFAULT NULL;
  l_column_name9   GMA_ACTDATA_WF.COLUMN_NAME9%TYPE DEFAULT NULL;
  l_column_value9  GMA_ACTDATA_WF.COLUMN_VALUE9%TYPE DEFAULT NULL;
  l_column_name10  GMA_ACTDATA_WF.COLUMN_NAME10%TYPE DEFAULT NULL;
  l_column_value10 GMA_ACTDATA_WF.COLUMN_VALUE10%TYPE DEFAULT NULL;
  l_column_prompt1 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt2 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt3 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt4 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt5 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt6 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt7 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt8 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt9 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;
  l_column_prompt10 GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE  DEFAULT NULL;

  l_activity_id    GMA_ACTDATA_WF.ACTIVITY_ID%TYPE;
/* Cursor to get the column list for a given activity */
  V_cursor_id    INTEGER;
  v_dummy        INTEGER;
   Data_string   Varchar2(2500);
   wf_Data_string   Varchar2(2500);
   l_temp_col_name  GMA_ACTDATA_WF.COLUMN_NAME1%TYPE;
   l_temp_prompt    GMA_ACTCOL_WF_TL.COLUMN_PROMPT%TYPE;
   CURSOR Cur_Actcol_wf IS
          SELECT COLUMN_NAME,COLUMN_PROMPT
          FROM   gma_actcol_wf_vl
          WHERE  activity_id = l_activity_id
          ORDER BY Column_hierarchy;
   CURSOR Cur_Proccol_wf IS
          SELECT COLUMN_NAME,COLUMN_PROMPT
          FROM   gma_proccol_wf_vl
          WHERE WF_ITEM_TYPE = P_WF_ITEM_TYPE  AND
                PROCESS_NAME = p_PROCESS_NAME
          ORDER BY Column_hierarchy;
   l_column_count Integer :=0;
   l_no_rows      Integer :=0;
   l_col_vals     Integer :=0;
   error_message  VARCHAR2(2000);
   /* To get the default delimiter */
   l_delimiter varchar2(10);
   WF_ERROR  Exception;
  BEGIN
      IF p_where_clause is null
      Then
        data_string:= 'WHERE_ERROR';
        Raise WF_ERROR;
      END IF;
      IF P_table_name IS NULL
      THEN
        data_string:= 'TABLE_ERROR';
        Raise WF_ERROR;
      END IF;
      IF (FND_PROFILE.DEFINED ('SY$WF_DELIMITER')) THEN
        l_delimiter := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
     ELSE
        data_string:= 'PROFILE_ERROR';
        Raise WF_ERROR;
     END IF;

     IF l_delimiter is NULL THEN
        data_string:= 'PROFILE_ERROR';
        Raise WF_ERROR;
     END IF;
     IF P_ACTIVITY_NAME IS NULL THEN
        SELECT column_data_sql into l_sql_stmt
        FROM GMA_PROCDEF_WF
        WHERE WF_ITEM_TYPE = P_WF_ITEM_TYPE  AND
              PROCESS_NAME = p_PROCESS_NAME;
     ELSE
        SELECT column_data_sql,activity_id into l_sql_stmt,l_activity_id
        FROM GMA_ACTDEF_WF
        WHERE WF_ITEM_TYPE = P_WF_ITEM_TYPE  AND
              PROCESS_NAME = p_PROCESS_NAME  AND
              ACTIVITY_NAME= P_ACTIVITY_NAME;
     END IF;
     l_key_table         := instr(UPPER(l_sql_stmt),UPPER(p_table_name));
     IF nvl(l_key_table,0) = 0
        /*  Key table is missing in SQL Statement or
            no SQL statement We can't proced with the workflow */
     THEN
        data_string:= 'SQL_ERROR';
        Raise WF_ERROR;
     ELSE
        l_where_position    := instr(UPPER(l_sql_stmt),'WHERE');
        IF l_where_position = 0 /*  No where Clause */
        THEN
          l_sql_stmt := l_sql_stmt || '  WHERE '||P_where_clause;
        ELSE
          l_sql_stmt := l_sql_stmt || '  AND '||p_where_clause;
        END IF;
     END IF;
  BEGIN
       -- Open the cursor for processing
      V_cursor_id  := DBMS_SQL.OPEN_CURSOR;

      --  Parse the Query

       DBMS_SQL.PARSE(v_cursor_id,l_sql_stmt,DBMS_SQL.V7);

     IF P_ACTIVITY_NAME IS NOT NULL THEN
        OPEN Cur_Actcol_wf;
        LOOP
          Fetch Cur_Actcol_wf into  l_temp_col_name,l_temp_prompt;
          EXIT WHEN Cur_Actcol_WF%NOTFOUND;
          l_column_count := l_column_count + 1;
          IF l_column_count = 1 THEN
             l_column_name1   := l_temp_col_name;
             l_column_prompt1 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value1,240);
	    ELSIF l_column_count = 2 THEN
             l_column_name2:=l_temp_col_name;
             l_column_prompt2 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value2,240);
	    ELSIF l_column_count = 3 THEN
             l_column_name3:=l_temp_col_name;
             l_column_prompt3 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value3,240);
	    ELSIF l_column_count = 4 THEN
             l_column_name4:=l_temp_col_name;
             l_column_prompt4 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value4,240);
	    ELSIF l_column_count = 5 THEN
             l_column_name5:=l_temp_col_name;
             l_column_prompt5 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value5,240);
	    ELSIF l_column_count = 6 THEN
             l_column_name6:=l_temp_col_name;
             l_column_prompt6 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value6,240);
	    ELSIF l_column_count = 7 THEN
             l_column_name7:=l_temp_col_name;
             l_column_prompt7 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value7,240);
	    ELSIF l_column_count = 8 THEN
             l_column_name8:=l_temp_col_name;
             l_column_prompt8 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value8,240);
	    ELSIF l_column_count = 9 THEN
             l_column_name9:=l_temp_col_name;
             l_column_prompt9 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value9,240);
	    ELSIF l_column_count = 10 THEN
             l_column_name10:=l_temp_col_name;
             l_column_prompt10 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value10,240);
	    END IF;
        END LOOP;
        CLOSE Cur_Actcol_wf;
      ELSE
        OPEN Cur_proccol_wf;
        LOOP
          Fetch Cur_proccol_wf into  l_temp_col_name,l_temp_prompt;
          EXIT WHEN Cur_proccol_WF%NOTFOUND;
          l_column_count := l_column_count + 1;
          IF l_column_count = 1 THEN
             l_column_name1:=l_temp_col_name;
             l_column_prompt1 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value1,240);
	    ELSIF l_column_count = 2 THEN
             l_column_name2:=l_temp_col_name;
             l_column_prompt2 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value2,240);
	    ELSIF l_column_count = 3 THEN
             l_column_name3:=l_temp_col_name;
             l_column_prompt3 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value3,240);
	    ELSIF l_column_count = 4 THEN
             l_column_name4:=l_temp_col_name;
             l_column_prompt4 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value4,240);
	    ELSIF l_column_count = 5 THEN
             l_column_name5:=l_temp_col_name;
             l_column_prompt5 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value5,240);
	    ELSIF l_column_count = 6 THEN
             l_column_name6:=l_temp_col_name;
             l_column_prompt6 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value6,240);
	    ELSIF l_column_count = 7 THEN
             l_column_name7:=l_temp_col_name;
             l_column_prompt8 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value7,240);
	    ELSIF l_column_count = 8 THEN
             l_column_name8:=l_temp_col_name;
             l_column_prompt8 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value8,240);
	    ELSIF l_column_count = 9 THEN
             l_column_name9:=l_temp_col_name;
             l_column_prompt9 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value9,240);
	    ELSIF l_column_count = 10 THEN
             l_column_name10:=l_temp_col_name;
             l_column_prompt10 := l_temp_prompt;
             DBMS_SQL.DEFINE_COLUMN_CHAR(v_cursor_id,l_column_count,l_column_value10,240);
	    END IF;
        END LOOP;
        CLOSE Cur_proccol_wf;
      END IF;
    --  Execute the statement
    v_dummy := DBMS_SQL.EXECUTE(v_cursor_id);
    LOOP
      IF DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0 THEN
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
         IF  l_no_rows > 1 THEN
         --  Close the cursor
             data_string := 'MULTI_ROWS_ERROR';
             RAISE WF_ERROR;
         END IF;
         EXIT;
      END IF;
      FOR l_col_vals in 1..l_column_count
      LOOP


       --
       -- Modified following code to fix bug 2478400
       -- Modification is chnage if condions to use l_col_vals instead of l_column_count.
       --

          IF l_col_vals = 1 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value1);
             data_string := data_string ||l_column_name1||'='||trim(l_column_value1);
             wf_data_string := wf_data_string ||l_column_prompt1||'='||trim(l_column_value1);
	  ELSIF l_col_vals  = 2 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value2);
             data_string := data_string ||l_delimiter||l_column_name2||'='||trim(l_column_value2);
             wf_data_string := wf_data_string ||l_column_prompt2||'='||trim(l_column_value2);
	  ELSIF l_col_vals = 3 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value3);
             data_string := data_string ||l_delimiter||l_column_name3||'='||trim(l_column_value3);
             wf_data_string := wf_data_string ||l_column_prompt3||'='||trim(l_column_value3);
	  ELSIF l_col_vals = 4 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value4);
             data_string := data_string ||l_delimiter||l_column_name4||'='||trim(l_column_value4);
             wf_data_string := wf_data_string ||l_column_prompt4||'='||trim(l_column_value4);
	  ELSIF l_col_vals = 5 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value5);
             data_string := data_string ||l_delimiter||l_column_name5||'='||trim(l_column_value5);
             wf_data_string := wf_data_string ||l_column_prompt5||'='||trim(l_column_value5);
	  ELSIF l_col_vals = 6 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value6);
             data_string := data_string ||l_delimiter||l_column_name6||'='||trim(l_column_value6);
             wf_data_string := wf_data_string ||l_column_prompt6||'='||trim(l_column_value6);
	  ELSIF l_col_vals = 7 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value7);
             data_string := data_string ||l_delimiter||l_column_name7||'='||trim(l_column_value7);
             wf_data_string := wf_data_string ||l_column_prompt7||'='||trim(l_column_value7);
	  ELSIF l_col_vals = 8 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value8);
             wf_data_string := wf_data_string ||l_column_prompt8||'='||trim(l_column_value8);
             data_string := data_string ||l_delimiter||l_column_name8||'='||trim(l_column_value8);
	  ELSIF l_col_vals = 9 THEN
             wf_data_string := wf_data_string ||l_column_prompt9||'='||trim(l_column_value9);
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value9);
             data_string := data_string ||l_delimiter||l_column_name9||'='||trim(l_column_value9);
	  ELSIF l_col_vals = 10 THEN
             DBMS_SQL.COLUMN_VALUE_CHAR(v_cursor_id,l_col_vals,l_column_value10);
             wf_data_string := wf_data_string ||l_column_prompt10||'='||trim(l_column_value10);
             data_string := data_string ||l_delimiter||l_column_name10||'='||trim(l_column_value10);
	    END IF;
        END LOOP;
        l_no_rows  :=l_no_rows + 1;
     END LOOP;
     P_DATASTRING   := data_string;
     P_WFSTRING     := wf_data_string;
     EXCEPTION WHEN OTHERS THEN
         data_string := 'SQL_ERROR';
         Raise WF_ERROR;
     END;
  EXCEPTION WHEN WF_ERROR THEN
    BEGIN
       IF data_string = 'SQL_ERROR' THEN
          error_message := FND_MESSAGE.GET_STRING('GMA','GMA_WF_CTRL_SQL_ERR');
          FND_MESSAGE.SET_NAME('GMA','GMA_WF_CTRL_SQL_ERR');
       ELSIF data_string =  'MULTI_ROWS_ERROR' THEN
          error_message := FND_MESSAGE.GET_STRING('GMA','GMA_WF_CTRL_MULTI_ROW_ERR');
          FND_MESSAGE.SET_NAME('GMA','GMA_WF_CTRL_MULTI_ROW_ERR');
       ELSIF data_string = 'PROFILE_ERROR' THEN
          error_message := FND_MESSAGE.GET_STRING('GMA','GMA_WF_CTRL_PROF_ERR');
          FND_MESSAGE.SET_NAME('GMA','GMA_WF_CTRL_PROF_ERR');
       END IF;
    END;
    WF_CORE.CONTEXT ('gma_wfstd_p','WF_GET_CONTORL_PARAMS',P_WF_ITEM_TYPE,P_PROCESS_NAME,P_ACTIVITY_NAME,error_message);
    app_exception.raise_exception;
  WHEN OTHERS THEN
    WF_CORE.CONTEXT ('gma_wfstd_p','WF_GET_CONTORL_PARAMS',P_WF_ITEM_TYPE,P_PROCESS_NAME,P_ACTIVITY_NAME,SQLERRM(SQLCODE));
    app_exception.raise_exception;
  END WF_GET_CONTORL_PARAMS;
END gma_wfstd_p;

/
