--------------------------------------------------------
--  DDL for Package Body EDR_RULE_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_RULE_TEMP" AS
/* $Header: EDRTEMPB.pls 120.4.12000000.1 2007/01/18 05:55:41 appldev ship $ */
-- Bug 5167817 : start

  procedure getRuleDetails( ruleIdIn in number,
                             ruleTypeOut out nocopy varchar2,
                             ruleDescriptionOut out nocopy varchar2,
                             conditionIdsOut out nocopy ame_util.idList,
                             conditionDescriptionsOut out nocopy ame_util.longestStringList,
                             conditionHasLOVsOut out nocopy ame_util.charList,
                             approvalTypeNameOut out nocopy varchar2,
                             approvalTypeDescriptionOut out nocopy varchar2,
                             approvalDescriptionOut out nocopy varchar2) IS

  l_approvalTypeNames ame_util.stringList;
  l_approvalTypeDescriptions ame_util.stringList;
  l_approvalDescriptions ame_util.stringList;
  Begin
      ame_api3.getRuleDetails3( ruleIdIn => ruleIdIn,
                             ruleTypeOut => ruleTypeOut,
                             ruleDescriptionOut =>ruleDescriptionOut,
                             conditionIdsOut => conditionIdsOut,
                             conditionDescriptionsOut =>conditionDescriptionsOut,
                             conditionHasLOVsOut =>conditionHasLOVsOut,
                             actionTypeNamesOut =>  l_approvalTypeNames,
                             actionTypeDescriptionsOut =>  l_approvalTypeDescriptions,
                             actionDescriptionsOut => l_approvalDescriptions);

	if l_approvalTypeNames.count = 0 then
       approvalTypeNameOut := null;
       approvalTypeDescriptionOut := null;
       approvalDescriptionOut := null;
    else
       approvalTypeNameOut := l_approvalTypeNames(1);
       approvalTypeDescriptionOut := l_approvalTypeDescriptions(1);
       approvalDescriptionOut := l_approvalDescriptions(1);
    end if;

  END getRuleDetails;



-- Bug 5167817 : end
/* Obtain rule details for certain trasaction, and insert into temp tables */
PROCEDURE GET_DETAILS_TRANS ( p_trans_id  IN  VARCHAR2, p_input_var IN VARCHAR2
                          	) IS
  l_ssnid	NUMBER;
  ith		NUMBER;
  l_apps_id	NUMBER;
  l_apps_name	VARCHAR2(240);

  l_rule_ids	ame_util.idList;
  l_rule_id_t	ame_util.idList;
  l_date_0s	edr_rule_temp.edr_array_date;
  l_date_1s	edr_rule_temp.edr_array_date;

  l_rule_name	VARCHAR2(100);
  l_count_num	NUMBER;
  jth		NUMBER;
  l_deft_use	VARCHAR2(1);

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN

  select USERENV('SESSIONID') into l_ssnid from dual;

  -- 3171627 note: this procedure is obsolete due to new ConfigVar ERES key.
  select distinct application_id, application_name into l_apps_id, l_apps_name
  from ame_calling_apps
  where transaction_type_id = p_trans_id
  --Bug 4652277: Start
  --and end_Date is null;
  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End

  -- 3171627 end: restrict end_date for valid transaction with new description

  /* bulk collect use implicit cursor to pull out rule details from rule_usages */

  select distinct rule_id, start_date, end_date bulk collect
  into l_rule_ids, l_date_0s, l_date_1s   from ame_rule_usages
  --Bug 4652277: Start
  --where item_id = l_apps_id and (end_date is null OR end_date > sysdate);
  where item_id = l_apps_id and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End

  FOR ith IN 1..l_rule_ids.count LOOP

  BEGIN

    /* determine if the rule defines its own value for the variable */

    -- 3171627 note: deleted rule doesn't count for transVar default usage
    select count(*) into l_count_num from ame_rules where rule_id = l_rule_ids(ith)
    and description in ( select distinct rule_name from edr_amerule_input_var
    where ame_trans_name = l_apps_name and input_name = p_input_var )
    --Bug 4652277: Start
    -- and (end_date is null or end_date > sysdate);
    and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
    --Bug 4652277: End


    -- 3171627 end: shared rule may be valid in rule_usages but deleted for particular trans

    IF l_count_num > 0 THEN
      l_deft_use := 'N';
    ELSE
      l_deft_use := 'Y';
    END IF;
    -- Bug 5167817 : start
      getRuleDetails ( 	RULEIDIN => l_rule_ids(ith),
	RULETYPEOUT 	 	   => l_rule_type, RULEDESCRIPTIONOUT 	    => l_rule_desc,
	CONDITIONIDSOUT 	   => l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	   => l_cond_lov,  APPROVALTYPENAMEOUT 	    => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type, APPROVALDESCRIPTIONOUT   => l_appr_desc );
   -- Bug 5167817 : end
    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, p_trans_id, l_rule_ids(ith), l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, l_deft_use, l_date_0s(ith), l_date_1s(ith) );

    FOR jth IN 1..l_cond_ids.count LOOP
	insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id,
		condition_id, condition_desc ) values ( l_ssnid, p_trans_id, l_rule_ids(ith),
		l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      select distinct description into l_rule_name from ame_rules where rule_id = l_rule_ids(ith);

      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
		default_var, start_date, end_date)	values ( l_ssnid, p_trans_id, l_rule_ids(ith),
		l_rule_name, l_deft_use, l_date_0s(ith), l_date_1s(ith) );
/* insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id,
		condition_id, condition_desc )
		values ( l_ssnid, p_trans_id, l_rule_ids(ith), null, null ); */
  END;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_TRANS') );
  WHEN TOO_MANY_ROWS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_DETAILS_TRANS;



PROCEDURE GET_DETAILS_RULE ( p_trans_name  IN  VARCHAR2, p_rule_name IN VARCHAR2
                          	) IS
  l_ssnid	NUMBER;
  l_trans_id	VARCHAR2(100);
  l_apps_id	NUMBER;
  jth		NUMBER;
  l_rule_id	NUMBER;
  l_date_frm	DATE;
  l_date_end	DATE;

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN
  select USERENV('SESSIONID') into l_ssnid from dual;

  -- 3171627 note: this procedure is obsolete. ame_calling_apps.end_date cannot be in future.
  select transaction_type_id, application_id into l_trans_id, l_apps_id
  from ame_calling_apps
  where application_name = p_trans_name
  --Bug 4652277: Start
  --and end_Date is null;
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  -- 3171627 end: restrict end_date for valid transaction with new description

  -- 3171627 note: this procedure is obsolete due to new ConfigVar ERES key.
  select distinct rule_id into l_rule_id from ame_rules where description = p_rule_name
  and rule_id in ( select distinct rule_id from ame_rule_usages where item_id = l_apps_id )
  --Bug 4652277: Start
  --and (end_date is null or end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  -- 3171627 end: to avoid the deleted rule being recreated for the same transaction

  select start_date, end_date into l_date_frm, l_date_end
  from   ame_rule_usages
  where rule_id = l_rule_id
  --Bug 4652277: Start
  --and (end_date is null or end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  -- 3171627 end: the usage information will be the same for all transaction if the rule is shared

  BEGIN
     -- Bug 5167817 : start
      getRuleDetails ( 	RULEIDIN => l_rule_id,
	RULETYPEOUT 	 	=> l_rule_type, RULEDESCRIPTIONOUT 	 => l_rule_desc,
	CONDITIONIDSOUT 	=> l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	=> l_cond_lov,  APPROVALTYPENAMEOUT 	 => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type,
	APPROVALDESCRIPTIONOUT     => l_appr_desc );
    -- Bug 5167817 : end

    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, l_trans_id, l_rule_id, l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, 'N', l_date_frm, l_date_end );

    FOR jth IN 1..l_cond_ids.count LOOP
    insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
	condition_desc ) values ( l_ssnid, l_trans_id, l_rule_id, l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name, default_var,
		start_date, end_date) values
		( l_ssnid, l_trans_id, l_rule_id, p_rule_name, 'N', l_date_frm, l_date_end );
  END;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_FOUND') );
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_DETAILS_RULE;


PROCEDURE CLEAR_DETAILS_TRANS (	p_trans_id    IN VARCHAR2
				) IS
  l_ssnid	NUMBER;
BEGIN
  select USERENV('SESSIONID') into l_ssnid from dual;

  delete edr_rule_detail_temp where transaction_type_id = p_trans_id and SESSION_ID = l_ssnid;

  delete edr_rule_condition_temp where transaction_type_id = p_trans_id and SESSION_ID = l_ssnid;

END CLEAR_DETAILS_TRANS;


PROCEDURE CLEAR_DETAILS_RULE (	p_trans_id   	IN VARCHAR2,
				p_rule_id	IN VARCHAR2
				) IS
  l_ssnid	NUMBER;
  l_apps_id	NUMBER;
BEGIN
  select USERENV('SESSIONID') into l_ssnid from dual;

  delete edr_rule_detail_temp where transaction_type_id = p_trans_id
		and RULE_ID = p_rule_id and SESSION_ID = l_ssnid;

  delete edr_rule_condition_temp where transaction_type_id = p_trans_id
		and RULE_ID = p_rule_id and SESSION_ID = l_ssnid;

END CLEAR_DETAILS_RULE;


PROCEDURE GET_TVAR_RULE_DETAIL ( p_trans_var  IN  VARCHAR2 ) IS
  p_trans_id	VARCHAR2(100);
  p_input_var	VARCHAR2(100);
  l_ssnid	NUMBER;
  ith		NUMBER;
  l_apps_id	NUMBER;
  l_apps_name	VARCHAR2(240);

  l_rule_ids	ame_util.idList;
  l_rule_id_t	ame_util.idList;
  l_date_0s	edr_rule_temp.edr_array_date;
  l_date_1s	edr_rule_temp.edr_array_date;

  l_rule_name	VARCHAR2(100);
  l_count_num	NUMBER;
  jth		NUMBER;
  l_deft_use	VARCHAR2(1);

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN
  select substr( p_trans_var, 1, instr(p_trans_var,'-')-1 ) into p_trans_id from dual;
  select substr( p_trans_var, 1+instr(p_trans_var,'-') ) into p_input_var from dual;

  select USERENV('SESSIONID') into l_ssnid from dual;

  -- ame_calling_apps' end_date can only be null or outdated, no end_date>sysdate
  select distinct application_id, application_name into l_apps_id, l_apps_name
  from ame_calling_apps
  where transaction_type_id = p_trans_id
  --Bug 4652277: Start
  --AND end_date is null ;
  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End


  select distinct rule_id, start_date, end_date bulk collect
  into l_rule_ids, l_date_0s, l_date_1s   from ame_rule_usages
  where item_id = l_apps_id
  --Bug 4652277: Start
  --and (end_date is null OR end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  FOR ith IN 1..l_rule_ids.count LOOP

  BEGIN

    select count(*) into l_count_num from ame_rules where rule_id = l_rule_ids(ith)
    and description in ( select distinct rule_name from edr_amerule_input_var
      where ame_trans_name = l_apps_name and input_name = p_input_var );

    IF l_count_num > 0 THEN
      l_deft_use := 'N';
    ELSE
      l_deft_use := 'Y';
    END IF;

    -- Bug 5167817 : start

      getRuleDetails ( 	RULEIDIN => l_rule_ids(ith),
	RULETYPEOUT 	 	   => l_rule_type, RULEDESCRIPTIONOUT 	    => l_rule_desc,
	CONDITIONIDSOUT 	   => l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	   => l_cond_lov,  APPROVALTYPENAMEOUT 	    => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type, APPROVALDESCRIPTIONOUT   => l_appr_desc );
    -- Bug 5167817 : end
    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, p_trans_id, l_rule_ids(ith), l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, l_deft_use, l_date_0s(ith), l_date_1s(ith) );

    FOR jth IN 1..l_cond_ids.count LOOP
	insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
		condition_desc ) values
		( l_ssnid, p_trans_id, l_rule_ids(ith), l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      select distinct description into l_rule_name from ame_rules where rule_id = l_rule_ids(ith);
      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name, default_var,
		start_date, end_date)	values ( l_ssnid, p_trans_id, l_rule_ids(ith),
		l_rule_name, l_deft_use, l_date_0s(ith), l_date_1s(ith) );
/* insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
		condition_desc ) values ( l_ssnid, p_trans_id, l_rule_ids(ith), null, null ); */
  END;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_TRANS') );
  WHEN TOO_MANY_ROWS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_TVAR_RULE_DETAIL;


PROCEDURE GET_RVAR_RULE_DETAIL ( p_trans_rule  IN  VARCHAR2 ) IS
  p_trans_name	VARCHAR2(240);
  p_rule_id	NUMBER;
  p_rule_name	VARCHAR2(100);
  l_position	NUMBER;
  l_ssnid	NUMBER;
  l_trans_id	VARCHAR2(100);
  l_apps_id	NUMBER;
  jth		NUMBER;
  l_rule_id	NUMBER;
  l_date_frm	DATE;
  l_date_end	DATE;

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN
  select substr( p_trans_rule, 1, instr(p_trans_rule,'-')-1 ) into p_trans_name from dual;
  select instr(p_trans_rule, '-', 1+instr(p_trans_rule,'-')) into l_position from dual;

  --Bug : 3499311 : Start - Specified Number Format in call TO_NUMBER
  select TO_NUMBER( substr( p_trans_rule, 1+instr(p_trans_rule,'-'),
		l_position - instr(p_trans_rule,'-') - 1 ),'999999999999.999999'  )  into p_rule_id from dual;
  --Bug : 3499311 : End

  select USERENV('SESSIONID') into l_ssnid from dual;

  -- ame_calling_apps' end_date can only be null or outdated, transName/transId must be unique
  select transaction_type_id, application_id into l_trans_id, l_apps_id
  from ame_calling_apps
  where application_name = p_trans_name
  --Bug 4652277: Start
  --and end_date is null;
  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End


  l_rule_id := p_rule_id;

  -- 3171627 start: rule name can be changed in AME
  select distinct description into p_rule_name from ame_rules
  where  rule_id = l_rule_id
  --Bug 4652277: Start
  --and (end_date is null or end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  -- 3171627 end: add constraint on end_date

  select start_date, end_date into l_date_frm, l_date_end
  from   ame_rule_usages where rule_id = l_rule_id and item_id = l_apps_id
  --Bug 4652277: Start
  --and    (end_date is null OR end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  BEGIN
    -- Bug 5167817 : start
      getRuleDetails ( 	RULEIDIN => l_rule_id,
	RULETYPEOUT 	 	=> l_rule_type, RULEDESCRIPTIONOUT 	 => l_rule_desc,
	CONDITIONIDSOUT 	=> l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	=> l_cond_lov,  APPROVALTYPENAMEOUT 	 => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type,
	APPROVALDESCRIPTIONOUT     => l_appr_desc );
    -- Bug 5167817 : end
    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, l_trans_id, l_rule_id, l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, 'N', l_date_frm, l_date_end );

    FOR jth IN 1..l_cond_ids.count LOOP
    insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
	condition_desc ) values ( l_ssnid, l_trans_id, l_rule_id, l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
		default_var, start_date, end_date) values
		( l_ssnid, l_trans_id, l_rule_id, p_rule_name, 'N', l_date_frm, l_date_end );
  END;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_FOUND') );
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_RVAR_RULE_DETAIL;


/* 3016075: event key changed to instance id, use it to find input var */
PROCEDURE GET_TRANS_RULES ( p_trans_config_id  IN  VARCHAR2 ) IS
  p_trans_id	VARCHAR2(100);
  p_input_var	VARCHAR2(100);
  l_ssnid	NUMBER;
  ith		NUMBER;
  l_apps_id	NUMBER;
  l_apps_name	VARCHAR2(240);

  l_rule_ids	ame_util.idList;
  l_rule_id_t	ame_util.idList;
  l_date_0s	edr_rule_temp.edr_array_date;
  l_date_1s	edr_rule_temp.edr_array_date;

  l_rule_name	VARCHAR2(100);
  l_count_num	NUMBER;
  jth		NUMBER;
  l_deft_use	VARCHAR2(1);

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN

  --Bug : 3499311 : Start - Specified Number Format in call TO_NUMBER
  select distinct ame_trans_id, input_name into p_trans_id, p_input_var
  from edr_ametran_input_var where tran_config_id = TO_NUMBER(p_trans_config_id,'999999999999.999999');
  --Bug : 3499311 : End

  select USERENV('SESSIONID') into l_ssnid from dual;

  select distinct application_id, application_name into l_apps_id, l_apps_name
  from ame_calling_apps
  where transaction_type_id = p_trans_id
  --Bug 4652277: Start
  --and end_date is null;
  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End

  select distinct rule_id, start_date, end_date bulk collect
  into l_rule_ids, l_date_0s, l_date_1s   from ame_rule_usages
  where item_id = l_apps_id
  --Bug 4652277: Start
  --and (end_date is null OR end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  FOR ith IN 1..l_rule_ids.count LOOP

  BEGIN

    -- 3075902 note: trans/ruleName may be changed and names in ruleVar table become old
    -- no need for end_date constraint because it's validated above
    select count(*) into l_count_num from ame_rules where rule_id = l_rule_ids(ith)
    and description in ( select distinct rule_name from edr_amerule_input_var
      where ame_trans_name in (select distinct application_name from ame_calling_apps
        where transaction_type_id = p_trans_id) and input_name = p_input_var );
    -- 3075902 fix doesn't help here if ruleVar not touched but need correct default usage
    -- 3075902 end: change equal test on transName to IN operation based on transId

    IF l_count_num > 0 THEN
      l_deft_use := 'N';
    ELSE
      l_deft_use := 'Y';
    END IF;

    -- Bug 5167817 : start
      getRuleDetails ( 	RULEIDIN => l_rule_ids(ith),
	RULETYPEOUT 	 	   => l_rule_type, RULEDESCRIPTIONOUT 	    => l_rule_desc,
	CONDITIONIDSOUT 	   => l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	   => l_cond_lov,  APPROVALTYPENAMEOUT 	    => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type, APPROVALDESCRIPTIONOUT   => l_appr_desc );
    -- Bug 5167817 : end
    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, p_trans_id, l_rule_ids(ith), l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, l_deft_use, l_date_0s(ith), l_date_1s(ith) );

    FOR jth IN 1..l_cond_ids.count LOOP
	insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
		condition_desc ) values
		( l_ssnid, p_trans_id, l_rule_ids(ith), l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- 3171627 start: rule description can be changed in AME, rule_usages validation doesn't help here
      select distinct description into l_rule_name from ame_rules
      where  rule_id = l_rule_ids(ith) and (end_date is null or end_date > sysdate);
      -- 3171627 end: add end_date constraint to prevent multiple matches
      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name, default_var,
		start_date, end_date)	values ( l_ssnid, p_trans_id, l_rule_ids(ith),
		l_rule_name, l_deft_use, l_date_0s(ith), l_date_1s(ith) );
/* insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
		condition_desc ) values ( l_ssnid, p_trans_id, l_rule_ids(ith), null, null ); */
  END;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_TRANS') );
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_TRANS_RULES;


/* 3016075: event key changed to instance id, use it to find input var */
PROCEDURE GET_RULE_DETAIL ( p_rule_config_id  IN  VARCHAR2 ) IS
  p_trans_name	VARCHAR2(240);
  p_rule_id	NUMBER;
  p_rule_name	VARCHAR2(100);
  l_position	NUMBER;
  l_ssnid	NUMBER;
  l_trans_id	VARCHAR2(100);
  l_apps_id	NUMBER;
  jth		NUMBER;
  l_rule_id	NUMBER;
  l_date_frm	DATE;
  l_date_end	DATE;

  l_rule_type	VARCHAR2(100);
  l_rule_desc	VARCHAR2(100);
  l_cond_ids	ame_util.idList;
  l_cond_desc	ame_util.longestStringList;
  l_cond_lov	ame_util.charList;
  l_appr_name	VARCHAR2(100);
  l_appr_type	VARCHAR2(100);
  l_appr_desc	VARCHAR2(100);

BEGIN

  --Bug : 3499311 : Start - Specified Number Format in call TO_NUMBER
  select distinct ame_trans_name, rule_id into p_trans_name, p_rule_id
  from edr_amerule_input_var where rule_config_id = TO_NUMBER(p_rule_config_id,'999999999999.999999');
  --Bug : 3499311 : End

  select USERENV('SESSIONID') into l_ssnid from dual;

  -- 3075902 note: shall be ok below, b'coz ame_trans_name has been updated to the new name
  select transaction_type_id, application_id into l_trans_id, l_apps_id
  from ame_calling_apps
  where application_name = p_trans_name
  --Bug 4652277: Start
  --and end_date is null;
  and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
  --Bug 4652277: End

  l_rule_id := p_rule_id;
  -- 3171627 start: rule description can be changed in AME, rule_usages validation doesn't help here
  select distinct description into p_rule_name from ame_rules
  where  rule_id = l_rule_id
  --Bug 4652277: Start
  --and (end_date is null or end_date > sysdate);
  and (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  -- 3171627 end: add end_date constraint to prevent multiple matches

  select distinct start_date, end_date into l_date_frm, l_date_end
  from   ame_rule_usages where rule_id = l_rule_id and item_id = l_apps_id
  --Bug 4652277: Start
  --and    (end_date is null OR end_date > sysdate);
  and    (sysdate between START_DATE AND NVL(END_DATE, SYSDATE));
  --Bug 4652277: End

  BEGIN
    -- Bug 5167817 : start
      getRuleDetails ( 	RULEIDIN => l_rule_id,
	RULETYPEOUT 	 	=> l_rule_type, RULEDESCRIPTIONOUT 	 => l_rule_desc,
	CONDITIONIDSOUT 	=> l_cond_ids,  CONDITIONDESCRIPTIONSOUT => l_cond_desc,
	CONDITIONHASLOVSOUT 	=> l_cond_lov,  APPROVALTYPENAMEOUT 	 => l_appr_name,
	APPROVALTYPEDESCRIPTIONOUT => l_appr_type,
	APPROVALDESCRIPTIONOUT     => l_appr_desc );
    -- Bug 5167817 : end
    insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
	rule_type, appr_type, appr_desc, default_var, start_date, end_date ) values
	( l_ssnid, l_trans_id, l_rule_id, l_rule_desc, l_rule_type, l_appr_type,
	l_appr_desc, 'N', l_date_frm, l_date_end );

    FOR jth IN 1..l_cond_ids.count LOOP
    insert into edr_rule_condition_temp ( session_id, transaction_type_id, rule_id, condition_id,
	condition_desc ) values ( l_ssnid, l_trans_id, l_rule_id, l_cond_ids(jth), l_cond_desc(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      insert into edr_rule_detail_temp ( session_id, transaction_type_id, rule_id, rule_name,
		default_var, start_date, end_date) values
		( l_ssnid, l_trans_id, l_rule_id, p_rule_name, 'N', l_date_frm, l_date_end );
  END;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_FOUND') );
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.output, fnd_message.get_string('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END GET_RULE_DETAIL;


--This API is used to set the transaction details in the temp tables
--for the specified transaction ID and variable name.
PROCEDURE SET_TRANSACTION_DETAILS(P_TRANSACTION_ID IN VARCHAR2,
                                  P_VARIABLE_NAME  IN VARCHAR2)

IS

  L_SSNID	NUMBER;
  ITH		NUMBER;
  L_APPS_ID	NUMBER;
  L_APPS_NAME	VARCHAR2(240);

  L_RULE_IDS	AME_UTIL.IDLIST;
  L_RULE_ID_T	AME_UTIL.IDLIST;
  L_DATE_0S	EDR_RULE_TEMP.EDR_ARRAY_DATE;
  L_DATE_1S	EDR_RULE_TEMP.EDR_ARRAY_DATE;

  L_RULE_NAME	VARCHAR2(100);
  L_COUNT_NUM	NUMBER;
  jth		NUMBER;
  L_DEFT_USE	VARCHAR2(1);

  L_RULE_TYPE	VARCHAR2(100);
  L_RULE_DESC	VARCHAR2(100);
  L_COND_IDS	AME_UTIL.IDLIST;
  L_COND_DESC	AME_UTIL.LONGESTSTRINGLIST;
  L_COND_LOV	AME_UTIL.CHARLIST;
  L_APPR_NAME	VARCHAR2(100);
  L_APPR_TYPE	VARCHAR2(100);
  L_APPR_DESC	VARCHAR2(100);

BEGIN

  --Set the session ID value.
  SELECT USERENV('SESSIONID') INTO L_SSNID FROM DUAL;

  --Obtain the application ID and application Name from the AME tables.
  SELECT DISTINCT APPLICATION_ID, APPLICATION_NAME INTO L_APPS_ID, L_APPS_NAME
  FROM  AME_CALLING_APPS_VL
  WHERE TRANSACTION_TYPE_ID = P_TRANSACTION_ID
  AND   SYSDATE BETWEEN START_DATE AND NVL(END_DATE, SYSDATE);

  --Obtain all the applicable AME rules in one shot.
  SELECT DISTINCT RULE_ID, START_DATE, END_DATE BULK COLLECT
  INTO   L_RULE_IDS, L_DATE_0S, L_DATE_1S   FROM AME_RULE_USAGES
  WHERE  ITEM_ID = L_APPS_ID
  AND    SYSDATE <= NVL(END_DATE,SYSDATE);


  --Obtain and set the details of each rule associated with the transaction.
  FOR ith IN 1..L_RULE_IDS.COUNT LOOP

  BEGIN

    SELECT COUNT(*)
    INTO   L_COUNT_NUM
    FROM   AME_RULES_VL AME_RULES,
           EDR_AMERULE_INPUT_VAR RULE_VAR
    WHERE  AME_RULES.RULE_ID = L_RULE_IDS(ith)
    AND    AME_RULES.RULE_ID = RULE_VAR.RULE_ID
    AND    RULE_VAR.AME_TRANS_ID = P_TRANSACTION_ID
    AND    RULE_VAR.INPUT_NAME = P_VARIABLE_NAME
    AND    SYSDATE <= NVL(AME_RULES.END_DATE,SYSDATE);

    IF L_COUNT_NUM > 0 THEN
      L_DEFT_USE := 'N';
    ELSE
      L_DEFT_USE := 'Y';
    END IF;

    -- Bug 5167817 : start
    GETRULEDETAILS (RULEIDIN                   => L_RULE_IDS(ith),
	                     RULETYPEOUT                => L_RULE_TYPE,
			     RULEDESCRIPTIONOUT         => L_RULE_DESC,
	                     CONDITIONIDSOUT 	        => L_COND_IDS,
			     CONDITIONDESCRIPTIONSOUT   => L_COND_DESC,
	                     CONDITIONHASLOVSOUT        => L_COND_LOV,
			     APPROVALTYPENAMEOUT        => L_APPR_NAME,
	                     APPROVALTYPEDESCRIPTIONOUT => L_APPR_TYPE,
			     APPROVALDESCRIPTIONOUT     => L_APPR_DESC );
    -- Bug 5167817 : end
    INSERT INTO EDR_RULE_DETAIL_TEMP (SESSION_ID, TRANSACTION_TYPE_ID, RULE_ID, RULE_NAME,
	                              RULE_TYPE, APPR_TYPE, APPR_DESC, DEFAULT_VAR, START_DATE, END_DATE )
	   VALUES (L_SSNID, P_TRANSACTION_ID, L_RULE_IDS(ith), L_RULE_DESC, L_RULE_TYPE, L_APPR_TYPE,
	           L_APPR_DESC, L_DEFT_USE, L_DATE_0S(ith), L_DATE_1S(ith) );

    FOR jth IN 1..l_cond_ids.count LOOP
      INSERT INTO EDR_RULE_CONDITION_TEMP( SESSION_ID, TRANSACTION_TYPE_ID, RULE_ID, CONDITION_ID,CONDITION_DESC )
      VALUES ( L_SSNID, P_TRANSACTION_ID, L_RULE_IDS(ith), L_COND_IDS(jth), L_COND_DESC(jth) );
    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      SELECT DISTINCT DESCRIPTION
      INTO   L_RULE_NAME FROM AME_RULES_VL
      WHERE  RULE_ID = L_RULE_IDS(ith) AND (END_DATE IS NULL OR END_DATE > SYSDATE);

      INSERT INTO EDR_RULE_DETAIL_TEMP ( SESSION_ID, TRANSACTION_TYPE_ID, RULE_ID, RULE_NAME,
                                         DEFAULT_VAR, START_DATE, END_DATE)
      VALUES ( L_SSNID, P_TRANSACTION_ID, L_RULE_IDS(ith),L_RULE_NAME, L_DEFT_USE, L_DATE_0S(ith), L_DATE_1S(ith));
    END;
  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('EDR', 'EDR_PLS_RULE_NOT_TRANS') );
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END SET_TRANSACTION_DETAILS;


--This API is used to set the rule details in the temp tables
--for the specified transaction ID and rule ID.
PROCEDURE SET_RULE_DETAILS(P_TRANSACTION_ID IN VARCHAR2,
                           P_RULE_ID        IN VARCHAR2)
IS

  L_RULE_NAME	VARCHAR2(100);
  L_POSITION	NUMBER;
  L_SSNID	NUMBER;
  L_TRANS_ID	VARCHAR2(100);
  L_APPS_ID	NUMBER;
  JTH		NUMBER;
  L_RULE_ID	NUMBER;
  L_DATE_FRM	DATE;
  L_DATE_END	DATE;

  L_RULE_TYPE	VARCHAR2(100);
  L_RULE_DESC	VARCHAR2(100);
  L_COND_IDS	AME_UTIL.IDLIST;
  L_COND_DESC	AME_UTIL.LONGESTSTRINGLIST;
  L_COND_LOV	AME_UTIL.CHARLIST;
  L_APPR_NAME	VARCHAR2(100);
  L_APPR_TYPE	VARCHAR2(100);
  L_APPR_DESC	VARCHAR2(100);

BEGIN


  SELECT USERENV('SESSIONID') INTO L_SSNID FROM DUAL;

  SELECT APPLICATION_ID INTO L_APPS_ID
  FROM   AME_CALLING_APPS_VL
  WHERE  TRANSACTION_TYPE_ID = P_TRANSACTION_ID
  AND    SYSDATE BETWEEN START_DATE AND NVL(END_DATE, SYSDATE);


  SELECT DISTINCT DESCRIPTION
  INTO   L_RULE_NAME FROM AME_RULES_VL
  WHERE  RULE_ID = P_RULE_ID
  AND    SYSDATE <= NVL(END_DATE,SYSDATE);


  SELECT DISTINCT START_DATE, END_DATE INTO L_DATE_FRM, L_DATE_END
  FROM   AME_RULE_USAGES
  WHERE  RULE_ID = P_RULE_ID
  AND    ITEM_ID = L_APPS_ID
  AND    SYSDATE <= NVL(END_DATE,SYSDATE);


  BEGIN
    -- Bug 5167817 : start
    GETRULEDETAILS ( 	RULEIDIN                   => P_RULE_ID,
	                        RULETYPEOUT 	 	   => L_RULE_TYPE,
				RULEDESCRIPTIONOUT 	   => L_RULE_DESC,
	                        CONDITIONIDSOUT 	   => L_COND_IDS,
				CONDITIONDESCRIPTIONSOUT   => L_COND_DESC,
	                        CONDITIONHASLOVSOUT 	   => L_COND_LOV,
				APPROVALTYPENAMEOUT 	   => L_APPR_NAME,
	                        APPROVALTYPEDESCRIPTIONOUT => L_APPR_TYPE,
	                        APPROVALDESCRIPTIONOUT     => L_APPR_DESC );
    -- Bug 5167817 : end
    INSERT INTO EDR_RULE_DETAIL_TEMP (SESSION_ID, TRANSACTION_TYPE_ID, RULE_ID, RULE_NAME, RULE_TYPE, APPR_TYPE,
                                      APPR_DESC, DEFAULT_VAR, START_DATE, END_DATE )
    VALUES (L_SSNID, P_TRANSACTION_ID, P_RULE_ID, L_RULE_DESC, L_RULE_TYPE, L_APPR_TYPE,
	    L_APPR_DESC, 'N', L_DATE_FRM, L_DATE_END );

    FOR JTH IN 1..L_COND_IDS.COUNT LOOP
      INSERT INTO EDR_RULE_CONDITION_TEMP ( SESSION_ID, TRANSACTION_TYPE_ID,
                                            RULE_ID, CONDITION_ID,CONDITION_DESC)
      VALUES (L_SSNID, P_TRANSACTION_ID, P_RULE_ID, L_COND_IDS(JTH), L_COND_DESC(JTH) );

    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO EDR_RULE_DETAIL_TEMP (SESSION_ID, TRANSACTION_TYPE_ID, RULE_ID, RULE_NAME,
	 	                        DEFAULT_VAR, START_DATE, END_DATE)
      VALUES(L_SSNID, P_TRANSACTION_ID, P_RULE_ID, L_RULE_NAME, 'N', L_DATE_FRM, L_DATE_END );
  END;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('EDR', 'EDR_PLS_RULE_NOT_FOUND') );
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET_STRING('EDR', 'EDR_PLS_RULE_NOT_UNIQUE') );

END SET_RULE_DETAILS;


--This function returns the specified display date in String format.
FUNCTION DISPLAY_DATE(P_DATE IN DATE)

RETURN VARCHAR2

IS

L_DATE VARCHAR2(4000);

BEGIN

  EDR_STANDARD.DISPLAY_DATE(P_DATE_IN  => P_DATE,
                            P_DATE_OUT => L_DATE);
  RETURN L_DATE;

END DISPLAY_DATE;


PROCEDURE SYNC_RULE_TABLE(P_TRANSACTION_ID IN VARCHAR2)

IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  DELETE FROM EDR_AMERULE_INPUT_VAR RULE_VAR
  WHERE  RULE_VAR.AME_TRANS_ID = P_TRANSACTION_ID
  AND   RULE_VAR.RULE_ID NOT IN (SELECT AME_USAGES.RULE_ID
                                 FROM   AME_CALLING_APPS_VL AME_APPS,
                                     AME_RULE_USAGES AME_USAGES
                                 WHERE  AME_APPS.TRANSACTION_TYPE_ID = P_TRANSACTION_ID
                                 AND    AME_APPS.APPLICATION_ID = AME_USAGES.ITEM_ID
			         AND    SYSDATE <= NVL(AME_USAGES.END_DATE,SYSDATE));

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_RULE_TEMP');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','SYNC_RULE_TABLE');
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_RULE_TEMP.SYNC_RULE_TABLE',
                      FALSE
                     );
    END IF;
END SYNC_RULE_TABLE;


PROCEDURE CHECK_AND_SYNC_RULE_TABLE(P_TRANSACTION_ID IN VARCHAR2)

IS

L_COUNT NUMBER;

BEGIN

  SELECT COUNT(*) INTO L_COUNT FROM EDR_AMERULE_INPUT_VAR RULE_VAR
  WHERE  RULE_VAR.AME_TRANS_ID = P_TRANSACTION_ID
  AND   RULE_VAR.RULE_ID NOT IN (SELECT AME_USAGES.RULE_ID
                                 FROM   AME_CALLING_APPS_VL AME_APPS,
                                     AME_RULE_USAGES AME_USAGES
                                 WHERE  AME_APPS.TRANSACTION_TYPE_ID = P_TRANSACTION_ID
                                 AND    AME_APPS.APPLICATION_ID = AME_USAGES.ITEM_ID
			         AND    SYSDATE <= NVL(AME_USAGES.END_DATE,SYSDATE));

  IF L_COUNT > 0 THEN
    SYNC_RULE_TABLE(P_TRANSACTION_ID);
  END IF;

END CHECK_AND_SYNC_RULE_TABLE;

END EDR_RULE_TEMP;

/
