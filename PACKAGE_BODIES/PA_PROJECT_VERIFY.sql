--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_VERIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_VERIFY" as
-- $Header: PAXPCO3B.pls 115.0 99/07/16 15:29:22 porting ship $


 i   BINARY_INTEGER;

 function get_rule_name(xrow IN NUMBER) return varchar2 IS
 begin
	return(verify_rule_name(xrow));
 end;

 function get_error_code(xrow IN NUMBER) return varchar2 IS
 begin
	return(verify_error_code(xrow));
 end;

 function get_error_msg(xrow IN NUMBER) return varchar2 IS
 begin
	return(verify_error_msg(xrow));
 end;

 function get_action_msg(xrow IN NUMBER) return varchar2 IS
 begin
	return(verify_action_msg(xrow));
 end;

 function get_required_flag(xrow IN NUMBER) return varchar2 IS
 begin
	return(verify_required_flag(xrow));
 end;


 PROCEDURE verification (x_project_type IN VARCHAR2, num_rows OUT NUMBER) IS

-- Commented out this procedure because, the pa_verification_rules and
-- pa_project_type_verification table has been dropped fromPA V4.0 May rel.

      --CURSOR get_verify_rules IS
      --SELECT v.verification_rule rule_name, v.meaning, v.procedure_name,
	     --v.description, p.required_flag
        --FROM pa_verification_rules v, pa_project_type_verifications p
       --WHERE p.project_type = x_project_type
         --AND p.verification_rule = v.verification_rule
         --AND v.calling_process = 'PROJECT'
    --ORDER BY p.process_sequence;

      cursor1 integer;
      proc_stmt varchar2(1000);
      row_processed   integer;

  BEGIN

       num_rows := 0;
       --cursor1 := dbms_sql.open_cursor;

       --i := 0;

       --FOR EACHREC IN get_verify_rules LOOP

          --IF ( EACHREC.procedure_name is not null and
		--x_project_type = 'Cost Plus') THEN

	        --i := i + 1;

--proc_stmt := 'begin '||EACHREC.procedure_name||'('||to_char(i)||
--','''||EACHREC.meaning||''','''||x_project_type||''','''||
--EACHREC.description||''','''||EACHREC.required_flag||'''); end;';
--
		--dbms_sql.parse(cursor1, proc_stmt, dbms_sql.native);
		--row_processed := dbms_sql.execute(cursor1);
          --END IF;

--	dbms_output.put_line(verify_rule_name(i));
--	dbms_output.put_line(verify_error_msg(i));

       --END LOOP;

       --dbms_sql.close_cursor(cursor1);
       --num_rows := i;
  END;


  PROCEDURE manager (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
		verify_error_msg(x_index) :=  'Project manager does not exist.';
verify_action_msg(x_index) := 'Go to Project Options and enter manager in Key Member screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;
  END;

  PROCEDURE client (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
       		verify_error_msg(x_index) :=  'Primary customer is required.';
verify_action_msg(x_index) :=  'Go to Project Options and enter client in Customers and Contacts screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;
  END;

  PROCEDURE contact (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
		verify_error_msg(x_index) :=  'Invalid billing contact specified.';
verify_action_msg(x_index) :=  'Go to Project Options and enter a billing contact in Customers and Contacts screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;
  END;

  PROCEDURE cost_budget (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
		verify_error_msg(x_index) :=  'Cost budget does not exist.';
verify_action_msg(x_index) :=  'Go to Project Options and enter cost budget in the Enter Cost Budget screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;

  END;

  PROCEDURE revenue_budget (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
		verify_error_msg(x_index) :=  'Revenue budget is incorrect.';
verify_action_msg(x_index) :=  'Go to Project Options and correct budget in the Enter Revenue Budget screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;

  END;

  PROCEDURE category (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
verify_error_msg(x_index) :=  'Mandatory category Funding Source does not exist';
		verify_action_msg(x_index) :=  'Go to Project Options and enter category
and class code in the Classification screen.';
      		verify_required_flag(x_index) := x_flag;
	end if;
  END;

  PROCEDURE billing_event (x_index IN NUMBER, x_rule_name IN VARCHAR2,
  x_project_type IN VARCHAR2, x_description IN VARCHAR2,x_flag IN VARCHAR2) IS
  BEGIN
	If (x_project_type = 'Cost Plus') then
		verify_rule_name(x_index) :=  x_rule_name;
		verify_error_msg(x_index) :=  'Billing event does not exist.';
verify_action_msg(x_index) :=  'Go to Project Options and enter billing event in the Events screen under Billing Information.';
      		verify_required_flag(x_index) := x_flag;
	end if;
  END;



END;

/
