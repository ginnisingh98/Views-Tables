--------------------------------------------------------
--  DDL for Package Body PSP_WF_EFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_WF_EFT_PKG" AS
--$Header: PSPWFCRB.pls 115.11 2002/12/31 09:58:05 ddubey ship $

PROCEDURE Populate_Attribute(itemtype	   IN     VARCHAR2,
			itemkey            IN  	  VARCHAR2,
			actid        	   IN	  NUMBER,
			funcmode	   IN	  VARCHAR2,
			result		   OUT NOCOPY    VARCHAR2
			) IS

l_person_id NUMBER;
l_template_id NUMBER;
l_bgn_Perd DATE;
l_end_Perd DATE;
l_emp_num VARCHAR2(30);
l_emp_name VARCHAR2(240);
l_sup_name  VARCHAR2(240);
l_orig_login VARCHAR2(100);
l_result     VARCHAR2(30);
l_emp_login	varchar2(100);
-- 8.31.99...Itemkey passed has version number concatenated..causes probs with some queries
l_itemkey	varchar2(30);
l_ver		varchar2(2);
-- End 8.31.99
CURSOR get_emp_details_csr IS
SELECT full_name,
       employee_number
FROM per_people_f
WHERE person_id = L_Person_id and
      L_end_perd between effective_start_date and effective_end_date;

CURSOR get_period_details_csr IS
SELECT Begin_date,
       End_date
FROM psp_effort_report_templates
WHERE template_id = l_template_id;

CURSOR get_supervisor_csr IS
SELECT ppf.full_name
FROM per_people_f ppf
WHERE ppf.person_id = (select paf.supervisor_id from per_assignments_f paf
                       where  paf.person_id = l_person_id
                              AND  paf.assignment_type ='E'	--Added for bug 2624259.
                              AND  l_end_perd between paf.effective_start_date and
                                                 paf.effective_end_date   and
                              paf.primary_flag  = 'Y' ) and
      l_end_perd between ppf.effective_start_date and ppf.effective_end_date;

--For Bug 2624263: Changed the select. Selecting name from fnd_users instead of wf_users
CURSOR get_user_name_csr IS
SELECT	usr.user_name
FROM	fnd_user usr,
	per_people_f ppf,
	fnd_languages fndl
WHERE 	usr.employee_id = ppf.person_id
AND     trunc ( SYSDATE ) between ppf.effective_start_date and ppf.effective_end_date
AND     fndl.installed_flag='B'
AND 	usr.end_date IS  NULL
AND 	ppf.person_id  = l_person_id
AND     rownum = 1 ;
/************
SELECT name
FROM   wf_users
where  orig_system_id = l_person_id and
       orig_system    = 'PER' and
       status         = 'ACTIVE' and
       rownum	  = 1;
******/
--End of bug fix 2624263

begin
IF (funcmode = 'RUN') THEN
	L_orig_login :=   Fnd_Global.User_name;

-- 8.31.99 ... Here is where itemkey gives prob...remove the version num..

 	l_itemkey := substr(itemkey, 1, length(itemkey) - 1);
        l_ver := substr(itemkey, length(itemkey));
-- 8.31.99

	SELECT person_id, template_id INTO L_person_id,L_template_id
	FROM psp_effort_reports
--	WHERE effort_report_id = to_number(itemkey); 8.31.99...use the l_itemkey
	WHERE effort_report_id = to_number(l_itemkey)
	  AND version_num = to_number(l_ver); -- to get the correct record and avoid multiple row returns.
-- End 8.31.99

	OPEN get_period_details_csr;
	FETCH get_period_details_csr INTO L_bgn_perd,
		   L_end_perd;
	CLOSE get_period_details_csr;

	OPEN get_emp_details_csr;
	FETCH get_emp_details_csr INTO L_emp_name,
		   L_emp_num;
	CLOSE get_emp_details_csr;

	OPEN get_supervisor_csr;
	FETCH get_supervisor_csr INTO L_sup_name;
	CLOSE get_supervisor_csr;

      OPEN get_user_name_csr;
      FETCH get_user_name_csr INTO l_emp_login;
      if get_user_name_csr%NOTFOUND then
         result	:= wf_engine.eng_completed||':'||'N';
      else
         result	:= wf_engine.eng_completed||':'||'Y';
      end if;
      close get_user_name_csr;

	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_NAME',
				  L_emp_name);
      --dbms_output.put_line('Emp Name ' || l_emp_name);

	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_NO',
				  L_emp_num);
      --dbms_output.put_line('Emp No ' || l_emp_num);

	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'SUP_NAME',
				  L_sup_name);

      --dbms_output.put_line('Sup Name ' || l_sup_name);

	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_LOGIN',
			     l_emp_login);

      --dbms_output.put_line('Emp Login ' || l_emp_login);

	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'ORG_NAME',
				  L_orig_login);

      --dbms_output.put_line('Orig Login ' || l_orig_login);


        wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'BEGIN_DT',
				L_bgn_perd);

      --dbms_output.put_line('Begin Dt ' || to_char(l_bgn_perd));

        wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'END_DT',
				  L_end_perd);

      --dbms_output.put_line('End Dt ' || to_char(l_end_perd));

/*        wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'RESULT',
				  l_result);
*/

--       result := 'COMPLETE';
END IF;

EXCEPTION
		WHEN OTHERS THEN
		wf_core.context('Psh_Wf_Eft_Pkg','Populate_Attribute',itemtype,itemkey,to_char(actid),funcmode);
		raise;

end Populate_Attribute;

PROCEDURE Populate_Attribute1(itemtype	   IN     VARCHAR2,
			itemkey            IN  	  VARCHAR2,
			actid        	   IN	  NUMBER,
			funcmode	   IN	  VARCHAR2,
			result		   OUT NOCOPY    VARCHAR2
			) IS

l_person_id NUMBER;
l_template_id NUMBER;
l_supervisor_id NUMBER;
l_no_sup	   NUMBER;
l_total_sup	   NUMBER;
l_count	   NUMBER;
l_bgn_Perd DATE;
l_end_Perd DATE;
l_emp_num VARCHAR2(30);
l_emp_name VARCHAR2(240);
l_sup_name  VARCHAR2(240);
l_result     VARCHAR2(30);
l_action	VARCHAR2(30);
l_emp_login	varchar2(100);
l_supervisor_login varchar2(100);
l_tmp		varchar2(50);

-- 8.31.99....remove the version number from the itemkey and use the ER Id...
l_itemkey	varchar2(30);
l_ver		varchar2(2);
--8.31.99

CURSOR get_emp_details_csr IS
SELECT full_name,
       employee_number
FROM per_people_f
WHERE person_id = L_Person_id and
      L_end_perd between effective_start_date and effective_end_date;

CURSOR get_period_details_csr IS
SELECT Begin_date,
       End_date
FROM psp_effort_report_templates
WHERE template_id = l_template_id;

CURSOR get_supervisor_csr IS
SELECT ppf.full_name, ppf.person_id
FROM per_people_f ppf
WHERE ppf.person_id = (select paf.supervisor_id from per_assignments_f paf
                       where  paf.person_id = l_person_id
		              AND paf.assignment_type ='E' --Added for bug 2624259.
                              AND l_end_perd between paf.effective_start_date and
                                                 paf.effective_end_date and
		                 primary_flag = 'Y')   and
      l_end_perd between ppf.effective_start_date and ppf.effective_end_date;

--For Bug 2624263 : Supervisor 's login name being selected from fnd_users instead of wf_users
CURSOR get_supervisor_login_csr IS
SELECT	usr.user_name
FROM	fnd_user usr,
	per_people_f ppf,
	fnd_languages fndl
WHERE 	usr.employee_id = ppf.person_id
AND     trunc ( SYSDATE ) between ppf.effective_start_date and ppf.effective_end_date
AND     fndl.installed_flag='B'
AND 	usr.end_date IS NULL
AND 	ppf.person_id  = l_supervisor_id
AND     rownum = 1 ;
/*************************
SELECT name
FROM   wf_users
where  orig_system_id = l_supervisor_id and
       orig_system    = 'PER' and
       status         = 'ACTIVE';
**************************/
--end of bug fix 2624263
begin
IF (funcmode = 'RUN') THEN
	L_emp_login :=   Fnd_Global.User_name;

-- 8.31.99...itemkey causes prob with the version num concatenated..remove it..
	l_itemkey	:=  substr(itemkey, 1, length(itemkey) - 1);
        l_ver := substr(itemkey, length(itemkey));
-- End 8.31.99

	SELECT person_id, template_id INTO L_person_id, l_template_id
	FROM psp_effort_reports
--8.31.99 ....use the l_itemkey above...BUG#969850
--	WHERE effort_report_id = to_number(itemkey);
	WHERE effort_report_id = to_number(l_itemkey)
          AND version_num = to_number(l_ver); -- to get the correct record and avoid multiple row returns.
-- End 8.31.99

      --dbms_output.put_line('Crossed 1 Select  ');

	OPEN get_period_details_csr;
	FETCH get_period_details_csr INTO L_bgn_perd,
		   L_end_perd;
	CLOSE get_period_details_csr;

      --dbms_output.put_line('Crossed 2 Select  ');

	OPEN get_emp_details_csr;
	FETCH get_emp_details_csr INTO L_emp_name,
		   L_emp_num;
	CLOSE get_emp_details_csr;

      --dbms_output.put_line('Crossed 3 Select  ');

	OPEN get_supervisor_csr;
      LOOP
  	  FETCH get_supervisor_csr INTO L_sup_name, l_supervisor_id;
        EXIT WHEN get_supervisor_csr%NOTFOUND;

        l_action	:= wf_engine.GetItemAttrText (
  				itemtype,
                           itemkey,
                           aname	=> 'RESULT');
        l_no_sup	:= wf_engine.GetItemAttrNumber (
  				itemtype,
                           itemkey,
                           aname	=> 'L_COUNTER');

        l_total_sup	:= wf_engine.GetItemAttrNumber (
  				itemtype,
                           itemkey,
                           aname	=> 'NO_SUP');


        --dbms_output.put_line('Supervisor ID ' || to_char(l_supervisor_id));
        --dbms_output.put_line('Action ' || l_action);
        --dbms_output.put_line('No Of Supervisors ' || to_char(l_no_sup));
	  l_no_sup	:= l_no_sup	+ 1;
        l_count	:= 1;
        if l_count = l_no_sup then
           OPEN get_supervisor_login_csr;
           FETCH get_supervisor_login_csr INTO l_supervisor_login;
           if get_supervisor_login_csr%NOTFOUND then
   	         if l_action = 'Accepted' then
                  l_tmp		:= wf_engine.eng_completed||':'||'NOSUP_ACC';
               else
                  l_tmp		:= wf_engine.eng_completed||':'||'NOSUP_RET';
               end if;
           else
	         if l_action = 'Accepted' then
                  l_tmp		:= wf_engine.eng_completed||':'||'SUP_ACC';
               else
                  l_tmp		:= wf_engine.eng_completed||':'||'SUP_RET';
               end if;
            end if;
            close get_supervisor_login_csr;

            --dbms_output.put_line('Result ' || l_tmp);
            result		:= l_tmp;


            wf_engine.SetItemAttrNumber (
  				itemtype,
                           itemkey,
                           'L_COUNTER',
                            l_no_sup);

       	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_NAME',
				  L_emp_name);

             --dbms_output.put_line('Emp Name ' || l_emp_name);

       	wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_NO',
				  L_emp_num);

             --dbms_output.put_line('Emp Num ' || l_emp_num);

		wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'SUP_NAME',
				  L_sup_name);

	     --dbms_output.put_line('Sup Name ' || l_sup_name);

		wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'EMP_LOGIN',
			     l_emp_login);

	     --dbms_output.put_line('Emp Login ' || l_emp_login);

	     wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'BEGIN_DT',
				L_bgn_perd);

	     --dbms_output.put_line('Begin Period ' || to_date(l_bgn_perd));

	        wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'END_DT',
				  L_end_perd);

	     --dbms_output.put_line('End Period ' || to_date(l_end_perd));

		wf_engine.setitemattrtext(itemtype,
			 	itemkey,
		      	    'SUP_LOGIN',
			     l_supervisor_login);
	     --dbms_output.put_line('Supervisor Login ' || l_supervisor_login);
       end if;
   END LOOP;
   CLOSE get_supervisor_csr;
END IF;

EXCEPTION
		WHEN OTHERS THEN
		wf_core.context('Psh_Wf_Eft_Pkg','Populate_Attribute',itemtype,itemkey,to_char(actid),funcmode);
		raise;

end Populate_Attribute1;

END PSP_WF_EFT_PKG;


/
