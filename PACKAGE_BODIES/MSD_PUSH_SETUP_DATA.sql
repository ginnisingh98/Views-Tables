--------------------------------------------------------
--  DDL for Package Body MSD_PUSH_SETUP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PUSH_SETUP_DATA" as
/* $Header: msdpstpb.pls 120.3 2006/07/12 06:05:23 sjagathe noship $ */
--
-- Global variables
        G_DBLINK                 varchar2(30);
        l_para_prof              para_profile_list;
        g_already_checked        BOOLEAN := FALSE;
        g_num_profile            NUMBER;


    /* Debug */
    C_DEBUG               Constant varchar2(1) := 'N';


-- Declaring Function
    --
    Function decode_profile_function ( p_profile_rec in para_profile) return varchar2;
    Function get_multi_org_flag return varchar2;
    Function get_profile_value ( p_profile_name in varchar2, p_DP_Server_flag in varchar2) return varchar2;
    Function get_function_value(p_function_name in  varchar2,
                                p_DP_Server_flag in varchar2) return varchar2;

    Procedure push_profile (errbuf         OUT  NOCOPY VARCHAR2,
                            retcode        OUT  NOCOPY VARCHAR2,
                            p_instance_id in number);

    Procedure push_organization (errbuf         OUT  NOCOPY VARCHAR2,
                                 retcode        OUT  NOCOPY VARCHAR2,
                                 p_instance_id in number);

    Procedure Init;


    Procedure show_line(p_sql in    varchar2);
    Procedure debug_line(p_sql in    varchar2);


--

/* Usability Enhancements. Bug # 3509147. This function sets the value of profile MSD_CUSTOMER_ATTRIBUTE to NONE
if collecting for the first time */
procedure chk_customer_attribute(
		                      errbuf              OUT NOCOPY VARCHAR2,
				      retcode             OUT NOCOPY VARCHAR2,
			              p_instance_id       IN  NUMBER) IS

Type c_setup_params is ref cursor;
x_cust_attribute    varchar2(40);
x_dblink         varchar2(128);
x_retcode	number;
x_source_table	VARCHAR2(50) ;
x_sql_stmt       varchar2(4000);
x_num_params number := 0;
l_cur c_setup_params;
x_set_profile number;
x_profile_name VARCHAR2(50) := '''MSD_CUSTOMER_ATTRIBUTE''';
x_profile_value VARCHAR2(50) := '''NONE''';
x_profile_level VARCHAR2(50) := '''SITE''';

chk_customer_attr_log_msg VARCHAR2(4000) := 'The collection of customers, ship to locations (customer sites),
regions, and other level values in the geography dimension from
e-business source instance to Demand Planning depends on the profile,
MSD:Customer Attribute. It is recommended to set the profile to
selectively collect these level values. To collect all the available
geography dimension level values, please clear out the dummy profile
value. Until the profile value is set appropriately or cleared out, only
the dummy level value (other) will be collected into Demand Planning for
geography dimension.';

Begin

	msd_common_utilities.get_db_link(p_instance_id, x_dblink, x_retcode);
	if (x_retcode = -1) then
		retcode :=-1;
		errbuf := 'Error while getting db_link';
		return;
	end if;

	x_source_table := 'MSD_SETUP_PARAMETERS'||x_dblink;
	x_sql_stmt := 'SELECT COUNT(*) FROM '||x_source_table||' where instance_id = '||p_instance_id;

	open l_cur for x_sql_stmt;
	  fetch l_cur into x_num_params;
	close l_cur;

	if x_num_params = 0 then
	       x_sql_stmt := 'Begin :l_out1 := MSD_SR_UTIL.set_customer_attr'||x_dblink||'('||x_profile_name||','
	       ||x_profile_value||','||x_profile_level||'); End;';
	       EXECUTE IMMEDIATE x_sql_stmt using OUT x_set_profile;
               fnd_file.put_line(fnd_file.log, chk_customer_attr_log_msg);
	       If (x_set_profile=2) then
		 retcode :=-1;
		 errbuf := 'Error while Setting Value for Profile MSD_CUSTOMER_ATTRIBUTE';
		 return;
	       end if;
	       commit;
	end if;

End chk_customer_attribute;

--

Procedure  Init is

l_count  NUMBER := 0;

BEGIN


    -- Initialize parameter array
        l_para_prof(1).profile_name   := 'MSD_CATEGORY_SET_NAME';
        l_para_prof(1).function_name   := 'MSD_SR_UTIL.GET_CATEGORY_SET_ID';
        l_para_prof(1).DP_Server_Flag := 'N';
        l_para_prof(1).function_profile_code := 'F';

        l_para_prof(2).profile_name   := 'MSD_CONVERSION_TYPE';
        l_para_prof(2).function_name   := 'MSD_SR_UTIL.GET_CONVERSION_TYPE';
        l_para_prof(2).DP_Server_Flag := 'N';
        l_para_prof(2).function_profile_code := 'F';

        l_para_prof(3).profile_name   := 'MSD_CURRENCY_CODE';
        l_para_prof(3).DP_Server_Flag := 'Y';
        l_para_prof(3).function_profile_code := 'P';

        l_para_prof(4).profile_name   := 'MSD_MASTER_ORG';
        l_para_prof(4).function_name   := 'MSD_SR_UTIL.MASTER_ORGANIZATION';
        l_para_prof(4).DP_Server_Flag := 'N';
        l_para_prof(4).function_profile_code := 'F';

        l_para_prof(5).profile_name   := 'MSD_CUSTOMER_ATTRIBUTE';
        l_para_prof(5).function_name   := 'MSD_SR_UTIL.GET_CUSTOMER_ATTR';
        l_para_prof(5).DP_Server_Flag := 'N';
        l_para_prof(5).function_profile_code := 'F';

        l_para_prof(6).profile_name   := 'MSD_PLANNING_PERCENTAGE';
        l_para_prof(6).DP_Server_Flag := 'Y';
        l_para_prof(6).function_profile_code := 'P';

        l_para_prof(7).profile_name   := 'AS_FORECAST_CALENDAR';
        l_para_prof(7).DP_Server_Flag := 'N';
        l_para_prof(7).function_profile_code := 'P';

        l_para_prof(8).profile_name   := 'MSD_TWO_LEVEL_PLANNING';
        l_para_prof(8).DP_Server_Flag := 'Y';
        l_para_prof(8).function_profile_code := 'P';

/* BUG# 5383368 - SOP and EOL code cleanup
        l_para_prof(9).profile_name   := 'MSD_EOL_CATEGORY_SET_NAME';
        l_para_prof(9).function_name   := 'MSD_SR_UTIL.GET_EOL_CATEGORY_SET_ID';
        l_para_prof(9).DP_Server_Flag := 'N';
        l_para_prof(9).function_profile_code := 'F';
*/

        /* Bug# 4157588 */
        l_para_prof(9).profile_name   := 'MSD_ITEM_ORG';
        l_para_prof(9).function_name   := 'MSD_SR_UTIL.ITEM_ORGANIZATION';
        l_para_prof(9).DP_Server_Flag := 'N';
        l_para_prof(9).function_profile_code := 'F';

        g_num_profile := l_para_prof.LAST;

END Init;



Procedure Push_data (
        errbuf          OUT NOCOPY  varchar2,
        retcode         OUT NOCOPY  varchar2,
        p_instance_id   IN  number) is
--
    --
    l_retcode   varchar2(10);
    x_ret_val number;
    l_count number;
    l_push_profiles number;
    l_err number;
    l_prof_val varchar2(80);
    l_parameter_value varchar2(80);
    x_dblink  varchar2(128);
    x_retcode number;
    v_sql_stmt varchar2(4000);
    x_source_table varchar2(255);


Begin

    x_ret_val := 0;
    l_count := 0;
    l_push_profiles := 0;
    l_err := 0;

    /* Initialization parameter values */
    Init;


    --  Find out if there are rows in msd_setup_parameters in the source instance
    --
    -- Call MSD_CONC_LOG_UTIL.Initialize for log file for concurrent program
    --
    msd_conc_log_util.Initilize(msd_conc_log_util.C_OUTPUT_TO_FNDFILE);
    --

    msd_common_utilities.get_db_link(p_instance_id, g_dblink, l_retcode);
    if (l_retcode = -1) then
       msd_conc_log_util.display_message('Instance id : ' || p_instance_id || ' not found ', msd_conc_log_util.C_FATAL_ERROR);
       return;
    end if;


    -- log details
    msd_conc_log_util.display_message('Demand Plan Push Setup Parameters', msd_conc_log_util.C_SECTION);
    msd_conc_log_util.display_message(' ', msd_conc_log_util.C_HEADING);
    msd_conc_log_util.display_message('Demand Plan Push Setup Program Parameters', msd_conc_log_util.C_HEADING);
    msd_conc_log_util.display_message('-----------------------------------------', msd_conc_log_util.C_HEADING);
    -- get instance dblink
    --
    msd_common_utilities.get_db_link(p_instance_id, g_dblink, l_retcode);
    -- Check results
    if (l_retcode = -1) then
        -- Log Fatal Error
        msd_conc_log_util.display_message('Instance id : ' || p_instance_id || ' not found ', msd_conc_log_util.C_FATAL_ERROR);
		return;
    else
        -- Log success details
        msd_conc_log_util.display_message('Instance ID : ' || p_instance_id, msd_conc_log_util.C_INFORMATION);
        msd_conc_log_util.display_message('DB Link     : ' || g_dblink , msd_conc_log_util.C_INFORMATION);
    end if;

    --
    -- Call Push_profile
    --
       push_profile( errbuf, retcode, p_instance_id);

    -- Call Push organizations
        --
       push_organization (errbuf, retcode, p_instance_id);
        --

    retcode := msd_conc_log_util.retcode;
    --
    msd_conc_log_util.display_message('Exiting with :  ', msd_conc_log_util.Result);


    --
Exception
   When msd_conc_log_util.EX_FATAL_ERROR then
       retcode := 2;
       errbuf := substr( sqlerrm, 1, 80);
   when others then
       retcode := 2;
       errbuf := substr( sqlerrm, 1, 80);
End Push_data;
--
Function decode_profile_function ( p_profile_rec in para_profile) return varchar2 is
--
    l_ret_val   varchar2(255);
Begin
    --
    if p_profile_rec.function_profile_code = 'P' then
        -- Record is a Profile. Fetch profile value
        l_ret_val := get_profile_value ( p_profile_rec.profile_name, p_profile_rec.DP_Server_flag);
    elsif p_profile_rec.function_profile_code = 'F' then
        -- Record is a function. Fetch return value
        -- Note* Currently code supports call to function with no parameters
        l_ret_val := get_function_value(p_profile_rec.function_name, p_profile_rec.DP_Server_flag);
    end if;
    --
    return l_ret_val;
End decode_profile_function;

Function get_profile_value ( p_profile_name in varchar2, p_DP_Server_flag in varchar2) return varchar2 is
--
    l_ret_val   varchar2(255);
    l_sql       varchar2(100);
Begin
    --
    if p_DP_Server_flag = 'Y' then
        --
       l_ret_val := fnd_profile.value(p_profile_name);
       --
    else
       --
       l_sql := 'Begin :l_ret1 := fnd_profile.value' || G_DBLINK || '(''' || p_profile_name || '''); End;';
       EXECUTE IMMEDIATE l_sql using OUT l_ret_val;
    end if;
    --
    return l_ret_val;
    --
End get_profile_value;
--
Function get_function_value(p_function_name in  varchar2, p_DP_Server_flag in varchar2) return varchar2 is
    l_ret_val   varchar2(255);
    l_sql       varchar2(100);
Begin
    if p_DP_Server_flag = 'Y' then
       l_sql := 'Begin :l_out1 := ' || p_function_name || '; End;';
       EXECUTE IMMEDIATE l_sql using OUT l_ret_val;
    else
       l_sql := 'Begin :l_out1 := ' || p_function_name || G_DBLINK || '; End;';
       EXECUTE IMMEDIATE l_sql using OUT l_ret_val;
    end if;
    return l_ret_val;
End get_function_value;

Function get_multi_org_flag return varchar2 is
    l_ret_val   varchar2(255);
    v_sql_stmt       varchar2(100);
Begin

    v_sql_stmt :=  'Select multi_org_flag from fnd_product_groups' || G_DBLINK ||
                   ' where product_group_type = ''Standard''';

   EXECUTE IMMEDIATE v_sql_stmt into l_ret_val;
    return l_ret_val;

 exception
    when others then

       l_ret_val := 'Y';
       return l_ret_val;
End get_multi_org_flag;

--
Procedure push_profile (    errbuf         OUT  NOCOPY VARCHAR2,
                            retcode        OUT  NOCOPY VARCHAR2,
                            p_instance_id in number) is
--
    --
    l_retcode   varchar2(10);
    l_cnt       BINARY_INTEGER:=0;
    l_retval    varchar2(255);
    l_sql       varchar2(2000);
    l_err       BINARY_INTEGER:=0;
    l_warning   BINARY_INTEGER:=0;
    l_prof      varchar2(255);
    l_multi_org_flag varchar2(255);

    --
--
Begin
    -- Log
    msd_conc_log_util.display_message('Push Profile', msd_conc_log_util.C_SECTION);
    msd_conc_log_util.display_message('Action', msd_conc_log_util.C_HEADING);
    msd_conc_log_util.display_message(rpad('-', 80, '-'), msd_conc_log_util.C_HEADING);

    -- Read profiles/functions from the array and initialise on source instance
    --
     l_err := 0;

     /* Get the parameter values */
     FOR i IN l_para_prof.FIRST..l_para_prof.LAST LOOP
        l_para_prof(i).parameter_value  := decode_profile_function(l_para_prof(i));
        msd_conc_log_util.display_message('Profile ' || l_para_prof(i).profile_name || ' : ' ||
                                           l_para_prof(i).parameter_value, msd_conc_log_util.C_INFORMATION);
     END LOOP;

     IF ((l_para_prof(2).parameter_value is NULL) or
         (l_para_prof(3).parameter_value is NULL) or
         (l_para_prof(4).parameter_value is NULL)) THEN
          l_err := 1;
     END IF;


     /* In case of multi org, l_para_prof(4) will have master org id
        through master_organization function call even though
        profile value is not specified.  In this case, give warning to user
        to confirm that master_org_id for the source will be the org_id from
        master_organization function call, not from the source profile value */
     IF (l_para_prof(4).parameter_value is not null) THEN
         l_prof := get_profile_value('MSD_MASTER_ORG', 'N');
         l_multi_org_flag := get_multi_org_flag;
         IF (l_prof is null) THEN
            IF (l_multi_org_flag = 'Y') THEN
               l_warning := 1;
            END IF;
         END IF;
     END IF;



    /* If Two-Level Planning has not been set, then default it to NO */
    IF (l_para_prof(8).parameter_value is NULL) THEN
        msd_conc_log_util.display_message('Profile ' || l_para_prof(8).profile_name ||
                    ' is not defined.  Defaulting this profile value to ',msd_conc_log_util.C_INFORMATION);
        msd_conc_log_util.display_message('''Exclude family members with forecast control NONE''',
                                          msd_conc_log_util.C_INFORMATION);
        l_para_prof(8).parameter_value := 2;
    END IF;

    if ((l_err <> 1) and (l_warning = 1)) then

                 msd_conc_log_util.display_message('Profile ' || l_para_prof(4).profile_name ||
                                                   ' in the Source instance NOT SET !!!', msd_conc_log_util.C_INFORMATION);
                 msd_conc_log_util.display_message('The system has determined to use Organization Id = ' ||
                                                   l_para_prof(4).parameter_value || ' as the master org', msd_conc_log_util.C_INFORMATION);
                 msd_conc_log_util.display_message('If this is not the master org, please update the MSD_MASTER_ORG profile on the source',
                                                    msd_conc_log_util.C_WARNING);
                 msd_conc_log_util.display_message(' and rerun the Push Setup Parameters concurrent program', msd_conc_log_util.C_WARNING);
    end if;


    IF (l_err = 1) THEN
           msd_conc_log_util.display_message('Please make sure that profiles ' ||
                                         'MSD_CONVERSION_TYPE and MSD_MASTER_ORG are set in Source instance.', msd_conc_log_util.C_ERROR);
           msd_conc_log_util.display_message(' and MSD_CURRENCY_CODE profile in the Planning Server are set.', msd_conc_log_util.C_ERROR);
    ELSE
           msd_conc_log_util.display_message('Deleting records from msd_setup_parameters in the Source instance', msd_conc_log_util.C_HEADING);
           /* Truncate Source msd_setup_parameters */
           l_sql := 'delete from msd_setup_parameters' || g_dblink;
           EXECUTE IMMEDIATE l_sql;

           msd_conc_log_util.display_message('Inserting profile into source msd_setup_parameters', msd_conc_log_util.C_INFORMATION);

           /* Insert profiles in source msd_setup_parameters */
           l_sql := 'insert into msd_setup_parameters' || g_dblink ||
              ' (instance_id, parameter_name, parameter_value) values (:1, :2, :3)';

           FOR j IN l_para_prof.FIRST..l_para_prof.LAST LOOP
              EXECUTE IMMEDIATE l_sql using p_instance_id, l_para_prof(j).profile_name, l_para_prof(j).parameter_value;
           END LOOP;
    END IF;


    commit;

EXCEPTION
          when others then
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

END push_profile;



Procedure push_organization ( errbuf         OUT  NOCOPY VARCHAR2,
                              retcode        OUT  NOCOPY VARCHAR2,
                              p_instance_id in number) is
--
    l_sql   varchar2(2000);
--
Begin
    -- Log
    msd_conc_log_util.display_message('Push Organization', msd_conc_log_util.C_SECTION);
    msd_conc_log_util.display_message('Action', msd_conc_log_util.C_HEADING);
    msd_conc_log_util.display_message(rpad('-', 80, '-'), msd_conc_log_util.C_HEADING);
    --
    msd_conc_log_util.display_message('Deleting Organizations from source MSD_APP_INSTANCE_ORGS', msd_conc_log_util.C_INFORMATION);
    --
    -- Delete all organization records from MSD_APP_INSTANCE_ORGS
    l_sql := 'Delete from MSD_APP_INSTANCE_ORGS' || g_dblink;
    EXECUTE IMMEDIATE l_sql;
    --
    msd_conc_log_util.display_message('Creating Organizations into source MSD_APP_INSTANCE_ORGS', msd_conc_log_util.C_INFORMATION);
    --
    -- Create rows in MSD_APP_INSTANCE_ORGS, in source database, for all the enabled
    -- organization in msc_instance_orgs
    --
/* Bug# 4166487 Use dp_enabled_flag instead of enabled_flag */
    l_sql := 'insert into MSD_APP_INSTANCE_ORGS' || g_dblink ||
             '( instance_id, organization_id, last_update_date, last_updated_by, creation_date, ' ||
             '  created_by, last_update_login, request_id, program_application_id, program_id,  ' ||
             '  program_update_date, attribute_category, attribute1, attribute2, attribute3,    ' ||
             '  attribute4, attribute5, attribute6, attribute7, attribute8, attribute9, '         ||
             '  attribute10, attribute11, attribute12, attribute13, attribute14, attribute15) '   ||
             'select sr_instance_id, organization_id, last_update_date, last_updated_by, '        ||
             '  creation_date, created_by, last_update_login, request_id, program_application_id,' ||
             '  program_id, program_update_date, attribute_category, attribute1, attribute2, '    ||
             '  attribute3, attribute4, attribute5, attribute6, attribute7, attribute8, attribute9,' ||
             '  attribute10, attribute11, attribute12, attribute13, attribute14, attribute15' ||
             ' from msc_instance_orgs where sr_instance_id = :id and nvl(dp_enabled_flag, enabled_flag) = ''1''';
    EXECUTE IMMEDIATE l_sql using p_instance_id;
    --

    commit;

EXCEPTION
          when others then
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

end push_organization;



procedure chk_push_setup(   errbuf         OUT  NOCOPY VARCHAR2,
                            retcode        OUT  NOCOPY VARCHAR2,
                            p_instance_id  IN   NUMBER ) IS

l_count    number:= 0;
v_sql_stmt     varchar2(4000);

TYPE Source_Profile_Value IS REF CURSOR;
c_source_profile Source_Profile_Value;

TYPE parameter_name_tab  IS TABLE OF MSD_SETUP_PARAMETERS.parameter_name%TYPE;
TYPE parameter_value_tab IS TABLE OF MSD_SETUP_PARAMETERS.parameter_value%TYPE;

a_parameter_name   parameter_name_tab;
a_parameter_value  parameter_value_tab;

x_parameter_name   varchar2(200);
x_parameter_value  varchar2(200);
j number := 1;

b_match          BOOLEAN := FALSE;
b_need_to_push   BOOLEAN := FALSE;

TYPE org_diff IS REF CURSOR;
c_org  org_diff;


Begin

   /* Check g_pushed, session variable. If it has been
      pushed within the session, then don't push it again */
   IF (g_already_checked = FALSE) THEN

      Init;

         /* Set the value of profile msd_customer_attribute to some dummy value if collecting for the first time */
       chk_customer_attribute(	      errbuf,
				      retcode,
			              p_instance_id);

      /* Get db_link */
      msd_common_utilities.get_db_link(p_instance_id, g_dblink, retcode);
      IF retcode <> 0 THEN
         msd_conc_log_util.display_message('Instance id : ' || p_instance_id ||
                                           ' not found ', msd_conc_log_util.C_FATAL_ERROR);
         return;
      END IF;

      /* First, Check the setup parameters, and then check organization */
      /* Get the profile values */
      FOR i IN l_para_prof.FIRST..l_para_prof.LAST LOOP
          l_para_prof(i).parameter_value  := decode_profile_function(l_para_prof(i));
      END LOOP;

      v_sql_stmt := 'SELECT parameter_name, parameter_value FROM MSD_SETUP_PARAMETERS'||g_dblink ||
                    ' where instance_id = ' || p_instance_id;

/* Does not work on Oracle 8i
 *      OPEN c_source_profile FOR v_sql_stmt;
 *     FETCH c_source_profile BULK COLLECT INTO a_parameter_name, a_parameter_value;
 */

      a_parameter_name := parameter_name_tab(null);
      a_parameter_value := parameter_value_tab(null);

      OPEN c_source_profile FOR v_sql_stmt;
      LOOP
        FETCH c_source_profile INTO x_parameter_name, x_parameter_value;
        EXIT WHEN c_source_profile%NOTFOUND;
        a_parameter_name.extend;
        a_parameter_value.extend;
        a_parameter_name(j) := x_parameter_name;
        a_parameter_value(j) := x_parameter_value;
        j := j + 1;
      END LOOP;

      IF (a_parameter_name.exists(1)) THEN
         /* Check if all the profile values are matching or not.
            IF any of them are not matching then exit immediately */

         FOR j IN l_para_prof.FIRST..l_para_prof.LAST LOOP
            FOR i IN a_parameter_name.FIRST..a_parameter_name.LAST LOOP
               IF (a_parameter_name(i) = l_para_prof(j).profile_name) THEN
                  IF ( (a_parameter_value(i) = l_para_prof(j).parameter_value) or
                       (a_parameter_value(i) is null and l_para_prof(j).parameter_value is null) ) THEN
                     b_match := TRUE;
                     exit;  /* Exit inner loop when there is a maching.  Goto
                               the next profile value to compare */
                  END IF;
               END IF;
            END LOOP;

            IF (b_match = FALSE) THEN
               b_need_to_push := TRUE;
               /* Exit the loop - difference in parameter value found */
               exit;
            END IF;

            /* ReInitialize the variable */
            b_match := FALSE;

         END LOOP;
      ELSE
         /* IF there is no profile value exist in the source */
         b_need_to_push := TRUE;

      END IF;  /* IF (a_parameter_name.exists(1)) THEN */


      /* Check Organization only if b_need_to_push is false.
         Otherwise, we need to execute push_setup_parameters anyway.
         doesn't need to check org  */
/* Bug# 4166487 Use dp_enabled_flag instead of enabled_flag */
      IF (b_need_to_push = FALSE) THEN
         v_sql_stmt  := ' SELECT count(*) from ( ' ||
                        '        ( SELECT organization_id FROM msc_instance_orgs ' ||
                        '                 WHERE sr_instance_id = ' || p_instance_id ||
                        '                       and nvl(dp_enabled_flag, enabled_flag) = ''1''' ||
                        '          MINUS ' ||
                        '          SELECT organization_id FROM msd_app_instance_orgs' || g_dblink ||
                        '                 WHERE instance_id = ' || p_instance_id || ') ' ||
                        '          UNION ALL ' ||
                        '        ( SELECT organization_id FROM msd_app_instance_orgs' || g_dblink ||
                        '                 WHERE instance_id = ' || p_instance_id ||
                        '          MINUS ' ||
                        '          SELECT organization_id FROM msc_instance_orgs ' ||
                        '                 WHERE sr_instance_id = ' || p_instance_id ||
                        '                       and nvl(dp_enabled_flag, enabled_flag) = ''1'') ' ||
                        ' )';


         OPEN c_org FOR v_sql_stmt;
         FETCH c_org INTO l_count;
         CLOSE c_org;

         IF l_count <> 0 THEN
            b_need_to_push := TRUE;
         END IF;
      END IF; /* (b_need_to_push = FALSE) */

      if (b_need_to_push) then
           push_data(errbuf,retcode,p_instance_id);
           /* retcode will be 1 in case of WARNING.
               Do not error out in case of WARNING. Proceed as it was normal */
           IF  nvl(retcode,0) = 1 THEN
               retcode := 0;
           END IF;
           IF  nvl(retcode,0) <> 0  THEN
               show_line('---------------------------------------------------------------------------------------------' );
               show_line('Profiles not setup properly. Please check Profiles on Planning Server and re-run collections.');
 	       show_line('---------------------------------------------------------------------------------------------' );
               return;
           end if;
      end if;


   /* Set this session variable to TRUE so that within this sesssion,
      we don't need to check profile values had been pushed into
      the source or not */

      g_already_checked := TRUE;

  END IF;  /* if g_already_checked = FALSE */

EXCEPTION
          when others then
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;

End chk_push_setup;

/*------------------------- DWK  For the debugging purpose ---------------------*/
Procedure show_line(p_sql in    varchar2) is
    i   number:=1;
Begin
    while i<= length(p_sql)
    loop
 --     dbms_output.put_line (substr(p_sql, i, 255));
        fnd_file.put_line(fnd_file.log,substr(p_sql, i, 255));
	null;
        i := i+255;
    end loop;
End;


Procedure debug_line(p_sql in    varchar2)is
Begin
    if c_debug = 'Y' then
        show_line(p_sql);
    end if;
End;


END MSD_PUSH_SETUP_DATA;

/
