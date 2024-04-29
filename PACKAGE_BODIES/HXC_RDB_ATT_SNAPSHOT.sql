--------------------------------------------------------
--  DDL for Package Body HXC_RDB_ATT_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RDB_ATT_SNAPSHOT" as
/* $Header: hxcrdbsnpsht.pkb 120.1.12010000.8 2010/04/06 13:00:51 sabvenug noship $ */


----------------------------------------------------------------
TYPE LOCKED_TCS_TAB_TYPE is TABLE OF VARCHAR2(1)
	INDEX BY PLS_INTEGER;


TYPE VTAB IS TABLE OF VARCHAR2(2500);
TYPE NTAB IS TABLE OF NUMBER(15,5);

g_lock_transaction_id	NUMBER;


NO_UPG_DONE 		EXCEPTION;
NO_LATEST_DETAILS_UPG	EXCEPTION;

TABLE_EXCEPTION 	EXCEPTION;
PRAGMA EXCEPTION_INIT(TABLE_EXCEPTION,-24381);
-----------------------------------------------------------------



PROCEDURE generate_attribute_info(errbuff   OUT NOCOPY VARCHAR2,
                                  retcode   OUT NOCOPY NUMBER)

IS

t_locked_tcs	LOCKED_TCS_TAB_TYPE;

l_process_lock_type	varchar2(30):= HXC_LOCK_UTIL.c_plsql_deposit_action;
l_row_id		rowid;
l_tc_lock_boolean	boolean;
l_messages	        hxc_self_service_time_deposit.message_table;

l_update_warning	VARCHAR2(1);

l_lock_warning		VARCHAR2(1);


CURSOR get_pay_attribute_info
IS
SELECT ROWIDTOCHAR(hld.rowid),
       hta.attribute_category,
       REPLACE(hta.attribute_category,'ELEMENT - '),--hta.attribute1,
       hta.attribute2,
       hta.attribute3,
       hta.attribute4,
       hta.attribute5,
       hta.attribute6,
       hta.attribute7,
       DECODE (TBB.DATE_TO, HR_GENERAL.end_of_time,  nvl (tbb.measure,
             						TO_NUMBER (tbb.stop_time - tbb.start_time) * 24 ) ,
             		  0 ) measure,
       hld.timecard_id
  FROM hxc_pay_latest_details hld,
       hxc_time_attribute_usages htau,
       hxc_time_attributes hta,
       hxc_bld_blk_info_types bld,
       hxc_time_building_blocks tbb
 WHERE htau.time_building_block_id = hld.time_building_block_id
   AND htau.time_building_block_ovn = hld.object_version_number
   AND tbb.time_building_block_id = hld.time_building_block_id
   AND tbb.object_version_number = hld.object_version_number
   AND (  hld.attribute_category is null
        OR hld.measure is null)
   AND hta.time_attribute_id = htau.time_attribute_id
   AND hta.bld_blk_info_type_id = bld.bld_blk_info_type_id
   AND bld.bld_blk_info_type = 'Dummy Element Context' -- 'PROJECTS'
   /*AND NOT EXISTS ( SELECT 1
                         FROM hxc_locks hlk
                        WHERE  (hlk.time_building_block_id = hld.timecard_id
                                OR
                                   (hlk.time_building_block_id = hld.time_building_block_id
                                    AND
                                    hlk.time_building_block_ovn = hld.object_version_number
                                   )
                               )
                          AND lock_date <= sysdate - ( 20 / (24*60) )
                  )*/
     ;



CURSOR get_pa_attribute_info
IS
SELECT ROWIDTOCHAR(hld.rowid),
       hta.attribute_category,
       hta.attribute1,
       hta.attribute2,
       hta.attribute3,
       hta.attribute4,
       hta.attribute5,
       hta.attribute6,
       hta.attribute7,
       DECODE (TBB.DATE_TO, HR_GENERAL.end_of_time,  nvl (tbb.measure,
             						TO_NUMBER (tbb.stop_time - tbb.start_time) * 24 ) ,
             		  0 ) measure,
       hld.timecard_id
  FROM hxc_pa_latest_details hld,
       hxc_time_attribute_usages htau,
       hxc_time_attributes hta,
       hxc_bld_blk_info_types bld,
       hxc_time_building_blocks tbb
 WHERE htau.time_building_block_id = hld.time_building_block_id
   AND htau.time_building_block_ovn = hld.object_version_number
   AND tbb.time_building_block_id = hld.time_building_block_id
   AND tbb.object_version_number = hld.object_version_number
   AND (  hld.attribute_category is null
        OR hld.measure is null)
   AND hta.time_attribute_id = htau.time_attribute_id
   AND hta.bld_blk_info_type_id = bld.bld_blk_info_type_id
   AND bld.bld_blk_info_type = 'PROJECTS' -- 'PROJECTS'
   /*AND NOT EXISTS ( SELECT 1
                      FROM hxc_locks hlk
                     WHERE (hlk.time_building_block_id = hld.timecard_id
                            OR
                               (hlk.time_building_block_id = hld.time_building_block_id
                                AND
                                hlk.time_building_block_ovn = hld.object_version_number
                                )
                           )
                       AND lock_date <= sysdate - ( 20 / (24*60) )
                  )*/
    ;


ROW_ID_TAB			VTAB;
ATTRIBUTE_CATEGORY_TAB   	VTAB;
ATTRIBUTE1_TAB			VTAB;
ATTRIBUTE2_TAB			VTAB;
ATTRIBUTE3_TAB			VTAB;
ATTRIBUTE4_TAB			VTAB;
ATTRIBUTE5_TAB			VTAB;
ATTRIBUTE6_TAB			VTAB;
ATTRIBUTE7_TAB			VTAB;
MEASURE_TAB			NTAB;
TIMECARD_ID_TAB			NTAB;
TIMECARD_ID_STATUS		LOCKED_TCS_TAB_TYPE;

LOCK_TCS_TAB			NTAB;

l_latest_details_upg		VARCHAR2(10);
l_pay_upg			VARCHAR2(10);
l_pa_upg			VARCHAR2(10);

	-- Pvt procedure to lock timecards, if not already locked -- Bug 8888905
	FUNCTION get_locked_timecards(p_lock_tcs_tab	IN NTAB) RETURN LOCKED_TCS_TAB_TYPE

	IS

	 l_resource_id		NUMBER;
	 l_start_time		DATE;
	 l_stop_time		DATE;
	 l_tc_id		NUMBER;
	 l_tc_ovn		NUMBER;

	 TIMECARD_STATUS	LOCKED_TCS_TAB_TYPE;


	 CURSOR get_tc_info (p_timecard_id 	IN NUMBER)
	 IS
	 SELECT
	        tc.timecard_id,
	        tc.timecard_ovn,
	        tc.resource_id,
	        tc.start_time,
	        tc.stop_time
	   FROM
	        hxc_timecard_summary tc
	  WHERE
	        tc.timecard_id = p_timecard_id;


	 BEGIN

	  --TIMECARD_STATUS :=  p_lock_tcs_tab;

	  FOR i in p_lock_tcs_tab.first .. p_lock_tcs_tab.last LOOP

		if NOT (t_locked_tcs.EXISTS(p_lock_tcs_tab(i))) then

			OPEN get_tc_info (p_lock_tcs_tab(i));
			FETCH get_tc_info into l_tc_id, l_tc_ovn, l_resource_id, l_start_time, l_stop_time;

			IF get_tc_info%FOUND then

				if g_debug then
					fnd_file.put_line (fnd_file.LOG,'Acquiring Locking for TC ID: '||p_lock_tcs_tab(i));
				end if;

				hxc_lock_api.request_lock (p_process_locker_type => l_process_lock_type,
			            		   p_resource_id => l_resource_id,
			            		   p_start_time => l_start_time,
			            		   p_stop_time => l_stop_time ,
			            		   p_time_building_block_id => l_tc_id,
			            		   p_time_building_block_ovn => l_tc_ovn,
			            		   p_transaction_lock_id => g_lock_transaction_id,
			            		   p_messages => l_messages,
			            		   p_row_lock_id => l_row_id,
			            		   p_locked_success => l_tc_lock_boolean
           					  );

				/* Need to handle those cases which fail to acquire lock*/

				if l_tc_lock_boolean then
					t_locked_tcs(p_lock_tcs_tab(i)):= 'Y';

					if g_debug then
					fnd_file.put_line (fnd_file.LOG,'Obtained lock for TC ID: '||p_lock_tcs_tab(i));
					end if;
				else
				        if g_debug then
					fnd_file.put_line (fnd_file.LOG,'SKIPPING: The timecard seems to be locked by another process TC ID: '||p_lock_tcs_tab(i));
					end if;
					t_locked_tcs(p_lock_tcs_tab(i)):= 'N';
				end if; -- l_tc_lock_boolean

			else

				t_locked_tcs(p_lock_tcs_tab(i)):= 'Y';

				if g_debug then
				fnd_file.put_line (fnd_file.LOG,'The Timecard seems to be deleted. TC ID: '||p_lock_tcs_tab(i));
				end if;

			end if; -- get_tc_info%FOUND

	                CLOSE get_tc_info;


		end if; --t_locked_tcs.EXISTS

		TIMECARD_STATUS(i) := t_locked_tcs(p_lock_tcs_tab(i));

	  END LOOP; --p_lock_tcs_tab

	 RETURN TIMECARD_STATUS;

	 END get_locked_timecards;



BEGIN -- generate_attribute_info

-- check for upgrade completion -- Bug 8888905

 begin
 	SELECT 'Y'
 	  INTO l_latest_details_upg
 	  FROM hxc_upgrade_definitions
 	 WHERE upg_type = 'LATEST_DETAILS'
 	   AND status = 'COMPLETE';
 exception
 WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.LOG,' The Latest Details Upgrade has not been completed ');
    raise NO_LATEST_DETAILS_UPG;

 end;

--get the values for pay/pa upgrade

 begin
  	SELECT 'Y'
  	  INTO l_pay_upg
  	  FROM hxc_upgrade_definitions
  	 WHERE upg_type = 'RETRIEVAL_PAY'
  	   AND status = 'COMPLETE';
 exception
 WHEN OTHERS THEN

    l_pay_upg:='N';

 end;

 begin
   	SELECT 'Y'
   	  INTO l_pa_upg
   	  FROM hxc_upgrade_definitions
   	 WHERE upg_type = 'RETRIEVAL_PA'
   	   AND status = 'COMPLETE';
  exception
  WHEN OTHERS THEN

     l_pa_upg:='N';

 end;

if l_pay_upg = 'N' and l_pa_upg = 'N' then

	fnd_file.put_line(fnd_file.LOG, 'Both Payroll and Projects upgrades have not been completed');
	raise NO_UPG_DONE;

end if;



-- initialize the g_lock_transaction_id

 begin

	SELECT hxc_transactions_s.NEXTVAL
	  INTO g_lock_transaction_id
	  FROM SYS.DUAL;

 exception
 WHEN NO_DATA_FOUND THEN

    fnd_file.put_line(fnd_file.LOG,' No transaction id obtained from sequence hxc_transactions_s ');
    raise ;

 end;

if g_debug then
fnd_file.put_line (fnd_file.LOG,'g_lock_transaction_id =  '||g_lock_transaction_id);
end if;


if l_pay_upg = 'Y' then

if g_debug then
fnd_file.put_line (fnd_file.LOG,'******************************');
fnd_file.put_line (fnd_file.LOG,'STARTING WITH HXC_PAY_LATEST_DETAILS');
fnd_file.put_line (fnd_file.LOG,'******************************');
end if;

OPEN get_pay_attribute_info;

	LOOP
		FETCH get_pay_attribute_info BULK COLLECT into ROW_ID_TAB, ATTRIBUTE_CATEGORY_TAB, ATTRIBUTE1_TAB, ATTRIBUTE2_TAB,
							  ATTRIBUTE3_TAB, ATTRIBUTE4_TAB, ATTRIBUTE5_TAB, ATTRIBUTE6_TAB,
							  ATTRIBUTE7_TAB, MEASURE_TAB,TIMECARD_ID_TAB
					 LIMIT 500;

		-- We need to lock the timecards

		EXIT WHEN ROW_ID_TAB.COUNT = 0;

		if g_debug then
			fnd_file.put_line (fnd_file.LOG,'******************************');
			fnd_file.put_line (fnd_file.LOG,'Getting a set of bulk data');
			fnd_file.put_line (fnd_file.LOG,'******************************');
		end if;

		TIMECARD_ID_STATUS:= get_locked_timecards(TIMECARD_ID_TAB);

		if g_debug then
			fnd_file.put_line (fnd_file.LOG,'Updating hxc_pay_latest_details');
			fnd_file.put_line (fnd_file.LOG,'ROW_ID_TAB.COUNT ='||ROW_ID_TAB.COUNT);
		end if;


		begin
		FORALL i in ROW_ID_TAB.first .. ROW_ID_TAB.last SAVE EXCEPTIONS
			UPDATE hxc_pay_latest_details
			   SET ATTRIBUTE_CATEGORY = ATTRIBUTE_CATEGORY_TAB(i),
			       ATTRIBUTE1 = ATTRIBUTE1_TAB(i),
			       ATTRIBUTE2 = ATTRIBUTE2_TAB(i),
			       ATTRIBUTE3 = ATTRIBUTE3_TAB(i),
			       ATTRIBUTE4 = ATTRIBUTE4_TAB(i),
			       ATTRIBUTE5 = ATTRIBUTE5_TAB(i),
			       ATTRIBUTE6 = ATTRIBUTE6_TAB(i),
			       ATTRIBUTE7 = ATTRIBUTE7_TAB(i),
			       MEASURE = MEASURE_TAB(i)
			 WHERE rowid = CHARTOROWID (ROW_ID_TAB(i))
			   AND TIMECARD_ID_STATUS(i) = 'Y';
	        exception
	        when table_exception then --ORA 24381 do nothing.. ignore..
	        	--null;
	        	l_update_warning:= 'Y';

	        end;
	     commit;

	END LOOP;

CLOSE get_pay_attribute_info;
end if; -- l_pay_upg


if l_pa_upg = 'Y' then

if g_debug then
fnd_file.put_line (fnd_file.LOG,'******************************');
fnd_file.put_line (fnd_file.LOG,'STARTING WITH HXC_PA_LATEST_DETAILS');
fnd_file.put_line (fnd_file.LOG,'******************************');
end if;

OPEN get_pa_attribute_info;

	LOOP
		FETCH get_pa_attribute_info BULK COLLECT into ROW_ID_TAB, ATTRIBUTE_CATEGORY_TAB, ATTRIBUTE1_TAB, ATTRIBUTE2_TAB,
							  ATTRIBUTE3_TAB, ATTRIBUTE4_TAB, ATTRIBUTE5_TAB, ATTRIBUTE6_TAB,
							  ATTRIBUTE7_TAB, MEASURE_TAB,TIMECARD_ID_TAB
					 LIMIT 500;
		EXIT WHEN ROW_ID_TAB.COUNT = 0;

		if g_debug then
			fnd_file.put_line (fnd_file.LOG,'******************************');
			fnd_file.put_line (fnd_file.LOG,'Getting a set of bulk data');
			fnd_file.put_line (fnd_file.LOG,'******************************');
		end if;

		TIMECARD_ID_STATUS := get_locked_timecards(TIMECARD_ID_TAB);

		if g_debug then
			fnd_file.put_line (fnd_file.LOG,'Updating hxc_pa_latest_details');
			fnd_file.put_line (fnd_file.LOG,'ROW_ID_TAB.COUNT ='||ROW_ID_TAB.COUNT);
		end if;


		begin
		FORALL i in ROW_ID_TAB.first .. ROW_ID_TAB.last SAVE EXCEPTIONS
			UPDATE hxc_pa_latest_details
			   SET ATTRIBUTE_CATEGORY = ATTRIBUTE_CATEGORY_TAB(i),
			       ATTRIBUTE1 = ATTRIBUTE1_TAB(i),
			       ATTRIBUTE2 = ATTRIBUTE2_TAB(i),
			       ATTRIBUTE3 = ATTRIBUTE3_TAB(i),
			       ATTRIBUTE4 = ATTRIBUTE4_TAB(i),
			       ATTRIBUTE5 = ATTRIBUTE5_TAB(i),
			       ATTRIBUTE6 = ATTRIBUTE6_TAB(i),
			       ATTRIBUTE7 = ATTRIBUTE7_TAB(i),
			       MEASURE = MEASURE_TAB(i)
			 WHERE rowid = CHARTOROWID (ROW_ID_TAB(i))
			 AND TIMECARD_ID_STATUS(i) = 'Y';
	     	 exception
	         when table_exception then
	         	--null;
	         	l_update_warning:= 'Y';
	         end;
	     commit;

	END LOOP;

CLOSE get_pa_attribute_info;
end if; -- l_pa_upg

-- Release all locks

hxc_lock_api.release_lock
            (p_row_lock_id              => NULL,
             p_process_locker_type      => l_process_lock_type,
             p_transaction_lock_id      => g_lock_transaction_id,
             p_released_success         => l_tc_lock_boolean
            );


fnd_file.put_line (fnd_file.LOG,'******************************');
fnd_file.put_line (fnd_file.LOG,'List of skipped TC IDs');
fnd_file.put_line (fnd_file.LOG,'******************************');

if t_locked_tcs.COUNT > 0 then
for i in t_locked_tcs.FIRST .. t_locked_tcs.LAST LOOP

	if t_locked_tcs.EXISTS(i) then

		if t_locked_tcs(i) <>'Y' then

			fnd_file.put_line (fnd_file.LOG,i);
		        l_lock_warning :='Y';
		end if; -- t_locked_tcs(i) <>'Y'

	end if;-- t_locked_tcs.EXISTS

END LOOP; -- t_locked_tcs
end if; -- t_locked_tcs.COUNT

fnd_file.put_line (fnd_file.LOG,'******************************');

if (l_lock_warning = 'Y' ) then

retcode:= 1;
fnd_file.put_line (fnd_file.LOG,' Warning: Some Timecards were locked. ');
fnd_file.put_line (fnd_file.LOG,' Please clear the locks, and retry the process');

end if;


if (l_update_warning = 'Y') then

retcode:= 1;
fnd_file.put_line (fnd_file.LOG,' Warning: Some Detail Records were locked. ');
fnd_file.put_line (fnd_file.LOG,' Please clear the locks, and retry the process');

end if;

EXCEPTION
WHEN NO_UPG_DONE then

	fnd_file.put_line(fnd_file.LOG, 'Both Payroll and Projects upgrades have not been completed');
	retcode:=2;
	RAISE;

WHEN NO_LATEST_DETAILS_UPG then

	fnd_file.put_line(fnd_file.LOG, 'The Latest Details Upgrade has not been completed');
	retcode:=2;
        RAISE;

WHEN OTHERS THEN

        hxc_lock_api.release_lock
	            (p_row_lock_id              => NULL,
	             p_process_locker_type      => l_process_lock_type,
	             p_transaction_lock_id      => g_lock_transaction_id,
	             p_released_success         => l_tc_lock_boolean
                    );



        fnd_file.put_line(fnd_file.LOG,' The Program has encountered an unexpected error');
        fnd_file.put_line(fnd_file.LOG,' Tracing the error as follows - ');
        fnd_file.put_line(fnd_file.LOG,'-------------------------------');
        fnd_file.put_line(fnd_file.LOG,dbms_utility.format_error_backtrace);
        fnd_file.put_line(fnd_file.LOG,SQLERRM);
        fnd_file.put_line(fnd_file.LOG,'-------------------------------');
        retcode:=2;

        RAISE;

END generate_attribute_info;




end;

/
