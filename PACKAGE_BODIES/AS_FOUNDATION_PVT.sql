--------------------------------------------------------
--  DDL for Package Body AS_FOUNDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FOUNDATION_PVT" as
/* $Header: asxvfoub.pls 120.1 2005/12/06 03:14:26 amagupta noship $ */
--
-- NAME
-- AS_FOUNDATION_PVT
--
-- HISTORY
--   7/22/98            AWU          CREATED
--

G_PKG_NAME  CONSTANT VARCHAR2(30):='AS_FOUNDATION_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asxvfoub.pls';

G_APPL_ID         NUMBER := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID        NUMBER := FND_GLOBAL.Conc_Login_Id;
G_PROGRAM_ID      NUMBER := FND_GLOBAL.Conc_Program_Id;
--G_USER_ID         NUMBER := FND_GLOBAL.User_Id;
G_REQUEST_ID      NUMBER := FND_GLOBAL.Conc_Request_Id;

G_MAX NUMBER := 14;

FUNCTION get_subOrderBy(p_col_choice IN NUMBER, p_col_name IN VARCHAR2)
        RETURN VARCHAR2 IS
l_col_name varchar2(30);
begin

        if (p_col_choice is NULL and p_col_name is NOT NULL)
            or (p_col_choice is NOT NULL and p_col_name is NULL)
        then
           if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            then
                fnd_message.set_name('AS', 'API_MISSING_ORDERBY_ELEMENT');
                fnd_msg_pub.add;
            end if;
            raise fnd_api.g_exc_error;
        end if;

        if floor(p_col_choice/10) > G_MAX
            -- Greater than maximum order by columns
             or floor(p_col_choice/10) = 0
            -- only one digit
        then
            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            then
                fnd_message.set_name('AS', 'API_INVALID_ORDERBY_CHOICE');
                fnd_message.set_token('PARAM',p_col_choice, false);
                fnd_msg_pub.add;
            end if;
            raise fnd_api.g_exc_error;
            return '';
        end if;

	if (nls_upper(p_col_name) = 'CUSTOMER_NAME')
	then
		l_col_name :=  ' nls_upper' ||'(' ||p_col_name|| ')';
	else
		l_col_name := p_col_name;
	end if;
        if (mod(p_col_choice, 10) = 1)
        then
            return(l_col_name || ' ASC, ');
        elsif (mod(p_col_choice, 10) = 0)
        then
            return(l_col_name || ' DESC, ');
        else
            if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
            then
                fnd_message.set_name('AS', 'API_INVALID_ORDERBY_CHOICE');
                fnd_message.set_token('PARAM',p_col_choice, false);
                fnd_msg_pub.add;
            end if;
            raise fnd_api.g_exc_error;
            return '';
        end if;
end;

PROCEDURE Translate_OrderBy
(    p_api_version_number              IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                                                := FND_API.G_FALSE,
    p_validation_level        IN    NUMBER
                        := FND_API.G_VALID_LEVEL_FULL,
        p_order_by_rec            IN      UTIL_ORDER_BY_REC_TYPE,
    x_order_by_clause        OUT NOCOPY    VARCHAR2,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                     OUT NOCOPY     NUMBER,
        x_msg_data                      OUT NOCOPY     VARCHAR2
) IS

TYPE OrderByTabTyp is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;
l_orderBy_tbl OrderByTabTyp;
i    BINARY_INTEGER := 1;
l_order_by_clause VARCHAR2(2000) := NULL;
l_api_name    CONSTANT VARCHAR2(30)     := 'Translate_OrderBy';
l_api_version_number  CONSTANT NUMBER   := 2.0;
begin
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'TRANSLATE_ORDERBY', TRUE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- API body
	--

	-- Validate Environment

	IF FND_GLOBAL.User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	END IF;

    -- initialize the table to ''.
        for i in 1..G_MAX loop
            l_orderBy_tbl(i) := '';
        end loop;

    -- We allow the choice seqence order such as 41, 20, 11, ...
    -- So, we need to sort it first(put them into a table),
    -- then loop through the whole table.

        if (p_order_by_rec.col_1_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_1_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_1_choice,
                                p_order_by_rec.col_1_name);
        end if;
        if (p_order_by_rec.col_2_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_2_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_2_choice,
                                p_order_by_rec.col_2_name);
        end if;
        if (p_order_by_rec.col_3_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_3_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_3_choice,
                                p_order_by_rec.col_3_name);
        end if;
        if (p_order_by_rec.col_4_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_4_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_4_choice,
                                p_order_by_rec.col_4_name);
        end if;
        if (p_order_by_rec.col_5_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_5_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_5_choice,
                                p_order_by_rec.col_5_name);
        end if;
        if (p_order_by_rec.col_6_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_6_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_6_choice,
                                p_order_by_rec.col_6_name);
        end if;
        if (p_order_by_rec.col_7_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_7_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_7_choice,
                                p_order_by_rec.col_7_name);
        end if;
        if (p_order_by_rec.col_8_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_8_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_8_choice,
                                p_order_by_rec.col_8_name);
        end if;
        if (p_order_by_rec.col_9_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_9_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_9_choice,
                                p_order_by_rec.col_9_name);
        end if;
        if (p_order_by_rec.col_10_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_10_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_10_choice,
                                p_order_by_rec.col_10_name);
        end if;
                  if (p_order_by_rec.col_11_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_11_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_11_choice,
                                p_order_by_rec.col_11_name);
        end if;

                if (p_order_by_rec.col_12_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_12_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_12_choice,
                                p_order_by_rec.col_12_name);
        end if;

                if (p_order_by_rec.col_13_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_13_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_13_choice,
                                p_order_by_rec.col_13_name);
        end if;
                 if (p_order_by_rec.col_14_choice is NOT NULL)
        then
            l_orderBy_tbl(floor(p_order_by_rec.col_14_choice/10)) :=
                get_subOrderBy(p_order_by_rec.col_14_choice,
                                p_order_by_rec.col_14_name);
        end if;

        for i in 1..G_MAX loop
            l_order_by_clause := l_order_by_clause || l_orderBy_tbl(i);
        end loop;
        l_order_by_clause := rtrim(l_order_by_clause); -- trim ''
        l_order_by_clause := rtrim(l_order_by_clause, ',');    -- trim last ,
        x_order_by_clause := l_order_by_clause;

	EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

end;

PROCEDURE Get_PeriodNames
(    p_api_version_number             IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2
                            := FND_API.G_FALSE,
    p_validation_level             IN     NUMBER
                            := FND_API.G_VALID_LEVEL_FULL,
    p_period_rec                 IN     UTIL_PERIOD_REC_TYPE,
    x_period_tbl                 OUT NOCOPY     UTIL_PERIOD_TBL_TYPE,
        x_return_status                 OUT NOCOPY     VARCHAR2,
        x_msg_count                 OUT NOCOPY     NUMBER,
        x_msg_data                 OUT NOCOPY     VARCHAR2
) IS

    cursor get_period_name_csr(l_period_name VARCHAR2, l_period_start_date DATE,
                   l_period_end_date DATE, l_period_set_name VARCHAR2) is
        select period_name, start_date, end_date
        from gl_periods
        where period_name like decode(l_period_name, NULL, '%',
                                      FND_API.G_MISS_CHAR, '%',
                                      l_period_name)
        and start_date >= decode(l_period_start_date, NULL, to_date('01/01/1000',
													   'DD/MM/YYYY'),
                                      FND_API.G_MISS_CHAR, to_date('01/01/1000',
												       'DD/MM/YYYY'),
                                      l_period_start_date)
        and end_date <= decode(l_period_end_date, NULL, to_date('01/01/9999',
												    'DD/MM/YYYY'),
                                      FND_API.G_MISS_CHAR, to_date('01/01/9999',
													  'DD/MM/YYYY'),
                                      l_period_end_date)
        and (period_set_name = l_period_set_name or period_set_name is NULL);

l_api_name    CONSTANT VARCHAR2(30)     := 'Get_PeriodNames';
l_api_version_number  CONSTANT NUMBER   := 2.0;
l_period_set_name VARCHAR2(15);
l_period_name VARCHAR2(20);
l_start_date DATE;
l_end_date DATE;
i BINARY_INTEGER := 0;

begin
    -- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'AS_ACCESSES', TRUE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- API body
	--

	-- Validate Environment

	IF FND_GLOBAL.User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	END IF;

    l_period_set_name := fnd_profile.value('AS_FORECAST_CALENDAR');
    open get_period_name_csr(p_period_rec.period_name, p_period_rec.start_date, p_period_rec.end_date,
                l_period_set_name);
    loop
        i := i + 1;
        fetch get_period_name_csr into l_period_name, l_start_date, l_end_date;
        exit when get_period_name_csr%NOTFOUND;
        x_period_tbl(i).period_name := l_period_name;
     x_period_tbl(i).start_date := l_start_date;
     x_period_tbl(i).end_date := l_end_date;
    end loop;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );
end;

--      Notes:  The valid inputs for p_tablename are:
--        G_AS_LOOKUPS        VARCHAR2 := 'AS_LOOKUPS',
--        G_AR_LOOKUPS        VARCHAR2 := 'AR_LOOKUPS',
--        G_SO_LOOKUPS        VARCHAR2 := 'SO_LOOKUPS',
--        G_HR_LOOKUPS        VARCHAR2 := 'HR_LOOKUPS',
--        G_FND_COMMON_LOOKUPS    VARCHAR2 := 'FND_COMMON_LOOKUPS',
--        G_CS_LOOKUPS        VARCHAR2 := 'CS_LOOKUPS'

FUNCTION get_lookupMeaning
(    p_lookup_type            IN    VARCHAR2,
    p_lookup_code            IN    VARCHAR2,
    p_tablename            IN    VARCHAR2
) RETURN VARCHAR2 IS

    cursor as_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from as_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;

    cursor ar_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from ar_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;
   /*
    cursor so_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from aso_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;
   */
    cursor hr_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from hr_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;

    cursor cs_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from cs_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;

    cursor fnd_common_lookups_meaning_csr(l_lookup_type VARCHAR2,
                    l_lookup_code VARCHAR2) is
        select meaning
        from fnd_common_lookups
        where lookup_code = l_lookup_code
        and lookup_type = l_lookup_type;

l_meaning VARCHAR2(80);
begin
    if p_tablename = G_AS_LOOKUPS
    then
        open as_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch as_lookups_meaning_csr into l_meaning;
        close as_lookups_meaning_csr;
        return l_meaning;
    elsif p_tablename = G_AR_LOOKUPS
    then
        open ar_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch ar_lookups_meaning_csr into l_meaning;
        close ar_lookups_meaning_csr;
        return l_meaning;
	   /*
    elsif p_tablename = G_SO_LOOKUPS
    then
        open so_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch so_lookups_meaning_csr into l_meaning;
        close so_lookups_meaning_csr;
        return l_meaning;
	   */
    elsif p_tablename = G_HR_LOOKUPS
    then
        open hr_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch hr_lookups_meaning_csr into l_meaning;
        close hr_lookups_meaning_csr;
        return l_meaning;
    elsif p_tablename = G_CS_LOOKUPS
    then
        open cs_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch cs_lookups_meaning_csr into l_meaning;
        close cs_lookups_meaning_csr;
        return l_meaning;
    elsif p_tablename = G_FND_COMMON_LOOKUPS
    then
        open fnd_common_lookups_meaning_csr(p_lookup_type, p_lookup_code);
        fetch fnd_common_lookups_meaning_csr into l_meaning;
        close fnd_common_lookups_meaning_csr;
        return l_meaning;
    else
        raise fnd_api.g_exc_error;
        return NULL;
    end if;

end;

FUNCTION get_unitOfMeasure(p_uom_code IN VARCHAR2) RETURN VARCHAR2 is

    cursor get_unitOfMeasure_csr(l_uom_code VARCHAR2) is
	select unit_of_measure
        from mtl_units_of_measure
        where uom_code = l_uom_code;

l_uom VARCHAR(25) := NULL;
begin
    open get_unitOfMeasure_csr(p_uom_code);
    fetch get_unitOfMeasure_csr into l_uom;
    return l_uom;
    close get_unitOfMeasure_csr;
end;

FUNCTION get_uomCode(p_uom IN VARCHAR2) RETURN VARCHAR2 is

    cursor get_uomCode_csr(l_uom VARCHAR2) is
        select uom_code
        from mtl_units_of_measure
        where unit_of_measure = l_uom;

l_uom_code VARCHAR(25) := NULL;
begin
    open get_uomCode_csr(p_uom);
    fetch get_uomCode_csr into l_uom_code;
    return l_uom_code;
    close get_uomCode_csr;
end;

PROCEDURE Get_inventory_items(  p_api_version_number      IN    NUMBER,
                                p_init_msg_list           IN    VARCHAR2
                                    := FND_API.G_FALSE,
                                p_identity_salesforce_id  IN    NUMBER,
                                p_validation_level        IN    NUMBER
                                    := FND_API.G_VALID_LEVEL_FULL,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                x_return_status           OUT NOCOPY   VARCHAR2,
                                x_msg_count               OUT NOCOPY   NUMBER,
                                x_msg_data                OUT NOCOPY   VARCHAR2,
                                x_inventory_item_tbl      OUT NOCOPY   AS_FOUNDATION_PUB.inventory_item_TBL_TYPE) IS


          Cursor C_Get_inv_items_W_inv_id(p_inventory_item_id Number,
                                          p_organization_id Number,
                                          p_description Varchar2,
                                          p_concatenated_segments Varchar2,
                                          p_collateral_flag Varchar2,
                                          p_bom_item_type Number) IS
            Select      inventory_item_id,
                        organization_id ,
                        enabled_flag,
                        start_date_active,
                        end_date_active,
                        description,
                        concatenated_segments,
                        inventory_item_flag,
                        item_catalog_group_id,
                        Collateral_flag,
                        Primary_UOM_Code,
                        Primary_Unit_of_Measure,
                        inventory_item_status_code,
                        product_family_item_id,
                        bom_item_type
            From        mtl_system_items_kfv
            Where       inventory_item_id = p_inventory_item_id
            And         (description like NVL(p_description, '%')
            Or           description is NULL)
            And         (concatenated_segments like NVL(p_concatenated_segments, '%')
            Or           concatenated_segments is NULL)
            And         organization_id = p_organization_id
            And         (collateral_flag like NVL(p_collateral_flag, '%')
            Or           collateral_flag is NULL)
            And         bom_item_type = NVL(p_bom_item_type, bom_item_type);  -- Bom_item_type is not indexed

          Cursor C_Get_inv_items_NO_inv_id(p_organization_id Number,
                                          p_description Varchar2,
                                          p_concatenated_segments Varchar2,
                                          p_collateral_flag Varchar2,
                                          p_bom_item_type Number) IS
            Select      inventory_item_id,
                        organization_id ,
                        enabled_flag,
                        start_date_active,
                        end_date_active,
                        description,
                        concatenated_segments,
                        inventory_item_flag,
                        item_catalog_group_id,
                        Collateral_flag,
                        Primary_UOM_Code,
                        Primary_Unit_of_Measure,
                        inventory_item_status_code,
                        product_family_item_id,
                        bom_item_type
            From        mtl_system_items_kfv
            Where       (description like p_description)
            And         (concatenated_segments like NVL(p_concatenated_segments, '%')
            Or           concatenated_segments is NULL)
            And         organization_id = p_organization_id
            And         (collateral_flag like NVL(p_collateral_flag, '%')
            Or           collateral_flag is NULL)
            And         bom_item_type = NVL(p_bom_item_type, bom_item_type)  -- Bom_item_type is not indexed
            UNION
            Select      inventory_item_id,
                        organization_id ,
                        enabled_flag,
                        start_date_active,
                        end_date_active,
                        description,
                        concatenated_segments,
                        inventory_item_flag,
                        item_catalog_group_id,
                        Collateral_flag,
                        Primary_UOM_Code,
                        Primary_Unit_of_Measure,
                        inventory_item_status_code,
                        product_family_item_id,
                        bom_item_type
            From        mtl_system_items_kfv
            Where       (description is NULL)
            And         (concatenated_segments like NVL(p_concatenated_segments, '%')
            Or           concatenated_segments is NULL)
            And         organization_id = p_organization_id
            And         (collateral_flag like NVL(p_collateral_flag, '%')
            Or           collateral_flag is NULL)
            And         bom_item_type = NVL(p_bom_item_type, bom_item_type);  -- Bom_item_type is not indexed



          -- Local API Variables
          l_api_name    CONSTANT VARCHAR2(30)     := 'Get_inventory_items';
          l_api_version_number  CONSTANT NUMBER   := 2.0;

          -- Local Identity Variables

          l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

          -- Locat tmp Variables
          l_inventory_item_rec AS_FOUNDATION_PUB.inventory_item_Rec_Type;

          -- Local record index
          l_cur_index Number := 0;

          -- Local return statuses
          l_return_status Varchar2(1);

  BEGIN
            -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--          dbms_output.put_line('AS_Foundation_PVT.Get_inventory_items: Start');
--      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


       --  Validating Environment
      /*
      AS_SALES_MEMBER_PVT.Get_CurrentUser(
           p_api_version_number => 2.0
          ,p_salesforce_id => p_identity_salesforce_id
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,x_sales_member_rec => l_identity_sales_member_rec);

      IF l_return_status != FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */


      -- API BODY

      If (p_inventory_item_rec.Inventory_Item_id IS NULL) Then

          -- Debug Message
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--          THEN
--            dbms_output.put_line('AS_Foundation_PVT - Open NO ID Cursor to Select');
--          END IF;

          l_inventory_item_rec.description := nvl(p_inventory_item_rec.description,'%');
          Open C_Get_inv_items_NO_inv_id(p_inventory_item_rec.organization_id,
                                     l_inventory_item_rec.description,
                                     p_inventory_item_rec.concatenated_segments,
                                     p_inventory_item_rec.collateral_flag,
                                     p_inventory_item_rec.bom_item_type );

          -- Debug Message
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--          THEN
--            dbms_output.put_line('AS_Foundation_PVT - Fetching');
--          END IF;

          Loop

            Fetch C_Get_inv_items_NO_inv_id into
            l_inventory_item_rec.inventory_item_id,
            l_inventory_item_rec.organization_id,
            l_inventory_item_rec.enabled_flag,
            l_inventory_item_rec.start_date_active,
            l_inventory_item_rec.end_date_active,
            l_inventory_item_rec.description,
            l_inventory_item_rec.concatenated_segments,
            l_inventory_item_rec.inventory_item_flag,
            l_inventory_item_rec.item_catalog_group_id,
            l_inventory_item_rec.Collateral_flag,
            l_inventory_item_rec.Primary_UOM_Code,
            l_inventory_item_rec.Primary_Unit_of_Measure,
            l_inventory_item_rec.inventory_item_status_code,
            l_inventory_item_rec.product_family_item_id,
            l_inventory_item_rec.bom_item_type;
            Exit when C_Get_inv_items_NO_inv_id%NOTFOUND;

            l_cur_index := l_cur_index + 1;
            x_inventory_item_tbl(l_cur_index) := l_inventory_item_rec;
          End Loop;

    -- Debug Message
--    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--      dbms_output.put_line('AS_Foundation_PVT - Closing Cursor');
--      dbms_output.put_line('AS_Foundation_PVT - retrived lines =' || to_char(l_cur_index));
--    END IF;

         Close C_Get_inv_items_NO_inv_id;
    Else

         -- Debug Message
--         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--           dbms_output.put_line('AS_Foundation_PVT - Open With ID Cursor to Select');
--         END IF;

         Open C_Get_inv_items_w_inv_id(p_inventory_item_rec.inventory_item_id,
                                     p_inventory_item_rec.organization_id,
                                     p_inventory_item_rec.description,
                                     p_inventory_item_rec.concatenated_segments,
                                     p_inventory_item_rec.collateral_flag,
                                     p_inventory_item_rec.bom_item_type );

         -- Debug Message
--         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--            dbms_output.put_line('AS_Foundation_PVT - Fetching');
--         END IF;

          Loop

            Fetch C_Get_inv_items_w_inv_id into
            l_inventory_item_rec.inventory_item_id,
            l_inventory_item_rec.organization_id,
            l_inventory_item_rec.enabled_flag,
            l_inventory_item_rec.start_date_active,
            l_inventory_item_rec.end_date_active,
            l_inventory_item_rec.description,
            l_inventory_item_rec.concatenated_segments,
            l_inventory_item_rec.inventory_item_flag,
            l_inventory_item_rec.item_catalog_group_id,
            l_inventory_item_rec.Collateral_flag,
            l_inventory_item_rec.Primary_UOM_Code,
            l_inventory_item_rec.Primary_Unit_of_Measure,
            l_inventory_item_rec.inventory_item_status_code,
            l_inventory_item_rec.product_family_item_id,
            l_inventory_item_rec.bom_item_type;
          Exit when C_Get_inv_items_w_inv_id%NOTFOUND;
--dbms_output.put_line('FOUND');
          l_cur_index := l_cur_index + 1;
          x_inventory_item_tbl(l_cur_index) := l_inventory_item_rec;
         End Loop;

    -- Debug Message
--    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--      dbms_output.put_line('AS_Foundation_PVT - Closing Cursor');
--      dbms_output.put_line('AS_Foundation_PVT - retrived lines =' || to_char(l_cur_index));
--    END IF;

         Close C_Get_inv_items_w_inv_id;

    End if;


    -- API Ending

    x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
        FND_MSG_PUB.Add;
    END IF;


      -- Debug Message
--    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--    THEN
--      dbms_output.put_line('AS_Foundation_PVT.Get_inventory_items: End');
--    END IF;

      -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );

      WHEN NO_DATA_FOUND THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--           THEN
--            dbms_output.put_line('AS_Foundation_PVT - Cannot Find Inventory Item');
--            END IF;


          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );


  End Get_inventory_items;

FUNCTION Get_Concatenated_Segments( p_inventory_item_id IN NUMBER
                            ,p_organization_id   IN NUMBER) return Varchar2 IS

    Cursor Get_One_Item(p_inventory_item_id Number,
                        p_organization_id Number) IS
        Select Concatenated_Segments
        From   mtl_system_items_kfv
        Where  inventory_item_id = p_inventory_item_id And
               organization_id = p_organization_id;

    l_Concatenated_Segments VARCHAR2(50);

Begin

    Open Get_One_Item(p_inventory_item_id, p_organization_id);
    Fetch Get_One_Item into l_Concatenated_Segments;
    Close Get_One_Item;

    return l_Concatenated_Segments;

EXCEPTION

      WHEN Others THEN
          return NULL;

End Get_Concatenated_Segments;


PROCEDURE Get_inventory_itemPrice(  p_api_version_number      IN    NUMBER,
                                p_init_msg_list           IN    VARCHAR2
                                    := FND_API.G_FALSE,
                                p_identity_salesforce_id  IN    NUMBER,
                                p_validation_level        IN    NUMBER
                                    := FND_API.G_VALID_LEVEL_FULL,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                p_price_list_id           IN    NUMBER,
                                x_return_status           OUT NOCOPY   VARCHAR2,
                                x_msg_count               OUT NOCOPY   NUMBER,
                                x_msg_data                OUT NOCOPY   VARCHAR2,
                                x_list_price              OUT NOCOPY   NUMBER,
                                x_currency_code           OUT NOCOPY   VARCHAR2) IS


          Cursor C_Get_inv_item_price(    p_inventory_item_id Number,
                                          p_unit_code Varchar2,
                                          p_price_list_id Number) IS
            Select      pr_line.list_price,
                        pr_head.currency_code
            From        aso_i_price_lists_v pr_head, aso_i_price_list_lines_v pr_line
            Where       pr_head.price_list_id = p_price_list_id
            And         pr_line.inventory_item_id = p_inventory_item_id
            And         pr_line.uom_code = p_unit_code
            And         pr_head.price_list_id = pr_line.price_list_id
            And         trunc(sysdate) between nvl(pr_head.start_date_active, trunc(sysdate))
            And         nvl(pr_head.end_date_active, trunc(sysdate))
            And         trunc(sysdate) between nvl(pr_line.start_date_active, trunc(sysdate))
            And         nvl(pr_line.end_date_active, trunc(sysdate))
            And         rownum = 1;

          Cursor C_Get_inv_item_second_pr(    p_inventory_item_id Number,
                                              p_unit_code Varchar2,
                                              p_price_list_id Number) IS
            Select      pr_line.list_price,
                        pr_head.currency_code
            --From        oe_price_lists pr_head, oe_price_list_lines pr_line
            From        qp_price_lists_v pr_head, qp_price_list_lines_v pr_line
            Where       pr_head.price_list_id = p_price_list_id
            And         pr_line.inventory_item_id = p_inventory_item_id
            And         pr_line.unit_code = p_unit_code
            And         pr_head.secondary_price_list_id = pr_line.price_list_id
            And         trunc(sysdate) between nvl(pr_head.start_date_active, trunc(sysdate))
            And         nvl(pr_head.end_date_active, trunc(sysdate))
            And         trunc(sysdate) between nvl(pr_line.start_date_active, trunc(sysdate))
            And         nvl(pr_line.end_date_active, trunc(sysdate))
            And         rownum = 1;

          -- Local API Variables
          l_api_name    CONSTANT VARCHAR2(30)     := 'Get_inventory_itemPrice';
          l_api_version_number  CONSTANT NUMBER   := 2.0;

          -- Local Identity Variables

          l_identity_sales_member_rec      AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

          -- Local return statuses
          l_return_status Varchar2(1);
          l_list_price    Number;
          l_currency_code Varchar2(30);

  BEGIN
            -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--          dbms_output.put_line('AS_Foundation_PVT.Get_inventory_itemPrice: Start');
--      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;


       --  Validating Environment
      /*
      AS_SALES_MEMBER_PVT.Get_CurrentUser(
           p_api_version_number => 2.0
          ,p_salesforce_id => p_identity_salesforce_id
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,x_sales_member_rec => l_identity_sales_member_rec);

      IF l_return_status != FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */


      -- API BODY


      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT - Open Primary Cursor to Select');
--      END IF;

      Open C_Get_inv_item_price (p_inventory_item_rec.inventory_item_id,
                                 p_inventory_item_rec.primary_uom_code,
                                 p_price_list_id );

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT - Fetching');
--      END IF;

      -- If first price list yields nothing, use secondary
      Fetch C_Get_inv_item_price into l_list_price, l_currency_code;


      If (C_Get_inv_item_price%NOTFOUND = TRUE) Then

        Open C_Get_inv_item_second_pr (p_inventory_item_rec.inventory_item_id,
                                       p_inventory_item_rec.primary_uom_code,
                                       p_price_list_id );


        -- Debug Message
--        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--            dbms_output.put_line('AS_Foundation_PVT - Open Secondary Cursor');
--        END IF;

        Fetch C_Get_inv_item_second_pr into l_list_price, l_currency_code;

        If (C_Get_inv_item_second_pr%NOTFOUND = TRUE) Then
--            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--                dbms_output.put_line('AS_Foundation_PVT - Cannot Find List Price');
--            END IF;
            l_list_price := NULL;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
        Else
            x_return_status := FND_API.G_RET_STS_SUCCESS;
        End if;

        -- Debug Message
--        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--          dbms_output.put_line('AS_Foundation_PVT - Closing Secondary Cursor');
--        END IF;

        Close C_Get_inv_item_second_pr;

      Else
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      End if;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--        dbms_output.put_line('AS_Foundation_PVT - Closing Primary Cursor');
--      END IF;

      Close C_Get_inv_item_price;

    -- API Ending

      x_list_price := l_list_price;
      x_currency_code := l_currency_code;


      -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
        FND_MSG_PUB.Add;
    END IF;


      -- Debug Message
--    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    --THEN
--      dbms_output.put_line('AS_Foundation_PVT.Get_inventory_itemPrice: End');
--    END IF;

      -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );


  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );

      WHEN NO_DATA_FOUND THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--           THEN
--            dbms_output.put_line('AS_Foundation_PVT - Cannot Find Inventory Item List Price');
--            END IF;


          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


      WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );


End Get_inventory_itemPrice;

PROCEDURE Get_Price_List_Id(p_api_version_number	IN  NUMBER,
			    p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			    p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			    x_return_status	 OUT NOCOPY VARCHAR2,
			    x_msg_count		 OUT NOCOPY NUMBER,
			    x_msg_data		 OUT NOCOPY VARCHAR2,
			    p_currency_code		IN  VARCHAR2,
			    x_price_list_id	 OUT NOCOPY NUMBER) IS
  CURSOR l_price_list_id_csr (c_group_id NUMBER, c_currency_code VARCHAR2) IS
	SELECT apl.price_list_id
	--FROM as_price_lists apl, oe_price_lists spl
	FROM as_price_lists apl, qp_price_lists_v spl
	WHERE apl.group_id = c_group_id
	      AND apl.price_list_id = spl.price_list_id
	      AND spl.currency_code = c_currency_code;

  -- Local API Variables
  l_api_name    CONSTANT VARCHAR2(30)     := 'Get_Price_List_Id';
  l_api_version_number  CONSTANT NUMBER   := 2.0;

  -- Local return statuses
  l_return_status Varchar2(1);
  l_price_list_id    Number;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--          dbms_output.put_line('AS_Foundation_PVT.Get_Price_List_Id: Start');
--      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT.Get_Price_List_Id - Open Price list Cursor');
--      END IF;

--      IF FND_PROFILE.Value('AS_MC_PRICE_LIST_GROUP') IS NULL
--      THEN
--	dbms_output.put_line('AS_Foundation_PVT.Get_Price_List_Id - No Price List Group is set');
--      END IF;
      OPEN l_price_list_id_csr(FND_PROFILE.Value('AS_MC_PRICE_LIST_GROUP'),p_currency_code);

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT.Get_Price_List_Id - Fetching');
--      END IF;

      FETCH l_price_list_id_csr INTO l_price_list_id;
	 -- Fix bug 858247 Jshang, when price list id is missing, set it to NULL instead of 0
      IF l_price_list_id_csr%NOTFOUND THEN
	 -- l_price_list_id := 0;
	 l_price_list_id := NULL;
--	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--	    dbms_output.put_line('AS_FOUNDATION_PVT.Get_Price_List_Id - No Price List Id is found');
--	 END IF;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
        Else
            x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE l_price_list_id_csr;
      x_price_list_id := l_price_list_id;


      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
        FND_MSG_PUB.Add;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT.Get_Price_List_Id: End');
--      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--          THEN
--            dbms_output.put_line('AS_Foundation_PVT. - Cannot Find Price List Id');
--          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

END Get_Price_List_Id;



PROCEDURE Get_Price_Info(p_api_version_number	IN  NUMBER,
			 p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			 p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			 p_secondary_interest_code_id	IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_currency_code		IN  VARCHAR2,
			 x_return_status	 OUT NOCOPY VARCHAR2,
			 x_msg_count		 OUT NOCOPY NUMBER,
			 x_msg_data		 OUT NOCOPY VARCHAR2,
			 x_price_list_id	 OUT NOCOPY NUMBER,
			 x_price		 OUT NOCOPY NUMBER) IS

  CURSOR l_secondary_price_csr(c_secondary_code_id NUMBER,
			       c_currency_code VARCHAR2) IS
	SELECT icm.price
	FROM AS_INTEREST_CODES_MC icm
	WHERE icm.interest_code_id = c_secondary_code_id
	      AND icm.currency_code = c_currency_code;

  -- Local API Variables
  l_api_name    CONSTANT VARCHAR2(30)     := 'Get_Price_Info';
  l_api_version_number  CONSTANT NUMBER   := 2.0;

  -- Local return statuses
  l_return_status Varchar2(1);
  l_price_list_id    Number;
  l_price Number;
  l_currency_code VARCHAR2(15);
BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                   p_api_version_number,
                                   l_api_name,
                                   G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--          dbms_output.put_line('AS_Foundation_PVT.Get_Price_Info: Start');
--      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Check inventory item id, if it's not null, use it to get the price list id and price
      IF (p_inventory_item_rec.inventory_item_id <> FND_API.G_MISS_NUM AND p_inventory_item_rec.inventory_item_id IS NOT NULL)
      THEN
	Get_Price_List_Id(p_api_version_number => 2.0,
			    p_init_msg_list => FND_API.G_FALSE,
			    x_return_status => l_return_status,
			    x_msg_count	=> x_msg_count,
			    x_msg_data => x_msg_data,
			    p_currency_code => p_currency_code,
			    x_price_list_id => l_price_list_id);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
	END IF;
--	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--	   dbms_output.put_line('AS_FOUNDATION_PVT.Get_Price_Info - Price_list_id : ' || to_char(l_price_list_id));
--	END IF;
	Get_inventory_itemPrice(  p_api_version_number => 2.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_identity_salesforce_id => NULL,
                                p_inventory_item_rec => p_inventory_item_rec,
                                p_price_list_id => l_price_list_id,
                                x_return_status => l_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_list_price => l_price,
                                x_currency_code => l_currency_code);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
	END IF;
	x_price_list_id := l_price_list_id;
	x_price := l_price;
      Elsif (p_secondary_interest_code_id IS NOT NULL) THEN
	open l_secondary_price_csr(p_secondary_interest_code_id,p_currency_code);
	fetch l_secondary_price_csr into l_price;
	IF l_secondary_price_csr%NOTFOUND THEN
--	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--	      dbms_output.put_line('AS_Foundation_PVT.Get_Price_Info - Cannot find price');
--	   END IF;
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
	      FND_MESSAGE.Set_Name('AS','FC_SEC_NO_LIST_PRICE');
	      FND_MSG_PUB.ADD;
	   END IF;
	   l_price := NULL;
--	   close l_secondary_price_csr;
--	   raise FND_API.G_EXC_ERROR;
	END IF;
	close l_secondary_price_csr;
      Else
--	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--	      dbms_output.put_line('AS_Foundation_PVT.Get_Price_Info - Wrong Parameter');
--	   END IF;
	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.Set_Name('AS','API_UNEXP_ERROR_IN_PROCESSING');
	      FND_MESSAGE.Set_Token('ROW','AS_FOUNDATION');
	      FND_MSG_PUB.ADD;
	   END IF;
	   raise FND_API.G_EXC_ERROR;
      END IF;
      x_price_list_id := l_price_list_id;
      x_price := l_price;
      -- Success Message
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
        FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
        FND_MSG_PUB.Add;
      END IF;

      -- Debug Message
--      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--      THEN
--        dbms_output.put_line('AS_Foundation_PVT.Get_Price_Info: End');
--      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

  EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--          THEN
--            dbms_output.put_line('AS_Foundation_PVT. - Cannot Find Price List Id');
--          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );

END Get_Price_Info;

-- Start of Comments
--
-- API name	: Check_Volume_Amount
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes inventory_item_rec, secondary_interest_code_id, currency_code, volume
--	and amount as the input, it will compute volume or amount if either of them is missed
--      or check the consistency between them if both of them have been set a value.
--
-- Parameters	:
-- IN		:
--			p_api_version_number	IN  NUMBER,
--			p_init_msg_list		IN  VARCHAR2
--					:= FND_API.G_FALSE
--			 p_validation_level		IN  NUMBER
--					:= FND_API.G_VALID_LEVEL_FULL
--			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE
--					DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC
--			 p_secondary_interest_code_id	IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 p_currency_code		IN  VARCHAR2
--			 p_volume			IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 p_amount			IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 x_return_status		OUT VARCHAR2
--			 x_msg_count			OUT NUMBER
--			 x_msg_data			OUT VARCHAR2
--			 x_vol_tolerance_margin		OUT NUMBER
--			 x_volume			OUT NUMBER
--			 x_amount			OUT NUMBER
--			 x_uom_code			OUT VARCHAR2
--			 x_price_list_id		OUT NUMBER
--			 x_price			OUT NUMBER
--
-- Version	:
--
-- HISTORY
--	19-Nov-1998	J. Shang	Created
-- Note     :
--	1. Inventory item will overwrite the secondary interest code when both of them are set
--      2. The values needed in pass-in parameter p_inventory_item_rec maybe:
--			Item_Id, Organization_Id and uom_code
--	   Among them, if uom_code is not set, the value in the table will be used
--	3. p_volume and p_amount are a pair of volume_amount to be checking. If one of them is missed,
--	   this API will compute the other one.
--      4. If the profile value tells that the volume forecasting is disabled, all parameters from
--	   x_vol_tolerance_margin to x_price will be NULL and x_return_status is FND_API.G_RET_STS_SUCCESS.
--End of Comments
PROCEDURE Check_Volume_Amount(p_api_version_number	IN  NUMBER,
			 p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			 p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			 p_secondary_interest_code_id	IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_currency_code		IN  VARCHAR2,
			 p_volume			IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_amount			IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 x_return_status	 OUT NOCOPY VARCHAR2,
			 x_msg_count		 OUT NOCOPY NUMBER,
			 x_msg_data		 OUT NOCOPY VARCHAR2,
			 x_vol_tolerance_margin	 OUT NOCOPY NUMBER,
			 x_volume		 OUT NOCOPY NUMBER,
			 x_amount		 OUT NOCOPY NUMBER,
			 x_uom_code		 OUT NOCOPY VARCHAR2,
			 x_price_list_id	 OUT NOCOPY NUMBER,
			 x_price		 OUT NOCOPY NUMBER) IS
	-- Local API Variables
	l_api_name    CONSTANT VARCHAR2(30)     := 'Check_Quantity_Revenue';
	l_api_version_number  CONSTANT NUMBER   := 2.0;

	l_volume_forecast_enable	VARCHAR2(1);
	l_inv_item_tbl		AS_FOUNDATION_PUB.Inventory_Item_tbl_type;
	l_return_status		VARCHAR2(1);
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_price_list_id		NUMBER;
	l_price			NUMBER;
	l_amount_floor		NUMBER;
	l_amount_ceiling	NUMBER;
	l_vol_tolerance_margin NUMBER := TO_NUMBER(NVL(FND_PROFILE.Value('AS_PRICE_VOLUME_TOLERANCE_MARGIN'),'100'));
BEGIN
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                       p_api_version_number,
                       l_api_name,
                       G_PKG_NAME) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
	END IF;

	-- Debug Message
--	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--           dbms_output.put_line('AS_Foundation_PVT.Check_Volume_Amount: Start');
--	END IF;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
	l_volume_forecast_enable := NVL(FND_PROFILE.Value('AS_VOLUME_FORECASTING_ENABLED'),'N');
	-- Debug Message
--	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--           dbms_output.put_line('AS_Foundation_PVT - AS_VOLUME_FORECASTING_ENABLED:' || l_volume_forecast_enable);
--	END IF;
	x_vol_tolerance_margin := l_vol_tolerance_margin;
	IF (p_inventory_item_rec.inventory_item_id IS NOT NULL) THEN
	    AS_FOUNDATION_PUB.Get_Inventory_items(
			p_api_version_number => 2.0,
			p_init_msg_list => FND_API.G_TRUE,
			p_identity_salesforce_id => NULL,
			p_inventory_item_rec => p_inventory_item_rec,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_inventory_item_tbl => l_inv_item_tbl);
	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--	       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--		  dbms_output.put_line('AS_FOUNDATION_PVT - Item : Not Found');
--	       END IF;
	       raise FND_API.G_EXC_ERROR;
	    END IF;
	    IF (p_inventory_item_rec.Primary_UOM_Code IS NOT NULL) THEN
		 l_inv_item_tbl(1).Primary_UOM_Code := p_inventory_item_rec.Primary_UOM_Code;
	    END IF;
	    x_uom_code := l_inv_item_tbl(1).Primary_UOM_Code;
	    -- Debug Message
--	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--               dbms_output.put_line('AS_Foundation_PVT - UOM:' || x_uom_code);
--	    END IF;
	    Get_Price_Info(
			p_api_version_number => 2.0,
			p_init_msg_list => FND_API.G_FALSE,
			p_inventory_item_rec => l_inv_item_tbl(1),
			p_secondary_interest_code_id => NULL,
			p_currency_code => p_currency_code,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_price_list_id => l_price_list_id,
			x_price => l_price);
	 Elsif (p_secondary_interest_code_id IS NOT NULL) THEN
	    Get_Price_Info(
			p_api_version_number => 2.0,
			p_init_msg_list => FND_API.G_FALSE,
			p_inventory_item_rec => NULL,
			p_secondary_interest_code_id => p_secondary_interest_code_id,
			p_currency_code => p_currency_code,
			x_return_status => l_return_status,
			x_msg_count => l_msg_count,
			x_msg_data => l_msg_data,
			x_price_list_id => l_price_list_id,
			x_price => l_price);
	 END IF;
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--		 dbms_output.put_line('AS_FOUNDATION_PVT - Price : Not Found');
--	    END IF;
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		 FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
		 FND_MESSAGE.Set_Token('COLUMN','Price', FALSE);
		 FND_MSG_PUB.ADD;
	    END IF;
	    raise FND_API.G_EXC_ERROR;
	 END IF;

	IF l_volume_forecast_enable = 'Y' THEN
	   IF ((p_volume = FND_API.G_MISS_NUM AND p_amount = FND_API.G_MISS_NUM) OR l_price IS NULL) THEN
	      IF l_price IS NULL THEN
		 IF p_volume = FND_API.G_MISS_NUM THEN
		    x_volume := NULL;
		   ELSE
		    x_volume := p_volume;
		 END IF;
		 IF p_amount = FND_API.G_MISS_NUM THEN
		    x_amount := NULL;
		   ELSE
		    x_amount := p_amount;
		 END IF;
--	         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--		  dbms_output.put_line('AS_FOUNDATION_PVT - price is missing');
--	         END IF;
	      ELSE
--	         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		  --dbms_output.put_line('AS_FOUNDATION_PVT - volume and amount are missing');
--	         END IF;
	         x_volume := NULL;
	         x_amount := NULL;
	      END IF;
	     Elsif (p_volume = FND_API.G_MISS_NUM or p_volume IS NULL) THEN
		x_volume := p_amount / l_price;
		x_amount := p_amount;
	     Elsif (p_amount = FND_API.G_MISS_NUM or p_amount IS NULL) THEN
		x_amount := p_volume * l_price;
		x_volume := p_volume;
	     Else
		   x_amount := p_amount;
		   x_volume := p_volume;
		   l_amount_floor := p_volume * l_price * (100 - l_vol_tolerance_margin) / 100;
		   l_amount_ceiling := p_volume * l_price * (100 + l_vol_tolerance_margin) / 100;
		   IF p_amount > l_amount_ceiling OR p_amount < l_amount_floor THEN
--		      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--			   dbms_output.put_line('AS_FOUNDATION_PVT - Validate volume, amount : Exceeds Margin');
--		      END IF;
		      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			   FND_MESSAGE.Set_Name('AS', 'API_EXCEED_MARGIN');
			   FND_MSG_PUB.ADD;
		      END IF;
		      raise FND_API.G_EXC_ERROR;
		   END IF;
	   END IF; -- End of p_volume and p_amount Checking
	 -- Fix bug 889659, 889809 pass back volume and amount when Volume forecasting is turned off
	 ELSE
	   x_vol_tolerance_margin := l_vol_tolerance_margin;
	   IF p_volume <> FND_API.G_MISS_NUM THEN
	      x_volume := p_volume;
	   END IF;
	   IF p_amount <> FND_API.G_MISS_NUM THEN
              x_amount := p_amount;
	   END IF;
	END IF; -- End of checking p_volume_forecast_enable flag
	-- API body end

	x_price_list_id := l_price_list_id;
 	x_price := l_price;
	-- Success Message
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
	   FND_MESSAGE.Set_Name('AS', 'API_SUCCESS');
	   FND_MESSAGE.Set_Token('ROW', 'AS_Foundation', TRUE);
	   FND_MSG_PUB.Add;
	END IF;

	-- Debug Message
--	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--	   dbms_output.put_line('AS_Foundation_PVT.Check_Volume_Amount: End');
--	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
           (   p_count           =>      x_msg_count,
               p_data            =>      x_msg_data
           );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
--          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
--          THEN
--            dbms_output.put_line('AS_Foundation_PVT. - Cannot Find Price List Id');
--          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );
      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get
              ( p_count         =>      x_msg_count,
                p_data            =>      x_msg_data
              );
END Check_Volume_Amount;


PROCEDURE Gen_NoBind_Flex_Where(
		p_flex_where_tbl_type	IN 	AS_FOUNDATION_PVT.flex_where_tbl_type,
		x_flex_where_clause OUT NOCOPY VARCHAR2) IS
  l_flex_where_cl 	VARCHAR2(2000) 		:= NULL;
BEGIN
--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Generate Flexfield Where: begin');
--  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      l_flex_where_cl := l_flex_where_cl||' AND '||p_flex_where_tbl_type(i).name
			 || ' = '''||p_flex_where_tbl_type(i).value||'''';
    END IF;
  END LOOP;
  x_flex_where_clause := l_flex_where_cl;

--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Generate Flexfield Where: end');
--  END IF;
END;

PROCEDURE Gen_Flexfield_Where(
		p_flex_where_tbl_type	IN 	AS_FOUNDATION_PVT.flex_where_tbl_type,
		x_flex_where_clause OUT NOCOPY VARCHAR2) IS
l_flex_where_cl 	VARCHAR2(2000) 		:= NULL;
BEGIN
--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Generate Flexfield Where: begin');
--  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      l_flex_where_cl := l_flex_where_cl||' AND '||p_flex_where_tbl_type(i).name
			 || ' = :p_ofso_flex_var'||i;
    END IF;
  END LOOP;
  x_flex_where_clause := l_flex_where_cl;

--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Generate Flexfield Where: end');
--  END IF;
END;

PROCEDURE Bind_Flexfield_Where(
		p_cursor_id		IN	NUMBER,
		p_flex_where_tbl_type	IN 	AS_FOUNDATION_PVT.flex_where_tbl_type) IS
BEGIN
--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Bind Flexfield Where: begin');
--  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      DBMS_SQL.Bind_Variable(p_cursor_id, ':p_ofso_flex_var'||i,
				p_flex_where_tbl_type(i).value);
    END IF;
  END LOOP;

--  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
--    dbms_output.put_line('AS_FOUNDATION_PVT Bind Flexfield Where: end');
--  END IF;
END;

  PROCEDURE Get_Messages (p_message_count IN  NUMBER,
                          p_msgs          OUT NOCOPY VARCHAR2
  )
  IS
      l_msg_list        VARCHAR2(5000) := '
';
      l_temp_msg        VARCHAR2(2000);
      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;

      l_id              NUMBER;
      l_message_num     NUMBER;

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
  BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '
';

      END LOOP;

      p_msgs := l_msg_list;

  END Get_Messages;

END AS_FOUNDATION_PVT;

/
