--------------------------------------------------------
--  DDL for Package Body AS_VALIDATE_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_VALIDATE_SETUP" as
/* $Header: asxsetvb.pls 120.9 2006/09/01 09:51:05 mohali noship $ */

PROCEDURE Write_Log(p_module in VARCHAR2, msg in VARCHAR2)
IS
    l_length        NUMBER;
    l_start         NUMBER := 1;
    l_substring     VARCHAR2(77);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
BEGIN
    IF l_debug THEN
       	AS_UTILITY_PVT.Debug_Message(p_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, msg);
    ELSE
	    -- chop the message to 77 long
	    l_length := length(msg);
	    WHILE l_length > 77 LOOP
		l_substring := substr(msg, l_start, 77);
		FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
		l_start := l_start + 77;
		l_length := l_length - 77;
	    END LOOP;
	    l_substring := substr(msg, l_start);
	    FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
    END IF;
EXCEPTION
    WHEN others THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in Write_Log');
        FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));
END Write_Log;

FUNCTION Get_Profile_Site_Value(
    p_NAME      VARCHAR2) RETURN VARCHAR2
IS
    Cursor c_prof_value IS
    SELECT v.PROFILE_OPTION_VALUE
    FROM FND_PROFILE_OPTIONS b, FND_PROFILE_OPTION_VALUES v
    WHERE b.APPLICATION_ID=279
      AND b.PROFILE_OPTION_NAME=p_name
      AND v.PROFILE_OPTION_ID=b.PROFILE_OPTION_ID
      AND v.level_id=10001;
    l_value VARCHAR2(240);
BEGIN
    OPEN c_prof_value;
    FETCH c_prof_value INTO l_value;
    CLOSE c_prof_value;
    RETURN l_value;
END Get_Profile_Site_Value;

FUNCTION Get_Profile_JTF_Site_Value(
    p_NAME      VARCHAR2) RETURN VARCHAR2
IS
    Cursor c_prof_value IS
    SELECT v.PROFILE_OPTION_VALUE
    FROM FND_PROFILE_OPTIONS b, FND_PROFILE_OPTION_VALUES v
    WHERE b.APPLICATION_ID=690
      AND b.PROFILE_OPTION_NAME=p_name
      AND v.PROFILE_OPTION_ID=b.PROFILE_OPTION_ID
      AND v.level_id=10001;
    l_value VARCHAR2(240);
BEGIN
    OPEN c_prof_value;
    FETCH c_prof_value INTO l_value;
    CLOSE c_prof_value;
    RETURN l_value;
END Get_Profile_JTF_Site_Value;

PROCEDURE Validate_Setup(
    ERRBUF      out NOCOPY VARCHAR2,
    RETCODE     out NOCOPY VARCHAR2,
    p_upgrade   IN VARCHAR2)
IS
    CURSOR C_Get_Stage_Info (c_SALES_STAGE_ID NUMBER) IS
      SELECT  nvl(min_win_probability, 0), nvl(max_win_probability, 100)
      FROM  as_sales_stages_all_b
      WHERE sales_stage_id = c_Sales_Stage_Id;

    cursor Get_FileDebugDir IS
      select rtrim(ltrim(value)) from v$parameter
      where upper(name) = 'UTL_FILE_DIR';

    -- SOLIN, 06/12/2001
    CURSOR C_GET_MISSING_OPP_CURR IS
        SELECT OPP.CURRENCY_CODE
        FROM AS_LEADS_ALL OPP
        WHERE OPP.CURRENCY_CODE NOT IN (
            SELECT LOOKUP.LOOKUP_CODE
            FROM FND_LOOKUP_VALUES LOOKUP
            WHERE LOOKUP.LOOKUP_TYPE = 'REPORTING_CURRENCY'
            AND LOOKUP.ENABLED_FLAG = 'Y');
    -- end SOLIN, 06/12/2001

    l_write_dir          VARCHAR2(2000);

    l_sales_stage_id    NUMBER := to_number(GET_PROFILE_SITE_VALUE('AS_OPP_SALES_STAGE'));
    l_win_prob      NUMBER := to_number(GET_PROFILE_SITE_VALUE('AS_OPP_WIN_PROBABILITY'));
    l_prob_ss_link  VARCHAR2(10) :=
            NVL(Get_Profile_Site_Value('AS_OPPTY_PROB_SS_LINK'), 'WARNING');

    l_cust_access   VARCHAR2(240) := GET_PROFILE_SITE_VALUE('AS_CUST_ACCESS');
    l_opp_access    VARCHAR2(240) := GET_PROFILE_SITE_VALUE('AS_OPP_ACCESS');
    l_lead_access   VARCHAR2(240) := GET_PROFILE_SITE_VALUE('AS_LEAD_ACCESS');

    l_mgr_update    VARCHAR2(240) := Get_Profile_Site_Value('AS_MGR_UPDATE');
    l_admin_update  VARCHAR2(240) := Get_Profile_Site_Value('AS_ADMIN_UPDATE');

    l_opp_status    VARCHAR2(240) := Get_Profile_Site_Value('AS_OPP_STATUS');
    l_opp_closing   VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_OPP_CLOSING_DATE_DAYS');

    l_fst_credit_type   VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_FORECAST_CREDIT_TYPE_ID');
    l_cn_credit_type    VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_COMPENSATION_CREDIT_TYPE_ID');
    l_opp_channel   VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_OPP_SALES_CHANNEL');
    l_mc_roll_days  VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_MC_MAX_ROLL_DAYS');
    l_mc_mapping_type   VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_MC_DATE_MAPPING_TYPE');
    l_mc_conv_type  VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_MC_DAILY_CONVERSION_TYPE');
    l_fst_calendar  VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_FORECAST_CALENDAR');
    l_prefer_currency   VARCHAR2(240) :=
                Get_Profile_Site_Value('AS_PREFERRED_CURRENCY');
    l_default_currency  VARCHAR2(240) :=
                Get_Profile_JTF_Site_Value('JTF_PROFILE_DEFAULT_CURRENCY');
-- fix for Bug#3256105
/*    l_prod_org      VARCHAR2(240) :=
                Get_Profile_Site_Value('ASO_PRODUCT_ORGANIZATION_ID');*/

    l_count     NUMBER;
    l_curr_code         VARCHAR2(15);

    l_min_winprob   NUMBER;
    l_max_winprob   NUMBER;

    l_err_num       BINARY_INTEGER;
    l_err_total     BINARY_INTEGER;
    l_warn_total    BINARY_INTEGER;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.setv.Validate_Setup';

BEGIN

    l_err_total := 0;
    l_warn_total := 0;
    IF p_upgrade = 'N' THEN
    Write_Log(l_module, '**** Run time checking for Oracle Sales application ****');
    ELSE
    Write_Log(l_module, '**** Setup checking for Oracle Sales 11i data migration');
    OPEN Get_FileDebugDir;
    FETCH Get_FileDebugDir into l_write_dir;
        IF(l_write_dir IS NULL) THEN
        CLOSE Get_FileDebugDir;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
            '): no directory defined in utl_file_dir.');
        Write_Log(l_module, ' ');
    ELSE
        CLOSE Get_FileDebugDir;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: found valid directory '
            ||'for migration log file.');
        Write_Log(l_module, ' ');
        END IF;
    END IF;

    -- checking Security Setup
    l_err_num := 0;
    IF p_upgrade = 'N' THEN
        Write_Log(l_module, '**** Checking the setup for Access security ****');
        IF l_cust_access IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
           '): Default value is missing in profile ''OS: Customer Access Privilege''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '||
        '''OS: Customer Access Privilege'' has value <'
        ||l_cust_access||'> at site level');
        END IF;
        IF l_lead_access IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
           '): Default value is missing in profile ''OS: Sales Lead Access Privilege''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Sales Lead Access Privilege'' has value <'
        ||l_lead_access||'> at site level.');
        END IF;
        IF l_opp_access IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
            '): Default value is missing in profile '||
            '''OS: Opportunity Access Privilege''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Opportunity Access Privilege'' has value <'
        ||l_opp_access||'> at site level.');
        END IF;
        IF l_cust_access = 'T' AND (l_lead_access IN ('F', 'P')
        OR l_opp_access IN ('F', 'P')) THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
           '): Invalid combination of access privilege profiles.');
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'If OS: Customer Access Privilege set to '||
        'Sales Team, you cannot set either Sales Lead Access '||
        'Privilege or opportunity Access Privilege to Full or Prospecting.');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: no invalid combination of access privilege profiles.');
        END IF;
        IF l_mgr_update IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
           '): Default value is missing in profile ''OS: Manager Update Access''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Manager Update Access'' has value <'
        ||l_mgr_update||'> at site level.');
        END IF;
        IF l_admin_update IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
           '): Default value is missing in profile ''OS: Sales Admin Update Access''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Sales Admin Update Access'' has value <'
        ||l_admin_update||'> at site level.');
        END IF;
    Write_Log(l_module, ' ');
        Write_Log(l_module, '**** '||to_char(l_err_num)
        ||' error(s) found in  Security setup ****');
        Write_Log(l_module, '+---------------------------------------'||
        '------------------------------------+');
    END IF;
    -- checking TCA Setup
    IF p_upgrade = 'Y' THEN
        l_err_num := 0;
        Write_Log(l_module, ' ');
        Write_Log(l_module, '**** Checking the setup for TCA/Resource module ****');
        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_CONTACT_FAMILY cf
    WHERE not exists
      ( select aslkp.lookup_code
        , arlkp.lookup_code
        from AS_LOOKUPS aslkp
        ,AR_LOOKUPS arlkp
        ,AS_CONTACT_FAMILY acf
        where aslkp.lookup_type = 'CONTACT_RELATION'
          and upper(ltrim(rtrim(aslkp.meaning))) =
          upper(ltrim(rtrim(acf.relation)))
          and arlkp.lookup_type = 'PARTY_RELATIONS_TYPE'
          and instr(arlkp.lookup_code , aslkp.lookup_code) > 0
          and cf.family_id = acf.family_id );
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Contact Relation is not set in TCA');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: no invalid Contact Relation in AS_CONTACT_FAMILY');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count FROM RA_SALESREPS_ALL rrep
    WHERE not exists
        (select 1 from OE_SALES_CREDIT_TYPES osct
         where rrep.sales_credit_type_id = osct.sales_credit_type_id);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;

    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): bad data found in RA_SALESREPS_ALL');
        Write_Log(l_module, 'The sales_credit_type of the salesrep must be'
        ||' defined in OE_SALES_CREDIT_TYPES');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: all salesrep in RA_SALESREPS_ALL have valid sales credit type');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count FROM RA_SALESREPS_ALL
    WHERE (start_date_active > end_date_active
        AND start_date_active is not null
        AND end_date_active is not null)
       OR (start_date_active is null
        AND end_date_active is not null);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): bad data found in RA_SALESREPS_ALL');
        Write_Log(l_module, 'The start_date_active of the salesrep must earlier '
        ||'than the end_date_active');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: all salesrep in RA_SALESREPS_ALL have '
        ||'valid active date');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count FROM (select salesrep_number
            from RA_SALESREPS_ALL
            group by salesrep_number having count(1) > 1);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): found duplicate SALESREP_NUMBER in RA_SALESREPS_ALL');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: no duplicate SALESREP_NUMBER found '
        ||'in RA_SALESREPS_ALL');
    END IF;

/*        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_SALES_GROUPS a, AS_SALESFORCE b
    WHERE a.manager_person_id = b.employee_person_id
      and a.manager_salesforce_id <> b.salesforce_id
      and b.type = 'EMPLOYEE';
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Dangling FK to AS_SALESFORCE found in AS_SALES_GROUPS');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: manager_salesforce_id in AS_SALES_GROUPS'
        ||' exists in AS_SALESFORCE');
    END IF;*/

        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_SALES_GRP_ADMIN sga
    WHERE not exists
        ( select 1 from PER_ALL_PEOPLE_F per
          where per.person_id = sga.person_id )
      and not exists
        ( select 1 from AS_SALESFORCE sf
          where sf.salesforce_id = sga.salesforce_id );
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): found record(s) with invalid person_id/salesforce_id'
        ||' in AS_SALES_GRP_ADMIN');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: records in AS_SALES_GRP_ADMIN'
        ||' having valid person_id/salesforce_id');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_SALES_GRP_ADMIN a, AS_SALESFORCE b
    WHERE a.salesforce_id <> b.salesforce_id
      and a.person_id = b.employee_person_id
      and b.type = 'EMPLOYEE';
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Dangling FK to AS_SALESFORCE found in AS_SALES_GRP_ADMIN');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: salesforce_id in AS_SALES_GRP_ADMIN'
        ||' exists in AS_SALESFORCE');
    END IF;

/*        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_SALES_GRP_ADMIN sga
    WHERE not exists
      ( select 1 from AS_SALES_GROUPS sg
        where sga.sales_group_id = sg.sales_group_id );
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): found record(s) with invalid sales_group_id'
        ||' in AS_SALES_GRP_ADMIN');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: sales_group_id in AS_SALES_GRP_ADMIN'
        ||' exists in AS_SALES_GROUPS');
    END IF;
*/
    Write_Log(l_module, ' ');
        Write_Log(l_module, '**** '||to_char(l_err_num)
        ||' error(s) found in  TCA/Resource setup ****');

    Write_Log(l_module, '+-------------------------------------'||
        '--------------------------------------+');

        l_err_num := 0;
        Write_Log(l_module, ' ');
        Write_Log(l_module, '**** Checking the setup for Task/Interaction module ****');

        BEGIN
    SELECT count(*) INTO l_count
        FROM AS_LOOKUPS aslkp
    WHERE aslkp.lookup_type = 'TODO'
        and not exists
            ( select 1 from JTF_TASK_TYPES_VL
              where upper(rtrim(ltrim(aslkp.meaning))) =
            upper(rtrim(ltrim(name))));
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Lookup_Type ''TODO'' has some lookup code(s), which are not'
        ||' defined in JTF_TASK_TYPES_VL');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: all lookup codes for ''TODO'''
        ||' have been setup in JTF_TASK_TYPES_VL');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_LOOKUPS aslkp
    WHERE aslkp.lookup_type = 'TODO_PRIORITY'
        and not exists
        ( select 1 from JTF_TASK_PRIORITIES_VL
          where upper(rtrim(ltrim(aslkp.meaning))) =
            upper(rtrim(ltrim(name))));
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Lookup_Type ''TODO_PRIORITY'' has some lookup code(s), '
        ||'which are not defined in JTF_TASK_PRIORITIES_VL');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: all lookup codes for ''TODO_PRIORITY'''
        ||' have been setup in JTF_TASK_PRIORITIES_VL');
    END IF;

        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_LOOKUPS aslkp
    WHERE aslkp.lookup_type = 'INTERACTION_TYPE'
        and aslkp.lookup_code not in ('MAIL_BLITZ','MAILED_IN_RESPONSE'
        ,'INBOUND','OUTBOUND','VISIT')
        and not exists
         ( select 1 from FND_LOOKUP_VALUES flv
              where flv.lookup_code = aslkp.lookup_code
              and flv.lookup_type = 'JTF_MEDIA_TYPE' );
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): Lookup_Type ''INTERACTION_TYPE'' has some lookup code(s), '
        ||'which are not defined in lookup_type ''JTF_MEDIA_TYPE''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: all lookup codes for ''INTERACTION_TYPE'''
        ||' have been setup in lookup_type ''JTF_MEDIA_TYPE''');
    END IF;
    Write_Log(l_module, ' ');
        Write_Log(l_module, '**** '||to_char(l_err_num)
        ||' error(s) found in  Task/Interaction setup ****');
    Write_Log(l_module, '+-------------------------------------'||
        '--------------------------------------+');
    END IF;

    -- checking Opportunity Setup
    l_err_num := 0;
    Write_Log(l_module, '**** Checking the setup for Opportunity module ****');
    IF p_upgrade = 'N' THEN
        IF l_opp_status IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Default Opportunity Status''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Default Opportunity Status'' has value <'
        ||l_opp_status||'> at site level.');
        END IF;
        IF l_win_prob IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile '
        ||'''OS: Default Opportunity Win Probability''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '
        ||'''OS: Default Opportunity Win Probability'' has value <'
        ||l_win_prob||'> at site level.');
    END IF;
        IF l_sales_stage_id IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile '
        ||'''OS: Default Opportunity Sales Stage''');
        ELSE
        Write_Log(l_module, ' ');
        Write_Log(l_module, 'Success: profile '||
        '''OS: Default Opportunity Sales Stage'' has ID value <'
        ||l_sales_stage_id||'> at site level.');
            OPEN  C_Get_Stage_Info (l_SALES_STAGE_ID);
            FETCH C_Get_Stage_Info into l_min_winprob, l_max_winprob;
            IF C_Get_Stage_Info%NOTFOUND THEN
            Write_Log(l_module, ' ');
            Write_Log(l_module, 'Error('||to_char(l_err_total)||
            '): Profile ''OS: Default Opportunity Sales Stage'' '||
            'has an invalid value');
                l_err_num := l_err_num+1;
            l_err_total := l_err_total+1;
            ELSIF l_min_winprob > l_win_prob OR l_max_winprob < l_win_prob THEN
                IF l_prob_ss_link = 'WARNING' THEN
                l_warn_total := l_warn_total+1;
            Write_log(l_module, ' ');
                Write_log(l_module, 'Warning('||to_char(l_warn_total)||
             '): The value combination of profile ''OS: '||
            'Default Opportunity Sales Stage'' and ''OS: '||
            'Default Opportunity Win Probability'' is not valid');
                ELSIF l_prob_ss_link = 'ERROR' THEN
                    l_err_num := l_err_num+1;
            l_err_total := l_err_total+1;
            Write_log(l_module, ' ');
                Write_log(l_module, 'Warning('||to_char(l_warn_total)||
             '): The value combination of profile ''OS: '||
            'Default Opportunity Sales Stage'' and ''OS: '||
            'Default Opportunity Win Probability'' must be valid');
                END IF;
        ELSE
            Write_log(l_module, ' ');
                Write_log(l_module, 'Success: The value combination of profile ''OS: '||
            'Default Opportunity Sales Stage'' and ''OS: '||
            'Default Opportunity Win Probability'' is valid');
            END IF;
            CLOSE C_Get_Stage_Info;
        END IF;
        IF l_opp_closing IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Default Close Date Days''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '||
        '''OS: Default Close Date Days'' has value <'
        ||l_opp_closing||'> at site level.');
        END IF;

        -- SOLIN, 06/12/2001
        -- Make sure all opportunity currency_code are defined in
        -- reporting currency.
        l_count := 0;
        OPEN C_GET_MISSING_OPP_CURR;
        LOOP
            FETCH C_GET_MISSING_OPP_CURR INTO l_curr_code;
            EXIT WHEN C_GET_MISSING_OPP_CURR%NOTFOUND;

        Write_log(l_module, 'Error('||to_char(l_err_total)||
                      '): currency ' || l_curr_code ||
                      ' should be defined in FND lookup with lookup_type ' ||
                      '''REPORTING_CURRENCY''');
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
            l_count := l_count + 1;
        END LOOP;
        CLOSE C_GET_MISSING_OPP_CURR;
        IF l_count = 0 THEN
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: All opportunity currencies are defined in FND lookup');
        END IF;
        -- end SOLIN, 06/12/2001

    END IF;
    IF l_fst_credit_type IS NULL THEN
    l_err_num := l_err_num+1;
    l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
    Write_log(l_module, 'Error('||to_char(l_err_total)||
     '): Default value is missing in profile ''OS: Forecast Sales Credit Type''');
    ELSE
        Write_log(l_module, ' ');
    Write_log(l_module, 'Success: profile '||
        '''OS: Forecast Sales Credit Type'' has ID value <'
        ||l_fst_credit_type||'> at site level.');
    END IF;
    IF l_cn_credit_type IS NULL THEN
    l_err_num := l_err_num+1;
    l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
    Write_log(l_module, 'Error('||to_char(l_err_total)||
            '): Default value is missing in profile '''||
        'OS: Compensation Sales Credit Type''');
    ELSE
        Write_log(l_module, ' ');
    Write_log(l_module, 'Success: profile '''||
        'OS: Compensation Sales Credit Type'' has ID value <'
        ||l_cn_credit_type||'> at site level.');
    END IF;
    IF p_upgrade = 'N' THEN
        IF l_opp_channel IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Default Sales Channel''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Default Sales Channel'' has value <'
        ||l_opp_channel||'> at site level.');
        END IF;
        IF l_mc_roll_days IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile '''||
        'OS: Maximum Roll Days for Converting Amount''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Maximum Roll Days for Converting Amount'' has value <'
        ||l_mc_roll_days||'> at site level.');
        END IF;
        IF l_mc_mapping_type IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Date Mapping Type''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Date Mapping Type'' has value <'||l_mc_mapping_type
        ||'> at site level.');
        END IF;
        IF l_mc_conv_type IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Daily Conversion Type''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Daily Conversion Type'' has value <'
        ||l_mc_conv_type||'> at site level.');
        END IF;
        IF l_fst_calendar IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''OS: Forecast Calendar''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Forecast Calendar'' has value <'||l_fst_calendar
        ||'> at site level.');
            BEGIN
        SELECT count(*) INTO l_count
        FROM AS_MC_TYPE_MAPPINGS
        WHERE PERIOD_SET_NAME=l_fst_calendar;
            EXCEPTION
                WHEN OTHERS THEN
                    l_count := 0;
            END;
        IF l_count = 0 THEN
            l_err_num := l_err_num+1;
            l_err_total := l_err_total+1;
            Write_log(l_module, ' ');
            Write_log(l_module, 'Error('||to_char(l_err_total)
            ||'): no type mapping found in AS_MC_TYPE_MAPPINGS');
        ELSE
            Write_log(l_module, ' ');
            Write_log(l_module, 'Success: MC type mapping found in AS_MC_TYPE_MAPPINGS');
        END IF;
        END IF;
        IF l_prefer_currency IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile '''||
        'OS: Preferred Reporting Currency''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'OS: Preferred Reporting Currency'' has value <'
        ||l_prefer_currency||'> at site level.');
        END IF;
        IF l_default_currency IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''JTF_PROFILE_DEFAULT_CURRENCY''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'JTF_PROFILE_DEFAULT_CURRENCY'' has value <'
        ||l_default_currency||'> at site level.');
        END IF;
-- fix for Bug#3256105
/*        IF l_prod_org IS NULL THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)||
        '): Default value is missing in profile ''ASO : Product Organization''');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: profile '''||
        'ASO : Product Organization'' has ID value <'
        ||l_prod_org||'> at site level.');
        END IF;*/
        BEGIN
    SELECT count(*) INTO l_count
    FROM ASO_I_SALES_CHANNELS_V
    WHERE ENABLED_FLAG='Y'
      AND NVL(START_DATE_ACTIVE, sysdate) <= sysdate
      AND NVL(END_DATE_ACTIVE, sysdate) >= sysdate;
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count = 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): no active Sales Channel in ASO_I_SALES_CHANNELS_V.');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: active Sales Channel'||
        ' found in ASO_I_SALES_CHANNELS_V');
    END IF;
    END IF;
    BEGIN
        BEGIN
    SELECT count(*) INTO l_count
    FROM ASO_I_SALES_CREDIT_TYPES_V
    WHERE ENABLED_FLAG='Y'
      AND QUOTA_FLAG='N';
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count = 0 THEN
            l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): no active revenue credit type found in ASO_I_SALES_CREDIT_TYPES_V.');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: revenue credit type'||
        ' found in ASO_I_SALES_CREDIT_TYPES_V');
    END IF;
        BEGIN
    SELECT count(*) INTO l_count
    FROM ASO_I_SALES_CREDIT_TYPES_V
    WHERE ENABLED_FLAG='Y'
      AND QUOTA_FLAG='Y';
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count = 0 THEN
            l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): no active non-revenue credit type found '||
        'in ASO_I_SALES_CREDIT_TYPES_V.');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: non-revenue credit type'||
        ' found in ASO_I_SALES_CREDIT_TYPES_V');
    END IF;
    END;
    -- SOLIN, 06/12/2001
    -- AS_MC_REPORTING_CURR will be obsolete and migrate to
    -- FND_LOOKUP_VALUES with lookup_type='REPORTING_CURRENCY'
    IF p_upgrade = 'N' THEN
        BEGIN
        SELECT count(*) INTO l_count
        FROM FND_LOOKUP_VALUES
        WHERE ENABLED_FLAG = 'Y'
        AND LOOKUP_TYPE = 'REPORTING_CURRENCY';
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;

--  SELECT count(*) INTO l_count
--  FROM AS_MC_REPORTING_CURR;
    IF l_count=0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
--      Write_Log('Error('||to_char(l_err_total)
--      ||'): no reporting currency found in AS_MC_REPORTING_CURR');
        Write_Log(l_module, 'Error('||to_char(l_err_total)
        ||'): no reporting currency found in FND lookup');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: reporting currency found in FND lookup');
--      Write_Log('Success: reporting currency found in AS_MC_REPORTING_CURR');
    END IF;
    END IF;
    -- end SOLIN, 06/12/2001

    IF p_upgrade = 'Y' THEN
        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_SALES_CREDITS
    WHERE (REVENUE_PERCENT IS NOT NULL AND REVENUE_AMOUNT IS NOT NULL)
       OR (QUOTA_CREDIT_PERCENT IS NOT NULL AND QUOTA_CREDIT_AMOUNT IS NOT NULL)
       OR (REVENUE_PERCENT IS NULL AND REVENUE_AMOUNT IS NULL AND
        QUOTA_CREDIT_PERCENT IS NULL AND QUOTA_CREDIT_AMOUNT IS NULL);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): bad data found in AS_SALES_CREDITS');
        Write_log(l_module, 'Before 11i data migration, one and only one of the two fields, '||
        'amount or percent, must be entered for either revenue or quota credtis.');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no bad data found in AS_SALES_CREDITS');
    END IF;

        BEGIN
        SELECT count(*) INTO l_count
    FROM as_sales_stages_all_b stg
    WHERE not exists (Select 'E' From as_sales_stages_all_b istg
                   Where istg.name = stg.name
                   And istg.org_id = 0);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_Log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): found sales stage, which has no set up for org_id=0, '
        ||'in AS_SALES_STAGES_ALL_B');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no bad data found in AS_SALES_STAGES_ALL_B');
    END IF;

        BEGIN
        SELECT count(*) INTO l_count
    FROM as_forecast_prob_all_b fp
    WHERE not exists (Select 'E' From as_forecast_prob_all_b ifp
                   Where ifp.probability_value = fp.probability_value
                   And ifp.org_id = 0);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): found sales stage, which has no set up for org_id=0, '
        ||'in AS_FORECAST_PROB_ALL_B');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no bad data found in AS_FORECAST_PROB_ALL_B');
    END IF;

    ELSE
        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_LEADS_ALL
    WHERE SALES_STAGE_ID IS NULL
       OR DECISION_DATE IS NULL
       OR WIN_PROBABILITY IS NULL
       OR CHANNEL_CODE IS NULL;
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): bad data found in AS_LEADS_ALL');
        Write_log(l_module, 'SALES_STAGE_ID, DECISION_DATE, '||
        'WIN_PROBABILITY and CHANNEL_CODE in AS_LEADS_ALL must be NOT NULL.');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no bad data found in AS_LEADS_ALL');
    END IF;
    END IF;
    Write_log(l_module, ' ');
    Write_log(l_module, '**** '||to_char(l_err_num)
    ||' error(s) found in  Opportunity setup ****');
    Write_log(l_module, '+----------------------------------'||
    '-----------------------------------------+');
    IF p_upgrade = 'N' THEN
        -- checking Forecast Setup
        l_err_num := 0;
        Write_log(l_module, ' ');
        Write_log(l_module, '**** Checking the setup for Forecast module ****');
        BEGIN
        SELECT count(*) INTO l_count
        FROM as_fst_sales_categories
        WHERE product_category_id is not null
        and ROWID NOT IN ( SELECT MIN(ROWID)
                            FROM as_fst_sales_categories
                            GROUP BY  product_category_id);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
        IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): duplicate records found in AS_FST_SALES_CATEGORIES');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no duplicate records'||
        ' found in AS_FST_SALES_CATEGORIES');
        END IF;
        BEGIN
        SELECT count(*) INTO l_count
        FROM as_pe_int_categories
        WHERE product_category_id is not null
        and ROWID NOT IN ( SELECT MIN(ROWID)
                            FROM as_pe_int_categories
                            GROUP BY quota_id, product_category_id );
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
        IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): duplicate records found in AS_PE_INT_CATEGORIES');
        ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no duplicate records'||
        ' found in AS_PE_INT_CATEGORIES');
        END IF;
        Write_log(l_module, ' ');
        Write_log(l_module, '**** '||to_char(l_err_num)
        ||' error(s) found in  Forecast setup ****');
        Write_log(l_module, '+---------------------------------------------'||
        '------------------------------+');
    END IF;
    -- checking Territory Setup
    IF p_upgrade = 'Y' THEN
        l_err_num := 0;
        Write_log(l_module, ' ');
        Write_log(l_module, '**** Checking the setup for Territory module ****');
        BEGIN
    SELECT count(*) INTO l_count
    FROM AS_TERR_TYPE_QUALIFIERS C, AS_TERRITORIES_ALL  A
    WHERE A.TERRITORY_TYPE_ID = C.TERRITORY_TYPE_ID
      AND C.seeded_qualifier_id not in (
        select B.seeded_qualifier_id
        from  AS_TERRITORY_VALUES_ALL B
        where A.TERRITORY_ID =B.TERRITORY_ID);
        EXCEPTION
            WHEN OTHERS THEN
                l_count := 0;
        END;
    IF l_count > 0 THEN
        l_err_num := l_err_num+1;
        l_err_total := l_err_total+1;
        Write_log(l_module, ' ');
        Write_log(l_module, 'Error('||to_char(l_err_total)
        ||'): invalid records found in AS_TERRITORIES_ALL');
        Write_log(l_module, '(The record is invalid if the Qualifier has no'
            ||' Value defined in AS_TERRITORY_VALUES_ALL.)');
    ELSE
        Write_log(l_module, ' ');
        Write_log(l_module, 'Success: no invalid qualifier found in territory records');
    END IF;
    END IF;
    Write_log(l_module, ' ');
    Write_log(l_module, '**** '||to_char(l_err_num)
        ||' error(s) found in  Territory setup ****');
    Write_log(l_module, '+----------------------------------------------'||
        '-----------------------------+');
    Write_log(l_module, ' ');
    Write_log(l_module, '**** Total '||to_char(l_err_total)
        ||' error(s) found in Oracle Sales Application setup ****');
    Write_log(l_module, ' ');
    Write_log(l_module, '**** Total '||to_char(l_warn_total)
        ||' warning(s) found in Oracle Sales Application setup ****');
END Validate_Setup;

END AS_VALIDATE_SETUP;

/
