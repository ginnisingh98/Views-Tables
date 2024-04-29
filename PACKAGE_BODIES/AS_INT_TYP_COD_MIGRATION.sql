--------------------------------------------------------
--  DDL for Package Body AS_INT_TYP_COD_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INT_TYP_COD_MIGRATION" as
/* $Header: asxmintb.pls 120.3 2005/12/22 22:53:31 subabu noship $ */

--*****************************************************************************
-- GLOBAL VARIABLES AND CONSTANTS
--

    -- This variable is used to store the application id for ASF
    G_APPLICATION_ID NUMBER := 522;

    -- Transaction date is committed in batches of this size
    G_BATCH_SIZE CONSTANT NUMBER := 10000;

    G_RET_STS_WARNING       CONSTANT    VARCHAR2(1) :=  'W';

    G_SCHEMA_NAME   VARCHAR2(32) := null;

    G_INDEX_SUFFIX       CONSTANT    VARCHAR2(4) :=  '_MT1';

--*****************************************************************************
-- Declarations
--
PROCEDURE Process_Perz_Query_Params (
     p_query_id     IN        NUMBER,
     p_query_name   IN        VARCHAR2,
     p_debug        IN        BOOLEAN,
     x_ret_sts_warning  OUT NOCOPY   VARCHAR2
    );
PROCEDURE Enable_Triggers(p_lead_lines_biud IN BOOLEAN,
                          p_lead_lines_after_biud IN BOOLEAN,
                          p_sales_credits_biud IN BOOLEAN,
                          p_sales_credits_after_biud IN BOOLEAN);
PROCEDURE Disable_Triggers;
PROCEDURE Load_Schema_Name;
PROCEDURE Create_Temp_Index(p_table   IN VARCHAR2,
                      p_index_columns IN VARCHAR2,
                      p_debug IN BOOLEAN);
PROCEDURE Drop_Temp_Index(p_table IN VARCHAR2,
                          p_debug IN BOOLEAN);

--*****************************************************************************
-- Public API
--

/*
This procedure migrates all the perz data and transaction data
*/
PROCEDURE Migrate_All(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS

    l_status BOOLEAN;
    l_warning VARCHAR2(1) := 'N';
    l_debug BOOLEAN := false;
BEGIN
    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration started');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    Migrate_Perz_Data(ERRBUF,
                      RETCODE,
                      p_Debug_Flag);
    if (RETCODE = G_RET_STS_WARNING) then
        l_warning := 'Y';
    end if;

    Migrate_AS_LEAD_LINES_ALL(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_FST_SALES_CATEGORIES(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_AS_LEAD_LINES_LOG(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_AS_INTERESTS_ALL(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_AS_SALES_C_DENORM(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_AS_PRODWKS_LINES(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);
    Migrate_AS_PE_INT_CATEGORIES(ERRBUF,
                             RETCODE,
                             p_Debug_Flag);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Migration finished successfully');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    if (l_warning = 'Y') then
        l_status := fnd_concurrent.set_completion_status('WARNING',FND_MESSAGE.Get_String('AS','API_REQUEST_WARNING_STATUS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in migration '||SQLERRM);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_All;

/*
This is called by concurrent program 'Product Catalog Migration for Perz Data'

This procedure migrates all the perz data
If parameter_name is 'productCategory' or 'prodCat', the parameter name is converted
to the format rep.ROW0.ProdCategory and the corresponding parameter_value is converted
to category id (mapped to the interest type id stored previously).

Here is an example:
old scheme:
parameter name              parameter value
--------------              ---------------
prodCat                     207
prodCat                     208


new scheme:
parameter name              parameter value
--------------              ---------------
rep.ROW0.ProdCategory       xxxxxx (where xxxxxx is the new category_id corresponding to interest type 207)
rep.ROW1.ProdCategory       yyyyyy (where yyyyyy is the new category_id corresponding to interest type 208)

For 'Opportunity by Products Report', the perz data is stored differently
old scheme:
parameter name              parameter value
--------------              ---------------
ROW0ProductCategory         207/434/435
ROW1ProductCategory         208
ROW2ProductCategory         208/460
ROW0.Invt                   CM18761
invItemID0                  253


new scheme:
parameter name              parameter value
--------------              ---------------
rep.ROW0.ProdCategory       xxxxxx (where xxxxxx is the  new category id corresponding to interest code 435)
rep.ROW1.ProdCategory       yyyyyy (where yyyyyy is the  new category id corresponding to interest type 208)
rep.ROW2.ProdCategory       zzzzzz (where zzzzzz is the  new category id corresponding to interest code 460)
rep.ROW0.invItemID          253
rep.ROW0.invItem            CM18761
*/
PROCEDURE Migrate_Perz_Data (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS

    CURSOR C_Get_Query_Ids(c_application_id NUMBER) IS
        select distinct Q.query_id, Q.query_name
        from JTF_PERZ_QUERY_PARAM P, JTF_PERZ_QUERY Q
        where Q.Query_Id = P.Query_Id
        and Q.Application_Id = c_application_id
        and P.Parameter_Type = 'condition'
        and (P.Parameter_Name = 'productCategory' OR    -- As in Group Summary Report or Advanced Search
             P.Parameter_Name = 'prodCat' OR            -- As in Summary Report or detail Report or other reports
             P.Parameter_Name like 'ROW%ProductCategory' OR
             P.Parameter_Name like 'ROW%Invt' OR
             P.Parameter_Name like 'invItemID%')
        order by Q.query_id;

    l_ret_sts_warning VARCHAR2(1) := 'N';
    l_status BOOLEAN;
    l_debug BOOLEAN := false;

BEGIN
    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Perz data migration started');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    -- Initialize retcode to success
    RETCODE := FND_API.G_RET_STS_SUCCESS;

    for scr in C_Get_Query_Ids(G_APPLICATION_ID)
    loop
        Process_Perz_Query_Params(scr.query_id, scr.query_name,l_debug,l_ret_sts_warning);
        if (l_ret_sts_warning = 'Y') then
            RETCODE := G_RET_STS_WARNING;
        end if;
    end loop;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Perz data migration finished succesfully');
    end if;

    commit;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Perz data migration finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    if (RETCODE = G_RET_STS_WARNING) then
        l_status := fnd_concurrent.set_completion_status('WARNING',FND_MESSAGE.Get_String('AS','API_REQUEST_WARNING_STATUS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in perz data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_Perz_Data;

PROCEDURE Process_Perz_Query_Params (
     p_query_id     IN        NUMBER,
     p_query_name   IN        VARCHAR2,
     p_debug        IN        BOOLEAN,
     x_ret_sts_warning  OUT NOCOPY  VARCHAR2
    ) IS

    l_cnt               NUMBER;
    l_cnt2              NUMBER;
    l_index             NUMBER;
    l_index1            NUMBER;
    l_index2            NUMBER;

    l_product_cat_id    NUMBER;
    l_product_cat_set_id NUMBER;
    l_old_query_id      NUMBER;
    l_warning           VARCHAR2(1) := 'N';

    l_int_type_id       NUMBER;
    l_pri_int_code_id   NUMBER;
    l_sec_int_code_id   NUMBER;
    l_debug             BOOLEAN := false;

    CURSOR C_Get_Query_Params(c_query_id NUMBER) IS
        select P.query_param_id, P.parameter_name, P.parameter_type, P.parameter_value, P.parameter_condition, P.parameter_sequence, P.created_by, P.last_update_date, P.last_updated_by, P.last_update_login, P.security_group_id
        from JTF_PERZ_QUERY_PARAM P
        where P.query_id = c_query_id
        and P.Parameter_Type = 'condition'
        and (P.Parameter_Name = 'productCategory' OR    -- As in Group Summary Report or Advanced Search
             P.Parameter_Name = 'prodCat' OR            -- As in Summary Report or detail Report or other reports
             P.Parameter_Name like 'ROW%ProductCategory' OR
             P.Parameter_Name like 'ROW%Invt' OR
             P.Parameter_Name like 'invItemID%')
        order by P.query_param_id;

    CURSOR C_Prod_Cat_Desc(c_product_category_id NUMBER, c_product_cat_set_id NUMBER) IS
        select concat_cat_parentage
        from eni_prod_den_hrchy_parents_v
        where category_id = c_product_category_id
        and category_set_id = c_product_cat_set_id
        and language = userenv('lang');

    CURSOR C_Get_Product_Cat_Id(c_interest_type_id NUMBER) IS
        select product_category_id, product_cat_set_id
        from AS_INTEREST_TYPES_B
        where interest_type_id = c_interest_type_id;

    CURSOR C_Get_Product_Cat_Id2(c_interest_code_id NUMBER) IS
        select product_category_id, product_cat_set_id
        from AS_INTEREST_CODES_B
        where interest_code_id = c_interest_code_id;

BEGIN

    SAVEPOINT Process_Perz_Query_Params;

    l_debug := p_debug;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Processing query ' || p_query_name);
    end if;

    x_ret_sts_warning := 'N';

    -- Initialize count
    l_cnt := -1;

    for scr in C_Get_Query_Params(p_query_id)
    loop
        l_cnt := l_cnt + 1;

        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Query details are query_id='||p_query_id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','query_param_id:'||scr.query_param_id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','parameter_name:'||scr.parameter_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','parameter_type:'||scr.parameter_type);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','parameter_value:'||scr.parameter_value);
        END IF;

        if (scr.parameter_type = 'condition') then
            if (scr.parameter_name = 'productCategory' or scr.parameter_name = 'prodCat') then
                l_product_cat_id := NULL;
                l_product_cat_set_id := NULL;
                -- Get product category id corresponding to the interest type id
                open C_Get_Product_Cat_Id(scr.parameter_value);
                Fetch C_Get_Product_Cat_Id into l_product_cat_id, l_product_cat_set_id;
                if C_Get_Product_Cat_Id%NOTFOUND THEN
                    close C_Get_Product_Cat_Id;

                    -- 'Warning! Ignoring query ' || p_query_name || '(Found Invalid interest type id ' || scr.parameter_value || ')'
                    FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING1');
                    FND_MESSAGE.Set_Token('NAME', p_query_name);
                    FND_MESSAGE.Set_Token('ID', scr.parameter_value);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                    l_warning := 'Y';
                    exit;
                end if;

                close C_Get_Product_Cat_Id;
                if ((l_product_cat_id IS NULL) OR (l_product_cat_set_id IS NULL)) then

                    -- 'Warning! Ignoring query ' || p_query_name || '(Interest type with id ' || scr.parameter_value || ' not mapped to any product category)'
                    FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING2');
                    FND_MESSAGE.Set_Token('NAME', p_query_name);
                    FND_MESSAGE.Set_Token('ID', scr.parameter_value);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                    l_warning := 'Y';
                    exit;
                end if;

                IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','product category id=' || l_product_cat_id || ', category set id='||l_product_cat_set_id);
                END IF;

                -- Set product category id in the JTF_PERZ_QUERY_PARAM table
                Update JTF_PERZ_QUERY_PARAM P
                set parameter_name = 'rep.ROW' || l_cnt || '.ProdCategory',
                parameter_value = l_product_cat_id
                where
                P.query_param_id = scr.query_param_id;
            else
                Begin

                if (instr(scr.parameter_name, 'ProductCategory') > 0) then
                    -- Example: instr('Row10ProductCategory','ProductCategory') = 6
                    -- substr('Row10ProductCategory',4,2) = 10
                    l_index := instr(scr.parameter_name, 'ProductCategory');
                    l_cnt2 := substr(scr.parameter_name, 4, (l_index - 4));

                    -- Now find index of first slash (if any)
                    l_index1 := instr(scr.parameter_value, '/');
                    -- Find index of second slash (if any)
                    l_index2 := instr(scr.parameter_value, '/', l_index1+1);

                    if (l_index1 > 0) then
                        if (l_index2 > 0) then
                            l_int_type_id := substr(scr.parameter_value, 1, l_index1-1);
                            l_pri_int_code_id := substr(scr.parameter_value, l_index1+1, l_index2-l_index1-1);
                            l_sec_int_code_id := substr(scr.parameter_value, l_index2+1);

                            Open C_Get_Product_Cat_Id2(l_sec_int_code_id);
                            Fetch C_Get_Product_Cat_Id2 into l_product_cat_id, l_product_cat_set_id;
                        else
                            l_int_type_id := substr(scr.parameter_value, 1, l_index1-1);
                            l_pri_int_code_id := substr(scr.parameter_value, l_index1+1);

                            Open C_Get_Product_Cat_Id2(l_pri_int_code_id);
                            Fetch C_Get_Product_Cat_Id2 into l_product_cat_id, l_product_cat_set_id;
                        end if;

                        if C_Get_Product_Cat_Id2%NOTFOUND THEN
                            close C_Get_Product_Cat_Id2;

                            -- 'Warning! Ignoring query ' || p_query_name || '(Found Invalid interest code id ' || l_sec_int_code_id || ')'
                            FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING4');
                            FND_MESSAGE.Set_Token('NAME', p_query_name);
                            FND_MESSAGE.Set_Token('ID', l_sec_int_code_id);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                            l_warning := 'Y';
                            exit;
                        end if;

                        close C_Get_Product_Cat_Id2;
                        if ((l_product_cat_id IS NULL) OR (l_product_cat_set_id IS NULL)) then

                             -- 'Warning! Ignoring query ' || p_query_name || '(Interest code with id ' || l_sec_int_code_id || ' not mapped to any product category)'
                             FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING5');
                             FND_MESSAGE.Set_Token('NAME', p_query_name);
                             FND_MESSAGE.Set_Token('ID', l_sec_int_code_id);
                             FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                            l_warning := 'Y';
                            exit;
                        end if;
                    else
                        Open C_Get_Product_Cat_Id(scr.parameter_value);
                        Fetch C_Get_Product_Cat_Id into l_product_cat_id, l_product_cat_set_id;

                        if C_Get_Product_Cat_Id%NOTFOUND THEN
                            close C_Get_Product_Cat_Id;

                            -- 'Warning! Ignoring query ' || p_query_name || '(Found Invalid interest type id ' || scr.parameter_value || ')'
                            FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING1');
                            FND_MESSAGE.Set_Token('NAME', p_query_name);
                            FND_MESSAGE.Set_Token('ID', scr.parameter_value);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                            l_warning := 'Y';
                            exit;
                        end if;

                        close C_Get_Product_Cat_Id;
                        if ((l_product_cat_id IS NULL) OR (l_product_cat_set_id IS NULL)) then

                            -- 'Warning! Ignoring query ' || p_query_name || '(Interest type with id ' || scr.parameter_value || ' not mapped to any product category)'
                            FND_MESSAGE.Set_Name('AS', 'API_MIGRATION_WARNING2');
                            FND_MESSAGE.Set_Token('NAME', p_query_name);
                            FND_MESSAGE.Set_Token('ID', scr.parameter_value);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                            l_warning := 'Y';
                            exit;
                        end if;
                    end if;

                    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','product category id=' || l_product_cat_id || ', category set id='||l_product_cat_set_id);
                    END IF;

                    -- Set product category id in the JTF_PERZ_QUERY_PARAM table
                    Update JTF_PERZ_QUERY_PARAM P
                    set parameter_name = 'rep.ROW' || l_cnt2 || '.ProdCategory',
                    parameter_value = l_product_cat_id
                    where
                    P.query_param_id = scr.query_param_id;
                elsif (instr(scr.parameter_name, '.Invt') > 0) then
                    l_index := instr(scr.parameter_name, '.Invt');
                    l_cnt2 := substr(scr.parameter_name, 4, (l_index - 4));

                    -- Set name as rep.ROW0.invItem
                    Update JTF_PERZ_QUERY_PARAM P
                    set parameter_name = 'rep.ROW' || l_cnt2 || '.invItem'
                    where
                    P.query_param_id = scr.query_param_id;
                elsif (instr(scr.parameter_name, 'invItemID') > 0) then
                    l_index := length('invItemID');
                    l_cnt2 := substr(scr.parameter_name, l_index+1);

                    -- Set name as rep.ROW0.invItemID
                    Update JTF_PERZ_QUERY_PARAM P
                    set parameter_name = 'rep.ROW' || l_cnt2 || '.invItemID'
                    where
                    P.query_param_id = scr.query_param_id;
                end if;

                End;
            end if;
        end if; -- end if (scr.parameter_type = 'condition')

    end loop;

    if (l_warning = 'Y') then
        ROLLBACK TO Process_Perz_Query_Params;
        x_ret_sts_warning := 'Y';
    end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured while processing query_id='||p_query_id);
    RAISE;
END Process_Perz_Query_Params;

/*
Migrate product_category_id and product_cat_set_id into AS_LEAD_LINES_ALL table
*/
PROCEDURE Migrate_AS_LEAD_LINES_ALL(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    l_lead_lines_biud       BOOLEAN := true;
    l_lead_lines_after_biud BOOLEAN := true;
    l_sales_credits_biud    BOOLEAN := true;
    l_sales_credits_after_biud BOOLEAN := true;

    CURSOR Get_Min_Id IS
    select  min(lead_line_id)
    from  as_lead_lines_all;

    CURSOR Get_Max_Id IS
    select  max(lead_line_id)
    from  as_lead_lines_all;

    CURSOR Get_Next_Val IS
    select AS_LEAD_LINES_S.nextval
    from dual;

    CURSOR Get_Disabled_Triggers(c_schema_name VARCHAR2) IS
    select trigger_name
    from all_triggers
    where table_owner = c_schema_name
    and trigger_name IN ('AS_LEAD_LINES_BIUD','AS_LEAD_LINES_AFTER_BIUD','AS_SALES_CREDITS_BIUD','AS_SALES_CREDITS_AFTER_BIUD')
    and nvl(status,'DISABLED')<>'ENABLED';


BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Opportunity Lines');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    -- First find out the existing state of the triggers
    FOR scr in Get_Disabled_Triggers(G_SCHEMA_NAME)
    LOOP
        if (scr.trigger_name = 'AS_LEAD_LINES_BIUD') then
            l_lead_lines_biud := false;
            IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Trigger AS_LEAD_LINES_BIUD is already disabled');
            end if;
        elsif (scr.trigger_name = 'AS_LEAD_LINES_AFTER_BIUD') then
            l_lead_lines_after_biud := false;
            IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Trigger AS_LEAD_LINES_AFTER_BIUD is already disabled');
            end if;
        elsif (scr.trigger_name = 'AS_SALES_CREDITS_BIUD') then
            l_sales_credits_biud := false;
            IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Trigger AS_SALES_CREDITS_BIUD is already disabled');
            end if;
        elsif (scr.trigger_name = 'AS_SALES_CREDITS_AFTER_BIUD') then
            l_sales_credits_after_biud := false;
            IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Trigger AS_SALES_CREDITS_AFTER_BIUD is already disabled');
            end if;
        end if;
    END LOOP;


    -- Disable all the triggers
    Disable_Triggers;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
    end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_LEAD_LINES_ALL','LEAD_LINE_ID,INTEREST_TYPE_ID,PRIMARY_INTEREST_CODE_ID,SECONDARY_INTEREST_CODE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update as_lead_lines_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
        where l.lead_line_id >= l_count
        and l.lead_line_id < l_count+G_BATCH_SIZE
        and l.interest_type_id is not null
        and l.primary_interest_code_id is null
        and l.secondary_interest_code_id is null;

        -- Update primary interest code
        update as_lead_lines_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.primary_interest_code_id = int.interest_code_id)
        where l.lead_line_id >= l_count
        and l.lead_line_id < l_count+G_BATCH_SIZE
        and l.primary_interest_code_id is not null
        and l.secondary_interest_code_id is null;

        -- Update secondary interest code
        update as_lead_lines_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.secondary_interest_code_id = int.interest_code_id)
        where l.lead_line_id >= l_count
        and l.lead_line_id < l_count+G_BATCH_SIZE
        and l.secondary_interest_code_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_LEAD_LINES_ALL',l_debug);

    -- Enable All the triggers
    Enable_Triggers(l_lead_lines_biud,l_lead_lines_after_biud,l_sales_credits_biud,l_sales_credits_after_biud);


    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Opportunity Lines finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in opportunity lines data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    -- Enable All the triggers (even in case of exception)
    Enable_Triggers(l_lead_lines_biud,l_lead_lines_after_biud,l_sales_credits_biud,l_sales_credits_after_biud);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_LEAD_LINES_ALL;

/*
Migrate product_category_id and product_cat_set_id into AS_FST_SALES_CATEGORIES table
*/
PROCEDURE Migrate_FST_SALES_CATEGORIES(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    CURSOR Get_Min_Id IS
    select  min(fst_sales_category_id)
    from  as_fst_sales_categories;

    CURSOR Get_Max_Id IS
    select  max(fst_sales_category_id)
    from  as_fst_sales_categories;

    CURSOR Get_Next_Val IS
    select AS_FST_SALES_CATEGORIES_S.nextval
    from dual;

BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Forecast Categories');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

     IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
     end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_FST_SALES_CATEGORIES','FST_SALES_CATEGORY_ID,INTEREST_TYPE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update as_fst_sales_categories l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
        where l.fst_sales_category_id >= l_count
        and l.fst_sales_category_id < l_count+G_BATCH_SIZE
        and l.interest_type_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_FST_SALES_CATEGORIES',l_debug);

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Forecast Categories finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in forecast category data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_FST_SALES_CATEGORIES;

/*
Migrate product_category_id and product_cat_set_id into AS_INTERESTS_ALL table
*/
PROCEDURE Migrate_AS_INTERESTS_ALL(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    CURSOR Get_Min_Id IS
    select  min(interest_id)
    from  as_interests_all;

    CURSOR Get_Max_Id IS
    select  max(interest_id)
    from  as_interests_all;

    CURSOR Get_Next_Val IS
    select AS_INTERESTS_S.nextval
    from dual;

BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Product Interests');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
    end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_INTERESTS_ALL','INTEREST_ID,INTEREST_TYPE_ID,PRIMARY_INTEREST_CODE_ID,SECONDARY_INTEREST_CODE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update as_interests_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
        where l.interest_id >= l_count
        and l.interest_id < l_count+G_BATCH_SIZE
        and l.interest_type_id is not null
        and l.primary_interest_code_id is null
        and l.secondary_interest_code_id is null;

        -- Update primary interest code
        update as_interests_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.primary_interest_code_id = int.interest_code_id)
        where l.interest_id >= l_count
        and l.interest_id < l_count+G_BATCH_SIZE
        and l.primary_interest_code_id is not null
        and l.secondary_interest_code_id is null;

        -- Update secondary interest code
        update as_interests_all l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.secondary_interest_code_id = int.interest_code_id)
        where l.interest_id >= l_count
        and l.interest_id < l_count+G_BATCH_SIZE
        and l.secondary_interest_code_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_INTERESTS_ALL',l_debug);

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Product Interests finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in product interests data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_INTERESTS_ALL;

/*
Migrate product_category_id and product_cat_set_id into AS_LEAD_LINES_LOG table
*/
PROCEDURE Migrate_AS_LEAD_LINES_LOG(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    CURSOR Get_Min_Id IS
    select  min(log_id)
    from  as_lead_lines_log;

    CURSOR Get_Max_Id IS
    select  max(log_id)
    from  as_lead_lines_log;

    CURSOR Get_Next_Val IS
    select AS_LEAD_LINES_LOG_S.nextval
    from dual;

BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Opportunity Logs');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
    end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_LEAD_LINES_LOG','LOG_ID,INTEREST_TYPE_ID,PRIMARY_INTEREST_CODE_ID,SECONDARY_INTEREST_CODE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update as_lead_lines_log l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
        where l.log_id >= l_count
        and l.log_id < l_count+G_BATCH_SIZE
        and l.interest_type_id is not null
        and l.primary_interest_code_id is null
        and l.secondary_interest_code_id is null;

        -- Update primary interest code
        update as_lead_lines_log l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.primary_interest_code_id = int.interest_code_id)
        where l.log_id >= l_count
        and l.log_id < l_count+G_BATCH_SIZE
        and l.primary_interest_code_id is not null
        and l.secondary_interest_code_id is null;

        -- Update secondary interest code
        update as_lead_lines_log l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.secondary_interest_code_id = int.interest_code_id)
        where l.log_id >= l_count
        and l.log_id < l_count+G_BATCH_SIZE
        and l.secondary_interest_code_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_LEAD_LINES_LOG',l_debug);

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Opportunity Logs finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in opportunity logs data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_LEAD_LINES_LOG;

/*
Migrate product_category_id and product_cat_set_id into AS_SALES_CREDITS_DENORM table
*/
PROCEDURE Migrate_AS_SALES_C_DENORM(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    CURSOR Get_Min_Id IS
    select  min(sales_credit_id)
    from  as_sales_credits_denorm;

    CURSOR Get_Max_Id IS
    select  max(sales_credit_id)
    from  as_sales_credits_denorm;

    CURSOR Get_Next_Val IS
    select AS_SALES_CREDITS_S.nextval
    from dual;

BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Sales Credits');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
    end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_SALES_CREDITS_DENORM','SALES_CREDIT_ID,INTEREST_TYPE_ID,PRIMARY_INTEREST_CODE_ID,SECONDARY_INTEREST_CODE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update as_sales_credits_denorm l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
        where l.sales_credit_id >= l_count
        and l.sales_credit_id < l_count+G_BATCH_SIZE
        and nvl(l.interest_type_id,-1) <> -1
        and nvl(l.primary_interest_code_id,-1) = -1
        and nvl(l.secondary_interest_code_id,-1) = -1;

        -- Update primary interest code
        update as_sales_credits_denorm l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.primary_interest_code_id = int.interest_code_id)
        where l.sales_credit_id >= l_count
        and l.sales_credit_id < l_count+G_BATCH_SIZE
        and nvl(l.primary_interest_code_id,-1) <> -1
        and nvl(l.secondary_interest_code_id,-1) = -1;

        -- Update secondary interest code
        update as_sales_credits_denorm l
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.secondary_interest_code_id = int.interest_code_id)
        where l.sales_credit_id >= l_count
        and l.sales_credit_id < l_count+G_BATCH_SIZE
        and nvl(l.secondary_interest_code_id,-1) <> -1;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_SALES_CREDITS_DENORM',l_debug);

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Sales Credits finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in sales credits data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_SALES_C_DENORM;

/*
Migrate product_category_id and product_cat_set_id into AS_OPP_WORKSHEET_LINES table
Since table has been not used in R12  so we need to obsolete Migrate_AS_OPPWKS_LINES procedure
*/

PROCEDURE Migrate_AS_PRODWKS_LINES(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_count  NUMBER := 0;
    l_min_id NUMBER := 0;
    l_max_id NUMBER := 0;
    l_status BOOLEAN;
    l_debug  BOOLEAN := false;

    CURSOR Get_Min_Id IS
    select  min(PROD_WORKSHEET_LINE_ID)
    from  AS_PROD_WORKSHEET_LINES;

    CURSOR Get_Max_Id IS
    select  max(PROD_WORKSHEET_LINE_ID)
    from  AS_PROD_WORKSHEET_LINES;

    CURSOR Get_Next_Val IS
    select AS_PROD_WORKSHEET_LINES_S.nextval
    from dual;

BEGIN
    -- First load the schema name
    Load_Schema_Name;

    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Forecast Product Worksheet');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;

    open Get_Min_Id;
    fetch Get_Min_Id into l_min_id;
    close Get_Min_Id;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Minimum Id found:' || l_min_id);
    end if;

    open Get_Next_Val;
    fetch Get_Next_Val into l_max_id;
    close Get_Next_Val;

    IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Maximum Id found:' || l_max_id);
    end if;

    -- Create temporary index to improve the performance
    Create_Temp_Index('AS_PROD_WORKSHEET_LINES','PROD_WORKSHEET_LINE_ID,INTEREST_TYPE_ID',l_debug);

    -- Initialize counter
    l_count := l_min_id;

    while (l_count <= l_max_id)
    loop
        IF (l_debug) and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) Then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Current loop count:' || l_count);
        end if;

        -- Update interest type
        update AS_PROD_WORKSHEET_LINES pwl
        set (product_category_id, product_cat_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where pwl.interest_type_id = int.interest_type_id)
        where pwl.PROD_WORKSHEET_LINE_ID >= l_count
        and pwl.PROD_WORKSHEET_LINE_ID < l_count+G_BATCH_SIZE
        and pwl.interest_type_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    end loop;
    commit;

    -- Drop temporary index
    Drop_Temp_Index('AS_PROD_WORKSHEET_LINES',l_debug);

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for Forecast Product Worksheet finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in forecast product worksheet data migration '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_PRODWKS_LINES;

/*
Migrate product_category_id and product_cat_set_id into AS_PE_INT_CATEGORIES table
*/
PROCEDURE Migrate_AS_PE_INT_CATEGORIES(
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS
    l_debug BOOLEAN;
    l_status BOOLEAN;


BEGIN
    -- Note: We are not using any detailed performance "batching" since this table
    --       in most implementation will contain less than 1000 rows.


    if (upper(p_Debug_Flag) = 'Y') then
        l_debug := true;
    end if;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration started for Plan Element Categories');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;


        -- Update interest type
                update as_pe_int_categories l
                set (product_category_id, product_cat_set_id) =
                        (select int.product_category_id, int.product_cat_set_id
                        from as_interest_types_b int
                        where l.interest_type_id = int.interest_type_id)
                where nvl(l.interest_type_id,-1) <> -1
                and nvl(l.pri_interest_code_id,-1) = -1
                and nvl(l.sec_interest_code_id,-1) = -1;

                -- Update primary interest code
                update as_pe_int_categories l
                set (product_category_id, product_cat_set_id) =
                        (select int.product_category_id, int.product_cat_set_id
                        from as_interest_codes_b int
                        where l.pri_interest_code_id = int.interest_code_id)
                where nvl(l.pri_interest_code_id,-1) <> -1
                and nvl(l.sec_interest_code_id,-1) = -1;

                -- Update secondary interest code
                update as_pe_int_categories l
                set (product_category_id, product_cat_set_id) =
                        (select int.product_category_id, int.product_cat_set_id
                        from as_interest_codes_b int
                        where l.sec_interest_code_id = int.interest_code_id)
                where nvl(l.sec_interest_code_id,-1) <> -1;

        -- commit after each batch
        commit;

    If l_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Migration for OIC Plan Elements finished successfully');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;
    RETCODE := FND_API.G_RET_STS_ERROR;
    ERRBUF := 'Error in plan element categories '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);
    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, cannot complete Concurrent Program') ;
    END IF ;
END Migrate_AS_PE_INT_CATEGORIES;

/*
Enable the following triggers
a) AS_LEAD_LINES_BIUD
b) AS_LEAD_LINES_AFTER_BIUD
c) AS_SALES_CREDITS_BIUD
d) AS_SALES_CREDITS_AFTER_BIUD
*/
PROCEDURE Enable_Triggers(p_lead_lines_biud IN BOOLEAN,
                          p_lead_lines_after_biud IN BOOLEAN,
                          p_sales_credits_biud IN BOOLEAN,
                          p_sales_credits_after_biud IN BOOLEAN) IS
BEGIN
    -- Enable All the triggers
    if (p_lead_lines_biud) then
        EXECUTE IMMEDIATE('Alter trigger AS_LEAD_LINES_BIUD ENABLE');
    end if;

    if (p_lead_lines_after_biud) then
        EXECUTE IMMEDIATE('Alter trigger AS_LEAD_LINES_AFTER_BIUD ENABLE');
    end if;

    if (p_sales_credits_biud) then
        EXECUTE IMMEDIATE('Alter trigger AS_SALES_CREDITS_BIUD ENABLE');
    end if;

    if (p_sales_credits_after_biud) then
        EXECUTE IMMEDIATE('Alter trigger AS_SALES_CREDITS_AFTER_BIUD ENABLE');
    end if;
END Enable_Triggers;

/*
Disable the following triggers
a) AS_LEAD_LINES_BIUD
b) AS_LEAD_LINES_AFTER_BIUD
c) AS_SALES_CREDITS_BIUD
d) AS_SALES_CREDITS_AFTER_BIUD
*/
PROCEDURE Disable_Triggers IS
BEGIN
    -- Disable all the triggers
    EXECUTE IMMEDIATE('Alter trigger AS_LEAD_LINES_BIUD DISABLE');
    EXECUTE IMMEDIATE('Alter trigger AS_LEAD_LINES_AFTER_BIUD DISABLE');
    EXECUTE IMMEDIATE('Alter trigger AS_SALES_CREDITS_BIUD DISABLE');
    EXECUTE IMMEDIATE('Alter trigger AS_SALES_CREDITS_AFTER_BIUD DISABLE');
END Disable_Triggers;

PROCEDURE Load_Schema_Name IS
    l_status            VARCHAR2(2);
    l_industry          VARCHAR2(2);
    l_oracle_schema     VARCHAR2(32) := 'OSM';
    l_schema_return     BOOLEAN;
BEGIN
  if (G_SCHEMA_NAME is null) then
      l_schema_return := FND_INSTALLATION.get_app_info('AS', l_status, l_industry, l_oracle_schema);
      G_SCHEMA_NAME := l_oracle_schema;
  end if;
END;

PROCEDURE Create_Temp_Index(p_table   IN VARCHAR2,
                      p_index_columns IN VARCHAR2,
                      p_debug IN BOOLEAN) IS
       l_check_tspace_exist varchar2(100);
       l_index_tablespace varchar2(100);
       l_sql_stmt         varchar2(2000);
       l_user             varchar2(2000);
       l_index_name       varchar2(100);

begin
       --execute immediate 'alter session set events ''10046 trace name context forever, level 12''';

       -----------------
       -- Create index--
       -----------------

       l_user := USER;

       if p_debug and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','User is:' || l_user);
       end if;

       -- Name for temporary index created for migration
       l_index_name := p_table || G_INDEX_SUFFIX;

       AD_TSPACE_UTIL.get_tablespace_name('AS', 'TRANSACTION_INDEXES','N',l_check_tspace_exist,l_index_tablespace);

       l_sql_stmt :=    'create index ' || l_index_name || ' on '
                     || G_SCHEMA_NAME||'.'
                     || p_table || '(' || p_index_columns || ') '
                     ||' tablespace ' || l_index_tablespace || '  nologging '
                     ||'parallel 8';
       execute immediate l_sql_stmt;

       --------------------
       -- convert to no||--
       --------------------
       l_sql_stmt := 'alter index '|| l_user ||'.' || l_index_name || ' noparallel ';
       execute immediate l_sql_stmt;


       -----------------
       -- Gather Stats--
       -----------------
       dbms_stats.gather_index_stats(l_user,l_index_name,estimate_percent => 10);

       if p_debug and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Created temporary index:' || l_index_name);
       end if;
END Create_Temp_Index;

PROCEDURE Drop_Temp_Index(p_table  IN VARCHAR2,
                          p_debug IN BOOLEAN) IS
       l_sql_stmt         varchar2(2000);
       l_index_name       varchar2(100);
       l_user             varchar2(2000);
begin
       -----------------
       -- Drop index  --
       -----------------
       l_user := USER;

       -- Name for temporary index created for migration
       l_index_name := p_table || G_INDEX_SUFFIX;

       l_sql_stmt := 'drop index ' || l_user||'.' || l_index_name || ' ';

       execute immediate l_sql_stmt;

       if p_debug and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmintb','Dropped temporary index:' || l_index_name);
       end if;
END Drop_Temp_Index;

/*  For testing purposes we can use the following statements.
    Change the date as per requirements.
update as_lead_lines_all set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_interests_all set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_sales_credits_denorm set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_lead_lines_log set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_fst_sales_categories set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_opp_worksheet_lines set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
update as_prod_worksheet_lines set product_category_id=null,product_cat_set_id=null where nvl(interest_type_id,-1)<>-1;
commit;
*/

END AS_INT_TYP_COD_MIGRATION;

/
