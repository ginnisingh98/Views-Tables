--------------------------------------------------------
--  DDL for Package Body AS_CATALOG_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_CATALOG_MIGRATION" as
/* $Header: asxmcatb.pls 120.4 2005/12/15 23:03:15 sumani noship $ */

--*****************************************************************************
-- GLOBAL VARIABLES AND CONSTANTS
--
    -- This variable is used to store the inventory create api version numbers.
    G_CREATE_CAT_API_VER NUMBER := 1.0;

    -- This variable is used to store the application id for ASF
    G_APPLICATION_ID NUMBER := 522;

    -- Category Set Control Levels
    G_CONTROL_LEVEL_MASTER   NUMBER   := 1;
    G_CONTROL_LEVEL_ORG      NUMBER   := 2;

    G_DEBUG BOOLEAN := false;

    -- Functional area for product catalog
    G_FUNCTIONAL_AREA Constant NUMBER := 11;

    G_SME_CATEGORY_SET_NAME Constant Varchar2(20) := 'SME Product Catalog';

    G_PKG_NAME Constant Varchar2(22) := 'AS_CATALOG_MIGRATION';

--*****************************************************************************
-- Declarations
--
TYPE Name_Count_Tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE Process_Categories(p_int_typ_cod_id       IN NUMBER,
                             p_structure_id         IN NUMBER,
                             p_old_structure_id     IN NUMBER,
                             p_category_set_id      IN NUMBER,
                             p_control_level        IN NUMBER,
                             p_mult_item_cat_assign_flag IN VARCHAR2,
                             p_parent_category_id   IN NUMBER,
                             p_category_name        IN VARCHAR2,
                             p_description          IN VARCHAR2,
                             p_interest_level       IN NUMBER,
                             p_expected_purchase    IN VARCHAR2,
                             p_level0_enabled_flag  IN VARCHAR2,
                             p_level1_enabled_flag  IN VARCHAR2,
                             p_level2_enabled_flag  IN VARCHAR2,
                             p_attr_group_id        IN NUMBER,
                             p_name_count_tab       IN OUT NOCOPY Name_Count_Tab,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count            OUT NOCOPY NUMBER,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_category_id          OUT NOCOPY NUMBER,
                             x_warning_flag         OUT NOCOPY VARCHAR2);

PROCEDURE Check_Duplicate_Category(
                    x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE Find_Duplicate_Category_Id(
                             p_structure_id         IN NUMBER,
                             p_category_name        IN VARCHAR2,
                             x_category_id          OUT NOCOPY NUMBER
                             );
PROCEDURE Create_SME_Category_Set(x_category_set_id OUT NOCOPY NUMBER);
PROCEDURE Attach_SME_Set_To_Func_Area(p_category_set_id IN NUMBER);
PROCEDURE Make_SME_Set_Hierarchical(p_category_set_id IN NUMBER);
PROCEDURE Retrieve_Category_Set(x_category_set_id OUT NOCOPY NUMBER,
                                x_warning_flag         OUT NOCOPY VARCHAR2);
PROCEDURE Pre_Process_Categories(p_name_count_tab IN OUT NOCOPY Name_Count_Tab,
                                 p_category_name  IN VARCHAR2,
                                 p_create_legacy  IN VARCHAR2,
                                 x_category_name        OUT NOCOPY VARCHAR2,
                                 x_legacy_category_name OUT NOCOPY VARCHAR2,
                                 x_warning_flag         OUT NOCOPY VARCHAR2);

PROCEDURE Trunc_Name(p_name         IN VARCHAR2,
                     p_trunc_length IN NUMBER,
                     x_trunc_name   OUT NOCOPY VARCHAR2);

PROCEDURE Grant_Access_To_Catalog(p_category_set_id IN NUMBER,
                                  x_warning_flag    OUT NOCOPY VARCHAR2);

PROCEDURE Assign_Item_To_Category(p_category_set_id      IN NUMBER,
                                  p_organization_id      IN NUMBER,
                                  p_inventory_item_id    IN NUMBER,
                                  p_category_id          IN NUMBER,
                                  p_control_level        IN NUMBER,
                                  p_mult_item_cat_assign_flag IN VARCHAR2,
                                  x_return_status        OUT NOCOPY VARCHAR2,
                                  x_errorcode            OUT NOCOPY NUMBER,
                                  x_msg_count            OUT NOCOPY NUMBER,
                                  x_msg_data             OUT NOCOPY VARCHAR2);

PROCEDURE Cleanup_Legacy_Categories(p_category_set_id IN NUMBER,
                                    p_category_id   IN NUMBER);
--*****************************************************************************
-- Public API
--

/*
This procedure creates new categories corresponding to interest types/codes
if required and then map these categories to interest types/codes. It will also
associate items to these newly created categories based on the old association
between items and interest types/codes
This will be called by concurrent program 'Product Catalog Mapping'
*/
PROCEDURE Migrate_Categories (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    ) IS

--      Variables
    l_Debug_Flag    VARCHAR2(12);    l_count  NUMBER := 0;
    l_old_category_id NUMBER := 0;
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(1);    -- Local return status equal to p_return_status
    l_structure_id NUMBER;
    l_old_structure_id NUMBER;
    l_category_set_id NUMBER;
    l_int_type_cat_id NUMBER;
    l_pri_int_code_cat_id NUMBER;
    l_sec_int_code_cat_id NUMBER;
    l_control_level NUMBER;
    l_status BOOLEAN;
    l_attr_group_id       NUMBER;
    l_val                 NUMBER;
    l_warning             VARCHAR2(1) := 'N';
    l_warning_flag        VARCHAR2(1) := 'N';
    l_category_name       VARCHAR2(120);
    l_name_count_tab      Name_Count_Tab;
    l_mult_item_cat_assign_flag VARCHAR2(1);

--      Cursors
    CURSOR C_Get_Int_Type IS
        select B.interest_type_id, TL.interest_type, TL.description, B.Expected_Purchase_Flag,B.enabled_flag
        from as_interest_types_b B, as_interest_types_tl TL
        where B.interest_type_id = TL.interest_type_id
        and TL.language = userenv('LANG');


    CURSOR C_Get_Pri_Int_Code(c_interest_type_id Number) IS
        select B.interest_code_id, TL.code, TL.description,B.enabled_flag
        from as_interest_codes_b B, as_interest_codes_tl TL
        where B.interest_code_id = TL.interest_code_id
        and TL.language = userenv('LANG')
        and B.interest_type_id = c_interest_type_id
        and B.parent_interest_code_id is null;

    CURSOR C_Get_Sec_Int_Code(c_interest_code_id Number) IS
        select B.interest_code_id, TL.code, TL.description,B.enabled_flag
        from as_interest_codes_b B, as_interest_codes_tl TL
        where B.interest_code_id = TL.interest_code_id
        and TL.language = userenv('LANG')
        and B.parent_interest_code_id = c_interest_code_id;

BEGIN
    fnd_profile.put('AFLOG_ENABLED', 'Y');
    fnd_profile.put('AFLOG_LEVEL', '1');
    if (upper(p_Debug_Flag) = 'Y') then
        G_DEBUG := true;
    end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Category mapping started');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    -- Initialize retcode to success
    RETCODE := FND_API.G_RET_STS_SUCCESS;

    -- Retrieve the category set id for SME Product Catalog
    Retrieve_Category_Set(x_category_set_id => l_category_set_id,
                          x_warning_flag    => l_warning_flag);

    if (l_warning_flag = 'Y') then
        l_warning := 'Y';
    end if;

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Parameters are as below:');
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(a) New Category Set Id   =   ' || l_category_set_id);
    end if;

    BEGIN
        -- Get structure id corresponding to Product Catalog
        select C.structure_id,C.control_level,C.mult_item_cat_assign_flag
        into l_structure_id, l_control_level, l_mult_item_cat_assign_flag
        from MTL_CATEGORY_SETS C where C.category_set_id = l_category_set_id;

    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Unable to find structure id corresponding to Product Catalog');
            RAISE;
    END;

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(b) New Control Level     =   ' || l_control_level);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(c) New Structure Id      =   ' || l_structure_id);
    end if;

    BEGIN
            -- Get structure id corresponding to sales and marketing category set
            select FIFS.ID_FLEX_NUM into l_old_structure_id
            from FND_ID_FLEX_STRUCTURES FIFS
            where FIFS.ID_FLEX_CODE = 'MCAT' AND FIFS.APPLICATION_ID = 401  AND FIFS.ID_FLEX_STRUCTURE_CODE = 'SALES_CATEGORIES';
    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Unable to find structure id corresponding to sales and marketing category set');
            RAISE;
    END;

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(d) Old Structure Id      =   ' || l_old_structure_id);
    end if;

    BEGIN
        -- EGO Application Id is 431
        SELECT ATTR_GROUP_ID INTO l_attr_group_id FROM EGO_FND_DSC_FLX_CTX_EXT WHERE APPLICATION_ID = 431 AND DESCRIPTIVE_FLEXFIELD_NAME = 'EGO_PRODUCT_CATEGORY_SET' AND DESCRIPTIVE_FLEX_CONTEXT_CODE = 'SalesAndMarketing';
    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Unable to find attribute group for Sales and Marketing');
            RAISE;
    END;

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(e) Attribute Group Id    =   ' || l_attr_group_id);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','(f) Multiple Item Category Assignment Flag    =   ' || l_mult_item_cat_assign_flag);
    end if;

    BEGIN
    -- For each interest type
    FOR scr in C_Get_Int_Type
    LOOP
        FND_MESSAGE.Set_Name('AS', 'API_PROCESSING_INTEREST_TYPE');
        FND_MESSAGE.Set_Token('NAME', scr.interest_type);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'->' || FND_MESSAGE.Get());

        -- Create Mtl categories and associate to inventory items
        Process_Categories(p_int_typ_cod_id     => scr.interest_type_id,
                           p_structure_id       => l_structure_id,
                           p_old_structure_id   => l_old_structure_id,
                           p_category_set_id    => l_category_set_id,
                           p_control_level      => l_control_level,
                           p_mult_item_cat_assign_flag => l_mult_item_cat_assign_flag,
                           p_parent_category_id => null,
                           p_category_name      => scr.interest_type,
                           p_description        => scr.description,
                           p_interest_level     => 0,
                           p_expected_purchase  => scr.expected_purchase_flag,
                           p_level0_enabled_flag => scr.enabled_flag,
                           p_level1_enabled_flag => scr.enabled_flag,
                           p_level2_enabled_flag => scr.enabled_flag,
                           p_attr_group_id      => l_attr_group_id,
                           p_name_count_tab     => l_name_count_tab,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           x_category_id        => l_int_type_cat_id,
                           x_warning_flag       => l_warning_flag);

        if (l_warning_flag = 'Y') then
            l_warning := 'Y';
            GOTO end_loop1;
        end if;

        -- Update the mapping between interest type and product category
        Update AS_INTEREST_TYPES_B set product_category_id = l_int_type_cat_id, product_cat_set_id = l_category_set_id where interest_type_id = scr.interest_type_id;

        -- For each primary interest code corresponding to selected interest type
        FOR scr2 in C_Get_Pri_Int_Code(scr.interest_type_id)
        LOOP
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Now processing primary interest code '||scr2.code);
            end if;

            -- Create Mtl categories and associate to inventory items
            Process_Categories(p_int_typ_cod_id     => scr2.interest_code_id,
                               p_structure_id       => l_structure_id,
                               p_old_structure_id   => l_old_structure_id,
                               p_category_set_id    => l_category_set_id,
                               p_control_level      => l_control_level,
                               p_mult_item_cat_assign_flag => l_mult_item_cat_assign_flag,
                               p_parent_category_id => l_int_type_cat_id,
                               p_category_name      => scr2.code,
                               p_description        => scr2.description,
                               p_interest_level     => 1,
                               p_expected_purchase  => scr.expected_purchase_flag,
                               p_level0_enabled_flag => scr.enabled_flag,
                               p_level1_enabled_flag => scr2.enabled_flag,
                               p_level2_enabled_flag => scr2.enabled_flag,
                               p_attr_group_id   => l_attr_group_id,
                               p_name_count_tab     => l_name_count_tab,
                               x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg_data,
                               x_category_id        => l_pri_int_code_cat_id,
                               x_warning_flag       => l_warning_flag);

            if (l_warning_flag = 'Y') then
                l_warning := 'Y';
                GOTO end_loop2;
            end if;

             -- Update the mapping between primary interest code and product category
             Update AS_INTEREST_CODES_B set product_category_id = l_pri_int_code_cat_id, product_cat_set_id = l_category_set_id where interest_code_id = scr2.interest_code_id;

             -- For each secondary interest code corresponding to selected primary interest code
             FOR scr3 in C_Get_Sec_Int_Code(scr2.interest_code_id)
             LOOP
                IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Now processing secondary interest code '||scr3.code);
                end if;

                -- Create Mtl categories and associate to inventory items
                Process_Categories(p_int_typ_cod_id     => scr3.interest_code_id,
                                   p_structure_id       => l_structure_id,
                                   p_old_structure_id   => l_old_structure_id,
                                   p_category_set_id    => l_category_set_id,
                                   p_control_level      => l_control_level,
                                   p_mult_item_cat_assign_flag => l_mult_item_cat_assign_flag,
                                   p_parent_category_id => l_pri_int_code_cat_id,
                                   p_category_name      => scr3.code,
                                   p_description        => scr3.description,
                                   p_interest_level     => 2,
                                   p_expected_purchase  => scr.expected_purchase_flag,
                                   p_level0_enabled_flag => scr.enabled_flag,
                                   p_level1_enabled_flag => scr2.enabled_flag,
                                   p_level2_enabled_flag => scr3.enabled_flag,
                                   p_attr_group_id      => l_attr_group_id,
                                   p_name_count_tab     => l_name_count_tab,
                                   x_return_status      => l_return_status,
                                   x_msg_count          => l_msg_count,
                                   x_msg_data           => l_msg_data,
                                   x_category_id        => l_sec_int_code_cat_id,
                                   x_warning_flag       => l_warning_flag);

                if (l_warning_flag = 'Y') then
                    l_warning := 'Y';
                    GOTO end_loop3;
                end if;

                 -- Update the mapping between secondary interest code and product category
                 Update AS_INTEREST_CODES_B set product_category_id = l_sec_int_code_cat_id, product_cat_set_id = l_category_set_id where interest_code_id = scr3.interest_code_id;
             <<end_loop3>>
             NULL;
             END LOOP;
        <<end_loop2>>
        NULL;
        END LOOP;
    <<end_loop1>>
    NULL;
    END LOOP;
    END;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Category mapping finished successfully');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

    COMMIT;

    if (l_warning = 'Y') then
        l_status := fnd_concurrent.set_completion_status('WARNING',FND_MESSAGE.Get_String('AS','API_REQUEST_WARNING_STATUS'));
    end if;
EXCEPTION
  WHEN OTHERS THEN
    Rollback;

    RETCODE := FND_API.G_RET_STS_ERROR;

    l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
    IF l_status = TRUE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error, can not complete Concurrent Program') ;
    END IF ;

    ERRBUF := 'Error in category mapping '||SQLERRM;
    FND_FILE.PUT_LINE(FND_FILE.LOG,ERRBUF);

     fnd_msg_pub.count_and_get( p_encoded    => 'F'
      , p_count      => l_msg_count
      , p_data        => l_msg_data);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Return Status:' || nvl(l_return_status,'xxx'));
    --=================message display part begins
     for k in 1 .. l_msg_count loop
       l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                       p_encoded => 'F'
                                      );
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Error msg: '||substr(l_msg_data,1,240));
       ERRBUF := substr(ERRBUF || ';Error msg: '|| l_msg_data,1,3900);
      end loop;
    --=================message display part ends

End Migrate_Categories;

--*****************************************************************************
-- Private API
--

PROCEDURE Pre_Process_Categories(p_name_count_tab IN OUT NOCOPY Name_Count_Tab,
                                 p_category_name  IN VARCHAR2,
                                 p_create_legacy  IN VARCHAR2,
                                 x_category_name        OUT NOCOPY VARCHAR2,
                                 x_legacy_category_name OUT NOCOPY VARCHAR2,
                                 x_warning_flag         OUT NOCOPY VARCHAR2) IS
l_name_hash_val  NUMBER;
l_category_name  VARCHAR2(35);
l_legacy_category_name VARCHAR2(28);
BEGIN

    -- Since there is limitation of 40 characters on size of category name (due to length of segment1),
    -- truncate the category name to 35 characters. Leave buffer of 5 characters to store the duplicate
    -- count if any .e,g, After truncation, you might have a category name as 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    -- and duplicate category with name as 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx(1)'. Thus leaving a buffer
    -- of 5 characters will allow 999 duplicates!
    -- Since number of bytes per character differ in different languages, the substr to 35 characters
    -- might return more than 35 bytes in languages other than english. There are two possible solutions
    -- to this problem:
    -- Solution1:
    -- Calculate the number of bytes/character and then calculate the actual number of characters to substring.
    -- To achieve this, we will first calculate the ratio bytes/char by dividing lengthb by length.
    -- Using this ratio, we will then calculate number of characters equivalent to 35 bytes and then
    -- do a substr based on this number(after truncating the decimal portion). The problem with this
    -- solution is that this wouldn't work for european languages since europen languages mix english
    -- and non-english characters. So one character might be 1 byte, whereas other might be 2 bytes. So
    -- it is not possible to get a correct bytes/char ratio. Solution1 can be implemented as:
    -- l_category_name := substr(p_category_name, 1, trunc((35/lengthb(p_category_name)) * length(p_category_name)));
    -- Solution2:
    -- We will do a substr to 35 characters and store it in varchar2(35). If it throws an exception,
    -- we will substring to 35/2 characters. If it still fails we try with 35/3 characters. If it still
    -- fails, we give a warning to the user to truncate manually. This solution will work fine for most
    -- languages. Hence we will use this solution here.

    BEGIN
        Trunc_Name(p_name           =>  p_category_name,
                   p_trunc_length   =>  35,
                   x_trunc_name     =>  l_category_name);
    EXCEPTION
        WHEN OTHERS THEN
            if (SQLCODE = '-6502') then
                -- Warning! Unable to create category for interest type/code as category name is too long.
                FND_MESSAGE.Set_Name('AS', 'API_WARNING_CREATE_CATEGORY');
                FND_MESSAGE.Set_Token('NAME', p_category_name);
                FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                x_warning_flag := 'Y';
                return;
            end if;
            RAISE;
    END;

    -- Append the count if duplicate found
    BEGIN
        -- Get the hash value of the category name
        l_name_hash_val := DBMS_UTILITY.GET_HASH_VALUE(l_category_name,1,10000000);
        p_name_count_tab(l_name_hash_val) := p_name_count_tab(l_name_hash_val) + 1;
        x_category_name := l_category_name || '(' || p_name_count_tab(l_name_hash_val) || ')';
    EXCEPTION
        -- NO_DATA_FOUND Exception implies that the name occurs for the very first time in array
        When NO_DATA_FOUND Then
            p_name_count_tab(l_name_hash_val) := 1;
            x_category_name := l_category_name;
    END;

    -- Now pre-process legacy categories
    IF (p_create_legacy = 'Y') THEN
        BEGIN
            Trunc_Name(p_name           =>  p_category_name,
                       p_trunc_length   =>  28,
                       x_trunc_name     =>  l_legacy_category_name);
        EXCEPTION
            WHEN OTHERS THEN
                if (SQLCODE = '-6502') then
                    -- Warning! Unable to create legacy category for interest type/code as legacy category name is too long.
                    FND_MESSAGE.Set_Name('AS', 'API_WARNING_CREATE_LEGACY');
                    FND_MESSAGE.Set_Token('NAME', p_category_name);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());

                    x_warning_flag := 'Y';
                    return;
                end if;
                RAISE;
        END;

        -- Append the count if duplicate found
        BEGIN
            -- Get the hash value of the category name
            l_name_hash_val := DBMS_UTILITY.GET_HASH_VALUE(l_legacy_category_name,1,10000000);
            p_name_count_tab(l_name_hash_val) := p_name_count_tab(l_name_hash_val) + 1;
            x_legacy_category_name := l_legacy_category_name || '(' || p_name_count_tab(l_name_hash_val) || ')' || ' LEGACY';
        EXCEPTION
            -- NO_DATA_FOUND Exception implies that the name occurs for the very first time in array
            When NO_DATA_FOUND Then
                p_name_count_tab(l_name_hash_val) := 1;
                x_legacy_category_name := l_legacy_category_name || ' LEGACY';
        END;
    END IF;


END Pre_Process_Categories;

PROCEDURE Trunc_Name(p_name         IN VARCHAR2,
                     p_trunc_length IN NUMBER,
                     x_trunc_name   OUT NOCOPY VARCHAR2) IS
BEGIN
    -- First Try
    x_trunc_name := substr(p_name, 1, p_trunc_length);
EXCEPTION
    WHEN OTHERS THEN
    if (SQLCODE = '-6502') then
        BEGIN
            -- Second Try
            x_trunc_name := substr(p_name, 1, trunc(p_trunc_length/2));
        EXCEPTION
            WHEN OTHERS THEN
            if (SQLCODE = '-6502') then
                BEGIN
                    -- Third and Final Try
                    x_trunc_name := substr(p_name, 1, trunc(p_trunc_length/3));
                EXCEPTION
                    WHEN OTHERS THEN
                    RAISE;
                END;
            else
                RAISE;
            end if;
         END;
    else
        RAISE;
    end if;
END;



PROCEDURE Retrieve_Category_Set(x_category_set_id OUT NOCOPY NUMBER,
                                x_warning_flag    OUT NOCOPY VARCHAR2) IS
    CURSOR C_Get_Cat_Set_Id IS
        select category_set_id, hierarchy_enabled
        from MTL_CATEGORY_SETS
        where category_set_name = G_SME_CATEGORY_SET_NAME;

    CURSOR C_Check_Functional_Area(c_category_set_id NUMBER) IS
        select 1
        from MTL_CATEGORY_SETS S, MTL_DEFAULT_CATEGORY_SETS D
        where S.category_set_id = D.category_set_id
        and D.functional_area_id = G_FUNCTIONAL_AREA
        and D.category_set_id = c_category_set_id;

    l_category_set_id   NUMBER;
    l_hierarchy_enabled VARCHAR2(1);
    l_val               NUMBER;
BEGIN
    OPEN C_Get_Cat_Set_Id;
    FETCH C_Get_Cat_Set_Id INTO l_category_set_id, l_hierarchy_enabled;
    IF C_Get_Cat_Set_Id%NOTFOUND THEN
        Close C_Get_Cat_Set_Id;
        Create_SME_Category_Set(x_category_set_id => l_category_set_id);
        Grant_Access_To_Catalog(l_category_set_id,x_warning_flag);
        Attach_SME_Set_To_Func_Area(l_category_set_id);
    ELSE
        Close C_Get_Cat_Set_Id;

        if (upper(l_hierarchy_enabled) <> 'Y') then
            Make_SME_Set_Hierarchical(l_category_set_id);
        end if;

        Grant_Access_To_Catalog(l_category_set_id,x_warning_flag);

        Open C_Check_Functional_Area(l_category_set_id);
        Fetch C_Check_Functional_Area into l_val;
        if C_Check_Functional_Area%NOTFOUND then
            Close C_Check_Functional_Area;
            Attach_SME_Set_To_Func_Area(l_category_set_id);
        else
            Close C_Check_Functional_Area;
        end if;
    END IF;
    x_category_set_id := l_category_set_id;
EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error occured while retrieving category set');
    RAISE;
END Retrieve_Category_Set;

PROCEDURE Create_SME_Category_Set(x_category_set_id OUT NOCOPY NUMBER) IS
    l_structure_id  NUMBER;
    l_control_level NUMBER;
    l_row_id        VARCHAR2(100);
    l_next_val      NUMBER;
BEGIN
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Creating Category Set');
    end if;

    -- Get structure id and control level associated with functional area 11
    select C.structure_id, C.control_level into l_structure_id, l_control_level
    from MTL_DEFAULT_CATEGORY_SETS D, MTL_CATEGORY_SETS C
    where D.functional_area_id = G_FUNCTIONAL_AREA and D.category_set_id = C.category_set_id;

    select MTL_CATEGORY_SETS_S.NEXTVAL into l_next_val from dual;

    MTL_CATEGORY_SETS_PKG.INSERT_ROW (
      X_ROWID => l_row_id,
      X_CATEGORY_SET_ID         => l_next_val,
      X_CATEGORY_SET_NAME       => G_SME_CATEGORY_SET_NAME,
      X_DESCRIPTION             => G_SME_CATEGORY_SET_NAME,
      X_STRUCTURE_ID            => l_structure_id,
      X_VALIDATE_FLAG           => 'Y',
      X_MULT_ITEM_CAT_ASSIGN_FLAG   => 'N',
      X_CONTROL_LEVEL_UPDT_FLAG     => 'N',
      X_MULT_ITEM_CAT_UPDT_FLAG     => 'N',
      X_VALIDATE_FLAG_UPDT_FLAG     => 'N',
      X_HIERARCHY_ENABLED           => 'Y',
      X_CONTROL_LEVEL               => l_control_level,
      X_DEFAULT_CATEGORY_ID         => null,
      X_LAST_UPDATE_DATE            => SYSDATE,
      X_LAST_UPDATED_BY             => 0,
      X_CREATION_DATE               => SYSDATE,
      X_CREATED_BY                  => 0,
      X_LAST_UPDATE_LOGIN           => 0 );

    x_category_set_id := l_next_val;
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Finished Creating Category Set');
    end if;
END Create_SME_Category_Set;

-- Grant catalog manager role for all users to SME Product Catalog
-- For more details refer script EGOCSGRA.sql
PROCEDURE Grant_Access_To_Catalog(p_category_set_id IN NUMBER,
                                  x_warning_flag    OUT NOCOPY VARCHAR2) IS
  l_catalog_manager_resp VARCHAR2(2000) := 'EGO_CATEGORY_SET_MANAGER';
  l_category_set_object VARCHAR2(2000) := 'EGO_CATEGORY_SET';
  l_instance_type VARCHAR2(2000) := 'INSTANCE';
  l_all_users_grantee_type VARCHAR2(2000) := 'GLOBAL';
  l_num_cat_set_grants NUMBER;

  x_grant_guid RAW(16);
  x_return_status VARCHAR2(1);
  x_errorcode VARCHAR2(1);

BEGIN

  SELECT count(*) into l_num_cat_set_grants
  FROM fnd_grants fg, fnd_objects fo
  WHERE fg.object_id = fo.object_id
  and fo.obj_name = l_category_set_object
  and fg.instance_pk1_value=p_category_set_id;


    IF l_num_cat_set_grants = 0  THEN

       IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Granting Access to Catalog');
       end if;

      fnd_grants_pkg.grant_function(
                   p_api_version        => 1.0,
                   p_menu_name          => l_catalog_manager_resp ,
                   p_object_name        => l_category_set_object,
                   p_instance_type      => l_instance_type,
                   p_instance_set_id    => null,
                   p_instance_pk1_value => p_category_set_id,
                   p_instance_pk2_value => null,
                   p_instance_pk3_value => null,
                   p_instance_pk4_value => null,
                   p_instance_pk5_value => null,
                   p_grantee_type       => l_all_users_grantee_type,
                   p_grantee_key        => null,
                   p_start_date         => sysdate,
                   p_end_date           => null,
                   p_program_name       => null,
                   p_program_tag        => null,
                   x_grant_guid         => x_grant_guid,
                   x_success            => x_return_status,
                   x_errorcode          => x_errorcode
               );

        if (x_return_status = FND_API.G_FALSE) then
            x_warning_flag := 'Y';

            -- Warning! Unable to grant access to catalog (Error code:' || x_errorcode || '). Please notify the administrator about this error.
            FND_MESSAGE.Set_Name('AS', 'API_WARNING_GRANT_CATALOG');
            FND_MESSAGE.Set_Token('ERRORCODE', x_errorcode);
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get());
        end if;

        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Grant guid=' || x_grant_guid);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Done Granting Access to Catalog');
        end if;
    END IF;
END Grant_Access_To_Catalog;

PROCEDURE Attach_SME_Set_To_Func_Area(p_category_set_id IN NUMBER) IS
BEGIN
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Attaching Category Set to functional area 11');
    end if;

    Update MTL_DEFAULT_CATEGORY_SETS
    set category_set_id = p_category_set_id
    where functional_area_id = G_FUNCTIONAL_AREA;

    -- If nothing updated then this is an error
    IF (SQL%NOTFOUND) THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'No functional area found corresponding to product catalog');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Done Attaching Category Set to functional area 11');
    end if;
END Attach_SME_Set_To_Func_Area;

PROCEDURE Make_SME_Set_Hierarchical(p_category_set_id IN NUMBER) IS
BEGIN
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Making SME set hierarchical');
    end if;

    Update Mtl_Category_Sets
    set hierarchy_enabled = 'Y'
    where category_set_id = p_category_set_id;
END Make_SME_Set_Hierarchical;

/*
This procedure creates new MTL categories corresponding to the interest type/code passed in.
It creates/updates records in following MTL tables:
a) MTL_CATEGORIES_B
b) MTL_CATEGORIES_TL
c) MTL_CATEGORY_SET_VALID_CATS
d) MTL_ITEM_CATEGORIES
*/
PROCEDURE Process_Categories(p_int_typ_cod_id       IN NUMBER,
                             p_structure_id         IN NUMBER,
                             p_old_structure_id     IN NUMBER,
                             p_category_set_id      IN NUMBER,
                             p_control_level        IN NUMBER,
                             p_mult_item_cat_assign_flag IN VARCHAR2,
                             p_parent_category_id   IN NUMBER,
                             p_category_name        IN VARCHAR2,
                             p_description          IN VARCHAR2,
                             p_interest_level       IN NUMBER,
                             p_expected_purchase    IN VARCHAR2,
                             p_level0_enabled_flag  IN VARCHAR2,
                             p_level1_enabled_flag  IN VARCHAR2,
                             p_level2_enabled_flag  IN VARCHAR2,
                             p_attr_group_id        IN NUMBER,
                             p_name_count_tab       IN OUT NOCOPY Name_Count_Tab,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count            OUT NOCOPY NUMBER,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_category_id          OUT NOCOPY NUMBER,
                             x_warning_flag         OUT NOCOPY VARCHAR2) IS

    CURSOR C_Get_Items(c_structure_id Number, c_type_code_id Number, c_interest_level Number) IS
        select MIC.INVENTORY_ITEM_ID,
               MIC.ORGANIZATION_ID
          from
              (      SELECT CATEGORY_ID
                       FROM MTL_CATEGORIES_B MC
                      WHERE MC.STRUCTURE_ID = c_structure_id
                        and DECODE(c_interest_level,0,MC.SEGMENT1,1,MC.SEGMENT2,2,MC.SEGMENT3,NULL) = c_type_code_id
                        and DECODE(c_interest_level,0,MC.SEGMENT2,1,MC.SEGMENT3,NULL) IS NULL
                        and DECODE(c_interest_level,0,MC.SEGMENT3,NULL) IS NULL
              ) MC1,
                       MTL_ITEM_CATEGORIES MIC
        where  MIC.CATEGORY_ID = MC1.CATEGORY_ID;

    CURSOR C_Valid_Cat_Exists(c_category_set_id Number, c_category_id Number) IS
        select 1
        from MTL_CATEGORY_SET_VALID_CATS
        where
            category_id = c_category_id
            and category_set_id = c_category_set_id;

    CURSOR C_EXISTS_EXTN_ID(c_category_set_id Number, c_category_id Number) IS
        select 1
          from EGO_PRODUCT_CAT_SET_EXT
         where category_set_id = c_category_set_id
           and category_id     = c_category_id;


    l_category_rec  INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
    l_out_category_id NUMBER := 0;
    l_out_legacy_category_id NUMBER := 0;
    l_val1 NUMBER;
    l_val2 NUMBER;
    l_val  NUMBER;
    l_msg_count         NUMBER := 0;
    l_msg_data          VARCHAR2(2000);
    l_return_status     VARCHAR2(1);    -- Local return status equal to p_return_status
    l_return_status2     VARCHAR2(1);
    l_error_code        NUMBER;
    l_dup_category_id   NUMBER;
    l_dup_legacy_category_id NUMBER;
    l_skip_valid_cat    VARCHAR2(1);
    l_category_name     VARCHAR2(40);
    l_legacy_category_name     VARCHAR2(40);
    l_category_desc     VARCHAR2(240);
    l_legacy_category_desc     VARCHAR2(240);
    l_create_legacy       VARCHAR2(1);
    l_item_found_flag     VARCHAR2(1) := 'N';
    l_exclude_user_view   VARCHAR2(1) := 'N';

BEGIN
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Inside process categories for interest type/code:' || p_category_name || ',interest type/code id:' || p_int_typ_cod_id || ',parent category id:' || p_parent_category_id);
    end if;

    x_warning_flag := 'N';
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_level0_enabled_flag <> 'Y' OR p_level1_enabled_flag <> 'Y' OR p_level2_enabled_flag <> 'Y' then
       l_exclude_user_view := 'Y';
    END IF;

    -- Check if any items exist for the current interest type id/interest code id
    Open C_Get_Items(p_old_structure_id, p_int_typ_cod_id, p_interest_level);
    FETCH C_Get_Items into l_val1, l_val2;
    IF C_Get_Items%FOUND then
        l_item_found_flag := 'Y';
    END IF;
    close C_Get_Items;

    IF (l_item_found_flag = 'Y' and p_interest_level <> 2) THEN
        l_create_legacy := 'Y';
    END IF;

    Pre_Process_Categories(p_name_count_tab => p_name_count_tab,
                           p_category_name  => p_category_name,
                           p_create_legacy  => l_create_legacy,
                           x_category_name  => l_category_name,
                           x_legacy_category_name => l_legacy_category_name,
                           x_warning_flag         => x_warning_flag);

    IF (x_warning_flag = 'Y') THEN
        return;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Create Records in MTL_CATEGORIES_B and MTL_CATEGORIES_TL
    l_category_rec.segment1 := l_category_name;
    l_category_rec.structure_id := p_structure_id;
    l_category_rec.description := p_category_name; -- This is the original non-truncated name

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Creating category with name:' || l_category_rec.segment1 || ' and description:' || l_category_rec.description);
    end if;

    INV_ITEM_CATEGORY_PUB.Create_Category (
      p_api_version    => G_CREATE_CAT_API_VER,
      p_init_msg_list  => FND_API.G_FALSE,
      p_commit         => FND_API.G_FALSE,
      x_return_status  => l_return_status,
      x_errorcode      => l_error_code,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data,
      p_category_rec   => l_category_rec,
      x_category_id    => l_out_category_id
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_return_status2 := FND_API.G_RET_STS_SUCCESS;
        -- check if error is due to duplicate category
        Check_Duplicate_Category(x_return_status => l_return_status2);
        IF (l_return_status2 <> FND_API.G_RET_STS_SUCCESS) THEN
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Error occured while calling INV_ITEM_CATEGORY_PUB.Create_Category');
            end if;
            RAISE FND_API.G_EXC_ERROR;
        ELSE -- if duplicate found
            Find_Duplicate_Category_Id(
                             p_structure_id => p_structure_id,
                             p_category_name => l_category_name,
                             x_category_id => l_dup_category_id
                             );
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Duplicate category found with id:' || l_dup_category_id);
            end if;
            -- Assign duplicate category id to category id (that otherwise should have been created)
            l_out_category_id := l_dup_category_id;
        END IF;
    END IF;

    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb', 'Category Id:' || l_out_category_id);
    END IF;

    l_skip_valid_cat := 'N';
    -- If a duplicate category was found, there is a chance that a record for this category
    -- already exists in MTL_CATEGORY_SET_VALID_CATS. If such a record exists then skip
    -- creating a new record in MTL_CATEGORY_SET_VALID_CATS table
    IF (l_dup_category_id is not null) THEN
        OPEN C_Valid_Cat_Exists(p_category_set_id, l_dup_category_id);
        FETCH C_Valid_Cat_Exists INTO l_val;
        IF (C_Valid_Cat_Exists%FOUND) THEN
            l_skip_valid_cat := 'Y';
        END IF;

        CLOSE C_Valid_Cat_Exists;
    END IF;

    IF (l_skip_valid_cat = 'N') THEN
        -- Create Record in MTL_CATEGORY_SET_VALID_CATS
        INV_ITEM_CATEGORY_PUB.Create_Valid_Category (
          p_api_version    => G_CREATE_CAT_API_VER,
          p_init_msg_list  => FND_API.G_FALSE,
          p_commit         => FND_API.G_FALSE,
          p_category_set_id => p_category_set_id,
          p_category_id     => l_out_category_id,
          p_parent_category_id => p_parent_category_id,
          x_return_status  => l_return_status,
          x_errorcode      => l_error_code,
          x_msg_count      => l_msg_count,
          x_msg_data       => l_msg_data
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Error occured while calling INV_ITEM_CATEGORY_PUB.Create_Valid_Category');
            end if;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    Open C_EXISTS_EXTN_ID(p_category_set_id,l_out_category_id);
    FETCH C_EXISTS_EXTN_ID into l_val;
    IF C_EXISTS_EXTN_ID%NOTFOUND
      THEN
             -- do the insert here
             INSERT INTO EGO_PRODUCT_CAT_SET_EXT ( EXTENSION_ID, CATEGORY_SET_ID, CATEGORY_ID, ATTR_GROUP_ID,
             CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
             INCLUDE_IN_FORECAST, EXPECTED_PURCHASE, EXCLUDE_USER_VIEW )
             VALUES (EGO_EXTFWK_S.NEXTVAL, p_category_set_id, l_out_category_id, p_attr_group_id, -1,  sysdate, -1,  sysdate, -1, 'Y', p_expected_purchase, l_exclude_user_view);
      ELSE
         UPDATE EGO_PRODUCT_CAT_SET_EXT
            SET EXPECTED_PURCHASE = p_expected_purchase,
                EXCLUDE_USER_VIEW = l_exclude_user_view
          WHERE CATEGORY_SET_ID = p_category_set_id
                AND CATEGORY_ID     = l_out_category_id;
    END IF;
    Close C_EXISTS_EXTN_ID;

    IF (l_item_found_flag = 'Y')
    THEN
        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Items found for category:' || p_category_name || ',interest type/code:' || p_int_typ_cod_id );
        end if;

        -- For secondary interest codes don't create legacy categories
        IF l_create_legacy = 'Y' THEN
            BEGIN


            -- Create Legacy Records in MTL_CATEGORIES_B and MTL_CATEGORIES_TL
            l_category_rec.segment1 := l_legacy_category_name;
            l_category_rec.structure_id := p_structure_id;
            l_category_rec.description := p_category_name || ' LEGACY';

            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Creating legacy category with name:' || l_category_rec.segment1 || ' and description:' || l_category_rec.description);
            end if;

            INV_ITEM_CATEGORY_PUB.Create_Category (
              p_api_version    => G_CREATE_CAT_API_VER,
              p_init_msg_list  => FND_API.G_FALSE,
              p_commit         => FND_API.G_FALSE,
              x_return_status  => l_return_status,
              x_errorcode      => l_error_code,
              x_msg_count      => l_msg_count,
              x_msg_data       => l_msg_data,
              p_category_rec   => l_category_rec,
              x_category_id    => l_out_legacy_category_id
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                l_return_status2 := FND_API.G_RET_STS_SUCCESS;
                -- check if error is due to duplicate legacy category
                Check_Duplicate_Category(x_return_status => l_return_status2);
                IF (l_return_status2 <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Error occured while calling INV_ITEM_CATEGORY_PUB.Create_Category for legacy category');
                   end if;
                   RAISE FND_API.G_EXC_ERROR;
                ELSE -- if duplicate found
                    Find_Duplicate_Category_Id(
                                     p_structure_id => p_structure_id,
                                     p_category_name => l_legacy_category_name,
                                     x_category_id => l_dup_legacy_category_id
                                     );
                    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Duplicate legacy category found with id:' || l_dup_legacy_category_id);
                    end if;
                    -- Assign duplicate category id to category id (that otherwise should have been created)
                    l_out_legacy_category_id := l_dup_legacy_category_id;
                END IF;
            END IF;

            l_skip_valid_cat := 'N';
            -- If a duplicate category was found, there is a chance that a record for this category
            -- already exists in MTL_CATEGORY_SET_VALID_CATS. If such a record exists then skip
            -- creating a new record in MTL_CATEGORY_SET_VALID_CATS table
            IF (l_dup_legacy_category_id is not null) THEN
                OPEN C_Valid_Cat_Exists(p_category_set_id, l_dup_legacy_category_id);
                FETCH C_Valid_Cat_Exists INTO l_val;
                IF (C_Valid_Cat_Exists%FOUND) THEN
                    l_skip_valid_cat := 'Y';
                END IF;

                CLOSE C_Valid_Cat_Exists;
            END IF;

            IF (l_skip_valid_cat = 'N') THEN
                -- Create Legacy Records in MTL_CATEGORY_SET_VALID_CATS
                INV_ITEM_CATEGORY_PUB.Create_Valid_Category (
                  p_api_version    => G_CREATE_CAT_API_VER,
                  p_init_msg_list  => FND_API.G_FALSE,
                  p_commit         => FND_API.G_FALSE,
                  p_category_set_id => p_category_set_id,
                  p_category_id     => l_out_legacy_category_id,
                  p_parent_category_id => l_out_category_id,
                  x_return_status  => l_return_status,
                  x_errorcode      => l_error_code,
                  x_msg_count      => l_msg_count,
                  x_msg_data       => l_msg_data
                );

                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Error occured while calling INV_ITEM_CATEGORY_PUB.Create_Valid_Category for legacy category');
                   end if;

                   RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

            Open C_EXISTS_EXTN_ID(p_category_set_id,l_out_legacy_category_id);
                FETCH C_EXISTS_EXTN_ID into l_val;
                IF C_EXISTS_EXTN_ID%NOTFOUND
                  THEN
                         -- do the insert here
                         INSERT INTO EGO_PRODUCT_CAT_SET_EXT ( EXTENSION_ID, CATEGORY_SET_ID, CATEGORY_ID, ATTR_GROUP_ID,
                         CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
                         INCLUDE_IN_FORECAST, EXPECTED_PURCHASE, EXCLUDE_USER_VIEW )
                         VALUES ( EGO_EXTFWK_S.NEXTVAL, p_category_set_id, l_out_legacy_category_id, p_attr_group_id, -1,  sysdate, -1,  sysdate, -1, 'Y', p_expected_purchase, l_exclude_user_view);
                   ELSE
                         UPDATE EGO_PRODUCT_CAT_SET_EXT
                            SET EXPECTED_PURCHASE = p_expected_purchase,
                                EXCLUDE_USER_VIEW = l_exclude_user_view
                         WHERE CATEGORY_SET_ID = p_category_set_id
                            AND CATEGORY_ID     = l_out_legacy_category_id;
                   END IF;
            Close C_EXISTS_EXTN_ID;
            END;
        ELSE -- IF (l_create_legacy...)
              l_out_legacy_category_id := l_out_category_id;
        END IF; --END IF (l_create_legacy...)

        -- Before attaching items to categories, cleanup the non-required legacy categories (Bug 3495005)
        IF p_interest_level = 2 THEN
            Cleanup_Legacy_Categories(p_category_set_id, l_out_legacy_category_id);
        END IF;

        -- Create Legacy Records in MTL_ITEM_CATEGORIES
        FOR scr in C_Get_Items(p_old_structure_id, p_int_typ_cod_id, p_interest_level)
        LOOP

            Assign_Item_To_Category(p_category_set_id=>p_category_set_id,
                                    p_organization_id=>scr.organization_id,
                                    p_inventory_item_id=>scr.inventory_item_id,
                                    p_category_id=>l_out_legacy_category_id,
                                    p_control_level=>p_control_level,
                                    p_mult_item_cat_assign_flag => p_mult_item_cat_assign_flag,
                                    x_return_status  => l_return_status,
                                    x_errorcode      => l_error_code,
                                    x_msg_count      => l_msg_count,
                                    x_msg_data       => l_msg_data);




        END LOOP;
    END IF;
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Finished Process_Categories, Returning category_id ' || l_out_category_id);
    end if;

    x_category_id := l_out_category_id;

EXCEPTION
  WHEN OTHERS THEN
     if l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
     end if;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception in Process_Categories');
     --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Process_Categories');
     x_return_status := l_return_status;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;
     x_category_id := l_out_category_id;

     RAISE;

END Process_Categories;

PROCEDURE Assign_Item_To_Category(p_category_set_id      IN NUMBER,
                                  p_organization_id      IN NUMBER,
                                  p_inventory_item_id    IN NUMBER,
                                  p_category_id          IN NUMBER,
                                  p_control_level        IN NUMBER,
                                  p_mult_item_cat_assign_flag IN VARCHAR2,
                                  x_return_status        OUT NOCOPY VARCHAR2,
                                  x_errorcode            OUT NOCOPY NUMBER,
                                  x_msg_count            OUT NOCOPY NUMBER,
                                  x_msg_data             OUT NOCOPY VARCHAR2) IS

    l_create_item_rec     VARCHAR2(1);
    l_val                 NUMBER;
    l_the_item_assign_count    NUMBER;
    l_the_cat_assign_count     NUMBER;
    l_exists                   VARCHAR2(1);

    CURSOR C_Check_Master_Org(c_organization_id NUMBER) IS
        select 1
        from mtl_parameters
        where organization_id = master_organization_id
        and organization_id = c_organization_id;

    CURSOR item_cat_assign_count_csr
       (  p_inventory_item_id  NUMBER
       ,  p_organization_id    NUMBER
       ,  p_category_set_id    NUMBER
       ,  p_category_id        NUMBER
       ) IS
          SELECT  COUNT( category_id ), COUNT( DECODE(category_id, p_category_id,1, NULL) )
          FROM  mtl_item_categories
          WHERE
                  inventory_item_id = p_inventory_item_id
             AND  organization_id   = p_organization_id
             AND  category_set_id = p_category_set_id;

       CURSOR org_item_exists_csr
       (  p_inventory_item_id  NUMBER
       ,  p_organization_id    NUMBER
       ) IS
          SELECT 'x' --2879647
          FROM  mtl_system_items_b
          WHERE  inventory_item_id = p_inventory_item_id
            AND  organization_id   = p_organization_id;

       CURSOR category_exists_csr (p_category_id  NUMBER)
       IS
          SELECT  'x'
          FROM  mtl_categories_b
          WHERE  category_id = p_category_id
            AND NVL(DISABLE_DATE,SYSDATE+1) > SYSDATE;

BEGIN
    IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Associating item ' || p_inventory_item_id || ' with category ' || p_category_id || ' for org id ' || p_organization_id || ' and set id ' || p_category_set_id);
    end if;

    /*
    -- Update MTL_ITEM_CATEGORIES
    Update MTL_ITEM_CATEGORIES
    Set category_id = p_category_id
    where category_set_id = p_category_set_id
    and organization_id = p_organization_id
    and inventory_item_id = p_inventory_item_id;

    -- If nothing is updated, then insert
    --IF (SQL%NOTFOUND) THEN
    */

    l_create_item_rec := 'Y';

    -- Check if item exists for that org
    OPEN org_item_exists_csr (p_inventory_item_id, p_organization_id);
    FETCH org_item_exists_csr INTO l_exists;
    IF (org_item_exists_csr%NOTFOUND) THEN
        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Warning! Ignoring item ' || p_inventory_item_id || ' as this item is not associated with organization ' || p_organization_id);
        end if;

        l_create_item_rec := 'N';
    END IF;
    CLOSE org_item_exists_csr;

    -- Check if category exists and is enabled
    IF (l_create_item_rec = 'Y') THEN
        OPEN category_exists_csr (p_category_id);
        FETCH category_exists_csr INTO l_exists;
        IF (category_exists_csr%NOTFOUND) THEN
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Warning! Unable to associate items to category ' || p_category_id || ' as the category is disabled');
            end if;
            l_create_item_rec := 'N';
        END IF;
        CLOSE category_exists_csr;
    END IF;

    -- Following validation ensures  that the below mentioned business rule is satisfied:
    -- 'Cannot Create/Delete Item Controlled category set from Organization Items.'
    -- Basically, if the control level is 'Master', items can be created only for master org
    -- This validation required here otherwise INV_ITEM_CATEGORY_PUB.Create_Category_Assignment
    -- throws this as an error
    IF (l_create_item_rec = 'Y' AND p_control_level = G_CONTROL_LEVEL_MASTER) THEN
        open C_Check_Master_Org(p_organization_id);
        fetch C_Check_Master_Org into l_val;
        IF C_Check_Master_Org%NOTFOUND THEN
            IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Organization ' || p_organization_id || ' is not a master org');
            end if;
            l_create_item_rec := 'N';
        END IF;
        Close C_Check_Master_Org;
    END IF;

    IF (l_create_item_rec = 'Y') THEN

        -- Get this item all category assignments count, and this category assignments count
        OPEN item_cat_assign_count_csr (p_inventory_item_id,
                                        p_organization_id,
                                        p_category_set_id,
                                        p_category_id);

        FETCH item_cat_assign_count_csr INTO l_the_item_assign_count, l_the_cat_assign_count;

        -- If a Category Set is defined with the MULT_ITEM_CAT_ASSIGN_FLAG set to 'N'
        -- then an Item may be assigned to only one Category in the Category Set.
        -- if more categories are assigned, then delete those associations first
        IF (p_mult_item_cat_assign_flag = 'N'
            AND (l_the_item_assign_count - l_the_cat_assign_count) > 0 ) THEN
                IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Deleting existing item associations');
                end if;

                DELETE FROM mtl_item_categories
                WHERE organization_id   = p_organization_id
                AND inventory_item_id = p_inventory_item_id
                AND category_set_id = p_category_set_id;
        END IF;

        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Creating new item associations');
        end if;
        INV_ITEM_CATEGORY_PUB.Create_Category_Assignment (
          p_api_version    => G_CREATE_CAT_API_VER,
          p_init_msg_list  => FND_API.G_FALSE,
          p_commit         => FND_API.G_FALSE,
          x_return_status  => x_return_status,
          x_errorcode      => x_errorcode,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_category_id    => p_category_id,
          p_category_set_id => p_category_set_id,
          p_inventory_item_id => p_inventory_item_id,
          p_organization_id => p_organization_id
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Error occured while calling INV_ITEM_CATEGORY_PUB.Create_Category_Assignment for inventory_item_id=' || p_inventory_item_id);
           end if;

           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
END Assign_Item_To_Category;

/*
Return success if duplicate category is found.
Parses the error message returned by create API to find out if create failed due to duplicate category
*/
PROCEDURE Check_Duplicate_Category(
                    x_return_status    OUT NOCOPY VARCHAR2) IS

    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
BEGIN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_msg_pub.count_and_get( p_encoded    => 'F'
                              , p_count      => l_msg_count
                              , p_data       => l_msg_data);
     for k in 1 .. l_msg_count loop
       l_msg_data := fnd_msg_pub.get( p_msg_index => k,
                                      p_encoded => 'F'
                                    );
       -- If this token is found in the message, it signifies a duplicate
       if (INSTR(l_msg_data,'Category Segment Combination')> 0)
       then
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            FND_MSG_PUB.Delete_Msg(k);
            exit;
       end if;
     end loop;
END Check_Duplicate_Category;

/*
    Given a category name, find the category id by looking into MTL_CATEGORIES_B table
*/
PROCEDURE Find_Duplicate_Category_Id(
                             p_structure_id         IN NUMBER,
                             p_category_name        IN VARCHAR2,
                             x_category_id          OUT NOCOPY NUMBER
                             ) IS

l_category_id NUMBER;

    CURSOR C_Get_Category_Id(c_structure_id Number, c_category_name VARCHAR2) IS
    select category_id
    from MTL_CATEGORIES_B
    where structure_id = c_structure_id
          and segment1 = c_category_name
          and segment2 is null
          and segment3 is null
          and segment4 is null
          and segment5 is null
          and segment6 is null
          and segment7 is null
          and segment8 is null
          and segment9 is null
          and segment10 is null
          and segment11 is null
          and segment12 is null
          and segment13 is null
          and segment14 is null
          and segment15 is null
          and segment16 is null
          and segment17 is null
          and segment18 is null
          and segment19 is null
          and segment20 is null;
BEGIN
    OPEN C_Get_Category_Id(p_structure_id, p_category_name);
    FETCH C_Get_Category_Id into l_category_id;
    IF (C_Get_Category_Id%NOTFOUND) THEN
        CLOSE C_Get_Category_Id;
        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Unable to find category with name ' || p_category_name);
        end if;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        CLOSE C_Get_Category_Id;
    END IF;

    x_category_id := l_category_id;
END Find_Duplicate_Category_Id;

PROCEDURE Cleanup_Legacy_Categories(p_category_set_id IN NUMBER,
                                    p_category_id   IN NUMBER) IS

    CURSOR C_Get_Legacy_Category_Id(c_category_set_id NUMBER, c_category_id NUMBER) IS
        select B.category_id, B.segment1 category_name from mtl_category_set_valid_cats V, mtl_categories_b B
        where V.category_set_id=c_category_set_id
        and V.parent_category_id=c_category_id
        and V.category_id = B.category_id;
        --and B.segment1 like '%LEGACY';
BEGIN
    FOR scr in C_Get_Legacy_Category_Id(p_category_set_id, p_category_id)
    LOOP
        IF G_debug  and (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'as.plsql.conc.asxmcatb','Deleting unused legacy category with id:' || scr.category_id || ' and name:' || scr.category_name);
        end if;
        -- No need to update transaction tables since they are handled in a seperate migration program.
        update mtl_item_categories
        set category_id=p_category_id
        where category_id=scr.category_id
        and category_set_id=p_category_set_id;
        delete from ego_product_cat_set_ext
        where category_id=scr.category_id and category_set_id=p_category_set_id;
        delete from mtl_category_set_valid_cats
        where category_id=scr.category_id and category_set_id=p_category_set_id;
        delete from mtl_categories_b where category_id=scr.category_id;
        delete from mtl_categories_tl where category_id=scr.category_id;
    END LOOP;

END Cleanup_Legacy_Categories;


/*  For testing purposes we can use the following statements.
delete from mtl_categories_tl where category_id in
(select category_id from mtl_categories_b where structure_id in
(select structure_id from mtl_category_sets where category_set_name='SME Product Catalog'));
delete from mtl_categories_b where structure_id in
(select structure_id from mtl_category_sets where category_set_name='SME Product Catalog');
delete from mtl_category_set_valid_cats where category_set_id in
(select category_set_id from mtl_category_sets where category_set_name='SME Product Catalog');
delete from mtl_item_categories where category_set_id in
(select category_set_id from mtl_category_sets where category_set_name='SME Product Catalog');
delete from EGO_PRODUCT_CAT_SET_EXT where category_set_id in
(select category_set_id from mtl_category_sets where category_set_name='SME Product Catalog');
commit;
*/

END AS_CATALOG_MIGRATION;


/
