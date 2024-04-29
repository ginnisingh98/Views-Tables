--------------------------------------------------------
--  DDL for Package Body IGS_SC_BULK_ASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SC_BULK_ASSIGN" AS
 /* $Header: IGSSC07B.pls 120.7 2006/02/02 07:10:55 skpandey noship $ */



Type StrArray IS VARRAY(10) of VARCHAR2(500);
Type DateArray IS VARRAY(10) of VARCHAR2(11);
l_usrroles_array StrArray;
l_startdate_array DateArray;
l_enddate_array DateArray;

l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_sc_bulk_assign';
l_label VARCHAR2(4000);
l_debug_str VARCHAR2(32000);


PROCEDURE PopulateRolesArray(EncdStr VARCHAR2) IS
 ------------------------------------------------------------------
  --Updated by  : ssawhney, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: This procedure will populate the roles arrays with the values of
  --  Role Name,Start Date and End Date
  --
  --Change History:
------------------------------------------------------------------
--This Local variable will save	the String passed as parameter
l_Param_Str VARCHAR2(4000);
l_Rec_Str VARCHAR2(500);
--This will have the end positions of the substring
l_End_Count NUMBER;
--This will have the send position of a particular record
l_End_Rec_Count NUMBER;
l_array_index binary_integer;
-- This will have the current array index

BEGIN
  /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.PopulateRolesArray';
  l_debug_str := 'Entering PopulateRolesArray. EncdStr is ' || EncdStr;
  fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;


L_Param_Str := EncdStr;
L_End_Count := INSTR(L_Param_Str,'\:\');
l_array_index := 1;

WHILE L_Param_Str IS NOT NULL LOOP

l_usrroles_array.EXTEND(1);
l_startdate_array.EXTEND(1);
l_enddate_array.EXTEND(1);

l_Rec_Str := SUBSTR(L_Param_Str,1,L_End_Count-1);
l_End_Rec_Count := INSTR(l_Rec_Str,'\~\');
l_usrroles_array(l_array_index) := SUBSTR(l_Rec_Str,1,l_End_Rec_Count-1);

l_Rec_Str := SUBSTR(l_Rec_Str,l_End_Rec_Count+3);
l_End_Rec_Count := INSTR(l_Rec_Str,'\~\');
l_startdate_array(l_array_index) := SUBSTR(l_Rec_Str,1,l_End_Rec_Count-1);
l_Rec_Str := SUBSTR(l_Rec_Str,l_End_Rec_Count+3);

IF l_Rec_Str IS NOT NULL THEN
	l_enddate_array(l_array_index) := l_Rec_Str;
END IF;

l_Param_Str := SUBSTR(L_Param_Str,L_End_Count+3);
l_array_index := l_array_index +1;
L_End_Count := INSTR(L_Param_Str,'\:\');

IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.PopulateRolesArray';
  l_debug_str := 'Inside PopulateRolesArray. l_Rec_Str: '||l_Rec_Str|| ', l_End_Rec_Count: '||l_End_Rec_Count||
			', l_Param_Str: '||l_Param_Str|| ', l_array_index: '||l_array_index;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

END LOOP;
   /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.PopulateRolesArray';
  l_debug_str := 'Exiting PopulateRolesArray.';
  fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

END PopulateRolesArray;



FUNCTION getTokens( EncdStr Varchar2)
RETURN StrArray
IS
------------------------------------------------------------------
  --Updated by  : ssawhney, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose:This Function will return an array populated with user attributes
  --
  --Change History:
------------------------------------------------------------------
--This Local variable will save the String passed as parameter
L_Param_Str VARCHAR2(4000);--This will have the beg position of the substring
--This will have the end positions of the substring
L_End_Count NUMBER;
l_tokenArray StrArray := StrArray();
l_array_index binary_integer;

BEGIN
  /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.getTokens';
  l_debug_str := 'Entering getTokens. EncdStr is ' || EncdStr||', l_array_index is ' || l_array_index;
  fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

L_Param_Str := EncdStr;
L_End_Count := INSTR(L_Param_Str,'\:\');
l_array_index := 1;


IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.getTokens';
  l_debug_str := 'Inside getTokens. L_Param_Str is'||L_Param_Str|| ', L_End_Count is '||L_End_Count;
  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

WHILE L_Param_Str IS NOT NULL LOOP
l_tokenArray.EXTEND(1);
l_tokenArray(l_array_index) := SUBSTR(L_Param_Str,1,L_End_Count-1);
L_Param_Str := SUBSTR(L_Param_Str,L_End_Count+3);

l_array_index := l_array_index +1;
L_End_Count := INSTR(L_Param_Str,'\:\');

END LOOP;
  /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.getTokens';
  l_debug_str := 'Exiting getTokens. Returning l_tokenArray(1)= ' ||l_tokenArray(1);
  fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

RETURN l_tokenArray;
End getTokens;


PROCEDURE BulkSecAssignment(
 retValue out NOCOPY number,
 orgUnitStr IN varchar2,
 locStr IN varchar2,
 pgmStr IN varchar2,
 unitMdStr IN varchar2,
 userRolesStr_one IN varchar2,
 userRolesStr_two IN varchar2,
 prsnGrpStr IN varchar2)
 IS
 ------------------------------------------------------------------
  --Updated by  : ssawhney, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: This Procedure will carry out the Bulk Assignment of user Attributes
  --         Does a submit request. Called by SS Page.
  --
  --Change History:
  --who                 when                  what
  --skpandey            08-SEP-2005           Bug: 4583789
  --                                          Description: Corrected spelling
------------------------------------------------------------------

BEGIN
 /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_bulk_assign.BulkSecAssignment';
     l_debug_str :=  'Entering BulkSecAssignment parameter values:'||
		     'Org  Unit: '||orgUnitStr||','||
		     'Location: '||locStr||','||
		     'Program Type: '||pgmStr||','||
		     'Unit Mode: '||unitMdStr||','||
		     'User Roles Str1: '||userRolesStr_one||','||
		     'User Roles Str2: '||userRolesStr_two||','||
		     'Person Group: '||prsnGrpStr;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;
  retValue := fnd_request.submit_request('IGS','IGSSCJ01','Bulk Security Attributes Assignment',NULL,false,
               orgUnitStr,locStr,pgmStr,unitMdStr,userRolesStr_one,userRolesStr_two,prsnGrpStr);

  /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
  l_label := 'igs.plsql.igs_sc_bulk_assign.BulkSecAssignment';
  l_debug_str := 'Exiting BulkSecAssignment. retValue is '||retValue;
  fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
END IF;

END BulkSecAssignment;

PROCEDURE ASSIGN_USER_ATTRIBUTES (
          ERRBUF out NOCOPY VARCHAR2,
          RETCODE out NOCOPY NUMBER,
          P_ORGUNIT_STR IN VARCHAR2 DEFAULT NULL,
          P_LOCATIONS_STR IN VARCHAR2 DEFAULT NULL,
          P_PGMTYPES_STR IN VARCHAR2 DEFAULT NULL,
          P_UNITMODE_STR IN VARCHAR2 DEFAULT NULL,
          P_USERROLES_STR_ONE IN VARCHAR2 DEFAULT NULL,
          P_USERROLES_STR_TWO IN VARCHAR2 DEFAULT NULL,
          P_PRSNGRP_STR IN VARCHAR2) IS
 ------------------------------------------------------------------
  --Updated by  : ssawhney, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose: Called by SRS Conc Job
  --
  --Change History:
  --gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID to disable OSS for R12.
  --gmaheswa      17-Jan-06        4938278: disable Business Events before starting bulk import process and enable after import.
------------------------------------------------------------------
    l_org_unit_array StrArray;
    l_locations_array StrArray;
    l_pgmtypes_array StrArray;
    l_unitmd_array StrArray;
    loc_prsnGrp_array StrArray;

    l_GrpId igs_pe_persid_group_v.group_id%TYPE;
    l_User_Id NUMBER;
    l_sec_User_id NUMBER;
    l_rowId VARCHAR2(500);
    l_DupId NUMBER;
    l_user_name VARCHAR2(320);
    l_sec_User_Name VARCHAR2(320);
    l_return_Status VARCHAR2(10);
    l_return_message VARCHAR2(500);
    --l_role_id NUMBER;
    l_role_name VARCHAR2(1000);
    l_last_update_date Date := Sysdate;
    l_Ret_Status VARCHAR2(100);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(500);
    l_party_rel_id VARCHAR2(100);
    l_party_id NUMBER;
    l_party_number NUMBER;
    l_object_version NUMBER;
    L_select VARCHAR2(32767);
    l_status VARCHAR2(1);
    L_str VARCHAR2(32000);
    l_Inf_date VARCHAR2(11);
    l_user_roles_param VARCHAR2(4000);
    l_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

CURSOR Fnd_User_Check_C(Prsn_id	NUMBER)	IS
SELECT user_id,user_name, customer_id, employee_id
FROM FND_USER
WHERE Person_party_id = Prsn_id AND
SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE+1);

CURSOR IGS_SC_DUP_C(prsnId NUMBER,usrAttrId NUMBER,usrAttrVal VARCHAR2) IS
SELECT 1
FROM IGS_SC_PER_ATTR_VALS
WHERE person_id = prsnId AND
user_attrib_id = usrAttrId AND
user_attrib_value = usrAttrVal;

CURSOR DUP_ROLES_CHK_C(UserId NUMBER,RoleName VARCHAR2,RolrOrgSystem VARCHAR2,
		RoleOrgSysId NUMBER, UsrOrgSystem VARCHAR2,UsrName VARCHAR2) IS
SELECT 1, START_DATE /*while assigning roles check if person is associated with mul FND USER */
FROM WF_LOCAL_USER_ROLES
WHERE user_orig_system_id =UserId AND
      user_name=UsrName AND
      role_name= RoleName AND
      user_orig_system = UsrOrgSystem AND
      role_orig_system = RolrOrgSystem AND
      role_orig_system_id = RoleOrgSysId; -- and partition_id IS NOT NULL

CURSOR GET_ROLE_NAME_C(RoleId NUMBER) IS
SELECT NAME
FROM WF_LOCAL_ROLES
WHERE
ORIG_SYSTEM_ID = RoleId AND
ORIG_SYSTEM ='IGS'
AND partition_id=0 ;  -- non registered orig systems are stored in partion 0

CURSOR DUP_ORGUNIT_CHECK_C(PrsnId NUMBER,OrgId NUMBER,RelCode VARCHAR2,DFLAG VARCHAR2) IS
Select 1
from HZ_RELATIONSHIPS
WHERE
   SUBJECT_ID = PrsnId AND
   OBJECT_ID = OrgId AND
   object_type = 'ORGANIZATION' AND
   subject_type = 'PERSON' AND
   RELATIONSHIP_CODE = 'EMPLOYEE_OF'
   AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE+1)
   AND DIRECTIONAL_FLAG='F';

CURSOR get_person_num (cp_prsnId NUMBER) IS
SELECT party_number
FROM hz_parties
WHERE party_id=cp_prsnId;

 TYPE cur_query IS REF CURSOR;
 c_cur_query cur_query;

 TYPE rec_query IS RECORD (
          person_id     NUMBER(30)
          );
r_rec_query rec_query;
l_DupStartDate Date;
l_start_date Date;
l_cust_id number;
l_emp_id number;
l_sec_cust_id number;
l_sec_emp_id number;
l_role_exists varchar2(1);
--s binary_integer ;
l_roles WF_DIRECTORY.RoleTable ;
l_wf_orig_id number;
l_wf_orig_ref wf_local_roles.orig_system%type;
l_person_num igs_pe_person.person_number%type;

BEGIN

igs_ge_gen_003.set_org_id;

--Disable Business Event before running Bulk Process
IGS_PE_GEN_003.TURNOFF_TCA_BE (
      P_TURNOFF  => 'Y'
);

	 /* Debug */
IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
     l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
     l_debug_str :=  'Entering assign_user_attributes parameter values:'||
		     'Org  Unit: '||P_ORGUNIT_STR||','||
		     'Location: '||P_LOCATIONS_STR||','||
		     'Program Type: '||P_PGMTYPES_STR||','||
		     'Unit Mode: '||P_UNITMODE_STR||','||
		     'User Roles Str1: '||P_USERROLES_STR_ONE||','||
		     'User Roles Str2: '||P_USERROLES_STR_TWO||','||
		     'Person Group: '||P_PRSNGRP_STR;
     fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;

	RETCODE :=0;
	/* Now we have all the person Grp Code */

	l_user_roles_param :=P_USERROLES_STR_ONE||P_USERROLES_STR_TWO;
	loc_prsnGrp_array := getTokens(P_PRSNGRP_STR);

	IF P_ORGUNIT_STR IS NOT	NULL THEN
		l_org_unit_array := getTokens(P_ORGUNIT_STR);
	END IF;

	IF P_LOCATIONS_STR IS NOT NULL THEN
		l_locations_array := getTokens(P_LOCATIONS_STR);
	END IF;

	IF P_PGMTYPES_STR IS NOT NULL THEN
		l_pgmtypes_array := getTokens(P_PGMTYPES_STR);
	END IF;

	IF P_UNITMODE_STR IS NOT NULL THEN
		l_unitmd_array := getTokens(P_UNITMODE_STR);
	END IF;

	IF l_user_roles_param IS NOT NULL THEN
		l_usrroles_array := StrArray();
		l_startdate_array:= DateArray();
		l_enddate_array := DateArray();
		PopulateRolesArray(l_user_roles_param);
	END IF;


	FOR j IN 1..loc_prsnGrp_array.COUNT
	LOOP
		l_GrpId	:= loc_prsnGrp_array(j);

		/* get the person id corresponding to user belonging to	the grp	and assigned them following attributes */
		l_select :=igs_pe_dynamic_persid_group.get_dynamic_sql(l_GrpId, l_status, l_group_type);

		IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
		  l_debug_str := 'Person Group Array. Dynamic Person Group select is '||l_select ;
		  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		END IF;

		IF l_status <> 'S' THEN
		    FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_QUERY');
		    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
		    RAISE NO_DATA_FOUND;
		END IF;

	--skpandey, Bug#4937960: Added logic as a part of Literal Fix
	   IF l_group_type = 'STATIC' THEN
	    OPEN c_cur_query FOR L_select USING l_GrpId;
	   ELSIF l_group_type = 'DYNAMIC' THEN
	    OPEN c_cur_query FOR L_select;
	   END IF;
		LOOP
 		  FETCH c_cur_query INTO r_rec_query;
		  EXIT WHEN c_cur_query%NOTFOUND;
		 /* Check Whether user id FND USER otherwise put a error msg in	the error log and skip assignment */
		  OPEN Fnd_User_Check_C(r_rec_query.Person_id);
		  FETCH Fnd_User_Check_C INTO l_User_Id,l_user_name, l_cust_id, l_emp_id;

		  IF Fnd_User_Check_C%FOUND THEN
			/* IF User is a	FND USER then carry out	the assignment*/

			--IMP logic --simran.
			IF l_emp_id IS NOT NULL and l_cust_id IS NULL THEN
			   l_wf_orig_id := l_emp_id;
			   l_wf_orig_ref:= 'PER';
			ELSIF    l_cust_id IS NOT NULL and (l_cust_id = r_rec_query.Person_id) THEN
			   l_wf_orig_id := l_User_Id;
			   l_wf_orig_ref:= 'FND_USR';
			END IF;

			IF l_org_unit_array IS NOT NULL THEN

  			  /*Now iterate through the array to insert record into HZ_RELATIONSHIP */
			  FOR i IN 1..l_org_unit_array.COUNT
			  LOOP

			    /* First check whether this attribute already exist */
			    OPEN DUP_ORGUNIT_CHECK_C(r_rec_query.Person_id,l_org_unit_array(i),'EMPLOYEE_OF','F');
			    FETCH DUP_ORGUNIT_CHECK_C INTO l_DupId;

			    IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
				  l_debug_str := 'Inside assign_user_attributes. l_org_unit_array(i) is '||l_org_unit_array(i) ;
				  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
			     END IF;

			    IF DUP_ORGUNIT_CHECK_C%NOTFOUND THEN

				IGS_PE_RELATIONSHIPS_PKG.CREATUPDATE_PARTY_RELATIONSHIP(
				   p_action  				=> 'INSERT',
				   p_subject_id				=> r_rec_query.Person_id,
				   p_object_id				=> l_org_unit_array(i),
				   p_party_relationship_type		=> 'EMPLOYMENT',
				   p_relationship_code		=> 'EMPLOYEE_OF',
				   p_comments				=> NULL,
				   p_start_date				=> trunc(SYSDATE),
				   p_end_date				=> null,
				   p_last_update_date		=> l_last_update_date,
				   p_return_status			=> l_Ret_Status,
				   p_msg_count				=> l_msg_count,
				   p_msg_data				=> l_msg_data,
				   p_party_relationship_id	=> l_party_rel_id,
				   p_party_id				=> l_party_id,
				   p_party_number			=> l_party_number,
				   p_caller				    => 'NOT_FAMILY',
				   P_Object_Version_Number	=> l_object_version,
				   P_Primary				=> null,
				   P_Secondary				=> null,
				   P_Joint_Salutation		=> null,
				   P_Next_To_Kin			=> null,
				   P_Rep_Faculty			=> null,
				   P_Rep_Staff				=> null,
				   P_Rep_Student			=> null,
				   P_Rep_Alumni				=> null,
				   p_directional_flag		=> 'F');

    				IF l_return_status IN ('E' , 'U') THEN
					FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
					RAISE NO_DATA_FOUND;
				END IF;

			    END IF;  -- DUP_ORGUNIT_CHECK_C%NOTFOUND
			    CLOSE DUP_ORGUNIT_CHECK_C;
		          END LOOP;  -- l_org_unit_array.COUNT
   		        END IF; -- l_org_unit_array

		        IF l_locations_array IS NOT NULL THEN

				/*Now iterate through Locations array to insert record into igs_sc_per_attr_vals */
			  FOR i IN 1..l_locations_array.COUNT
			  LOOP
				/* First check that user does not have this attribute already assigned */
				OPEN IGS_SC_DUP_C(r_rec_query.Person_id,6,l_locations_array(i));
				FETCH IGS_SC_DUP_C INTO l_DupId;

				 IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
				  l_debug_str := 'Inside assign_user_attributes. l_locations_array(i) is '||l_locations_array(i) ;
				  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				END IF;

				IF IGS_SC_DUP_C%NOTFOUND THEN
				   IGS_SC_PER_ATTR_VALS_PKG.INSERT_ROW(
					    x_rowid => l_rowId,
					    x_person_id =>r_rec_query.Person_id,
					    x_user_attrib_id => 6,
					    x_user_attrib_value => l_locations_array(i)
					   );
				END IF;
				CLOSE IGS_SC_DUP_C;
			  END LOOP;
		        END IF;  -- l_locations_array

			IF l_pgmtypes_array IS NOT NULL THEN
				/*Now iterate through PgmTypes array to insert record into igs_sc_per_attr_vals */
				for i IN 1..l_pgmtypes_array.COUNT
				LOOP
				   OPEN IGS_SC_DUP_C(r_rec_query.Person_id,7,l_pgmtypes_array(i));
				   FETCH IGS_SC_DUP_C INTO l_DupId;

				   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
					  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
					  l_debug_str := 'Inside assign_user_attributes. l_pgmtypes_array(i) is '||l_pgmtypes_array(i) ;
					  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				   END IF;

				   IF IGS_SC_DUP_C%NOTFOUND THEN
					IGS_SC_PER_ATTR_VALS_PKG.INSERT_ROW(
					    x_rowid => l_rowId,
					    x_person_id =>r_rec_query.Person_id,
					    x_user_attrib_id => 7,
					    x_user_attrib_value => l_pgmtypes_array(i)
					   );
				   END IF;
				   CLOSE IGS_SC_DUP_C;
               			END LOOP;
			END IF; -- l_pgmtypes_array

			IF l_unitmd_array IS NOT NULL THEN
				/*Now iterate through Unit Md array to insert record into igs_sc_per_attr_vals */
				FOR i IN 1..l_unitmd_array.COUNT
				LOOP
				   OPEN IGS_SC_DUP_C(r_rec_query.Person_id,8,l_unitmd_array(i));
				   FETCH IGS_SC_DUP_C INTO l_DupId;

				   IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
					  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
					  l_debug_str := 'Inside assign_user_attributes. l_unitmd_array(i) is '||l_unitmd_array(i) ;
					  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				   END IF;

				   IF IGS_SC_DUP_C%NOTFOUND THEN
					IGS_SC_PER_ATTR_VALS_PKG.INSERT_ROW(
					    x_rowid => l_rowId,
					    x_person_id =>r_rec_query.Person_id,
					    x_user_attrib_id => 8,
					    x_user_attrib_value => l_unitmd_array(i)
					   );
				   END IF;
				   CLOSE IGS_SC_DUP_C;
				END LOOP;
			END IF;

			IF l_usrroles_array IS NOT NULL THEN
			/*First check if the user has multiple FND USer associated since cursor is already open-refetch it. */
			FETCH Fnd_User_Check_C INTO l_sec_User_Id,l_sec_User_Name,l_sec_cust_id, l_sec_emp_id;

                        --skpandey.Bug: 4583789
			IF Fnd_User_Check_C%FOUND THEN
			    OPEN get_person_num (r_rec_query.Person_Id);
			    FETCH get_person_num INTO l_person_num;
			    CLOSE get_person_num;
         		    FND_MESSAGE.SET_NAME('IGS','IGS_SC_MUL_FND_USER');
			    FND_MESSAGE.SET_TOKEN('PERS_NUM',l_person_num);
	        	    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
			ELSE

			/*Now iterate through UserRoles array to insert record into wf_local_user_roles */
			FOR i IN 1..l_usrroles_array.COUNT
			LOOP
				IF l_enddate_array(i) IS NULL THEN
					l_Inf_date := null ;  --remove the logic for infinite date.
				--l_Inf_date := igs_ge_date.igsdate(igs_ge_date.igschar('4712/12/31')) ; -- cannonical format is rrrr/mm/dd ;
				ELSE
					l_Inf_date :=igs_ge_date.igsdate((l_enddate_array(i) ));
				END IF;

				IF l_enddate_array(i) IS NOT NULL THEN
					l_start_date:=igs_ge_date.igsdate((l_startdate_array(i) ));
				END IF;

				-- IMP: FND_USER has cust_id , person_party_id and emp_id. If person is from HZ the cust = pp_id
				-- If person is from HR then cust is null and emp_id is not null
				-- User WF APIs to verify if the user has any roles. First Check if user already has this role associated
				-- get the role name, note its an igs role, so partion would be 0.

				OPEN GET_ROLE_NAME_C(l_usrroles_array(i));
				FETCH GET_ROLE_NAME_C INTO l_role_name;

				IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
				  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
				  l_debug_str := 'Inside assign_user_attributes. l_usrroles_array(i) is '||l_usrroles_array(i) ;
				  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
				END IF;

				CLOSE GET_ROLE_NAME_C;

				l_role_exists :=  'N';
				WF_DIRECTORY.GetUserRoles( l_user_name, l_roles) ;
				FOR s in 1..l_roles.count LOOP
				    IF l_roles(s) = l_role_name THEN
				       l_role_exists := 'Y' ;
				    END IF;
				END LOOP;


				IF  l_role_exists = 'Y' THEN
				/*Role is already assigned Update the end_date */


					IGS_SC_DATA_SEC_APIS_PKG.Update_Local_User_Role(
						 p_api_version         => 1.0,
						 p_user_name           => l_user_name,
						 p_role_name           => l_role_name,
						 p_user_orig_system    => l_wf_orig_ref,
						 p_user_orig_system_id => l_wf_orig_id,
						 p_role_orig_system    => 'IGS',
						 p_role_orig_system_id => l_usrroles_array(i),
						 p_start_date          => NVL(l_DupStartDate,TRUNC(SYSDATE)),
						 p_expiration_date     => l_Inf_date,
						 p_security_group_id   => 0,
						 x_return_status       => l_return_status,
						 x_return_message      => l_return_message);
					IF l_return_status IN ('E' , 'U') THEN

						FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

					END IF;

				ELSE

					IGS_SC_DATA_SEC_APIS_PKG.Insert_Local_User_Role(
						     p_api_version         => 1.0,
						     p_user_name           => l_user_name,
						     p_role_name           => l_role_name,
						     p_user_orig_system    => l_wf_orig_ref,
						     p_user_orig_system_id => l_wf_orig_id,
						     p_role_orig_system    => 'IGS',
						     p_role_orig_system_id => l_usrroles_array(i),
						     p_start_date          => trunc(SYSDATE), --sysdate, --l_startdate_array(i),
						     p_expiration_date     => l_Inf_date , --sysdate+2, --l_enddate_array(i),
						     p_security_group_id   => 0,
						     x_return_status       => l_return_status,
						     x_return_message      => l_return_message);

					IF l_return_status IN ('E' , 'U') THEN

						FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
						--RAISE NO_DATA_FOUND;
					END IF;
				END IF;  -- DUP_ROLES_CHK_C%FOUND


				--CLOSE DUP_ROLES_CHK_C;
			END LOOP;  -- l_usrroles_array
			END IF;  -- Fnd_User_Check_C%FOUND
		        END IF; -- l_usrroles_array
		  ELSE  -- Fnd_User_Check_C%FOUND
  		        OPEN get_person_num (r_rec_query.Person_Id);
		        FETCH get_person_num INTO l_person_num;
		        CLOSE get_person_num;
		        FND_MESSAGE.SET_NAME('IGS','IGS_SC_NO_FND_USER');
 		        FND_MESSAGE.SET_TOKEN('PERS_NUM',l_person_num);
	        	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
		  END IF; /*END of IF of FND_USER */
   		  CLOSE Fnd_User_Check_C;

		END LOOP; -- c_cur_query
	CLOSE c_cur_query;
	END LOOP;
	/* Debug */
	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
	  l_debug_str := 'Exiting assign_user_attributes.';
	  fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	END IF;

	--Enable Business Event before quiting Bulk Process
	IGS_PE_GEN_003.TURNOFF_TCA_BE (
             P_TURNOFF  => 'N'
        );
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    /* Debug */
	      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
		l_debug_str := 'NO_DATA_FOUND exception in assign_user_attributes.'||SQLERRM;
		fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	      END IF;
              --Enable Business Event before quiting Bulk Process
	      IGS_PE_GEN_003.TURNOFF_TCA_BE (
                  P_TURNOFF  => 'N'
              );
	    ROLLBACK;
	    retcode := 2;
	    errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

	    IF Fnd_User_Check_C%isopen then
		     CLOSE Fnd_User_Check_C;
            END IF;

	    IF GET_ROLE_NAME_C%isopen then
		     CLOSE GET_ROLE_NAME_C;
            END IF;
            IF IGS_SC_DUP_C%isopen then
		     CLOSE IGS_SC_DUP_C;
            END IF;

	WHEN OTHERS THEN
	    /* Debug */
	      IF fnd_log.test(fnd_log.level_statement,l_prog_label) THEN
		l_label := 'igs.plsql.igs_sc_bulk_assign.assign_user_attributes';
		l_debug_str := 'Exception in assign_user_attributes.'||SQLERRM;
		fnd_log.string_with_context( fnd_log.level_statement,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	      END IF;

	      --Enable Business Event before quiting Bulk Process
	      IGS_PE_GEN_003.TURNOFF_TCA_BE (
                  P_TURNOFF  => 'N'
              );
	    ROLLBACK;
	    retcode := 2;
	    errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

	    IF Fnd_User_Check_C%isopen then
		     CLOSE Fnd_User_Check_C;
            END IF;

	    IF GET_ROLE_NAME_C%isopen then
		     CLOSE GET_ROLE_NAME_C;
            END IF;
            IF IGS_SC_DUP_C%isopen then
		     CLOSE IGS_SC_DUP_C;
            END IF;

END Assign_User_attributes;

END IGS_SC_BULK_ASSIGN;


/
