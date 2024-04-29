--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_PROPERTIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_PROPERTIES" AS
/* $Header: hxctcprops.pkb 120.14.12010000.11 2010/01/08 08:13:25 bbayragi ship $ */

c_alias_name CONSTANT varchar2(27) := 'TcWTcrdAliasesTimecardAlias';
c_alias_type CONSTANT varchar2(23) := 'TcWTcrdAliasesAliasType';
g_debug boolean := hr_utility.debug_enabled;

Type property_definition is Record
  (property_name varchar2(60)
  ,column_name   fnd_descr_flex_column_usages.application_column_name%type
  );

Type property_definition_tbl is table of property_definition index by binary_integer;

g_property_definitions property_definition_tbl;

Type context_definition is Record
  (context_code fnd_descr_flex_column_usages.descriptive_flex_context_code%type
  ,start_index  number
  );

Type context_definition_tbl is table of context_definition index by binary_integer;

g_context_definition context_definition_tbl;

Type period_list_cache is table of number index by binary_integer;

g_period_list_cache period_list_cache;

Type asg_id is table of number index by binary_integer;
Type asg_date is table of date index by binary_integer;
type asg_number is table of per_all_assignments_f.assignment_number%type index by binary_integer;
type asg_status is table of per_assignment_status_types.per_system_status%type index by binary_integer;

  function find_segment
          (p_context_code in fnd_descr_flex_column_usages.descriptive_flex_context_code%type
          ,p_segment_name in fnd_descr_flex_column_usages.end_user_column_name%type
          ) return varchar2 is

cursor c_segment_name
        (p_cc in fnd_descr_flex_column_usages.descriptive_flex_context_code%type
        ,p_sn in fnd_descr_flex_column_usages.end_user_column_name%type
        ) is
select application_column_name
  from fnd_descr_flex_column_usages
 where descriptive_flexfield_name = 'OTC PREFERENCES'
   and descriptive_flex_context_code = p_cc
   and end_user_column_name = p_sn
   and application_id = 809;

l_application_column_name fnd_columns.column_name%type;

Begin

open c_segment_name(p_context_code,p_segment_name);
fetch c_segment_name into l_application_column_name;
close c_segment_name;

return l_application_column_name;

End find_segment;

procedure cache_property_definitions
            (p_for_timecard in boolean) is

begin

if(g_property_definitions.count <1) then
--
-- We need to populate the references for the
-- preference contexts
--

 if(p_for_timecard) then
--
-- We need to populate the properties
--
  g_property_definitions(1).column_name := 'ATTRIBUTE1';
  g_property_definitions(1).property_name := 'TcWAlwNegTimeAllowNegativeEntries';
  g_property_definitions(2).column_name := 'ATTRIBUTE1';
  g_property_definitions(2).property_name := 'TcWAprvrDfltOvrdDefaultOverrideApprover';
  g_property_definitions(3).column_name := 'ATTRIBUTE1';
  g_property_definitions(3).property_name := 'TcWAprvrEnbleOvrdEnableApproverOverride';
  g_property_definitions(4).column_name := 'ATTRIBUTE1';
  g_property_definitions(4).property_name := 'TcWDateFormatsPeriodlist';
  g_property_definitions(5).column_name := 'ATTRIBUTE2';
  g_property_definitions(5).property_name := 'TcWDateFormatsTimecardDayHeaderFormat';
  g_property_definitions(6).column_name := 'ATTRIBUTE3';
  g_property_definitions(6).property_name := 'TcWDateFormatsTimecardDetailsHeaderFormat';
  g_property_definitions(7).column_name := 'ATTRIBUTE4';
  g_property_definitions(7).property_name := 'TcWDateFormatsTemplateTimeperiodPicklist';
  g_property_definitions(8).column_name := 'ATTRIBUTE1';
  g_property_definitions(8).property_name := 'TcWDeleteAllowTimecardDeleteAllowed';
  g_property_definitions(9).column_name := 'ATTRIBUTE1';
  g_property_definitions(9).property_name := 'TcWDiscnctdEntryDisconnectedEntry';
	--Property for enabling Defined Project List Export
  g_property_definitions(10).property_name := 'TcWDiscnctdEntryDefinedProjectListExport';
  g_property_definitions(10).column_name := 'ATTRIBUTE2';

  g_property_definitions(11).column_name := 'ATTRIBUTE1';
  g_property_definitions(11).property_name := 'TcWFlowProcessNameSelfServiceFlow';
  g_property_definitions(12).column_name := 'ATTRIBUTE1';
  g_property_definitions(12).property_name := 'TcWNumRcntTcrdsDisplayNumberTcards';
  g_property_definitions(13).column_name := 'ATTRIBUTE1';
  g_property_definitions(13).property_name := 'TcWRulesEvaluationRulesEvaluation';
  g_property_definitions(14).column_name := 'ATTRIBUTE1';
  g_property_definitions(14).property_name := 'TcWTcrdAliasesTimecardAlias1';
  g_property_definitions(15).column_name := 'ATTRIBUTE10';
  g_property_definitions(15).property_name := 'TcWTcrdAliasesTimecardAlias10';
  g_property_definitions(16).column_name := 'ATTRIBUTE2';
  g_property_definitions(16).property_name := 'TcWTcrdAliasesTimecardAlias2';
  g_property_definitions(17).column_name := 'ATTRIBUTE3';
  g_property_definitions(17).property_name := 'TcWTcrdAliasesTimecardAlias3';
  g_property_definitions(18).column_name := 'ATTRIBUTE4';
  g_property_definitions(18).property_name := 'TcWTcrdAliasesTimecardAlias4';
  g_property_definitions(19).column_name := 'ATTRIBUTE5';
  g_property_definitions(19).property_name := 'TcWTcrdAliasesTimecardAlias5';
  g_property_definitions(20).column_name := 'ATTRIBUTE6';
  g_property_definitions(20).property_name := 'TcWTcrdAliasesTimecardAlias6';
  g_property_definitions(21).column_name := 'ATTRIBUTE7';
  g_property_definitions(21).property_name := 'TcWTcrdAliasesTimecardAlias7';
  g_property_definitions(22).column_name := 'ATTRIBUTE8';
  g_property_definitions(22).property_name := 'TcWTcrdAliasesTimecardAlias8';
  g_property_definitions(23).column_name := 'ATTRIBUTE9';
  g_property_definitions(23).property_name := 'TcWTcrdAliasesTimecardAlias9';
  g_property_definitions(24).column_name := 'ATTRIBUTE1';
  g_property_definitions(24).property_name := 'TcWTcrdLayoutTimecardLayout';
  g_property_definitions(25).column_name := 'ATTRIBUTE2';
  g_property_definitions(25).property_name := 'TcWTcrdLayoutReviewLayout';
  g_property_definitions(26).column_name := 'ATTRIBUTE3';
  g_property_definitions(26).property_name := 'TcWTcrdLayoutConfirmationLayout';
  g_property_definitions(27).column_name := 'ATTRIBUTE4';
  g_property_definitions(27).property_name := 'TcWTcrdLayoutDetailLayout';
  g_property_definitions(28).column_name := 'ATTRIBUTE5';
  g_property_definitions(28).property_name := 'TcWTcrdLayoutExportLayout';
  g_property_definitions(29).column_name := 'ATTRIBUTE6';
  g_property_definitions(29).property_name := 'TcWTcrdLayoutAuditLayout';
  g_property_definitions(30).column_name := 'ATTRIBUTE7';
  g_property_definitions(30).property_name := 'TcWTcrdLayoutFragmentLayout';
  g_property_definitions(31).column_name := 'ATTRIBUTE8';
  g_property_definitions(31).property_name := 'TcWTcrdLayoutNotificationLayout';
  g_property_definitions(32).column_name := 'ATTRIBUTE1';
  g_property_definitions(32).property_name := 'TcWTcrdNumEmtyRwsTimecardEmptyRows';
  g_property_definitions(33).column_name := 'ATTRIBUTE1';
  g_property_definitions(33).property_name := 'TcWTcrdPeriodTimecardPeriods';
  g_property_definitions(34).column_name := 'ATTRIBUTE1';
  g_property_definitions(34).property_name := 'TcWTcrdStAlwEditsTcardStatusAllowEdits';
  g_property_definitions(35).column_name := 'ATTRIBUTE11';
  g_property_definitions(35).property_name := 'TcWTcrdStAlwEditsFutureNumber';
  g_property_definitions(36).column_name := 'ATTRIBUTE6';
  g_property_definitions(36).property_name := 'TcWTcrdStAlwEditsPastNumber';
  g_property_definitions(37).column_name := 'ATTRIBUTE1';
  g_property_definitions(37).property_name := 'TcWTcrdUomTimecardUnitOfMeasure';
  g_property_definitions(38).column_name := 'ATTRIBUTE2';
  g_property_definitions(38).property_name := 'TcWTcrdUomUnitOfMeasureFormat';

  g_property_definitions(39).column_name := 'ATTRIBUTE3';
  g_property_definitions(39).property_name := 'TcWTcrdUomDecimalPrecision';
  g_property_definitions(40).column_name := 'ATTRIBUTE4';
  g_property_definitions(40).property_name := 'TcWTcrdUomRoundingRule';

  g_property_definitions(41).column_name := 'ATTRIBUTE1';
  g_property_definitions(41).property_name := 'TcWTmpltApndOnTcrdAppendOnTcard';
  g_property_definitions(42).column_name := 'ATTRIBUTE1';
  g_property_definitions(42).property_name := 'TcWTmpltCreateCreateUserTemplates';
  g_property_definitions(43).column_name := 'ATTRIBUTE1';
  g_property_definitions(43).property_name := 'TcWTmpltDfltValAdminAdminDefaultTemplate';
  g_property_definitions(44).column_name := 'ATTRIBUTE1';
  g_property_definitions(44).property_name := 'TcWTmpltDfltValUsrUserDefaultTemplate';
  g_property_definitions(45).column_name := 'ATTRIBUTE1';
  g_property_definitions(45).property_name := 'TcWTmpltFcnltyTmpltFunctionality';
  g_property_definitions(46).column_name := 'ATTRIBUTE4';
  g_property_definitions(46).property_name := 'TcWTmpltFcnltyExcludeHoursCheckBox';
  g_property_definitions(47).column_name := 'ATTRIBUTE1';
  g_property_definitions(47).property_name := 'TcWTmpltSvOnTcrdSaveAsTemplate';
  g_property_definitions(48).column_name := 'ATTRIBUTE1';
  g_property_definitions(48).property_name := 'TsPerApprovalStyleTsApprovalStyle';
  g_property_definitions(49).column_name := 'ATTRIBUTE2';
  g_property_definitions(49).property_name := 'TsPerApprovalStyleTsOverrideApprovalStyle';




  --These properties are newly added for the Display Accrual balances work.
  g_property_definitions(50).column_name := 'ATTRIBUTE1';
  g_property_definitions(50).property_name := 'TcWDisplayAccBalDisplayBalances';

  g_property_definitions(51).column_name := 'ATTRIBUTE2';
  g_property_definitions(51).property_name := 'TcWDisplayAccBalElementSet';

  g_property_definitions(52).column_name := 'ATTRIBUTE3';
  g_property_definitions(52).property_name := 'TcWDisplayAccBalAccrualEvaluationDate';

  g_property_definitions(53).column_name := 'ATTRIBUTE4';
  g_property_definitions(53).property_name := 'TcWDisplayAccBalAccrualFunction';

  -- The properties have been newly added for the Public Templates Group.
  g_property_definitions(54).column_name := 'ATTRIBUTE1';
  g_property_definitions(54).property_name := 'TcWPublicTemplatePublicTemplateGroup1';
  g_property_definitions(55).column_name := 'ATTRIBUTE2';
  g_property_definitions(55).property_name := 'TcWPublicTemplatePublicTemplateGroup2';
  g_property_definitions(56).column_name := 'ATTRIBUTE3';
  g_property_definitions(56).property_name := 'TcWPublicTemplatePublicTemplateGroup3';
  g_property_definitions(57).column_name := 'ATTRIBUTE4';
  g_property_definitions(57).property_name := 'TcWPublicTemplatePublicTemplateGroup4';
  g_property_definitions(58).column_name := 'ATTRIBUTE5';
  g_property_definitions(58).property_name := 'TcWPublicTemplatePublicTemplateGroup5';
  g_property_definitions(59).column_name := 'ATTRIBUTE6';
  g_property_definitions(59).property_name := 'TcWPublicTemplatePublicTemplateGroup6';
  g_property_definitions(60).column_name := 'ATTRIBUTE7';
  g_property_definitions(60).property_name := 'TcWPublicTemplatePublicTemplateGroup7';
  g_property_definitions(61).column_name := 'ATTRIBUTE8';
  g_property_definitions(61).property_name := 'TcWPublicTemplatePublicTemplateGroup8';
  g_property_definitions(62).column_name := 'ATTRIBUTE9';
  g_property_definitions(62).property_name := 'TcWPublicTemplatePublicTemplateGroup9';
  g_property_definitions(63).column_name := 'ATTRIBUTE10';
  g_property_definitions(63).property_name := 'TcWPublicTemplatePublicTemplateGroup10';

  g_property_definitions(64).column_name := 'ATTRIBUTE1';
  g_property_definitions(64).property_name :=  'TsPerValidateOnSaveValidateOnSave';
-- This property has been add for DA Enhancement
  g_property_definitions(65).column_name := 'ATTRIBUTE2';--find_segment('TS_PER_VALIDATE_ON_SAVE','DELETE_BLANK_ROWS_ON_SAVE');--
  g_property_definitions(65).property_name :=  'TsPerDeleteBlankRowsOnSave';

-- This properties have been newly add for OTL ABS Integration 8778791
  g_property_definitions(66).column_name := 'ATTRIBUTE1';
  g_property_definitions(66).property_name := 'TcWTsAbsEnabled';
  g_property_definitions(67).column_name := 'ATTRIBUTE2';
  g_property_definitions(67).property_name := 'TcWTsAbsEdPrepAbs';
  g_property_definitions(68).column_name := 'ATTRIBUTE3';
  g_property_definitions(68).property_name := 'TcWTsAbsPendApprOut';
  g_property_definitions(69).column_name := 'ATTRIBUTE4';
  g_property_definitions(69).property_name := 'TcWTsAbsRertRules';
  g_property_definitions(70).column_name := 'ATTRIBUTE5';
  g_property_definitions(70).property_name := 'TcWTsAbsStatusComp';
  g_property_definitions(71).column_name := 'ATTRIBUTE6';
  g_property_definitions(71).property_name := 'TcWTsAbsHrValidations';
  g_property_definitions(72).column_name := 'ATTRIBUTE7';
  g_property_definitions(72).property_name := 'TcWTsAbsPendConfOut';
  g_property_definitions(73).column_name := 'ATTRIBUTE8';
  g_property_definitions(73).property_name := 'TcWTsAbsExcludeAbsTotals';

 else

  g_property_definitions(1).column_name := 'ATTRIBUTE1';
  g_property_definitions(1).property_name := 'TsPerApplicationSetTsApplicationSet';
  g_property_definitions(2).column_name := find_segment('TC_W_TCRD_ST_ALW_EDITS','MODIFY_APPROVED_TC_DETAILS');
  g_property_definitions(2).property_name :=  'TcWTcrdStAlwEditsModifyApprovedTcDetails';
  g_property_definitions(3).column_name := find_segment('TC_W_TCRD_ST_ALW_EDITS','MODIFY_APPROVED_TC_DAYS');
  g_property_definitions(3).property_name :=  'TcWTcrdStAlwEditsModifyApprovedTcDays';
  g_property_definitions(4).column_name := 'ATTRIBUTE1';
  g_property_definitions(4).property_name :=  'TsPerMmeTimeEntryRulesPteTimeEntryRule';
  g_property_definitions(5).column_name := 'ATTRIBUTE1';
  g_property_definitions(5).property_name :=  'TsPerElpRulesElpTimeEntryRuleGroup';
  g_property_definitions(6).column_name := 'ATTRIBUTE1';
  g_property_definitions(6).property_name :=  'TcWRulesEvaluationRulesEvaluation';
  g_property_definitions(7).column_name := 'ATTRIBUTE2';
  g_property_definitions(7).property_name :=  'TcWRulesEvaluationAppRulesEvaluation';
  g_property_definitions(8).column_name := 'ATTRIBUTE1';
  g_property_definitions(8).property_name :=  'TsPerAuditRequirementsAuditRequirements';
  g_property_definitions(9).column_name := 'ATTRIBUTE1';
  g_property_definitions(9).property_name :=  'TsPerValidateOnSaveValidateOnSave';
  g_property_definitions(10).column_name := 'ATTRIBUTE1';
  g_property_definitions(10).property_name := 'TsPerTimeCategoryIdentifyingDayElements';
  g_property_definitions(11).column_name := 'ATTRIBUTE2';
  g_property_definitions(11).property_name := 'TsPerNumberofDaysinAssignmentFrequency';


 end if; -- if for timecard
end if;

end cache_property_definitions;

procedure find_name_indices_for_context
           (p_context_code in     fnd_descr_flex_column_usages.descriptive_flex_context_code%type
           ,p_for_timecard in     boolean
           ,p_start_index     out nocopy number
           ,p_stop_index      out nocopy number
           ) is

l_index number;
l_found_context boolean := false;
l_bother_to_look boolean := false;

Begin

p_start_index := hr_api.g_number;

if(g_context_definition.count <1) then
  cache_property_definitions(p_for_timecard);
end if;

if(p_for_timecard) then

  if(p_context_code = 'TC_W_ALW_NEG_TIME') then
    p_start_index := 1;
    p_stop_index := 1;
  elsif(p_context_code = 'TC_W_APRVR_DFLT_OVRD') then
    p_start_index := 2;
    p_stop_index := 2;
  elsif(p_context_code = 'TC_W_APRVR_ENBLE_OVRD') then
    p_start_index := 3;
    p_stop_index := 3;
  elsif(p_context_code = 'TC_W_DATE_FORMATS') then
    p_start_index := 4;
    p_stop_index := 7;
  elsif(p_context_code = 'TC_W_DELETE_ALLOW') then
    p_start_index := 8;
    p_stop_index := 8;
  elsif(p_context_code = 'TC_W_DISCNCTD_ENTRY') then
    p_start_index := 9;
    p_stop_index := 10;
  elsif(p_context_code = 'TC_W_FLOW_PROCESS_NAME') then
    p_start_index := 11;
    p_stop_index := 11;
  elsif(p_context_code = 'TC_W_NUM_RCNT_TCRDS') then
    p_start_index := 12;
    p_stop_index := 12;
  elsif(p_context_code = 'TC_W_RULES_EVALUATION') then
    p_start_index := 13;
    p_stop_index := 13;
  elsif(p_context_code = 'TC_W_TCRD_ALIASES') then
    p_start_index := 14;
    p_stop_index := 23;
  elsif(p_context_code = 'TC_W_TCRD_LAYOUT') then
    p_start_index := 24;
    p_stop_index := 31;
  elsif(p_context_code = 'TC_W_TCRD_NUM_EMTY_RWS') then
    p_start_index := 32;
    p_stop_index := 32;
  elsif(p_context_code = 'TC_W_TCRD_PERIOD') then
    p_start_index := 33;
    p_stop_index := 33;
  elsif(p_context_code = 'TC_W_TCRD_ST_ALW_EDITS') then
    p_start_index := 34;
    p_stop_index := 36;
  elsif(p_context_code = 'TC_W_TCRD_UOM') then
    p_start_index := 37;
    p_stop_index := 40;
  elsif(p_context_code = 'TC_W_TMPLT_APND_ON_TCRD') then
    p_start_index := 41;
    p_stop_index := 41;
  elsif(p_context_code = 'TC_W_TMPLT_CREATE') then
    p_start_index := 42;
    p_stop_index := 42;
  elsif(p_context_code = 'TC_W_TMPLT_DFLT_VAL_ADMIN') then
    p_start_index := 43;
    p_stop_index := 43;
  elsif(p_context_code = 'TC_W_TMPLT_DFLT_VAL_USR') then
    p_start_index := 44;
    p_stop_index := 44;
  elsif(p_context_code = 'TC_W_TMPLT_FCNLTY') then
    p_start_index := 45;
    p_stop_index := 46;
  elsif(p_context_code = 'TC_W_TMPLT_SV_ON_TCRD') then
    p_start_index := 47;
    p_stop_index := 47;
  elsif(p_context_code = 'TS_PER_APPROVAL_STYLE') then
    p_start_index := 48;
    p_stop_index := 49;
  elsif(p_context_code = 'TC_W_DISPLAY_ACC_BAL') then  --This code has been newly added for PTO
    p_start_index := 50;
    p_stop_index := 53;
  elsif(p_context_code = 'TC_W_PUBLIC_TEMPLATE') then  --These indices have been newly added for the
    p_start_index := 54;			       --Public Templates Enhancement.
    p_stop_index := 63;
  elsif(p_context_code = 'TS_PER_VALIDATE_ON_SAVE') then--added for DA Enhancement
    p_start_index := 64;
    p_stop_index := 65;
  elsif(p_context_code = 'TS_ABS_PREFERENCES') then --Added for OTL-ABS Integration 8778791
    p_start_index := 66;
    p_stop_index := 73;
  end if;
else
  if(p_context_code = 'TS_PER_APPLICATION_SET') then
    p_start_index := 1;
    p_stop_index := 1;
  elsif(p_context_code = 'TC_W_TCRD_ST_ALW_EDITS') then
    p_start_index := 2;
    p_stop_index := 3;
  elsif(p_context_code = 'TS_PER_MME_TIME_ENTRY_RULES') then
    p_start_index := 4;
    p_stop_index := 4;
    elsif(p_context_code = 'TS_PER_ELP_RULES') then
    p_start_index := 5;
    p_stop_index := 5;
   elsif(p_context_code = 'TC_W_RULES_EVALUATION') then
    p_start_index := 6;
    p_stop_index := 7;
   elsif(p_context_code = 'TS_PER_AUDIT_REQUIREMENTS') then
    p_start_index := 8;
    p_stop_index := 8;
   elsif(p_context_code = 'TS_PER_VALIDATE_ON_SAVE') then
    p_start_index := 9;
    p_stop_index := 9;
   elsif(p_context_code = 'TS_PER_DAYS_TO_HOURS') then
    p_start_index := 10;
    p_stop_index := 11;
   end if;

end if; -- is this for timecard, or deposit wrapper

End find_name_indices_for_context;

function set_property_value
            (p_column in varchar2
            ,p_preference in HXC_PREFERENCE_EVALUATION.t_pref_table_row
            ) return varchar2 is

l_prop_value VARCHAR2(2000) :='';

begin

if (p_column = 'ATTRIBUTE1') then
  l_prop_value := p_preference.attribute1;
elsif (p_column = 'ATTRIBUTE2') then
  l_prop_value := p_preference.attribute2;
elsif (p_column = 'ATTRIBUTE3') then
  l_prop_value := p_preference.attribute3;
elsif (p_column = 'ATTRIBUTE4') then
  l_prop_value := p_preference.attribute4;
elsif (p_column = 'ATTRIBUTE5') then
  l_prop_value := p_preference.attribute5;
elsif (p_column = 'ATTRIBUTE6') then
  l_prop_value := p_preference.attribute6;
elsif (p_column = 'ATTRIBUTE7') then
  l_prop_value := p_preference.attribute7;
elsif (p_column = 'ATTRIBUTE8') then
  l_prop_value := p_preference.attribute8;
elsif (p_column = 'ATTRIBUTE9') then
  l_prop_value := p_preference.attribute9;
elsif (p_column = 'ATTRIBUTE10') then
  l_prop_value := p_preference.attribute10;
elsif (p_column = 'ATTRIBUTE11') then
  l_prop_value := p_preference.attribute11;
elsif (p_column = 'ATTRIBUTE12') then
  l_prop_value := p_preference.attribute12;
elsif (p_column = 'ATTRIBUTE13') then
  l_prop_value := p_preference.attribute13;
elsif (p_column = 'ATTRIBUTE14') then
  l_prop_value := p_preference.attribute14;
elsif (p_column = 'ATTRIBUTE15') then
  l_prop_value := p_preference.attribute15;
elsif (p_column = 'ATTRIBUTE16') then
  l_prop_value := p_preference.attribute16;
elsif (p_column = 'ATTRIBUTE17') then
  l_prop_value := p_preference.attribute17;
elsif (p_column = 'ATTRIBUTE18') then
  l_prop_value := p_preference.attribute18;
elsif (p_column = 'ATTRIBUTE19') then
  l_prop_value := p_preference.attribute19;
elsif (p_column = 'ATTRIBUTE20') then
  l_prop_value := p_preference.attribute20;
elsif (p_column = 'ATTRIBUTE21') then
  l_prop_value := p_preference.attribute21;
elsif (p_column = 'ATTRIBUTE22') then
  l_prop_value := p_preference.attribute22;
elsif (p_column = 'ATTRIBUTE23') then
  l_prop_value := p_preference.attribute23;
elsif (p_column = 'ATTRIBUTE24') then
  l_prop_value := p_preference.attribute24;
elsif (p_column = 'ATTRIBUTE25') then
  l_prop_value := p_preference.attribute25;
elsif (p_column = 'ATTRIBUTE26') then
  l_prop_value := p_preference.attribute26;
elsif (p_column = 'ATTRIBUTE27') then
  l_prop_value := p_preference.attribute27;
elsif (p_column = 'ATTRIBUTE28') then
  l_prop_value := p_preference.attribute28;
elsif (p_column = 'ATTRIBUTE29') then
  l_prop_value := p_preference.attribute29;
elsif (p_column = 'ATTRIBUTE30') then
  l_prop_value := p_preference.attribute30;
end if;

return l_prop_value;

end set_property_value;

  --
  -- 115.31
  -- Modified to include the assignment status type
  -- Also changed ordering to support fast decision
  -- in begin_approval to determine whether to 'approve
  -- on submit'
  procedure get_assignment_information
    (p_resource_id in            number,
     p_props       in out nocopy hxc_timecard_prop_table_type) is
    -- fix v115.18 bug no. 3491084
    -- New boolean
    l_asg_exists       BOOLEAN:= FALSE;

    cursor c_assignment_info(p_pid in number) is
      select asg.assignment_id,
             asg.assignment_number,
             asg.effective_start_date,
             asg.effective_end_date,
             nvl(ast.per_system_status,'NoSystemStatus') assignment_status_type
        from per_all_assignments_f asg,
             per_assignment_status_types ast
       where asg.person_id = p_pid
         and asg.assignment_type in ('E','C')
         and asg.primary_flag = 'Y'
         and asg.assignment_status_type_id = ast.assignment_status_type_id;

    l_asg_index     binary_integer := 0;

    l_assignment_id     asg_id;
    l_assignment_number asg_number;
    l_assignment_start  asg_date;
    l_assignment_end    asg_date;
    l_assignment_status asg_status;

    l_user_person_id    NUMBER;       -- Bug 6350637 --
    is_self_service     BOOLEAN;      -- Bug 6350637 --

  begin

    -- Bug 6350637 --
    -- Select the resource id who is depositing the timecard
    -- If the user is submitting timecard for self, then set
    -- flag is_self_service

    SELECT employee_id
      INTO l_user_person_id
      FROM fnd_user
     WHERE user_id = fnd_global.user_id;

    IF(l_user_person_id = p_resource_id)
    -- Bug 8676961
    -- Added the call to new profile here
     AND (NVL(FND_PROFILE.VALUE('HXC_ALLOW_TERM_SS_TIMECARD'),'N') = 'N')
    THEN
       is_self_service := TRUE;
    ELSE
       is_self_service := FALSE;
    END IF;
    -- Bug 6350637 --

    for asg_rec in c_assignment_info(p_resource_id) loop

    -- Bug 6350637 --
    -- If user is entering time for self, then make sure
    -- assignments being populated are all active assignments.

       IF (is_self_service)
       THEN
          IF ( asg_rec.assignment_status_type  IN ('ACTIVE_ASSIGN','ACTIVE_CWK'))
          THEN
              l_asg_index := l_asg_index + 1;
              l_assignment_id(l_asg_index) := asg_rec.assignment_id;
              l_assignment_number(l_asg_index) := asg_rec.assignment_number;
              l_assignment_start(l_asg_index) := asg_rec.effective_start_date;
              l_assignment_end(l_asg_index) := asg_rec.effective_end_date;
              l_assignment_status(l_asg_index) := to_char(asg_rec.assignment_status_type);
              -- Set the Boolean in case assignment information exists.
              l_asg_exists := TRUE;
          END IF;
       ELSE
          -- If user is timekeeper or linemanager, he might want
          -- non-active assignments also.
    	  l_asg_index := l_asg_index + 1;
    	  l_assignment_id(l_asg_index) := asg_rec.assignment_id;
          l_assignment_number(l_asg_index) := asg_rec.assignment_number;
      	  l_assignment_start(l_asg_index) := asg_rec.effective_start_date;
      	  l_assignment_end(l_asg_index) := asg_rec.effective_end_date;
      	  l_assignment_status(l_asg_index) := to_char(asg_rec.assignment_status_type);
      	  -- Set the Boolean in case assignment information exists.
      	  l_asg_exists := TRUE;
       END IF;
       -- Bug 6350637 --
    end loop;
    if not l_asg_exists then
      -- Add error
      --
      -- Initialize the message stack
      --
      fnd_msg_pub.initialize;
      fnd_message.set_name('HXC','HXC_NOT_VALID_ASSIGNMENT');
      fnd_msg_pub.add;
    else
      --
      -- Populate property structure
      --
      for i in 1..l_asg_index loop
        p_props.extend();
        p_props(p_props.last) := hxc_timecard_prop_type
          ('ResourceAssignmentId',
           null,
           l_assignment_start(i),
           l_assignment_end(i),
           l_assignment_id(i)
           );
      end loop;
      for i in 1..l_asg_index loop
        p_props.extend();
        p_props(p_props.last) := hxc_timecard_prop_type
          ('ResourceAssignmentNumber',
           null,
           l_assignment_start(i),
           l_assignment_end(i),
           l_assignment_number(i)
           );
      end loop;
      for i in 1..l_asg_index loop
        p_props.extend();
        p_props(p_props.last) := hxc_timecard_prop_type
          ('ResourceAssignmentStartDate',
           null,
           l_assignment_start(i),
           l_assignment_end(i),
           to_char(l_assignment_start(i),'YYYY/MM/DD')
           );
      end loop;
      for i in 1..l_asg_index loop
        p_props.extend();
        p_props(p_props.last) := hxc_timecard_prop_type
          ('ResourceAssignmentEndDate',
           null,
           l_assignment_start(i),
           l_assignment_end(i),
           to_char(l_assignment_end(i),'YYYY/MM/DD')
           );
      end loop;
      for i in 1..l_asg_index loop
        p_props.extend();
        p_props(p_props.last) := hxc_timecard_prop_type
          ('ResourceAssignmentStatusType',
           null,
           l_assignment_start(i),
           l_assignment_end(i),
           l_assignment_status(i)
           );
      end loop;
    end if;
  END get_assignment_information;


FUNCTION setup_mo_global_params ( p_resource_id in number) return number is
l_operating_unit_id NUMBER(15);
BEGIN

-- Derive the operating unit for the resource
-- ONLY CALL THIS FOR R12 WHEN API AVAILABLE
Begin
l_operating_unit_id :=
hr_organization_api.get_operating_unit
(p_effective_date                 => sysdate
,p_person_id                      => p_resource_id);

exception
when others then
   l_operating_unit_id := fnd_profile.value('ORG_ID');
end;

-- now set the operating unit context

-- ONLY CALL THIS FOR RELEASE 12

mo_global.init('HXC');

mo_global.set_policy_context ( 'S', l_operating_unit_id );

return l_operating_unit_id;

END setup_mo_global_params;


PROCEDURE get_org_id ( p_resource_id in            number
                      ,p_props       in out nocopy hxc_timecard_prop_table_type) is

l_operating_unit_id NUMBER(15);

BEGIN

if g_debug then
	hr_utility.trace('Entering get org id : resource id is '||to_char(p_resource_id));
end if;

 l_operating_unit_id := setup_mo_global_params(p_resource_id);

-- now add the operating unit to the timecard props record

 p_props.extend();

 p_props(p_props.last) := hxc_timecard_prop_type
                            ('ResourceOrgId'
                            ,null
                            ,hr_general.start_of_time
                            ,hr_general.end_of_time
                            ,l_operating_unit_id
                            );
if g_debug then
	hr_utility.trace('Leaving get_org id : org id is '||to_char(l_operating_unit_id));
end if;

END get_org_id;


procedure get_period_information
           (p_period_id in NUMBER
           ,p_start_date in date
           ,p_end_date in date
           ,p_props in out nocopy hxc_timecard_prop_table_type) is

cursor c_period_info
        (p_recurring_period_id in HXC_RECURRING_PERIODS.RECURRING_PERIOD_ID%TYPE) is
  select rp.period_type
        ,rp.duration_in_days
        ,substr(fnd_date.date_to_canonical(rp.start_date),1,50) start_date
   from  hxc_recurring_periods rp
  where  rp.recurring_period_id = p_recurring_period_id;

cursor c_number_per_year
         (p_type in per_time_periods.period_type%type) is
  select number_per_fiscal_year
    from per_time_period_types
   where period_type = p_type;

l_period_type PER_TIME_PERIOD_TYPES.period_type%TYPE;
l_duration_in_days HXC_RECURRING_PERIODS.DURATION_IN_DAYS%TYPE;
l_number_per_fiscal_year PER_TIME_PERIOD_TYPES.NUMBER_PER_FISCAL_YEAR%TYPE;
l_start_date VARCHAR2(50);

BEGIN

if((g_period_list_cache.exists(p_period_id))AND(p_props.exists(g_period_list_cache(p_period_id)))) then

  l_period_type := p_props(g_period_list_cache(p_period_id)).property_value;
  l_duration_in_days := p_props((g_period_list_cache(p_period_id)+1)).property_value;
  l_number_per_fiscal_year := p_props((g_period_list_cache(p_period_id)+2)).property_value;
  l_start_date := p_props((g_period_list_cache(p_period_id)+3)).property_value;

else

  open c_period_info(p_period_id);
  fetch c_period_info into l_period_type, l_duration_in_days, l_start_date;

  if(c_period_info%NOTFOUND) then
    close c_period_info;
    FND_MESSAGE.SET_NAME('HXC','HXC_NO_PERIOD_FOR_PREF');
    FND_MESSAGE.RAISE_ERROR;
  end if;
  close c_period_info;

  if(l_period_type is not null) then
     open c_number_per_year(l_period_type);
     fetch c_number_per_year into l_number_per_fiscal_year;
     close c_number_per_year;
  end if;

end if;

p_props.extend();
if(NOT g_period_list_cache.exists(p_period_id)) then
  g_period_list_cache(p_period_id) := p_props.last;
end if;

p_props(p_props.last) := hxc_timecard_prop_type
                           ('PeriodType'
                           ,null
                           ,p_start_date
                           ,p_end_date
                           ,l_period_type
                           );

p_props.extend();
p_props(p_props.last) := hxc_timecard_prop_type
                          ('PeriodDurationInDays'
                          ,null
                          ,p_start_date
                          ,p_end_date
                          ,l_duration_in_days
                          );

p_props.extend();
p_props(p_props.last) := hxc_timecard_prop_type
                          ('PeriodNumberPerFiscalYear'
                          ,null
                          ,p_start_date
                          ,p_end_date
                          ,l_number_per_fiscal_year
                          );

p_props.extend();
p_props(p_props.last) := hxc_timecard_prop_type
                          ('PeriodStartDate'
                          ,null
                          ,p_start_date
                          ,p_end_date
                          ,l_start_date
                          );

end get_period_information;

procedure get_personal_information
           (p_resource_id in            number
           ,p_props       in out nocopy hxc_timecard_prop_table_type) is

cursor c_full_name(p_pid in number) is
  select distinct full_name, effective_start_date, effective_end_date
    from per_all_people_f
   where person_id = p_pid;

l_index number := p_props.last;

BEGIN

for name_rec in c_full_name(p_resource_id) loop

 p_props.extend();

 p_props(p_props.last) := hxc_timecard_prop_type
                           ('ResourceIdentifierName'
                           ,null
                           ,name_rec.effective_start_date
                           ,name_rec.effective_end_date
                           ,name_rec.full_name
                           );
end loop;

END get_personal_information;

function get_alias_reference_object
           (p_alias_definition_id in hxc_alias_definitions.alias_definition_id%type)
         RETURN varchar2 is

cursor c_ref_obj
        (p_id in hxc_alias_definitions.alias_definition_id%type) is
  select ty.reference_object
    from hxc_alias_types ty, hxc_alias_definitions ad
   where ad.alias_definition_id = p_id
     and ty.alias_type_id = ad.alias_type_id;

l_reference_object hxc_alias_types.reference_object%type;

begin

open c_ref_obj(p_alias_definition_id);
fetch c_ref_obj into l_reference_object;
if(c_ref_obj%notfound) then
  close c_ref_obj;
  fnd_message.set_name('HXC','HXC_NO_ALIAS_TYPE');
  fnd_message.set_token('DEF_ID',to_char(p_alias_definition_id));
  fnd_message.raise_error;
else
  close c_ref_obj;
end if;

return l_reference_object;

end get_alias_reference_object;

procedure include_alias_type
           (p_alias_definition_id   in            number
           ,p_alias_property_number in            varchar2
           ,p_date_from             in            date
           ,p_date_to               in            date
           ,p_props                 in out nocopy hxc_timecard_prop_table_type
           ) is

l_alias_reference hxc_alias_types.reference_object%type;
begin

l_alias_reference := get_alias_reference_object(p_alias_definition_id);
if(l_alias_reference is not null) then

  p_props.extend();
  p_props(p_props.last) := hxc_timecard_prop_type
                             (c_alias_type||p_alias_property_number
                             ,null
                             ,p_date_from
                             ,p_date_to
                             ,l_alias_reference
                             );

end if;

end include_alias_type;

function earliest_date
           (p_resource_id in NUMBER) return date is

l_date date;

begin

select min(effective_start_date)
  into l_date
  from per_all_assignments_f
 where person_id = p_resource_id;

return l_date;

end;
--
-- Overloaded for the middle tier
--
procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            VARCHAR2
           ,p_timecard_stop_time  in            VARCHAR2
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           ) is

l_messages hxc_message_table_type;
l_timecard_start_time date := sysdate;
l_timecard_stop_time  date := sysdate;

Begin

l_messages := hxc_message_table_type();
if(length(p_timecard_start_time)>5) then
  l_timecard_start_time := fnd_date.canonical_to_date(p_timecard_start_time);
  l_timecard_stop_time := fnd_date.canonical_to_date(p_timecard_stop_time);
end if;


get_preference_properties
 (p_validate             => p_validate
 ,p_resource_id          => p_resource_id
 ,p_timecard_start_time  => l_timecard_start_time
 ,p_timecard_stop_time   => l_timecard_stop_time
 ,p_for_timecard         => true
 ,p_messages             => l_messages
 ,p_property_table       => p_property_table
 );

hxc_timecard_message_helper.processErrors(l_messages);

End get_preference_properties;

--
-- Overloaded for the middle tier
--
procedure get_preference_properties
           (p_validate            in            VARCHAR2,
            p_resource_id         in            NUMBER,
            p_timecard_start_time in            VARCHAR2,
            p_timecard_stop_time  in            VARCHAR2,
            p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE,
            p_messages               out nocopy HXC_MESSAGE_TABLE_TYPE
            ) is

l_timecard_start_time date;
l_timecard_stop_time  date;

Begin
   if(p_messages is null) then
      p_messages := hxc_message_table_type();
   end if;

   if(length(p_timecard_start_time)>5) then
      l_timecard_start_time := fnd_date.canonical_to_date(p_timecard_start_time);
      l_timecard_stop_time := fnd_date.canonical_to_date(p_timecard_stop_time);
   else
      l_timecard_start_time := sysdate;
      l_timecard_stop_time := sysdate;
   end if;

   get_preference_properties
      (p_validate             => p_validate,
       p_resource_id          => p_resource_id,
       p_timecard_start_time  => l_timecard_start_time,
       p_timecard_stop_time   => l_timecard_stop_time,
       p_for_timecard         => true,
       p_messages             => p_messages,
       p_property_table       => p_property_table
       );

End get_preference_properties;

procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            date
           ,p_timecard_stop_time  in            date
           ,p_for_timecard        in            BOOLEAN
           ,p_messages            in out nocopy hxc_message_table_type
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           ) is
Begin

  get_preference_properties
   (p_validate              =>	p_validate
   ,p_resource_id           =>	p_resource_id
   ,p_timecard_start_time   =>  p_timecard_start_time
   ,p_timecard_stop_time    =>	p_timecard_stop_time
   ,p_for_timecard          =>  p_for_timecard
   ,p_timecard_bb_id 	    =>  null
   ,p_timecard_bb_ovn	    =>  null
   ,p_messages              =>	p_messages
   ,p_property_table        =>	p_property_table
   );

end get_preference_properties;

procedure get_preference_properties
           (p_validate            in            VARCHAR2
           ,p_resource_id         in            NUMBER
           ,p_timecard_start_time in            date
           ,p_timecard_stop_time  in            date
           ,p_for_timecard        in            BOOLEAN
           ,p_timecard_bb_id      in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_bb_ovn     in            hxc_time_building_blocks.object_version_number%type
           ,p_messages            in out nocopy hxc_message_table_type
           ,p_property_table         out nocopy HXC_TIMECARD_PROP_TABLE_TYPE
           ) is

l_pref_table HXC_PREFERENCE_EVALUATION.T_PREF_TABLE;

l_prop_table t_prop_table;
l_property_value hxc_pref_hierarchies.attribute1%type;
l_property_name varchar2(60);
l_property_column fnd_descr_flex_column_usages.application_column_name%type;
l_index NUMBER;
l_prop_index NUMBER :=1;
l_date DATE;

l_name_start_index number;
l_name_stop_index number;
l_name_index number;
l_name varchar2(60);

l_proc VARCHAR2(30) := 'get_preference_properties';

l_recurring_period_id NUMBER;

begin
g_property_definitions.delete;
cache_property_definitions(p_for_timecard);

g_period_list_cache.delete;

if(p_messages is null) then
  p_messages := hxc_message_table_type();
end if;

p_property_table := hxc_timecard_prop_table_type();

--  l_date := earliest_date(p_resource_id);

   l_date := to_date('1990/01/01','YYYY/MM/DD');

-- Start by getting all the preferences for the resource
-- over all time!

   HXC_PREFERENCE_EVALUATION.RESOURCE_PREFERENCES
     (p_resource_id => p_resource_id
     ,p_start_evaluation_date => l_date
     ,p_end_evaluation_date => to_date('4712/12/31','YYYY/MM/DD')
     ,p_pref_table => l_pref_table
     );

--
-- Call Set Up validation, to ensure these preferences
-- are valid.  We pass null for the timecard id and ovn
-- because at the stage this call is made we don't know
-- these values.  Not sure why the validation needs
-- operation, but pass submit in anyway, this value
-- isn't used in that package.
--

if(p_validate = hxc_timecard.c_yes) then
   hxc_setup_validation_pkg.execute_otc_validation
    (p_operation         => hxc_timecard.c_submit
    ,p_resource_id       => p_resource_id
    ,p_timecard_bb_id    => p_timecard_bb_id
    ,p_timecard_bb_ovn   => p_timecard_bb_ovn
    ,p_start_date        => p_timecard_start_time
    ,p_end_date          => p_timecard_stop_time
    ,p_master_pref_table => l_pref_table
    ,p_messages          => p_messages
    );
end if;

--
-- Record the earliest date we're using to obtain
-- the preferences, this is currently used by
-- the period list generation code.
--
     p_property_table.extend();
     l_prop_index := p_property_table.last;
     p_property_table(l_prop_index) := hxc_timecard_prop_type
                                        ('ResourceEarliestAssignmentDate'
                                        ,null
                                        ,to_date('0001/01/01','YYYY/MM/DD')
                                        ,to_date('4712/12/31','YYYY/MM/DD')
                                        ,to_char(l_date,'YYYY/MM/DD')
                                        );

-- Next for each of the records in the preference table
-- load the properties table

l_index := l_pref_table.first;

LOOP

  EXIT WHEN NOT l_pref_table.exists(l_index);

   find_name_indices_for_context
     (p_context_code => l_pref_table(l_index).preference_code
     ,p_for_timecard => p_for_timecard
     ,p_start_index => l_name_start_index
     ,p_stop_index => l_name_stop_index
     );

   if(l_name_start_index <> hr_api.g_number) then

   For l_name_index in l_name_start_index..l_name_stop_index Loop

     l_property_name := g_property_definitions(l_name_index).property_name;
     l_property_column := g_property_definitions(l_name_index).column_name;

     --
     -- We use last here, because inside the loop, we call the
     -- period information function, which can add additional
     -- records to the prop table, which is safer than just
     -- adding 1.
     --

     l_property_value := set_property_value(l_property_column, l_pref_table(l_index));

     if(l_property_value is not null) then

       p_property_table.extend();
       l_prop_index := p_property_table.last;

       if(l_property_name = 'TcWTcrdStAlwEditsPastNumber') then
         l_property_name := 'EffectiveTimecardPeriodPastDate';
         l_property_value := to_char((sysdate-to_number(l_property_value)),'YYYY/MM/DD');
       end if;
       if(l_property_name = 'TcWTcrdStAlwEditsFutureNumber') then
         l_property_name := 'EffectiveTimecardPeriodFutureDate';
         l_property_value := to_char((sysdate+to_number(l_property_value)),'YYYY/MM/DD');
       end if;

       p_property_table(l_prop_index) := hxc_timecard_prop_type
                                           (l_property_name
                                           ,null
                                           ,l_pref_table(l_index).start_date
                                           ,l_pref_table(l_index).end_date
                                           ,l_property_value
                                           );

       if(l_property_name = 'TcWTcrdPeriodTimecardPeriods') then

           get_period_information
            (p_period_id => l_property_value
            ,p_start_date => l_pref_table(l_index).start_date
            ,p_end_date => l_pref_table(l_index).end_date
            ,p_props=> p_property_table);

       end if;

       if(substr(l_property_name,1,27) = c_alias_name)then

         include_alias_type
           (to_number(l_property_value)
           ,substr(l_property_name,28)
           ,l_pref_table(l_index).start_date
           ,l_pref_table(l_index).end_date
           ,p_property_table
           );
       end if;

    end if; -- does the property have a value?

   END LOOP;

   end if; -- did we find the index we wanted.

  l_index := l_pref_table.next(l_index);

END LOOP;


get_personal_information
  (p_resource_id
  ,p_property_table
  );

get_org_id ( p_resource_id, p_property_table );
-- 115.31
-- Made this the last call as the order of the
-- properties now matters to hxc_timecard_approval
get_assignment_information
  (p_resource_id
  ,p_property_table
  );

end get_preference_properties;

Function find_property_value
           (p_props      in HXC_TIMECARD_PROP_TABLE_TYPE
           ,p_name       in varchar2
           ,p_code       in varchar2
           ,p_segment    in number
           ,p_start_date in date
           ,p_stop_date  in date
           ) return varchar2 is

l_eval_date      date;
l_property_value hxc_pref_hierarchies.attribute1%type := null;

Begin

l_property_value := find_property_value(p_props,p_name,p_code,p_segment,p_start_date);

if(l_property_value is null) then
  l_property_value := find_property_value(p_props,p_name,p_code,p_segment,p_stop_date);
  if(l_property_value is null) then
  --
  -- Loop across the days looking for a value
  --
     l_eval_date := p_start_date + 1;
     Loop
       Exit when ((l_property_value is not null) OR (trunc(p_stop_date)-trunc(l_eval_date)<1));
       l_property_value := find_property_value(p_props,p_name,p_code,p_segment,l_eval_date);
       l_eval_date := l_eval_date + 1;
     End Loop;
  end if;
end if;

return l_property_value;

End find_property_value;

Function find_property_value
          (p_props   in HXC_TIMECARD_PROP_TABLE_TYPE
          ,p_name    in varchar2
          ,p_code    in hxc_pref_hierarchies.code%type
          ,p_segment in number
          ,p_date    in date
          ) return varchar2 is

cursor c_prop_name
        (p_code    in varchar2
        ,p_segment in number
        ) is
select replace(initcap(replace(descriptive_flex_context_code,'_',' ')),' ')
      ||replace(initcap(replace(end_user_column_name,'_',' ')),' ') property_name
 from fnd_descr_flex_column_usages
 where descriptive_flexfield_name = 'OTC PREFERENCES'
   and descriptive_flex_context_code = p_code
   and application_column_name = 'ATTRIBUTE'||to_char(p_segment)
   and application_id = 809;

l_property_value  hxc_pref_hierarchies.attribute1%type;
l_property_name   varchar2(240) := null;
l_index           number;
l_date_difference number;
l_close_value     hxc_pref_hierarchies.attribute1%type;

Begin

  if(p_name is null) then
    open c_prop_name(p_code,p_segment);
    fetch c_prop_name into l_property_name;

    if(c_prop_name%notfound) then
      close c_prop_name;
      fnd_message.set_name('HXC','HXC_UNKNOWN_PROP');
      fnd_message.raise_error;
    else
      close c_prop_name;
    end if;
  else
    l_property_name := p_name;
  end if;

  l_index := p_props.first;
  Loop
    Exit when ((not p_props.exists(l_index)) or (l_property_value is not null));

    if (p_props(l_index).property_name = l_property_name) then
     if(p_date between p_props(l_index).date_from and p_props(l_index).date_to) then
       l_property_value := p_props(l_index).property_value;
     else
       if(l_property_value is null) then
         if(
            (abs(p_date - p_props(l_index).date_from) < l_date_difference)
           OR
            (l_date_difference = hr_api.g_number)
           ) then
            l_close_value := p_props(l_index).property_value;
            l_date_difference := abs(p_date - p_props(l_index).date_from);
         end if;
       end if;
     end if;
    end if;
    l_index := p_props.next(l_index);
  End Loop;

  if(l_property_value is null) then

    l_property_value := l_close_value;

  end if;

  return l_property_value;

End find_property_value;

END hxc_timecard_properties;


/
