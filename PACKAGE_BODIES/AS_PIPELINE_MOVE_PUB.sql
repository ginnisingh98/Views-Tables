--------------------------------------------------------
--  DDL for Package Body AS_PIPELINE_MOVE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_PIPELINE_MOVE_PUB" as
/* $Header: asxppmvb.pls 120.0 2005/06/02 17:23:29 appldev noship $ */
--
-- HISTORY
--   02/27/01  ACNG     Created.
-- NOTES
--   The main package for the concurrent program "Pipeline movement"
--
/************************************************************/
/* This script is used to move sales credits and access     */
/* records from one salesforce to another salesforce        */
/* Input required : User login      (from which user      ) */
/*                  group number    (from which salesgroup) */
/*                  User login      ( to  which user      ) */
/*                  group number    ( to  which salesgroup) */
/*                  win probability (win probability range) */
/*                  decision date   (close date range     ) */
/*                  status          (statuses             ) */
/************************************************************/
/********************************************************************************/
/* Instruction to run this SQL script, parameters are in sequence               */
/* 1) from_user_name  (move from which salesforce)                              */
/* 2) to_user_name    (move to which salesforce)                                */
/* 3) from_group_num  (move from group where the salesforce belongs to)         */
/* 4) to_group_num    (move to group where the salesforce belongs to)           */
/* 5) from_win_prob (move sales credits with win prob range starts from)        */
/*    Default value = 0 if no input from user                                   */
/* 6) to_win_prob (move sales credits with win prob range ends at)              */
/*    Default value = 100 if no input from user                                 */
/* 7) from_close_date (decision date range starts from)                         */
/*    Please input the date as the following format                             */
/*    e.g.: 01-JAN-1999                                                         */
/*    Default value = 01-JAN-1900                                               */
/* 8) to_close_date (decision date range ends at)                               */
/*    Please input the date as the following format                             */
/*    e.g.: 01-JAN-1999                                                         */
/*    Default value = 01-JAN-4712                                               */
/* 9) Statuses : all leads with these statuses will be moved                    */
/*    Please input a list of statuses separated by comma (,)                    */
/*    e.g.: won,preliminary                                                     */
/*    Default value = all statuses if no input from user                        */
/********************************************************************************/
/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Pipeline_Movement
 |
 | PURPOSE
 |  The main program for pipeline movement.
 | NOTES
 |
 | HISTORY
 |   02/27/01  ACNG     Created
 *-------------------------------------------------------------------------*/
PROCEDURE Pipeline_Movement(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_from_user           IN  VARCHAR2,
    p_from_grp            IN  VARCHAR2,
    p_to_user             IN  VARCHAR2,
    p_to_grp              IN  VARCHAR2,
    p_from_win_prob       IN  NUMBER := NULL,
    p_to_win_prob         IN  NUMBER := NULL,
    p_from_close_date     IN  DATE := NULL,
    p_to_close_date       IN  DATE := NULL,
    p_status              IN  VARCHAR2 := NULL )
IS
/********  DECLARE ALL CURSORS ***************************/
/*
CURSOR FIND_LEADS(from_win_prob NUMBER,
                  to_win_prob NUMBER,
                  from_close_date DATE,
                  to_close_date DATE,
                  from_sf_id NUMBER,
                  from_sg_id NUMBER,
                  in_status VARCHAR)
IS
SELECT LD.LEAD_ID LEAD_ID
FROM AS_LEADS_ALL LD
WHERE LD.DECISION_DATE BETWEEN from_close_date AND to_close_date
  AND LD.WIN_PROBABILITY BETWEEN from_win_prob AND to_win_prob
  AND STATUS || '' IN in_status
  AND EXISTS
 	 (SELECT 1
 	    FROM AS_ACCESSES_ALL ACC
 	   WHERE ACC.LEAD_ID = LD.LEAD_ID
 	     AND ACC.SALESFORCE_ID = from_sf_id
 	     AND ACC.SALES_GROUP_ID = from_sg_id);
*/
TYPE    FIND_LEADS is REF CURSOR;
l_credit_type_id NUMBER;
status_str VARCHAR2(1000);
status_tokenized VARCHAR2(1000);
from_person NUMBER;
to_person NUMBER;
from_res NUMBER;
to_res NUMBER;
from_group_id NUMBER;
to_group_id NUMBER;
from_is_group_correct NUMBER;
to_is_group_correct NUMBER;
is_owner NUMBER;
is_in_sales_credits NUMBER;
is_in_sales_team NUMBER;
from_win_prob    NUMBER;
to_win_prob      NUMBER;
from_close_date  DATE;
to_close_date    DATE;
curs    FIND_LEADS;
sqlstr  VARCHAR2(2000);
L_LEAD_ID 	NUMBER;


l_salesforceid number;
l_salesgroupid number;
l_personid number;


CURSOR SALES_CR (l_lead_id number,l_salesforceid number,l_salesgroupid number,l_personid number) IS
SELECT LEAD_LINE_ID,
CREDIT_TYPE_ID,
SUM(CREDIT_AMOUNT) CR_AMT ,
SUM(CREDIT_PERCENT) CR_PCT
  FROM AS_SALES_CREDITS ASSC
  WHERE ASSC.LEAD_ID = l_lead_id
    AND ASSC.SALESFORCE_ID = l_salesforceid
    AND ASSC.SALESGROUP_ID = l_salesgroupid
    AND ASSC.PERSON_ID = l_personid
GROUP BY LEAD_LINE_ID,CREDIT_TYPE_ID;

BEGIN
 	BEGIN
	   SELECT RES.SOURCE_ID,RES.RESOURCE_ID INTO from_person,from_res FROM JTF_RS_RESOURCE_EXTNS RES, FND_USER USR WHERE RES.SOURCE_ID = USR.EMPLOYEE_ID AND RES.CATEGORY = 'EMPLOYEE' AND USR.USER_NAME =  p_from_user;
	   SELECT RES.SOURCE_ID,RES.RESOURCE_ID INTO to_person,to_res FROM JTF_RS_RESOURCE_EXTNS RES, FND_USER USR WHERE RES.SOURCE_ID = USR.EMPLOYEE_ID AND RES.CATEGORY = 'EMPLOYEE' AND USR.USER_NAME =  p_to_user;
	   SELECT GROUP_ID INTO from_group_id FROM JTF_RS_GROUPS_B WHERE GROUP_NUMBER = p_from_grp;
	   SELECT GROUP_ID INTO to_group_id FROM JTF_RS_GROUPS_B WHERE GROUP_NUMBER = p_to_grp;
	   SELECT COUNT(1) INTO from_is_group_correct FROM JTF_RS_GROUP_MEMBERS WHERE RESOURCE_ID = from_res AND GROUP_ID = from_group_id AND DELETE_FLAG = 'N';
	   SELECT COUNT(1) INTO to_is_group_correct FROM JTF_RS_GROUP_MEMBERS WHERE RESOURCE_ID = to_res AND GROUP_ID = to_group_id AND DELETE_FLAG = 'N';
 	EXCEPTION
	    WHEN OTHERS THEN
	    ERRBUF := 'Error at Pipeline Movement '||SQLERRM||' - (Error in group info)';
  	END;
        IF from_is_group_correct = 0 OR to_is_group_correct = 0 THEN
        BEGIN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: From Salesforce/salesgroup do not match.');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        END IF;
        IF from_res = to_res AND from_group_id = to_group_id THEN
        BEGIN
           FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: From Resource And To Resource cannot be identical.');
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Start pipeline movement');

        from_win_prob := NVL(p_from_win_prob,0);
        to_win_prob := NVL(p_to_win_prob,100);
        from_close_date := NVL(p_from_close_date,to_date('01/01/1900','DD/MM/YYYY'));
        to_close_date := NVL(p_to_close_date,to_date('01/01/4712','DD/MM/YYYY'));

     --	*******  GET SALESREP INFO BASED ON INPUT **************************
     --	****** MANIPULATE STATUS ******************************************
	IF NVL(length(p_status),0) = 0 OR p_status IS NULL OR UPPER(TRIM(p_status)) = 'ALL' THEN
	   status_str := '(SELECT DISTINCT UPPER(status_code) FROM as_statuses_b WHERE enabled_flag = ''Y'' AND opp_flag = ''Y'')';
	ELSE
	  BEGIN
	     /*  Status filter earlier code
	     status_str := '''(''';
	     SELECT REPLACE(UPPER(TRIM(p_status)),',',''',''') INTO status_tokenized FROM DUAL;
	     status_str := status_str || status_tokenized || ''')''';
	     status_str := '(''';
	     SELECT REPLACE(UPPER(TRIM(p_status)),',',''',''') INTO status_tokenized FROM DUAL;
	     status_str := status_str || status_tokenized || ''')';
	     --DBMS_OUTPUT.PUT_LINE(status_str);
	     */
             SELECT '(TRIM(''' || REPLACE(REPLACE(UPPER(TRIM(p_status)),',','''),TRIM('''),' ','') || '''))' INTO status_str FROM DUAL;
	  EXCEPTION
	     WHEN OTHERS THEN
	     ERRBUF := 'Error at Pipeline Movement '||SQLERRM||' - (Error in determining input value of STATUS)';
	  END;
	END IF;
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     : ' || status_str);
	BEGIN
	   -- ** LOOP THRO ALL LEADS THAT SATISFY INPUT CRITERIA *
	   -- dbms_output.put_line('Status is:'|| status_str);
	   sqlstr := ' SELECT LD.LEAD_ID lead_id ';
	   sqlstr := sqlstr || ' FROM AS_LEADS_ALL LD ';
	   sqlstr := sqlstr || ' WHERE LD.DECISION_DATE BETWEEN :from_close_date AND :to_close_date ';
	   sqlstr := sqlstr || ' AND LD.WIN_PROBABILITY BETWEEN :from_win_prob AND :to_win_prob ';
	   sqlstr := sqlstr || ' AND UPPER(STATUS) IN ';
	   sqlstr := sqlstr || status_str ;
	   sqlstr := sqlstr || ' AND EXISTS ';
	   sqlstr := sqlstr || ' (SELECT 1';
	   sqlstr := sqlstr || ' FROM AS_ACCESSES_ALL ACC ';
	   sqlstr := sqlstr || ' WHERE ACC.LEAD_ID = LD.LEAD_ID ';
	   sqlstr := sqlstr || ' AND ACC.SALESFORCE_ID = :from_sf_id ';
	   sqlstr := sqlstr || ' AND ACC.SALES_GROUP_ID = :from_sg_id) ';
	   OPEN curs for sqlstr using from_close_date ,to_close_date ,from_win_prob  ,to_win_prob  ,from_res ,from_group_id ;
	   LOOP
	    FETCH curs INTO L_LEAD_ID ;
	    EXIT WHEN curs%NOTFOUND ;
		--* UPDATE SALES CREDITS **
		--** CASE 1 - SR2 already exists in as_sales_credits **
		--** add up the salescredits for SR1 to SR2, update SR2's salescredits and delete the salescredits for SR1 **
		       --dbms_output.put_line('CASE 1 - SR2 already exists in as_sales_credits');

		    -- find r2 sales credit exist
            --dbms_output.put_line(to_char(l_lead_id) || '-' || to_char(from_res) || '-' || to_char(from_group_id)|| '-' || to_char(from_person));

	    l_salesforceid := from_res;
	    l_salesgroupid := from_group_id;
	    l_personid  := from_person;

            FOR SC_REC IN SALES_CR(L_LEAD_ID,l_salesforceid,l_salesgroupid,l_personid) LOOP

                  --dbms_output.put_line('Lead id is:'|| L_LEAD_ID);

                  --dbms_output.put_line(to_char(sc_rec.credit_type_id) || '-' || to_char(sc_rec.cr_amt) || '-' || to_char(sc_rec.cr_pct));

	          SELECT COUNT(*) INTO is_in_sales_credits
                  FROM AS_SALES_CREDITS SC
                  WHERE SC.LEAD_ID = L_LEAD_ID
                    AND SC.LEAD_LINE_ID = SC_REC.LEAD_LINE_ID
                    AND SC.SALESFORCE_ID = to_res
                    AND SC.SALESGROUP_ID = to_group_id
                    AND SC.CREDIT_TYPE_ID = SC_REC.CREDIT_TYPE_ID;
    		    IF is_in_sales_credits > 0 THEN
	    	          BEGIN
		       -- update salescredits for SR2
				   UPDATE AS_SALES_CREDITS ASSC
				      SET object_version_number =  nvl(object_version_number,0) + 1, ASSC.CREDIT_AMOUNT = ASSC.CREDIT_AMOUNT + SC_REC.CR_AMT,
					  ASSC.CREDIT_PERCENT = ASSC.CREDIT_PERCENT + SC_REC.CR_PCT
				   WHERE ASSC.LEAD_ID = L_LEAD_ID
				           AND ASSC.LEAD_LINE_ID = SC_REC.LEAD_LINE_ID
					   AND ASSC.SALESFORCE_ID = to_res
					   AND ASSC.SALESGROUP_ID = to_group_id
					   AND ASSC.PERSON_ID = to_person
					   AND ASSC.CREDIT_TYPE_ID = SC_REC.CREDIT_TYPE_ID
					   AND ROWID = (SELECT MIN(ROWID)
							FROM AS_SALES_CREDITS z
							WHERE z.LEAD_ID = L_LEAD_ID
							AND z.LEAD_LINE_ID = SC_REC.LEAD_LINE_ID
							AND z.SALESFORCE_ID = ASSC.SALESFORCE_ID
							AND z.SALESGROUP_ID = ASSC.SALESGROUP_ID
							AND z.PERSON_ID = ASSC.PERSON_ID
 							AND z.CREDIT_TYPE_ID = SC_REC.CREDIT_TYPE_ID);
                             END;
                    ELSE
			     BEGIN
				--** CASE 2 - SR2 does not exist in as_sales_credits **
					UPDATE AS_SALES_CREDITS
					   SET object_version_number =  nvl(object_version_number,0) + 1, SALESFORCE_ID = to_res,
					       PERSON_ID = to_person,
					       SALESGROUP_ID = to_group_id
					 WHERE LEAD_ID = L_LEAD_ID
					   AND LEAD_LINE_ID = SC_REC.LEAD_LINE_ID
					   AND SALESFORCE_ID = from_res
					   AND PERSON_ID = from_person
					   AND SALESGROUP_ID = from_group_id
					   AND CREDIT_TYPE_ID = SC_REC.CREDIT_TYPE_ID;
			       END;
                     END IF;
                     --dbms_output.put_line('After updating sales credit:'|| SQL%ROWCOUNT);
    	             -- delete salescredits for SR1
		        DELETE FROM AS_SALES_CREDITS
    			 WHERE LEAD_ID = L_LEAD_ID
    			   AND LEAD_LINE_ID = SC_REC.LEAD_LINE_ID
		           AND SALESFORCE_ID = from_res
       			   AND SALESGROUP_ID = from_group_id
       			   AND CREDIT_TYPE_ID = SC_REC.CREDIT_TYPE_ID;
       			--dbms_output.put_line('After deleteing sales credit:'|| SQL%ROWCOUNT);
            END LOOP;
		--* UPDATE LEADS *
		SELECT COUNT(*) INTO is_owner FROM AS_LEADS_ALL L WHERE L.LEAD_ID = L_LEAD_ID AND L.OWNER_SALESFORCE_ID = from_res AND L.OWNER_SALES_GROUP_ID = from_group_id;
		SELECT COUNT(*) INTO is_in_sales_team FROM AS_ACCESSES_ALL ACC WHERE ACC.LEAD_ID = L_LEAD_ID AND ACC.SALESFORCE_ID = to_res AND ACC.SALES_GROUP_ID = to_group_id;
		--* CASE 1 - IF SR1 was owner *
		IF is_owner = 1 THEN
		BEGIN
		        UPDATE AS_LEADS_ALL L
			   SET object_version_number =  nvl(object_version_number,0) + 1, L.OWNER_SALESFORCE_ID = to_res,
			       L.OWNER_SALES_GROUP_ID = to_group_id
      		      	 WHERE L.LEAD_ID = L_LEAD_ID
      		      	   AND L.OWNER_SALESFORCE_ID = from_res
      		      	   AND L.OWNER_SALES_GROUP_ID = from_group_id;
			--* UPDATE SALES TEAM *
		  	 --* CASE 1 - SR1/GRP1 moved to SR2/GRP2 *
		  	  If is_in_sales_team = 1 THEN --* CASE 1A - SR2/GRP2 is already in SALES TEAM *
		  	    BEGIN
                          	-- delete SR1/GR1 from SALES TEAM
                          	DELETE FROM AS_ACCESSES_ALL ACC
                          	WHERE ACC.LEAD_ID = L_LEAD_ID
                          	  AND ACC.SALESFORCE_ID = from_res
				  AND ACC.SALES_GROUP_ID = from_group_id
				  AND ACC.PERSON_ID = from_person ;
                		-- IF SR1 was the owner then give full access and ownership TO SR2
                		UPDATE AS_ACCESSES_ALL ACC
                		   SET object_version_number =  nvl(object_version_number,0) + 1, OWNER_FLAG = 'Y',
	       			       TEAM_LEADER_FLAG = 'Y'
	       			 WHERE ACC.LEAD_ID = L_LEAD_ID
	       			   AND ACC.SALESFORCE_ID = to_res
				   AND ACC.SALES_GROUP_ID = to_group_id
				   AND ACC.PERSON_ID = to_person ;
		            END;
                          ELSE  --* CASE 1B - SR2/GRP2 is NOT in SALES TEAM *
                            BEGIN
                                UPDATE AS_ACCESSES_ALL ACC
			           SET object_version_number =  nvl(object_version_number,0) + 1, SALESFORCE_ID = to_res,
			               SALES_GROUP_ID = to_group_id,
			               PERSON_ID = to_person,
			               OWNER_FLAG = 'Y',
			    	       TEAM_LEADER_FLAG = 'Y'
			    	 WHERE ACC.LEAD_ID = L_LEAD_ID
			    	   AND ACC.SALESFORCE_ID = from_res
			           AND ACC.SALES_GROUP_ID = from_group_id
				   AND ACC.PERSON_ID = from_person ;
                            END;
                          END IF;
                END;
                ELSE   --- SR1 is NOT the owner
                BEGIN
                       --- We will NTO be updating AS_LEADS_ALL
                       --* UPDATE SALES TEAM *
	                 --* CASE 1 - SR1/GRP1 moved to SR2/GRP2 *
			  If is_in_sales_team = 1 THEN --* CASE 1A - SR2/GRP2 is already in SALES TEAM *
			    BEGIN
				-- delete SR1/GR1 from SALES TEAM
			       DELETE FROM AS_ACCESSES_ALL ACC
				WHERE ACC.LEAD_ID = L_LEAD_ID
				  AND ACC.SALESFORCE_ID = from_res
				  AND ACC.SALES_GROUP_ID = from_group_id
				  AND ACC.PERSON_ID = from_person ;
				-- IF SR1 was the owner then give full access and ownership TO SR2
				-- No need to do this here since SR1 was not the owner.
			    END;
			  ELSE  --** CASE 1B - SR2/GRP2 is NOT in SALES TEAM *
		            BEGIN
			       UPDATE AS_ACCESSES_ALL ACC
			          SET object_version_number =  nvl(object_version_number,0) + 1, SALESFORCE_ID = to_res,
			              SALES_GROUP_ID = to_group_id,
			              PERSON_ID = to_person
				WHERE ACC.LEAD_ID = L_LEAD_ID
				  AND ACC.SALESFORCE_ID = from_res
				  AND ACC.SALES_GROUP_ID = from_group_id
				  AND ACC.PERSON_ID = from_person ;
		            END;
                          END IF;
                END;
                END IF;
	     END LOOP; -- End Loop for Leads
           END;
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'Finish pipeline movement');
	   --dbms_output.put_line('Finish pipeline movement');
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
	ERRBUF := 'Error at Pipeline Movement'||SQLERRM;
	--dbms_output.put_line('Error at Pipeline Movement'||SQLERRM);
END PIPELINE_MOVEMENT;
/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Pipeline_Movement
 |
 | PURPOSE
 |  The main program for pipeline movement. (sales credits only)
 | NOTES
 |
 | HISTORY
 |   02/27/01  ACNG     Created
 *-------------------------------------------------------------------------*/
PROCEDURE Pipeline_SC_Movement(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_from_user           IN  VARCHAR2,
    p_from_grp            IN  VARCHAR2,
    p_to_user             IN  VARCHAR2,
    p_to_grp              IN  VARCHAR2,
    p_from_win_prob       IN  NUMBER := NULL,
    p_to_win_prob         IN  NUMBER := NULL,
    p_from_close_date     IN  DATE := NULL,
    p_to_close_date       IN  DATE := NULL,
    p_status              IN  VARCHAR2 := NULL )
IS
   from_sf_id   NUMBER;
   from_sg_id   NUMBER;
   from_person  NUMBER;
   to_sf_id     NUMBER;
   to_sg_id     NUMBER;
   to_person    NUMBER;
   from_win_prob    NUMBER;
   to_win_prob      NUMBER;
   from_close_date  DATE;
   to_close_date    DATE;
   group_ok        NUMBER := 0;
   error_flag      VARCHAR2(1) := 'N';
   cursor get_id(x_user VARCHAR2) is
   select res.source_id, res.resource_id
   from JTF_RS_RESOURCE_EXTNS res, FND_USER usr
   where res.source_id = usr.employee_id
   and res.category = 'EMPLOYEE'
   and usr.user_name = x_user;
   cursor get_sg_id(x_sg_num VARCHAR2) is
   select group_id
   from JTF_RS_GROUPS_B
   where group_number = x_sg_num;
   cursor check_grp_id(x_sf_id NUMBER, x_grp_id NUMBER) is
   select count(1)
   from JTF_RS_GROUP_MEMBERS
   where resource_id = x_sf_id
   and group_id = x_grp_id;
   TYPE status_rec IS RECORD
   ( status  VARCHAR2(30) );
   TYPE status_tbl IS TABLE OF status_rec INDEX BY BINARY_INTEGER;
   allstatus   VARCHAR2(1000);
   st_len      NUMBER;
   st_count    NUMBER := 1;
   ld_status   status_tbl;
   i_count     NUMBER := 1;
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Start pipeline movement');
-- get salesforce_id from user_name --
   open get_id(p_from_user);
   fetch get_id into from_person, from_sf_id;
   close get_id;
-- get salesforce_id from user_name --
   open get_id(p_to_user);
   fetch get_id into to_person, to_sf_id;
   close get_id;
-- get sales_group_id from group_name --
   open get_sg_id(p_from_grp);
   fetch get_sg_id into from_sg_id;
   close get_sg_id;
-- get sales_group_id from group_name --
   open get_sg_id(p_to_grp);
   fetch get_sg_id into to_sg_id;
   close get_sg_id;
   open check_grp_id(from_sf_id, from_sg_id);
   fetch check_grp_id into group_ok;
   close check_grp_id;
   if(group_ok = 0) then
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: From Salesforce/salesgroup do not match.');
      error_flag := 'Y';
   end if;
   group_ok := 0;
   open check_grp_id(to_sf_id, to_sg_id);
   fetch check_grp_id into group_ok;
   close check_grp_id;
   if(group_ok = 0) then
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: To Salesforce/salesgroup do not match.');
      error_flag := 'Y';
   end if;
   group_ok := 0;
   from_win_prob := nvl(p_from_win_prob,0);
   to_win_prob := nvl(p_to_win_prob,100);
   from_close_date := nvl(p_from_close_date,to_date('01/01/1900','DD/MM/YYYY'));
   to_close_date := nvl(p_to_close_date,to_date('01/01/4712','DD/MM/YYYY'));
/*
   dbms_output.put_line('User   : '||p_from_user);
   dbms_output.put_line('Person : '||from_person);
   dbms_output.put_line('Id     : '||from_sf_id);
   dbms_output.put_line('SG     : '||from_sg_id);
   dbms_output.put_line('User   : '||p_to_user);
   dbms_output.put_line('Person : '||to_person);
   dbms_output.put_line('Id     : '||to_sf_id);
   dbms_output.put_line('SG     : '||to_sg_id);
   dbms_output.put_line('Win Prob : '||from_win_prob);
   dbms_output.put_line('Win Prob : '||to_win_prob);
   dbms_output.put_line('Close Dt : '||to_char(from_close_date,'DD/MM/YYYY'));
   dbms_output.put_line('Close Dt : '||to_char(to_close_date,'DD/MM/YYYY'));
*/
-- If user put 'ALL' for the first status, then --
-- no where filter condition for status         --
   allstatus := upper(ltrim(rtrim(p_status)));
   st_len := nvl(length(allstatus),0);
   -- nothing type in for status, default to 'ALL'
   if(st_len = 0) then
      ld_status(st_count).status := 'ALL';
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     : ALL');
   else
   -- specify only one status, maybe 'ALL', maybe others
      if(instr(allstatus,',') = 0) then
         ld_status(st_count).status := allstatus;
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     '||st_count||' : '||ld_status(st_count).status);
   -- more than 1 status specified
      else
         ld_status(st_count).status := ltrim(rtrim(substr(allstatus,1,instr(allstatus,',')-1)));
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     '||st_count||' : '||ld_status(st_count).status);
         --dbms_output.put_line('Status : '||ld_status(st_count).status);
         allstatus := ltrim(rtrim(substr(allstatus,instr(allstatus,',')+1,st_len)));
         st_count := st_count + 1;
         while (instr(allstatus,',') <> 0) loop
            ld_status(st_count).status := ltrim(rtrim(substr(allstatus,1,instr(allstatus,',')-1)));
	       FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     '||st_count||' : '||ld_status(st_count).status);
            --dbms_output.put_line('Status '||st_count||' : '||ld_status(st_count).status);
            allstatus := ltrim(rtrim(substr(allstatus,instr(allstatus,',')+1,st_len)));
            st_count := st_count + 1;
         end loop;
         ld_status(st_count).status := ltrim(rtrim(allstatus));
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'Status     '||st_count||' : '||ld_status(st_count).status);
         --dbms_output.put_line('last Status : '||ld_status(st_count).status);
         --dbms_output.put_line('Total status : '||st_count);
      end if;
   end if;
--DBMS_OUTPUT.PUT_LINE('I AM OUTSIDE');
IF(error_flag <> 'Y') THEN
   IF(rtrim(ltrim(ld_status(1).status)) = 'ALL') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Win Prob   : '||from_win_prob||'-'||to_win_prob);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'Close Date : '||from_close_date||'-'||to_close_date);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'From SF/SG : '||from_sf_id||'-'||from_sg_id);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'To SF/SG   : '||to_sf_id||'-'||to_sg_id);
      update AS_SALES_CREDITS sc
      set object_version_number =  nvl(object_version_number,0) + 1, salesforce_id = to_sf_id,
	     person_id = to_person,
	     salesgroup_id = to_sg_id
      where exists
            ( select ld.lead_id
              from AS_LEADS_ALL ld
              where ld.win_probability between from_win_prob and to_win_prob
              and ld.decision_date between from_close_date and to_close_date
		    and ld.lead_id = sc.lead_id )
      and sc.salesforce_id = from_sf_id
      and sc.salesgroup_id = from_sg_id
      and sc.person_id = from_person;
   ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Win Prob   : '||from_win_prob||'-'||to_win_prob);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'Close Date : '||from_close_date||'-'||to_close_date);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'From SF/SG : '||from_sf_id||'-'||from_sg_id);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'To SF/SG   : '||to_sf_id||'-'||to_sg_id);
	 while (i_count <= st_count) loop
         update AS_SALES_CREDITS sc
         set object_version_number =  nvl(object_version_number,0) + 1, salesforce_id = to_sf_id,
	        person_id = to_person,
	        salesgroup_id = to_sg_id
         where exists
               ( select ld.lead_id
                 from AS_LEADS_ALL ld
                 where ld.win_probability between from_win_prob and to_win_prob
                 and ld.decision_date between from_close_date and to_close_date
                 and ld.status = ld_status(i_count).status
		       and ld.lead_id = sc.lead_id )
         and sc.salesforce_id = from_sf_id
         and sc.salesgroup_id = from_sg_id
         and sc.person_id = from_person;
         i_count := i_count + 1;
      end loop;
   END IF;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Finish pipeline movement');
EXCEPTION
  WHEN others THEN
	ERRBUF := 'Error at Pipeline Movement'||SQLERRM;
END Pipeline_SC_Movement;
END AS_PIPELINE_MOVE_PUB;

/
