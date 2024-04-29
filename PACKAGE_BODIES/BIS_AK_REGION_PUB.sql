--------------------------------------------------------
--  DDL for Package Body BIS_AK_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_AK_REGION_PUB" as
/* $Header: BISPAKRB.pls 120.7.12000000.3 2007/01/31 18:42:32 akoduri ship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_AK_REGION_PUB                                       --
--                                                                        --
--  DESCRIPTION:  Private package that calls the AK packages to           --
--        insert/update/delete records in the AK tables.          --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  01/10/03   nbarik     Enhancement : 2638594  Portlet Builder          --
--                        Added DELETE_REGION_ITEM_ROW                    --
--  10/13/03   nbarik     Bug 2806513 - Added AK_OBJECTS_PKG.INSERT_ROW   --
--  12/25/03   mdamle     Page Definer Integration - overloaded for       --
--            functionality and error messaging       --
--  02/10/03   nbarik     BSC/PMV Integration - Overloaded Procedures     --
--  05/12/04   adrao      Modifed Insert/Update APIs to ensure Nested     --
--                        Region code is inserted and updated             --
--  05/22/04   adrao      Added Exception handling to propogated to UI    --
--  06/07/04   mdamle     Added DELETE_REGION_AND_REGION_ITEMS            --
--  06/29/04   mdamle     Added INSERT_AK_OBJECT to the overloaded        --
--                insert routines                                 --
--                Added calls to ext. APIs for delete             --
--  07/22/04   mdamle     Enh#3786101 - Consider Materialized view as     --
--                a valid database object                         --
--  30-JUL-2004  rpenneru Modified for enhancemen#3748519                 --
--  08/04/04   mdamle     Bug#3823878 - Add lock_row                      --
--  08/16/04   sawu       Bug#3822777 - Added IS_MEASURE_TYPE and VALIDATE_MEASURE  --
--  08/16/04   sawu       Bug#3859267 - Added IS_COMPARE_TYPE and VALIDATE_COMPARE,
--                        overloaded UPDATE_REGION_ITEM_ATTR
--  09/24/04   mdamle     Bug#3893663 - Return SQLERRM for all unexp errs --
--                        Added rollback within the lock procedure        --
--  09/29/04   sawu       Bug#3921384 - Nullify attribute1 when attribute2
--                        is set to null for 'Compare to Measure No Target'
--  11/04/04   ankgoel    Bug#3990675 - Call AK_REGION_ITEMS_PKG.UPDATE_ROW only
--                        AK Item exists
--  11/05/04   ankgoel    Bug#3937907 - Added AK_DATA_SET to verify if AK data
--                        will be modified for the source and compare-to columns
--  11/24/04   sawu       Bug#4028958: added GET_COMPARE_AGG_FUNCTION,
--                        IS_VIEW_BY_REPORT, IS_AGGREGATE_DEFINED and
--                        updated UPDATE_REGION_ITEM_ATTR, COMPARE_TYPE_AND_SHORTNAME
--  11/29/04   skchoudh   Bug#4028958 Replaces the Aggregate Function of
--            COMPARE_TO with Measure
--  01/08/05   mdamle     Add Url to AK_REGION_ITEMS routines              --
--  02/01/05   mdamle     Add order_sequence, direction to AK_REGION_ITEMS --
--  03/21/05   ankagarw   bug#4235732 - changing count(*) to count(1)      --
--  04/26/05   ankagarw   bug#4194925 - saving measure display name as     --
--                        attribute long label in ak_region_items          --
--  04/28/05   ankgoel    Bug#4289493 - Truncated ak_object name to 23 chars
--  19-MAY-2005  visuri   GSCC Issues bug 4363854                        --
--  06/14/05   ankgoel    Bug#4371653 - Region name not getting saved
--  06/30/05   akoduri    Bug#4370200 - Default Number of Rows not getting saved
--  07/07/05   rpenneru   Bug#4468843 - Synonym should be treated as a valid DB Object.
--  07/14/05   adrao      Bug#4448994   added API  Get_Region_Code_TL_Data
--  06/19/06   ankgoel    Bug#5256605 - Support MLS for AK Region Items    --
--  09-Aug-06  ankgoel    Bug#5412517 Del all customizations for a ak region
--  10/20/06   akoduri    Bug#5584162 - Enable Sort For Percent Of Total
----------------------------------------------------------------------------

--return true if the attribute types and measure levels are the same
FUNCTION COMPARE_TYPE_AND_SHORTNAME(
  p_src_type            IN Ak_Region_Items.ATTRIBUTE1%TYPE
 ,p_src_short_name      IN Ak_Region_Items.ATTRIBUTE2%TYPE
 ,p_target_type         IN Ak_Region_Items.ATTRIBUTE1%TYPE
 ,p_target_short_name   IN Ak_Region_Items.ATTRIBUTE2%TYPE
) RETURN BOOLEAN
IS
BEGIN
 RETURN ((p_src_type = p_target_type) AND (p_src_short_name = p_target_short_name));
END COMPARE_TYPE_AND_SHORTNAME;

--return the aggregate_function (ak_region_items.attribute9) for referenced measure
--column for this particular compare_to ak_region_item
FUNCTION GET_COMPARE_AGG_FUNCTION(
  p_region_code                 IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id               IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_compare_code                IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
) RETURN Ak_Region_Items.ATTRIBUTE9%TYPE
IS
 l_ret_val      Ak_Region_Items.ATTRIBUTE9%TYPE := NULL;

 --need to take care when multiple attribute codes defined in the same report
 CURSOR agg_cur IS
   SELECT attribute9
   FROM ak_region_items
   WHERE region_code = p_region_code
   AND region_application_id = p_region_app_id
   AND attribute_code = p_compare_code
   AND attribute1 IN (BIS_AK_REGION_PUB.C_MEASURE, BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET);

BEGIN
  --retrive the first such aggregate function
  FOR rec IN agg_cur LOOP
    l_ret_val := rec.attribute9;
    EXIT;
  END LOOP;

  RETURN l_ret_val;
EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;
END GET_COMPARE_AGG_FUNCTION;


--return true if and only if p_attribute_type is one of C_MEASURE or C_MEASURE_NO_TARGET
FUNCTION IS_MEASURE_TYPE(
    p_attribute_type IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
  RETURN (p_attribute_type = BIS_AK_REGION_PUB.C_MEASURE) OR (p_attribute_type = BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET);
END IS_MEASURE_TYPE;

--return true if and only if p_attribute_type is C_COMPARE_TO_MEASURE_NO_TARGET
FUNCTION IS_COMPARE_TYPE(
    p_attribute_type IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
  RETURN (p_attribute_type = BIS_AK_REGION_PUB.C_COMPARE_TO_MEASURE_NO_TARGET);
END IS_COMPARE_TYPE;

--return true if and only if given measure short name exists
FUNCTION VALIDATE_MEASURE(
  p_short_name          IN         Bisbv_Performance_Measures.MEASURE_SHORT_NAME%Type
 ,x_measure_short_name  OUT NOCOPY Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN BOOLEAN
IS
  l_result        BOOLEAN := false;
  l_measure_name  Bisbv_Performance_Measures.MEASURE_NAME%TYPE;

CURSOR mea_cur IS
  SELECT measure_name
  FROM Bisbv_Performance_Measures
  WHERE measure_short_name = p_short_name;

BEGIN
  IF (p_short_name IS NOT NULL) THEN
    OPEN mea_cur;
    FETCH mea_cur INTO l_measure_name;
    IF (mea_cur%FOUND) THEN
      --pick the first match
      l_result := true;
      x_measure_short_name := p_short_name;
      x_measure_name := l_measure_name;
    END IF;
    CLOSE mea_cur;
  END IF;

  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN RETURN false;
END VALIDATE_MEASURE;

--return true if any only if p_compare_code refers to a valid entry in ak_region_items which
--subsequently refers to a valid measure
FUNCTION VALIDATE_COMPARE(
  p_region_code         IN          Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN          Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_compare_code        IN          Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,x_measure_short_name  OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN BOOLEAN
IS
  l_result                BOOLEAN := false;

  --need to handle the case when there are multiple ak_region_items in the same
  --report with the same attribute_code
  CURSOR comp_cur IS
    SELECT attribute2
    FROM Ak_Region_Items
    WHERE REGION_CODE = p_region_code
    AND REGION_APPLICATION_ID = p_region_app_id
    AND ATTRIBUTE_CODE = p_compare_code
    AND ATTRIBUTE1 IN (BIS_AK_REGION_PUB.C_MEASURE, BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET);
BEGIN
    IF (p_compare_code IS NOT NULL) THEN
      FOR rec IN comp_cur LOOP
        l_result := VALIDATE_MEASURE(p_short_name => rec.attribute2, x_measure_short_name => x_measure_short_name, x_measure_name => x_measure_name);
        EXIT WHEN (l_result = true);
      END LOOP;
    END IF;

    RETURN l_result;
EXCEPTION
    WHEN OTHERS THEN RETURN false;
END VALIDATE_COMPARE;

procedure INSERT_REGION_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_DATABASE_OBJECT_NAME in VARCHAR2,
    X_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_NUM_ROWS_DISPLAY in NUMBER,
    X_REGION_STYLE in VARCHAR2,
    X_REGION_OBJECT_TYPE in VARCHAR2,
    X_ISFORM_FLAG in VARCHAR2,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2) is

begin

    IF valid_database_object(X_DATABASE_OBJECT_NAME) and not AK_OBJECT_EXISTS(X_DATABASE_OBJECT_NAME) THEN
        INSERT_AK_OBJECT(
            P_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
            P_APPLICATION_ID => X_REGION_APPLICATION_ID);
    END IF;

    AK_REGIONS_PKG.INSERT_ROW(
        X_ROWID => X_ROWID,
        X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
        X_REGION_CODE  => upper(X_REGION_CODE),
        X_DATABASE_OBJECT_NAME  => X_DATABASE_OBJECT_NAME,
        X_REGION_STYLE  => X_REGION_STYLE,
        X_NUM_COLUMNS => null,
        X_ICX_CUSTOM_CALL => null,
        X_NAME  => X_NAME,
        X_DESCRIPTION  => X_DESCRIPTION,
        X_REGION_DEFAULTING_API_PKG => null,
        X_REGION_DEFAULTING_API_PROC => null,
        X_REGION_VALIDATION_API_PKG => null,
        X_REGION_VALIDATION_API_PROC => null,
        X_APPL_MODULE_OBJECT_TYPE => null,
        X_NUM_ROWS_DISPLAY => X_NUM_ROWS_DISPLAY,
        X_REGION_OBJECT_TYPE => X_REGION_OBJECT_TYPE,
        X_IMAGE_FILE_NAME => null,
        X_ISFORM_FLAG => X_ISFORM_FLAG,
        X_HELP_TARGET => null,
        X_STYLE_SHEET_FILENAME => null,
        X_VERSION => null,
        X_APPLICATIONMODULE_USAGE_NAME=>null,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => X_USER_ID,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15);

end INSERT_REGION_ROW;

procedure UPDATE_REGION_ROW (
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_DATABASE_OBJECT_NAME in VARCHAR2,
    X_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_NUM_ROWS_DISPLAY in NUMBER,
    X_REGION_STYLE in VARCHAR2,
    X_REGION_OBJECT_TYPE in VARCHAR2,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2) is

l_region_rec        AK_REGION_PUB.Region_Rec_Type;

cursor cRegion is
select  icx_custom_call,
    num_columns,
    region_defaulting_api_pkg,
    region_defaulting_api_proc,
    region_validation_api_pkg,
    region_validation_api_proc,
    applicationmodule_object_type,
    image_file_name,
    isform_flag,
    help_target,
    style_sheet_filename,
    version,
    applicationmodule_usage_name,
    add_indexed_children,
    stateful_flag,
    function_name,
    children_view_usage_name,
    search_panel,
    advanced_search_panel,
    customize_panel,
    default_search_panel,
    results_based_search,
    display_graph_table,
    disable_header,
    standalone,
    auto_customization_criteria
from ak_regions
where region_code = X_REGION_CODE
and region_application_id = X_REGION_APPLICATION_ID;

begin

    if cRegion%ISOPEN then
            CLOSE cRegion;
    end if;
        OPEN cRegion;
        FETCH cRegion INTO
        l_region_rec.icx_custom_call,
        l_region_rec.num_columns,
        l_region_rec.region_defaulting_api_pkg,
        l_region_rec.region_defaulting_api_proc,
        l_region_rec.region_validation_api_pkg,
        l_region_rec.region_validation_api_proc,
        l_region_rec.applicationmodule_object_type,
        l_region_rec.image_file_name,
        l_region_rec.isform_flag,
        l_region_rec.help_target,
        l_region_rec.style_sheet_filename,
        l_region_rec.version,
        l_region_rec.applicationmodule_usage_name,
        l_region_rec.add_indexed_children,
        l_region_rec.stateful_flag,
        l_region_rec.function_name,
        l_region_rec.children_view_usage_name,
        l_region_rec.search_panel,
        l_region_rec.advanced_search_panel,
        l_region_rec.customize_panel,
        l_region_rec.default_search_panel,
        l_region_rec.results_based_search,
        l_region_rec.display_graph_table,
        l_region_rec.disable_header,
        l_region_rec.standalone,
        l_region_rec.auto_customization_criteria;
    CLOSE cRegion;

    AK_REGIONS_PKG.UPDATE_ROW(
        X_REGION_APPLICATION_ID  => X_REGION_APPLICATION_ID,
        X_REGION_CODE  => X_REGION_CODE,
        X_DATABASE_OBJECT_NAME  => X_DATABASE_OBJECT_NAME,
        X_REGION_STYLE  => X_REGION_STYLE,
        X_NUM_COLUMNS =>l_region_rec.num_columns,
        X_ICX_CUSTOM_CALL => l_region_rec.icx_custom_call,
        X_NAME  => X_NAME,
        X_DESCRIPTION  => X_DESCRIPTION,
        X_REGION_DEFAULTING_API_PKG => l_region_rec.region_defaulting_api_pkg,
        X_REGION_DEFAULTING_API_PROC => l_region_rec.region_defaulting_api_proc,
        X_REGION_VALIDATION_API_PKG => l_region_rec.region_validation_api_pkg,
        X_REGION_VALIDATION_API_PROC => l_region_rec.region_validation_api_proc,
        X_APPL_MODULE_OBJECT_TYPE => l_region_rec.applicationmodule_object_type,
        X_NUM_ROWS_DISPLAY => X_NUM_ROWS_DISPLAY,
        X_REGION_OBJECT_TYPE => X_REGION_OBJECT_TYPE,
        X_IMAGE_FILE_NAME => l_region_rec.image_file_name,
        X_ISFORM_FLAG => l_region_rec.isform_flag,
        X_HELP_TARGET => l_region_rec.help_target,
        X_STYLE_SHEET_FILENAME => l_region_rec.style_sheet_filename,
        X_VERSION => l_region_rec.version,
        X_APPLICATIONMODULE_USAGE_NAME => l_region_rec.applicationmodule_usage_name,
        X_ADD_INDEXED_CHILDREN => l_region_rec.add_indexed_children,
        X_STATEFUL_FLAG => l_region_rec.stateful_flag,
        X_FUNCTION_NAME => l_region_rec.function_name,
        X_CHILDREN_VIEW_USAGE_NAME => l_region_rec.children_view_usage_name,
        X_SEARCH_PANEL => l_region_rec.search_panel,
        X_ADVANCED_SEARCH_PANEL =>l_region_rec.advanced_search_panel,
        X_CUSTOMIZE_PANEL => l_region_rec.customize_panel,
        X_DEFAULT_SEARCH_PANEL => l_region_rec.default_search_panel,
        X_RESULTS_BASED_SEARCH => l_region_rec.results_based_search,
        X_DISPLAY_GRAPH_TABLE => l_region_rec.display_graph_table,
        X_DISABLE_HEADER => l_region_rec.disable_header,
        X_STANDALONE => l_region_rec.standalone,
        X_AUTO_CUSTOMIZATION_CRITERIA =>l_region_rec.auto_customization_criteria,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15);
end UPDATE_REGION_ROW;


procedure INSERT_REGION_ITEM_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_ATTRIBUTE_APPLICATION_ID in NUMBER,
    X_ATTRIBUTE_CODE in VARCHAR2,
    X_DISPLAY_SEQUENCE in number,
    X_NODE_DISPLAY_FLAG in VARCHAR2,
    X_NODE_QUERY_FLAG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
    X_DISPLAY_VALUE_LENGTH in number,
    X_ITEM_STYLE in VARCHAR2,
    X_REQUIRED_FLAG in VARCHAR2,
    X_NESTED_REGION_CODE IN VARCHAR2,
    X_NESTED_REGION_APPL_ID IN NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_URL in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_SEQUENCE in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_DIRECTION in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR) is

l_display_value_length      number;
l_attributeCount            number;
l_attribute_rowid           varchar2(50);
l_url                   AK_REGION_ITEMS.URL%TYPE;
l_nested_region_appl_id     number;

cursor cAttributeExists is
select  count(1)
from ak_attributes
where attribute_code = X_ATTRIBUTE_CODE
and attribute_application_id = X_ATTRIBUTE_APPLICATION_ID;

begin

    if cAttributeExists%ISOPEN then
            CLOSE cAttributeExists;
    end if;
        OPEN cAttributeExists;
        FETCH cAttributeExists INTO l_attributeCount;
    CLOSE cAttributeExists;

    if l_attributeCount = 0 then
        -- Insert into Attributes

        AK_ATTRIBUTES_PKG.INSERT_ROW (
            X_ROWID => l_attribute_rowid,
            X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
            X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
            X_ATTRIBUTE_LABEL_LENGTH => c_ATTR_LABEL_LENGTH,
            X_ATTRIBUTE_VALUE_LENGTH  => c_ATTR_VALUE_LENGTH,
            X_BOLD => c_BOLD ,
            X_ITALIC => c_ITALIC,
            X_UPPER_CASE_FLAG => c_UPPER_CASE_FLAG,
            X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
            X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
            X_DEFAULT_VALUE_VARCHAR2 => null,
            X_DEFAULT_VALUE_NUMBER => null,
            X_DEFAULT_VALUE_DATE => null,
            X_LOV_REGION_CODE => null,
            X_LOV_REGION_APPLICATION_ID => null,
            X_DATA_TYPE => c_ATTR_DATATYPE,
            X_DISPLAY_HEIGHT => null,
            X_ITEM_STYLE => X_ITEM_STYLE,
            X_CSS_CLASS_NAME => null,
            X_CSS_LABEL_CLASS_NAME => null,
            X_PRECISION => null,
            X_EXPANSION  => null,
            X_ALS_MAX_LENGTH => null,
            X_POPLIST_VIEWOBJECT => null,
            X_POPLIST_DISPLAY_ATTRIBUTE => null,
            X_POPLIST_VALUE_ATTRIBUTE => null,
            X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_NAME => X_ATTRIBUTE_CODE,
            X_ATTRIBUTE_LABEL_LONG => null,
            X_ATTRIBUTE_LABEL_SHORT => null,
            X_DESCRIPTION => null,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => X_USER_ID,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => X_USER_ID,
            X_LAST_UPDATE_LOGIN => X_USER_ID);
    end if;

    if X_URL <> BIS_COMMON_UTILS.G_DEF_CHAR then
    l_url := x_url;
    end if;

    l_nested_region_appl_id := x_nested_region_appl_id;
    if (x_nested_region_code is null) then
    l_nested_region_appl_id := null;
    end if;


    AK_REGION_ITEMS_PKG.INSERT_ROW (
        X_ROWID => X_ROWID,
        X_REGION_APPLICATION_ID => X_REGION_APPLICATION_ID,
        X_REGION_CODE => upper(X_REGION_CODE),
        X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE => upper(X_ATTRIBUTE_CODE),
        X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
        X_NODE_DISPLAY_FLAG => X_NODE_DISPLAY_FLAG,
        X_NODE_QUERY_FLAG => X_NODE_QUERY_FLAG,
        X_ATTRIBUTE_LABEL_LENGTH => X_ATTRIBUTE_LABEL_LENGTH,
        X_BOLD => c_BOLD,
        X_ITALIC  => c_ITALIC,
        X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
        X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
        X_ITEM_STYLE => X_ITEM_STYLE,
        X_OBJECT_ATTRIBUTE_FLAG => c_OBJECT_ATTRIBUTE_FLAG,
        X_ATTRIBUTE_LABEL_LONG => X_ATTRIBUTE_LABEL_LONG,
        X_DESCRIPTION => null,
        X_SECURITY_CODE => null,
        X_UPDATE_FLAG => c_UPDATE_FLAG,
        X_REQUIRED_FLAG => X_REQUIRED_FLAG,
        X_DISPLAY_VALUE_LENGTH => X_DISPLAY_VALUE_LENGTH,
        X_LOV_REGION_APPLICATION_ID => null,
        X_LOV_REGION_CODE => null,
        X_LOV_FOREIGN_KEY_NAME => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE  => null,
        X_LOV_DEFAULT_FLAG  => null,
        X_REGION_DEFAULTING_API_PKG => null,
        X_REGION_DEFAULTING_API_PROC => null,
        X_REGION_VALIDATION_API_PKG => null,
        X_REGION_VALIDATION_API_PROC => null,
        X_ORDER_SEQUENCE  => X_ORDER_SEQUENCE,
        X_ORDER_DIRECTION => x_ORDER_DIRECTION,
        X_DEFAULT_VALUE_VARCHAR2 => null,
        X_DEFAULT_VALUE_NUMBER => null,
        X_DEFAULT_VALUE_DATE  => null,
        X_ITEM_NAME  => replace(initcap(X_ATTRIBUTE_CODE), '_', ''),
        X_DISPLAY_HEIGHT  => c_DISPLAY_HEIGHT,
        X_SUBMIT  => c_SUBMIT,
        X_ENCRYPT  => c_ENCRYPT,
        X_VIEW_USAGE_NAME  => null,
        X_VIEW_ATTRIBUTE_NAME  => null,
        X_CSS_CLASS_NAME  => null,
        X_CSS_LABEL_CLASS_NAME  => null,
        X_URL  => l_URL,
        X_POPLIST_VIEWOBJECT  => null,
        X_POPLIST_DISPLAY_ATTRIBUTE  => null,
        X_POPLIST_VALUE_ATTRIBUTE  => null,
        X_IMAGE_FILE_NAME  => null,
        X_NESTED_REGION_CODE  => upper(X_NESTED_REGION_CODE),
        X_NESTED_REGION_APPL_ID => l_NESTED_REGION_APPL_ID,
        X_MENU_NAME   => null,
        X_FLEXFIELD_NAME   => null,
        X_FLEXFIELD_APPLICATION_ID   => null,
        X_TABULAR_FUNCTION_CODE   => null,
        X_TIP_TYPE   => null,
        X_TIP_MESSAGE_NAME   => null,
        X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_FLEX_SEGMENT_LIST   => null,
        X_ENTITY_ID   => null,
        X_ANCHOR   => null,
        X_POPLIST_VIEW_USAGE_NAME   => null,
        X_USER_CUSTOMIZABLE   => null,
        X_ADMIN_CUSTOMIZABLE   => c_ADMIN_CUSTOMIZABLE,
        X_INVOKE_FUNCTION_NAME   => null,
        X_ATTRIBUTE_LABEL_SHORT  => null,
        X_EXPANSION  => null,
        X_ALS_MAX_LENGTH  => null,
        X_SORTBY_VIEW_ATTRIBUTE_NAME  => null,
        X_ICX_CUSTOM_CALL   => null,
        X_INITIAL_SORT_SEQUENCE  => null,
        X_CUSTOMIZATION_APPLICATION_ID   => null,
        X_CUSTOMIZATION_CODE   => null,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => X_USER_ID,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15);

end INSERT_REGION_ITEM_ROW;


procedure UPDATE_REGION_ITEM_ROW (
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_ATTRIBUTE_APPLICATION_ID in NUMBER,
    X_ATTRIBUTE_CODE in VARCHAR2,
    X_DISPLAY_SEQUENCE in VARCHAR2,
    X_NODE_DISPLAY_FLAG in VARCHAR2,
    X_NODE_QUERY_FLAG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
    X_DISPLAY_VALUE_LENGTH in number,
    X_ITEM_STYLE in VARCHAR2,
    X_REQUIRED_FLAG in VARCHAR2,
    X_NESTED_REGION_CODE IN VARCHAR2,
    X_NESTED_REGION_APPL_ID IN NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_URL in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_SEQUENCE in VARCHAR2 := NULL,
    X_ORDER_DIRECTION in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR)
 is

l_regionItem_rec        AK_REGION_PUB.Item_Rec_Type;

cursor cRegionItem is
select  display_sequence,
    bold,
    italic,
    vertical_alignment,
    horizontal_alignment,
    item_style,
    object_attribute_flag,
    icx_custom_call,
    update_flag,
    required_flag,
    security_code,
    default_value_varchar2,
    default_value_number,
    default_value_date,
    lov_region_application_id,
    lov_region_code,
    lov_foreign_key_name,
    lov_attribute_application_id,
    lov_attribute_code,
    lov_default_flag,
    region_defaulting_api_pkg,
    region_defaulting_api_proc,
    region_validation_api_pkg,
    region_validation_api_proc,
    order_sequence,
    order_direction,
    display_height,
    submit,
    encrypt,
    css_class_name,
    view_usage_name,
    view_attribute_name,
    url,
    poplist_viewobject,
    poplist_display_attribute,
    poplist_value_attribute,
    image_file_name,
    item_name,
    css_label_class_name,
    menu_name,
    flexfield_name,
    flexfield_application_id,
    tabular_function_code,
    tip_type,
    tip_message_name,
    tip_message_application_id,
    flex_segment_list,
    entity_id,
    anchor,
    poplist_view_usage_name,
    user_customizable,
    sortby_view_attribute_name,
    admin_customizable,
    invoke_function_name,
    expansion,
    als_max_length,
    initial_sort_sequence,
    customization_application_id,
    customization_code,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute_label_short,
    description
from ak_region_items_vl
where region_code = X_REGION_CODE
and region_application_id = X_REGION_APPLICATION_ID
and attribute_code = X_ATTRIBUTE_CODE
and attribute_application_id = X_ATTRIBUTE_APPLICATION_ID;


begin

    -- Save the current data
    if cRegionItem%ISOPEN then
            CLOSE cRegionItem;
    end if;
        OPEN cRegionItem;
        FETCH cRegionItem INTO
        l_regionItem_rec.display_sequence,
        l_regionItem_rec.bold,
        l_regionItem_rec.italic,
        l_regionItem_rec.vertical_alignment,
        l_regionItem_rec.horizontal_alignment,
        l_regionItem_rec.item_style,
        l_regionItem_rec.object_attribute_flag,
        l_regionItem_rec.icx_custom_call,
        l_regionItem_rec.update_flag,
        l_regionItem_rec.required_flag,
        l_regionItem_rec.security_code,
        l_regionItem_rec.default_value_varchar2,
        l_regionItem_rec.default_value_number,
        l_regionItem_rec.default_value_date,
        l_regionItem_rec.lov_region_application_id,
        l_regionItem_rec.lov_region_code,
        l_regionItem_rec.lov_foreign_key_name,
        l_regionItem_rec.lov_attribute_application_id,
        l_regionItem_rec.lov_attribute_code,
        l_regionItem_rec.lov_default_flag,
        l_regionItem_rec.region_defaulting_api_pkg,
        l_regionItem_rec.region_defaulting_api_proc,
        l_regionItem_rec.region_validation_api_pkg,
        l_regionItem_rec.region_validation_api_proc,
        l_regionItem_rec.order_sequence,
        l_regionItem_rec.order_direction,
        l_regionItem_rec.display_height,
        l_regionItem_rec.submit,
        l_regionItem_rec.encrypt,
        l_regionItem_rec.css_class_name,
        l_regionItem_rec.view_usage_name,
        l_regionItem_rec.view_attribute_name,
        l_regionItem_rec.url,
        l_regionItem_rec.poplist_viewobject,
        l_regionItem_rec.poplist_display_attr,
        l_regionItem_rec.poplist_value_attr,
        l_regionItem_rec.image_file_name,
        l_regionItem_rec.item_name,
        l_regionItem_rec.css_label_class_name,
        l_regionItem_rec.menu_name,
        l_regionItem_rec.flexfield_name,
        l_regionItem_rec.flexfield_application_id,
        l_regionItem_rec.tabular_function_code,
        l_regionItem_rec.tip_type,
        l_regionItem_rec.tip_message_name,
        l_regionItem_rec.tip_message_application_id,
        l_regionItem_rec.flex_segment_list,
        l_regionItem_rec.entity_id,
        l_regionItem_rec.anchor,
        l_regionItem_rec.poplist_view_usage_name,
        l_regionItem_rec.user_customizable,
        l_regionItem_rec.sortby_view_attribute_name,
        l_regionItem_rec.admin_customizable,
        l_regionItem_rec.invoke_function_name,
        l_regionItem_rec.expansion,
        l_regionItem_rec.als_max_length,
        l_regionItem_rec.initial_sort_sequence,
        l_regionItem_rec.customization_application_id,
        l_regionItem_rec.customization_code,
        l_regionItem_rec.attribute_category,
        l_regionItem_rec.attribute1,
        l_regionItem_rec.attribute2,
        l_regionItem_rec.attribute3,
        l_regionItem_rec.attribute4,
        l_regionItem_rec.attribute5,
        l_regionItem_rec.attribute6,
        l_regionItem_rec.attribute7,
        l_regionItem_rec.attribute8,
        l_regionItem_rec.attribute9,
        l_regionItem_rec.attribute10,
        l_regionItem_rec.attribute12,
        l_regionItem_rec.attribute13,
        l_regionItem_rec.attribute14,
        l_regionItem_rec.attribute15,
        l_regionItem_rec.attribute_label_short,
        l_regionItem_rec.description;
    CLOSE cRegionItem;

    l_regionItem_rec.url := x_url;

    if X_ORDER_DIRECTION <> BIS_COMMON_UTILS.G_DEF_CHAR then
    l_regionItem_rec.order_direction := x_ORDER_DIRECTION;
    end if;

    AK_REGION_ITEMS_PKG.UPDATE_ROW (
        X_REGION_APPLICATION_ID => X_REGION_APPLICATION_ID,
        X_REGION_CODE => X_REGION_CODE,
        X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
        X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
        X_NODE_DISPLAY_FLAG => X_NODE_DISPLAY_FLAG,
        X_NODE_QUERY_FLAG => X_NODE_QUERY_FLAG,
        X_ATTRIBUTE_LABEL_LENGTH => X_ATTRIBUTE_LABEL_LENGTH,
        X_BOLD => l_regionItem_rec.bold,
        X_ITALIC  => l_regionItem_rec.italic,
        X_VERTICAL_ALIGNMENT => l_regionItem_rec.VERTICAL_ALIGNMENT,
        X_HORIZONTAL_ALIGNMENT => l_regionItem_rec.HORIZONTAL_ALIGNMENT,
        X_ITEM_STYLE => l_regionItem_rec.ITEM_STYLE,
        X_OBJECT_ATTRIBUTE_FLAG => l_regionItem_rec.OBJECT_ATTRIBUTE_FLAG,
        X_ATTRIBUTE_LABEL_LONG => X_ATTRIBUTE_LABEL_LONG,
        X_DESCRIPTION => l_regionItem_rec.description,
        X_SECURITY_CODE => l_regionItem_rec.security_code,
        X_UPDATE_FLAG => l_regionItem_rec.UPDATE_FLAG,
        X_REQUIRED_FLAG => l_regionItem_rec.REQUIRED_FLAG,
        X_DISPLAY_VALUE_LENGTH => X_DISPLAY_VALUE_LENGTH,
        X_LOV_REGION_APPLICATION_ID => l_regionItem_rec.lov_region_application_id,
        X_LOV_REGION_CODE => l_regionItem_rec.lov_region_code,
        X_LOV_FOREIGN_KEY_NAME => l_regionItem_rec.lov_foreign_key_name,
        X_LOV_ATTRIBUTE_APPLICATION_ID => l_regionItem_rec.lov_attribute_application_id,
        X_LOV_ATTRIBUTE_CODE  => l_regionItem_rec.lov_attribute_code,
        X_LOV_DEFAULT_FLAG  => l_regionItem_rec.lov_default_flag,
        X_REGION_DEFAULTING_API_PKG => l_regionItem_rec.region_defaulting_api_pkg,
        X_REGION_DEFAULTING_API_PROC => l_regionItem_rec.region_defaulting_api_proc,
        X_REGION_VALIDATION_API_PKG => l_regionItem_rec.region_validation_api_pkg,
        X_REGION_VALIDATION_API_PROC => l_regionItem_rec.region_validation_api_proc,
        X_ORDER_SEQUENCE  => X_ORDER_SEQUENCE,
        X_ORDER_DIRECTION => l_regionItem_rec.order_direction,
        X_DEFAULT_VALUE_VARCHAR2 => l_regionItem_rec.default_value_varchar2,
        X_DEFAULT_VALUE_NUMBER => l_regionItem_rec.default_value_number,
        X_DEFAULT_VALUE_DATE  => l_regionItem_rec.default_value_date,
        X_ITEM_NAME  => l_regionItem_rec.item_name,
        X_DISPLAY_HEIGHT  => l_regionItem_rec.display_height,
        X_SUBMIT  => l_regionItem_rec.submit,
        X_ENCRYPT  => l_regionItem_rec.encrypt,
        X_VIEW_USAGE_NAME  => l_regionItem_rec.view_usage_name,
        X_VIEW_ATTRIBUTE_NAME  => l_regionItem_rec.view_attribute_name,
        X_CSS_CLASS_NAME  => l_regionItem_rec.css_class_name,
        X_CSS_LABEL_CLASS_NAME  => l_regionItem_rec.css_label_class_name,
        X_URL  => l_regionItem_rec.url,
        X_POPLIST_VIEWOBJECT  => l_regionItem_rec.poplist_viewobject,
        X_POPLIST_DISPLAY_ATTRIBUTE  => l_regionItem_rec.poplist_display_attr,
        X_POPLIST_VALUE_ATTRIBUTE  => l_regionItem_rec.poplist_value_attr,
        X_IMAGE_FILE_NAME  => l_regionItem_rec.image_file_name,
        X_NESTED_REGION_CODE  => X_NESTED_REGION_CODE,
        X_NESTED_REGION_APPL_ID => X_NESTED_REGION_APPL_ID,
        X_MENU_NAME   =>l_regionItem_rec.menu_name,
        X_FLEXFIELD_NAME   => l_regionItem_rec.flexfield_name,
        X_FLEXFIELD_APPLICATION_ID   => l_regionItem_rec.flexfield_application_id,
        X_TABULAR_FUNCTION_CODE   => l_regionItem_rec.tabular_function_code,
        X_TIP_TYPE   => l_regionItem_rec.tip_type,
        X_TIP_MESSAGE_NAME   => l_regionItem_rec.tip_message_name,
        X_TIP_MESSAGE_APPLICATION_ID   => l_regionItem_rec.tip_message_application_id,
        X_FLEX_SEGMENT_LIST   => l_regionItem_rec.flex_segment_list,
        X_ENTITY_ID   => l_regionItem_rec.entity_id,
        X_ANCHOR   => l_regionItem_rec.anchor,
        X_POPLIST_VIEW_USAGE_NAME   => l_regionItem_rec.poplist_view_usage_name,
        X_USER_CUSTOMIZABLE   => l_regionItem_rec.user_customizable,
        X_ADMIN_CUSTOMIZABLE   => l_regionItem_rec.admin_customizable,
        X_INVOKE_FUNCTION_NAME   => l_regionItem_rec.invoke_function_name,
        X_EXPANSION  =>l_regionItem_rec.expansion,
        X_ALS_MAX_LENGTH  => l_regionItem_rec.als_max_length,
        X_SORTBY_VIEW_ATTRIBUTE_NAME  =>l_regionItem_rec.sortby_view_attribute_name,
        X_ICX_CUSTOM_CALL   => l_regionItem_rec.icx_custom_call,
        X_INITIAL_SORT_SEQUENCE  => l_regionItem_rec.initial_sort_sequence,
        X_CUSTOMIZATION_APPLICATION_ID   => l_regionItem_rec.customization_application_id,
        X_CUSTOMIZATION_CODE   => l_regionItem_rec.customization_code,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
        X_ATTRIBUTE_CATEGORY => X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => X_ATTRIBUTE1,
        X_ATTRIBUTE2 => X_ATTRIBUTE2,
        X_ATTRIBUTE3 => X_ATTRIBUTE3,
        X_ATTRIBUTE4 => X_ATTRIBUTE4,
        X_ATTRIBUTE5 => X_ATTRIBUTE5,
        X_ATTRIBUTE6 => X_ATTRIBUTE6,
        X_ATTRIBUTE7 => X_ATTRIBUTE7,
        X_ATTRIBUTE8 => X_ATTRIBUTE8,
        X_ATTRIBUTE9 => X_ATTRIBUTE9,
        X_ATTRIBUTE10 => X_ATTRIBUTE10,
        X_ATTRIBUTE11 => X_ATTRIBUTE11,
        X_ATTRIBUTE12 => X_ATTRIBUTE12,
        X_ATTRIBUTE13 => X_ATTRIBUTE13,
        X_ATTRIBUTE14 => X_ATTRIBUTE14,
        X_ATTRIBUTE15 => X_ATTRIBUTE15);

end UPDATE_REGION_ITEM_ROW;

--nbarik 10/01/03 - Delete Region Item row
PROCEDURE DELETE_REGION_ITEM_ROW (
   X_REGION_APPLICATION_ID IN NUMBER,
   X_REGION_CODE IN VARCHAR2,
   X_ATTRIBUTE_APPLICATION_ID IN NUMBER,
   X_ATTRIBUTE_CODE IN VARCHAR2
 ) IS
BEGIN

  AK_REGION_ITEMS_PKG.DELETE_ROW(
    X_REGION_APPLICATION_ID => X_REGION_APPLICATION_ID,
    X_REGION_CODE => X_REGION_CODE,
    X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE
  );

END DELETE_REGION_ITEM_ROW;

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure INSERT_REGION_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_DATABASE_OBJECT_NAME     in VARCHAR2
,p_NAME             in VARCHAR2
,p_REGION_STYLE         in VARCHAR2 := c_TABLE_LAYOUT_STYLE
,p_DESCRIPTION          in VARCHAR2 := NULL
,p_APPL_MODULE_OBJECT_TYPE  in VARCHAR2 := NULL
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := NULL
,p_ATTRIBUTE1           in VARCHAR2 := NULL
,p_ATTRIBUTE2           in VARCHAR2 := NULL
,p_ATTRIBUTE3           in VARCHAR2 := NULL
,p_ATTRIBUTE4           in VARCHAR2 := NULL
,p_ATTRIBUTE5           in VARCHAR2 := NULL
,p_ATTRIBUTE6           in VARCHAR2 := NULL
,p_ATTRIBUTE7           in VARCHAR2 := NULL
,p_ATTRIBUTE8           in VARCHAR2 := NULL
,p_ATTRIBUTE9           in VARCHAR2 := NULL
,p_ATTRIBUTE10          in VARCHAR2 := NULL
,p_ATTRIBUTE11          in VARCHAR2 := NULL
,p_ATTRIBUTE12          in VARCHAR2 := NULL
,p_ATTRIBUTE13          in VARCHAR2 := NULL
,p_ATTRIBUTE14          in VARCHAR2 := NULL
,p_ATTRIBUTE15          in VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_rowid         Varchar2(30);
l_image_file_name   Varchar2(80) := null;
begin

    IF valid_database_object(p_DATABASE_OBJECT_NAME) and not AK_OBJECT_EXISTS(p_DATABASE_OBJECT_NAME ) THEN
        INSERT_AK_OBJECT(
            P_DATABASE_OBJECT_NAME => p_DATABASE_OBJECT_NAME ,
            P_APPLICATION_ID => p_REGION_APPLICATION_ID);
    END IF;


    if (p_REGION_STYLE = c_PAGE_LAYOUT_STYLE) then
        l_image_file_name := c_IMAGE_FILE_NAME;
    end if;

    AK_REGIONS_PKG.INSERT_ROW(
        X_ROWID => l_ROWID,
        X_REGION_APPLICATION_ID  => p_REGION_APPLICATION_ID,
        X_REGION_CODE  => upper(p_REGION_CODE),
        X_DATABASE_OBJECT_NAME  => p_DATABASE_OBJECT_NAME,
        X_REGION_STYLE  => p_REGION_STYLE,
        X_NUM_COLUMNS => null,
        X_ICX_CUSTOM_CALL => null,
        X_NAME  => p_NAME,
        X_DESCRIPTION  => p_DESCRIPTION,
        X_REGION_DEFAULTING_API_PKG => null,
        X_REGION_DEFAULTING_API_PROC => null,
        X_REGION_VALIDATION_API_PKG => null,
        X_REGION_VALIDATION_API_PROC => null,
        X_APPL_MODULE_OBJECT_TYPE => p_appl_module_object_type,
        X_NUM_ROWS_DISPLAY => null,
        X_REGION_OBJECT_TYPE => null,
        X_IMAGE_FILE_NAME => l_image_file_name,
        X_ISFORM_FLAG => c_ISFORM_FLAG,
        X_HELP_TARGET => null,
        X_STYLE_SHEET_FILENAME => null,
        X_VERSION => null,
        X_APPLICATIONMODULE_USAGE_NAME=>null,
        X_ADD_INDEXED_CHILDREN => c_ADD_INDEXED_CHILDREN,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => p_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_ATTRIBUTE1,
        X_ATTRIBUTE2 => p_ATTRIBUTE2,
        X_ATTRIBUTE3 => p_ATTRIBUTE3,
        X_ATTRIBUTE4 => p_ATTRIBUTE4,
        X_ATTRIBUTE5 => p_ATTRIBUTE5,
        X_ATTRIBUTE6 => p_ATTRIBUTE6,
        X_ATTRIBUTE7 => p_ATTRIBUTE7,
        X_ATTRIBUTE8 => p_ATTRIBUTE8,
        X_ATTRIBUTE9 => p_ATTRIBUTE9,
        X_ATTRIBUTE10 => p_ATTRIBUTE10,
        X_ATTRIBUTE11 => p_ATTRIBUTE11,
        X_ATTRIBUTE12 => p_ATTRIBUTE12,
        X_ATTRIBUTE13 => p_ATTRIBUTE13,
        X_ATTRIBUTE14 => p_ATTRIBUTE14,
        X_ATTRIBUTE15 => p_ATTRIBUTE15);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := 'BIS_AK_REGION_PUB.INSERT_ROW: ' || SQLERRM;
    end if;

end INSERT_REGION_ROW;

-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE INSERT_REGION_ROW
(  p_commit                       IN  VARCHAR2   := FND_API.G_TRUE
 , p_Report_Region_Rec            IN  BIS_AK_REGION_PUB.Bis_Region_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_rowid             VARCHAR2(30);
BEGIN

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF valid_database_object(p_Report_Region_Rec.Database_Object_Name) and not AK_OBJECT_EXISTS(p_Report_Region_Rec.Database_Object_Name) THEN
        INSERT_AK_OBJECT(
            P_DATABASE_OBJECT_NAME => p_Report_Region_Rec.Database_Object_Name,
            P_APPLICATION_ID => p_Report_Region_Rec.Region_Application_Id);
    END IF;

    AK_REGIONS_PKG.INSERT_ROW
    (     X_ROWID                        => l_rowid
        , X_REGION_APPLICATION_ID        => p_Report_Region_Rec.Region_Application_Id
        , X_REGION_CODE                  => UPPER(p_Report_Region_Rec.Region_Code)
        , X_DATABASE_OBJECT_NAME         => p_Report_Region_Rec.Database_Object_Name
        , X_REGION_STYLE                 => p_Report_Region_Rec.Region_Style
        , X_NUM_COLUMNS                  => NULL
        , X_ICX_CUSTOM_CALL              => NULL
        , X_NAME                         => p_Report_Region_Rec.Region_Name
        , X_DESCRIPTION                  => p_Report_Region_Rec.Region_Description
        , X_REGION_DEFAULTING_API_PKG    => NULL
        , X_REGION_DEFAULTING_API_PROC   => NULL
        , X_REGION_VALIDATION_API_PKG    => NULL
        , X_REGION_VALIDATION_API_PROC   => NULL
        , X_APPL_MODULE_OBJECT_TYPE      => NULL
        , X_NUM_ROWS_DISPLAY             => p_Report_Region_Rec.Display_Rows
        , X_REGION_OBJECT_TYPE           => p_Report_Region_Rec.Region_Object_Type
        , X_IMAGE_FILE_NAME              => NULL
        , X_ISFORM_FLAG                  => c_ISFORM_FLAG
        , X_HELP_TARGET                  => p_Report_Region_Rec.Help_Target
        , X_STYLE_SHEET_FILENAME         => NULL
        , X_VERSION                      => NULL
        , X_APPLICATIONMODULE_USAGE_NAME => NULL
        , X_ADD_INDEXED_CHILDREN         => c_ADD_INDEXED_CHILDREN
        , X_CREATION_DATE                => SYSDATE
        , X_CREATED_BY                   => fnd_global.user_id
        , X_LAST_UPDATE_DATE             => SYSDATE
        , X_LAST_UPDATED_BY              => fnd_global.user_id
        , X_LAST_UPDATE_LOGIN            => fnd_global.user_id
        , X_ATTRIBUTE_CATEGORY           => C_ATTRIBUTE_CATEGORY
        , X_ATTRIBUTE1                   => p_Report_Region_Rec.Disable_View_By
        , X_ATTRIBUTE2                   => p_Report_Region_Rec.No_Of_Portlet_Rows
        , X_ATTRIBUTE3                   => p_Report_Region_Rec.Schedule
        , X_ATTRIBUTE4                   => p_Report_Region_Rec.Header_File_Procedure
        , X_ATTRIBUTE5                   => p_Report_Region_Rec.Footer_File_Procedure
        , X_ATTRIBUTE6                   => p_Report_Region_Rec.Group_By
        , X_ATTRIBUTE7                   => p_Report_Region_Rec.Order_By
        , X_ATTRIBUTE8                   => p_Report_Region_Rec.Plsql_For_Report_Query
        , X_ATTRIBUTE9                   => p_Report_Region_Rec.Display_Subtotals
        , X_ATTRIBUTE10                  => p_Report_Region_Rec.Data_Source
        , X_ATTRIBUTE11                  => p_Report_Region_Rec.Where_Clause
        , X_ATTRIBUTE12                  => p_Report_Region_Rec.Dimension_Group
        , X_ATTRIBUTE13                  => p_Report_Region_Rec.Parameter_Layout
        , X_ATTRIBUTE14                  => NULL
        , X_ATTRIBUTE15                  => NULL
    );

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.INSERT_REGION_ROW: ' || SQLERRM;
    END IF;

END INSERT_REGION_ROW;

procedure UPDATE_REGION_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_DATABASE_OBJECT_NAME     in VARCHAR2
,p_NAME             in VARCHAR2
,p_REGION_STYLE         in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_APPL_MODULE_OBJECT_TYPE  in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE1           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE2           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE3           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE4           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE5           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE6           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE7           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE8           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE9           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE10          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE11          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE12          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE13          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE14          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE15          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_region_rec        AK_REGION_PUB.Region_Rec_Type;

cursor cRegion is
select  icx_custom_call,
    num_columns,
    region_defaulting_api_pkg,
    region_defaulting_api_proc,
    region_validation_api_pkg,
    region_validation_api_proc,
    applicationmodule_object_type,
    image_file_name,
    isform_flag,
    help_target,
    style_sheet_filename,
    version,
    applicationmodule_usage_name,
    add_indexed_children,
    stateful_flag,
    function_name,
    children_view_usage_name,
    search_panel,
    advanced_search_panel,
    customize_panel,
    default_search_panel,
    results_based_search,
    display_graph_table,
    disable_header,
    standalone,
    auto_customization_criteria,
    region_style,
    name,
    description,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15
from ak_regions_vl
where region_code = p_REGION_CODE
and region_application_id = p_REGION_APPLICATION_ID;

begin

    if cRegion%ISOPEN then
            CLOSE cRegion;
    end if;
        OPEN cRegion;
        FETCH cRegion INTO
        l_region_rec.icx_custom_call,
        l_region_rec.num_columns,
        l_region_rec.region_defaulting_api_pkg,
        l_region_rec.region_defaulting_api_proc,
        l_region_rec.region_validation_api_pkg,
        l_region_rec.region_validation_api_proc,
        l_region_rec.applicationmodule_object_type,
        l_region_rec.image_file_name,
        l_region_rec.isform_flag,
        l_region_rec.help_target,
        l_region_rec.style_sheet_filename,
        l_region_rec.version,
        l_region_rec.applicationmodule_usage_name,
        l_region_rec.add_indexed_children,
        l_region_rec.stateful_flag,
        l_region_rec.function_name,
        l_region_rec.children_view_usage_name,
        l_region_rec.search_panel,
        l_region_rec.advanced_search_panel,
        l_region_rec.customize_panel,
        l_region_rec.default_search_panel,
        l_region_rec.results_based_search,
        l_region_rec.display_graph_table,
        l_region_rec.disable_header,
        l_region_rec.standalone,
        l_region_rec.auto_customization_criteria,
        l_region_rec.region_style,
    l_region_rec.name,
        l_region_rec.description,
        l_region_rec.attribute_category,
        l_region_rec.attribute1,
        l_region_rec.attribute2,
        l_region_rec.attribute3,
        l_region_rec.attribute4,
        l_region_rec.attribute5,
        l_region_rec.attribute6,
        l_region_rec.attribute7,
        l_region_rec.attribute8,
        l_region_rec.attribute9,
        l_region_rec.attribute10,
        l_region_rec.attribute11,
        l_region_rec.attribute12,
        l_region_rec.attribute13,
        l_region_rec.attribute14,
        l_region_rec.attribute15;
    CLOSE cRegion;

    if (p_region_style <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.region_style := p_region_style;
    end if;
    IF (p_name <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.name := p_name;
    END IF;
    if (p_description <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.description := p_description;
    end if;
    if (p_appl_module_object_type <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.applicationmodule_object_type := p_appl_module_object_type;
    end if;
    if (p_attribute_category <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute_category := p_attribute_category;
    end if;
    if (p_attribute1 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute1 := p_attribute1;
    end if;
    if (p_attribute2 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute2 := p_attribute2;
    end if;
    if (p_attribute3 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute3 := p_attribute3;
    end if;
    if (p_attribute4 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute4 := p_attribute4;
    end if;
    if (p_attribute5 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute5 := p_attribute5;
    end if;
    if (p_attribute6 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute6 := p_attribute6;
    end if;
    if (p_attribute7 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute7 := p_attribute7;
    end if;
    if (p_attribute8 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute8 := p_attribute8;
    end if;
    if (p_attribute9 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute9 := p_attribute9;
    end if;
    if (p_attribute10 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute10 := p_attribute10;
    end if;
    if (p_attribute11 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute11 := p_attribute11;
    end if;
    if (p_attribute12 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute12 := p_attribute12;
    end if;
    if (p_attribute13 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute13 := p_attribute13;
    end if;
    if (p_attribute14 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute14 := p_attribute14;
    end if;
    if (p_attribute15 <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_region_rec.attribute15 := p_attribute15;
    end if;


    AK_REGIONS_PKG.UPDATE_ROW(
        X_REGION_APPLICATION_ID  => p_REGION_APPLICATION_ID,
        X_REGION_CODE  => p_REGION_CODE,
        X_DATABASE_OBJECT_NAME  => p_DATABASE_OBJECT_NAME,
        X_REGION_STYLE  => l_region_rec.region_style,
        X_NUM_COLUMNS =>l_region_rec.num_columns,
        X_ICX_CUSTOM_CALL => l_region_rec.icx_custom_call,
        X_NAME  => l_region_rec.name,
        X_DESCRIPTION  => l_region_rec.description,
        X_REGION_DEFAULTING_API_PKG => l_region_rec.region_defaulting_api_pkg,
        X_REGION_DEFAULTING_API_PROC => l_region_rec.region_defaulting_api_proc,
        X_REGION_VALIDATION_API_PKG => l_region_rec.region_validation_api_pkg,
        X_REGION_VALIDATION_API_PROC => l_region_rec.region_validation_api_proc,
        X_APPL_MODULE_OBJECT_TYPE => l_region_rec.applicationmodule_object_type,
        X_NUM_ROWS_DISPLAY => null,
        X_REGION_OBJECT_TYPE => Null,
        X_IMAGE_FILE_NAME => l_region_rec.image_file_name,
        X_ISFORM_FLAG => l_region_rec.isform_flag,
        X_HELP_TARGET => l_region_rec.help_target,
        X_STYLE_SHEET_FILENAME => l_region_rec.style_sheet_filename,
        X_VERSION => l_region_rec.version,
        X_APPLICATIONMODULE_USAGE_NAME => l_region_rec.applicationmodule_usage_name,
        X_ADD_INDEXED_CHILDREN => l_region_rec.add_indexed_children,
        X_STATEFUL_FLAG => l_region_rec.stateful_flag,
        X_FUNCTION_NAME => l_region_rec.function_name,
        X_CHILDREN_VIEW_USAGE_NAME => l_region_rec.children_view_usage_name,
        X_SEARCH_PANEL => l_region_rec.search_panel,
        X_ADVANCED_SEARCH_PANEL =>l_region_rec.advanced_search_panel,
        X_CUSTOMIZE_PANEL => l_region_rec.customize_panel,
        X_DEFAULT_SEARCH_PANEL => l_region_rec.default_search_panel,
        X_RESULTS_BASED_SEARCH => l_region_rec.results_based_search,
        X_DISPLAY_GRAPH_TABLE => l_region_rec.display_graph_table,
        X_DISABLE_HEADER => l_region_rec.disable_header,
        X_STANDALONE => l_region_rec.standalone,
        X_AUTO_CUSTOMIZATION_CRITERIA =>l_region_rec.auto_customization_criteria,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => l_region_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => l_region_rec.attribute1,
        X_ATTRIBUTE2 => l_region_rec.attribute2,
        X_ATTRIBUTE3 => l_region_rec.attribute3,
        X_ATTRIBUTE4 => l_region_rec.attribute4,
        X_ATTRIBUTE5 => l_region_rec.attribute5,
        X_ATTRIBUTE6 => l_region_rec.attribute6,
        X_ATTRIBUTE7 => l_region_rec.attribute7,
        X_ATTRIBUTE8 => l_region_rec.attribute8,
        X_ATTRIBUTE9 => l_region_rec.attribute9,
        X_ATTRIBUTE10 => l_region_rec.attribute10,
        X_ATTRIBUTE11 => l_region_rec.attribute11,
        X_ATTRIBUTE12 => l_region_rec.attribute12,
        X_ATTRIBUTE13 => l_region_rec.attribute13,
        X_ATTRIBUTE14 => l_region_rec.attribute14,
        X_ATTRIBUTE15 => l_region_rec.attribute15);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.UPDATE_REGION_ROW: ' || SQLERRM;
    end if;

end UPDATE_REGION_ROW;

-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE UPDATE_REGION_ROW
(  p_commit                       IN  VARCHAR2   := FND_API.G_TRUE
 , p_Report_Region_Rec            IN  BIS_AK_REGION_PUB.Bis_Region_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_region_rec        AK_REGION_PUB.Region_Rec_Type;

CURSOR cRegion IS
SELECT  icx_custom_call,
    num_columns,
    region_defaulting_api_pkg,
    region_defaulting_api_proc,
    region_validation_api_pkg,
    region_validation_api_proc,
    applicationmodule_object_type,
    image_file_name,
    isform_flag,
    help_target,
    style_sheet_filename,
    version,
    applicationmodule_usage_name,
    add_indexed_children,
    stateful_flag,
    function_name,
    children_view_usage_name,
    search_panel,
    advanced_search_panel,
    customize_panel,
    default_search_panel,
    results_based_search,
    display_graph_table,
    disable_header,
    standalone,
    auto_customization_criteria,
    region_style,
    name,
    description,
    num_rows_display,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15
FROM ak_regions_vl
WHERE region_code = p_Report_Region_Rec.Region_Code
AND region_application_id = p_Report_Region_Rec.Region_Application_Id;

BEGIN

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF cRegion%ISOPEN THEN
            CLOSE cRegion;
    END IF;
        OPEN cRegion;
        FETCH cRegion INTO
        l_region_rec.icx_custom_call,
        l_region_rec.num_columns,
        l_region_rec.region_defaulting_api_pkg,
        l_region_rec.region_defaulting_api_proc,
        l_region_rec.region_validation_api_pkg,
        l_region_rec.region_validation_api_proc,
        l_region_rec.applicationmodule_object_type,
        l_region_rec.image_file_name,
        l_region_rec.isform_flag,
        l_region_rec.help_target,
        l_region_rec.style_sheet_filename,
        l_region_rec.version,
        l_region_rec.applicationmodule_usage_name,
        l_region_rec.add_indexed_children,
        l_region_rec.stateful_flag,
        l_region_rec.function_name,
        l_region_rec.children_view_usage_name,
        l_region_rec.search_panel,
        l_region_rec.advanced_search_panel,
        l_region_rec.customize_panel,
        l_region_rec.default_search_panel,
        l_region_rec.results_based_search,
        l_region_rec.display_graph_table,
        l_region_rec.disable_header,
        l_region_rec.standalone,
        l_region_rec.auto_customization_criteria,
        l_region_rec.region_style,
    l_region_rec.name,
        l_region_rec.description,
        l_region_rec.num_rows_display,
        l_region_rec.attribute_category,
        l_region_rec.attribute1,
        l_region_rec.attribute2,
        l_region_rec.attribute3,
        l_region_rec.attribute4,
        l_region_rec.attribute5,
        l_region_rec.attribute6,
        l_region_rec.attribute7,
        l_region_rec.attribute8,
        l_region_rec.attribute9,
        l_region_rec.attribute10,
        l_region_rec.attribute11,
        l_region_rec.attribute12,
        l_region_rec.attribute13,
        l_region_rec.attribute14,
        l_region_rec.attribute15;
    CLOSE cRegion;

    IF (p_Report_Region_Rec.Region_Style <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.region_style := p_Report_Region_Rec.Region_Style;
    END IF;
    IF (p_Report_Region_Rec.Region_Name <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.name := p_Report_Region_Rec.Region_Name;
    END IF;
    IF (p_Report_Region_Rec.Display_Rows <> BIS_COMMON_UTILS.G_DEF_NUM) THEN
        l_region_rec.num_rows_display := p_Report_Region_Rec.Display_Rows;
    END IF;
    IF (p_Report_Region_Rec.Region_Description <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.description := p_Report_Region_Rec.Region_Description;
    END IF;
    IF (p_Report_Region_Rec.Disable_View_By <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute1 := p_Report_Region_Rec.Disable_View_By;
    END IF;
    IF (p_Report_Region_Rec.No_Of_Portlet_Rows <> BIS_COMMON_UTILS.G_DEF_NUM) THEN
        l_region_rec.attribute2 := p_Report_Region_Rec.No_Of_Portlet_Rows;
    END IF;
    IF (p_Report_Region_Rec.Schedule <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute3 := p_Report_Region_Rec.Schedule;
    END IF;
    IF (p_Report_Region_Rec.Header_File_Procedure <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute4 := p_Report_Region_Rec.Header_File_Procedure;
    END IF;
    IF (p_Report_Region_Rec.Footer_File_Procedure <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute5 := p_Report_Region_Rec.Footer_File_Procedure;
    END IF;
    IF (p_Report_Region_Rec.Group_By <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute6 := p_Report_Region_Rec.Group_By;
    END IF;
    IF (p_Report_Region_Rec.Order_By <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute7 := p_Report_Region_Rec.Order_By;
    END IF;
    IF (p_Report_Region_Rec.Plsql_For_Report_Query <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute8 := p_Report_Region_Rec.Plsql_For_Report_Query;
    END IF;
    IF (p_Report_Region_Rec.Display_Subtotals <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute9 := p_Report_Region_Rec.Display_Subtotals;
    END IF;
    IF (p_Report_Region_Rec.Data_Source <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute10 := p_Report_Region_Rec.Data_Source;
    END IF;
    IF (p_Report_Region_Rec.Where_Clause <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute11 := p_Report_Region_Rec.Where_Clause;
    END IF;
    IF (p_Report_Region_Rec.Dimension_Group <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute12 := p_Report_Region_Rec.Dimension_Group;
    END IF;
    IF (p_Report_Region_Rec.Parameter_Layout <> BIS_COMMON_UTILS.G_DEF_CHAR) THEN
        l_region_rec.attribute13 := p_Report_Region_Rec.Parameter_Layout;
    END IF;

    AK_REGIONS_PKG.UPDATE_ROW(
        X_REGION_APPLICATION_ID  => p_Report_Region_Rec.Region_Application_Id,
        X_REGION_CODE  => p_Report_Region_Rec.Region_Code,
        X_DATABASE_OBJECT_NAME  => p_Report_Region_Rec.Database_Object_Name,
        X_REGION_STYLE  => l_region_rec.region_style,
        X_NUM_COLUMNS => l_region_rec.num_columns,
        X_ICX_CUSTOM_CALL => l_region_rec.icx_custom_call,
        X_NAME  => l_region_rec.name,
        X_DESCRIPTION  => l_region_rec.description,
        X_REGION_DEFAULTING_API_PKG => l_region_rec.region_defaulting_api_pkg,
        X_REGION_DEFAULTING_API_PROC => l_region_rec.region_defaulting_api_proc,
        X_REGION_VALIDATION_API_PKG => l_region_rec.region_validation_api_pkg,
        X_REGION_VALIDATION_API_PROC => l_region_rec.region_validation_api_proc,
        X_APPL_MODULE_OBJECT_TYPE => l_region_rec.applicationmodule_object_type,
        X_NUM_ROWS_DISPLAY => l_region_rec.num_rows_display,
        X_REGION_OBJECT_TYPE => p_Report_Region_Rec.Region_Object_Type,
        X_IMAGE_FILE_NAME => l_region_rec.image_file_name,
        X_ISFORM_FLAG => l_region_rec.isform_flag,
        X_HELP_TARGET => p_Report_Region_Rec.Help_Target,
        X_STYLE_SHEET_FILENAME => l_region_rec.style_sheet_filename,
        X_VERSION => l_region_rec.version,
        X_APPLICATIONMODULE_USAGE_NAME => l_region_rec.applicationmodule_usage_name,
        X_ADD_INDEXED_CHILDREN => l_region_rec.add_indexed_children,
        X_STATEFUL_FLAG => l_region_rec.stateful_flag,
        X_FUNCTION_NAME => l_region_rec.function_name,
        X_CHILDREN_VIEW_USAGE_NAME => l_region_rec.children_view_usage_name,
        X_SEARCH_PANEL => l_region_rec.search_panel,
        X_ADVANCED_SEARCH_PANEL =>l_region_rec.advanced_search_panel,
        X_CUSTOMIZE_PANEL => l_region_rec.customize_panel,
        X_DEFAULT_SEARCH_PANEL => l_region_rec.default_search_panel,
        X_RESULTS_BASED_SEARCH => l_region_rec.results_based_search,
        X_DISPLAY_GRAPH_TABLE => l_region_rec.display_graph_table,
        X_DISABLE_HEADER => l_region_rec.disable_header,
        X_STANDALONE => l_region_rec.standalone,
        X_AUTO_CUSTOMIZATION_CRITERIA =>l_region_rec.auto_customization_criteria,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => l_region_rec.ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => l_region_rec.attribute1,
        X_ATTRIBUTE2 => l_region_rec.attribute2,
        X_ATTRIBUTE3 => l_region_rec.attribute3,
        X_ATTRIBUTE4 => l_region_rec.attribute4,
        X_ATTRIBUTE5 => l_region_rec.attribute5,
        X_ATTRIBUTE6 => l_region_rec.attribute6,
        X_ATTRIBUTE7 => l_region_rec.attribute7,
        X_ATTRIBUTE8 => l_region_rec.attribute8,
        X_ATTRIBUTE9 => l_region_rec.attribute9,
        X_ATTRIBUTE10 => l_region_rec.attribute10,
        X_ATTRIBUTE11 => l_region_rec.attribute11,
        X_ATTRIBUTE12 => l_region_rec.attribute12,
        X_ATTRIBUTE13 => l_region_rec.attribute13,
        X_ATTRIBUTE14 => l_region_rec.attribute14,
        X_ATTRIBUTE15 => l_region_rec.attribute15);

        IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
        END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.UPDATE_REGION_ROW: ' || SQLERRM;
    END IF;

END UPDATE_REGION_ROW;

-- nbarik - 04/05/04 - Enh 3546750 - BSC/PMV Integration - Added p_commit
PROCEDURE DELETE_REGION_ROW
(p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
,p_commit                 IN    VARCHAR2   := FND_API.G_FALSE
 ) IS
BEGIN

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  AK_REGIONS_PKG.DELETE_ROW(
    X_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
    X_REGION_CODE => p_REGION_CODE
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.DELETE_REGION_ROW: ' || SQLERRM;
    end if;

END DELETE_REGION_ROW;

procedure INSERT_REGION_ITEM_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_ATTRIBUTE_CODE       in VARCHAR2
,p_ATTRIBUTE_APPLICATION_ID     in NUMBER
,p_DISPLAY_SEQUENCE         in number
,p_NODE_DISPLAY_FLAG        in VARCHAR2 := 'Y'
,p_ATTRIBUTE_LABEL_LONG     in VARCHAR2 := NULL
,p_NESTED_REGION_CODE       in VARCHAR2 := NULL
,p_NESTED_REGION_APPL_ID    in NUMBER   := NULL
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := NULL
,p_ATTRIBUTE1           in VARCHAR2 := NULL
,p_ATTRIBUTE2           in VARCHAR2 := NULL
,p_ATTRIBUTE3           in VARCHAR2 := NULL
,p_ATTRIBUTE4           in VARCHAR2 := NULL
,p_ATTRIBUTE5           in VARCHAR2 := NULL
,p_ATTRIBUTE6           in VARCHAR2 := NULL
,p_ATTRIBUTE7           in VARCHAR2 := NULL
,p_ATTRIBUTE8           in VARCHAR2 := NULL
,p_ATTRIBUTE9           in VARCHAR2 := NULL
,p_ATTRIBUTE10          in VARCHAR2 := NULL
,p_ATTRIBUTE11          in VARCHAR2 := NULL
,p_ATTRIBUTE12          in VARCHAR2 := NULL
,p_ATTRIBUTE13          in VARCHAR2 := NULL
,p_ATTRIBUTE14          in VARCHAR2 := NULL
,p_ATTRIBUTE15          in VARCHAR2 := NULL
,p_URL              in VARCHAR2 := NULL
,p_ORDER_SEQUENCE       in VARCHAR2 := NULL
,p_ORDER_DIRECTION      in VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
l_label_length          number;
l_attributeCount        number;
l_attribute_rowid       varchar2(30);
l_rowid                 varchar2(30);
l_item_style            varchar2(30);
l_nested_region_appl_id number;
cursor cAttributeExists is
select  count(1)
from ak_attributes
where attribute_code = p_ATTRIBUTE_CODE
and attribute_application_id = p_ATTRIBUTE_APPLICATION_ID;

begin

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    if cAttributeExists%ISOPEN then
            CLOSE cAttributeExists;
    end if;
        OPEN cAttributeExists;
        FETCH cAttributeExists INTO l_attributeCount;
    CLOSE cAttributeExists;

    if l_attributeCount = 0 then
        -- Insert into Attributes

        AK_ATTRIBUTES_PKG.INSERT_ROW (
            X_ROWID => l_attribute_rowid,
            X_ATTRIBUTE_APPLICATION_ID => p_ATTRIBUTE_APPLICATION_ID,
            X_ATTRIBUTE_CODE => p_ATTRIBUTE_CODE,
            X_ATTRIBUTE_LABEL_LENGTH => c_ATTR_LABEL_LENGTH,
            X_ATTRIBUTE_VALUE_LENGTH  => c_ATTR_VALUE_LENGTH,
            X_BOLD => c_BOLD,
            X_ITALIC => c_ITALIC,
            X_UPPER_CASE_FLAG => c_UPPER_CASE_FLAG,
            X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
            X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
            X_DEFAULT_VALUE_VARCHAR2 => null,
            X_DEFAULT_VALUE_NUMBER => null,
            X_DEFAULT_VALUE_DATE => null,
            X_LOV_REGION_CODE => null,
            X_LOV_REGION_APPLICATION_ID => null,
            X_DATA_TYPE => c_ATTR_DATATYPE,
            X_DISPLAY_HEIGHT => null,
            X_ITEM_STYLE => c_TEXT_STYLE,
            X_CSS_CLASS_NAME => null,
            X_CSS_LABEL_CLASS_NAME => null,
            X_PRECISION => null,
            X_EXPANSION  => null,
            X_ALS_MAX_LENGTH => null,
            X_POPLIST_VIEWOBJECT => null,
            X_POPLIST_DISPLAY_ATTRIBUTE => null,
            X_POPLIST_VALUE_ATTRIBUTE => null,
            X_ATTRIBUTE_CATEGORY => null,
            X_ATTRIBUTE1 => null,
            X_ATTRIBUTE2 => null,
            X_ATTRIBUTE3 => null,
            X_ATTRIBUTE4 => null,
            X_ATTRIBUTE5 => null,
            X_ATTRIBUTE6 => null,
            X_ATTRIBUTE7 => null,
            X_ATTRIBUTE8 => null,
            X_ATTRIBUTE9 => null,
            X_ATTRIBUTE10 => null,
            X_ATTRIBUTE11 => null,
            X_ATTRIBUTE12 => null,
            X_ATTRIBUTE13 => null,
            X_ATTRIBUTE14 => null,
            X_ATTRIBUTE15 => null,
            X_NAME => p_ATTRIBUTE_CODE,
            X_ATTRIBUTE_LABEL_LONG => null,
            X_ATTRIBUTE_LABEL_SHORT => null,
            X_DESCRIPTION => null,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => fnd_global.user_id,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN => fnd_global.user_id);
    end if;

    if p_Attribute_label_long is null then
        l_label_length := 0;
    else
        l_label_length := length(p_Attribute_label_long);
    end if;

    if (p_nested_region_code is not null) then
        l_item_Style := c_NESTED_REGION_STYLE;
    else
        l_Item_style := c_TEXT_STYLE;
    end if;

    l_nested_region_appl_id := p_nested_region_appl_id;
    if (p_nested_region_code is null) then
    l_nested_region_appl_id := null;
    end if;

    AK_REGION_ITEMS_PKG.INSERT_ROW (
        X_ROWID => l_ROWID,
        X_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
        X_REGION_CODE => upper(p_REGION_CODE),
        X_ATTRIBUTE_APPLICATION_ID => p_ATTRIBUTE_APPLICATION_ID,
        X_ATTRIBUTE_CODE => upper(p_ATTRIBUTE_CODE),
        X_DISPLAY_SEQUENCE => p_DISPLAY_SEQUENCE,
        X_NODE_DISPLAY_FLAG => c_NODE_DISPLAY_FLAG,
        X_NODE_QUERY_FLAG => c_NODE_QUERY_FLAG,
        X_ATTRIBUTE_LABEL_LENGTH => l_label_length,
        X_BOLD => c_BOLD,
        X_ITALIC  => c_ITALIC,
        X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
        X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
        X_ITEM_STYLE => l_item_style,
        X_OBJECT_ATTRIBUTE_FLAG => c_OBJECT_ATTRIBUTE_FLAG,
        X_ATTRIBUTE_LABEL_LONG => p_ATTRIBUTE_LABEL_LONG,
        X_DESCRIPTION => null,
        X_SECURITY_CODE => null,
        X_UPDATE_FLAG => c_UPDATE_FLAG,
        X_REQUIRED_FLAG => c_REQUIRED_FLAG,
        X_DISPLAY_VALUE_LENGTH => 0,
        X_LOV_REGION_APPLICATION_ID => null,
        X_LOV_REGION_CODE => null,
        X_LOV_FOREIGN_KEY_NAME => null,
        X_LOV_ATTRIBUTE_APPLICATION_ID => null,
        X_LOV_ATTRIBUTE_CODE  => null,
        X_LOV_DEFAULT_FLAG  => null,
        X_REGION_DEFAULTING_API_PKG => null,
        X_REGION_DEFAULTING_API_PROC => null,
        X_REGION_VALIDATION_API_PKG => null,
        X_REGION_VALIDATION_API_PROC => null,
        X_ORDER_SEQUENCE  => p_ORDER_SEQUENCE,
        X_ORDER_DIRECTION => p_ORDER_DIRECTION,
        X_DEFAULT_VALUE_VARCHAR2 => null,
        X_DEFAULT_VALUE_NUMBER => null,
        X_DEFAULT_VALUE_DATE  => null,
        X_ITEM_NAME  => replace(initcap(p_ATTRIBUTE_CODE), '_', ''),
        X_DISPLAY_HEIGHT  => c_DISPLAY_HEIGHT,
        X_SUBMIT  => c_SUBMIT,
        X_ENCRYPT  => c_ENCRYPT,
        X_VIEW_USAGE_NAME  => null,
        X_VIEW_ATTRIBUTE_NAME  => null,
        X_CSS_CLASS_NAME  => null,
        X_CSS_LABEL_CLASS_NAME  => null,
        X_URL  => p_URL,
        X_POPLIST_VIEWOBJECT  => null,
        X_POPLIST_DISPLAY_ATTRIBUTE  => null,
        X_POPLIST_VALUE_ATTRIBUTE  => null,
        X_IMAGE_FILE_NAME  => null,
        X_NESTED_REGION_CODE  => upper(p_NESTED_REGION_CODE),
        X_NESTED_REGION_APPL_ID => l_NESTED_REGION_APPL_ID,
        X_MENU_NAME   => null,
        X_FLEXFIELD_NAME   => null,
        X_FLEXFIELD_APPLICATION_ID   => null,
        X_TABULAR_FUNCTION_CODE   => null,
        X_TIP_TYPE   => null,
        X_TIP_MESSAGE_NAME   => null,
        X_TIP_MESSAGE_APPLICATION_ID   => null,
        X_FLEX_SEGMENT_LIST   => null,
        X_ENTITY_ID   => null,
        X_ANCHOR   => null,
        X_POPLIST_VIEW_USAGE_NAME   => null,
        X_USER_CUSTOMIZABLE   => null,
        X_ADMIN_CUSTOMIZABLE   => c_ADMIN_CUSTOMIZABLE,
        X_INVOKE_FUNCTION_NAME   => null,
        X_ATTRIBUTE_LABEL_SHORT  => null,
        X_EXPANSION  => null,
        X_ALS_MAX_LENGTH  => null,
        X_SORTBY_VIEW_ATTRIBUTE_NAME  => null,
        X_ICX_CUSTOM_CALL   => null,
        X_INITIAL_SORT_SEQUENCE  => null,
        X_CUSTOMIZATION_APPLICATION_ID   => null,
        X_CUSTOMIZATION_CODE   => null,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => p_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_ATTRIBUTE1,
        X_ATTRIBUTE2 => p_ATTRIBUTE2,
        X_ATTRIBUTE3 => p_ATTRIBUTE3,
        X_ATTRIBUTE4 => p_ATTRIBUTE4,
        X_ATTRIBUTE5 => p_ATTRIBUTE5,
        X_ATTRIBUTE6 => p_ATTRIBUTE6,
        X_ATTRIBUTE7 => p_ATTRIBUTE7,
        X_ATTRIBUTE8 => p_ATTRIBUTE8,
        X_ATTRIBUTE9 => p_ATTRIBUTE9,
        X_ATTRIBUTE10 => p_ATTRIBUTE10,
        X_ATTRIBUTE11 => p_ATTRIBUTE11,
        X_ATTRIBUTE12 => p_ATTRIBUTE12,
        X_ATTRIBUTE13 => p_ATTRIBUTE13,
        X_ATTRIBUTE14 => p_ATTRIBUTE14,
        X_ATTRIBUTE15 => p_ATTRIBUTE15);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW: ' || SQLERRM;
    end if;

end INSERT_REGION_ITEM_ROW;

-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE INSERT_REGION_ITEM_ROW
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Region_Item_Rec              IN         BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS
l_attribute_rowid       VARCHAR2(30);
l_attributeCount        NUMBER;
l_label_length          NUMBER;
l_rowid                 VARCHAR2(30);
l_Item_Style            AK_REGION_ITEMS.ITEM_STYLE%TYPE;

CURSOR cAttributeExists IS
SELECT  COUNT(1)
FROM ak_attributes
WHERE attribute_code = p_Region_Item_Rec.Attribute_Code
AND attribute_application_id = p_Region_Item_Rec.Attribute_Application_Id;

BEGIN

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF cAttributeExists%ISOPEN THEN
            CLOSE cAttributeExists;
    END IF;
        OPEN cAttributeExists;
        FETCH cAttributeExists INTO l_attributeCount;
    CLOSE cAttributeExists;


    IF l_attributeCount = 0 THEN
        -- Insert into Attributes
        AK_ATTRIBUTES_PKG.INSERT_ROW (
            X_ROWID => l_attribute_rowid,
            X_ATTRIBUTE_APPLICATION_ID => p_Region_Item_Rec.Attribute_Application_Id,
            X_ATTRIBUTE_CODE => UPPER(p_Region_Item_Rec.Attribute_Code),
            X_ATTRIBUTE_LABEL_LENGTH => c_ATTR_LABEL_LENGTH,
            X_ATTRIBUTE_VALUE_LENGTH  => c_ATTR_VALUE_LENGTH,
            X_BOLD => c_BOLD,
            X_ITALIC => c_ITALIC,
            X_UPPER_CASE_FLAG => c_UPPER_CASE_FLAG,
            X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
            X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
            X_DEFAULT_VALUE_VARCHAR2 => NULL,
            X_DEFAULT_VALUE_NUMBER => NULL,
            X_DEFAULT_VALUE_DATE => NULL,
            X_LOV_REGION_CODE => NULL,
            X_LOV_REGION_APPLICATION_ID => NULL,
            X_DATA_TYPE => c_ATTR_DATATYPE,
            X_DISPLAY_HEIGHT => NULL,
            X_ITEM_STYLE => c_TEXT_STYLE,
            X_CSS_CLASS_NAME => NULL,
            X_CSS_LABEL_CLASS_NAME => NULL,
            X_PRECISION => NULL,
            X_EXPANSION  => NULL,
            X_ALS_MAX_LENGTH => NULL,
            X_POPLIST_VIEWOBJECT => NULL,
            X_POPLIST_DISPLAY_ATTRIBUTE => NULL,
            X_POPLIST_VALUE_ATTRIBUTE => NULL,
            X_ATTRIBUTE_CATEGORY => NULL,
            X_ATTRIBUTE1 => NULL,
            X_ATTRIBUTE2 => NULL,
            X_ATTRIBUTE3 => NULL,
            X_ATTRIBUTE4 => NULL,
            X_ATTRIBUTE5 => NULL,
            X_ATTRIBUTE6 => NULL,
            X_ATTRIBUTE7 => NULL,
            X_ATTRIBUTE8 => NULL,
            X_ATTRIBUTE9 => NULL,
            X_ATTRIBUTE10 => NULL,
            X_ATTRIBUTE11 => NULL,
            X_ATTRIBUTE12 => NULL,
            X_ATTRIBUTE13 => NULL,
            X_ATTRIBUTE14 => NULL,
            X_ATTRIBUTE15 => NULL,
            X_NAME => p_Region_Item_Rec.Attribute_Code,
            X_ATTRIBUTE_LABEL_LONG => NULL,
            X_ATTRIBUTE_LABEL_SHORT => NULL,
            X_DESCRIPTION => NULL,
            X_CREATION_DATE => SYSDATE,
            X_CREATED_BY => fnd_global.user_id,
            X_LAST_UPDATE_DATE => SYSDATE,
            X_LAST_UPDATED_BY => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN => fnd_global.user_id);
    END IF;

    IF p_Region_Item_Rec.Long_Label IS NULL THEN
        l_label_length := 0;
    ELSE
        l_label_length := LENGTH(p_Region_Item_Rec.Long_Label);
    END IF;


    IF p_Region_Item_Rec.Item_Style IS NULL THEN
        l_Item_Style := c_TEXT_STYLE;
    ELSE
        l_Item_Style := p_Region_Item_Rec.Item_Style;
    END IF;


    AK_REGION_ITEMS_PKG.INSERT_ROW (
        X_ROWID => l_rowid,
        X_REGION_APPLICATION_ID => p_region_application_id,
        X_REGION_CODE => UPPER(p_region_code),
        X_ATTRIBUTE_APPLICATION_ID => p_Region_Item_Rec.Attribute_Application_Id,
        X_ATTRIBUTE_CODE => UPPER(p_Region_Item_Rec.Attribute_Code),
        X_DISPLAY_SEQUENCE => p_Region_Item_Rec.Display_Sequence,
        X_NODE_DISPLAY_FLAG => p_Region_Item_Rec.Node_Display_Flag,
        X_NODE_QUERY_FLAG => p_Region_Item_Rec.Queryable_Flag,
        X_ATTRIBUTE_LABEL_LENGTH => l_label_length,
        X_BOLD => c_BOLD,
        X_ITALIC  => c_ITALIC,
        X_VERTICAL_ALIGNMENT => c_VERTICAL_ALIGNMENT,
        X_HORIZONTAL_ALIGNMENT => c_HORIZONTAL_ALIGNMENT,
        X_ITEM_STYLE => l_Item_Style,
        X_OBJECT_ATTRIBUTE_FLAG => c_OBJECT_ATTRIBUTE_FLAG,
        X_ATTRIBUTE_LABEL_LONG => p_Region_Item_Rec.Long_Label,
        X_DESCRIPTION => NULL,
        X_SECURITY_CODE => NULL,
        X_UPDATE_FLAG => c_UPDATE_FLAG,
        X_REQUIRED_FLAG => p_Region_Item_Rec.Required_Flag,
        X_DISPLAY_VALUE_LENGTH => p_Region_Item_Rec.Display_Length,
        X_LOV_REGION_APPLICATION_ID => NULL,
        X_LOV_REGION_CODE => NULL,
        X_LOV_FOREIGN_KEY_NAME => NULL,
        X_LOV_ATTRIBUTE_APPLICATION_ID => NULL,
        X_LOV_ATTRIBUTE_CODE  => NULL,
        X_LOV_DEFAULT_FLAG  => NULL,
        X_REGION_DEFAULTING_API_PKG => NULL,
        X_REGION_DEFAULTING_API_PROC => NULL,
        X_REGION_VALIDATION_API_PKG => NULL,
        X_REGION_VALIDATION_API_PROC => NULL,
        X_ORDER_SEQUENCE  => p_Region_Item_Rec.Sort_Sequence,
        X_ORDER_DIRECTION => p_Region_Item_Rec.Sort_Direction,
        X_DEFAULT_VALUE_VARCHAR2 => NULL,
        X_DEFAULT_VALUE_NUMBER => NULL,
        X_DEFAULT_VALUE_DATE  => NULL,
        X_ITEM_NAME  => REPLACE(INITCAP(p_Region_Item_Rec.Attribute_Code), '_', ''),
        X_DISPLAY_HEIGHT  => c_DISPLAY_HEIGHT,
        X_SUBMIT  => c_SUBMIT,
        X_ENCRYPT  => c_ENCRYPT,
        X_VIEW_USAGE_NAME  => NULL,
        X_VIEW_ATTRIBUTE_NAME  => NULL,
        X_CSS_CLASS_NAME  => NULL,
        X_CSS_LABEL_CLASS_NAME  => NULL,
        X_URL  => p_Region_Item_Rec.Url,
        X_POPLIST_VIEWOBJECT  => NULL,
        X_POPLIST_DISPLAY_ATTRIBUTE  => NULL,
        X_POPLIST_VALUE_ATTRIBUTE  => NULL,
        X_IMAGE_FILE_NAME  => NULL,
        X_NESTED_REGION_CODE  => p_Region_Item_Rec.Nested_Region_Code,
        X_NESTED_REGION_APPL_ID => p_Region_Item_Rec.Nested_Region_Application_Id,
        X_MENU_NAME   => NULL,
        X_FLEXFIELD_NAME   => NULL,
        X_FLEXFIELD_APPLICATION_ID   => NULL,
        X_TABULAR_FUNCTION_CODE   => NULL,
        X_TIP_TYPE   => NULL,
        X_TIP_MESSAGE_NAME   => NULL,
        X_TIP_MESSAGE_APPLICATION_ID   => NULL,
        X_FLEX_SEGMENT_LIST   => NULL,
        X_ENTITY_ID   => NULL,
        X_ANCHOR   => NULL,
        X_POPLIST_VIEW_USAGE_NAME   => NULL,
        X_USER_CUSTOMIZABLE   => NULL,
        X_ADMIN_CUSTOMIZABLE   => c_ADMIN_CUSTOMIZABLE,
        X_INVOKE_FUNCTION_NAME   => NULL,
        X_ATTRIBUTE_LABEL_SHORT  => NULL,
        X_EXPANSION  => NULL,
        X_ALS_MAX_LENGTH  => NULL,
        X_SORTBY_VIEW_ATTRIBUTE_NAME  => NULL,
        X_ICX_CUSTOM_CALL   => NULL,
        X_INITIAL_SORT_SEQUENCE  => p_Region_Item_Rec.Initial_Sort_Sequence,
        X_CUSTOMIZATION_APPLICATION_ID   => NULL,
        X_CUSTOMIZATION_CODE   => NULL,
        X_CREATION_DATE => SYSDATE,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => C_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_Region_Item_Rec.Attribute_Type,
        X_ATTRIBUTE2 => p_Region_Item_Rec.Measure_Level,
        X_ATTRIBUTE3 => p_Region_Item_Rec.Base_Column,
        X_ATTRIBUTE4 => p_Region_Item_Rec.Lov_Where_Clause,
        X_ATTRIBUTE5 => p_Region_Item_Rec.Graph_Position,
        X_ATTRIBUTE6 => p_Region_Item_Rec.Graph_Style,
        X_ATTRIBUTE7 => p_Region_Item_Rec.Display_Format,
        X_ATTRIBUTE8 => p_Region_Item_Rec.Schedule,
        X_ATTRIBUTE9 => p_Region_Item_Rec.Aggregate_Function,
        X_ATTRIBUTE10 => p_Region_Item_Rec.Display_Total,
        X_ATTRIBUTE11 => p_Region_Item_Rec.Override_Hierarchy,
        X_ATTRIBUTE12 => NULL,
        X_ATTRIBUTE13 => p_Region_Item_Rec.Variance,
        X_ATTRIBUTE14 => p_Region_Item_Rec.Display_Type,
        X_ATTRIBUTE15 => p_Region_Item_Rec.Lov_Table);

        IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
        END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW: ' || SQLERRM;
    END IF;

END INSERT_REGION_ITEM_ROW;

-- nbarik 02/10/04 - overloaded for region record type
-- adrao  05/12/04 -- added Nested Region & Nested Region Application Id
PROCEDURE UPDATE_REGION_ITEM_ROW
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Region_Item_Rec              IN         BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS

l_regionItem_rec        AK_REGION_PUB.Item_Rec_Type;
l_label_length          NUMBER;

CURSOR cRegionItem IS
SELECT  display_sequence,
    bold,
    italic,
    vertical_alignment,
    horizontal_alignment,
    item_style,
    object_attribute_flag,
    icx_custom_call,
    update_flag,
    required_flag,
    security_code,
    default_value_varchar2,
    default_value_number,
    default_value_date,
    lov_region_application_id,
    lov_region_code,
    lov_foreign_key_name,
    lov_attribute_application_id,
    lov_attribute_code,
    lov_default_flag,
    region_defaulting_api_pkg,
    region_defaulting_api_proc,
    region_validation_api_pkg,
    region_validation_api_proc,
    order_sequence,
    order_direction,
    display_height,
    submit,
    encrypt,
    css_class_name,
    view_usage_name,
    view_attribute_name,
    nested_region_application_id,
    nested_region_code,
    url,
    poplist_viewobject,
    poplist_display_attribute,
    poplist_value_attribute,
    image_file_name,
    item_name,
    css_label_class_name,
    menu_name,
    flexfield_name,
    flexfield_application_id,
    tabular_function_code,
    tip_type,
    tip_message_name,
    tip_message_application_id,
    flex_segment_list,
    entity_id,
    anchor,
    poplist_view_usage_name,
    user_customizable,
    sortby_view_attribute_name,
    admin_customizable,
    invoke_function_name,
    expansion,
    als_max_length,
    initial_sort_sequence,
    customization_application_id,
    customization_code,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute_label_short,
    description
FROM ak_region_items_vl
WHERE region_code = p_region_code
AND region_application_id = p_region_application_id
AND attribute_code = p_Region_Item_Rec.Attribute_Code
AND attribute_application_id = p_Region_Item_Rec.Attribute_Application_Id;

c_region_item_rec  cRegionItem%ROWTYPE;

BEGIN
    -- Save the current data
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF cRegionItem%ISOPEN THEN
       CLOSE cRegionItem;
    END IF;
    OPEN cRegionItem;
    FETCH cRegionItem INTO c_region_item_rec;
     IF cRegionItem%FOUND THEN
        l_regionItem_rec.display_sequence := c_region_item_rec.display_sequence;
        l_regionItem_rec.bold := c_region_item_rec.bold;
        l_regionItem_rec.italic := c_region_item_rec.italic;
        l_regionItem_rec.vertical_alignment := c_region_item_rec.vertical_alignment;
        l_regionItem_rec.horizontal_alignment := c_region_item_rec.horizontal_alignment;
        l_regionItem_rec.item_style := c_region_item_rec.item_style;
        l_regionItem_rec.object_attribute_flag := c_region_item_rec.object_attribute_flag;
        l_regionItem_rec.icx_custom_call := c_region_item_rec.icx_custom_call;
        l_regionItem_rec.update_flag := c_region_item_rec.update_flag;
        l_regionItem_rec.required_flag := c_region_item_rec.required_flag;
        l_regionItem_rec.security_code := c_region_item_rec.security_code;
        l_regionItem_rec.default_value_varchar2 := c_region_item_rec.default_value_varchar2;
        l_regionItem_rec.default_value_number := c_region_item_rec.default_value_number;
        l_regionItem_rec.default_value_date := c_region_item_rec.default_value_date;
        l_regionItem_rec.lov_region_application_id := c_region_item_rec.lov_region_application_id;
        l_regionItem_rec.lov_region_code := c_region_item_rec.lov_region_code;
    l_regionItem_rec.lov_foreign_key_name := c_region_item_rec.lov_foreign_key_name;
        l_regionItem_rec.lov_attribute_application_id := c_region_item_rec.lov_attribute_application_id;
        l_regionItem_rec.lov_attribute_code := c_region_item_rec.lov_attribute_code;
        l_regionItem_rec.lov_default_flag := c_region_item_rec.lov_default_flag;
        l_regionItem_rec.region_defaulting_api_pkg := c_region_item_rec.region_defaulting_api_pkg;
        l_regionItem_rec.region_defaulting_api_proc := c_region_item_rec.region_defaulting_api_proc;
        l_regionItem_rec.region_validation_api_pkg := c_region_item_rec.region_validation_api_pkg;
        l_regionItem_rec.region_validation_api_proc := c_region_item_rec.region_validation_api_proc;
        l_regionItem_rec.order_sequence := c_region_item_rec.order_sequence;
        l_regionItem_rec.order_direction := c_region_item_rec.order_direction;
        l_regionItem_rec.display_height := c_region_item_rec.display_height;
        l_regionItem_rec.submit := c_region_item_rec.submit;
        l_regionItem_rec.encrypt := c_region_item_rec.encrypt;
        l_regionItem_rec.css_class_name := c_region_item_rec.css_class_name;
        l_regionItem_rec.view_usage_name := c_region_item_rec.view_usage_name;
        l_regionItem_rec.view_attribute_name := c_region_item_rec.view_attribute_name;
        l_regionItem_rec.nested_region_application_id := c_region_item_rec.nested_region_application_id;
        l_regionItem_rec.nested_region_code := c_region_item_rec.nested_region_code;
        l_regionItem_rec.url := c_region_item_rec.url;
        l_regionItem_rec.poplist_viewobject := c_region_item_rec.poplist_viewobject;
        l_regionItem_rec.poplist_display_attr := c_region_item_rec.poplist_display_attribute;
        l_regionItem_rec.poplist_value_attr := c_region_item_rec.poplist_value_attribute;
        l_regionItem_rec.image_file_name := c_region_item_rec.image_file_name;
        l_regionItem_rec.item_name := c_region_item_rec.item_name;
        l_regionItem_rec.css_label_class_name := c_region_item_rec.css_label_class_name;
        l_regionItem_rec.menu_name := c_region_item_rec.menu_name;
        l_regionItem_rec.flexfield_name := c_region_item_rec.flexfield_name;
        l_regionItem_rec.flexfield_application_id := c_region_item_rec.flexfield_application_id;
        l_regionItem_rec.tabular_function_code := c_region_item_rec.tabular_function_code;
        l_regionItem_rec.tip_type := c_region_item_rec.tip_type;
        l_regionItem_rec.tip_message_name := c_region_item_rec.tip_message_name;
        l_regionItem_rec.tip_message_application_id := c_region_item_rec.tip_message_application_id;
        l_regionItem_rec.flex_segment_list := c_region_item_rec.flex_segment_list;
        l_regionItem_rec.entity_id := c_region_item_rec.entity_id;
        l_regionItem_rec.anchor := c_region_item_rec.anchor;
        l_regionItem_rec.poplist_view_usage_name := c_region_item_rec.poplist_view_usage_name;
        l_regionItem_rec.user_customizable := c_region_item_rec.user_customizable;
        l_regionItem_rec.sortby_view_attribute_name := c_region_item_rec.sortby_view_attribute_name;
        l_regionItem_rec.admin_customizable := c_region_item_rec.admin_customizable;
        l_regionItem_rec.invoke_function_name := c_region_item_rec.invoke_function_name;
        l_regionItem_rec.expansion := c_region_item_rec.expansion;
        l_regionItem_rec.als_max_length := c_region_item_rec.als_max_length;
        l_regionItem_rec.initial_sort_sequence := c_region_item_rec.initial_sort_sequence;
        l_regionItem_rec.customization_application_id := c_region_item_rec.customization_application_id;
        l_regionItem_rec.customization_code := c_region_item_rec.customization_code;
        l_regionItem_rec.attribute_category := c_region_item_rec.attribute_category;
        l_regionItem_rec.attribute1 := c_region_item_rec.attribute1;
        l_regionItem_rec.attribute2 := c_region_item_rec.attribute2;
        l_regionItem_rec.attribute3 := c_region_item_rec.attribute3;
        l_regionItem_rec.attribute4 := c_region_item_rec.attribute4;
        l_regionItem_rec.attribute5 := c_region_item_rec.attribute5;
        l_regionItem_rec.attribute6 := c_region_item_rec.attribute6;
        l_regionItem_rec.attribute7 := c_region_item_rec.attribute7;
        l_regionItem_rec.attribute8 := c_region_item_rec.attribute8;
        l_regionItem_rec.attribute9 := c_region_item_rec.attribute9;
        l_regionItem_rec.attribute10 := c_region_item_rec.attribute10;
        l_regionItem_rec.attribute12 := c_region_item_rec.attribute12;
        l_regionItem_rec.attribute13 := c_region_item_rec.attribute13;
        l_regionItem_rec.attribute14 := c_region_item_rec.attribute14;
        l_regionItem_rec.attribute15 := c_region_item_rec.attribute15;
        l_regionItem_rec.attribute_label_short := c_region_item_rec.attribute_label_short;
        l_regionItem_rec.description := c_region_item_rec.description;

      IF p_Region_Item_Rec.Long_Label IS NULL THEN
        l_label_length := 0;
      ELSE
        l_label_length := LENGTH(p_Region_Item_Rec.Long_Label);
      END IF;

      AK_REGION_ITEMS_PKG.UPDATE_ROW (
        X_REGION_APPLICATION_ID => p_region_application_id,
        X_REGION_CODE => p_region_code,
        X_ATTRIBUTE_APPLICATION_ID => p_Region_Item_Rec.Attribute_Application_Id,
        X_ATTRIBUTE_CODE => p_Region_Item_Rec.Attribute_Code,
        X_DISPLAY_SEQUENCE => p_Region_Item_Rec.Display_Sequence,
        X_NODE_DISPLAY_FLAG => p_Region_Item_Rec.Node_Display_Flag,
        X_NODE_QUERY_FLAG => p_Region_Item_Rec.Queryable_Flag,
        X_ATTRIBUTE_LABEL_LENGTH => l_label_length,
        X_BOLD => l_regionItem_rec.bold,
        X_ITALIC  => l_regionItem_rec.italic,
        X_VERTICAL_ALIGNMENT => l_regionItem_rec.VERTICAL_ALIGNMENT,
        X_HORIZONTAL_ALIGNMENT => l_regionItem_rec.HORIZONTAL_ALIGNMENT,
        X_ITEM_STYLE => l_regionItem_rec.ITEM_STYLE,
        X_OBJECT_ATTRIBUTE_FLAG => l_regionItem_rec.OBJECT_ATTRIBUTE_FLAG,
        X_ATTRIBUTE_LABEL_LONG => p_Region_Item_Rec.Long_Label,
        X_DESCRIPTION => l_regionItem_rec.description,
        X_SECURITY_CODE => l_regionItem_rec.security_code,
        X_UPDATE_FLAG => l_regionItem_rec.UPDATE_FLAG,
        X_REQUIRED_FLAG => p_Region_Item_Rec.Required_Flag,
        X_DISPLAY_VALUE_LENGTH => p_Region_Item_Rec.Display_Length,
        X_LOV_REGION_APPLICATION_ID => l_regionItem_rec.lov_region_application_id,
        X_LOV_REGION_CODE => l_regionItem_rec.lov_region_code,
        X_LOV_FOREIGN_KEY_NAME => l_regionItem_rec.lov_foreign_key_name,
        X_LOV_ATTRIBUTE_APPLICATION_ID => l_regionItem_rec.lov_attribute_application_id,
        X_LOV_ATTRIBUTE_CODE  => l_regionItem_rec.lov_attribute_code,
        X_LOV_DEFAULT_FLAG  => l_regionItem_rec.lov_default_flag,
        X_REGION_DEFAULTING_API_PKG => l_regionItem_rec.region_defaulting_api_pkg,
        X_REGION_DEFAULTING_API_PROC => l_regionItem_rec.region_defaulting_api_proc,
        X_REGION_VALIDATION_API_PKG => l_regionItem_rec.region_validation_api_pkg,
        X_REGION_VALIDATION_API_PROC => l_regionItem_rec.region_validation_api_proc,
        X_ORDER_SEQUENCE  => p_Region_Item_Rec.Sort_Sequence,
        X_ORDER_DIRECTION => p_Region_Item_Rec.Sort_Direction,
        X_DEFAULT_VALUE_VARCHAR2 => l_regionItem_rec.default_value_varchar2,
        X_DEFAULT_VALUE_NUMBER => l_regionItem_rec.default_value_number,
        X_DEFAULT_VALUE_DATE  => l_regionItem_rec.default_value_date,
        X_ITEM_NAME  => l_regionItem_rec.item_name,
        X_DISPLAY_HEIGHT  => l_regionItem_rec.display_height,
        X_SUBMIT  => l_regionItem_rec.submit,
        X_ENCRYPT  => l_regionItem_rec.encrypt,
        X_VIEW_USAGE_NAME  => l_regionItem_rec.view_usage_name,
        X_VIEW_ATTRIBUTE_NAME  => l_regionItem_rec.view_attribute_name,
        X_CSS_CLASS_NAME  => l_regionItem_rec.css_class_name,
        X_CSS_LABEL_CLASS_NAME  => l_regionItem_rec.css_label_class_name,
        X_URL  => p_Region_Item_Rec.Url,
        X_POPLIST_VIEWOBJECT  => l_regionItem_rec.poplist_viewobject,
        X_POPLIST_DISPLAY_ATTRIBUTE  => l_regionItem_rec.poplist_display_attr,
        X_POPLIST_VALUE_ATTRIBUTE  => l_regionItem_rec.poplist_value_attr,
        X_IMAGE_FILE_NAME  => l_regionItem_rec.image_file_name,
        X_NESTED_REGION_CODE  => l_regionItem_rec.nested_region_code,
        X_NESTED_REGION_APPL_ID => l_regionItem_rec.nested_region_application_id,
        X_MENU_NAME   =>l_regionItem_rec.menu_name,
        X_FLEXFIELD_NAME   => l_regionItem_rec.flexfield_name,
        X_FLEXFIELD_APPLICATION_ID   => l_regionItem_rec.flexfield_application_id,
        X_TABULAR_FUNCTION_CODE   => l_regionItem_rec.tabular_function_code,
        X_TIP_TYPE   => l_regionItem_rec.tip_type,
        X_TIP_MESSAGE_NAME   => l_regionItem_rec.tip_message_name,
        X_TIP_MESSAGE_APPLICATION_ID   => l_regionItem_rec.tip_message_application_id,
        X_FLEX_SEGMENT_LIST   => l_regionItem_rec.flex_segment_list,
        X_ENTITY_ID   => l_regionItem_rec.entity_id,
        X_ANCHOR   => l_regionItem_rec.anchor,
        X_POPLIST_VIEW_USAGE_NAME   => l_regionItem_rec.poplist_view_usage_name,
        X_USER_CUSTOMIZABLE   => l_regionItem_rec.user_customizable,
        X_ADMIN_CUSTOMIZABLE   => l_regionItem_rec.admin_customizable,
        X_INVOKE_FUNCTION_NAME   => l_regionItem_rec.invoke_function_name,
        X_EXPANSION  =>l_regionItem_rec.expansion,
        X_ALS_MAX_LENGTH  => l_regionItem_rec.als_max_length,
        X_SORTBY_VIEW_ATTRIBUTE_NAME  =>l_regionItem_rec.sortby_view_attribute_name,
        X_ICX_CUSTOM_CALL   => l_regionItem_rec.icx_custom_call,
        X_INITIAL_SORT_SEQUENCE  => p_Region_Item_Rec.Initial_Sort_Sequence,
        X_CUSTOMIZATION_APPLICATION_ID   => l_regionItem_rec.customization_application_id,
        X_CUSTOMIZATION_CODE   => l_regionItem_rec.customization_code,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => C_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1 => p_Region_Item_Rec.Attribute_Type,
        X_ATTRIBUTE2 => p_Region_Item_Rec.Measure_Level,
        X_ATTRIBUTE3 => p_Region_Item_Rec.Base_Column,
        X_ATTRIBUTE4 => p_Region_Item_Rec.Lov_Where_Clause,
        X_ATTRIBUTE5 => p_Region_Item_Rec.Graph_Position,
        X_ATTRIBUTE6 => p_Region_Item_Rec.Graph_Style,
        X_ATTRIBUTE7 => p_Region_Item_Rec.Display_Format,
        X_ATTRIBUTE8 => p_Region_Item_Rec.Schedule,
        X_ATTRIBUTE9 => p_Region_Item_Rec.Aggregate_Function,
        X_ATTRIBUTE10 => p_Region_Item_Rec.Display_Total,
        X_ATTRIBUTE11 => p_Region_Item_Rec.Override_Hierarchy,
        X_ATTRIBUTE12 => NULL,
        X_ATTRIBUTE13 => p_Region_Item_Rec.Variance,
        X_ATTRIBUTE14 => p_Region_Item_Rec.Display_Type,
        X_ATTRIBUTE15 => p_Region_Item_Rec.Lov_Table);

      IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
      END IF;

    END IF;
    CLOSE cRegionItem;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ROW: ' || SQLERRM;
    END IF;

END UPDATE_REGION_ITEM_ROW;

-- nbarik - 04/05/04 - Enh 3546750 - BSC/PMV Integration - Added p_commit
PROCEDURE DELETE_REGION_ITEM_ROW
(p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_ATTRIBUTE_CODE       in VARCHAR2
,p_ATTRIBUTE_APPLICATION_ID     in NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
,p_commit               IN  VARCHAR2   := FND_API.G_FALSE
 ) IS
BEGIN

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  AK_REGION_ITEMS_PKG.DELETE_ROW(
    X_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
    X_REGION_CODE => p_REGION_CODE,
    X_ATTRIBUTE_APPLICATION_ID => p_ATTRIBUTE_APPLICATION_ID,
    X_ATTRIBUTE_CODE => p_ATTRIBUTE_CODE
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW: ' || SQLERRM;
    end if;

END DELETE_REGION_ITEM_ROW;


PROCEDURE DELETE_REGION_AND_REGION_ITEMS(
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

begin

    delete_region_items(
            p_REGION_CODE  => p_REGION_CODE,
            p_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data =>x_msg_data);


    BIS_AK_REGION_PUB.DELETE_REGION_ROW(
        p_REGION_CODE => p_REGION_CODE ,
        p_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data =>x_msg_data);

    delete_ext_region_items(
            p_REGION_CODE  => p_REGION_CODE,
            p_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data =>x_msg_data);

    BIS_REGION_EXTENSION_PVT.DELETE_REGION_EXTN_RECORD(
        p_commit => FND_API.G_FALSE,
        pRegionCode => p_REGION_CODE,
        pRegionAppId => p_REGION_APPLICATION_ID);

    BIS_CUSTOMIZATIONS_PVT.delete_region_customizations
    ( p_region_code  => p_region_code
    , p_region_application_id => p_region_application_id
    , x_return_status => x_return_status
    , x_msg_count => x_msg_count
    , x_msg_data => x_msg_data
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.DELETE_REGION_AND_REGION_ITEMS: ' || SQLERRM;
    end if;


END DELETE_REGION_AND_REGION_ITEMS;


PROCEDURE DELETE_REGION_ITEMS (
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

cursor items_cursor IS
    select attribute_code, attribute_application_id
    from ak_region_items
    where region_code = p_REGION_CODE
    and region_application_id = p_REGION_APPLICATION_ID;

begin
    if items_cursor%ISOPEN then
            close items_cursor;
    end if;

    for cr in items_cursor loop
        BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW(
                p_REGION_CODE => p_REGION_CODE,
                p_REGION_APPLICATION_ID => p_REGION_APPLICATION_ID,
                p_ATTRIBUTE_CODE => cr.attribute_code,
                p_ATTRIBUTE_APPLICATION_ID => cr.attribute_application_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data =>x_msg_data);
    end loop;

    if items_cursor%ISOPEN then
            close items_cursor;
    end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := 'BIS_AK_REGION_PUB.DELETE_REGION_ITEMS: ' || SQLERRM;
    end if;


END DELETE_REGION_ITEMS;

PROCEDURE DELETE_EXT_REGION_ITEMS (
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

cursor items_cursor IS
    select attribute_code, attribute_application_id
    from bis_ak_region_item_extension
    where region_code = p_REGION_CODE
    and region_application_id = p_REGION_APPLICATION_ID;

begin
    if items_cursor%ISOPEN then
            close items_cursor;
    end if;

    for cr in items_cursor loop
        BIS_REGION_ITEM_EXTENSION_PVT.DELETE_REGION_ITEM_RECORD(
            p_commit => FND_API.G_FALSE,
                pRegionCode => p_REGION_CODE,
                pRegionAppId => p_REGION_APPLICATION_ID,
                pAttributeCode => cr.attribute_code,
                pAttributeAppId => cr.attribute_application_id);
    end loop;

    if items_cursor%ISOPEN then
            close items_cursor;
    end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_AK_REGION_PUB.DELETE_EXT_ITEMS: ' || SQLERRM;
    end if;


END DELETE_EXT_REGION_ITEMS;


function VALID_DATABASE_OBJECT (
 P_DATABASE_OBJECT_NAME IN VARCHAR2) return boolean IS

l_count     number;
l_valid     boolean;

begin

    -- mdamle 07/22/04 - Enh#3786101 - Consider Materialized view as a valid database object
    select count(1) into l_count from user_objects
    where object_type in ('VIEW', 'MATERIALIZED VIEW','SYNONYM')
    and object_name = p_database_object_name;

    if (l_count > 0) then
        l_valid := true;
    else
        l_valid := false;
    end if;

    return l_valid;

end VALID_DATABASE_OBJECT;

function AK_OBJECT_EXISTS(
 P_DATABASE_OBJECT_NAME IN VARCHAR2) return boolean IS

l_count     number;
l_exists    boolean;

begin

    SELECT  count(1) into l_count
    FROM ak_objects
    WHERE database_object_name = P_DATABASE_OBJECT_NAME;

        IF l_count > 0 THEN
        l_exists := true;
    else
        l_exists := false;
    end if;

    return l_exists;
end AK_OBJECT_EXISTS;


procedure INSERT_AK_OBJECT (
 P_DATABASE_OBJECT_NAME IN VARCHAR2
,P_APPLICATION_ID IN NUMBER) IS

l_object_rowid          varchar2(50);
begin
    -- Insert into Objects
    AK_OBJECTS_PKG.INSERT_ROW(
        X_ROWID => l_object_rowid,
        X_DATABASE_OBJECT_NAME => upper(P_DATABASE_OBJECT_NAME),
        X_APPLICATION_ID => P_APPLICATION_ID,
        X_NAME => SUBSTR(P_DATABASE_OBJECT_NAME, 1, 23),  -- bug#4289493
        X_DESCRIPTION => null,
        X_PRIMARY_KEY_NAME => null,
        X_DEFAULTING_API_PKG => null,
        X_DEFAULTING_API_PROC => null,
        X_VALIDATION_API_PKG => null,
        X_VALIDATION_API_PROC => null,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_ATTRIBUTE_CATEGORY => null,
        X_ATTRIBUTE1 => null,
        X_ATTRIBUTE2 => null,
        X_ATTRIBUTE3 => null,
        X_ATTRIBUTE4 => null,
        X_ATTRIBUTE5 => null,
        X_ATTRIBUTE6 => null,
        X_ATTRIBUTE7 => null,
        X_ATTRIBUTE8 => null,
        X_ATTRIBUTE9 => null,
        X_ATTRIBUTE10 => null,
        X_ATTRIBUTE11 => null,
        X_ATTRIBUTE12 => null,
        X_ATTRIBUTE13 => null,
        X_ATTRIBUTE14 => null,
        X_ATTRIBUTE15 => null);

end INSERT_AK_OBJECT;


PROCEDURE GET_REGION_ITEM_REC
(  p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , x_Region_Item_Rec              OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS
CURSOR cRegionItem IS
SELECT  display_sequence,
  node_display_flag,
  required_flag,
  node_query_flag,
  display_value_length,
  attribute_label_long,
  order_sequence,
  initial_sort_sequence,
  order_direction,
  url,
  attribute1,
  attribute7,
  attribute14,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute15,
  attribute9,
  attribute10,
  attribute13,
  attribute8,
  attribute11
 FROM ak_region_items_vl
 WHERE region_code = p_region_code
 AND region_application_id = p_region_application_id
 AND attribute_code = p_Attribute_Code
 AND attribute_application_id = p_Attribute_Application_Id;

BEGIN
    -- Save the current data
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    x_Region_Item_Rec.Attribute_Code := p_Attribute_Code;
    x_Region_Item_Rec.Attribute_Application_Id := p_Attribute_Application_Id;
    IF cRegionItem%ISOPEN THEN
       CLOSE cRegionItem;
    END IF;
        OPEN cRegionItem;
        FETCH cRegionItem INTO
        x_Region_Item_Rec.Display_Sequence,
        x_Region_Item_Rec.Node_Display_Flag,
        x_Region_Item_Rec.Required_Flag,
        x_Region_Item_Rec.Queryable_Flag,
        x_Region_Item_Rec.Display_Length,
        x_Region_Item_Rec.Long_Label,
        x_Region_Item_Rec.Sort_Sequence,
        x_Region_Item_Rec.Initial_Sort_Sequence,
        x_Region_Item_Rec.Sort_Direction,
        x_Region_Item_Rec.Url,
        x_Region_Item_Rec.Attribute_Type,
        x_Region_Item_Rec.Display_Format,
        x_Region_Item_Rec.Display_Type,
        x_Region_Item_Rec.Measure_Level,
        x_Region_Item_Rec.Base_Column,
        x_Region_Item_Rec.Lov_Where_Clause,
        x_Region_Item_Rec.Graph_Position,
        x_Region_Item_Rec.Graph_Style,
        x_Region_Item_Rec.Lov_Table,
        x_Region_Item_Rec.Aggregate_Function,
        x_Region_Item_Rec.Display_Total,
        x_Region_Item_Rec.Variance,
        x_Region_Item_Rec.Schedule,
        x_Region_Item_Rec.Override_Hierarchy;
    CLOSE cRegionItem;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.GET_REGION_ITEM_REC: ' || SQLERRM;
    END IF;
END GET_REGION_ITEM_REC;


--deprecated, call the next one with p_type parameter
PROCEDURE UPDATE_REGION_ITEM_ATTR
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , p_Short_Name                   IN         VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS

 l_Region_Item_Rec     BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
 l_measure_short_name  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE;
 l_measure_name        Bisbv_Performance_Measures.MEASURE_NAME%TYPE;
 l_msg_data            VARCHAR2(300);
 l_msg_count           NUMBER;
 l_ret_status          VARCHAR2(10);

BEGIN
    -- Save the current data
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ATTR
    (  p_commit                       => p_commit
     , p_region_code                  => p_region_code
     , p_region_application_id        => p_region_application_id
     , p_Attribute_Code               => p_Attribute_Code
     , p_Attribute_Application_Id     => p_Attribute_Application_Id
     , p_Short_Name                   => p_Short_Name
     , p_type                         => NULL
     , p_Meas_Name            => NULL
     , x_return_status                => x_return_status
     , x_msg_count                    => x_msg_count
     , x_msg_data                     => x_msg_data
    );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ATTR: ' || SQLERRM;
    END IF;
END UPDATE_REGION_ITEM_ATTR;

--bug#3859267: overloaded to take in p_type, which is one of
--C_MEASURE, C_MEASURE_NO_TARGET, or C_COMPARE_TO_MEASURE_NO_TARGET
PROCEDURE UPDATE_REGION_ITEM_ATTR
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , p_Short_Name                   IN         VARCHAR2
 , p_type                         IN         VARCHAR2
 , p_Meas_Name            IN         VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
) IS

 l_Region_Item_Rec     BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type;
 l_measure_short_name  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE;
 l_measure_name        Bisbv_Performance_Measures.MEASURE_NAME%TYPE;
 l_msg_data            VARCHAR2(300);
 l_msg_count           NUMBER;
 l_ret_status          VARCHAR2(10);
 l_type                VARCHAR2(30);

BEGIN
    -- Save the current data
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --make sure p_type is recognized
    IF ((p_type IS NOT NULL) AND
        (p_type <> BIS_AK_REGION_PUB.C_MEASURE) AND
        (p_type <> BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET) AND
        (p_type <> BIS_AK_REGION_PUB.C_COMPARE_TO_MEASURE_NO_TARGET)) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BIS_AK_REGION_PUB.GET_REGION_ITEM_REC
        (  p_region_code          => p_region_code
     , p_region_application_id => p_region_application_id
     , p_Attribute_Code        => p_Attribute_Code
     , p_Attribute_Application_Id => p_Attribute_Application_Id
     , x_Region_Item_Rec       => l_Region_Item_Rec
     , x_return_status        => l_ret_status
     , x_msg_count            => l_msg_count
     , x_msg_data             => l_msg_data
     );

     IF ((l_ret_status IS NOT NULL) AND (l_ret_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    --set type
    IF (p_type IS NULL) THEN
      l_type := BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET;
    ELSE
      l_type := p_type;
    END IF;

    --check attribute1
    IF (BIS_UTILITIES_PUB.Value_Missing(l_Region_Item_Rec.Attribute_Type) = FND_API.G_TRUE) THEN
      l_Region_Item_Rec.Attribute_Type := BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET;
    END IF;

    --set attribute2
    IF (BIS_UTILITIES_PUB.Value_Missing(p_Short_Name) = FND_API.G_TRUE) THEN
      l_Region_Item_Rec.Measure_Level  := NULL;
      IF (IS_COMPARE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) THEN
        l_Region_Item_Rec.Attribute_Type := NULL;
      END IF;
    ELSE
      IF ((BIS_UTILITIES_PUB.Value_Missing(l_Region_Item_Rec.Measure_Level) = FND_API.G_TRUE) OR
          (COMPARE_TYPE_AND_SHORTNAME(l_Region_Item_Rec.Attribute_Type, l_Region_Item_Rec.Measure_Level, l_type, p_Short_Name) = TRUE) OR
          ((IS_MEASURE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) AND
           (VALIDATE_MEASURE(p_short_name=>l_Region_Item_Rec.Measure_Level, x_measure_short_name=>l_measure_short_name, x_measure_name=>l_measure_name) = FALSE)) OR
          ((IS_COMPARE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) AND
           (VALIDATE_COMPARE(p_region_code=>p_region_code, p_region_app_id=>p_region_application_id, p_compare_code=>l_Region_Item_Rec.Measure_Level, x_measure_short_name=>l_measure_short_name, x_measure_name=>l_measure_name) = FALSE))) THEN

            l_Region_Item_Rec.Attribute_Type := l_type;
            l_Region_Item_Rec.Measure_Level  := p_Short_Name;

            IF (BIS_UTILITIES_PUB.Value_Missing(l_Region_Item_Rec.Long_Label) = FND_API.G_TRUE) THEN
              l_Region_Item_Rec.Long_Label := substrb(p_Meas_Name, 1, 80);
            END IF;
        --special handlings for view-based report:
        IF (IS_VIEW_BASED_REPORT(p_region_code, p_region_application_id) = FND_API.G_TRUE) THEN

          --bug#4018318: set node_display_flag to 'N' for compare type for view based report
          IF (IS_COMPARE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) THEN
            l_Region_Item_Rec.Node_Display_Flag :=  'N';
          END IF;

          --bug#4028958: need to handle aggregation function for view based report
          --if aggregate function is null, need to populate it according to description in bug#4028958
          IF (l_Region_Item_Rec.Aggregate_Function IS NULL OR (IS_COMPARE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE)) THEN

            --handle measure type here:
            IF (IS_MEASURE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) THEN
              --if veiw based and view by report, for measure type, if attribute9 is null, set it to 'SUM'
              IF (IS_VIEW_BY_REPORT(p_region_code, p_region_application_id) = FND_API.G_TRUE) THEN
                l_Region_Item_Rec.Aggregate_Function := BIS_AK_REGION_PUB.C_SUM;
              ELSIF (IS_AGGREGATE_DEFINED(p_region_code, p_region_application_id) = FND_API.G_TRUE) THEN
              --if view based and non-view by report, for measure type, if attribute9 is null,
              --check if any other column in the same report has non-null attribute9, is so, set this measure column to 'SUM'
                l_Region_Item_Rec.Aggregate_Function := BIS_AK_REGION_PUB.C_SUM;
              END IF;

            --handle compare type here:
            ELSIF (IS_COMPARE_TYPE(l_Region_Item_Rec.Attribute_Type) = TRUE) THEN
              --if view based report, and attribute9 is null, always sync up with measure column's attribute9
              l_Region_Item_Rec.Aggregate_Function := GET_COMPARE_AGG_FUNCTION(p_region_code, p_region_application_id, l_Region_Item_Rec.Measure_Level);
            END IF;
          END IF;
        END IF;

      END IF;
    END IF;

    BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ROW
    ( p_commit => p_commit
      , p_region_code => p_region_code
      , p_region_application_id => p_region_application_id
      , p_Region_Item_Rec => l_Region_Item_Rec
      , x_return_status => x_return_status
      , x_msg_count => x_msg_count
      , x_msg_data => x_msg_data
     );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := 'BIS_AK_REGION_PUB.UPDATE_REGION_ITEM_ATTR: ' || SQLERRM;
    END IF;
END UPDATE_REGION_ITEM_ATTR;

PROCEDURE LOCK_REGION_ROW
(  p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_last_update_date             IN         VARCHAR2
 , x_record_status                OUT NOCOPY VARCHAR2
) IS

 l_last_update_date    date;

 cursor cRegion is select last_update_date
 from ak_regions
 where region_code = p_region_code
 and region_application_id = p_region_application_id
 for update of region_application_id nowait;

BEGIN

    SAVEPOINT SP_LOCK_REGION_ROW;

    IF cRegion%ISOPEN THEN
       CLOSE cRegion;
    END IF;
    OPEN cRegion;
    FETCH cRegion INTO l_last_update_date;

    if (cRegion%notfound) then
    x_record_status := BIS_AK_REGION_PUB.c_RECORD_DELETED;
    end if;

    if p_last_update_date is not null then
    if p_last_update_date <> TO_CHAR(l_last_update_date, BIS_AK_REGION_PUB.C_LAST_UPDATE_DATE_FORMAT) then
            x_record_status := BIS_AK_REGION_PUB.c_RECORD_CHANGED;
    end if;
    end if;

    rollback to SP_LOCK_REGION_ROW;

    CLOSE cRegion;

EXCEPTION
  WHEN OTHERS THEN
    close cRegion;
    x_record_status := BIS_AK_REGION_PUB.c_RECORD_CHANGED;
    rollback  to SP_LOCK_REGION_ROW;
END LOCK_REGION_ROW;

-- ankgoel: bug#3937907 - Verify if AK data will be modified or not for the current source and compare-to column only
-- SC   - Source Column modified
-- CC   - Compare-to Column modified
-- SSCC - Both Source and Compare-to columns modified
FUNCTION AK_DATA_SET(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_source_code         IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_compare_code        IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_measure_short_name  IN  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
) RETURN VARCHAR2
IS
  ak_sc_modify  BOOLEAN := TRUE;
  ak_cc_modify  BOOLEAN := TRUE;
  ak_modify      VARCHAR2(10) := 'SCCC';
  l_measure_short_name  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE;
  l_measure_name        Bisbv_Performance_Measures.MEASURE_NAME%TYPE;

  CURSOR attribute_cur(p_attr_code VARCHAR2) IS
    SELECT a.attribute2
    FROM ak_region_items a
    WHERE a.region_code = p_region_code
    AND a.region_application_id = p_region_app_id
    AND a.attribute1 IN ('MEASURE', 'MEASURE_NOTARGET')
    AND a.attribute_code = p_attr_code
    AND a.attribute2 = p_measure_short_name;

  CURSOR compare_col_cur IS
    SELECT sc.attribute2
    FROM ak_region_items sc, ak_region_items cc
    WHERE sc.region_code = p_region_code
    AND sc.region_code = cc.region_code
    AND sc.region_application_id = p_region_app_id
    AND (sc.attribute1 IN ('MEASURE','MEASURE_NOTARGET') AND sc.attribute_code = p_source_code)
    AND (cc.attribute1 = 'COMPARE_TO_MEASURE_NO_TARGET' AND cc.attribute_code = p_compare_code)
    AND sc.attribute_code = cc.attribute2
    AND sc.attribute2 = p_measure_short_name;

BEGIN

    FOR rec IN attribute_cur(p_source_code) LOOP
      ak_sc_modify := FALSE;
    END LOOP;

    IF (p_compare_code IS NOT NULL) THEN
      FOR rec IN compare_col_cur LOOP
    ak_cc_modify := FALSE;
      END LOOP;
      FOR rec IN attribute_cur(p_compare_code) LOOP
        ak_cc_modify := FALSE;
      END LOOP;
    ELSE
      ak_cc_modify := FALSE;
    END IF;

    IF((ak_sc_modify) AND (ak_cc_modify)) THEN
      ak_modify := 'SCCC';
    ELSIF (ak_sc_modify) THEN
      ak_modify := 'SC';
    ELSIF (ak_cc_modify) THEN
      ak_modify := 'CC';
    ELSE
      ak_modify := NULL;
    END IF;

    RETURN ak_modify;
EXCEPTION
    WHEN OTHERS THEN
      RETURN 'SCCC';
END AK_DATA_SET;

--return 'T' if given report is view based, 'F' otherwise
FUNCTION IS_VIEW_BASED_REPORT(
  p_region_code         IN  Ak_Regions.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Regions.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2
IS
 l_attribute10  Ak_Regions.ATTRIBUTE10%TYPE;
 l_ret_val      VARCHAR2(1) := FND_API.G_FALSE;
BEGIN
 SELECT attribute10 INTO l_attribute10
 FROM ak_regions
 WHERE region_code = p_region_code
 AND region_application_id = p_region_app_id;

 IF (l_attribute10 IS NULL) THEN
   l_ret_val := FND_API.G_TRUE;
 ELSE
   l_ret_val := FND_API.G_FALSE;
 END IF;

 RETURN l_ret_val;
EXCEPTION
 WHEN OTHERS THEN
   RETURN  FND_API.G_FALSE;
END IS_VIEW_BASED_REPORT;


--return 'T' if given report is view-by, 'F' otherwise
FUNCTION IS_VIEW_BY_REPORT(
  p_region_code         IN  Ak_Regions.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Regions.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2
IS
 l_attribute1   Ak_Regions.ATTRIBUTE1%TYPE;
 l_ret_val      VARCHAR2(1) := FND_API.G_TRUE;
BEGIN
 SELECT attribute1 INTO l_attribute1
 FROM ak_regions
 WHERE region_code = p_region_code
 AND region_application_id = p_region_app_id;

 IF ((l_attribute1 = 'N') OR (l_attribute1 IS NULL)) THEN
   l_ret_val := FND_API.G_TRUE;
 ELSIF (l_attribute1 = 'Y') THEN
   l_ret_val := FND_API.G_FALSE;
 END IF;

 RETURN l_ret_val;
EXCEPTION
 WHEN OTHERS THEN
   RETURN FND_API.G_TRUE;
END IS_VIEW_BY_REPORT;

--return 'T' if at least one aggregate function is defined in any column
--for the given report, 'F' otherwise
FUNCTION IS_AGGREGATE_DEFINED(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2
IS
 l_count        NUMBER := 0;
 l_ret_val      VARCHAR2(1) := FND_API.G_FALSE;
BEGIN
 SELECT COUNT(0) INTO l_count
 FROM ak_region_items
 WHERE region_code = p_region_code
 AND region_application_id = p_region_app_id
 AND attribute9 IS NOT NULL;

 IF (l_count > 0) THEN
   l_ret_val := FND_API.G_TRUE;
 END IF;

 RETURN l_ret_val;
EXCEPTION
 WHEN OTHERS THEN
   RETURN FND_API.G_FALSE;
END IS_AGGREGATE_DEFINED;

-- added for Bug#4448994 and as a general utility file.
PROCEDURE Get_Region_Code_TL_Data (
    p_Region_Code              IN         Ak_Regions.REGION_CODE%TYPE
  , p_Region_Application_Id    IN         Ak_Regions.REGION_APPLICATION_ID%TYPE
  , x_Region_Name              OUT NOCOPY Ak_Regions_Tl.NAME%TYPE
  , x_Region_Description       OUT NOCOPY Ak_Regions_Tl.DESCRIPTION%TYPE
  , x_Region_Created_By        OUT NOCOPY Ak_Regions_Tl.CREATED_BY%TYPE
  , x_Region_Creation_Date     OUT NOCOPY Ak_Regions_Tl.CREATION_DATE%TYPE
  , x_Region_Last_Updated_By   OUT NOCOPY Ak_Regions_Tl.LAST_UPDATED_BY%TYPE
  , x_Region_Last_Update_Date  OUT NOCOPY Ak_Regions_Tl.LAST_UPDATE_DATE%TYPE
  , x_Region_Last_Update_Login OUT NOCOPY Ak_Regions_Tl.LAST_UPDATE_LOGIN%TYPE
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
) IS
    CURSOR c_AkRegionsTl IS
    SELECT
        A.REGION_CODE
      , A.REGION_APPLICATION_ID
      , A.NAME
      , A.DESCRIPTION
      , A.CREATED_BY
      , A.CREATION_DATE
      , A.LAST_UPDATED_BY
      , A.LAST_UPDATE_DATE
      , A.LAST_UPDATE_LOGIN
    FROM  AK_REGIONS_VL A
    WHERE A.REGION_CODE           = p_Region_Code
    AND   A.REGION_APPLICATION_ID = p_Region_Application_Id;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR c_AkRTl IN c_AkRegionsTl LOOP
        x_Region_Name               := c_AkRTl.NAME;
        x_Region_Description        := c_AkRTl.DESCRIPTION;
        x_Region_Created_By         := c_AkRTl.CREATED_BY;
        x_Region_Creation_Date      := c_AkRTl.CREATION_DATE;
        x_Region_Last_Updated_By    := c_AkRTl.LAST_UPDATED_BY;
        x_Region_Last_Update_Date   := c_AkRTl.LAST_UPDATE_DATE;
        x_Region_Last_Update_Login  := c_AkRTl.LAST_UPDATE_LOGIN;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        IF (x_msg_data IS NULL) THEN
            x_msg_data := SQLERRM || ' at BIS_AK_REGION_PUB.Get_Region_Code_TL_Data ';
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Get_Region_Code_TL_Data;

-- Bug#5256605 : Reset the display sequence of AK Region Items
-- starting from -1 down below. This is done before updating all AK Items.
PROCEDURE reset_ak_items_display_seq (
  p_region_code                  IN VARCHAR2
, p_region_application_id        IN NUMBER
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
  l_counter  NUMBER;
  CURSOR cr_items IS
    SELECT attribute_code, attribute_application_id
    FROM  ak_region_items
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;

BEGIN
  IF cr_items%ISOPEN THEN
    CLOSE cr_items;
  END IF;

  l_counter := -1;
  FOR cr IN cr_items LOOP
    UPDATE ak_region_items
      SET display_sequence = l_counter
      WHERE attribute_code = cr.attribute_code
      AND   attribute_application_id = cr.attribute_application_id
      AND   region_code = p_region_code
      AND   region_application_id = p_region_application_id;
    l_counter := l_counter - 1;
  END LOOP;

  IF cr_items%ISOPEN THEN
    CLOSE cr_items;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF cr_items%ISOPEN THEN
      CLOSE cr_items;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
  WHEN OTHERS THEN
    IF cr_items%ISOPEN THEN
      CLOSE cr_items;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
  IF (x_msg_data IS NULL) THEN
    x_msg_data := 'BIS_AK_REGION_PUB.reset_ak_items_display_seq: ' || SQLERRM;
  END IF;
END reset_ak_items_display_seq;

END BIS_AK_REGION_PUB;

/
