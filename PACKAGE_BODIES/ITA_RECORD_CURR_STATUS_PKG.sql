--------------------------------------------------------
--  DDL for Package Body ITA_RECORD_CURR_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_RECORD_CURR_STATUS_PKG" as
/* $Header: itarcurb.pls 120.24.12010000.2 2008/09/23 06:04:10 ptulasi ship $ */

PROCEDURE enable_tracking(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2, p_table_name IN VARCHAR2)
IS
l_ret_code  NUMBER;
l_ret_val   BOOLEAN;
l_app_id    NUMBER;
l_set_warn  BOOLEAN;
CURSOR c_all_tables IS
SELECT table_name, application_id
FROM fnd_tables
WHERE table_id IN (SELECT table_id FROM ita_setup_groups_b WHERE audit_end_date IS NULL);

l_table c_all_tables%ROWTYPE;

BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Starting concurrent program');
    IF p_table_name IS NOT NULL
    THEN
        l_app_id := -1;
        SELECT application_id
        INTO l_app_id
        FROM fnd_tables
        WHERE table_name = p_table_name;

        IF l_app_id = -1
        THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Table ' || p_table_name || ' does not exist in fnd_tables.');
            l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Current State not fetched.');
            RETURN;
        END IF;
        l_ret_code := enable_tracking_for_table(l_app_id, p_table_name);
        IF l_ret_code = 0
        THEN
            l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Current State not fetched.');
        ELSE
            l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', 'Current State fetched.');
        END IF;
        RETURN;
    ELSE
        FOR l_table IN c_all_tables
        LOOP
            EXIT WHEN c_all_tables%NOTFOUND;
            l_ret_code := enable_tracking_for_table(l_table.application_id, l_table.table_name);
            IF l_ret_code = 0
            THEN
                l_set_warn := TRUE;
            END IF;
        END LOOP;
        /*l_ret_code := enable_tracking_for_table(200, 'AP_SYSTEM_PARAMETERS_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(200, 'FINANCIALS_SYSTEM_PARAMS_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(222, 'AR_SYSTEM_PARAMETERS_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(260, 'CE_SYSTEM_PARAMETERS_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(101, 'GL_SETS_OF_BOOKS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(101, 'GL_TAX_OPTIONS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(401, 'MTL_PARAMETERS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(201, 'PO_SYSTEM_PARAMETERS_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(201, 'RCV_PARAMETERS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(665, 'WSH_SHIPPING_PARAMETERS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(140, 'FA_SYSTEM_CONTROLS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(8901, 'FV_SYSTEM_PARAMETERS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(8901, 'FV_FEDERAL_OPTIONS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(201, 'AP_SUPPLIERS');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(201, 'AP_SUPPLIER_SITES_ALL');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;
        l_ret_code := enable_tracking_for_table(0, 'FND_PROFILE_OPTION_VALUES');
        IF l_ret_code = 0
        THEN
            l_set_warn := TRUE;
        END IF;*/
    END IF;
    -- Status - NORMAL, WARNING, ERROR
    IF l_set_warn = TRUE
    THEN
        errbuf := 'Current state fetched for some of the tables.';
        l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', errbuf);
        retcode := FND_API.G_RET_STS_SUCCESS;
    ELSE
        errbuf := 'Current state fetched.';
        l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', errbuf);
        retcode := FND_API.G_RET_STS_SUCCESS;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Finished fetching current configuration.');
EXCEPTION WHEN OTHERS
THEN
    l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', 'Current State not fetched.');
    errbuf := SQLERRM;
    retcode := FND_API.G_RET_STS_UNEXP_ERROR;
END enable_tracking;

FUNCTION enable_tracking_for_table
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER
IS
l_ret_code  NUMBER;
BEGIN
    l_ret_code := create_shadow_trigger(p_application_id, p_table_name);
    IF l_ret_code = 0
    THEN
        RETURN l_ret_code;
    END IF;
    IF p_table_name = 'FND_PROFILE_OPTION_VALUES'
    THEN
        l_ret_code := record_profile_current_state(p_application_id, p_table_name);
    ELSE
        l_ret_code := record_current_state(p_application_id, p_table_name);
    END IF;
    IF l_ret_code = 0
    THEN
        RETURN l_ret_code;
    END IF;
    -- l_ret_code = 2 means audit_start_date was already set so current state already fetched.
    IF l_ret_code <> 2
    THEN
        l_ret_code := set_audit_start_date(p_application_id, p_table_name);
    END IF;
    IF l_ret_code = 0
    THEN
        RETURN l_ret_code;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done with ' || p_table_name);
    COMMIT;
    RETURN 1;
END enable_tracking_for_table;

FUNCTION set_audit_start_date
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER
IS
    l_setup_gp_code     ITA_SETUP_GROUPS_B.setup_group_code%TYPE;
    l_ret_val           BOOLEAN;
BEGIN

    select setup_gp.SETUP_GROUP_CODE
    INTO l_setup_gp_code
    FROM ITA_SETUP_GROUPS_B setup_gp, FND_TABLES ft
    WHERE setup_gp.TABLE_APP_ID = p_application_id and setup_gp.TABLE_ID = ft.table_id and
          ft.application_id = setup_gp.table_app_id and ft.table_name = UPPER(p_table_name);

    UPDATE ita_setup_groups_b SET audit_start_date = sysdate
    WHERE setup_group_code = l_setup_gp_code;
    RETURN 1;
EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
--     dbms_output.put_line(SUBSTR (SQLERRM, 1, 2000));
     --l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Audit Start date not set for ' || p_table_name);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Audit Start Date not set for ' || p_table_name);
     RETURN 0;
END set_audit_start_date;


FUNCTION get_shadow_table_prefix
(p_table_name     IN VARCHAR2)
RETURN VARCHAR2
IS
    l_shadow_table_name     VARCHAR2(40);

BEGIN
    IF LENGTH(p_table_name) IS NULL
    THEN
        RETURN NULL;
    END IF;
    IF LENGTH(p_table_name) > 24
    THEN
        l_shadow_table_name := SUBSTR(p_table_name, 1, 24);
    ELSE
        l_shadow_table_name := p_table_name;
    END IF;
    l_shadow_table_name := CONCAT(l_shadow_table_name, '_A');
    RETURN l_shadow_table_name;
END get_shadow_table_prefix;

FUNCTION create_shadow_trigger
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER
IS
 --- sanayak start bug#5766565 - skip workflow biz events for audit disabled parameters
Cursor curParams
is
select distinct
PARAMETER_CODE,
PARAMETER_NAME,
SETUP_GROUP_CODE,
COLUMN_ID,
(
select COLUMN_NAME
from FND_COLUMNS fc
where
(APPLICATION_ID, TABLE_ID) = (
select TABLE_APP_ID, TABLE_ID
from ITA_SETUP_GROUPS_B
where SETUP_GROUP_CODE = ispv.SETUP_GROUP_CODE) and
COLUMN_ID = ispv.COLUMN_ID
) COLUMN_NAME,
AUDIT_ENABLED_FLAG
from ITA_SETUP_PARAMETERS_VL ispv
where ispv.SETUP_GROUP_CODE in
(select distinct
setup_gp.SETUP_GROUP_CODE
from
ITA_SETUP_GROUPS_VL setup_gp,
FND_TABLES fnd_table ,
FND_APPLICATION_VL FND_APP
where
fnd_table.APPLICATION_ID (+) = setup_gp.TABLE_APP_ID and
fnd_table.TABLE_ID (+) = setup_gp.TABLE_ID and
setup_gp.TABLE_APP_ID = FND_APP.application_id
and setup_gp.TABLE_APP_ID = setup_gp.TABLE_APP_ID
and setup_gp.table_app_id = p_application_id
and table_name = p_table_name
)
and exists			--- query to find existance in audit schema tables(R12 only)
(
select COLUMN_id
from FND_AUDIT_COLUMNS
where
(TABLE_APP_ID, TABLE_ID) = (
select TABLE_APP_ID, TABLE_ID
from ITA_SETUP_GROUPS_B
where SETUP_GROUP_CODE = ispv.SETUP_GROUP_CODE)
and ispv.Column_id = column_id
)
;

    l_shadow_table_name     VARCHAR2(40);
    l_if_block              VARCHAR2(32767) := 'if ((';
    l_if_notnull	    VARCHAR2(32767);
    l_if_null		    VARCHAR2(32767);
    l_query_header          VARCHAR2(32767);
    l_query                 VARCHAR2(32767);
    l_query_launch	    VARCHAR2(32767);
    l_skip_chgevent         BOOLEAN := FALSE;

    l_ret_val               BOOLEAN;
BEGIN
/* for all rows in ITA_SETUP_PARAMETERS_VL view
   if there is alteast one not null column which
   meets the above mentioned criteria, skip the workflow
*/
    for recParams in curParams
	Loop

	 if recParams.AUDIT_ENABLED_FLAG = 'N' then
	 	l_if_notnull :=  l_if_notnull || ':n.' || recParams.COLUMN_NAME || ' is not null or ';
	 	l_skip_chgevent := TRUE;
	 else
	 	l_if_null := l_if_null || ':n.' || recParams.COLUMN_NAME || ' is null and ';

	 end if;

	End loop;

	l_if_block := l_if_block || l_if_notnull || '''Y'' = ''N'') and (' ||  l_if_null || '''Y'' = ''Y''))'||
                        ' then return; end if;';

	l_shadow_table_name := ITA_RECORD_CURR_STATUS_PKG.get_shadow_table_prefix(p_table_name);

        l_query_header :=
        'create or replace trigger ' || l_shadow_table_name || '_ITA ' ||
        'after insert or update ' ||
        'on ' || l_shadow_table_name || ' ' ||
        'referencing new as n ' ||
        'for each row ' ||
        'declare l_item_key WF_ITEMS.ITEM_KEY%type; ' ||
        'begin ' ;

	l_query_launch :=
        'l_item_key := ITA_BIZ_EVENTS_PVT.RAISE_CHANGE_EVENT(''' ||
        p_application_id || ''', ''' || p_table_name || ''', :n.ROWID); ' || 'end;';

	-- ptulasi: 22/09/08: bug: 7260425
	-- ITA is not tracking profile option changes. Modified below condition to fix this issue
	if (l_skip_chgevent AND p_table_name <> 'FND_PROFILE_OPTION_VALUES') then --- code to return without launching workflow
	   l_query := l_query_header||l_if_block||l_query_launch;
	else
	   l_query := l_query_header ||l_query_launch;
	end if;
--- sanayak end bug#5766565
FND_FILE.PUT_LINE(FND_FILE.LOG, 'query is ' || l_query);
    EXECUTE IMMEDIATE l_query;
    RETURN 1;
EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
     --dbms_output.put_line(SUBSTR (SQLERRM, 1, 2000));
     --l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Shadow trigger not created for ' || p_table_name);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Shadow trigger not created for ' || p_table_name);
     RETURN 0;
END create_shadow_trigger;

FUNCTION record_current_state
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER
IS

l_ret_val   BOOLEAN;
l_table_id              NUMBER;
l_setup_gp_code         ITA_SETUP_GROUPS_B.SETUP_GROUP_CODE%TYPE;
l_audit_start_date      DATE;
l_context_param_code    ITA_SETUP_GROUPS_B.CONTEXT_PARAMETER_CODE%TYPE;
l_hier_level_code       VARCHAR2(30);
l_context_param_code2   ITA_SETUP_GROUPS_B.CONTEXT_PARAMETER_CODE2%TYPE;
l_column_id             NUMBER;
l_column_id1            NUMBER;
--l_shadow_table_name     VARCHAR2(40);
l_del_sql               VARCHAR2(32767);
l_select_clause         ITA_SETUP_PARAMETERS_B.SELECT_CLAUSE%TYPE;
l_from_clause           ITA_SETUP_PARAMETERS_B.FROM_CLAUSE%TYPE;
l_where_clause          ITA_SETUP_PARAMETERS_B.WHERE_CLAUSE%TYPE;
l_ins_sql               VARCHAR2(32767);
l_column_name           FND_COLUMNS.COLUMN_NAME%TYPE;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_inst_code             ITA_SETUP_CHANGE_HISTORY.INSTANCE_CODE%TYPE;
l_rec_val_code_sql      VARCHAR2(32767);

CURSOR c_get_parameters(p_setup_group_code  IN VARCHAR2)
IS
SELECT fnd.column_name, isp.parameter_code
from fnd_columns fnd, ita_setup_parameters_b isp
WHERE isp.setup_group_code = p_setup_group_code AND
      isp.column_id = fnd.column_id;

l_param_rec             c_get_parameters%ROWTYPE;
l_curr_sql              VARCHAR2(32767);
l_rec_sql               VARCHAR2(32767);
l_upd_sql               VARCHAR2(32767);
l_curr_val_code         ita_setup_change_history.pk3_value%TYPE;
l_rec_val_code          ita_setup_change_history.pk5_value%TYPE;

BEGIN
    IF LENGTH(p_table_name) IS NULL
    THEN
        RETURN 0;
    END IF;

    SELECT fnd_table.TABLE_ID
    INTO l_table_id
    FROM FND_TABLES fnd_table
    WHERE fnd_table.APPLICATION_ID = p_application_id AND fnd_table.TABLE_NAME = UPPER(p_table_name);

    select setup_gp.SETUP_GROUP_CODE, setup_gp.AUDIT_START_DATE,
    setup_gp.CONTEXT_PARAMETER_CODE, setup_gp.HIERARCHY_LEVEL hierarchy_level_code,
    setup_gp.context_parameter_code2,
    (SELECT column_id FROM ita_setup_parameters_b WHERE parameter_code = setup_gp.CONTEXT_PARAMETER_CODE) column_id,
    (SELECT column_id FROM ita_setup_parameters_b WHERE parameter_code = setup_gp.CONTEXT_PARAMETER_CODE2) column_id1
    INTO l_setup_gp_code, l_audit_start_date, l_context_param_code, l_hier_level_code, l_context_param_code2,
         l_column_id, l_column_id1
    FROM ITA_SETUP_GROUPS_B setup_gp
    WHERE setup_gp.TABLE_APP_ID = p_application_id and
    setup_gp.TABLE_ID = l_table_id;

    select COLUMN_NAME
    INTO l_column_name
    from FND_COLUMNS
    where (APPLICATION_ID, TABLE_ID) = (select TABLE_APP_ID, TABLE_ID
                                        from ITA_SETUP_GROUPS_B
                                        where SETUP_GROUP_CODE = l_setup_gp_code) and
                                              COLUMN_ID = l_column_id;

    l_user_id     := fnd_global.user_id;
    l_login_id    := fnd_global.conc_login_id;
    IF l_audit_start_date IS NULL
    THEN
        l_del_sql := 'delete from ITA_SETUP_CHANGE_HISTORY where INSTANCE_CODE = ''CURRENT'' and SETUP_GROUP_CODE =''' || l_setup_gp_code || '''';
        EXECUTE IMMEDIATE l_del_sql;
        SELECT INSTANCE_CODE INTO l_inst_code FROM ITA_SETUP_INSTANCES_B WHERE CURRENT_FLAG='Y';
        -- l_shadow_table_name := get_shadow_table_prefix(p_table_name);
        FOR l_param_rec IN c_get_parameters(l_setup_gp_code)
        LOOP
            EXIT WHEN c_get_parameters%NOTFOUND;

            SELECT select_clause, from_clause, where_clause
            INTO l_select_clause, l_from_clause, l_where_clause
            FROM ita_setup_parameters_b
            WHERE parameter_code = l_param_rec.parameter_code;

            IF l_select_clause IS NOT NULL
            THEN
            l_select_clause := RTRIM(l_select_clause);
            END IF;
            IF l_from_clause IS NOT NULL
            THEN
            l_from_clause := RTRIM(l_from_clause);
            END IF;
            IF l_where_clause IS NOT NULL
            THEN
            l_where_clause := RTRIM(l_where_clause);
            END IF;
            IF LENGTH(l_select_clause) IS NOT NULL and LENGTH(l_from_clause) IS NOT NULL
            THEN
                l_select_clause := CONCAT(l_select_clause, ' ');
                l_select_clause := CONCAT(l_select_clause, l_from_clause);
                IF LENGTH(l_where_clause) IS NOT NULL
                THEN
                    l_select_clause := CONCAT(l_select_clause, ' ');
                    l_select_clause := CONCAT(l_select_clause, l_where_clause);
                END IF;
            END IF;
            IF LENGTH(l_select_clause) IS NOT NULL
            THEN
                l_curr_sql := REPLACE(l_select_clause, ''':1''', 'bt.' || l_param_rec.column_name);
                l_curr_sql := REPLACE(l_curr_sql, ':1', 'bt.' || l_param_rec.column_name);
                l_curr_sql := REPLACE(l_curr_sql, ':2', '(SELECT ORG_ID FROM AP_SUPPLIER_SITES_ALL WHERE VENDOR_SITE_ID = bt.' || l_column_name || ')');
                --l_rec_sql := REPLACE(l_select_clause, ''':1''', 'pk5_value');
                --l_rec_sql := REPLACE(l_select_clause, ':1', 'pk5_value');
            ELSE
                l_curr_sql := 'bt.' || l_param_rec.column_name;
                l_rec_sql := NULL;
            END IF;

            IF l_setup_gp_code = 'FND' || '.FND_PROFILE_OPTION_VALUES'
            THEN
                l_ins_sql := '';
            END IF;
            -- insert into ita_setup_change_history
            IF p_table_name = 'AP_SUPPLIERS'
            THEN
                /* pk1 - supplier name
                   pk2 - supplier id */
                l_ins_sql := 'INSERT INTO ITA_SETUP_CHANGE_HISTORY(INSTANCE_CODE, CHANGE_ID, PARAMETER_CODE, ' ||
                         'SETUP_GROUP_CODE, CHANGE_AUTHOR, CHANGE_DATE, PK2_VALUE, PK3_VALUE, PK1_VALUE, ' ||
                         'PK5_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ' ||
                         'LAST_UPDATE_DATE, CURRENT_VALUE, OBJECT_VERSION_NUMBER) ' ||
                         '(SELECT ''' || l_inst_code || ''', ' ||
                         'ITA_SETUP_CHANGE_HISTORY_S1.NEXTVAL, ''' || l_param_rec.parameter_code || ''', ''' || l_setup_gp_code || ''', ' ||
                         '(SELECT USER_NAME FROM FND_USER WHERE USER_ID=bt.LAST_UPDATED_BY), bt.LAST_UPDATE_DATE, ' ||
                         'bt.' || l_column_name || ', bt.' || l_param_rec.column_name || ', ' ||
                         '(SELECT VENDOR_NAME FROM AP_SUPPLIERS WHERE VENDOR_ID = bt.' || l_column_name || '), ' ||
                         'to_char(null), ' || l_user_id || ', sysdate, ' || l_user_id || ', ' || l_login_id || ', sysdate, (' || l_curr_sql || '), 1 obj_ver FROM ' || p_table_name || ' bt WHERE ' ||
                         l_param_rec.column_name || ' IS NOT NULL)';
                BEGIN
                    EXECUTE IMMEDIATE l_ins_sql;
                EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
                    fnd_file.put_line(fnd_file.LOG, 'Not fetched for ' || l_param_rec.column_name);
                END;
            END IF;
            IF p_table_name = 'AP_SUPPLIER_SITES_ALL'
            THEN
                /* pk1 - org name
                   pk2 - org id
                   pk6 - supplier name
                   pk7 - supplier id
                   pk8 - site name
                   pk9 - site id*/
                l_ins_sql := 'INSERT INTO ITA_SETUP_CHANGE_HISTORY(INSTANCE_CODE, CHANGE_ID, PARAMETER_CODE, ' ||
                         'SETUP_GROUP_CODE, CHANGE_AUTHOR, CHANGE_DATE, PK9_VALUE, PK3_VALUE, PK8_VALUE, ' ||
                         'PK5_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ' ||
                         'LAST_UPDATE_DATE, PK1_VALUE, PK7_VALUE, PK6_VALUE, PK2_VALUE, CURRENT_VALUE, ' ||
                         'OBJECT_VERSION_NUMBER) ' ||
                         '(SELECT ''' || l_inst_code || ''', ' ||
                         'ITA_SETUP_CHANGE_HISTORY_S1.NEXTVAL, ''' || l_param_rec.parameter_code || ''', ''' || l_setup_gp_code || ''', ' ||
                         '(SELECT USER_NAME FROM FND_USER WHERE USER_ID=bt.LAST_UPDATED_BY), bt.LAST_UPDATE_DATE, ' ||
                         'bt.' || l_column_name || ', bt.' || l_param_rec.column_name || ', ' ||
                         '(SELECT VENDOR_SITE_CODE FROM AP_SUPPLIER_SITES_ALL WHERE VENDOR_SITE_ID = bt.' || l_column_name || '), ' ||
                         'to_char(null), ' || l_user_id || ', sysdate, ' || l_user_id || ', ' || l_login_id || ', sysdate, ' ||
                        '(SELECT name FROM ((select distinct org.ORGANIZATION_ID, org.NAME, org_info.ORG_INFORMATION1 type ' ||
                        'from HR_ALL_ORGANIZATION_UNITS org, HR_ORGANIZATION_INFORMATION org_info ' ||
                        'where org_info.ORGANIZATION_ID = org.ORGANIZATION_ID and ' ||
                        'org_info.ORG_INFORMATION_CONTEXT = ''CLASS'') ' ||
                        'union ' ||
                        '(select distinct SET_OF_BOOKS_ID organization_id, NAME, ''SET_BOOKS'' type ' ||
                        'from GL_SETS_OF_BOOKS ' ||
                        ')) WHERE organization_id = (SELECT ORG_ID FROM AP_SUPPLIER_SITES_ALL WHERE VENDOR_SITE_ID=bt.' || l_column_name || ') and type = ''' || l_hier_level_code || ''') org_name , ' ||
                        '(SELECT VENDOR_ID FROM AP_SUPPLIER_SITES_ALL WHERE VENDOR_SITE_ID = bt.' || l_column_name || ')vendor_id, ' ||
                        '(SELECT VENDOR_NAME FROM AP_SUPPLIERS v, AP_SUPPLIER_SITES_ALL vs WHERE v.VENDOR_ID = vs.VENDOR_ID and VENDOR_SITE_ID = bt.' || l_column_name || ')vendor_name, ' ||
                        '(SELECT ORG_ID FROM AP_SUPPLIER_SITES_ALL WHERE VENDOR_SITE_ID = bt.' || l_column_name || ') org_id, ' ||
                        '(' || l_curr_sql || ') , 1 obj_ver FROM ' || p_table_name || ' bt WHERE ' ||
                        l_param_rec.column_name || ' IS NOT NULL)';
                BEGIN
                    EXECUTE IMMEDIATE l_ins_sql;
                EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
                    fnd_file.put_line(fnd_file.LOG, 'Not fetched for ' || l_param_rec.column_name);
                END;
            END IF;
            IF p_table_name <> 'FND_PROFILE_OPTION_VALUES' and p_table_name <> 'AP_SUPPLIERS' and
                p_table_name <> 'AP_SUPPLIER_SITES_ALL'
            THEN
                /* pk1 - org name
                   pk2 - org id */
                l_rec_val_code_sql := '((select recommended_value from ita_setup_rec_values_vl where parameter_code = '''
                                || l_param_rec.parameter_code || ''' and pk1_value = to_char(bt.' || l_column_name ||
                                ')) union (select recommended_value from ita_setup_rec_values_vl where parameter_code = '''
                                || l_param_rec.parameter_code || ''' and default_flag = ''Y'' and not exists (select recommended_value ' ||
                                ' from ita_setup_rec_values_vl where parameter_code = ''' || l_param_rec.parameter_code || ''' and pk1_value = to_char(bt.' ||
                                l_column_name || ')))) ';
                l_rec_sql := l_rec_val_code_sql || 'recomm_val';
                l_ins_sql := 'INSERT INTO ITA_SETUP_CHANGE_HISTORY(INSTANCE_CODE, CHANGE_ID, PARAMETER_CODE, ' ||
                         'SETUP_GROUP_CODE, CHANGE_AUTHOR, CHANGE_DATE, PK2_VALUE, PK3_VALUE, PK1_VALUE, ' ||
                         'PK5_VALUE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ' ||
                         'LAST_UPDATE_DATE, CURRENT_VALUE, RECOMMENDED_VALUE, OBJECT_VERSION_NUMBER) ' ||
                         '(SELECT ''' || l_inst_code || ''', ' ||
                         'ITA_SETUP_CHANGE_HISTORY_S1.NEXTVAL, ''' || l_param_rec.parameter_code || ''', ''' || l_setup_gp_code || ''', ' ||
                         '(SELECT USER_NAME FROM FND_USER WHERE USER_ID=bt.LAST_UPDATED_BY), bt.LAST_UPDATE_DATE, ' ||
                         'bt.' || l_column_name || ', bt.' || l_param_rec.column_name || ', ' ||
                        '(SELECT name FROM ((select distinct org.ORGANIZATION_ID, org.NAME, org_info.ORG_INFORMATION1 type ' ||
                        'from HR_ALL_ORGANIZATION_UNITS org, HR_ORGANIZATION_INFORMATION org_info ' ||
                        'where org_info.ORGANIZATION_ID = org.ORGANIZATION_ID and ' ||
                        'org_info.ORG_INFORMATION_CONTEXT = ''CLASS'') ' ||
                        'union ' ||
                        '(select distinct SET_OF_BOOKS_ID organization_id, NAME, ''SET_BOOKS'' type ' ||
                        'from GL_SETS_OF_BOOKS ' ||
                        ')) WHERE organization_id = bt.' || l_column_name || ' and type = ''' ||
                        l_hier_level_code || ''') org_name , ' ||
                         l_rec_val_code_sql || 'recomm_code, ' || l_user_id || ', sysdate, ' || l_user_id || ', ' || l_login_id || ', sysdate, ' ||
                         '(' || l_curr_sql || '), ' || l_rec_sql || ' , 1 obj_ver FROM ' || p_table_name || ' bt WHERE ' ||
                         l_param_rec.column_name || ' IS NOT NULL)';
                BEGIN
                    EXECUTE IMMEDIATE l_ins_sql;
                EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
                    fnd_file.put_line(fnd_file.LOG, 'Not fetched for ' || l_param_rec.column_name);
                END;
            END IF;

        END LOOP;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current State fetched for table - ' || p_table_name);
    ELSE
        -- Log that current state already fetched for l_setup_gp_code
        --dbms_output.put_line('Current State already fetched for table - ' || p_table_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current State already fetched for table - ' || p_table_name);
        RETURN 2;
    END IF;
    RETURN 1;
EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
     --dbms_output.put_line(SUBSTR (SQLERRM, 1, 2000));
     --l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Current state not fetched for ' || p_table_name);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current state not fetched for ' || p_table_name);
     RETURN 0;
END record_current_state;

FUNCTION record_profile_current_state
(p_application_id IN NUMBER,
 p_table_name     IN VARCHAR2)
RETURN NUMBER
IS

l_ret_val   BOOLEAN;
l_table_id              NUMBER;
l_setup_gp_code         ITA_SETUP_GROUPS_B.SETUP_GROUP_CODE%TYPE;
l_audit_start_date      DATE;
l_context_param_code    ITA_SETUP_GROUPS_B.CONTEXT_PARAMETER_CODE%TYPE;
l_hier_level_code       VARCHAR2(30);
l_context_param_code2   ITA_SETUP_GROUPS_B.CONTEXT_PARAMETER_CODE2%TYPE;
l_column_id             NUMBER;
l_column_id1            NUMBER;
l_del_sql               VARCHAR2(32767);
l_select_clause         ITA_SETUP_PARAMETERS_B.SELECT_CLAUSE%TYPE;
l_ins_sql               VARCHAR2(32767);
l_ins_param_sql         VARCHAR2(32767);
l_column_name           FND_COLUMNS.COLUMN_NAME%TYPE;
l_column_name1          FND_COLUMNS.COLUMN_NAME%TYPE;
l_user_id               NUMBER;
l_login_id              NUMBER;
l_inst_code             ITA_SETUP_CHANGE_HISTORY.INSTANCE_CODE%TYPE;
l_rec_val_code_sql      VARCHAR2(32767);

l_curr_sql              VARCHAR2(32767);
l_rec_sql               VARCHAR2(32767);
l_upd_sql               VARCHAR2(32767);
l_curr_val_code         ita_setup_change_history.pk3_value%TYPE;
l_rec_val_code          ita_setup_change_history.pk5_value%TYPE;

-- cpetriuc start - bug 5163722
CURSOR c_get_profiles_with_sql(p_setup_group_code IN VARCHAR2) IS
SELECT isch.CHANGE_ID, isp.SELECT_CLAUSE, isch.CURRENT_VALUE
FROM ITA_SETUP_CHANGE_HISTORY isch, ITA_SETUP_PARAMETERS_B isp
WHERE
isch.SETUP_GROUP_CODE = p_setup_group_code and
isch.CURRENT_VALUE is not null and
isch.PARAMETER_CODE = isp.PARAMETER_CODE and
isp.SELECT_CLAUSE is not null and
LTRIM(isp.SELECT_CLAUSE) is not null;  -- cpetriuc - bug 5638086

l_change_id NUMBER;
l_profile_sql VARCHAR2(3000);
l_profile_value_code VARCHAR2(3000);
l_profile_value_meaning VARCHAR2(3000);
l_index_comma NUMBER;
l_index_begin NUMBER;
l_index_end NUMBER;
l_update_sql VARCHAR2(3000);
-- cpetriuc end - bug 5163722

l_prof_rec              c_get_profiles_with_sql%ROWTYPE;
n                       NUMBER;
l_pos                   NUMBER;
l_vis_op_val_pos        NUMBER;

BEGIN
    IF LENGTH(p_table_name) IS NULL
    THEN
        RETURN 0;
    END IF;

    SELECT fnd_table.TABLE_ID
    INTO l_table_id
    FROM FND_TABLES fnd_table
    WHERE fnd_table.APPLICATION_ID = p_application_id AND fnd_table.TABLE_NAME = UPPER(p_table_name);

    select setup_gp.SETUP_GROUP_CODE, setup_gp.AUDIT_START_DATE,
    setup_gp.CONTEXT_PARAMETER_CODE, setup_gp.HIERARCHY_LEVEL hierarchy_level_code,
    setup_gp.context_parameter_code2,
    (SELECT column_id FROM ita_setup_parameters_b WHERE parameter_code = setup_gp.CONTEXT_PARAMETER_CODE) column_id,
    (SELECT column_id FROM ita_setup_parameters_b WHERE parameter_code = setup_gp.CONTEXT_PARAMETER_CODE2) column_id1
    INTO l_setup_gp_code, l_audit_start_date, l_context_param_code, l_hier_level_code, l_context_param_code2,
         l_column_id, l_column_id1
    FROM ITA_SETUP_GROUPS_B setup_gp
    WHERE setup_gp.TABLE_APP_ID = p_application_id and
    setup_gp.TABLE_ID = l_table_id;

    select COLUMN_NAME
    INTO l_column_name
    from FND_COLUMNS
    where (APPLICATION_ID, TABLE_ID) = (select TABLE_APP_ID, TABLE_ID
                                        from ITA_SETUP_GROUPS_B
                                        where SETUP_GROUP_CODE = l_setup_gp_code)
          and COLUMN_ID = l_column_id;

    select COLUMN_NAME
    INTO l_column_name1
    from FND_COLUMNS
    where (APPLICATION_ID, TABLE_ID) = (select TABLE_APP_ID, TABLE_ID
                                        from ITA_SETUP_GROUPS_B
                                        where SETUP_GROUP_CODE = l_setup_gp_code)
          and COLUMN_ID = l_column_id1;

    l_user_id     := fnd_global.user_id;
    l_login_id    := fnd_global.conc_login_id;
    IF l_audit_start_date IS NULL
    THEN
        l_del_sql := 'delete from ITA_SETUP_CHANGE_HISTORY where INSTANCE_CODE = ''CURRENT'' and SETUP_GROUP_CODE =''' || l_setup_gp_code || '''';
        EXECUTE IMMEDIATE l_del_sql;
        SELECT INSTANCE_CODE INTO l_inst_code FROM ITA_SETUP_INSTANCES_B WHERE CURRENT_FLAG='Y';
        /* pk1 - level id
           pk2 - level value
           pk6 - level value name
           pk10 - level value application id */
        l_ins_sql := 'INSERT INTO ITA_SETUP_CHANGE_HISTORY(INSTANCE_CODE, CHANGE_ID, PARAMETER_CODE,' ||
                     'SETUP_GROUP_CODE, CHANGE_AUTHOR, CHANGE_DATE, PK2_VALUE, PK3_VALUE, PK1_VALUE, ' ||
                     'CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, ' ||
                     'LAST_UPDATE_DATE, PK6_VALUE, OBJECT_VERSION_NUMBER, CURRENT_VALUE, RECOMMENDED_VALUE, PK5_VALUE, PK10_VALUE) ' ||
                     '(SELECT /*+ PARALLEL(bt) */''' || l_inst_code || ''', ' || 'ITA_SETUP_CHANGE_HISTORY_S1.NEXTVAL, ''' ||
                     l_setup_gp_code || '.''|| (SELECT profile_option_name FROM fnd_profile_options WHERE application_id=bt.application_id and profile_option_id=bt.profile_option_id), ''' ||
                     l_setup_gp_code || ''', ' ||
                     '(SELECT USER_NAME FROM FND_USER WHERE USER_ID=bt.LAST_UPDATED_BY) change_author, bt.LAST_UPDATE_DATE, ' ||
                     'bt.LEVEL_VALUE, bt.PROFILE_OPTION_VALUE, bt.LEVEL_ID, ' ||
                     l_user_id || ', sysdate, ' || l_user_id || ', ' || l_login_id ||
                     ', sysdate, '  ||
                     '(DECODE(bt.LEVEL_ID, 10002, (SELECT application_name FROM fnd_application_tl WHERE application_id=bt.LEVEL_VALUE AND language = USERENV(''LANG'')),' ||
                     '(DECODE(bt.LEVEL_ID, 10003, (SELECT RESPONSIBILITY_NAME FROM fnd_responsibility_tl WHERE ' ||
                     'RESPONSIBILITY_ID=bt.LEVEL_VALUE and APPLICATION_ID=bt.LEVEL_VALUE_APPLICATION_ID AND language = USERENV(''LANG'')), (DECODE(bt.LEVEL_ID, 10004, (SELECT user_name FROM fnd_user ' ||
                     'WHERE user_id=bt.LEVEL_VALUE), (DECODE(bt.LEVEL_ID, 10005, (SELECT node_name from fnd_nodes where node_id=bt.LEVEL_VALUE), ' ||
                     '(DECODE(bt.LEVEL_ID, 10006, (SELECT name from HR_ALL_ORGANIZATION_UNITS_TL where organization_id=bt.LEVEL_ID AND language = USERENV(''LANG'')), null))) ' ||
                     '))))))) level_value_name, 1 obj_ver, bt.profile_option_value, ' ||
                     '(SELECT recommended_value FROM ita_setup_rec_values_vl WHERE default_flag=''Y'' and ' ||
                     'parameter_code=''' || l_setup_gp_code || '.''|| (SELECT profile_option_name FROM ' ||
                     'fnd_profile_options WHERE application_id=bt.application_id and profile_option_id=bt.profile_option_id)) rec_value, ' ||
                     '(SELECT recommended_value FROM ita_setup_rec_values_vl WHERE default_flag=''Y'' and ' ||
                     'parameter_code=''' || l_setup_gp_code || '.''|| (SELECT profile_option_name FROM ' ||
                     'fnd_profile_options WHERE application_id=bt.application_id and profile_option_id=' ||
                     'bt.profile_option_id)) rec_code, bt.LEVEL_VALUE_APPLICATION_ID  FROM ' || p_table_name || ' bt WHERE bt.profile_option_value is NOT NULL)';
        EXECUTE IMMEDIATE l_ins_sql;
        -- For all profiles in fnd_profile_options that don't exist in ita_setup_parameters_b and
        -- exist in fnd_profile_option_values,
        -- insert into ita_setup_parameters_b, ita_setup_parameters_tl
        l_ins_param_sql := 'INSERT INTO ita_setup_parameters_b (PARAMETER_CODE, SETUP_GROUP_CODE, COLUMN_ID, AUDIT_ENABLED_FLAG, COLUMN_REFERENCE1, COLUMN_REFERENCE2, CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,' ||
        'LAST_UPDATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER, SELECT_CLAUSE)' ||
        '(SELECT ''' || l_setup_gp_code || '.' || ''' || bt.profile_option_name, ''' || l_setup_gp_code || ''', bt.profile_option_id' || ', ''Y'',' ||
        'bt.profile_option_id, bt.application_id, ' || l_user_id || ', sysdate, sysdate, ' || l_user_id ||
        ', ' || l_login_id || ', 1, ' ||
--        '(UPPER(REPLACE(substr(sql_validation, instr(upper(sql_validation), ''SELECT ''),
--        (instr(upper(sql_validation), ''"'' || chr(10) || ''COLUMN='') - instr(upper(sql_validation),
--        ''SELECT ''))), substr(sql_validation, instr(sql_validation, ''\"''), instr(sql_validation,
--        ''\"'', 1, 2) - instr(sql_validation, ''\"'') + 2), ''visible_option_value''))) select_cl ' ||
-- cpetriuc start - bug 5638086
-- Removed the space character after "SELECT".
-- Introduced call to LENGTH.
--        '(UPPER(REPLACE(substr(sql_validation, instr(upper(sql_validation), ''SELECT ''), (instr(upper(sql_validation), ''"'' || chr(10) || ''COLUMN='') - instr(upper(sql_validation), ''SELECT ''))), ''\"'', ''"''))) select_cl ' ||
        '(UPPER(REPLACE(substr(sql_validation, instr(upper(sql_validation), ''SELECT''), (1 + length(upper(sql_validation)) - instr(upper(sql_validation), ''SELECT''))), ''\"'', ''"''))) select_cl ' ||
-- cpetriuc end - bug 5638086
        'FROM fnd_profile_options bt WHERE ''' || l_setup_gp_code || '.' || ''' || bt.profile_option_name NOT IN ' ||
        '(SELECT parameter_code FROM ita_setup_parameters_b) AND (bt.profile_option_id, bt.application_id) ' ||
        'IN (SELECT profile_option_id, application_id from fnd_profile_option_values))';
        EXECUTE IMMEDIATE l_ins_param_sql;
        l_ins_param_sql := 'INSERT INTO ita_setup_parameters_tl (PARAMETER_CODE, CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,' ||
        'LAST_UPDATED_BY, LAST_UPDATE_LOGIN, OBJECT_VERSION_NUMBER, LANGUAGE, SOURCE_LANG, PARAMETER_NAME)' ||
        '(SELECT PARAMETER_CODE, isp.CREATED_BY, isp.CREATION_DATE, isp.LAST_UPDATE_DATE, isp.LAST_UPDATED_BY, isp.LAST_UPDATE_LOGIN, 1, prof.language, prof.source_lang, prof.user_profile_option_name ' ||
        'FROM ita_setup_parameters_b isp, fnd_profile_options_tl prof WHERE ''' || l_setup_gp_code || '.' || ''' || prof.profile_option_name = isp.parameter_code ' ||
        'AND (isp.parameter_code, prof.language) NOT IN (SELECT parameter_code, language from ita_setup_parameters_tl))';
        EXECUTE IMMEDIATE l_ins_param_sql;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current State fetched for table - ' || p_table_name);
    ELSE
        -- Log that current state already fetched for l_setup_gp_code
        --dbms_output.put_line('Current State already fetched for table - ' || p_table_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current State already fetched for table - ' || p_table_name);
        RETURN 2;
    END IF;

-- cpetriuc start - bug 5163722
FOR l_profile_change IN c_get_profiles_with_sql(l_setup_gp_code)
LOOP EXIT WHEN c_get_profiles_with_sql%NOTFOUND;

l_change_id := l_profile_change.CHANGE_ID;
l_profile_sql := UPPER(l_profile_change.SELECT_CLAUSE);
l_profile_value_code := l_profile_change.CURRENT_VALUE;

/*
-- cpetriuc start - bug 5410296
l_index_comma := INSTR(l_profile_sql, ',');

IF INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE') < INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE')
THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' code, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
--l_profile_sql := REPLACE(l_profile_sql, 'INTO :PROFILE_OPTION_VALUE,', ' meaning ');
--l_profile_sql := REPLACE(l_profile_sql, ':VISIBLE_OPTION_VALUE');
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' meaning ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
ELSE
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' meaning, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
--l_profile_sql := REPLACE(l_profile_sql, 'INTO :VISIBLE_OPTION_VALUE,', ' code ');
--l_profile_sql := REPLACE(l_profile_sql, ':PROFILE_OPTION_VALUE');
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' code ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
END IF;

-- Remove from the query the text between double quotes.
WHILE INSTR(l_profile_sql, '"') <> 0 LOOP
l_index_begin := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_begin + 1, LENGTH(l_profile_sql) - l_index_begin);
l_index_end := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_end + 1, LENGTH(l_profile_sql) - l_index_end);
END LOOP;


BEGIN

l_profile_sql := 'SELECT meaning FROM ( ' || l_profile_sql || ' ) WHERE code = ''' || l_profile_value_code || '''';
EXECUTE IMMEDIATE l_profile_sql INTO l_profile_value_meaning;
-- cpetriuc end - bug 5410296
*/


BEGIN

l_profile_value_meaning := get_profile_value_meaning(l_profile_sql, l_profile_value_code);

l_update_sql := 'UPDATE ITA_SETUP_CHANGE_HISTORY SET CURRENT_VALUE = ''' || l_profile_value_meaning || ''' WHERE CHANGE_ID = ' || l_change_id;
EXECUTE IMMEDIATE l_update_sql;

EXCEPTION
WHEN OTHERS THEN fnd_file.PUT_LINE(fnd_file.LOG, SUBSTR(SQLERRM, 1, 2000));

END;


END LOOP;
-- cpetriuc end - bug 5163722

    RETURN 1;
EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
     --dbms_output.put_line(SUBSTR (SQLERRM, 1, 2000));
     --l_ret_val := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', 'Current state not fetched for ' || p_table_name);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current state not fetched for ' || p_table_name);
     RETURN 0;
END record_profile_current_state;




-- cpetriuc start - bug 5410296
FUNCTION get_profile_value_meaning
(p_profile_sql        IN VARCHAR2,
 p_profile_value_code IN VARCHAR2)
RETURN VARCHAR2
IS

l_profile_sql VARCHAR2(3000);
l_profile_value_meaning VARCHAR2(3000);
--l_index_comma NUMBER;  // commented by cpetriuc - bug 5235411
--l_index_begin NUMBER;  // commented by cpetriuc - bug 5235411
--l_index_end NUMBER;  // commented by cpetriuc - bug 5235411

BEGIN

/* comment block by cpetriuc - bug 5235411
l_profile_sql := UPPER(p_profile_sql);
l_index_comma := INSTR(l_profile_sql, ',');

IF INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE') < INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE')
THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' code, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' meaning ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
ELSE
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' meaning, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' code ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
END IF;

-- Remove from the query the text between double quotes.
WHILE INSTR(l_profile_sql, '"') <> 0 LOOP
l_index_begin := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_begin + 1, LENGTH(l_profile_sql) - l_index_begin);
l_index_end := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_end + 1, LENGTH(l_profile_sql) - l_index_end);
END LOOP;
*/

l_profile_sql := strip_profile_query(p_profile_sql);
l_profile_sql := 'SELECT value_meaning FROM ( ' || l_profile_sql || ' ) WHERE value_code = ''' || p_profile_value_code || '''';
EXECUTE IMMEDIATE l_profile_sql INTO l_profile_value_meaning;

RETURN l_profile_value_meaning;

EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR(SQLERRM, 1, 2000));
     fnd_file.put_line(fnd_file.LOG, 'GET_PROFILE_VALUE_MEANING: SQL Statement: ' || l_profile_sql);  -- cpetriuc - bug 5638086
     --dbms_output.put_line(SUBSTR(SQLERRM, 1, 2000));
     RETURN p_profile_value_code;

END get_profile_value_meaning;
-- cpetriuc end - bug 5410296




-- cpetriuc start - bug 5235411
FUNCTION strip_profile_query
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2
IS

l_profile_sql VARCHAR2(3000);
l_index_comma NUMBER;
l_index_begin NUMBER;
l_index_end NUMBER;

BEGIN

--l_profile_sql := UPPER(p_profile_sql);  -- commented by cpetriuc - bug 5638086
-- cpetriuc start - bug 5638086
l_profile_sql := strip_double_quotes(p_profile_sql);
l_profile_sql := strip_aliases(l_profile_sql);
-- cpetriuc end - bug 5638086

l_index_comma := INSTR(l_profile_sql, ',');

IF INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE') < INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE')
THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' value_code, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':VISIBLE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' value_meaning ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
ELSE
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_comma - 1) || ' value_meaning, ' || SUBSTR(l_profile_sql, l_index_comma + 1, LENGTH(l_profile_sql) - l_index_comma);
l_index_begin := INSTR(l_profile_sql, 'INTO');
-- During our investigations, the following query returned no rows:
-- select SQL_VALIDATION from FND_PROFILE_OPTIONS
-- where upper(SQL_VALIDATION) like '%INTO%INTO%'
l_index_end := INSTR(l_profile_sql, ':PROFILE_OPTION_VALUE');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || ' value_code ' || SUBSTR(l_profile_sql, l_index_end + 21, LENGTH(l_profile_sql) - l_index_end - 20);
END IF;

/*
-- commented by cpetriuc - bug 5638086
-- Remove from the query the text between double quotes.
WHILE INSTR(l_profile_sql, '"') <> 0 LOOP
l_index_begin := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_begin + 1, LENGTH(l_profile_sql) - l_index_begin);
l_index_end := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_end + 1, LENGTH(l_profile_sql) - l_index_end);
END LOOP;
*/

-- cpetriuc - bug 5638086
-- Reorder the columns before returning, in the order (VALUE_MEANING, VALUE_CODE),
-- because of limitations in the OA Framework that were discovered during the
-- creation of the dynamic view object definition in method
-- createRecommendedValueLOVView of
-- java/setup/server/RecommendedValuesBuildAMImpl.java.
-- Please see that file for more information.
l_profile_sql := 'SELECT value_meaning, value_code FROM ( ' || l_profile_sql || ' )';

RETURN l_profile_sql;

EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR(SQLERRM, 1, 2000));
     fnd_file.put_line(fnd_file.LOG, 'STRIP_PROFILE_QUERY: SQL Statement: ' || l_profile_sql);  -- cpetriuc - bug 5638086
     --dbms_output.put_line(SUBSTR(SQLERRM, 1, 2000));
     RETURN p_profile_sql;

END strip_profile_query;
-- cpetriuc end - bug 5235411




-- cpetriuc start - bug 5638086
FUNCTION strip_double_quotes
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2
IS

l_profile_sql VARCHAR2(3000);
l_index_column NUMBER;
l_index_title NUMBER;
l_index_begin NUMBER;
l_index_end NUMBER;

BEGIN

l_profile_sql := UPPER(p_profile_sql);

-- Some SQL validation strings in FND_PROFILE_OPTIONS.SQL_VALIDATION
-- contain the code "TITLE=" before the code "COLUMN=".  The logic
-- in RECORD_PROFILE_CURRENT_STATE above used to check for the latter.
-- As of bug 5638086, we are not checking for that anymore in the code
-- above.  Instead, we do that processing here.
l_index_column := INSTR(l_profile_sql, '"' || fnd_global.local_chr(10) || 'COLUMN=');
l_index_title := INSTR(l_profile_sql, '"' || fnd_global.local_chr(10) || 'TITLE=');

l_index_end := l_index_column;
IF (l_index_title <> 0) THEN
IF (l_index_end = 0 or l_index_title < l_index_end) THEN
l_index_end := l_index_title;
END IF;
END IF;

IF  l_index_end <> 0 THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_end - 1);
END IF;

-- Remove from the query the text between double quotes.
WHILE INSTR(l_profile_sql, '"') <> 0 LOOP
l_index_begin := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_begin + 1, LENGTH(l_profile_sql) - l_index_begin);
l_index_end := INSTR(l_profile_sql, '"');
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_begin - 1) || SUBSTR(l_profile_sql, l_index_end + 1, LENGTH(l_profile_sql) - l_index_end);
END LOOP;

RETURN l_profile_sql;

EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR(SQLERRM, 1, 2000));
     fnd_file.put_line(fnd_file.LOG, 'STRIP_DOUBLE_QUOTES: SQL Statement: ' || l_profile_sql);
     --dbms_output.put_line(SUBSTR(SQLERRM, 1, 2000));
     RETURN p_profile_sql;

END strip_double_quotes;
-- cpetriuc end - bug 5638086




-- cpetriuc start - bug 5638086
FUNCTION strip_aliases
(p_profile_sql        IN VARCHAR2)
RETURN VARCHAR2
IS

l_profile_sql VARCHAR2(3000);
l_index_select NUMBER;
l_index_comma NUMBER;
l_index_into NUMBER;
l_index_mark NUMBER;
letter VARCHAR2(1);

BEGIN

l_profile_sql := UPPER(p_profile_sql);
l_profile_sql := REPLACE(l_profile_sql, fnd_global.local_chr(9), ' ');  -- Replace tabs.
l_profile_sql := REPLACE(l_profile_sql, fnd_global.local_chr(10), ' ');  -- Replace new lines.

-- Try to find the beginning of the first column name.
l_index_select := INSTR(l_profile_sql, 'SELECT');
l_index_mark := l_index_select + 6;
LOOP
letter := SUBSTR(l_profile_sql, l_index_mark, 1);
IF letter <> ' ' and letter <> fnd_global.local_chr(9) and letter <> fnd_global.local_chr(10) THEN EXIT; END IF;
l_index_mark := l_index_mark + 1;
END LOOP;

-- Check that this word is not "DISTINCT".
IF SUBSTR(l_profile_sql, l_index_mark, 8) = 'DISTINCT' THEN
l_index_mark := l_index_mark + 8;
-- Find the beginning of the first column name.
LOOP
letter := SUBSTR(l_profile_sql, l_index_mark, 1);
IF letter <> ' ' and letter <> fnd_global.local_chr(9) and letter <> fnd_global.local_chr(10) THEN EXIT; END IF;
l_index_mark := l_index_mark + 1;
END LOOP;
END IF;

-- Delete the first column alias.
l_index_mark := INSTR(l_profile_sql, ' ', l_index_mark, 1);
l_index_comma := INSTR(l_profile_sql, ',');
IF l_index_mark < l_index_comma THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_mark - 1) || SUBSTR(l_profile_sql, l_index_comma, LENGTH(l_profile_sql) - l_index_comma + 1);
END IF;

-- Find the beginning of the second column name.
l_index_comma := INSTR(l_profile_sql, ',');
l_index_mark := l_index_comma + 1;
LOOP
letter := SUBSTR(l_profile_sql, l_index_mark, 1);
IF letter <> ' ' and letter <> fnd_global.local_chr(9) and letter <> fnd_global.local_chr(10) THEN EXIT; END IF;
l_index_mark := l_index_mark + 1;
END LOOP;

-- Delete the second column alias.
l_index_mark := INSTR(l_profile_sql, ' ', l_index_mark, 1);
l_index_into := INSTR(l_profile_sql, 'INTO');
IF l_index_mark < l_index_into THEN
l_profile_sql := SUBSTR(l_profile_sql, 1, l_index_mark) || SUBSTR(l_profile_sql, l_index_into, LENGTH(l_profile_sql) - l_index_into + 1);
END IF;

RETURN l_profile_sql;

EXCEPTION
WHEN OTHERS
    THEN
     fnd_file.put_line(fnd_file.LOG, SUBSTR(SQLERRM, 1, 2000));
     fnd_file.put_line(fnd_file.LOG, 'STRIP_ALIASES: SQL Statement: ' || l_profile_sql);
     --dbms_output.put_line(SUBSTR(SQLERRM, 1, 2000));
     RETURN p_profile_sql;

END strip_aliases;
-- cpetriuc end - bug 5638086




end ITA_RECORD_CURR_STATUS_PKG;

/
