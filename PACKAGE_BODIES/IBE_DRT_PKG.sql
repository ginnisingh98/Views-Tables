--------------------------------------------------------
--  DDL for Package Body IBE_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DRT_PKG" AS
  /* $Header: IBEDRTPB.pls 120.0.12010000.1 2018/04/06 23:22:57 ytian noship $ */

l_package varchar2(33) := 'IBE_DRT_PKG';
  --
  --- Implement log writer
  --
  PROCEDURE write_log
    (message       IN         varchar2,
     stage	   IN	      varchar2) IS
  BEGIN

	if (g_debug = 'Y' AND fnd_log.g_current_runtime_level<=fnd_log.level_procedure ) then
		fnd_log.string(fnd_log.level_procedure,message,stage);
	end if;

       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
         IBE_Util.Debug('IBE_DRT_PKG:'||message||' '||stage);
       END IF;

  END write_log;
  --

  --
  --- Implement Core HR specific DRC for HR entity type
  --
  PROCEDURE ibe_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ibe_profile_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);
    l_email_str varchar2(200);
    l_email_str2 varchar2(200);
    L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;
  BEGIN
    -- .....
    write_log ('Entering:'|| l_proc,'10');
    --dbms_output.put_line('Entering:'|| l_proc);
    p_person_id := person_id;
    write_log ('p_person_id: '|| p_person_id,'20');

    l_email_str := FND_PROFILE.VALUE_SPECIFIC('IBE_DEF_ORDER_ADMIN_EMAIL',null,null,671);
    l_email_str2 := FND_PROFILE.VALUE_SPECIFIC('IBE_ORDER_ADMIN',null,null,671);
    write_log ('profle IBE_DEF_ORDER_ADMIN_EMAIL: '|| l_email_str,'20');
    write_log ('profle IBE_ORDER_ADMIN: '|| l_email_str2,'30');
    --dbms_output.put_line('profle IBE_DEF_ORDER_ADMIN_EMAIL: '|| l_email_str);
    --dbms_output.put_line('profle IBE_ORDER_ADMIN: '|| l_email_str2);
	---- Check DRC rule# 1
    if ((l_email_str is not null)  and (l_email_str <>'null')) then
     BEGIN

	   --- Check Profile IBE:Order Administrator for Booking Issues:  IBE_DEF_ORDER_ADMIN_EMAIL
            write_log ('IBE_DEF_ORDER_ADMIN_EMAIL:l_email_str is not null = '|| l_email_str,40);
            --dbms_output.put_line ('IBE_DEF_ORDER_ADMIN_EMAIL:l_email_str is not null = '|| l_email_str);
           SELECT  count(*) into l_count
           FROM    per_all_people_f
           WHERE   person_id = p_person_id
            AND    nvl(email_address,'') = l_email_str ;

           write_log ('Found matching for IBE_DEF_ORDER_ADMIN_EMAIL l_email_str='||l_email_str||' l_count= '|| l_count,'50');
		--
		--- If FPD is in future or not set at all, then person is active. Should not delete. Raise error.
		--
	   if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'IBE_DRC_ORD_EMAIL'
			  ,msgaplid => 671
			  ,result_tbl =>   l_result_tbl  );
                        write_log ('Done logging warning message IBE_DRC_ORD_EMAIL','60');
	   end if;
       EXCEPTION
             WHEN NO_DATA_FOUND THEN
                write_log ('NO_DATA_FOUND Checking IBE_DEF_ORDER_ADMIN_EMAIL for person_id='||p_person_id,'70');
                RESULT_TBL  := L_RESULT_TBL;

             WHEN OTHERS THEN
                write_log ('Error IBE_DEF_ORDER_ADMIN_EMAIL while getting the record for person_id='||p_person_id,'80');
                RESULT_TBL  := L_RESULT_TBL;

     END;
    else
         write_log ('IBE_DEF_ORDER_ADMIN_EMAIL:l_email_str is null  ',90);
         --dbms_output.put_line ('IBE_DEF_ORDER_ADMIN_EMAIL:l_email_str is  null = '|| l_email_str);
    END IF;

	---- Check DRC rule# 2
    if ((l_email_str2 is not null)  and (l_email_str2 <>'null')) then
     BEGIN

		--- Check Profile IBE:Order Administrator : IBE_ORDER_ADMIN
           write_log ('IBE_ORDER_ADMIN:l_email_str2 is not null = '|| l_email_str2,100);
           --dbms_output.put_line ('IBE_ORDER_ADMIN:l_email_str2 is not null = '|| l_email_str2);
           SELECT  count(*) into l_count
           FROM    per_all_people_f
           WHERE   person_id = p_person_id
            AND    nvl(email_address,'') = l_email_str2 ;

           write_log ('Found the match for IBE_ORDER_ADMIN:l_count= '|| l_count,'110');
           --dbms_output.put_line('Found match for IBE_ORDER_ADMIN:l_count= '|| l_count);
		--
		--- If FPD is in future or not set at all, then person is active. Should not delete. Raise error.
		--
	   if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'IBE_DRC_ORD_ADMIN'
			  ,msgaplid => 671
			  ,result_tbl =>   l_result_tbl  );
                        write_log ('Done logging warning message IBE_DRC_ORD_ADMIN','120');
                        --dbms_output.put_line('logged IBE_DRC_ORD_ADMIN');
                        RESULT_TBL  := L_RESULT_TBL;
	   end if;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                write_log ('NO_DATA_FOUND IBE_ORDER_ADMIN  for person_id='||p_person_id,'130');
                --dbms_output.put_line('NO DATA FOUND logged IBE_DRC_ADMIN');
                RESULT_TBL  := L_RESULT_TBL;

             WHEN OTHERS THEN
                write_log ('Error IBE_ORDER_ADMIN while getting the record for person_id='||p_person_id,'140');
                --dbms_output.put_line('error logged IBE_DRC_ADMIN'||sqlerrm);
                RESULT_TBL  := L_RESULT_TBL;


     END;
    else
      write_log ('IBE_ORDER_ADMIN:l_email_str2 is null  ',150);
      --dbms_output.put_line('IBE_ORDER_ADMIN:l_email_str2 is null');
    END IF;

    write_log ('Leaving:'|| l_proc,'999');
    --dbms_output.put_line ('Leaving:'|| l_proc);

  END ibe_hr_drc;


END ibe_drt_pkg;

/
